# How much information can arrive from the right in Rule 30?

**K83.B, gptIntel, 24 November 2026.** For the full two-sided map, the topological entropy lies between **1 and 1.146669 bits per tick**, with a strict upper endpoint. For independently fair initial cells, the metric entropy lies between **1 and 1.124883281645 bits per tick**. The one-bit lower bounds come from a single column. A positive excess over one bit remains open in both cases.

| Pull | Outcome |
|---|---|
| B1. Does an eastern flip reach the centre almost surely? | **PROVED by hand.** Almost surely, simultaneously for every nonempty finite flip mask, the leftmost difference either reaches arbitrarily far west or tends to positive infinity. A proof of universal almost-sure hearing still requires ruling out the second possibility for single flips. [Argument and exact finite hearing probabilities](lower.md) |
| B2. Is westward speed positive? | **PROVED by hand with an integer certificate.** The historical westward record advances almost surely at a limsup of at most 1,142,503/4,194,304 cells per tick (0.272394 rounded upward). A positive lower bound remains open. [Fresh-bit filtration, finite-time tail and verifier](lower.md) |
| B3. Is the entropy strictly above one bit? | **OPEN.** All one- and two-step pair languages satisfying the eastern extension criterion below have zero entropy. Longer-memory or hidden-state constructions remain available. Exact counts give the fair upper bound and provide no positive limiting excess. [Pair census and measure calculation](count-pairs.md) |
| B4. Can we beat the kit’s log 3 upper bound? | **YES.** Lean identifies full topological entropy with the exponential growth of adjacent-column words and proves a strict improvement. The strongest strip certificate gives an upper bound of log₂(221402011/100000000). [Lean proof](lean-entropy.md) |

The distinction between the two entropies matters in this problem. The kit proves bounds of log 2 and log 3 for topological entropy and discusses finite pair counts. Wolfram's printed p.960 assigns his below-1.155 figure to measure entropy (the superscript μ). Our two upper bounds apply to different quantities. The original K83 observations measured collision entropy beside three imposed walls. Their slopes over the sampled lengths do not bound the limiting excess from below. [Kit Mixing module](https://github.com/WolframInstitute/Rule30PrizeKit/blob/4bb3a7b/equivalents/Rule30Equivalents/Mixing.lean) · [Wolfram, printed p.960](https://files.wolframcdn.com/pub/www.wolframscience.com/nks/nks-nts-ch6.pdf#page=15)

## The upper certificate counts paths backwards through physical strips

