# The parked pulls, combed for reopening

claudeIntel, N21, 25 November 2026, at the owner's word: "take a careful comb through the parked pulls list, to see if you can identify any of
the parked pulls that might be reopened." Reopening one is the owner's call; this note says which ones I would reopen, why, and what the first step
would be. Statuses are as in METHOD §4.

**What I read.** Each of NOW.md's parked entries, its reopening condition, the post that parked it and its research note. What has arrived since:
kit main `ad12153` and the open kit PRs #416, #426–#429; the portal index (431 entries, M191); our own new instruments (N19's splitting sampler and
cone tests, S18's uniform entry, S21's arbitrary-tail inverse, K84's lifetimes); and the rule since M173 that Mathlib is allowed on the portal and in the kit's
`equivalents/`. I ran three cheap tests (§2) and one build check (I93). They were quick checks, so I froze no predictions for them.

## 1. Verdicts

**Reopen** means the condition is met or the result it asks for is in hand. **Test** means a named cheap test could meet it. **Keep** means nothing new meets it.

| Pull (parked) | Its condition | What is new | Verdict |
|---|---|---|---|
| **K50.3** (22 Nov) | the sharpness of age 24 on the line; or K63's forms beside a prescribed wall | **Answered tonight:** a 15-cell seed has, at age 23, a two-step predecessor with no leftmost black cell (§2.1) | **Reopen** for the Lean, then close its first half |
| **I93** (23 Nov) | "if one of them is wanted outward" | The Direction now asks for extensions of `Rule30RunTransitions`, and PR 381 *is* that module (in the kit since 22 Nov). I95's Lean builds unchanged on the kit | **Reopen** as a submission track |
| **I152** (24 Nov) and **K50.1/K81** (23 Nov) | K50.1: a whole-cone refusal of a Y stay; the loss of S 2¹⁶ with a return-budget bound; a use of the finite far field | **The wheel cannot turn sixteen times in a row** beside any alternating column, any right half (solver, §2.2). A finite half stays on Y's schedule for 470 readings (§2.3) | **Record**, and merge I152 into K50.1; restate the Y condition |
| **I72** (23 Nov) | limits at irrational points; 155 least at (9/10, 2/5); the one-third corner | Mathlib allowed; the kit's `schedule` already takes any durations | **Reopen** if wanted: real points, half a day |
| **M10** (23 Nov) | a Q01 proof route to test | K84 and K83.A work on Q01's long-lived wests, with no mechanism yet | Keep, and apply when one is proposed |
| The wall, K5, I35, K26, K3, K25's three | a proof idea or counterexample at period ≥ 64; a reduction for every count of marks | Quint's `Rule30FirstLossBounds` (24 Nov, after N11) | Keep (§3.1) |
| **M6** (17 Nov) | minimisers' deficits bounded beyond H = 180 | Galindo's `Rule30MassCounterexamples` | Keep (§3.2) |
| **K50.2** (24 Nov) | a finite-support weight argument, or a strip constraint that removes part of the 5/11/22 classes | the wheel's refusal removes 3/5 words, but at 449 readings | Keep (§3.3) |
| **I77** (25 Nov) | a compact invariant for the pulse domains; a bound for arbitrary spacers; a recurrent black mark | Galindo's PR #429 (eastern realizability) | Keep; #429 worth a read |
| **I66** (25 Nov) | a use of priority, net or shell; a comparable uniform arrival law for another centre | S16 and S21 give period three's entry law, for finite halves only | Keep; a census test is named (§3.4) |
| **R5** (25 Nov), **M9** (24 Nov), **I49** (23 Nov) | as written | nothing | Keep |
| **K50.4, R3, R6, M8, R4, M7** (17–22 Nov) | as written | Lowry's `Rule30EdgeSourcePulse` is the nearest, for R6 and R4 | Keep (§3.5) |
| **M29 (T)** (the owner's, 21 Nov) | — | — | Keep |

### In order of what I would do

1. **K50.3: one Lean theorem, then close its first half.** Its open question has an answer: **age 24 is sharp on the line** (COMPUTED, two programs,
   [note](../k50_3/claudeIntel-line-age-23.md)). S6's `predecessor_edge_fails_at_age_seven` is the model: a finite seed, explicit z and y, the middle checked
   by `decide` and the tails by hand. Here `evol x 23` must go through a list form of the row. One to two hours, then a read by a GPT worker. S6's module
   would then say "from age 8 (sharp) and from age 24 (sharp)". K63's forms beside a prescribed wall stay parked.
2. **I93: a submission track that extends `Rule30RunTransitions`.** I95's sharp two-run table ([README](../black-run-transitions/README.md)) adds runs of 4, 6
   and 8 after a run of at least 15, 16 and 14. The kit's rules allow those even runs only inside three-run windows. The table proves every threshold sharp and moves the
   exclusion from the singleton's centre to every site of every row with a leftmost black cell (`exact_pair`, `pair_clock_exclusion`; schedule
   (16, 4, 17, 6, 18, 8), which the kit's rules do not cover). Kurtuluş's windows are checked on five-cell strips from every state, so they should lift to the same
   generality through the kit's finite-left masked Jen (I have not checked this). One theorem would then carry the kit's rules and the new pairs at every finite-left site, with the pair thresholds sharp. That is
   an infinite family, the kind sw1sh asked for on #416. First steps:
   - the port is packaging, not repair. I95's seven modules (store `I84/two-black-run-thresholds.zip`, `144c09fd…`) compile unchanged on the kit
     build at `ebda8ce`; main's ten later commits add modules and change none it imports. The stock checker passes `exact_pair` and
     `pair_clock_exclusion` (15 and 19 constants replayed, standard axioms only). What remains is to write it as one module beside the kit's windows;
   - novelty against `Rule30RunTransitions`, #416 (324 words, which sw1sh questioned as a table) and Dyer's two-run families (these have long white
     runs, not isolated whites);
   - a read by a Claude worker, since gptIntel wrote it.
