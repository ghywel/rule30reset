# The shared store as a container

*Status (19 November): a tested prototype. The image is not published and the store has not moved. Publishing
waits for the owner's word; the move is claudeM5's, after S2 and S3.*

One container holds the whole server side of the shared store: `store.php`, byte for byte the file one folder up,
running inside [FrankenPHP](https://frankenphp.dev) (PHP built into the Caddy web server). The web server obtains
and renews the HTTPS certificate itself. The workers' files, the token hashes and the certificate live in two
folders on the NAS, so the container can be replaced at any time and nothing is lost.

| File | What it is |
|---|---|
| `Dockerfile` | The recipe for the image. |
| `entrypoint.sh` | Runs at each start: checks the settings, writes the web server's configuration from them, starts it. |
| `config.php` | The store's settings, read from the environment and from `workers.json` on the NAS. |
| `store.ini` | PHP settings: no parsing of request bodies, no upload tracking, errors to the container's log. |
| `store-admin` | The token tool, run in the container's shell. |
| `rule30-store.yaml` | The file to paste into TrueNAS (or give to `docker compose`). |
| `store-image.workflow.yml` | Builds, checks and publishes the image on GitHub. Not active where it sits. |
| `test_container.py` | The checks: the server's own 45, then 31 on the container and its certificates. |

## How an image reaches the NAS

A line such as `image: qmcgaw/gluetun:latest` names an image in a registry; the NAS downloads it and runs it. Three
steps put an image of ours there.

1. **The recipe** is `Dockerfile`. `docker build` turns it and the files beside it into an image.
2. **The registry.** GitHub keeps one for every account, `ghcr.io/<account>/<name>`. The workflow file builds the
   image on GitHub's machines, runs `test_container.py`, and publishes only if every check passes. It needs no
   secret of ours: GitHub hands each run a token that may publish to the account's own registry.
3. **The YAML** names the image. TrueNAS pulls it, and pulls the newer one at each update.

A new repository is not needed. The workflow can run in this one, where `store.php` and its checks already live; it
runs only when `tools/store/` changes, and once a week to take the base image's security updates. The same folder
would work unchanged as a repository of its own, should the owner prefer one: only the image's name would change.

**To publish** (the owner's word first, because it creates a public package on the owner's account):

1. Copy `store-image.workflow.yml` to `.github/workflows/store-image.yml` and push to `main`.
2. Wait for the run under the repository's *Actions* tab to finish (about three minutes).
3. Once only: a new package starts private. On GitHub, *your profile → Packages → rule30-store → Package settings →
   Change visibility → Public*. The image holds nothing private: every file in it is already in this public
   repository. (The alternative is to keep it private and sign TrueNAS in to `ghcr.io`.)

## Install on TrueNAS

1. **Two folders.** Make a dataset for the app, with two folders in it, `data` and `config` (two datasets work as
   well). Give the `apps` user (568) Modify on both.
2. **The router.** Forward TCP port 443 from the internet to the NAS, to the port the YAML publishes (30443 as
   written). The NAS's own web interface keeps ports 80 and 443 on the NAS and is not exposed by this.
3. **The app.** *Apps → Discover Apps → the three-dot menu → Install via YAML*. Name it `rule30-store`, paste
   `rule30-store.yaml`, and set the lines marked `<--`: the image, the public name, the NAS port, the two folders.
4. **Watch the log.** Within a minute it should say `certificate obtained successfully`. If the router is not
   forwarding yet, the web server keeps retrying, more slowly each time; restart the app once the forward is in.
5. **Tokens.** In the app's shell, once for each worker:
   `store-admin token add NAME` for a new token (printed once), or `store-admin token import NAME SHA256` to keep
   the token a worker already holds (the SHA-256 is the worker's line in the old store's `config.php`).
6. **Check.** From any worker: `python3 tools/store/store.py ls` with that host's store address set to
   `https://THE-NAME/store.php`.

A wrong installation does not start and says why in the log: no folder mapped, a folder the user cannot write,
no name given.

**A rehearsal that costs nothing.** Let's Encrypt limits failed attempts for a name to a few each hour. To try the
whole path first, add `STORE_ACME_CA: https://acme-staging-v02.api.letsencrypt.org/directory` under `environment:`.
The certificate that arrives is a test one (clients refuse it), but it proves the name, the router and the folders.
Remove the line and restart, and the real certificate is requested.

## Settings

All are environment variables, under `environment:` in the YAML. Only the name is required.

| Variable | Default | Meaning |
|---|---|---|
| `STORE_DOMAIN` | none | The public name that reaches the NAS. It is written in the YAML on the NAS and nowhere in git. |
| `STORE_TLS` | `acme` | `acme`: a certificate from Let's Encrypt, renewed without attention. `internal`: the container's own certificate authority, for a private network. `files`: a certificate you supply. `off`: plain HTTP, for a reverse proxy of your own in front. |
| `STORE_ACME_EMAIL` | none | An address for the certificate authority's notices. |
| `STORE_ACME_CA` | Let's Encrypt | Another ACME directory, such as Let's Encrypt's staging one. |
| `STORE_HTTPS_PORT` | `8443` | The port the store listens on inside the container. |
| `STORE_HTTP_PORT` | `8080` | The same for `STORE_TLS: off`. |
| `STORE_MAX_BYTES` | `67108864` | The largest single file (64 MB). |
| `STORE_MAX_TOTAL_BYTES` | `2147483648` | The cap on the whole store (2 GB); `0` for none. |
| `STORE_REQUIRE_HTTPS` | `true` | Refuse plain HTTP. Turn off for tests only. |
| `STORE_TRUST_FORWARDED_PROTO` | `false` | With `off`: believe the reverse proxy's `X-Forwarded-Proto`. |
| `STORE_CERT_FILE`, `STORE_KEY_FILE` | `/config/tls/cert.pem`, `key.pem` | With `files`: the certificate and its key. |

**The listening port and the storage folders are lines of the YAML, not variables.** Docker sets both up before
the program inside starts, so the program cannot read them from its environment. The YAML gives each its own
labelled line: `published:` is the port on the NAS, and each `source:` is a folder on the NAS.

The remaining variables (`STORE_DATA_DIR`, `STORE_WORKERS_FILE`, `STORE_LOG_FILE`, `STORE_TLS_DIR`,
`STORE_HEALTH_PORT`, `STORE_ACME_CA_ROOT`, `STORE_ALLOW_UNMAPPED`) move things inside the container. The tests use
them; an installation does not need them.

## What is in the two folders

| On the NAS | Holds |
|---|---|
| `data/` | The store's data folder: `postbox/`, `share-scratch/`, and the rest, as files you can read on the NAS. |
| `config/workers.json` | Each worker's name and the SHA-256 of its token. No token is ever stored. |
| `config/store.log` | One line for each write: time, worker, operation, path, size, digest. Not readable through the store. |
| `config/tls/` | The certificate and its private key. Keep this folder as private as a password. |

## What the container may do

It runs as an ordinary user (568) with a read-only filesystem, no capabilities, and no way to gain any. It can
write to the two folders and to a scratch area in memory. It serves `/store.php` and answers 404 to every other
path. A request with a multipart body is refused before PHP sees it. Requests are logged to the container's log
without their headers, because the worker's token travels in a header. The web server's control interface is off.

## Moving the store from the website

This is claudeM5's task, after S2 and S3. With the app installed:

1. Tell the workers to stop writing. Copy the old data folder into `data/`, owned by user 568.
2. `store-admin token import NAME SHA256` for each of the four workers, from the old `config.php`. Every worker
   keeps its token.
3. Each host changes its store address, and nothing else.
4. Each worker runs `store.py ls` and `store.py inbox NAME`. claudeCloud runs its eight identity checks in a row.
5. On the owner's word, remove the old store from the website.

## The checks

```bash
python3 tools/store/docker/test_container.py
```

It needs Docker and `openssl`, and builds the image first. Part 1 is `test_store.py` unchanged, each of its three
servers a container: 45 checks, and one line that says all of them passed. Part 2 is the container: the refusals,
the token tool, HTTPS with the private authority and with certificate files, the reverse-proxy mode, the log, the
privileges, and that data, tokens and certificates outlive the container: 26 checks. Part 3 obtains a certificate
from Pebble, the Let's Encrypt project's test authority, by the challenge that needs only the HTTPS port: 5 checks.
The last line reads `32 of 32 checks pass`.

**Not tested here**, because it needs the NAS and the router: a certificate from Let's Encrypt itself for the
public name, the port forward, and TrueNAS's handling of the YAML. Tested on Linux only (x86-64).
