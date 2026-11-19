<?php
/*
 * The store's settings inside the container. store.php is unchanged: it finds this file through SHAREDSTORE_CONFIG.
 * Everything comes from the environment, except the token hashes, which live in one file on the NAS
 * (STORE_WORKERS_FILE, by default /config/workers.json: {"worker-name": "sha256 of its token", ...}).
 * No token is ever stored: only its SHA-256.
 *
 * The entry point refuses to start on a setting it cannot read. Should this file ever meet one all the same, it
 * takes the safe value: HTTPS required, the proxy's header not believed, the default size limits.
 */
require_once __DIR__ . '/registry.php';

$flag = static function (string $name, bool $default, bool $safe): bool {
    $v = setting_bool($name);
    return $v === null ? $default : ($v === 'invalid' ? $safe : $v);
};
$number = static function (string $name, int $default): int {
    $v = getenv($name);
    return ($v === false || $v === '' || !ctype_digit($v) || strlen($v) > 15) ? $default : (int)$v;
};
[$state, $workers] = registry_read(getenv('STORE_WORKERS_FILE') ?: '/config/workers.json');
return [
    'data_dir'              => getenv('STORE_DATA_DIR') ?: '/data',
    'log_file'              => getenv('STORE_LOG_FILE') ?: '/config/store.log',   // outside what the store serves
    'require_https'         => $flag('STORE_REQUIRE_HTTPS', true, true),
    'max_bytes'             => $number('STORE_MAX_BYTES', 64 * 1024 * 1024),
    'max_total_bytes'       => $number('STORE_MAX_TOTAL_BYTES', 2 * 1024 * 1024 * 1024),
    'trust_forwarded_proto' => $flag('STORE_TRUST_FORWARDED_PROTO', false, false),
    'workers'               => $state === 'ok' ? $workers : [],
    'registry_state'        => $state,
];
