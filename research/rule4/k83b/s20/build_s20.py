#!/usr/bin/env python3
"""S20's portal source: the kit module PairTraceEntropy of the equivalents patch, for the verifier's pin (claudeM5, M184).

    python3 -I build_s20.py KIT OUT

KIT is a kit checkout with gptM5's equivalents patch applied (R123). OUT/portal/Rule30Submission.lean is its module with the
module keywords removed, its namespace changed, and the window-cover word count of the patched Mixing carried at the top (the
pin's Mixing proves it inside another proof and does not export it). The definitions and proofs are the patch's.
"""
import pathlib, re, sys

kit, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
mix = (kit / "equivalents/Rule30Equivalents/Mixing.lean").read_text()
src = (kit / "equivalents/Rule30Equivalents/PairTraceEntropy.lean").read_text()
i = mix.index("theorem coverMincard_le_card_pairWords")
j = mix.index("/-- The three-letter backward extension bound")
cover = mix[mix.rindex("/-- **A dynamical cover**", 0, i):i] + mix[i:j].rstrip() + "\n"
body = src[src.index("/-!\n# Rule 30 entropy"):]
doc_end = body.index("-/\n") + 3
doc, rest = body[:doc_end], body[doc_end:]
import re
doc, hits = re.subn(r"Contributed by [^\n]*\n", lambda m: "The verifier's kit exports no count of the words in the window-cover proof, so `coverMincard_le_card_pairWords` is carried\nfrom the kit patch before the rest.\n", doc)
assert hits == 1
rest = rest.replace("@[expose] public section\n", "", 1)
rest = rest.replace("namespace Rule30Equivalents.PairTraceEntropy\n", "namespace Rule30Submission\n", 1)
rest = rest.replace("end Rule30Equivalents.PairTraceEntropy", "end Rule30Submission")
rest = rest.replace("open Rule30Equivalents.Mixing\n", "open Rule30Equivalents Rule30Equivalents.Mixing\n", 1)
k = rest.index("open Rule30Equivalents Rule30Equivalents.Mixing\n") + len("open Rule30Equivalents Rule30Equivalents.Mixing\n")
source = "import Rule30Equivalents.Mixing\n\n" + doc + rest[:k] + "\n" + cover + rest[k:]
assert '"' not in source and chr(92) not in source, "quote or backslash"
p = out / "portal/Rule30Submission.lean"
p.parent.mkdir(parents=True, exist_ok=True)
p.write_bytes(source.encode("utf-8"))
print(len(source.encode("utf-8")), "bytes", len(source.splitlines()), "lines")
