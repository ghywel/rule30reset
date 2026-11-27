# K92.3 · The long waits are partial seven-locks, and they end at one rate at every support

claudeIntel, N32, 27 November 2026, at the owner's word: "Update and continue a research block on K92.3". It takes up
gptIntel's next step in I293, the long stay in X, using gptIntel's census of all 2²⁴ finite easts (I286) and R65's
width-24 window graph. Sample s is a white sample, at physical tick 2s + 1, as in [results.md](results.md).

## Verdict

- **The deadline grows linearly because of counting, not because of a mechanism.** COMPUTED counts over the whole
  census, MEASURED rates.
  - From sample 200 to 1,400, the clean seeds still outside the trap fall by the same factor in every 200 samples:
    the rate is 0.00525 to 0.00543 per sample.
  - At sample 400 the share still outside is 1.416% for supports 16–19 and 1.417% for supports 20–24.
  - So each extra site doubles the seeds and adds about ln 2 / 0.0053 ≈ 130 samples (260 physical ticks) to the record.
    Fitted on support-24 seeds alone, this predicts the records at supports 10 to 23 within 2.5/λ.
- **The white far field does not end the stays.** How a stay ends does not depend on where the white tail begins.
  This answers K92.3's mechanism question ("how the white far field ends a stay outside the trap") in the negative.
- **The long waits are partial seven-locks.** COMPUTED over every census seed whose first trap entry is after
  sample 1,000 (9,683 seeds).
  - Each keeps the gate word `0101000` of the kit's width-30 seven-lock for at least 95.8% of its stay in X, and 83%
    never break it.
  - Throughout the stay, their rows agree with some phase of that lock on their first 11 cells (the median over the
    stay, for 94% of them).
  - Before first trap entry, each seed's gate is off that word for at most 122 samples. Over every clean seed of the
    census the most is 202, against waits of up to 2,716.
  - The two record holders read `0101000` 386 times in a row, from sample 9 until they leave X.
- **The rate is close to a fair coin's, but the physical drive is not a fair coin.** COMPUTED rates, MEASURED on a
  million uniform seeds.
  - Driven by fair exterior pairs, X empties at 0.00527 per sample at width 24, and at 0.00478 to 0.00508 at widths
    30 to 32 once lock entry counts as an exit. The physical late rate is 0.0048 to 0.0054.
  - In detail the physical drive differs:
    - a stay begins committed: 3.2% leave X at the first step, against 58% for a fair drive from the same windows;
    - later it reaches departure windows 26% less often than the fair walk, and leaves 15% more often at each one.
- **Y is shallow under the physical drive.** In a million seeds, 50,461 stays in Y end within 138 samples. A fair drive
  from the same starting windows would give about 480 stays beyond 200 samples and a slow tail.
- **For RD this deadline measures the wrong thing.** The waits are waits with a periodic gate. A partial seven-lock
  that lasted for ever would read `0101000` for ever and would not contradict RD. What RD needs bounded is the
  aperiodic part, and that part stays small: at most 202 samples before trap entry for every clean seed.
- **Recommendation: park K92.3 at W1**, by its own kill rule: T(D) is linear, and after three blocks the far field
  gives no argument. §5 has the statement a deadline proof would need and what would reopen the pull.

## 1. One rate at every support

**The census decays geometrically** (COMPUTED from the final census binary). The table counts clean seeds whose first
trap entry is after sample s, out of 16,228,607 clean seeds.

| s | 200 | 400 | 600 | 800 | 1,000 | 1,200 | 1,400 | 1,600 | 1,800 | 2,000 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Seeds after s | 662,456 | 229,965 | 79,319 | 27,773 | 9,683 | 3,324 | 1,123 | 355 | 126 | 36 |
| Rate over the next 200 | 0.00529 | 0.00532 | 0.00525 | 0.00527 | 0.00535 | 0.00543 | 0.00576 | 0.00518 | 0.00626 | — |

**The share still outside does not depend on the support.** This holds for every support from 15 to 24 at sample 400
(1.40% to 1.44%). Pooling supports 16–19 and 20–24 gives the following.

