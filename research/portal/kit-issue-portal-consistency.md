Portal and catalogue consistency: 58 portal entries with no kit modules, some of them ours

We checked the submissions site against the catalogue. We compared the portal's `submissions.json` (22 November, 16:13 UTC, 393 entries) with the kit at `a88097e`. **58 entries record no kit contribution.** We read each against the catalogue. Most rows rest on the abstract and the headline theorem names, with the Lean source read where marked. Our working list is [PORTAL.md](https://github.com/ghywel/rule30reset/blob/main/PORTAL.md). These are first judgements, not reviews.

**1. Our own entries, which we will fix.** Eleven of ours were never sent to the catalogue. We will send them as pull requests, one module at a time, each read by a second worker first. The plan is [KIT-REPAIR.md](https://github.com/ghywel/rule30reset/blob/main/KIT-REPAIR.md).
- **Two are ready in core Lean.**
  - [R30-20261030-803bc4](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261030-803bc4): every nonzero finite row has a unique finite root and age.
  - [R30-20261023-8e6bd3](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-8e6bd3): the bound 96 at width 52 is exact. `Rule30ZeroBoundaryWidth52`'s docstring still says this tightness "is observed, not proved".
- **Eight use Mathlib and need porting.**
  - Five need only tactic changes: the near-square core and the characteristic Sturmian words beside a period-2 centre, the two rule-210 results at period 2, and one refinement of `window_jen_col`.
  - Three are stated over real numbers (Sturmian, mechanical and rotation words of real slope), so they would have to be recast combinatorially. We will decide on those after the first port.
- **One may already be covered.** [R30-20261024-8d7751](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-8d7751) gives CQ01 for two prefix families of right halves. We will check it against `Rule30SidewaysLocks` and `Rule30GateTrap` before sending it.

**2. Other portal-only entries that look kit-worthy (7).** These are not ours, so we only list them.

| Entry | Authors | What it proves | Why it looks kit-worthy | Read |
|---|---|---|---|---|
| [R30-20261023-c5e3c0](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-c5e3c0) and [R30-20261023-603218](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-603218) | Andy Norris; Jesse v1.4 (solidSF) | A self-replicating shield cascade: the right wall of the (0,1)^j shield stays black for 2j ticks and spawns further shields. So a single-seed period with r ≥ 9j blacks and P − r + 9 ≤ 4·cascadePairs d j is excluded (`no_long_black_run_cascade`, slope 7/4, limit 7/11). The second entry extends the first. | The catalogue has Bosdure's later quarter-period theorem (`Rule30BlackRuns`, slope 9/4), but not the cascade. Their other parts are covered, for example 11 0^q by `Rule30WhiteRunEight`. | Source |
| [R30-20261115-043275](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261115-043275) | KDRonald3; Claude | A one-tape machine computes the centre column in quadratic time: 9 symbols, 69 states, C = 21 (`exists_quadratic_machine`). | `Rule30Problem3` and `Rule30Problem3Bounds` hold the statements and lower bounds. We found no upper-bound construction. | Source, briefly |
| [R30-20261115-2d4add](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261115-2d4add) | KDRonald3; Claude | For every row with a leftmost black cell, at every column, seven sets of three-cell windows recur, and so does a black pair. The white pair need not recur. | We found no catalogue theorem on recurrent windows. It should be compared with `Rule30SourceObservables`. | Abstract |
| [R30-20261023-7e9e6e](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-7e9e6e) | G.P.J.W. Quint; Gemini (Google) | Jen's left-permutive hypotheses hold for exactly four rules, 90, 150, 210 and 30 (`jen_class_iff_four_rules`). | `Rule30Realization` defines the rules (`g90`, `g150`, …), but we found no classification. A small extension. | Source, briefly |
| [R30-20261105-c6874e](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-c6874e) and [R30-20261105-4b74be](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-4b74be) | G.P.J.W. Quint; Gemini (Google) | Machine constructions for every eventually periodic `f : Nat → Bool`, and the aperiodicity transfers that follow. It is the same entry, submitted twice. | It extends `Rule30Problem3Bounds`, and no catalogue theorem has these names. | Source, briefly |

**3. Entries we cannot place without reading the Lean source (5).**
- [R30-20261029-23ac1b](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-23ac1b) (Eric Elbaz): if the column beside the centre is eventually black, its deviation from the alternating reference vanishes above an explicit frontier. So the reconstructed left half is not finitely supported.
- [R30-20261029-99db76](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-99db76) (Eric Elbaz): with the canonical alternating centre, an adjacent column white at all odd times forces infinitely many black cells at time zero.
- [R30-20261108-508c6c](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261108-508c6c) (h3artfield): every Y < 2^52 dies within size Y + 4 steps of G, and Q01 is equivalent to `Open131072Exit`. The portal has no separate Lean file for it.
- [R30-20261108-a0fd36](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261108-a0fd36) (h3artfield): `first_even Y ≤ size Y + 4` for every Y would give Q01 (`Q01_of_size_add_four`). The `Rule30RecognizableBarrier` row cites it only for an observed sharpness.
- [R30-20261122-66c410](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-66c410) (h3artfield): a finite trace-horizon barrier, and an eight-bit obstruction to universal entry into the gate trap.

**4. Duplicate entries without a supersedes link.**
- **Two entries of Quint's look portal-only, but their theorems are in the catalogue.** Each is an earlier copy, with the same title and headlines, of an entry submitted minutes later. The later copy carries the kit contribution and is the one the catalogue cites:
  - [R30-20261105-5e2517](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-5e2517), before [R30-20261105-3bda85](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-3bda85) (`Rule30Coupled`, #168);
  - [R30-20261105-8becc6](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-8becc6), before [R30-20261105-bd78e5](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261105-bd78e5) (`Rule30PeriodFourSkeleton`, #174).
- **The pair in section 2,** c6874e and 4b74be, is a third duplicate. Neither copy has a kit link.
- **The effect.** None of these records `supersedes`, so the earlier copies show no kit contribution, and anyone filtering for portal-only entries meets them.

**Questions.**
1. How would you like the kit-worthy items in section 2 handled? You could invite their authors to open pull requests, or accept ports from others with full credit to the original entry. Or should portal-only entries stay portal-only unless their authors send them?
2. For our own items, is one pull request per module right? For R30-20261023-8e6bd3, would you rather have a theorem added to `Rule30ZeroBoundaryWidth52`, with its docstring corrected, or a separate module?
3. Could the duplicate entries in section 4 be linked to the copies they repeat, so that the portal's list and the catalogue agree?

The check itself is small: a script that reads `submissions.json` and lists every entry with an empty `kitContribution` that our list does not yet have. We are happy to share it, or to rerun it whenever the catalogue moves.
