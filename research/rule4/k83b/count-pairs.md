# Exact words of two neighbouring Rule 30 columns

Write $N(n)$ for the number of different length-$n$ temporal words at sites 0 and 1 together, over all two-sided initial rows. **$N(18)=12,684,636$ and $N(23)=718,268,824$.** The latter count gives $h_{\rm top}\le \log(179,567,206)/22=0.863911823\ldots$ nats per tick. A separate weighted count gives the sharper bound **$1\le h_\mu\le 1.124883281645$ bits per tick** for the stationary fair measure. Whether either entropy is strictly above one bit remains open. [Kit definition of temporal pair words](../../../Rule30PrizeKit/equivalents/Rule30Equivalents/Mixing.lean)

## A finite recurrence that counts the physical language

Write temporal words as integers with bit 0 at time zero. Let $H_n(s)$ be the set of possible words **east** of a prescribed length-$n$ west word $s$. Only its first $n-1$ bits affect those neighbours. An arbitrary prescribed column can be extended against every initial right half by solving for the west, one site at a time. [Kit realization theorem](../../../Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Realization.lean)

To enumerate length $n+1$, choose its eastern word $g$ and write $s=g\bmod 2^n$. For each $h\in H_n(s)$, the first $n$ bits of the column west of $g$ are

```text
west = (g >> 1) XOR (s OR h).
```

This is Rule 30 solved for its western input at each time. Every such $h$ occurs beside $g$ because the final bit of $g$ does not affect its first $n$ eastern readings. The final bit of the west column is free: the next outer west initial bit appears there with coefficient one. Conversely a physical pair necessarily satisfies this formula with its actual eastern neighbour $h$. Deduplicate the possible values of $s\mathbin{\rm OR}h$ before recording the new pair. At length one every letter occurs. This induction is a count of the physical language, including all constraints from the plane.

For the fair law on initial rows attach to each pair an integer $m$, its number of preimages among the $4^n$ full initial-cone assignments. All four one-tick pairs have $m=1$. In the recurrence, **add** the old multiplicities from the $h$'s with the same $s\mathbin{\rm OR}h$. To see why, condition on the freely prescribed trace $g$. The $n$ initial cells immediately east that determine $h$ are independent fair bits given this trace; this follows by the same western triangular bijection on the finite cone. There are exactly $m(s,h)$ such eastern inputs realizing $h$. The additional last bit pair enlarges the denominator by four, and each resulting pair has precisely the sum stated. Every stage checks its total is $4^n$.

## Counts

The two alternating columns in the table are the prescribed **west** words starting with the indicated colour. “Maximum” ranges over all west words. At length 23, the 22 decisive western bits of a maximum are `0100011100000111000010` in time order.

| $n$ | $N(n)$ | Maximum eastern partners | Black-first alternating | White-first alternating |
|---:|---:|---:|---:|---:|
| 1 | 4 | 2 | 2 | 2 |
| 2 | 12 | 3 | 3 | 3 |
| 3 | 32 | 4 | 4 | 4 |
| 4 | 80 | 5 | 5 | 5 |
| 5 | 200 | 7 | 6 | 7 |
| 6 | 496 | 9 | 9 | 8 |
| 7 | 1,208 | 12 | 10 | 10 |
| 8 | 2,916 | 15 | 12 | 12 |
| 9 | 6,964 | 19 | 15 | 15 |
| 10 | 16,476 | 24 | 19 | 18 |
| 11 | 38,616 | 30 | 22 | 22 |
| 12 | 89,844 | 36 | 27 | 26 |
| 13 | 207,544 | 42 | 32 | 32 |
| 14 | 476,596 | 49 | 40 | 36 |
| 15 | 1,089,000 | 56 | 43 | 44 |
| 16 | 2,477,236 | 63 | 52 | 49 |
| 17 | 5,615,036 | 73 | 58 | 59 |
| 18 | 12,684,636 | 88 | 72 | 64 |
| 19 | 28,574,636 | 104 | 78 | 78 |
| 20 | 64,200,720 | 119 | 91 | 86 |
| 21 | 143,901,720 | 136 | 101 | 102 |
| 22 | 321,834,352 | 155 | 122 | 112 |
| 23 | 718,268,824 | 177 | 133 | 133 |

