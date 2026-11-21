# NOW

*Where things stand: one file, rewritten (not appended) by whoever changes the state, stamped with the time and the
post that changed it. History is in the [ledger](CHAT-LEDGER.md). Reset at the owner's word on 20 November 2026 (K33);
the file as it stood is [archive/now/now-before-reset-2026-11-20.md](archive/now/now-before-reset-2026-11-20.md).
Rewritten 2026-11-21 11:28 UTC by claudeM5 (M78).*

## Arrangement

| Worker | Host | Since |
|---|---|---|
| claudeM5 | the owner's M5 laptop, the Wolfram host, in the owner's session | 17 November (M1) |
| gptM5 | the M5 laptop, with claudeM5 | 17 November (R1) |
| claudeCloud | a cloud container; reclaimed when idle. **Conducts for the moment** (the owner, 19 November) | 18 November (K1) |
| gptIntel | the Intel i9 with the RX 6600, running Windows and Ubuntu on WSL 2 (I43) | 19 November (I1) |

No worker and no host has a specialism (METHOD §1). What each host can run is in [TOOLS.md](TOOLS.md).

- **Running jobs:** gptIntel started K48's two frozen reruns at 10:30 UTC on 21 November (I44). R6 computes the centre through 2^27 on four threads. M9 computes the 36-column rung with a 400,000-state cap. Both write durable local logs. claudeM5 runs M78's frozen run grammar of the code on the M5, at 32 and 34 columns and then 36.
- **Schedules:** none on. Only the owner turns them on.
- **The store:** on the owner's NAS, image `981c5eb`. Its image workflow runs on a change under `tools/store/` and
  once a week (M52).

## Needs the owner

Calls to action only.

- **Choose among the new pulls.** K50 derives them from the kit as it stands, with the recent third-party work
  first. Until then: M9 continues with claudeM5 at the owner's word (M78); K48 §3's second M9 worker and one cheap
  block on R5 are on offer.
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

The conductor derives a new set of pulls from the kit (K50). In hand meanwhile:
- **gptIntel:** K48's two frozen reruns (I44): R6 to 2^27, M9's 36-column rung.
- **claudeM5:** M9's second block (M78), at the owner's word: the run grammar of the free code in the lifts at 32 to
  36 columns, frozen before it runs.
- **gptM5, claudeM5:** M10's block is complete and read (R63, M77); the matrix stands as an instrument.

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
| M9 | 17 Nov, claudeM5 | Forbidden gap words and the entropy of the gate trap, lifted to 20–24 columns | **Preliminary** (K42, K47 and its addenda). The inherited record already had this ladder to 30 columns (PRIOR-ART P15), and a replay here agrees exactly. New: at 32 and at 34 columns a word of the free code {5, 3555} is not read from the core, by two methods at each width, so the record's entropy floor of 0.0991 has lost its footing. At 34 columns six runs of four 5s are forbidden. Entropy: 0.1169, then 0.1147. The 36-column ladder is running on the Intel (I44). Warm. Next tests: a third implementation by another worker; the forbidden code words at 32 to 36 columns and whether they follow a rule. | no |
| M10 | 17 Nov, claudeM5 | Which exact laws distinguish Rule 30 from controls with an immortal finite row? | **In progress** as a standing instrument (K44, R63, M77). The [matrix](research/m10/control-laws.md) gives the spatial reset and first-check degree for every width. The hybrid has a sharp tick-2 reset and degree 1. Planting changes only the top monomial from n=L onward (PROVED: Lean, read in M77). Next use: compare the hypotheses of the next Q01 proof route against these controls. | no |

## Parked

One dated line each, with what would bring it back (METHOD §3, the incubator).

- **M29, the every-k statement (T)** (parked 21 Nov, the owner). In the kit from one open lemma, (DL⁻₁): see The
  chain; submissions S2, S4, S5. Comes back with a proof idea for (DL⁻₁), or a counterexample, which needs a dyadic
  source period of at least 64. Data kept: f(k) for k ≤ 11, and f(k) ≤ 265,441 for k ≤ 7,911 (M40).
- **R3, do changes of gap spend seed bits?** (parked 21 Nov; K36). No: the gaps behave as fair coins, with the exact
  constant λ/4. Comes back with a reason why white seed bits cannot be accepted for ever.
- **R6, do c(2^k) and c(2^(k+1)) differ for ever?** (parked 21 Nov; K39). Tabulated to k = 24, differing at 17 of
  24 steps; no rule in the split of the slab. The run to 2^27 is on the Intel (I44) and extends the table when it
  is in. Comes back with a cancellation in the slab that survives doubling.

## Open threads

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
