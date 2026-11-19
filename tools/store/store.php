<?php
/*
 * store.php: a thin read/write store over HTTPS for the project's workers (Cloud, Local, Intel, GPT, the owner).
 *
 * One file, no database, no shell. Each worker sends its own token in the X-Store-Token header (or as
 * "Authorization: Bearer <token>"). The store keeps files in a data folder outside the web root, so nothing in it is
 * reachable except through this script. Every write is logged with the worker's name and the time.
 *
 * Who may do what (see README.md). A worker's name is its token's name in config.php's 'workers'.
 *   workers/<you>/...  read: everyone   create or replace, append, delete: you only
 *   flags/<you>/...    read: everyone   create or replace, append, delete: you only
 *   cited/...          read: everyone   create once (never overwritten, never deleted): anyone
 *   log/...            read: everyone   append only: anyone
 * and, since the data folder is the project folder (scratch/rule30reset/ on the website), at its top:
 *   postbox/<you>/...       read: everyone   create or replace, delete: you only (your first file makes the postbox)
 *   postbox/<other>/F.flag  read: everyone   create once: any worker, if <other> has joined and F names the sender:
 *                                            <yyyymmdd>T<hhmm>Z-<sender>-<post>-<KIND>.flag (no subfolders)
 *   share-scratch/<you>/... read: everyone   create or replace, append, delete: you only
 *   anything else      read: everyone   nothing else
 *
 * Requests (all over HTTPS):
 *   GET    store.php?whoami                 -> {"worker": "..."}
 *   GET    store.php?list=<dir>             -> JSON listing ("" or omitted for the top)
 *   GET    store.php?stat=<path>            -> {"path", "bytes", "mtime", "sha256"}
 *   GET    store.php?path=<path>            -> the file's bytes
 *   PUT    store.php?path=<path>   (body)   -> create or replace; {"path", "bytes", "sha256"}
 *   POST   store.php?append=<path> (body)   -> append; {"path", "bytes", "sha256"} of what was appended
 *   DELETE store.php?path=<path>            -> remove one file in your own area
 * Hosts that block PUT or DELETE: POST store.php?put=<path> and POST store.php?delete=<path> do the same.
 */
declare(strict_types=1);

const AREAS_OWNED = ['workers', 'flags'];
// The project's areas, at the top of the data folder: data_dir in config.php is the project folder itself.
const PROJECT_AREAS = ['postbox', 'share-scratch'];
const FLAG_MAX_BYTES = 16384;

$configPath = getenv('SHAREDSTORE_CONFIG') ?: __DIR__ . '/../../sharedstore-private/config.php';
if (!is_file($configPath)) {
    fail(500, 'store not configured');
}
$cfg = require $configPath;
$dataDir = rtrim((string)$cfg['data_dir'], '/');
if (!is_dir($dataDir)) {
    fail(500, 'data folder missing');
}

header('Cache-Control: no-store');
header('X-Content-Type-Options: nosniff');

if (!empty($cfg['require_https']) && !is_https(!empty($cfg['trust_forwarded_proto']))) {
    fail(403, 'HTTPS required');
}

$worker = authenticate($cfg);
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
if ($method === 'POST' && isset($_GET['put'])) {
    $method = 'PUT';
    $_GET['path'] = $_GET['put'];
} elseif ($method === 'POST' && isset($_GET['delete'])) {
    $method = 'DELETE';
    $_GET['path'] = $_GET['delete'];
}

