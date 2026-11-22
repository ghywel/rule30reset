#!/usr/bin/env python3
"""claudeM5_port.py: the kit form of portal entry R30-20261024-8d7751 (KIT-REPAIR.md, repair 3).

  python3 research/kit-repair/R30-20261024-8d7751/claudeM5_port.py

Reads portal-source.lean (the portal's file, SHA-256 b0113490…) and writes Rule30EtherFamilies.lean beside it.
Only these change:
  - the header: `import Rule30PrizeKit` becomes the module system and the three kit modules used;
  - the module docstring, replaced by a statement of the claims, the method and the credit;
  - the namespace Rule30Submission, which becomes Ruliology.CellularAutomata.Rule30EtherFamilies;
  - two section headers lose their internal references ("the record's L910", "GPT's GC1836");
  - Mathlib's `Relation.EqvGen` becomes `EqvGen`, the same inductive with the same four constructors, defined in the
    module, since the catalogue is core Lean;
  - one proof line of `R31_far`: Mathlib's `List.getD_eq_default` becomes core's `List.getD_eq_getElem?_getD` and
    `List.getElem?_eq_none`.
One section is added at the end: no member of either family enters the gate trap of Rule30GateTrap (two theorems,
after h3artfield's R30-20261122-66c410). Every other declaration and proof line is kept as it is; the script checks
that the declaration lines are unchanged apart from the `EqvGen` name.
"""
import hashlib, pathlib, re

D = pathlib.Path(__file__).resolve().parent
src = (D / 'portal-source.lean').read_text()
assert hashlib.sha256(src.encode()).hexdigest().startswith('b0113490'), 'not the pinned portal source'

HEADER = '''module

public import Ruliology.CellularAutomata.Rule30Ether
public import Ruliology.CellularAutomata.Rule30PeriodTwoSideways
public import Ruliology.CellularAutomata.Rule30GateTrap

/-!
# Two infinite families of right halves locked into period 2 by the ether-and-wall trap

Drive a right half `R` with the alternating column (`Rule30PeriodTwoCoupled.altCol`). Column `1` at the white ticks
is `Rule30PeriodTwoSideways.u R`, and the sideways row `Psi R` has infinitely many black cells whenever `u R` is
eventually periodic (`Rule30PeriodTwoSideways.not_finSupp_Psi_of_eventuallyPeriodic`). Take `R31`, black at cells
`1..5`, and `R495`, black at cells `1..4` and `6..9` (the row of `R31` at time `4`).

* `CQ01_prefix31`, `CQ01_prefix495`: every right half that agrees with `R31` on cells `1..28`, or with `R495` on
  cells `1..24`, whatever its later cells, has `u R q = (q % 2 == 1)` for every `q`, so `Psi R` has infinitely many
  black cells.
* `Psi_prefix31`, `Psi_prefix495`, `Psi_eq`: all of them have one sideways row, that of `R31`.
* `CQ01_fam`, `fam_injective`: the right halves `fam n`, `R31` with one more black cell at `29 + n`, are finitely
  supported, pairwise distinct, and satisfy `CQ01`.
* `not_move_equivalent`: `R31` and `R495` are not joined by the right-end moves (the inverses of the terminal
  rewrites `011 -> 01` and `101 -> 11`, with the black wall counted as a cell left of cell `1`). So the moves do not
  account for every collision of `R ↦ Psi R`.
* `never_enters_gate_trap31`, `never_enters_gate_trap495`: no member of either family has its window in the
  829-window trap of `Rule30GateTrap` at any odd time.

Column `1` of every member locks into period `2`, beside the locks of periods `5` and `7` in
`Rule30SidewaysLocks`.

**Method.** Column `0` is the ether column `B4` (index `3`) at phase `t + 3` (`altCol_ether`). At time `9` for `R31`,
and `5` for `R495`, columns `1..6` carry the ether at that phase and columns `7..19` form one of the wall states of
`Rule30Ether` (decided). `Rule30Ether.trap_invariant` then keeps columns `1..6` in the ether for ever, so column `1`
is the ether column `B5`, which at the white ticks is the parity of the step. Both entries lie within columns `1..19`,
inside the cones of `28` and `24` cells, so radius-one locality (`drv_prefix_agree`) carries them to every member of
the families. In the gate trap a black cell of `u R` is followed by the next at distance `3` or `5`
(`Rule30GateTrap.gaps_of_entry`), and here the distance is `2`. The moves act on reversed cell lists; every chain has
a computable root that the moves preserve, and the two roots differ. Core Lean has no `Relation.EqvGen`, so the
equivalence closure `EqvGen` is defined here, with the same four constructors.

**Credit.** That such right halves never enter the gate trap is from h3artfield's Lean-verified submission
`R30-20261122-66c410`, for the right halves that agree with `175` (cells `1, 2, 3, 4, 6, 8`) on cells `1..28`. The
proof here follows that entry's.
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30EtherFamilies'''

