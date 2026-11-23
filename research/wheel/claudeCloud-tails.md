# What a tail beside the wheel can look like

**K75 · claudeCloud · 23 November 2026.** This continues gptIntel's [wheel note](README.md) (I152 to I156) at the
owner's word. It asks what the gate of a hypothetically alternating tail can look like, and which short
observations certify the trap. Statuses are given per section. Nothing here is second-read.

**Words.** A right half is driven by the alternating column 0. A *sample* is a tick at which column 0 is white. The
*gate* is column 1 at the samples, and a *kick* is a black gate sample. Inside the kit's 829-window trap consecutive
kicks are 3 or 5 samples apart: a *gap*. A *run* is the number of 5-gaps between two consecutive 3-gaps. The wheel
is the gate with runs 5, 5, 5, … for ever.

## 1. The three fragments are a rule on runs

**COMPUTED, with a hand argument.** Read as gaps, the three fragments of I155 are the factors `555553` (phase 26),
`355555` (phase 21) and `5535555` (phase 12). Each fragment begins and ends at kicks, or at whites that the
neighbouring gaps force, so the translation is exact.

- **A trapped gate avoids all three fragments exactly when every run is at most 4 and no run of 4 follows a run of 2
  or more.** A fragment is a run of five or more, or a run of four after a run of two or more.
- Checked on every cyclic gap word of up to 14 gaps: 32,766 words, no exception
  ([script](claudeCloud_wheel_runs.py), `selftest`).
- With the laws on record (the kit's `333`, `3533`, `5533`, `3553`; (1, 1, 4) and (3, 1, 4) from K56 and I66),
  a tail that avoids the fragments for ever has **runs of 1 and 3 only**, after a possible opening chain
  4, 1, 4, 1, ….
- An endless run of 5-gaps holds one fragment at most. It is the five-lock, and its gate is periodic.

## 2. Which short gap words certify the trap

A gap word *forces* the trap if every right half that reads it has its sixteen columns in the trap at the last
kick. The fragments are forcing words of 29 to 33 samples.

**COMPUTED** ([script](claudeCloud_wheel_observers.py)). On real rows, by SAT on the light cone, for every word of
up to seven gaps over 3 and 5: 254 words, 200 of which can end outside the trap (each row replayed cell by cell)
and 54 of which cannot. The 24-column window graph with a free exterior, which can only over-count what is read
outside, gives the same 25 minimal forcing words. The UNSAT answers are not proof-checked on this host; the
instances are named by their CNF digests in [the data](data/claudeCloud-wheel-forcing-sat.jsonl).

| Gaps | Minimal forcing words |
|---:|---|
| 5 | `53535` |
| 6 | `355353` `535335` `555353` `555553` |
| 7 | `3335353` `3335535` `3335553` `3353353` `3353355` `3355555` `3533353` `3535535` `3535553` `5333535` `5335353` `5335535` `5335553` `5355535` `5355555` `5535535` `5535553` `5553353` `5555335` `5555555` |

- **The shortest certificate is `53535`:** kicks at samples 0, 5, 8, 13, 16 and 21, so 22 samples, against 29 for
  the shortest fragment. It is a lone `353` with a 5-gap on each side.
- **`555553` is gptIntel's fragment at phase 26,** found again by a different encoder. The same encoder gives
  I155's threshold at that phase: 29 samples cannot end outside, 28 can.
- **Odd runs certify, even runs do not.** With a 5-gap on each side, a closed run of 1 (`53535`) and of 3
  (`5355535`) force the trap, and so does any closed run of five or more (`555553`). A closed run of 0, 2 or 4 with
  a 5-gap on each side can end outside the trap: `5335`, `535535` and `53555535` each have a row
  ([data](data/claudeCloud-wheel-forcing-sat-runs.jsonl)).
- **A closed odd run alone is not enough:** `35553` and `3535` can end outside. The 5-gap on each side is needed.
- Inside the trap a run of 3 is 61% of all runs (K56), and late runs of 0 and 2 do not occur. So a trapped gate
  shows a certificate at almost every run.

## 3. Gaps of 3 and 5 alone do not certify the trap

**COMPUTED.** Right halves exist that read 46, 60 and 100 samples of 3-gaps and 5-gaps and are outside the trap at
every one of them ([rows](data/claudeCloud-wheel-observer-sat.jsonl), replayed). 200 samples: UNKNOWN after
2,000,000 conflicts.

- Each reads a long stretch of 3-gaps, a kick every third sample, 27 in a row in the 100-sample row. Inside the
  trap `333` never occurs.
- In that row the twelve columns beside the wall repeat every six ticks while the stretch lasts. **gptIntel
  identified the block (I160): it is the rotating 84-ring of October,** a row of spatial period 84 that turns 14
  cells a tick. That row reads 3-gaps for ever outside the trap, so no bounded number of samples certifies the trap.
- On the window graph with a free exterior such paths never end, at 16 to 24 columns.

**The exterior's endless gates of 3-gaps and 5-gaps** ([gptIntel's note](exterior-tails.md), I162, I164; replayed
in K77). On the window graph at 31 columns and wider, an endless path outside the trap with gaps 3 and 5 only ends
by repeating `3`, `33355` or `333355`. My own lift, one column at a time from 16, gives gptIntel's counts of kick
windows on cycles at every width from 16 to 43, and the same words
([data](data/claudeCloud-wheel-exterior-lift.jsonl)). This replaces my reading of R65 and R69 in K75.

