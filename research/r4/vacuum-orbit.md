# A Rule 30 orbit with the seed’s right edge and positive vacuum mass

R20–R21, gptM5, 18 November 2026. **PROOF-SKETCH** pending an independent carrying read. Finite controls are **COMPUTED**.

R19, carried in M27, identifies the single seed’s upper density of white ticks at arbitrarily large gaps with the largest mass its time-averaged row distributions can assign to the entirely white row in a subsequential limit. M28 found source pairs attaining R19’s spacing bound and suggested testing time invariance. The question here is how much time invariance can tell us when we also know the complete seed history along its moving right edge.

## Statement

Let z be the single-black-cell seed and F the Rule 30 update on two-sided rows. For every integer B ≥ 0 there is a single initial row x with infinitely many black cells to the left such that

1. x agrees with z at every i ≥ −B. At every t ≥ 0, their rows agree at every i ≥ t−B. In particular the rightmost black cell is exactly at t on both orbits.
2. Some weak limit μ of the empirical averages of the orbit of x is F-invariant and satisfies μ({the entirely white row}) ≥ 1/2.

For any finite collection of spacetime observations of the seed, one can choose B large enough for the moving half-line in (1) to contain them all. B is chosen **before** constructing x. A different x is allowed for each B. The whole construction below, across infinitely many scales, uses the same x for that B.

## Constructing the initial row

The kit's left-permutive difference-front theorem says that flipping an initial bit at q while holding all bits to its right fixed flips cell q+T at time T and preserves all cells farther right. The bits strictly left of q have no influence there by the radius-one light cone. Consequently, if the initial suffix strictly right of b−T is fixed, the initial bits from a−T through b−T can prescribe any desired word on [a,b] at time T. Solve from b down to a, one bit per desired output. This is the known triangular inversion (P5).

Begin with the seed suffix from −B onward. At a stage with its suffix fixed from −D onward, choose L = (D+2)², plant a black marker at −D−1, and set T = L+D+2. Apply the inversion to prescribe zeros on [−L,L] at time T. The rightmost adjustable initial cell is L−T = −D−2, adjacent to the marker. The leftmost is −L−T. Thus the suffix is now fixed from −(T+L) onward. Repeat with D replaced by T+L. The fixed suffixes nest and exhaust the integers. Each marker survives in the initial row, and all earlier spacetime requirements remain fixed. Light-cone dependence proves the moving half-line agreement. The seed's right edge advances one cell per tick because the neighbourhood just outside the edge is 100.

## One limiting measure for every window

At times T+h, for 0 ≤ h ≤ L, the all-white interval contains [−L+h,L−h]. Write Vₖ for the rows white on [−k,k]. Among the T+L+1 rows from time zero through T+L, at least L−k+1 belong to Vₖ when L ≥ k. The resulting lower bound is

    (L−k+1)/(2L+D+3) → 1/2

along the stages, for every fixed k, since D/L tends to zero. Compactness gives a weakly convergent subsequence of those same stage-end averages. Each Vₖ is clopen, so its limiting mass is at least 1/2. The decreasing intersection of the Vₖ is the singleton entirely white row. Continuity from above gives it mass at least 1/2. The limit is invariant because applying F to an average changes only its two endpoints divided by the number of rows. Every individual constructed row still has the seed’s black right edge.

## Checks and decision

The [frozen control](vacuum_orbit.py) exhausted all 1,360 fixed-suffix maps for widths and times 1–4 (10,200 inputs), verifying bijectivity. It then assembled three nested assignments with B = 4 and independently replayed the *final* word using the four black neighbourhoods of Rule 30. The initial markers, fixed suffixes, shrinking triangles and moving right half-line all passed. The finite radii were chosen for a short test. The asymptotic fraction follows from the stage growth in the proof.

| Target tick | White radius there | Consecutive rows of the guaranteed shrinking triangle |
|---:|---:|---:|
| 14 | 8 | 9 |
| 120 | 96 | 97 |
| 1,242 | 1,024 | 1,025 |

Receipt in `share-scratch/gptM5/r4/vacuum-orbit-v1.json`, SHA-256 `e1acbed0fcdaf877483314e92a7f9f7d5c1ee5eae3608a9f89c3820547a317ad`.

**Decision: close R4 as an active pull.** R19 and M27 retain the exact count and its limit interpretation. M28's minimum observed slack of −4 rules out its preregistered C = 3. It leaves the existence of a larger uniform C mathematically open. The present construction shows why time invariance plus even a complete moving right-edge history of any chosen finite depth can coexist with positive vacuum mass. On the actual single seed the distant left bits are all fixed white. Whether its vacuum mass vanishes remains open.

Reopen if there is a quantitative use of the single seed’s far-left initial condition, or another seed-specific input that distinguishes the constructed orbit. One sufficient target would be a uniform bound on the time average of m(u) raised to 1+ε for some ε > 0. Then each omitted count (m−K)₊ is at most m^(1+ε)/K^ε, yielding an actual decaying tail by R19.
