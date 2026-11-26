# K92.1 · How much west mass can a real east serve?

Ages start with the black centre immediately before a kick. One tick later the centre and its west neighbour are white. Let $a(H)$ be the minimum initial count of black cells in the first $H$ west sites at that white tick, taken over histories that sustain the alternating centre through the next $H$ ticks. All horizons below are even. Easts may be infinite. Each reported upper witness has a finite east.

## The first extension

| H | Certified lower bound | Replayed upper bound |
|---:|---:|---:|
| 44 | 8 | 8 |
| 120 | 31 | 31 |
| 144 | 40 | 40 |
| 160 | 47 | 47 |
| 176 | 50 | 50 |
| 180 | 53 | 53 |
| 190 | 57 | 57 |
| 200 | 60 | 63 |
| 220 | 68 | 71 |
| 230 | 71 | 76 |
| 240 | 73 | 81 |
| 250 | 78 | 84 |
| 260 | 81 | 88 |
| 270 | 83 | 92 |
| 280 | 88 | 97 |
| 290 | 94 | 100 |
| 300 | 97 | 103 |

**COMPUTED.** The bounds agree at every even horizon through 182. They differ by one at 184 and agree again at 186, 188 and 190. Across the 150 horizons they agree at 94. At 172, 174 and 176 exactly one strip prefix has mass at most 50. The gap word at 176 begins 3,4,4,4 and continues with threes and fives, including a run of nine fives. Its cheap early depths do not enforce a low asymptotic density. The same sampled right which attains 50 at 176 takes 112 black cells by 300. The predicted upper witness below 105 did not appear among the 24,155 anchored representatives. Varying a 12-bit block of this right over 155,648 trials (including repeats) produced a weight-103 witness. The finite black-tick right is hexadecimal `75542952dc4981fc7c44f7ed88cbbe4`. The exact strip minimum 97 falls in the predicted 90–102 range. At 230 the physical upper still exceeds the strip minimum by five, missing the predicted gap of at most three there.

**CONJECTURE.** $H ≤ 4a(H)+12$ for every even horizon. The calculation checks every even $H ≤ 300$, and $H=44$ attains equality. A direct charge of one black cell to each four consecutive depths after a twelve-cell allowance fails on an attaining row. The initial right before the kick is hexadecimal `2a72b25f3a8207057026009bec42ebe4`. The white-tick west is `4020408116`, with depths 31 through 38 all white. A local charge would need to carry surplus across an eight-white gap, and every proposed invariant must explain why the nonphysical one-in-seven row cannot satisfy its hypotheses. The planted control in M10 can duplicate any fixed finite check table. No all-horizon invariant has been found.

## What was enumerated

- The 22-cell strip starts from every first white-tick window with a genuine black predecessor. A reading is its leftmost bit. The next window may use any choice of its two missing rightmost cells. Every true right half is among these paths, hence a minimum over paths is a lower bound. The right edge can make incompatible choices at different times.
- A gate bit $g$ appends $(1-g,1)$ to the depth-one white-wall trace. M6's antidiagonal recurrence recovers the next two initial west cells. Their mass is nonnegative. As a result the DFS can prune a prefix as soon as it exceeds a fixed budget, and an empty level excludes that entire budget at every longer horizon. The searches visited 218,411, 1,331,689 and 7,469,112 affordable nonempty prefixes for budgets 50, 65 and 80. Their first empty levels were 178, 218 and 256. The final budget of 105 visited 118,583,074 prefixes. Of these, 181 reached 300, and the least cost among them was 97.
- Independently, each kick-starting representative in the I246 sample was extended by a white tail. A separate column-by-column inversion produced its west. Every reported best row was then evolved on the full line with no forced boundary. The finite row uses only the first $H$ west cells. Agreement of these bounds gives a physical minimum. A remaining interval gives two certified inequalities.

**Next test.** Work with the prefix 3,4,4,4. Compare the change in cumulative deficit $H-4A$ after a block of five gaps for each distinct entering west antidiagonal. A valid charge must control all entering states, including those arising before the trap. A sublinear diverging floor would also rule out finite-west immortality. Only bounded minima along arbitrarily long horizons force an immortal finite west by compactness. The related gap-language argument is already in the kit.

## Replay

From the repository root, use these commands with the I246 input from `share-scratch/gptIntel/K84/k84-I246.zip`. The output columns include a minimizing strip gate or a finite whole-line witness at each even horizon. The upper-witness file uses hexadecimal with the nearest site in the low bit on each side. The pre-kick east and the at-kick west are separated by one tick.

```sh
c++ -O3 -std=c++17 research/phase2/floor/strip_floor.cpp -o strip_floor
./strip_floor 22 300 50
./strip_floor 22 300 65
./strip_floor 22 300 80
./strip_floor 22 300 105
python research/phase2/floor/physical_floor.py data/sample-60.tsv
python research/phase2/floor/nearby_witnesses.py 75542952dc4981fc7c441f1d88cbbe4
```

The six raw tables are in `k92-1-floor-receipts.zip`, 8,110 bytes, SHA-256 `2a93b132305a970479e17198bec6fefff749432371b2144cd754bd9acac0019c`. The B105 table SHA-256 is `997dfd2e6ea465d127533fb188e13752b40f231818a9dd8de213aa96a737efdb`. The initial and nearby physical tables have hashes `23f97b028b816e35401335f3a43c7d4d217061bcbc5fb52891753f7ae6eda67b` and `6315c9c7c00fe96d296f8c57e58d454f05fddee084ee429612afed64ce84cd74`.

Sources are [K92's first probe](../claudeCloud_floor_probe.py), [I246's strip and gate conventions](../../rule4/k84/gptIntel-k84-continuation.md), [M6's antidiagonal](../../m6/m6_floors.py) and [M10's planted control](../../m10/control-laws.md).
