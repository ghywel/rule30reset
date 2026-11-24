# What a finite flip can do on a fair Rule 30 row

**B1 and B2.** On almost every fair two-sided row, any nonempty finite set of flipped cells has one of two behaviours. Its leftmost difference visits arbitrarily distant sites to the west, or its leftmost difference tends to positive infinity. The westward record has an almost-sure upper speed of **at most 1,142,503/4,194,304 (0.272394 cells per tick)**. Whether it has positive speed, or whether rightward escape has zero fair probability, remains open.

Here a difference means unequal physical cells in two full runs. Write Dₜ for the finite set of differences at tick t, Lₜ for its least element and Mₜ for the least element seen through tick t. A leftward advance of M has length one by the light cone. The rightmost difference moves right exactly one site every tick by left permutivity, so Dₜ stays nonempty. The following two arguments use fresh fair bits at different places.

## A fair trial when the driven gates disagree

Fix an observation site q strictly west of the initial change. Under a full fair row, its original centre trace W is an independent fair sequence, independent of the entire initial row east of q. This is the kit's trace/right product theorem after a spatial translation. Drive both initial right halves by W. Their gate bits at tick t depend on the right halves and W strictly before t. As long as the site q has agreed, both actual diagrams at and west of q agree, and their eastern evolutions are exactly the two driven runs. The first difference at q is therefore at tick t+1 precisely when the driven gates differ at t and Wₜ is white. [Product theorem](../../../Rule30PrizeKit/equivalents/Rule30Equivalents/RandomConfigurations.lean) · [Left and right coupling](../../../Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Coupled.lean)

Let Nₜ count differing driven gates before t, and let Iₜ be the indicator that every such trial saw a black wall. Conditional on any fixed initial right pair, **`2^(Nₜ) Iₜ` is a mean-one martingale**. Its one-step factor at a differing gate is two on black and zero on white. At every other tick it is one. Stopping at the m-th trial (first truncating by a deterministic horizon) shows that the chance of encountering and passing m such trials is at most 2⁻ᵐ. In particular, a forever-silent observer almost surely has only finitely many driven gate differences. This argument uses trials selected before the current coin is seen.

There is also an exact way to compute the probability of silence. Force the driving bit black at each gate mismatch, and draw an independent fair bit at all other ticks. A surviving T-bit word with m trials then receives 2ᵐ times its original probability. Thus the physical probability of silence through T equals the expectation of 2⁻ᴺᵀ in this forced experiment. Bounded convergence gives the infinite version, taking 2⁻∞=0. Silence has positive probability precisely when the forced experiment has a positive probability of finitely many mismatches.

### From one observer to the whole front

Choose a simultaneous full-measure set on which the one-site conclusion holds for every integer observer, every deterministic finite flip mask east of it, and every time restart. There are countably many such tests. Each restarted *original* row has the fair law because Rule 30 preserves that law. At a restart the actual difference mask may depend on the row; the simultaneous assertion applies to every possible finite value of the mask.

If D never reaches q from the east, no difference can jump over q. By the one-site conclusion, its neighbour q+1 differs at only finitely many ticks. After the last such tick the two rows agree forever on every site through q+1. Restart there, using the countable choice of time and mask. Inductively, every fixed site is eventually strictly west of the entire difference set. Hence Lₜ→+∞. If the overall west record is finite, choose q still farther west and apply the same conclusion. Otherwise liminf Lₜ=−∞.

For a single initial flip at site zero, let P_d be the probability that site −d is never reached. Then P_d increases with d to the probability of escape to the right. By spatial covariance, B1 for every fixed positive flip distance is equivalent to the vanishing of this escape probability. An escaping perturbation can have crossed a specified observer earlier.

The kit supplies an exact exceptional pair. Initial right halves `1,0,0,…` and `1,1,0,…` differ only at +2. With the same white centre and any common west they have identical centre traces forever. Related response equivalences hold on the kit's specified eventually white tails after splicing. These are genuine single-flip obstructions to a universal claim. The fixed infinite eastern tails have zero fair probability. [Lowry, Rule30FeedbackErasure](../../../Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30FeedbackErasure.lean) · [Controlled response predicates](../../../Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30ControlledResponse.lean)

### Exact finite hearing probabilities

For each mask and T≤16, the finite table assigns an integer count to every possible number of successful mismatch trials. For T=16 the denominator is 2³², accounting for 16 fair eastern input bits and 16 fair wall bits.

