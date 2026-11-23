# How long the pure-three exterior can match a finite left edge

A black sample every third white tick is the surviving exterior gate in K77. Its full-line reference is the rotating 84-cell ring, with temporal period six. The gate alone does not force its right half to repeat. It does determine how many cells to the **left** must still agree with the ring if the centre is to keep alternating. [K77](claudeCloud-tails.md) · [Kernel proof](WheelPureThreeDeadline.lean).

## The sharp duration for a prescribed left edge

Start at any of the six temporal phases of the ring. Let the actual leftmost black cell be at site −W, with W positive, and allow any initial right half. Read the centre through tick n inclusive. At the white centre ticks strictly before n also read site +1. This is exactly the information in a clock and pure-three gate needed for n updates.

The first compulsory mismatch in the **initial** left half gives an exact deadline d.

* If the reference at −W is white, take d = W. The real edge must be black there.
* If the reference at −W is black, take d to be the next deeper black reference cell. The real row must be white there.

No row with that left edge can match the observations through d. Some row, finite on both sides, matches through d−1. To attain the horizon, copy the ring wherever the light cone requires it, place a black cell at −W, and set cells to its west and beyond site +d to white. This construction also proves a general sharpness theorem for any reference evolution and any first forced mismatch. The exact correction d−W for this ring is as follows. Each temporal alignment is a spatial shift and has the same counts.

| Extra ticks d−W | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---:|---:|---:|---:|---:|---:|---:|
| Residues of W out of 84 | 41 | 22 | 10 | 5 | 4 | 1 | 1 |

In black-first phase zero with W = 71, one finite row matches through tick 76 and every row fails by 77. For the **actual singleton** at age A, its edge is at −A. Therefore the centre or the required white-time gate differs by absolute tick **2A+6** at the latest. The finite witnesses establish sharpness over all rows with the prescribed left edge. Sharpness for singleton ages remains open.

## Which side decides the last reading

Writing c for a column, the observation channel is its value together with the OR of c and its eastern neighbour. The rule reconstructs the western neighbour from the next c and this OR. Matching n centre updates and their OR inputs forces the whole triangle to the west through depth n at the starting time. This is the two-configuration form of the kit’s finite masked-Jen determination lemma.

Suppose the past matches through d−1, and the actual initial bit at depth d differs from the reference. That discrepancy advances one column east at each update inside the matched triangle. At tick d−1 it reaches the western neighbour. Rule 30 then gives the following exact alternatives.

* If the centre at d−1 is white, the centre at d stays on the old clock **exactly when the eastern bit at d−1 departs from its ring value**.
* If the centre at d−1 is black, its OR input is already black in both rows. The clock breaks at d for every eastern bit.

This fork applies to **any** initial spatial discrepancy, including one closer than the forced edge discrepancy. In particular, if some earlier coupling argument keeps the centre alternating, the left bit and its matched history can prescribe an unscheduled gate reading from across the centre. That extra clock hypothesis matters. This is a finite compatibility law for a pure-three stretch on the exterior; it does not label a change of the 17/56 phase inside the trap.

## Finite right halves and credit

An endlessly pure-three **driven right half** could be joined to the matching 84-periodic left row. Use the rotating ring on nonpositive sites and the driven trajectory on positive sites. All positive cells satisfy the rule by construction and the negative cells follow the ring. At the centre a black cell masks its east neighbour, while at a white cell the pure-three hypothesis supplies the needed east reading. Thus the joined film obeys Rule 30 everywhere. Conversely, keeping the centre and masked gate for arbitrarily many updates forces every initial western cell of the joined row to equal the reference. The reference has no constant temporal column. Its straightforward finite truncations give every finite observation, while the existence of a single finite right start that gives the gate forever remains open. The kit’s ether-wall witness for finite right support has a four-periodic eastern column. That witness has another gate. RD itself allows either a periodic sampled gate or entry into the trap.

The project already identified the ring and its arbitrary finite truncations. Jen and the kit’s finite masked-Jen theorem supply backward determination. The kit’s exact-death theorem uses the first difference from the coupled left row to determine when an alternating centre fails. Lowry’s seven-lock comparison and the kit’s prefix-certificate module also exploit the moving singleton edge. Here the two configurations may have independent right halves, and either the clock or its sampled gate may break. The sharp edge horizon, its finite two-sided witnesses, and the last-tick choice are the additions. For comparison, applying the kit’s same-trajectory window theorem to times A and A+6 gives a contradiction by 2A+12 for such an observation. The 84-ring comparison gives the residue-dependent d above. [Finite masked Jen](https://github.com/WolframInstitute/Rule30PrizeKit/blob/f41bb494d64f120e0e6f07ab68d799a6018396cc/lean/Ruliology/CellularAutomata/Rule30FiniteMaskedJen.lean) · [Exact death for period two](https://github.com/WolframInstitute/Rule30PrizeKit/blob/f41bb494d64f120e0e6f07ab68d799a6018396cc/lean/Ruliology/CellularAutomata/Rule30PeriodTwoSideways.lean) · [S12 and Lowry](../k50_1/path4/README.md) · [Ether-wall witness](https://github.com/WolframInstitute/Rule30PrizeKit/blob/f41bb494d64f120e0e6f07ab68d799a6018396cc/lean/Ruliology/CellularAutomata/Rule30EtherWallWitness.lean).

The Lean module imports the official kit at `f41bb49`. The stock checker replays nine headlines covering the sideways triangle, final fork, general sharpness, ring evolution and signals, first edge discrepancy, sharp ring bound and finite witness, and the singleton deadline. [Machine receipt](data/pure-three-deadline-stock.json).
