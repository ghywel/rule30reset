# A read of K83.A (I229)

claudeIntel, N16, 24 November 2026. Asked in I229: "an independent read of the past-wall source, its adaptive corollary and
priority would decide whether to develop a portal partial". The owner asked for the review of the block.

## Verdict

1. **The Lean source passes.** `K83RightCoin.lean` says what its text says.
2. **The adaptive corollary is right, and is now PROVED IN LEAN,** in a more general form (below).
3. **The reduction of A1 is right, and is now PROVED IN LEAN,** for every period.
4. **Every count I recomputed is exact.** None of my programs shares code with gptIntel's.
5. **One finding changes the weight of the forward part.** For period two, a finite left half of width at most 52 cannot sustain
   the alternation at all, for any right half: that is the kit's `q01_width_le_52`. So the fixed-B limit is already 0 for
   B ≤ 52, with no probability in it.
6. **No portal partial from this yet.** The past-wall law gives nothing for Problems 1 to 3 on its own. It and the reduction are
   the Lean base for A1 if A1 is ever proved.

## 1. The past-wall law

*Read.* `after w T r` is the right half at time T of the unique row with centre trace w and right half r. `ae_read_past` goes back
one tick at a time. Each step needs 010 arbitrarily far east in the row it leaves, which `ae_isNormal_rows` gives at every
time. `after_exact` rests on one almost-everywhere identity of events in the full fair row. The direction that needs the decoding is
"final right half in the range ⇒ the wall prefix is w", and there `x` is the almost-sure row and the comparison row is the
realizing one, which is the order `ae_read_past` is stated in. Independence and the time-slice law do the rest. `T = 0` is included.
`incompatible_pasts`, `long_past_null` and `countable_long_past_null` follow.

*Replay at the pin.* Compiles in 60 s here, the packet's copy is byte-identical (`52c1c53b…`), stock check: 10 headlines, 13 declared,
27 constants, no new axioms, `leanchecker`.

*The text around it.* The decoder's band arithmetic, the union bound T(7/8)^m, the 24 sites, the nested ranges, "closed and null,
so nowhere dense", and the martingale argument for Σ 2^(−d(p)) are right. `no_column_eventually_constant` and
`orCol_not_eventuallyPeriodic` assume a leftmost black cell and nothing on the right, as the reduction needs.

## 2. The adaptive corollary and the reduction, in Lean

[K83Feedback.lean](K83Feedback.lean), on top of gptIntel's file, at the pin: 60 to 90 s, 7 headlines, 20 declared, 57 constants, no
new axioms, `leanchecker`.

| Theorem | Content |
|---|---|
| `driven_exact` | for *any continuous* rule W that chooses the wall from the initial right half, even looking ahead: 2⁻ᵀ μ(G⁻¹E) = μ(range G ∩ E), G the right half at time T |
| `later_exact`, `mass_later` | the corollary: beside any fixed left half, finite or not, the right half at time T has law 2ᵀ μ on a closed set of measure 2⁻ᵀ |
| `driven_null` | null events stay null under any such feedback |
| `reduction` | if, beside every finite left half with a black site, each purely periodic centre word from time zero has a null set of right halves, then beside every such left half the centre is almost surely not eventually periodic |

`driven_exact` contains `after_exact` (W constant). The proof does not cut the right halves by their first T centre bits. It integrates over
the wall first: for each right half the wall agrees with W on T ticks with probability 2⁻ᵀ. `reduction` is I229's "restart
at a specified time" with the countable union over finite left halves, transients and periodic words, and it keeps the black
site of the left half (`left_black`). It confirms the corrected form of K83's equivalence. The gate enters only after it, through the
coupling, and I did not formalize that.

## 3. What I recomputed

| Claim | Mine |
|---|---|
| gate words, H = 5, 9, 12, 14 and 15, both phases | bit-sliced enumeration of 2³⁰ and 2²⁹ prefixes: 237 and 251 words, **all bins equal** to the packet's table; maxima 71,024,640 and 21,974,016 at `001000010000100` |
| the four attaining rows | alternate through ticks 30, 31, 33 and 32 (claimed 30, 29, 30, 29) |
| distinct wests, least depths 19 and 20, the B table (19, 20, 24) | equal, with my decoder, which matches whole-row evolution on 600 random rows |
| S12's fork | my CNF and CaDiCaL: readings 0 to 47 forced on the 28-cell prefix, 48 free both ways; white forced at 48 on the 35-cell prefix; the 64 six-cell witnesses spell `0000101` for 700 samples; exactly 5 of 8 three-cell extensions forced (to sample 120) |
| the eight two-colour certificates | 16 of 16 forced, by SAT |
| trap basin, W = 16, 20, 24, 28 | 6,594; 283,491; 6,848,990; **138,081,872**, all equal, from the kit's 829 windows, whose closure I rechecked |
| the sums 52.6718%, 52.67236%, 1.232854% and the atom total | equal as fractions |
| the one-tick decoder | brute force over all old rows to 14 cells: the run rule, the generating function, the recurrence, E[R] = 8 |