| Flipped sites | Silent through tick 16 | Heard by tick 16 |
|---|---:|---:|
| +1 | 112,323,972 | 97.38475% |
| +3 | 746,026,588 | 82.63021% |
| +6 | 2,344,497,864 | 45.41291% |
| +1 and +3 | 106,423,066 | 97.52214% |

For each of the 65,536 eastern prefixes the weighted sum over surviving wall words of 2ᵐ was exactly 65,536. A separate exhaustive ordinary full-row evolution at T=4,8 verified the whole count vector. The finite silent fractions bound the chance of never hearing the given change at that specified observer. [Integer counter and independent physical control](lower-hazard.cpp)

## A speed bound for the west record

Fix **both** initial eastern halves from the first changed site m₀ onward. To their west draw one common sequence of fair bits. The speed proof below holds under this conditioning even for an exceptional prescribed east. For a fair full row intersect over the countable set of finite masks to obtain the result simultaneously for all finite changes.

At tick t, with historical west record m=Mₜ, expose all initial cells at or east of b=m−t. This gives both current rows at every site ≥m. The unrevealed common western bits remain fresh. To see this by induction, the common cell c at site m−1 and time t equals the as-yet unseen initial bit at b−1 XOR a function of the exposed half. The extremal western input passes with coefficient one at every physical tick. Reveal that one bit. The record advances precisely when the rows differ at m and c=0. On a nonadvance, the next exposure cut is b−1 and we stop revealing. On an advance it is b−2. Reveal the bit at b−2, which similarly supplies the common cell u at m−2, fair even given c and the previous east. These decisions inspect consecutive fresh western bits without either selection depending on an unread bit. The actual leftmost difference may retreat arbitrarily far while the record remains at m.

At width w keep the two w-cell patterns at sites m through m+w−1; both use bit zero for m. The actual pair of eastern bits at m+w is already determined by the exposed data. Allow any of its four values as an action. At a nonadvance the new w cells are the ordinary updates at m through m+w−1 using west c and that action. At an advance the new record starts at m−1. Its two low bits are u XOR the two old low bits, and the rest are updates from m through m+w−2 with west zero. Both u values are given equal weight also on a nonadvance as identical copies of that transition, without revealing the second physical bit.

For each state s and action e, an integer table P and scale D certify

```text
Σ over (c,u) of [D · advance + P(next) − P(s)] ≤ 4D v.
```

The conditional drift of (m₀−Mₜ) + P(sₜ)/D is at most v. The martingale part has bounded differences, so its ratio to t goes to zero almost surely; for example apply the bounded-difference inequality at each integer t and sum its exponential tails. The bounded potential disappears on dividing by t. Thus limsup (m₀−Mₜ)/t ≤ v. This bounds westward displacement of the actual defect as well.

Width two already gives **2/5** by hand-checkable integers. Use D=5 and list P in order 4a+b, for a,b=0,1,2,3:

```text
 0  7  4  7
 7  0  5  0
 4  5 -6  5
 7  0  5 -2
```

The largest four-outcome sum is eight. Larger widths allow the following tighter certificates. The production loop uses integer relative value iteration; validity only requires the displayed inequality, which a separate scalar checker verifies directly from the three physical inputs at each updated cell.

| Width | Pair states | Certified v |
|---:|---:|---:|
| 2 | 16 | 2/5 |
| 3 | 64 | 768523/2097152 |
| 4 | 256 | 1415223/4194304 |
| 5 | 1024 | 1264591/4194304 |
| 6 | 4096 | 1220991/4194304 |
| 7 | 16384 | 1172039/4194304 |
| 8 | 65536 | 1142503/4194304 |

For the width-eight certificate the oscillation L of P/D is 8785531/1048576. The same conditional bounded-difference argument gives, for every x≥0, the finite-time estimate

```text
Pr(m₀ − M_T ≥ vT + L + x) ≤ exp(−2x²/[T(1+L)²]).
```

Each centred increment has conditional range of length at most 1+L. This uniform tail bound also holds for two fixed eastern halves with infinitely many differences. If they later become equal everywhere, their historical record stays where it was.

