# NOW

*Where things stand, the current work and main focuses of interest. One file, rewritten (not appended) by whoever
changes the state, stamped with the time and who changed it. Workers on the same host may share the same local git
repository - take care when writing. Earlier versions are in [archive/now/](archive/now/).*

*Phase 1 of rule30reset (17 to 26 November 2026: submissions S1 to S29, every pull parked or closed) is archived
whole in [archive/now/now-phase1-2026-11-26.md](archive/now/now-phase1-2026-11-26.md). The submissions are kept up to
date in [SUBMISSIONS.md](SUBMISSIONS.md). What stopped each pull is in [WALLS.md](WALLS.md).*

*Updated 2026-11-27 23:52 UTC by claudeCloud (K100): I321's five-tick clock theorem passes the carrying read and is ready to propose; I316's census and fibre replayed. Before that 2026-11-27 23:42 UTC by claudeIntel (N38): K92.2's survival tables to width 76; the conditional bias is merged orbits.
Before that 23:28 UTC by claudeCloud (K99): K92.5's second block; the 30/180 front read (K92.5.B) passes; the hard class of relatives and (150, 180) added to K92.5.B. Before that 2026-11-27 22:11 UTC by gptIntel (I324). Added the follow-ups from K98 and the Gemini block.
K92.4 is open again on unbounded marked births. [Research results](research/phase2/gemini/five-questions.md)*

## Arrangement

The owner - Gareth - providing direction and instruction by prompting.

The AI assistant workers:

| Worker | Host | Ledger Code | Last Completed |
|---|---|---|---|
| claudeM5 | the owner's MacBook Pro M5 laptop, macOS | M | 2711/1829 · M223 · S32's kit PR #458 opened; I295.2 parked at W1; S32 (R30-20261127-157e8c) awaits a maintainer's rerun |
| gptM5 | the M5 laptop, shared with claudeM5 | R | 2711/1753 · R138 · S32 packet b passes the technical release read; timing decision pending |
| claudeIntel | the owner's MacBook Pro Intel i9 laptop, AMD RX 6600 GPU, Windows and WSL Ubuntu | N | 2711/2342 · N38 · K92.2: survival past the support exact to n=38; survivors are clusters of merged orbits and fair coins on distinct rows; the last survivor sits at log2 of the distinct rows
| gptIntel | the i9 laptop shared with claudeIntel | I | 2711/2211 · I324 · Added the K98 and Gemini proof targets to the pull table (research I313–I323). |
| claudeCloud | an Anthropic cloud container | K | 2711/2352 · K100 · I321 five-tick read PASS, with five repairs for the essay; five ticks and seven wheels are the local optimum; I316's census and fibre replayed PASS |

No worker and no host has a specialism (METHOD §1). ClaudeM5 is responsible for portal submissions and kit pull
requests, and keeps [SUBMISSIONS.md](SUBMISSIONS.md). What each host can run is in [TOOLS.md](TOOLS.md).

Each worker must update their 'Last Completed' at the end of a block of work.

## Needs the owner

This section may only contain calls to action that require the owner's input or decision and are removed when
answered.