The kit’s reported squares $6^2,7^2,8^2$ at $n=14,16,18$ agree exactly with the white-first column. The other phase has 40, 52 and 72 partners, and neither phase maximizes at these lengths. Beyond the catalogue's all-wall survey through 15, the first excess over a literal $n^2/4$ ceiling is $73>17^2/4$. At 23 the maximum exceeds $23^2/4$ by about 34%. A polynomial growth law for partners and an exponential one remain compatible with these finite data. [Kit catalogue, Mixing](../../../Rule30PrizeKit/equivalents/CATALOG.md)

## A sharper block bound than submultiplicativity alone

Every terminal pair ends the same number of length-$n$ words, $N(n)/4$. Its western bit is free. To toggle its eastern bit while preserving all previous eastern bits, toggle the penultimate western bit in the reconstruction formula. For a one-letter word the same conclusion is immediate.

Hence $a_k=N(k+1)/4$ is submultiplicative: for any fixed suffix, there are at most $a_k$ choices of $k$ preceding letters, by looking at the first letter of that suffix. This maximum is attained at **any** suffix length, even for the complete infinite suffix $(0,1)^\infty$. Every past ending in $(0,1)$ extends into that suffix: prescribe the same western trace through the seam and zero thereafter. A black eastern cell beside a white wall stays black, for any tail. Pair-word growth equals topological entropy as the kit notes; for the upper bound alone, any fixed spatial window of $T$ observations is determined by $T+O(1)$ observations of its right-edge pair via sideways reconstruction. It follows that $h_{\rm top}\le \log(a_k)/k$ for every $k\ge1$. Already $a_2=8<9$ proves a strict improvement on $log 3$. The best single block in this table is $k=22$, with $a_{22}=179,567,206$.

## Fair-measure entropy

If $c_m$ pair words have multiplicity $m$, their joint Shannon entropy in bits is

```text
H_n = 2n − sum_m (c_m m / 4^n) log2(m).
```

The fair stationary process has nonincreasing conditional entropies $H_n-H_{n-1}$. Their limit is the entropy rate of the pair. This is also the full metric entropy: $T$ samples of any finite spatial window are determined by $T+O(1)$ samples of its right-edge pair. Spatial stationarity makes that pair's law the same as at sites 0 and 1, and the finite spatial windows generate the measurable sets. The fair single centre trace supplies the lower bound of one bit. These are forward measurements of joint pair words; the imposed-wall conditional collision diagnostic is a different statistic.

| $n$ | $H_n$, bits | $H_n-H_{n-1}$, bits/tick |
|---:|---:|---:|
| 5 | 7.395146923 | 1.272318259 |
| 10 | 13.486811675 | 1.189035678 |
| 15 | 19.299123476 | 1.148627123 |
| 18 | 22.716419032 | 1.134930360 |
| 20 | 24.975659965 | 1.127975429 |
| 21 | 26.100543247 | 1.124883282 |

At $n=21$, outward-rounded integer arithmetic places the increment in **[1.124883281644, 1.124883281645]**. The exact collision probability at this length is $455443259156435792/16^{21}$. The Shannon increment gives a rigorous upper bound on the *infinite* fair entropy. Its observed excess above one bit gives no corresponding lower bound on the infinite excess.

## Reproduction and controls

Build [the exact counter](count-pairs.cpp) and [the independent physical check](count-wall-control.cpp) with `g++ -std=c++17 -O3`. The counter stores CSR lists of distinct eastern words per western prefix; it streams its last level rather than retaining it. The weighted run also writes a histogram of all integer multiplicities.

```text
count-pairs 23 partner-hist.tsv > pairs23.tsv
count-pairs 21 partner-hist21.tsv masses21.tsv > weighted21.tsv
python count-entropy.py masses21.tsv > entropy21.tsv
count-wall-control 23 1106146 1398101 2796202
```

Through $n=10$ a separate forward simulation exhausts all $4^n$ initial cones and compares every actual pair, including each positive multiplicity on a weighted run. For 14, 16, 18 and 20–23 the independent bit-plane simulator exhausts all $2^n$ initial right halves for a maximizing west word and both alternating phases. The final three counts above are 177, 133 and 133, in that order. The counts of preceding words for suffix lengths 1–4 also check the sharp block formula against the enumerated language. [Outward-rounded Shannon and exact collision checks](count-entropy.py)
