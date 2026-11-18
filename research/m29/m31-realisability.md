# M31 realisability test on one million wide seeds

**Result.** Every one of the 16 four-tick wall histories closed for every sampled seed at every age 59 through 79. The test covered 1,000,000 seeds, 21,000,000 seed–age pairs and 336,000,000 history outcomes. These are exact counts for the sample. M31's prediction of a failure after age 58 missed. The universal question remains **59 ≤ f(4) ≤ 72** on the R25 certificate, with seed 7815 witnessing failure at age 58.

## Where a physical history mattered

For each row the sampler first asked whether its outermost 64 cells reset all 256 possible incoming four-layer registers. When they did, the 16 physical histories all closed. Otherwise it scanned the complete row from each of its 16 wall states. The table counts rows requiring that second calculation, out of one million rows at each age.

| Age | Whole-row checks | Age | Whole-row checks |
|---:|---:|---:|---:|
| 59 | 18,637 | 66 | 73,845 |
| 60 | 18,729 | 67 | 61,752 |
| 61 | 43,838 | 68 | 12,807 |
| 62 | 19,641 | 69 | 31,176 |
| 63 | 26,863 | 70 | 7,503 |
| 64 | 28,229 | 71 | 14,576 |
| 65 | 75,619 | 72–79 | 0 at each age |

Of the 433,215 rows requiring a whole-row check, none realised an incoming state that failed on its outer 64 cells. At age 71 alone there were 14,576 such rows. This gives a concrete target for a follow-up proof or witness search: constrain the incoming register and the outer word to come from the same seed. A longer random census is unnecessary to establish that distinction.

## Execution and review

R26 froze the [sampler](m31_realisability.cpp) and the [independent replay](m31_replay.py) before the run. Each seed width was drawn uniformly from 160 through 200, the high bit was set, and the other bits were drawn uniformly. The same seeds were followed at every age. Each width occurred between 24,107 and 24,622 times. The forward rows fit in five 64-bit words (maximum physical width 279). Exact byte transitions compose the Rule 30 inverse recurrence one bit at a time. A wall state has a zero previous bit and a free head bit in each layer. After the last edge cell, an all-zero register persists. Conversely, any finite four-tick ancestor and its intermediate rows must have retreated edges by the forward edge law, hence zero terminal register.

The original M31 `histories` routine independently rebuilt all 16 histories of 840 prespecified wide seed–age cases and four controls, agreeing on their full failure masks and forward rows. For seed 7815 at age 58 it returned mask `0xaaaa` (eight failed histories). Seed 1 at age 80 had none. The counts by age are correlated because the same seed appears at all 21 ages.

**Reproduction.** Compile with `clang++ -O3 -std=c++17 research/m29/m31_realisability.cpp -o m31-run`. For batch numbers 0 through 39 run `./m31-run <number>` and save standard output as `batch-NN.txt` in one directory, using two decimal digits for NN. Then run `python3 research/m29/m31_replay.py <directory>`. The PRNG is mt19937_64, seeded with `0x4d33315233300000 + batch`.

The shared-store folder is `share-scratch/gptM5/M29/`. The 40 checkpoints plus verified summary are in `m31-million-checkpoints-v1.zip` (SHA-256 `6bac061a2d4c41e679deea4b0689926575e8a94a65dee0f7d1f6712aee3827c1`). The separate summary is `m31-million-verified-v1.json` (SHA-256 `0ff2c20484cfe6ce0c1d7990e5803b80e86e072182ef4068a08e85f74403951e`).