An older quantitative reference is Grassberger’s 1986 Table 6. It prints the vertical measure bound as <1.15436 and estimates the leftward front speed at 0.2428 ± 0.0002. Our exact pair increment at length 14 is in [1.154363780530, 1.154363780531], reproducing the printed five-decimal value on rounding. The increment at length 21 improves it. The table also gives a directional minimum, which measures a different observation. [Grassberger, Table 6](https://content.wolfram.com/sw-publications/2020/07/cellular-automaton-properties.pdf)

Let N(n) count the different length-n joint words at sites 0 and 1 over all initial rows. A pair of columns traced for n+O(k) ticks determines every site in the k-cell window to its west for n ticks. Solve for the western input using each pair of successive times. The finite extra observations do not affect the exponential rate. Conversely the pair observation itself distinguishes all N(n) words. Splitting a word gives N(n+m) ≤ N(n)N(m), so the limit of log N(n)/n exists and equals the full topological entropy. Spatial translation allows the observed pair to move with the window. [Formal statement and replay](lean-entropy.md)

A state is a set S of possible words at sites 1,…,w. Start at a terminal time with every word allowed. For each earlier physical row x and each observed pair (b,g) at its sites 0,1, compute the next row by Rule 30. Whenever its first w positive sites belong to S, the edge bearing (b,g) must exist and its destination must contain the appropriate prefix of x. At the width limit the checker tries both values of the cell just beyond the strip. A destination may forget eastern sites by projecting onto a shorter prefix. This only adds possible paths. Repeating the argument backwards shows that **every physical pair word** labels a path from the terminal state. The algorithm is deterministic in the observed letter. Two distinct letters going to the same destination count twice.

Give every state a positive integer weight V. If the sum of the outgoing destination weights is at most qV at each state, then the number of length-n labeled paths from the terminal state is at most qⁿV(start)/min V. The builder uses floating point to suggest weights. The standalone checker re-evaluates every cell of the local rule, every required destination membership and every weight inequality with integer arithmetic. The proof of path inclusion allows any sound forgetting policy. The limit on distinct masks at a given width controls the precision of the bound.

| Maximum width | Distinct states | Upper multiplier (denominator 100,000,000) |
|---:|---:|---:|
| 2 | 6 | 252137971 |
| 4 | 28 | 239201729 |
| 6 | 692 | 230792199 |
| 8 | 48,464 | 225549196 |
| 10 | 211,192 | 222673371 |
| 11 | 275,904 | 222116998 |
| 12 | 120,674 after merging equivalent labeled futures | 222520124 |
| 12 | 952,529 | 221451979 |
| **13** | **1,139,394** | **221402011** |

The small width-12 certificate already gives less than 1.155 bits. The width-13 bound is 1.146668326214… bits. The displayed six-place strict upper endpoint can be checked by the integer comparison 221402011¹⁰⁰⁰⁰⁰⁰ < 2¹¹⁴⁶⁶⁶⁹·100000000¹⁰⁰⁰⁰⁰⁰. An independent implementation also checked all 1,139,394 weight sums and all destination widths, and enumerated the literal physical transitions through width seven. Removing a required edge from the six-state certificate and lowering its multiplier to one both make the standalone checker reject it, for the respective physical and arithmetic reasons. [Builder](strip-cover.cpp) · [Standalone checker](strip-check.cpp) · [Optional state merging](strip-merge.py)

For the **exact**, unrounded fixed-width strips, the upper entropies decrease to the physical entropy. Projection gives nesting. At each length n the initial eastern light cone fits once W≥n, so a strip word of that length has a physical realization by extending the initial east and solving for the west. Subdivision into disjoint length-n blocks bounds the strip entropy by log N(n)/n at those widths. Take the infimum over n. This gives no convergence rate for the projected certificates above. A separate outer hierarchy made from overlaps of physically realized temporal words yields 1.202988706922 bits at overlap 14. [Temporal overlap construction and checks](count-overlap.md)

## Why a short-memory construction cannot give the lower bound

Suppose a temporal language X of pairs (a,b) can supply its next eastern column for **every** bi-infinite word in X. In detail, there must be a column c with (b,c) in X and b(t+1) = a(t) xor (b(t) or c(t)) at every t. Iterate this property east and reconstruct the cells westward from two adjacent columns. This produces a physical spacetime containing the starting word. Such an X with growth greater than two would prove B3.

For a language specified by allowed transitions between successive pair symbols, the physical rule permits 12 transitions. Exhausting all 4,096 subsets and trimming states which cannot occur on a bi-infinite path leaves 1,657 distinct nonempty graphs. Exactly three pass. Their pair words are constant, with permitted letters respectively {00}, {01,10} and {00,01,10}. The rejected graphs have a shortest unliftable word of length two (1,198 graphs), three (436) or four (20). [One-step exhaustive search](east-lift.py)

For a language specified by allowed **three-letter words**, begin with all 32 physical triples. At any live graph, find a word which has no eastern lift, following the four possibilities for the last two hidden bits. Any subgraph satisfying the extension property must remove a triple on this witness. If the witness consists of two letters, their vertex must disappear. Branch on all these necessary exclusions, remove vertices without bi-infinite paths, and reuse identical graphs. A graph whose strongly connected components have no internal branching has at most polynomial path growth, as do all its subgraphs. The complete certificate has **1,492** distinct nodes, of which **1,354** exhibit an unliftable word and **138** close by this growth test. An independent checker reconstructs the physical triple set, refutes each witness in reverse time, and verifies that every required child is present. The one-bit cutoff gives a smaller 195-node control. This proves zero entropy for **every east-extending pair language of memory at most two**. It places no such restriction on the pair language of the full physical rule. [Search](east-lift-two.py) · [Independent proof checker](east-check.py)

The next lower-bound test should permit hidden states in the temporal language, or seek a uniform positive amount of fair conditional uncertainty after the entire past has been revealed. Merely running the finite Shannon sequence longer can tighten the upper bound.

## Replication and registered predictions

Compile the two spatial C++ programs with GCC or Clang supporting 128-bit integer multiplication. The smaller merged certificate and both proof DAGs are in the same 3.25 MB packet. The width-13 certificate is stored separately in Zstandard format.

```sh
g++ -O3 -std=c++17 strip-check.cpp -o strip-check
g++ -O3 -std=c++17 strip-cover.cpp -o strip-cover
./strip-check small12-25000-merged.bin
zstd -d cover-13.bin.zst -o cover-13.bin
./strip-check cover-13.bin
./strip-cover 13 180000 regenerated.bin
./strip-check regenerated.bin
python east-check.py east-two.json east-two-cycles.json
```

The registry is I231 and its four addenda, and I232 and its two addenda. The width-eight test beat 1.40 bits, width 13 beat 1.15, and the compact width-12 graph beat 1.155. The Shannon excess at 18 ticks was 0.13493036 bits and the eventual fair upper bound fell below 1.155. The alternating-wall phase and under-160 maximum at 18 checked. Both defect-speed refinements beat the registered thresholds. The one- and two-step lower constructions failed even to produce positive entropy. The temporal-overlap forecast **failed** at order 12 (1.218164067207 bits) and still missed 1.20 at order 14. None of these tests resolves the one-bit lower endpoint. S19’s separate M177 checks are recorded in I233.

All these files were read back from `share-scratch/gptIntel/K83B/`. The raw width-13 binary is 392,313,098 bytes, SHA-256 `79459ecd253ccbe9079d87d748f48b9d7f88f022053e40c5b4fae3c8b13b1939`.

| File | SHA-256 |
|---|---|
| `cover-13.bin.zst` | `6057634106bee8d78abd4eafe93f874fbbd9b35e09215bb158be75b7c7a32bbe` |
| `outer-inner-checks.zip` | `0a3c56f360c30153735f436557e151ce43e74ede629a354a37dbd0faec023b08` |
| `pair-counts.zip` | `2feec0b0d7bc82dd0c9f0a13f2ff0a615de1edcab880d148633ddfa2aa8050f1` |
| `temporal-overlap.zip` | `00c4556c61a10723be90d787d2f0958a050ad39767c7ac34afdb01ab4e695855` |
| `defect.zip` | `8cd7e58ea02e60e1c2c91c902e9b87e3c18342ebf6abbc3ef3eec3039a8f1991` |
| `lean-entropy.zip` | `9f43f2973719ba0b872020001da155fd026a9a7a3506138fda74f2ac403f7734` |
