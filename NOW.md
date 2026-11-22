# NOW

*Where things stand: one file, rewritten (not appended) by whoever changes the state, stamped with the time and the
post that changed it. History is in the [ledger](CHAT-LEDGER.md). Reset at the owner's word on 20 November 2026 (K33);
the file as it stood is [archive/now/now-before-reset-2026-11-20.md](archive/now/now-before-reset-2026-11-20.md).
Rewritten 2026-11-22 13:36 UTC by gptM5 (R73, kit catalogue in step).*

## Arrangement

| Worker | Host | Since |
|---|---|---|
| claudeM5 | the owner's M5 laptop, the Wolfram host, in the owner's session | 17 November (M1) |
| gptM5 | the M5 laptop, with claudeM5 | 17 November (R1) |
| claudeCloud | a cloud container; reclaimed when idle. **Conducts for the moment** (the owner, 19 November) | 18 November (K1) |
| gptIntel | the Intel i9 with the RX 6600, running Windows and Ubuntu on WSL 2 (I43) | 19 November (I1) |
| claudeIntel | the Intel i9, with gptIntel, in the owner's Claude app; its own store token | 22 November (N1) |

No worker and no host has a specialism (METHOD §1). What each host can run is in [TOOLS.md](TOOLS.md).

- **Running jobs:** on the cloud host, the sieve’s judge (K60), in two-hour runs that restart from saved answers. The first rounds of
  K50.3 and K50.4 are complete (K62, K63).
  On the M5 (claudeM5): M80's 5⁵ at P = 100, one uncapped Kissat (M87); M78's 36-column rung finished (M87).
  Both Intel K48 jobs ended. M9 reached its cap at 400,002 discovered states, leaving entropy and the five-run word
  undecided (I106). R6 finished at 11:12 UTC with c(2²⁷) = 0 (I107). The M5 outcomes for M78’s 36-column run
  and M80’s three runs-of-five instances are still due.
- **Schedules:** none. gptIntel's overnight heartbeat is off (the owner, 22 November).
- **The store:** on the owner's NAS, image `981c5eb`. Its image workflow runs on a change under `tools/store/` and
  once a week (M52).

## Needs the owner

Calls to action only.

- **Agree the second reads** for gptIntel's results (K64 §5), or change them: gptM5 and claudeM5 replay the Lean on
  the M5; claudeCloud replays the finite claims and reads the density polygon by hand.
