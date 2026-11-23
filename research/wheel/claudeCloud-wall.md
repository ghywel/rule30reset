# The period-2 wall from the right: what survives outside the gate trap when the strip is widened

claudeCloud, ledger K79 and its addenda (23 November 2026). Statuses as in METHOD §5. This note is the work
block the owner asked for before the period-2 line is salvaged or parked. It continues gptIntel's I170 to I181
and my K75 to K78.

**In one paragraph.** A right half beside the alternating column either enters the kit's gate trap, or has a
periodic gate, or stays for ever in one of two window components, X and Y, making excursions for ever (RD's open
case; R65, R69, K52, K78). This block asks how much of X and Y is real once the window is as wide as one likes.
Four exact things came out. (1) Beside an alternating column there are exactly four patterns periodic in time
and space with time period up to 24 ticks, one for each pure loop. (2) Every periodic train of excursions that
I followed dies at a finite width, except one train of Y that is still alive at 200 columns. (3) On the whole
light cone, right halves of unbounded support can still make many excursions of Y and stay on Y's schedule for
at least 200 samples, so no argument that holds for every right half closes Y at these lengths. (4) On real
rows the count of completed excursions falls by a fixed factor per excursion, about 0.1 in Y and below 0.01 in
X, and finite seeds give the same numbers as random far fields. So RD's open half asks the bulk of one finite
seed to beat fixed odds for ever. That is the wall, and it is the same kind of statement as the prize itself.

## Words

The wall is column 0, alternating. A *sample* is a tick at which it is white. The *gate* is column 1 at the
samples; a *kick* is a black gate sample; a *gap* is the number of samples from one kick to the next. A *strip*
of W columns is columns 1 to W with column W + 1 free at every tick, so it reads at least what a real right
half reads on its first W columns. The *whole cone* of N samples is every cell that can reach the gate in that
time; an answer on it holds for every right half of every support.

- **X**: the loop A = 25 and the excursion E = 33535555. A *spacing* is the number of loops between excursions.
- **Y**: the loop 2 and the excursions S = 45 and L = 4525.
- A *train* is a gap word repeated for ever, such as E A⁷ or S 2¹⁶. It is *alive at W* if a closed walk of the
  W-column window graph spells it, and *dead at W* if no W-column strip spells N copies of it for some N.

## 1. The four rings (COMPUTED, complete to 24 ticks)

Rule 30 is new = left xor (centre or right), so two neighbouring columns determine the column on their left.
If every column of a right half has one time period N, the pairs of neighbouring columns form an endless
backward orbit of a map on a finite set, and such an orbit lies on a cycle. So **a right half that is periodic
in time in every column is periodic in space, and the wall is one of its own columns** (PROOF-SKETCH; Jen's
sideways argument run to the right). The patterns of time period N beside an alternating column are then
exactly the columns b for which the pair (alternating, b) returns to itself, and all 2^N can be tried.

| Gate, in gaps | Columns × ticks | Its right half | In the record as |
|---|---|---|---|
| 2 repeated | 7 × 4 | outside the trap: Y's loop | the kit's ether |
| 3 repeated | 84 × 6 | outside | the 84-ring (October; I160) |
| 5 repeated | 155 × 10 | inside the trap at every sample | the all-5 cycle (M15, M20) |
| 2, 5 repeated | 728 × 14 | outside: X's loop | Lowry's 728-cell ring (kit) |

These four, with their time shifts and multiples, are **all** of them for N = 2, 4, …, 24 (22.4 million columns
tried). Each was known singly. New here: the list is complete to 24 ticks, and so *a right half all of whose
columns share a time period of at most 24 ticks is one of the four*. A train with an excursion has a period of
at least 50 ticks, beyond this census; sections 2 to 4 answer for those.
[List](data/claudeCloud-alt-periodic.txt) · [each rebuilt on its torus](data/claudeCloud-alt-rings.txt) ·
[program](claudeCloud_alt_periodic.cpp) · [checker](claudeCloud_alt_rings.py)

## 2. Trains die when the strip is widened (COMPUTED)

| Train | Last width with a closed walk | First width refused | Note |
|---|---|---|---|
| X, spacing 6 | 42 | 43 | R69's figure |
| X, the pair (4,7) | 42 | 43 | placego's (P20) |
| X, the pair (4,12) | 46 | 47 | placego's |
| X, spacing 7 | 63 | 64 | placego has 63 under tighter edges, reproduced here (62 alive, 63 dead) |
| X, spacing 8 | 60 | 100 | four copies are still spelled at 70 |
| X, spacing 9 | 90 | SPACING9 | SPACING9NOTE |
| Y, S 2ⁿ for n = 8, 9, 10, 11, 12, 13, 14 | 34, 33, 41, 26, 48, 27, 29 | 35, 34, 42, 27, 49, 28, 30 | |
| Y, S 2ⁿ for n = 18, 21, 22 | 33, 26, 33 | 34, 27, 34 | |
| Y, L 2³ and S 2³ L 2³ | 33, 31 | 34, 32 | |
| Y, S 2¹⁷ | 57 (two copies) | 200 | eight copies are spelled at 59 |
| **Y, S 2¹⁶** | 70 | **not seen** | eight copies are spelled at 200 columns |