*Extended:* the trap bound at W = 30, 32 and 34 is 598,646,850 / 2³⁰ (55.75%), 2,557,066,280 / 2³² (59.54%) and
**10,797,628,217 / 2³⁴ (62.85%)**. COMPUTED, one program, the trap alone.

*Not checked:* the ether and seven-lock cylinder counts, the million-row cohort, the LRAT proofs themselves, the d₆₄ tables, the
census 7.64229% to 12.16486%, the prior art on the reset sweep (Wolfram, Jen, Spencer).

## 4. The finding: the kit already decides fixed B up to 52

At a black centre tick the next centre bit is white, so column −1 must be black there. That is a condition on the left half
alone, and while it holds the left half evolves as beside a white wall. It is the kit's `InX`. `q01_width_le_52`: every
row supported on depths 1 to 52 is white at depth 1 at some even time at most 96. So:

- **E(B, T) is empty for every B ≤ 52 and T ≥ 97,** black first. For white first use B ≤ 51 and one tick more, since the row one
  tick later is one deeper. No right half escapes, and no measure is needed.
- The table's 26,151,424 at B = 19 is a tick-30 figure. COMPUTED here: the longest alternation of any west of depth exactly b, the right
  half free, black first: 38 ticks at b = 19, 30 at 20, 42 at 24, 48 at 28 (white first 29, 37, 41, 47).
- The bounds 6.6147% and 4.0930% are for *every* left half, infinite ones included, where they mean something (a lock is an atom). For
  a finite left half of width at most 52 the probability of immediate everlasting alternation is 0.
- **A1 for period two fails only if Q01 fails.** The event is empty unless the left half at the restart is an immortal row. So
  it is "CQ01 for almost every right half", a weakening of CQ01 and of Q01. What A1 adds is only at transients so long that the left
  half is wider than 52.
  *Corrected (I235): the kit's named `CQ01` has a finitely supported right half as well, so it does not imply this. Q01 does. What
  is meant is CQ01's condition with the right half quantified over almost every row.*

This does not make A1 wrong as a pull. It moves the first test. "Survival tends to zero at each fixed west width" is a theorem
of the kit up to 52 and its content beyond that is Q01's. What is A1's own is the atom side: an immortal row X prescribes one gate
word γ(X), and one must show that almost no right half reads it. γ(X) is not arbitrary. It obeys the nine pairs (S18), has no
near-squares (`corollary_F`), no long excess repeats (Jen), no bounded excess of factors, and since N15 it is not a two-block
rotation order. Also, if A_γ is the set of right halves reading γ, the sets for the shifts of an aperiodic γ are disjoint and
μ(A_σγ) ≥ μ(A_γ)/4 (from `driven_exact`, two ticks), so the shifts' masses have sum at most 1 and lose at most a factor of 4 a
sample. I do not see a contradiction in that alone.

**Suggested next test for K83.A** in place of fixed B: take the longest-lived wests of depth 50 to 60 (the kit's death-time
witnesses), compute their gate words to the death time, and the exact share of right halves reading them. If that share falls
like 2^(−cT) with one c for all of them, there is something to prove.

## 5. Priority

- *Kit* (`equivalents/` at `4bb3a7b`): `rightHalf` occurs in `RandomConfigurations` alone. `Mixing` has invertibility almost everywhere and
  `Invertibility` has the measure-preserving inverse and the two-sided trace, all for full fair rows. No one-sided range, no density 2ᵀ,
  no feedback.
- *Portal* (419 entries at 18:28 UTC, 24 November, abstracts searched for *almost every, fair, measure, coin, probability*): none on a fair right half
  beside a prescribed wall or a fixed left half. 4767e0 and 4d1a54 (ours) bound how many words the right neighbour can read.
- *Literature:* two web searches found nothing that states it. The nearest are the K-property and Bernoulli property of permutive
  automata (Shereshevsky; cited, not read by me) and boundary-driven reversible automata, which are another setting.
- *Judgement.* The law is a short consequence of two kit theorems (trace and right half independent; time slices fair) and the
  010 decoding, which is classical. New, as far as we searched, is the statement on one half-line, exact and with feedback.

## 6. Portal or not

Not now. METHOD §12 rule 4 asks what it gives. For the single cell the right half is one point of measure zero, and for a fixed left
half the law says how the right half is distributed, not what the centre does. `reduction` is conditional. If A1 is proved for some
period, the two files are its measure half, ready. If the owner wants a Mathlib-side contribution sooner, the natural home is the
kit's `equivalents/` beside `Invertibility`, as a theorem on random configurations, and not a Problem 1 partial.

## 7. Wording to repair

1. `k83a-gate-mass.md`: after the first paragraph, say that for finite left halves of width at most 52 the everlasting event is empty
   (`q01_width_le_52`), and in its last section that the limit is 0 for B ≤ 52 and what is open starts at 53.
2. `k83a-gate-mass.md`, the B table: "survival to tick 30 (29)" in the caption.
3. `right-coin-past.md`: the adaptive deduction and the restart are formal now; link `K83Feedback.lean`.
4. K83's README, A1: add that for period two the event needs an immortal row, so A1 is implied by Q01. *(Corrected, I235: not by the named CQ01, whose right half is finite.)*
