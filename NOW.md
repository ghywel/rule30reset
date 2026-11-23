# NOW

*Where things stand: one file, rewritten (not appended) by whoever changes the state, stamped with the time and the
post that changed it. History is in the [ledger](CHAT-LEDGER.md). Reset at the owner's word on 20 November 2026 (K33);
the file as it stood is [archive/now/now-before-reset-2026-11-20.md](archive/now/now-before-reset-2026-11-20.md).
Updated 2026-11-23 10:53 UTC by gptIntel (I151, Path 4 family criterion and 77-cell proof).*

## Arrangement

| Worker | Host | Since |
|---|---|---|
| claudeM5 | the owner's M5 laptop, the Wolfram host, in the owner's session | 17 November (M1) |
| gptM5 | the M5 laptop, with claudeM5 | 17 November (R1) |
| claudeCloud | a cloud container; reclaimed when idle, and its background runs are stopped at two hours, so its long runs go to gptIntel (the owner, 22 November). Lean 4.35.0 per session since K67. **Conducts for the moment** (the owner, 19 November) | 18 November (K1) |
| gptIntel | the Intel i9 with the RX 6600, running Windows and Ubuntu on WSL 2 (I43) | 19 November (I1) |
| claudeIntel | the Intel i9, with gptIntel, in the owner's Claude app; its own store token | 22 November (N1) |

No worker and no host has a specialism (METHOD §1). What each host can run is in [TOOLS.md](TOOLS.md).

- **Running jobs:**
  - On the Intel: the K65 sieve and all 23 onset certificates finished at 09:19 UTC (I140, I142).
  - On the cloud host: K65’s long solver work transferred to the Intel. K66 is the ether-lock probe.
  - On the M5 (claudeM5): nothing. M80's last instance, 5⁵ at P = 100, finished SAT after 27 hours (M106).
- **Schedules:** none. gptIntel's overnight heartbeat is off (the owner, 22 November).
- **The store:** on the owner's NAS, image `981c5eb`. Its image workflow runs on a change under `tools/store/` and
  once a week (M52).

## Needs the owner

Calls to action only.

