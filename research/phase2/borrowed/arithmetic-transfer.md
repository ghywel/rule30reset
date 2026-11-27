# Arithmetic comparisons for K98

## 2. A sparse set of starts and repeated visits by one start

Mahler's half-interval condition forces the integer part to iterate by
`g ↦ ⌈3g/2⌉`. Its parities determine the fractional part by a convergent real
series. This makes the integer part an identifier for a possible Z-number,
and his count below X is O(X^0.7). The real contraction and the matching
2-adic expansion both use the affine branch formulas. Our archive already
records this argument. [Mahler, pp. 313–321](https://www.cambridge.org/core/services/aop-cambridge-core/content/view/6416420BFE33A5DDC3DAB6EA358C2B0B/S1446788700005371a.pdf/an-unsolved-problem-on-the-powers-of-32.pdf)

For every nonzero 3-adic λ, at most `2 X^(log₃ 2)` of the first X positive
exponents give λ2ⁿ with no ternary digit 2 (X ≥ 2). Lagarias credits Narkiewicz
for the original λ = 1 case. Remove the initial factors of 3. The first
`2·3^(k−1)` powers visit every unit modulo 3ᵏ once, including exactly
`2^(k−1)` acceptable residues. Choosing k to cover X gives the bound.
The transferable step is a count of visits *along one orbit* with bounded
multiplicity. The multiplicity here comes from a primitive root.
[Lagarias, published Theorem 1.5 and §3.1](https://deepblue.lib.umich.edu/bitstream/handle/2027.42/135390/jlms0562.pdf?sequence=1)

**Known, reproved here.** For the white Rule 30 wall, among starts below 4ⁿ
exactly 2ⁿ pass the first n even-time checks, by the free-bit bijection.
Consequently at most 2√X starts below X can be immortal (choose the least
4ⁿ ≥ X, X ≥ 1). This counts *different starts*. The time hybrid (30,240)
has the same prefix bijection because the bit at depth t+1 toggles the
wall-neighbour reading at t while preserving all earlier readings.
Nevertheless its finite row 1 goes to 3 and then back to 1, passing every
even check. This control rules out any Q01 deduction from the square-root
bound alone. [Kit and published free-cube counts](../ladder/sources.md)

**A cumulative equivalence at W1 (PROVED IN LEAN).** Write S(B,k) for the
number of starts below 2ᴮ passing the first k even-time checks. Q01 holds
exactly when the integer deficit `2048 B − S(B,k)` is unbounded above as
B and k vary. Indeed,
an immortal of width b gives 4,096 different immortal starts at each width
b+390, b+392, … by Benboubakeur et al. Distinct widths give disjoint sets
inside one census. Thus S(B,k) ≥ 2048 B − O(b+1), uniformly in k. The
reverse implication uses the kit's uniform death theorem. Under Q01 each
fixed B has a finite k with S(B,k)=0. The deficit condition also follows
from a sequence B tending to infinity with
liminf S(B,k(B))/B < 2048. The census lets the horizon vary and needs no
separate choice of odd and even widths. In K92.2's existing table,
`S(2n,2n) = A(n,n)` exactly. A bound `A(n,n) ≤ 4095 n` at unbounded n
would settle Q01 even if survivors persisted at every sampled width.
We have no estimate of the required strength. Build the source against
the same `ImmortalThreshold.olean` as
the [exact-width criterion](methods.md). [Formal deduction](WindowCensus.lean) · [Benboubakeur et al., published proof](https://www.wolframcloud.com/obj/rule-30-prize/Agents/api/file?id=R30-20261126-e2e0e2&kind=lean)

**Why branching a second time cannot multiply 4,096 (PROVED IN LEAN).**
Let F advance the packed wall row by one tick. The 4,096 constructed
ancestors at width b+s, for an even offset s ≥ 390, all reach the *same*
row F^(s+24)y after 24 ticks. A second invocation of the 24-tick theorem
first ages each ancestor at least 413 ticks. By then the common image has
persisted for at least 389 ticks. Even mixing shorter histories and earlier
joins cannot grow this batch. In general, suppose Fᴴa = F^(s+H)y and obtain a
new ancestor b by taking h inverse ticks from Fᵗa, where h ≤ t and h ≤ H.
Advancing b from tick h up to H shows Fᴴb = F^(s+t−h+H)y. Thus any chain
of these width-nondecreasing changes with depths at most H stays in one
H-tick preimage set at each width.

Given the endpoint and the h low bits seen over h ticks, reconstruct the
row uniquely by the kit's one-tick predecessor theorem, repeatedly. At
H = 24 all 12 even readings of an immortal are black. Only the 12 odd
readings can distinguish ancestors, so this one preimage set contains
at most 4,096 immortals. The original construction fills it exactly.
Even H = 25 leaves only 12 free readings. This bounds the starts
generated from one seed by the specified constructions. To force more,
one could exhibit a second endpoint at the same width with at least one
immortal start outside this set, or prove unbounded history depth along
the failed witness's own orbit with all odd histories realized from every
sufficiently late even age. The latter would give arbitrarily large
eventual multiplicities without a uniform age bound across witnesses.
[Common-image and uniqueness proofs](HistoryFibre.lean) · [Kit one-tick reconstruction](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30AgeTwentyFourInverse.lean#L439-L452)

## 5. Which upper bounds suffice on a single trace?

The Pyatetskii–Shapiro criterion takes **one constant for all finite words**.
If each length-k binary word has upper limiting frequency at most C·2⁻ᵏ
along the given trace, the trace is normal. Every empirical cluster measure
then gives each cylinder at most C times its fair-coin measure. This extends
to Borel sets, and shift invariance and ergodicity of the fair-coin law force
the two probability measures to coincide. Checking the two one-letter
bounds with C > 1 does not give this conclusion. The kit already proves
normality from convergence of empirical measures to the fair-coin measure,
and Problem 2 from the mass of [1] at every cluster point. Its Cramér bounds
sample random initial rows. [Bailey's hot-spot formulation](https://www.davidhbailey.com/dhbpapers/alpha-normal.pdf) · [Kit empirical measures](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/equivalents/Rule30Equivalents/EmpiricalMeasures.lean) · [Kit large deviations](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/equivalents/Rule30Equivalents/LargeDeviations.lean)

In the Stoneham example α₂,₃ = Σ 1/(3ʲ 2^(3ʲ)), doubling follows complete
cycles of unit residues over denominator 3ʲ between sparse corrections.
The number of visits to a given interval is bounded by its mesh count
times a bounded multiplicity. In Rule 30 the proved clocks sit a fixed
distance from the edge. The centre samples distance t at age t. A substitute
would have to track this changing distance and control repetitions
among the sampled ages. [Bailey, explicit α₂,₃ proof](https://www.davidhbailey.com/dhbpapers/alpha-normal.pdf) · [Bailey and Crandall, Theorem 4.8 and Corollary 4.9](https://www.emis.de/journals/EM/expmath/volumes/11/11.4/pp527_546.pdf)

## 9. Two smaller targets for the centre

**An averaged correlation test (standard van der Corput argument,
PROOF-SKETCH for this application).** Give a black centre value +1 and a
white value −1. Write xₜ for these signs and E(H,N) for the mean over
0 ≤ t < N of the square of (xₜ + ⋯ + xₜ₊ₕ₋₁)/H, with H ≥ 1. Shifting
the N-term average by j sites changes it by at most 2j/N. Averaging for
0 ≤ j < H and applying Cauchy–Schwarz bounds the absolute prefix bias by
√E(H,N) + (H−1)/N. Hence a single H with limsup E(H,N) ≤ 1−δ, δ > 0,
gives both colours lower density at least (1−√(1−δ))/2.
If inf over H of limsup as N tends to infinity of E(H,N) is zero, Problem 2
holds. Expanding the square uses only pair correlations at lags below H,
with weights H−j, up to an endpoint error vanishing for fixed H. A balanced
alternating trace passes with E(2,N)=0 despite its long-word frequencies.
The sequence formed by concatenating 0ʲ1ʲ for j=1,2,… has density one half
and E(H,N)→1 for each fixed H, so the test is genuinely sufficient only.
[Bergelson, Theorem 1.32](https://people.math.osu.edu/bergelson.1/vb_codet23nov05.pdf) · [Kit lag frequencies and their exact scope](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/equivalents/Rule30Equivalents/Autocorrelation.lean)

At H = 2 the quantity E is exactly the fraction of consecutive centre bits
that agree. Rule 30 turns a black centre white precisely when its west
neighbour is black. Thus if adjacent sites −1 and 0 are simultaneously black
at a positive lower density η of ticks, both centre colours have lower
density at least η, by counting the black starts and white endpoints of
the falls. Recurrence of that spatial pair is already proved. A still
smaller target is to make its cumulative count grow faster than log N,
which would raise the known logarithmic floor for both colours without
requiring a density. [Physical fall identity and existing shell bounds](../falling-phases/README.md) · [W2 baseline](../../../WALLS.md)

An external benchmark is Ω(N^(1/D)) ones in the first N binary digits
of an irrational algebraic of degree D. Applying the same theorem to its
complement gives the corresponding zero count for a value in (0,1).
The proof uses the defining polynomial and bounds for sums of occupied bit
positions. Identifying the centre expansion as irrational algebraic already
includes Problem 1. For integers, Stewart proves a growing lower bound on
the sum of the counts of digits different from specified digits in two
multiplicatively independent bases. Applying it would require two sparse
expansions of the **same** integer. Two ways of reading a spacetime diagram
provide no such arithmetic identity. [Bailey, Borwein, Crandall and Pomerance, Theorem 7.1](https://www.davidhbailey.com/dhbpapers/algebraic-bits.pdf) · [Stewart, Theorem 1 and §§2–3](https://uwaterloo.ca/pure-mathematics/sites/default/files/uploads/documents/j-reine-ange-math-1980.pdf)
