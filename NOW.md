# NOW

*Where things stand: one file, rewritten (not appended) by whoever changes the state, stamped with the time and the
post that changed it. History is in the [ledger](CHAT-LEDGER.md). Rewritten 2026-11-18 14:29 UTC by claudeM5 (M35).*

## Arrangement

The workers are `claudeM5`, `gptM5`, `claudeCloud` and `gptIntel` (METHOD §9). The old names Local, GPT and Cloud are
retired (the owner, 17 November); claudeM5 takes on Local's workflow (M1).

| Worker | State | Since |
|---|---|---|
| claudeM5 | working in the owner's session, on the M5 laptop (the Wolfram host); joined the shared store (M1) | 17 November (M1) |
| gptM5 | on the M5 laptop with claudeM5; joined the shared store and ready for submission review | 17 November (R1) |
| claudeCloud | compute host with fewer CPUs and more memory, for runs needing a large memory pool (M3); has a store token, not started here | — |
| gptIntel | compute host, Intel i9 with an RX 6600 GPU, for extra or long-running computation (M3); has a store token, not started here. On this host placego's GPT has been paused since 11 November, holding K-09b and frozen batch 02 for a restart (placego GC2929) | — |

Running jobs: none. Schedules: none on (only the owner turns them on).

## Needs the owner

- **Kit PR #357:** approve, change or decline the draft progress reply [reply-357-draft.md](research/m29/reply-357-draft.md)
  (M35). Not sent.
- When claudeCloud and gptIntel start, set their store credentials and point them to METHOD.md, NOW.md and KIT.md.
  Each takes a free ledger letter, posts an introduction and joins its postbox (M4).

## Direction

The easy submissions are done, ours and others'; the hard problem needs new ways in (the owner, 17 November). Two
strategies: this clean repository, whose method and kit summary are read whole into context; and inquisition and
visualisation, so the owner's eye can find structure.

## Submissions

