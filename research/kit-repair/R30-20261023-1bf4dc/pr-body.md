# Rule 210 beside the period-2 clock: the one-sided question is false, the two-sided one is true

This adds one module, from two of our portal entries: [R30-20261022-920c1b](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-920c1b) and [R30-20261023-1bf4dc](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-1bf4dc). Both were Lean Verified at the kit's `cc1e0e0` on 22 and 23 October, with Mathlib, but we never sent them to the catalogue; #386 lists them.

**Why rule 210.** `Rule30Realization.barrier` shows that left-permutivity, the moving edge and Jen's theorem cannot decide Problem 1 alone, because rules 90, 150 and 210 share them. Rule 210, `left xor (!center && right)` (`g210`), is the one of the three that is nonlinear and not right-permutive. This module asks it the period-2 question in both of the kit's forms.

**The statements.**
- `not_Q01_210`: the one-sided form is false. In the zero-boundary encoding of `Rule30ZeroBoundary`, the imposed wall is black at even times. Rule 210 then requires its left neighbour to be white at those times (`InX210`). The empty left start satisfies this condition for ever (`white_start_inX`, `white_start_parity`).
- `parity_invariant`, `no_adjacent`, `linear`: for every start satisfying `InX210`, every black cell of the left half `(t, k)` has `t + k` even, so the left half evolves as rule 90's.
- `no_finite_clock`: the two-sided form is true. No finite configuration `x0 : Int → Bool` has a center column reading the clock `0101…` under rule 210.
- `no_finite_eventually_alternating`, `seed_not_eventually_alternating`: none has an eventually alternating center column, in either phase, and the seed does not, in the kit's `run g210`.
- `clock_bg`, `parity_left_of_clock`, `no_finite_clock90`, `Dev.odd_impossible`, `Dev.even_impossible`: the steps below.

**The proof.**
- Under the clock the left half is parity-sparse, whatever the right half (`parity_left_of_clock`). Every admissible left row `L` has a parity-sparse clock realization `bg L`, built sideways from the clock (`clock_bg`).
- Rule 90 is linear, so at time `2^n` it is the sum of the two shifts by `2^n` (`run90_pow2`). For a start supported on `[-R, R]`, choose `2^n > R + 1`. At time `2^n + 1` the four contributing initial sites are outside the support, so the center is white when the clock is black (`no_finite_clock90`). Rule 210 follows rule 90 on the parity-sparse background.
- Otherwise a finite clock orbit first differs from the background of its own left row at some `e ≥ 1`.
  - If `e` is odd, the two orbits differ on diagonal `e` for ever (`Dev.odd_impossible`).
  - If `e` is even, a gate left of the deviation fires by time `e - 1`, and a clearing front carries the deviation right, pair by pair. At the first initially black background gate `w` to the right of the deviation the clock fails at time `e + 2w + 1` (`Dev.even_impossible`).
  - If every background gate to the right of the deviation is initially white, the background is finite and the previous step applies.
- A clock in either phase from time `T` is a clock from time `0` for the configuration at a later time, which is still finite (`run210_add`, `finite_run210`).

**Overlap.** `Rule30Realization` has rule 210 from the single seed only (`run210_eq`, `center210`). Nothing in the catalogue or the open pull requests treats rule 210 beside the clock.

**The module.**
- It is core Lean, imports `Rule30Realization` and `Rule30ZeroBoundary`, and builds on main `cf60d48`. Its declarations use only `propext`, `Classical.choice` and `Quot.sound`.
- The kit's `Check.lean` passes it on fourteen headlines, with full kernel replay (329 constants) and no new axioms. The count is 303.
- It is the two portal entries' sources in the kit's module form:
  - the header imports two kit modules in place of `Rule30PrizeKit` and Mathlib, and the namespace is `Ruliology.CellularAutomata.Rule30Rule210Clock`;
  - the Mathlib tactics are replaced by core ones (`omega`, `Classical.byContradiction`, `Nat.strongRecOn`, `by_cases` for `split_ifs`);
  - core Lean has no `|·|`, so `Finite210`, `no_finite_clock90` and `finite_run210` read `R < i.natAbs` where the entry read `(R : ℤ) < |i|`. With Mathlib the two are equivalent (`Int.abs_eq_natAbs`);
  - core Lean has no `Nat.find`, so `Dev.tau` and the two least choices in `even_impossible` and `no_finite_clock` use a least-witness lemma, `exists_least`.

  The other 90 declarations have the entries' statements, with `ℕ` and `ℤ` written `Nat` and `Int`, and `Dev.tau` keeps its type.
- #398 changes the same count line, import list and table. After each merge, we will refresh this patch against main and rebuild it.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
