# Carrying read: where marked gaps come from, and the colour counts (I321, I323)

*claudeIntel, 28 November 2026 (ledger N39), at I321's REVIEW flag. The objects of the read are
[launch.md](launch.md) and [MarkLaunch.lean](MarkLaunch.lean), SHA-256 `1cc76141…`, by gptIntel (I321–I323). The
asks were these:
- carry the birth and near-colour results against Lowry and the settled-run predecessors, including the inclusive
  endpoints and the frequency consequence;
- check the attribution;
- say whether either merits a submission.*

## Verdict

**CARRIED.** Every statement in launch.md that this read covers is what MarkLaunch.lean proves. Each proof was
checked by hand from the Rule 30 update and replayed in the kernel.
- **Replay:** core Lean 4.35.0 against the kit at `ea5d70e`, the commit the note names. It compiles in 4 s with no
  warnings, and `leanchecker MarkLaunch` passes.
- **Axioms:** the twelve headlines use only `propext`, `Quot.sound` and `Classical.choice` (`black_two_west` and
  `width_one_obstruction` use only the first two).

## What was checked by hand

Write c(t, p) for `Rule30Jen.cell` (one black cell at p = 0; `rule a b c = a xor (b or c)`, west first).

1. **`next_gap_iff` (the exact one-step law).** Suppose row t+1 is white on [−l, −1] with a black cap at −l−1.
   - The cell at −1 forces c(t, −2) = c(t, −1) or c(t, 0).
   - **Quiet pair:** c(t, −2) is white. Each white cell of row t+1 then forces the cell one further west white, down
     to −l−1, and the cap forces c(t, −l−2) black. That is `Gap t (l+1)`.
   - **Active pair:** c(t, −2) is black. Each white cell of row t+1 forces the cell one further west black, down to
     −l−1, and the cap forces c(t, −l−2) white. That is `Bar t l`.
   - Both converse directions are the same updates read forwards. The case l = 1 needs no separate treatment.
2. **`birth_of_mark` and `record_is_birth`.** A quiet step turns `Mark(s, l)` into `Mark(s − 1, l + 1)`, with the
   same arrival s + l. Row 0 has no black cell west of the centre, so the walk ends at a bar.
   - A strict record is one wider than every mark one row earlier, so its quiet predecessor would contradict it.
   - The prose says "every new width record must be born this way". The Lean hypothesis compares only with the marks
     at the row before, which is weaker and so implies the prose.
3. **`arrival_eq`.** The light cone of c(t + 1 + l, 0) on row t is [−l−1, l+1]. The bar fixes [−l−1, −2] black, so
   continuing black to the west changes nothing inside the cone. Unbounded marks are therefore equivalent to
   arbitrarily wide bars that pass this finite test (`unbounded_iff_births`). Lowry's kit theorem then gives
   `problem1_of_births`. It is conditional, and its hypothesis is open.
4. **Spacing (`wide_births_apart`, `collision_widths`, `band_arrivals_injective`).**
   - The bar's update clears its interior. Inside that white interval the black cap moves east one cell per tick,
     and site −d−1 stays white for d ticks.
   - A second bar of width at least 2d before then would need that site black.
   - Equal arrivals force the older width l to satisfy l ≥ 2m + 3. Otherwise the advancing cap lands on the younger
     bar's white flank.
5. **The colour counts.**
   - **Black:** the last black bar cell and the active pair give a black centre by t + 2.
   - **White:** four black centre ticks from t need c(t, −3) white, by Pérez Morales's black triangle in the kit, so
     a bar of width at least 2 gives a white centre by t + 3.
   - **Endpoints:** a birth before N gives a witness in [t, t + 3] ⊂ [0, N + 2]. That is `List.range (N + 3)`: the
     note's "before N + 3" is exact.
   - **Disjointness:** windows are disjoint at width ≥ 6, since births are at least four ticks apart (d = 3). At
     width ≥ 2 they are at least two apart, so no tick lies in three windows. Hence k ≤ 2·count, and ⌈k/2⌉ in the
     note is right.
6. **The fall counts.**
   - `fall_iff`: a black cell turns white exactly when its west neighbour is black.
   - Falls are at least two ticks apart, and each fall has c(t, −3) black, which gives F(N) ≤ 2·white₀(N + 3).
   - `budget_step` is the 5-bit inequality A_t + E_t ≤ E_{t+1} + 2C_t + C_{t+1} + C_{t+2}, decided by the kernel over
     all 32 cases. Its three right-hand terms are c(t+1, 1), c(t+1, 0) and c(t+2, 0), as the update gives them.
   - Summing telescopes the eastern terms and leaves black₋₂(N) ≤ 4·black₀(N + 2) + 1. F(N) ≤ black₋₂(N) holds
     because a fall starts on a black tick. The Lean states the black₋₂ bound, and the step to F is this one line.
7. **The frequency consequences.** Suppose F(N) ≥ ρN − o(N). Then the black centre count before N + 2 is at least
   (ρN − 1)/4, and the white count before N + 3 is at least ρN/2. So liminf black/N ≥ ρ/4 and
   limsup black/N ≤ 1 − ρ/2, with no assumption that the frequency exists. The same holds for births:
   [δ, 1 − δ] at width ≥ 6 and [δ/2, 1 − δ/2] at width ≥ 2, as the note says.
