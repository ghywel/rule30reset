# K92.4 · What an edge predictor is, what it decides, and what it still needs

claudeM5, 27 November 2026 (M220), at the owner's word: "See if you can make progress on this edge predictor, or
process the parking with a clear description of what this 'edge predictor' requires."

**Verdict.** The edge clock has a real and exact role, and it is half of a predictor.
- **It decides the colour of an arrival.** A gap of width l is marked or not according to one left diagonal of the
  seed, read from a short prefix of the cells east of the centre: 9 cells for every width up to 28.
- **It says nothing about when a gap opens.** No clock of the edge produces a white gap beside the centre. That half
  is W2's missing statement itself.

K92.4 is parked at W2 with that as its requirement (§5).

## 1. The setting

- A *gap* at age s has l white cells at sites −l..−1 and a black cell at −l−1. It is a *mark* when the centre is
  black at age s + l. Marks of unbounded width give Problem 1 (`problem1_of_marks`, Lowry).
- The centre at age s + l depends only on the row at age s on [−l, l]. The west half of that window is white. So the
  arrival is a function of the *context*: the l + 1 cells at sites 0..l.
- `D j t = cell t (j − t)` is the seed's left diagonal j. The first J diagonals evolve on their own:
  `D j (t+1) = D (j−2) t XOR (D (j−1) t OR D j t)`. The *edge word of age k* is `(D 0 k, D 1 k, …)`.
- The kit proves that the eventual period of D j divides 2^(number of eventually white diagonals up to j)
  (`Rule30LeftReset`), and that the seed's white diagonals through 87,866 are 2, 7, 28, 399, 53207, 58286 and 87866
  (`Rule30SeedLeftSide`). So the clock is 4 through depth 28, 8 through 399 and 16 through 53,206.

## 2. The settled wedge never reaches the centre (COMPUTED)

[claudeM5_edge_settle.py](claudeM5_edge_settle.py), to depth 8,192. F(j) is the first tick from which D j has its
final period.
- **Controls.** The eventually white diagonals found are 2, 7, 28 and 399, and the period first reaches 2, 4, 8 and
  16 at diagonals 3, 8, 29 and 400, as the kit proves.
- **F(j) lies between 1.267 j and 1.340 j** for 1000 ≤ j < 8192. The settled wedge is the sites x ≤ −0.25 t, and its
  boundary moves away from the centre.
- **F(j) > j for every j from 20 to 8,191** (and F(j) ≤ j only for j ≤ 17 and j = 19). The centre at age t is D t t,
  so from age 20 it is read before its own diagonal has settled.

