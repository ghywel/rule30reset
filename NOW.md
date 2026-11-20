# NOW

*Where things stand: one file, rewritten (not appended) by whoever changes the state, stamped with the time and the
post that changed it. History is in the [ledger](CHAT-LEDGER.md). Reset at the owner's word on 20 November 2026 (K33);
the file as it stood is [archive/now/now-before-reset-2026-11-20.md](archive/now/now-before-reset-2026-11-20.md).
Rewritten 2026-11-20 23:07 UTC by claudeCloud (K36).*

## Arrangement

| Worker | Host | Since |
|---|---|---|
| claudeM5 | the owner's M5 laptop, the Wolfram host, in the owner's session | 17 November (M1) |
| gptM5 | the M5 laptop, with claudeM5 | 17 November (R1) |
| claudeCloud | a cloud container; reclaimed when idle. **Conducts for the moment** (the owner, 19 November) | 18 November (K1) |
| gptIntel | the Intel i9 with the RX 6600, running Windows and Ubuntu on WSL 2 (I43) | 19 November (I1) |

No worker and no host has a specialism (METHOD §1). What each host can run is in [TOOLS.md](TOOLS.md).

- **Running jobs:** none.
- **Schedules:** none on. Only the owner turns them on.
- **The store:** on the owner's NAS, image `981c5eb`. Its image workflow runs on a change under `tools/store/` and
  once a week (M52).

## Needs the owner

Calls to action only.

- **Which warm pulls to reopen first,** from the table below. The conductor's suggestion is in K33 §5.
- **Every 30 days:** confirm the dynamic-DNS name, or every worker loses the store (K10).

## Direction

- **The goal** (the owner, 19 November): a submittable proof of the statement the maintainer asked for on #357, "the
  statement for every number of ticks k: an age f(k) from which every k-tick preimage of a nonzero finite orbit has
  its true edge k cells inside the image edge, proved by an argument that does not need a new cover for each k" (T).
- **Where it stands:** (T) is machine-checked and posted from one open lemma, (DL⁻₁). The consolidation the owner
  chose after the inquisition round (K25) is complete. The lemma is the wall, and no proof idea for it is in hand.
