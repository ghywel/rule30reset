# NOW

*Where things stand, the current work and main focuses of interest. One file, rewritten (not appended) by whoever
changes the state, stamped with the time and who changed it. Workers on the same host may share the same local git
repository - take care when writing. Earlier versions are in [archive/now/](archive/now/).*

*Updated 2026-11-26 16:23 UTC by claudeM5 (M209); last edited by the owner at 22:41 UTC on 25 November.*

## Arrangement

The owner - Gareth - providing direction and instruction by prompting.

The AI assistant workers:

| Worker | Host | Ledger Code | Last Completed |
|---|---|---|---|
| claudeM5 | the owner's MacBook Pro M5 laptop, macOS | M | 2611/1623 · M209 · S27 core port, part 1 in core; part 2 (unequal blocks) open |
| gptM5 | the M5 laptop, shared with claudeM5 | R | 2611/1556 · R134 · S27 statement read passes on the rebuilt portal packet |
| claudeIntel | the owner's MacBook Pro Intel i9 laptop, AMD RX 6600 GPU, Windows and WSL Ubuntu | N | 2611/1526 · N28 · N6: I270's ratio-six exclusion passes its carrying read |
| gptIntel | the i9 laptop shared with claudeIntel | I | 2611/1602 · I273 · S28 proposed from K83, with the core support companion |
| claudeCloud | an Anthropic cloud container | K | 2611/1613 · K91 · Kit PRs #443 and #444 reviewed: sound, nothing moves on CQ01, half of #444 is already in the kit |

No worker and no host has a specialism (METHOD §1). ClaudeM5 is responsible for portal submissions and kit pull
requests. What each host can run is in [TOOLS.md](TOOLS.md).

Each worker must update their 'Last Completed' at the end of a block of work.

## Needs the owner

This section may only contain calls to action that require the owner's input or decision and are removed when
answered.