if ($method === 'GET' && isset($_GET['whoami'])) {
    reply(['worker' => $worker]);
}
if ($method === 'GET' && isset($_GET['list'])) {
    $rel = (string)$_GET['list'];
    $dir = $rel === '' ? $dataDir : $dataDir . '/' . no_links($dataDir, clean_path($rel));
    if (!is_dir($dir)) {
        fail(404, 'no such folder');
    }
    $out = [];
    foreach (scandir($dir) as $name) {
        $full = $dir . '/' . $name;
        if ($name[0] === '.' || is_link($full)) {
            continue;
        }
        $out[] = is_dir($full)
            ? ['name' => $name, 'type' => 'dir']
            : ['name' => $name, 'type' => 'file', 'bytes' => filesize($full), 'mtime' => gmdate('c', filemtime($full))];
    }
    reply(['folder' => $rel, 'entries' => $out]);
}
if ($method === 'GET' && isset($_GET['stat'])) {
    $rel = no_links($dataDir, clean_path((string)$_GET['stat']));
    $full = $dataDir . '/' . $rel;
    if (!is_file($full)) {
        fail(404, 'no such file');
    }
    reply(['path' => $rel, 'bytes' => filesize($full), 'mtime' => gmdate('c', filemtime($full)),
           'sha256' => hash_file('sha256', $full)]);
}
if ($method === 'GET' && isset($_GET['path'])) {
    $rel = no_links($dataDir, clean_path((string)$_GET['path']));
    $full = $dataDir . '/' . $rel;
    if (!is_file($full)) {
        fail(404, 'no such file');
    }
    header('Content-Type: application/octet-stream');
    header('Content-Length: ' . filesize($full));
    readfile($full);
    exit;
}
if ($method === 'PUT' && isset($_GET['path'])) {
    $rel = no_links($dataDir, clean_path((string)$_GET['path']));
    [$mode, $limit, $exists] = put_rule($worker, $rel, $dataDir, (int)$cfg['max_bytes']);
    $createOnly = $mode === 'create';
    $full = $dataDir . '/' . $rel;
    ensure_parent($full);
    [$tmp, $bytes, $sha] = receive_body($full, $limit);
    $lock = lock($dataDir, $tmp);
    within_quota($cfg, $dataDir, $tmp, $bytes, $lock);
    if ($createOnly && file_exists($full)) {
        unlink($tmp);
        flock($lock, LOCK_UN);
        fail(409, $exists);
    }
    if (is_dir($full) || !rename($tmp, $full)) {
        @unlink($tmp);
        flock($lock, LOCK_UN);
        fail(500, 'could not store the file');
    }
    flock($lock, LOCK_UN);
    log_write($cfg, $worker, 'put', $rel, $bytes, $sha);
    reply(['path' => $rel, 'bytes' => $bytes, 'sha256' => $sha]);
}
if ($method === 'POST' && isset($_GET['append'])) {
    $rel = no_links($dataDir, clean_path((string)$_GET['append']));
    $place = project_place($rel);
    $ownShare = $place !== null && $place[0] === 'share-scratch' && $place[1] === $worker;
    if (!(area_of($rel) === 'log' || owns($worker, $rel) || $ownShare)) {
        fail(403, 'you may not append here');
    }
    $full = $dataDir . '/' . $rel;
    ensure_parent($full);
    [$tmp, $bytes, $sha] = receive_body($full, (int)$cfg['max_bytes']);
    $lock = lock($dataDir, $tmp);
    within_quota($cfg, $dataDir, $tmp, $bytes, $lock);
    clearstatcache(true, $full);
    $existed = is_file($full);
    $before = $existed ? filesize($full) : 0;
    $out = fopen($full, 'ab');
    $in = fopen($tmp, 'rb');
    $ok = $out !== false && $in !== false && flock($out, LOCK_EX)
        && stream_copy_to_stream($in, $out) === $bytes && on_disk($out);
    if (!$ok && $out !== false) {
        // The file goes back to what it was: its previous complete data, or no file at all.
        ftruncate($out, $before);
        fflush($out);
    }
    if ($out !== false) {
        flock($out, LOCK_UN);
        fclose($out);
    }
    if ($in !== false) {
        fclose($in);
    }
    @unlink($tmp);
    if (!$ok) {
        if (!$existed) {
            @unlink($full);
        }
        flock($lock, LOCK_UN);
        fail(507, 'could not append on disk: the file is as it was');
    }
    flock($lock, LOCK_UN);
    log_write($cfg, $worker, 'append', $rel, $bytes, $sha);
    reply(['path' => $rel, 'bytes' => $bytes, 'sha256' => $sha]);
}
if ($method === 'DELETE' && isset($_GET['path'])) {
    $rel = no_links($dataDir, clean_path((string)$_GET['path']));
    $place = project_place($rel);
    if (!(owns($worker, $rel) || ($place !== null && $place[1] === $worker))) {
        fail(403, 'you may delete only in your own area');
    }
    $full = $dataDir . '/' . $rel;
    if (!is_file($full)) {
        fail(404, 'no such file');
    }
    unlink($full);
    log_write($cfg, $worker, 'delete', $rel, 0, '');
    reply(['deleted' => $rel]);
}
fail(400, 'unknown request');