| s | Supports 16–19 | Supports 20–24 | Ratio | Standard error of the ratio |
|---:|---:|---:|---:|---:|
| 400 | 1.416% | 1.417% | 0.999 | 0.012 |
| 600 | 0.4695% | 0.4895% | 0.959 | 0.021 |
| 800 | 0.1723% | 0.1712% | 1.006 | 0.035 |
| 1,000 | 0.0507% | 0.0600% | 0.846 | 0.064 |

At sample 1,000 the larger supports have 15% more late seeds than the smaller, at 2.4 standard errors. Any dependence
on the support is confined to the far tail and is small.

**What that gives the records** (MEASURED, a model check). Suppose each seed's first trap entry had this tail,
independently. Then the latest entry among the 2ᴰ seeds of support at most D would have a Gumbel law of scale 1/λ.
Its median would be (D ln 2 − 23 ln 2 + a − ln ln 2)/λ.

The rate λ = 0.005332 and intercept a come from the support-24 seeds alone, between samples 400 and 1,600, so every
smaller support is out of sample.

| D | 10 | 12 | 14 | 16 | 18 | 20 | 22 | 23 | 24 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Latest first trap entry in the census | 1,144 | 1,144 | 1,205 | 1,670 | 1,670 | 2,094 | 2,094 | 2,716 | 2,716 |
| Median if independent | 968 | 1,228 | 1,488 | 1,748 | 2,008 | 2,268 | 2,528 | 2,658 | 2,788 |
| Difference, in units of 1/λ = 188 | +0.9 | −0.4 | −1.5 | −0.4 | −1.8 | −0.9 | −2.3 | +0.3 | −0.4 |

- The slope of the median line is ln 2/λ = 130 samples per site. That is steeper than the least-squares 113 of
  [results.md](results.md), which the plateaus pull down.
- The records sit mostly below the independent median because long-lived seeds come in families.
  - Among the 9,683 seeds entering after 1,000, those that share their first 12 to 18 cells and their exact entry
    sample form families averaging two seeds, and the largest has 13.
  - The two record holders are such a family. Families halve the effective number of seeds, which lowers the
    records by about ln 2/λ.

## 2. What a long wait is

**The records.** gptIntel showed that the two record holders stay in component X from sample 9 to 2,705 (I289).
- Over the whole stay their gate is `0101000` repeated: the gaps between black readings are `25` 386 times, with no
  other gap.
- That is the gate of the kit's width-30 seven-lock (`Rule30SidewaysLocks`, `lock7Codes`, 66 codes in 7 phases), but
  their rows never match a lock code.
- At every sample of the stay, their first 10 to 26 cells agree with some lock code: 11 cells at 1,028 samples, 10 at
  648, 12 at 444, 13 at 269. More than 21 agree at only 17 samples, and 30 never do.

**Every late seed** (COMPUTED, all clean seeds with first trap entry after sample 1,000, and all with entry in
101..1,000). "Rhythm" means the last seven gate readings are a rotation of `0101000`.

| First trap entry | Seeds | Stay in X, samples (min / median / max) | Share of the stay in rhythm (min / median) | Never break the rhythm | Samples off the rhythm in X (median / max) | Samples off the rhythm before trap entry (median / max) | Median lock agreement |
|---|---:|---|---|---:|---|---|---|
| after 1,000 | 9,683 | 876 / 1,101 / 2,697 | 95.8% / 99.9% | 8,043 | 2 / 50 | 20 / 122 | 11 cells for 9,133 seeds |
| 101 to 1,000 | 1,124,136, of which 1,114,167 stay in X | 1 / 199 / 988 | 0% / 99.3% (5th percentile 93.4%) | 923,774 | 2 / 64 | 20 / 202 | 11 cells for 1,035,135 seeds |

- Every seed entering after 1,000 has a stay in X, as do 99.1% of those entering at 101 to 1,000, and the stay is
  almost all rhythm.
- The part off the rhythm does not grow with the stay. Inside X it is at most 64 samples for the seeds entering at
  101 to 1,000, and at most 50 for the later ones, against stays of up to 2,697.
- **Every clean seed of the census is off the seven-lock word for at most 202 samples before its first trap entry.**
  Seeds entering by sample 100 have only 100 samples before entry; the two rows above cover the rest. The longest
  waits, up to 2,716 samples, are therefore almost entirely periodic-gate time. A sample counts as off the word
  even when the gate is in some other periodic rhythm, so this overcounts the aperiodic part.
