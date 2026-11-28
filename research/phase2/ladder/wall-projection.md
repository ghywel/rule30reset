# K92.2 — Wall projection and exact surviving widths

R140 registered the projection test before the run. R141 records its result.

## The wall half can lose distinct rows

Let `F` be one packed zero-wall Rule 30 step and `G = F²`. In the even-pinned cube at
parameter `n`, the starts are `0 ≤ y < 4ⁿ` with wall readings true at ticks
`0, 2, …, 2n − 2`. The aged images are their rows at physical tick `2n`. Write `D(n)` for the
number of distinct images and `V(n)` for the set of their low `2n` bit words. The finite
trace-prefix bijection in the kit's `Rule30ZeroCoastBridge` also identifies `V(n)` with the
set of the next `2n` wall-reading words, now on **all** physical ticks.

**Refuted.** M224's proposed equality `D(n) = |V(n)|` for all `n` fails at both `n = 5`
and `n = 6`. These widths were absent from its saved wall-half sweep. The count and
recurrence results in M224 use full images and are unaffected.

| n | Starts | Aged images | Starting widths | Shared low word (integer) | Common prefix length | D(n) | \|V(n)\| |
|---:|---|---|---|---:|---:|---:|---:|
| 5 | 579, 413 | 822074, 411450 | 10, 9 | 826 | 10 | 22 | 21 |
| 6 | 1277, 2997 | 6561921, 13164673 | 11, 12 | 129 | 14 | 38 | 37 |

These are the only collisions between distinct aged images in either pinned phase for
`1 ≤ n ≤ 20`. In each failed cube exactly one wall word has two images. The respective
next wall-reading words, in time order, are `0101111100` and `110111011101`. A per-cell
Rule 30 truth-table replay verifies the traces and the images. The Lean theorems give
the exact counterexamples independently of the census.

**Computed scope.** At equal support widths the wall half separates every pair of
distinct aged images in both pinned phases through `n = 20`. The two witnesses have
adjacent widths, so even the wall half together with the width parity separates the
images on this range. The same-width test without pins fails first at `n = 6` on the
range `1 ≤ n ≤ 9`. Starts 1234 and 1700 give distinct images 6563620 and 7300900, both
of width 23, with 14 common wall bits. The first R140 prediction failed and the
unpinned prediction held. The width-tagged separation statement for all pinned widths
remains open.

## Exact widths suffice for Q01

**Proved in Lean.** Q01 is equivalent to the following property. For each parity and
above each bound, there is a top-bit position `p` of that parity and a finite even-check
horizon `k` at which every row with exact top bit `p` has failed a check. The horizons
can be chosen independently. The width of such a row is `p + 1`.

For the forward-orbit argument, start with a hypothetical immortal `x`. Its `q`-th
iterate under `G` still passes every check, and its top bit is at
`log₂ x + 2q`. One missing position of the matching parity above `log₂ x` suffices for
a contradiction. Conversely, Q01 gives a finite failure time for each row.
Taking the maximum over the finitely many rows at a fixed width gives a common
horizon. This is the exact-width version of I320's forward age census argument.
I287's sparse-width criterion allows up to 4095 survivors at each chosen width and
uses Benboubakeur et al.'s 4096-row amplification. The zero-survivor version here
uses only the forward orbit and top-bit motion.

**Diagonal corollary.** At arbitrarily large parameters `n`, it would suffice to
rule out survivors of the first `2n` even checks only at the exact widths `2n − 1`
and `2n`. Equivalently, among the `n)-check survivors in N38's cube, prove that every
start in the top two width classes fails one of the next `n` even checks. N38
already computed this for `17 ≤ n ≤ 38` by ruling out *all* widths up to `2n`.
The two-width target drops the need to bound the full image count or reconstruct
rows from trace vocabulary. The unbounded-width step remains open.

## Reproduction

The pinned census reconstructs each prescribed trace, checks it against the
forward evolution, ages the seed and deduplicates full rows in wall-first order.
An equal-prefix class is an interval in that order. Its different-width maximum
is found at an adjacent boundary between widths, while the same-width maximum
uses consecutive entries of each width. An independent direct census enumerated all
`4ⁿ` starts and agreed on the counts and both prefix maxima for all 27
combinations of phase (including unpinned) and `1 ≤ n ≤ 9`.

```sh
clang++ -O3 -std=c++17 -Wall -Wextra research/phase2/ladder/wall_projection.cpp -o /tmp/wall_projection
/tmp/wall_projection 20 9
```

[Census source](wall_projection.cpp) and [full output](data/gptM5-wall-projection.txt).
[M224's saved sweep](data/claudeM5-wall-half.txt).
[Lean source](WallProjection.lean) and [verification receipt](data/gptM5-wall-projection-lean.json).
Lean 4.35.0 replayed the module against kit commit `ea5d70e`. The stock checker
verified five headlines and 32 declarations with standard axioms only. The
missing-headline control failed and `leanchecker` passed. The kit checker
itself emits a deprecation warning for its replay API.
