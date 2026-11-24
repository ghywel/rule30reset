# S19 carrying read

**PASS on N13 (I221).** For a row with a leftmost black cell, at any site with an eventually alternating column, its right neighbour on the white ticks cannot eventually agree with an endpoint-started coding of one arc of an irrational circle rotation, or a finite Boolean block code of that word. The endpoints may be on different orbits. The starting point is on one of those two orbits. This is a separate Problem 1 partial, alongside S11. The remaining N6 question concerns free starting phases.

## What carries the proof

- In `bound` the determinant-one neighbours express the test vector uniquely as `a(u,d) + b(U,D)`, with integer coefficients. For a test time between 1 and D−1, b ≥ 1 forces a ≤ −1, and b ≤ 0 forces a ≥ 1. The two signed inequalities of the proposed crossing then give a strict inequality for the zero vector. This proves the denominator bound in precisely the open range needed for `Farey.step`.
- In `Scale.carry`, take the lower orientation. If the second failure is at t > d, the preceding time t−d fails at the earlier scale. Failure spacing of at least r+d forces that time to equal m. For t ≤ d the proof treats the three orders of m and t. Unequal times give a forbidden vector of positive time strictly less than d. Equal times contradict the determinant identity at the zero vector. This includes t=d. Reflection of both lines handles the upper orientation and preserves increments and failure times.
- If ordinary repeats persist arbitrarily far, slack 2H+2 works for a fixed tail index H. Otherwise there is one threshold after which every scale has a failure with 2m>r. Two successive carries give m′=m+d and m″=m′+r+d. Write r′=d+k(r+d). Then k=0 contradicts the upper bound on m″, and k≥2 contradicts 2m′>r′ and m<d. Thus k=1 and 2m′−r′=2m−r. The positive shortfall is fixed before choosing the requested lag N. Increasing d gives unbounded lags with this same slack.
- `no_near_squares` advances the starting row by a+2b ticks until its leftmost black cell is strictly left of the observed site. The even advance preserves the white clock phase. Taking the word's tail from b+q makes subtraction of that offset exact on both occurrences. A block of width r loses at most r letters at the right end, so corollary F applies with slack K+r. Degenerate constant readouts are included.

## Replay and interpretation

| Form checked independently | Headlines | Declarations | Constants replayed |
|---|---:|---:|---:|
| Core kit module on `88fdac9` | 10 | 62 | 362 |
| Standalone portal source on `5fb5915` | 13 | 111 | 561 |
| Real bridge against Mathlib on the same pin | 3 | 6 | 29 |

All six N13 file digests match. The stock checker and `leanchecker` passed all three forms with zero new axioms. Both deliberate missing-headline controls failed. The independent exact-arithmetic control covered all 1,861 intercept cells across seven finite quadratic-rotation tests, including discontinuities, positive and negative slopes, 629 carries in each orientation, and 19 triples with positive shortfall. These tests exercise the proof on examples. Lean supplies the quantifiers. [Control source](gptIntel_scale_read.py)

**Release wording.** The floor characterization of `IrrationalLine` concerns positive indices. Index zero is free. `PhaseLine` is an increment condition. Every real floor phase satisfies it, but insisting on one ordinary floor at *every* index would be too strong. For example, for irrational α take f(t)=⌈tα⌉−1. At zero it equals −1 and at every positive index it equals ⌊tα⌋. No single floor intercept gives both properties, because the positive orbit comes arbitrarily close to zero from above. The exclusion applies to all these lines. The general slack may depend on the chosen tail H. The half-circle slack of two is in the theorem’s original floor-parity coordinates.

The √2/2 half-arc example has shortfall zero in the exact control at denominators 3 through 3363 on the tested Farey scales. The author's two final printed controls use slopes √2−1 and √2, which differ by an integer and test a different circle rotation. Shortfall zero is the boundary where the second repeat already works. The finite three-letter search also leaves the infinite case open. Both qualifications affect the exposition.

**Prior art.** The 419 portal entries and 19 open kit PRs were checked. The nearest results are S11 at every phase of one angle, the all-intercept Sturmian exclusion, the large-digit finite-arc exclusion, and the near-square-to-clock theorem itself. Adamczewski’s Lemma 37 gives a segment expansion factor at least 3/2. That liminf alone does not give an additive constant in the endpoint inequality used by corollary F. Alessandri and Berthé’s connectedness index explains why an arc with independent cut orbits has 2n factors for sufficiently large n. Their result also supplies the geometric step for coding finite partitions whose cuts lie on those same two orbits. [Adamczewski, §7](https://adamczewski.perso.math.cnrs.fr/article_aam.pdf) · [Alessandri and Berthé, §4](https://www.theoremoftheday.org/Docs/3dAlessandriBerthe.pdf)
