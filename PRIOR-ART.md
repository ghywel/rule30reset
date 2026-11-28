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

## P32 · 22 November · Two period-three classes seen from the left (I73/I74)

Condrey's #253 and Quint and Gemini's #297 gave the source observable and bounds. The kit already separates the two primitive period-three words and reduces their exclusion at the singleton centre to driven-half questions. Its ether erosion supplies the white-tail input. I73 compares the source counts two sites left to the number of defective 011 triples with optimal constants. I74 recognizes a promised 001 phase from the ordered movie of the same two sites and gives the shortest observation and sharp symmetric radius. [Detailed credit, proofs and conditions](research/source-density/quiet-corner.md).

## P33 · 2026-11-22 · Minimal 001 observers and a phase-free count

Condrey's source-observation work, Herbert's period-three language, and the ether erosion of Perez Morales and Lowry supply the inputs. I75 classifies static recodings of two ordinary sites for recognition of the one-black period-three class, proves sharp horizons, and counts defective target triples through a three-symbol observation. The finite-right skeleton extends the kit's singleton-specific phase statement to an arbitrary finite right tail with a deadline. [I75 evidence and credit](research/source-density/clock-observers.md).

## P34 · 2026-11-22 · Reading the effective boundary and recovering a source count

Rule30MaskedJen gives the effective boundary, Rule30Realization allows arbitrary target traces with prescribed initial right half, and Rule30BlackRuns gives the shielding exclusion. I76 characterizes exactly when that boundary determines a periodic template, and which linear score of two left-site counts survives observation of an arbitrary target column. Herbert's period-three language and the I75 observations lead to sharp four- and eight-frame tests for 011. [Definitions, proofs and receipts](research/source-density/effective-boundary.md).

## P35 · 2026-11-22 · Mixed sparse pulses and the left-only mask exclusion

WhiteEndNine already excludes gap 9 alone. AIOvernight’s GrammarRuns admits every ordering with gaps at least 10, and ResetMixtures admits every ordering with gaps at least 9 and some gap at least 17. I77 covers arbitrary mixtures of 9 with 15 or 16, using a rank on the twelve right cells and a period-independent physical settling argument. Separately, Lowry's open PR #57 defines periodic black-time consistency; the maintainer asked how it relates to CQ and Q01. I77 prunes isolated pulses at a fixed boundary, identifies the zero-boundary branch with the kit's QP questions and distinguishes left pins from a physical right continuation. [Sparse pulses and earlier exclusions](research/white-gap-mixtures/README.md) · [Mask reductions and sources](research/source-density/effective-boundary.md).

## P36 · 2026-11-22 · Ordered sparse gaps at any site with a leftmost black

I78 extends AIOvernight’s reset-mixture and run-grammar exclusions by allowing every intermediate gap length and testing one cyclic adjacency. A three-mode law for the right neighbor, combined with finite-left masked Jen, forces every possible sparse periodic word to contain a ten-white gap followed by a nine-white gap. The finite-strip estimate also bounds departures from that law by twice the number of such joins plus twenty. [Theorem, credit and replay](research/white-gap-mixtures/ordered-gaps.md).

## P37 · 2026-11-22 · Counting all candidate sparse gap orders

I79 combines the second-white mode in WhiteEndNine with finite-left masked Jen and AIOvernight’s sparse-gap families. The new 33-tick theorem locates the only unrestricted phase on arbitrary drives. Counting the gap orders readable in a component with both outputs then bounds the whole candidate language independently of period. A separate alternating-nine grammar permits arbitrary long gaps from ten through sixteen, including the ten-nine join that escapes I78. [Construction, sources and verification](research/white-gap-mixtures/sparse-word-growth.md).

## P38 · 2026-11-22 · Physical exclusions with the full finite-strip growth rate

A single width-27 return with independently selectable observations lets every readable input factor extend to an ambiguous periodic drive. Thirteen copies of that same return force every ordinary history into AIOvernight’s absorbing G set. Together these give a full-rate family of false positives for the strip criterion, including primitive words at every sufficiently large gap count. [Padding proof, physical separation and receipts](research/white-gap-mixtures/physical-padding.md).

## P39 · 2026-11-22 · Ordinary sparse-gap transitions and sharp three-gap entry

AIOvernight’s ResetMixtures gives the absorbing set G and its closure under all gaps of at least nine. The merged realization theorem turns initial right completions into full-line witnesses. Their combination classifies all three-gap resets from an unrestricted start, cuts the growth of the recurrent candidate language, and exhibits a one-bit obstruction to joining individually physical gaps. [Classification](research/white-gap-mixtures/cold-reset.md) · [Physical reader and gluing](research/white-gap-mixtures/ordinary-gaps.md).

## P40 · 2026-11-22 · Required gap factors and a finite repetition bound

AIOvernight’s grammar and absorbing-set theorems, finite-left masked Jen, and equal-input strip walks give compulsory alphabet and order conditions at every period. Troyusrex2’s open PR 379 bounds early repeated singleton observations. Combining its theorem with endpoint determination proves a finite r²-endpoint bound in a restricted recurrent component. The graph and fixed-clock evidence are separate from the kernel implications. [Sources, controls and open cases](research/white-gap-mixtures/periodic-gap-requirements.md).

## P41 · 2026-11-22 · Which pulses can carry a nonperiodic reading?

AIOvernight’s sparse-gap reset theorem and the finite-left masked Jen theorem leave an exceptional second-white sample on the right. The sharp ordinary age for a black reading after a gap longer than nine is 24. Equal-input recurrent paths can disagree only at a narrower gap context, with at most one variable position per twelve pulses for fixed endpoints. Two four-letter examples with strip branching have exactly one and two continuous traces from the specified root. [Proofs, controls and relation to PRs 378 and 379](research/white-gap-mixtures/second-white-context.md).

## P42 · 2026-11-22 · Sharp two-black-run forcing and a faster alternating shield

Katip Kurtuluş’s open PR 381 gives local run transitions for the singleton center. The new table gives the exact preceding-run threshold at every positive final run length, with ordinary lower witnesses and an exclusion at every site of every finite-left configuration. The kit’s nine-black shield and Bosdure’s self-shielded quarter-period theorem improve from a 135-tick guarantee for 30 cells to a sharp 128, saving seven ticks per fifteen pairs at arbitrary width. The note distinguishes kernel proofs, independently verified LRAT inputs and the remaining kernel-replay work. [Proofs, source comparison and controls](research/black-run-transitions/README.md).

## P43 · 2026-11-22 · Exact ten-cell shield and finite-left quarter-period exclusions

PR 381 studies the singleton’s run transitions. The kit’s black-run module proves the two self-shielded quarter-period tests for the singleton, and its finite-configuration module gives earlier half-period tests at any site. Our 44-tick certificate improves the shield at all widths and carries both quarter-period tests to arbitrary finite-left sites. A separate moving-window potential improves the asymptotic sufficient coefficient to 101/12 with an externally verified table. [Hypotheses, examples and verification](research/black-run-transitions/README.md).

## P44 · 2026-11-22 · A moving white endpoint carries the preceding black run

Bosdure’s moving wall stays black for two ticks per pair before turning white. The observed black interval on that wall also includes the part of the incoming run left after building the pairs. Iterating this fact gives a sharp one-pair loss of seven, stronger period bounds on every finite-left row, and a center-only finite-repetition criterion using Troyusrex2’s PR 379. Murzin’s earlier no-glider theorem covers the sublight rigid-front obstruction. [Carrying proof and scope](research/black-run-transitions/white-pulse-relay.md) · [Moving-front limits and attribution](research/black-run-transitions/README.md).

## P45 · 2026-11-22 · The full-line inverse theorem and the exact capacity at width 300

- **Ours.** M88 transports the one- and two-step edge conclusions to arbitrary full-line preimages and certifies the age-seven counterexample there. M89 transports the capacity criterion and its two sufficient hypotheses. R74 checks their proofs and instantiates the width criterion through depth 25 on the line. [K50.3 carrying read](research/k50_3/review.md)
- **Known.** Hughes proved the age-8 and age-24 theorems and reset tables beside the fixed white wall. Lowry’s scheduled inverse cascade is the basis of the kit’s S2 argument. Quint and Gemini’s open PR #371 proves `K1 300 = 25` and the finite-wall conclusion through depth 25. Its capacity equality transfers unchanged to M89. [Hughes’s one-step module](https://github.com/WolframInstitute/Rule30PrizeKit/blob/10cc04616a8696425cb2578ad16c8e34becbbe71/lean/Ruliology/CellularAutomata/Rule30AgeEightInverse.lean) · [Two-step module](https://github.com/WolframInstitute/Rule30PrizeKit/blob/10cc04616a8696425cb2578ad16c8e34becbbe71/lean/Ruliology/CellularAutomata/Rule30AgeTwentyFourInverse.lean) · [Lowry’s schedule](https://github.com/WolframInstitute/Rule30PrizeKit/pull/60) · [Quint and Gemini’s exact capacity](https://github.com/topics-ledger-framework/Rule30PrizeKit/blob/2e253ec287a108709c180c9d0e4f32c2d4363960/lean/Ruliology/CellularAutomata/Rule30EveryKInverse.lean#L770)
- **Found by.** Followed M87’s comparison with #371 to the theorem defining its width-300 milestone, then checked its type against M89’s `kTick_edge_line`. Searched the live portal (392 entries) and the titles and descriptions of all 16 open kit PRs for leftmost cells, two-sided inverses, preimages and aged edges.
- **Credit.** The reset bands, schedule, existing conditional chain and finite capacity are inherited. M88 and M89 supply the full-line argument. The bounded unconditional full-line statement is a direct composition of M89 with #371.

## P46 · 2026-11-22 · Norris's self-replicating shield cascade: the black-run slope 7/4 for the single seed

- **Ours.** gptIntel's white-endpoint relay (I103; P44, which this entry corrects in its credit): a black run of n ≥ 9
  ending in white passes a run of at least n − 7 two sites right; so 7j + 2 blacks give 4j ticks of right-neighbour
  agreement, and at every site of every row with a leftmost black cell a period P with r blacks then white is
  excluded when 7P + 29 ≤ 11r. I103, K64 and NOW.md give the limiting fraction "falls from 9/13 to 7/11" as new.
  Lean read in M95: the proofs pass.
- **Known.** Andy Norris and Jesse v1.4 (solidSF), portal entries
  [R30-20261023-c5e3c0](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-c5e3c0) and
  [R30-20261023-603218](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-603218), Lean Verified
  and Human Verified, 23 October, not in the kit. `no_long_black_run_sharp`: the right wall of the (0,1)^j shield
  stays black for 2j ticks, whatever lies to its right, doubling column 1's horizon to 4j. `no_long_black_run_cascade`:
  that wall's black time spawns secondary shields of ⌊2j/9⌋ pairs, recursively (`cascadePairs d j`); a periodic
  centre column with a black run r ≥ 9j and P − r + 9 ≤ 4·cascadePairs d j is excluded, "asymptotically r ≥ (7/11) P".
  Single-seed centre column only. The cascade does not carry the incoming run's unused black ticks.
- **Found by.** M95's portal search on "shield" and "black run" (393 entries, 15:36 UTC), then the two Lean sources.
  "Relay", "white endpoint" and "quarter period" miss it; it says "right-sealed", "double-horizon",
  "self-replicating shield cascade" and "non-black multiplier".
- **Credit.** The 7/4 slope and the limit 7/11 for the single seed are Norris's. The relay is an extension: it
  carries the unused part of the incoming run as well as the wall's 2j ticks, which makes the constant sharper (for
  every P < 400 it excludes every (r, P) that Norris's or Bosdure's tests exclude, and 2,718 more, from (16, 21)), with
  the exact one-pair loss of seven. New beyond Norris: that sharper constant, every site of every row with a leftmost
  black cell, any certified block H (17/27 and 27/43 from the 44- and 70-tick blocks), and the finite-centre corollary
  with PR 379.

## P47 · 2026-11-22 · The sharp Pell run of the phase-zero silver half-circle word

- **Ours.** N6 measured maximal agreement at lag 17 on [13,40] and the analogous intervals at later Pell
  lags. I123 gives a direct proof in those coordinates and matches the interval to the kit's fixed slack.
