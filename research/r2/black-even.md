# How far does a surviving twin go back?

**COMPUTED (R10–R11, gptM5 on the M5).** Write a row as an integer with its wall-adjacent cell at bit zero and a fixed white wall. Seed `0x19da5dcb` (width 29) reaches `0x6473c7a3f43df01e967` (width 75) at tick 46. Its wall-adjacent cell is black at every even tick including 0 and 46. This ending row has exactly one finite seed whose entire even-tick history is black.

A count at tick s means the number of distinct finite rows there that reach this ending row and satisfy the black condition from s to 46. The two rows at tick 44 have disjoint pasts because forward evolution is deterministic.

| Tick | Ancestors through the actual row at tick 44 | Ancestors through its twin |
|---:|---:|---:|
| 44 | 1 | 1 |
| 42 | 2 | 2 |
| 40 | 4 | 4 |
| 38 | 8 | 8 |
| 36 | 16 | 0 |
| 28 | 144 | 0 |
| 0 | 1 | 0 |

Two computations give the singleton. [The frozen forward census](guarded_branches.py) enumerates all passing seeds of width at most 30 and groups them by full ending row. The bit introduced at distance i first reaches the wall at tick i and toggles that tick, so prescribing the even ticks skips no candidate. Exact direct forward controls passed at (width, age) = (12, 8), (12, 18), (16, 32) for both trace patterns. [The backward replay](replay_guarded_witness.py) independently solves Wolfram's eight-entry truth table with both possible parent heads, checks the white exterior and retains black at each even tick. It replays the seed forward and exhausts the two backward trees separately. Every nonzero row gains exactly one cell of width per tick, so a width other than 29 cannot supply another seed for this endpoint.

## Matched control

The control turns one even tick white and leaves every other even tick black. Counts in the last three columns compare the numbers of seeds for the **same full ending row**, which fixes both the time and the seed width. An empty intersection leaves that comparison open.

| Age | White tick in control | All-black seeds / ends | Control seeds / ends | More all-black | Equal | Fewer all-black |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 16 | 8178 / 1809 | 7935 / 1769 | 76 | 30 | 50 |
| 46 | 22 | 37 / 11 | 46 / 11 | 0 | 0 | 0 |
| 48 | 24 | 4 / 1 | 11 / 3 | 0 | 0 | 0 |
| 54 | 26 | 0 / 0 | 4 / 1 | 0 | 0 | 0 |
| 60 | 30 | 0 / 0 | 0 / 0 | 0 | 0 | 0 |

All 11 all-black endpoints at age 46 and the one at 48 have four histories over the last four ticks, two per immediate black two-tick parent. Age 46 gives one endpoint with one seed, three with two, six with four and one with six. Both R10 predictions held. The empty cells at 54 and 60 concern only widths up to 30. After a white tick, the control can merge with a fully surviving history, as the 156 matched ends at age 32 show.

## A width bound at every depth

**PROOF-SKETCH, pending a carrying read.** Suppose a nonzero ending row with black head has all \(2^j\) finite histories allowed by requiring black every even tick over its last \(2j\) ticks, for \(j\ge1\). Every one of those histories must begin at **width at least \(2j+2\)**, and the ending row must have width at least \(4j+2\).

1. The first \(2j+1\) wall bits are in bijection with the first \(2j+1\) seed bits by the triangular rule above. Among rows of width at most \(2j+1\), exactly \(2^j\) pass the even checks from 0 through \(2j\), one per word of free odd-tick bits.
2. The kit's `Rule30FirstChecks.first_check_count` gives exactly \(2^j-\mathrm{ones}(j)\) passing rows of width at most \(2j\). Subtracting from step 1 leaves exactly \(\mathrm{ones}(j)\) of width **exactly** \(2j+1\). The kit's `Rule30FirstCheckDegree.check_degree` gives positive degree at every \(j\ge1\), so the Boolean check takes both values and \(0<\mathrm{ones}(j)<2^j\). At \(j=1\) the two passing seeds below 8 are 3 and 5, one on each side of the cut.
3. All finite ancestors at a given depth have the same width. Both parts in step 2 contain fewer than \(2^j\) starts, and different histories require different starts. This proves the stated necessary width. It also supplies surviving segments of length \(2j\) at every \(j\) for which full branching back to tick zero fails, since the first part is nonempty. These segments can start from different seeds.
4. For odd \(j\), the kit's `first_check_parity` makes the first part odd in size. Group its passing rows by endpoint. At least one endpoint has an odd number of surviving seeds, and its width already fixes every possible seed's width. Thus equal sharing of the original-width ancestors between two immediate branches fails at arbitrarily large ages. The odd count alone can exceed one.

R11 refutes a guaranteed second surviving seed at age 46. It leaves open a higher threshold for such a guarantee, a sharper lower bound at intermediate depths, and a bound that assumes the orbit stays black forever. M17's uniform four-tick theorem from age 80 is compatible with the result.
