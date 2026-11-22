# Finite ancestors of finite rows: a unique root and age

This adds one module, from our portal entry [R30-20261030-803bc4](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261030-803bc4). That entry was Lean Verified at the kit's `19540bf` on 30 October, but we never sent it to the catalogue; #386 lists it.

**The statements**, for rule 30 on the line (`Rule30Realization.evol` on `Int → Bool`):
- `finite_root_age`: every nonzero finite row `y` has a unique root and a unique age `n` with `evol x n = y`.
  - A root is a finite nonzero row with no finite nonzero predecessor.
  - `2 n` is at most the distance between the extreme black cells of `y`.
- `finite_parent_test`: if the extreme black cells of `y` are at `l` and `r`, a predecessor `p` that is white at every cell from `r` on is finite exactly when `y (l + 1)` and `p (l + 1)` are both black.
- `normalized_ancestor_bijection`: `n`-step evolution, normalized to start at cell 0, is a bijection from the normalized finite rows of width `w` onto those of width `w + 2 n` with an `n`-step finite past.
- `finite_word_enumeration`, `finite_parent_enumeration`, `finite_parent_count`, `finite_parent_small_widths`: exhaustive, duplicate-free enumerations.
  - Exactly `2 ^ (w - 4)` normalized rows of width `w ≥ 4` have a finite predecessor.
  - At widths 1, 2 and 3 there are 0, 0 and 1.

**The proof.**
- Endpoint growth: each tick moves both extreme black cells out by one.
- Reconstruction from right to left: two rows with the same image that agree far to the right are equal.
- An exact translated-image bijection.
- Counts are lengths of proved-exhaustive, duplicate-free lists, so no cardinality library is needed.

**Credit and overlap.**
- The finite ancestor and its age are described in Antti Karttunen's OEIS entries of February 2016: [A269165](https://oeis.org/A269165), the earliest finite ancestor, and [A269166](https://oeis.org/A269166), its age, with [A269160](https://oeis.org/A269160) for one step of rule 30 on binary words. No priority is claimed: this is their formal statement for the kit's `evol`.
- Injectivity on configurations that agree far to the right is `Rule30Equivalents.Preimages.eq_of_evol_one_eq_of_right`. That library also builds the white-right preimage. Its elementary proof is repeated here in core Lean, since the catalogue does not import the equivalents.
- The endpoint arguments specialise edge facts of `Rule30FiniteConfigs` and `Rule30FrozenRuler`.

**The module.**
- It is core Lean, imports `Rule30Prize` and `Rule30Realization`, and builds on main `ba7433c`. Its declarations use only `propext`, `Classical.choice` and `Quot.sound`.
- The kit's `Check.lean` passes it on its seven headlines, with full kernel replay (196 constants) and no new axioms. `lake build Ruliology` passes, and the count is 292.
- It is the portal entry's source in the kit's module form:
  - the namespace is moved to `Ruliology.CellularAutomata.Rule30FiniteRoots`;
  - the headline wrappers move into it;
  - the preparation notes are replaced by a module docstring and section headers.

  Every declaration line is unchanged, and the headline statements are identical.
- PRs #385 and #387 are in the base. This patch adds one module to the 291 already in the kit. If the other repair merges first, we will refresh the catalogue integration against the new main.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
