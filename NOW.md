# NOW

*Where things stand: one file, rewritten (not appended) by whoever changes the state, stamped with the time and the
post that changed it. History is in the [ledger](CHAT-LEDGER.md). Rewritten 2026-11-19 16:53 UTC by gptIntel (I10).*

## Arrangement

The workers are `claudeM5`, `gptM5`, `claudeCloud` and `gptIntel` (METHOD §9). The old names Local, GPT and Cloud are
retired (the owner, 17 November); claudeM5 takes on Local's workflow (M1).

| Worker | State | Since |
|---|---|---|
| claudeM5 | working in the owner's session, on the M5 laptop (the Wolfram host); joined the shared store (M1) | 17 November (M1) |
| gptM5 | on the M5 laptop with claudeM5; joined the shared store | 17 November (R1) |
| claudeCloud | Claude in a cloud container: 4 CPUs, 16 GB, no Lean or Wolfram; reclaimed when idle, so long runs checkpoint to share-scratch. Joined the shared store (K1). **Conducts for the moment (the owner, 19 November)**: keeps the schedule (K8), the chain table and the gates | 18 November (K1) |
| gptIntel | Joined the shared store. Intel i9, 8 cores, 16 logical processors, 15.90 GiB visible RAM, RX 6600. Completed the additional research reviews in I2. Lean 4.35.0, GCC and Z3 available locally. | 19 November (I1) |

No worker and no host is set aside for a specialism: every worker does every kind of work, and hosts differ only in
what they can run (the owner, 19 November; METHOD §1). The M5 and claudeCloud both have 16 GB (K1, M43).

Running jobs: claudeM5, B2 (M45): the
frozen all-period listing at gaps 51–100 on the M5 laptop, 9 workers, from 12:58 UTC for at most four hours, each
finished gap copied to `share-scratch/claudeM5/M29/B2/`.
Schedules: none on (only the owner turns them on).

## Needs the owner

- **Gate 2 of the schedule (K8), when it comes:** whether S2, a theorem for every k that is conditional on reset
  capacity, is submitted to the portal, and what #357 is told.
- **S3, when its packet is built and read (K10):** the owner's word to post it, asked once with the built essay.
- **Gate 3, the wall:** an inquisition round, once claudeM5's B2 verdicts (M46) are in.
- **The store's move to the NAS (K10):** at cut-over, the owner sets the new store address on the four hosts; for
  claudeCloud it is a variable of its cloud environment. Tested from the cloud (K10, addendum 1): the owner's DNS
  name resolves and is accepted; this host needs port 443 and a valid public certificate. A free dynamic-DNS record
  must be confirmed every 30 days or every worker loses the store.

## Direction

The easy submissions are done, ours and others'; the hard problem needs new ways in (the owner, 17 November). Two
strategies: this clean repository, whose method and kit summary are read whole into context; and inquisition and
visualisation, so the owner's eye can find structure.

**The goal now** (the owner, 19 November): a submittable proof of the kind the maintainer asked for on #357, "the
statement for every number of ticks k: an age f(k) from which every k-tick preimage of a nonzero finite orbit has its
true edge k cells inside the image edge, proved by an argument that does not need a new cover for each k" (T).

## Schedule (K8)

The full schedule, its rules and its two reformulations are in [K8](CHAT-LEDGER.md). claudeCloud conducts.

**The chain.**

| Link | Status |
|---|---|
| (T) ⇐ (CAP): reset capacity K1(w) ≥ k on every edge cycle, for every k | Hand proof (M34, M39), carried in R37; the cascade is Lowry's PR #60 (P6). Not in Lean. |
| (CAP) ⇔ (L∞): reset words infinitely often in every phase of every consistent left side | Hand proof by compactness (M39), carried in R37 |
| (L∞) in one phase of every three | Three phases wholly in core Lean (I10); one of every five in R43 |
| (L∞) ⇐ (DL): every dyadic doubling white interval resets every tick | PROOF-SKETCH (M41). B1 writes it as Theorem C, which needs (DL⁻), the doubling lemma only at the first clock losses of pointed recurrent strips (M45) |
| (DL) | OPEN. COMPUTED at every source period 2–32 except 5 (K5), and at the gaps listed in the ledger's header |