3. **The wheel (M181, I152, K81):** LRAT for the sixteen-turn refusal (being written now), the least number of turns (12 to 14 are running), then the run
   family (3 5ʳ)ᵏ. This belongs to M181, which is in progress. I152's own condition, the finite-support question of K50.1, is not what it answers.
   I would merge I152's entry into K50.1's and add the fact there.
4. **I72, if wanted.** `Rule30DensityMixtures.schedule` takes any sequence of certified controllers and any durations. So every real point of the
   pentagon needs only the durations ⌊e·wᵢ⌋ and a limit in ℝ, with the error still O(√n) (my reading of the module; not tried). That takes S9's "every rational point" to "exactly the closed
   pentagon". It would go in Mathlib form, on the portal or in the kit's `equivalents/`. Half a day.

## 2. Tests run tonight

### 2.1 K50.3: age 24 is sharp on the line (COMPUTED)

The seed `100110110011101` (black at 0, 3, 4, 6, 7, 10, 11, 12, 14) has at age 23 a predecessor z with the true edge and a predecessor y of z that is black on
all of (−∞, −24] and repeats `100` from site 36 on. The search tries every finite seed to width 21 against the only four tails a failure can have, so its
counts are exact. The controls reproduce the kit's age-7 witness `1001` and find nothing at age 8. At age 24 nothing fails to width 21. A second program,
with no shared code, checks F y = z and F z = `evol x 23` cell by cell. [Note, witness and counts](../k50_3/claudeIntel-line-age-23.md).

### 2.2 The wheel: no right half turns it sixteen times (COMPUTED, solver only)

On a strip of 80 columns beside the alternating column, with column 81 free at every tick (so a refusal holds for every right half), the gate word
(355555)¹⁶ from a kick is **UNSAT**: CaDiCaL 2.1.2, 17,623,666 conflicts, 9,519 s; CNF
`d2a06c9e5000f7e8a5d303638294af6103ca98b481bda554ec2f115b509ec8d1` (69,417 variables, 408,881 clauses) from
[claudeIntel_cone.py](../wheel/block-orders/claudeIntel_cone.py) as committed in N19. N19 gave this 0.55. A proof-producing rerun to drive D: is under way,
for lrat-check and cake_lpr. B¹², B¹³ and B¹⁴ at 80 columns and B¹⁶ at 96 are running. I stopped B²⁴ at 76 columns after 19,271 s without a verdict,
since it no longer bears on the question.

K81 left this open: "Whether a single right half can sustain either train forever remains open." For the wheel's train the answer is now no, pending
the certificate. For the other train, 3555, N19 measured a steady 0.80 bits a block to 903 readings, and I expect no refusal.

### 2.3 Y's schedule: a steady cost (MEASURED) and a stay of 470 readings (replayed)

