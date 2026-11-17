# NOW

*Where things stand: one page, rewritten (not appended) by whoever changes the state, stamped with the time and the
post that changed it. History is in the [ledger](CHAT-LEDGER.md). Rewritten 2026-11-17 20:10 UTC by claudeM5 (M11).*

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
| none yet | | | | |

Verifier's kit commit: `5fb5915` (5 November), read 17 November 15:18 UTC; the kit's main is `8ff5467` since gptM5's
update step (R1). Stages: proposed, packet, read, agreed, owner's word, posted, Lean Verified, pull request, merged.

## Latest results (newest first)

- **17 Nov, M6. Conjecture S's sharpness witnesses are one row, truncated** (COMPUTED): black at depths 1, 2, 4,
  then every 7 places. The infinite row stays G-valid to depth 2000 (MEASURED, not proved), so the constant 7 is
  probably the density of one eternal row, as NoFloor's 9 and 14 are for theirs.
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

- **The owner's round of warm pulls (17 November); the choice of direction is the owner's, pending.** gptM5's five
  are R2–R6, with the second-predecessor test in R2 first. claudeM5's five are M6–M10, written before reading R2–R6:
  M6, Conjecture S's 7 as an eternal row's density, first; then M7, CQ01Empty through the factor complexity of the
  empty right half's word u ∅; M8, healing of Theta inside the gap language; M9, the lifted gate-trap languages;
  M10, a matrix of which laws the barrier controls share. M11 compares the lists (R3 meets M7; R2 meets M10) and
  proposes a first block: M6 and M7's first tests by claudeM5, R2's test by gptM5 with the planted survivor as
  control.
- Inherited with Local's workflow (L1): a reach map on the page, then the reach of later free bits by sampling to
  depth 81 (placego L1680). M8 would give it a question: the reach inside the gap language.
- Inherited with Local's workflow (L1): replay the kit's surviving-seed law against the tables of placego L1675.
- Visualisations proposed, not built: an interactive map of the open statements; the branching-walk fan; Mahler's
  valid starts on the circle; a timeline of kit contributions by theme.

## Recently closed routes

- A bounded black frontier for Q01GapCore survivors: the frontier recedes (placego L1673).
