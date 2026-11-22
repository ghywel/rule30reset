# NOW

*Where things stand: one file, rewritten (not appended) by whoever changes the state, stamped with the time and the
post that changed it. History is in the [ledger](CHAT-LEDGER.md). Reset at the owner's word on 20 November 2026 (K33);
the file as it stood is [archive/now/now-before-reset-2026-11-20.md](archive/now/now-before-reset-2026-11-20.md).
Rewritten 2026-11-22 11:15 UTC by claudeCloud (K62: K50.4 preliminary; K50.3's test and the sieve, K60, are running).*

## Arrangement

| Worker | Host | Since |
|---|---|---|
| claudeM5 | the owner's M5 laptop, the Wolfram host, in the owner's session | 17 November (M1) |
| gptM5 | the M5 laptop, with claudeM5 | 17 November (R1) |
| claudeCloud | a cloud container; reclaimed when idle. **Conducts for the moment** (the owner, 19 November) | 18 November (K1) |
| gptIntel | the Intel i9 with the RX 6600, running Windows and Ubuntu on WSL 2 (I43) | 19 November (I1) |

No worker and no host has a specialism (METHOD §1). What each host can run is in [TOOLS.md](TOOLS.md).

- **Running jobs:** on the cloud host, the sieve's judge (K60) and the first tests of K50.3 and K50.4 (K61). None on
  the M5 or the Intel (the owner, 22 November), where four outcomes are not recorded yet: on the Intel,
  R6's centre column to 2^27 (last recorded c(2^26) = 1, I66) and M9's 36-column automaton and entropy (I61, I70);
  on the M5, M78's 36-column run and M80's three instances of runs of five.
- **Schedules:** none. gptIntel's overnight heartbeat is off (the owner, 22 November).
- **The store:** on the owner's NAS, image `981c5eb`. Its image workflow runs on a change under `tools/store/` and
  once a week (M52).

## Needs the owner

Calls to action only.

- **Say what becomes of K50.4** (K62): park it, as I recommend, or pick up the tree or the zone statistic.
- **Say what becomes of gptIntel's overnight threads** (listed under Open threads): which become pulls, who reads
  each, and whether any is to be prepared as a submission. gptIntel names two candidates: the seven-lock prefix
  packet (I52) and the sharp three-gap resets (`research/white-gap-mixtures/cold-reset.md`, no post yet).
- **Every 30 days:** confirm the dynamic-DNS name, or every worker loses the store (K10).

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
| (T) ⇐ (CAP): some width has reset capacity k, for every k | In Lean and in the kit: **S2**. |
| (CAP) ⇐ (L∞): reset words at arbitrarily large depths in every phase of every pointed recurrent strip | In Lean: **S4**, Lean Verified, and in the kit since `05c9c73` (#375; M75). |
| (L∞) ⇐ (DL⁻₁): a tick that the doubled stretch after a first clock loss misses is caught in the next stretch | In Lean: **S5**, Lean Verified. In the kit since `40017e8` ([#377](https://github.com/WolframInstitute/Rule30PrizeKit/pull/377), I44). |
| (DL⁻₁) | **OPEN: the wall.** Its strict form is COMPUTED for every source of dyadic period up to 32 (K5); for five black or five white marks at every dyadic period (I32, R59); for quiet sources at every period (K18, I20); and at every first clock loss on every rooted strip through clock 16 (K27). Nothing is settled from seven marks on, and the mark-count line is closed (I35). A counterexample needs a dyadic source period of at least 64. |

## The next block

**Not set.** The last block ended on the morning of 22 November with nothing running. Before the next one starts:

1. **gptIntel posts its missing entries,** I80 onward: twelve commits between 02:47 and 05:43 UTC on 22 November
   have no post (the owner is prompting it).
2. **The four stopped jobs are accounted for** (Arrangement): each host's worker records where its job ended.
3. **The reads owed are shared out.** Of gptIntel's overnight results only I67 and I69 have a second reader (K56
   addendum 1, K58). Nothing unread goes further (METHOD §12).
4. **The owner chooses** (Needs the owner).

Last posts: claudeM5 M86 and gptM5 R71 (21 November); gptIntel I79 (22 November, 02:46 UTC); claudeCloud K59. Open
with the maintainers: kit issue [#380](https://github.com/WolframInstitute/Rule30PrizeKit/issues/380), on how a law
with a certified CNF hypothesis can enter the kit (M86). No reply is recorded.

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

The verifier's kit commit is `5fb5915`. The kit's main is `40017e8`, and KIT.md is in step with it (I44).

## Pulls in progress

One row per pull; its full text is the ledger post named in the first column, in the live ledger or its archives.
Status begins with *open*, **preliminary** (one first block run) or *in progress*, and says the next test. A
parked or closed pull leaves the table for the lists below. The rules are in METHOD §8.

| Pull | Written | Summary | Status | Submission? |
|---|---|---|---|---|
| K5 | 19 Nov, claudeCloud | The resolution law: how the last catch depends on source period P | **In progress** (K29, read in R61). The first-excursion census agrees closely with the fair-input model. Its measured tail is about 1.36 κ^x, κ ≈ 0.847810. A uniform bound remains open. Next test: compare the trace restricted to doubled inputs with the census before using the mixing rate for a pooled bound. Carries K2’s conjecture on white returns. | no |
| R5 | 17 Nov, gptM5 | Period 3: where does a cut 001 ether go after it first departs? | **Preliminary** (K35, K38). Every cut to N = 240 ends in the same 21-tick cycle on columns 1–24, never in the 15-trap. Departure advances 30 ticks for each 12 columns. The wait from departure behaves like chance, mean 20,900 ticks, and cuts N and N + 12 share no later history. Cool. Next tests: is the wait the same from random strips, and can the 15-trap be entered from outside? | no |
| M9 | 17 Nov, claudeM5 | The late gate language under an alternating centre, inside and outside the trap | **In progress** (K47, M79, M81, M85, K54, K56; outside: K52, [R69](research/m9/exterior-grammars.md)). Inside, the gate settles within 50 samples of entry to a fixed, structured process and stays there to 10^7 ticks (K56). Its laws are read by SAT, each certified by LRAT: at most three closed runs of four, and four never after two samples (M81; in Lean from one CNF, M85, [read](research/m9/runs-of-four-review.md) in R71); 19 of the 81 quadruples over runs 4–6 by delay 20 (K54, I65); the pair (5, 1) from delay 12, (3, 1, 4) from 9, (10, 1, 5) from 20 and (5, 5, 5, 6) from 39 (K56, I66, I75). The column ladder misses the short ones: (5, 1) needs 37 columns (I70). No rule behind the table yet. Absence from real rows is not a law: (11, 1) never occurs and is SAT at delay 80. Outside, X and Y have their grammars to 43 columns. Now: the sieve run to the end on the cloud host, 98 candidates frozen in K60 (the owner, 22 November). After it: a hand reason for (5, 1); the kit route waits on issue #380. | no |
| M10 | 17 Nov, claudeM5 | Which exact laws distinguish Rule 30 from controls with an immortal finite row? | **In progress** as a standing instrument (K44, R63, M77). The [matrix](research/m10/control-laws.md) gives the spatial reset and first-check degree for every width. The hybrid has a sharp tick-2 reset and degree 1. Planting changes only the top monomial from n=L onward (PROVED: Lean, read in M77). Next use: compare the hypotheses of the next Q01 proof route against these controls. | no |
| K50.1 | 21 Nov, claudeCloud | RD: does every finite right half end in the gate trap or in a periodic gate? | **Preliminary** ([R65](research/k50_1/right-dichotomy.md), K52, [R69](research/m9/exterior-grammars.md)). Proved for every ether cut (I46 read) and computed through support width 26. A counterexample needs one finite right half sustaining an aperiodic gate in X or Y. The finite-window grammars now constrain that realization question. Beside it, unread: gptIntel's prefix criterion for the period-seven lock and a deadline for the true centre (I49 to I64, Lean in `research/k50_1/`). | no |
| K50.2 | 21 Nov, claudeCloud | Lowry's events (`Rule30EventReturns`), read in gate coordinates | **Preliminary** ([R67](research/k50_2/event-returns.md)). The trapped event code is invertible at every width. Physical gates exclude 5, two or more 2s, 5. I46 checked the exclusion in Lean and exhibited a finite GE2 trace with 5,2,2,5. Next test: tighten the GE2 finite-left survivor check with this exclusion. Feeds M9. | no |
| K50.3 | 21 Nov, claudeCloud | One inverse theorem for every wall: does the chain for (T) need the white wall? | **Open,** preliminary round under way on the cloud host (the owner, 22 November). The reading is done: only narrow rows touch the wall (K61). The exact test of the ages beside every wall is frozen in K61. Relates to the parked M29. | no |
| K50.4 | 21 Nov, claudeCloud | Every white triangle has one family tree (Quint's backward cascade) | **Preliminary** (K62). The cascade is exact and almost unbranched: 48 rows reach all black in 39 ticks, 3,552 in 199,999. But a black run's patch shrinks by about 1.4 cells a row going back, so a triangle cannot be exchanged for a longer patch earlier: the long shot at the density bound is refuted in this form. [Pictures](research/k50_4/triangles-overview.png) made. By-product: windows above black runs are uniform in the right third of the seed's diagram and far from it in the left third. The owner to say whether it is parked. | no |

## Parked

One dated line each, with what would bring it back (METHOD §3, the incubator).

- **M29, the every-k statement (T)** (parked 21 Nov, the owner). In the kit from one open lemma, (DL⁻₁): see The
  chain; submissions S2, S4, S5. Comes back with a proof idea for (DL⁻₁), or a counterexample, which needs a dyadic
  source period of at least 64. Data kept: f(k) for k ≤ 11, and f(k) ≤ 265,441 for k ≤ 7,911 (M40).
- **R3, do changes of gap spend seed bits?** (parked 21 Nov; K36). No: the gaps behave as fair coins, with the exact
  constant λ/4. Comes back with a reason why white seed bits cannot be accepted for ever.
- **R6, do c(2^k) and c(2^(k+1)) differ for ever?** (parked 21 Nov; K39). Tabulated to k = 26: c(2^26) = 1, and 18
  changes in the first 27 values (I45, I66); no rule in the split of the slab. The Intel's run to 2^27 has stopped; its
  outcome is not recorded yet. Comes back with a cancellation in the slab that survives doubling.

## Open threads

- **gptIntel's overnight threads** (21 to 22 November; not pulls yet, and unread unless marked). Posts are in ledger
  archive 6.
  - Early repeats and excursion clocks on Lowry's #379 (I48, I51, I53; `research/m9/Rule30ExcursionClocks.lean`).
  - Lowry's arrival parity under periodic and alternating centres (I66 to I68; I67 read in K56 addendum 1), and
    source priority (I69, read in K58; I71). In `research/arrivals/`.
  - The density region of Condrey's run ends (I72); what two sites or one column can recognise (I73 to I76).
  - Mixtures of white gaps and sparse clocks (I77 to I79, and later work without a post), in
    `research/white-gap-mixtures/`; transitions of black runs, in `research/black-run-transitions/` (no post).

- **The round's curiosities and misgivings** (K25 §5, in ledger archive 4) are not pulls yet: time order matters
  (I25); period 5's four poor rows (K21); two late single sources at P = 21 and 23 (K29).
- **K6:** METHOD §12 has three handoffs in practice (R45, I2, M45). Writing them into §12 is the conductor's call;
  not done.
- **Visualisations proposed, not built:** a map of the open statements; the branching-walk fan; Mahler's valid starts
  on the circle; a timeline of kit contributions by theme.

## Recently closed routes

One line each, with what would reopen it.

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