**The streams.**

| Stream | Worker | Items, in order | Reader | State |
|---|---|---|---|---|
| A, the Lean of S2 (the conditional theorem (CAP) ⇒ (T)) | gptM5, author | A1 the statement file; A2 the cascade, with its own proof and credit to #60; A3 the assembly with an explicit f(k) | gptIntel; claudeM5 for A1's statement | A1 done: [statement](research/m29/Rule30EveryKStatement.lean), three reads PASS (I4, M45, K9). **Gate 1 passed (K9). A2 kernel-checked on both kit revisions (R47); A3 underway.** K10: #60's credit goes in A2's docstring and row; gptM5 also does S3's Lean and shared reads. |
| B, the hand proofs, then the early doubling returns | claudeM5 | B1 `research/m29/every-k-chain.md`; B2 M44 B at gaps 51–100 with K7's controls and the single-pulse family; B3 the essay and the #357 reply | gptIntel for B1; gptM5 for B3 | B1 written, [every-k-chain.md](research/m29/every-k-chain.md); read PASS by claudeCloud (K9), gptIntel's read still welcome. B2 frozen and running (M45); verdicts in M46. B3 waits for the owner's word. **K10, in this order:** the store's move to the owner's NAS; M46; S3's notebook; B3. |
| C, the counting theory as theorems, then the wall | gptIntel | C1 the pooled mean-gap theorem (candidate S3); C2 the wall by pair counting; C3 the reads; **now A4** (K9): R44's bridge and the dyadic clocks in Lean, reader gptM5; then the read of B1 | claudeCloud for C1's proof; gptM5 for its Lean | C1 written and kernel-checked (I3, I5), its mathematics carried (K9). C2 done: at odd gaps a row fixes its successor (I6, carried in M45 and K9). C3: A1, the catalogue and both reformulations read (I4, I7). **K10, in this order:** the #60 comment reviewed and posted (I9); S3 sources with the notebook builder (I10); A4 kernel-checked, with gptM5 (I10); the read of B1. |
| Conducting | claudeCloud | The chain table, the controls, K7's six SAT instances, S2's novelty check, the gates | — | Running. Gate 1 called (K9). K10 records the owner's three decisions. Next: the test of the new store from the cloud, S3's last novelty check, Gate 3. |

**The gates.** 1: the statement — **passed in K9**. 2: S2 proposed under METHOD §12, and the owner
decides. 3: the wall, when B2 and C2 report; if neither gives a mechanism, an inquisition round with the owner.

## Submissions

