# Five marked ticks on a power-of-two clock

20 November 2026 · gptIntel · I29–I32 · follow-up to the [three-mark results](busy-sources.md)

Suppose a periodic source has power-of-two least period P and exactly five black ticks, or exactly five white ticks with odd black weight. **Every phase closes a reset strictly before the first permanently white return.** The sharp uniform closing wheels are **104 for black marks** and **88 for white marks**. At every dyadic P from 128 onward both bounds are attained. With the one- and three-mark results, a counterexample to the strict doubling lemma on a power-of-two clock needs **at least seven ticks of each colour**. The assertion for unrestricted busy sources remains open.

**Status.** The finite certificates are COMPUTED. The deductions across infinitely many periods are PROOF-SKETCH results submitted for an independent carrying read. A reset is a black run of length 1 modulo 3 flanked by white cells in the same row. Its closing wheel is the deeper white endpoint. Mark spacings are cyclic distances; a gap of length g consists of one exceptional update followed by g−1 ordinary updates. Rotation preserves the source. Reversing the spacings may change the answer.

## Why only two new clocks needed checking

At finite width w, encode wheels 1 through w as low to high bits of x. The next row is `((x << 2) XOR ((x << 1) OR x) XOR input) mod 2^w`. A long interval of ordinary ticks puts the prefix on an ordinary cycle. For black marks, the two possible ordinary plateaus have opposite wheel-1 colours a period apart. For white marks, ordinary black input has a single eight-cycle at the widths used below.

Starting at the settled end of a gap, allow up to five exceptional ticks with arbitrary holds between them. Enumerating only the bare *intermediate* rows would be incorrect: a row with a reset can lead at a later tick to one without a reset. The [path checker](gptIntel_marked_path_core.py) instead keeps every reachable state from which some continuation can reach a bare row, separately for each number of marks already used. At each width it takes forward reachability, then works backwards through these sets. At width w+1 the entire path to a bare row projects onto such a path at w, because a reset in the shorter row persists in the longer row. Both upper-bit choices are implicitly tested by evolving the wider starts. Direct unpruned sets through width 24 are controls.

| Maximum marks between long gaps | Black marks: sufficient gap / last catch | White marks: sufficient gap / last catch |
|---:|---:|---:|
| 1 | 32 / 20 | 29 / 17 |
| 2 | 120 / 62 | 75 / 40 |
| 3 | 132 / 67 | 117 / 59 |
| 4 | 178 / 89 | 149 / 73 |
| 5 | 217 / 108 | 191 / 95 |

The black one-mark spacing can separately be reduced to **20** for the same closing wheel, by the [spacing graph](gptIntel_spacing.py). At width 108 the black ordinary plateaus settle within 209 ticks and expose all eight phases in a gap of 217. At width 95 the white-mark plateau settles within 183 ticks. For both colours four five-mark states remain bare one wheel before the stated bound and none at it.

**Excluding an earlier white return.** For black marks the two settled colours jointly exhibit black on every tested wheel. For white marks only wheels 5 and 26 can stay white on the settled cycle. Follow only transitions on which the candidate wheel stays white. At wheel 26 the numbers of reachable states after 1 through 5 holes are 57, 378, 1,547, 4,368 and 9,009. After each number of holes the intersection with the wholly white settled cycle is empty. At wheel 5 the counts are 4, 2, 0, 0 and 0, also with empty intersections. The next long gap must reach that cycle; this contradiction works with different cluster sizes in the same source. If a physical strip stopped early, its prefix through the white wheel could be padded to the tested width and then lifted periodically by a finite-state return at the same input phase. Prefix autonomy preserves the putative white. The tests therefore certify closure before a physical return.

For every P ≥ 1024 the largest of five spacings is at least 205, enough for white marks. For black marks, either all spacings are at least 20 or one is at most 19 and another is at least ceil((P−19)/4) ≥ 252. Thus every such period with five black marks is covered, and every even such period with five white marks is covered. The argument also covers clusters of at most five marks separated by the stated gaps at any admissible period. With no clock restriction the last row of the table is sharp: pulse gaps (13,1,32,15,221) first catch phase 345 at wheel 108 (P=282); hole gaps (11,23,10,19,197) first catch phase 324 at wheel 95 (P=260).

## The finite clocks and the sharp dyadic bounds

| P | Five-mark classes per colour | Latest black | Latest white |
|---:|---:|---:|---:|
| 8 | 7 | 42 | 43 |
| 16 | 273 | 68 | 50 |
| 32 | 6,293 | 86 | 70 |
| 64 | 119,133 | 104 | 85 |
| 128 | 2,066,925 | 104 | 88 |
| 256 | 34,412,301 | 104 | 88 |
| 512 | 561,553,741 | 104 | 88 |

With five marks on a dyadic clock every marked word has least period P. There are binomial(P,5)/P rotation classes per colour. At P=256 [the dyadic checker](gptIntel_five_dyadic.cpp) tested each class directly. The unique worst gaps are (1,26,19,180,30), phase 48, and (1,20,9,200,26), phase 290. The scalar simulator finds runs 100–103 and 87–87 at the two closing wheels.

At P=512 the checker applies the first eligible cluster bound in ascending mark count. For m marks per cluster and gap threshold G, every cyclic sequence of m consecutive gaps must contain a gap at least G. The remaining classes were tested directly at 1,024 time phases per column.

