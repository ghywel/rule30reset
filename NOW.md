# NOW

*Where things stand, the current work and main focuses of interest. One file, rewritten (not appended) by whoever
changes the state, stamped with the time and who changed it. Workers on the same host may share the same local git
repository - take care when writing. Earlier versions are in [archive/now/](archive/now/).*

*Updated 2026-11-26 09:46 UTC by claudeIntel (N19 addendum 5); last edited by the owner at 22:41 UTC on 25 November.*

## Arrangement

The owner - Gareth - providing direction and instruction by prompting.

The AI assistant workers:

| Worker | Host | Ledger Code | Last Completed |
|---|---|---|---|
| claudeM5 | the owner's MacBook Pro M5 laptop, macOS | M | 2611/0937 · M195 · kit update; S22 posted, PR #434 |
| gptM5 | the M5 laptop, shared with claudeM5 | R | 2611/0005 · R126 · K50.3 age-24 sharpness passed its carrying read |
| claudeIntel | the owner's MacBook Pro Intel i9 laptop, AMD RX 6600 GPU, Windows and WSL Ubuntu | N | 2511/2356 · N23 · K50.3 reopened; age 24 sharp on the line, proved in Lean |
| gptIntel | the i9 laptop shared with claudeIntel | I | 2511/2357 · I257 · K83.C certificate converse and one-in-seven census criterion |
| claudeCloud | an Anthropic cloud container | K | 2511/1630 · K85 · S20's prior-art read |

No worker and no host has a specialism (METHOD §1). ClaudeM5 is responsible for portal submissions and kit pull
requests. What each host can run is in [TOOLS.md](TOOLS.md).

Each worker must update their 'Last Completed' at the end of a block of work.

## Needs the owner

This section may only contain calls to action that require the owner's input or decision and are removed when
answered.

- None.

## Direction

- **The goal:** Any Wolfram prize portal (accepts Mathlib) submission and/or WolframInstitute/Rule30PrizeKit git pull
  request (core Lean; Mathlib only in `equivalents/`), of the type requested by the maintainers - a general theorem
  or infinite family (for example, extending the transition rules of Rule30RunTransitions or a block grammar covering
  new families across all lengths) is the right fit.
- **Standing:** The Wolfram git and prize portal contain the bulk of the totality of what is known about the Rule 30
  Prize problem, with significant contributions from ourselves and other third parties. The 'easy' proofs will now be
  known, which leaves the hard proofs and the prize problems 1, 2 and 3 themselves - we continue to research and work
  with others towards the prize proofs.
- **Strategy:** The KIT.md, KIT-INDEX.md and PORTAL.md documents are read regularly to keep everything that is known
  about the problem in the context window, and always kept up to date. The instinct method (METHOD §3) is used to
  identify pulls, choose the next research block and know when to park a pull that has cooled off. We use the Prior
  Art of others and third-party submissions to inform our own research, taking care to always credit where credit is
  due - we are all working together on the prize not competing.

## Submissions

A list of all the Submissions we have made since rule30reset superseded the older placego repository.

METHOD §12: Any worker may propose a submission and add it to the table, a worker of a different model (gpt <->
claude) reviews the submission for correctness and continues a research block on it, claudeM5 prepares the submission
for the prize portal and/or kit PR, the progenitor author confirms their approval, claudeM5 submits with owner
approval.

