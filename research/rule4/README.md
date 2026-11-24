# The questions that need measure, topology or analysis

*claudeCloud, 24 November 2026 (ledger K83). The owner's task: "Which questions have we not been asking because they
use mathlib. Can we identify new pulls that focus on this area." METHOD §12, Mathlib, rule 4: "If the theorem itself
needs measure, probability, topology or analysis, use Mathlib and accept portal only."*

Nothing here is a result unless it carries a status word. Section 6 holds the first probe.

## 1. What I read

Whole, this session: NOW.md, KIT.md, PORTAL.md, METHOD's Mathlib rules, M175. Of KIT-INDEX.md: the statements, both
period-2 sections, Jen, the barriers, density, complexity, and the last 72 rows of `equivalents/`. Not re-read this
session: its rows on periods 3 and 4, longer periods, the diagonals, algebra and tooling, and the 47 forms equivalent
to Problem 1; KIT.md covers them. In the kit's Mathlib folder: the index of `equivalents/CATALOG.md`, its section 6.3
and its section 7 item 11 ("Generic versus special points"), and keyword counts over the catalogue and its README. Ours:
[metric-rotation-repeats.md](../kit-repair/R30-20261029-0ef6e2/metric-rotation-repeats.md), R65, PRIOR-ART P23 to P26.

## 2. What the record already holds on the Mathlib side

**The kit's `equivalents/`** (108 modules on Mathlib) is thorough in one direction.

- *Forms equivalent to Problems 1 and 2*, over the reals, the p-adics, power series, automata and logic.
- *Almost every configuration.* With a fair coin on every cell: the centre column is a fair-coin sequence; rule 30
  preserves the measure, is mixing of all orders and ergodic; almost surely all three prize problems hold; the laws
  of large numbers, of the iterated logarithm, of large deviations, of return times. Also the generic (Baire) forms.
- *The one structural fact behind all of it* (CATALOG §7.11): rule 30 is linear in its left cell, so
  c(t) = x(−t) ⊕ g(x(−t+1), …, x(t)), and the cell x(−t) is used by no earlier c(s). The space of rows is the product
  of the centre column and the right half, and the fair coin on rows is the product of fair coins on the two
  (`measurePreserving_traceRightHalf`). **A fair-coin left half makes the centre fair for every right half**
  (`ae_isNormal_trace_glue`), the single cell's white right half included.
- It says so itself: "The single seed lies in the countable, null, meager set of finite configurations, so neither
  statement says anything about it."
- *Entropy.* Rule 30's topological entropy is between log 2 and log 3 (`log_two_le_coverEntropy`,
  `coverEntropy_le_log_three`). The catalogue adds: "Numerically it is log 2 … Proving h = log 2 is open (own
  computation)", from counts to 15 ticks, and to 18 for the alternating column.
- *Kopra's theorems* for the single cell: the right halves of its rows have infinitely many limit points, and return
  to the first row only finitely often.

**Ours.** Three portal entries stated over the reals (8084e6, 0ef6e2, dc3d17; PORTAL.md, *Port*). S11 and S19 with a
thin Mathlib layer. One theorem by hand that needs measure: the metric rotation theorem (I127, I128, read in N8),
for almost every cut tuple and almost every phase. Measurements with no theorem asked for: the leftward speed of a
flipped cell, 0.21 and 0.28 cells a tick (placego, October; PRIOR-ART-ARCHIVE); the share of fair right halves that
enter the gate trap, 0.9672, and the return factors 0.1 for Y and 0.001 for X (K80); the entropy bounds 0.258 and
0.2445 bits a reading at widths 12 and 14 (4767e0, 4d1a54); K5's tail constant 0.847810.

## 3. What we have not been asking, and why

Three habits, all from wanting core Lean.

1. **Every statement of ours says "every".** Every right half, every finite seed, every completion. When "every" was
   out of reach we parked (RD in I191, Q01Gap, the wall). We did not ask the same question for almost every one.
2. **Where the kit says "almost every", the coin is on the left.** There rule 30 is linear and every law is exact
   and easy. **No one has put the coin on the right and kept the left half finite.** On that side rule 30 is not
   linear (the right cell is heard only through a white centre), nothing is exact, and the answers are not known.
   The catalogue's keyword counts agree: "random right", "basin", "attractor", "Lyapunov", "Hausdorff" and
   "invariant measure" each occur zero times in it.
3. **We measured rates and never asked for them as theorems,** because a rate is a limit: the leftward speed, the
   entropy the right half adds, the trap's share, the floor of M6, the tail of K5, the irrational points of S9's
   pentagon (I72 is parked on exactly that sentence).