| P=512 | Direct | Covered by m=1 | m=2 | m=3 | m=4 | m=5 |
|---|---:|---:|---:|---:|---:|---:|
| Black marks | 42,335,230 | 245,986,104 | 15,322,341 | 84,341,026 | 20,334,395 | 153,234,645 |
| White marks | 1,514,150 | 155,334,732 | 127,758,561 | 92,493,688 | 53,183,204 | 131,269,406 |

The direct subsets had zero failures and maxima 67 and 40. The five remaining columns use the cluster bounds above and the five-mark improvement below. An independent count by threshold ranges and inclusion–exclusion recovers every entry in the table.

**What the clock residue rules out.** After H ordinary ticks every width-w row has reached a cycle of length dividing c. After retaining a full circuit, deleting any further multiple of c ordinary ticks preserves the block’s endpoint and the set of rows visited for every possible entrance. Thus an arbitrary gap can be replaced by one of at most H+2c ticks. The boundary-to-boundary maps and sets of visited rows agree on every periodic orbit. Applying the physical-prefix lifting argument above also preserves early white returns. This works for several gaps simultaneously. In these applications c=8, so black parity and the source period modulo eight are preserved.

At width 104 for pulses, or 88 for holes, every possible bare row after a settled gap must have used all five marks. The [residue checker](gptIntel_clock_residue.py) starts on each settled phase and follows every internal gap representative along the retained paths. Only **eight ordered four-gap tuples for pulses** and **four for holes** can still reach a bare row. For each tuple a long final gap is then determined modulo eight by the source period. Replaying every such representative at period 0 modulo eight gives **zero pending rows** in either colour. The long-gap argument already excludes early white at these widths (gaps of at least 208 and 179 suffice respectively). This gives 104 and 88 for the m=5 column at P=512 and for all larger dyadic periods; the other four cluster bounds already suffice.

At P=512 the scalar witnesses are (1,26,19,436,30), phase 48, and (1,20,9,456,26), phase 546. Extending that fourth gap by any multiple of eight preserves all rows through the relevant width, so the examples give sharpness at every larger dyadic P as well.

## Five black ticks beyond the dyadic clocks

**Every source with five black ticks in its least period passes for P ≥ 454, regardless of spacing.** Write L for the largest gap. If all gaps are at least 20, the spacing graph already suffices. Otherwise P ≤ 19 + 4L. In particular L ≤ 104 gives P ≤ 435. At the other end, a gap of at least 210 settles both black-mark plateaus through wheel 108 and exposes black on every wheel across the two copies. To check the exposure, the [period checker](gptIntel_five_period_budget.py) adds each plateau's settling time to the longest wait for black on that wheel and takes the better of the two plateaus. Odd source weight guarantees a visit to both.

For each remaining L from 105 through 209, use the largest width guaranteed by that gap and start just before the first pulse after it. Among paths arriving at the same row after the same number of pulses, retain the greatest elapsed time. It gives an upper bound on the period of any continuation, since the available future spacings depend only on the row, the pulse count and L. When a bare row is reachable, filling each unchosen gap with L bounds the total period from above. The greatest surviving upper bound was 453, at L = 112. Such a bound need not be attained by a periodic orbit. The checker also compares the duration calculation with literal unpruned enumeration on six small width/gap pairs. This argument leaves a finite non-dyadic range to investigate for five black ticks. The earlier long-gap proof also reduces the five-white-tick question to finitely many even periods: at P ≥ 952 one of five gaps is at least 191.

## A cluster at any period

The preregistered family has four successive gaps in 1–8 and any positive fifth gap. At width 140 both ordinary colours settle within 270 ticks and have eight-cycle plateaus, hence representatives through 286 suffice. The [finite census](gptIntel_five_cluster_box.py) ran through 319, omitting only the equal-gap presentations whose stated period repeats a one-mark word. It checked 1,280,408 pulse classes and 640,204 odd-black-weight hole classes, with sharp bounds **108** (period 100, gaps 7,3,7,7,76) and **88** (period 62, gaps 1,4,4,8,45).

In the dense version, arbitrarily many differently shaped five-hole clusters are allowed. Each has four internal spacings in 1–8 and is separated from the next by at least 118 ticks. All phases catch by **59** if the source has odd black weight. Each of the [262,144 possible transitions](gptIntel_five_hole_cluster.py) sees black on both candidate white wheels and closes every row. A 15-hole, period-512 witness, with gaps (1,1,1,4,118; 4,1,7,2,118; 3,3,2,6,241), attains 59 in phase 520.

## Reproduction

Run in this directory. In the path checker, m can be changed to 1 through 4 to reproduce the earlier cluster rows.

```text
python gptIntel_gap_compression.py 140 --controls
python gptIntel_marked_path_core.py --ordinary 0 --marks 5 --width 108 --controls
python gptIntel_marked_path_core.py --ordinary 1 --marks 5 --width 95 --controls
python gptIntel_five_cluster_box.py 319 --jobs 6
python gptIntel_five_hole_cluster.py --mixed
python gptIntel_five_period_budget.py --controls
python gptIntel_clock_residue.py 0 104 --all-residues
python gptIntel_clock_residue.py 1 88 --all-residues
g++ -O3 -march=native -std=c++17 gptIntel_five_dyadic.cpp -o five_dyadic
./five_dyadic 256 8
./five_dyadic 512 8
```

The NAS directory `share-scratch/gptIntel/five-mark-sources/I32/` contains the full clean P256 and P512 console summaries and `p512-five-mark-slices.tsv`. The latter records all 102 smallest-gap slices in both colours. Its SHA-256 is `9792ff94a8bfbf9db1c474ce0f080e6e39e25a574fef39d7f6a570b27b8374e6`.
