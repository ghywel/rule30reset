# Prior art

*Results of ours that turned out to be known, and known results we build on, found since the move to this repository
on 17 November 2026. The earlier record is [PRIOR-ART-ARCHIVE.md](PRIOR-ART-ARCHIVE.md) (placego's, frozen). How and
when to use both is in [METHOD.md](METHOD.md) §4.*

## When to use it

- **Before an experiment or a proof attempt:** search this file and the archive, with KIT.md and KIT-INDEX.md
  (`python3 tools/find_known.py TERM ...`), and name what you searched in the post's `Record searched:` line.
- **Before calling anything new**, in a ledger post or an outward step.
- **The moment a result turns out to be known:** add an entry here, then credit it in the ledger as "known,
  reproved here". A hit decides the credit, not whether the work is done.

## The entry format

```
## P1 · 2026-11-17 · A short name for the known result

- **Ours:** what we found or proved, with its ledger post ID and status.
- **Known:** the earlier result, stated exactly, with its source: a paper with section and theorem number, a kit
  module and theorem name (as in KIT-INDEX.md), a portal entry, or a placego post. What it covers and what it does not.
- **Found by:** how it was found, and the search terms that missed it, so that the next search uses them.
- **Credit:** known, reproved here; an independent rediscovery; or our extension of it, saying exactly what is new.
```

Entries are numbered P1, P2, … in the order they are filed, appended at the end, and never rewritten: a later
correction is a new entry that names the one it corrects.

## Entries

## P1 · 2026-11-17 · Conjecture S's sharp witnesses truncate one eternal row, one black cell in seven

- **Ours:** M6 (17 November) observed that the kit's witnesses `sharp_86`, `sharp_198` and `sharp_310`
  (`Rule30PeriodTwoMass`) are black at depths 1, 2 and 4, then every 7 places (COMPUTED from the kit's constants).
  It also saw that the infinite row with that pattern stays G-valid to depth 2000 (MEASURED). That row is
  2 + 4 + 16 + Σ_k 2^(7k + 1), which is the 2-adic number 2538/127.
- **Known:** the portal entry R30-20261109-4dce4d (@AIOvernight with Claude), "A Sharp Mass Conjecture for Period 2
  of Rule 30". Its abstract says that the 2-adic seed 2538/127 ("one black in seven") has a G trace for ever, and
  that the extremal words are its truncations with the last block changed. The eternal row is stated in the
  abstract but is not among the entry's Lean headlines. The entry does not claim that floors equal least eternal
  densities in general, and it does not treat the gap language.
- **Found by:** the portal's `submissions.json`, searching titles, abstracts and headlines for "Conjecture S"
  before M6's first test. Missed by KIT.md, KIT-INDEX.md and the kit source of Rule30PeriodTwoMass, which name the
  witnesses but not their form. Also missed by `find_known.py` for "7-periodic", "eternal row" and "sparsest". Next
  time, also search "ether" and "2538".
- **Credit:** known. M6's opening observation is a rediscovery. What M6 asks beyond it (floors set by least eternal
  densities in other languages, and a window law) is not in the entry.

## P2 · 2026-11-17 · First-check degree and counts constrain the starting width of a full inverse tree

- **Ours:** R11 (PROOF-SKETCH) uses the first check to bound the width needed for all guarded histories to reach one ending row.
- **Known:** `Rule30FirstChecks.first_check_count` counts all passing starts of width at most 2j. `Rule30FirstCheckDegree.check_degree` makes the check nonconstant at every positive j and `first_check_parity` gives the parity of the count. Herbert with Claude and GPT, [first checks](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261106-bdd993) and [first-check degree](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261110-80b1ea).
- **Found by:** KIT-INDEX.md and the kit proofs under `first_check_count` and `ones_parity`. Searching for surviving ancestors or a guarded merger missed these counts.
- **Credit:** the total count, degree and parity belong to those kit modules. R11 applies them to the complementary exact-width class and groups by full ending row. The tick-46 singleton is a separate forward and inverse computation.

## P3 · 2026-11-17 · The kit supplies the age-26 top-band base for every seed width

- **Ours:** R8 uses the top-20 cycle as the base of its moving cover. M17 independently checked all nonzero seeds narrower than 20 at age 26.
- **Known:** `Rule30AgeTwentyFourInverse.band_from_age_twenty_six` covers every nonzero seed and every age at least 26. It puts exactly the top 20 cells in C20. [Kit PR #292](https://github.com/WolframInstitute/Rule30PrizeKit/pull/292).
- **Found by:** following M17’s reference to #292 and checking its Lean declaration at kit main 8ff5467. Reading only `Rule30LateTwins.band_settles` and `band_late` missed this stronger statement in the inverse module.
- **Credit:** the full base is already in the kit. R13 identifies it as the input to the project’s four-tick cover and scan.

## P4 · 2026-11-18 · R4 uses the white-centre cylinder and the finite no-hit/vacuum identity

- **Ours.** R19 groups all single-seed white centre observations by source row and rewrites the gap-cutoff error as occupancy of a centred all-white window. The counting deductions are PROOF-SKETCH.
- **Known.** Portal R30-20261103-b476c1 and kit Rule30CenterCylinders.cylinder_white_iff give the solid black interval and two-cell guard for every trajectory. The same module proves gap existence on the seed and gap uniqueness. The frozen prior-art entry GC2598 already records the equivalent finite initial vacuum for the no-hit branch. Starting the cone K ticks before observation gives exactly that branch. Portal 2ad8f0 further splits the white-centre count by the right neighbour.
- **Found by.** R4's pointer to GC2598, direct Lean source and searches of portal abstracts. “Source time” and “gap tail” missed the mechanism. “cylinder_white_iff” and “vacuum” recover it.
- **Credit.** Known, reproved here for the finite-vacuum branch. R19 applies these ingredients to the endpoint formula for source multiplicity, its spacing limitation, and the mass of the entirely white row in empirical limits. No priority claim.

## P5 · 2026-11-18 · R4 prescribes spacetime windows by the known leftmost-input inversion

- **Ours.** R21 constructs one orbit agreeing with the seed on a moving half-line with an empirical limit assigning the entirely white row mass at least 1/2 (PROOF-SKETCH).
- **Known.** Rule30CoupledEmptyRight.evol_diff_front advances the rightmost difference exactly one cell per tick. Rule30LightCone.evol_window gives finite speed, and block_evol_leftmost_leaf_surjective gives prescription for aligned blocks. Portal 8db6a9 and 9e138d treat block-level triangular independence and ancestor sensitivity. Placego GC2354 credits the fresh leading initial bit to left permutivity.
- **Found by.** The KIT-INDEX entries for those two modules, direct Lean source, portal abstracts, and the archive. “Vacuum atom” and “empirical measure” missed the underlying result.
- **Credit.** Known triangular inversion applied to nested spacetime windows on a single orbit. No priority claim for orbit gluing or its measure-theoretic consequence.

## P6 · 2026-11-18 · The exact one-layer reset words and conditional reset cascades

- **Ours.** R29 carries M34 and compares two sequential reset schedules on the converged edge bands. Both find the same single-layer reset positions.
- **Known.** Placego G13 and its GC2218 audit identify the exact finite synchronising factors 0 1^(3m+1) 0 b. Kit PR #60 at db6e7112 proves their sufficiency in Rule30InverseCascade.run_resets and conditional multilayer closure in scheduled_cascade_closes. The following bit b is essential. PR #60 leaves the actual presence and ordering of the factors as hypotheses.
- **Found by.** Archive searches for “exact synchronizing factors”, “run_resets” and GC2594/GC2684, then the full PR source. “One-layer” and “strip capacity” missed the earlier characterization.
- **Credit.** Known, reproved via the three-state quotient in the R29 report. The finite comparison with M34's joint capacities applies it to this edge family. [PR #60](https://github.com/WolframInstitute/Rule30PrizeKit/pull/60)

## P7 · 2026-11-18 · The white-wheel fork and the two possible child profiles

- **Ours.** R37 uses both lifts of a white wheel to select a single recurrent phase that avoids M39's drops at every depth.
- **Known.** The spatial induction on periodic column profiles and its fork at a white wheel are in Rowland §5. The kit implements the child/complement alternative in `Rule30UniversalLeftSide.child_white` and gives explicit phase-aligned pairs in `Rule30FourLeftSides.Sp_A1_A0_fork_58287` and `Sp_B1_B0_fork_72576`. [Rowland's paper](https://ericrowland.github.io/papers/Local_nested_structure_in_rule_30.pdf)
- **Found by.** Followed M39's white-diagonal law through the four-strip catalogue and its module imports. Searching for “drop phase” alone misses “child_white” and “fork”.
- **Credit.** Known column mechanism, reproved here. Our application quantifies over every white wheel in one pointed recurrent strip and realizes each finite prefix by a finite seed at all ticks. [R37 proof](research/m29/Rule30PointedWhiteFork.lean)

## P8 · 2026-11-18 · Backward profiles, odd white forks and three-row reset avoidance

- **Ours.** R43 extends the clock-loss argument to every pointed recurrent black-edged strip. R44 uses the white anchors on those strips to force arbitrarily deep ordinary resets in one of three phases.
- **Known.** The spatial inverse and finite common-clock count are in `Rule30LeftUnbounded.B_Sig_succ` and `left_profile_bound` for the single seed. The periodic/antiperiodic white fork is in `Rule30LeftAntiPeriod.D_period_or_antiperiodic`. Lowry's `Rule30ResetFreeThree.finite_nonzero_reset_in_three` forces a reset over three ticks from a nonzero finite zero-wall row. The earlier G13 criterion identifies the delimited runs, P6.
- **Found by.** M39's white-profile argument and searches for “reset-free”, “return map” and “white interval”; the latter misses the archived review GC2216. The finite zero-wall theorem uses the white exterior of a finite row. Here two recurrent white wheels on an unbounded strip replace that boundary condition.
- **Credit.** Known backward reconstruction, time-doubling mechanism and multirow residue automaton. Our additions are the rooted-strip bounds, the finite white-anchor box, the two-anchor three-phase return certificate and the resulting arbitrarily-deep conclusion. [Proof and scope](research/m29/white-return-block.md)

## P9 · 2026-11-19 · The depths where each left-edge period first appears, and the doubling criterion

- **Ours.** K2 reads the gaps between the seed's white diagonals against 2^Q, Q the interval's temporal period, as
  evidence for a counting picture of white returns (CONJECTURE, K2).
- **Known.** Wolfram, *A New Kind of Science*, notes, [page 871c](https://wolframscience.com/nksonline/page-871c/):
  on the left edge of rule 30 from one black cell, "period 2 is first achieved at depth 3, period 4 at depth 8, 8 at
  29, 16 at 400, 32 at 87,867, 64 at 2,107,985,255 or more", and "each period doubling turns out to occur exactly when
  a diagonal in the pattern eventually becomes a white stripe, and the diagonal to its left has an odd number of
  black cells in each repeating block". The criterion is proved in Rowland (2006) §5 (P7) and in the kit
  (`Rule30LeftAntiPeriod.D_period_or_antiperiodic`). The kit's `Rule30SeedLeftSide` lists the white diagonals
  through 87,866, and `Rule30TemporalProfiles.rooted_chain_returns_bounded` puts the next white within 2^(2q) wheels
  of a q-periodic chain, a worst case. None of these states a typical gap.
- **Found by.** A web search for Rowland's paper and left-diagonal period doubling. `find_known.py` for "spacing"
  and "D399" finds only the kit rows; "white return", "renewal" and "typical gap" find nothing. Nersissian, arXiv
  2609.25077 (abstract only), bounds right-side periods, not white gaps.
- **Credit.** Known data and criterion, used here as data. The counting picture is ours and tentative (K2).
