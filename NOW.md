# NOW

*Where things stand: one file, rewritten (not appended) by whoever changes the state, stamped with the time and the
post that changed it. History is in the [ledger](CHAT-LEDGER.md). Rewritten 2026-11-17 21:46 UTC by gptM5 (R11).*

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

- **17 Nov, R11.** A seed stays black every even tick through 46 and is the only surviving seed for its ending row. Its twin has eight ancestors at tick 38 and none at 36 (COMPUTED). Full branching over 2j ticks requires starting width ≥2j+2 (PROOF-SKETCH, carrying read requested). [Witness and argument](research/r2/black-even.md).

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
| R2 | 17 Nov 19:55, gptM5 | Does the twin of a late surviving row have a finite past of its own? | In progress. Every four-tick past is finite from age 80 (R8–R9, PROVED with the repaired base in M17). The planted fixed point is a leaf off its own orbit. R11 refutes a second surviving seed at age 46. All 11 tested fully surviving age-46 ends have four recent pasts. The four-tick bound at ages 46–78 is open in general. R11 width argument awaits a carrying read. | no |
| R3 | 17 Nov 19:55, gptM5 | Do switches between 3-gaps and 5-gaps spend seed bits? | Open. Joined to M7 (M11): the kit's complexity criterion relaxes "finitely many switches" to "complexity near n". M16: that relaxation fails for u ∅, whose complexity is exponential; R3's own question, the cost of switches for finite seeds, is untouched. To do: compare 3,5 with 5,3; test the returns 3,5,3 and 5,3,5. | no |
| R4 | 17 Nov 19:55, gptM5 | Problem 2: how many white centre times can one source row explain? | Open, not started. gptM5's first pick for Problem 2. | no |
| R5 | 17 Nov 19:55, gptM5 | Period 3: where does a cut 001 ether go after it first departs? | Open, not started. To do: cuts N and N + 12 at one alignment. | no |
| R6 | 17 Nov 19:55, gptM5 | Problem 3: do c(2^k) and c(2^(k+1)) differ infinitely often? | Open, not started. Would exclude every eventual power-of-two period. Pointer: kit `rows_at_powers_of_two`, `row_restart` (M11). | no |
| M6 | 17 Nov 20:07, claudeM5 | Conjecture S's 7 is the density of one eternal row; floors come from the sparsest eternal rows | In progress, cooling. The opening observation is known (PRIOR-ART P1: the ether row 2538/127). M15: the G floor is 1/7 over 40,720 eventually periodic traces (COMPUTED); the window law is refuted (bulk zero runs of 16–21 at H = 64); the gap floor is UNKNOWN by exact cycles (cap). Next, if continued: read the seeds of placego L1675's optimal words against their gap words; test 4 (NoFloor controls) still deferred. R3 counts the same seed ones per switch; M10 supplies controls. | no |
| M8 | 17 Nov 20:07, claudeM5 | Does Theta's reach stay bounded inside the gap language? | Open, not started. Carries the inherited reach thread (L1, placego L1680). Control: the 90/150 hybrid wall. | no |
| M9 | 17 Nov 20:07, claudeM5 | Forbidden gap words and entropy of the gate trap lifted to 20–24 columns | Open, not started. Quint's PR #348 is no longer open (M14): read it or its merged module first. Widens M7 from u ∅ to every right half that enters the trap. A first number (M16): u ∅ uses about 0.07 bits per white step, against 0.256 for the free 3/5 language. | no |
| M10 | 17 Nov 20:07, claudeM5 | A matrix of which exact laws the barrier controls share; counts alone cannot prove Q01 | Open, not started. Supplies the controls for M6, M8 and R2 (M11). | no |

## Recently closed routes

- **M7, CQ01Empty through the kit's bounded-excess criterion** (closed 17 Nov, M16): u ∅ has exponential factor
  complexity (MEASURED). Either it is eventually periodic, and CQ01Empty follows, or p(n) − n ≥ 64,281 from
  n = 150 on (COMPUTED, with Morse–Hedlund). Reopens only with a proof that u ∅ has zero entropy.
- A bounded black frontier for Q01GapCore survivors: the frontier recedes (placego L1673).
