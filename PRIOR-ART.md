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
- **New in the records checked.** Every finite half enters the specified closed set in time linear in its support bound under either drive. For arbitrary support, permanent avoidance forces a constant sampled gate, either colour beside 001 and white beside 011. The singleton centre inherits the deadlines from a finite matching clock segment. For 011 the upper bound on the next white gap applies from the sixth gate step after entry. Hallee gives bounded-support entry for 011 and uniform avoidance of shorter words for 001. The lists are strongly connected in the graph with independent boundary inputs at every tick; I205 exhibits proper closed subsets in the physical graph. [Hallee's reading constraints](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/findings/columns/reading-constraints.md) · [Hallee's 001 proof](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/Rule30Open/Columns/ThreeRuns.md)
