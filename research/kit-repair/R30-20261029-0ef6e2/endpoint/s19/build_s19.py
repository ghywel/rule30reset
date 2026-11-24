#!/usr/bin/env python3
"""Assemble S19's two Lean forms from the reviewed module (claudeM5, M172).

    python3 -I build_s19.py KIT OUT

KIT is a kit checkout at 88fdac9 or later. OUT/portal/Rule30Submission.lean is self-contained at the verifier's
pin. Its core part needs no Mathlib. It carries three pieces of kit main the pin lacks, unchanged apart from namespaces:
the tail-left lemmas of Rule30ZeroWallDiagonals, Rule30ClockNearSquares up to corollary_F, and Rule30RotationEndpoints
from the folder above. After it comes the real-number layer (M173): the bodies of RealBridge.lean, RealBlockBridge.lean
and PhaseLineBridge.lean, with five narrow Mathlib imports. OUT/kit/Rule30RotationEndpoints.lean is the module for the
kit, core only. The only edits to the reviewed module are the comments in DOC, which state the scope of I221, and the
only edits to the companions are their namespace lines.
"""
import pathlib, re, sys

here = pathlib.Path(__file__).resolve().parent
kit, out = pathlib.Path(sys.argv[1]) / "lean/Ruliology/CellularAutomata", pathlib.Path(sys.argv[2])

DOC = [
 ("the supremum of the `g n / n` is then irrational and `g n` is the floor of its `n`-th multiple. (Both directions are\n"
  "checked against Mathlib's real numbers in a companion file outside the kit.) `PhaseLine g f` says that every\n"
  "increment of `f` over `n` ticks is `g n` or `g n + 1`, as for `f t = ⌊t α + θ⌋` with any real `θ`. The arc `[0, γ)`\n",
  "the supremum of the `g n / n` is then irrational and `g n` is the floor of its `n`-th multiple for every `n ≥ 1`; `g 0`\n"
  "is free. (Both directions are checked against Mathlib's real numbers in a companion file outside the kit.)\n"
  "`PhaseLine g f` is a condition on increments: every increment of `f` over `n` ticks is `g n` or `g n + 1`, as for\n"
  "`f t = ⌊t α + θ⌋` and for `f t = ⌈t α + θ⌉ - 1` with any real `θ`. The arc `[0, γ)`\n"),
 ("/-- `f` is the sequence of floors of a line of the slope of `g`, with any phase. -/\n",
  "/-- Every increment of `f` over `n` ticks is `g n` or `g n + 1`, as for the floors of a line of the slope of `g` with\n"
  "any phase. -/\n"),
]

def between(text, a, b):
    i = text.index(a)
    return text[i:text.index(b, i)]

rot = (here.parent / "Rule30RotationEndpoints.lean").read_text()
for old, new in DOC:
    assert rot.count(old) == 1, old
    rot = rot.replace(old, new)
zero = (kit / "Rule30ZeroWallDiagonals.lean").read_text()
near = (kit / "Rule30ClockNearSquares.lean").read_text()

tail = between(zero, "/-! ### The tail-left interface -/", "/-! ### The zero-wall diagonals -/")
near = between(near, "open Rule30Realization (evol)", "/-! ## Standard words")
body = between(rot, "/-! ### Integer floors", "end Ruliology.CellularAutomata.Rule30RotationEndpoints")
doc = between(rot, "/-!\n# Rotation words", "-/\n")

CARRIED = """
**Carried here.** The verifier's kit predates `corollary_F`. `Tail` is the tail-left package of the kit's
`Rule30ZeroWallDiagonals` and `Near` is the kit's `Rule30ClockNearSquares` up to `corollary_F`, with their proofs.
What follows them is new. The last section is the real-number form, and alone uses Mathlib.
"""

def companion(name):
    text = (here.parent / name).read_text()
    text = between(text, "namespace RotationRealBridge\n", "end RotationRealBridge").replace("namespace RotationRealBridge\n", "", 1)
    return re.sub(r"^open Ruliology.*\n", "", text, flags=re.M).strip()

REAL = """
/-! ### Real numbers

The theorems above are about integers and their proofs are core Lean. These state them with Mathlib's real numbers: the
hypotheses `IrrationalLine` and `PhaseLine` are the floors of an irrational line and the two roundings of a line of the
same slope, and the exclusion is for a rotation by an irrational `α` read through an arc `[0, γ)`. -/

section Reals

"""
pdoc = doc.replace("(Both directions are checked against Mathlib's real numbers in a companion file outside the kit.)",
                   "(`irrationalLine_iff`, in the last section.)")
assert pdoc != doc
pdoc = pdoc.replace("**No real numbers.**", "**In integers.**")
anchor = "and `m = 2` as an\n  example.\n"
assert pdoc.count(anchor) == 1
pdoc = pdoc.replace(anchor, anchor + """* `rotation_block_excluded`, `rotation_excluded`: the exclusion over the real numbers, for an irrational angle `α`, the
  arc `[0, γ)`, either end, any translate, and any Boolean function of finitely many readings.
* `irrationalLine_iff`, `phaseLine_iff`, `phaseLine_one_exception`: what the two integer hypotheses say of real lines.
""")

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
  + "\n\n".join(companion(n) for n in ("RealBridge.lean", "RealBlockBridge.lean", "PhaseLineBridge.lean"))
  + "\n\nend Reals\n\nend Rule30Submission\n")
assert '"' not in source and "\\" not in source

for name, text in (("portal/Rule30Submission.lean", source), ("kit/Rule30RotationEndpoints.lean", rot)):
    p = out / name
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text)
    print(name, len(text.encode()), "bytes", len(text.splitlines()), "lines")
