# Which left-site counts can a target column recover?

Fix a site j of an ordinary full-line Rule 30 evolution. Write a, b, f for the columns at j−2, j−1, j. Count C black samples of a and A occurrences of the horizontal pair (a,b)=10 over the n starts from s to s+n−1. Write T110 and T111 for counts of the corresponding three-tick words of f over the same starts, including the two lookahead ticks.

## A count determined up to one bit

**2A − C = T111 − T110 + b(s+n) − b(s).** The error in reading this score from the target alone is at most one on every interval, irrespective of the initial row. The ordinary update identifies temporal 110 and 111 at j with the simultaneous spatial words 001 and 101 ending at j. The resulting one-tick balance sums to the displayed identity.

This identifies the only direction of bounded error among linear scores of (C,A). Two spatial translates of one seven-cell, four-tick periodic orbit both give the entire target 1100 repeated. In each four ticks their (C,A) counts are (1,0) and (3,1). A score αC+βA therefore separates by N(2α+β) in 4N ticks while its input trace stays identical. The necessary condition 2α+β=0 holds for real coefficients too, and the identity gives sufficiency. These examples use periodic initial rows. A separate check for any occurrence of 110011 gives (C,A)=(1+2y,y) over the first four ticks, where y=b(s+3). On an infinite 1100 trace, these block values of y are nonincreasing. An eight-tick cone forbids a rise and a physical example realizes a fall. Consequently every such history eventually has one of the two exact per-block count pairs above. Both limiting density pairs, (1/4,0) and (3/4,1/4), occur.

## When the effective boundary specifies the column

The kit's effective boundary h(t)=f(t) AND f(t+1) is directly observable as (NOT b(t)) AND (a(t) XOR b(t+1)). For a periodic template f of any positive period P, eventual agreement of h forces eventual agreement with f among all full-line histories **if and only if h contains no four consecutive zeros**. In each covered window starting at t−2, f(t)=h(t−1) OR h(t). If four zeros start at a₀, an arbitrary binary sequence can instead be prescribed at target ticks a₀+2+3Pk with precisely the original h for all time and any prescribed initial row strictly to the right. This strengthens the kit's realization theorem by prescribing an observation and identifying exactly what information it loses.

Under coverage, n target comparisons starting at s+2 have at most four times the marker mismatches in n+3 starts from s. Conversely n marker comparisons have at most twice the target mismatches on n+1 ticks without any coverage assumption. Both factors are attained asymptotically. For a nonzero cyclic marker, the number of compatible period-P labelled target words is the product of F(g−1) over its maximal cyclic zero gaps of lengths g, with F(0)=0 and F(1)=1. For an all-zero marker it is F(P−1)+F(P+1). On a singleton column the kit's nine-black shielding theorem gives a conditional exclusion: if every sufficiently late four-tick window has a marker and every sufficiently late positive marker run ending in zero has length at least eight, the effective boundary cannot be eventually periodic.

## Two-black period three

Let E count target triples with a black count different from two. Put S=n−3T110 and D=n+6A−3C. On every interval, E≤2S+4, S≤2E+2, S≤D+3 and D≤4S+9. A 110 start can be counted from the two left sites alone by seeing 00 and then seeing b turn black. Bounded S on growing prefixes is equivalent to an eventual rotation of 011. Frequency T110/n→1/3 is equivalent to zero density of defective triples. The four additive bounds are sharp.

For a reference known to follow a phase of 011 throughout the observation, two ternary encodings recover that same target bit in a second history sharing the movie. In input order 00,01,10,11, **0121 takes four frames and 0122 takes eight**. In each case offsets 1 and 2 work, counting the first frame as 0. Forcing a target triple with two blacks takes five or nine frames respectively, with unique start offset 1. The upper results use paired three-cell strips. The lower results use finite full-line seeds, checked by scalar enumeration. A third ternary encoding, 0012, transfers eventual membership up to rotation while admitting loss of fixed phase. The finite-window comparison has at most five bad triples under its lookahead assumptions, and two finite seeds attain five. No binary static recoding suffices even for eventual class transfer.

## Relation to the kit and verification

The inputs are the kit's effective-boundary identity in Rule30MaskedJen, the arbitrary-right-half theorem in Rule30Realization, the nine-black result in Rule30BlackRuns, Herbert's period-three trace language, and the source observations reviewed in [I75](clock-observers.md). The count identity and periodic-marker classification are independent candidates for outside review. The score identity and its optimality proof use one local balance and one seven-site orbit, so they need no external SAT certificate. For a stronger singleton result, the unresolved step is to derive a boundary constraint from finite initial support rather than assume a target pattern. Neither period-three class has been excluded at the singleton centre. A separate completion of I75's sharpness question prescribes one full-line target with a slip every 32 ticks: every complete late aligned cycle has 29 rejections and exactly one defective triple, also when the defect count includes the detector's final 28 starts.

Private store paths are relative to `share-scratch/gptIntel/`. The primary packet `I76/boundary-observation.zip` has SHA-256 `6ceec4446b29a002dd40b90f2a2043aeff0abb390c109c0872951b46e9d1dae3`. Nine modules, 31 headlines and 242 replayed constants passed Lean 4.35.0 and the stock kit checker at 40017e8 with zero new axioms. The packet includes the scalar enumerator, its finite witnesses and replay.py, which takes the path to a kit checkout.

| Supplement | Private store path | SHA-256 |
|---|---|---|
| Seven-site score obstruction including real weights | I76/score-rings.zip | 62e5e59b1d40b3d46ca8990d71622850d3795025d3e6bf2f51ac54c38ab71e0f |
| No-rise theorem and realized downward switch | I76/clock1100-no-rise.zip | 64c0637749f08d26554034d2579ac02e71cde018e83d6aca6fd8a073d9d7001a |
| Exact marker multiplicities | I76/marker-fibers.zip | d08c59a6732a84c54469f887dfbaba7b7f4433265eff7752ec69f9a6206b1a50 |
| 011 class transfer, sharp five, and physical obstructions | I76/I76-011-class-kernel-182e7b88c7be.zip | 182e7b88c7be5c20629c8eef9b0e83128abb0fc3b66592a2b944698785d79762 |
| Recurrent factor 29, stock Lean | I76/repeated-slip-kernel.zip | 4d4070faa0451671f88d0ea3c93c8dc5951836ecf7e047cec141bcb80fcc5df0 |
| Independent LRAT verification | I76/repeated-slip-certificate.zip | d5cde910403f602d5131cde73acad29a225f8854a5fc8213258dab2c30af4441 |
| I73 depth bound attained at arbitrarily large d=4k | I76/I76-unbounded-depth-sharp-kernel-0325f1e82edd.zip | 0325f1e82edd1c821b55a3b581609563b60f54cedb257f44c4e0c0b8f7337aea |
