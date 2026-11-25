# K84 continuation on finite support and the alternating gate

The minimum west support for alternation through tick `T` can be computed from gate words on the right. This gives a smaller certificate for the original depth-80 cutoff and extends the finite profile. The gate census reaches **17,324 physical words at 43 readings**. A separate finite cover gives a uniform asymptotic upper bound of **0.151 bits per white reading** for the gate.

## The support test

Let `Psi R` be the kit's unique west that makes the centre alternate forever beside the driven right half `R`. Three Lean theorems make the finite reduction explicit.

1. Alternation at every tick from 0 through `T` is equivalent to agreement with `Psi R` at depths 1 through `T`.
2. A west of support at most `B` works through `T` exactly when every `Psi R` bit at depths `B+1,…,T` is white.
3. Two driven right halves have the same gate word at odd ticks strictly below `T` exactly when they require the same length-`T` west prefix. The `m`-reading gate words therefore count the successful west prefixes through both `2m` and `2m+1`. A successful prefix gives an actual west by padding with white.

The stock checker on kit main `e2c9d8e` passed all three headlines and replayed 11 constants with zero new axioms. Standalone `leanchecker` passed. The sideways inverse and the exact death at the first disagreement belong to the kit. K83.A gave the support condition in prose and used it for its fifteen-reading census. [Lean](K84FiniteSupport.lean) · [K83.A](../k83a-gate-mass.md#keeping-the-finite-left-condition-in-the-infinite-problem) · [Kit exact-death proof](https://github.com/WolframInstitute/Rule30PrizeKit/blob/e2c9d8e/lean/Ruliology/CellularAutomata/Rule30PeriodTwoSideways.lean)

## Finite lifetimes

The minimum-support scan is exact for every tick from 90 through 120. Inverting it gives exact `L(B)` through depth 106. Depth 107 already has a witness through tick 120. The original depth-80 result is a control.

| B | 80 | 82 | 84 | 86 | 88 | 90 | 92 | 94 | 96 | 98 | 100 | 102 | 104 | 106 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| L(B) | 92 | 92 | 95 | 102 | 102 | 102 | 107 | 109 | 109 | 111 | 115 | 116 | 116 | 119 |
| Excess | 12 | 10 | 11 | **16** | 14 | 12 | 15 | 15 | 13 | 13 | 15 | 14 | 12 | 13 |

The new even depths give excesses from 10 to 16. The older maximum was 14 at depth 66. At depth 86, four 51-reading strip words decode to a west shallow enough for tick 102, and exactly one replays on a physical right half. The least-squares slope of the excess over the combined even depths 26–106 is 0.086. Its value over the new depths 82–106 is 0.049. The finite range supports no stable fit.

For an upper bound, enumerate the gate words allowed by the first `W` right cells. Start from a genuine black predecessor, then give the strip any two exterior cells at the beginning of each two-tick step. A physical right history always projects to a strip path. Decode each candidate's west with the sideways inverse. If no word decodes to support at most `B`, the strip already refuses `(B,T)`. Otherwise one selector per remaining word asks whether the physical cone of the right half can read any of them. For a lower bound, pad the selected west and east with white and replay the entire line. Bit zero in each hex mask is the site next to the centre. [Strip enumeration](gptIntel_k84_strip.cpp) · [Physical search and replay](gptIntel_k84_words.py) · [Minimum supports and witnesses](data/gptIntel-k84-support.jsonl)

Both checkers accepted the direct coupled refusal at `(80,93)`. Its LRAT is 637,357,865 bytes. The width-18 cover kept two candidates for the same cutoff and both checkers accepted its 177,445-byte proof. The small LRAT asserts that the right cone cannot read either candidate. Completeness of the candidate list follows from the strip and the sideways decoder. Both checkers also accepted the reduced refusals at `(82,93)`, `(84,96)`, `(90,103)`, `(91,103)`, `(105,117)` and `(106,120)`. As a control, K83.A's scalar decoder matched 8,190 short words and the complete even-tick prefixes of all candidates in the initial cutoff cases. [CNF generator](gptIntel_k84_certificates.py)

## Exact gate counts and an asymptotic upper bound

For each length, merge replayed physical samples with the results of exact right-cone SAT on every remaining strip word. A refusal at one length rules out its extensions. The original count of 237 at 15 was independently recovered. At 35, the width-18 strip gave 8,138 candidates and the initial right-row sample gave 6,649 words. Physical queries found 201 more. At 43, the corresponding numbers were 24,944 and 15,788, with 1,536 more found by the cone queries. Both LRAT checkers accepted one combined refusal covering all 2,948 newly absent prefixes through length 40. Counts 41–43 use exact cone solves with positive replays. [Counts](data/gptIntel-k84-gate-counts.tsv)

An asymptotic bound needs a factor cover that works at every late starting time. The width-22 strip has 84,121 possible windows after 35 white-to-white updates from the first white sample. At every later sample a physical window is still among these possibilities. The same strip calculation can start at the black tick preceding the last 36 white samples of that history. Its 27,847 possible words of length 56 therefore cover every 56-reading factor from sample 35 onward.

Use the first 55 readings of a covered word as a vertex and its last 55 as the destination. This makes a graph with 24,898 vertices and 27,847 edges. The physical sequences after 35 give paths in this graph. An integer recurrence, starting with 1 at every vertex, counts the paths of length `k` starting at each vertex. The largest entry at `k=614` is `6684746140070677363946439002`, and it satisfies `max × 100^614 ≤ 111^614`. Concatenate blocks of 614 steps to obtain

```text
limsup (log2 G_m) / m ≤ log2(111/100) < 0.151 bits per white reading.
```

The finite initial segment, initial vertex and final incomplete block each contribute a constant factor. The sequence `G_m` is submultiplicative because a suffix of a black-first gate word starts at another black tick. Thus the limsup is a limit. The overlap graph allows some paths whose full right histories may be incompatible. The older K47 ladder reaches a tighter rate for the 829-window trap once entered. Its gap-3-or-5 restriction excludes the known gap-2 ether. [Integer path count](gptIntel_k84_rate.py) · [Prior-art comparison](../../../PRIOR-ART.md#p77--2026-11-25--coupled-lifetime-and-the-unrestricted-driven-gate)

## What remains

The size of the gate language and the length of a white section in `Psi R` are different observables. A language with one freely chosen bit at each even depth could put black at every odd depth. A rate bound or a positive floor from M181 needs a separate constraint linking gate words to the decoded white sections before it can inform the support-delay law. The new finite profile excludes a universal additive constant below 16 and leaves bounded excess versus slow growth open.

## Replay

Run these commands from this directory. The Python that runs SAT needs python-sat.

```sh
g++ -O3 -std=c++17 gptIntel_k84_strip.cpp -o strip
./strip strip 18 53 > strip18-53.txt
./strip sample 16777216 53 > sample-53.tsv
python gptIntel_k84_words.py counts strip18-53.txt sample-53.tsv 53 15 43 > counts18.jsonl
python gptIntel_k84_certificates.py right-b80-t93.cnf support strip18-53.txt 53 80 93
cadical --quiet --lrat --no-binary right-b80-t93.cnf right-b80-t93.lrat
lrat-check right-b80-t93.cnf right-b80-t93.lrat
cake_lpr right-b80-t93.cnf right-b80-t93.lrat
./strip strip 22 56 35 > warm22-56.txt
python gptIntel_k84_rate.py warm22-56.txt 56 55 111/100 614
./strip strip 22 56 > strip22-56.txt
./strip sample 33554432 56 > sample-56.tsv
python gptIntel_k84_words.py support strip22-56.txt sample-56.tsv 56 90 112
./strip strip 22 60 > strip22-60.txt
./strip sample 33554432 60 > sample-60.tsv
python gptIntel_k84_words.py support strip22-60.txt sample-60.tsv 60 113 120
```

The other right-only cutoffs use the width-18 strip file for depths 82 and 84, and the width-22 strip files at 56 readings for depths 90 and 91 and at 60 readings for 105 and 106. To regenerate the original coupled CNF, use `python gptIntel_k84_support.py cnf 80 93 b80-t93.cnf`. To regenerate the combined word refusal through 40, use `python gptIntel_k84_certificates.py counts18-through40.cnf counts counts18.jsonl 40`.

The read-back-verified packet `share-scratch/gptIntel/K84/k84-I246.zip` is 8,666,041 bytes, SHA-256 `c5070efac47754b2a3e1dc00ee866aba84a0f9ebe11d1610a84d5e6571f5def0`. It contains all seven reduced LRATs, the candidate lists, the census and overlap inputs, and both Lean receipts. Regenerate the two large LRATs from their bundled CNFs and compare against their recorded digests and checker receipts.
