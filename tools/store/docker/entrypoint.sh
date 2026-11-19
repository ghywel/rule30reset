#!/bin/sh
# Entry point of the store container: checks the settings, writes the web server's configuration from them, starts it.
# Any other command is run as given (so "store-admin token add NAME" works before the server has ever started).
set -eu

say() { echo "store: $*" >&2; }
die() { say "$*"; say "not started"; exit 1; }
on()  { case "$(printf %s "${1:-}" | tr 'A-Z' 'a-z')" in 1|true|yes|on) return 0 ;; *) return 1 ;; esac; }
port() { case "$2" in ''|*[!0-9]*) die "$1 must be a port number, not '$2'" ;; esac
         [ "$2" -ge 1 ] && [ "$2" -le 65535 ] || die "$1 must be between 1 and 65535, not $2"; }
plain() { case "$2" in *[!A-Za-z0-9@%+=:,./_-]*) die "$1 holds a character that is not allowed there" ;; esac; }

[ $# -gt 0 ] && exec "$@"

TLS="$(printf %s "${STORE_TLS:-acme}" | tr 'A-Z' 'a-z')"
DOMAIN="${STORE_DOMAIN:-}"
HTTPS_PORT="${STORE_HTTPS_PORT:-8443}"
HTTP_PORT="${STORE_HTTP_PORT:-8080}"
HEALTH_PORT="${STORE_HEALTH_PORT:-8081}"
DATA="${STORE_DATA_DIR:-/data}"
WORKERS="${STORE_WORKERS_FILE:-/config/workers.json}"
CONFIG_DIR="$(dirname "$WORKERS")"
TLS_DIR="${STORE_TLS_DIR:-$CONFIG_DIR/tls}"
STATE="$TLS_DIR"      # where the web server keeps certificates it obtains; scratch space when it obtains none
WHO="$(id -u):$(id -g)"

port STORE_HTTPS_PORT "$HTTPS_PORT"; port STORE_HTTP_PORT "$HTTP_PORT"; port STORE_HEALTH_PORT "$HEALTH_PORT"
plain STORE_DATA_DIR "$DATA"; plain STORE_WORKERS_FILE "$WORKERS"; plain STORE_TLS_DIR "$TLS_DIR"
case "$DOMAIN" in *[!A-Za-z0-9.-]*) die "STORE_DOMAIN must be a bare host name such as store.example.org" ;; esac

# The data and the settings must live on the NAS, not inside the container, where an update would delete them.
for d in "$DATA" "$CONFIG_DIR"; do
    [ -d "$d" ] || die "the folder $d does not exist: map a NAS folder to it (volumes: in the YAML)"
    if [ "$(stat -c %d "$d")" = "$(stat -c %d /)" ] && ! on "${STORE_ALLOW_UNMAPPED:-}"; then
        die "$d is inside the container, so its contents would be lost on the next update: map a NAS folder to it (volumes: in the YAML)"
    fi
done
[ -w "$DATA" ] || die "$DATA is not writable by user $WHO: give that user Modify on the NAS folder, or set user: in the YAML to the folder's owner"

site=""; tls=""
case "$TLS" in
acme)
    [ -n "$DOMAIN" ] || die "STORE_TLS=acme needs STORE_DOMAIN, the public name that reaches this NAS on port 443"
    [ -w "$CONFIG_DIR" ] || die "$CONFIG_DIR is not writable by user $WHO, and the certificate is kept there"
    issuer="issuer acme {
			disable_http_challenge"
    if [ -n "${STORE_ACME_CA:-}" ]; then plain STORE_ACME_CA "$STORE_ACME_CA"; issuer="$issuer
			dir $STORE_ACME_CA"; fi
    if [ -n "${STORE_ACME_EMAIL:-}" ]; then plain STORE_ACME_EMAIL "$STORE_ACME_EMAIL"; issuer="$issuer
			email $STORE_ACME_EMAIL"; fi
    if [ -n "${STORE_ACME_CA_ROOT:-}" ]; then plain STORE_ACME_CA_ROOT "$STORE_ACME_CA_ROOT"; issuer="$issuer
			trusted_roots $STORE_ACME_CA_ROOT"; fi
    site="https://$DOMAIN"; tls="tls {
		$issuer
		}
	}"
    ;;
