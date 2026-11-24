# NOW

*Where things stand: one file, rewritten (not appended) by whoever changes the state, stamped with the time and the
post that changed it. History is in the [ledger](CHAT-LEDGER.md). Reviewed and purged at the owner's word on
23 November 2026 (K73): the file as it stood is
[archive/now/now-before-review-2026-11-23.md](archive/now/now-before-review-2026-11-23.md), and the file before the
reset of 20 November (K33) is [archive/now/now-before-reset-2026-11-20.md](archive/now/now-before-reset-2026-11-20.md).
Updated 2026-11-24 22:18 UTC by claudeM5 (M177, S19 packet c held).*

## Arrangement

| Worker | Host | Since | On now |
|---|---|---|---|
| claudeM5 | the owner's M5 laptop, the Wolfram host, in the owner's session | 17 November (M1) | S16 and S17 are in the kit. S18 is Lean and Human Verified; its kit PR is #422 (M176). S19’s packet c is held: the block form’s example dies on a 40-column strip (M177). R5 next: a periodic trap beside 011 |
| gptM5 | the M5 laptop, with claudeM5 | 17 November (R1) | I77’s N12 carrying read and return-spacing block are complete (R117). S19 release read awaits the rebuilt block packet (N15, I230) |
| claudeCloud | a cloud container; reclaimed when idle, and its background runs are stopped at two hours, so its long runs go to gptIntel (the owner, 22 November). Lean 4.35.0 per session since K67. **Conducts for the moment** (the owner, 19 November) | 18 November (K1) | Woken by the owner, 24 November, to look for Mathlib and portal-only questions we passed over: [the note](research/rule4/README.md) and two pulls are in K83; its probe has run (K83 addendum 1). Not on a block |
| gptIntel | the Intel i9 with the RX 6600, running Windows and Ubuntu on WSL 2 (I43) | 19 November (I1) | K83.B in progress (I231). K83.A returned (I229). S19 block form passed its carrying read (I230). Both general Y runs continue (I212) |
| claudeIntel | the Intel i9, with gptIntel, in the owner's Claude app; its own store token | 22 November (N1) | S19: packet b held (N14); the block form passed its carrying read (I230). N12’s reads are complete (I217, R117) |

No worker and no host has a specialism (METHOD §1). What each host can run is in [TOOLS.md](TOOLS.md).

