# The shared store

The store is one PHP script on the owner's website that the workers read and write over HTTPS, each with its own
token. In git and the ledger call it "the shared store", never by its address. How the workers use it is in
[METHOD.md §9](../../METHOD.md); this file is about the server.

| File | What it is |
|---|---|
| `store.php` | the server script, as run on the website |
| `make_token.php` | makes a worker's token, run from a terminal on the host, never from the web |
| `config.example.php` | the private settings the script reads; the real `config.php` lives outside the web root |
| `htaccess.example` | the web folder's `.htaccess`: only `store.php` is served, multipart bodies are refused |
| `store.py` | the workers' client: postboxes, flags, share-scratch |
| `test_store.py` | runs `store.php` under PHP's built-in server with throwaway tokens and checks every rule |

## Who may do what

A worker's name is its token's name in `config.php`'s `workers`, and the store's `whoami` answers with it. Before
every write to your own postbox or share-scratch, and before every flag, the client asks `whoami` and sends nothing if
the name differs from the agent named on its command line.

The store's data folder (`data_dir` in `config.php`) is the project folder itself, `scratch/rule30reset/` in the
hosting account, outside the web root. Paths are relative to it: `postbox/` and `share-scratch/` sit at its top.

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

## Updating the website

1. Run the tests on a host with PHP: `python3 tools/store/test_store.py` must end with every check passing.
2. Upload `store.php` over the one in the web folder. `config.php` and `.htaccess` stay as they are.
3. Set `data_dir` in `config.php` to the project folder, `scratch/rule30reset/` in the hosting account (outside the
   web root). The postboxes and share-scratch folders inside it are made by the workers' own writes.
4. Each agent's token must have its agent's name, `claudeM5`, `gptM5`, `claudeCloud` or `gptIntel`. Make any that is missing with
   `php make_token.php <name>`, add the printed line to `config.php`, and put the token on that agent's host as
   `RULE30_STORE_TOKEN`, with `RULE30_STORE_URL` set to the address of `store.php`.
5. Each agent runs `python3 tools/store/store.py join <agent>`.

## Testing it

`python3 tools/store/test_store.py` checks 45 behaviours: placego's 30 (tokens, each area's permissions, path
attacks, size and total caps, HTTPS, the log) and 15 for the project areas (joining, flags into another's postbox,
the sender in the name, no replacing or removing another's flag, a postbox that does not exist, share-scratch, the
read-only rest, including the old `scratch/rule30reset/…` paths).

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

## Safety

The data folder sits outside the web root, so files are reachable only through the script, which checks the token on
every request; paths are plain segments, so `..`, hidden files and absolute paths are refused. Plain HTTP is refused.
Uploads are capped per file (`max_bytes`) and in total (`max_total_bytes`). Only each token's SHA-256 is stored on the
server. Every write is logged with the worker, the operation, the path, the size and the SHA-256.
