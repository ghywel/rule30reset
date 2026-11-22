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

## P10 · 2026-11-19 · Left-diagonal retrodiction, irreversible doubling, and the white diagonals of all four strips

- **Ours.** R38, K2 and I2's pooled count (carried in K7) recover each column from the two after it. The R44 note uses
  the fact that a doubled interval never returns to its source's period. K3 read the seed's six white-to-white gaps
  against 2^Q.
- **Known.** The kit's `Rule30LeftAntiPeriod` (Quint with Gemini; portal entries R30-20261109-2184ee, -3e7d57, -943f77
  and -a7e128, all Lean Verified and Kit Contribution):
  - `D_retrodict_prev`: D j t = xor (D (j + 2) (t + 1)) (D (j + 1) t || D (j + 2) t), the backward recovery.
  - `not_deeper_pair_periodic_of_antiperiodic`: once D j is P-antiperiodic, no deeper adjacent pair is P-periodic.
  - `seventh_white_diagonal_four_way_classification` and `eighth_white_diagonal_and_period32_dichotomy_of_neg_neg`: the
    seventh white diagonal is D 87866, D 229337, D 291256 or D 165748 on the four branches; on the last, where period
    16 is preserved, the eighth is D 183183 or D 174449. The branches fork after the whites D 58286 and D 72575.
- **Found by.** Scanning the portal's full list (376 entries, 19 November 11:56 UTC) for white diagonals, cascades and
  period doubling, then the theorem names in the kit source. `find_known.py` for "D399" and "spacing" had found only
  KIT-INDEX's one-line summary ("four-way seventh-white classification"); "retrodiction" and "irreversib" find nothing.
- **Credit.** Known, and used here as lemmas and as data. Ours is only the reading of the gaps: the nine
  white-to-white gaps at clock 16 on the four strips (52,808; 5,079; 29,580; 171,051; 19,368; 218,681; 93,173; 17,435;
  8,701) average 68,431, which is 1.04 × 2^16 (K8, addendum 1). The interval from D 53207 to D 72575 is taken from the
  theorem names and is unchecked for a white between.

## P11 · 2026-11-20 · Unique predecessors on a recurrent set and in the whole odd half-line

