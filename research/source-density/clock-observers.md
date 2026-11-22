# Which two-site readings detect the 001 clock?

Let the target be site j of any ordinary Rule 30 evolution. The observer sees the two cells at j−2 and j−1 in that order, once per tick, through a fixed recoding. The reference and actual histories can have different initial rows and different right tails. If the reference target reads a prescribed phase of 001 throughout the window, can the observer determine a bit of the actual target?

## Exactly two three-symbol answers

| Reading | What it records | Shortest window | Target offset from the first frame |
|---|---|---:|---:|
| 0121 | The nearest cell, plus the farther cell whenever the nearest is white | 29 frames | 23 |
| 0122 | The farther cell, plus the nearest cell whenever the farther is white | 34 frames | 23 |

The four digits give the output for 00, 01, 10 and 11, respectively. For each reading, 23 is the only working offset at the shortest horizon. The fastest reading needs 23 earlier frames and five later ones. Among **all** time-independent recodings, a finite decoder exists exactly when the recoding distinguishes four pairs: 00/01, 00/10, 00/11 and 01/10. This covers arbitrary output alphabets. In particular no binary reading works, even with an entire infinite common movie. Spatially periodic histories separate three of the four failed identifications. For the fourth, a width-12 ether and a history initially white strictly to the right of the drive have the same entire 101 drive and agree on its black-phase neighbor readings. The second target fails eventual period three.

This extends Condrey's source-observation question to a specific temporal class of the *unobserved* neighboring cell. Herbert's kit modules already distinguish 001 from 011 and constrain the neighboring languages. The new classification states exactly which static loss of information at the two left sites permits finite recognition. The proof combines their physical Rule 30 update, checked LRAT certificates, a finite-right consequence of ether erosion, and finite seeds at every shorter alignment. [Condrey's source observables](https://github.com/WolframInstitute/Rule30PrizeKit/pull/253) · [Kit period-three language](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30PeriodThreeLanguage.lean) · [Kit white-tail erosion](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30WhiteTailErosion.lean)

## Detecting departures without choosing a phase

On 31 frames use the first ternary reading. Try each of the three phases. At each of the three successive starts, allow a fresh width-13 reference strip for the 29 frames beginning there. A phase passes if all three strips exist with that phase advancing one tick per start. The observer rejects if all three phases fail. This only reads the two left cells. The finite-state implementation keeps at most 4,096 possible right prefixes for a given phase. [C++ implementation](clock-observer.cpp)

Call a target triple defective if it contains other than one black cell. For n consecutive observer starts, the number of defective triples at offset 23 is at most the number of rejections. In the other direction, rejections are at most **29 times** the number of defective triples whose starts are in the combined n+28 positions. Three overlapping successful reads recover the three bits of an intact triple. A rejection needs at least one defective triple somewhere in the underlying 31 frames, and each such triple belongs to at most 29 windows.

Thus eventual acceptance is equivalent to an eventual 001 target, with no need to choose any global phase in advance. Vanishing rejection density is equivalent to vanishing defect density. These claims hold on the actual singleton. In a comparison of imperfect histories, every wrong actual bit at offset 23 can also be charged to one of 29 input ticks on which the reference clock is wrong or the ternary observations differ.

**The factor 29 is attained on a finite seed.** Number the initial bits from zero and use seed 244070477827444462062923 with target 79. Among 80 target readings the only defective triple starts at 39. All 29 windows containing that triple reject. A direct scalar Rule 30 replay, exhaustive strip propagation, and independent SAT decisions agree. For 86 of the 87 rejected window/phase combinations, one white-neighbor update contradicts the candidate. The remaining combination fails on a strip with only four right cells. [Standalone finite-seed check](sharp-clock-slip.py)

For a finite check on the actual trajectory, all 1,048,546 available 31-frame windows reject in the first 1,048,576 centre readings. The centre has 656,463 defective triples in the same data. Eventual exclusion at the centre remains open. The finite sample and the phase-free theorem have different quantifiers.

## Finite-right boundary

For a drive repeating 101 from time S with the initial right tail white beyond W, the first right neighbor eventually reads 0 and 1 at the two black phases of each block. This starts by age 4S+3W+19. Neither the first nor the second neighbor can be eventually three-periodic. A width-303 positive support can nevertheless follow the candidate sampled word 110 for 242 white phases, first disagreeing at tick 727. If that sampled word persists forever, its forced left recurrence prevents any two pairs of adjacent right columns from having identical tails. Whether any finite-right realization keeps it forever remains open.

The full source closure, local reader, independent finite seeds, CNFs and checker receipts are in I75/clock-observers.zip. The 29- and 34-frame physical recognizers and the lower witnesses have separate kernel replays. The corresponding ledger post gives the hashes.

[I76 proves that factor 29 is attained indefinitely and gives the corresponding two-black observer bounds.](effective-boundary.md)
