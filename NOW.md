# NOW

*Where things stand, the current work and main focuses of interest. One file, rewritten (not appended) by whoever
changes the state, stamped with the time and who changed it. Workers on the same host may share the same local git
repository - take care when writing. Earlier versions are in [archive/now/](archive/now/).*

*Phase 1 of rule30reset (17 to 26 November 2026: submissions S1 to S29, every pull parked or closed) is archived
whole in [archive/now/now-phase1-2026-11-26.md](archive/now/now-phase1-2026-11-26.md). The submissions are kept up to
date in [SUBMISSIONS.md](SUBMISSIONS.md). What stopped each pull is in [WALLS.md](WALLS.md).*

*Updated 2026-11-28 13:32 UTC by gptIntel (I343). K92.4 has an exact six-cell test for four alternating updates at a fall. K106 carried I338 and split I295.4's window-age target. M230 and N40 parked I295.5 and I295.3 at the owner's word.*

## Arrangement

The owner - Gareth - providing direction and instruction by prompting.

The AI assistant workers:

| Worker | Host | Ledger Code | Last Completed |
|---|---|---|---|
| claudeM5 | the owner's MacBook Pro M5 laptop, macOS | M | 2811/1317 · M230 · I295.5 parked at W2 at the owner's word (M229: dyadic mismatches are fair coins; nothing reaches the centre) |
| gptM5 | the M5 laptop, shared with claudeM5 | R | 2811/0945 · R142–R143 · K92.2: exponential families die on both unbounded width classes. The remaining late rows meet a small outer-band test. |
| claudeIntel | the owner's MacBook Pro Intel i9 laptop, AMD RX 6600 GPU, Windows and WSL Ubuntu | N | 2811/1315 · N40 · I295.3 parked at W3 at the owner's word (S33 posted; the prescribed-tick catch stays open), after N39's carried read and the width-23 marked birth
| gptIntel | the i9 laptop shared with claudeIntel | I | 2811/1332 · I341–I343 · K92.4: two-observer birth recurrence, distinct equal centre pairs from seven fall patterns, and white-arrival first failures. |
| claudeCloud | an Anthropic cloud container | K | 2811/1326 · K106 · I338 read PASS (covers exact; direct simulation agrees on every n to 1,100 and 3,000 and on the sharp G classes); I295.4: the settled left side carries the age to 2.5w, the wedge beyond 5w |

No worker and no host has a specialism (METHOD §1). ClaudeM5 is responsible for portal submissions and kit pull
requests, and keeps [SUBMISSIONS.md](SUBMISSIONS.md). What each host can run is in [TOOLS.md](TOOLS.md).

Each worker must update their 'Last Completed' at the end of a block of work.

## Needs the owner

This section may only contain calls to action that require the owner's input or decision and are removed when
answered.

- **Whether the new shape stands.** This file no longer holds the submissions, the parked pulls or the closed
  pulls: they are in SUBMISSIONS.md, WALLS.md and the archive. It is one commit to undo.
- **K92.5.B: park the growing hybrid subline at W1?** (claudeCloud, K102). Erosion and a terminal map decide 26
  of the 128 relatives (K101). Time (150, 180) has comparable degrees and survivor counts to Rule 30 at the tested
  widths. The Rule 30 cutoff proofs continue in .B. Also pending is whether the 26-case criterion becomes a control-module submission.

## Direction

- **Phase 2** (the owner, 26 November): "These partials, or the whole prize, are more possible now than they have
  ever been, with the combined input of everything we now know about the problem. So how do we find our way in to
  these final proofs?" Every pull is put to one question: **"Does this pull move us towards a solution or partial
  solution for a prize problem?"** A pull names its wall in [WALLS.md](WALLS.md), the first statement past that wall
  that it aims at, and what a failure would prove.
- **The goal:** Any Wolfram prize portal (accepts Mathlib) submission and/or WolframInstitute/Rule30PrizeKit git pull
  request (core Lean; Mathlib only in `equivalents/`), of the type requested by the maintainers - a general theorem
  or infinite family (for example, extending the transition rules of Rule30RunTransitions or a block grammar covering
  new families across all lengths) is the right fit.
