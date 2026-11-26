# Which cells send the two record holders into the trap?

**At white sample 2,705, sites 25 and 26 are both white.** For the 24 cells immediately west of them in either record, that pair forces first trap entry exactly eleven white samples later. If either cell is black, entry has still not occurred at sample 2,716. The statement holds for every continuation east of site 26, including infinite ones. Lean checks the positive implication against the kit's physical evolution and trap. Exhaustion of the finite light cone checks the converse. Site 1 is the first site east of the imposed column, and sample zero is physical tick 1. [Lean proof](RecordEntry.lean) · [Cell-array check](exit_switch.py)

| White sample | Physical tick | What happens in both records |
|---:|---:|---|
| 9 | 19 | The 24-cell window enters exterior component X. |
| 2,705 | 5,411 | Last sample in X. Sites 1–24 encode 2,549,074, and sites 25–26 are white. |
| 2,706 | 5,413 | The new window is 9,127,232, outside X and outside the trap. |
| 2,715 | 5,431 | Sites 1–17 are black exactly at 4, 7 and 17. The 16-cell window encodes 72, outside the trap. |
| 2,716 | 5,433 | Sites 1–16 are black exactly at 1, 2, 3, 9, 15 and 16. Their code is 49,415, the kit's own `entryCode`. |

## How the two white cells act

At sample 2,705 the 24-cell window reads `010010101010011101100100` from the imposed column outwards. In particular, sites 22–24 read `100`. Write the colours at sites 25 and 26 as `a,b`. One tick later sites 23–25 read `1, a, a OR b`. Rule 30 therefore sets site 24 at the next white sample to `NOT (a OR b)`. The other 23 cells of the next window agree for all four choices.

| Sites 25–26 at sample 2,705 | Next 24-cell window | Next component | First trap entry through 2,716 |
|---|---:|---|---|
| White, white | 9,127,232 | Outside X | Sample 2,716 for all 4,096 completions |
| White, black | 738,624 | X | None in 4,096 completions |
| Black, white | 738,624 | X | None in 4,096 completions |
| Black, black | 738,624 | X | None in 4,096 completions |

The eleven-interval light cone for the final 16 sites ends at site 38 of the starting sample. The enumeration varies all twelve remaining sites 27–38 in each row of the table and checks every intermediate white sample. Farther cells cannot intervene. Both white cells are necessary with the 24-cell source held fixed. The Lean proof checks a shorter certificate for the white pair. When the last known cell is black it masks its eastern neighbour in the Rule 30 update. This retains 19 known cells even after 22 ticks. At the previous white sample the 16-code is 72, so the kit's forward closure rules out every earlier trap visit. [Kit closure and empty-row entrance](https://github.com/WolframInstitute/Rule30PrizeKit/blob/0f957499e86fe008ca0ae75b5aef2e4df79144af/lean/Ruliology/CellularAutomata/Rule30GateTrap.lean)

**At sample 2,715 the unique smallest certificate is all of sites 1–17.** Their colours are `00010010000000001` from west to east. Flipping any one of these 17 cells alone leaves the predecessor outside and makes its successor miss the trap. In particular, changing site 17 to white changes the successor from 49,415 to 263. Either colour at site 18 gives 49,415 for the observed first 17 cells. A two-tick update of the first 16 cells cannot read site 19. These single-flip witnesses prove the 17-cell lower bound even if one is allowed to specify sites farther east. Both implementations find 7,640 immediate outside-to-inside words among all 262,144 possible 18-cell predecessors. [Minimum-certificate search](entry_cells.py) · [Independent Rule 30 truth-table check](exit_switch.py)

## Why both records agree

The initial seeds 7,693,847 and 11,888,151 have the **same gate forever**, even under any common boundary drive. At physical tick `t`, the two rows agree through site `22+t`. At sites `21+t` through `24+t`, their tips alternate between the pairs `1110 / 1101` and `0010 / 0011`, followed by white cells. Advancing the four-site frame one site east and applying Rule 30 exchanges those phases. The first two sites match in each phase, so the common western region grows by one site per tick. The kernel checks this induction and its specialization to both numeric seeds. The result strengthens the finite gate comparison in I286. [All-time tip proof](RecordTips.lean)

The shared first 22 **initial** cells alone allow other outcomes. With white everywhere beyond site 24, the pairs white/white and black/black at 23–24 enter at samples 226 and 315 respectively. The two mixed choices give the records.

| Initial seed | Farthest single flip changing first entry at 2,716 | Initial prefix sufficient to force the entire 26-cell switch for every tail |
|---:|---:|---:|
| 7,693,847 | Site 2,240 | Sites 1–3,567 |
| 11,888,151 | Site 2,237 | Sites 1–3,568 |

Those farthest single flips delay entry beyond 2,716. The initial-prefix lengths are sufficient upper bounds. In an exhaustive single-flip test **no initial site** changed the pair at 2,705 while preserving the 24-cell source window at that sample. The test checked every site in the sufficient initial prefix. Any change entirely beyond that prefix leaves the whole switch intact. Thus the last two white cells have a precise local role, while the initial influence reaches them through a longer history. The least sufficient initial prefix remains unknown. [Initial intervention and prefix checks](switch_origin.py)

## What this says about the deadline

During the 2,697 samples from 9 through 2,705 inclusive, only eight visited 24-windows had any possible edge out of X. Those samples were 240, 288, 995, 1,569, 1,897, 1,898, 2,592 and 2,705. The physical outer pair kept the first seven in X. The final 24-window had never previously occurred on either trajectory.

R65 already counted **1,419** assignments of the exterior pair that leave X, among its 15,826 windows. They come from 724 source windows. Following all width-24 continuations from each exit gives the following split. [R65's window graph](../../k50_1/right-dichotomy.md) · [Exit calculation](x_exits.py)

- **1,144** force trap entry within 45 white intervals of the source. Of these, 311 force one exact entry time. The record edge is one of them.
- For each of the other **275**, the graph admits paths to the trap and paths to the fixed-gate component with least code 5,562. This component reads the repeating gate `001` up to phase while the path remains inside it. These alternatives concern paths in the strip. Particular paths may require mutually incompatible exterior bits on a physical history.

**K92.3 remains in progress.** For these records the delay comes from residence inside X. The final approach is bounded independently of the eastern tail. The next test is to mark the opportunities to leave X on the other long finite trajectories, distinguish paths eventually in a known lock, and ask what finite-support constraint limits the number of opportunities a nonlocking trajectory can decline. A bound on the eleven-sample approach alone leaves the all-support deadline open.

## Reproduction

Run `entry_cells.py`, `exit_switch.py` and `x_exits.py` with the kit root, R65's `W24.scc` and an output JSON path. Run `switch_origin.py` with just its output path. R65's certificate SHA-256 is `67937025136a83f5a89772f81bf62acc3c979972a78c64f6f28755642e953cb7`. Run Lean 4.35 on the two proof files with the kit library on its search path. The kit revision used was `0f957499e86fe008ca0ae75b5aef2e4df79144af`. The four JSON receipts are in `share-scratch/gptIntel/phase2/K92.3/entry-cells.zip`, 20,846 bytes, SHA-256 `ae419e656f3477ea65a54b0cb23e6f955cba1b42e342f293ee286cb7bee2870b`.
