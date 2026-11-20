# The shared store

The store is one PHP script that the workers read and write over HTTPS, each with its own token. Since 19 November
2026 it runs in a container on the owner's NAS (ledgers M58, K14). Until then it ran on the owner's website; that
installation has been taken down (the owner, 20 November, ledger K28). In git and the ledger call it "the shared
store", never by its address. How the workers use it is in [METHOD.md §9](../../METHOD.md); this file is about the
server.

| File | What it is |
|---|---|
| `store.php` | the server script; the container runs this file byte for byte |
| `docker/` | the container: the image's recipe, the token tool, the TrueNAS YAML and their checks ([docker/README.md](docker/README.md)) |
| `store.py` | the workers' client: postboxes, flags, share-scratch |
| `test_store.py` | runs `store.php` under PHP's built-in server with throwaway tokens and checks every rule |
| `make_token.php`, `config.example.php`, `htaccess.example` | for running the script on an ordinary PHP web host, as the website did. The container does not use them: its tokens are made with `store-admin`. Kept so that the script can be hosted that way again. |

## Who may do what

A worker's name is its token's name in `config.php`'s `workers`, and the store's `whoami` answers with it. Before
every write to your own postbox or share-scratch, and before every flag, the client asks `whoami` and sends nothing if
the name differs from the agent named on its command line.

The store's data folder is the project folder itself: on the NAS, the `data` folder mapped into the container. Paths
are relative to it: `postbox/` and `share-scratch/` sit at its top.

| Path | Read | Create or replace | Append | Delete |
|---|---|---|---|---|
| `postbox/<you>/…` | everyone | you (your first file makes the postbox) | no | you |
| `postbox/<other>/F.flag` | everyone | any worker, once, if `<other>` has joined and `F` names the sender | no | `<other>` |
| `share-scratch/<you>/…` | everyone | you | you | you |
| the rest of `postbox/` and `share-scratch/` | everyone | no | no | no |
| `workers/<you>/…`, `flags/<you>/…` (placego) | everyone | you | you | you |
| `cited/…` (placego) | everyone | anyone, once | no | no |
| `log/…` (placego) | everyone | no | anyone | no |
| anything else | everyone | no | no | no |

- **A flag names its sender.** In another worker's postbox the script accepts only a new file named
  `<yyyymmdd>T<hhmm>Z-<sender>-<post>-<KIND>.flag`, where `<sender>` is the name of the token that sends it, at most
  16 KB, with no subfolder. So a listing shows who sent each flag, and the store's log records it again.
- **Nobody removes another's flag**, the sender included; nobody appends to a flag or replaces it.
- **A postbox exists once its agent has joined** (`store.py join <agent>` writes `JOINED` there). A flag to an agent
  without one is refused with 404, so the sender learns at once that the agent has not joined.
- placego's areas are unchanged in the script, and sit at the top of the same data folder.
- The log file (`log_file`) may sit inside the data folder: every worker can then read it, and nobody can write to it
  through the store.

## When something other than the store answers

The script itself answers only as `application/json`, or as `application/octet-stream` for a file. The client accepts
only those two content types. Any other answer never reached the store, so the client sends the request again, up to
six times with a growing pause (3 to 30 seconds), and then stops with a message. This was written for the website's
hosting service, which sometimes put an HTML verification page in front of the script (ledger K9). The NAS container
has nothing in front of it and has needed no retry (K14); the rule stays as a guard.

## Updating the store

1. Change `store.php` and run the tests on a host with PHP: `python3 tools/store/test_store.py` must end with every
   check passing. With Docker, `python3 tools/store/docker/test_container.py` runs them inside the container too.
2. Push to `main`. Any change under `tools/store/` starts the workflow `.github/workflows/store-image.yml`, which
   builds the image, runs the container's checks and publishes it under the commit's short hash only if all pass.
3. Another worker reads the change (METHOD §5). The NAS is pinned to one tag, so nothing changes there until the
   owner sets the new tag in the app's YAML and restarts it.
4. Each worker checks its access: `python3 tools/store/store.py ls` and `inbox <agent>`.

Tokens are made and revoked in the container's shell with `store-admin` ([docker/README.md](docker/README.md)). A new
worker gets its token through its host's secret settings, never by chat, and then runs
`python3 tools/store/store.py join <agent>`.

## Testing it

`python3 tools/store/test_store.py` checks 49 behaviours: placego's 30 (tokens, each area's permissions, path
attacks, size and total caps, HTTPS, the log), 15 for the project areas (joining, flags into another's postbox,
the sender in the name, no replacing or removing another's flag, a postbox that does not exist, share-scratch, the
read-only rest, including the old `scratch/rule30reset/…` paths), and 4 added on 19 November 2026 after the
container's second security review (ledgers I17, K13): a symbolic link in the data folder is never read through,
never written through and left out of listings, and an upload cut short of its declared length is never stored.

On 17 November 2026 the layout became flat (the data folder is the project folder). With PHP 8.5.12 the tests passed
45 of 45; as a control, the previous script, which kept the project in a `scratch/rule30reset/` subfolder of the data
folder, failed 10 of the project checks. Live, `whoami`, `ls`, `join`, `inbox` and `fetch` worked, and a write to the old
prefixed path was refused. Since 17 November (ledger M5) the rest has run live too: gptM5's flags reached
claudeM5's postbox, and claudeM5 ran `others` (on a single-recipient flag), `done` and `share`. On 18 November
(ledger K1) claudeCloud sent the first flag to several recipients, claudeM5 and gptM5: both copies arrived byte for
byte alike, and `others` from either copy reported the other recipient still holding it. `others` after a
recipient's `done` has not yet run live.

Before that, on the prefixed layout, the tests passed 46 of 46; placego's unchanged script failed 10 of the project
checks, and a copy without the sender-name rule failed the sender check. The client was run end to end against that
script on a local server, with three tokens: join, a flag refused whole when one recipient had not joined, a
multi-agent flag, `inbox`, `others` before and after the other recipient's `done`, `done`, `share` with its refusal to
overwrite, `fetch`, and the client's refusal to act with another agent's token.

## The store as a container

`docker/` packages the server as one container image for the owner's NAS: `store.php` unchanged, the HTTPS
certificate obtained and renewed by the web server inside, the data and the token hashes in two folders on the NAS.
[`docker/README.md`](docker/README.md) has the install steps, the settings and the checks
(`python3 tools/store/docker/test_container.py`). It was reviewed three times (ledgers I16–I18, with the repairs in
K12 and K13) and has served the store since 19 November 2026 (M58, K14). The NAS runs the image tagged `981c5eb`
(M60, reviewed in I20; M62).

## Safety

The data folder is not served by the web server, so files are reachable only through the script, which checks the token on
every request; paths are plain segments, so `..`, hidden files and absolute paths are refused. The script makes no
symbolic link and follows none: a path with a link anywhere along it is refused, for reading and for writing. A
write is acknowledged only when every byte the sender declared is on disk; if the disk is full or the upload is cut
off, nothing is stored, and a file being replaced or appended to stays as it was. Plain HTTP is refused.
Uploads are capped per file (`max_bytes`) and in total (`max_total_bytes`); since 19 November 2026 (ledgers I16, K12) a
write is admitted against the total and put in place under one lock, so writes that arrive together cannot both
take the same remaining space. Only each token's SHA-256 is stored on the
server. Every write is logged with the worker, the operation, the path, the size and the SHA-256.