What measure cannot do stays true: the single cell is one point, and a statement for almost every right half does not
reach its white one. Each question below says what it would give.

## 4. The questions

### A. The coin on the right: a finite left half and a fair-coin right half

Fix a left half with a leftmost black cell (the single cell's, or any finite one) and toss a fair coin for every
cell to its right.

**A1. Is the centre column almost surely not eventually periodic?** CONJECTURE: yes, for every such left half and
every column. For period two this reads: *for almost every right half, no finite left half gives an eventually
alternating centre* (countably many left halves and transients, so one null set serves all).

*A reduction* (PROOF-SKETCH, unread). The left half is driven by the centre alone (`Rule30Coupled`). Fix the left
half L and an eventually periodic target ω for the centre. Then the whole left history is fixed, and
c(t+1) = l(t) ⊕ (c(t) ∨ g(t)), with l and g the columns −1 and 1, says two things. At ω's black ticks it is a
condition on L and ω alone. At ω's white ticks it prescribes the gate: g(t) = ω(t+1) ⊕ l(t). So the right halves
that give centre ω are exactly those whose gate, beside the wall ω, reads one prescribed sequence γ at the white
ticks. By the kit's masked Jen (`orCol_not_eventuallyPeriodic`) ω ∨ γ is not eventually periodic. Hence:

> Original proposed equivalence (corrected below): A1 holds if and only if, beside every periodic wall, the gate readings of a fair-coin right half have no atom at a
> sequence that is not eventually periodic. (For period two: beside the alternating column.)

**Correction after the K83.A read.** The equivalence ranges over gate prescriptions obtainable from a finite left half satisfying the black-tick consistency conditions. Excluding all aperiodic atoms for a prescribed periodic wall suffices. The converse for unrestricted gate words is open. The exact finite-transient change of measure is now proved in Lean. [Proof and forward reduction](right-coin-past.md)

Atoms do exist at periodic sequences: the ether lock and the seven-lock are open sets of right halves with one gate
each, and Jen excludes them. What would an atom at an aperiodic sequence γ be? New cells of the right half are fair
and independent of the cells already seen. Call an extension q of a prefix p *derailing* if every right half that
begins p q misses γ somewhere, and let d(p) be the length of the shortest one (infinite if p forces γ for ever).
Then the chance of γ given p is at most 1 − 2^−d(p). By the martingale convergence theorem an atom needs, along
almost every one of its right halves, d(p) → ∞ over the prefixes p: either a prefix that forces γ for ever (a lock
with an aperiodic gate), or prefixes that take ever more fresh cells to derail (call it a soft lock). Neither is
known to exist, neither is excluded. S12's finite branching certificates (I49) are the tool for the first.
*(Corrected after the probe, K83 addendum 1: the first version of this paragraph measured forcing against the light
cone. That is the wrong yardstick: a short prefix routinely fixes the centre far past its cone, section 6.)*

*What it would give.* Not Problem 1: the white right half is one point. It would be the first almost-sure statement
in which the left half is the single cell's own. Its proof would not pass through Q01, RD or the wall: it replaces
"the bulk of one finite seed" (K80's verdict on why RD stops) by fresh coins, and leaves a question about forcing by
prefixes, which is finite in kind. If it fails, the failure is a new object, a soft lock or an aperiodic lock, and
that is a lead for RD itself.

**A2. Do almost all right halves beside an alternating column end in the trap or in a lock?** This is RD for almost
every right half. K80 measured 0.9672 for the trap and did not class the rest. With it: the exact shares (a phase
portrait in numbers), and the size of the exceptional set (the stays in X and Y for ever), as a Hausdorff dimension.

**A3. What kind of sequence is the centre column of the half-random row?** Its entropy rate, whether it equals the
leftward speed of a flipped cell, whether its black density is 1/2. This is Problem 2 with the coin on the right.

### B. How fast is the right side heard?

**B1.** For almost every row, does flipping one cell on the right change the centre column at some time? **B2.** Is
the leftward speed positive? **B3.** Is rule 30's entropy strictly above log 2, against the catalogue's numerical
reading? Under the fair coin the entropy of the pair of columns (0, 1) is log 2 plus the entropy the right half adds
to column 1 given column 0; B3 asks whether that is positive. **B4.** An upper bound below log 3: the number N(n) of
pair words is submultiplicative, so the entropy is at most (log N(n))/n for every n, and the catalogue's own count
at n = 15 (about 2^15 · 15²) would already give log 2 + (2 log 15)/15 ≈ 1.05 < log 3 ≈ 1.10. UNCHECKED: the count
is theirs, quoted from the catalogue.

*What it would give.* Nothing for the single cell directly. It is the rate at which the bulk speaks to the wall,
which is the quantity behind the right-side wall, and it would correct or confirm a row of the kit's Mathlib folder.

### C. Candidate columns in measure (N6's line; not new here)

The metric rotation theorem is proved by hand and read; in Lean it needs the ergodicity of a rotation and the first
Borel–Cantelli lemma, both in Mathlib (M175 §4). One addition: 0ef6e2 excludes a rotation coding when the
continued-fraction digits exceed 2^(r+1) arbitrarily late, and almost every angle has unbounded digits, so *almost
every angle is excluded for every finite-step coding at once*. UNCHECKED whether Mathlib has that almost-sure fact;
Gallagher's zero-one law (M175) is close to it.

### D. Results we hold in whole numbers whose natural form is a limit (METHOD's rule 3 shape; small)

- **S9's pentagon.** Every real point of the pentagon as the limit of one history, and the pentagon as the set of
  density pairs of invariant measures. I72 is parked on exactly this.
- **Q01 for almost every start.** The kit's `first_check_count` gives at most 2^n survivors of n checks among the
  4^n rows of width 2n. So the naturals that never reach an even number under G have density zero, with at most
  √N of them below N. This is Terras's theorem for the Collatz map, in our setting, and it is one line from the
  kit. It is not in the kit or the catalogue in that form ("Collatz" and "Terras" do not occur there).
- **M6's floor** as a limit (Fekete's lemma), and **K5's tail** as the spectral radius of its chance model.

### E. The same questions in the sense of category

For a fixed finite left half, is the centre aperiodic for all right halves but a meagre set? Equivalently: no finite
prefix of the right half forces a periodic centre. This is weaker than Problem 1 for finite rows (`FinConf`), which
would give it at once, and it is the lock half of A1.

## 5. Proposed pulls

| Pull | The question | First test |
|---|---|---|
| **K83.A, the coin on the right** | A1 to A3 and E | The probe of section 6 (done). Then, by solver: d(p), the number of fresh cells it takes to derail the gate, along the prefixes of trapped halves, of the long trains and of lock-bound halves. A bound on d off the locks would give A1 for period two from Jen and S12's certificates. |
| **K83.B, how fast the right side is heard** | B1 to B4 | The probe's random-wall mode. Then exact pair-word counts to 16 or 18 ticks, and B4's bound in Lean on the kit's `pairWords`. |

C stays with N6. D is a list for whoever next sends a packet on S9, Q01 or K5, not a pull.

A Mathlib candidate cannot be compiled on a cloud container; the M5 and the Intel can (TOOLS.md).

## 6. The first probe (K83 addendum 1)

[claudeCloud_rule4_probe.cpp](claudeCloud_rule4_probe.cpp), SHA-256
`9a7fb960d9e594b77790701edfd18e693703efa800f4a486041bb05b972701c4`, frozen and pushed with eight predictions before
its runs. One development control ran before freezing: the exact mode at M = 8 against an independent brute force,
equal. Outputs are in [data/](data/). Everything below is MEASURED, except the exact table, which is COMPUTED.

```
g++ -O3 -fopenmp -std=c++17 claudeCloud_rule4_probe.cpp -o rule4_probe
rule4_probe centre-exact 30
rule4_probe centre-mc 4194304 512 20261124
rule4_probe gate KITFILE 1048576 600 20261124      # KITFILE = the kit's Rule30Certificates/GateTrap.lean
rule4_probe wall 1 1048576 512 20261124            # and walls 2 and 3
```

**The centre column with a white left half and a fair right half** (cell 0 black).

| Ticks m | Different centre words | Shannon entropy, bits | Collision entropy, bits | Share of the likeliest word |
|---:|---:|---:|---:|---:|
| 8 | 5 | 2.19 | 2.08 | 0.348 |
| 16 | 21 | 3.64 | 3.25 | 0.223 |
| 24 | 41 | 4.81 | 4.51 | 0.085 |
| 30 | 76 | 5.39 | 4.94 | 0.085 |
| 64 | | | 7.19 | 0.029 |
| 128 | | | 11.17 | 0.0058 |
| 256 | | | 17.11 | 3.8 × 10⁻⁴ |
| 384 | | | 22.54 | 3.3 × 10⁻⁵ |
| 512 | | | 27.79 | 4.8 × 10⁻⁶ |

Rows to 30 are exact, over all 2³⁰ right halves; the rest are from 4,194,304 samples. The collision entropy grows by
0.041 bits a tick from 256 to 512. The words to 30 ticks are fitted as well by m²/12 as by an exponential; the
samples to 512 settle it, since almost all 4,194,304 are different there.

**Column 1 beside a fair-coin wall,** 1,048,576 fair right halves, three walls. Collision entropy in bits:

| Ticks m | Wall 1 | Wall 2 | Wall 3 |
|---:|---:|---:|---:|
| 64 | 7.99 | 7.74 | 7.51 |
| 128 | 11.41 | 11.29 | 11.25 |
| 256 | 16.99 | 16.59 | 15.61 |
| 512 | 28.46 | 28.32 | 27.10 |

From 256 to 512: 0.0448, 0.0458 and 0.0449 bits a tick. The fall of the share of equal pairs is exponential and not
a power of m: from 256 to 512 the walls lose 11.5, 11.7 and 11.5 bits, against 5.6, 5.3 and 4.4 from 128 to 256.

**The fates beside the alternating column,** 1,048,576 fair right halves at sample 600 (tick 1,200).

| Fate at sample 600 | Share |
|---|---:|
| In the 829-window trap | 0.96253 |
| Outside, gate of period 2 over the last 200 samples (the ether's gap 2) | 0.02585 |
| Outside, gate of period 7 (the loop 2, 5) | 0.01135 |
| Outside, no period up to 60 | 0.00027 |

K80's 0.9673 is at sample 1,500: entries keep arriving (median entry sample 13, 99% by 392, the last at 599), and
they come from the loop 2, 5, which is a lock for some halves and a long stay of X for others. Inside the trap 0.31%
of the halves have a periodic gate over the last 200 samples: the train 3555 (period 18) in 0.25%, the gap 5 alone in
0.012%, periods 46 to 58 in 0.044%. gptIntel's K81 bound says no strip of 88 columns returns with the train 3555, so
these are long stays or stays that keep changing further out, not locks of fixed width.

**Pairs with the same gate.** Among all pairs the share is 9.7 × 10⁻⁵ at 256 samples and 5.0 × 10⁻⁵ at 512, still
falling slowly; the largest group is constant at 3,840 halves (0.37%) from sample 384. Among pairs both in the trap
and aperiodic at the end it falls by 0.07 bits a sample from 64 to 128 and by 0.016 from 320 to 512, with no plateau
through 512.

**What it says.**
1. **The right half is heard, slowly:** about 0.04 to 0.05 bits of collision entropy a tick, for the centre of the
   half-random row and for column 1 beside a random wall alike. That is five times less than the leftward speed of a
   flipped cell (0.24 cells a tick) would give if each cell brought a bit.
2. **It is an exponential rate, not a power.** The Shannon entropy that the right half adds is at least the
   collision entropy, so under the fair coin the pair of columns (0, 1) carries at least about 1.045 bits a tick.
   This is evidence against the catalogue's numerical reading that rule 30's entropy is exactly log 2 (question B3).
3. **A short prefix fixes the centre far past its light cone.** One centre word of 30 ticks has share 0.085: under
   four bits of the right half decide thirty ticks. So forcing measured against the cone is the wrong yardstick for
   A1; the corrected one is d(p) in section 4.
4. **No atom at an aperiodic gate was seen,** and none can be excluded by sampling.
5. **The trap's share was still rising at sample 600.** A table of the eventual shares needs the loop 2, 5 split
   into its lock and its long stays.

**Predictions:** three of eight held (the alternation share; the gap-5 class inside the trap; the fall among trapped
aperiodic pairs). Five failed, four of them the same way: I expected rates of 0.15 to 0.4 bits a tick and found 0.04
to 0.13. The fifth was my own control, set against K80's share at the wrong sample.

## 7. The K83.A work block

The [exact forward count](k83a-gate-mass.md) gives sharp finite bounds for both phases and a test that keeps the left support fixed. The [gate escape calculation](k83a-escape.md) gives an exact infinite comparison at S12’s 28-cell prefix and a finite search on trapped rows and the Y train. The [basin count](k83a-basin.md) certifies over half the fair-right measure in the trap alone and resolves every row in the original cohort. The [past-wall theorem](right-coin-past.md) and the [eight-site mean for reading the previous wall](predecessor-wall-radius.md) quantify the backward information. The almost-sure questions about future periodicity and eventual basin capture remain open.
