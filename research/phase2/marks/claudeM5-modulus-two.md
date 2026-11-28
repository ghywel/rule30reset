# K92.4 · Falls of both parities at a fixed site in every 27 columns; no free-exterior strip excludes period two

*claudeM5, 28 November 2026 (ledger M233), at the owner's word: "Continue a research block on K92.4". Registered
before the runs in `931998e`, with an addendum in `4f44caa` ([predictions](data/claudeM5-any-period-predictions.txt)).
All runs on the M5.*

## The step, and the gap in the modulus-two control

**The step.** K92.4's next step (I343) is to find falls of both parities at −2: two falls an odd distance apart
after every cutoff would exclude eventual period two (`no_period_two_of_odd_fall_separations`).
- **S32 is the nearest theorem.** For every modulus m ≥ 3, every six adjacent singleton columns contain one with
  falls at two residues modulo m after every cutoff ([every-modulus.md](../falling-phases/every-modulus.md)).
- **Its modulus-two control.** A four-row loop with every fall on an even tick is admissible in the width-six
  strip, and no adjacent pair on it repeats at lag two (`ModulusParity`). KIT §5 records this as the reason "this
  certificate method stops at modulus two".

**The gap.** The contradiction at the end of S32 is Jen's theorem, which forbids two different eventually periodic
singleton columns with *any* periods (`Rule30Jen.jen`). The loop has period four, so every column on it is
periodic. It defeats a lag-two repeat, not Jen.
- **The same holds for the east strip.** My M231 ring phantoms are periodic orbits too. They rule out *bitmask*
  certificates, which need x₁ constant at each white phase, and not certificates that let x₁ cycle. The kit's rank
  certificates already do that.

So the question for this block: what does the exact any-period strip test give?

## The exact test

[claudeM5_any_period_strips.cpp](claudeM5_any_period_strips.cpp) decides, at a given width, whether every infinite
path of a strip graph has a given reading eventually periodic.
- **Why it is exact.** An infinite path of a finite graph ends in one strongly connected component. If a reading is
  constant on each cyclic class of that component (its period d, from breadth-first levels), the path sees it
  periodically.
- **And conversely.** If no reading is constant on the classes, two closed walks of one length pass disagreeing
  nodes at the same offset. An aperiodic choice between them, one block per reading in a fixed super-block, gives a
  path on which no reading is eventually periodic.

**The two graphs.**

| Mode | The strip | A step | The reading |
|---|---|---|---|
| **fall**, after `ModulusStrip` | W cells, both exterior cells free, nodes (row, t mod m) | only the cells permitted at that phase may fall | the adjacent pairs |
| **east**, after `Rule30StripCertificates` | K cells driven by the centre word w | the cell beyond the strip is free | x₁ at the white phases |

- **Pruning.** A width-W assignment is tested only when both width-(W−1) restrictions are uncertified, since a path
  restricts to a path of either substrip.
- **The addendum program.** [claudeM5_jen_strips.cpp](claudeM5_jen_strips.cpp) weakens the readings to Jen's full
  form: two rigid single columns anywhere, or one strip column at every phase beside a periodic centre.

## Modulus two is reached at width 27 (COMPUTED, three implementations)

**The control first.** With m = 3 every normalized assignment is certified at width 6, as S32 found.

With m = 2 ([output](data/claudeM5-modulus-two-27.txt)):

| Width | 4 | 6 | 8 | 10 | 12 | 14 | 16 | 18 | 20 | 22 | 24 | 25 | 26 | 27 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Uncertified assignments | 6 | 10 | 14 | 18 | 21 | 20 | 19 | 15 | 11 | 7 | 4 | 2 | 1 | **0** |

**What does the work.** Fifteen assignments, of widths 4 to 20, were certified by direct test. Every width-27
assignment contains one of them as a window, up to swapping the two parities:

> 0011, 0110, 01010, 01011, 011101, 0111101, 01111101, 011111101, 0000000010, 0¹², 00100000000001,
> 000000010000001, 00000001000000010, 000000010000000001, 00000001000000000001

- **Eleven repeat a pair at lag two.**
- **Four need longer lags,** from cycles of length 4, 8 or 10: 011111101 (lag 4), 0¹² (lag 8),
  00100000000001 (lag 8) and 00000001000000000001 (lag 10). With the lag-two certificates alone, 86 width-27
  assignments stay uncovered. So S32's control was right about lag two and wrong as a verdict on modulus two.

**The survivors.** From width 21 every surviving assignment has two odd-tick columns eight apart:
0ᵃ 1 0⁷ 1 0ᵇ, sometimes with a third at the east end. The last one, at width 26, is 0⁶ 1 0⁷ 1 0¹¹.

