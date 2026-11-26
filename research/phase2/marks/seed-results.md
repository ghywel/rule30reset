# K92.4 · Marks and white-west restarts on the single seed

**COMPUTED.** Of the 4,194,304 positive starting ages through `2^22`, 2,326,009 have a mark (including length zero). The largest marked gap has 22 white neighbours and occurs twice, at ages 34,429 and 2,125,919. The largest physical gap has 25 white neighbours at age 2,085,567, when its arrival finds the centre white. The longest finite first failure is 53 ticks. It begins at age 2,752,669 with just two white neighbours and ends at age 2,752,722.

The three observations have different definitions. For each onset `s`, let `l` be the number of whites immediately west of the centre before the nearest black. A mark requires the centre black at `s+l`. To calculate a finite first failure, restart the west all white, drive it with the actual centre sequence, and at each black centre tick compare its predicted nearest west bit with the complement of the following centre bit. The first disagreement determines the delay. Every positive onset gave a finite first failure, and every observed mark had its first failure exactly at `l`. At age zero the singleton already has an empty west. The exact driven restart agrees with the real west at every time. [Lowry's definitions and implication for Problem 1](https://github.com/WolframInstitute/Rule30PrizeKit/blob/0f957499e86fe008ca0ae75b5aef2e4df79144af/lean/Ruliology/CellularAutomata/Rule30MarkedGaps.lean#L20-L65)

## Record onsets

Each list gives `onset (width, delay, or run length)` for strict increases. Run endpoints are inclusive, hence the last tick of a run is `onset+length−1`; marks and failures use `onset+delay`.

| Observable | Strict records |
|---|---|
| Mark | 1 (0), 3 (1), 17 (2), 20 (3), 46 (10), 242 (11), 13,001 (12), 24,448 (14), 34,429 (22) |
| Finite first failure | 1 (0), 2 (2), 4 (4), 6 (13), 156 (14), 204 (15), 285 (20), 1,162 (24), 3,443 (26), 12,908 (29), 16,369 (34), 61,472 (39), 759,621 (45), 2,752,669 (53) |
| Black centre run | 0 (2), 3 (3), 62 (6), 191 (7), 1,053 (9), 4,646 (10), 6,531 (13), 22,711 (16), 37,260 (21), 731,772 (22), 1,174,512 (23) |
| White centre run | 2 (1), 6 (2), 10 (3), 43 (4), 86 (5), 117 (7), 292 (10), 1,269 (12), 11,109 (14), 26,216 (15), 32,198 (19), 2,810,107 (20) |

We retained the centre through age 4,194,816, providing 512 extra ticks for resolving onsets through 4,194,304 inclusive. Every mark, positive restart and centre run in that onset range was resolved. The 512-site west collar always reached the nearest black for every positive age observed. Four independently evolved moving diagonals were cross-checked against the physical row wherever the two simulated cones overlapped. In the whole observed range, D2 was black only at age 1; D7 was white throughout; D28 had ten black ticks ending at age 30; D399 had 137 ending at age 500. Each had settled well before the last several record onsets. Values at the same age alone cannot distinguish those late records from other late ages.

The pre-run prediction (0.8) put the maximum marked width between 16 and 30 inclusive. It was borne out, though the width-22 record already occurred before age `2^16`. Unbounded widths or unbounded finite failure delays would imply aperiodicity; this finite run establishes neither. A clock explanation requires a specific rule predicting future records from the edge. [Probe and build command](seed_records.cpp)

## Did the clock predict the second half?

At ages up to 2,097,152 there were 50 marks of width at least 14. Among their births the most frequent phase mod 16 was 0 (7/50). Among their arrivals it was 14 (10/50). Among the 64 marks in the second half, those same phases occurred 5 and 4 times respectively. The fixed offsets 2, 7, 28 and 399 taken mod 256 captured one held-out birth and zero arrivals. All available right-going characteristic intersections from those four diagonals to these marked births saw white. The final strict width record was already set at 34,429, leaving no strict records on which to test a late record law. The fitted phase failed to give a repeatable predictor. The results leave open a different observable that changes on the edge and reaches the centre by a specified route. Recommend parking the scout pending such a prediction. [Held-out test](timing.py)

## Replay receipts

The observations, counts, records, timing output and small oracle are archived at `share-scratch/gptIntel/phase2/K92.4/marks.zip`, SHA-256 `1f653e1de7b9f72bfe6b105a93d2201e6af2a4fea1cb5fc7c3ed66af2aaba6e0`.

Run the compiled probe with an existing output directory and arguments `4194304 512`. The record and count tables are TSV. The two binary arrays use four little-endian bytes per age. In the observation word, bit zero is the centre, bits 1–10 encode the physical gap plus one (zero at the singleton onset), and bits 11–14 hold D2, D7, D28 and D399. In the failure array `0xffffffff` is the sentinel whose classification is in `unresolved.tsv`.

| Artifact | SHA-256 |
|---|---|
| Source | `47f8130281dba75d824ef5f1eb193e60806476ddc14cbec3db68f10de8647281` |
| records.tsv | `2ad6ec2c87121b6546d3716c64074fd7dc916aeb75f31b743c2697387bf4d1f2` |
| counts.tsv | `66feb0dd4d85bb2777a2e04ba7007936e56d45d4fcb0841e291ff14e8117d2cc` |
| unresolved.tsv | `dbfd0f3ef31f34c78afd0472edf68a986b08cc533bd9965a79ee13774287ee0d` |
| observations.u32le | `a9989ed73021c2e7d945eca5a1eefa971cc573f8a25d5803facb8aac0897466f` |
| failures.u32le | `83a22a62939b90d54ffd3ee3905335477d47b505e7cc464a3d7c1dc05bb32f45` |
