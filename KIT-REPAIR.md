# Kit repair: our portal entries that never reached the kit

*Eleven of our own portal entries that the kit's catalogue does not hold, found by the portal and kit consistency check
in [PORTAL.md](PORTAL.md) (ledger M97, the portal list of 22 November 16:13 UTC, kit main `a88097e`). The owner asked
for this list on 22 November: our 2 missed entries, our 8 that need Mathlib removed, and our 1 that needs a source
read. Each repair is a kit pull request of the existing portal entry, through METHOD §12, and nothing goes out
without the owner's word. Rows move to the done list when their pull request merges.*

## How a repair goes

1. **The source.** Every entry here predates this repository, so its only copy is the portal's Lean file,
   `https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/file?id=<id>&kind=lean`.
   - Fetch it, and record its SHA-256 in the ledger.
   - Commit it under `research/kit-repair/<id>/` before changing anything.
2. **The kit form.** The kit's README, *Contributing a partial result*, sets it:
   - core Lean 4.35.0 with no Mathlib;
   - the module system (`module`, `public import`, `@[expose] public section`);
   - the namespace `Ruliology.CellularAutomata.Rule30<Name>`;
   - only the kit modules it needs in place of `import Rule30PrizeKit`;
   - a docstring that states the claim and the method.

   No proof idea changes. Only tactics and imports change, unless a row below says the statement itself must be
   recast.
3. **The checks, at kit main.**
   - `lake build` of the module, and the kit's `Check.lean` on its headlines;
   - `lake build Ruliology` with the new import, and the count updated;
   - every headline compared with the portal entry's, statement by statement.
4. **The listing.**
   - Its `public import` goes in `lean/Ruliology.lean`.
   - Its row in *Added in the kit* ends with our credit line and the existing portal id, as S4 to S6 did.
5. **The reads.**
   - A second worker reads the port against the portal source, which is the carrying read.
   - The same worker reads the patch and the pull request text, which is the release read.
6. **The owner's word, then the pull request.** Work in the order of the plan at the end.

## 1. Missed: kit-worthy, never sent (2)

These are core Lean already. The repair is the kit form, the checks and a pull request.

| Entry | What it proves | Source | Against the kit | Repair |
|---|---|---|---|---|
| [R30-20261030-803bc4](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261030-803bc4), *Finite ancestors of Rule 30 rows: roots, boundary tests and exact counts* | Every nonzero finite row y has a unique finite root x and age n with Fⁿx = y, with 2n at most the distance between y's extreme black cells (`finite_root_age`). It also proves: a finite-parent test (a predecessor white from R on is finite exactly when y(L+1) = p(L+1) = 1, `finite_parent_test`); a bijection of n-step finite pasts; and exact counts. | 758 lines, core Lean. Imports `Rule30Prize` and `Rule30Realization`. Every theorem uses `Rule30Realization.evol` on `Int → Bool`. | No finite-root theorem in the kit. It sits beside Hughes's inverse modules and S6's `Rule30TwoSidedInverse`, which follow predecessors' edges but not roots. | Module `Rule30FiniteRoots`. Check whether S6's edge lemmas or `Rule30FiniteConfigs` already supply some steps; drop any duplicates. |
| [R30-20261023-8e6bd3](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-8e6bd3), *The death time at width 52 is exactly 96, with witnesses at widths 56 and 60* | The explicit start `0x7dc2ff6fcc4fd` is black at depth 1 at every even time below 96 and white at 96, so the kit's bound 96 at width 52 is exact (`death_time_52_exact`). Witnesses at widths 56 and 60 give lower bounds there. | 136 lines, core Lean, `decide` through the kit's packed evaluator. Imports `Rule30ZeroBoundarySmall` and `Rule30ZeroBoundaryWidth52`. | The kit's `Rule30ZeroBoundaryWidth52` docstring still says the tightness "is observed, not proved" (`a88097e`). | The smallest repair: offer the theorem as an addition to `Rule30ZeroBoundaryWidth52`, or as a module beside it, and correct that sentence. Ask the maintainers which. |

## 2. Port: kit-worthy, but the proof uses Mathlib (8)

The kit is core Lean without Mathlib. Two kinds of port are needed.

**Light ports (5).** Mathlib supplies only tactics: `ring` (16 to 42 uses), `norm_num` (3 to 6), `use` (1 or 2).
`push_cast`, `omega` and `decide` are in core Lean. A port replaces `ring`, by `grind`, `omega` or explicit
`Nat` and `Int` lemmas, and changes nothing else. The kit modules each imports must be named in place of
`Rule30PrizeKit`.