**Checks** ([receipts](data/claudeM5-modulus-two-verify.txt)):
- **The verifier.** [claudeM5_lag2_verify.c](claudeM5_lag2_verify.c) was written after the runs. It evaluates the
  rule cell by cell, builds the graph and its reverse explicitly, and finds components by Kosaraju's method. It
  applies the lag-two test, then the any-period test.
  - It agrees on all fifteen certificates.
  - It agrees that the width-26 survivor and both width-25 survivors are uncertified, so 27 is the least width for
    this method.
  - Its coverage pass finds that all 67,108,864 normalized width-27 assignments contain a listed window.
- **A third check.** [claudeM5_any_period_diag.py](claudeM5_any_period_diag.py), plain Python, agrees on all fifteen
  and reports each component's size and period.
- **Jen's full form changes nothing.** With two rigid columns anywhere instead of an adjacent pair, the counts at
  every width are identical and 27 is still the least width ([output](data/claudeM5-jen-full-form.txt)).

**THEOREM (COMPUTED; proved in core Lean in M234, `two_parities_every_27`).** For every integer i, one of the 27 singleton columns i, …, i + 26 has
black-to-white falls on even ticks and on odd ticks after every cutoff.

**Why.** Suppose each of the 27 columns has late falls at one parity at most. Then after a common cutoff the strip
history is an admissible run for one assignment. Every assignment is certified, so some adjacent pair is eventually
periodic, and Jen's theorem forbids that.

With S32 this gives two falling residues at **every** modulus m ≥ 2: six columns for m ≥ 3, and 27 for m = 2.

## Period two: no free-exterior strip excludes it at these widths (COMPUTED)

**The fall strip.** Under an alternating centre the late falls of columns −4, −3, −1, 0 and +1 are on black ticks,
and those of −2 on white ticks: the assignment 001000.
- **Where that comes from.** Columns −4 to −1 follow from the kit's skeleton (`Rule30PeriodTwo`, m1_even to m4_odd).
  For +1: at a white tick x₁(t + 1) = x₁(t) ∨ x₂(t), so x₁ cannot fall there.
- **It is uncertified at width 6.** One component of 15 nodes has no rigid pair, so the skeleton alone does not
  contradict Jen.
- **The theorem does not exclude period two either.** It supplies a column with both parities somewhere in every 27
  columns, and under alternation that column can lie outside −4 … +1.

**The east strip** ([output](data/claudeM5-east-any-period.txt)):

| Word | Widths tested | Certified at any width tested | Largest component with no rigid reading |
|---|---|---|---|
| 01 (period two) | 1 to 24 | no | 694 nodes at K = 10; 72,367 at K = 24, period 2 |
| 001, 011 (period three) | 1 to 20 | no | 50,006 and 40,639 nodes at K = 20, period 3 |

- **This is the exact test,** so it covers bitmask and rank certificates and any other strip certificate of these
  widths.
- **With every strip column as a reading** (Jen beside a periodic centre), nothing changes.
- **The census.** Over every primitive word up to length 8, at widths to 16, five words are certified:
  - 1 and 0 at width 1 (0 is excluded already, since the centre is not eventually constant);
  - 01111111 at width 5;
  - 00000011 at width 6, the kit's rank certificate (bitmask needs 12);
  - 00000001 at width 12, which no bitmask certificate reaches.

  No word of length 2 to 7 is certified.