- **The believed truth first** (the owner, 28 November): "I think we should stop looking for counterexamples to the
  walls, expecting there to be none, and focus on the believed truth first and foremost." A pull aims at the statement
  believed true, for example that every finite row dies, or at a step of it. A counterexample is never its target nor
  the other branch of its aim, and no block searches for one unless the owner asks. The full rule is in
  [METHOD §3](METHOD.md#3-the-instinct-method).
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

## Walls

The hard places, each one missing statement. [WALLS.md](WALLS.md) has, for each: the statement in plain words, what
is proved up to it, why it resists, what it would take, and the phase-1 pulls that stopped there with what would
reopen them. A pull that stops is filed there, under its wall.

| | Wall | The missing statement | What it stops |
|---|---|---|---|
| **W1** | The white tail | A finite row's own white cells must end a periodic centre; a uniform all-budget proof beyond its support is missing. | Problem 1: period two, and every period by the same reduction |
| **W2** | One orbit | What almost every row does cannot be carried to the single seed. | Problem 2; Problem 1 through its weakest sufficient conditions |
| **W3** | The doubling step | Prescribed-tick cancellation across clock doublings remains open. | The every-k chain; the left-edge routes to Problem 1 |
| **W4** | Hearing from below | We bound what the right side sends from above and cannot show that any given thing is sent. | No prize problem directly |
| **W5** | Lower bounds on computation | A lower bound for lookup at the named centre of the unaltered seed is missing at unbounded scales. | Problem 3 |

## Pulls in progress

One row per pull; its full originating text is in the ledger post named in the first column. The columns:

- **Written:** the date it was made and who made it.
- **Summary:** the pull's wall (W1 to W5), then the area of research being investigated, written as a question, then
  what a yes would give for a prize problem.
- **Status:** begins with *open* (a new pull) and can be moved to *preliminary* (one first research block run) or *in
  progress* (actively being worked on, usually by multiple workers).
- **Progress:** Every time a worker completes a block on a pull, they add a new line to the progress cell with the
  date/time (UTC) in ddmm/hhmm format, the ledger post ids written during the work block, a very brief summary of the
  work done, and a statement of what is required next to move the pull towards a solution or partial solution.
- **Submissions:** if a pull has led to 1 or more submissions add them to this list, kept in sync with
  [SUBMISSIONS.md](SUBMISSIONS.md).

If a pull itself invites a new area of research directly related to it, it should be added as a new pull with a
.{letter} postfix such as K83.A. A parent pull may only be parked or closed when all its related child-suffixed pulls
have been parked or closed.

A pull that stops leaves this table in the same rewrite. If a condition would reopen it, it is filed in WALLS.md
under the wall that stopped it, with where it stopped and that condition. If it is answered, with nothing left, the
post that answers it is its record, and what it proved goes into its wall's *Proved up to it*.

Each row stays on one line of this file, with six cells and no blank line between rows: a blank or broken line ends
the table. Inside a cell, start a new line with `<br>`.

| Pull | Written | Summary | Status | Progress | Submissions |
|---|---|---|---|---|---|
| **K92.2** | 26 Nov · claudeCloud, K92 | W1 · How quickly do finite rows fail checks past their support, and can that exclude period two? | in progress | 2611/2318 · I278–I279, I283 · Rule 30 has 3,517/2^24 twelve-check survivors in the even free cube. Explain the conditional bias. [Block](research/phase2/ladder/free-cube-results.md)<br>2711/2211 · I316, I320, I324 · Use the registered coalescence run to test distinct aged images. Seek unbounded n−E or A(n,n) ≤ 4095n at unbounded widths. [Count criteria](research/phase2/gemini/sparse.md)<br>2711/2342 · N38 · Exact A(k,n) for n≤38 (width 76), all k. The conditional bias is merged orbits: distinct rows D(n)=E(n,n,2n)≈1.762^n, and on them checks pass like fair coins; the last survivor is at log2 D(n) (k_max−n=−7 at 38). Next: an exact law for D(n) (M5's FindLinearRecurrence), then a bound on distinct aged rows (I320). [Survival](research/phase2/ladder/claudeIntel-survival-coalescence.md)<br>2811/0014 · M224 · D(1..32) exact on the M5 (D(32)=112,339,762). No constant-coefficient recurrence of order ≤14 fits all 32 terms; measured minimal DFA level widths reach ≈0.55 D(n). The wall half separates the rows at the sampled widths. [Recurrence and regularity](research/phase2/ladder/claudeM5-recurrence.md)<br>2811/0922 · R140–R141 · The even cube has wall-half collisions at the skipped n=5,6. At equal widths separation holds in both pinned phases through n=20 (computed). Lean: Q01 follows if the first 2n even checks rule out the two exact start widths 2n−1 and 2n at arbitrarily large n. Seek a uniform failure argument for these width classes. [Projection and widths](research/phase2/ladder/wall-projection.md)<br>2811/0945 · R142–R143 · For every n≥16, ≥2^floor((2n−3)/8) starts at each exact width 2n−1 and 2n die after the support. The odd family dies at tick 2n, the even family by 2n+30, sharply. An eight-width count localizes ≥2^n/128 failures at one width for one n in each adjacent pair. The three-cell bound restricts late survivors. Seek a post-support exclusion on those outer bands. [Unbounded widths](research/phase2/ladder/unbounded-exclusion.md) | — |
| **K92.4** | 26 Nov · claudeCloud, K92 | W2 · Can arbitrarily wide gaps force finite first failures at the centre? Which falls at −2 break period two? | in progress | I321, N39 · [Primitive births](research/phase2/gemini/launch.md) carried. Marked width 23 at birth 21,892,697 through 2²⁵ ticks. 2811/1332 · I343 · Width ≥2 births recur at 0 or +1. At −2 a fall can sustain four alternating updates only on 011001. Seek two falls an odd distance apart after every cutoff, or unbounded widths passing a black or delayed check. Carrying read with claudeIntel. [Proof and replay](research/phase2/gemini/unmarked-launch.md) | — |
| **K92.4.A** | 27 Nov · gptIntel, I324 | W2 · Can the fixed site −2 be forced to fall more often than logarithmically? This would improve both centre colour counts for Problem 2. | preliminary | 2711/2142 · I323 · Each colour has a lower bound in terms of the fall count. Seek a growing number of falls per late dyadic shell at −2, or directly at the centre. [Proof and census](research/phase2/gemini/launch.md) | — |
| **K92.5** | 26 Nov · claudeCloud, K92 | W1/W2 · Which outside methods supply a hypothesis we can prove for Problem 1? | in progress | 2611/2330 · I282, I284, I287 · Lean checks the sparse-width criterion and advancing fronts for rules 120/180. Seek sparse survivor widths of both parities. [Methods](research/phase2/borrowed/methods.md)<br>2711/2035 · K98, I313–I317 · Nine families read. A(n,n)≤4095n at unbounded n would give Q01. Bound the post-support survivors or their tick-24 images. [Handoff](research/phase2/borrowed/k98-nine-questions.md)<br>2711/2211 · I324 · Try to bound sideways white runs after conditioning on earlier checks. The target overlaps K92.2’s survivor count. [Conditional counting](research/phase2/ladder/sources.md)<br>2711/2328 · K98–K99 · Atlas scored, 9 of 11 held. 65 of 128 relatives have wall witnesses. The nonlinear candidates replayed as bounded cycles. At the atlas horizons 21 other relatives had neither a wall candidate nor a periodic line column. [Second block](research/phase2/borrowed/claudeCloud-second-block.md)<br>2711/2352 · K100 · I316's census equivalence and 24-tick fibre replayed in the kernel: PASS. [Replay](research/phase2/gemini/claudeCloud-clock-review.md)<br>2811/1125 · I331–I338 · Uniform failure laws via difference diagonals and moving strips. .B now covers both seven-spaced families at every width. [Transfer](research/phase2/borrowed/wall-cutoffs.md) | — |
| **K92.5.A** | 27 Nov · gptIntel, I324 | W1 · Can a two-coordinate affine rank certify mortality by descending strictly on one recurring residue class? A yes gives Q01. | preliminary | 2711/2035 · K98.3, I317 · The scalar and least-element cases fail. Test a nonzero terminal vector against the exact prefix extensions, then seek an all-width descent argument. [Rank test](research/phase2/borrowed/termination-transfer.md) | — |
| **K92.5.B** | 27 Nov · gptIntel, I324 | W1 · Which front and cutoff conditions prove white-wall mortality? Extend the proof to every single-spike addition past a seven-spaced cut. | in progress | 2711/2328 · I315, K99 · Both orders of 30/180 erode on the line. The sharp wall deadlines depend on the order. [Hybrid theorem](research/phase2/borrowed/k98-nine-questions.md)<br>2811/0927 · I325–I330, K101 · Growing (150, 180) has exact family deadlines. The front and terminal criterion decides 26 of 128 relatives. [Analysis and review](research/phase2/borrowed/claudeCloud-k925b-read.md)<br>2811/1024 · I331–I333, K102 · The hybrid periodic cuts fail by W+5 and the alternating Rule 30 cuts at W+2 or W+4. I333 read PASS. The growing hybrid subline has a parking proposal. [Cutoffs](research/phase2/borrowed/wall-cutoffs.md)<br>2811/1125 · I334–I338 · Seven-spaced Rule 30 cuts first lose a pin within 19 ticks of the omitted spike, or 49 with Galindo's added spike. Both are sharp. The light cone handles every added spike at offset 20 or deeper. Prove a bound for the remaining nearby positions. [Exact laws](research/phase2/borrowed/seven-spaced-cutoffs.md)<br>2811/1326 · K106 · I338 read by claudeCloud: PASS, with independent direct simulation of both families. [Read](research/phase2/borrowed/claudeCloud-seven-spaced-read.md) | — |
| **K92.5.C** | 27 Nov · gptIntel, I324 | W2 · When does a periodic centre mask force the full ternary bond to repeat? Forcing this for a family would exclude those periods. | open | 2711/2022 · I315 · The full bond is aperiodic. Test whether legal neighbouring bonds constrain the 0/2 choices on the white phases of a candidate periodic mask. [Half-step representation](research/phase2/borrowed/k98-nine-questions.md) | — |
| **K92.5.D** | 27 Nov · gptIntel, I324 | W2 · Can bounds on the singleton’s lag correlations make its mean squared window bias arbitrarily small? A yes gives Problem 2. | open | 2711/2035 · K98.5–6, I317 · The squared average uses actual centre ticks. Seek an upper bound on its weighted lag sum for increasing fixed window lengths. [One-trace criteria](research/phase2/borrowed/arithmetic-transfer.md) | — |
| **I295.4** | 27 Nov · gptIntel, I295 | W2 · Can repeated-snapshot collisions be bounded, or can enough terminal forks be forced, to give quadratic left vocabulary toward Problem 1? | preliminary | 2711/2138 · I322 · The late bound is linear. Bound long-lag collisions among w² ages or force jN eligible forks at width 2ʲ. [Vocabulary proofs](research/phase2/gemini/vocabulary.md)<br>2811/1311 · K104–K105 · To age 2²⁰ the first w² snapshots are pairwise distinct for every w from 17 to 48, and the first repeat sits at the birthday scale, √2 per cell against Galindo's 39/32. Next: prove that the w + 1 cells determine the age among ages below w². [Repeats](research/phase2/vocabulary/claudeCloud-snapshot-repeats.md)<br>2811/1326 · K106 · Early windows keep their age in the settled left side: at every width from 20 to 1,000, settled parts separate the ages w to 2.5w. Wheel j settles near 1.34j against the kit's 16j. The quadratic rung lies beyond 5w, in the unsettled wedge (W2). Next: a uniform settling bound. [Addendum](research/phase2/vocabulary/claudeCloud-snapshot-repeats.md) | — |
