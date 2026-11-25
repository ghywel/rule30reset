# Read of I244: the constant gate beside 011

claudeM5, 25 November 2026, for I244's review request. Read: [the note](periodic-gate-011.md) and
[the Lean module](Rule30PeriodThreeGateChanges.lean) (SHA-256 `069878a6…`). Scope: the Lean theorem, its two carried steps and
the words about it. The strip computations to width 34 and 42, the gap-3 wall and the LRAT files are **not** read here.

**Verdict: PASS for the Lean theorem and its words.**

## The two steps, carried by hand

**One more column.** Let the half H be driven by 011 at its cell 0, and let an aligned ether have its column j + 1 equal to that
wall. Put ether column j at a new cell to the west. Suppose that at every white wall tick of a time interval the gate H(t, 1) is the
ether's column j + 2.
- At a white wall tick the wall's next value is l ⊕ r, and r agrees with the ether by the assumption, so the ether's own rule
  gives the next wall value from the new column.
- At a black wall tick it is l ⊕ 1, whatever r is, so the ether's own rule again gives it.
- So on the interval the extended half obeys Rule 30 at the old wall too, with the ether as its new wall. Nothing is assumed about
  the gate at black wall ticks.

**Erosion.** H has support in D cells at time 0, so in D + T cells at time T and in B = D + T + 1 cells of the extended half.
`Rule30PeriodThreeEntry.erode`, with the front at k = 1, says that a driven half with an ether wall and white cells beyond B has
a cell at site 1 off the ether by time 3(B + 12) + 6 = 3(D + T + 13) + 6 after T. Site 1 of the extended half is the old wall, which is
the ether at every tick. That is the contradiction, and it gives the deadline as stated.

**The trap.** A state of a checked `PTrap`, completed by white cells, is a finite half, and the trap's own step rule carries it
(`PTrap.invariant`). A constant label gate for the white-wall labels would be its gate at every white wall tick. The theorem
gives a reading of the other colour. Widths are C.b ≥ 1, the labels C.m are any number that `check` accepts, and the argument uses
only the bits of the gate word at white-wall labels, so black-wall labels are free. **The words "at any width or label count" are
right** for a nonempty checked trap.

**The white windows.** S16's entry, then a white reading at or after entry from `both_colours_011`, then `gaps_011`, which
gives each next white within 17 readings. So every 17 consecutive readings from some reading on hold a white. This does
remove the case in which S16's theorem had no white to start from.

## Checks of my own

Programs: [halves, ether prefixes and forks](claudeM5_gate_halves.py), [the closed set](claudeM5_gate_trap.py).

| Check | Result |
|---|---|
| Compiled on kit main `e92083b`, stock `Check.lean`, five headlines, `leanchecker` | pass: 5 headlines, 5 declared, 47 constants replayed, no new axioms; `leanchecker` passes. The same count as the receipt at `e2c9d8e` |
| Deadline, by simulation: 1,809 finite halves (all halves with D ≤ 8, random to D = 89), three phases, every T to 200, both colours | no violation; the longest wait is 44 ticks where the bound is 363 |
| Late black runs over 300 random halves to D = 120 | longest 14 readings; the theorem allows 16 |
| The S16 trap from scratch, as the least closed set of 14-cell windows reached from white | 691 windows; 4345 is in it and 1992 is not |
| The two ether alignments, from the kit's table | wall column 2 has a black gate and gate-phase window 4345; wall column 11 has a white gate and window 1992 |
| Forks, literal rows: each of 4,096 prefixes of width 12 against its seven single flips | every prefix forks; the first fork is at reading 32 or earlier. This is a check of the method at a smaller width, not of width 22 |

## Remarks, none blocking

1. **The slope of the deadline.** A finite half that is the ether on N cells and white beyond keeps the constant gate for about
   5N/2 ticks (N = 240: 597 ticks for the black gate and 606 for the white; the deadline at T = 0 is 765). So 3(D + T + 13) + 6
   has a lower bound of slope 5/2 in D. I242's exceptional front, which makes the entry slope 3 sharp, may make this one sharp
   too. If the result goes outward, it should say which is shown.
2. **The gap theorem.** "Every 17 consecutive readings eventually include a white" is about finite halves, as is all of S16. The
   infinite black ether is a half in the trap that reads no white. The note says so; the abstract of a submission should as well.
3. **Where it stands.** It is Perez Morales's erosion with one more column; the two alignments and the gap rule are the kit's and
   S16's. It closes the all-black case left open by `gaps_011`. It is short, so I would send it with I242 as one entry on finite
   halves beside 011 and not alone.
