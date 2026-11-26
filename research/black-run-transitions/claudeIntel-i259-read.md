# Carrying read of I259: run-transition windows at every site

claudeIntel, N24, 26 November 2026. It answers I259's REVIEW flag and the owner's "continue pull I93". Packet `share-scratch/gptIntel/I93/I259-run-transition-windows.zip`,
`c1233524…`, read back; its kit module equals the committed [Rule30RunTransitionWindows.lean](Rule30RunTransitionWindows.lean), `008768bc…`.

## Verdict

**PASS.** The Lean says what [joint-windows.md](joint-windows.md) says. The three parts I was asked to check all hold: the clipping of the finite witnesses, the
window at an arbitrary transient, and the strict example. I found one gap in the novelty check, Dyer's mixture entries (§4). It can be closed only from the
M5, and I do not expect it to change the verdict.

## 1. Replay (mine)

- Kit build at `ebda8ce` (`Rule30RunTransitions` and `Rule30FiniteStrips` are unchanged up to main `71151d0`): compiles in 17 s.
- Stock checker on the seven headlines (`exact_pair`, `pair_forces`, `old_forcing_window`, `exclude_of_windows`, `not_eventually_combined`,
  `both_colours_below`, `mixedExample_requires_both`): **pass**, 151 constants replayed, standard axioms only, none new. That is gptIntel's count.
- `leanchecker`: pass, 51 s.
- Not repeated: the portable form at the verifier's pin. The shared pin folder does not have `Rule30FiniteStrips` built, and it is read-only for me. gptIntel's
  receipt says it passes there with 209 constants.

## 2. The table, by another route (COMPUTED, my own code)

[claudeIntel_cone_table.py](claudeIntel_cone_table.py) uses no strips. Column 0 is driven by the window, which any left half can supply. Column 1 at the next
tick depends only on the initial cells 1 to L + 1, so the script tries all 2^(L+1) right halves of the light cone (2^24 at r = 6, a = 16).

| r | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9, 10, 11 |
|---|---|---|---|---|---|---|---|---|---|
| At a = cutoff | white | black | white | black | white | black | white | white | white at a = 0 |
| At a = cutoff − 1 | both | both | both | both | both | both | both | both | — |

This is I95's table exactly, from the whole cone rather than the width-seven strip. Forcing is monotone in a (`prefix_irrelevant`), so both statements
hold for every a on their side of the cutoff.

## 3. The three steps I was asked about

**Clipping (`both_colours_below`). Right.** The witness y is copied to z on [−W, W + 1], with one black cell at −W − 1 and white elsewhere. `evol_local` gives
z = y wherever −W + t ≤ k and k + t ≤ W + 1. Every observation lies in that cone: column 0 at the ticks t ≤ W of the window, and column 1 at tick W. The added black
spreads east at speed one, so at tick t it reaches −W − 1 + t at most, outside the cone. Then z has a leftmost black cell and finite support, and the
translation by j moves the observation to any site. The witness depends on the colour asked for and on the window, which the note says.

**Arbitrary transient (`exclude_of_windows`). Right.**
- Every window chosen is at most B = 3·len + 25 long (`old_forcing_window` gives 3·len + 16, and the pair windows are at most 25).
- From T + B on, a window ending at a white tick lies wholly in the periodic tail. `drive_of_endsWith` turns `EndsWith` into an actual drive by
  reducing ticks modulo the period, including windows longer than the word, which wrap.
- Two white ticks one period apart have the same phase, so they get the same certificate and the same right reading. Finite-left masked Jen
  (`Rule30FiniteMaskedJen.masked_jen`) then excludes the word.
- Nothing assumes isolated whites, so the reduction holds for any word whose white phases are all covered.

**The strict example. Right.** [claudeIntel_family.py](claudeIntel_family.py) codes Kurtuluş's rules from the statement in `Rule30RunTransitions` and the pair
rule from the table, with no shared code. For (16, 4, 9, 1, 4, 9) followed by n nines, n = 0 to 40:
- the union covers every white;
- the kit's rules alone fail only at phase 21, the 4 after 16;
- the pair rule alone fails at phase 38, the 4 after 1, and also at the long runs, which only the kit's w9 covers;
- every word is primitive.

So the family is infinite as claimed, and the note's hand argument for all n agrees with the 41 members checked.

## 4. Novelty

- **`Rule30RunTransitions` (Kurtuluş).** It proves the theorem for the singleton's centre only. Runs of 4, 6 and 8 occur there only inside three-run windows,
  and it states no sharpness. New here: the pair cutoffs 15, 16 and 14, sharp; every threshold sharp even with finite rows; and the choice of rule phase by phase.
- **Lifting to every site is not itself new.** Lowry's `Rule30FiniteStrips` (`not_eventually_word_strip`, in the kit since 24 October) and Dyer's e99565 already take strip exclusions to any
  column of a row with a leftmost black cell, word by word. What I93 adds is one theorem for a family at every length, and the sharpness. The essay should credit
  Lowry's `Rule30FiniteStrips` for the method of lifting.
- **#416.** A finite list of words of lengths 14 to 18. sw1sh asked for a rule or a family, and this is one.
- **Dyer, cacfbd and 2b846f.** One black run and one white run per period (gptIntel read the notebooks). They are a different family.
- **Dyer, cade33 (not read at source).** "Free mixtures from seven run categories" at every column. Its page renders only in a browser, and its notebook needs
  Wolfram, which the Intel does not use. If one of the seven categories is a block 1^a 0 with a threshold, the family may overlap. **Ask:** claudeM5, read
  cade33's seven categories from its notebook before the abstract is written. The theorem is new as a statement either way; this decides only the credit line.

## 5. For the submission

The headline should be `not_eventually_combined`, with `exact_pair` as its sharp local half. `exclude_of_windows` is the reusable form. The example belongs
in the essay, not the abstract. Status words: the joint theorem and the 49-tick example are PROVED IN LEAN, and the family for every n is a hand proof that I
have checked to n = 40.
