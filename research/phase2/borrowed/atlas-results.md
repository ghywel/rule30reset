# K98 · Rule 30 among its relatives

**Fifteen of the twenty registered hybrids meet Cloud's definition of “rule-30-like” beside the wall. Five have explicit finite rows that pass the wall check forever.** On the full line, six of the twenty have nonwhite periodic columns in the search, with an elementary all-time witness for each. The registered Rule 45 and Rule 75 systems match Rule 30 in both finite tests. [K98 predictions and definitions](data/claudeCloud-atlas-predictions.txt)

## Predictions scored on the frozen runs

| K98 | Prediction | Intel replay |
|---|---|---|
| A1 · 97% | Rule 30 dies by tick 100 and within 2w+8 for every tested width | **Pass.** Longest 40 at width 22. The widthwise bound is attained at width 11, lifetime 30. |
| A2 · 99% | Time (30,240) row 1 and (240,30) row 3 survive forever | **Pass.** Both are exact two-tick cycles. There were 14 and 29 candidates respectively across all widths. |
| A3 · 60% | None of the twenty has a candidate at tick 4,096 | **Miss.** Five systems have candidates. Each has an actual immortal row, exhibited below. |
| A4 · 55% | At least twelve of the twenty are rule-30-like | **Pass.** Fifteen: nine time hybrids and six space hybrids. Every one of the twenty passes the two numerical shape criteria. The five exceptions each have a row alive at tick 100. |
| A5 · 65% each | Neither normalized Rule 45 nor normalized Rule 75 has a wall candidate | **Pass for both** through width 22. The longest lifetimes are respectively 50 and 38 at width 22. |
| B1 · 97% | Rule 30 gives no periodic tail in the full-line search | **Pass** in all 59,334 tested start/site combinations. |
| B2 · 80% each | Neither flashing-rule time hybrid gives a periodic tail | **Pass for both** in all 59,334 tested combinations per hybrid, in the normalized coordinates of K98. |
| B3 · 55% | None of the twenty gives a nonwhite periodic tail | **Miss.** Both time orders with 150 and the four space orders with 120 or 180 do. |
| B4 · 95% | Every tested time (30,240) start has a nonwhite periodic column | **Pass.** All 1,023 starts have one. The initial leftmost occupied site is permanently black for every nonempty finite start. |

## Every registered relative

In a time pair (A,B), A acts first. In a space pair, A acts at odd wall depths or at even full-line coordinates, including site 0. A wall row is packed with depth 1 as bit 0. All 2,097,152 positive odd rows of widths 1–22 per system were checked until their first failed even tick or tick 100. At each exact width the 64 smallest remaining rows were then checked to tick 4,096. This cap affected **zero** of the twenty registered systems and zero of the three single-rule comparison rows below. Every tick-100 survivor in these rows survived to tick 4,096.

- **Lifetime (w)** is the longest observed *finite* lifetime and the first width attaining it.
- **After support** gives the count passing the first even check after all initial cells have been read, divided by the count passing every even check inside their support. Widths 20–22 are pooled by adding counts. “Like” also requires no tick-100 survivor and some width 16–22 with lifetime exceeding w+2.
- **Candidates (seed)** gives the number alive at tick 4,096 and the least starting integer when positive.
- **Line, any / nonwhite / all** counts starts with at least one periodic tail, starts with at least one periodic tail containing black, and starts with a periodic tail at every inspected site. For each of the 1,023 starts the test compares sites −24 through 33 on the inclusive interval [2,048, 4,096], accepting any period 1–64. A white tail passes with period 1.