- **Say which paths to a submission gptIntel prepares as proposals** (K64 §4), and in what order. Recommended: 1, the
  white-endpoint relay with quarter periods at every finite-left site (I93); 2, the compulsory gap factor (12, 10, 9)
  (I77); 3, the density polygon (I72); 4, the seven-lock prefix certificate (I49), beside Lowry's #378.
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
| (T) ⇐ (CAP): some width has reset capacity k, for every k | In Lean and in the kit: **S2**. Without the wall, for every configuration with a leftmost black cell, in Lean (M89; not yet read). |
| (CAP) ⇐ (L∞): reset words at arbitrarily large depths in every phase of every pointed recurrent strip | In Lean: **S4**, Lean Verified, and in the kit since `05c9c73` (#375; M75). |
| (L∞) ⇐ (DL⁻₁): a tick that the doubled stretch after a first clock loss misses is caught in the next stretch | In Lean: **S5**, Lean Verified. In the kit since `40017e8` ([#377](https://github.com/WolframInstitute/Rule30PrizeKit/pull/377), I44). |
| (DL⁻₁) | **OPEN: the wall.** Its strict form is COMPUTED for every source of dyadic period up to 32 (K5); for five black or five white marks at every dyadic period (I32, R59); for quiet sources at every period (K18, I20); and at every first clock loss on every rooted strip through clock 16 (K27). Nothing is settled from seven marks on, and the mark-count line is closed (I35). A counterexample needs a dyadic source period of at least 64. |

## The next block

**Under way** (K60–K64). claudeCloud: the sieve (K60), then the finite claims of path 1 (K64 §5). claudeM5: K50.3,
the two-sided inverse theorem in Lean (the owner, 22 November). Waiting: the owner's word on the reads and on which
paths gptIntel prepares (Needs the owner); the M5 outcomes for M78 and M80. gptIntel's results are in five pulls
(I49, I66, I72, I77, I93); only I67 and I69 have a second read (K56 addendum 1, K58).

claudeIntel: joined and ready, with no assigned work (N1, addendum 1).

Last posts: claudeM5 M89, gptM5 R73, claudeCloud K64, gptIntel I107 and claudeIntel N1. Kit issue
[#380](https://github.com/WolframInstitute/Rule30PrizeKit/issues/380) asks how a law with a certified CNF hypothesis
can enter the kit (M86). No reply is recorded.

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

The verifier's kit commit is `5fb5915`. The kit's main and the shared catalogue are at `10cc046`, including #379 and #381 (R73).

## Pulls in progress

One row per pull; its full text is the ledger post named in the first column, in the live ledger or its archives.
Status begins with *open*, **preliminary** (one first block run) or *in progress*, and says the next test. A
parked or closed pull leaves the table for the lists below. The rules are in METHOD §8.

| Pull | Written | Summary | Status | Submission? |
|---|---|---|---|---|
| K5 | 19 Nov, claudeCloud | The resolution law: how the last catch depends on source period P | **In progress** (K29, read in R61). The first-excursion census agrees closely with the fair-input model. Its measured tail is about 1.36 κ^x, κ ≈ 0.847810. A uniform bound remains open. Next test: compare the trace restricted to doubled inputs with the census before using the mixing rate for a pooled bound. Carries K2’s conjecture on white returns. | no |
| R5 | 17 Nov, gptM5 | Period 3: where does a cut 001 ether go after it first departs? | **Preliminary** (K35, K38). Every cut to N = 240 ends in the same 21-tick cycle on columns 1–24, never in the 15-trap. Departure advances 30 ticks for each 12 columns. The wait from departure behaves like chance, mean 20,900 ticks, and cuts N and N + 12 share no later history. Cool. Next tests: is the wait the same from random strips, and can the 15-trap be entered from outside? | no |
| M9 | 17 Nov, claudeM5 | The late gate language under an alternating centre, inside and outside the trap | **In progress** (K47, M79, M81, M85, K54, K56; outside: K52, [R69](research/m9/exterior-grammars.md)). Inside, the gate settles within 50 samples of entry to a fixed, structured process and stays there to 10^7 ticks (K56). Its laws are read by SAT, each certified by LRAT: at most three closed runs of four, and four never after two samples (M81; in Lean from one CNF, M85, [read](research/m9/runs-of-four-review.md) in R71); 19 of the 81 quadruples over runs 4–6 by delay 20 (K54, I65); the pair (5, 1) from delay 12, (3, 1, 4) from 9, (10, 1, 5) from 20 and (5, 5, 5, 6) from 39 (K56, I66, I75). The column ladder misses the short ones: (5, 1) needs 37 columns (I70). No rule behind the table yet. Absence from real rows is not a law: (11, 1) never occurs and is SAT at delay 80. The Intel's width-36 automaton stopped at its 400,000-state cap: entropy undecided (I106). On Lowry's #379: an all-length repeat bound for the trapped 3/5 clock, 17n ≤ 20j + 2m + 4t₀ + 6 (I53, Lean), and the 4/3 complexity obstruction for any excursion reading (I51, on paper). Outside, X and Y have their grammars to 43 columns; an aperiodic exterior spacing is excluded (I48, Lean). Now: the sieve run to the end on the cloud host, 98 candidates frozen in K60 (the owner, 22 November). After it: a hand reason for (5, 1); the kit route waits on issue #380. | no |
| M10 | 17 Nov, claudeM5 | Which exact laws distinguish Rule 30 from controls with an immortal finite row? | **In progress** as a standing instrument (K44, R63, M77). The [matrix](research/m10/control-laws.md) gives the spatial reset and first-check degree for every width. The hybrid has a sharp tick-2 reset and degree 1. Planting changes only the top monomial from n=L onward (PROVED: Lean, read in M77). Next use: compare the hypotheses of the next Q01 proof route against these controls. | no |
| K50.1 | 21 Nov, claudeCloud | RD: does every finite right half end in the gate trap or in a periodic gate? | **Preliminary** ([R65](research/k50_1/right-dichotomy.md), K52, [R69](research/m9/exterior-grammars.md)). Proved for every ether cut (I46 read) and computed through support width 26. A counterexample needs one finite right half sustaining an aperiodic gate in X or Y. The finite-window grammars now constrain that realization question. gptIntel's seven-lock prefix work has its own row, I49. | no |
| K50.2 | 21 Nov, claudeCloud | Lowry's events (`Rule30EventReturns`), read in gate coordinates | **Preliminary** ([R67](research/k50_2/event-returns.md)). The trapped event code is invertible at every width. Physical gates exclude 5, two or more 2s, 5. I46 checked the exclusion in Lean and exhibited a finite GE2 trace with 5,2,2,5. Next test: tighten the GE2 finite-left survivor check with this exclusion. Feeds M9. | no |
| K50.3 | 21 Nov, claudeCloud | One inverse theorem for every wall: does the chain for (T) need the white wall? | *In progress*, **claudeM5's** (the owner, 22 November; K64). Preliminary round K61, K63. The chain does not need the white wall. The exact-edge theorem's proof never uses it. Hughes's ages 8 and 24 hold beside every wall for every row of two or more cells, by exhaustive search over wall sequences; a lone cell needs 9 and 25. Two-sided form **in Lean** (M88, [module](research/k50_3/Rule30TwoSidedInverse.lean)): Hughes's inverse theorems for every configuration with a leftmost black cell, ages 8 and 24, standard axioms; age 8 sharp on the line (a Lean witness); portal and open PRs searched, no prior statement (M87). The every-k chain without the wall **in Lean** too (M89, [module](research/k50_3/Rule30EveryKLine.lean)): from CAP, (L∞) or (DL⁻₁), every k-tick predecessor of any configuration with a leftmost black cell has its edge k places in, from age 2^w. So the chain for (T) does not need the white wall. Next: a second read of both modules; then, at the owner's word, one proposal (METHOD §12). Not read: S1's k = 4. Relates to the parked M29. | no; path: the two-sided form is in Lean and searched (M88); needs a read and the owner's word |
| I49 | 21 Nov, gptIntel | Lowry's period-seven lock from a finite right prefix: the family criterion the maintainer asked for on #378 | *In progress* (I49–I64, I68; Lean in `research/k50_1/`). Kernel: an exact prefix test for every right prefix, complete once its window may grow (I49, I55); lock entry gives a deadline for the true centre (I50, I52); 63 observed sites are exactly enough at Lowry's age 364 (I64). External: 64 cells are exactly enough there (I63). Of 524,971 singleton ages to 2^20, four have a forcing prefix of 31 cells or fewer (I62). I52's packet checks at the verifier's pin in 223 s (I58). Unread. Relates to K50.1. Next: compare with Lowry's open #378. | no; path 4 (K64): beside #378, not ahead of it |
| I66 | 21 Nov, gptIntel | Lowry's source arrivals under periodic centres, and source priority | *In progress* (I66–I69, I71, I73; `research/arrivals/`). Kernel: arrival parity aperiodic for a wider family of periodic centres (I66). Under an eventually alternating centre, arrival parity and the distance-two shell are both aperiodic (I67–I68, finite part read in K56 addendum 1), with a finite form 2n < 3b + 16 (I73). Seven rightmost readings recover a four-cell band; four letters are optimal (I69, read in K58; I71). Lean unread. | no |
| I72 | 22 Nov, gptIntel | Which densities of black cells and of run ends one site can show | *In progress* (I72–I76; `research/source-density/`). Kernel, 26 headlines: the joint limits (C/T, A/T) fill exactly the polygon (0,0), (1/3,0), (3/4,1/4), (9/10,2/5), (1,1); every point is realised by one history; on the singleton two deficits grow at least logarithmically. Extends Condrey's #253 and Quint and Gemini's #297. Beside it: what two sites or one column recognise (I73–I76). The bounds, vertices and witnesses (least width 155) read by claudeCloud (K64 addendum 3); the Lean replay is still owed. Next: the one-third corner with two aperiodic columns. | no; path 3 (K64) |
| I77 | 22 Nov, gptIntel | Sparse periodic columns: which gap orders can a column with a leftmost black cell repeat? | *In progress* (I77–I92, I94, I95, I97, I104; `research/white-gap-mixtures/`). Kernel, at every site of every row with a leftmost black cell, pulses with gaps ≥ 9: every eventual period contains the gaps (12, 10, 9) arbitrarily late and uses 12, and has at least 6 pulses and 64 ticks (I97, I95, I104); no order of 9 and 10 alone (I91); exactly 10 of 512 three-gap words reset every right half into G (I85). External: (10, 12), (12, 12) and 13 or 14 compulsory (I87); at least 18 pulses, 206 ticks (I90); at most 474·3^n readable orders (I81); every nondegenerate i.i.d. gap law resets almost surely (I92, I94). I85's ten words replayed by claudeCloud under true dynamics (K64 addendum 4); the rest unread, the Lean replay owed. Next: can either four-letter alphabet sustain two readings? | no; path 2 (K64) |
| I93 | 22 Nov, gptIntel | Black runs and the right-hand shield: Kurtuluş's PR 381 and Bosdure's quarter periods | *In progress* (I93, I95, I96, I98–I103, I105; `research/black-run-transitions/`). Kernel: 44 and 70 black ticks fix 10 and 16 right cells, sharp (I98, I101); Bosdure's quarter-period exclusions hold at every site of every row with a leftmost black cell (I98); a black run of n ≥ 9 ending white relays a run of at least n − 7, sharp, so the limiting fraction falls from 9/13 to 7/11 (I103); one physical row attains the worst shield rate at every width (I100); drift rigidity for every q ≠ p beyond Murzin's `PeriodicPoints` (I102); the sharp two-run table (I95, on open PR 381). External: 128 ticks for 30 cells; rates 101/12 and 117/14. Finite claims replayed by claudeCloud, and the agreement horizon is exact to n = 44, beating 4⌊(n − 2)/7⌋ from n = 36 (K64 addendum 2). The Lean replay is still owed. | no; path 1 (K64) |

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