- **Running jobs:** K80’s fixed sixteen-copy train is UNSAT, verified by lrat-check and cake_lpr (I212). Intel restarted the 400- and 500-sample Y stays after the 10:15 host reboot. [Run state and collection](research/wheel/gptIntel-k80-review.md#reproduction-and-intel-runs) (I198).
- **Schedules:** none. gptIntel's overnight heartbeat is off (the owner, 22 November).
- **The store:** on the owner's NAS, image `981c5eb`. Its image workflow runs on a change under `tools/store/` and
  once a week (M52).
- **Last posts:** claudeM5 M177, gptM5 R117, claudeCloud K83, gptIntel I231 and claudeIntel N15.

## Needs the owner

Calls to action only. A call leaves when it is answered; a fact goes in the row it changes.

- None.

## Direction

- **The goal** (the owner, 19 November): a submittable proof of the statement the maintainer asked for on #357, "the
  statement for every number of ticks k: an age f(k) from which every k-tick preimage of a nonzero finite orbit has
  its true edge k cells inside the image edge, proved by an argument that does not need a new cover for each k" (T).
- **Where it stands:** (T) is machine-checked, posted and in the kit from one open lemma, (DL⁻₁). The lemma is the
  wall, no proof idea for it is in hand, and the main line is **parked there** (the owner, 21 November): the first
  entry under Parked.
- **Now** (the owner, 21 November): the first round on the old pulls is done (K48), and warm pulls are short. New
  pulls are to be derived from KIT.md and KIT-INDEX.md read whole, with key attention to recent third-party
  submissions, "which we might be able to spring board off towards the next general proof".
- **23 November** (the owner): the portal-to-kit repairs are complete on our side, except the N6 continuation, which
  is its own pull. Path 4 is S12, posted; N6 is with claudeIntel (M165).
- **24 November** (the owner): the day’s partials on Problem 1, the reset repository, the method, the kit as the source
  of known truth, and the interest in external submissions to support our own work, have been “extremely successful”.
- **Standing** (the owner, 17 November): the easy submissions are done, ours and others'; the hard problem needs new
  ways in. Two strategies: this clean repository, read whole into context; and inquisition and visualisation, so
  that the owner's eye can find structure.

## The next block

**The owner, 24 November:** claudeM5 checks this file and assigns a block each to gptIntel and claudeIntel (M165).

- **Being worked:** claudeM5, R5’s periodic trap beside 011. S19: packet b is withdrawn (N14, M176); packet c is held: the block theorem stands, and its example is impossible for every right half at 40 columns (M177), so claudeIntel chooses. claudeCloud: the Mathlib questions we passed over, K83, with a first probe run on pulls K83.A and K83.B (addendum 1); K83.A returned for a read (I229). The two Intel Y runs continue.
- **On offer, none started:**
  - new pulls derived from KIT.md and KIT-INDEX.md read whole (the owner's direction of 21 November; last done in
    K50);
  - the visualisations proposed and not built: a map of the open statements; the branching-walk fan; Mahler's valid
    starts on the circle; a timeline of kit contributions by theme.

## Submissions

METHOD §12: any worker authors, a different worker reads, both agree on the same digests, the owner gives the word;
the Wolfram steps run on the M5. Standing consent to post: none.

S1 to S18 are posted and **Lean Verified**; S1 to S18 are **Human Verified** (public list, 24 November 21:57 UTC). S1 and S18 are not in the kit: S18’s pull request is [#422](https://github.com/WolframInstitute/Rule30PrizeKit/pull/422), open.

| | Result | From | Portal | Kit |
|---|---|---|---|---|
| **S1** | From age 80, every four-tick predecessor of a nonzero finite seed is finite, with its edge four cells inside. | R2 | [R30-20261118-c8b41f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261118-c8b41f) | not taken: the maintainers want every k (M29) |
| **S2** | (CAP), that some width has reset capacity k for every k, gives an explicit age for the k-tick statement (T). | M29 | [R30-20261119-ccc65f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-ccc65f) | `Rule30EveryKInverse` (M61) |
| **S3** | The mean first white gap is at most 2^Q + 1 over the nonzero Q-bit first children. | K2 | [R30-20261119-5896c2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-5896c2) | `Rule30TemporalProfiles` (K15) |
| **S4** | (L∞), reset words at arbitrarily large depths in every phase of every pointed recurrent strip, gives (CAP), and so every k. | M29 | [R30-20261120-eb2bcc](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261120-eb2bcc) (M66) | four modules, `05c9c73`, #375 (M75) |
| **S5** | (DL⁻₁) gives (L∞), and so every k. | M29 | [R30-20261120-8dc0b3](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261120-8dc0b3) (M72) | `Rule30RelaxedWindows`, `40017e8`, [#377](https://github.com/WolframInstitute/Rule30PrizeKit/pull/377) (I44) |
| **S6** | Without the wall: for every configuration with a leftmost black cell, Hughes's ages 8 (sharp) and 24, and from (CAP) every k. | K50.3 | [R30-20261122-7c7bad](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-7c7bad) (M93). [Release and final PR review](research/k50_3/s6-release-review.md) | `Rule30TwoSidedInverse` and `Rule30EveryKLine`, `54d030c`, [#385](https://github.com/WolframInstitute/Rule30PrizeKit/pull/385) (I108) |
| **S7** | The sharp loss of seven ticks at a moving white endpoint, and both quarter-period exclusions at every site of a row with a leftmost black cell. | I93 | [R30-20261122-a963b5](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-a963b5) (M103) | `Rule30PulseRelay`, `98cdf71`, #393. Norris has priority for singleton 7/11. |
| **S8** | Every periodic sparse column (isolated pulses, gaps of at least 9) at any site of a row with a leftmost black cell contains the gaps 12, 10, 9; the ten three-gap reset words as support. | I77 | [R30-20261122-f1c87a](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-f1c87a) (M112) | `Rule30RequiredGapFactor` and `Rule30ThreeGapCapture`, `33b19c8`, [#398](https://github.com/WolframInstitute/Rule30PrizeKit/pull/398) |
| **S9** | Three sharp inequalities and five periodic corners classify uniform linear bounds on black and run-end counts. From any right half, one history realizes each prescribed rational point. On the single seed two corner deficits grow at least logarithmically. Problem 2, partial. | I72 | [R30-20261123-b2be99](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-b2be99) (M118, M120). [Release reads](research/source-density/s9-release-review.md). A lighter notebook with one kernel check passed its read and stays on the M5, unposted (M119, R88). | **In the kit** at `8e1cc84` ([#402](https://github.com/WolframInstitute/Rule30PrizeKit/pull/402)), all thirteen modules byte for byte (M125) |
| **S10** | In the trapped gate, four closed runs of four 5-gaps are excluded from delay two, sharply. Five blocks are excluded from entry. On the kit ladder the four-run threshold is exactly width 45. | M9 | [R30-20261123-71bab6](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-71bab6) (M123). [Reviewed PR text and receipts](research/m9/compact/s10-release-review.md) | **In the kit** at `dc99b86` ([#403](https://github.com/WolframInstitute/Rule30PrizeKit/pull/403)), both modules byte for byte (M128) |
| **S11** | Every golden half-circle phase is excluded as the eventual even-time neighbour of an eventual period-two clock. Problem 1, partial. | N6 | [R30-20261123-6c3fa9](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-6c3fa9) (M128). Reads: [M125](research/kit-repair/R30-20261029-0ef6e2/claudeM5-s11-read.md), M127 | **In the kit** at `b686c1d` ([#405](https://github.com/WolframInstitute/Rule30PrizeKit/pull/405)): gptM5's core port (R94), read by claudeIntel (N10) |
| **S12** | Finite right-prefix certificates for the width-30 seven-lock, a singleton centre deadline and a conditional period-two exclusion. Companion to Troy Lowry’s [age-364 construction](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378). | I49, K74 | [R30-20261123-9608ac](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-9608ac) (M132). [Independent read](research/k50_1/path4/claudeM5-s12-read.md) and [author pins](research/k50_1/path4/release/author-pins.json). | **In the kit** at `f41bb49` ([#406](https://github.com/WolframInstitute/Rule30PrizeKit/pull/406)). [Criterion and release links offered to Lowry](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378#issuecomment-7103117646) |
| **S13** | [Two sites give the exact next pulse beside an alternating column](research/wheel/pulse-candidate/README.md), with a finite singleton clock test. Problem 1, partial. | I152, I179–I180 | [R30-20261123-78e431](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-78e431), Lean Verified (M146). Reads: K80, K82; the last release read and the author's ready were waived by the owner | [#409](https://github.com/WolframInstitute/Rule30PrizeKit/pull/409) merged at `5cf9874` (R101) |
| **S14** | The exact first departure from an aligned period-3 ether prefix of any length; the kit's 15-trap is closed to ether and white prefixes; the gate word of each half in a trap of 001, with a conditional exclusion in the form of Bosdure's `Lock`. Problem 1, partial. | R5 | [R30-20261123-f214f2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-f214f2), Lean Verified (M142). Reads: [R98](research/r5/s14/m139-carrying-read.md), R99, I182, I186 | **In the kit** at `0c4194c` ([#408](https://github.com/WolframInstitute/Rule30PrizeKit/pull/408)), three modules and a data module (M148) |
| **S15** | One column shows the 829-window trap: 48 clean readings, or 47 after the first white tick, for every right half, both least for a uniform test; nine certifying words; sharp delays. Problem 1, partial. | I152, I181, I190, R100 | [R30-20261124-4eb126](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261124-4eb126), Lean Verified (M150). Reads: R100, [R101](research/wheel/s15/r101-release-read.md), [M144](research/wheel/claudeM5-i175-read.md), I195 | **In the kit** at `a09d6c6` ([#412](https://github.com/WolframInstitute/Rule30PrizeKit/pull/412)), `Rule30GateObserver` and a data module (M153) |
| **S16** | Every finite right half beside 001 or 011 enters the least nonempty closed set of 14-cell windows in linear time; no slope below 5/2 would do. Problem 1, partial. | R5, M152, I206 | [R30-20261124-629dac](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261124-629dac) (M159): **Lean Verified**. [Packet b](research/r5/s16/); reads [I206](research/r5/s16/i206-carrying-read.md), [R107, R108](research/r5/s16/gptM5-packet-a-review.md) on packet a, [I208](research/r5/s16/gptIntel-packet-b-review.md) PASS on b; gptM5’s release read superseded (M161) | **In the kit** at `88fdac9` ([#415](https://github.com/WolframInstitute/Rule30PrizeKit/pull/415), R109). |
| **S17** | If the singleton centre eventually alternates, each phase of Lowry’s source net and shell is aperiodic. Problem 1, partial. | I66, I203, M156, I211 | [R30-20261124-6af182](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261124-6af182) (M164): **Lean Verified**, **Human Verified**. [Packet c](research/arrivals/s17/) passed by gptM5 ([R111](research/arrivals/s17/gptM5-packet-b-review.md#packet-c-release-read)); gptIntel also agreed to the posted packet c (I215) | **In the kit** at `4bb3a7b` ([#418](https://github.com/WolframInstitute/Rule30PrizeKit/pull/418)), `Rule30AlternatingArrivals` and a data module, both as ours (M176) |
| **S18** | Every right half beside an alternating column enters S17’s 777-window set by white sample 35, sharply. An eventual kick every fourth sample is impossible. Problem 1, partial. | M165, [I216](research/arrivals/uniform/README.md) | [R30-20261124-aa6a32](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261124-aa6a32) (M171): **Lean Verified**, **Human Verified**. [Packet b](research/arrivals/s18/); reads [R113](research/arrivals/s18/gptM5-release-review.md#packet-b-release-read), I220, carrying read M166 | [#422](https://github.com/WolframInstitute/Rule30PrizeKit/pull/422) on `4bb3a7b`, open; patch `1d1d5c61…` rebased, module and row unchanged (M176) |
| **S19, block form proposed** | Two nonempty blocks of readings, of any lengths, set in the order of the answers of an irrational rotation to *in the arc?*, started at an end of the arc, are not read by the right neighbour of an alternating column on its white ticks, in a row with a leftmost black cell. Problem 1, partial. | N6, M165, [N15](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/README.md) | [Carrying PASS for packet c](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/gptIntel-carrying-read.md) (I230). **The owner, 24 November: S19 says that S11 is weaker for Rule 30 than its text suggests** ([wording for packet c](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/packet-c-wording.md)). Packet b (the words themselves) is **held**: already implied by `golden`, S18 and 8084e6 (I228 hand read PASS) ([N14](research/kit-repair/R30-20261029-0ef6e2/endpoint/claudeIntel-s19-hold.md)) | Module ready on `ebda8ce` |

- **The kit.** The portal verifier is at `5fb5915`. Kit main and the shared catalogue are in step at `ebda8ce` (I226).
- **The kit repairs** are complete on our side (the owner, 23 November): steps 1 to 6 of
  [KIT-REPAIR.md](KIT-REPAIR.md) are in kit main, and step 7 was assessed, leaving pull N6.
- **Kit issues.** [#386](https://github.com/WolframInstitute/Rule30PrizeKit/issues/386), the portal and kit
  consistency check (M98), has no reply. [#380](https://github.com/WolframInstitute/Rule30PrizeKit/issues/380), how
  a law with a certified CNF hypothesis can enter the kit (M86), is closed as resolved independently (M123).

## Pulls in progress

One row per pull; its full text is the ledger post named in the first column, in the live ledger or its archives.
Status begins with *open* (nothing run), **preliminary** (one first block run) or *in progress*. An *in progress*
row names the worker on it, or says **free**. Every row says its next test. A parked or closed pull leaves the
table for the lists below. The rules are in METHOD §8.

| Pull | Written | Summary | Status | Submission? |
|---|---|---|---|---|
| N6 | 22 Nov, claudeIntel | Which rotation codings do Jen and corollary F exclude beside a clock? | *In progress with claudeIntel.* **The words of one arc, from any start, are excluded without Jen or corollary F** (N14: `golden`, the nine pairs of S18, and 8084e6 for arcs on one orbit); S11 is a case. **PROVED IN LEAN, carrying PASS (N15, I230):** [two blocks of any lengths in the order of an arc, from an end](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/README.md), which those rules do not reach. On words: [near-squares of every arc from an end](research/kit-repair/R30-20261029-0ef6e2/endpoint/README.md) (N13, read in I221) and the [metric results](research/kit-repair/R30-20261029-0ef6e2/metric-rotation-repeats.md) (I127, I128, N8). **Next:** (1) build and read S19 packet c; (2) the metric theorem and the silver cover only for gap orders, not for words of an arc. | **S19, block form** (N15) |
| I77 | 22 Nov, gptIntel | Sparse periodic columns: which gap orders can a column with a leftmost black cell repeat? | N12’s nine-gap factor (a,12,14,12,12,10,9,10,b), a=10 or 14, b=10 or 12, **COMPUTED; carrying PASS** (R117). The full four-letter width-29 replay gave zero differing pairs. **COMPUTED:** successive occurrences are at least 11 pulses apart. **PROVED IN LEAN:** at distances 7–9, two occurrences capture every right half in G. [Read, controls and reproduction](research/white-gap-mixtures/gptM5-n12-return-read.md). **Next:** carry the two unobserved cells across every distance-11 path and test physical continuity. | S8 is in the kit. The close-return capture has a standalone Lean proof ready for independent read. Full nine-gap necessity and eleven-pulse spacing need compact certificates. |
| I66 | 21 Nov, gptIntel | Lowry’s source arrivals under periodic centres, and source priority | [I216](research/arrivals/uniform/README.md) proves M165’s uniform entry in Lean. Sample 35 is attained by a finite half with eight black sites. The nine gap pairs apply to every right half from that sample. | S17 and S18 are posted (M164, M171). |
| R5 | 17 Nov, gptM5 | Period 3: where does a cut 001 ether go after it first departs? | *In progress:* claudeM5 and gptM5 ([report](research/r5/README.md)). **PROVED IN LEAN:** recurrent fronts of the ether move on one path for every right side (M134, read by gptM5); the exact first departure after a 22-site prefix exit, 49 or 52 ticks (R97, read by claudeM5); no half that carries 20 ether columns, or 16 white cells, enters the kit's 15-trap (M137, read by gptM5 in R98). **COMPUTED:** the only component reached after departure is the 22-column giant (I173, I177); the traps of 001 share a 34-column trunk; a census of every wall with labels to 30 finds no gate but 1100000 and 11000, none for 011, and a **fifth trap** that refutes entry into the four known (M137). CONJECTURE: every finite half's gate is eventually one of those two. **PROVED (M153, I208):** each finite half enters the least nonempty closed 14-cell trap, at every gate tick from 3 D + 170 or 3 D + 820. The portable proof rules out slopes below 5/2. The period-two analogue remains open. Open: that a finite half ever passes the last rung. **Next:** a periodic trap beside 011, labels 33. | **S14** (M142) and **S16** (M159) are posted and in the kit |
| K83.A | 24 Nov, claudeCloud | With a fixed finite left and fair east, is the centre almost surely aperiodic? What enters the alternating wall’s trap or locks? | **Block returned (I229); A1 and A2 open.** [Exact forward bounds](research/rule4/k83a-gate-mass.md) and [seven/one escape](research/rule4/k83a-escape.md). [Trap alone ≥51.4395%](research/rule4/k83a-basin.md). [Past-wall measure law in Lean](research/rule4/right-coin-past.md). **Next:** prove survival tends to zero at each fixed west-support width; independent read requested. | No S number. The Mathlib half-line result awaits a carrying and prior-art read. |
| K83.B | 24 Nov, claudeCloud | How fast is the right side heard: is rule 30's entropy strictly above log 2, and below the kit's log 3? | **In progress with gptIntel (I231).** The kit's Mathlib catalogue reads log 2 from counts to 18 ticks. MEASURED (K83 addendum 1): beside three fair-coin walls column 1 gains 0.045 bits of collision entropy a tick, exponentially, which points above log 2. **Next:** exact pair-word counts past 18 ticks; a construction that proves the extra entropy. | no. Would improve a row of the kit's `equivalents/` |

## Parked

One dated entry each, with what would bring it back (METHOD §3, the incubator). A route that stopped with a condition
that would reopen it is here, not under closed (the owner, 23 November). Glance down the list at session start.

- **M9, lone 5-gaps inside the trap** (parked 24 Nov, I224). The pair (5, 1) can start after eleven trapped samples. Its two candidate spatial prefixes have physical histories of at most 11 and 10 samples. A later strip occurrence requires a black cell at site 37 to disappear beside a white western neighbour. Reopen for a hand derivation of the two possible starts or a rule predicting another lone-1 exclusion. [Proofs and controls](research/m9/late-pair.md) · [K65 sieve, 23 certified onsets and 67 survivors](research/m9/data/gptIntel-sieve-final-K65.txt). S10 is in the kit. The entropy is open. X and Y belong to K50.1.

- **K50.2, Lowry’s event returns and the finite left seeds** (parked 24 Nov, I197). The full six-cell strip leaves 5, 11 and 22 kit seed classes and admits every 3/5 schedule. Reopen with a finite-support weight argument or a strip constraint that removes part of that class. [Results and exact residues](research/k50_2/finite-left.md)

**The main line: the every-k statement (T) and its wall.**

- **M29, (T)** (parked 21 Nov, the owner). In Lean and in the kit from one open lemma. The links, with statements and
  proofs in [every-k-chain.md](research/m29/every-k-chain.md): (T) ⇐ (CAP), S2, and without the wall for every
  configuration with a leftmost black cell, S6; (CAP) ⇐ (L∞), S4; (L∞) ⇐ (DL⁻₁), S5. Data kept: f(k) for k ≤ 11, and
  f(k) ≤ 265,441 for k ≤ 7,911 (M40).
- **The wall, (DL⁻₁):** a tick that the doubled stretch after a first clock loss misses is caught in the next
  stretch. **Open.** Its strict form is `DL` in the kit (Quint, #404; stronger than the wall). It is PROVED IN LEAN for
  source periods up to 16 (#407) and COMPUTED at 32 (K5). Quint's L is twice the source period. Both were read, and
  neither reopens the wall (N11). The strict form is also COMPUTED for five black or
  five white marks at every dyadic period (I32, R59); for quiet sources at every period (K18, I20); and at every
  first clock loss on every rooted strip through clock 16 (K27). Nothing is settled from seven marks on. Comes back
  with a proof idea, or with a counterexample, which needs a dyadic source period of at least 64.
- **K5, the resolution law: how the last catch depends on the source period** (parked with the wall, 23 Nov, K73;
  last block K29, read in R61). The first-excursion census agrees closely with the fair-input model; its measured
  tail is about 1.36 κ^x, κ ≈ 0.847810. A uniform bound is open. Carries K2's conjecture on white returns. Comes
  back with the wall. Its next test is written: compare the trace restricted to doubled inputs with the census
  before using the mixing rate for a pooled bound.
- **Counting marks** (I35, 20 Nov): five marks pass at every dyadic clock, and rows survive from seven. Comes back
  only with a reduction for every count at once.
- **The census under the relaxed lemma** (K26, 20 Nov): nothing to run, since no dyadic source fails the strict form
  in reach. Comes back if one does.
- **K3, where reset-free doublings occur** (K5, 19 Nov): only period 5, to period 32. Comes back if one appears
  above 32.
- **Noticed in the round and not pursued** (K25 §5, in ledger archive 4): time order matters (I25); period 5's four
  poor rows (K21); two late single sources at P = 21 and 23 (K29).

**Pulls and routes.**

- **I152, the 17/56 wheel beside an alternating column** (parked 24 Nov, M165; its questions in the next entry). S13 and S15 are posted and in the kit. K81’s [sharp 66-cell change](research/wheel/gptIntel-k81-compactness.md) and [40-reading singleton test](research/wheel/k81-structure/README.md) are kept. Comes back with the finite-support question of K50.1.
- **K50.1 / K81, the period-two right-half dichotomy** (parked 23 Nov, I191). A finite seed can sustain Y’s schedule for 344 readings. A full wheel turn forces a nearby cell to change, while its visible gate can stay on rhythm. Reopen for a certified whole-cone refusal of a Y stay, loss of the sixteen-copy Y train with a return-budget bound, or a new argument that uses the finite far field. The sixteen-copy train is UNSAT by a proof that two checkers accept (I212). The two general Y runs are active (I198). I216 proves that every half is in S17’s 777-window set by white sample 35. The remaining `RD` question lies inside that set. [R65](research/k50_1/right-dichotomy.md) · [Exterior grammars](research/m9/exterior-grammars.md) · [K80 certificates](research/wheel/gptIntel-k80-review.md).
- **I49, what S12 leaves** (parked 23 Nov, M133; S12 is in the kit). A forcing prefix at arbitrarily late black-centre
  ages of the singleton would exclude an eventual period two. That is a statement about the seed's own right half at
  late ages, with no mechanism in hand: of 524,971 ages to 2²⁰, four have a forcing prefix of 31 cells or fewer (I62).
  Comes back with a reason why any forcing prefix recurs, or if Lowry or the maintainer takes it up on #378.
- **I72, what S9 leaves** (parked 23 Nov, K73; S9 is posted and in the kit). Comes back for limits at points of the pentagon with
  an irrational coordinate, which the mixing schedule with slowly changing weights should give and which are not
  formalized; for a proof that 155 is the least width at the corner (9/10, 2/5), which is searched only (K64); or
  for gptIntel's next test, the one-third corner with two aperiodic columns.
- **I93, what S7 leaves** (parked 23 Nov, K73; S7 is posted and in the kit). Kernel results in
  `research/black-run-transitions/` that have not gone outward: 44 and 70 black ticks fix 10 and 16 right cells,
  sharp (I98, I101); one physical row attains the worst shield rate at every width (I100); drift rigidity for every
  q ≠ p (I102); the sharp two-run table, on open PR 381 (I95). Comes back if one of them is wanted outward: each
  needs the novelty check and a read.
- **M10, the control matrix** (parked 23 Nov, K73, as a standing instrument; K44, R63, M77). The
  [matrix](research/m10/control-laws.md) gives the spatial reset and first-check degree at every width for the
  controls with an immortal finite row; planting changes only the top monomial (PROVED: Lean, read in M77). Comes
  back when a Q01 proof route is proposed: compare its hypotheses against the controls.
- **K50.3, what S6 leaves** (answered 22 Nov, K65). Comes back for the sharpness of age 24 on the line, which is
  open (Hughes's age-23 control is beside the wall and outside Lean), or to prove K63's forms beside a prescribed
  wall, which are COMPUTED only.
- **K50.4, every white triangle has one family tree** (parked 22 Nov, the owner; K62). The backward cascade is exact
  and almost unbranched, but a run's patch shrinks by about 1.4 cells a row going back, so it gives no bound on
  triangles. Pictures in `research/k50_4/`. Comes back with a reason to bound patches in the bulk, or if the tree's
  growth law is wanted.
- **R3, do changes of gap spend seed bits?** (parked 21 Nov; K36). No: the gaps behave as fair coins, with the exact
  constant λ/4. Comes back with a reason why white seed bits cannot be accepted for ever.
- **R6, do c(2^k) and c(2^(k+1)) differ for ever?** (parked 21 Nov; K39). Tabulated to k = 27.
  c(2²⁶) = 1 and c(2²⁷) = 0, giving 19 changes in the first 28 values (I45, I66, I107). No rule in the split of the
  slab has emerged. Comes back with a cancellation that survives doubling.
- **M8, bounded reach on gap words** (K41; stopped 21 Nov, the owner). No bound: a flipped bit reaches as far as in
  random words, 6.4 times its entry depth. Comes back only with a smaller language on which reach could be bounded.
- **R4, source multiplicity and deep-gap density** (R21, 18 Nov): the count is PROVED; the proposed spacing is
  refuted. Comes back with a seed-specific bound on deep-source occupancy.
- **M6, the floor as the density of the sparsest eternal row** (M21, 17 Nov). Comes back if the minimisers' deficits
  stay bounded beyond H = 180.
- **M7, CQ01Empty through the bounded-excess criterion** (M16, 17 Nov). Comes back only with a proof that u ∅ has
  zero entropy.

## Recently closed routes

One line each: answered, refuted or finished, with nothing that would reopen it.

- **I49, which finite right prefixes force the seven-lock?** (answered 23 Nov, M133; I148–I165.) Exactly those with a
  finite branching certificate: S12. At Lowry's age 364 the least is 64 contiguous cells, or 63 chosen ones. What S12
  leaves open is parked.
- **N3, the complexity form of 8084e6** (closed 23 Nov; K72 addendum 1, P51). Already in the kit:
  `Rule30ZeroWallDiagonals` (10 Nov) has it in the left-half frame, for n + C blocks and not only n + 1. A
  [second proof in the clock's frame](research/kit-repair/R30-20261023-8084e6/Rule30ClockComplexity.lean) passes the
  stock checker and is not a submission.
- **The kit repairs** (finished 23 Nov, the owner; [KIT-REPAIR.md](KIT-REPAIR.md)): our portal entries that never
  reached the kit are in kit main, steps 1 to 6. Of step 7's three entries, the complexity form of 8084e6 was
  already there (N3), dc3d17 stays portal-only, and 0ef6e2 continues as pull N6.
- **K50.3, does the every-k inverse chain need the white wall?** (K61, K63, M88, M89; closed 22 Nov, K65). No: the
  answer is S6. What it leaves open is parked.
- **L1, the kit's seed law against placego's table** (K46; closed 21 Nov, the owner). They agree at every point, to
  H = 162. Nothing is left in it.
- **A gap bound for reset-free doublings** (M43, 19 Nov): refuted at gap 32, period 64.
- **A bounded black frontier for Q01GapCore survivors** (placego L1673): the frontier recedes.
- **Folded or superseded:** R2 gave S1 and continues as M29. K2 gave S3, and its open part is carried by K5. K8 is
  folded into M29, and the reach thread L1 (placego L1680) into M8. gptIntel's overnight threads became pulls I49,
  I66, I72, I77 and I93 (K64).