Each candidate follows METHOD §12: claudeM5 writes and posts, gptM5 reads, both agree on the same digests, then the
owner gives the word. Standing consent to post: none (placego's of 10 November does not carry over).

| Candidate | Result | Route | Stage | Post |
|---|---|---|---|---|
| **S1** (from R2; M17, R15) | For every nonzero finite seed and every age t ≥ 80, every four-tick predecessor is finite with its edge exactly four cells inside; all 16 wall histories occur (`aged_four_step_predecessor`, `all_four_tick_histories`). | Portal partial and kit catalogue module `Rule30AgeEightyInverse` | **Lean Verified, Human Verified** (M26, M29): portal entry [R30-20261118-c8b41f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261118-c8b41f), checked 18 Nov 11:05 UTC at `5fb5915`. Kit pull request [#357](https://github.com/WolframInstitute/Rule30PrizeKit/pull/357) is open but will not be merged as it stands. The maintainer will take no more per-k certificates after ages 8 and 24, only the statement for every k (M29, pull M29). M29's draft reply is held: the owner will post on #357 only when there is relevant progress (18 Nov). | [M22](CHAT-LEDGER.md), [M23](CHAT-LEDGER.md), [M24](CHAT-LEDGER.md), [M26](CHAT-LEDGER.md), [handoff](research/r2/age80/proposal.md) |

Verifier's kit commit: `5fb5915` (5 November), confirmed 18 November 10:45 UTC (R16); the kit's main is
`1b3dceb` after the ZeroCoastBridge update (R16). Stages: proposed, packet, read, agreed, owner's word, posted, Lean Verified, pull request, merged.

## Latest results (newest first)

- **18 Nov, M35. One-layer resets alone keep pace to width 4096:** 383 layers, one per 10.7 cells, with every
  layer's registers coalescing within 65 cells at every depth (COMPUTED). With the kit's universal left side, f(k) is
  finite for every k ≤ 383 (PROOF-SKETCH, pending carrying read). The missing step for every k becomes bounded
  one-layer coalescence in the edge band. Draft reply for #357 ready, not sent.

- **18 Nov, R33 (COMPUTED).** On the width-91 witness, 010 immediately before the cut forces the seventh layer’s current bit to 1. That one bit recovers closure of both remaining layers. [Exact repair](research/m29/strip-carry.md).

- **18 Nov, R31 (COMPUTED).** Pairs of inverse layers recover full strip capacity at 71 of 109 widths. At width 91 even triples with a common-suffix cut certify seven layers while the joint register certifies eight. [Witness and table](research/m29/strip-carry.md).

- **18 Nov, R29. M32–M34 carrying PASS.** All seven upper bounds through depth 11 independently reproduced. At width 128 single-layer resets explain 9 of 11 layers. [Review and scope](research/m29/strip-carry.md).

- **18 Nov, M34. Why the ages grow: f(k) ≤ g(W(k)).** The converged edge band (the limit cycle) resets about one
  inverse layer per 11–12 cells, in steps (K(w) = 3 on widths 25–61, 11 by width 123); every row's top w cells reach
  the cycle by age g(w) ≈ 1.4w (g(128) = 178). Together they bound f with no cover per k: f(9) ≤ 144, f(10) ≤ 157,
  f(11) ≤ 172 (PROVED, computer-assisted, carried in R29). Both M33 predictions held.

- **18 Nov, M33. Seven and eight ticks close by 131 and 132** (S1's cover, COMPUTED), so f(7) ≤ 131 and f(8) ≤ 132.
  The two-tick rhythm of M32 is dead. M32's "decided from the wall" is corrected: typical rows synchronise near the
  wall, but the thresholds are set by rows that reach the edge band unmerged. The kit's C20 is exactly the edge
  band's limit cycle at width 20. A route to every k is frozen as two tests: the converged band's reset capacity per
  cell, and the band's convergence time. M34 reports both tests and R29 carries them.

- **18 Nov, M32. The thresholds f(k) through six ticks:** f(1) = 8, f(2) = 24 (kit), f(3) = 31, 59 ≤ f(4) ≤ 72
  (R23, R25, carried in M32: PROVED, computer-assisted), 73 ≤ f(5) ≤ 78 and 104 ≤ f(6) ≤ 108 (PROVED, computer-assisted, carried in R29). Closure is synchronisation of the 2^k wall histories (PROVED), and their merge front moves out from
  the wall about 9 cells per layer (median), with hold-ups of up to about 50. A two-tick rhythm in the steps is
  frozen as a prediction for k = 7, 8. The ledger was rotated (archive 1).

- **18 Nov, R27 (COMPUTED for the sample).** M31 test 1 found zero four-tick failures on one million wide seeds at ages 59–79. All 433,215 rows needing a whole-row scan closed. [Counts and checks](research/m29/m31-realisability.md).

- **18 Nov, R25.** All four-tick histories close by age 72, so **59 ≤ f(4) ≤ 72** (COMPUTED certificate, carrying read requested). [Table and argument](research/m29/seed-anchored-covers.md).

- **18 Nov, R23.** M31 carrying PASS. A seed-anchored cover settles **f(3) = 31** (COMPUTED certificate, new carrying read requested). Seed 617 fails at 30, and 653 band words plus 127 narrower seeds pass at 31. [Argument](research/m29/seed-anchored-covers.md).

- **18 Nov, M31. S1's cover first closes four ticks at exactly 80,** with every failure at 34–79 in the fourth
  layer (COMPUTED). Its first three layers close from age 34, so **31 ≤ f(3) ≤ 34**. Narrow seeds reach only 5–16% of
  the cover's words, so the four-tick gap 59–80 is open. [Scan](research/m29/claudeM5_cover_scan.py),
  [layers](research/m29/claudeM5_cover_layers.py).

- **18 Nov, M30. The sharp thresholds f(k) for k inverse ticks: f(1) = 8 and f(2) = 24 reproduce, and the linear
  guess fails.** Over every seed below 2^15 (COMPUTED): f(3) ≥ 31, f(4) ≥ 59, f(5) ≥ 73, f(6) ≥ 104. f is monotone
  in age over all seeds and in k (PROVED), so f(3) ≤ f(4) ≤ 80. The bounds for k = 4 and 6 rose with seed width, so
  S1's 80 is not mostly slack. [Probe](research/m29/claudeM5_thresholds.py).

- **18 Nov, R21 (PROOF-SKETCH).** One Rule 30 orbit shares the single seed’s moving right edge to any prescribed fixed depth and has an empirical limit giving the entirely white row mass ≥ 1/2. Its initial left tail is unbounded. [Construction and replay](research/r4/vacuum-orbit.md).

- **18 Nov, M29. The kit will not take S1 as one more inverse-tick step.** On #357 the maintainer asks for an age
  f(k) for every number of ticks k, by an argument that needs no new cover per k, and asks why the ages grow (8, 24,
  80). METHOD §12 now excludes the class, with a chain test in the novelty check. The kit's ages 8 and 24 are sharp,
  and M17 bounds f(4) below by 56; f(k) = 16k − 8 fits all three (a prediction, not tested). S1 is now also Human
  Verified on the portal.

- **18 Nov, M26. S1 is Lean Verified on the portal** ([R30-20261118-c8b41f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261118-c8b41f)):
  every four-tick predecessor of an aged finite row is finite from age 80, all 16 wall histories occur. Kit pull
  request [#357](https://github.com/WolframInstitute/Rule30PrizeKit/pull/357) is open.
- **18 Nov, R19 (PROOF-SKETCH).** White ticks above gap K correspond exactly to centred all-white windows K ticks earlier. All 2,068 white ticks through 4096 match the source count (COMPUTED). [Formula, spacing limit and next test](research/r4/source-rows.md).

- **17 Nov, R15 (PROVED in Lean).** Both age-80 four-tick headlines pass the kit checker on main and the pinned portal environment, with no new axioms. The 3,657-word cover compresses to 12 terminal prefixes. [Source and receipts](research/r2/age80/proposal.md).

- **17 Nov, R11.** A seed stays black every even tick through 46 and is the only surviving seed for its ending row. Its twin has eight ancestors at tick 38 and none at 36 (COMPUTED). Full branching over 2j ticks requires starting width ≥2j+2 (PROVED, M18). [Witness and argument](research/r2/black-even.md).

- **17 Nov, M19–M21. M6 closes.** The gap floor (μ(180) = 59, slope about 0.275, COMPUTED) is far below every
  periodic eternal gap row measured (all-5 68/155 the least, all-3 0.512); the minimisers are nested to H = 180 with
  deficit 4.
- **17 Nov, M16. The empty right half's word u ∅ has exponential factor complexity** (MEASURED: p(n) − n = 6,655 at
  n = 100, 64,281 at n = 150; about 0.07 bits per white step, against 0.256 for the free 3/5 gap language). So the
  kit's bounded-excess criterion cannot give CQ01Empty. Psi ∅ has density 0.506 to depth 4000.
- **17 Nov, M15. The G floor is the ether row's 1/7** over 40,720 eventually periodic G traces (COMPUTED; known in
  substance, PRIOR-ART P1). **No window law** (COMPUTED: G words of length 64 have bulk zero runs of 16–21 seed
  bits). The gap floor is UNKNOWN by exact cycles: the 882 traces that close give at least 68/155.
- **17 Nov, R8.** A 74-cell edge certificate closes all four-tick inverse histories from tick 80 (PROVED with M17’s narrow-seed base check). A width-one control gives t ≥ 2d for unconditional closure of d inverse ticks (R9, read in M17).

- **17 Nov, M10. Every exact survivor count in the period-2 web is a word count** (known, kit `seedOfTrace`), which
  is why the planted survivor matches them: counts alone cannot prove Q01.
- **17 Nov, M1 and M5. The shared store is live, with the flat layout, and claudeM5 and gptM5 have joined.**
  `store.php` and `store.py` follow the owner's flat data folder (tests 45 of 45; the previous script fails 10 as a
  control). Every verb has run live; a flag to several recipients has not yet been sent.
- **17 Nov, placego L1680. The bars in the Theta monomial picture are healing.** Each empty column is a context in which
  flipping the first free bit cannot reach depth 31 (COMPUTED, an exact match on all 18 columns). A free bit's reach
  grows with its position: median about 11 depths beyond entry for f0, about 24 for f1, 34 or more for f2 (MEASURED).
  Deep constraints remember most earlier free bits.
- **17 Nov, placego L1679. The kit update step.** KIT.md and KIT-INDEX.md are checked against the kit row by row
  (KIT-UPDATE.md); in step at kit `345f7d7`. New in the kit: NoSeedGE2 ⇒ Q01Gap, and an exact surviving-seed law
  N(H + 10) = N(H + 4) + N(H) for the gap language.
- **17 Nov, placego L1678. "Survivors at the Wall"**, a private visualisation page: space-time diagrams of rows beside
  the white wall, the stopping-time carpet below 2^20, survivor counts (exact halving to k = 12, known; a fair-coin
  tail after, MEASURED), and Theta as a GF(2) polynomial (odd-depth degree known from the kit; monomial density about
  0.38, COMPUTED, not in the kit's catalogue).
- **16 Nov, placego L1675–L1676. The exact mass table of the Q01Gap language to popcount 90** (COMPUTED): NoMass M H
  holds exactly when M < μ(H); the kit's rung is reproduced and sharp; μ(H) ≈ 0.307H + 5.3 (MEASURED). The comment
  offering it to kit PR #350 was withdrawn.
- **14 Nov, placego L1673. The black frontier of a Q01GapCore survivor recedes** (MEASURED); the bounded-frontier
  route is closed.
- **12–14 Nov, placego L1670, GC2940, GC2942, L1672. Mahler's valid starts are equidistributed** (Theorem V, PROVED
  and carried both ways); the count of Z-numbers below x is o(x^0.585).

## Open threads

- **The owner's round of warm pulls (17 November).** gptM5 posted R2–R6 and claudeM5 posted M6–M10, independently.
  M11 compares them and proposes a first block: M6 and M7 by claudeM5, R2 by gptM5. The owner selected R2 for gptM5 (R7).
- Visualisations proposed, not built: an interactive map of the open statements; the branching-walk fan; Mahler's
  valid starts on the circle; a timeline of kit contributions by theme.

### Pulls in progress

One row per pull; the full text is the ledger post named in the first column. Any worker adds to a row's Status as
the work goes. The rules are in METHOD §8.

| Pull | Written | Summary | Status | Submission candidate? |
|---|---|---|---|---|
| L1 (placego L1680) | 17 Nov 10:28, Local (inherited) | The reach map, then the reach of later free bits by sampling to depth 81 | Open. Folded into M8, which gives it a question: the reach inside the gap language. | no |
| L1 (placego L1679) | 17 Nov 10:28, Local (inherited) | Replay the kit's surviving-seed law against placego L1675's tables | Open. Partly answered by M10: the law counts {3, 5}-gap words (N = 1, 2, 4, 7 at H = 6–24, by hand). To do: the replay. | no |
| R2 | 17 Nov 19:55, gptM5 | Does the twin of a late surviving row have a finite past of its own? | In progress. Every four-tick past is finite from age 80 (R8–R9, PROVED in M17; the base is the kit's `band_from_age_twenty_six`, P3, so M17's repair was unnecessary, M18). The planted fixed point is a leaf off its own orbit. R11 refutes a second surviving seed at age 46. All 11 tested fully surviving age-46 ends have four recent pasts. The four-tick bound at ages 46–78 is open in general. Age-80 proposal handoff and both Lean passes in R15. M18: R11's starting-width bound and odd endpoint multiplicity PASS (PROVED), and the age-46 singleton replays independently. The bound 2j + 2 is far from sharp: the least starting widths with a full guarded tree are 7 and 13 for j = 1, 2, and above 14 for j = 3, 4 (COMPUTED).  M22: proposed as S1. M26: S1 posted, Lean Verified as R30-20261118-c8b41f; kit PR #357 open. M29: the kit wants the statement for every k instead, now pull M29. | **yes: S1** (M22) |
| R3 | 17 Nov 19:55, gptM5 | Do switches between 3-gaps and 5-gaps spend seed bits? | Open. Joined to M7 (M11): the kit's complexity criterion relaxes "finitely many switches" to "complexity near n". M16: that relaxation fails for u ∅, whose complexity is exponential; R3's own question, the cost of switches for finite seeds, is untouched. To do: compare 3,5 with 5,3; test the returns 3,5,3 and 5,3,5. | no |
| R5 | 17 Nov 19:55, gptM5 | Period 3: where does a cut 001 ether go after it first departs? | Open, not started. To do: cuts N and N + 12 at one alignment. | no |
| R6 | 17 Nov 19:55, gptM5 | Problem 3: do c(2^k) and c(2^(k+1)) differ infinitely often? | Open, not started. Would exclude every eventual power-of-two period. Pointer: kit `rows_at_powers_of_two`, `row_restart` (M11). | no |
| M8 | 17 Nov 20:07, claudeM5 | Does Theta's reach stay bounded inside the gap language? | Open, not started. Carries the inherited reach thread (L1, placego L1680). Control: the 90/150 hybrid wall. | no |
| M9 | 17 Nov 20:07, claudeM5 | Forbidden gap words and entropy of the gate trap lifted to 20–24 columns | Open, not started. Quint's PR #348 is no longer open (M14): read it or its merged module first. Widens M7 from u ∅ to every right half that enters the trap. A first number (M16): u ∅ uses about 0.07 bits per white step, against 0.256 for the free 3/5 language. | no |
| M10 | 17 Nov 20:07, claudeM5 | A matrix of which exact laws the barrier controls share; counts alone cannot prove Q01 | Open, not started. Supplies the controls for M8 and R2 (M11); M6, which it also served, closed in M21. | no |
| M29 | 18 Nov 11:34, claudeM5 | The maintainer's question on #357: an age f(k) for every number of inverse ticks k, with no cover per k; why the ages grow (8, 24, 80) | In progress. Comes from R2 and S1. Bounds: f(1) = 8, f(2) = 24, f(3) = 31, 59 ≤ f(4) ≤ 72, 73 ≤ f(5) ≤ 78, 104 ≤ f(6) ≤ 108, f(7) ≤ 131, f(8) ≤ 132, f(9) ≤ 144, f(10) ≤ 157, f(11) ≤ 172 (M30–M34, R23–R29, carried); f(k) finite for k ≤ 383 (M35, pending read). M34: f(k) ≤ g(W(k)). R29–R33: joint resets beat one-layer resets (11 vs 9 at 128; a forced 010 at width 91). M35: one-layer resets alone are linear to 4096, coalescence ≤ 65 cells. Next: prove bounded one-layer coalescence in the band's row slices. Draft #357 reply awaits the owner. Bounds are data, not submissions (METHOD §12). | no |

## Recently closed routes

- **R4, source multiplicity and deep-gap density** (closed 18 Nov, R21). The exact count and vacuum-mass identity are PROVED (R19, M27). M28 refuted its proposed spacing with C = 3. R21 shows that time invariance and fixed-depth right-edge data allow positive vacuum mass. Reopen for a quantitative restriction using the single seed’s distant white left tail or another seed-specific bound on deep-source occupancy. The seed’s vacuum mass is open.

- **M6, the floor as the density of the sparsest eternal row** (closed 17 Nov, M21). For G the floor is the
  ether's 1/7 (COMPUTED, M15; known, P1), but no window law carries it (M15). The gap floor has slope about 0.275
  (COMPUTED to H = 180, M20), far below every periodic gap row measured, the least being all-5 at 68/155 (M21). Reopens
  if the minimisers' deficits stay bounded beyond H = 180 (4 at H = 140–180), which by compactness gives an
  aperiodic floor row.
- **M7, CQ01Empty through the kit's bounded-excess criterion** (closed 17 Nov, M16): u ∅ has exponential factor
  complexity (MEASURED). Either it is eventually periodic, and CQ01Empty follows, or p(n) − n ≥ 64,281 from
  n = 150 on (COMPUTED, with Morse–Hedlund). Reopens only with a proof that u ∅ has zero entropy.
- A bounded black frontier for Q01GapCore survivors: the frontier recedes (placego L1673).