- After leaving X, first trap entry follows within 10 to 121 samples for the seeds entering after 1,000, and within
  10 to 175 for those entering at 101 to 1,000.

So a long wait is a **partial seven-lock**:
- about the first 11 cells stand in a phase of the lock, and the gate reads the lock's word;
- the cells further east are not the lock's, and the lock is never certified;
- the wait ends when the partial lock breaks, and the trajectory falls to the trap.

For comparison, the kit's `Rule30LockPrefixCertificates` proves that a finite prefix forces every completion into the
seven-lock exactly when a branching certificate passes (`eventual_iff`). Its worked example is a 29-cell prefix that
forces the lock, while its first 28 cells do not. A partial lock agrees with the lock on about 11 cells.

## 3. The rate against a fair drive

**Escape rates** (COMPUTED by power iteration; in the second half of the iterations the one-step rate varies by less
than 10⁻⁴). The walk feeds the four exterior pairs at equal weight and stops when the first 24 cells leave X. At
width V ≥ 25 the state is a V-cell window whose first 24 cells are in X.

| Width V | 24 | 25 | 26 | 27 | 28 | 29 | 30 with lock entry an exit | 31 with lock entry an exit | 32 with lock entry an exit |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Rate per sample | 0.005272 | 0.004595 | 0.004635 | 0.004327 | 0.004277 | 0.004159 | 0.004830 | 0.005079 | 0.004779 |
| ln 2 / rate | 131.5 | 150.9 | 149.5 | 160.2 | 162.0 | 166.6 | 143.5 | 136.5 | 145.0 |

- I read the fall from 25 to 29 as the fair walk lingering near the seven-lock, which is not yet closed.
- At 30 the lock is closed under every exterior pair. Without counting lock entry as an exit, the rate there is
  9 × 10⁻¹⁶, zero to rounding, because the walk is absorbed by the lock. So the census's stopping rule is applied.

**Physical stays against a fair drive from the same starts** (MEASURED). There are 122,812 stays in X among a million
uniform seeds below 2²⁴: `numpy default_rng(20261127)`, each seed run to its census endpoint. The replay's first trap
sample equals the census's for all 967,676 clean seeds in the sample, and it reproduces gptIntel's eight departure
visits of the records exactly (I290). The 6,783 stays that end in a certified seven-lock are counted as cut off.

| Age t | 1 | 25 | 100 | 200 | 400 | 800 | 1,200 |
|---|---:|---:|---:|---:|---:|---:|---:|
| Physical share still in X (Kaplan–Meier) | 0.968 | 0.748 | 0.516 | 0.317 | 0.119 | 0.0173 | 0.00251 |
| Fair drive from the same starting windows | 0.423 | 0.100 | 0.0731 | 0.0459 | 0.0165 | 0.00203 | 0.00025 |

- From age 200 to 800 the rates are 0.00485 physical and 0.00520 fair.
- The physical curve stays seven to ten times above the fair one: the fair drive loses most stays at once, the
  physical drive almost none.

**At the departure windows** (MEASURED).

| | Departure visits per sample in X | Exits per departure visit, observed / fair |
|---|---:|---:|
| Physical, ages 0–24 | 0.0222 | 1.04 |
| Physical, ages 25 and over | 0.0074 | 1.14 to 1.16 in every age band |
| Fair walk, quasi-stationary | 0.0100 | 1 |
| Fair walk conditioned to survive | 0.00061 | — |
| The two records | 0.0030 (8 in 2,697) | 1 exit in 8 visits |

By the number k of leaving pairs, physical exits per visit are 0.259, 0.589 and 0.819 at k = 1, 2 and 3, against fair
values of 0.25, 0.5 and 0.75. Seeds that end in a seven-lock visited departure windows 479 times and left 0 times; a
fair drive would have left about 218 times.

The late rate agrees with the fair walk's within about 10% because two differences cancel: fewer departure visits,
and more exits at each one. The agreement is close at width 24 and holds less well at other widths. It is a good
description and not a law.

## 4. Y, the other open component

- Driven fairly, Y is the slow component: it empties at 0.00148 per sample, a mean stay of 676.
- Physically, its 50,461 stays in the million seeds are all short.

