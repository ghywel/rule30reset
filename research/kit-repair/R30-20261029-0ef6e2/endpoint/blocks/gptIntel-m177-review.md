# Independent read of the two M177 strip claims

**The literal silver example dies at width 40. A nonperiodic endpoint-arc example survives the full width-44 test.** Both computations begin at a white tick, with the gate at site 1 black at reading zero. The width starts at 12 and the strip advances 300 two-tick transitions at each width. At an enlargement every reachable state receives both possible values of the newly observed eastern site.

| Input | Last completed width | Last live reading, zero-based | Live states | First impossible reading |
|---|---:|---:|---:|---:|
| N15 silver, block shift 0 | 39 | 8,653 | 111,599 at width 40 | 8,654 |
| N15 silver, block shift 1 | 39 | 8,635 | 111,599 at width 40 | 8,636 |
| Gap 3 inside an arc of length 1/9, gap 5 outside, angle √2/9, phase zero | 44 | 9,900 | 4,821,917 at width 44 | |
| Silver order, five gaps of 5 after the 3 for an odd symbol, three for even, shift 0 | 44 | 9,900 | 3,640,491 at width 44 | |

### The old example

The Lean headline gives length 23 when the floor of $(q+n)\sqrt2$ is odd and length 18 when it is even. Within each block the black offsets are 0 and those congruent to 3 modulo 5. Our independent generator evaluates that formula literally. Its first 10,001 digits agree at both shifts with the author’s separate concatenation of gaps. At shift zero, 633,793 states remain when the width-39 dwell ends. At width 40, all 111,599 states matching reading 8,653 have no successor matching reading 8,654. The shift-one result displaces the first failure by 18 readings. M177 prints the index it is advancing *from* when the transition fails, which explains its reported values 8,653 and 8,635. [The integer theorem](Rule30RotationBlocks.lean) · [Word generator](gptIntel_m177_words.py)

The shift-zero obstruction applies at every later phase of this example. Its first 423 block symbols already contain the failed prefix. In rotation coordinates the odd/even order is the half-circle coding of angle $\sqrt2/2$. A sufficiently small positive phase displacement preserves those 423 decisions. The first symbol is at the included lower endpoint, and every nonzero-index phase is away from either boundary by irrationality. Every rotation orbit visits that positive-length interval, producing the forbidden factor at a block boundary arbitrarily late. Thus any infinite reading of the silver word at any block shift would contain a finite strip obstruction. This conclusion uses the computed empty set and the elementary recurrence argument. The unequal-block theorem’s Lean proof stands independently.

### The surviving test

For $α=\sqrt2/9$, use the half-open arc $[0,1/9)$ and start at its left endpoint. Membership is equivalent to $\lfloor t\sqrt2\rfloor\bmod 9=0$. Choose the two nonempty reading blocks `100` and `10000`, giving black-to-black gaps 3 and 5. This is an explicit irrational endpoint instance of the real block theorem. The observed numbers of gap steps between successive 3s in the first 2,400 block indices are 6, 7 and 13.

The 42-, 43- and 44-cell dwells ended with 4,651,315, 3,557,948 and 4,821,917 rows. The width-44 test reached all 300 transitions, ending at reading 9,900. The reachable set is stored as 625,166 sorted records, each an eight-byte little-endian low-40-bit prefix and a two-byte nonempty mask of its possible upper four sites. Independent deserialization checked the order, bounds, final gate and complete cardinality. The 6,251,660 snapshot bytes have SHA-256 `e13e41943e660e61be331af175b2130c6aa5cf3aca801fd1de8ad989ae79702b`.

The finite survival qualifies this word for consideration by the author. Its gap sequence also has a complete repeated interval of length 5,332 starting at indices 1 and 1,802. That gives $8n-10j=24,636$ in Lowry’s test. Large individual values leave the question of unbounded excess open. The arc's relationship to existing exclusions deserves a separate check before it is used to distinguish the submission. A surviving strip can still die later or admit spatial histories that do not lift to a full right half.

### A closer replacement to consider

Keep the original parity of $\lfloor t\sqrt2\rfloor$ and the black offsets $y=0$ or $y\bmod 5=3$. Increase the odd block from 23 to **28** readings; the even block remains 18. This is the endpoint half-circle order of angle $\sqrt2/2$ with literal nonempty reading blocks of lengths 28 and 18. It is a direct specialization of the general block theorem. The current `silver_blocks_excluded` headline still specifies 23.

With this sole change and $q=0$, the 42-, 43- and 44-cell dwells ended with 1,000,311, 3,394,227 and **3,640,491** rows. Independent reading of the 456,555 ordered records in the last snapshot gave the same count; its SHA-256 is `823b4b8614cfa671092bf41facc1fe861c0ebc2fe190a82d5a7b1c66d8badc92`. For a separate comparison, scan the first 20,000 gaps at lags below 3,000 for the largest $8n-10j$ and the first 60,000 readings at lags below 9,000 for the largest $n-j$, omitting the unfinished terminal matches. The respective maxima are **−4 and 9** from block 0, **18 and 27** from block 1. These numbers are substantially smaller than for the 1/9 arc in the same finite tests. The scans leave all larger lags open. This variant meets both of M177’s finite selection tests and is the closer replacement for the author to assess. [Finite comparison](gptIntel_m177_repeats.py)

### Independent transfer and reproduction

The native computation groups rows by their western $W-4$ cells. A 16-bit mask retains every possible assignment to the other four. Given the last four fixed cells, those four variable cells and the two fresh spatial east cells, a site-by-site simulation determines every possible assignment to the eastern six output sites after a white-wall update followed by a black-wall update. The lower $W-6$ output sites already follow from the fixed prefix. Union the outputs with the requested next gate; this preserves the exact finite-strip image. The second update’s outside input comes from the first update of the first eastern cell, which is constrained by the two initial east bits. The algorithm applies this physical two-tick cone at every strobe. [Independent grouped strip](gptIntel_m177_strip.cpp)

Controls exhaust all 1,024 ten-cell inputs to the eastern transfer, compare every set of reachable states against independent scalar enumeration at 22 successive samples, check two width enlargements, and retain the actual row of a planted physical spacetime. The wide production runs use no state cap.

```text
g++ -O3 -std=c++17 gptIntel_m177_strip.cpp -o strip
strip --control
python gptIntel_m177_words.py silver 0 10001 > silver0.txt
python gptIntel_m177_words.py silver 1 10001 > silver1.txt
python gptIntel_m177_words.py 9 0 10001 > arc9.txt
strip silver0.txt 40 300
strip silver1.txt 40 300
strip arc9.txt 44 300 arc9-final.bin
python gptIntel_m177_words.py 5,3 0 10001 > silver53.txt
strip silver53.txt 44 300 silver53-final.bin
python gptIntel_m177_repeats.py silver53 0
python gptIntel_m177_repeats.py silver53 1
```