**The two mixed gates do not exist** (COMPUTED, K77; [script](claudeCloud_wheel_exterior.py)). Following each word
alone to wider windows, the kick windows on a two-sided endless path that spells it are:

| Word | 43 | 44 | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `333355` | 145 | **0** | | | | | | | | | | | |
| `33355` | 43 | 54 | 62 | 49 | 59 | 65 | 48 | 49 | 52 | 60 | 25 | 21 | **0** |

- **`333355` dies at 44 columns and `33355` at 55.** The word `3` is alive at every width tested, to 62 columns,
  as the 84-ring requires.
- By I166's compactness argument, a right half that reads a repeating gate for ever outside the trap gives a closed
  walk at every width. So **no right half of any kind reads `33355` or `333355` for ever outside the trap.**
- **Three routes agree:** the lift from 43 columns, the same word lifted alone from 16 columns, and for `333355`
  the plain-integer edge routine at every width. A fourth, with a different encoding
  ([script](claudeCloud_wheel_exterior_sat.py)): by SAT, a 44-column strip outside the trap spells `333355` eight
  times and not nine, and a 55-column strip spells `33355` six times and not seven. At 43 and 54 columns the same
  instances stay satisfiable at 8 and 16 repetitions. The UNSAT answers are not proof-checked here.
- 55 is also where gptIntel's strips of period 38 and 76 stop (I164, I166). At that width nothing is left at any
  period.
- **So a right half that stays outside the trap for ever, with only 3-gaps and 5-gaps from some time on, ends by
  kicking every third sample.** For a configuration with a leftmost black cell and an alternating centre that gate
  is excluded by masked Jen, so such a tail is in the trap (I164).
- By compactness, a gate of 3-gaps and 5-gaps holds no forcing word exactly when some right half reads it outside
  the trap for ever. So a trapped tail holds forcing words again and again. §2 says which short ones.

## 4. The three kinds of tail

| Kind | Its gate | What stands against it |
|---|---|---|
| 1. Outside for ever | gaps of 2 or 4 keep coming, in X or in Y | the open half of RD (K50.1, R65, R69, I48) |
| 2. Trapped, without the three fragments | from some time on every run is 1 or 3 | nothing local: see below |
| 3. Trapped, with the fragments for ever | runs of five or more keep coming | the left side only |

- **Kind 2 is not excluded by anything near the wall.** The ladder to 30 columns reads the run word 3, 3, 3, … for
  ever at every width, from 19,039 windows at 30 columns. It reads 4, 1, 4, 1, … to 26 columns and loses it at 28.
  A real row reads ten runs of three in a row with no fragment (SAT).
  In 13.9 million runs of real rows, (3, 1, 3, 3) occurs 87,662 times and (3, 3, 1, 3) 81,566 times.
- **Kind 2 does not escape certification.** Its runs of 1 and 3 are the certificates `53535` and `5355535` of §2.
  So "avoiding the three fragments" is not "avoiding the wheel's trap". Only kind 1 avoids the trap.
- **Every kind is aperiodic** (Jen), has no early repeats (I53) and has tile complexity with limsup p(n)/n ≥ 4/3
  (I51). Those are the left side's known demands. This note adds none.

## 5. The wheel's rate is nearly, and not exactly, the mean

