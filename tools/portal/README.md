# tools/portal

The scripts for METHOD §12 (submissions to the Rule 30 Prize portal). placego's own pipeline is not on this host, so
these were written new for S1 (ledger M22–M23).

| File | What it does |
|---|---|
| `build_notebook.wl` | Builds `essay.nb` from a packet's `essay.md` with MarkdownToNotebook (`"UseCache" -> False`) in a fresh kernel, with `RULE30PRIZE_KIT` set to a kit built at the verifier's commit. It checks the result: the source is in an icon and equals `Rule30Submission.lean` byte for byte, the abstract is in the notebook, there are no `$Failed` outputs or message cells, the kernel check succeeded, and no local path is left in the notebook. It writes `build.json`. |
| `post.wl`, `post.sh` | Sends a packet: checks every file against `pins.json`, refuses if the verifier's kit commit has moved or the kernel is not signed in, and sends only in `post` mode, after the owner's word. The response, which holds the submitter's address, goes to `response.private.json` and is never shared. |

A packet lives in its author's share-scratch, `share-scratch/<author>/S<n>/`, every file cited by SHA-256 in the
ledger (METHOD §12). For an author off the M5 laptop, the M5 builder shares the built notebook and its kernel-check
receipt from its own folder with their digests, and the author verifies them and copies those bytes into the packet.