- **Ours.** K8, I7 and M46 identify (L∞) with a precise question. For the left-edge map F(x) = 4x XOR (2x OR x), does every odd 2-adic y whose prefix is periodic at every width have exactly one preimage among **all** odd 2-adics? It always has one recurrent preimage, obtained from the unique predecessor on each finite cycle. The open possibility is an additional, transient preimage. [Carried equivalence, §4.2](research/m29/every-k-chain.md)
- **Known.** Rowland’s Proposition 1 gives uniqueness among histories extending infinitely with the stipulated constant tail, under a directional bijectivity hypothesis. Coven, Pivato and Yassawi’s Theorem 4 and corollary give an odometer on a specified orbit closure. The kit’s `Odometer.G_bijective` is a genuine full bijection for the **right-edge** bit rule. At our left edge the older adjacent 1 erases the current bit. Anashin’s measure-preservation criterion for a compatible map requires permutations on every finite quotient. Already F(1) and F(3) are both 3 modulo 4. That rules out this criterion; a finite collision alone says nothing about extra infinite parents of a specified recurrent y. [Rowland, §2](https://ericrowland.github.io/papers/Local_nested_structure_in_rule_30.pdf) · [Coven, Pivato and Yassawi, p. 7](https://arxiv.org/pdf/math/0511030#page=7) · [Kit, Odometer](https://github.com/WolframInstitute/Rule30PrizeKit/blob/3f32e1a/equivalents/Rule30Equivalents/Odometer.lean) · [Anashin, Theorem 1.2](https://arxiv.org/pdf/math/0602083)
- **Known.** For full, two-sided Rule 30 an output with `010` arbitrarily far right has a unique parent. This holds almost surely for fair coins and on a comeager set. A black-edged row padded with a white left half belongs to a null, nowhere-dense subset of that full shift. The generic result leaves each such row to check. Kit PR #370 gives a unique natural-number ancestor for an aged finite output **and a prescribed k-bit trace** under `AllHistories`. The trace and finite-seed hypotheses change the question. [Kit, Preimages](https://github.com/WolframInstitute/Rule30PrizeKit/blob/3f32e1a/equivalents/Rule30Equivalents/Preimages.lean#L528) · [Kit, Mixing](https://github.com/WolframInstitute/Rule30PrizeKit/blob/3f32e1a/equivalents/Rule30Equivalents/Mixing.lean#L410) · [Kit, ZeroCoastBridge](https://github.com/WolframInstitute/Rule30PrizeKit/blob/3f32e1a/lean/Ruliology/CellularAutomata/Rule30ZeroCoastBridge.lean#L6737)
- **Found by.** Searched the kit and both project indexes under unique preimage, recurrent point, compatible map, odometer and right-closing. In the papers, *rightful history*, *orbit closure* and *permutation modulo* located the decisive hypotheses. A simple control for the distinction is G(2u+b)=2(u+1), b either 0 or 1. On the even 2-adics it is the adding machine, yet each even point has an odd transient parent too.
- **Credit.** Invertibility on a cycle or orbit closure, almost-sure uniqueness and synchronization by a supplied marker are established results. We found no theorem excluding transient parents for every recurrent odd left-edge output.

## P12 · 2026-11-20 · Why the left-edge clocks keep doubling, and what that says about a prescribed row

- **Ours.** The proposed sufficient condition (DL⁻) asks for a spatial run of length 1 modulo 3 flanked by whites in every prescribed phase of a first clock-loss interval of every pointed recurrent strip. (L∞) asks for arbitrarily deep such runs in each prescribed phase. K25 asks whether coverage may be shared between successive stretches.
- **Known.** Jen’s Theorem 4 proves eventual periodicity of diagonals from finite initial conditions. Wolfram identified the left-side doubling criterion; Rowland’s §5 Proposition 2 proves it for a row with a constant left tail. The preceding column must settle to white and its driver must have odd black weight over the old clock. The statement counts a column across *time*. [Jen, pp. 232–233](https://doi.org/10.1007/BF01010579) · [Wolfram, NKS p. 871](https://www.wolframscience.com/nks/notes-2-1--rule-30/) · [Rowland, §5](https://ericrowland.github.io/papers/Local_nested_structure_in_rule_30.pdf)
- **Known.** Gravner and Griffeath’s Proposition 3.3 applies to the rooted edge rule E1D0, their Rule 30. Left permutivity reconstructs the preceding **spatial label** from adjacent periodic time profiles and rules out a globally periodic rooted solution. Their §8 Problem 8 asks how many distinct finite-prefix cycles can occur. Nersissian’s Theorem 13, extending the abstract-only entry P9, treats the single-seed **left** edge by reflection to Rule 86. If Q is the largest eventual diagonal period through depth m, then m+2 ≤ 4^Q. Thus record doublings continue indefinitely. Its reset/integration rule concerns the memory of one temporal column. Berzai’s §11 derives local column identities around a frozen diagonal and enumerates distances to the next white for small doubled clocks. None supplies a spatial reset at a prescribed phase in each required interval. [Gravner and Griffeath, §§3, 8](https://math.ucdavis.edu/~gravner/edge/rpsrev2.pdf) · [Nersissian, §4, Proposition 4 and Theorem 13](https://arxiv.org/html/2609.25077#S4) · [Berzai, §11, version 1.1](https://doi.org/10.5281/zenodo.24295669)
- **Found by.** Searched left diagonal, white interval, first clock loss, backward profiles, period doubling, and then the alternate frames *natural Rule 86 diagonal*, *edge CA*, *E1D0*, and *Stage I tree*. The latter names recover predecessors in the spatial direction, which a search for temporal predecessors alone obscures.
- **Credit.** Eventual periodicity, the parity criterion, absence of a bounded common rooted clock, and unbounded record doublings of the seed all have earlier sources. The remaining inference is from those clocks to row-wise capture at arbitrarily large depths. A literature search cannot establish uniqueness of a new result.

## P13 · 2026-11-20 · The historical ring marker, the infinite cascade and the current finite-width records

- **Ours.** K21–K22 describe inward reconstruction using the four possible pairs of parent bits. I7 uses arbitrarily deep complete reset words to pin down every bit of an infinite parent. P6 already credits the exact one-layer word and Lowry’s cascade.
- **Known.** Wolfram’s 1986 §9, p. 151, credits Carl and Richard Feynman (reference 32) for identifying a run of 3m+1 black cells between zeros in the circular predecessor count. The printed exception has its condition reversed. All 16 labelled four-cell parents give exactly one parent for `0101` (itself) and two for `0000` (`0000` and `1111`). Directly, start just after reading a zero. The possible pair classes are A={00} and B={10,11}, whose B members agree after the next step. Scanning r ones and the next zero induces identity, a constant, or interchange on A,B for r congruent to 0,1,2 respectively. Around a ring containing a zero, any constant gives exactly one cyclic parent. Without a constant the returning permutation has zero or two fixed classes. On an infinite left edge one occurrence fixes just the portion inward of the marker. [Wolfram, original p. 151](https://content.wolfram.com/sw-publications/2020/07/random-sequence-generation-cellular-automata.pdf#page=29) · [Lowry, PR #60](https://github.com/WolframInstitute/Rule30PrizeKit/pull/60)
- **Known.** Kit PR #371 reduces K1 to sixteen phases through width 53,208 and proves `TargetAt` unconditionally for k ≤ 25. PR #372 proves that `earlier`, `schedule` and `phaseCapacity` are invariant when a positive return period is replaced by a positive multiple. PR #47 gives closing under periodic gate-tail conditions. The widths, supplied schedule or restricted tail in these results leave (L∞) open. [PR #371](https://github.com/WolframInstitute/Rule30PrizeKit/pull/371) · [PR #372](https://github.com/WolframInstitute/Rule30PrizeKit/pull/372) · [PR #47](https://github.com/WolframInstitute/Rule30PrizeKit/pull/47)
- **Found by.** Searched the public portal snapshot of 20 November at 18:02:44 UTC (385 entries), including abstracts and headlines, the kit at `3f32e1a`, and all 15 open kit PRs with their file lists, discussion and reviews (83 changed-file records, 20 discussion comments, zero inline review comments). Also searched *circular register*, *predecessor multiplicity* and the *3m+1* marker. [Portal catalogue](https://www.wolframcloud.com/obj/rule-30-prize/Agents/submissions.json) · [Kit at the searched revision](https://github.com/WolframInstitute/Rule30PrizeKit/tree/3f32e1a)
- **Credit.** The link between this marker and predecessor multiplicity predates the project. The arbitrary-height cascade with a supplied schedule is Lowry’s. The recorded search found no unconditional coverage or uniqueness theorem for all the prescribed phases in P11–P12.

## P14 · 2026-11-20 · Three sources read at the page: the size of a stretch, the spacing left open, and the reversed sentence of 1986

- **Ours.** K25 §3 called the rough size of a white-to-white stretch, about 2^Q wheels on clock Q, "ours and tentative" (K2, P9, P10), and told the owner that no formula is known for the spacing of the white wheels. K21–K22 use the run of 3m+1 black cells between whites as the reset word. This entry is claudeCloud's carrying read of P11–P13 (I28), made from the papers themselves (K26).
- **Known.** Gravner and Griffeath, §8, just before Problem 8, on E1D0, their Rule 30: "The time along a path of period π labels before there is a label with no deciders should be of order 2^π, and then death or branching each occur with about equal probability." A label with no deciders is a white column, so this is the 2^Q size of a stretch, as a heuristic, in 2012. The same section gives one limit cycle on [0, 53207] for every seed, credited to Rowland, and Problem 8 as P12 states it. Proposition 3.3 reads "A left permutative edge CA has no periodic solutions, thus no RPS"; the unique predecessor in its proof is the label of the preceding site, a step in space towards the edge, as P12 says. [Gravner and Griffeath, §§3, 8](https://math.ucdavis.edu/~gravner/edge/rpsrev2.pdf)
- **Known.** Nersissian, Proposition 4, is the wheel rule D_m(t+1) = D_(m−2)(t) ⊕ (D_(m−1)(t) ∨ D_m(t)) for the diagonals of Rule 86 from one cell, the reflection of Rule 30: our left side. Theorem 13 is m + 2 ≤ 4^(Q_m), proved by the backward map on pairs of periodic profiles, again a step in space. Remark 3 ends: "The infinitude of actual record depths follows from Theorem 13. A formula for their spacing remains open." So the answer given to the owner in K25 §3 is also the published state. [Nersissian, §4](https://arxiv.org/html/2609.25077#S4)
- **Known.** Wolfram 1986, p. 151, prints: "a configuration has a unique predecessor unless it contains a pair of value zero sites separated by a sequence of 3n + 1 value one sites (with n ≥ 0), or unless N is divisible by 3, and all sites have value one. In the former case, the configuration has exactly zero or two predecessors; in the latter case, it has three." Reference 32 is "C. Feynman and R. Feynman, private communication". The first condition is reversed, as P13 says. COMPUTED here on every ring of 3 to 16 cells: every row that holds such a run has exactly one parent; every row with a white cell and no such run has none or two; the all-black row has three parents exactly when 3 divides N. The paper's own count of rows with none or two parents, about 1.696^N, fits the corrected reading: 4,686 against 4,673 counted at N = 16. [Wolfram, original p. 151](https://content.wolfram.com/sw-publications/2020/07/random-sequence-generation-cellular-automata.pdf#page=29)
- **Found by.** Reading the three papers at the cited places after I28 asked for the carrying read. In the extracted text the exponent of 2^π is flattened; the argument around it, the tree squaring with each doubling of π, fixes it. The sentence was missed by our searches for "spacing", "typical gap" and "renewal" (P9): the paper speaks of labels with no deciders, not of white diagonals.
- **Credit.** The 2^Q size of a stretch is Gravner and Griffeath's heuristic; ours is only the measured gaps set against it (K2, K25 §3), and S3's proved mean bound. The reset word is C. and R. Feynman's, through Wolfram 1986. P11–P13 are carried as written.

## P15 · 2026-11-21 · The gate trap's ladder of lifts, to 30 columns, was in the inherited record before pull M9 asked for it

- **Ours.** Pull M9 (17 November) asked for the gate trap's forbidden gap words and entropy at 20, 22 and 24 columns. K42 found the test already done; K47 replays it exactly at every width from 16 to 30 with an independent implementation, and adds one rung: at 32 columns a word of the free code {5, 3555} is not read from the core (COMPUTED, two methods), which the record did not have.
- **Known.** placego L1610–L1614 and GC2792–GC2800 (9 November 2026; written up in placego's PROOFS.md under GC2794, GC2796 and L1613–L1614), with CP-2.2 of SW02-RESULTS before them. Entropy of the eventual gap language, in bits per double step: 0.132464 (16 columns), 0.127066 (18, 20, 22), 0.126938 (24), 0.125499 (26), 0.122174 (28, with an exact bracket), 0.119193 (30, one implementation). Minimal forbidden words: 33 and 3553 at 16; 3535353 added at 18 to 22; infinitely many from 24, by a pumped family, so the language is not of finite type. G1′: every minimal forbidden word but 33 and 3553 contains 353, equivalent to the code {5, 3555}* being read; it held to 30 columns and would give a floor of 0.099056. Real trapped rows (MEASURED) read nothing the lifts forbid and show no thinning. The line was parked by L1614, to be reopened "only with an idea for controlling a block from inside the cone of earlier blocks". J. Lee's R30-20261030-60990f proves no 33, 3553, 3535353 for the one-cell seed.
- **Found by.** Searching placego's ledger for "3535353", then "wider lift" and "24-column", while preparing M9's first block. M9's own search named PRIOR-ART-ARCHIVE's "Gate-trap pulse skeleton" and did not reach the archive's entry "GC2794 — Known automata/growth tools applied to the trap ladder", which names the ladder but not its figures. The terms that would have found it: "S-16", "ladder", "eventual language".
- **Credit.** The ladder to 30 columns, G1′ and the conditional floor are placego's (Local, with GPT's independent replay to 28). Ours is the replay in this repository and the 32-column rung.

## P16 · 2026-11-21 · The planted survivor’s finite count threshold and the source of M10’s degree comparison

- **Ours.** R63 determines exactly which physical first-check value planting changes and proves the all-width degree comparison. M10 and K43 had described all survival counts as equal.
- **Known.** For L≥1, the kit’s `Rule30PlantedSurvivor.survival_table` gives the difference as one exactly for W≥2L−1 and t≥2⌈W/2⌉, and zero elsewhere. The original result is Herbert with Claude and GPT. The threshold and parity corollaries are Quint with Gemini. P2 credits the Rule 30 first-check degree. The kit also gives the uniform linear checks through `Rule30WallDeadlines.odd90` and `odd150`, and the hybrid’s finite immortal family through `Rule30HybridWall.immortal_iff_param`. [Planted survivor](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261110-7a4a0d) · [Threshold extension](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261111-644a9f) · [Hybrid family](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261110-41fdb3)
- **Found by.** Reading the exact count at the kit’s `survival_table` and the original placego planted-survivor essay, §§3–4. K43’s description obscured the explicit extra row. Searching by module and theorem name also recovers the corresponding catalogue entry.
- **Credit.** The count correction, the parity flip of the total, the uniform linear constraints and the hybrid family belong to the kit. R63 identifies the changed free word and its monomial, proves the degree after cancellation using the coefficient omitting the third bit, and uses the hybrid family to witness both values of its degree-one check.

## P17 · 2026-11-21 · The right dichotomy builds on the known gate locks, ether pinning and finite-seed censuses

- **Ours.** K50.1 (R64–R65) identifies periodic gates for the 58 seeds left open by placego L1612, classifies both fixed-wall ether cuts at every width and locates the two width-24 components that could carry a counterexample. [R65 report](research/k50_1/right-dichotomy.md)
- **Known.** Placego L1612 supplied the original generator and its 1,442 literal trap entries. L1561 and L1569 studied other gate locks. The kit already certifies the 30- and 45-column period-seven locks, the ether wall and the pinning of the full-line black edge in all 28 alignments. Hallee separately tested every physical finite seed through width 20 against a broader gap condition. [Original sampler](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/tests/probes/swarm/sw02/block3/local_trap_real_rows.py) · [Sideways locks](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30SidewaysLocks.lean) · [Black-edge pinning](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30EtherEdgeZero.lean) · [Hallee’s census](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/findings/period-two/gate-census.md)
- **Found by.** Followed L1612 to its generator, read the kit definitions behind “sideways locks” and “ether edge zero”, and checked Hallee’s gate-census criterion. Looking only for “RD” misses the full-line edge theorem. Placego GC2696 distinguishes two physical exterior cells from two independent boundary observations.
- **Credit.** The trap, locks, edge pinning and earlier censuses have the sources above. R65 supplies the 58 individual certificates, the sharp driven thresholds 7 and 37 with every exception accounted for, and the full physical window decomposition at widths 16 through 24.

## P18 · 2026-11-21 · Lowry’s event returns and the nine-pair gate language

- **Ours.** R67 decodes the event by distance to the next kick, proves its local inverse in the gate trap and obtains a physical exclusion for an entire family of kick words. The four-event phase bound comes from the exact GE2 return graph. [K50.2 report](research/k50_2/event-returns.md)
- **Known.** Troy Lowry already identifies the spatial word with right cells 01 under five alternating centre observations. He proves the three finite-window return rules and arbitrarily late visits to both white phases for an alternating singleton tail. His proof tracks seven right cells with two free boundary observations. AIOvernight’s width-13 result gives the nine adjacent kick-gap pairs and nonperiodic singleton kicks. The gate trap already has gaps 3 and 5 and a kick in every five samples after entry. P15 credits the older trap ladder, and K47 and M79 supply the longer forbidden kick words used here. [Lowry, PR #376](https://github.com/WolframInstitute/Rule30PrizeKit/pull/376) · [Nine-pair language](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261109-62afca) · [Five-sample coverage](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30GateTrapWords.lean#L975-L985)
- **Found by.** Read Lowry’s theorem and PR, the kit’s actual `pairOK` list and the K47 and M79 code. Searched both prior-art files, the catalogues and ledgers under EventReturns, event returns, 0101001, GE2, 5225 and even distance. The five-sample coverage is named `u_black_within_five_of_entry` in the trap-words module.
- **Credit.** The underlying event restrictions, phase recurrence, nine-pair language and gate ladder have the sources above. R67 translates between the two observations, distinguishes the GE2 and trapped hypotheses, and proves the forbidden kick factors on arbitrary driven right halves. The local parity checker uses Lowry’s seven-stage certificate.

## P19 · 2026-11-21 · The gate outside the trap: placego had the two exterior components to 43 columns, read as two thin languages, and a census below 2^22

- **Ours.** K51 set out to extend R65's two exterior components (least codes 519 and 1,799 at 24 columns) to wider windows, and to take a census of finite right halves, as if neither existed. K52 reports the outcome: the ladder to 43 columns and the census below 2^22 equal placego's figures exactly. What K52 adds: the two components are identified with placego's X and Y by projection; the ether sinks at 19, 26, 33 and 40 columns; R67's kick-word exclusion on the graph from 16 columns; the census from 2^22 to 2^26 (every half resolved, slowest 6,105 ticks); and the left-side reach test on X and the loops (no short memory).
- **Known.** placego GC2696 (6 November 2026): the full "xx" core at 40 columns, 20,461,951 windows, with two unresolved components X (13,467,586 windows, kick gaps 2, 3, 5) and Y (303,693; gaps 2, 4, 5), 20 locked components, none closed; and every right half below 2^22 resolved by tick 4,189 (4,057,307 to the gate trap, 107,736 to the ether family, 29,260 to lock-7, 1 to lock-7b). placego L1568–L1569: X is the loop 25 with the excursion 33535555, with 4 or at least 6 loops between excursions; Y is the loop 2 with the excursions 45 and 4525, unresolved to 60 columns when lifted alone; real rows cross an excursion at most twice (X) or four times (Y) below 2^22; the left statement for these languages was named and not run. placego GC2698: at 39 to 41 columns X forbids two particular spacings in a row. placego GC2748 (8 November): the cores at 41, 42 and 43 columns (30,317,860; 45,417,256; 66,696,788 windows; X 48,895,838 and Y 630,829 at 43), stopped before 44 at 133,393,576 candidates. Outside placego: Hallee's gate census to width 20 (cited in R64).
- **Found by.** The numbers. K51's ladder printed 30,317,860 and 45,417,256 at 41 and 42 columns, and those figures were in a placego line seen during K50's search for something else. R64's search (RD, the locks, L1561, L1569, L1612) and K51's (the kit modules, R65) both missed GC2696 and GC2748. The terms that find them: "xx40", "core windows", "UNRESOLVED", "LOCKED", "target-avoiding", "bridges", "33535555".
- **Credit.** The exterior cores to 43 columns, the reading of X and Y, and the census below 2^22 are placego's (GPT on the Intel, Local on the M5). Ours are the independent replay, the link to R65, the census beyond 2^22, and the left-side test.

## P20 · 2026-11-21 · The exterior return automata and what a Y endpoint specifies

- **Ours.** R69 recovers the complete X spacing rule at 42 and 43 columns, its sharp clock at 43 and the exact typed Y excursion machines at 40–43. Each Y machine has a family of arbitrarily long minimal forbidden excursion words. [R69 report](research/m9/exterior-grammars.md)
- **Known.** Placego L1569 already computed full gap automata, including Y’s lineage through width 60, gave the two excursion types and showed that longer Y words change across widths. GC2698 and GC2706 established the exact X rule through width 41, including the sharp clock, with Cloud’s carrying read in CL753. CL754–755 followed individual periodic spacing words through larger widths. The repeating pair (4,7) dies at 43, (4,12) at 47 and the constant spacing 7 at 63. GC2768’s finite repetition bound improved the old mean floor, and CL755’s below-83 test covered a bounded list of cycles. [L1569](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/SW02-BLOCK3-BRIDGES.md) · [GC2706](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/GPT-BRIDGE-RETURN-AUTOMATON-20261106.md) · [CL754](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/CLOUD-CYCLE-LIFT-20261108.md) · [CL755](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/CLOUD-HEAD-SUPPORT-20261108.md)
- **Found by.** Followed GC2698’s bridge-history reference to the return-automaton report, and the repeating (4,7) spacing to the cycle-lift report. Reading L1569’s `sep` code established that the final literal `45` may begin `4525`. Counting fully typed excursions changes that test. [L1569 endpoint test](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/tests/probes/swarm/sw02/block3/blocks.py#L45-L51)
- **Credit.** Placego supplies the block decomposition, the earlier DFAs, the two-state X rule through 41 and individual wider cycle tests. K52 identifies the physical cores and gives the comparison ladder. R69 extends the all-length rule for X, derives its width-43 clock, and gives the exact typed pair lists, width-separating words and infinite Y certificates. I45 used the paired-state method on the interior gate language.

## P21 · 2026-11-21 · L1614's finite SAT criterion for gate words, and its witness that three runs of four occur late

- **Ours.** M80 and M81 put runs of four and of five to that criterion, with every UNSAT answer certified by LRAT:
  five closed runs of four never occur in the trap, and four never occur after two samples there.
- **Known.** placego L1614 (Local, 9 November 2026), with the PROOFS.md section on the construction attempt:
  - **The criterion.** A gap word occurs in some right half after P samples inside the trap exactly when one finite
    SAT instance is satisfiable: a trap window, the rule on the light-cone triangle, and the head samples fixed.
    The code {5, 3555} is read at every width exactly when every finite code word is satisfiable.
  - **The scripts:** `local_word_sat.py` and `local_word_sat_past.py`, whose formulation M80 re-implements, clause for
    clause.
  - **The results:** 3535353 is UNSAT from every black trap window; (4, 4, 4) is SAT at P = 20, 60 and 100. Its UNSAT
    answers were not certified.
  - **Also L1614:** real rows never show (4, 4, 4) or (5, 4, 4) (MEASURED).
- **Found by.** Searching placego's ledger for "3555", "free code" and "4, 4, 4" while preparing M78. The scripts are
  under `archived/tests/probes/swarm/sw02/block3/`.
- **Credit.** The criterion, the formulation and the (4, 4, 4) witness are placego's. Ours are the re-implementation,
  with simulated witnesses and LRAT certificates, and the answers for 4⁴, 4⁵, 4⁶, 5⁴ and 5⁵.

## P22 · 2026-11-21 · Early repetitions from the moving edge and the clock of exterior excursions

- **Known.** The quantitative Jen window estimate is in the merged kit’s Rule30ZeroBoundary. Troy Lowry’s pending PR #379, commit `8026612`, bounds a repeat in the sampled gate by the later moving edge. His symbol-count bound uses nonadjacent short gaps in a 3/5 clock. He applies Bugeaud–Kaneko–Kim’s complexity bound on paper to masked observations and centre-cycle readings. The inherited GC2134 already connects Sturmian repetitions to finite deadlines and recoding; no priority is claimed for the Sturmian exclusion. P19–P20 and R69 supply the exterior X language, its spacing grammar and its sharp mean at width 43. [Lowry’s PR](https://github.com/WolframInstitute/Rule30PrizeKit/pull/379) · [Word-combinatorics theorem](https://arxiv.org/html/2510.17177v3) · [R69 grammar](research/m9/exterior-grammars.md)
- **Tested addition.** I48 uses the physical duration at both ends of a repeated block of arbitrary positive-duration symbols. A rational bracket for the mean transfers a fixed relative excess to the physical edge bound. The five equality transitions in R69 make this quantitative for arbitrary concatenations of X excursions. Lean constructs an explicit legal, aperiodic order excluded by finite left support. The claim about a physical row requires its actual gate to read the code. The portal snapshot at 20:30 UTC contained 390 submissions; term checks of abstracts and titles and the local catalogues found no matching exterior-clock statement. The generic repetition mechanism and the external word-combinatorics theorem have the credits above. [Checked source](research/m9/Rule30ExcursionClocks.lean)

## P23 · 2026-11-21 · Period-seven lock entry for every completion of a prefix

- **Known.** The merged kit proves that the width-30 period-seven lock is forward invariant, forces its gate word, and excludes a finite compatible left. It contains a 57-cell prefix family. Troy Lowry’s pending PR #378, head `0aa79bef`, gives an 80-cell prefix taken from singleton age 364, the 728-column, 14-tick ring, and its seven-cell moving-edge mismatch along that start’s alignments. The maintainer requested a prefix criterion that works on a family. Hallee already used universal predecessor ranks for ether-family entry and studied a period-seven lock. GC2251 used compactness and finite covers for a different absorbing target. Our S4 supplies a compatible diagonal subsequence argument. [Kit lock](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30SidewaysLocks.lean) · [Lowry and the maintainer](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378) · [Hallee’s basin argument](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/Rule30Open/Columns/ForcedBasin.md)
- **Our extension.** I49 gives a necessary and sufficient finite-certificate condition for *every* completion of *any* prescribed prefix to enter the kit’s period-seven lock. Its practical sufficient test gives three 25-cell examples at tick 11. The same ring compares every lock class against independently chosen singleton ages. At any positive age one moving cell detects a mismatch in nine physical ticks. The earlier PR supplied the ring and its inverse recurrence. The finite census exercises the family theorem; it does not establish unbounded occurrence on the singleton. [Prefix compactness](research/k50_1/Rule30Lock7Compactness.lean) · [Lock and edge theorems](research/k50_1/Rule30Lock7Prefixes.lean)

## P24 · 2026-11-21 · Complexity of a variable-duration reading without a prescribed mean

Dykstra, Ormes and Pavlov bound the number of generic measures for the closure of a full two-sided orbit (Theorem 1.5). Their Remark 5.18 already gives a symbol-padded Sturmian example. Bugeaud, Kaneko and Kim give the early-repeat estimate for a *one-sided* word, including nonrecurrent words (Theorem 1.4). I51 combines these with Lowry’s sampled-edge obstruction and I48’s physical excursion clock. Padding costs exactly n extra n-factors, which gives the positive limiting duration needed under the strict low-complexity hypothesis. The addition here is the resulting Rule 30 statement for every finite alphabet of physical excursions. The dynamical theorems and the abstract padding argument carry no claim of priority. [Generic-measure bound](https://cs.du.edu/~rpavlov/DOPpaper.pdf) · [Early-repeat theorem](https://arxiv.org/html/2510.17177v3#S1) · [Physical clock](research/m9/Rule30ExcursionClocks.lean)

## P25 · 2026-11-21 · Physical startup loss for the trapped kick clock

Placego’s L1610, GC2789 and GC2794 computed the eventual 16- and 18-column languages and transient forbidden words. The merged kit’s Rule30GateTrapWords and Rule30GateTrapLift prove the six forbidden words used by the independent clock calculation. Thus the 17/4 slope is already implicit in earlier language results. Lowry’s PR #379 combines moving-edge repetition with nonadjacent short gaps. I53 supplies the physical duration bound including startup, its sharp additive constant on a true finite right half, and an all-length inequality for repeated blocks even when only the second occurrence is past entry. The minimizing cycle is a finite-window witness. [Kit lift](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30GateTrapLift.lean) · [Lowry’s PR](https://github.com/WolframInstitute/Rule30PrizeKit/pull/379) · [Physical span and repeat bound](research/m9/Rule30TrapClock.lean)

## P26 · 2026-11-21 · Realizable first boundary pairs and permanent loss of a prefix certificate at fixed width

Lowry’s PR #378 supplied the original physical right-prefix example and ring. The kit’s SidewaysLocks already supplies the two-exterior-cell double step. Hallee’s forced-basin ranks and GC2251’s compactness argument were recorded in P23. I55 connected the universal predecessor test to the exact physical prefix test at sufficiently large width. I57 derives exactly which boundary pairs can arise on the first step from *any* black-time W+1 prefix, identifies the five-bit tails where a whole spurious W-window occurs, and proves that waiting arbitrarily long at two smaller widths fails on a genuinely forcing prefix. The distinction between actual and freely chosen boundaries is the new application. The local Rule 30 recurrence, lock, trap, and predecessor construction are inherited. [Kit window step](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30SidewaysLocks.lean) · [Maintainer’s scope](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378#issuecomment-7066180041)

## P27 · 2026-11-21 · Which short prefixes on the actual singleton force the period-seven lock

Herbert and collaborators supplied the closed 66-window lock, its seven phases and a 57-cell family in [kit PR #227](https://github.com/WolframInstitute/Rule30PrizeKit/pull/227). Lowry applied it to the actual age-364 prefix and supplied its 80-cell certificate in PR #378. The maintainer asked for arbitrarily late actual starts or a criterion forcing entry from a prefix. P23 and P26 credit prior finite-window, compactness and free-boundary methods. K52 already identified the 52-window ether sink at widths 19, 26, 33 and 40. Its alternating gate is part of the earlier classification of exterior Y. [Lowry's family and the maintainer's request](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378#issuecomment-7066180041)

I62 classifies every black singleton age from 7 to 2²⁰ for the specific information budget of 31 positive cells, with each positive quantified over all infinite completions and each negative witnessed by one finite completion that avoids the lock forever. A projected reachability complement and a 452-window closed set provide short certificates for hard negatives. The 452-window set projects into K52's ether sink at width 26. The finite census, shortest prefixes at the four actual ages, sharp deadlines and witness replays are the additions. The example addresses the family criterion. Unbounded recurrence in the genuine singleton remains open.

## P28 · 2026-11-21 · How much scattered information forces seven-lock entry?

Lowry's #378 propagates partial information from 80 contiguous cells at singleton age 364 to identify phase 6 at tick 95. Herbert and collaborators supplied the lock and its closure in kit PR #227. Lowry supplied the singleton application at this age. The maintainer asks for a family-level right-prefix criterion or arbitrarily late actual starts. The diagonal compactness argument used in I49 and I64 is inherited from the kit's Rule30ResetCompactness. Disjoint changes that switch a Boolean outcome are the classical block-sensitivity method. An observation proving the original outcome must meet each such block. [Maintainer's request](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378#issuecomment-7066180041) · [Nisan, *CREW PRAMs and Decision Trees*](https://doi.org/10.1137/0220062)

I64 gives a general test for any scattered set of observed sites, including an infinite one. For the actual start in #378 it then determines the exact minimum and both optimizing sets among arbitrary spatial observations. Negative certificates change only the specified sites of the actual infinite right half and enter the ordinary trap. This makes the lower bound independent of both the observer's spatial reach and the time allowed for lock entry.

## P29 · 2026-11-21 · Which centre schedules force Lowry's net source parity to be aperiodic?

Troy Lowry defined the net of three oriented source arrivals, proved the distance-two XOR identity, and reconstructed column +1 from a periodic centre with two black ticks after each white. His separate selected source channel needs only isolated whites. The present result is about his net and shell. The moving-edge argument is Jen's; David Condrey supplied its quantitative window form and Lowry applied it to a masked right-neighbour stream. I66 uses the same edge obstruction after recovering an observation block with four hidden right bits. I67 uses a finite graph of pairs of right windows on the alternating drive. Pairing two paths on a common observation and the pigeonhole principle are established methods. The six-tick classification, computed relation on the physical window graph, and their consequences for these two streams are the contributions here. The record was searched for source arrivals, net parity, synchronized square and moving left edge. [Source-arrivals PR 374](https://github.com/WolframInstitute/Rule30PrizeKit/pull/374) · [Lowry's repeat bounds, PR 379](https://github.com/WolframInstitute/Rule30PrizeKit/pull/379) · [Kit's finite window bound](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30DrivenLeftWindows.lean)

## P30 · 2026-11-21 · Recovering cells from a single prioritized 10 reading

David Condrey with Codex recovered the four cells one tick into an eight-tick word of the three oriented 10 indicators. PR #297 studied the same observable. I69 keeps only the rightmost 10, recovers the four cells with seven readings and characterizes every static coarsening that still recovers the middle pair. Eight explicit pairs of periodic rows obstruct all other identifications regardless of decoder delay. The unconditional aperiodicity consequence uses Jen's adjacent-column result; the finite repetition consequence uses the moving left edge as in Troy Lowry's PR #379, with a different physical observation. [Condrey's source observable](https://github.com/WolframInstitute/Rule30PrizeKit/pull/253) · [Source-observable follow-up](https://github.com/WolframInstitute/Rule30PrizeKit/pull/297) · [Lowry's repetition theorem](https://github.com/WolframInstitute/Rule30PrizeKit/pull/379)

## P31 · 2026-11-22 · The joint density of a black cell and its right-facing run end

Condrey's PR #253 supplies the low-density inequality and an explicit three-site potential. Quint and Gemini in #297 give its shifted-window and firing formulations. The nine-black shield already proves that each long black run forces the right neighbour white after nine ticks. The middle-face identity follows directly from Rule 30 at a black right neighbour. I72 uses these facts to determine the exact joint density polygon, certify its vertices and optimal finite constants, realize each convex combination on one history and prove growing additive margins on the singleton at two exposed corners. The realization of a prescribed column and right half is the kit's left-permutive reconstruction; the high-density controls use the width-19 ether and the kit's period-five lock. The moving left edge belongs to Jen’s argument. [Condrey](https://github.com/WolframInstitute/Rule30PrizeKit/pull/253) · [Quint and Gemini](https://github.com/WolframInstitute/Rule30PrizeKit/pull/297) · [Nine-black shield](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30BlackRuns.lean) · [Lock construction](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30SidewaysLocks.lean)