S1 to S22 are posted and **Lean Verified**; S1 to S21 are **Human Verified** (public list, 25 November 22:31 UTC); S20
is now
R30-20261126-3c2c76, Lean Verified, its review to come. S2 to S19 and S21 are in the kit. S20’s kit pull request,
[#426](https://github.com/WolframInstitute/Rule30PrizeKit/pull/426), is open.

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
| **S18** | Every right half beside an alternating column enters S17’s 777-window set by white sample 35, sharply. An eventual kick every fourth sample is impossible. Problem 1, partial. | M165, [I216](research/arrivals/uniform/README.md) | [R30-20261124-aa6a32](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261124-aa6a32) (M171): **Lean Verified**, **Human Verified**. [Packet b](research/arrivals/s18/); reads [R113](research/arrivals/s18/gptM5-release-review.md#packet-b-release-read), I220, carrying read M166 | **In the kit** at `5bda6ab` ([#422](https://github.com/WolframInstitute/Rule30PrizeKit/pull/422)), `Rule30UniformEntry`, as ours; Kit Contribution (M181) |
| **S19** | Two nonempty blocks of readings, of any lengths, set in the order of the answers of an irrational rotation to *in the arc?*, started at an end of the arc, are not read by the right neighbour of an alternating column on its white ticks, in a row with a leftmost black cell. Problem 1, partial. | N6, M165, [N15](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/README.md) | [R30-20261125-301e35](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261125-301e35) (M183): **Lean Verified**, **Human Verified**. Packet d; example 18 and 28 readings, class not shown to be read by a right half beyond powers of one word. [Carrying PASS for packet c](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/gptIntel-carrying-read.md) (I230). **The owner, 24 November: S19 says that S11 is weaker for Rule 30 than its text suggests** ([wording for packet c](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/packet-c-wording.md)). Packet b (the words themselves) is **held**: already implied by `golden`, S18 and 8084e6 (I228 hand read PASS) ([N14](research/kit-repair/R30-20261029-0ef6e2/endpoint/claudeIntel-s19-hold.md)) | **In the kit** at `e92083b` ([#424](https://github.com/WolframInstitute/Rule30PrizeKit/pull/424)), `Rule30RotationBlocks` (M184) |
| **S20** | Full two-sided topological entropy equals the growth rate of adjacent-column words and is below 1.232039 bits per tick. | K83.B, I234, R123 | [R30-20261126-3c2c76](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-3c2c76) (M194): **Lean Verified**, superseding R30-20261125-91722e (M188); adds the K83.C hearing modules. Reads: I247, I248, K85, I257, M193 | [#426](https://github.com/WolframInstitute/Rule30PrizeKit/pull/426), in `equivalents/`, open: passed static review, queued with AIOvernight’s [#238](https://github.com/WolframInstitute/Rule30PrizeKit/pull/238) until the maintainers add an `equivalents/` check (25 November). Credit to Lowry’s and Galindo’s per-wall bounds added (`4140469`, M192); the hearing modules added (`ce013bb`, M194). **The owner, 25 November:** “It is worth stating 426 is likely to stay open for some time … We can modify 426 and it's portal submission as much as we like.” |
| **S21** | The sharp entry slope for both traps is three ticks per site. The finite erosion and 011 constant-gate deadlines also have sharp slope three. One infinite right half sustains the exceptional front forever. | R5, I242, N18, I247 | [R30-20261125-257977](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261125-257977) (M187): **Lean Verified, Human Verified**. Packet b, agreed by gptIntel (I248). Reads: [N18](research/r5/sharp-slope/claudeIntel-review.md), [I247](research/r5/sharp-slope/I247-carrying-read.md). gptM5’s and claudeIntel’s reads of b waived by the owner | **In the kit** at `202ba55` ([#425](https://github.com/WolframInstitute/Rule30PrizeKit/pull/425), R124). I244 remains a separate companion |
| **S22** | A uniform bound on what a column hears sets the pair density in Galindo's terminal census: one disjoint pair per seven positions at unbounded widths would give Problem 1. | K83.C, I257, M193 | [R30-20261126-14e62a](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-14e62a) (M195): **Lean Verified**. Read: M193 (the Lean), the owner waived further reads | [#434](https://github.com/WolframInstitute/Rule30PrizeKit/pull/434), core, open, mergeable |

## Pulls in progress

One row per pull; its full originating text is in the ledger post named in the first column. The columns:

- **Written:** the date it was made and who made it.
- **Summary:** the area of research being investigated, written as a question.
- **Status:** begins with *open* (a new pull) and can be moved to *preliminary* (one first research block run) or *in
  progress* (actively being worked on, usually by multiple workers).
- **Progress:** this column is being transitioned to a new format by the owner. Moving forward, every time a worker
  completes a block on a pull, they add a new line to the progress cell with the date/time (UTC) in ddmm/hhmm format,
  the ledger post ids written during the work block, a very brief summary of the work done, and a statement of what is
  required next to move the pull towards a submission.
- **Submissions:** if a pull has led to 1 or more submissions add them to this list, kept in sync with the submissions
  table.

If a pull itself invites a new area of research directly related to it, it should be added as a new pull with a
.{letter} postfix such as K83.A. A parent pull may only be parked or closed when all its related child-suffixed pulls
have been parked or closed.

Each row stays on one line of this file, with six cells and no blank line between rows: a blank or broken line ends
the table. Inside a cell, start a new line with `<br>`.

| Pull | Written | Summary | Status | Progress | Submissions |
|---|---|---|---|---|---|
| N6 | 22 Nov, claudeIntel | Which prescribed rotation orders can the neighbour of an alternating column read? | *in progress* | 2511/1121 · M183 · S19 covers the endpoint orbits.<br>2511/1719 · I252 · Proof sketch with Lean criterion: arbitrary phases and nonempty blocks when the limsup of consecutive convergent-denominator ratios exceeds seven, and for the golden half-circle. The exclusion also holds at almost every phase of each fixed arc and angle. [Proof and checks](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/free-phase-repeats.md).<br>2511/1932 · N20 · **Carrying read PASS;** the [frequency step is in Lean](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/FreePhaseFrequency.lean) (unread), so the ratio family has no hypothesis on the block clock. Jen’s bound suffices for all three families. [Read](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/claudeIntel-i252-read.md). **Next:** gptIntel’s answer on the Lean and the Jen form; gptM5’s read. Free-phase sequel: next number S22, if it goes forward. | S11, S19 (both in the kit) |
| K83 | 24 Nov, claudeCloud | Which questions have we not asked because they use Mathlib: what becomes of the almost-every laws with the fair coin on the right and a finite left half? | *in progress* | 2411/2052 · K83 · The kit's almost-every laws all put the fair coin on the left or on the whole row; none has it on the right with a finite left half. Four questions: A, the coin on the right, is K83.A; B, how fast the right side is heard, is K83.B; C, candidate columns in measure, stays with N6; D, limits of results we hold in whole numbers (S9's pentagon, Q01 for almost every start, M6's floor, K5's tail), is not taken. [Note](research/rule4/README.md).<br>2411/2059 · K83 addendum 1 · First probe, frozen before it ran (MEASURED): the right half is heard at about 0.04 bits a tick, exponentially. Three of eight predictions held.<br>2511/2248 · M190 · Parent row put back, at the owner's word. **Next:** it follows K83.A and K83.B, and can be parked or closed only when both are. D waits for a worker. | S20 (from K83.B) |
| K83.A | 24 Nov, claudeCloud | For a fixed finite west and fair east, is the centre almost surely aperiodic? Which rows enter the alternating trap or locks? | *in progress* | 2411/2235 · I229, N16 · **A1 and A2 open.** Trap basin ≥62.85% at width 34. The kit excludes black-first west width ≤52 and white-first width ≤51. [Past-wall law](research/rule4/right-coin-past.md), [independent read and basin counts](research/rule4/claudeIntel-k83a-read.md).<br>2411/2247 · I235 · The [Lean feedback and restart](research/rule4/K83Feedback.lean) reduce A1 to pure-period nullity ([read passed](research/rule4/gptIntel-n16-feedback-read.md)). Next, measure gate-word masses for long-lived wests of depth 50–60.<br>2511/1158 · K84 · **COMPUTED:** Q01's long-lived wests (to support 64, D(64) = 116) demand gates no right half reads after 1 to 12 readings; the coupled lifetime L(B), with some right half supplying the demand, is B + 7 to B + 11 for 26 ≤ B ≤ 64, so E(B, T) is empty for T > L(B); on the coupled witnesses the supplying share falls by 0.4 to 0.7 bits a reading (MEASURED). [Note](research/rule4/k84/README.md). **Next:** see pull K84. | none |
| K83.B | 24 Nov, claudeCloud | How quickly is the right side heard, and is entropy above one bit? | *in progress* | 2411/2334 · I234, M178 · **B4 proved.** Full topological entropy <1.146669 bits/tick (<1.143992 by a width-14 cover, M178), fair metric entropy ≤1.124883281645. The escape dichotomy (B1) and the speed bound (B2) are read, **PASS**; B3 remains open. [Results and certificates](research/rule4/k83b/README.md), [review](research/rule4/k83b/claudeM5-k83b-read.md). [Portable Lean bound <1.232039](research/rule4/k83b/lean-entropy.md) passed the M178 mathematics read and K84 prior-art read.<br>2511/1314 · R123, M184 · [Direct equivalents patch and PR text](research/rule4/k83b/kit/README.md) passed their release read with three wording repairs.<br>2511/1643 · M188 · **S20** is posted and Lean Verified, kit PR #426. **Next:** for B3, test a language with hidden states. | S20 (kit PR #426 open) |
| K83.C | 25 Nov, claudeM5 | How much of its right side can a wall hear: on average, which is the entropy; at worst, which bounds the left words beside a periodic centre; and beside one given period? | *in progress* | 2511/2312 · M191 · The entropy is the growth of the total OR-word count. The largest per-wall count bounds the left words. M191 reported a seven-cell upper bound of 0.2425 bits.<br>2511/2357 · I253–I255, I257 · **M191 read PASS.** Every strict rational upper rate has a finite integer certificate. With Galindo’s #428, one pair per seven age-depth positions at unbounded widths suffices for Problem 1. The pair density is open. [Proofs and scope](research/rule4/k83b/hearing/finite-lookahead.md). **Next:** Claude read of the new theorems for the S20 amendment.<br>2611/0003 · M193 · **Claude read PASS** of `ExactHearingStrip`, `LookaheadHearing` and `TerminalHearing`; replayed on `86864e4`. **Next:** the wording read (claudeIntel or claudeCloud), then the owner's route: the Mathlib modules into #426 and S20, `TerminalHearing` as a core pull request.<br>2611/0119 · M194 · Posted inside S20's replacement (R30-20261126-3c2c76, Lean Verified) and #426; the census test is S22, built and unposted. <br>2611/0937 · M195 · S22 is Lean Verified (R30-20261126-14e62a), kit PR #434. **Next:** the seed-side pair density (I257). | S20 (R30-20261126-3c2c76), S22 (R30-20261126-14e62a) |
| K84 | 25 Nov, claudeCloud | Is the excess of coupled lifetime L(B) over west support B bounded? | *preliminary* | 2511/1303 · I246 · Exact cutoffs through B = 106; the depth-80 cutoff is verified with both LRAT checkers. The largest excess is 16, at B = 86. Lean checks the equivalence to a white section of the decoded west. G₄₃ = 17,324. The unrestricted gate rate is below 0.151 bits a reading. [Results and replay](research/rule4/k84/gptIntel-k84-continuation.md). **Next:** find a constraint on decoded white sections that holds uniformly in B; no worker is on it. | none |
| M181 | 25 Nov, claudeM5 | Can an alternating wall’s right half read every order of the 18- and 28-reading blocks? | *in progress* | 2511/1107 · I239 · **Open.** The finite-prefix criterion is in Lean. S19’s example motivates the question; its silver word is read for 821 readings.<br>2511/1752 · N19 · Every order of ten blocks has a physical row (1,024). The train of A = 3 5 5 5 costs a steady 0.80 bits a block for 50 blocks. The train of B = 3 5⁵ rises to 6 or 7 bits a turn; eleven turns found; on 72 columns it returns after no 1 to 8 turns, where A returns at 90 after three. **Conjecture: Bᵏ is refused for some k ≥ 12.** Running on the Intel: B¹⁶ at 80 columns, B²⁴ at 76. [Orders and proofs](research/wheel/block-orders/README.md), [trains](research/wheel/block-orders/claudeIntel-n19.md). **Next:** if refused, ask for orders with no two B’s together.<br>2511/2337 · N19 addendum 1 · **B¹⁶ is refused** on 80 columns (solver; LRAT running): no right half turns the wheel sixteen times in a row. **Next:** the certificate; the least k (12 to 14 running); then (3 5ʳ)ᵏ for other r.<br>2511/2351 · I256 · The two 72-column B return exclusions at 2 and 3 turns have checked LRAT.<br>2611/0450 · N19 addenda 2, 3 · **B¹⁶ refusal checked** by lrat-check and cake_lpr (20.8 GB LRAT). B¹², B¹³, B¹⁴ are strip-SAT on 80 columns. **Next:** B¹⁵ on 80 (the least refused number of turns); then (3 5ʳ)ᵏ for other r.<br>2611/0651 · N19 addendum 4 · B¹⁵ refused on 80 columns (solver; LRAT running), so on 80 columns the least refused number of turns is 15. **Next:** its certificate; whether wider strips refuse fewer turns; (3 5ʳ)ᵏ for other r.<br>2611/0946 · N19 addendum 5 · **B¹⁵ refusal checked** by both checkers: no right half turns the wheel fifteen times in a row; fourteen are strip-SAT on 80 columns. **Next:** whether real rows read B¹⁴ (a whole-cone or wider-strip test); (3 5ʳ)ᵏ for other r. | none |
| K50.3 | 21 Nov, claudeCloud | What does S6 leave: is its age 24 sharp on the line, and do K63's forms hold beside a prescribed wall? | *in progress* | 2211/1752 · K65 · S6 answers the original question: Hughes's ages hold without the wall (`Rule30TwoSidedInverse`, in the kit). Parked with two questions.<br>2511/2337 · N21 · **Age 24 is sharp on the line** (COMPUTED, two programs): at age 23 a 15-cell seed has a two-step predecessor with no leftmost black cell. [Note](research/k50_3/claudeIntel-line-age-23.md).<br>2511/2348 · N22 · Reopened at the owner's word. **Next:** the witness in Lean beside S6's age-7 theorem (claudeIntel, under way), then a read by a GPT worker. K63's forms beside a prescribed wall stay open.<br>2511/2356 · N23 · **PROVED IN LEAN**: `age_twenty_four_sharp` and the witness, core Lean importing only `Rule30FiniteConfigs`; stock check passes (115 constants, no new axioms), `leanchecker` passes. [Lean](research/k50_3/Rule30TwoSidedSharp.lean).<br>2611/0005 · R126 · **Carrying read PASS.** Same Lean source replayed at kit main and the live verifier pin. [Review](research/k50_3/gptM5-age-24-carrying-read.md). With claudeM5 for the S6 amendment route. K63’s prescribed-wall forms stay open. | S6 (in the kit) |
| I93 | 22 Nov, gptIntel | Black runs and the right-hand shield: which of the kernel results in `research/black-run-transitions/` extend `Rule30RunTransitions`? | *in progress* | 2311/1114 · K73 · Parked after S7 (`Rule30PulseRelay`, in the kit). Not yet outward: the sharp two-run table (I95), the 44- and 70-tick shields (I98, I101), the worst-rate row (I100), drift rigidity (I102).<br>2511/2337 · N21 · I95's seven modules compile unchanged on the kit and pass the stock checker. Its table adds runs of 4, 6 and 8 after runs of at least 15, 16 and 14, sharp, at every site of every row with a leftmost black cell. [Comb](research/pulls/claudeIntel-parked-comb.md).<br>2511/2348 · N22 · Reopened at the owner's word. **Next:** novelty against `Rule30RunTransitions`, #416 and Dyer's two-run families; one module joining the pair table to the kit's windows at every finite-left site; a read by a Claude worker. | S7 (in the kit) |
| I72 | 22 Nov, gptIntel | Which joint densities of black cells and run ends can one site realize: is every point of the closed pentagon the limit along one history? | *in progress* | 2311/1114 · K73 · Parked after S9 (in the kit), which realizes every rational point. Left: irrational points, whether 155 is the least width at (9/10, 2/5), and the one-third corner with two aperiodic columns.<br>2511/2337 · N21 · Mathlib is allowed, and the kit's `schedule` takes any durations, so real points need Beatty durations and a limit in ℝ.<br>2511/2348 · N22 · Reopened at the owner's word. **Next:** the real-point theorem in Mathlib form, for the portal or the kit's `equivalents/`; then the other two questions. | S9 (in the kit) |

## Parked pulls

A pull that has reached a wall, gone cold, circular, or has become non-productive, but still has some unsatisfied
condition that would continue it is considered Parked, removed from Pulls in progress and added to this list. One
dated entry each, with the condition that would re-open it (METHOD §3, the incubator).

- **R5, period-three gates** (parked 25 Nov, R125). S14, S16 and S21 are in the kit. I244 excludes constant 011 gates
  on finite halves. No nonconstant trap through width 34, or pure gap-3 or gap-8 trap through width 42. The new gap-3
  front witness lasts 1,159 ticks at the reconstructed west seam, then fails. Reopen for an all-time argument through
  the 14-column transient or a repeatable physical nonconstant 011 gate. [R5 record](research/r5/README.md) ·
  [Continuation and replay](research/r5/gap3-front-continuation.md)
- **I77, sparse periodic columns** (parked 25 Nov, I250). A varying mark needs at least sixteen pulses on both sides.
  Thus a qualifying 18–31-pulse period has exactly one mark. Both LRAT checkers pass. The 37-tick local obstruction
  has four projected pulse domains as hypotheses. Reopen for a compact invariant deriving such domains, a bound valid
  for arbitrary spacers, or a continuous recurrent black mark between two returns. S8 is in the kit. [Results and
  controls](research/white-gap-mixtures/gptIntel-i77-two-sided-returns.md)
- **M9, lone 5-gaps inside the trap** (parked 24 Nov, I224). The pair (5, 1) can start after eleven trapped samples.
  Its two candidate spatial prefixes have physical histories of at most 11 and 10 samples. A later strip occurrence
  requires a black cell at site 37 to disappear beside a white western neighbour. Reopen for a hand derivation of the
  two possible starts or a rule predicting another lone-1 exclusion. [Proofs and controls](research/m9/late-pair.md) ·
  [K65 sieve, 23 certified onsets and 67 survivors](research/m9/data/gptIntel-sieve-final-K65.txt). S10 is in the kit.
  The entropy is open. X and Y belong to K50.1.
- **K50.2, Lowry’s event returns and the finite left seeds** (parked 24 Nov, I197). The full six-cell strip leaves 5,
  11 and 22 kit seed classes and admits every 3/5 schedule. Reopen with a finite-support weight argument or a strip
  constraint that removes part of that class. [Results and exact residues](research/k50_2/finite-left.md)
- **M29, (T)** (parked 21 Nov, the owner). In Lean and in the kit from one open lemma. The links, with statements and
  proofs in [every-k-chain.md](research/m29/every-k-chain.md): (T) ⇐ (CAP), S2, and without the wall for every
  configuration with a leftmost black cell, S6; (CAP) ⇐ (L∞), S4; (L∞) ⇐ (DL⁻₁), S5. Data kept: f(k) for k ≤ 11, and
  f(k) ≤ 265,441 for k ≤ 7,911 (M40).
- **The wall, (DL⁻₁):** a tick that the doubled stretch after a first clock loss misses is caught in the next stretch.
  **Open.** Its strict form is `DL` in the kit (Quint, #404; stronger than the wall). It is PROVED IN LEAN for source
  periods up to 16 (#407) and COMPUTED at 32 (K5). Quint's L is twice the source period. Both were read, and neither
  reopens the wall (N11). The strict form is also COMPUTED for five black or five white marks at every dyadic period
  (I32, R59); for quiet sources at every period (K18, I20); and at every first clock loss on every rooted strip
  through clock 16 (K27). Nothing is settled from seven marks on. Comes back with a proof idea, or with a
  counterexample, which needs a dyadic source period of at least 64.
- **K5, the resolution law: how the last catch depends on the source period** (parked with the wall, 23 Nov, K73; last
  block K29, read in R61). The first-excursion census agrees closely with the fair-input model; its measured tail is
  about 1.36 κ^x, κ ≈ 0.847810. A uniform bound is open. Carries K2's conjecture on white returns. Comes back with the
  wall. Its next test is written: compare the trace restricted to doubled inputs with the census before using the
  mixing rate for a pooled bound.
- **Counting marks** (I35, 20 Nov): five marks pass at every dyadic clock, and rows survive from seven. Comes back
  only with a reduction for every count at once.
- **The census under the relaxed lemma** (K26, 20 Nov): nothing to run, since no dyadic source fails the strict form
  in reach. Comes back if one does.
- **K3, where reset-free doublings occur** (K5, 19 Nov): only period 5, to period 32. Comes back if one appears above
  32.
- **Noticed in the round and not pursued** (K25 §5, in ledger archive 4): time order matters (I25); period 5's four
  poor rows (K21); two late single sources at P = 21 and 23 (K29).
- **I66, Lowry’s source arrivals under periodic centres** (parked 25 Nov, R118). S17 and S18 are in the kit.
  [I216](research/arrivals/uniform/README.md) gives sharp entry at white sample 35 and the uniform nine-pair decoder.
  Reopen with a concrete way to use the source priority, net or shell to exclude eventual alternation, or a comparable
  uniform arrival law for another periodic centre.
- **I152, the 17/56 wheel beside an alternating column** (parked 24 Nov, M165; its questions in the next entry). S13
  and S15 are posted and in the kit. K81’s [sharp 66-cell change](research/wheel/gptIntel-k81-compactness.md) and
  [40-reading singleton test](research/wheel/k81-structure/README.md) are kept. Comes back with the finite-support
  question of K50.1. No right half turns the wheel fifteen times in a row (N19 addenda 4 and 5; LRAT accepted by both
  checkers).
- **K50.1 / K81, the period-two right-half dichotomy** (parked 23 Nov, I191). A finite seed can sustain Y’s schedule
  for 470 readings (N21), so the 400-sample whole-cone search is satisfiable. A full wheel turn forces a nearby cell
  to change, while its visible gate can stay on rhythm.
  Reopen for a certified whole-cone refusal of a Y stay, loss of the sixteen-copy Y train with a return-budget bound,
  or a new argument that uses the finite far field. The sixteen-copy train is UNSAT by a proof that two checkers
  accept (I212). The two general Y runs are active (I198). I216 proves that every half is in S17’s 777-window set by
  white sample 35. The remaining `RD` question lies inside that set. [R65](research/k50_1/right-dichotomy.md) ·
  [Exterior grammars](research/m9/exterior-grammars.md) · [K80 certificates](research/wheel/gptIntel-k80-review.md).
- **I49, what S12 leaves** (parked 23 Nov, M133; S12 is in the kit). A forcing prefix at arbitrarily late black-centre
  ages of the singleton would exclude an eventual period two. That is a statement about the seed's own right half at
  late ages, with no mechanism in hand: of 524,971 ages to 2²⁰, four have a forcing prefix of 31 cells or fewer (I62).
  Comes back with a reason why any forcing prefix recurs, or if Lowry or the maintainer takes it up on #378.
- **M10, the control matrix** (parked 23 Nov, K73, as a standing instrument; K44, R63, M77). The
  [matrix](research/m10/control-laws.md) gives the spatial reset and first-check degree at every width for the
  controls with an immortal finite row; planting changes only the top monomial (PROVED: Lean, read in M77). Comes back
  when a Q01 proof route is proposed: compare its hypotheses against the controls.
- **K50.4, every white triangle has one family tree** (parked 22 Nov, the owner; K62). The backward cascade is exact
  and almost unbranched, but a run's patch shrinks by about 1.4 cells a row going back, so it gives no bound on
  triangles. Pictures in `research/k50_4/`. Comes back with a reason to bound patches in the bulk, or if the tree's
  growth law is wanted.
- **R3, do changes of gap spend seed bits?** (parked 21 Nov; K36). No: the gaps behave as fair coins, with the exact
  constant λ/4. Comes back with a reason why white seed bits cannot be accepted for ever.
- **R6, do c(2^k) and c(2^(k+1)) differ for ever?** (parked 21 Nov; K39). Tabulated to k = 27. c(2²⁶) = 1 and c(2²⁷) =
  0, giving 19 changes in the first 28 values (I45, I66, I107). No rule in the split of the slab has emerged. Comes
  back with a cancellation that survives doubling.
- **M8, bounded reach on gap words** (K41; stopped 21 Nov, the owner). No bound: a flipped bit reaches as far as in
  random words, 6.4 times its entry depth. Comes back only with a smaller language on which reach could be bounded.
- **R4, source multiplicity and deep-gap density** (R21, 18 Nov): the count is PROVED; the proposed spacing is
  refuted. Comes back with a seed-specific bound on deep-source occupancy.
- **M6, the floor as the density of the sparsest eternal row** (M21, 17 Nov). Comes back if the minimisers' deficits
  stay bounded beyond H = 180.
- **M7, CQ01Empty through the bounded-excess criterion** (M16, 17 Nov). Comes back only with a proof that u ∅ has zero
  entropy.

## Closed pulls

One line each: answered, refuted or finished, with nothing that would reopen it.

- **I49, which finite right prefixes force the seven-lock?** (answered 23 Nov, M133; I148–I165.) Exactly those with a
  finite branching certificate: S12. At Lowry's age 364 the least is 64 contiguous cells, or 63 chosen ones. What S12
  leaves open is parked.
- **N3, the complexity form of 8084e6** (closed 23 Nov; K72 addendum 1, P51). Already in the kit:
  `Rule30ZeroWallDiagonals` (10 Nov) has it in the left-half frame, for n + C blocks and not only n + 1. A [second
  proof in the clock's frame](research/kit-repair/R30-20261023-8084e6/Rule30ClockComplexity.lean) passes the stock
  checker and is not a submission.
- **The kit repairs** (finished 23 Nov, the owner; [KIT-REPAIR.md](KIT-REPAIR.md)): our portal entries that never
  reached the kit are in kit main, steps 1 to 6. Of step 7's three entries, the complexity form of 8084e6 was already
  there (N3), dc3d17 stays portal-only, and 0ef6e2 continues as pull N6.
- **K50.3, does the every-k inverse chain need the white wall?** (K61, K63, M88, M89; closed 22 Nov, K65). No: the
  answer is S6. What it leaves open is parked.
- **L1, the kit's seed law against placego's table** (K46; closed 21 Nov, the owner). They agree at every point, to H
  = 162. Nothing is left in it.
- **A gap bound for reset-free doublings** (M43, 19 Nov): refuted at gap 32, period 64.
- **A bounded black frontier for Q01GapCore survivors** (placego L1673): the frontier recedes.
- **Folded or superseded:** R2 gave S1 and continues as M29. K2 gave S3, and its open part is carried by K5. K8 is
  folded into M29, and the reach thread L1 (placego L1680) into M8. gptIntel's overnight threads became pulls I49,
  I66, I72, I77 and I93 (K64).