function reply(array $body, int $status = 200): never
{
    http_response_code($status);
    header('Content-Type: application/json');
    echo json_encode($body, JSON_UNESCAPED_SLASHES), "\n";
    exit;
}

function fail(int $status, string $message): never
{
    reply(['error' => $message], $status);
}

/* X-Forwarded-Proto is sent by the client, so it is believed only when the host sits behind a proxy that sets it
   ('trust_forwarded_proto' in config.php). Otherwise a client could claim HTTPS over plain HTTP. */
function is_https(bool $trustForwarded): bool
{
    return (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (($_SERVER['SERVER_PORT'] ?? '') === '443')
        || ($trustForwarded && strtolower($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
}

/* The store shares the hosting account's disk with the website itself, and cited files can never be deleted through
   the store. A runaway upload loop or a leaked token must not be able to fill the account, so the whole data folder
   is capped ('max_total_bytes'). The new body is counted, and the file it may replace is not subtracted.
   The caller holds the store's lock from this count until its write is in place, so two writes arriving together
   cannot both be admitted against the same remaining space. */
function within_quota(array $cfg, string $dataDir, string $tmp, int $bytes, $lock): void
{
    $cap = (int)($cfg['max_total_bytes'] ?? 0);
    if ($cap <= 0) {
        return;
    }
    $used = 0;
    $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dataDir, FilesystemIterator::SKIP_DOTS));
    foreach ($it as $f) {
        if (!$f->isLink() && $f->isFile() && strpos($f->getFilename(), '.tmp-') !== 0) {
            $used += $f->getSize();
        }
    }
    if ($used + $bytes > $cap) {
        unlink($tmp);
        flock($lock, LOCK_UN);
        fail(507, 'the store is full');
    }
}

function authenticate(array $cfg): string
{
    $token = $_SERVER['HTTP_X_STORE_TOKEN'] ?? '';
    if ($token === '') {
        $auth = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
        if (preg_match('/^Bearer\s+(\S+)$/', $auth, $m)) {
            $token = $m[1];
        }
    }
    if ($token === '') {
        fail(401, 'token required');
    }
    $hash = hash('sha256', $token);
    foreach ($cfg['workers'] as $name => $known) {
        if (is_string($known) && hash_equals($known, $hash)) {
            return (string)$name;
        }
    }
    fail(401, 'unknown token');
}

/* A relative path of plain segments: letters, digits, '.', '_' and '-', each starting with a letter or digit. This
   rules out '..', hidden files, absolute paths and backslashes. */
function clean_path(string $p): string
{
    if ($p === '' || strlen($p) > 512 || substr_count($p, '/') > 15
        || !preg_match('#^[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)*$#', $p)) {
        fail(400, 'bad path');
    }
    return $p;
}

/* A symbolic link in the data folder could point at anything on the host, and the data folder is served to every
   worker. The store never makes a link and never follows one: a path with a link anywhere along it is refused, for
   reading as for writing, and listings leave links out. */
function no_links(string $dataDir, string $rel): string
{
    $path = $dataDir;
    foreach (explode('/', $rel) as $segment) {
        $path .= '/' . $segment;
        if (is_link($path)) {
            fail(403, 'that path passes through a link, and the store follows none');
        }
    }
    return $rel;
}

function area_of(string $rel): string
{
    return explode('/', $rel, 2)[0];
}

function owns(string $worker, string $rel): bool
{
    $parts = explode('/', $rel);
    return count($parts) >= 3 && in_array($parts[0], AREAS_OWNED, true) && $parts[1] === $worker;
}

/* For a path in some agent's postbox or share-scratch, ['postbox' or 'share-scratch', agent, rest], otherwise null. */
function project_place(string $rel): ?array
{
    $parts = explode('/', $rel);
    if (count($parts) >= 3 && in_array($parts[0], PROJECT_AREAS, true)) {
        return [$parts[0], $parts[1], implode('/', array_slice($parts, 2))];
    }
    return null;
}

/* What a PUT of $rel by $worker may do: ['replace' or 'create', the byte limit, the refusal if the file exists].
   Anything not allowed fails here, before the body is read. */
function put_rule(string $worker, string $rel, string $dataDir, int $maxBytes): array
{
    if (area_of($rel) === 'cited') {
        return ['create', $maxBytes, 'cited files are never overwritten'];
    }
    if (owns($worker, $rel)) {
        return ['replace', $maxBytes, ''];
    }
    $place = project_place($rel);
    if ($place !== null) {
        [$kind, $agent, $rest] = $place;
        if ($agent === $worker) {
            return ['replace', $maxBytes, ''];
        }
        if ($kind === 'postbox') {
            if (!preg_match('/^[0-9]{8}T[0-9]{4}Z-' . preg_quote($worker, '/') . '-[A-Za-z0-9._-]+\.flag$/', $rest)) {
                fail(403, "in another worker's postbox you may only create a flag named "
                    . '<yyyymmdd>T<hhmm>Z-' . $worker . '-<post>-<KIND>.flag');
            }
            if (!is_dir($dataDir . '/postbox/' . $agent)) {
                fail(404, 'no postbox for ' . $agent . ': it has not joined');
            }
            return ['create', min($maxBytes, FLAG_MAX_BYTES), 'that flag already exists: flags are never replaced'];
        }
    }
    fail(403, 'you may not write here');
}

function ensure_parent(string $full): void
{
    $dir = dirname($full);
    if (!is_dir($dir) && !mkdir($dir, 0750, true) && !is_dir($dir)) {
        fail(500, 'could not make the folder');
    }
}

/* Stream the request body into a temporary file beside the target, enforcing the size limit and hashing as it goes.
   It returns only when the whole body, as long as it was declared, is on disk; otherwise nothing is stored. */
function receive_body(string $full, int $maxBytes): array
{
    $tmp = dirname($full) . '/.tmp-' . bin2hex(random_bytes(8));
    $in = fopen('php://input', 'rb');
    $out = fopen($tmp, 'xb');
    if ($in === false || $out === false) {
        fail(500, 'could not receive the body');
    }
    $ctx = hash_init('sha256');
    $bytes = 0;
    while (!feof($in)) {
        $chunk = fread($in, 1 << 16);
        if ($chunk === false) {
            fclose($out);
            unlink($tmp);
            fail(400, 'the body could not be read: nothing was stored');
        }
        $bytes += strlen($chunk);
        if ($bytes > $maxBytes) {
            fclose($out);
            unlink($tmp);
            fail(413, 'body larger than the limit');
        }
        hash_update($ctx, $chunk);
        if (!write_all($out, $chunk)) {
            fclose($out);
            unlink($tmp);
            fail(507, 'could not write the body to disk: nothing was stored');
        }
    }
    $stored = on_disk($out);
    $stored = fclose($out) && $stored;
    fclose($in);
    // An upload cut off on its way arrives shorter than it said it would be. It is not the file the sender meant.
    $declared = $_SERVER['CONTENT_LENGTH'] ?? '';
    if (is_string($declared) && ctype_digit($declared) && (int)$declared !== $bytes) {
        @unlink($tmp);
        fail(400, 'the body was cut short of its declared length: nothing was stored');
    }
    clearstatcache(true, $tmp);
    if (!$stored || filesize($tmp) !== $bytes) {
        @unlink($tmp);
        fail(507, 'could not write the body to disk: nothing was stored');
    }
    return [$tmp, $bytes, hash_final($ctx)];
}

/* Write all of $data, or say that it could not be done (a full disk writes part of it, or none). */
function write_all($handle, string $data): bool
{
    for ($done = 0, $size = strlen($data); $done < $size; $done += $n) {
        $n = @fwrite($handle, substr($data, $done));
        if ($n === false || $n === 0) {
            return false;
        }
    }
    return true;
}

/* Push what was written out of PHP and out of the system's buffers, and say whether both succeeded. */
function on_disk($handle): bool
{
    return @fflush($handle) && (!function_exists('fsync') || @fsync($handle));
}

/* The store's one lock, taken with the body already received in $tmp: held while a write is admitted and put in place. */
function lock(string $dataDir, string $tmp)
{
    $h = fopen($dataDir . '/.lock', 'c');
    if ($h === false || !flock($h, LOCK_EX)) {
        @unlink($tmp);
        fail(500, 'could not lock');
    }
    return $h;
}

function log_write(array $cfg, string $worker, string $op, string $rel, int $bytes, string $sha): void
{
    $line = json_encode(['time' => gmdate('c'), 'worker' => $worker, 'op' => $op, 'path' => $rel,
                         'bytes' => $bytes, 'sha256' => $sha], JSON_UNESCAPED_SLASHES) . "\n";
    file_put_contents((string)$cfg['log_file'], $line, FILE_APPEND | LOCK_EX);
}