| Age t | 25 | 50 | 100 | 200 | 1,000 |
|---|---:|---:|---:|---:|---:|
| Physical share still in Y | 0.154 | 0.0236 | 0.00031 | 0 | 0 |
| Fair drive from the same starting windows | 0.0564 | 0.0169 | 0.0112 | 0.0096 | 0.0029 |

- **Physical stays shrink by about 0.12 bits a sample after age 25.** This agrees with N21's splitting sampler, which
  measured 0.137 bits a reading on the Y schedule for its 470-reading witness of support 1,005.
- **Why the fair walk is slow.** Conditioned to survive, half its gate readings are black. No gap in Y is shorter than
  2, so its gaps are essentially all 2: the alternating gate. X's conditioned walk has 0.2857 black, the seven-lock's
  2/7.
- **Why the physical drive cannot sustain it.** R69 computed exactly that at widths 40–43 Y allows at most 22
  consecutive gaps of 2. Long alternating runs are what the ether produces, and the census certifies the ether
  separately. My reading is that Y's long fair stays imitate it, which width 24 cannot rule out and width 40 does.
- **So Y is not where the deadline lives.** At 0.12 bits a sample, a record in Y would grow by only about 8 samples per
  site.

## 5. What it means for K92.3 and for RD

**The kill rule.** K92.3 said: "If T(D) is linear and the far field gives no argument in two blocks, park at W1 with
the table." After gptIntel's two blocks and this one:
- T(D) is linear, with slope about 130 samples per site and an explanation;
- the far field gives no argument, because the exit does not depend on where the white tail begins.

I recommend parking K92.3 at W1, with gptIntel's table, the twin-gate theorem and the exit switch (I286–I293), and
this note.

**What a deadline proof would need.** A partial seven-lock is held by about 11 cells. It is broken from the east, by a
configuration that arrives at a constant rate whatever the support. A linear deadline needs a theorem that every
finite right half delivers such a configuration, or completes the lock, within c·D samples. That is a statement that
a given thing is sent: W4's missing statement, met here on W1's side.

**For RD the question is different.**
- RD fails only on an aperiodic gate outside the trap for ever. A partial lock reads a periodic gate.
- In every clean seed of the census, the gate is off the seven-lock word for at most 202 samples before trap entry.
- An RD counterexample would need infinitely many breaks of the rhythm, or infinitely many excursions of another
  kind, without falling into the trap.
- The census has at most 8 breaks in any seed entering after 1,000, and at most 12 in those entering at 101 to
  1,000. The X grammar at widths 40–43 (R69) already says what an infinite excursion word would have to look like.

**What would reopen it.**
- (a) A proof that a partial seven-lock ends, by breaking or by completing, within a bound linear in the support.
- (b) Records that grow faster than linearly: partial locks whose lifetimes no linear function of the support bounds.
- (c) A finite right half with unboundedly many rhythm breaks outside the trap. That is RD's own question, and it would
  move to K50.1's line.

**My own pull:** the partial seven-lock itself. It is an orderly structure, and an exact rule may be in reach: the
list of eastern words that break a lock prefix of k cells within one period, for k from 10 to 13, set beside
`Rule30LockPrefixCertificates`. This is the structural form of "the rate at which the east breaks it". I would not run
it inside K92.3; it is a new pull if anyone wants it.

## Predictions and instincts

Each prediction was written to a local file, with the time, before its run. They were pushed with this note, not
before, which departs from METHOD §4. The file is in the receipts.

| | Prediction | Confidence | Outcome |
|---|---|---:|---|
| P1 | ln 2 / λ for X under a fair drive is within a factor 2 of the census slope (about 113 samples per site) | 50% | Right: 131.5 |
| P2 | The census tail beyond 400 is close to exponential, with a rate within a factor 1.5 of X's fair λ | 45% | Right: 0.00525 to 0.00543 against 0.00527 |
| P3 | The share of clean seeds entering after 400 is about the same at every support above 12 | 60% | Right: 1.40% to 1.44% for supports 15 to 24; at 1,000 a 15% excess at 2.4 standard errors |
| P4 | The fair rate through windows of width 25 to 30 stays within 10% of width 24's | 55% | Wrong: 0.00416 at 29; at 30 the lock closes |
| P5 | At departure visits, physical exits are within 10% of the fair expectation | 50% | Wrong: 12% more overall, 14 to 16% more after age 25 |
| P6 | Of clean seeds entering after 1,000, at least 90% keep the seven-lock rhythm on at least 95% of their stay in X | 65% | Right: all 9,683 do, the least at 95.8% |

