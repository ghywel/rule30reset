# The real density pentagon and its rigid upper corner

Fix a site and count the first n physical ticks. Write C(n) for black cells at the site and A(n) for horizontal 10s across the site and its right neighbour. S9 gives five periodic corner witnesses, sharp inequalities for all rows, and a one-history construction for rational mixtures. I72 originally gave the real mixture argument on paper. This block formalizes the exact real limit set and answers the minimum-width question. [S9 in the kit](https://github.com/WolframInstitute/Rule30PrizeKit/pull/402)

## One row for any prescribed real point

Fix the initial row on **every site from zero to the right**, including zero. There is a full-line extension on which C(n)/n tends to c and A(n)/n tends to a if and only if

```
0 ≤ a ≤ c,     3c ≤ 1+5a,     2c ≤ 1+2a,     6c ≤ 5+a.
```

For instance, choose a = 0 and c = √2/6. Whatever the specified right half, the same row realizes this irrational black frequency and zero run-end frequency. Both conclusions concern all physical times tending to infinity.

Divide the pentagon into the three triangles joining the origin to consecutive nonzero vertices. This gives explicit nonnegative weights wᵢ adding to one, including on the seams. In epoch e use S9's ith controller for ⌊e wᵢ⌋ ticks after steering to it. Even a zero-duration mode pays its steering time. The five steering times add to 69, so the full epoch takes between e+64 and e+69 ticks. Both counts gain their target fraction times e with error at most 250 per epoch. After charging steering to the target elapsed time, the error at the start of epoch e is at most 319e. A prefix of the next epoch costs at most its length. The resulting row satisfies, for **every** n ≥ 0,

```
(C(n) − cn)² ≤ 210000(n+1),     (A(n) − an)² ≤ 210000(n+1).
```

The constant is uniform over the closed pentagon and over initial right halves. The converse divides S9's finite inequalities by n and passes to the limit. [Mathlib proof](Rule30RealDensityRegion.lean)

## Why the width is 155

At the vertex (9/10, 2/5) the exposing deficit is D(n) = 6n + 3A(n) − 8C(n). On **any ordinary history**, an upper bound on D(n) at all n forces a common time after which the *entire left half*, including the observed site, agrees with one explicit periodic film. The construction leaves the exterior to the right of the observed pair unrestricted by the theorem's hypotheses.

S9's six-cell potential turns D into a nondecreasing integer total by adding the initial potential and subtracting the current one. The potential lies between zero and six. A bounded total attains a maximum, after which each edge has zero loss. Four rounds of requiring a predecessor and a successor in S9's tight graph reduce 64 words to 20, 17, 15 and finally 14. The 14 words split into ten phases. Every surviving edge advances the phase by one. At phase zero the observed ten-tick columns, in chronological order, are

```
observed site      1111111110
right neighbour    1010101010
```

These two columns determine their left neighbour at each time. If c and r are the known columns, its bit at t is c(t+1) XOR (c(t) OR r(t)). Iteration therefore identifies every column to the left from the same onset. The first spatial return of the ordered pair is at 155. The kernel checks the physical recurrence through both seams, a distinguishing phase for every smaller positive displacement, and the counts (9,4) on a width-155, ten-tick witness.

On a ring cycle of **any** positive temporal period p, D(p) = 0 makes the accumulated loss vanish over the cycle. Every edge is tight. Thus every spatial period is divisible by 155. Repeating the checked 155-site film realizes every positive multiple. A finite ring started off-cycle enters a cycle after finitely many steps, so the same minimum applies to limiting frequencies there. The arbitrary full-line result assumes bounded D(n). Convergence to the corner alone only gives D(n)/n → 0. [Core Lean proof](Rule30NineTenthsRing.lean)

An independent Python check derives the graph directly from all 256 eight-cell rows and S9's potential, then reconstructs the ring as literal tuples of bits. All 1,550 cells agree with S9's checked film at the original observing site after a four-tick time shift. It also checks all 1,550 forward update equations. [Independent replay](check_nine_tenths_ring.py)

## Scope and review

The real result extends S9's arbitrary controller schedule. The ring result uses S9's loss graph, period-ten witness and earlier period-ten SAT minimum. The new step is a proof for every temporal period and a rigidity theorem for bounded deficits on arbitrary full-line histories. The singleton's limiting densities remain open. I72's remaining question asks for a history at (1/3,0) with bounded A(n) and bounded |3C(n)−n| in which both observed columns are aperiodic.

The portable builder reads S9 dependencies from kit commit `71151d0`. Running `python build_real_density_portal.py Rule30Submission.lean` builds the Mathlib proof for the older portal pin. Adding `--ring` builds the separate core proof. The real proof belongs with S9's density classification. The core result can extend the kit's density-escape family. Both are staged for a carrying read. [Portable builder](build_real_density_portal.py)

| Proof | Kit main `71151d0` | Portable on `5fb5915` |
|---|---:|---:|
| Real region | 4 headlines, 72 declarations replayed | 4 headlines, 408 declarations replayed |
| Ring rigidity | 6 headlines, 100 declarations replayed | 6 headlines, 290 declarations replayed |

The stock checker found zero new axioms in all four forms. The independent arithmetic control checked the triangle formulas on 5,329 rational pairs and the floor durations at the irrational example for 2,000 epochs. The exact sources, checker receipts and controls accompany ledger I262.

