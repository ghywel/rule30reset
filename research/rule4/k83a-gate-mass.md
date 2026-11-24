# How likely is an immediately alternating centre?

Fix the entire left half, including a black centre, and choose the positive sites by independent fair coins. The probability that the centre alternates forever from time zero is **at most 4,335/65,536 (6.6147%)**. With a white centre the bound is **21,459/524,288 (4.0930%)**. Both bounds hold for every fixed left half, including each finite-left state in K83.A.

To obtain the bound, first drive the two sides with the proposed alternating centre and write `l(t)` for the driven cell immediately to its left. At each white time the actual update can agree with the proposed next centre only if the gate immediately to its right equals `1 XOR l(t)`. The prescribed left half fixes all these required readings. The black times impose additional consistency conditions on the left. Thus the probability of immediate alternation is bounded by the probability of one specified length-15 gate word under the alternating drive. Maximizing over *all* gate words produces the common bound. It does not require that a particular fixed left half realizes the maximizing word. [Kit coupling theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ebda8cefa92d2ba2ec4d67fc14f69fa31908c0cc/lean/Ruliology/CellularAutomata/Rule30Coupled.lean)

The most likely fifteen readings are **`001000010000100`** for either initial colour. The full counts are 71,024,640 out of 2³⁰ initial right prefixes for black first and 21,974,016 out of 2²⁹ for white first. The first white sample is physical tick 1 in the first case and tick 0 in the second. These computations use fresh fair right halves at the onset. At a later onset the preceding dynamics can change their distribution. [Finite-transient law](right-coin-past.md)

| White readings | Number of words, black first | Maximum probability, black first | Number of words, white first | Maximum probability, white first |
|---:|---:|---:|---:|---:|
| 1 | 2 | 3/4 | 2 | 1/2 |
| 2 | 3 | 9/16 | 3 | 1/2 |
| 3 | 5 | 19/64 | 5 | 13/32 |
| 4 | 8 | 17/64 | 8 | 5/16 |
| 5 | 12 | 55/256 | 12 | 7/32 |
| 6 | 17 | 165/1024 | 17 | 7/32 |
| 7 | 25 | 121/1024 | 25 | 1,059/8,192 |
| 8 | 36 | 121/1024 | 36 | 217/2,048 |
| 9 | 49 | 121/1024 | 50 | 5/64 |
| 10 | 65 | 1,643/16,384 | 68 | 311/4,096 |
| 11 | 88 | 19,387/262,144 | 91 | 517/8,192 |
| 12 | 115 | 18,747/262,144 | 119 | 517/8,192 |
| 13 | 148 | 18,747/262,144 | 156 | 517/8,192 |
| 14 | 188 | 18,747/262,144 | 199 | 23,495/524,288 |
| 15 | 237 | 4,335/65,536 | 251 | 21,459/524,288 |

Every supported word avoids `11`. If the gate is black at a white tick, its next physical value is black, which forces it white at the next white tick. All words satisfying this restriction occur through length four. At length five the first additional missing word is `00000` in both initial phases.

## Exact counting and replay

The last gate reading is at tick 2H−1 for a black first wall and 2H−2 for a white first wall. Its light cone reaches initial positive site 2H or 2H−1, respectively. For a fixed initial prefix, assign every farther site the two possible values. Propagate sets of values using the Rule 30 truth table. A gate with a singleton value is certified simultaneously for all completions. If every reading is certified, add the size of this entire cylinder to its word. Otherwise split on the next unknown input bit and repeat. Reaching the full cone always determines the word. This counts each completion exactly once.

The shorter tables are marginals of the fifteen-reading table. Dropping the last reading erases two initial cone bits, so the sum of the two descendant counts is four times the parent count on its shorter cone. The checker verifies this exact divisibility at every node. It also regenerates every word count through nine readings with a separate Boolean site-by-site simulation and checks the total and the `11` exclusion at all lengths. [Reproduction source](k83a-gate-mass.cpp)

```sh
g++ -O3 -std=c++17 -fopenmp research/rule4/k83a-gate-mass.cpp -o gate-mass
./gate-mass 15 > gate-counts.tsv
```