| Entry | What it proves | Source | Port |
|---|---|---|---|
| [R30-20261022-91b0b0](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-91b0b0), *Under a period-2 center column, a right neighbour that starts with near-squares has no left edge* | Under the period-2 clock on column 0, column −1 is fixed by column 1. A configuration with a leftmost black cell whose visible bits (column 1 at even times) have near-squares at unbounded scales cannot exist (`corollary_F`, `theorem_A3`). | 727 lines; `ring` 37, `norm_num` 3. | **First.** It is the combinatorial core that 0c4a33 and 8084e6 each copy (`corollary_F`). Port it once, as `Rule30ClockNearSquares`. |
| [R30-20261023-0c4a33](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-0c4a33), *Every characteristic Sturmian word is excluded as the right neighbour of a period-2 center column* | For every directive sequence d with every term at least 1, the characteristic Sturmian word c_d is not the visible-bit sequence of any configuration with a leftmost black cell whose centre reads the clock (`characteristic_excluded`). The same holds for its complement. | 991 lines; `ring` 42, `norm_num` 3. It carries its own copy of `corollary_F`. | Port it onto the 91b0b0 module, dropping the copy. Its statement uses no real numbers (d : ℕ → ℕ), so it is the kit's form of the Sturmian family. |
| [R30-20261023-1bf4dc](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-1bf4dc), *Rule 210, the two-sided statement: no finite configuration keeps the period-2 clock on its center column* | For rule 210, x' = ℓ ⊕ (¬c ∧ r), no finite configuration keeps the period-2 clock on its centre column (`no_finite_clock`). So no finite configuration has an eventually alternating centre, and neither does the seed (`no_finite_eventually_alternating`). | 915 lines; `ring` 38, `norm_num` 6. | It bears on the kit's barrier, `Rule30Realization.barrier` (rules 90, 150 and 210 share Jen's hypotheses): it shows what separates 210 from 30 at period 2. Port it with 920c1b as `Rule30Rule210Clock`. |
| [R30-20261022-920c1b](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-920c1b), *Rule 210 beside the period-2 clock: the one-sided question is false and the left half is linear* | For rule 210, the analogue of `Q01` is false, and the left half beside the clock evolves linearly. | 166 lines; `use` 2, no `ring`. | With 1bf4dc. |
| [R30-20261022-1d5070](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-1d5070), *A repeat on the center column cannot put its white run inside the settled band of left diagonals* | If diagonals 0 to M agree at times a₂ − P and a₂, the white run that the kit's `window_jen_col` uses to bound a shared block cannot lie in that settled band (Theorem A'''') | 390 lines; `ring` 16, `use` 1. | A refinement of `window_jen_col`. It may fit beside the kit's `Rule30LeftUnbounded` or `Rule30AgedLeftDiagonals`; read those first. Its companion, 0616de, is covered by `Rule30LeftUnbounded` (PORTAL.md). |

**Restatements (3).** These are stated over real numbers (`ℝ`, `Irrational`, `Int.floor`, `Int.fract`). Core Lean
has no reals, so a port must recast each statement combinatorially. That changes what is claimed, so each needs its
own read. Recommended: port 0c4a33 first, then decide whether any of these is still worth recasting.

| Entry | What it proves | Source | What a recast needs |
|---|---|---|---|
| [R30-20261023-8084e6](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-8084e6), *Every Sturmian word, of every slope and every intercept, is excluded as the right neighbour of a period-2 center column* | For every irrational 0 ≤ α < 1 and every θ, the mechanical word ⌊θ + (i+1)α⌋ − ⌊θ + iα⌋ is not the visible-bit sequence of any configuration with a leftmost black cell whose centre reads the clock from some time on (`sturmian_excluded`). It also covers every sliding block code. | 1106 lines. `ℝ` 96 times, `Irrational` 10, `Int.fract` 28, `Int.floor` 16, plus `Finset` sums. | Its route is `corollary_F` plus a real-number lemma that Sturmian words have near-squares (`sturmian_pairs`). A kit form would state the words by their continued-fraction digits and intercept digits (an Ostrowski-type expansion), and prove that lemma in ℕ. 0c4a33 is that recast with intercept 0. |
| [R30-20261029-dc3d17](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-dc3d17), *An explicit finite horizon for mechanical words beside a Rule 30 clock* | For every real slope α, phase θ and natural C, the mechanical word has a repetition with an explicit bound, and so do its block recodings. Beside a clock, a stretch [a, b] of the visible neighbour that agrees with such a word has b − a < 251(L + 2a + 4) + … | 2197 lines. `ℝ` 309 times, `Irrational` 31, `linarith` 73, `nlinarith` 17. Lean Verified, not Human Verified. | It is uniform in real α, θ. A recast over rational or digit-given slopes would lose that uniformity. Probably leave it portal-only. |
| [R30-20261029-0ef6e2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-0ef6e2), *Finite-arc rotation codes beside a Rule 30 clock* | The visible neighbour of a clocked row cannot eventually equal a finite-step coding of an irrational rotation whose continued-fraction digits exceed 2^(r+1) arbitrarily late. | 1001 lines. `ℝ` 139 times, `Irrational` 17. Lean Verified, not Human Verified. | Its hypothesis is already about continued-fraction digits, so a recast with the rotation given by its digits may be natural. Read it before deciding. |

## 3. Read: a third missed entry (1)

| Entry | What it proves | Source | The question |
|---|---|---|---|
| [R30-20261024-8d7751](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-8d7751), *Two infinite families of right halves absorbed by the ether: CQ01 for every right half with one of two prefixes* | For the prefixes R31 (black cells 1 to 5) and R495 (black cells 1 to 4 and 6 to 9), every right half with that prefix enters the ether-and-wall trap by time 9, so CQ01 holds for it. | 289 lines, core Lean. Imports `Rule30PeriodTwoSideways`. | **Read in K66: it is not in the kit.** The three locks of `Rule30SidewaysLocks` read 10000, 0101000 and 0010100 in column 1, and inside `Rule30GateTrap` black gate cells are 3 or 5 apart. These families read 01 for ever. The kit has the trap invariant and the step from a periodic gate to CQ01, and no family through the ether-and-wall trap beside the alternating column. The repair: the lock is the kit's 53 ether-and-wall windows of 19 columns in two classes, a lock of period 2 in `Rule30SidewaysLocks`' sense; keep the eight headlines word for word. Possible additions, each new and needing its own read (K66 addendum 2): the families never enter the gate trap (h3artfield's R30-20261122-66c410 states this for the seed 175, to be credited); the other time alignment, from the seed 112; and the sharper prefix lengths, 23 and 20 cells where the entry states 28 and 24 (COMPUTED). |

## The plan, in order

1. **8e6bd3**, the smallest: one theorem, and a sentence in the kit to correct. Ask the maintainers how they want it.
2. **803bc4**, core Lean and general.
3. **91b0b0, then 0c4a33 on it**, as one module: the near-square core and the characteristic Sturmian words.
4. **1bf4dc with 920c1b**, rule 210.
5. **1d5070**, after reading `Rule30LeftUnbounded` and `Rule30AgedLeftDiagonals`.
6. **8d7751:** read (K66), and not covered. Send it as a pull request: the period-2 lock beside the three of `Rule30SidewaysLocks`.
7. **8084e6, dc3d17 and 0ef6e2:** decide after step 3 whether a combinatorial recast is worth it.

Each step is one pull request, read by a second worker. The maintainers have been told in kit issue
[#386](https://github.com/WolframInstitute/Rule30PrizeKit/issues/386) (M98), which asks what form they want.

## Status

| Step | Entry | State |
|---|---|---|
| 1 | 8e6bd3 | **Carrying and release reads passed** (I109, I114). `Rule30ZeroBoundaryDeathTimes` gives the exact width-52 bound. [Reviewed source](research/kit-repair/R30-20261023-8e6bd3/Rule30ZeroBoundaryDeathTimes.lean). Three headlines, 34 constants. Reviewed patch `8d0b85fd…` on `ba7433c`. **Agreed** (M100): the tree claudeM5 built and checked on `ba7433c`, `cf85df6f…`, is I114's, and M100 adopts I114's patch, title and body byte for byte. Waiting: the owner's word. #386 asks about placement. |
| 2 | 803bc4 | **Carrying and release reads passed** (I110, I114). `Rule30FiniteRoots` gives the unique root and age, the finite-parent test, and exact counts. [Reviewed source](research/kit-repair/R30-20261030-803bc4/Rule30FiniteRoots.lean) and [port generator](research/kit-repair/R30-20261030-803bc4/claudeM5_port.py). Seven headlines, 196 constants. Reviewed patch `c8618846…` on `ba7433c`. M100 proposes one change to it, a credit sentence in the docstring and the body that also names A269166, Karttunen's age sequence; no Lean line changes (patch `6dcc6753…`, tree `6f8a806e…`). Waiting: gptIntel's recheck of that delta, then the owner's word. |
| 3 to 5 | — | Not started. |
| 6 | 8d7751 | **Read** (K66): not in the kit, so a third missed entry. The kit form is not started; it waits for the owner's word. |
| 7 | — | Not started. |

The author and owner have the release digests in I114, and repair 2's credit change in M100. Either patch can be first on the 291-module base. The second needs a fresh rebase and build after the first merges.

## Done

None yet.
