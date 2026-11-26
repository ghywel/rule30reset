# I72 at the one-third corner

The remaining question is whether an ordinary Rule 30 history can have bounded $A(n)$ and $|3C(n)-n|$ at a bond while both columns of that bond are aperiodic. Here $C$ counts black readings at the western site and $A$ counts spatial $10$ at the bond. There is also the stronger S9-style question with the initial half from the observed site eastward prescribed.

**Status.** Parked. Two explicit finite right halves pass the finite test through gate period 4,096 from gate sample 4,096 onward. An all-period argument for either half, or a construction of a single infinite right half with that property, would reopen the pull. The prescribed-half version would additionally need to reach such a half after a finite control. S25 and S26 have their own release and PR records.

## Exact reduction and the observed periods

Bounded discrepancy is equivalent to an eventual $011$ two sites east. One direction follows from the boundedness of $D=n-3C+6A$, using Lowry's bounded-charge theorem. The other follows from the two west columns below. I73 previously gave the sharp quantitative defect comparison and the unbounded-error density variant. Bounds on densities alone allow infinitely many slips. [Lowry's kit theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/aaaefdd46c07c03aa2abd4d980a71dba746e686d/lean/Ruliology/CellularAutomata/Rule30OneThirdClock.lean) · [I73](quiet-corner.md)

Choose the time origin at a late $101$ block and the clock site at 0. Let $g_m$ be site 1 at tick $3m+1$. Rule 30 is left-permutive. The bit west of a site is its next bit XOR the OR of its current bit and its eastern neighbour. Apply this twice.

| Offset in block | Site 0 | Site −1 | Site −2 |
|---:|---:|---:|---:|
| 0 | 1 | 1 | $g_m$ |
| 1 | 0 | $1-g_m$ | $1-g_m$ |
| 2 | 1 | 0 | 0 |

Thus $A=0$ after onset and the aligned count satisfies $|3C(n)-n|\le2$. A finite prefix contributes only a constant. The periods of **each** observed column are exactly $3p$ for the eventual periods $p$ of $g$. A period prime to three would propagate the zero residue class through all three classes, contradicting the black cell in each triple. A period divisible by three restricts to a gate period. This verifies the aperiodicity equivalence in I73 and N25, and gives the exact scaling. The kit's realization theorem lifts each chosen driven half to an ordinary full-line history preserving that half. [Checked columns, bound and period scaling](Rule30QuietGate.lean) · [Realization](https://github.com/WolframInstitute/Rule30PrizeKit/blob/aaaefdd46c07c03aa2abd4d980a71dba746e686d/lean/Ruliology/CellularAutomata/Rule30Realization.lean)

The sliding count $3C_{[t,t+3)}-3$ at site $-2$ is zero at offsets 0 and 2 and is $3(g_{m+1}-g_m)$ at offset 1. That identity is checked in Lean. At a known phase, the count stream determines the gate once a nonzero difference is seen. If its differences have eventual period $p$, then $g_{m+p}-g_m$ is constant for all late $m$. Iterating $p$ and using boundedness shows the constant is zero. If all late differences vanish, the gate is eventually constant. In a finite-right example, I244 gives both colours arbitrarily late. Both signs of the three-tick count error therefore recur arbitrarily late. This gives an exact observable for a gate change and a local consequence of the existing nonconstant-gate theorem.

## Finite witnesses

The registered search tested four prescribed pairs per requirement. From the empty prefix it stalled on onset 1, period 3, after eight requirements and 527 frozen cells. This identified a weakness in choosing the observation pair. The second test examines the entire interval, looking for any differing pair at the candidate lag.

| Initial right half (bit 0 is site 1) | Gate onset tested | All periods rejected | Largest cone width used |
|---|---:|---:|---:|
| White | 128 | 1–128 | 788 |
| 64 aligned ether cells, then white | 128 | 1–128 | 791 |
| Same ether prefix and white tail | 512 | 1–512 | 3,098 |
| White | 4,096 | 1–4,096 | 24,590 |
| Same ether prefix and white tail | 4,096 | 1–4,096 | 24,605 |

The ether prefix is `0x7c87c87c87c87c87` in phase $101$. Both candidates already worked with a white completion at every stage. For each $p$ tested there is an $m$ at or after the tested onset with $g_{m+p}\ne g_m$. The last witness has a gate reading at physical tick 24,604. The independent C++ replay reconstructs a finite left cone, then evolves an ordinary row and checks the actual clock and every mismatch. Each row works throughout its own recorded horizon. A tested period could still settle later. [First test](quiet_gate_diagonal.py) · [Window test](quiet_gate_window.py) · [Ordinary full-line replay](quiet_gate_full_replay.cpp)

## An all-time criterion

There is a precise condition for getting an aperiodic gate inside **every** finite prefix of the imposed $101$ right-half space. For fixed $N,p>0$, the set of initial halves with $g_{m+p}=g_m$ at every $m\ge N$ is closed. Each failure is witnessed by finite light cones. If every prescribed cylinder has a completion with a failure for that $N,p$, the periodic set has empty interior. One can enumerate the pairs $(N,p)$, pick a concrete breaking completion at each step, and fix the two light cones in the next cylinder. The nested cylinders give one row with no eventual period. Conversely, a cylinder with a common eventual period bars this property. It can be restricted further by fixing the first $p$ gate bits after $N$, after which every row in it reads exactly the same periodic tail.

A finite trap for periodic gate labels would give a cylinder of this kind. The reverse direction needs proof. R5's absence of such traps through width 34 concerns a relaxation with fresh possible exterior bits at every step. Its physical forks through width 22 concern true initial rows but only bounded prefixes. The two longer examples here are fully physical, while the missing extension for arbitrarily wide cylinders and every $(N,p)$ is still the obstacle. An all-time proof for just one concrete right half would answer existence without the stronger cylinder argument. [I244 and the trap obstruction](../r5/periodic-gate-011.md) · [Hallee's finite-half survey](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/negative-results/columns/period-three-011.md)

The temporary control in the prescribed-half question can be made explicit. If the observation starts at site 0 and the full initial half at sites $j\ge0$ is prescribed, its site-2 clock can be assigned all readings from tick 3 by the kit's left-permutive realization at site 2. The fixed sites 0 and 1 impose precisely the clock values at ticks 1 and 2 once the site-2 initial value is fixed. Events from tick 3 onward are free in the prescribed clock, but the gate from then on is driven by whatever right half that finite prefix leaves. Showing that some choice enters an aperiodic case is an additional requirement. [Kit realization](https://github.com/WolframInstitute/Rule30PrizeKit/blob/aaaefdd46c07c03aa2abd4d980a71dba746e686d/lean/Ruliology/CellularAutomata/Rule30Realization.lean)