- **A comment on kit PR #444?** It restates three results the kit holds (two in our `Rule30EtherFamilies`, and
  `CQ01_of_RD_of_Q01Gap`) without citing them, and its prefix lengths are not least. A draft is in
  [K91's review](research/k50_1/kit-prs/claudeCloud-pr443-444.md). Post it through claudeM5, or leave it?

## Direction

- **The goal:** Any Wolfram prize portal (accepts Mathlib) submission and/or WolframInstitute/Rule30PrizeKit git pull
  request (core Lean; Mathlib only in `equivalents/`), of the type requested by the maintainers - a general theorem
  or infinite family (for example, extending the transition rules of Rule30RunTransitions or a block grammar covering
  new families across all lengths) is the right fit.
- **Core Lean first** (the owner, 26 November): "In general the equivalents/ path should only be used for routes that
  have no core lean version, lean is always preferred where possible." A result that uses Mathlib goes to the
  catalogue through a core form whenever one exists, even if that needs a port; `equivalents/` only when none does
  ([METHOD §12, Mathlib, rule 5](METHOD.md#mathlib)).
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

S1 to S22 are posted, **Lean Verified** and **Human Verified** (portal status, 26 November 09:50 UTC), S20 as
R30-20261126-3c2c76. S6's replacement (R30-20261126-523aad, superseding R30-20261122-7c7bad) and S23
(R30-20261126-2e7cd2) were posted at 12:10 UTC on 26 November, S24 (R30-20261126-86f74a) at 13:15, S25
(R30-20261126-744811) and S26 (R30-20261126-97edd5), both Problem 2, at 14:28, and S27 (R30-20261126-8c236d) at 16:01;
all six are **Lean Verified**. S2 to S19, S21 to S24 and S6's amendment are in the kit, S24 as `fa1091e`
([#439](https://github.com/WolframInstitute/Rule30PrizeKit/pull/439)). Open: S20's
[#426](https://github.com/WolframInstitute/Rule30PrizeKit/pull/426) and S26's
[#442](https://github.com/WolframInstitute/Rule30PrizeKit/pull/442), both in `equivalents/`, and S25's
[#441](https://github.com/WolframInstitute/Rule30PrizeKit/pull/441), rebased on `aaaefdd` with the count 377 to 378
(M206).

| | Result | From | Portal | Kit |
|---|---|---|---|---|
| **S1** | From age 80, every four-tick predecessor of a nonzero finite seed is finite, with its edge four cells inside. | R2 | [R30-20261118-c8b41f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261118-c8b41f) | not taken: the maintainers want every k (M29) |
| **S2** | (CAP), that some width has reset capacity k for every k, gives an explicit age for the k-tick statement (T). | M29 | [R30-20261119-ccc65f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-ccc65f) | `Rule30EveryKInverse` (M61) |
| **S3** | The mean first white gap is at most 2^Q + 1 over the nonzero Q-bit first children. | K2 | [R30-20261119-5896c2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-5896c2) | `Rule30TemporalProfiles` (K15) |
| **S4** | (L∞), reset words at arbitrarily large depths in every phase of every pointed recurrent strip, gives (CAP), and so every k. | M29 | [R30-20261120-eb2bcc](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261120-eb2bcc) (M66) | four modules, `05c9c73`, #375 (M75) |
| **S5** | (DL⁻₁) gives (L∞), and so every k. | M29 | [R30-20261120-8dc0b3](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261120-8dc0b3) (M72) | `Rule30RelaxedWindows`, `40017e8`, [#377](https://github.com/WolframInstitute/Rule30PrizeKit/pull/377) (I44) |
| **S6** | Without the wall: for every configuration with a leftmost black cell, Hughes's sharp ages 8 and 24, and from (CAP) every k. | K50.3 | [R30-20261122-7c7bad](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261122-7c7bad) (M93). [Release and final PR review](research/k50_3/s6-release-review.md). **Replaced by [R30-20261126-523aad](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-523aad) (M198): Lean Verified**; age 24 sharp and the least ages. [gptM5 release read PASS](research/k50_3/gptM5-wall-and-s6b-review.md#s6-replacement-packet-b) (R127); claudeIntel's age-23 read waived by the owner's word to post. The old entry keeps its tags | `Rule30TwoSidedInverse` and `Rule30EveryKLine`, `54d030c`, [#385](https://github.com/WolframInstitute/Rule30PrizeKit/pull/385) (I108); the amendment, [#435](https://github.com/WolframInstitute/Rule30PrizeKit/pull/435), merged at `ea04541` (I268) |
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
| **S22** | A uniform bound on what a column hears sets the pair density in Galindo's terminal census: one disjoint pair per seven positions at unbounded widths would give Problem 1. | K83.C, I257, M193 | [R30-20261126-14e62a](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-14e62a) (M195): **Lean Verified**. Read: M193 (the Lean), the owner waived further reads | In the kit at `bd5ec59` ([#434](https://github.com/WolframInstitute/Rule30PrizeKit/pull/434)), `Rule30TerminalHearing` |
| **S23** | Hughes's inverse ticks beside every prescribed wall: from ages 8 and 24, or 9 and 25 for a start next to the wall, all sharp. | K50.3, R127, R130, M197 | [R30-20261126-2e7cd2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-2e7cd2) (M198): **Lean Verified**. Reads: M197 (carrying), [R133](research/k50_3/s23/release-read.md) (release) | **In the kit** as `Rule30DrivenLeftInverse` at `c7c2207` ([#436](https://github.com/WolframInstitute/Rule30PrizeKit/pull/436), I268) |
| **S24** | Kurtuluş's run transitions in every column of every configuration with a leftmost black cell, with sharp two-run cutoffs chosen at each white letter, at every period length. | I93, I259, N24 | [R30-20261126-86f74a](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-86f74a) (M201): **Lean Verified**. Reads: N24 (carrying), [I264](research/black-run-transitions/gptIntel-s24-release-read.md) (release), M200 (cade33 at source) | **In the kit** as `Rule30RunTransitionWindows` at `fa1091e` ([#439](https://github.com/WolframInstitute/Rule30PrizeKit/pull/439), 26 November; the module byte for byte, M206) |
| **S25** | At the corner (9/10, 2/5) of S9's pentagon, a bounded deficit fixes the whole left half to one ten-tick film of 155 columns; every ring at that corner, of any temporal period, has width divisible by 155. | I72, I262, N25 | [R30-20261126-744811](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-744811) (M203): **Lean Verified**, Problem 2. Reads: N25 (carrying), [I268](research/source-density/gptIntel-s25-s26-release-read.md) (release; its repairs made, the reread waived by the owner's word to post) | `Rule30NineTenthsRing`, new; [#441](https://github.com/WolframInstitute/Rule30PrizeKit/pull/441), open (M203); rebased on `aaaefdd`, count 377 to 378 (M206) |
| **S26** | Every real point of S9's pentagon is the limiting black and run-end frequency pair at one site, from any right half, with squared count errors at most 210000(n + 1); no other point is. Mathlib. | I72, I261, I262, N25 | [R30-20261126-97edd5](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-97edd5) (M203): **Lean Verified**, Problem 2. Reads: N25 (carrying), [I268](research/source-density/gptIntel-s25-s26-release-read.md) (release; repairs made, as S25) | `Rule30Equivalents.RealDensityRegion`, in `equivalents/`; [#442](https://github.com/WolframInstitute/Rule30PrizeKit/pull/442), open (M203); the maintainers decide when, as for #426. No core version: the statement is about real limits (METHOD rule 5) |
| **S27** | Two nonempty blocks set in the order of an irrational rotation, at every phase and every arc, are not read by the right neighbour of an alternating column on its white ticks, in a row with a leftmost black cell, when arbitrarily large straddling approximants have denominator ratio above six by a fixed margin, including the all-six angle √10 − 3. Problem 1, partial. | N6, I252, N20, I270 | [R30-20261126-8c236d](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-8c236d) (M208): **Lean Verified**, Problem 1, from packet b. Reads: N28 (carrying), [R134](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/s27/gptM5-statement-read.md) (statement); gptIntel's release read waived by the owner's word to post | core port (claudeM5, M209): [part 1](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/core/README.md) in core, `Rule30RotationFreePhase` (9 headlines, 145 constants at `aaaefdd`): every phase for blocks of one length, and for any lengths given the reading clock's envelopes. Part 2, the envelopes in core, is open. No kit PR yet |
| **S28** | A prescribed or feedback-driven T-tick wall has right-half image of fair mass 2⁻ᵀ with exact conditional law. Pure-period nullity implies eventual-period nullity for fixed finite nonempty left support. The alternating-wall companion gives the exact finite west support test and gate-prefix correspondence. Problem 1, partial. | K83, I229, N16, I246 | Proposed, I273. Pinned portal proof passes 12 headlines. [Draft and review](research/rule4/s28/review.md). Claude carrying read of the core results and assembly requested. | Core `Rule30AlternatingFiniteSupport`, three headlines pass, patch at `aaaefdd`. The measure part has an `equivalents/` route. |

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
| N6 | 22 Nov, claudeIntel | Which prescribed rotation orders can the neighbour of an alternating column read? | *in progress* | S19 covers endpoint phases at every angle. I252 gives hand extensions for the golden half-circle and almost every phase of each fixed arc and angle. N20’s frequency proof passed independent read.<br>2611/1446 · I270 · Every phase, arc and pair of nonempty blocks is excluded above denominator ratio six, including the all-six angle, by Jen in Lean. The strict bound is sharp for the three-trial test at one lag. **Next:** claudeIntel and gptM5 to read the [candidate and boundary construction](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/relative-cut-span.md). Joint lags below six remain open.<br>2611/1505 · M204 · **Assessed as S27**, a new entry beside S19: every phase at ratio above six, where S19 has the endpoint orbits at every angle. The portal source reproduces at `c7c2207` (`8bc36732`). **Next:** claudeIntel's carrying read and gptM5's statement read; then claudeM5 prepares.<br>2611/1511 · M205 · **S27 goes core** (the owner: core Lean always preferred): an integer form in core beside `Rule30RotationBlocks`, the real statement as a thin Mathlib layer for the portal. **Next:** the two reads; the core port (gptIntel, or gptM5 as for S11).<br>2611/1526 · N28 · **claudeIntel carrying read PASS**: six headlines, 190 constants at `5fb5915`; the span, the Jen window, the all-six instance and the equality construction (every trial in range fails at Q = 6(H+S)) checked, with my own exact control. [Read](research/kit-repair/R30-20261029-0ef6e2/endpoint/blocks/claudeIntel-i270-read.md). **Next:** gptM5's statement read; the core port and its read.<br>2611/1538 · M206 · **S27 packet built** from the reviewed Mathlib source (`8bc36732`): at the pin six headlines, 190 constants, notebook (7 outputs) and dry run pass; the essay marks the four hand steps and the possibly empty class. **Next:** gptM5's statement read of the packet; the core port for the kit (gptIntel).<br>2611/1556 · R134 · S27 statement read PASS on packet b. The limsup margin and endpoint reindexing are explicit. Portal release read with gptIntel. Core port is separate.<br>2611/1603 · M208 · **Posted at the owner's word**: S27 R30-20261126-8c236d, Lean Verified, from packet b; gptIntel's release read waived. **Next:** the core port for the kit (claudeM5, at the owner's word), then claudeIntel's carrying read of it.<br>2611/1623 · M209 · **Core port, part 1 PROVED IN LEAN** (core): `three_failures` from S19's `Farey.gap`, the whole argument given the envelopes, blocks of one length outright, and √10 − 3 with its Farey pairs. **Next:** part 2, the free-phase window bound in integers (a near-grid argument; failures do not simply alternate, COMPUTED), then the kit PR and claudeIntel's read. | S11, S19, S27 |
| K83 | 24 Nov, claudeCloud | With a fair coin on the right of a finite left half, do fresh cells keep reaching the wall: is Rule 30's entropy strictly above one bit, so that the words on two neighbouring columns outnumber 2ⁿ exponentially? (One pull since 26 Nov; it absorbs K83.A, K83.B and K83.C.) | *in progress* | 2411/2052 · K83 · The kit's almost-every laws put the fair coin on the left or the whole row; none had it on the right. [Note](research/rule4/README.md).<br>2411/2334 · I229–I235, N16 · **The almost-sure side (was K83.A).** In Lean with Mathlib, read by the other model both ways: a prescribed T-tick wall is met by right halves of mass exactly 2⁻ᵀ, with the exact change of measure, and almost-sure aperiodicity of the centre reduces to purely periodic words. The trap takes at least 62.85% of right halves beside an alternating column. A1 (no periodic centre almost surely) and A2 stay open. [Past-wall law](research/rule4/right-coin-past.md) · [K83RightCoin](research/rule4/K83RightCoin.lean) · [K83Feedback](research/rule4/K83Feedback.lean) · [basin](research/rule4/k83a-basin.md).<br>2411/2334 · I234, M178 · **The rate from above (was K83.B).** Topological entropy is the growth of two-column words and is below 1.143992 bits a tick (1.232039 in Lean); fair metric entropy at most 1.124884. By hand: a finite flip either reaches arbitrarily far west or escapes east, and its westward record advances at most 0.272394 cells a tick. [Results](research/rule4/k83b/README.md) · [flips](research/rule4/k83b/lower.md).<br>2611/0119 · M188, M194 · **S20** posted and Lean Verified; kit PR #426 in `equivalents/`.<br>2611/0937 · M191–M195, I257 · **What one wall hears (was K83.C).** The entropy is the growth of the OR-word count; every rational upper rate has a finite certificate; one disjoint pair per seven positions at unbounded widths would give Problem 1. **S22** is in the kit. [Proofs](research/rule4/k83b/hearing/finite-lookahead.md).<br>2611/1335 · N26 · On the seed the largest census nears 1/2 and passes 1/7 at 2^(s+2) ages for widths 10 to 20 (COMPUTED). Abundance at every width is open and is as strong as window normality. [Measurement](research/rule4/k83b/hearing/seed-census/README.md).<br>2611/1519 · K88, K89 · The coupled case beside an alternating column is parked as K84: the decoded west is a fair coin along the gate tree, and the excess grows at half the gate's entropy.<br>2611/1542 · K90 · **Consolidated at the owner's word.** Every upper bound asked for is proved and posted. Every lower bound is open and is one question in several forms: entropy above one bit (B3), positive westward speed, every flip heard, no atom at a periodic centre (A1), the growth of K84's excess, M181's successor. No route to it is known: short-memory pair languages have zero entropy, a returning cylinder cannot exist, and rings stop at four. [Assessment](research/rule4/consolidation.md).<br>2611/1602 · I273 · **S28 proposed.** Exact fair right-half laws under prescribed and feedback walls, conditional reduction to pure periods, and the finite-support test for a black-first alternating wall. Portal Lean and core companion pass. **Next:** Claude carrying read of the finite-support module and combined scope, then claudeM5's build. Park the remaining lower-bound question after S28, pending a hidden-state language or horseshoe that supplies exponentially many extra two-column words.<br>2611/1613 · K91 · For S28's carrying read: the core companion's three statements are two-way forms of the kit's `truncation_death`, `exact_death_center` and `alternates_iff_meets` (17 October), with #433's integer form; better an extension of `Rule30PeriodTwoSideways` than a new module. The measure part is untouched. [Review of #443 and #444](research/k50_1/kit-prs/claudeCloud-pr443-444.md). | S20, S22, S28 |
| K50.3 | 21 Nov, claudeCloud | What are the least ages for three or more inverse ticks beside an arbitrary prescribed wall? | *in progress* | 2611/1512 · N27 · **Three ticks: carrying read PASS**, with an exact restart enumeration (23 bands). **Four ticks: lower ages 72 and 73 PROVED IN LEAN** (`Rule30DrivenLeftFourLower`, same-wall witnesses at 71 and 72); I267's 76/77 replayed; no physical failure beyond 71/72 in about 1.5 million samples. [Read and note](research/k50_3/claudeIntel-i267-read.md). **Next:** a sharper four-tick upper cover (predicted 72/73); the three-tick sequel.<br>2611/1418 · I268 · S6 amendment and S23 merged in [#435](https://github.com/WolframInstitute/Rule30PrizeKit/pull/435) and [#436](https://github.com/WolframInstitute/Rule30PrizeKit/pull/436).<br>2611/1352 · I267 · **Three ticks:** sharp ages 31 for starts at least two sites away and 32 for adjacent starts, proved in Lean even with the inverse wall bits prescribed. **Four ticks:** upper ages 76 and 77, computed. [Proof and replay](research/k50_3/three-or-more-wall.md). **Next:** carrying read of three ticks, certify the four-tick cover in Lean and test its four surviving age-75 words for physical witnesses. | S6, S23 |

## Parked pulls

A pull that has reached a wall, gone cold, circular, or has become non-productive, but still has some unsatisfied
condition that would continue it is considered Parked, removed from Pulls in progress and added to this list. One
dated entry each, with the condition that would re-open it (METHOD §3, the incubator).

- **I72, bounded discrepancy at (1/3,0)** (parked 26 Nov, I272). Bounded discrepancy pins an eventual 011
  two sites east. Each observed column has exactly triple the eventual periods of the white-tick gate. The white half
  and a 64-cell ether prefix with a white tail each defeat periods 1–4,096 from sample 4,096 in ordinary finite-row replays.
  Reopen with an all-period argument for a fixed right half, or a physical extension lemma that breaks a specified period
  arbitrarily late inside every finite prefix. S9, S25 and S26 cover the completed parts. [Proofs and checks](research/source-density/one-third-gate-status.md)

- **K84, the coupled lifetime** (parked 26 Nov, K89, at the owner's word after K88). Is L(B) − B bounded, where L(B)
  is the longest alternation of a west of support at most B with some right half? Not at computable lengths: exact to
  B = 106 (I246, depth-80 cutoff with LRAT), the excess rises from 7–11 near B = 40, and sampled lower bounds replayed
  on the whole line give L(124) ≥ 145 and L(194) ≥ 218. The decoded west is a fair coin along the gate tree, so the
  excess is log₂ G less two or three (G the gate words; tested on an unseen sample). Floor: L(B) ≥ B + 7 for
  B ≡ 17 (mod 31), from the 155-column ring (PROOF-SKETCH). No submission. Reopen with a geometric bound on the
  coupled survivors (at most C·G·θˡ after l ticks past the support), which would give L(B) < ∞ for every B, or a
  uniform constraint on decoded white sections. [Note](research/rule4/k84/README.md) ·
  [I246](research/rule4/k84/gptIntel-k84-continuation.md)
- **M181, block orders beside an alternating column** (parked 26 Nov, K87, after the appraisal the owner asked for).
  Answered: not every order of A = 3555 and B = 355555 is read, since no right half turns the wheel fifteen times in a
  row (N19 addenda 4 and 5; LRAT accepted by both checkers; the formula read in K87). Open: is every order with B's
  apart (X = A, Y = AB) read? All 512 orders of nine have real rows and one row reads Y¹² X Y¹² (R130, R132); its least
  case, 3555 for ever, is K81's question. No submission: the refusal's proof is 19.4 GB of LRAT, and I239's prefix
  criterion in Lean is a lemma. The four rings (gates 2, 3, 5 and 2,5) are all there are to 48 ticks (K87). Reopen
  with a reason why a forcing prefix recurs, or one right half that reads 3555 for ever; a certified refusal of a word
  in X and Y; or a proof of the wheel's refusal small enough for the kernel.
  [Appraisal](research/wheel/block-orders/claudeCloud-appraisal.md) ·
  [notes](research/wheel/block-orders/README.md) · [trains](research/wheel/block-orders/claudeIntel-n19.md) ·
  [the infinite case](research/wheel/block-orders/isolated-infinite.md)
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
  checkers; formula read, K87).
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

- **I93, which kernel results in `research/black-run-transitions/` extend `Rule30RunTransitions`?** (closed 26 Nov,
  M206, at the owner's word; I258, I259, N24, I264.) S24, in the kit as `Rule30RunTransitionWindows` (#439):
  Kurtuluş's windows and sharp two-run cutoffs at every site, chosen letter by letter. S7 is in the kit too. The
  moving-shield rates (I98–I102) were always a separate question.
- **K83.A, K83.B, K83.C** (merged into K83 on 26 Nov, K90, at the owner's word). What each settled: the exact
  past-wall law and the reduction of almost-sure aperiodicity to pure periods (A, in Lean); the entropy's upper bounds
  and the flip dichotomy and speed bound (B; S20); the hearing bounds and the census test (C; S22). Their open ends
  are K83's one question.
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
