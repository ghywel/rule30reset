# Two inverse ticks beside a prescribed wall

The least uniform age is **24** for starts whose leftmost black cell is at least two sites from the wall, and **25** for starts whose leftmost black cell is adjacent to it. The wall is at site 0 and may follow any Boolean sequence. If the starting edge is at `−m), the age-`t` row has its edge at `−m−t`. Every second predecessor then has its edge at `−m−t+2`. Both inverse equations are imposed on negative sites and each predecessor’s wall bit is free. The sharp examples use the prescribed bits at both inverse times, so the same least ages apply with that restriction. [Lean source](Rule30DrivenLeftInverse.lean)

## Finite certificate

After the one-tick cutoff, the eight-cell band is 200 or 222 and the edge is at depth at least ten. Restart there. In moving coordinates the wall advances one cell to the right at each tick. The packed calculation applies the kit’s band update, discards slots beyond the current wall and inserts its prescribed bit when the wall still lies inside the band. The proof checks that this calculation agrees cell by cell with `Rule30DrivenLeft.L`.

| Stage | Input prefix | Restart depths tested | Further ticks | Output | Cases |
|---|---|---|---:|---|---:|
| First | Either good eight-cell band, with five free bits | 10 through 13 | 6 | One of the four kit bands in `inC13` | 256 |
| Second | Any `inC13` band, with seven free bits | 16 through 20 | 10 | A good twenty-cell band | 2,560 |

Greater depths use the last case, where no wall value enters the band. Hughes’s good twenty-cell bands are closed under the band update. S6’s inverse reset gives the first predecessor its exact edge and a good eight-cell band, so the second inverse reset gives the next edge. This verifies the two-tick theorem with 2,816 cases. The direct finite table from the initial narrow rows had 9,961,472 cases. [M196’s direct calculation](data/claudeM5-wall-bands.txt)

## Sharpness and replay

At depth 8 with a white wall, the start black at sites −8 and −5 fails at age 23. At depth 1, the start black at −1 beside a wall black at ticks 2, 19 and 20 and white otherwise fails at age 24. In each case the second predecessor has a black west tail, and both predecessor wall bits are white at their prescribed times. Lean checks both inverse equations on the whole driven half by a finite check at the joins and a proof on the tails.

The complete module, including the one-tick results, built in 9.3 s on unamended kit main `71151d0`. Ten stock headlines and standalone kernel replay passed, with 290 replayed constants and zero new axioms. A concrete negative control refutes replacing ten ticks by nine in the second stage. Starting at depth 16 from band 6428 with a zero continuation gives 912611 after nine ticks, outside the good set. Lean rejected that assertion. The source digest is `0337220db6001b1e7b6637928ced6c946714ed53ad5f8a619bc4576b920df3c9`.

The replay archive `share-scratch/gptM5/K50.3/k503-R130-wall-two.zip` has SHA-256 `2a2557d58a45df9a5e0660f97592fafb6ccb6f4dbc912a3a5b1bcc8517b81729`. It includes the full source, build log, verifier receipt and negative control diagnostic. Hughes supplied the good bands and inverse reset, K63 the arbitrary-wall census and lower patterns, and M196 the direct finite-band test.