| Mode | A,B | Lifetime (w) | After support | Candidates (seed) | Like | Line, any / nonwhite / all |
|---|---|---:|---:|---:|:---:|---:|
| time | 30,90 | 46 (22) | 1055/2068 | 0 | yes | 0 / 0 / 0 |
| time | 90,30 | 42 (22) | 1028/2061 | 0 | yes | 0 / 0 / 0 |
| time | 30,150 | 40 (20) | 1034/2049 | 0 | yes | 84 / 58 / 0 |
| time | 150,30 | 48 (22) | 1031/2055 | 0 | yes | 46 / 32 / 0 |
| time | 30,210 | 38 (21) | 960/1966 | 0 | yes | 0 / 0 / 0 |
| time | 210,30 | 40 (22) | 1020/2087 | 0 | yes | 0 / 0 / 0 |
| time | 30,120 | 36 (19) | 1060/2064 | 0 | yes | 0 / 0 / 0 |
| time | 120,30 | 38 (20) | 1002/2015 | 0 | yes | 0 / 0 / 0 |
| time | 30,180 | 40 (21) | 1119/2034 | 0 | yes | 1023 / 0 / 1023 |
| time | 180,30 | 34 (22) | 1105/2074 | 1 (7) | no | 1023 / 0 / 1023 |
| space | 30,90 | 50 (22) | 1071/2023 | 0 | yes | 0 / 0 / 0 |
| space | 90,30 | 38 (21) | 1124/2034 | 0 | yes | 0 / 0 / 0 |
| space | 30,150 | 40 (22) | 756/2163 | 0 | yes | 229 / 0 / 0 |
| space | 150,30 | 40 (20) | 1227/2103 | 0 | yes | 176 / 0 / 0 |
| space | 30,210 | 40 (22) | 1065/2029 | 0 | yes | 0 / 0 / 0 |
| space | 210,30 | 36 (20) | 1041/2040 | 0 | yes | 0 / 0 / 0 |
| space | 30,120 | 34 (22) | 1016/2023 | 67 (1) | no | 1023 / 1023 / 0 |
| space | 120,30 | 34 (21) | 1000/2060 | 4 (1) | no | 1023 / 1023 / 0 |
| space | 30,180 | 36 (20) | 992/2048 | 1 (1) | no | 1023 / 1023 / 0 |
| space | 180,30 | 34 (21) | 1026/2074 | 5 (3) | no | 1023 / 1023 / 0 |
| time | 30,30 | 40 (22) | 1005/2062 | 0 | yes | 0 / 0 / 0 |
| time | 210,180 (45) | 50 (22) | 1108/1995 | 0 | yes | 0 / 0 / 0 |
| time | 180,210 (75) | 38 (22) | 1028/2042 | 0 | yes | 0 / 0 / 0 |

The Rule 45 and 75 rows use the perturbation from the flashing background. The raw colour equals the normalized colour XOR the parity of the tick. The atlas's white wall therefore corresponds to a flashing raw wall. On the line, eventual periodicity is equivalent between the two colourings. A period-p raw trace with even p has normalized period p, while an odd p gives normalized period 2p (possibly a divisor). Hence the normalized cutoff 64 covers all raw even periods through 64 and all raw odd periods through 31. [Local truth-table identities](HybridParity.lean)

## Which conclusions extend to all times?

**Wall, positive cases.** Direct substitution in the wall's local update gives all five witnesses. The even-time states stay odd, exactly the survival condition.

| Hybrid | Initial segment and repeating states |
|---|---|
| time (180,30) | 7 → 2 → 7, repeating |
| space (30,120) | 1 → 1 |
| space (120,30) | 1 → 2 → 3 → 3 |
| space (30,180) | 1 → 1 |
| space (180,30) | 3 → 2 → 3, repeating |

The separate A2 controls are 1 → 3 → 1 under time (30,240) and 3 → 1 → 3 under time (240,30). All remaining *counts* in the candidates column come from finite runs. No uniform death theorem follows from a zero there. The separate four-tick front proof supplies an all-width deadline for time (30,180), although it passes every “like” criterion in the atlas. [Four-tick front and wall theorem](HybridWallFront.lean)

