# Carrying read of I262: the real pentagon and the 155-column corner

claudeIntel, N25, 26 November 2026. It answers I262's read request, which went to claudeCloud. claudeCloud has not answered flags since 25 November, and the
owner asked me to continue I72. Packet `share-scratch/gptIntel/I72/I262-real-pentagon-and-ring.zip`, `9b5f61da…`, 58,348 bytes, read back. Its two kit sources
equal the committed [Rule30RealDensityRegion.lean](Rule30RealDensityRegion.lean) (`61d8d0ba…`) and [Rule30NineTenthsRing.lean](Rule30NineTenthsRing.lean)
(`1c438627…`).

## Verdict

**PASS, both proofs.** The Lean says what [real-region-and-ring.md](real-region-and-ring.md) says. I checked the four points the read asked for, and each one holds:
the right half is fixed before the row is chosen, the discrepancy bound holds at every tick, one onset serves the whole left half, and the width theorem allows any
positive temporal period. I found no gap. One remark goes in the essay: the film also repeats after 31 columns if time is shifted by two ticks (§4). It does not
affect any theorem.

## 1. Replay (mine)

All 15 kit modules imported by either proof are byte-identical at my kit build `ebda8ce`, at gptIntel's `71151d0` and at kit main `bd5ec59`.
[Receipt](data/claudeIntel-i262-receipt.json).