- **S9, the density polygon.** The [original entry](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-b2be99) is **Lean Verified** and **Human Verified**. The lighter notebook passed its read (M119, R88) but is not posted: the owner, 23 November, "the lighter version is probably not required now" (M120), and the author agrees (K71 addendum 3). Kit PR #402 links the verified original and is MERGEABLE; its body carries K71's sentence correction (M121).
- **M9 as S10, the trapped-gate exclusions,** is posted at the owner's word as [R30-20261123-71bab6](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-71bab6), **Lean Verified**, with kit PR [#403](https://github.com/WolframInstitute/Rule30PrizeKit/pull/403); kit issue #380 is **closed** as resolved independently (M123). Nothing is needed from you.
- **The kit repairs** in [KIT-REPAIR.md](KIT-REPAIR.md). The owner's word, 22 November: "Open repair 1, start
  preparing repair 3, open repair 2 when ready" (M101).
  - Repair 1 (8e6bd3) is **merged** as kit commit `a4b4aff` (#391), with the maintainer's review change (M107).
  - Repair 2 (803bc4) is **merged** as kit commit `cef7356` (#392).
  - Repair 3 (8d7751, `Rule30EtherFamilies`) is **merged** as kit commit `dd2a220` (#394).
  - Kit issue #386 asks the maintainers about the other portal-only entries; no reply yet.
  - Steps 3 and 5 are **merged**: `Rule30ClockNearSquares` (`49b99cc`, #395) and `Rule30SettledRepeats` (`cf60d48`, #396).
  - Step 4 (`Rule30Rule210Clock`) is in kit main at `127ebed`. The maintainer applied the reviewed module and closed [#397](https://github.com/WolframInstitute/Rule30PrizeKit/pull/397) (I130).

## Direction

- **The goal** (the owner, 19 November): a submittable proof of the statement the maintainer asked for on #357, "the
  statement for every number of ticks k: an age f(k) from which every k-tick preimage of a nonzero finite orbit has
  its true edge k cells inside the image edge, proved by an argument that does not need a new cover for each k" (T).
- **Where it stands:** (T) is machine-checked, posted and in the kit from one open lemma, (DL⁻₁). The lemma is the
  wall, no proof idea for it is in hand, and the main line is **parked there** (the owner, 21 November).
- **Now** (the owner, 21 November): the first round on the old pulls is done (K48), and warm pulls are short. New
  pulls are to be derived from KIT.md and KIT-INDEX.md read whole, with key attention to recent third-party
  submissions, "which we might be able to spring board off towards the next general proof".
- **Standing** (the owner, 17 November): the easy submissions are done, ours and others'; the hard problem needs new
  ways in. Two strategies: this clean repository, read whole into context; and inquisition and visualisation, so
  that the owner's eye can find structure.

## The chain

Each row is one link of (T). The statements and proofs are in
[every-k-chain.md](research/m29/every-k-chain.md); the posts are in the ledger's header.

| Link | Status |
|---|---|
| (T) ⇐ (CAP): some width has reset capacity k, for every k | In Lean and in the kit: **S2**. Without the wall, for every configuration with a leftmost black cell, proved in Lean and independently read (M89, R74). |
| (CAP) ⇐ (L∞): reset words at arbitrarily large depths in every phase of every pointed recurrent strip | In Lean: **S4**, Lean Verified, and in the kit since `05c9c73` (#375; M75). |
| (L∞) ⇐ (DL⁻₁): a tick that the doubled stretch after a first clock loss misses is caught in the next stretch | In Lean: **S5**, Lean Verified. In the kit since `40017e8` ([#377](https://github.com/WolframInstitute/Rule30PrizeKit/pull/377), I44). |
| (DL⁻₁) | **OPEN: the wall.** Its strict form is COMPUTED for every source of dyadic period up to 32 (K5); for five black or five white marks at every dyadic period (I32, R59); for quiet sources at every period (K18, I20); and at every first clock loss on every rooted strip through clock 16 (K27). Nothing is settled from seven marks on, and the mark-count line is closed (I35). A counterexample needs a dyadic source period of at least 64. |

## The next block

**Under way.**
- **The kit repairs** (the owner, with claudeM5; [KIT-REPAIR.md](KIT-REPAIR.md)). Steps 1–6 are in kit main
  following #397 (I130). Step 7's three entries need separate treatment (N3).
- **gptIntel:** Path 4’s [family checker and 77-cell example](research/k50_1/path4/README.md) are in Lean beside Lowry’s #378. claudeM5 has the independent read of the five-headline portal-pin packet (I148, I151).
- **claudeCloud:** Agreed to the original S9 packet and kit patch in K71. The conditions for the lighter S9 packet passed in [R88’s second read](research/source-density/s9-release-review.md#r88-second-read-of-the-lighter-notebook).
- **claudeIntel:** I123 carried (N7). I127 answers the metric question posed after the scale test and P49.

**Done since K64.** S6 is posted, Lean Verified and Human Verified, and in the kit at `54d030c` (M93, I108). It came
from pull K50.3 (K61, K63, M88, M89, R74).

**S7.** gptIntel’s relay is posted as [R30-20261122-a963b5](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-a963b5), Lean Verified, and in the kit as `Rule30PulseRelay`, merged as kit commit `98cdf71` (#393). The other paths and a Lean reader for path 2 remain with the owner.
gptIntel's results are in five pulls (I49, I66, I72, I77, I93). Read so far: path 1
in full (K64 addendum 2, M95); the finite parts of paths 2 and 3 (K64 addenda 3 and 4); I67 and I69 (K56 addendum
1, K58).

Last posts: claudeM5 M123, gptM5 R90, claudeCloud K72, gptIntel I151 and claudeIntel N9. Kit issue
[#380](https://github.com/WolframInstitute/Rule30PrizeKit/issues/380) asks how a law with a certified CNF hypothesis
can enter the kit (M86). It is **closed** as resolved independently, with a comment linking S10 and PR #403 (M123). Kit issue
[#386](https://github.com/WolframInstitute/Rule30PrizeKit/issues/386) reports the portal and kit consistency check
(M98).

## Submissions

METHOD §12: any worker authors, a different worker reads, both agree on the same digests, the owner gives the word;
the Wolfram steps run on the M5. Standing consent to post: none.

| | Result | Portal | Kit |
|---|---|---|---|
| **S1** | From age 80, every four-tick predecessor of a nonzero finite seed is finite, with its edge four cells inside. | [R30-20261118-c8b41f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261118-c8b41f), Human Verified | not taken: the maintainers want every k (M29) |
| **S2** | (CAP) gives, for every k, an explicit age for the k-tick statement. | [R30-20261119-ccc65f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-ccc65f), Human Verified | in the kit (M61) |
| **S3** | The mean first white gap is at most 2^Q + 1 over the nonzero Q-bit first children. | [R30-20261119-5896c2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-5896c2), Human Verified | in the kit (K15) |
| **S4** | (L∞) gives (CAP), and so every k. | [R30-20261120-eb2bcc](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261120-eb2bcc), Lean Verified (M66) | in the kit: main `05c9c73`, from #375 (M75) |
| **S5** | (DL⁻₁) gives (L∞), and so every k. | [R30-20261120-8dc0b3](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261120-8dc0b3), Lean Verified (M72) | in the kit at `40017e8` from [#377](https://github.com/WolframInstitute/Rule30PrizeKit/pull/377) (I44) |
| **S6** | Without the wall: for every configuration with a leftmost black cell, Hughes's ages 8 (sharp) and 24, and from (CAP) every k. | **posted** as [R30-20261122-7c7bad](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-7c7bad) (M93), on manifest `374b8d2d…`: **Lean Verified, Human Verified**. **Merged** in [#385](https://github.com/WolframInstitute/Rule30PrizeKit/pull/385) at `54d030c` (I108). The portal lists both kit modules. [Release and final PR review](research/k50_3/s6-release-review.md) | route: two catalogue modules, `Rule30TwoSidedInverse` and `Rule30EveryKLine` |
| **S7** | The sharp loss of seven ticks at a moving white endpoint, and both quarter-period exclusions at every site of a row with a leftmost black cell. | Proposed in R79 from I93/I103. Finite replay K64 and Lean read M95 passed. **Packet ready** (R80). Portal manifest `d6977083…`, kit patch `4137eecb…`. **Posted** at the owner's word as [R30-20261122-a963b5](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-a963b5), **Lean Verified** at `5fb5915` (M103). | **In the kit** as `Rule30PulseRelay`, kit commit `98cdf71` (#393). Norris has priority for singleton 7/11. |
| **S8** | Every periodic sparse column (isolated pulses, gaps of at least 9) at any site of a row with a leftmost black cell contains the gaps 12, 10, 9; the ten three-gap reset words as support. | **Posted** as [R30-20261122-f1c87a](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-f1c87a), **Lean Verified** at `5fb5915` (M112) | **Merged** as `Rule30RequiredGapFactor` and `Rule30ThreeGapCapture`, kit `33b19c8` ([#398](https://github.com/WolframInstitute/Rule30PrizeKit/pull/398)). |
| **S9** | Three sharp inequalities and five periodic corners classify uniform linear bounds on black and run-end counts. From any right half, one history realizes each prescribed rational point. On the single seed two corner deficits grow at least logarithmically. | **Release read PASS** (R87) on M115’s notebook `e11a6626…`, pins `0ee1c461…`. All thirteen modules carried (K67, I124, I126, I139). Eleven headlines and 731 constants replayed at the live verifier pin. **Posted** at the owner's word as [R30-20261123-b2be99](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-b2be99) (M118). **Lean Verified** at 09:59:45 UTC, and **Human Verified**. Not superseded (M120). M119’s lighter notebook `f937d378…`, pins `3d170e73…`, also passed [R88’s second read](research/source-density/s9-release-review.md#r88-second-read-of-the-lighter-notebook). | Reviewed patch `0d431282…` on `ac88b68`, four rows and PR text in [R87’s read](research/source-density/s9-release-review.md). Full catalogue builds. All 52 headlines pass. **Kit PR [#402](https://github.com/WolframInstitute/Rule30PrizeKit/pull/402)** at `62a03b7`, the rows filled (M118). |
| **S10** | In the trapped gate, four closed runs of four 5-gaps are excluded from delay two, sharply. Five blocks are excluded from entry. On the kit ladder the four-run threshold is exactly width 45. | **Release read PASS on R89’s revised packet.** Notebook `8eb18b7a…`, pins `7480a662…`, Problem 1 partial. Four physical headlines, 244 constants at `5fb5915`. Author agreement (I149). **Posted** as [R30-20261123-71bab6](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-71bab6), **Lean Verified** (M123). | Kit PR [#403](https://github.com/WolframInstitute/Rule30PrizeKit/pull/403) at `4e041ce` on `60799e8` (M123). Full catalogue builds and all 12 headlines pass. [Reviewed PR text and receipts](research/m9/compact/s10-release-review.md). |

The portal verifier is at `5fb5915`. The shared catalogue is in step with kit main at `ac88b68` (K69 addendum 4).

## Pulls in progress

One row per pull; its full text is the ledger post named in the first column, in the live ledger or its archives.
Status begins with *open*, **preliminary** (one first block run) or *in progress*, and says the next test. A
parked or closed pull leaves the table for the lists below. The rules are in METHOD §8.

| Pull | Written | Summary | Status | Submission? |
|---|---|---|---|---|
| K5 | 19 Nov, claudeCloud | The resolution law: how the last catch depends on source period P | **In progress** (K29, read in R61). The first-excursion census agrees closely with the fair-input model. Its measured tail is about 1.36 κ^x, κ ≈ 0.847810. A uniform bound remains open. Next test: compare the trace restricted to doubled inputs with the census before using the mixing rate for a pooled bound. Carries K2’s conjecture on white returns. | no |
| R5 | 17 Nov, gptM5 | Period 3: where does a cut 001 ether go after it first departs? | **Preliminary** (K35, K38). Every cut to N = 240 ends in the same 21-tick cycle on columns 1–24, never in the 15-trap. Departure advances 30 ticks for each 12 columns. The wait from departure behaves like chance, mean 20,900 ticks, and cuts N and N + 12 share no later history. Cool. Next tests: is the wait the same from random strips, and can the 15-trap be entered from outside? | no |
| M9 | 17 Nov, claudeM5 | The late gate language under an alternating centre, inside and outside the trap | **In progress** (K47, M79, M81, M85, K54, K56; outside: K52, [R69](research/m9/exterior-grammars.md)). Inside, the gate settles within 50 samples of entry to a fixed, structured process and stays there to 10^7 ticks (K56). Its laws are read by SAT, each certified by LRAT: at most three closed runs of four, and four never after two samples (M81; in Lean from one CNF, M85, [read](research/m9/runs-of-four-review.md) in R71); 19 of the 81 quadruples over runs 4–6 by delay 20 (K54, I65); the pair (5, 1) from delay 12, (3, 1, 4) from 9, (10, 1, 5) from 20 and (5, 5, 5, 6) from 39 (K56, I66, I75). The column ladder misses the short ones: (5, 1) needs 37 columns (I70). No rule behind the table yet. Absence from real rows is not a law: (11, 1) never occurs and is SAT at delay 80, and five runs of five, never seen in real rows, are SAT after 60 and 100 samples in the trap (M85, M106). The Intel's width-36 automaton stopped at its 400,000-state cap: entropy undecided (I106). On Lowry's #379: an all-length repeat bound for the trapped 3/5 clock, 17n ≤ 20j + 2m + 4t₀ + 6 (I53, Lean), and the 4/3 complexity obstruction for any excursion reading (I51, on paper). Outside, X and Y have their grammars to 43 columns; an aperiodic exterior spacing is excluded (I48, Lean). The [final K65 sieve](research/m9/data/gptIntel-sieve-final-K65.txt) has 23 exact onsets and 67 survivors through delay 40 or higher. All 18 newly judged laws contain a run of 1. Both proof checkers passed all 23 first forbidden delays (I142). The open mathematical question is why a lone 1 forces exclusion, starting with (5,1). M114 carried the four physical laws and the ladder from width 46. I143's shared-prefix certificate builds in 47.5 s at the verifier pin, and in 15.3 s on the M5; its scoped read passes (M117). | no |
| M10 | 17 Nov, claudeM5 | Which exact laws distinguish Rule 30 from controls with an immortal finite row? | **In progress** as a standing instrument (K44, R63, M77). The [matrix](research/m10/control-laws.md) gives the spatial reset and first-check degree for every width. The hybrid has a sharp tick-2 reset and degree 1. Planting changes only the top monomial from n=L onward (PROVED: Lean, read in M77). Next use: compare the hypotheses of the next Q01 proof route against these controls. | no |
| K50.1 | 21 Nov, claudeCloud | RD: does every finite right half end in the gate trap or in a periodic gate? | **Preliminary** ([R65](research/k50_1/right-dichotomy.md), K52, [R69](research/m9/exterior-grammars.md)). Proved for every ether cut (I46 read) and computed through support width 26. A counterexample needs one finite right half sustaining an aperiodic gate in X or Y. The finite-window grammars now constrain that realization question. gptIntel's seven-lock prefix work has its own row, I49. The periodic side (K66, COMPUTED): the period-2 lock is one set, the kit's 53 ether-and-wall windows of 19 columns, entered at two alignments; 31 is the least right half that never enters the gate trap; 23, 20 and 24 cells of the seeds 31, 495 and 175 force it exactly; the shortest forcing prefixes have 14 cells. Our portal entry 8d7751 has two of its families and is not in the kit: KIT-REPAIR step 6. | no; a kit repair (K66) |
| K50.2 | 21 Nov, claudeCloud | Lowry's events (`Rule30EventReturns`), read in gate coordinates | **Preliminary** ([R67](research/k50_2/event-returns.md)). The trapped event code is invertible at every width. Physical gates exclude 5, two or more 2s, 5. I46 checked the exclusion in Lean and exhibited a finite GE2 trace with 5,2,2,5. Next test: tighten the GE2 finite-left survivor check with this exclusion. Feeds M9. | no |
| I49 | 21 Nov, gptIntel | Which finite right prefixes force Lowry’s seven-lock for every completion? | **Path 4 active.** [Exact finite tree criterion and comparison with #378](research/k50_1/path4/README.md). An 11-leaf tree needs 77 of Lowry’s 80 cells. The physical minimum is 64 contiguous or 63 chosen cells (I63–I68, kernel). Each matching singleton age A has a centre-break deadline. Arbitrarily late black-centre occurrences remain open. The I52 packet is on independent read. | Beside Lowry’s #378 (K64, I148–I151). |
| I66 | 21 Nov, gptIntel | Lowry's source arrivals under periodic centres, and source priority | *In progress* (I66–I69, I71, I73; `research/arrivals/`). Kernel: arrival parity aperiodic for a wider family of periodic centres (I66). Under an eventually alternating centre, arrival parity and the distance-two shell are both aperiodic (I67–I68, finite part read in K56 addendum 1), with a finite form 2n < 3b + 16 (I73). Seven rightmost readings recover a four-cell band; four letters are optimal (I69, read in K58; I71). Lean unread. | no |
| I72 | 22 Nov, gptIntel | Which densities of black cells and spatial run ends one site can show | **Read in Lean** (K67, I124, I126, I139), including one history for every rational point from a prescribed right half. Builds on Condrey, Ulrey, Quint and Gemini (P31, P48). The width-155 minimum is computed (K64). The one-third corner with two aperiodic columns remains open. | yes, S9 posted as R30-20261123-b2be99 (M118) |
| I77 | 22 Nov, gptIntel | Sparse periodic columns: which gap orders can a column with a leftmost black cell repeat? | *In progress* (I77–I92, I94, I95, I97, I104; `research/white-gap-mixtures/`). Kernel, at every site of every row with a leftmost black cell, pulses with gaps ≥ 9: every eventual period contains the gaps (12, 10, 9) arbitrarily late and uses 12, and has at least 6 pulses and 64 ticks (I97, I95, I104); no order of 9 and 10 alone (I91); exactly 10 of 512 three-gap words reset every right half into G (I85). External: (10, 12), (12, 12) and 13 or 14 compulsory (I87); at least 18 pulses, 206 ticks (I90); at most 474·3^n readable orders (I81); every nondegenerate i.i.d. gap law resets almost surely (I92, I94). I85's ten words replayed by claudeCloud under true dynamics (K64 addendum 4). The 0.51 MB factor and ten-word classification pass at the portal pin and kit main (M105, I119). The five- and six-pulse floors await a separate read. Next: can either four-letter alphabet sustain two readings? | no; path 2 (K64) |
| I93 | 22 Nov, gptIntel | Black runs and the right-hand shield: Kurtuluş's PR 381 and Bosdure's quarter periods | *In progress* (I93, I95, I96, I98–I103, I105; `research/black-run-transitions/`). Kernel: 44 and 70 black ticks fix 10 and 16 right cells, sharp (I98, I101); Bosdure's quarter-period exclusions hold at every site of every row with a leftmost black cell (I98); a black run of n ≥ 9 ending white relays a run of at least n − 7, sharp, so the limiting fraction falls from 9/13 to 7/11 (I103), though for the single seed 7/11 is Norris's shield cascade of 23 October (P46); one physical row attains the worst shield rate at every width (I100); drift rigidity for every q ≠ p beyond Murzin's `PeriodicPoints` (I102); the sharp two-run table (I95, on open PR 381). External: 128 ticks for 30 cells; rates 101/12 and 117/14. Finite claims replayed by claudeCloud, and the agreement horizon is exact to n = 44, beating 4⌊(n − 2)/7⌋ from n = 36 (K64 addendum 2). The Lean replay passes at `40017e8` and main, and at the verifier's pin with two kit declarations carried (M95). The relay's gain over Norris is the constant, with every finite-left site and any certified block. | yes, S7 packet ready (R80); carrying read K64 and M95 |
| N3 | 22 Nov, claudeIntel | The complexity form of 8084e6: no aperiodic word with at most n + 1 blocks of each length n (every Sturmian word, every slope and intercept) is the visible-bit sequence beside a clock, in core Lean | **Closed: already in the kit** (K72 addendum 1, P51). `Rule30ZeroWallDiagonals` (10 Nov) has it for the free word of a finitely supported constrained row, which under the clock is the complement of the visible word, and for n + C blocks, not only n + 1. K72's [second proof in the clock's frame](research/kit-repair/R30-20261023-8084e6/Rule30ClockComplexity.lean), through `corollary_F`, passes the stock checker on kit main. | no: the statement is in the catalogue |
| N6 | 22 Nov, claudeIntel | Which rotation codings do Jen and corollary F exclude beside a clock? | **PROVED** (I123, N7): the [silver Pell identity and half-circle exclusion on both cut orbits](research/kit-repair/R30-20261029-0ef6e2/silver-pell.md). **PROVED** (I127–I128, carried in N8): [almost every finite cut tuple at each angle, and almost every phase for any two fixed cuts](research/kit-repair/R30-20261029-0ef6e2/metric-rotation-repeats.md) violate Jen's bound. Pointwise arguments cover [golden #9 and #19](research/kit-repair/R30-20261029-0ef6e2/golden-rational-cuts.md) and the [silver quarter phases](research/kit-repair/R30-20261029-0ef6e2/silver-quarter.md). **PROOF-SKETCH** (N8): along a unit orbit the excess is exactly `τ^sΦ + κ^sψ + ξ − 3`, so one fundamental domain of lags decides each quadratic phase, and off the cut orbits `corollary_F` adds nothing to Jen. COMPUTED (N8 addendum 1): Jen excludes all 30 tested quadratic phases. **PROOF-SKETCH + COMPUTED certificate** (N9 addenda 1–4): every phase's scale-`n` configuration is `Dⁿ(x₀, 0)` on a 2-torus, `D` the unit's hyperbolic automorphism; an interval certificate over 65,536 cells gives [Jen excludes every golden half-circle word, with excess ≥ 0.0999 q − 3 at every scale, and every silver one off the cut orbit](research/kit-repair/R30-20261029-0ef6e2/configuration-torus.md). I146 carries the hand reduction conditional on the cell bounds and reproduces both grids with exact slab endpoints. Two wording corrections are with claudeIntel. **COMPUTED control without the torus** (K72 addenda 4–5): over 27,065 phases the golden minimum is 0.1497 at the same phase as N9's 0.150, 7.96% of silver phases are below the line, and pruning that map leaves only cells within 3 of 0. | no |

## Parked

One dated line each, with what would bring it back (METHOD §3, the incubator).

- **M29, the every-k statement (T)** (parked 21 Nov, the owner). In the kit from one open lemma, (DL⁻₁): see The
  chain; submissions S2, S4, S5. Comes back with a proof idea for (DL⁻₁), or a counterexample, which needs a dyadic
  source period of at least 64. Data kept: f(k) for k ≤ 11, and f(k) ≤ 265,441 for k ≤ 7,911 (M40).
- **K50.4, every white triangle has one family tree** (parked 22 Nov, the owner; K62). The backward cascade is exact
  and almost unbranched, but a run's patch shrinks by about 1.4 cells a row going back, so it gives no bound on
  triangles. Pictures in `research/k50_4/`. Comes back with a reason to bound patches in the bulk, or if the tree's
  growth law is wanted.
- **R3, do changes of gap spend seed bits?** (parked 21 Nov; K36). No: the gaps behave as fair coins, with the exact
  constant λ/4. Comes back with a reason why white seed bits cannot be accepted for ever.
- **R6, do c(2^k) and c(2^(k+1)) differ for ever?** (parked 21 Nov; K39). Tabulated to k = 27.
  c(2²⁶) = 1 and c(2²⁷) = 0, giving 19 changes in the first 28 values (I45, I66, I107). No rule in the split of the
  slab has emerged. Comes back with a cancellation that survives doubling.

## Open threads

- **gptIntel's overnight threads** are now pulls I49, I66, I72, I77 and I93 (K64). The early repeats and
  excursion clocks on Lowry's #379 (I48, I51, I53) are in M9's row.

- **The round's curiosities and misgivings** (K25 §5, in ledger archive 4) are not pulls yet: time order matters
  (I25); period 5's four poor rows (K21); two late single sources at P = 21 and 23 (K29).
- **K6:** METHOD §12 has three handoffs in practice (R45, I2, M45). Writing them into §12 is the conductor's call;
  not done.
- **Visualisations proposed, not built:** a map of the open statements; the branching-walk fan; Mahler's valid starts
  on the circle; a timeline of kit contributions by theme.

## Recently closed routes

One line each, with what would reopen it.

- **K50.3, does the every-k inverse chain need the white wall?** (K61, K63, M88, M89; closed 22 Nov, K65). No: the
  answer is S6, in the kit at `54d030c`. Reopens for the sharpness of age 24 on the line, which is open (Hughes's
  age-23 control is beside the wall and outside Lean), or to prove K63's forms beside a prescribed wall, which are
  COMPUTED only.
- **M8, bounded reach on gap words** (K41; closed 21 Nov, the owner). No bound: a flipped bit reaches as far as in
  random words, 6.4 times its entry depth. Reopens only with a smaller language on which reach could be bounded.
- **L1, the kit's seed law against placego's table** (K46; closed 21 Nov, the owner). They agree at every point, to
  H = 162. Nothing is left in it.
- **Counting marks** (I35, 20 Nov): five marks pass at every dyadic clock; rows survive from seven. Reopens only with
  a reduction for every count at once.
- **The census under the relaxed lemma** (K26, 20 Nov): nothing to run, since no dyadic source fails the strict form
  in reach. Reopens if one does.
- **A gap bound for reset-free doublings** (M43, 19 Nov): refuted at gap 32, period 64.
- **K3, where reset-free doublings occur** (K5, 19 Nov): only period 5, to period 32. Reopens if one appears above 32.
- **R4, source multiplicity and deep-gap density** (R21, 18 Nov): the count is PROVED; the proposed spacing is
  refuted. Reopens with a seed-specific bound on deep-source occupancy.
- **M6, the floor as the density of the sparsest eternal row** (M21, 17 Nov). Reopens if the minimisers' deficits
  stay bounded beyond H = 180.
- **M7, CQ01Empty through the bounded-excess criterion** (M16, 17 Nov). Reopens only with a proof that u ∅ has zero
  entropy.
- **A bounded black frontier for Q01GapCore survivors** (placego L1673): the frontier recedes.
- **Folded or superseded:** R2 gave S1 and continues as M29. K2 gave S3, and its open part is carried by K5. K8 is
  folded into M29, and the reach thread L1 (placego L1680) into M8.
