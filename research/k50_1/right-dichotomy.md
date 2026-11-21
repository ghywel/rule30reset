# The right dichotomy for cut ether and the 58 historical misses

The right dichotomy (RD) asks whether every finite right half driven by a black-even alternating centre either
enters the kit’s 829-window gate trap at an odd tick or has an eventually periodic gate. The gate is column 1
sampled at odd ticks. K50.1 settles RD for every truncation of the reference ether in both compatible phases.
For arbitrary finite starts, two components of the width-24 window graph still allow an aperiodic gate.
[Kit definition of RD](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30PeriodTwoWidth13.lean#L1377-L1382)

## Every cut of the ether

Place the alternating centre at ether column B4. Choose phase 1 or 3 at tick zero, keep the first N cells of
the ether to its right, and set every deeper cell white. The following classification is kernel-checked for
every N, including zero. A match means that physical column 1 agrees with the uncut ether at **every** tick.
Its odd-time gate then has period two from the start. [Classification and sharp thresholds](Rule30CutDichotomy.lean)

| Initial phase | Cut widths that depart from the reference and enter the kit trap | Least width from which every cut matches |
|---|---|---:|
| 1 | 0 through 6 | 7 |
| 3 | 0, 1, 2, 3, 4, 5, 8, 10, 11, 12, 15, 17, 18, 19, 22, 25, 26, 29, 36 | 37 |

Every unlisted cut matches. Each of the 26 exceptions has an odd-time mismatch and a literal trap entry by tick
293. Measured from first departure of physical column 1, the largest wait among them is 293 ticks. Measured
from the first gate mismatch it is 292. Phase 3 with N=0 attains both maxima. Phase 3 with N=3 is already
in the trap at tick 5 when column 1 first departs at tick 6, so its wait after departure is zero.

**Why the finite checks cover all N.** If a cut keeps column 1 in phase, prepend seven ether cells. The original
driving column becomes the interface at depth seven. Its right neighbour supplies the matching first column,
so the local rule advances the prepended cells as ether and the old half as its original orbit. This can be
repeated for any number of spatial periods. For each residue modulo seven, one finite check through entry
into the kit’s 13-cell wall proves a match forever. The table gives the least such width in each residue.
[Seven-cell extension](Rule30CutSplice.lean) · [Fourteen base cases](Rule30CutAnchors.lean)

| N mod 7 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---:|---:|---:|---:|---:|---:|---:|
| Phase 1 | 7 | 8 | 9 | 10 | 11 | 12 | 13 |
| Phase 3 | 7 | 43 | 9 | 24 | 32 | 33 | 6 |

The kit already proves that a black edge inserted into full-line ether pins in each of the 28 alignments.
The result above identifies exactly what the fixed alternating wall observes for each finite cut and checks
trap entry for the exceptional widths. [Earlier edge theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30EtherEdgeZero.lean)

## Where the 58 seeds went

The replay used placego L1612’s generator in its original draw order. Of 1,500 exact-width-30 starts, 1,442
entered the literal trap by tick 6,001, with median entry at tick 29. This reproduces the archived calculation.
The other 58 already had periodic gates by tick 967. The finite seed and entry window for each were also
checked by an independent cell-by-cell replay. Lean proves eventual periodicity for every seed on the list.
[Original sampler](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/tests/probes/swarm/sw02/block3/local_trap_real_rows.py) · [Replay](gptM5_sample.py) · [Lean witnesses](gptM5_sample.lean)

| Destination | Seeds | Earliest and latest certificate tick | Gate period in odd-time samples |
|---|---:|---:|---:|
| Ether prefix followed by a kit wall | 53 | 2–73 | 2 |
| Kit’s 30-column lock with repeating word `0101000` | 5 | 423–967 | 7 |

Both periodic words give recurring pairs of black gate observations two samples apart. After entry to the
829-window trap the next black observation after each black is three or five samples away. This explains
why a search for that trap alone missed the 58. The million-tick horizon was a cutoff for an unresolved
seed. Every seed reached a certificate earlier. [Kit gate-trap theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30GateTrap.lean)

## What the window graphs decide

**COMPUTED.** Each vertex is a W-cell window at an odd tick. Each edge evolves it two physical ticks using
one of the four choices for the two exterior cells in the **initial** row. The far input at the second tick
is determined by the local rule. The program checks that distinction against a scalar cone. The *eventual
image* contains windows with arbitrarily long graph histories, including one-way paths downstream of
cycles. A *sink* is a strongly connected component with no outgoing edge. Counts below cover the whole
graph at each width. [Classifier and controls](gptM5_windows.cpp)

| W | Eventual image | Vertices on cycles | Cyclic components | Trap sink size | Ether sink size | Exterior components with variable gate labels |
|---:|---:|---:|---:|---:|---:|---:|
| 16 | 6,250 | 3,223 | 4 | 740 | — | 1 |
| 17 | 9,250 | 4,873 | 4 | 1,252 | — | 1 |
| 18 | 13,374 | 7,407 | 3 | 2,024 | — | 1 |
| 19 | 21,482 | 10,880 | 5 | 3,176 | 52 | 1 |
| 20 | 33,853 | 12,152 | 6 | 5,221 | 88 | 2 |
| 21 | 50,750 | 18,195 | 6 | 8,159 | 156 | 2 |
| 22 | 78,655 | 27,804 | 6 | 13,276 | 261 | 2 |
| 23 | 123,486 | 41,098 | 6 | 21,608 | 452 | 2 |
| 24 | 191,382 | 63,124 | 6 | 34,926 | 780 | 2 |

At widths 19–24 every member of the exterior sink has six ether cells followed by a certified 13-cell
wall. Its gate repeats `10` up to rotation. Width 20 has exactly two minimal nonempty closed sets, as
K50.1 predicted. An infinite path can stay in a component that has exits.

At width 24, every *physical* counterexample must eventually stay in one of the following two components.
Every other recurrent component either lies inside the trap or forces a periodic gate. In each listed
component two vertices in the same cyclic class have different gate labels. This admits aperiodic graph
paths. Extending one such path to a **single finite right half** is the open step.

| Least window code | Windows | Outgoing edges, counting the four inputs | Projects into width-20 component | Known finite behaviour |
|---:|---:|---:|---:|---|
| 519 | 15,826 | 1,419 | 305 | Both kit period-seven locks project here. Finite starts can stay forever with periodic gates. |
| 1,799 | 11,069 | 3,389 | 153 | Gate periodicity for a finite start that stays here is open. |

Both project into component 23 at width 16. Every cyclic vertex can occur at tick 1 of a finite start:
take an internal incoming edge, retain its middle row through depth W+1, then pad white. Successive edges
can require incompatible exterior data. This is why entry alone does not refute RD. The next test is to
track which returns within component 1,799 remain compatible with deeper columns of one orbit.
[Projection and ether checks](gptM5_read_windows.py)

## Replay and evidence

Run these commands from the repository root at kit commit `40017e8`, with Lean 4.35 and Lake on the path. The Lean check builds its local modules in a temporary directory.

```sh
research/k50_1/check-lean.sh
evidence=$(mktemp -d)
python3 research/k50_1/gptM5_sample.py > "$evidence/sample.jsonl"
python3 research/k50_1/gptM5_cuts.py > "$evidence/cuts.json"
c++ -std=c++17 -O3 research/k50_1/gptM5_windows.cpp -o "$evidence/windows"
kit_file=Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean
for w in 16 17 18 19 20 21 22 23 24; do
  "$evidence/windows" "$kit_file" "$w" "$w" "$evidence/W$w.scc" > "$evidence/W$w.txt" || exit 1
done
python3 research/k50_1/gptM5_read_windows.py "$evidence"
```

The shared-store archive `share-scratch/gptM5/K50.1/R65-evidence.tar.gz` holds both JSON outputs, all nine
component membership files and their summaries, checksums and resource use. SHA-256
`db5c68a8648d0dad81265b0504d8983ea90191d5d71a4a8e85f187900718f308`.
