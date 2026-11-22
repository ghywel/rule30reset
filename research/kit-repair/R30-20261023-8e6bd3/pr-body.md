# The death time at width 52 is exactly 96

This adds one module, from our portal entry [R30-20261023-8e6bd3](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-8e6bd3). That entry was Lean Verified at the kit's `cc1e0e0` on 23 October, but we never sent it to the catalogue; #386 lists it.

**The statement.**
- `death_time_52_exact`: the start `0x7dc2ff6fcc4fd`, supported at depths at most 52, is black at depth 1 at every even time below 96.
  - With `Rule30ZeroBoundaryWidth52.q01_width_le_52`, this makes the least uniform even death bound at width 52 exactly 96.
- `width56_lower`, `width60_lower`: two more explicit starts are black at depth 1 at every even time below 100 at width 56, and below 114 at width 60.
  - So no uniform bound there is smaller. Upper bounds at those widths are not proved here.

**The proof** is a kernel evaluation through the kit's packed evaluator. Bit 0 of `prun w (2 s)` is checked by `decide +kernel` for every s below D / 2, and `run_toFun` turns it into the physical cell `zrow (toFun w) t 1`.

**The module.**
- It is core Lean and builds on main `b5b9dbd`. Its declarations use only `propext`, `Classical.choice` and `Quot.sound`.
- The kit's `Check.lean` passes it on its three headlines, with full kernel replay (34 constants) and no new axioms. `lake build Ruliology` passes, and the count is 294.
- It is the portal entry's source in the kit's module form. The headline statements are identical, and no proof changes. The docstring's provenance notes are replaced by a statement of the claim and the method.

**Two notes.**
- `Rule30ZeroBoundaryWidth52`'s docstring still says the tightness of 96 "is observed, not proved". We have left that module untouched, since the README's provenance note tracks its docstring. We can add a pointer there, or move the theorem into it, whichever you prefer (also asked in #386).
- PRs #385, #387 and #388 are in the base. This patch adds one module to the 293 already in the kit. If the other repair merges first, we will refresh the catalogue integration against the new main.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