So the seed's own edge clock cannot be read at the centre. This is why the ages of the records show no clock
(gptIntel's held-out test, [seed-results.md](seed-results.md)).

## 3. Where the clock does act: the arrival (PROOF-SKETCH, with exact controls)

**The criterion.** Let the gap at age s have width l, and let the first r cells of its context be the first r cells
of the edge word of age k. If r is at least the forcing length rmin(l, k), then the centre at age s + l is
`D l (k + l)`, whatever the other l + 1 − r cells are. When k + l ≥ F(l), that value is a function of l and k mod 16.

**Why.**
- With r = l + 1 it is the kit's `arrival_eq_diagonal` (Lowry), read at the gap's own age instead of k ticks
  earlier: the window [−l, l] agrees with the evolution of a single black cell, so the centre l ticks later is that
  cell's left diagonal.
- A shorter prefix is enough because of the kit's reset rule. When diagonal j is black at a tick, diagonal j + 1 one
  tick later is `NOT D (j−1)`, whatever it was. So unknown cells deeper than the prefix are erased one diagonal at a
  time (`Rule30LeftReset`, and our `Rule30HealingBound` and `Rule30ErrorEdge`).
- A white diagonal stops the erasing: past it, the next diagonal keeps its starting value for ever. That is where
  the clock doubles. So the prefix must reach two cells past the last doubling white diagonal: 9 cells past D 7,
  30 past D 28, 401 past D 399.

**Computed, exact.** [claudeM5_forcing_prefix.py](claudeM5_forcing_prefix.py) finds rmin(l, k) by truth tables over
the free cells, for every width l ≤ 26 and every age k up to 16 past settling
([table](data/claudeM5-force-26.json)).
- For the settled ages, rmin is at most 10 at every width to 26: exactly 9 at widths 8, 10, 14, 15, 18 and 19, and
  as low as 2 to 5 at widths 7, 9, 11, 12, 13 and 17. (At width 26 the search starts at nine known cells, so its 9 is
  an upper bound.)
- The first transient ages need more: up to 17 cells for k ≤ 2 from width 18.
- In every forced case the forced value is `D l (k + l)`.

**Computed, an upper bound at large widths.** [claudeM5_forcing_front.py](claudeM5_forcing_front.py) treats each
free cell as "unknown". This is the healing front of `Rule30HealingBound`. It never underestimates: it equals the
exact value in 410 of the 744 cases to width 26 and is larger in 334 ([output](data/claudeM5-front.txt)).

| Width l | 8 to 28 | 29 to 48 | 64 | 128 | 256 | 399 | 400 to 512 | 1024 | 2048 | 4096 |
|---|---|---|---|---|---|---|---|---|---|---|
| Prefix cells that suffice | 9 to 12 | 30 | 40 | 68 | 118 | 207 | 401 | 528 | 1005 | 2038 |

So about half the width always suffices, and the jumps to 30 and 401 sit just past the white diagonals 28 and 399.
The kit's `indistinguishable_launches` already shows that no fixed window decides arrivals at every width.

## 4. The seed, to age 2²² (COMPUTED)

[claudeM5_seed_windows.c](claudeM5_seed_windows.c) runs the seed and keeps 64 cells each side of the centre.
[claudeM5_clock_regime.py](claudeM5_clock_regime.py) and [claudeM5_forced_census.py](claudeM5_forced_census.py)
class every age ([edge words](data/claudeM5-clock-22.json), [forced](data/claudeM5-forced-22.json)).
- **gptIntel's counts reproduce**, from separate code: 2,326,009 marked ages of 4,194,304; the widest mark is 22, at
  ages 34,429 and 2,125,919; the widest gap is 25, at age 2,085,567; 114 marks have width at least 14.
- **The criterion never fails.** At all 2,088,127 ages where an edge prefix forces the arrival, the centre seen is
  the forced value. They hold 1,748,594 of the marks.
- **How often the clock decides, by width:**

| Width | 0 to 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 to 25 |
|---|---|---|---|---|---|---|---|---|---|---|
| Gaps | 4,161,620 | 16,427 | 8,118 | 4,141 | 2,028 | 988 | 494 | 264 | 111 | 113 |
| Forced by an edge prefix | half | 31% | 1.2% | 26% | 0.9% | 4.2% | 12% | 9.1% | 1.8% | none |

- At widths 0 to 6 a black centre alone, or with one to three more cells, forces the arrival.
- At widths 8 to 14 the share is 8.2% overall (1,317 of 16,144). There are only six edge words of nine cells, four
  of them settled.
- **Of the 114 marks of width at least 14, one is clock-decided**: width 14 at age 3,714,525, with a nine-cell prefix
  of an edge word. Neither width-22 record is. The widest mark whose whole context is an edge word has
  width 13 (age 2,146,822).
- Whole edge words thin out by a factor of three to four for each unit of width, against two for all gaps.

## 5. What an edge predictor requires

A mark of width l has two halves.

1. **The arrival: available.** Given the gap, a prefix of the context that is an edge prefix decides the colour by
   the clock. The kit proves that infinitely many diagonals are eventually black, and infinitely many alternate
   (`unbounded_black`, `unbounded_both`), so black arrivals exist at unbounded widths.
2. **The launch: missing.** For every bound B, an age s and a width l > B at which the seed's row reads, from site
   −l−1 eastward: one black cell, l white cells, then a forcing prefix of an edge word whose arrival is black. That
   is l + 1 + r prescribed cells, with r = 9 to width 28, 30 to width 399, 401 to width 53,206 and at most about
   l/2 in general.

A predictor would have to supply the launch. It needs all three of these:
- **A source of white gaps beside the centre.** Even without the prefix and the arrival, arbitrarily wide white gaps
  west of the centre are open (they are the hypothesis of `accepting_phase_of_late_gaps`). Nothing at the edge makes
  them: the settled wedge ends at x ≈ −t/4 and recedes.
- **A route.** A named carrier that crosses from depth 3t/4 to depth t: the diagonals between are read before they
  settle. A function of the age modulo a power of two is not enough, since the clock that decides the arrival is the
  context's, k, and the age s does not determine k.
- **A test it can fail.** Launches named in advance, on held-out ages, against the base rate: a gap of width l
  appears at about 2⁻⁽ˡ⁺¹⁾ of ages, and at widths 8 to 14 between 1% and 26% of gaps carry a forcing prefix.

What it would give: Problem 1, through `problem1_of_marks`. With the criterion, the hypothesis is about single rows
of the seed and no longer about a centre l ticks later.

**Reopen K92.4 with** any of:
- a mechanism, or a proof, that white gaps of unbounded width open beside the centre;
- a law for the arrival when the context is not an edge prefix, which is 92% of gaps at widths 8 to 14: that is the
  context's own left diagonal l, read at tick l before it settles;
- a reason for the seed's edge to be read at the centre: F(j) ≤ j at unbounded j, against F(j) ≈ 1.3 j computed.

## 6. Predictions and method

- **Registered before the runs** ([predictions](claudeM5-predictions.txt), commit `f077a20`). I left out the
  counterfactual and the `Record searched` line that METHOD §4 asks for; the record searched is below.
  - P1 (90%), F(j)/j between 1.5 and 3 and F(j) > j from j = 8: **wrong** on both numbers. The slope is 1.27 to
    1.34, and F(j) > j only from j = 20. Right that the growth is linear and the centre lies outside the wedge.
  - P2 (85%), no mark of width ≥ 14 with a settled edge word, the widest at most 12: the first part **right**, the
    second **wrong** (13).
  - P3 (95%), the theorem control: **right**, no mismatch.
  - P4 (80%), gptIntel's counts: **right**, all three.
  - P5 (70%), edge-word contexts fall about fourfold per unit of width: **right** (three- to fourfold).
- **Not registered.** The forcing prefix came from a surprise in the first run (a nine-cell agreement at the width-22
  record). Its runs are development, with exact controls: the forced value is always the diagonal, and the census
  has no mismatch.
- **Not checked.** The criterion for a short prefix is a hand argument plus exact tables to width 26; it has no
  second reader and no Lean. Beyond width 26 only the upper bound is computed.

Felt: surprise, short prefixes forcing arrivals, strong; first guess: white diagonals act as walls. -> the exact
table, then the front. Outcome: right. Two verdicts. Reasoned: the clock decides arrivals and not launches
(PROOF-SKETCH and COMPUTED); the launch is W2's statement, so park. Gut: the same; the criterion is the useful
residue.

My own pull: a general forcing-prefix theorem in Lean, extending `arrival_eq_diagonal` from a whole white window to
a gap and a short prefix, for every width. It would be a kit lemma and it removes the centre's future from Lowry's
criterion. It does not cross W2.

Record searched: KIT.md and KIT-INDEX.md (left diagonals, marked gaps, arrival, launch, healing, forcing prefix,
echo, restart); PRIOR-ART.md and its archive (edge clock, healing, forcing prefix); the ledger and archives (K92,
I281 to I285); the kit sources `Rule30MarkedGaps` and `Rule30GapBirthArrival`; WALLS W2.

**Receipts.** The windows file (67,109,904 bytes) has SHA-256 `f5678e60…e6e7dd`; it regenerates in about two
minutes. Sources: `claudeM5_seed_windows.c` `d9c1c2d0…`, `claudeM5_edge_settle.py` `a10b71b9…`,
`claudeM5_clock_regime.py` `08502623…`, `claudeM5_forcing_prefix.py` `3366a845…`, `claudeM5_forcing_front.py`
`f9b1f1d0…`, `claudeM5_forced_census.py` `ba859214…`.
