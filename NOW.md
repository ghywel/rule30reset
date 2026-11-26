# NOW

*Where things stand, the current work and main focuses of interest. One file, rewritten (not appended) by whoever
changes the state, stamped with the time and who changed it. Workers on the same host may share the same local git
repository - take care when writing. Earlier versions are in [archive/now/](archive/now/).*

*Phase 1 of rule30reset (17 to 26 November 2026: submissions S1 to S29, every pull parked or closed) is archived
whole in [archive/now/now-phase1-2026-11-26.md](archive/now/now-phase1-2026-11-26.md). The submissions are kept up to
date in [SUBMISSIONS.md](SUBMISSIONS.md). What stopped each pull is in [WALLS.md](WALLS.md).*

*Updated 2026-11-26 22:46 UTC by claudeCloud (K92): reset for phase 2 at the owner's word. The Direction's earlier
bullets are the owner's, last edited at 22:41 UTC on 25 November.*

## Arrangement

The owner - Gareth - providing direction and instruction by prompting.

The AI assistant workers:

| Worker | Host | Ledger Code | Last Completed |
|---|---|---|---|
| claudeM5 | the owner's MacBook Pro M5 laptop, macOS | M | 2611/2123 · M215 · S29 posted, Lean Verified; kit PR #449 |
| gptM5 | the M5 laptop, shared with claudeM5 | R | 2611/2117 · R137 · S29 final release read PASS on packet c and revised core kit patch |
| claudeIntel | the owner's MacBook Pro Intel i9 laptop, AMD RX 6600 GPU, Windows and WSL Ubuntu | N | 2611/2040 · N31 · K50.3 to S29: R136 carrying read PASS; S29 proposed (two theorems for every k); K50.3 parks once the packet is built |
| gptIntel | the i9 laptop shared with claudeIntel | I | 2611/2352 · I293 · K92.3 record exit and all-time gate equality checked |
| claudeCloud | an Anthropic cloud container | K | 2611/2246 · K92 · Phase 2 opened at the owner's word: NOW.md reset, WALLS.md and SUBMISSIONS.md made, five pulls proposed |

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
| **W1** | The white tail | A finite row's own white cells must end a periodic centre; nothing is proved once its last black cell has been read. | Problem 1: period two, and every period by the same reduction |
| **W2** | One orbit | What almost every row does cannot be carried to the single seed. | Problem 2; Problem 1 through its weakest sufficient conditions |
| **W3** | The doubling step | No left-edge result passes from clock 2ᵉ to 2ᵉ⁺¹. | The every-k chain; the left-edge routes to Problem 1 |
| **W4** | Hearing from below | We bound what the right side sends from above and cannot show that any given thing is sent. | No prize problem directly |
| **W5** | Lower bounds on computation | No technique bounds from below the cost of one fixed sequence. | Problem 3 |

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
| **K92.1** | 26 Nov · claudeCloud, K92 | W1 · Does kick-anchored weight grow enough to exclude period two? | preliminary | 2611/2318 · I276–I279, I283 · Exact at every even H≤182. At H=300 the minimum is 97–103. Test whether surplus can pay for long white gaps. [Block](research/phase2/floor/results.md) | — |
| **K92.2** | 26 Nov · claudeCloud, K92 | W1 · How quickly do finite rows fail checks past their support, and can that exclude period two? | preliminary | 2611/2318 · I278–I279, I283 · Rule 30 has 3,517/2^24 twelve-check survivors in the even free cube. Explain the conditional bias. [Block](research/phase2/ladder/free-cube-results.md) | — |
| **K92.3** | 26 Nov · claudeCloud, K92 | W1 · Do 48 clean readings or a certified lock arrive by a linear deadline? This would give RD. | in progress | 2611/2326 · I280–I286 · All 2^24 finite easts certify by tick 5,539, sharp through D=24. Identify what forces the shared record gate to exit. [Block](research/phase2/deadline/results.md)<br>2611/2352 · I288–I293 · White at 25–26 forces entry 11 samples later for the records. Bound how many exits a finite nonlocking east can decline in X. [Evidence](research/phase2/deadline/record-entry.md) | — |
| **K92.4** | 26 Nov · claudeCloud, K92 | W2 · Can dyadic edge clocks predict unbounded marked gaps on the single seed, sufficient for Problem 1? | preliminary | 2611/2320 · I281–I285 · Max mark 22, longest finite first failure 53 through 2^22. Selected phase failed on holdout. Recommend parking pending a new edge predictor. [Block](research/phase2/marks/seed-results.md) | — |
| **K92.5** | 26 Nov · claudeCloud, K92 | W1/W2 · Which outside methods supply a hypothesis we can prove for Problem 1? | preliminary | 2611/2330 · I282, I284, I287 · Lean checks the sparse-width criterion and advancing fronts for rules 120/180. Seek sparse survivor widths of both parities. [Methods](research/phase2/borrowed/methods.md) | — |
