# What the gap cutoff misses

R4, R18–R19 · gptM5 · 18 November 2026. The finite counts are COMPUTED. The deductions below are PROOF-SKETCH pending a carrying read. The cylinder and finite-vacuum mechanisms are known (P4).

Write x(u,i) for cell i at tick u, with black = 1. On the single-black-seed orbit, every white centre at t ≥ 2 has a unique gap g, the least positive j ≤ t with x(t−j,j−2) = 1. Its source is u = t−g. The kit proves existence, uniqueness and the following test. The row at u must be black throughout [−g,g−2], and at least one of g−1 and g must be black. [Kit theorem](../../KIT-INDEX.md) · [Lean statement](../../Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30CenterCylinders.lean)

## The complete count for one source

Use the black run through cell **−1**, the midpoint of every required interval. If −1 is white, set m(u) = 0. Otherwise let L and R count its black cells from −1 inclusively leftwards and rightwards, respectively. For a finite row the first white on the right is at R−1. Set b = x(u,R), the cell just beyond that white. Then

    m(u) = min(L, R−1+b).

The full list of gaps from this row is 1 through m(u). Indeed the solid interval fits exactly when g ≤ L and g ≤ R. For g < R the first guard cell g−1 is already black. At g = R the second guard is b. This includes the one-cell core for g = 1 and allows m = 0 even when −1 is black. For the seed, u = 0 contributes nothing. Up to tick T the source contributes min(m(u), T−u) observations for 0 ≤ u ≤ T. Gap uniqueness makes the time intervals disjoint.

If v > u is another source with m(v) ≥ 2 and m(u) ≥ 1, then v ≥ u+m(u)+1. Its own source row must be black at the centre, while all ticks u+1 through u+m(u) are white there. This spacing already charges the entire first interval. It leaves the following obstruction. The abstract schedule uⱼ = 2ʲ+j, mⱼ = 2ʲ for j ≥ 1 obeys that separation and the seed cone restriction mⱼ ≤ uⱼ. For each fixed K, all but O(Kj+j) ticks through the end of its j-th interval belong to gaps exceeding K. Its tail fraction tends to one. This is a counterexample to an inference from those two inequalities alone. Whether the Rule 30 seed can sustain such occupancy is the dynamical question.

## An exact spatial count for every cutoff

Let V_K be the event that cells −K through K are all white. For K ≥ 1, t ≥ max(2,K), on the seed,

    centre white at t with gap > K   ⇔   row t−K belongs to V_K.

Here is a short proof of the finite no-hit/vacuum identity used in placego GC2598. It applies on any trajectory if the left side is phrased as “white terminal and no hit at j = 1,…,K.” At K = 0 it just reads the terminal cell. For the induction, the last K−1 observations give a white interval [−K+1,K−1] at time t−K+1. The extra no-hit condition gives a white parent at K−2 at time t−K. In the update of the rightmost white output (at K−1), the left input is therefore zero. The rule l XOR (c OR r) forces its other two parents white. Sweep left through the other white outputs. Once c and r are white, a white output forces l white. This fills [−K,K]. Conversely, an all-white base yields an all-white forward cone, including the terminal and every tested diagonal site. Existence and uniqueness of the seed gap identify the no-hit event with g > K.

Thus the weighted error from truncating the white count through T equals the number of rows in V_K with indices max(0,2−K) through T−K, inclusive (an empty interval counts zero). Early t < K cannot have g > K. Equivalently, sum max(0,min(m(u),T−u)−K) over the source rows. Neither formula loses the multiplicity.

There is an exact limiting interpretation. Give each of the first T seed rows mass 1/T, and let C be the family of subsequential weak limits of these empirical measures on binary rows. Then

    lim as K→∞ of limsup as T→∞ of (omitted ticks through T)/T
      = max over μ in C of μ({the entirely white row}).

For fixed K, the time shift and endpoints change at most O(K+1) summands. V_K depends on finitely many cells, so its indicator is continuous. The inner limsup is therefore the maximum of μ(V_K) on C, which is compact by compactness of binary row space and its probability measures. These maxima decrease. Take a converging subsequence of maximisers as K grows. For each fixed radius r, its limit gives V_r at least the limiting maximum, since V_K is contained in V_r for K ≥ r. Intersect over r and use continuity of probability from above. The reverse inequality follows from the entirely white row belonging to every V_K. The mass refers to a limit of time averages, even though each individual seed row contains black. The vanishing of that mass on the seed orbit and the balance of short gaps are both open.

## Exact controls and next test

The frozen [control](check.py) compares literal Rule 30 truth-table evolution on shrinking words with the no-hit condition, and independently compares diagonal hits in the seed history with run lengths and vacuum windows. The arbitrary-word test exhausted 43,688 words (radii 1–7). R18's written total of 21,844 was an addition error. Its radius range and frozen program were correct.

| Gap cutoff K | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---:|---:|---:|---:|---:|---:|
| White ticks omitted through 4096 | 534 | 151 | 47 | 16 | 3 | 0 |

The 2,068 white ticks come from 1,534 distinct rows. The two counts agreed at every tested cutoff. The count at K = 6 is specific to this horizon. Receipt in `share-scratch/gptM5/r4/source-check-v1.json`, SHA-256 `8a77505f302accf1872cfb3af318e4ad125a1ec6953c4a5d7f6ef987c781f740`.

Next test on R4: work backwards one tick from the long black interval of a deep source. For a black output, l = 1 exactly when both c and r are zero. This gives just four predecessor words to compare for each block length, one per final bit pair. Determine which of their period-three phases and boundary bits can coexist with the previous source's white cone. The target is a restriction on the sizes or return times of successive deep sources beyond v ≥ u+m(u)+1. A larger cutoff census alone would leave the same inference open.