A shorter check of the mechanism gives v≤3/7 without a stored potential. At active ticks the copies differ at the record. Call the active tick type i if the copy white there has eastern neighbour i. Of A active ticks through time T, the number of advances is A/2+o(T), by the bounded martingale differences of the fresh crossing coins. Each type-1 advance gives another type-1 tick, as both new eastern neighbours are black. On a type-0 advance, the independent u selects the new white copy and yields type 1 with probability 1/2. If A₀,A₁ count the respective types, distinct advances therefore give A₁≥A₁/2+A₀/4+o(T), hence A₁≥A/3+o(T). At a failed type-1 attempt the two central bits heal to white and the record does not move, so the next tick is inactive. Each such failure charges a different inactive tick. Thus T−A≥A₁/2+o(T) and the record makes at most 3T/7+o(T) advances. All frequencies used here concern predictable indicator counts with bounded martingale errors; no stationarity of the record state is assumed.

We have allowed the outside inputs to change freely each tick. In the relaxed model, an equal pair of windows can remain equal forever by using identical eastern inputs. A positive lower speed for a physical finite flip would have to use information about the genuine eastern process. The exact unit speed of the opposite front is compatible with rightward escape.

Run `python lower-speed.py --make 8 width8.json` to regenerate the strongest table (SHA-256 `959a2192251fa8dd21d6d92dbcd8275baedaa7862370fafe0f8d788751acf2af`), then `python lower-speed.py --check width8.json`. The second command uses only the Python standard library. To reproduce the short hand certificate add `--scale 5` with width two. Compile the hearing counter with `g++ -O3 -std=c++17 lower-hazard.cpp -o hazard` and use `hazard 16 1` for the single flip at +1. [Potential builder and scalar verifier](lower-speed.py)

## What the entropy measurements can establish

The fair temporal column A and initial east are independent. The adjacent column B at tick t depends on the initial east and A strictly before t. Therefore the finite Shannon increment of the pair equals one bit plus H(Bₜ | A before t, B before t). Stationarity makes the pair increments decrease to the pair entropy rate. A finite positive increment bounds the limiting increment from above. K83 measured collision entropy on three fixed wall words over finite horizons. The observed slopes invite a longer test but do not supply a uniform positive lower bound on this decreasing infinite-past conditional entropy. If the fair pair entropy rate were strictly above one bit, the variational principle would give the same strict inequality for topological entropy. Equality of those two entropies is not used.

The west-record bound also gives a direct upper bound of 1+v bits per tick for the fair pair entropy. Fix ε>0 and resample all sites from q=⌈(v+ε)T⌉+2 eastwards, sharing all initial sites to the west. At the first differing eastern site m≥q the common west, including any initially equal resampled sites before m, is still independently fair conditional on m and the eastern pair. For the observations at 0,1 to differ by time T, a west advance of at least q−1 is required. The displayed tail bound makes the probability exponentially small as T grows. By the light cone, the two observed T-tick words form independent replicas conditional on the T+q shared initial sites from −T through q−1. For each such prefix the error of its most likely word is at most the chance the replicas disagree (the sum of squared word probabilities is at most their maximum). Fano's elementary finite-alphabet bound gives conditional entropy at most 1+2T times that error, meaning 1 + (2T · error). Unconditionally, the pair entropy is therefore at most T+q+1+o(T). Divide by T and then send ε to zero. The direct finite-Shannon counts give a numerically smaller bound. This argument links the dynamics to the observable and does not infer a positive entropy excess from a measured speed.

Wolfram's printed p.960 explicitly attaches the superscript μ to his upper bound of 1.155 bits for Rule 30, distinguishing the measure entropy from the topological spacetime entropy defined on the same page. Tisseur's Theorem 5.1 and Proposition 5.3 bound entropy from above using other, one-sided perturbation exponents. Baetens and Gravner's Lyapunov profiles use a branching defect process. Neither result converts the measured leftward speed of a simultaneous single difference into an extra Shannon bit rate. The project's earlier GC509–542 work studies fresh pivots, healing, deterministic escape templates and average returns; the historical record here keeps a fresh western pivot even during a retreat. No priority claim is made for the general martingale or finite-state potential method. [Wolfram, *A New Kind of Science*, printed p.960](https://files.wolframcdn.com/pub/www.wolframscience.com/nks/nks-nts-ch6.pdf#page=15) · [Tisseur](https://arxiv.org/pdf/math/0312136) · [Baetens and Gravner](https://arxiv.org/abs/1509.06639) · [Project's prior-art archive](../../../PRIOR-ART-ARCHIVE.md)
