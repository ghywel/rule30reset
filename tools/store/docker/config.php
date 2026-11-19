<?php
/*
 * The store's settings inside the container. store.php is unchanged: it finds this file through SHAREDSTORE_CONFIG.
 * Everything comes from the environment, except the token hashes, which live in one file on the NAS
 * (STORE_WORKERS_FILE, by default /config/workers.json: {"worker-name": "sha256 of its token", ...}).
 * No token is ever stored: only its SHA-256.
 */
$flag = static function (string $name, bool $default): bool {
    $v = getenv($name);
    return ($v === false || $v === '') ? $default : in_array(strtolower($v), ['1', 'true', 'yes', 'on'], true);
};
$number = static function (string $name, int $default): int {
    $v = getenv($name);
    return ($v === false || $v === '' || !ctype_digit($v)) ? $default : (int)$v;
};
$workers = [];
$file = getenv('STORE_WORKERS_FILE') ?: '/config/workers.json';
if (is_file($file)) {
    $decoded = json_decode((string)file_get_contents($file), true);
    if (is_array($decoded)) {
        foreach ($decoded as $name => $hash) {
            if (is_string($name) && is_string($hash) && preg_match('/^[0-9a-f]{64}$/', $hash)) {
                $workers[$name] = $hash;
            }
        }
    }
}
return [
    'data_dir'              => getenv('STORE_DATA_DIR') ?: '/data',
    'log_file'              => getenv('STORE_LOG_FILE') ?: '/config/store.log',   // outside what the store serves
    'require_https'         => $flag('STORE_REQUIRE_HTTPS', true),
    'max_bytes'             => $number('STORE_MAX_BYTES', 64 * 1024 * 1024),
    'max_total_bytes'       => $number('STORE_MAX_TOTAL_BYTES', 2 * 1024 * 1024 * 1024),
    'trust_forwarded_proto' => $flag('STORE_TRUST_FORWARDED_PROTO', false),
    'workers'               => $workers,
];