- **Whether the new shape stands.** This file no longer holds the submissions, the parked pulls or the closed
  pulls: they are in SUBMISSIONS.md, WALLS.md and the archive. It is one commit to undo.

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
| **K92.2** | 26 Nov · claudeCloud, K92 | W1 · How quickly do finite rows fail checks past their support, and can that exclude period two? | preliminary | 2611/2318 · I278–I279, I283 · Rule 30 has 3,517/2^24 twelve-check survivors in the even free cube. Explain the conditional bias. [Block](research/phase2/ladder/free-cube-results.md)<br>2711/2211 · I316, I320, I324 · Use the registered coalescence run to test distinct aged images. Seek unbounded n−E or A(n,n) ≤ 4095n at unbounded widths. [Count criteria](research/phase2/gemini/sparse.md)<br>2711/2342 · N38 · Exact A(k,n) for n≤38 (width 76), all k. The conditional bias is merged orbits: distinct rows D(n)=E(n,n,2n)≈1.762^n, and on them checks pass like fair coins; the last survivor is at log2 D(n) (k_max−n=−7 at 38). Next: an exact law for D(n) (M5's FindLinearRecurrence), then a bound on distinct aged rows (I320). [Survival](research/phase2/ladder/claudeIntel-survival-coalescence.md) | — |
| **K92.2.A** | 27 Nov · gptIntel, I324 | W1 · Can a failure deadline be proved for every black-cell budget on the bare white wall? A yes gives Q01. | preliminary | 2711/2128 · I320 · Sharp deadlines through 18 black cells. Bound the delay from one more black site by a uniform argument on the sparse tree. [Weight floor](research/phase2/gemini/sparse.md) | — |
| **K92.4** | 26 Nov · claudeCloud, K92 | W2 · Do arbitrarily wide black bars launch gaps with a black arrival at the centre? Unbounded marked births give Problem 1. | in progress | 2711/2142 · I321, I323 · Reopened in I324 via the exact launch law. Prove unbounded launches and a recurring forcing context on those same rows. Carrying read with claudeIntel. [Birth criterion](research/phase2/gemini/launch.md) | — |
| **K92.4.A** | 27 Nov · gptIntel, I324 | W2 · Can the fixed site −2 be forced to fall more often than logarithmically? This would improve both centre colour counts for Problem 2. | preliminary | 2711/2142 · I323 · Each colour has a lower bound in terms of the fall count. Seek a growing number of falls per late dyadic shell at −2, or directly at the centre. [Proof and census](research/phase2/gemini/launch.md) | — |
| **K92.5** | 26 Nov · claudeCloud, K92 | W1/W2 · Which outside methods supply a hypothesis we can prove for Problem 1? | in progress | 2611/2330 · I282, I284, I287 · Lean checks the sparse-width criterion and advancing fronts for rules 120/180. Seek sparse survivor widths of both parities. [Methods](research/phase2/borrowed/methods.md)<br>2711/2035 · K98, I313–I317 · Nine families read. A(n,n)≤4095n at unbounded n would give Q01. Bound the post-support survivors or their tick-24 images. [Handoff](research/phase2/borrowed/k98-nine-questions.md)<br>2711/2211 · I324 · Try to bound sideways white runs after conditioning on earlier checks. The target overlaps K92.2’s survivor count. [Conditional counting](research/phase2/ladder/sources.md)<br>2711/2328 · K98–K99 · Atlas scored, 9 of 11 held. 65 of 128 relatives have a wall immortal; in every nonlinear one it is a bounded cycle. 21 relatives form a hard class with no immortal and no periodic column. Next: the children, and a wall proof for one of the hard class. [Second block](research/phase2/borrowed/claudeCloud-second-block.md)<br>2711/2352 · K100 · I316's census equivalence and 24-tick fibre replayed in the kernel: PASS. [Replay](research/phase2/gemini/claudeCloud-clock-review.md) | — |
| **K92.5.A** | 27 Nov · gptIntel, I324 | W1 · Can a two-coordinate affine rank certify mortality by descending strictly on one recurring residue class? A yes gives Q01. | preliminary | 2711/2035 · K98.3, I317 · The scalar and least-element cases fail. Test a nonzero terminal vector against the exact prefix extensions, then seek an all-width descent argument. [Rank test](research/phase2/borrowed/termination-transfer.md) | — |
| **K92.5.B** | 27 Nov · gptIntel, I324 | W1 · Which local front conditions give white-wall mortality for Rule 30 relatives? A uniform criterion would give a control for the period-two route. | preliminary | 2711/2022 · K98.1, I315 · Both orders of 30/180 erode on the line. The wall deadline depends on the order. Review kit fit and isolate the front and terminal conditions. [Hybrid theorem](research/phase2/borrowed/k98-nine-questions.md)<br>2711/2328 · K99 · Read by claudeCloud: PASS, with an independent check; the four-tick speed is sharp. Next target: time (150, 180), which does not erode on the line, dies at the wall to width 22 and has the same 7→2→7 trap reversed. [Read](research/phase2/borrowed/claudeCloud-second-block.md) | — |
| **K92.5.C** | 27 Nov · gptIntel, I324 | W2 · When does a periodic centre mask force the full ternary bond to repeat? Forcing this for a family would exclude those periods. | open | 2711/2022 · I315 · The full bond is aperiodic. Test whether legal neighbouring bonds constrain the 0/2 choices on the white phases of a candidate periodic mask. [Half-step representation](research/phase2/borrowed/k98-nine-questions.md) | — |
| **K92.5.D** | 27 Nov · gptIntel, I324 | W2 · Can bounds on the singleton’s lag correlations make its mean squared window bias arbitrarily small? A yes gives Problem 2. | open | 2711/2035 · K98.5–6, I317 · The squared average uses actual centre ticks. Seek an upper bound on its weighted lag sum for increasing fixed window lengths. [One-trace criteria](research/phase2/borrowed/arithmetic-transfer.md) | — |
| **I295.3** | 27 Nov · gptIntel, I295 | W3 · Can phases separated by the old clock both miss the first interval? Does a catch on the prescribed tick follow in the next interval, giving every-depth inverse exactness? | in progress | 2711/2129 · I321 · Five-tick capture holds at every clock order. Carrying read with claudeCloud. Trace the surviving histories through the next white wheel with a shared rooted clock. [Clock proof and controls](research/phase2/gemini/clock.md)<br>2711/2352 · K100 · Carrying read by claudeCloud: PASS, with five repairs for the essay. Five ticks and seven wheels are the best a local argument gives. Ready for an S-proposal, portal and kit. The prescribed tick stays open. [Review and draft abstract](research/phase2/gemini/claudeCloud-clock-review.md) | — |
| **I295.4** | 27 Nov · gptIntel, I295 | W2 · Can repeated-snapshot collisions be bounded, or can enough terminal forks be forced, to give quadratic left vocabulary toward Problem 1? | preliminary | 2711/2138 · I322 · The late bound is linear. Bound long-lag collisions among w² ages or force jN eligible forks at width 2ʲ. [Vocabulary proofs](research/phase2/gemini/vocabulary.md) | — |
| **I295.5** | 27 Nov · gptIntel, I295 | W2/W5 · At unbounded P = 2ᵏ, does some t in [P,2P) give different centre bits at t and t+P? A yes excludes dyadic periods and gives a logarithmic lookup bound. | preliminary | 2711/2138 · I317, I322 · The joint-observable bound and scanner control give the scale. Try black centre readings at both ages with different western neighbours to force the mismatch one tick later. [Lookup bounds](research/phase2/gemini/indexed-cost.md) | — |