8. **Width one.** On the checkerboard fixed point the word 0101 sits at −3..0 at every tick, with the centre always
   black. So no width-one count can force white. It is a different initial row, as the note says.

## Attribution

- `next_gap_iff` specializes `Rule30SettledRepeats.back`, ours: Herbert, Claude and GPT, 22 November. The note
  credits it as the kit's white-run dichotomy.
- `Mark`, `first_failure_of_mark` and `problem1_of_marks` are Lowry's (`Rule30MarkedGaps`, with Codex).
  `problem1_of_births` is his theorem with the hypothesis restated.
- **The width-22 mark at age 34,428 is already in the kit:** Lowry's `Rule30OffCenterEcho`,
  `singleton_mark_and_echo` ("a marked gap of width 22 opens"). launch.md cites the census for it. It should also
  cite that kit theorem.
- The black triangle and the white-run reconstruction are Pérez Morales and Claude Fable 5.1's (`Rule30CenterRuns`,
  R30-20261024-03b551). The note credits them.
- Ulrey's `Rule30TwoBlockCounts` already relates centre blocks to the cells at −2 and −1 tick by tick, for example
  `center_two_step_black_independent_of_right`. It has no cumulative inequality like `black_two_west` and no fall
  count. Worth a line in the note.
- Existing logarithmic two-colour counts: `Rule30CenterRuns` (both colours in every window [a, 2a]), and
  AIOvernight's `Rule30BlackTimeGrowth` and `Rule30SettledBarrierEffective`. The new inequalities improve on these
  only when given a rate for falls at −2 or for births, which is open.
- The search found nothing else: `find_known` on black bar, gap birth, falls at −2, black-to-white transition and
  fall count, and a grep of the kit's Lean at `ea5d70e` for `Bar`, `next_gap_iff` and the column −2 counts.

## Does either merit a submission?

- **The birth theorem: a kit module, not a portal entry yet.** It is exact and general: every mark descends from
  one bar, and record widths are born. It turns Lowry's criterion into a statement about spatial black runs at one
  site plus a finite cone test. That is the right shape for the catalogue, beside `Rule30MarkedGaps`. As a portal
  entry it has no unconditional consequence for a prize problem: `problem1_of_births` is Lowry's conditional
  restated. I would package it with the next result that uses it.
- **The colour counts: one unconditional theorem worth stating alone.** The pair F(N) ≤ 2·white₀(N + 3) and
  black₋₂(N) ≤ 4·black₀(N + 2) + 1 holds for all N on the singleton. With them, any lower rate for one named event
  (falls at −2) gives a two-sided density bound for the centre. That is a clean reduction of the frequency half of
  Problem 2 to one fixed site. Packaged with the birth counts, it is a fair kit module, and a portal partial result
  if paired with even a superlogarithmic F(N). Alone it is a reduction, and the portal entry should say so.

Neither is a prize result on its own. I agree with I323's ordering: the superlogarithmic count of falls at −2
(K92.4.A) is the step that would make the counts bite.

## The census past 2^22: a marked birth of width 23

The read's research step was a direct evolution of the singleton (`claudeIntel_launch_census.cpp`, one barrier per
tick; `claudeIntel_launch_census2.cpp`, 64 ticks per barrier). It counts the observables of I322's census at every
birth tick. Registered in `16e5aee` ([predictions](data/claudeIntel-launch-census-predictions.txt)).

**Controls.** Both programs reproduce gptIntel's I323 census to 2^22 exactly: falls at −2 1,048,953; width ≥ 2
launches 787,329; width ≥ 6 49,123; black arrivals 376,457; widest marked births 22 at ticks 34,428 and 2,125,918.
They agree with each other line for line. The fast one took 55 s to 2^22 and 48 minutes to 2^25 on 12 threads.

**COMPUTED, to 2^25 birth ticks** ([table](data/claudeIntel-launch-census-2p25.txt)):

| Shell of birth ticks | Falls at −2 | Width ≥ 2 launches | Width ≥ 6 | Black arrival, of width ≥ 2 |
|---|---:|---:|---:|---:|
| [2^22, 2^23) | 24.995% | 18.755% | 1.179% | 47.79% |
| [2^23, 2^24) | 24.992% | 18.762% | 1.170% | 47.86% |
| [2^24, 2^25) | 24.992% | 18.747% | 1.174% | 47.83% |
| all of [0, 2^25) | 8,386,689 | 6,293,086 | 393,643 | 3,010,007 |

- **A marked birth of width 23, at birth tick 21,892,697.** The gap opens at 21,892,698, and the centre is black at
  21,892,721. It is the first marked width above the 22 that has stood since M220 and I323.
- **The widest bar of any arrival is still 25,** at 2,085,566, which has a white arrival.
- The fall rate at −2 stays at a quarter, the whole-line fair value 1/4. The width ≥ 2 launch rate stays at 18.75%,
  where the fair spatial value is 3/16 = 18.75%.

All four predictions held:
- C1: a marked width above 22, as the believed truth predicts;
- C2: the widest bar is 25;
- C3: the shell rates;
- C4: black arrivals within [47%, 49%].

These are finite counts on the single seed. They support the believed truth, unbounded marked widths, and prove no
part of it.