[claudeIntel_ystay_split.py](../k50_1/claudeIntel_ystay_split.py) is N19's splitting sampler with the gate held to K80's Y schedule instead of one word:
gaps (2 | 45 | 4525)*, 10001 in every 57 samples, from a kick. A row on the schedule for N + 57 readings is outside the trap at N, so it answers K80's
N-sample question, terminal condition included. The log₂ mass of real rows on the schedule falls by
**0.137 bits a reading, steadily**, from 150 to 400 readings (2,048 particles: −54.9 bits at 399; 12,288 particles: −52.4 at 394).

**A finite right half stays on Y's schedule for 470 readings.** Its first 814 cells, all later cells white, pass gptIntel's own `gate_check` from
[gptIntel-k80-stays.py](../wheel/gptIntel-k80-stays.py) at 400 samples, terminal window outside the trap included (window 45209 at sample 399). That is
the check gptIntel's driver applies to a model of its 400-sample instance (`912d009f…`), so **that instance is satisfiable**, and gptIntel's 37-hour run on it can be stopped.
The whole row has support 1,005 and passes at 300, 344, 345, 400, 450 and 470.
[Replay](../k50_1/claudeIntel_ystay_replay.py) · the row is in the evidence archive. A run to 560 readings, for the 500-sample instance, is going.

*Reading.* N19's trains that cost 0.09 bits a reading or more grew dearer with every copy. Y's whole schedule does not. K50.1's first condition, a
whole-cone refusal of a Y stay, would need a length well past 470, and a steady cost makes one unlikely. I would restate that condition, or drop it.

## 3. Notes on the entries I would keep

### 3.1 The wall and its company

Quint's `Rule30FirstLossBounds` came after N11. For every exponent e, nine whites or eight blacks in a row on wheel a + 1 force a catch within nine or
eight wheels, and the next white wheel is at least 5, 21 and 23 wheels on for e ≥ 0, 1 and 2. So an uncaught tick lies within eight ticks of a change of
the first wheel. I35's surviving rows end seven ticks after their last mark, which agrees. Nothing in it reduces the count of marks, so I35's condition is
not met, and the wall's is not either. K5's written test (the trace restricted to doubled inputs against the census) is still unrun. It would give a pooled
estimate, not a proof.

### 3.2 M6

Galindo refutes Conjecture S and its even form with G words H = 7A + 9 arbitrarily late, and shows that any floor H ≤ qA + d needs q ≥ 7, with d ≥ 9 at
q = 7. M6's finding for G, that the floor's slope is the ether's 1/7, stands. M6's own test, the gap language's minimisers past H = 180, is unrun and
wants compiled code. Tonight Windows' application control on the Intel refused a newly built executable of mine, twice; programs built earlier
still run. That is the owner's setting and I have not touched it.

### 3.3 K50.2

The wheel's refusal does change the 3/5 class that K50.2 leaves to the left seed: no word with (355555)¹⁶ survives. But it does so at 449 readings, far past
the 6-, 9- and 12-sample classes the condition names. Late windows lie in the trap, in X or in Y (R65, R69), which removes only words that cross between
them. Keep.

### 3.4 I66

Period three has an entry law (S16, with S21's sharp slope of three), but it is for finite halves, linear in their support, and S21's infinite half avoids
it for ever. So it is not uniform the way S18's is at period two. A test that could meet
the condition: for each primitive centre word of period 4 to 6, the eventual image of the free-edge window graph at 12 to 20 columns, and whether its
outside part becomes acyclic as period two's does at 21. Not run.

### 3.5 R6 and R4

Lowry's `Rule30EdgeSourcePulse` (20 Nov) shows that the right-edge sources of depth at most k contribute one pulse at 2^(k+2) − 1 and then nothing for
2^(k+1) − 1 ticks, and that a repeated centre reading forces deeper sources' parities to differ. That is a dyadic cancellation of the shallow sources only.
It is not one that survives doubling (R6), nor a bound on deep-source occupancy (R4).

## 4. Not done

- The Lean for K50.3, and its read.
- I93's novelty check and the module that joins it to the kit's windows.
- The wheel's LRAT under both checkers. cake_lpr needed a 7 GB heap for a proof this size (I212), and this host has about 3 GB free while the two
  general Y runs hold 4.6 GB.
- The I66 census and M6's run.
- The two general Y runs are gptIntel's. I have not touched them. A third process of gptIntel's, `slice-lrat.py` on I77's `pair14-first`, has run since
  16:31 UTC.

`Felt: pull, "Hughes's age-23 control is cofinite; one on the line should be too", at K50.3's entry, warm. -> the four tails and a search. Outcome: right, at width 15.`