EQVGEN = '''/-- The equivalence closure of a relation (as Mathlib's `Relation.EqvGen`, which core Lean lacks). -/
inductive EqvGen {α : Type} (r : α → α → Prop) : α → α → Prop
  | rel : ∀ x y, r x y → EqvGen r x y
  | refl : ∀ x, EqvGen r x x
  | symm : ∀ x y, EqvGen r x y → EqvGen r y x
  | trans : ∀ x y z, EqvGen r x y → EqvGen r y z → EqvGen r x z

'''

TRAP = '''
/-! ## Outside the gate trap

In the 829-window trap of `Rule30GateTrap`, a black cell of `u R` is followed by the next one at distance `3` or `5`
(`Rule30GateTrap.gaps_of_entry`). In both families `u R` is black at every odd step, so the window of no member is
ever in the trap. -/

/-- A black cell of `u R` two steps after another black cell, after time `t0`, keeps the window of `R` out of the
gate trap at the odd time `t0`. -/
theorem not_trap_of_black_pair (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1) (s : Nat) (hs : t0 ≤ 2 * s + 1)
    (h1 : u R s = true) (h2 : u R (s + 2) = true) : Rule30GateTrap.win R t0 ∉ Rule30GateTrap.trap := by
  intro hw
  rcases Rule30GateTrap.gaps_of_entry R h0 hw s hs h1 with g | g
  · rw [h2] at g; exact Bool.noConfusion g.2.1
  · rw [h2] at g; exact Bool.noConfusion g.2.1

/-- **The first family never enters the gate trap.** -/
theorem never_enters_gate_trap31 (R : Nat → Bool) (h : AgreesPrefix 28 R R31) (t : Nat) (ht : t % 2 = 1) :
    Rule30GateTrap.win R t ∉ Rule30GateTrap.trap :=
  not_trap_of_black_pair R ht (2 * t + 1) (by omega)
    (by rw [u_prefix31 R h]; simp only [show (2 * t + 1) % 2 = 1 by omega]; rfl)
    (by rw [u_prefix31 R h]; simp only [show (2 * t + 1 + 2) % 2 = 1 by omega]; rfl)

/-- **The second family never enters the gate trap.** -/
theorem never_enters_gate_trap495 (R : Nat → Bool) (h : AgreesPrefix 24 R R495) (t : Nat) (ht : t % 2 = 1) :
    Rule30GateTrap.win R t ∉ Rule30GateTrap.trap :=
  not_trap_of_black_pair R ht (2 * t + 1) (by omega)
    (by rw [u_prefix495 R h]; simp only [show (2 * t + 1) % 2 = 1 by omega]; rfl)
    (by rw [u_prefix495 R h]; simp only [show (2 * t + 1 + 2) % 2 = 1 by omega]; rfl)
'''

lines = src.split('\n')
assert lines[0] == 'import Rule30PrizeKit' and lines[3] == '/-!' and lines[30] == '-/' and lines[32] == 'namespace Rule30Submission'
assert lines[33] == 'open Ruliology.CellularAutomata'
body = '\n'.join(lines[34:])                     # the opens, then the declarations
reps = [
    ("The right-end move `S` (the record's L910, the inverse of", "The right-end move `S` (the inverse of"),
    ("/-! ## Infinite families (GPT's GC1836): every right half", "/-! ## Infinite families: every right half"),
    ("Relation.EqvGen Move", "EqvGen Move"),
    ("  rw [List.getD_eq_default _ _ (by simp [cells31]; omega)]; simp",
     "  rw [List.getD_eq_getElem?_getD, List.getElem?_eq_none (by simp [cells31]; omega)]; simp"),
    ("end Rule30Submission", TRAP + "\nend Ruliology.CellularAutomata.Rule30EtherFamilies"),
]
counts = {"Relation.EqvGen Move": 2}
for o, n in reps:
    assert body.count(o) == counts.get(o, 1), o
    body = body.replace(o, n)
anchor = '/-- One move step: `b = S a` with `a` a nonempty right half. -/'
assert body.count(anchor) == 1
body = body.replace(anchor, EQVGEN + anchor)
out = HEADER + '\n' + body
assert not re.search(r'GC\d|L910|GPT|Rule30Submission|Relation\.EqvGen Move|import Rule30PrizeKit', out)
decl = re.compile(r'^(theorem|def|structure|inductive|abbrev|lemma|instance|private) ')
a = [l.replace('Relation.EqvGen', 'EqvGen') for l in src.split('\n') if decl.match(l)]
b = [l for l in out.split('\n') if decl.match(l)]
new = [l for l in b if l not in a]
assert [l for l in b if l in a] == a, 'a declaration line changed'
assert len(new) == 4 and new[0].startswith('inductive EqvGen'), new
(D / 'Rule30EtherFamilies.lean').write_text(out)
print('Rule30EtherFamilies.lean: %d lines, %d declarations kept, %d added, SHA-256 %s' % (
    out.count('\n'), len(a), len(new), hashlib.sha256(out.encode()).hexdigest()))