internal)
    [ -w "$CONFIG_DIR" ] || die "$CONFIG_DIR is not writable by user $WHO, and the private certificate authority is kept there"
    site="https://${DOMAIN:-localhost}"; tls="tls internal"
    ;;
files)
    [ -n "$DOMAIN" ] || die "STORE_TLS=files needs STORE_DOMAIN, the name the certificate was issued for"
    CERT="${STORE_CERT_FILE:-$TLS_DIR/cert.pem}"; KEY="${STORE_KEY_FILE:-$TLS_DIR/key.pem}"
    plain STORE_CERT_FILE "$CERT"; plain STORE_KEY_FILE "$KEY"
    [ -r "$CERT" ] && [ -r "$KEY" ] || die "STORE_TLS=files: $CERT and $KEY must both exist and be readable by user $WHO"
    site="https://$DOMAIN"; tls="tls $CERT $KEY"; STATE=/tmp/caddy
    ;;
off)
    [ "$HTTP_PORT" != 443 ] || die "STORE_TLS=off cannot listen on port 443: the store would take plain HTTP for HTTPS"
    site="http://:$HTTP_PORT"; STATE=/tmp/caddy
    if ! on "${STORE_REQUIRE_HTTPS:-true}"; then
        say "WARNING: STORE_REQUIRE_HTTPS is off: tokens will cross the network in clear. For tests only."
    elif ! on "${STORE_TRUST_FORWARDED_PROTO:-}"; then
        say "WARNING: STORE_TLS=off with STORE_REQUIRE_HTTPS on: every request will be refused unless a reverse proxy"
        say "         in front sets X-Forwarded-Proto and STORE_TRUST_FORWARDED_PROTO is true."
    fi
    ;;
*)  die "STORE_TLS must be acme, internal, files or off, not '$TLS'" ;;
esac

if [ ! -s "$WORKERS" ]; then
    say "no worker has a token yet, so every request will be refused. In this container's shell run:"
    say "    store-admin token add NAME          (a new token, shown once)"
    say "    store-admin token import NAME SHA   (keep a token a worker already holds)"
fi

# What every door serves: /store.php and nothing else. Requests are logged to the container's log without their
# headers, because the worker's token travels in one. On a plain-HTTP door a Host header that names port 443 would
# make PHP report port 443, which store.php takes for HTTPS: the port is dropped from such a header first.
serve() {
    cat <<CADDY
	root * /app/public
	header -Server
	route {
CADDY
    [ "$1" = plain ] && cat <<'CADDY'
		@port443 header_regexp Host :0*443$
		request_header @port443 Host {http.request.host}
CADDY
    cat <<'CADDY'
		@multipart header_regexp Content-Type (?i)^\s*multipart/
		respond @multipart "multipart bodies are not accepted" 415
		@store path /store.php
		php @store
		respond 404
	}
CADDY
}
logging() {
    cat <<'CADDY'
	log {
		output stdout
		format filter {
			wrap json
			request>headers delete
			request>tls delete
			resp_headers delete
		}
	}
CADDY
}

CADDYFILE="${STORE_CADDYFILE:-/tmp/Caddyfile}"
{
    cat <<CADDY
# Written by the container's entry point from the STORE_* settings at each start. Do not edit: change the settings.
{
	admin off
	persist_config off
	skip_install_trust
	auto_https disable_redirects
	http_port $HTTP_PORT
	https_port $HTTPS_PORT
	storage file_system $STATE
	servers {
		protocols h1 h2
		timeouts {
			read_header 15s
			idle 2m
		}
	}
	frankenphp
}

$site {
CADDY
    if [ "$TLS" = off ]; then serve plain; else printf '\t%s\n' "$tls"; serve tls; fi
    logging
    cat <<CADDY
}

# The health check's own door: this container only, and not logged.
http://127.0.0.1:$HEALTH_PORT {
	bind 127.0.0.1
CADDY
    serve plain
    printf '\tlog_skip\n}\n'
} > "$CADDYFILE"

say "starting: tls=$TLS${DOMAIN:+ name=$DOMAIN} as user $WHO, data in $DATA, workers in $WORKERS"
exec frankenphp run --config "$CADDYFILE" --adapter caddyfile