**Line, nonwhite cases.** In time (30,150), the nonlinear tick agrees with Rule 150 whenever every black site has the same parity. Two linear ticks preserve this property. Rule 150 preserves reflection symmetry, and on a symmetric row its central left and right inputs cancel. Thus the singleton stays black at site 0 at every tick. Its row at tick 1 is three consecutive black cells. Translating that row yields start 7 with site 1 permanently black under the reversed time order (150,30). The finite period ranges seen across all starts were {1,2,4} in the first order and {1,2} in the second. [Parity and symmetry argument](HybridParity.lean)

For the four spatial orders with 120 or 180, take the initial leftmost occupied site L. If L uses rule 30, all sites below L remain white: the immediate west site uses the partner rule, which sends 001 to 0. Site L remains black since Rule 30 sends both 010 and 011 to 1. If L uses the partner rule, its western neighbour uses 30 and becomes the leftmost black on the first tick. The same induction applies there forever. For the singleton this gives a constant black at 0 for space (30,120) and (30,180), or a constant black from tick 1 at −1 for their reversals. For the time (30,240) control, the rule-30 tick creates a new leftmost black at L−1 and keeps L black, and the shift returns the left edge to L. Repetition gives B4 at site L itself.

**Comparison with pure Rule 30.** Passing the wall criteria is compatible with an all-width death bound, and even with an exactly constant singleton centre on the whole line. A finite stretch without a detected period in the 45 or 75 rows remains a bounded negative result. These are controls for proposed proofs of Q01 or for transfers from a wall to the actual singleton.

## Replay

Cloud wrote the native atlas and its separate cell-by-cell Python implementation. Intel ran both. The independent small-size comparison checked **256 blocks with zero mismatches** (two modes, two frames, 64 ordered pairs). The full native runs give, for time and space modes respectively, 27 and 38 systems with a tick-4,096 candidate, 33 and 17 satisfying “like”, 41 and 57 with some tested periodic line tail, and 22 and 32 with some nonwhite periodic tail. The per-width carry cap was reached with additional survivors omitted in four time systems and 21 space systems in the wider atlas. The small replay uses an uncapped carry at widths through nine. [Native generator](claudeCloud_atlas.cpp) · [Cell-by-cell replay](claudeCloud_atlas_check.py) · [Summary reader, optional `--all` to print all 128 systems](summarize_atlas.py)

The shared bundle `K98-atlas-replay.zip` is 23,728 bytes, SHA-256 `91142d2ed5d9dc9158b36dc64d028768fdf22bc36331788b484601678c85fef1`. Each member was compared byte-for-byte with its native output after replacing CRLF by LF.

| Output | Native Windows SHA-256 | Shared LF member SHA-256 |
|---|---|---|
| wall-time.txt | `20e0bf39802dc2662fc0b65f76cfa507b8eca78a42d8534d922b361d8ccf0077` | `f99bec7999bbed276d4494f3dbc9647216d2544f91bcf0fc4d2d3b06b919e1b3` |
| wall-space.txt | `d725b2e5600462712f1fce679469cb9a2670c03e59f072279bc6d2b231a3c7b4` | `9a0fcaecc3cce6ae47a60b9c4b2fcbee77fe9e996d4d5174849172d8ee93b622` |
| line-time.txt | `9988faef3aa774aae0cd0ed3a94069a15326925ab0e88c275c88d1fa7b9aed01` | `1a5838be9afae9c8fce82c83755cdebfe1e577033c61204969b1f0b93233cb42` |
| line-space.txt | `b086f7471f30b30b160c7c2fe920defdc33573e43da16ceceb4f6f22880eee5b` | `b5579d50fc87221435b88d1d6d00fb586f67bfb041abda5445a15e1d355b6522` |
| replay.txt | `64c24ae5444dfe6f9caef2a67423b7d59675c9edf7f9060fc9814d7b58ab592d` | `835ad89b63d67fb54322ae62e77fd6863af1f8627a2169864ddf1d0cd7c64ec8` |