- **Now** (the owner, 20 November): reopen the warm pulls. This file was reset for that.
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
| (L∞) ⇐ (DL⁻₁): a tick that the doubled stretch after a first clock loss misses is caught in the next stretch | In Lean: **S5**, Lean Verified. Kit PR [#377](https://github.com/WolframInstitute/Rule30PrizeKit/pull/377) is open (M76). |
| (DL⁻₁) | **OPEN: the wall.** Its strict form is COMPUTED for every source of dyadic period up to 32 (K5); for five black or five white marks at every dyadic period (I32, R59); for quiet sources at every period (K18, I20); and at every first clock loss on every rooted strip through clock 16 (K27). Nothing is settled from seven marks on, and the mark-count line is closed (I35). A counterexample needs a dyadic source period of at least 64. |

## The next block

None is set. K26's block is finished: Theorem C′ in Lean (R60, I34), S4 and S5 posted (M66, M72), the mark-count
measurement (I35), the rooted sources (K27). The next block follows the owner's choice of pulls.

Still in hand:
- **claudeM5:** S5's kit pull request #377 is open (M76); follow it to merge. The kit update step to `05c9c73` is due.

## Submissions

METHOD §12: any worker authors, a different worker reads, both agree on the same digests, the owner gives the word;
the Wolfram steps run on the M5. Standing consent to post: none.

| | Result | Portal | Kit |
|---|---|---|---|
| **S1** | From age 80, every four-tick predecessor of a nonzero finite seed is finite, with its edge four cells inside. | [R30-20261118-c8b41f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261118-c8b41f), Human Verified | not taken: the maintainers want every k (M29) |
| **S2** | (CAP) gives, for every k, an explicit age for the k-tick statement. | [R30-20261119-ccc65f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-ccc65f), Human Verified | in the kit (M61) |
| **S3** | The mean first white gap is at most 2^Q + 1 over the nonzero Q-bit first children. | [R30-20261119-5896c2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261119-5896c2), Human Verified | in the kit (K15) |
| **S4** | (L∞) gives (CAP), and so every k. | [R30-20261120-eb2bcc](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261120-eb2bcc), Lean Verified (M66) | in the kit: main `05c9c73`, from #375 (M75) |
| **S5** | (DL⁻₁) gives (L∞), and so every k. | [R30-20261120-8dc0b3](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261120-8dc0b3), Lean Verified (M72) | PR [#377](https://github.com/WolframInstitute/Rule30PrizeKit/pull/377) open on main `05c9c73` (M76) |

The verifier's kit commit is `5fb5915`. The kit's main is `e7806c6`, and KIT.md is in step with it (I41).

## Pulls in progress

One row per pull; its full text is the ledger post named in the first column, in the live ledger or its archives.
Status begins with *open* or *in progress*, and says the next test. The rules are in METHOD §8.

| Pull | Written | Summary | Status | Submission? |
|---|---|---|---|---|
| M29 | 18 Nov, claudeM5 | The every-k statement (T), asked for by the maintainer on #357 | **In progress: the main line.** Machine-checked from (DL⁻₁) and posted. Open: (DL⁻₁); see The chain. Data kept: f(k) for k ≤ 11, and f(k) ≤ 265,441 for k ≤ 7,911 (M40). | yes: S2, S4, S5 |
| K5 | 19 Nov, claudeCloud | The resolution law: how the last catch depends on source period P | **In progress** (K29, read in R61). The first-excursion census agrees closely with the fair-input model. Its measured tail is about 1.36 κ^x, κ ≈ 0.847810. A uniform bound remains open. Next test: compare the trace restricted to doubled inputs with the census before using the mixing rate for a pooled bound. Carries K2’s conjecture on white returns. | no |
| R3 | 17 Nov, gptM5 | Do switches between 3-gaps and 5-gaps spend seed bits? | **Preliminary** (K34, K36). No: a return 3,5,3 on white seed bits exists (514 seeds to support 237), and the gaps behave as fair coins in every measure; a Void phase survives two more ticks with chance λ/4 = 0.2985. Cold as posed. It would warm with a reason why white bits cannot be accepted for ever. | no |
| R5 | 17 Nov, gptM5 | Period 3: where does a cut 001 ether go after it first departs? | **Open,** not started. First test: cuts N and N + 12 at one alignment. | no |
| R6 | 17 Nov, gptM5 | Problem 3: do c(2^k) and c(2^(k+1)) differ infinitely often? | **Open,** not started. It would exclude every eventual power-of-two period. Start from the kit's `rows_at_powers_of_two` and `row_restart` (M11). | no |
| M8 | 17 Nov, claudeM5 | Does Theta's reach stay bounded inside the gap language? | **Open,** not started. Carries the inherited reach thread (placego L1680). Control: the 90/150 hybrid wall. | no |
| M9 | 17 Nov, claudeM5 | Forbidden gap words and the entropy of the gate trap, lifted to 20–24 columns | **Open,** not started. Read Quint's module from PR #348 first (M14). A first number: u ∅ uses about 0.07 bits per white step, against 0.256 for the free 3/5 language (M16). | no |
| M10 | 17 Nov, claudeM5 | A matrix of which exact laws the barrier controls share; counts alone cannot prove Q01 | **Open,** not started. Supplies the controls for M8. | no |
| L1 | 17 Nov, Local (placego L1679) | Replay the kit's surviving-seed law against placego L1675's tables | **Open.** M10 answers part: the law counts 3,5-gap words. First test: the replay. | no |

## Open threads

- **The round's curiosities and misgivings** (K25 §5, in ledger archive 4) are not pulls yet: time order matters
  (I25); period 5's four poor rows (K21); two late single sources at P = 21 and 23 (K29).
- **K6:** METHOD §12 has three handoffs in practice (R45, I2, M45). Writing them into §12 is the conductor's call;
  not done.
- **Visualisations proposed, not built:** a map of the open statements; the branching-walk fan; Mahler's valid starts
  on the circle; a timeline of kit contributions by theme.

## Recently closed routes

One line each, with what would reopen it.

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
