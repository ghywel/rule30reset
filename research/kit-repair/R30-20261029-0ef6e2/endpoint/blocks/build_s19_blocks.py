#!/usr/bin/env python3
"""Assemble the portal form of S19 in its block form (claudeIntel, N15). Adapted from claudeM5's build_s19.py (M172, M175).

    python3 -X utf8 -I build_s19_blocks.py KIT OUT

KIT is a kit checkout at 88fdac9 or later. OUT/Rule30Submission.lean is self-contained at the verifier's pin: the kit's
tail-left lemmas (Tail) and near-square core (Near), unchanged apart from namespaces, the module Rule30RotationBlocks,
and after it the real-number companions with five narrow Mathlib imports.
"""
import pathlib, re, sys

here = pathlib.Path(__file__).resolve().parent
kit, out = pathlib.Path(sys.argv[1]) / "lean/Ruliology/CellularAutomata", pathlib.Path(sys.argv[2])


def between(text, a, b):
    i = text.index(a)
    return text[i:text.index(b, i)]


rot = (here / "Rule30RotationBlocks.lean").read_text()
zero = (kit / "Rule30ZeroWallDiagonals.lean").read_text()
near = (kit / "Rule30ClockNearSquares.lean").read_text()

tail = between(zero, "/-! ### The tail-left interface -/", "/-! ### The zero-wall diagonals -/")
near = between(near, "open Rule30Realization (evol)", "/-! ## Standard words")
body = between(rot, "/-! ### Integer floors", "end Ruliology.CellularAutomata.Rule30RotationBlocks")
doc = between(rot, "/-!\n# Blocks in the order", "-/\n")

CARRIED = """
**Carried here.** The verifier's kit predates `corollary_F`. `Tail` is the tail-left package of the kit's
`Rule30ZeroWallDiagonals` and `Near` is the kit's `Rule30ClockNearSquares` up to `corollary_F`, with their proofs.
What follows them is new. The last section is the real-number form, and alone uses Mathlib.
"""


def companion(name):
    text = (here / name).read_text()
    key = "namespace RotationRealBridge\n"
    text = between(text, key, "end RotationRealBridge").replace(key, "", 1)
    return re.sub(r"^open Ruliology.*\n", "", text, flags=re.M).strip()


REAL = """
/-! ### Real numbers

The theorems above are about integers and their proofs are core Lean. These state them with Mathlib's real numbers: the
hypotheses `IrrationalLine` and `PhaseLine` are the floors of an irrational line and the two roundings of a line of the
same slope, and the exclusion is for a rotation by an irrational `α` read through an arc `[0, γ)`. -/

section Reals

"""
pdoc = doc.replace("**No real numbers.**", "**In integers.**")
assert pdoc != doc
pdoc = pdoc.rstrip() + """

**Over the real numbers,** in the last section: `rotation_blocks_excluded` (an irrational angle, an arc, either end, any
translate, two nonempty blocks), `rotation_block_excluded` (a Boolean function of finitely many answers),
`irrationalLine_iff`, `phaseLine_iff` and `phaseLine_one_exception` (what the two integer hypotheses say of real lines).
"""

source = ("import Ruliology.CellularAutomata.Rule30Realization\n"
  "import Ruliology.CellularAutomata.Rule30LeftUnbounded\n"
  "import Ruliology.CellularAutomata.Rule30LeftReset\n"
  "import Mathlib.NumberTheory.Real.Irrational\n"
  "import Mathlib.Algebra.Order.Floor.Ring\n"
  "import Mathlib.Tactic.FieldSimp\n"
  "import Mathlib.Tactic.Linarith\n"
  "import Mathlib.Tactic.Ring\n\n"
  + pdoc.replace("Rule30ClockNearSquares.corollary_F", "Near.corollary_F").rstrip() + "\n" + CARRIED + "-/\n\n"
  + "namespace Rule30Submission\n\nopen Ruliology.CellularAutomata\n\nnamespace Tail\n\n"
  + "open Rule30Diagonals (transducer_periodic)\n"
  + "open Rule30LeftReset (EvPer EvWhite period_or_white white_forces_eq)\n"
  + "open Rule30LeftUnbounded (B Bpow Bpow_zero win zero Trunc win_trunc zero_trunc xor_cancel\n"
  + "  pairCode pairCode_lt pairCode_inj pigeonhole code code_lt code_inj)\n\n"
  + tail.rstrip() + "\n\nend Tail\n\nnamespace Near\n\n"
  + near.replace("Rule30ZeroWallDiagonals.", "Tail.").rstrip() + "\n\nend Near\n\n"
  + body.replace("Rule30ClockNearSquares.", "Near.").rstrip() + "\n" + REAL
  + "\n\n".join(companion(n) for n in ("RealBridge.lean", "RealBlockBridge.lean", "PhaseLineBridge.lean", "RotationBlocksReal.lean"))
  + "\n\nend Reals\n\nend Rule30Submission\n")
assert '"' not in source and chr(92) not in source
p = out / "Rule30Submission.lean"
p.parent.mkdir(parents=True, exist_ok=True)
p.write_bytes(source.encode("utf-8"))
print(p.name, len(source.encode("utf-8")), "bytes", len(source.splitlines()), "lines")