**MEASURED** (`claudeCloud_m9_real_rows.cpp`, as frozen in K55). The wheel has 6 kicks in 28 samples, a mean run
of 5.

| Rows of support 30, 100,000 samples each | Runs from delay 100 on | Mean run | Standard error |
|---|---:|---:|---:|
| 4,000 rows (3,885 entered) | 13,862,582 | 4.99939 | 0.00096 |
| 40,000 rows (38,729 entered) | 138,142,554 | **5.00150** | 0.00030 |

- The larger sample is five standard errors from 5. Its five delay bins from 2,000 on give 5.0000, 5.0021,
  5.0013, 5.0015 and 5.0016, which scatter no more than their own errors. No row locked, and runs of 63 or more are
  77 of the 138 million.
- **So the mean run is 5.0015, within 3 parts in 10,000 of the wheel's 5, and not 5 on this evidence.** K56's
  "5.00" was right to three figures. No reason for the closeness is in hand.
- **The mean does not depend on what lies far to the right** ([script](claudeCloud_wheel_rate.py), 400 rows of
  20,000 samples per far field). White: 5.018. Fair random bits: 4.991. Random bits at 1/4 and at 3/4: 4.998 and
  4.998. All black: 4.999. Alternate columns: 4.995. Every third column: 4.998. Each has a standard error of 0.007
  to 0.008. The far field is forgotten before it reaches the wall.
- **The columns beside the wall follow the tiles.** Their black shares in 28ths, at white and at black ticks, are
  within 0.02 of (6, 17), (17, 16), (16, 11), (22, 17), (9, 11) and (16, 18) for columns 1 to 6, over 929,429
  samples of 47 rows. These are the wheel's own counts; the 17 is its name. Column 2 is a function of the tiles: it
  is black at every kick. From column 7 the shares are no longer whole (16.05 and 12.00, then 13.98 and 16.25), and
  they reach 14 by column 25. This was a look outside the frozen scripts.
- **A consequence that would have followed, and does not.** A tail of kind 2 has at least 2/9 of its samples black,
  against the measured 3/14. If the measured rate were a law of every right half that does not lock, kind 2 would
  not exist. It is a property of typical rows, and a tail is not typical, so it excludes nothing.

## 6. What is open

- **Kind 1:** can one finite right half stay in X or in Y for ever with an aperiodic gate? This is RD's open half.
- **Kinds 2 and 3:** which trapped, aperiodic orders of tiles a finite left side can read for ever. This is
  Q01Gap restricted to orders that real right halves produce.
- **X and Y do not end when widened** (K78, COMPUTED; [program](claudeCloud_exterior_cores.cpp)). A component whose
  gate is fixed stays fixed when widened, so only the variable ones need following. With R65's edges my program
  gives R65's and R69's counts exactly: X has 15,826 windows at 24 columns and 48,895,838 at 43, Y has 11,069 and
  630,829. Y is still variable at 62 columns and grows by about 1.15 a column; X grows by 1.54. So the window graph
  does not give RD, and I expect that right halves with the right far field do read aperiodic gates in Y. RD has
  to use the finiteness of the right half.
- **The 5.0015:** an exact value, or a reason for its closeness to 5.

## Reproducing

```text
KIT=Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean
python3 research/wheel/claudeCloud_wheel_runs.py $KIT selftest
python3 research/wheel/claudeCloud_wheel_runs.py $KIT observer 16 18 20 22 24
python3 research/wheel/claudeCloud_wheel_runs.py $KIT observer-sat 2000000 46 60 100 200
python3 research/wheel/claudeCloud_wheel_runs.py $KIT ladder 30
python3 research/wheel/claudeCloud_wheel_runs.py $KIT free-sat 3000000 12 60 120 200
python3 research/wheel/claudeCloud_wheel_observers.py $KIT graph 24 8
python3 research/wheel/claudeCloud_wheel_observers.py $KIT sat 500000 53535 35553 5355535
python3 research/wheel/claudeCloud_wheel_rate.py $KIT 400 20000
```

The mean run uses `research/m9/claudeCloud_m9_real_rows.cpp` with `cohort 30 40000 100000 OUT 76`, and
`claudeCloud_wheel_runs.py $KIT mean OUT.summary.txt` reads its summary. Outputs are in [data/](data/), each named
`claudeCloud-wheel-…`. Python needs NumPy and python-sat.
