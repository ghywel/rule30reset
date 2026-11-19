<?php
/*
 * The worker registry: one JSON object, {"worker-name": "sha256 of its token", ...}, in STORE_WORKERS_FILE.
 * This file is the one definition of a valid registry, shared by the server (config.php) and the token tool
 * (store-admin). A registry that is unreadable, malformed or inconsistent names no worker: the server then
 * refuses every request, and the token tool refuses to change it.
 */
const REGISTRY_NAME = '/^[A-Za-z0-9][A-Za-z0-9-]{0,31}$/';
const REGISTRY_HASH = '/^[0-9a-f]{64}$/';

/* ['absent' | 'ok' | 'bad', the workers (name => hash; empty unless 'ok'), why it is bad]. */
function registry_read(string $file): array
{
    clearstatcache(true, $file);
    if (!file_exists($file) && !is_link($file)) {
        return ['absent', [], ''];
    }
    if (!is_file($file) || !is_readable($file)) {
        return ['bad', [], 'it is not a readable file'];
    }
    $text = @file_get_contents($file);
    if ($text === false) {
        return ['bad', [], 'it could not be read'];
    }
    return registry_parse($text);
}

function registry_parse(string $text): array
{
    $object = json_decode($text);
    if (!$object instanceof stdClass) {
        return ['bad', [], 'it is not a JSON object of names and hashes'];
    }
    $data = get_object_vars($object);
    $seen = [];
    foreach ($data as $name => $hash) {
        $name = (string)$name;
        if (!preg_match(REGISTRY_NAME, $name)) {
            return ['bad', [], 'it holds a name that is not 1 to 32 letters, digits or hyphens'];
        }
        if (!is_string($hash) || !preg_match(REGISTRY_HASH, $hash)) {
            return ['bad', [], "the entry for '$name' is not a SHA-256 in lower-case hex"];
        }
        if (isset($seen[$hash])) {
            return ['bad', [], "'$name' and '{$seen[$hash]}' hold the same token"];
        }
        $seen[$hash] = $name;
    }
    return ['ok', $data, ''];
}

/* The registry's text for these workers: sorted, one entry a line. */
function registry_text(array $workers): string
{
    ksort($workers);
    return json_encode((object)$workers, JSON_PRETTY_PRINT) . "\n";
}

/* An explicit Boolean setting: null when the variable is absent or empty, true or false when it is one of the
   accepted words, and the string 'invalid' otherwise. A misspelt value must never read as "off". */
function setting_bool(string $name): bool|string|null
{
    $v = getenv($name);
    if ($v === false || $v === '') {
        return null;
    }
    $v = strtolower($v);
    if (in_array($v, ['1', 'true', 'yes', 'on'], true)) {
        return true;
    }
    if (in_array($v, ['0', 'false', 'no', 'off'], true)) {
        return false;
    }
    return 'invalid';
}
