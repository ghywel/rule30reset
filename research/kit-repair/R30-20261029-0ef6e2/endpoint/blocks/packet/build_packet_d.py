#!/usr/bin/env python3
"""S19's two Lean forms for packet d (claudeM5, M182): claudeIntel's sources with one paragraph of the header changed, as I237 asks.

    python3 -I build_packet_d.py KIT OUT

KIT is a kit checkout. The code is N17's, byte for byte: build_s19_blocks.py makes the portal file, the module file is copied, and the
single change is the paragraph "Not shown" of the module comment in both. OUT/portal/Rule30Submission.lean and OUT/kit/Rule30RotationBlocks.lean.
"""
import pathlib, subprocess, sys

here = pathlib.Path(__file__).resolve().parent
kit, out = sys.argv[1], pathlib.Path(sys.argv[2])
OLD = """**Not shown.** That the column to the right can read one of these words at all, in any row. A word that no right half
reads is impossible without this module, and finite computations on a strip of columns with its far edge free show
this for some of them: for the example with one gap 5 fewer in the longer block, at 40 columns. No right half that
reads one of these words is known.
"""
NEW = """**Not shown.** That a right half reads the word of the example, or of any two blocks that are not powers of one word, for
ever. (Two powers of one word give the same periodic word in every order; the kit's ether reads `1010…`, so it reads
the blocks `10` and `1010` in every order, `Rule30PeriodTwoCoupled`, and those rows have no leftmost black cell.) Finite
computations on a strip of columns with its far edge free show some words impossible for every right half: the
example with one gap 5 fewer in the longer block, at 40 columns.
"""
mod = (here.parent / "Rule30RotationBlocks.lean").read_text()
assert mod.count(OLD) == 1
out.mkdir(parents=True, exist_ok=True)
(out / "portal").mkdir(exist_ok=True)
(out / "kit").mkdir(exist_ok=True)
(out / "kit/Rule30RotationBlocks.lean").write_text(mod.replace(OLD, NEW))
subprocess.run([sys.executable, "-X", "utf8", "-I", str(here.parent / "build_s19_blocks.py"), kit, str(out / "portal")], check=True)
p = out / "portal/Rule30Submission.lean"
s = p.read_text()
assert s.count(OLD) == 1, s.count(OLD)
s = s.replace(OLD, NEW)
assert '"' not in s and chr(92) not in s
p.write_bytes(s.encode("utf-8"))
print(p.name, len(s.encode("utf-8")), "bytes")
