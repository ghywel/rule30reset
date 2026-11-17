# Rule 30: a fresh start

A clean working repository for the [Rule 30 Prize](https://rule30prize.org/) problems, begun on 17 November 2026.
The earlier repository grew over five weeks and is now the archive; only its method and its knowledge of the kit
come across.

Read these, in this order, at the start of every session:

1. [METHOD.md](METHOD.md): how we work. One document for onboarding any worker, human or model.
2. [KIT.md](KIT.md): what the official kit proves, what is open, and how the open statements connect.
3. [NOW.md](NOW.md): where things stand, what is running and what is stopped.
4. The latest posts in [CHAT-LEDGER.md](CHAT-LEDGER.md), the conversation between workers (after a rotation, its
   header's state section first).

For lookup: [KIT-INDEX.md](KIT-INDEX.md) has one line per kit catalogue row and per equivalent form. Both kit
documents are kept in step with the kit's main by the update step in [KIT-UPDATE.md](KIT-UPDATE.md); at session
start run `git -C Rule30PrizeKit fetch -q && python3 kit/check.py --rev origin/main`.

## Layout

| Path | What it holds |
|---|---|
| `METHOD.md` | the working method |
| `NOW.md`, `CHAT-LEDGER.md` | where things stand; the conversation (rotated into `archive/ledgers/` past 2000 lines) |
| `PRIOR-ART.md`, `PRIOR-ART-ARCHIVE.md` | results found to be known: new entries; placego's, frozen |
| `tools/find_known.py` | searches KIT, KIT-INDEX, both prior-art files and the ledgers, each term on its own |
| `tools/store/` | the shared store: `store.py`, the client for postboxes, flags and share-scratch; `store.php`, the server, with its tests, token maker, example settings and README |
| `tools/portal/` | the submission tools: the notebook builder and its checks, and the pinned post script with a dry run |
| `tools/ledger_check.py` | the ledger check: format, rotation limit, resurrected posts; also `--next`, `--stale`, `--rotate` |
| `KIT.md`, `KIT-INDEX.md` | the kit, condensed, stamped with the kit commit they were written from |
| `KIT-UPDATE.md`, `kit/` | the update step and its tools: the row index, the stamp, the check, merge and build scripts |
| `viz/` | generators and page template for the visualisations, with `PREDICTIONS.md` written before each run |
| `research/<pull>/` | the frozen probe code of each pull (for example `research/m6/`), cited by SHA-256 in the ledger before it runs |

Data stays outside git, cited by SHA-256. Built pages are published, not committed.