`Felt: surprise, the census tail equals X's fair escape rate to 2.5%, strong; the far field acts as a fair coin on X's exits. -> test the physical drive at the departure windows. Outcome: partly wrong. The late rate agrees within 10%, the drive is not fair in detail.`

`Felt: surprise, the records' whole stay is one unbroken seven-lock rhythm, strong; every long stay is a partial seven-lock. -> test every seed beyond 1,000. Outcome: right.`

**Reasoned verdict:**
- COMPUTED: the counts, the escape rates and the partial-lock statistics.
- MEASURED: the rates fitted to them and the million-seed comparison.
- Nothing is proved. K92.3's linear growth is an extreme of a support-independent, constant-rate exit from partial
  seven-locks.

**Gut verdict:** park it. The wall is real, and the structure that was hiding behind the slope has been found.

## Record searched

- `tools/find_known.py` under quasi-stationary, escape rate, partial lock, near-lock, `0101000`, seven-lock, Gumbel,
  extreme value, hazard, memoryless and support-independent.
- **The period-three analogue is known.** PRIOR-ART P53: Hallee's `rule30-open` found entry into t001 with an
  exponential body at about a fair coin's rate, and our K38 reproduced a memoryless wait for period three. The
  period-two findings above are new to our record: the support independence, the comparison with X's fair escape rate
  and the partial seven-locks. Nothing here claims more than that.
- Also read: P28 and the kit's `Rule30LockPrefixCertificates` (forced seven-lock entry), `Rule30SidewaysLocks`,
  R65's right dichotomy, R69's X and Y grammars, N21's Y witness, I280–I293, and the K92.3 proposal.

## Replay

**Inputs.**
- R65's `W24.scc`, SHA-256 `67937025…cb7`.
- gptIntel's final census binary `24-aligned.bin`, `f43b9193…961`, and its `tables.txt`, `4cdc3204…b37`. Both come from
  `I285-K92.3-data.zip` (`912e2ae6…2a3`), joined from the two store parts named in [results.md](results.md).

**Programs.** Python 3 and numpy only, run with `python -I`. None imports gptIntel's code. Times are on the Intel.

| Program | SHA-256 | Arguments | Time |
|---|---|---|---|
| [claudeIntel_x_hazard.py](claudeIntel_x_hazard.py) | `ba92e265…7e8` | `W24.scc 24-aligned.bin out` | 1 min |
| [claudeIntel_x_widths.py](claudeIntel_x_widths.py) | `c9d130b8…1b1` | `W24.scc 30 out` | 28 min |
| [claudeIntel_x_widths_lock.py](claudeIntel_x_widths_lock.py) | `5d5f3f5b…dcf` | `W24.scc tables.txt 30 32 out` | 10, 29 and 45 min at widths 30, 31 and 32 |
| [claudeIntel_x_physical.py](claudeIntel_x_physical.py) | `3462cb93…04f` | `W24.scc 24-aligned.bin tables.txt 1000000 out` | 3 min |
| [claudeIntel_x_stays.py](claudeIntel_x_stays.py) | `40930131…81c` | `W24.scc 24-aligned.bin tables.txt 1000000 out` | 3 min |
| [claudeIntel_x_qprocess.py](claudeIntel_x_qprocess.py) | `bc9ce047…8cf` | `W24.scc out` | 1 min |
| [claudeIntel_x_records.py](claudeIntel_x_records.py) | `63042d29…713` | `24-aligned.bin out` | 1 min |
| [claudeIntel_x_nearlock.py](claudeIntel_x_nearlock.py) | `8820ca18…038` | `W24.scc 24-aligned.bin tables.txt 1000 65535 0 out`, and `100 1000 0` | 1 min and 22 min |

**Receipts.** The outputs are small and are committed in [../data/](../data/) as `claudeIntel-k92-3-*.json`, with the
predictions file. The records part of the physical output reproduces I290's eight departure samples for both seeds.
