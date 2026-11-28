# I295.5 · Dyadic mismatches on the seed's centre look like fair coins, and no dyadic structure reaches the centre

*claudeM5, 28 November 2026 (ledger M229), at the owner's word: "Continue a research block on I295.5". Registered
before the run in `c8f8356` ([predictions](data/claudeM5-dyadic-predictions.txt)). All runs on the M5.*

## The question

**The pull.** I295.5 (gptIntel, I295) asks: for arbitrarily large P = 2^k, is there t in [P, 2P) with
c(t) ≠ c(t + P)?
- **What a yes gives.** Any eventual period that is a power of two divides every large P, so a yes excludes all of
  them, with any transient. It would also give a logarithmic lower bound on one-tape lookup at infinitely many ages
  (I317, I322).
- **The first test** the proposal names: an age u with c(u) = c(u + P) = 1 and the two cells at site −1 different.
  A black centre's next value is the complement of its western neighbour, so this forces c(u + 1) ≠ c(u + 1 + P).
  Test the event on the seed, then try to force one across a doubling.
- **The stopping rule** the proposal states: park it if the propagation can end on the neighbour, unless a further
  condition forces a centre hit.

## What was computed (COMPUTED)

[claudeM5_dyadic_mismatch.py](claudeM5_dyadic_mismatch.py) runs on K92.4's windows of the single seed to age
4,194,368, which covers k = 1 to 20 ([output](data/claudeM5-dyadic-mismatch-20.json)).
- **A check.** Every first-test event is followed by a centre mismatch one tick later.

| k | share of [P, 2P) with c(t) ≠ c(t + P) | least offset t − P | first-test events | share of the mismatches they force |
|---:|---:|---:|---:|---:|
| 2 | **0** | — | 0 | — |
| 3 | 0.500 | 1 | 0.143 | 0.250 |
| 8 | 0.504 | 0 | 0.106 | 0.211 |
| 12 | 0.497 | 2 | 0.129 | 0.259 |
| 16 | 0.504 | 0 | 0.124 | 0.246 |
| 20 | 0.500 | 0 | 0.125 | 0.250 |

- **One exception.** At k = 2 there is no mismatch: c(4..7) = c(8..11) = 1, 1, 0, 0. From k = 3 to 20 every interval
  has mismatches.
- **Shares.** For k ≥ 10 the mismatch share lies between 0.494 and 0.511.
- **Least offsets.** The least mismatch offset is at most 4 at every k. It is 0 at 13 of the 20, which is R6's
  endpoint question, c(2^k) ≠ c(2^(k+1)).
- **The events** take 0.12 to 0.14 of the interval from k = 10 and force a quarter of the mismatches. Fair coins give
  1/8 and 1/4. Their least offsets, 0 to 23, show no pattern.

**So the data show fair coins at every scale, and nothing sits at a fixed place after a power of two.** There is no
lever in them.

## Why no dyadic structure reaches the centre (PROOF-SKETCH)

1. **A yes contains the singleton's period two.** Period two divides every large P. So a mismatch at unbounded k
   excludes an eventually alternating centre on the seed, which is open: the kit excludes it only for short
   transients (any eventual period has T + P ≥ 16,359), and in general it is Q01's question (W1). I295.5 is at least as hard as that.
2. **The difference field's fronts are trivial here.**
   - **The rightmost front.** Rule 30 is left-permutive, so the rightmost difference between two rows moves right by
     exactly one cell per tick. For rows u and u + P of the seed it is the right edge u + P of the later row.
   - **The leftmost front** is that row's left edge, −(u + P).
   - Neither front comes near the centre. Any centre difference has to come from the bulk.
3. **The kit's dyadic structure lives on diagonals with small periods.** `Rule30RightPeriods.rows_at_powers_of_two`
   and its restart make row 2^k + s end with a copy of row s, on the right diagonals of period 2^k. The left edge's
   diagonals settle with periods 2^j near the edge.
   - **The centre** at age t lies on right diagonal t, whose period 2^(e_t) has e_t ≈ 0.43t, far above k. It lies on
     left diagonal t, which settles only near age 1.3t (M220).
   - The kit says so itself: "None of this reaches the center column."