**What this means.** The east strip's free cell can steer x₁, and every other column, aperiodically, beside period
two and both period-three clocks.
- **On the west side** the free exterior enters by XOR, so by left permutivity it steers the column next to it at
  will (the kit's `Rule30LightCone`).
- **So free-exterior strips are spent for period two** at these widths, whichever reading and contradiction they
  use. What is left is the finiteness of the seed's halves: Q01 in `Rule30PeriodTwo`, W1.

**A correction to M231.** Its note and WALLS row say the ring phantoms leave eight masks with "no certificate at any
width" and that "no strip width can" force them. That holds for **bitmask** certificates only. The rank and
any-period tests are not defeated by periodic phantoms. The exact test here leaves 01, 001 and 011 uncertified to
widths 24, 20 and 20, which supports the parking but proves less.

## Predictions

Registered in `931998e` and `4f44caa`:

| | Prediction | Outcome |
|---|---|---|
| A0 (97%) | modulus 3 certified by width 6 | **held** |
| B0 (95%) | 00000011 by K = 6; bitmask words no later than their width | **held** |
| A1 (65%) | some modulus-two assignment uncertified at width 6 | **held**: 10 of 32 |
| A2 (93%) | the alternation assignment 001000 uncertified at width 6 | **held** |
| A3 (35%) | every modulus-two assignment certified by width 12 | **failed**: 21 at width 12; all certified at 27 |
| A4 (60%) | the control loop's assignment 000000 certified at width 6 | **failed**: its 45-node component has no rigid pair |
| E1 (92%) | 01 uncertified at every K ≤ 22 | **held**, to K = 24 |
| E2 (80%) | 001 and 011 uncertified at every K ≤ 20 | **held** |
| E3 (70%) | at most five words certified beyond bitmask (length ≤ 8, K ≤ 16) | **held**: two (0 and 00000001) |
| E4 (60%) | 01's largest non-rigid component grows ≥ 1.3 per unit width from K = 10 | **held on average** (1.39); it dips at K = 16 and 21 |
| J1 (60%) | with two columns anywhere, modulus two certified below width 27 | **failed**: identical counts |
| J2 (90%) | 01 uncertified to K = 22 with every column | **held** |
| J3 (85%) | 001 and 011 uncertified to K = 18 with every column | **held** |
| J4 (90%) | 001000 still uncertified at width 6 | **held** |

**Not registered:**
- the modulus-two run past width 12 (registered as "to width 12, or until every assignment is certified");
- the run to K = 24 for 01;
- the verifier and the Python check, which came after the runs.

## Assessment

**Does this pull move us towards a solution or partial solution for a prize problem?** Partly.
- **It completes a theorem about the single seed's bulk.** S32's falling-phase theorem now holds at every modulus,
  and K92.4's "both falling parities at a fixed site" holds somewhere in every 27 columns. The site is not yet −2.
- **It closes a route for period two.** No free-exterior strip of these widths excludes period two or either
  period-three clock, with any period and any column. The missing input is the seed's finite halves (W1).

**Kit fit and submission.**
- **The modulus-two theorem extends S32's portal entry** (R30-20261127-157e8c, awaiting its rerun). It needs a Lean
  certificate first. Four certificates use lags 4, 8 and 10, so S32's lag-m format does not fit. A format with
  calendar 2 and lag 40 (a common multiple of 2, 4, 8 and 10) would.
- **The tables are large.** The widest tested certificate has 2²¹ nodes, against S32's 2⁶ × m. Kernel feasibility is
  untested.
- **KIT §5's "stops at modulus two"** should say "at lag two".

K92.4 stays open, and I do not propose parking it: gptIntel's −2 line continues. The fresh-choice test gives one
move, the Lean certificate.

Felt: surprise, strong, at width 22: the survivors were shrinking, and their restrictions left one candidate at 26
and none at 27. -> Replayed by two more programs before believing it. Outcome: it held. Felt: hope, small, that
Jen's full form would reach period two on the east strip. -> Ran it. Outcome: no change. Two verdicts. Reasoned:
modulus two holds at width 27 (COMPUTED, three implementations), and free-exterior strips are spent for period two
at these widths (COMPUTED). Gut: the modulus-two theorem is worth a Lean certificate; period two needs the finite
halves.

*Done in M234* ([Lean](../modulus-two/claudeM5-modulus-two-lean.md)): the any-lag and product certificates make it 2.9 s of building.
My own pull, as it was: a Lean certificate for the modulus-two theorem, with calendar 2 and lag 40, first at the small widths
(4 to 10) to time the kernel, then the four longer-lag tables.

## Files and replay

| File | What it does |
|---|---|
| `claudeM5_any_period_strips.cpp` | registered: `fall M WMAX THREADS`, `east WORD KMIN KMAX`, `eastcensus L KMAX THREADS` |
| `claudeM5_jen_strips.cpp` | addendum: the same with Jen's full form |
| `claudeM5_lag2_verify.c` | independent: `ASSIGNMENT` (lag two, then any period); `cover W FILE` |
| `claudeM5_any_period_diag.py` | a third check, to width 20 |

```sh
clang++ -O3 -std=c++17 -o any_period research/phase2/marks/claudeM5_any_period_strips.cpp
./any_period fall 2 27 2       # about 20 s and 3.5 GB at width 26 on the M5
./any_period east 01 1 24
```

**Credit.** The fall-phase strip, its pruning by substrips and the modulus-two control are S32's (gptIntel, I308 to
I310; claudeCloud's K96), after KDRonald3 and Claude's trapped windows (R30-20261115-2d4add). Jen's theorem and
masked Jen are the kit's (`Rule30Jen`, `Rule30MaskedJen`), after E. Jen. The rank certificates and the period-two
skeleton are the kit's (`Rule30StripCertificates`, `Rule30PeriodTwo`). The −2 step is I343's. The any-period test,
the modulus-two result at width 27 and the east-strip results are this block's.

Record searched: find_known for any period, modulus two, parity control, strongly connected, cyclic class, rank
certificate and lag two; KIT §5, KIT-INDEX's excluded words and rank certificates; `Rule30StripCertificates`,
`Rule30PeriodTwo` and `Rule30Jen`; S32's every-modulus.md, ModulusStrip.lean, ModulusParity.lean and
ModulusSingleton.lean; I341 to I343, N41 and unmarked-launch.md; M220 and M231.
