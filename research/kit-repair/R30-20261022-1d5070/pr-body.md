# A repeat's white run cannot lie in the settled band of left diagonals

This adds one module, from our portal entry [R30-20261022-1d5070](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-1d5070). That entry was Lean Verified at the kit's `cc1e0e0` on 22 October, with Mathlib, but we never sent it to the catalogue; #386 lists it. It builds on `Rule30ClockNearSquares` (#NNN), so it should merge after that PR.

**The statements**, for every `x0 : Int → Bool` with a leftmost black cell `L` cells left of column `i`, evolved by `Rule30Realization.evol`, with left diagonals `D x0 e k t = evol x0 t (e - t + k)` read from the moving edge `e`:
- `theorem_A4_sharp`, `theorem_A4`: if columns `i` and `i + 1` carry equal blocks of length `n` at times `a < a'`, and the diagonals `0 … M` agree at times `a' - P` and `a'`, with `1 ≤ P ≤ a'` and `M < a' - a`, then `n ≤ L + a' - M + 2 * P - 1`. The clocked bound is `n ≤ L + a'`, so the gain is `M - 2 * P + 1`.
- `lemma_B3_sharp`, `lemma_B3`: inside a band of diagonals `0 … M` that agree at times `t - P` and `t`, a white run of row `t` with a black cell on its left has length at most `2 * P - 1`.
- `center_A4_sharp`, `center_A4`: the same for the single seed, with the center column `Rule30Jen.cell t 0` and the kit's `Rule30Diagonals.D`, with `L = 0`.

**The proof.**
- Row `a'` is white at the distances `L + a + 1 … n - 1` left of column `i` (`Rule30ClockNearSquares.theorem_A3_white`). These cells are a run of diagonals ending at `M`, and diagonal `0`, the edge, is black, so the run has a black cell on its left.
- Lemma B3 follows the run back in time. One step back it is either older (two cells wider, black two further left) or newborn (black where it was white, and black at `M' - 1` or `M'`). Going forward, a white run loses cells only from its left side, two a step.
- If the run were older at all `P` steps back, its black cell would be white at time `t - P`, against the agreement. If it was born earlier, the run carried forward from `t - P` would cover both `M' - 1` and `M'` at the birth, and one of them is black.

**Credit and overlap.**
- The clocked bound is Jen's (J. Stat. Phys. 43, 1986).
- `Rule30SettledBarrier` bounds constant runs of the center column by settled white diagonals. `Rule30DrivenLeftWindows` bounds periodic agreement windows of column `-1` by their start. This module bounds a block repeated in two adjacent columns by the width of the settled band.
- Nothing here decides Problem 1: the diagonals that the run reaches have periods up to `2 ^ (a' - a)`, so the agreement hypothesis is not known to hold for the center column's own repeats.

**The module.**
- It is core Lean, imports `Rule30Diagonals` and `Rule30ClockNearSquares`, and builds on main `b5b9dbd` with `Rule30ClockNearSquares` in place. Its declarations use only `propext`, `Classical.choice` and `Quot.sound`.
- The kit's `Check.lean` passes it on its six headlines, with full kernel replay (90 constants) and no new axioms. `lake build Ruliology` passes, and the count is 295.
- It is the portal entry's source in the kit's module form:
  - the header imports two kit modules in place of `Rule30PrizeKit` and Mathlib, and the namespace is `Ruliology.CellularAutomata.Rule30SettledRepeats`;
  - the nine declarations that the entry shares with `Rule30ClockNearSquares` (`edge`, `D`, `agree`, `theorem_A'`, `theorem_A3`, …) are imported from it;
  - the Mathlib tactics are replaced by core ones (`omega`, `Classical.byContradiction`, `Nat.strongRecOn`, `let` for `set`).

  The 13 declarations kept have the entry's statements, with `ℕ` and `ℤ` written `Nat` and `Int`, and the imported nine have them too.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