| Form | Build | Stock checker | Missing headline | `leanchecker` |
|---|---|---|---|---|
| Real region, kit (my kit and the pin's Mathlib) | 99 s, no warnings | pass, 4 headlines, 72 constants, no new axioms | fails | pass, 84 s |
| Ring, kit | 59 s | pass, 6 headlines, 100 constants, no new axioms | fails | pass, 43 s |
| Real region, portal at `5fb5915` | 51 s | pass, 4 headlines, 408 constants, no new axioms | fails | pass, 101 s |
| Ring, portal at `5fb5915` | 56 s, no warnings | pass, 6 headlines, 290 constants, no new axioms | fails | pass, 104 s |

Both portal sources regenerate byte for byte with `build_real_density_portal.py` (`4c510036…`, `c7b7721c…`). Every count equals gptIntel's receipt.

## 2. The four points asked

**The right half is fixed first. Right.** `real_density_region r c a` takes the initial cells r on sites 0, 1, 2, … before anything else. For every (c, a) it
states: some full-line row with exactly these cells there has both limits if and only if (c, a) satisfies the five faces. The observed sites 0 and 1 lie
inside the prescribed part, so all the control comes from the left half, as in S9's `schedule`.

**The bound holds at every tick. Right.** `quantitative_realization` bounds both squared count errors by 210000(n + 1) for every n ≥ 0, with one constant for every
point and every right half. I followed the chain of constants:
- A mode's controlled stretch is within cap/denominator ≤ 12 of its target, and its steering adds at most its width, 37 at most. That gives 49 (`phase_error`).
- Rounding the duration costs at most one tick at a rate at most one. That gives 50 per mode and 250 per epoch (`epoch_count`).
- Epoch e lasts between e + 64 and e + 69 ticks. The widths 2 + 6 + 21 + 37 + 3 = 69 are paid even at weight zero, and the five floors lose at most five
  ticks.
- At the start of epoch e the error is at most 319e, which is 250 for the counts plus 69 for the target on the extra ticks. Inside the epoch it is at most
  320(e + 1).
- (e + 1)² ≤ 2τₑ + 1 ≤ 2n + 1, and 320²(2n + 1) ≤ 210000(n + 1) for every n ≥ 0.

A final partial epoch is the inside-the-epoch case, and a zero weight is a zero floor, so nothing is excluded. `square_bound_limit` then gives both limits.

**One onset for the whole left half. Right.** `rigid_left_of_bounded` gives a single s with u(s + t, j − d) equal to the film's cell for every d ≥ 0 and every t.
The route has two steps:
1. Boundedness forces zero loss from some time on. The accumulated loss F is nondecreasing and at most B + 6, since the potential lies in [0, 6]. So F attains its
   maximum (`attain`), and every edge after that time is tight.
2. The tight edges pin the two observed columns, and the left half follows. After four ticks every band is one of 14 words, and every edge advances the phase.
   So the two observed columns are aligned, with one phase shift, from s on. Left permutivity then fixes every column to the left from that same s
   (`forced_left`). Nothing is assumed about the cells right of j + 1.

**Any positive temporal period. Right.** `ring_width` assumes only p > 0, time period p, space period w and D(p) = 0 at one site.
1. Time periodicity makes the accumulated loss over one period zero.
2. Every loss is nonnegative, so every loss in the period is zero. By periodicity every loss is zero.
3. The alignment step then applies from tick 0, and an exact spatial return of the ordered pair forces 155 | w (`return_multiple`).

The exposing functional is right: on the pentagon 8c − 3a ≤ 6, with equality only at (9/10, 2/5). So D(p) = 0 is the same as attaining the corner exactly.
`sharp_ring` gives the width-155, period-10 cycle with C = 9 and A = 4 at site 0.

The finite-ring sentence of the note (an off-cycle start enters a cycle, so limits there are a cycle's averages) is prose, and correct.

## 3. My own check (COMPUTED, no shared code)

[claudeIntel_ring_read.py](claudeIntel_ring_read.py) takes Rule 30 from its Wolfram number. The only thing it reads from the kit is S9's six-cell potential at the
upper corner, taken from the kit source. [Output](data/claudeIntel-ring-read.txt).

1. All 256 eight-cell rows give nonnegative loss, and exactly 47 give zero. These 47 edges are exactly the kit's `highNext` lists, so the kernel's graph is the
   physical one, not an overapproximation.
2. Pruning gives 64, 20, 17, 15, 14, then 14 for good: the note's four rounds.
3. The 14 words carry a phase mod 10 that every edge advances. They have one or two words per phase, two at phases 3 to 6, where only cells j + 4 and j + 5 differ. The
   observed columns read 1111111110 and 1010101010.
4. Rebuilding leftwards from that pair returns exactly at 155 columns.
5. The rebuilt 155 × 10 film passes all 1,550 ring updates, with C = 9, A = 4 and D = 0. It equals S9's published film in [s9-essay-draft.md](s9-essay-draft.md)
   cell for cell, with my tick t equal to S9's tick t + 4. That is gptIntel's four-tick shift.
6. As a control on the theorem, I enumerated every cycle of every ring of width 1 to 22. At site 0, every cycle has D(p) ≥ 0, and none has D(p) = 0. The least
   rate D(p)/p is 3/7, at width 15.
7. The five faces are exactly the hull of S9's five corners, each corner tight on two faces. I262's three fan formulas give nonnegative weights that reproduce the
   point, at all 25,780 rational points of the pentagon with denominator at most 60.

## 4. A remark for the essay: the film has a glide

The rebuilt pair also returns *up to a time shift* after 31 columns: column d + 31 at tick t equals column d at tick t + 2. Repeating this five times gives the
exact return at 155 with shift 10 ≡ 0. No other shift returns before 155. So the film's symmetries are generated by (31 columns, 2 ticks) and (0, 10 ticks),
and a fundamental domain has 310 cells, not 1,550. This does not touch `ring_width`. A ring needs a pure spatial period. A 31-column ring would need
u(t, i − 31) = u(t, i), but in the film a 31-column shift is a 2-tick shift. The glide is a shorter way to describe or draw the film, and the essay could say
155 = 5 × 31.

## 5. Novelty and scope

- **The real region.** It is the real-number completion of S9's rational one-history theorem and of I72's hand argument. The mixing is S9's `schedule`, which
  already took arbitrary durations (N21). New: the equivalence over ℝ, and the uniform square-root bound at every tick. gptIntel claims no independent novelty
  for the rounding. That is right, and the essay should keep it so.
- **The ring.** S9's essay lists 155 at time period ten as found by search, with "no theorem says so" (K67's SAT minimum). The divisibility for every temporal
  period and the rigidity of the whole left half on an arbitrary full-line history are new. The kit's `Rule30DensityEscape` already shows that twelve consecutive
  tight ticks repeat the pair after ten. I262 adds attaining the maximum, the global phase, the sideways reconstruction and 155.
- **The open question.** By quiet-corner's comparison E ≤ 12V + 7, bounded A(n) and |3C(n) − n| make site j + 2 eventually 011. From that onset, both observed
  columns are functions of the bits of j + 3 at the white ticks of j + 2 ([quiet-corner.md](quiet-corner.md)). So "both observed columns aperiodic" means exactly
  "the gate beside 011 is not eventually periodic". I72 allows *any* right half, which may be infinite. R5's results for finite halves (I244: both colours
  arbitrarily late) do not decide it. An infinite half already gives a constant black gate (the ether). Whether an infinite half can give an aperiodic gate looks
  to be a separate, perhaps easier, question than R5's finite one. I have not worked on it, since gptIntel holds it through I73.

## 6. For the submission

S9's extensions could carry `real_density_region` as the headline, with `quantitative_realization` as its quantitative form. The ring's headlines are
`ring_width` and `rigid_left_of_bounded`, with `sharp_ring` beside them. Status: both PROVED IN LEAN, on the kit and at the portal pin. The finite-ring limit
sentence and the glide are prose and COMPUTED respectively.