The table has one row per nonzero count, with the wall's first colour, number of readings, chronological gate word, count and fair-prefix denominator. A missing word has zero count. A separate bit-plane simulation subsequently exhausted both whole cones at H=15, evolving 64 different physical right rows per machine word. It matched all 488 positive histogram bins and every zero bin. Its source and full output are in the replay packet.

## Why the finite bounds are sharp

Fix the centre from physical times 0 through T. Write its bits as C₀(t), and let γ(t) be the prescribed gate at its white times. Solving the Rule 30 update for the western input gives the successive columns to the left:

```text
C₁(t)     = C₀(t+1) XOR (C₀(t) OR γ(t))
Cⱼ₊₁(t)   = Cⱼ(t+1) XOR (Cⱼ(t) OR Cⱼ₋₁(t)),  j ≥ 1.
```

At a black tick the first line is independent of γ(t). The finite left prefix is Dⱼ = Cⱼ(0), for j=1,…,T. Replaying the triangle verifies that these cells and any right row with that driven gate word produce the requested centre through tick T. A first difference in the required C₁ at time t changes Dₜ₊₁: its coefficient is one, and every other term depends on earlier times. Thus each realized white word selects a different left prefix. The kit proves this sideways construction and its exact first failure for black-first alternation. Counting the preimages gives the finite probability here. [Kit realization](../../Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Realization.lean) · [Psi, uniqueness and exact death](../../Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30PeriodTwoSideways.lean)

In particular the two maxima above are **attained for the finite interval**. The black-first count is for alternation through tick 30 inclusive, the white-first count through tick 29 inclusive. Each maximizing left prefix can be padded with infinitely many white sites. Encode the initial west bits with site −1 low, and positive sites with site +1 low.

| Initial centre | T | Left prefix attaining maximum | One matching right | Least possible west depth | Left attaining minimum | One matching right |
|---|---:|---:|---:|---:|---:|---:|
| Black | 30 | 891675573 | 157765414 | 19 | 385973 | 390000698 |
| White | 29 | 100472357 | 107476394 | 20 | 857637 | 488559490 |

The last two pairs both produce gate word `001000010010010`. The minima were computed over all 237 or 251 realized words and attained by physical full-row replay. Thus for the stated interval even a specially chosen infinite east cannot help if the available west depth is at most 18 (black) or 19 (white).

## Keeping the finite-left condition in the infinite problem

For B fixed, let E(B,T) consist of right halves for which *some* west supported on sites −1 through −B achieves the target through tick T. This event holds exactly when Dⱼ=0 for B<j≤T. The right words belonging to different gate words are disjoint, so their counts can be added even when the eligible left depends on the right. The resulting survival probabilities decrease in T. At the longest measured interval the counts are:

| B | Black first, denominator 2³⁰ | White first, denominator 2²⁹ |
|---:|---:|---:|
| 8 | 0 | 0 |
| 16 | 0 | 0 |
| 19 | 26,151,424 | 0 |
| 20 | 26,151,424 | 11,467,776 |
| 24 | 51,544,960 | 32,839,380 |

The probability that **any finite left** can sustain the prescribed infinite wall is exactly lim as B→∞ of lim as T→∞ of P(E(B,T)). The order matters. If B is allowed to grow first, every finite word has a finite realizing left. This formulation works for any prescribed wall, using its white ticks; applying it to countably many eventually periodic targets includes arbitrary onsets. For period two, nullity for both pure phases also transfers across any fixed transient by the proved right-half measure bound. With a white centre, our finite table allows the all-white west. If the initial left is required to contain black, require a nonzero decoded west within B; this choice leaves the displayed fifteen-reading values unchanged.

A proof that P(E(B,T)) tends to zero for **each fixed B** would settle the corresponding almost-sure question. A deterministic cutoff at every B would prove the stronger all-rights assertion. The two different modes of failure at S12’s fork and the positive periodic atoms explain why maximizing over unbounded left widths at every T gives a less informative limit. [Bounded-support counter with coupled replay](k83a_left_support.py) · [K83’s forward and backward quantifiers](right-coin-past.md)

The shared-store packet `share-scratch/gptIntel/K83A/escape.zip` includes the complete `gate-counts.tsv` and `left-support.txt`. Run `python research/rule4/k83a_left_support.py gate-counts.tsv` after extraction. The script checks every west and east assignment through seven physical updates against independent whole-row evolution and verifies finite-word injectivity on every histogram used here.