My strips leave column W + 1 free at every tick; R65, R69 and placego fix it one tick after a sample by the
rule. A death width read here can therefore be one column larger than theirs, as for spacing 7.
[Controls](data/claudeCloud-trains-controls.jsonl) · [X](data/claudeCloud-trains-x.jsonl) ·
[Y](data/claudeCloud-trains-y.jsonl) · [script](claudeCloud_wheel_trains.py) ·
[tighter edges](claudeCloud_wheel_trains_initial.py)

## 3. What every right half can and cannot do (COMPUTED on the whole cone)

- **Fixed spacings in X.** Two excursions six loops apart are read (replayed). **Three are read by no right
  half**, with or without a gap of 2 after them. At spacing 7 three are read. So the 43-column grammar, which
  lets a window path repeat a spacing for ever, overstates what a right half can do, and by how much depends on
  the spacing.
- **The budget of Y.** Some right half reads five excursions of Y within 150 samples, and some reads seven.
- **The longest stay in Y.** In Y's variable part the gate is a word of (2 | 45 | 4525)* in which a gap of 4
  returns within 57 samples. Both are closed conditions, so if the cone refused a stay of N samples no right
  half of any support could stay that long, and RD's Y half would be one finite computation. It does not
  refuse: a stay of 200 samples is read, with seven excursions on schedule. STAY300
- **S 2¹⁶ on the cone.** Four copies are read by a right half. S16CONE
- XSTAY

[Fixed spacings](data/claudeCloud-trains-cone.jsonl) · [budget](data/claudeCloud-budget-y.jsonl) ·
[stay](data/claudeCloud-stay-y-200.json) · [budget script](claudeCloud_wheel_budget.py) ·
[stay script](claudeCloud_wheel_stay.py)

## 4. What real rows do (MEASURED)

Each half is followed exactly until it enters the trap (3,000 ticks at most), and its completed excursions are
counted: for X the gaps 25 33535555 25, for Y a gap of 4 whose excursion has two 2s on each side.

HAZARDTABLE

The share entering the trap is 0.9673 in every column, K52's figure for every seed of support 22 to 26. In Y
the number of halves with at least k excursions falls by about 0.1 for each further excursion. In X one half
in about 4,000 completes one excursion and HAZARDX. Finite seeds and random far fields agree in every count.
[Program](claudeCloud_exterior_hazard.cpp) · [counts](data/claudeCloud-hazard.txt)

## 5. The picture

On the slow seeds of K52's census the loop 25 is carried by the first ten columns; from column 11 on the row is
the ordinary disorder of Rule 30. The closed walk of the spacing-7 train at 63 columns looks the same: ten
regular columns through each stretch of loops, and an irregular strip beside them that repeats only because
the solver made it. So a stay in X or in Y is a narrow strip at the wall that the bulk beside it knocks. Most
knocks send it into the trap; about one in ten (Y) or fewer than one in a hundred (X) are excursions that
return. The three periodic exteriors that close themselves off, the ether behind its wall, the seven-phase
lock and the rings, are the cases where the bulk can no longer reach the strip.

## 6. What this says about the wall

1. **No statement about every right half closes Y at the lengths reached.** Y's schedule can be kept for at
   least 200 samples and S 2¹⁶ is alive at 200 columns. A refusal at a greater length would close Y for every
   support; that is the one cheap test left, and it needs a stronger solver than mine.
2. **Finite support is invisible in every count taken.** Seeds of support 24 and 40 and random far fields give
   the same shares, the same factors and the same tails.
3. **So RD's open half is a statement about the bulk of one finite seed**: that it fails, at some excursion, a
   test that a random bulk fails nine times in ten. Nothing in the window graphs, the strips or the cone speaks
   about that. It is a statement of the same kind as the prize problems, and it is the wall already met on the
   main line.

**What would reopen it.** A whole-cone refusal of a Y stay at some length; the death of S 2¹⁶ together with a
bound on Y's budget; or any handle on the bulk of a finite seed (the parked (DL⁻₁) is one such).

## Reproducing

```sh
kit=Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean
g++ -O3 -std=c++17 research/wheel/claudeCloud_alt_periodic.cpp -o alt_periodic
for n in 2 4 6 8 10 12 14 16 18 20 22 24; do ./alt_periodic $n; done > census.txt
python3 research/wheel/claudeCloud_alt_rings.py $kit census.txt
python3 research/wheel/claudeCloud_wheel_trains.py $kit death E.A*6 40 46
python3 research/wheel/claudeCloud_wheel_trains.py $kit finite S.2*16 200 8
python3 research/wheel/claudeCloud_wheel_observers.py $kit sat 20000000 3353555525252525252533535555252525252525 33535555
python3 research/wheel/claudeCloud_wheel_budget.py $kit y 150 7
python3 research/wheel/claudeCloud_wheel_stay.py $kit ystay 200
g++ -O3 -fopenmp -std=c++17 research/wheel/claudeCloud_exterior_hazard.cpp -o hazard
./hazard $kit random 2000000 3000 && ./hazard $kit seed 40 2000000 3000
```

The census of period 24 takes about half an hour on one core; the stay of 200 samples seven minutes; the
eight copies of S 2¹⁶ at 200 columns half an hour. SAT answers are replayed cell by cell; UNSAT answers are
COMPUTED only (python-sat, CaDiCaL 1.9.5), with the CNF digests in the logs.
