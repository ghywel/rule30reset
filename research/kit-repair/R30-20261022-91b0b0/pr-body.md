# No near-squares beside a period-2 center, and the characteristic Sturmian words

This adds one module, from two of our portal entries: [R30-20261022-91b0b0](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-91b0b0) and [R30-20261023-0c4a33](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-0c4a33). Both were Lean Verified at the kit's `cc1e0e0` on 22 and 23 October, with Mathlib, and we never sent them to the catalogue; #386 lists them. The second carries a copy of the first, so they form one module.

**The statements.** Let `x0 : Int → Bool` have a leftmost black cell `L ≥ 1` cells left of column `0`, evolved by `Rule30Realization.evol`, with column `0` reading the clock `0101…` from time `T0` on. The *visible bits* are column `1` at even times, `evol x0 (2 * i) 1`.
- `corollary_F`: the visible bits have no near-squares at unbounded scales. There is no `K` with pairs `i < i'`, `i' - i` unbounded and `T0 ≤ 2 * i`, whose visible bits agree for `i' - K` steps.
- `characteristic_excluded`, `characteristic_excluded_compl`, `fibonacci_excluded`: for every directive sequence `d` with every `d n ≥ 1`, neither the characteristic Sturmian word `cw d` of slope `[0; d 0 + 1, d 1, d 2, …]` nor its letter exchange is the sequence of visible bits beside a clock from time `0`. The Fibonacci word is `d n = 1`.
- `characteristic_block_excluded`: the same for every sliding block code of `cw d`.
- `cw_near_square`, `std_near_comm`: the word combinatorics. The standard words are prefixes of `cw d`, and `std (n + 1) ++ std n` and `std n ++ std (n + 1)` agree except in their last two letters, so `cw d` has near-squares of slack `2` at every scale.
- `theorem_A3`: Jen's clocked bound, sharpened by a black diagonal. If columns `i` and `i + 1` share a block of length `n` from the times `a` and `a'`, and the left diagonal `b` is black at time `a'` with `b + a < a'`, then `n ≤ L + a' - b`. Without the diagonal this is `n ≤ L + a'`, the window form of Jen's theorem (`Rule30FiniteMaskedJen.window_jen_col`).
- `col_m1`, `blocks_of_visible`: under the clock, column `-1` is black at odd times and the complement of column `1` at even times, so agreeing visible bits give columns `-1` and `0` a common block of twice the length.
- `infinitely_many_black`, `lemma_B2`: infinitely many left diagonals from the moving edge are eventually black, and no `P ≥ 1` is an eventual period of all of them.

**The proof.** Take an eventually black diagonal `b ≥ L + 2 * K` and a pair `i < i'` far enough apart. The visible agreement gives columns `-1` and `0` a common block of length `2 * (i' - K)` from the times `2 * i` and `2 * i'`. `theorem_A3` bounds it by `(L - 1) + 2 * i' - b`, which is shorter.

**Credit and overlap.**
- The clocked bound is Jen's (J. Stat. Phys. 43, 1986). The near-commutation of standard words is classical (Lothaire, *Algebraic Combinatorics on Words*, Chapter 2).
- `infinitely_many_black` and `lemma_B2` are instances of the kit's tail-left package, `Rule30ZeroWallDiagonals.tail_black_unbounded` and `tail_profile_bound`. The edge-measured diagonals of any configuration with a leftmost black cell form a `TailLeft` array (`tailLeft_D`). The portal entry proved both from scratch; here they use the kit's proofs. `Rule30LeftUnbounded` has the same facts for the single seed.
- `Rule30DrivenLeftWindows` bounds a periodic agreement window of column `-1` by its start. #379's `Rule30GapRepetitions.psi_not_finite_of_sample_repeats` rules out a finite left row when repeats of the white-tick readings outlast their second start by unbounded amounts. Here repeats at unbounded lags that fall short of their second start by a fixed amount already suffice, through the black diagonal. #379 also excludes Sturmian gap orders using Bugeaud and Kim's theorem, cited outside Lean. Here the characteristic Sturmian words are excluded as the readings themselves, with the proof in Lean.

**The module.**
- It is core Lean, imports `Rule30Realization` and `Rule30ZeroWallDiagonals`, and builds on main `b5b9dbd`. Its declarations use only `propext`, `Classical.choice` and `Quot.sound`.
- The kit's `Check.lean` passes it on its twelve headlines, with full kernel replay (174 constants) and no new axioms. `lake build Ruliology` passes, and the count is 294.
- It is the portal entries' source in the kit's module form:
  - the header imports two kit modules in place of `Rule30PrizeKit` and Mathlib, and the namespace is `Ruliology.CellularAutomata.Rule30ClockNearSquares`;
  - the Mathlib tactics are replaced by core ones (`omega`, `Classical.byContradiction`, `Nat.strongRecOn`, `rw (occs := …)`), and two `List.getD` append lemmas are proved in the module;
  - the entry's own proofs of the diagonal theory (period `2^j`, Lemmas B1 and B2) are replaced by the kit's tail-left package, through `tailLeft_D`. Its run bound, Lemma B3, which `corollary_F` does not use, is left out.

  The 44 declarations kept have the entries' statements, with `ℕ` and `ℤ` written `Nat` and `Int`.
- PRs #391 to #394 change the same count line, import list and table. After each merge, we will refresh this patch against main and rebuild it.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
