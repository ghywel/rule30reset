# Three or more inverse ticks beside a prescribed wall

Let the wall be at site 0 and follow any Boolean sequence. Start with the leftmost black cell at `−m`, where `m ≥ 1`. At age `t` the left edge is `f = −m−t`. At each inverse layer require the Rule 30 equation at every negative site. The predecessor can choose the bit at site 0 freely.

## Three ticks

The least uniform age is **31 if `m ≥ 2` and 32 if `m = 1`**. From that age, every third predecessor has its leftmost black cell at `f+3`. Both lower examples use the prescribed wall bits at all three predecessor times, so fixing those bits gives the same least ages. [Lean extension](three-step-extension.lean)

The upper proof begins at S23's good eight-cell band and uses its verified six-tick step to width 13. Restart the proof 23 ticks before the requested observation. At each further stage the old prefix is in the preceding list and the unconstrained part of the new band ranges over all its bits. The check clamps the starting depth at the new width. At smaller depths these unconstrained bits include the wall values that enter the band during the stage.

| Age for the nonadjacent class | Width | Retained words | Cases in the transition |
|---:|---:|---:|---:|
| 14 | 13 | 4 | 256 |
| 18 | 20 | 43 | 2,560 |
| 23 | 22 | 20 | 516 |
| 27 | 26 | 31 | 640 |
| 31 | 29 | 29 | 248 |

In the final band, start with two adjacent bits of each predecessor, at `f+27` and `f+28`. Reading the image bit at `p` determines all three bits at `p−1`, by left permutivity. The next layer reads the current bit of the previous one. All 64 possible starting states give a black third-layer bit at `f+3` and whites at `f+2,f+1,f`. At `f−1` all six state bits are zero. The rest of the image is white and the zero state is fixed, which proves the entire west-tail statement.

For the lower bounds, use two adjacent blacks at depth two with wall tape `0x192fd993`, or the single black at depth one with the tape shifted one tick later (`0x325fb326`). Wall tape bit 0 is the first tick. Both produce the same image at depth 32, respectively at ages 30 and 31. The predecessors have wall bits 0, 1, 1 from the image backwards. Their last row is black at every site `p ≤ −32`. The proof checks the finite rows, the joins onto the constant tails and all three wall equations. The independent program also constructs both images with the literal cell rule. [Reconstruction and witness replay](replay_three_step_wall.py)

## Four ticks

**Computed upper bounds of 76 for `m ≥ 2` and 77 for `m = 1`.** Starting from the age-31 cover, append either bit at the eastern end before each forward update. A width-`w` edge band thereby gives the width-`w+1` cover at the next age. All cells of each grown band fit left of the wall, since the wall's distance from the edge grows by one per tick. At age 76 the width-74 cover has 5,539 words. Each of their 256 four-layer states gives the exact edge `f+4` and then the all-white state. The same restart argument applies at every later age. [Cover replay](replay_three_step_wall.py)

At age 75, four of the 4,967 words still allow a failing register. In edge-first, least-significant-bit order they are `0x1bf6c706606c34737b`, `0xdbf6c706606c34737b`, `0x11bf6c706606c34737b` and `0x19bf6c706606c34737b`. These are candidates for a physical witness. They come from a cover with free eastern bits and arbitrary incoming inverse registers. The age-75 result therefore gives no lower bound. S1 proves age 80 beside the fixed white wall. R25 in the ledger computes a smaller white-wall upper bound of 72. The new bound covers any prescribed wall. [S1 proof](../r2/age80/Rule30AgeEightyInverse.lean) · [R25's seed-anchored covers](../m29/seed-anchored-covers.md)

## Any fixed number of layers

**Proof sketch.** At width `w`, after `max(w−m,0)` ticks the whole band lies at negative sites and evolves autonomously under the kit's band map. After another `2^w` ticks it is on a cycle. Read each inverse layer in depth from the wall, including its own bit at depth zero. The inverse equation at positive depth gives Lowry's `Drives` relation, independently of the value at depth zero. The band and its white exterior give the initial `Matches` hypothesis at edge depth `m+t`. The existing cascade then gives the required edge when `k ≤ K1(w)`. In particular a sufficient uniform age is `max(k, w−1+2^w)` under that capacity hypothesis. K63 already identified the wall independence. This uses the same open `CAP` premise for unbounded `k`. [K63 and the earlier inverse review](review.md) · [Lowry's cascade](https://github.com/WolframInstitute/Rule30PrizeKit/pull/60)

## Disposition

Keep K50.3 open. The sharp three-tick result is ready for a carrying read. For four ticks, formalize the finite successor check and test whether the four surviving age-75 words occur with physically attainable inverse boundary bits.

Run `python build_three_step_wall.py OUTFILE` to append the new proof to the exact S23 source. Add `--portal` for the verifier pin. The extension reuses S23's private stage checker inside the generated module. [Builder](build_three_step_wall.py)

The stock checker replayed four new headlines on both targets. Kit main `bd5ec59` replayed 447 constants and the verifier pin `5fb5915` replayed 952, with zero new axioms. The scalar C++ check of the four-tick cover passed all 1,417,984 inverse sweeps.