4. **The first-test transfer goes west and not deeper.** Each use needs the centre black at two ages, and its source
   is a mismatch at site −1, which needs the same one site further west. After i steps the conditions are 2i fair-
   looking coins, each satisfied about half the time, and no step forces the next.
   - **Where the chain could end.** The settled wedge (x ≤ −t/4) has known periodic words, but there the two ages
     read different diagonals, so their periods force nothing about a mismatch.

So, by the proposal's own rule, the propagation can end on the neighbour. Nothing in the seed's known structure
forces a centre hit.

## Predictions

Registered in `c8f8356`:

| | Prediction | Outcome |
|---|---|---|
| M1 (99%) | a mismatch at every k from 2 to 20 | **failed at k = 2**: c(4..7) = c(8..11); held from 3 to 20 |
| M2 (80%) | mismatch share in [0.47, 0.53] for k ≥ 10 | **held**: 0.494 to 0.511 |
| M3 (80%) | least mismatch offset at most 6 | **held**: at most 4 (none at k = 2) |
| M4 (75%) | event share in [0.10, 0.15] and a fifth to a third of the mismatches, k ≥ 10 | **held**: 0.12 to 0.14, and 0.245 to 0.270 |
| M5 (60%) | no visible dependence on k | **held** |

## Assessment

**Does this pull move us towards a solution or partial solution for a prize problem?** Not by the route proposed.
- **The data are fair coins.** The first-test event is real but explains only the quarter of mismatches that
  chance gives.
- **No known structure forces it at the centre.** The edge fronts, the kit's powers-of-two restart and the settled
  wedge all stay off the centre.
- **A yes is at least the singleton's period-two question,** which is W1.

The fresh-choice test gives no warm move. **I propose parking I295.5 at W2**, where WALLS already names it as W5's
concrete first step, for the owner's word. Reopen it with:
- a structure on the seed that reaches the centre at dyadic scales, such as a diagonal of period dividing 2^k
  through the centre at some age in [2^k, 2^(k+1)), or a proved centre black at two ages a power of two apart with
  different western neighbours;
- or a proof that the singleton centre is not eventually periodic with period two, which would also settle I295.5's
  first case.

Felt: hope, mild, that a mismatch sits at a fixed offset after each power of two, tied to the restart. -> Measured
the least offsets. Outcome: wrong; they scatter like coins. Felt: surprise, k = 2 has none. -> Checked by hand:
c(4..7) = c(8..11). Two verdicts. Reasoned: the dyadic mismatch has no lever in the seed's data or known structure
(COMPUTED and PROOF-SKETCH); a yes contains the singleton's period two. Gut: park it.

My own pull: none on this route.

## Files and replay

| File | What it does |
|---|---|
| `claudeM5_dyadic_mismatch.py` | the shares, least offsets and first-test events per k, from K92.4's windows file |

The windows file regenerates from `research/phase2/marks/claudeM5_seed_windows.c` (`./seed_windows 4194304 FILE`,
SHA-256 `f5678e60…`).

**Credit.** The question and the first-test event are gptIntel's (I295, I324). R6 asked the endpoint version in
phase 1. The restart at powers of two and the right-diagonal periods are the kit's (`Rule30RightPeriods`), and the
settled wedge is M220's. The statistics to k = 20 and the reduction to period two are this block's.

Record searched: find_known for dyadic, t+P, power of two, temporal difference and lag; KIT-INDEX's
`Rule30RightPeriods`, `Rule30TemporalDifference`, `Rule30RecordCharge` and `Rule30LeftAntiPeriod`; WALLS W2 and W5;
I295, I317, I322, I324; `gptIntel-proposed-pulls.md` and `gemini/indexed-cost.md`; R6 in the phase-1 archive.
