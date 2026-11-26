---
Template: ComputationalEssay
Name: Every Real Point of Rule 30's Density Pentagon Is Attained at One Site, from Any Right Half, with Square-Root Error
Author: {AUTHORS}
Date: 2026-11-26
Description: Lean with Mathlib. The pairs of real numbers that are limiting black and run-end frequencies at one site of rule 30 are exactly the closed pentagon, and each is attained from any prescribed right half with squared count errors at most 210000(n + 1) at every tick.
Abstract: {ABSTRACT}
Keywords: [rule 30, Rule 30 Prize, density, black frequency, run ends, pentagon, limiting frequencies, real numbers, controller schedule, discrepancy, Mathlib, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

Let `x : ℤ → Bool` be a row and `evol x` its rule 30 history. At site 0, count in the first `n` ticks the black cells, `C(n)` (`black (evol x) 0 0 n`), and the run ends, ticks where site 0 is black and site 1 is white, `A(n)` (`ends (evol x) 0 0 n`). The row has densities `(c, a)` (`HasDensities x c a`) when `C(n)/n → c` and `A(n)/n → a` as `n → ∞`, in the real numbers. `InPentagon c a` is the closed pentagon `0 ≤ a ≤ c`, `3c ≤ 1 + 5a`, `2c ≤ 1 + 2a`, `6c ≤ 5 + a`.

**The theorems**, all in the namespace `Rule30Submission`:
- `real_density_region`: for every right half `r : ℕ → Bool` and all real `c`, `a`, some row with `evol x 0 j = r j` for every `j ≥ 0` has densities `(c, a)` exactly when `InPentagon c a`.
- `limits_from_any_right_half`: the construction direction.
- `quantitative_realization`: the row can be chosen with `(C(n) − cn)² ≤ 210000(n + 1)` and `(A(n) − an)² ≤ 210000(n + 1)` at every tick `n`. The constant does not depend on the point or on the right half.
- `necessary`: every row with densities has them in the pentagon.

The right half is fixed first, and includes the observed sites 0 and 1. Only the left half is chosen.

## 2. Where it sits

Our entry R30-20261123-b2be99, in the kit, found the pentagon. It proved the finite forms of the five inequalities for every history, gave a periodic history at each of the five corners, and realized each rational point of the pentagon on one history from any right half. This entry takes the last step, from rational to real points, and makes the error uniform. The rounding argument is the natural one, and we claim no novelty for it. What is new is the exact real region as a theorem, with an explicit square-root error.

## 3. Exploration

**The pentagon.** Its corners are `(0, 0)`, `(1/3, 0)`, `(3/4, 1/4)`, `(9/10, 2/5)` and `(1, 1)`. In red is the irrational target `(√2/6, 0)`:

```wl
vertices = {{0, 0}, {1/3, 0}, {3/4, 1/4}, {9/10, 2/5}, {1, 1}};
target = {Sqrt[2]/6, 0};
Graphics[{LightBlue, EdgeForm[Black], Polygon[vertices], Black, PointSize[Medium], Point[vertices], Red, Point[target]},
 Frame -> True, FrameLabel -> {"black frequency c", "run-end frequency a"}]
```

**The weights.** The pentagon is the union of three triangles at the origin. On each, the point's barycentric weights on the five corners are linear in `(c, a)`, the formulas of `weights_of_faces`. They are nonnegative and add to one, and they reproduce the point. For the target the weights go to `(0, 0)` and `(1/3, 0)` only:

```wl
weights[{c_, a_}] := Which[3 a <= c, {1 - 3 c + 5 a, 3 c - 9 a, 4 a, 0, 0},
   9 a <= 4 c, {1 - 2 c + 2 a, 0, 16 c/3 - 12 a, 10 a - 10 c/3, 0},
   True, {(5 - 6 c + a)/5, 0, 0, 2 (c - a), (9 a - 4 c)/5}];
w = weights[target];
{N[w], Simplify[Total[w]], Simplify[w . vertices] == target}
```

The same check on every rational point with denominator at most 20, inside the pentagon:

```wl
inPentagon[{c_, a_}] := 0 <= a <= c && 3 c <= 1 + 5 a && 2 c <= 1 + 2 a && 6 c <= 5 + a;
pts = Union[Flatten[Table[{p/q, s/q}, {q, 1, 20}, {p, 0, q}, {s, 0, q}], 2]];
inside = Select[pts, inPentagon];
{Length[inside], AllTrue[inside, With[{v = weights[#]}, AllTrue[v, NonNegative] && Total[v] == 1 && v . vertices == #] &]}
```

## 4. The proof

1. **The controllers** (the earlier entry's `Rule30DensityControl`, `Rule30DensityModes`, `Rule30DensityVertices`, `Rule30DensityMixtures`). From any state, the left half can be steered so that site 0 follows any one corner's periodic history, after a bounded number of steering ticks. Any schedule of corners and durations can be followed in this way, from any right half.
2. **The schedule** (`realize_weights`). In epoch `e`, follow corner `i` for `⌊e wᵢ⌋` ticks, after steering to it. Even a corner of weight zero pays its steering time. The five steering times add to 69, so epoch `e` lasts between `e + 64` and `e + 69` ticks.
3. **The error.** In an epoch both counts gain their target fraction of `e`, with error at most 250. After the steering is charged to the elapsed time, the error at the start of epoch `e` is at most `319e`. Inside an epoch the error grows by at most the ticks elapsed. Since epoch `e` starts near tick `e²/2`, this gives `(C(n) − cn)² ≤ 210000(n + 1)` at every tick, and the same for `A`.
4. **The limits** (`limits_from_any_right_half`). A squared error of order `n` gives an error of order `√n`, so `C(n)/n → c` and `A(n)/n → a`.
5. **The converse** (`necessary`). Each finite inequality of the earlier entry, such as `2C(n) ≤ n + 2A(n) + 1`, divided by `n`, passes to the limit.

## 5. Prior art and credit

- **The pentagon, the corner histories, the controllers and the rational schedule** are our entry R30-20261123-b2be99, in the kit as thirteen modules. They are used here through their statements. Six of them, or the parts used, are carried in this entry's source.
- **The counts** `C` and `A` are those of David Condrey's `Rule30SourceObservables` (with OpenAI Codex), in the kit, also carried.
- **The real-number argument** was first given by hand in the rule30reset record, and is formalized here.
- **Search.** We searched the portal's 437 entries, the kit's catalogue and its open pull requests for limiting black and run-end frequencies at one site, and for real density regions. We found only the earlier entry.

## 6. What is not proved

- The theorem fixes the right half and the observed site. It does not say which densities the single seed has, or whether its frequencies converge. Problem 2 is not settled.
- The error is of order `√n`. Whether a bounded error is possible depends on the point; at the corner `(9/10, 2/5)`, a bounded error forces the whole left half to be periodic (our companion entry on the 155-column film).
- Joint frequencies of other observables are not treated.

## The formal proof

The module uses Mathlib's real numbers, limits and `linarith`. It imports the kit's `Rule30Realization` and `Rule30Prize`, both present at the verifier's kit revision, and seven narrow Mathlib modules. Seven kit modules that the revision lacks are carried in their own namespaces from the kit at `71151d0`: David Condrey's `Rule30SourceObservables`, which defines the counts, and from the earlier entry `Rule30SourceDensityRegion`, `Rule30DensityControl`, `Rule30DensityModes`, `Rule30DensityVertices`, and the parts of `Rule30DensityPolygon` and `Rule30DensityMixtures` that are used. One space is added in `Rule30DensityControl`, since Mathlib reads `<i` as a token. Then comes the module of this entry, in `Rule30Submission`, which holds the four headlines.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

## The formal checks

The four headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.real_density_region", "Rule30Submission.limits_from_any_right_half", "Rule30Submission.quantitative_realization", "Rule30Submission.necessary"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The pentagon, as Lean holds it:

```wl
rule30Submission["Rule30Submission.InPentagon"]["TermForm"]
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.necessary"]["KernelCheck"]
```