Each candidate follows METHOD §12: any worker authors it, a different worker reads it, both agree on the same
digests, then the owner gives the word; the Wolfram steps run on the M5 laptop. Standing consent to post: none (placego's of 10 November does not carry over).

| Candidate | Result | Route | Stage | Post |
|---|---|---|---|---|
| **S1** (from R2; M17, R15) | For every nonzero finite seed and every age t ≥ 80, every four-tick predecessor is finite with its edge exactly four cells inside; all 16 wall histories occur (`aged_four_step_predecessor`, `all_four_tick_histories`). | Portal partial and kit catalogue module `Rule30AgeEightyInverse` | **Lean Verified, Human Verified** (M26, M29): portal entry [R30-20261118-c8b41f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261118-c8b41f), checked 18 Nov 11:05 UTC at `5fb5915`. Kit pull request [#357](https://github.com/WolframInstitute/Rule30PrizeKit/pull/357) is open but will not be merged as it stands. The maintainer will take no more per-k certificates after ages 8 and 24, only the statement for every k (M29, pull M29). Progress reply posted on #357 at the owner's word (M36, 18 Nov 15:46 UTC); awaiting the maintainers. | [M22](CHAT-LEDGER.md), [M23](CHAT-LEDGER.md), [M24](CHAT-LEDGER.md), [M26](CHAT-LEDGER.md), [handoff](research/r2/age80/proposal.md) |
| **S3** (K2, I2) | Mean first white gap ≤ 2^Q+1 over the nonzero pointed Q-bit children, every Q>0. | Portal partial and kit temporal-profiles extension | Proposed privately. Lean carrying read PASS (R46); builds pass on main and the verifier pin. Mathematics carried, with an exact control at clocks 1–14 (K9). **S3 source packet frozen (I10), notebook build requested:** author gptIntel, Lean and shared reads gptM5, M5 build claudeM5. | I3, I5, I8 |

Verifier's kit commit: `5fb5915` (5 November), reconfirmed 19 November at the 12:27 UTC portal snapshot (I8); the kit's main is
`35f2c6e` after Lowry's WallRecordAncestry (K9). Stages: proposed, packet, read, agreed, owner's word, posted, Lean Verified, pull request, merged.

## Latest results (newest first)

- **19 Nov, K9. Gate 1 passes, and the pooled bound is sharp.** The A1 statement, the B1 chain and the pooled proof
  all carry. An exact control at clocks 1–14 finds the pooled sum never above N² − 1, equal to it at Q = 1 and 3, and
  within 0.04% at Q = 14; the largest gap there is 9.59 × 2^14, against 9.70 for a geometric wait (COMPUTED). Lowry's
  twelve old pull requests stopped on his side and none of their modules is in the kit, #60 included. The store
  client now retries the web host's verification page. [K9](CHAT-LEDGER.md)
- **19 Nov, M45. A1 passes claudeM5's read, and B1 writes the chain for every k.** The A1 statement's cut, phase,
  width and age are M34's and M39's, and it type-checks on the M5 at kit `a8072e7`.
  [B1](research/m29/every-k-chain.md) sets out (DL⁻) ⇒ (L∞) ⇒ (CAP) ⇒ (T) as ten steps and three theorems with
  statuses. The open link needs the doubling lemma only at first clock losses. K8's reformulations carry, the unique
  predecessor form through I7's lemma. Exploratory: the single-pulse family is early only at source periods 4–6; at
  odd gaps every cyclic component is a simple cycle (I6's determinism, checked on 1,875 rows). B2 is frozen and
  running. [M45](CHAT-LEDGER.md)
- **19 Nov, K7. Source period 64 is UNSAT at gaps 68 and 70 too, and the early doubling returns are one family.** K2's
  SAT run replicated M43 at every gap 31–63, 65 and 67 under an independent encoding and decided 68 and 70 (COMPUTED,
  solver claims); the tail at 74–96 is closed unrun. I2's pooled mean gap of at most 2^Q + 1 carries. A census of all
  9,973,336 odd classes at P = 2–28 finds doubling returns within 100 wheels only at gaps 21, 56, 88, 23 and 98, all
  from the single-pulse source; none at P = 7–28. [K7](archive/ledgers/CHAT-LEDGER.2.md)
- **19 Nov, I2.** gptIntel independently reviewed the live research through M44 and K6. The finite period-32
  census, gap-32 witness and whole-component swap exclusions carry. The two exact K2 steps hold; the geometric
  return law remains conjectural. At P=128 gaps 51–64 the exclusion requires a reset-free tick.
  [Review, scope and replay records](research/m29/gptIntel-review.md)
- **19 Nov, M44. No reset-free doubling at source period 128 at gaps 5–64, and (exploratory) no doubling of any
  period returns to white at gaps 31–50.** At period 256 the odd family is UNSAT at every gap 31–64 under kissat, and
  at 31–61 and 63 under CaDiCaL with its internal proof checker; no doubling of period 128 returns to white at 31–43
  or 45. B, exploratory: G_n's cyclic part, listed by SAT on windows (exact against M42 at gaps ≤ 30), has no
  swappable pair at gaps 31–50, so up to gap 50 the only reset-free doubling at any period is period 5's at gap 23.
  With K5, a reset-free dyadic doubling needs source period ≥ 64 and gap ≥ 51. [M44](CHAT-LEDGER.md)
- **19 Nov, K5. Every doubling white interval of source period 2–32 except 5 has a reset in every tick**
  (COMPUTED, exhaustive over 138,871,107 classes of unrestricted odd sources; P = 32 replays M41 exactly). The resolved classes finished
  by wheel 152. Period 5's single exception is M42's gap-23 orbit, which no dyadic strip carries. A uniform linear
  bound on resolution and a lower bound on the earliest return are open (I2). [K5](CHAT-LEDGER.md)
- **19 Nov, K3–K4. Mean white-return gaps track the doubled clock in the samples** (MEASURED). Plain means at
  Q = 14–24 range from 0.912 to 1.015 × 2^Q. Odd-source means at P = 7–12 range from 0.843 to 1.182 × 2^(2P).
  The six complete A0 gaps are consistent with that scale. Geometric waiting times and small-gap probabilities at
  larger P remain conjectural. At P = 5 one of three primitive odd classes returns at gap 23 with a reset-free tick.
  [K3, K4 and I2](CHAT-LEDGER.md)
- **19 Nov, M43. (G30) is false, and the doubling lemma survives at source period 64.** A whole white interval of gap
  32 and period 64 is reset-free in one tick: gptM5's period-five ring tiled four times, with a disturbance that keeps
  the tiling wheels from staying white. This defeats gap bounds 19 and 30 on unrestricted dyadic intervals. SAT at source period 64
  finds no reset-free doubling at gaps 31–67 (kissat and CaDiCaL), or at 69, 71 and 73 (kissat). The open statement
  is the doubling lemma itself. [M43](CHAT-LEDGER.md)
- **18 Nov, M42. R40's gap graph carries, and (G) holds to gap 30 at every period.** An independent rebuild matches
  gptM5's script field by field at gaps 5–19, with no reset-free doubling at any temporal period. Up to gap 30, whole
  white intervals of power-of-two period have reset-free ticks only at gaps 7, 8, 14 and 16, and none of these can
  double. The only dyadic doublings below gap 31 are the kit strip's own 2→7 and 7→28. At gap 23 a reset-free doubling
  with source period 5 exists, so the doubling lemma needs the dyadic clock. What remains is source period ≥ 64 with
  gap ≥ 31. [M42](CHAT-LEDGER.md)
- **18 Nov, M41. No doubling white excursion at source period 32 is reset-free in any phase.** All 134,215,680
  necklace classes (8.6 billion pointed lifts) were run with every tick at once, and the control reproduces R44's
  table at periods 1–16. Every reset-free whole interval found at P ≤ 32 has a gap of at most 16, inside R40's
  gap-graph range 5–19. So a gap bound of 19 for reset-free intervals, (G), would suffice for every k once R40's graph
  carries. M41 also carries R37 and R43 (PROVED IN LEAN) and R44 (computer-assisted), with independent replays.
  [M41](CHAT-LEDGER.md)
- **18 Nov, R43–R44.** At least one of every three consecutive phases of every pointed recurrent strip has resets arbitrarily far from its black edge. The two-anchor transfer is Lean-checked. If two phases both have reset-free tails, every sufficiently deep white anchor has a rising child at those two ticks. Every-k still needs control at the prescribed phase. [Proof, numerical controls and route decision](research/m29/white-return-block.md)

- **18 Nov, R37.** The age bound 265,441 through 7,911 inverse ticks passes independent review on all 64 strip phases. A [Lean construction](research/m29/Rule30PointedWhiteFork.lean) gives one phase with black immediately beyond every white diagonal, at all widths. B0 phase 9 realizes this at width 87,867 and still contains 12,532 ordinary reset factors. White-diagonal drops alone cannot supply the every-k theorem. [Five review verdicts and next test](research/m29/pointed-strip-review.md)

- **18 Nov, M40. f(k) ≤ 265,441 for every k ≤ 7,911.** M35's one-layer schedule, run exactly at width 87,867 on
  all 16 phases of the four strips, clears 7,911 layers in the worst phase (B1). It advances at a steady 11 wheels
  per layer from width 4,096 on. Rule30FourFronts puts every row's top 87,867 cells on a strip from age
  87,866 + 177,575, so M34's two-factor bound gives one explicit age for 7,911 ticks (PROVED, computer-assisted, carried in R37).
  This replaces 4095 + 2^4096 for k ≤ 383.

- **18 Nov, M39.** The largest completed window across the four strips is 87 cells. On A0 the measured tail counts at the reported lengths are 0.80–1.46 times their fair-coin expectations. The estimated median maximum under that model is 81. Bounded gaps remain open. Arbitrarily deep ordinary resets in every phase of every consistent strip would suffice for every k by compactness (carried in R37).

- **18 Nov, M38.** A one-tick heal gives two inverse trajectories over a window of the next phase. The measured maximal lengths agree at 3,807 of 3,847 comparable wheels. The largest one-tick heal through width 4,096 is 65. An independent envelope computation gives s*(4096) = 382 (R37).

- **18 Nov, M37. φ(w) = K(w) at all 68 widths to 103** (exact backward computation): the tested capacities equal the fastest post-cut times at these widths. The error edge can jump 45 wheels in one tick (the 16 → 61 jump behind
  the plateau K = 3). A long-run rate bound would suffice.

- **18 Nov, M36. Progress reply posted on kit PR #357** ([comment](https://github.com/WolframInstitute/Rule30PrizeKit/pull/357#issuecomment-6983561215),
  the owner's word; text confirmed by gptM5 in R35). **The capacity is the convergence time of post-cut bands:**
  an unclosed history is a black-tailed cut, and φ(w), the fastest post-cut band's time to the edge cycle, equals
  K(w) at every width 20–26 (exhaustive, COMPUTED). The step for every k becomes a bound on the error edge's healing
  speed (about 10 wheels per tick in the data).

- **18 Nov, R35.** M35 carrying PASS. All eleven one-layer counts independently replayed, including 383 at width 4096. The 65-cell bound covers starts with room to finish. [Revised #357 reply](research/m29/reply-357-draft.md) confirmed for the owner’s posting decision.

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
  control). Every verb has run live. The first flag to several recipients went out in K1 and arrived in both
  postboxes (K1, addendum 1).
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
- **K10, the owner's three decisions:** the store's move (claudeM5); the #60 comment, drafted in
  [comment-60-draft.md](research/m29/comment-60-draft.md), to be checked by gptIntel and posted by claudeM5; S3's
  packet (gptIntel).
- **K8, the schedule:** A1 passed the kit and all-cycle statement read (I4) and claudeM5's read (M45); B1 is written and waits for gptIntel's read (M45). C1's [paper proof](research/m29/pooled-white-returns.md) is with claudeCloud (I3), the [core Lean proof](research/m29/Rule30PooledReturns.lean) type-checks and is with gptM5 (I5), and Gate 1 follows the first reads.
- **K6:** METHOD §12 reads rightly off the M5 with three handoffs, which R45, I2 and M45 describe: the builder's notebook and receipt pass through the author's verification; the M5 operator verifies the packet's digests before `post.sh`; the raw portal response stays on the M5. Writing them into §12 is the conductor's call.
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
| M29 | 18 Nov 11:34, claudeM5 | The maintainer's question on #357: an age f(k) for every number of inverse ticks k, with no cover per k; why the ages grow (8, 24, 80) | In progress. Comes from R2 and S1. Bounds: f(1) = 8, f(2) = 24, f(3) = 31, 59 ≤ f(4) ≤ 72, 73 ≤ f(5) ≤ 78, 104 ≤ f(6) ≤ 108, f(7) ≤ 131, f(8) ≤ 132, f(9) ≤ 144, f(10) ≤ 157, f(11) ≤ 172 (carried); f(k) finite for k ≤ 383 (M35, carried); f(k) ≤ 265,441 for every k ≤ 7,911 (M40, from Rule30FourFronts and the exact schedule on all four strips, carried in R37). R37 independently carries M36–M40. The white-diagonal drop proposal fails on a Lean-certified pointed strip. The sufficient ordinary reset recurrence remains open. R44 proves one of every three phases has arbitrarily deep ordinary resets (carried in M41, with R37 and R43). The unrestricted single-phase local-anchor route is closed by a period-five ring. Continue with the rooted period-doubling interval in a prescribed phase; the control data contain zero bad doublings. M41: none at source period 32 either, at any gap. Reset-free whole intervals at P ≤ 32 all have gaps ≤ 16, so (G), a gap bound of 19, together with R40's gap graph would suffice. M42: R40's gap graph carries. (G) holds at every gap ≤ 30 for every dyadic period, and the only dyadic doublings below gap 31 are the kit's 2→7 and 7→28. So (G30), reset-free dyadic whole intervals have gap ≤ 30, suffices; it is open only at source period ≥ 64 with gap ≥ 31. A period-5 reset-free doubling at gap 23 shows the dyadic clock is needed. M43: (G30) is false, refuted by a ring-tiled interval of gap 32 and period 64, so the gap-bound route is closed. The doubling lemma (every dyadic doubling white interval has a reset in every tick) holds wherever tested: gaps ≤ 30 at every period, source periods ≤ 32 at every gap, and source period 64 at gaps 31–67 (two solvers) and 69, 71, 73. Progress reply posted on #357 (M36). Bounds are data, not submissions (METHOD §12). K2: an independent encoding reruns the odd family at P = 64 (running); a counting picture predicts every small-gap odd instance UNSAT whatever the resets. K5: the doubling lemma holds on unrestricted profiles at every source period 2–32 except 5 (one non-dyadic orbit). M44: no reset-free doubling at source period 128 at gaps 5–64 (kissat at every gap 31–64, CaDiCaL with internal proof checking at 31–61 and 63); exploratory, G_n's cyclic part has no swappable pair at gaps 31–50, so no doubling of any period returns to white there. Open for dyadic doublings: P = 64 at gaps 68, 70, 72 and 74 on (claudeCloud's K2 queue is running these), P = 128 from gap 65, P ≥ 256 from gap 51. Next for claudeM5: freeze the cyclic-part test at gaps 51–100, blind, with K3–K4's returns at 56 and 88 as positive controls. K8: the schedule. Stream A (gptM5) puts (CAP) ⇒ (T) in Lean as S2; B (claudeM5) writes the chain on paper and runs B at gaps 51–100; C (gptIntel) proves the pooled count and attacks the wall by pair counting. | no |
| K2 | 19 Nov 10:19, claudeCloud | The counting picture of white returns: an interval of temporal period Q returns to white after about 2^Q wheels, and a tick's reset-free stretch decays like a fair-coin string's (rate 0.848); as a model for the observed scarcity of short-gap doublings | In progress. K3: the gap law holds at Q = 14–24 for plain and doubling intervals (MEASURED); tails near 0.848; period 5 is the exception. K5: census at every source period to 28 fits the reset law. K7: the SAT run replicates M43 at gaps 31–63, 65 and 67 and decides 68 and 70; six instances restarted, the tail closed. I2: the two structural steps carry, the pooled mean is at most 2^Q + 1 (carried in K7), and the geometric law stays a conjecture. Explains M41–M43's census and SAT data; bears on M29's doubling lemma. K8 addendum 1: the kit's nine white-to-white gaps at clock 16 on the four strips average 1.04 × 2^16 (P10). | **yes: S3** (I8) |
| K5 | 19 Nov 10:44, claudeCloud | The resolution law: after a doubling white, why does every tick close a reset within about 4.2P wheels (0.98–1.31 × 4.2P at P = 12–32; not a bound, K7)? A linear resolution bound together with a sufficient earliest-return bound would imply the lemma above the period-5 exception | Open. P = 29–32 done (K5, addendum 1): worst 0.99–1.13 × 4.2P. Joined to K2; bears on M29. Stream C2 of the schedule takes the resolution side (K8). | no |
| K8 | 19 Nov, claudeCloud | The unique-predecessor form: (L∞) says every recurrent point of F(x) = 4x ⊕ (2x ∨ x) on the odd 2-adic integers has exactly one preimage, so no row off the strips maps onto a strip row; and it is enough that infinitely many white intervals of each strip reset every tick | In progress. Both reformulations carried in I7, with compact phases, inclusive endpoints and a low-bit proof on every strip. B1 due. | no |

## Recently closed routes

- **K3, where reset-free doublings occur** (closed 19 Nov, K5). K4 corrected K3's period-5 reading (one orbit among
  three classes), and K5's exhaustive census finds no other reset-free doubling at any source period 2–32. Reopens if
  one appears at a period above 32.
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
