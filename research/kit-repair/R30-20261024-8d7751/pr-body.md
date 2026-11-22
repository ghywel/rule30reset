# Two prefix families locked into period 2 by the ether

This adds one module, from our portal entry [R30-20261024-8d7751](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-8d7751). That entry was Lean Verified at the kit's `3eca23c` on 24 October, but we never sent it to the catalogue; #386 lists it.

**The statements.** Drive a right half `R` with the alternating column (`Rule30PeriodTwoCoupled.altCol`), so that column 1 at the white ticks is `Rule30PeriodTwoSideways.u R`. Take `R31`, black at cells 1..5, and `R495`, black at cells 1..4 and 6..9.
- `CQ01_prefix31`, `CQ01_prefix495`: every right half that agrees with `R31` on cells 1..28, or with `R495` on cells 1..24, has `u R q = (q % 2 == 1)` for every `q`, whatever its later cells. So `Psi R` has infinitely many black cells.
- `Psi_prefix31`, `Psi_prefix495`, `Psi_eq`: all of them have the sideways row of `R31`.
- `CQ01_fam`, `fam_injective`: the right halves `fam n`, which are `R31` with one more black cell at `29 + n`, are finitely supported, pairwise distinct, and satisfy `CQ01`.
- `not_move_equivalent`: `R31` and `R495` are not joined by the right-end moves (the inverses of the terminal rewrites `011 -> 01` and `101 -> 11`).
- `never_enters_gate_trap31`, `never_enters_gate_trap495`: no member of either family has its window in the 829-window trap of `Rule30GateTrap` at any odd time. These two are new here; see the credit.

Column 1 of every member locks into period 2, beside the locks of periods 5 and 7 in `Rule30SidewaysLocks`.

**The proof.**
- Column 0 is the ether column `B4` at phase `t + 3`.
- At tick 9 for `R31`, and 5 for `R495`, columns 1..6 carry the ether at that phase and columns 7..19 are one of the wall states of `Rule30Ether` (decided).
- `Rule30Ether.trap_invariant` keeps them there for ever, so column 1 is the ether column `B5`: at the white ticks, the parity of the step.
- Radius-one locality carries both entries to every member of the families.
- In the gate trap, consecutive black cells of `u R` are 3 or 5 apart (`Rule30GateTrap.gaps_of_entry`); here they are 2 apart.

**Credit and overlap.**
- The gate-trap corollary is from h3artfield's [R30-20261122-66c410](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-66c410), which proves it for the right halves that agree with 175 on cells 1..28. The proof here follows that entry's.
- Our 24 October entry proves the two prefix families around 31 and 495. The two gate-trap exclusions are added here using h3artfield’s argument.

**The module.**
- It is core Lean, imports `Rule30Ether`, `Rule30PeriodTwoSideways` and `Rule30GateTrap`, and builds on main `ba7433c`. Its declarations use only `propext`, `Classical.choice` and `Quot.sound`.
- The kit's `Check.lean` passes it on its ten headlines, with full kernel replay (131 constants) and no new axioms. `lake build Ruliology` passes, and the count is 292.
- It is the portal entry's source in the kit's module form. Beyond the header, namespace and docstring, three things change:
  - The entry used Mathlib's `Relation.EqvGen`. The module defines the same equivalence closure, `EqvGen`, with the same four constructors, so `not_move_equivalent` reads `¬ EqvGen Move cells31.reverse cells495.reverse`.
  - One proof line of `R31_far` uses core list lemmas in place of Mathlib's `List.getD_eq_default`.
  - The gate-trap section is added.

  The other seven headline statements are identical, and no other declaration or proof line changes.
- Repair PRs #391 and #392 change the same module count, import list and table. After each merge, we will refresh the remaining patches against main and rebuild them.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
