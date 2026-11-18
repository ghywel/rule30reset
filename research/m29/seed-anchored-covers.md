# The sharp three-tick threshold is 31

**M31 carrying verdict: PASS.** **R23 result: exact finite certificate with a hand deduction, pending independent carrying read.** Write f(k) for the first age from which every nonzero finite seed has all k-tick predecessors finite at the fixed white wall. Every such predecessor has its outermost black cell k cells inside the output edge, since the forward map extends any nonzero finite row by exactly one cell each tick.

## The carrying step

At a cut store two adjacent predecessor bits (previous, current) for each inverse layer. For input bit b the next pair is (current, b XOR (previous OR current)); the next layer's input is the old current bit. Thus the first three layers evolve with no dependence on the fourth. A three-layer incoming register has 64 possibilities. Every physical three-tick history supplies one such register at the inner end of the band. If they all reach zero after its last cell, subsequent exterior zeros keep all three layers zero. This proves finiteness. Conversely the two free pairs in a layer scan are an allowable overestimate of physical entrance states. M31 counts them independently of the fourth layer, as required.

Using the S1 packed-register convention, an independent calculation gave exactly M31's failing three-layer pair counts at ages 26 through 34: 85, 116, 144, 124, 160, 116, 56, 32, 0. At age 34 all 17 words reset all 64 registers. The kit's all-seed age-26 base, the moving-cover induction and age monotonicity give the claimed upper bound of 34 for every seed. Direct forward validation of candidate finite parents also reproduced one M30 failure at each depth 1 through 6. At three ticks, seed 617 at age 30 fails on wall-head history 000, read newest first. At four ticks seed 7815 at age 58 fails on 1000. [Review and exact control](gptM5_three_tick.py)

## Starting the band at the seed

For seeds at least eight bits wide, take all 128 possible top eight bits at age zero. In these edge-aligned coordinates a word p of fixed width evolves autonomously by

    R(p) = (p >> 2) XOR ((p >> 1) OR p).

Indeed the row map is F(y) = (y >> 1) XOR (y OR (y << 1)); shifting the output back to the advancing edge gives the formula. Apply R twice at fixed width. From age 2 onward grow the width by one per tick. If a row has current prefix p, its next prefix of the larger width is R(2p+b) for the actual next interior bit b. Retaining both choices includes every physical row, even when some choices cannot coexist along a trajectory. At age 31 this gives 653 words of width 37. All 41,792 word/register pairs reset. The other 127 nonzero seeds (width below eight) pass an exact finite-parent test on all eight wall histories at age 31.

For the finite-parent test, prescribe the wall-adjacent head and reconstruct the remaining bits outwards by the same recurrence with the wall bit fixed to zero. A finite parent of a nonzero output of width n must have width n−1. Truncate there and apply F to check equality and the prescribed head. This is exhaustive because the recurrence fixes the whole parent from its head. With a failed finite candidate the unique backward Boolean row continues infinitely. Every prescribed sequence of heads can be reconstructed layer by layer, also on infinite rows.

Finally F maps nonzero finite seeds to nonzero finite seeds. Every later row is consequently also an age-31 row of another seed. The age-30 failure gives f(3) ≥ 31, and the age-31 certificate gives f(3) ≤ 31. The width-one base by itself first passed at 32. Moving from the age-26 four-word base to an earlier base with a different retained width changes which free interior bits have already been constrained. It lowers the sufficient age.

[R22 output](gptM5_three_tick.py) in the store at `share-scratch/gptM5/M29/three-tick-r22-v1.jsonl`, SHA-256 `c030bdfc39bc3b059a827af8b92a84b57fdbb3be44f86d533f75acb16fb519d0`. This is internal evidence for the all-depth question in M29.
