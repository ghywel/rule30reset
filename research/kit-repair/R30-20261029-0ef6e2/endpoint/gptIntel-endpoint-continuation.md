# N6 after the carrying read

## Which phase lines are admitted?

For an irrational real α, the integer increment condition in N13 has an exact interpretation, including time zero. There is a real θ such that either

- f(t) = ⌊tα + θ⌋ for every t ≥ 0, or
- f(t) = ⌈tα + θ⌉ − 1 for every t ≥ 0.

Both conventions satisfy the increment condition. In the upper convention the ordinary floor can differ at only one index, where tα + θ is an integer. Two such indices would make a nonzero integer multiple of α an integer. At the end of the arc this matters: f(t) = ⌈tα⌉ − 1 differs from ⌊tα⌋ at t = 0.

The proof sets E(t) = f(t) − tα. The increment condition and irrationality give E(s) < E(t) + 1 for every s,t. Let θ be the supremum of E. Then E(t) ≤ θ ≤ E(t) + 1. If the right equality never occurs, rounding down works everywhere. If it occurs at s, the strict inequality E(t) < E(s) + 1 = θ holds for every t, so rounding up and subtracting one works everywhere. This formalizes the classical lower/upper mechanical-word distinction for N13’s exact predicate. [Lean proof](PhaseLineBridge.lean) · [Morse and Hedlund, *Sturmian Trajectories*](https://doi.org/10.2307/2371431)

## The geometric statement on a real arc

`rotation_block_excluded` allows any irrational real angle, arc [0,γ) with 0 < γ < 1, either endpoint, an arbitrary signed displacement d along its orbit, and any Boolean function of r consecutive arc readings. The neighbour may start agreeing at any white index H after the clock begins. In Lean the input to the Boolean function is literally `Fin r → Bool`. The proof advances k = H + |d| white ticks, after which k+d is a natural index, and relates every letter in the window to the corresponding signed difference of floors. This gives a single real-angle theorem a reader can use directly in the portal form. [Lean proof](RealBlockBridge.lean)

## Finite partitions supported on two cut orbits

Fix the base arc A = [0,γ), and suppose each boundary of a finite half-open partition is a translate, by an integer number of rotation steps, of 0 or γ. Give the resulting intervals any Boolean labels. There is a single finite window of observations of A that determines the new label at every point, including the cuts themselves.

To see this, take a consecutive range of signed sample offsets that includes one witnessing offset for each required boundary. The observation at offset n cuts the circle at −nα and γ−nα. Enlarge the range until its length exceeds the connectedness index of the binary rotation coding. Then every nonempty set of points with one observation word is a single half-open interval between consecutive observation cuts. Every target boundary is one of those cuts, so the target label is constant on each such interval. This constructs a truth table on the realized words. Signed offsets are absorbed into d in the real theorem. The geometry is an application of an existing connectedness theorem. The resulting exclusion concerns a start on either of the two base orbits. [Alessandri and Berthé, §4.1 and Lemma 3](https://www.theoremoftheday.org/Docs/3dAlessandriBerthe.pdf)

An exact example takes α = √2−1 and γ = 1/20. Alternate the labels at the four cuts 0, γ, 2α and γ−3α modulo one. With left offset fixed at −2, observations through +14 still give the same 17 zeros to two different colours. Through +15 all 26 realized words determine the colour on all 36 joint intervals. The calculation compares exact quadratic numbers at the included endpoint of every interval. This proves minimality for that fixed left offset. The general geometric passage above is a hand corollary. [Example and replay](gptIntel_partition_example.py)

## Reproduction

The original N13 kit module imported by the full `Ruliology` target builds on kit commit `88fdac9` (349 Lake jobs). Both companions import the separate Mathlib `RealBridge`. The optional self-contained portal form carries N13 and the three additional theorems in a single 99,957-byte source, SHA-256 `03f435045076eeacb7f1ea3fb81e1a4fac58e0d9d50c6a5c56b09677387f9da1`. The private review bundle is `share-scratch/gptIntel/S19/I222-bridges.zip`. Its `extend_portal.py` regenerates those exact bytes from the included sources with `python extend_portal.py sources reproduced.lean`. The new real-angle readout is a natural packet headline. The rounding characterization supports the interpretation of the proof.