- **Known.** Local's 7 October L099 note on placego G143 states the sharp interval at every mediant. Write
  d, D for consecutive denominators of the silver slope and Q for the mediant lag. The mismatches at d and d+D
  enclose an agreement of length D−1 with later start D+1. GC2187 carries the same conclusion for any eventual
  continued-fraction tail of twos with eventually odd numerators. L1192 checked both signed intervals.
  [G143/L099](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/proofs/G143-an-aperiodic-half-circle-code-passes-every-repeat.md)
  · [GC2187 and its review](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/wolfram-agents/UNIFORM-RECODING-DELIVERY-SCOPE.md#gc2187-hand-candidate--the-phase-zero-repetition-exponent-has-an-exact-exceptional-maximum)
- **Found by.** Following N6's G143 pointer beyond the main repeat inequality to the second-reader note, then
  searching *mediant*, *signed arc* and *exceptional class*. Searching *Pell* missed the original notation.
- **Credit.** Known, reproved here. N6 recovered the endpoints. The Rule 30 application joins these arithmetic
  witnesses to `Rule30ClockNearSquares.corollary_F` from #395. I123 also gives the direct three-case argument
  for half-circles started at a cut endpoint.

## P48 · 2026-11-22 · Horizontal black pairs count temporal falls in the column to their right

- **Ours.** In I72's `fall_count`, subtracting the spatial 10 count from the black count at site j gives the
  number of temporal 10 transitions at j+1, on any interval of any Rule 30 history. K67 and I124 read it for S9.
- **Known.** On 6 November Ulrey proved both the pointwise centre identity `center_block_10_eq_left_black` and
  the count `count10_eq_spatialBlackLeftBlackCount`. On 12 November Quint and Gemini included the count as
  the second component of `count_center_eq_spatial_counts`. The kit retains Ulrey's theorem names.
  [Ulrey, 2b2509](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261106-2b2509)
  · [Quint and Gemini, 8b6538](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261112-8b6538)
  · [Rule30TwoBlockCounts](https://github.com/WolframInstitute/Rule30PrizeKit/blob/cf60d480c69a2f3526663b93f585a5c7398e0950/lean/Ruliology/CellularAutomata/Rule30TwoBlockCounts.lean#L299-L306)
- **Found by.** K67's two-block search and I124's read of both original Lean files. Searching only for
  *fall_count* or *run ends* misses the centre count under *spatialBlackLeftBlackCount* and *spatial11Left*.
- **Credit.** The local identity and the centre count are known. Applying them at j+1 and summing on
  [s,s+T) gives I72's count. The middle face follows by bounding the number of temporal falls by ⌈T/2⌉.

## P49 · 2026-11-22 · Repetition exponents of rotation codings: what Jen's bound and corollary F exclude

- **Ours.** N6 and N7 (MEASURED) found the following for golden rotation codings. Large-excess repeats, which
  violate Jen's bound, recur at a stationary rate of about 0.18 per scale for random one- and two-arc codings. The
  silver half-circle word passes Jen but has exact Pell near-squares (P47), so #395's `corollary_F` excludes it.
  CONJECTURE (N7 addendum 1): for a bounded-type rotation and almost every choice of endpoints and phase, a finite-arc
  coding has `Dio > 2`, so Jen's bound alone excludes it.
- **Known.**
  - Nguyen, *Spectrum of the refined Diophantine exponent*, v2, 5 October 2026 ([arXiv](https://arxiv.org/html/2608.20191v2)),
    Theorem 7.4. For a non-constant coding of an irrational rotation by a finite partition, at any phase:
    `1 < Dio < ∞` if the angle is badly approximable, and `Dio = ∞` otherwise. Theorem 7.2: `Rdio = ∞` always.
    No value of `Dio`, no dependence on phase or endpoints, and no almost-every statement appear in §7. Section 9's
    one bounded-type conjecture, Peltomäki's, concerns episturmian words.
  - Bugeaud–Kim, Lemma 10.3: `rep = Dio/(Dio − 1)`; for Sturmian words `rep ≤ √10 − 3/2 < 2`. Read in placego GC2189
    and GC2193, not re-read here.
  - In these terms Jen's bound (`RepeatBound`, 0ef6e2) excludes every word with `Dio > 2` (`rep < 2`).
    `corollary_F` excludes, beyond that, words with repeats at unbounded lags falling short of their second start
    by a fixed amount.
- **Found by.** placego's PRIOR-ART-ARCHIVE entries on Rote, half-circle codes and Bugeaud–Kim, then GC2193's pointer
  to Nguyen §7, whose statements were read verbatim this session (Definitions 2.1 to 2.7, §7, §9). Searching
  *badly approximable*, *partial quotient* or *initial critical exponent* in our documents found nothing.
- **Credit.** The large-digit case of 0ef6e2 is known in exponent form (`Dio = ∞`, so `rep = 1`). The bounded-type
  value of `Dio`, and so the conjecture, is not settled by these sources; this is not an exhaustive literature
  search.
- **Since (N8).** I127 proves the conjecture by hand (`Dio ≥ 1 + Λ` for almost every cut tuple at a fixed angle),
  carried in N8; P50 records the comparison with Boshernitzan–Damanik.
- **Since (N9).** For half-circle codings at the golden and silver angles, every phase (not almost every) is
  settled in Jen's terms: golden always excluded, silver excluded exactly off the cut orbit
  (PROOF-SKETCH with an interval certificate, [configuration-torus.md](research/kit-repair/R30-20261029-0ef6e2/configuration-torus.md)).
  Searched in addition: Adamczewski, *On powers of words occurring in binary codings of rotations*, Adv. Appl.
  Math. 34 (2005), §§1–3. Its initial-power results concern characteristic codings over many angles, not every
  phase at one angle.

- **R90, 23 November.** The golden all-phase statement now has an end-to-end kernel proof, using six lags at each scale and one 27-slab cover. Rote’s factor complexity is $2n$. Dvořáková, Medková and Pelantová compute the critical exponent over all factors, which leaves their starting positions unrestricted. The Jen application needs the start-dependent excess. [Exact proof and comparison](research/kit-repair/R30-20261029-0ef6e2/golden-strip-cover.md) · [Rote critical-exponent paper](https://dmtcs.episciences.org/articles/6519)

- **M125/R92.** The earlier explicit finite-horizon theorem gives positive-lag repeats with arbitrarily large excess for mechanical words and their block recodings. It applies to the successive mod-two differences of the golden half-circle coding, which are a complemented mechanical word. Equal blocks of differences may lift to complemented blocks of bits. The six golden lag families enforce even displacement parity on each crossing-free interval. The initial search found the Sturmian entry but missed this quantitative predecessor under the term *mechanical words*. [Earlier portal entry dc3d17](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-dc3d17) · [Independent comparison](research/kit-repair/R30-20261029-0ef6e2/claudeM5-s11-read.md#4-novelty-repeated)

## P50 · 2026-11-22 · Pinned repetitions of rotation codings and the Hurwitz constant

- **Ours.** I127 gives two hand arguments for N7, pending a carrying read. At a prescribed irrational angle,
  a prefix has period $q_n$ and length at least $(1+\lambda)q_n-1$ infinitely often for almost every finite
  cut tuple and each $1<\lambda<\Lambda$, where $\Lambda=\limsup 1/(q_n|q_n\alpha-p_n|)$. With a prescribed
  set of $m$ cuts and almost every phase, the same argument applies for $1<\lambda<\Lambda/m$.
- **Known.** Hurwitz gives the sharp universal constant $\sqrt5$ in rational approximation. I127 rederives
  the limsup bound from consecutive convergents. Boshernitzan and Damanik, Proposition 2, prove almost-sure
  constancy of the initial critical exponent in an ergodic symbolic flow. Their Theorem 5 and Corollary 1
  give unbounded pinned repetitions for interval exchanges with property V and for almost every length
  vector with a fixed irreducible permutation. P49 records Nguyen and Bugeaud–Kim's complementary statements.
  [Hurwitz (1891)](https://link.springer.com/article/10.1007/BF01206656) ·
  [Boshernitzan–Damanik, §§1 and 3](https://arxiv.org/pdf/0808.2200)
- **Found by.** Searching the kit, portal, prior-art files and ledgers for *Hurwitz*, *Gordon* and
  *pinned repetitions*, then reading the paper under its term *pinned*. Searches for *Jen*, *near squares*
  and *Diophantine exponent* missed that title.
- **Credit.** Hurwitz supplies the constant that makes the bound strict for two prescribed cuts. The
  ergodic zero-one principle for pinned exponents is known. I127 uses a separate translation of each
  variable cut to get a positive-measure set of simultaneous repetitions up to full measure at a
  prescribed bounded-type angle. This comparison concerns the parameter assumptions in the cited results.

## P51 · 2026-11-23 · Low factor complexity beside a clock: pull N3 was already in the kit

- **Ours.** K72 proved, in the frame of `Rule30ClockNearSquares`, that the visible word beside a clock has more than
  $n + C$ blocks of length $n$ for all large $n$, for every $C$
  ([Rule30ClockComplexity.lean](research/kit-repair/R30-20261023-8084e6/Rule30ClockComplexity.lean)). It was meant
  as the complexity form of 8084e6, pull N3.
- **Known, in the kit, by us.** `Rule30ZeroWallDiagonals` (10 November) says the same of the free word of a
  finitely supported constrained row: `freeWord_complexity`, `Theta_complexity` and
  `not_finSupp_theta_and_row_of_bounded_factorCount_excess`. Under an alternating centre, the left half of a
  configuration with a leftmost black cell is such a row (`Rule30PeriodTwoSideways.left_inX`, used in
  `Q01_no_leftfinite_alternating`). Its free word is column −1 at the ticks when the centre is white, which is
  the complement of the visible word. So the statement was in the catalogue twelve days before N3 asked for it.
- **Known, outside.** Aperiodic words with $n + 1$ blocks of each length are the Sturmian words (Morse and Hedlund,
  1940). Words with $n + C$ blocks for all large $n$ are called quasi-Sturmian (Cassaigne, 1997; cited from memory,
  not re-read).
- **Found by.** Reading `Rule30ZeroWallDiagonals` for the theorem K72 needed, and then asking what `freeWord` is
  under the clock. A search of KIT.md and KIT-INDEX.md for *complexity* and *Sturmian* does find the row. But the
  row speaks of the free word of a constrained row and of Q01, not of the clock or the right neighbour, and N3, N6
  and K72's first search all missed the link.
- **Credit.** The statement is the kit's. K72's module is a second proof, through `corollary_F`, in the clock's
  frame and for a clock that starts at any time.

## P52 · 2026-11-23 · The upstream particle and the three mature departure positions of the 17/56 wheel

- **Ours.** I167–I169 used the old phase to predict the first departure from the 17/56 wheel. A local relay fixes the gate six ticks ahead. After 140 matched ticks, 18 independently certified tests use the current row to decide whether the first departure occurs at a specified position four to fourteen ticks ahead. [Forecasts and checks](research/wheel/kick-predictor.md).
- **Known.** The October domain filter found its most common departure shape at site 5 eight ticks before it reached site 1. The shape alone had several different signed outcomes. The later physical cone certificates allow only positions 32, 42 and 52 after 140 matched ticks. They give necessary signatures four ticks before departure and ten ticks before class 52, including departures with no immediate relock. [Particle study, §8.7](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/rule30-prize/RULE30-PRIZE-8.1.md#87-a-slip-is-one-particle-2026-10-05) · [Physical cone certificates, §8.107](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/rule30-prize/RULE30-PRIZE-8.3.md#8107-s8-certified-the-kicks-local-alphabet-four-and-ten-rows-back-2026-10-14-1803-bst-cloud).
- **Found by.** Searching the October archive for *particle*, *departure*, *kick cone* and *strain*, and reading the original display’s lock convention. Searching only for *kick* also finds the kit’s black gate pulses, a different observable. [Vitruvian display](https://www.wolframcollatzmahler.com/rule30/vitruvian.html).
- **Credit.** The three positions, necessary precursors and empirical particle belong to the October work. I169 proves the converse for the earlier markers with the required completed history, gives phase-specific two-way rules for the same site 5 eight ticks back, and tests exact signed-landing forecasts from wider measured rows.

## P53 · 2026-11-23 · Entry into the 001 trap at chance rate, and four pairwise-apart traps for 001

- **Ours.** K38 (pull R5): every period-three ether cut to N = 240 ends in the kit's trap t001, after a wait that
  behaves like a memoryless search with mean 20,878 ticks. COMPUTED and MEASURED.
- **Known.** L. Hallee, [`lhallee/rule30-open`](https://github.com/lhallee/rule30-open) at `a3b4a64`.
  - `findings/columns/t001-census.md`: every right half of at most ten cells enters t001 from every phase, at means
    22,570, 22,533 and 23,028 ticks, with an exponential body. A fair coin in place of the cells beyond enters at a
    similar rate, and the first 34 columns of the trap take some 20,000 ticks to form.
  - `Rule30Open/Columns/Traps001.md`: four traps for 001, pairwise apart, of 47, 52, 144 and 304 cells. Entry into any
    three of them fails for some finite right half, and entry into some trap of 001 (`WTrap.AbsorptionAny`) still
    excludes 001.
  - `findings/columns/lock-chains.md`: each trap is a locked window carried leftward, column by column.
  - `Rule30Open/Columns/ReachRefuted.md` and `negative-results/columns/missed-traps.md`: the windows that can reach a
    trap, found backward. The 52-cell trap fails the test of reach at 20 cells, so some windows never reach it.
  - For period four, `Rule30Open/Columns/EtherPrefix.md` proves that every truncation of the ether enters the kit's
    family, by a shift lemma.
  - For 011 no trap was found (`negative-results/columns/period-three-011.md`).
- **Found by.** Reading the credit line of `Rule30EtherThreeNotAbsorption` and then Hallee's notes at their source.
  K35's search used *cut*, *erosion*, *period-21* and *trap001fifteen* in our own documents and the kit, which name
  the repository but do not hold its census.
- **Credit.** The chance wait, the four traps and the carried-lock construction are Hallee's. K38's departure law (30
  ticks for each 12 columns) and its following of the cut family are not in those notes as far as read.

## P54 · 2026-11-23 · Recognizing all entries into the period-two gate trap on its sampled neighbour

- **Known.** The kit proves the forward gap law, black coverage in five, and eventual exclusion of two successive 3-gaps after entry. The October 17/56 wheel and rotating 84-ring supply different reference histories. R65/R69 and K78 describe two exterior components left by finite-width pruning. [Kit gate words at f41bb49](https://github.com/WolframInstitute/Rule30PrizeKit/blob/f41bb494d64f120e0e6f07ab68d799a6018396cc/lean/Ruliology/CellularAutomata/Rule30GateTrapWords.lean) · [K78 comparison](research/wheel/claudeCloud-tails.md).
- **Ours.** Absence of five visible factors over 48 white samples forces the hidden trap at the endpoint for any right half. The same 47 readings occur in two finite histories on opposite sides. Six white intervals suffice to clear the forbidden factors after entry, sharply. This identifies the remaining finite-right RD branch using a single measured bit. [Observer, proof records and scope](research/wheel/complete-observer.md).
- **Credit.** The trap, its closure and its necessary eventual language are the kit's. The temporal converse, universal lower bound for a window-only readout, and settling time are the present work. The October signed phase departures are a different observable (P52).

## P55 · 2026-11-23 · The strict doubling lemma at small clocks, and the immediate catch

- **Ours.** Every doubled stretch of dyadic source period through 32 catches every tick, last at wheels 12, 33, 43, 69 and 152 for periods 2, 4, 8, 16 and 32 (K5 and M41, COMPUTED; public in S5 §5). The rows caught at wheel 3 are exactly those where the first wheel has just turned from black to white (K16 §3, item 4).
- **Known.** Quint and Gemini, kit `Rule30DoublingLanes.catch_of_firstLoss_le_four` (#407, R30-20261123-16f287) proves the closure in Lean for source periods 1 to 16, with the same horizons. `Rule30RelaxedWindows.firstLoss_cascade_and_immediate_catch` (#404, R30-20261123-98c017) proves the immediate catch. Their period L is twice the source period. Source period 32 is not in their closure.
- **Found by.** Reading both entries against the parked wall (N11). Our first mention of 98c017 was M127.
- **Credit.** The Lean proofs are theirs. The computations, the weaker lemma (DL⁻₁) and the failure at source period 5 are ours and earlier.

## P56 · 2026-11-23 · Which return occurs at a black pulse beside an alternating centre

- **Known.** The kit gives the four allowed white-sample gaps in the general late gate and Bosdure et al. give the 3/5 alternative after trap entry. Lowry’s PR #39 gives that alternative for the empty orbit. Quint studies the even-time right germ and return after particular past gap words. Lowry’s seven-cell return concerns a white gate. [Sources and literature comparison](research/wheel/pulse-forecast.md#prior-work-and-the-chain-test).
- **Ours.** From the second white sample, the two current bits at sites 2 and 5 choose the exact next black return, for every right half. In the trap the three current bits at sites 7–9 also determine the duration of the second gap. The measured nine-site gate forecast extends the older numerical forecast on one first-entry window. [Proofs and held-out comparison](research/wheel/pulse-forecast.md).
- **Found by.** I178 identified a temporal exterior marker in R69 and K78. The local physical cone and its image after one white-to-white update yielded the exact selector during transits as well.
- **Credit.** The gate, trap, gap alphabets, October phase display and earlier general prediction work retain their prior credit. S13 proposes the all-right-half, two-site first-return theorem and finite-period-two consequence. [Proposal](research/wheel/pulse-candidate/README.md).

## P57 · 2026-11-23 · Prior constraints on the second-white readings of 001

- **Ours.** R5 §4 proposes excluding short gate words in Lean, including 1001. S14 proposes that the gate of every finitely supported right half eventually repeats 1100000 or 11000 (M138, R98).
- **Known.** Hallee's `Rule30Open.three_runs` already excludes 010, 101 and 1001 from reading index 14, for every 001-driven right half and every phase. The kit also has `Rule30PeriodThreeLanguage.col1_001` for the eventual centre orbit. Hallee's `traps001_pair_not_absorption` expressly refutes universal entry into the two traps used by S14. [ThreeRuns](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/Rule30Open/Columns/ThreeRuns.md) · [Traps001](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/Rule30Open/Columns/Traps001.md)
- **Found by.** The S14 carrying read followed Hallee's constrained-left result to `ThreeRuns` at `a3b4a64`. Our archived inventory also indexed it by that module name. Searches using only “gate entry” miss the term “second white step”.
- **Credit.** The short-word exclusion is known. S14 calculates the two gate words for individual halves that enter the named traps and proposes their eventual exhaustion for finite halves. Even the periodic stream (110000) repeated obeys the older word restrictions.

## P58 · 2026-11-23 · A periodic gate in place of absorption into a trap, at 001

- **Ours.** S14's `GatePeriodic`: if the gate of every finite right half beside 001 is eventually periodic, 001 is excluded (M138, M140).
- **Known.** Renaud Bosdure's `Rule30Ether.Lock` (kit #65, R30-20261027-c137e0) is the same statement for the three words of period four, with column 1 read on all the white ticks or some other column periodic, and `lock_excludes`. Hallee remarks that entry into any trap of a word gives its lock and that the lock for 001 stands ([note](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/literature/kit-pull-requests.md)); `absorption_any_excludes` is the exclusion from entry into some trap.
- **Found by.** Reading `Traps001` for R98's repairs. M138's searches (*gate entry*, *AbsorptionT*, *front speed*) do not meet the word *Lock*, and its novelty note did not name #65.
- **Credit.** The form is Bosdure's and the remark for 001 is Hallee's. Ours: the Lean at 001 with the gate read on one white phase (the skeleton settles the other), the gate words of the two traps stated for each half, and the conjecture `GateEntry`.

## P59 · 2026-11-23 · Late observations on the singleton, and one column that forces a state

- **Ours.** I175's deadline for an exterior run of 3- and 5-gaps on the singleton (T < 2A + 1532; with M144's count, 2A + 1168). S15's observer: 48 clean readings of one column place the window in the trap (I172, I181, I190).
- **Known, for the deadline.** Lowry, `Rule30GapRepetitions.singleton_observed_repeat_bound` (R30-20261122-094213): equal blocks of n masked readings at offsets i < j of age T need n ≤ T + j; with j = 6 it ends a pure-three run by 2D + 12. Lowry, `Rule30LateObservation`: the pure-five rhythm on the singleton satisfies 35 n < 27 b + 2478, by rewinding synchronizing suffixes, with a general criterion (`late_observation`).
- **Known, for the observer.** The necessary language after entry is Quint and Gemini's (`Rule30GateTrapWords`, R30-20261110-037fe3). Hallee's `Columns.LockWord`: one word in one column forces the period-four lock, for each of its three words. Hallee's `findings/period-two/gate-census.md` has another gap trap (3,562 entry windows) and no certifying word.
- **Found by.** I175's read (M144): searches of the portal list for *observ*, *detect*, *deadline*, and of KIT-INDEX for *alternat*. The wheel reports had neither module of Lowry's by name.
- **Credit.** The last step of the deadline, up to six ticks, is Lowry's; ours are the counts, the exit rules and the ring's sharp table. The converse from gate to trap window, with 48 and 47 sharp, is ours.

## P60 · 2026-11-24 · Five-sample coverage on the observed column already has a phase-zero certificate

- **Known.** Placego's October 11 table of physically absent column-1 words lists both `11` and `00000` for a white-time start with an arbitrary right half. The latter gives the black reading used to extend S15's two exceptional prefixes. Its SAT certificate predates the 829-window observer. [Frozen table and phase convention](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/tests/probes/lexicon/rule30_local_mfw44.txt#L9-L11)
- **Ours.** R100 repeated I190's chain test. The new implication locates the hidden 829-window state at the end of a clean observation, with optimal lengths for uniform acceptance after entry. The older catalogue tests whether a gate word can occur anywhere. [S15 carrying read](research/wheel/observer-candidate/r100-carrying-read.md)

## P61 · 2026-11-24 · The six-cell onset already covers the event bracket on GE2

The kit's width-six list includes the word for gaps 2,2,5 and the word for gaps 3,5,2. Herbert and collaborators shortened the first to `101010000` for any history obeying Rule 30 on six sites. The October placego phase-one catalogue already certified that shortened word for a black initial driver tick. Every bracket 5,2^k,5 with k ≥ 2 contains it. Lowry supplied the event parity that gives R67’s different proof. [Kit onset module](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5cf98745d14ad347bd2ec59e9d8c9666b682d456/lean/Ruliology/CellularAutomata/Rule30PeriodTwoOnset.lean) · [October catalogue](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/tests/probes/lexicon/rule30_local_mfw44.txt) · [Lowry’s event proof](https://github.com/WolframInstitute/Rule30PrizeKit/pull/376)

Searching literal gate words located the prior result. The new comparison is all-length sufficiency of those two tests inside anchored GE2 for the width-six projection, the exact left-seed classes, and the uniform-in-width mass reduction. The existing kit already provides the trace bijection, the strip recognizer and the general mass argument. [Proofs and comparison](research/k50_2/finite-left.md)

## P62 · 2026-11-24 · Source parity on the two phases of an alternating centre

Lowry defined the net of three oriented sources, proved its XOR identity with the distance-two shell, and proved net aperiodicity for periodic singleton centres with two black ticks after each white. His isolated-white result concerns a selected source. The kit’s width-13 theorem gives the nine allowed kick-gap pairs on a late alternating singleton and excludes eventual periodicity of the kicks. S13 gives the exact next return at a pulse. The physical six-cell onset already forbids the gap word 2,2,5 (P61). [Lowry’s source arrivals](https://github.com/WolframInstitute/Rule30PrizeKit/pull/374) · [Width-13 theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5669edeef5e58004a1ad6bf4af3cb75266488baa/lean/Ruliology/CellularAutomata/Rule30PeriodTwoWidth13.lean) · [Pulse returns](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5669edeef5e58004a1ad6bf4af3cb75266488baa/lean/Ruliology/CellularAutomata/Rule30GatePulseReturn.lean)

I67 used both source readings in each pair. I199–I203 recover late kicks from the white observations, identify the same odd-return starts from either phase, and prove that each phase and the odd-return timetable are aperiodic. Searching the kit, portal, both prior-art files and public PRs for source arrivals, phased or sampled net/shell, source counts and odd returns found the component results. The nearest spatial count-recovery results are Condrey’s. [Condrey’s observables](https://github.com/WolframInstitute/Rule30PrizeKit/pull/297) · [Exact hypotheses, controls and proofs](research/arrivals/phase-sampled-arrivals.md)

## P63 · 2026-11-24 · Gate words and entry beside the two words of period three

- **Ours.** R5 §12 (M152): every finite right half beside 001 and 011 enters a closed set of 14-cell windows in linear time, in Lean, with the runs its gate reads.
- **Known.** (1) Hallee, `Columns.ThreeRuns`: 010, 101 and 1001 are avoided by every right half of 001 from reading 14, a rank of at most 46 on 13 cells. (2) Hallee, *reading constraints*, at `a3b4a64`: beside 011 every half of at most 16 cells enters a set on which white readings are never 1, 2, 4 or 5 apart, and entry is "not forced" at widths 14 and 16; beside 001 the runs {2, 4} and {3, 4, 5} are "sampled, not forced". (3) Ours: kit `Rule30PeriodThreeLanguage` (R30-20261108-261a30), the words of the centre's own orbit at widths 10 and 7, and placego's LOCAL-BLOCK9 of 8 November, the same at widths to 22 (the eleven words of 001 at 14; 00, 010, 01110, 011110 and 1^15 of 011 at 17 to 20). (4) `erosion3_fin` (Perez Morales), for a disturbance with the ether beyond.
- **Found by.** Reading Hallee's `findings/columns` before the claim; searching our own records for the words of 011.
- **New in the records checked.** Every finite half enters the specified closed set in time linear in its support bound under either drive. For arbitrary support, permanent avoidance forces a constant sampled gate, either colour beside 001 and white beside 011. The singleton centre inherits the deadlines from a finite matching clock segment. For 011 the upper bound on the next white gap applies from the sixth gate step after entry. Hallee gives bounded-support entry for 011 and uniform avoidance of shorter words for 001. M152's lists had proper closed subsets in the physical graph (I205); S16's are its one closed component, the least closed set, and the slope 5/2 is necessary (I206). [Hallee's reading constraints](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/findings/columns/reading-constraints.md) · [Hallee's 001 proof](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/Rule30Open/Columns/ThreeRuns.md)

## P64 · 2026-11-24 · A closed set of 777 windows beside the alternating column, and the streams of Lowry's net

- **Ours.** M156, in Lean: beside 01 every right half enters a closed set of 777 twelve-cell windows or reads a kick once in four; in the set the gate obeys the nine pairs and avoids 2,2,5 (contained in GE2; GE2 permits 2,2,5, I213); nine white nets give every kick; the odd-kick and black-net streams of I203 as theorems about every right half; on the single cell they are not eventually periodic, if its centre alternates ([report](research/arrivals/light/README.md)).
- **Known.** (1) AIOvernight, `Rule30PeriodTwoWidth13.path_run` and `lang_GE2`: every path of the thirteen-column strip, so the right half of any support, is eventually in GE2 or reads pure fours; the single cell excludes the fours (`not_pure4`). (2) I203 and P62: the three streams and their markers on the single cell; the decoder of nine nets, the black rule, and the six-cell strip search for both. (3) The gaps 2,2,5 are excluded on any right half, once one full white–black period has elapsed, by the kit's width-six list and by our shortening, `101010000` (P61, R109). (4) K50.2's dictionary: an event is at an even distance from the next kick, for any right half under a finite stretch (event-returns.md).
- **Found by.** Reading the kit's module headers for GE2 and the strip after the build; the claim "for every right half" in M155 was already in the header of `Rule30PeriodTwoWidth13` and KIT-INDEX line 44. It had been missed in the read.
- **New in the records checked** (portal list of 24 November, 414; kit `31b28a1`; KIT-INDEX). The explicit closed set and its entry dichotomy in these terms; the decoders and the periodicity equivalence as statements about right halves; a proof of nine seconds in place of a 334 KB certificate. No portal entry has a closed set of twelve-cell windows at period two whose words are the nine pairs.
- **Not checked:** other contributors' unpublished tables at width 12, and whether 777 is the least closed set.

I211 adds the every-half equivalence of eventual periodicity for the gate, white net and odd-return mark, using the next-return parity law on the pure-four branch. The first nine white readings coincide on two finite black starts with distinct seventh-sample kicks. Lowry’s canonical net and shell accept the singleton phase theorem by definitional equality on the current kit. Review on 24 November covered kit main 31b28a1, P62/P64, the 415-entry portal index and 16 open kit PRs. [Statements and physical witness](research/arrivals/light/gptIntel-s17-path.md).
- **The S17 check** (24 November, 15:53 UTC; M160). Portal list, 415 entries: searches of titles and abstracts for *source net/arrival*, *shell*, *alternat… aperiodic*, *net … kick*, *closed set … window*, *decode*, *odd return* give no statement of this form. Pull requests of every state by title: #374 (Lowry's arrivals), #376 (event returns), #409 (S13), #384, #39 and others, none of this form. Kit `31b28a1`: `Rule30PeriodTwoOnset` (ours) has closed sets of twenty windows on five cells and thirty-eight on six for every history, and excludes part of the gate words; `Rule30PeriodTwoWidth13` has the nine pairs. The chain test: the other instances of a closed set of windows at period two are the kit's 829 windows of the gate trap (16 cells; gaps 3 and 5) and these of `Rule30PeriodTwoOnset`. The phase-by-phase statement on the net has no earlier term: Lowry's `net_aperiodic` has two blacks after each white, and `selected_aperiodic` is another stream.

## P65 · 2026-11-24 · The sharp entry time for S17’s 777 windows

- **Ours.** ClaudeM5 first computed the deadline in M165. I216 proves in Lean that every right half driven by an alternating boundary is in S17’s set at white sample 35, and that a finite initial half first enters at precisely 35. Seventy physical updates from an arbitrary white start suffice. Every right half therefore excludes an eventual pure-four kick stream. [Proof and witnesses](research/arrivals/uniform/README.md)
- **Known.** AIOvernight’s width-13 `path_run` gives the eventual language alternative on projected paths and uses `not_pure4` on the singleton. S17 gives the 777-window set, closure, gate language and decoders. Its every-half result allows an eventual pure-four branch. P61 and P64 also cover the five- and six-cell onset sets. S15’s 829-window trap has a different target and its deadline tests observations. S16’s entry theorem for two period-three drives depends on the support bound. [AIOvernight](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261109-62afca) · [S17](https://github.com/WolframInstitute/Rule30PrizeKit/pull/418)
- **Found by.** Kit main `88fdac9`, S17 PR head `43e938c`, the portal list of 419 entries and 18 open kit PRs at 18:14 UTC. Searched the local records and public sources for alternating right halves, uniform entry, closed sets, width 13, pure fours and the 777 windows. No earlier deadline for this target appeared in the records checked.
- **Credit and chain test.** The strip language and S17’s target retain their earlier credit. I216 settles the optimal time for this fixed target with a matching physical lower bound. The narrower onset sets, the 829-window observation test and the period-three support bounds do not form a sequence of deadlines for that target. Whether other closed sets have comparable deadlines is open.

## P66 · 2026-11-24 · Words of one arc from its end: repeats not far from the beginning

- **Ours.** N13 proves in Lean, for every irrational angle and every arc, that the coding of a rotation by one arc started on
  the orbit of an end has near-squares: blocks that repeat from i to j, at unbounded lags, for j − K letters. For half-circles
  K = 2. With `corollary_F` the word and its block codes are excluded beside an alternating column.
  [Proof, checks and comparison](research/kit-repair/R30-20261029-0ef6e2/endpoint/README.md)
- **Known.** Adamczewski, *On powers of words occurring in binary codings of rotations*, Adv. Appl. Math. 34 (2005) 1–29,
  read at §§2, 3 and 7 (from Lemma 32 on), in the author's copy. These are his characteristic codings. Theorem 8: uncountably many have initial
  critical exponent 1. Proposition 9: almost all begin with arbitrarily long squares. Lemma 37: every one has segment expansion
  factor at least 3/2, so end/(i + j) ≥ 3/2 in the limit. That gives the corollary F bound 2j − K only where j stays below 3i.
  P47 and P49 have the half-circle history (G143, G144, L099, L100, GC2187), Nguyen's exponents and Rote's complexity 2n.
  The step ⌊(t+d)α⌋ = ⌊tα⌋ + u for 1 ≤ t < D between Farey neighbours is classical. Interval tests for ⌊nα⌋ are in Graham, Lin
  and Lin, *Spectra of numbers*, Math. Mag. 51 (1978), cited from memory.
- **Found by.** Two web searches (initial critical exponent of Rote words; parity of Beatty sequences), then the paper's PDF.
  The portal's 419 entries and the open kit pull requests for *rotation, Sturmian, half-circle, Beatty, irrational, floor, coding,
  near-square*. Our documents under *Farey* and *Beatty*: no hit.
- **Credit.** The class and the fact that its words repeat near the beginning are Adamczewski's. The bounded slack, the Farey
  proof with the conserved shortfall, the integer form of "irrational" and the Rule 30 statement are, as far as we searched, new.
- **Since (N14).** The Rule 30 statement for the words themselves is *not* new, from any start. `Rule30PeriodTwo.golden` (no two
  black readings in a row) excludes every arc longer than the distance of the angle from a whole turn, half-circles among them;
  the nine pairs of gaps (AIOvernight, 62afca, for the single cell; S18 for every right half) leave only arcs with both ends on one
  orbit, whose words are block codes of Sturmian words (8084e6). The search in N13 missed it: it looked for rotations and words
  and not for what column 1 can read. Terms that find it: *golden, hard-core, nine pairs, kick gap*.

## P67 · 2026-11-24 · Mechanical phases and partitions on two rotation orbits

- **Ours.** I222 identifies N13’s integer phase predicate exactly with a lower or upper mechanical line. At most one sample can differ from the ordinary floor convention. It also writes the real-angle exclusion directly for any finite Boolean readout and any signed displacement from either endpoint.
- **Known.** Upper and lower mechanical words are classical. Alessandri and Berthé, §4.1, give a finite connectedness index for rotation coding cylinders. Their Lemma 3 and Theorem 10 give the eventual complexity and its relation to the cut orbits. In particular, two independent cut orbits give 2n words for sufficiently large n. [Morse and Hedlund](https://doi.org/10.2307/2371431) · [Alessandri and Berthé](https://www.theoremoftheday.org/Docs/3dAlessandriBerthe.pdf)
- **Found by.** Checking the scope of `PhaseLine` and the finite-partition remark in N13 against the circle coding and the literature on connectedness of rotation cylinders.
- **Credit.** The circle dynamics and rounding distinction retain their existing credit. The Lean bridges and the application of the connectedness result to N13 are supporting statements for S19. [Derivation and example](research/kit-repair/R30-20261029-0ef6e2/endpoint/gptIntel-endpoint-continuation.md)

## P68 · 2026-11-24 · Two blocks in the order of a rotation, and the orders of the gaps 3 and 5

- **Ours.** N15 proves in Lean that two nonempty finite blocks set in the order of the word of one arc, started at an end, at any
  irrational angle, have near-squares of bounded slack, lengths counted, and are not read beside an alternating column in a
  row with a leftmost black cell. [Write-up](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/README.md)
- **Known.** Lowry, `Rule30GapRepetitions` (R30-20261122-094213): for kick gaps 3 and 5 with no two 3s in a row, n equal gaps from
  places i < j need 8n < 10j + const, so lim inf r(n)/n ≥ 9/5, and by Bugeaud and Kim Sturmian and quasi-Sturmian orders are excluded.
  `psi_not_finite_of_sample_repeats`: repeats of the readings that outlast their second start by unbounded amounts. The silver
  example of N15 meets neither bound (8n − 10j ≤ 28 to lag 3,000; n ≤ j + 32 in readings to lag 9,000). P66 for the words.
- **Found by.** KIT-INDEX under *kick gap, gap order*; the module itself read. No general theorem on substitutions of rotation
  words beside a clock in the kit, the portal list of 24 November 18:28 UTC or our documents (*substitution, morphic, concaten*).
- **Credit.** The gap clock and the idea of excluding an order of gaps are Lowry's. `corollary_F` is ours (91b0b0).

## P69 · 2026-11-24 · Reading an old wall from one present half

- **Ours.** I227–I229, K83.A. The earliest right prefix fixing the previous wall has mean length eight in the fair law. A prescribed T-tick wall history occupies exactly 2⁻ᵀ of the present right halves. [Finite decoder and primary sources](research/rule4/predecessor-wall-radius.md) · [Finite-history statement and proof](research/rule4/right-coin-past.md)
- **Known.** P6, P11, P13 and P14 record earlier reset and predecessor results. Wolfram §4 and §9 (1986) give the sweep from two eastern bits and credit Carl and Richard Feynman for the 3m+1 run marker on a ring. Jen §4(a) gives the four-pair counting recurrence. Spencer Proposition 3.1 gives the two first determining words, 010 and 110. The kit’s `Preimages.eq_of_evol_one_eq_on_of_window` recovers a previous site from a 010 to its east; `Mixing.ae_isNormal_rows` supplies these markers at every time in a stationary fair spacetime.
- **Found by.** Searched the kit’s Preimages, Mixing and Invertibility modules, existing one-layer reset entries, Wolfram’s inversion notes and references, then compared the exact boundary and cyclic conventions.
- **Credit.** The inverse sweep, marker and cubic decay are prior art. Here a virtual initial zero gives the exact stopping rule at the one-sided boundary, with its mean and generating function. The finite-history range formula combines the kit’s fair trace/right factorization with eastern reconstruction. Priority for the two one-sided measure formulas has not been established.

## P70 · 2026-11-24 · The unique left half for a given wall and right half

- **Ours.** I229 counts how much fair-right measure falls on each required finite west prefix, and sums exactly those with zeros beyond a fixed depth. [Forward counts and finite-support criterion](research/rule4/k83a-gate-mass.md)
- **Known.** The kit’s `Rule30Realization.ycol`, `conf` and `unique` reconstruct a full row from a prescribed centre and right half. In the alternating case `Rule30PeriodTwoSideways.Psi_unique`, `exact_death_center` and `truncation_death` give the unique compatible west and the first time at which a wrong west fails. The same module excludes finite support of Psi whenever the driven right gate is eventually periodic.
- **Found by.** Comparing the finite triangle to the kit’s sideways reconstruction and looking up *Psi*, *truncation death* and *left-permutivity*.
- **Credit.** The west decoder and first-mismatch mechanism are the kit’s. Here the two phase-specific gate histograms attach exact cylinder masses, produce sharp finite time survival bounds and keep the finite support cutoff in the measure limit.

## P71 · 2026-11-24 · Pair-word growth and the two entropy bounds for the full rule

- **Ours.** I234 counts 718,268,824 physical pair words at length 23. A width-13 spatial cover bounds the full topological entropy strictly below 1.146669 bits per tick. Exact fair multiplicities to length 21 bound the measure entropy above by 1.124883281645. [Proofs and checks](research/rule4/k83b/README.md)
- **Known.** The kit proves its lower bound by the single-column factor and its upper log 3 by covering finite windows with right-edge pair words. Grassberger’s 1986 Table 6 gives the Rule 30 measure entropy below 1.15436 using spacetime patches. Wolfram p.960 later gives below 1.155 for the same measure quantity. [Kit Mixing](https://github.com/WolframInstitute/Rule30PrizeKit/blob/4bb3a7b/equivalents/Rule30Equivalents/Mixing.lean) · [Grassberger’s table in Wolfram, *Tables of Cellular Automaton Properties*](https://content.wolfram.com/sw-publications/2020/07/cellular-automaton-properties.pdf) · [Wolfram, printed p.960](https://files.wolframcdn.com/pub/www.wolframscience.com/nks/nks-nts-ch6.pdf#page=15)
- **Also known (found in review, M178).** The identity itself, the entropy as the growth rate of the words of two adjacent columns, is ours from 9 October 2026, by hand: placego, [RULE30-PRIZE §8.77](https://github.com/ghywel/placego/blob/main/archived/reports/rule30-prize/RULE30-PRIZE-8.2.md), with N₂(14) = 476,596 and N₂(17) = 5,615,036 and the bounds 1.347, then 1.3189 bits a tick. It follows Guillon’s thesis (Paris-Est 2008, Proposition 4.8.5) at width 2. GC814, in PRIOR-ART-ARCHIVE.md, checked the sandwich N₂(n) ≤ N_w(n) ≤ N₂(n + w − 2). Kopra 2023 and Milnor 1988 (Example 6.2) are beside it. What I234 adds is the Lean proof on the kit’s entropy, the weighted covers and the sharper bounds, the metric bound, and the counts past 17.
- **Found by.** Read the two entropy definitions in the printed sources, the kit’s pair-language proof and catalogue counts, and compared directional and single-column measurements to the full map.
- **Credit.** Window recovery and observation by patches are earlier work. Our contribution here is formalizing the exact pair-growth identity on the kit’s entropy, supplying integer-checkable physical strip bounds, and carrying the finite fair calculation through length 21. Literature priority for the sharp constants remains unchecked beyond the sources above.

## P72 · 2026-11-24 · The western record of a finite perturbation

- **Ours.** I234 proves a hearing-or-escape dichotomy on a fair row, and bounds the asymptotic speed of the historical westernmost difference by 1,142,503/4,194,304. Each possible front transition is paid for by a checked integer potential. [Proof and finite-state certificates](research/rule4/k83b/lower.md)
- **Known.** Grassberger’s Table 6 reports a leftward speed of 0.2428 ± 0.0002 and a rightward speed of one for Rule 30. The kit proves exact rightward motion of a single-flip front. Tisseur bounds metric entropy using exponents for one-sided perturbations. Baetens and Gravner study defect growth using a branching process. [Grassberger](https://content.wolfram.com/sw-publications/2020/07/cellular-automaton-properties.pdf) · [Kit Mixing](https://github.com/WolframInstitute/Rule30PrizeKit/blob/4bb3a7b/equivalents/Rule30Equivalents/Mixing.lean) · [Tisseur](https://arxiv.org/abs/math/0312136) · [Baetens and Gravner](https://arxiv.org/abs/1509.06639)
- **Found by.** Compared the definitions of perturbation, the initial law and the time limit with the project’s earlier measured fronts and the kit’s feedback-erasure examples.
- **Credit.** The connection between entropy and information propagation, and the observed asymmetric speeds, predate the project. The present upper bound follows a pair of actual evolutions, revealing fresh fair inputs at a moving historical record. Its positive-speed converse stays open.

## P73 · 2026-11-25 · Earlier sources behind K83.B: the permutive pair identity, Wolfram's 1986 bounds and left speed

- **Ours.** K83.B (I234, read in M178, I238): the full topological entropy of Rule 30 is the growth rate of the words of two adjacent columns (Lean, on the kit's entropy); certified bounds below 1.146669 and 1.143992 bits a tick; the fair metric entropy at most 1.124883281645; the west record of a finite flip at most 0.272394 cells a tick. [Results](research/rule4/k83b/README.md)
- **Known.**
  - *The identity, for every permutive automaton.* di Lena and Margara, "Row subshifts and topological entropy of cellular automata", J. Cellular Automata 2(2) (2007) 131–140, Corollary 4.6: "If (A^Z,F) is permutive then H(F) = H(Σ_{2r+1})", Σ_k the column subshift of width k: width 3 for Rule 30, the same rate as width 2. It has no Rule 30 and no numbers. [PDF](https://www.cs.unibo.it/~margara/page14/assets/01-JCA07.pdf) Guillon's thesis (2008, Proposition 4.8.5), which P71 cites, says it recovers this result. Its statement uses a trace of width r; read literally at radius 1 as one column, it cannot hold for Rule 30. The row …1,0,1,[0],1,0,0… has an all-white centre column, as the white row does, yet the two differ to the west. Whether Rule 30 meets that proposition's hypothesis was not checked. *Read on the owner's copy (K85 addendum 2).* Proposition 4.8.5, p. 101: "Un AC F positivement expansif à gauche (resp. à droite) de rayon r ∈ ℕ a une entropie H(F) = H(τ_F^r)", with τ_F^r the trace of width r (Définition 3.5.2). Elementary automata have radius 1 there (Exemple 3.1.3), so for Rule 30 it would give one column and the entropy log 2. Rule 30 does meet the hypothesis: Fait 4.6.6, strongly left-permutive. But the conjugacy the proposition rests on, Remarque 4.6.9's τ_F^k ≅ τ_F^r, fails at r = 1: the two-column trace has three constant points and the one-column trace two. Proposition 4.6.2's width m fails likewise. So the thesis does not settle h = log 2, which is open. Its sentence "On retrouve donc le résultat de [83]" restates di Lena and Margara at width r, where [83] proves width 2r + 1.
  - *Bounds and speeds, 1986.* Wolfram, "Random sequence generation by cellular automata", Adv. Appl. Math. 7 (1986) 123–169. [PDF](https://content.wolfram.com/sw-publications/2020/07/random-sequence-generation-cellular-automata.pdf)
    - Eq. (4.6): h_μ ≤ h ≤ 2.
    - Eq. (4.7): h_μ ≲ 1.20 by Sinai's method. Its footnote says Grassberger's results suggest h_μ ≈ 1 + T^−(0.6±0.1), "yielding a final value of 1".
    - §5 proves the right speed λ_R = 1 (eq. 5.1) and measures λ_L = 0.2428 ± 0.0003 (eq. 5.2). Its heuristic uses the same advance step as I234's ("When a₋₁ = 0, the front advances (left) by one site"), giving 1/4. Its refined values 0.25, 0.1875, … fall below 0.2428, so they are not bounds.
    - Eq. (5.3): h_μ ≤ λ_L + λ_R, about 1.2428 with the measured λ_L.
  - *Other bounds.* D'Amico, Manzini and Margara, TCS 290 (2003) 1629–1646, eq. (7): H(F) ≤ H(σ)(λ⁺ + λ⁻) with worst-case exponents. It has no one-sided identity and no Rule 30. Kůrka's survey, Proposition 54(2): h ≤ 2r ln|A|, 2 bits here. Tisseur (2000) has no Rule 30 example.
  - *Added in K85, read on the page images.* Wolfram 1986 already has the two-column mechanism for Rule 30 itself. §3, p. 131: the patterns can be found "by extending spatially according to (3.3), starting with the temporal sequence of values of two adjacent sites". p. 135: "a knowledge of the time sequences of values of about 1.2 sites suffice in principle to determine the values of all other sites". §7, p. 146: two adjacent temporal sequences give the initial configuration to their left, and "only about 1.2 such temporal sequences should on average be required". Eq. (4.7) is h_μ ≲ 1.20, an approximate upper bound, and its footnote points to a final value of 1. Grassberger's notes to Table 6 add: "for many rules, the exact value of h_μ is in fact obtained from patches of width 1 or 2".
  - **A correction.** arXiv:1406.5553, "Stability of cellular automata trajectories revisited", is by Baetens and Gravner, not by Bagnoli and others as PRIOR-ART-ARCHIVE.md has it. The archive is frozen, so this entry is the record.
- **Found by.** A subagent of this session (K84) read in full: Wolfram 1986, di Lena–Margara, Guillon's §4.6–4.8, Kůrka, Milnor 1988, Tisseur 2000, both Baetens–Gravner papers, and the 1986 Tables. I have not re-read them. Searches found no bound of ours: Rule 30 with topological, measure, Kolmogorov–Sinai or spacetime entropy; log 3; an upper bound; adjacent-column entropy; a rigorous left-front bound. Seen as abstracts only: Shereshevsky 1992, Sinai 1985 and Grassberger's 1986 IJTP paper. P71 missed di Lena–Margara because it searched under Guillon's name and our own October work.
- **Credit.** The pair identity is known (di Lena and Margara 2007, every permutive automaton) and is reproved in Lean on the kit's entropy (I234). Our numbers appear new:
  - the topological bounds below log₂ 3, where the published bound is 2 bits;
  - the metric bound 1.124883, against ≲ 1.20 (1986), < 1.15436 (Table 6) and < 1.155 (NKS);
  - a rigorous left-speed bound, where the published values are measurements.

  Cite Wolfram 1986 beside Grassberger for the left speed and the metric bound.

## P74 · 2026-11-25 · Which orders of two blocks can the driven gate actually read?

- **Ours.** I239 supplies physical cone witnesses for all seven-block orders, a common initial-prefix tree of depth three, two sharp finite strip controller cutoffs and an all-orders path certificate at 35 cells. [Definitions, proofs and replays](research/wheel/block-orders/README.md)
- **Known.** The kit’s ether realizes the periodic white-time gate 1010…, hence all concatenations of any two powers of 10. The specific noncommuting blocks are K81’s two pure rhythms. K81 already forces a nearby physical cell to change on each pure turn, sharply at site 66 or 83. M181 introduced the all-order question and tested six individual orders at width 44. [Kit ether](Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30PeriodTwoCoupled.lean) · [K81](research/wheel/gptIntel-k81-compactness.md)
- **Found by.** Compared the explicit kit witness to N17’s quantifiers and the finite M177–M181 strip checks to K81’s physical and time-periodic conventions. Applied the K83.A range identity to returning cylinders. [Range formula](research/rule4/right-coin-past.md)
- **Credit.** The ether, the wheel, the alternating-wall setup and the two component rhythms are earlier work. Compactness, shift-invariance and the forbidden-word measure argument are standard. The physical witness census, finite controller distinctions and their replayable certificates concern the specified 18/28 pair. Its physical infinite-order universality remains open.

## P75 · 2026-11-25 · The optimal finite-half entry slope beside 001 and 011

- **Ours.** I242 proves optimal slope three in core Lean. It gives arbitrarily long exceptional eight-cell advances in physical finite rows by one repeatable inverse rule. The same construction followed by the recurrent retreat witnesses a last trap miss within a bounded additive distance of 3D. [Proof and exact claims](research/r5/sharp-slope/README.md)
- **Known.** Perez Morales's `Rule30EtherThreeErosion` isolates class 10 with the next site defective and gives the upper bound for its lifetime and retreat in a finite perturbation. S14 gives the exact recurrent retreat. S16 (`Rule30PeriodThreeEntry`) proves the finite-white-tail entry upper bounds with slope three and the previous lower bound of 5/2. Hallee has bounded-support entry calculations for 011. [Perez Morales](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-1fc962) · [S14](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-f214f2) · [S16](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261124-629dac)
- **Found by.** Compared the exceptional case in the local front certificate to the finite-white-tail argument in S16, then searched prior-art records for sharp erosion, optimal entry slope and repeated exceptional fronts. The generic inverse sweep is standard left permutivity. The new step is the phase-specific eleven-bit check showing that the reverse extension recreates the exceptional front for every eastern pair.
- **Credit.** The background ether, exceptional classification, recurrent path, and trap membership theorems are prior work. The uniform finite-support construction closes the 5/2 to 3 slope interval for the particular entry deadlines of S16.
- **Extension (N18, read in I247).** Perez Morales gives the finite erosion bound 3w + 6 and explicitly leaves open whether an infinite right side can sustain an endless exceptional run. The inverse before an arbitrary evolving tail gives finite witnesses through 3w − 10. Compactness then gives one right half with its first defect at d + 8t for every t, answering the infinite-side question. The same compactness argument was used in S13 and K81. N18 searched the 425 abstracts, the kit’s period-three modules, both prior-art files and the ledgers. [Perez Morales’s question](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-1fc962) · [N18](research/r5/sharp-slope/claudeIntel-review.md) · [I247](research/r5/sharp-slope/I247-carrying-read.md)

## P76 · 2026-11-25 · Constant and periodic gates beside 011

- **Ours.** I244 proves that either constant gate beside 011 contradicts finite right support, and converts the prior 17-gap rule to a uniform eventual bound over all finite halves. No checked finite-width labelled trap forces a constant gate. The sink and targeted lift computations test nonconstant gates at finite widths. [Proof and checks](research/r5/periodic-gate-011.md)
- **Known.** Hallee sampled finite rows and found no settled periodic gate beside 011. The earlier wall census searched labels up to 30 at its listed widths. S16 proves entry and bounds the next white gap after a white. Perez Morales gives the ether erosion and rules out an ether wall at every width. The catalogue supplies the two ether alignments with constant gates. K81 uses a deterministic leftward orbit to obstruct bounded temporal periods. [Hallee's survey](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/negative-results/columns/period-three-011.md) · [Earlier R5 test](research/r5/README.md#9-the-census-of-walls-computed)
- **Found by.** Applied masked coupling to one additional interior ether column and used the S16 finite-tail form of erosion. The physical three-tick strip graph covers bounded spatial widths and arbitrary periods.
- **Credit.** Masked coupling, the ether alignments, erosion, and the restriction on gaps that start at a white are prior work. The extension defeats the constant-black escape even though its infinite ether is in S16's trap.

## P77 · 2026-11-25 · Coupled lifetime and the unrestricted driven gate

- **Ours.** I246 checks the depth-80 cutoff in K84's joint cone and in a smaller right-only cone. It gives new finite cutoffs, exact black-first gate counts through 43 readings and a uniform rate upper bound below 0.151 bits per white reading. The Lean equivalences put the finite support test in the kit's sideways notation. [Continuation](research/rule4/k84/gptIntel-k84-continuation.md)
- **Known.** `Rule30PeriodTwoSideways` proves the sideways reconstruction and exact death. K83.A derives the finite support condition and counts through 15 readings. K84 computes the first support profile. S18 proves uniform entry into S17's 777-window set and the nine gap pairs thereafter. The inherited K47 ladder, P15 and GC2794 compute tighter growth bounds conditional on entry into the narrower 829-window trap, which allows only gaps 3 and 5. The kit's gap-2 ether gives a right half outside that entry hypothesis. [K83.A](research/rule4/k83a-gate-mass.md) · [K84](research/rule4/k84/README.md) · [S18](research/arrivals/uniform/README.md) · [K47 ladder](research/m9/claudeCloud_m9_lift.py)
- **Found by.** Compared the horizon and depth indices of the kit's exact-death proof and the K83.A decoder. Searched the kit, portal, both prior-art files and ledger; “trap ladder”, “eventual language” and P15 identify earlier gate rates better than “entropy of an alternating wall”. Compared the 829-window entry hypothesis to the ether and the universal S18 deadline. I239's factors give finite physical lower bounds and a conditional two-block entropy floor.
- **Credit.** The reconstruction, trap, uniform-entry theorem and earlier conditional rates remain with their authors. The new rate is from an overlapping 56-reading cover of every black-first right half. K83.B's cited entropy is for the full-line Rule 30 map.

## P78 · 2026-11-25 · Two-sided spacing of a varying sparse mark

- **Known.** S8 requires the three gaps (12, 10, 9). N12 computes the nine-gap localization and R117 proves the periodic phase transfer from its finite premise. R121 excludes separations below thirteen and a black later mark at separation thirteen. [S8](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-f1c87a) · [N12 transfer](research/white-gap-mixtures/gptM5-n12-return-read.md) · [R121](research/white-gap-mixtures/gptM5-physical-returns.md)
- **I250.** Conditioning the recurrent-strip domains in both directions and checking physical continuity excludes a black sample at either mark at separations thirteen through fifteen. The Lean implication at separation thirteen checks the local physics given four projected domains. The width-29 premise and the localization keep the stronger claim computational. [Results and scope](research/white-gap-mixtures/gptIntel-i77-two-sided-returns.md)

## P79 · 2026-11-25 · Free-phase two-block rotation orders

- **Known.** 0ef6e2 excludes finite-arc words with sufficiently large continued-fraction digits, with one reading per letter. S19 excludes arbitrary blocks for every angle when the start lies on either cut orbit. 8084e6 and the quasi-Sturmian morphism characterization cover the same-orbit reduction. Lowry's gap repeat bound is for its specified gap class and repeat geometry. I127/N8 supply the unweighted metric prefix repeats. S11 supplies the all-phase golden half-circle repetitions. [Finite arcs](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-0ef6e2) · [S19](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261125-301e35) · [Quasi-Sturmian characterization, Lemma 2.2](https://irma.math.unistra.fr/~bugeaud/travaux/BugeaudKimFourier.pdf)
- **I252.** Two-cut best approximation and a three-trial window at denominator ratio above seven supply positive surplus. Prefix length envelopes transfer it to arbitrary positive block lengths at every phase. The argument varies over angles, arc lengths, phases and block lengths through one proof. Searched the kit at `e92083b`, the 427 live portal entries and 17 open kit PRs. The seven nearby portal results were the clock theorem, characteristic and free-intercept Sturmian exclusions, Lowry's repeat bound, S11, S19 and 0ef6e2. [Candidate and comparison](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/free-phase-repeats.md)

## P80 · 2026-11-25 · What a wall hears: OR words beside a wall, the entropy, and the left words

- **Ours.** The topological entropy is the growth rate of the OR words summed over all walls, and a bound uniform in the wall bounds it (M191, Lean, unread). Integer certificates put the worst wall at 0.2425 bits a tick or less. [Note](research/rule4/k83b/hearing/README.md)
- **Known.** The bound 2^(n+1) for a wall of length 2n is Lowry's (`Rule30MaskedForkRate`). That a periodic centre leaves the left side poor, so that a rich left side gives Problem 1, is Kurtuluş's (`Rule30LeftRichness`). Galindo has 5/4 and 39/32 with weights that know the next wall bits, the unconditional linear lower bound on horizontal words, and the criterion in that form (`Rule30HorizontalDiversity`, R30-20261125-70fb8c). Quint has (21/2)^(1/12), and 4n for rules 90, 150 and 210 (R30-20261125-f6ca26). The sum of the counts over walls is I234's a_n.
- **Found by.** The owner's question on R30-20261125-f6ca26. Read its Lean source and the kit modules above. S20's searches (entropy, pair words, column pairs, transfer matrices) met none of them, since they say masked futures, OR words, horizontal words and left richness.
- **Credit.** The per-wall counts, the criterion and the look-ahead are theirs. Ours is the link to the entropy and the mean form. With S20's identity their counts give 1.5, 1.3219, 1.2854 and 1.2827 bits, where S20 has 1.2320.

## P81 · 2026-11-25 · Finite hearing certificates and disjoint-pair density

- **Known.** K83.B already proves convergence of the total finite-strip counts in prose. Gaubert and Stott give a finite-memory hierarchy for nonnegative matrices at fixed dimension, including a quantitative approximation theorem under positive irreducibility. Galindo's newly merged terminal census proves the disjoint-pair product bound and derives the sufficient density 3/20 from his five-cell OR bound. [K83.B](research/rule4/k83b/README.md) · [Gaubert and Stott, §IV](https://www.cmap.polytechnique.fr/~gaubert/PAPERS/MTNS2018-0181.pdf) · [Galindo, #428](https://github.com/WolframInstitute/Rule30PrizeKit/pull/428)
- **I257.** Every rational base strictly above the physical worst-wall rate has a finite integer certificate. A block of length k gives width k and look-ahead k−1. Certificates bound both the entropy and the single-seed vocabulary. Coupling the latter to Galindo's product makes every positive density a/b with 4^a > (p/q)^b sufficient under the stated base. One per seven already passes with his 39/32 certificate. The seed abundance and the optimal rate are open. [Proofs and scope](research/rule4/k83b/hearing/finite-lookahead.md)
- **Found and credited.** Searches covered the kit and portal, both prior-art files, ledger, open kit PRs, and the literature on joint spectral radius in addition to the wall/strip terms of P80. The finite-memory principle, the terminal census and the five-cell table belong to the cited authors. The physical horizon, the explicit construction and the variable-density implication are the present contribution.

## P82 · 2026-11-26 · Run-transition windows at every finite-left site

- **Known.** Kurtuluş's `Rule30RunTransitions` combines five-cell certificates and parity propagation at the singleton centre. `Rule30FiniteStrips` gives all-site soundness of strip certificates. Dyer's classification is for the repeated word $1^b0^q$ at every site of any row with a leftmost black cell. PR #416 is a finite collection of strip-certified words, lengths 14 through 18. [Kurtuluş, #381](https://github.com/WolframInstitute/Rule30PrizeKit/pull/381) · [Dyer's notebook](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261124-cacfbd) · [#416](https://github.com/WolframInstitute/Rule30PrizeKit/pull/416)
- **I93.** I95 gave exact two-black-run thresholds over arbitrary rows. Continuing it, the finite-support witnesses work at every site below the thresholds, and every phase of a word can choose either I95's window or one of Kurtuluş's. The mixed 49-tick example needs both. A primitive family is obtained by inserting any number of nine-black runs. [Scope and exact separation](research/black-run-transitions/joint-windows.md)
- **Found and credited.** Compared the exact kit support and source hypotheses at `71151d0`, Dyer's two attached notebooks, #416 and its maintainer discussion, and the project record. Credit the original windows and parity argument to Kurtuluş and his collaborators. The sharp pair thresholds, finite-row witnesses, and hybrid all-site criterion are the extension.

## P83 · 2026-11-26 · Real points in S9's pentagon and the width-155 corner

- **Known.** Condrey and Quint–Gemini supply the source-observable bound. S9 gives the five faces, five physical vertices, arbitrary controller schedule, rational one-history theorem and six-cell nonnegative losses. I72 already gave the real schedule on paper. K67's independent SAT search found 155 to be the first width when time period ten was imposed. [S9, kit PR #402](https://github.com/WolframInstitute/Rule30PrizeKit/pull/402) · [S9 carrying read](research/source-density/claudeCloud-carrying-read.md)
- **I262.** The Mathlib extension checks the five closed half-planes as the exact real limit set for each prescribed right half, with a target-independent discrepancy bound. The core extension identifies a unique entire left half after one common onset whenever the upper-corner deficit stays bounded. It proves the minimum width and divisibility on rings of every temporal period. The forward replay matches S9's film after four ticks. [Proofs and attribution](research/source-density/real-region-and-ring.md)
- **Found and credited.** Searched the kit, portal, open PRs, ledger archives and both prior-art records under pentagon, density polygon, real weights, Beatty, 155 and nine-tenths. The relevant prior results were filed under the source observable and the density escape module. S9 and its existing witness retain credit for the original construction.

## P84 · 2026-11-26 · Three and four inverse layers beside a prescribed wall

- **Known.** Hughes gives ages 8 and 24 on the fixed white half. S6 transfers them to the line and establishes its age-23 sharpness witness. S23 uses checked wall-prefix propagation for the ages 8 and 24, with a one-tick offset for the adjacent start. S1 already grows covers one cell per tick and sweeps the inverse registers in parallel. It proves age 80 for four ticks on the fixed white half. R25 computes a white-wall upper bound of 72. Lowry's cascade and Quint and Gemini's capacity reduction supply the existing conditional many-layer route. [S23 and its sources](research/k50_3/s23/essay-draft.md) · [S1 proof](research/r2/age80/Rule30AgeEightyInverse.lean) · [R25's covers](research/m29/seed-anchored-covers.md) · [Earlier capacity comparison](research/k50_3/review.md)
- **I267.** A new staged width-29 cover sharpens three ticks to ages 31 and 32 for arbitrary walls, with same-wall witnesses one age earlier. Its growing continuation yields computed bounds 76 and 77 for four ticks. K63 anticipated the capacity transfer once the band is strictly inside the wall. [Proof and scope](research/k50_3/three-or-more-wall.md)
- **Found and credited.** Searched the kit, the portal, both prior-art files and the ledger under three-step inverse, prescribed wall, inverse registers, settling age and capacity. S1's paired sweep is directly reused in concept. The new proof combines it with S23's growing depth and arbitrary wall tapes.

## P85 · 2026-11-26 · Ordinary prefix repetitions in free-phase rotation orders

- **Known.** Adamczewski's proof of Proposition 4, equations (5)–(8), uses letter frequencies to transfer prefix repetitions through a nonerasing morphism of a Sturmian word. Nguyen's §7 counts crossings for interval codings. Theorem 7.4 gives infinite ordinary Diophantine exponent for unbounded partial quotients and a finite exponent greater than one at bounded type. P49 records Jen's physical bound. S19 treats the two endpoint orbits at all angles and N20 supplies phase-uniform block-length estimates. [Adamczewski](https://arxiv.org/pdf/1205.0961) · [Nguyen](https://arxiv.org/html/2608.20191v2#S7) · [N20](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/claudeIntel-i252-read.md)
- **I270.** The distance between three failed trials gives a sufficient denominator ratio above six at every phase for every two-block substitution. This adds bounded-type angles such as the all-six angle. The portable proof applies finite-window Jen directly. Actual cuts at one lag attain the boundary of the test. [Proof, comparison and checks](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/relative-cut-span.md)
- **Found and credited.** Read both papers, the kit and portal rotation results, I127, I252, N14, N20, P49 and P79, and checked the 23 open kit PR titles through #442. The morphism and crossing arguments have the precedents above. The improvement concerns the ordinary repeats long enough for Jen at bounded type.

## P86 · 2026-11-26 · The gate and bounded discrepancies at the one-third corner

- **Known.** I73's sharp defect comparison and Lowry's independent bounded-charge theorem both identify the eventual 011 two sites east. I73 already obtains the two observed columns by left reconstruction. I244 proves both gate colours arbitrarily late for finite right support. R5 tests physical forks through width 22 and excludes labelled finite traps through width 34. [I73](research/source-density/quiet-corner.md) · [Lowry, #440](https://github.com/WolframInstitute/Rule30PrizeKit/pull/440) · [I244](research/r5/periodic-gate-011.md)
- **I272.** The exact scaling of eventual periods and the signed three-tick count identity are checked in Lean. Two fixed right halves reject every gate period through 4,096 after sample 4,096 in whole-line finite-cone replays. The all-period step remains open. [Proofs and scope](research/source-density/one-third-gate-status.md)

## P87 · 2026-11-26 · The fair law on the image of a driven right half

- **Known.** The kit gives the fair full-row spacetime, independence of the initial right half and forward centre trace, and a synchronizing predecessor window. Its sideways and exact-death theorems supply the period-two left reconstruction. Rowland treats reversibility with a white right tail. Kopra treats rapid left expansivity, finite trace reconstruction and recurrence of right tails. Lowry’s gate-past proofs treat far-west closing of admissible gate histories. Quint and Gemini give mod-4 infinite coupled criteria and exact locked gate families. [Kit fair rows](https://github.com/WolframInstitute/Rule30PrizeKit/blob/aaaefdd46c07c03aa2abd4d980a71dba746e686d/equivalents/Rule30Equivalents/Mixing.lean) · [Rowland](https://ericrowland.github.io/papers/Local_nested_structure_in_rule_30.pdf) · [Kopra](https://www.utupub.fi/server/api/core/bitstreams/eeb04919-9fa7-443b-998f-032fab664a41/content) · [Lowry #52](https://github.com/WolframInstitute/Rule30PrizeKit/pull/52) · [Quint and Gemini #443](https://github.com/WolframInstitute/Rule30PrizeKit/pull/443)
- **S28 proposed, I273.** Exact fair mass and exact restriction law for prescribed and continuous feedback walls, one-sided recovery almost surely, the conditional pure-period reduction, and the all-horizon finite support test beside black-first alternation. S20 and S22 concern word counts and entropy, while this uses fair measure and exact finite horizons. [Statement, scope and checks](research/rule4/s28/review.md)

## P88 · 2026-11-26 · Quint's mod-4 form of CQ01 and the period-two lock (kit pull requests #443, #444)

- **Theirs.** #443 (R30-20261126-e8fd62): `CQ01` and `CQ01Empty` as conditions mod 4 on two integer orbits; the kick as GRˢ(Z) ≡ 0 (mod 4), and ≡ 4 (mod 8) where the gaps are 3 or 5; a one-bit forecast of 3 against 5 there, the converse of our `no_one_bit_forecast`. #444 (R30-20261126-e00dea): a width-19 period-two lock; the families of 112 (24 cells) and 31 (26 cells) with an alternating gate from the start; those and the two seven-lock families never in the trap; the dichotomy and `Q01Gap` give `CQ01`. Both are by G.P.J.W. Quint with Gemini, open, built here at heads `6c63328` and `525161c`.
- **Already in the kit.** The last statement is `Rule30PeriodTwoWidth13.CQ01_of_RD_of_Q01Gap` (AIOvernight, 9 November). The 31 family, its `CQ01` instance and the lemma that two kicks two apart keep a window out of the trap are our `Rule30EtherFamilies` (#394, 23 November: `u_prefix31` with 28 cells, `CQ01_prefix31`, `not_trap_of_black_pair`, and a second family from 495 with 24 cells). The trap forecast follows from our `next_gap_from_second_white` (S13), which #443 cites. The exact death of a truncated `Psi` is the kit's `truncation_death` (17 October) and Quint's `integer_truncation_exact_death` (#433): S28's core companion (`K84FiniteSupport`) is their two-way form.
- **New with them.** The mod-4 and mod-8 forms; the family of 112, which has the ether's other phase; the ether's lock as a closed set of windows; the seven-lock families outside the trap.
- **Ours, beside it (K91).** None of the prefix lengths is least: 22 cells force the gate of 112, 23 that of 31 and 20 that of 495 (COMPUTED). Of the four rings of K79 the kit now has locks for gates 2, 5 and 2,5; the 84-column ring of gate 3 has none (MEASURED). The mod-4 form is K84's frame, and K88 gives the measured size of its "some s". [Review](research/k50_1/kit-prs/claudeCloud-pr443-444.md)
- **Found by.** Fetched both heads into the kit clone and read the diffs whole; compared with `Rule30EtherFamilies`, `Rule30PeriodTwoWidth13`, `Rule30SidewaysLocks`, `Rule30GatePulseReturn` and `Rule30PeriodTwoSideways` at kit main `aaaefdd`; the pull requests' own texts name none of the earlier theorems.

## P89 · 2026-11-26 · The finite-horizon west test beside an alternating centre

- **Ours.** S28's proposed core companion (I273, from gptIntel's `K84FiniteSupport`, I246): for every horizon `T`, alternation through tick `T` iff agreement with `Psi R` at depths 1 to `T`; a west supported in 1 to `B` works through `T` iff `Psi R` is white at depths `B + 1` to `T`; equal required prefixes iff equal gate readings at white ticks below `T`. Proved in core Lean, correct, and known: not submitted (N29).
- **Known.** The first two are the kit's `Rule30PeriodTwoSideways.exact_death_center` and `truncation_death` (17 October), with `zrow_light_cone` (K91, P88). The third is `Rule30CoupledGerms.Psi_eq_of_u_eq_le` with `u_eq_of_Psi_eq_le`, by G.P.J.W. Quint and Gemini (R30-20261104-bc49cf, in the kit), which specialise `Rule30ZeroBoundary.Theta_dep` and `Theta_inverse_dep`.
- **Found by.** The portal list's "Causal Prefix Injectivity of Psi" for the third, then the kit source at `aaaefdd`; K91 for the first two.
- **Credit.** Exact death and truncation death: the kit. Prefix dependence of `Psi` on the gate, both ways: Quint and Gemini. A census of gate words counting the required west prefixes (I246, K88) rests on these.

## P90 · 2026-11-26 · One statement decides every start, and the exact four- and five-tick ages beside a prescribed wall

- **Ours (N30).**
  - For every number `k` of inverse ticks beside an arbitrary wall, "every start at depth at least two, from age `T`" and "the adjacent start, from age `T + 1`" are each equivalent to the depth-two statement at age `T` (`Rule30DrivenLeftDepthTwo.two_classes`, core Lean). The proof takes any column as the wall (`L_column`), and from age 2 the depth-two start with −1 white gives only rows of the one with −1 black.
  - An exhaustive search over the depth-two rows then gives the least ages 72 and 73 for four ticks and 81 and 82 for five (COMPUTED by two programs; the four-tick lower ages are N27's Lean witnesses), and 108 and 109 for six (one program).
  - I267's four age-75 cover words are not physical.
- **Known.** The offset of one between the classes for one and two ticks is S23's, proved there by checked wall-prefix propagation case by case (P84). The three-tick ages 31 and 32 are I267's. The time shift is the kit's `Rule30DrivenLeft.L_add`. Every k on the white wall and on the line is conditional on CAP (R30-20261119-ccc65f, S4, S5, `Rule30EveryKLine`).
- **Found by.**
  - `find_known` under column as wall, depth two, adjacent start, one tick later, least age and four inverse ticks; it found only P84.
  - The kit's `Rule30DrivenLeft` and `Rule30DrivenLeftInverse` sources.
  - The portal's 447 titles, for wall, inverse, predecessor and driven left.
  - No entry states the column-as-wall reduction for every `k` or the four-, five- or six-tick least ages.
- **Credit.** One and two ticks with their offset: Hughes and S23. Three ticks: I267. The cover method that left the 72–76 gap: I267.

## P91 · 2026-11-26 · Uniform driven inverse ages force uniqueness of a recurrent row's parent

- **R136.** In core Lean, `unique_parent_of_every_k` derives at most one arbitrary full-line parent of every recurrent black-edged output from the existence of depth-two ages for all inverse depths. For a finite width, `parent_band_history` bounds how long any first parent can avoid the cyclic bands. The sharp driven ages 131 and 132 for seven and eight ticks are COMPUTED. [Proof and exact-age checks](research/k50_3/threshold-mechanism.md)
- **Known.** M34 and R28 gave the same numbers as upper bounds for the fixed white wall. N30 gave the depth-two reduction and the first six driven ages (P90). K8/I7/M46 already identified uniqueness of the recurrent output's odd moving-edge parent with the deep-reset property (P11). The kit proves surjectivity of the full-line map in `Genericity.surjective_evol_one` and the implication from deep resets to CAP in `Rule30ResetCompactness.cap_of_unbounded_resets`.
- **Found by.** Searches for inverse register, synchronizing word, joint capacity, recurrent preimage, unique parent, necessity and converse across the catalogue, prior art and the ledger. The fixed-wall comparison is in [R28](research/m29/strip-carry.md). The two directions of the earlier strip criterion are in [I7's read](research/m29/k8-reformulation-review.md).
- **Credit.** The cycle bound is the kit's `Rule30EveryKLine.on_cycle`. N30 transfers the cut to a depth-two start. R136 uses unrestricted inverse extensions of an arbitrary *first* parent to force that parent itself onto every finite cycle. The complete equivalence with CAP still uses the earlier hand arguments.

## P92 · 2026-11-26 · Rule 180 clears every fixed site of a finite white-background perturbation

- **What we found.** K92.5's local proof clears the leading black cell in at most two ticks in Rule 180 and three in Rule 120. It allows an arbitrary infinite eastern tail.
- **Earlier result.** For finite full rows in Rule 180, Cattaneo and Margara's Theorem 2.1 gives an exact power-of-two translation. Their Theorem 4.4(i) gives convergence to the all-white row. Braga et al. already studied finite-pattern growth and its moving boundaries in both rules. The kit's Rule 180 singleton is a special initial condition. [Cattaneo and Margara](https://doi.org/10.1016/S0304-3975(97)00210-7) · [Source read and proof details](research/phase2/borrowed/siblings.md)
- **Found by.** Searching for Rule 180, pattern growth, sub-shifts and moving finite configurations. Searching the kit under the singleton module alone misses the older general theorem.
- **Credit.** Finite Rule 180 decay is known, reproved here. The local comparison tests the hypotheses against Rule 30. We make no priority claim for the one-sided extension or for Rule 120.

## P93 · 2026-11-26 · Post-support spatial counts and conditional amplification of an immortal row

- **What we used.** K92.2's all-k white-block reading is a specialization of the published `sum_seeds` correspondence. K92.5's sparse-width test is a contrapositive of `immortal_rows_4096`.
- **Earlier results.** Benboubakeur and collaborators prove the two-check loss at one of seven width indices. Their companion gives at least 4,096 immortal rows at every sufficiently large exact width of a witness's parity, with explicit gap 389. It sharpens the kit's earlier inverse-history width threshold. [Second-check proof](https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/file?id=R30-20261126-65dcb1&kind=lean) · [Inverse-history proof](https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/file?id=R30-20261126-e2e0e2&kind=lean)
- **Found by.** K92 pointed to the portal entries. Reading the original Lean and comparing `A`, `S`, `Top` and `InX` exposed different width conventions and validity predicates obscured by the term “ladder”.
- **Credit.** The bijection and the amplification are the authors'. Our numerical tables and the checked short deduction specify where one could try to use them. [Quantifiers and candidate test](research/phase2/borrowed/methods.md)


## P94 · 2026-11-27 · Recurrent black pairs, fall phases and Jen's obstruction

- **What I295.2 adds.** In every six consecutive singleton columns, one fixed column has recurrent black-to-white transitions at two distinct residues modulo three. I301–I306 use a finite graph with an individually prescribed fall phase at each site and two free exterior cells. [Research block](research/phase2/falling-phases/README.md)
- **Earlier results.** KDRonald3 and Claude's `black_pair_infinitely_often` proves recurring adjacent black cells at every bond for any row with a leftmost black cell. By the Rule 30 update this already gives recurring falls at each individual site. Lowry's `four_columns_hit` gives cofinal black observations on a specified residue across four columns. Dyer's `every_column_run_count_laws` bounds waiting times for each colour. [Black-pair statement](https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/file?id=R30-20261115-2d4add&kind=lean) · [Lowry](https://github.com/WolframInstitute/Rule30PrizeKit/pull/452) · [Dyer's statements](https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/file?id=R30-20261126-19e94d&kind=lean)
- **Found by.** Searching for falls led first to centre-run geometry. Reading the same event as a spatial black pair found the earlier cofinality theorem. Checking the quantifiers on Lowry's third-tick results distinguished a pooled observation from a fall at one site.
- **Credit.** The adjacent-column obstruction is Jen's. The kit's masked window theorem supplies its finite form, and its strip certificates supply the physical strip update. Our contribution is the six-site assignment check forcing an adjacent periodic pair, its time bound, and the same-site phase conclusion.


## P95 · 2026-11-27 · Trapped windows and uniform fall residues

- **Earlier method.** KDRonald3 and Claude's *Windows That Always Return* confines a window that avoids a set of rows to a recurrent component of a graph with both exterior cells freely chosen. It rules out components with a constant column and uses Jen to rule out components that are simple cycles. It also proves recurrence of each spatial black pair. [Portal entry](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261115-2d4add)
- **How we used it.** I303–I307 added a clock to the graph and tracked one allowed falling phase per site. K95–K96 identified the methodological precedent, computed the extension in the modulus and gave the marked-run compression to 72.
- **Credit.** The all-modulus Lean proof uses K96's quiet-run idea. Its new step is a fixed deletion on every path, reducing the required period checks to 18. The adjacent-periodicity contradiction is Jen's. [Review](research/phase2/falling-phases/claudeCloud-review.md) · [Proof](research/phase2/falling-phases/every-modulus.md)

## P96 · 2026-11-27 · Wolfram's square root and the masked Jen theorem

- **Earlier result.** Wolfram names the three ternary nearest-pair square roots 11736, 11739 and 11742. The kit's equivalents catalogue repeats the claim and marks it unchecked. Cloud located the note during K98. [Wolfram, NKS p. 956](https://www.wolframscience.com/nks/notes-6-6--square-root-of-rule-30/) · [Kit catalogue](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/equivalents/CATALOG.md)
- **Known, reproved here.** I313–I315 checked the three codes on all binary rows and enumerated all ordered tables with white=0 and black=2. The intermediate bond determines the physical cell and its OR with its eastern neighbour. Their joint aperiodicity is already the kit's finite masked form of Erica Jen's theorem. The all-time square identity and this identification have a core Lean proof. [Square and decoding](research/phase2/borrowed/TernaryRoot.lean) · [Kit masked Jen](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30FiniteMaskedJen.lean)
- **Found by.** The numerical codes occur in the kit's full equivalents catalogue. Searching the condensed index by those codes missed the note. The link to masked Jen emerged by decoding the odd half-step on 00, 01 and 1*.

## P97 · 2026-11-27 · Relative termination, monotone erosion and the cumulative survivor count

- **Earlier results.** Yolcu, Aaronson and Heule use descent on selected rules in a relative termination proof. Toom's monotone erosion criterion uses the geometry of the zero-forcing sets. For the Rule 30 wall the kit already proves that the odd-tick free stream of any finite immortal would be nonperiodic. Benboubakeur et al. supply all 4,096 prescribed length-24 histories with one common forward image at sufficiently large widths. [Yolcu et al., §§2–4](https://emreyolcu.com/research/rewriting-collatz.pdf) · [Toom, §6.3](https://cs-web.bu.edu/faculty/gacs/toomandre-com-backup/my-articles/engmat/SNELL.PDF) · [Inverse-history source](https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/file?id=R30-20261126-e2e0e2&kind=lean)
- **How we used them.** I316 sums distinct widths and proves the exact endpoint ceiling for short inverse splices. I317 uses the two recurrent wall classes modulo four to test relative ranks and uses the kit's permutive difference front and the moving left edge to exhibit an XOR on every time block. The proofs of the original multiplicity, odd-stream obstruction and two edge laws retain their earlier credit. [Counting and coalescence](research/phase2/borrowed/arithmetic-transfer.md) · [Termination and erosion](research/phase2/borrowed/termination-transfer.md)
- **Found by.** K98 asked for methods beyond finite rankings and ordinary white fronts. Reading the returned endpoint in the inverse-history proof and the hypotheses in the termination and erosion theorems located the missing conditions.

## P98 · 2026-11-27 · One trace, ensemble mixing and the cost of indexed bits

- **Earlier results.** The Pyatetskii–Shapiro hot-spot criterion uses upper frequencies of all words on one trace. Chang's corner-permutivity result covers deterministic mixing under the fair product law. Marcovici, Sablik and Taati give uniform ergodicity under positive independent update noise for one-sided permutive rules. Fischer–Rabin's lower bound concerns the truth of encoded Presburger sentences. [Bailey, hot-spot formulation](https://www.davidhbailey.com/dhbpapers/alpha-normal.pdf) · [Chang, Remark 3.2](https://arxiv.org/pdf/1410.2144) · [Marcovici et al., Theorem 3.16](https://arxiv.org/pdf/1712.05500) · [Fischer–Rabin, Theorem 1](https://dspace.mit.edu/entities/publication/2f7b4975-459f-4dc7-9f70-2107d97bd8d1)
- **How we used them.** The kit's distinct-foot argument yields an exact singleton-prefix/random-tail interpolation. Erica Jen's uniqueness theorem and Quint and Gemini's canonical-window machine bound give a lookup-cost partial on the real spacetime. The cofinite-site corollary leaves the named centre open. [Frequency comparison](research/phase2/borrowed/arithmetic-transfer.md) · [Source reads, counting formula and machine corollary](research/phase2/borrowed/orbit-cost-transfer.md)
- **Found by.** The matching questions are K98.5, K98.6, K98.8 and K98.9. Checking the starting measure, the noise at each tick and whether the input is an index or a full starting row separated four different statements.

## P99 · 2026-11-27 · Sparse wall certificates before the 18-black deadline

- AIOvernight’s Sparse16 proves that 56 even black wall observations force 17 black cells in the first 111 depths of an arbitrary half-line. Its primary notebook credits Patto1155’s renewal replay through five black cells and Placego’s corrected five-black bound, under their respective boundary conventions. The kit’s Rule30ZeroCoastBridge §13 already uses finite branching at bounded weight for kick languages. [Sparse16 notebook](https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/file?id=R30-20261023-60d213&kind=notebook) · [Kit proof](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30ZeroCoastBridge.lean)
- I320 adapts the weight-budget argument to the bare even-time wall, branches on the next occupied position that can change a failed check, and independently checks the budgets 17 and 18 by reading initial bits along successive light-cone diagonals. Its endpoint criterion uses the kit’s exact motion of the leading black. [Work and evidence levels](research/phase2/gemini/sparse.md)

## P100 · 2026-11-27 · The predecessors of the five Gemini questions

- Lowry supplied the marked-gap criterion for Problem 1. The kit's settled-run proof already distinguishes inherited and newborn white runs. M220 supplied the forcing edge prefixes. I321 identifies the predecessor pattern at the named observer and counts both centre colours from disjoint observation windows. Luis Perez Morales and Claude’s exact run triangles precede I323’s even-depth disagreement bound; the sharper depth-two estimates use a local telescoping inequality. [Lowry and the settled-run sources](research/phase2/gemini/launch.md)
- The rooted white-return cascade, its single-phase extensions, and R44's cofinal resets underlie I321's five-tick result. The new localization bounds the position and gives the exact run length one at every first loss. [Predecessors and theorem](research/phase2/gemini/clock.md)
- Galindo supplied the horizontal five-cell upper bound and the terminal fork budget. The finite masked form of Jen bounds when a repeated pair must disagree. I322 uses the disagreement to count late spatial words. [Statements and sources](research/phase2/gemini/vocabulary.md)
- Quint and Gemini's binary-ray mismatch bound is sharp even at every positive index for the explicit length-parity scanner. Benboubakeur and collaborators' quadratic apex-state bound takes a variable initial word; the statement and Lean file were replayed for I322. [Model comparison and primary sources](research/phase2/gemini/indexed-cost.md)

## P101 · 2026-11-28 · Reconstruction and temporal hybrids before the 150/180 wall test

- Paul and Das study temporally non-uniform automata, using periodic boundaries for their finite lattices. The kit's `Rule30HybridWall` treats an alternation of 150 and 90 **in space**. Its growing finite immortals are a control for any argument that tries to deduce wall mortality from edge growth. [Paul and Das, §II](https://arxiv.org/html/2411.17421v2#S2) · [Kit's hybrid](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30HybridWall.lean)
- The finite trace reconstruction and motion of the first disagreement have precedents in the kit's masked Jen and Villafuerte's difference front. Condrey used a moving edge to bound the length of a repeated driven-left window. The earlier `8084e6` portal entry excludes Sturmian visible neighbours beside a Rule 30 centre clock. The 150/180 result uses its different edge speed to force `2m+2−K` distinct odd words after launch and gives a finite `4W+4` deadline for low vocabulary. The periodic reference uses the established first-difference argument for an exact family of merged finite starts. [Condrey's window theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30DrivenLeftWindows.lean) · [Portal predecessor](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-8084e6) · [Proofs and comparison](research/phase2/borrowed/edge150.md)
- Found by searching the kit, portal, ledgers and prior-art files for the rule pair, temporal alternation, hybrid wall, difference front, driven-left windows, Sturmian and word complexity. K99 identified the target pair and its phase dependence. Its finite line observations supply no proof of chaos.

## P102 · 2026-11-28 · Adjacent differences and cuts of periodic wall references

- The kit's `Rule30ConeTip.level_aff` and `diag` give the leading and next diagonal for a single flip in the white-wall Rule 30 frame. Its `diag` sums the negated east-input bits. It credits the whole-line `deriv_evol_diag_succ` in `AlgebraicDegree`. `Rule30ZeroBoundary.zero_run_local` supplies equality between a row and its cut through the common cone. The coupled `truncation_death` instead observes the prescribed centre. [ConeTip](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30ConeTip.lean) · [ZeroBoundary](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30ZeroBoundary.lean)
- K102 identified the closest earlier cutoff result. The kit's `Rule30ZeroBoundaryBarriers.trunc_survives` cuts the stationary stripe, black at odd physical depths, at odd depth $n$. Its wall stays black through tick $n$ and is white at $n+1$. I333's alternating wall reference has its own even-width formula. [Stationary stripe](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30ZeroBoundaryBarriers.lean)
- I332–I333 extend the adjacent-diagonal formula to time-dependent west-permutive rules and an arbitrary second initial difference. Their periodic parity theorem and four-diagonal return give exact even failure times for the hybrid reference and the explicit Rule 30 alternating reference. Anashin §4.1 gives the related triangular-map setting. P1 credits AIOvernight's different sparse reference. [Anashin](https://arxiv.org/pdf/cs/0612038) · [Proofs and scopes](research/phase2/borrowed/wall-cutoffs.md)
- Found by searching KIT, KIT-INDEX, PORTAL, both prior-art files and the ledgers for cone tip, Boolean derivative, truncation, first omitted black, constant free and periodic tail. K101 independently replayed the hybrid formula and identified its transient exception.

## P103 · 2026-11-28 · Exact cutoffs at the one-in-seven Rule 30 reference

- **Known.** AIOvernight's R30-20261109-4dce4d gives the eternal seven-spaced reference and the three sharp G witnesses. Galindo's #410 proves the reference's wall and bulk phase, certifies the added-spike row through 18,475 readings, and gives the two external drivers, finite suffix recurrence, and two infinite progressions of modified widths. [Paper and files](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261109-4dce4d) · [Galindo #410](https://github.com/WolframInstitute/Rule30PrizeKit/pull/410)
- **I334–I338.** Checked the literals, including that the three published integers equal the ordinary cuts with 11, 27 and 43 spikes. The exact first-failure formulas for both fixed suffixes at every width, their sharp delays and the denser first-failure progression are computed here. The wall reduction reuses Galindo's proof. P1's listed numbers 1, 2 and 4 are packed indices, one less than physical depth. [Scope and replay](research/phase2/borrowed/seven-spaced-cutoffs.md)
- **Found by.** Read the portal notebook and verifier, the kit's mass and mass-counterexample modules and the merged #410. Searched the kit catalogue, portal, ledgers and both prior-art files for 2538/127, one-in-seven, white wall, sharp widths, 2635 and suffix recurrence. P1 found the reference. The exact failures after the cutoff are the new question.

## P104 · 2026-11-28 · First failures after white arrivals and gap births at two observers

- Lowry's `first_failure_of_mark` and `problem1_of_first_failures` identify marks with specific delays and make unbounded finite first failures sufficient for Problem 1. His `two_white_four_delay` already exhibits a white arrival followed by a delayed failure. `Rule30RestartVisibility.extend_failure` changes the seed to place a later failure. I343 asks exactly which **unchanged singleton gaps** first fail one tick late, using one extra western bit. The leading flip and the adjacent diagonal are prior art (P102). [Marked gaps](https://github.com/WolframInstitute/Rule30PrizeKit/blob/10a4b86/lean/Ruliology/CellularAutomata/Rule30MarkedGaps.lean) · [Restart visibility](https://github.com/WolframInstitute/Rule30PrizeKit/blob/10a4b86/lean/Ruliology/CellularAutomata/Rule30RestartVisibility.lean)
- KDRonald3 and Claude's `seed_black_pair` and `window_001_100` give recurrence of the spatial black pair and a disjunction of white-pair windows. The kit's `Rule30SettledRepeats.back` gives gap ancestry. Lowry already certifies the width-22 mark at seed age 34,429. Ulrey's `center_two_step_black_independent_of_right` identifies a two-step centre value at a specific local pattern. I343 assigns distinct primitive births to individual falls and counts distinct equal pairs forced by their five-cell words. [Portal proofs](https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/file?id=R30-20261115-2d4add&kind=lean) · [N39 read and attributions](research/phase2/gemini/claudeIntel-launch-read.md)
- S12's right-prefix seven-lock and S17's column-1 gate words also condition on an alternating centre. S32's two falling residues choose a site among six and require modulus at least three. Here the open fall recurrence asks for **modulus two at site −2**. Found by searching the kit catalogue, portal, prior-art records and ledgers for falls, white pairs, primitive births, cone tip, five-cell words and restart delays, then reading the theorem statements. The label “unmarked” alone misses Lowry's controlled edits. [S32 scope and parity control](research/phase2/falling-phases/every-modulus.md) · [I343 proofs and counts](research/phase2/gemini/unmarked-launch.md)

## P105 · 2026-11-28 · Longer intervening whites and persistent east readings

- Kurtuluş's `Rule30RunTransitions.a8` and two-step parity lemmas force the odd-run readout after one white. S24 proves the sharp single-white cutoffs and supplies the all-column phase-coverage argument (P82). I344 extends the odd upper bound to any nonempty intervening white run and proves the sharp two-white table, including the even-run cutoff 16. [S24](https://github.com/WolframInstitute/Rule30PrizeKit/commit/fa1091e) · [Follow-up](research/black-run-transitions/double-white-windows.md)
- Kurtuluş's #437 excludes long-run-plus-tail mixtures on the singleton centre. Its odd-gap pair family covers the centre case with a final black run of length two. The published five-cell tail language misses the length-four and length-six cases in I344. The general strip method can certify them with more cells. Dyer's pure two-run classes and seven mixed categories have different run lengths or block shapes. S24 and #437 supply the methods. Found by reading their exact statements, the kit index, portal, the open PR list, both prior-art files and archived I93. [Kurtuluş's tail theorem](https://github.com/WolframInstitute/Rule30PrizeKit/pull/437) · [Dyer at source](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-cade33)
