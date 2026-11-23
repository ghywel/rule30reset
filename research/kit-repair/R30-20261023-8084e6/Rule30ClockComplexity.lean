module

public import Ruliology.CellularAutomata.Rule30ClockNearSquares
public import Ruliology.CellularAutomata.Rule30FiniteConfigs

/-!
# Factor complexity beside a period-2 center column

Suppose column `0` of a configuration `x0 : Int → Bool` reads the clock `0101…` from some time `T0` on, and the
configuration has a leftmost black cell, `L ≥ 1` cells left of column `0`. Call column `1` at even times the
*visible bits*, `visible x0 i = evol x0 (2 * i) 1`, as in `Rule30ClockNearSquares`.

* `clock_complexity`: the number of distinct blocks of length `n` of the visible bits exceeds `n` by more than any
  constant. For every `C`, `n + C < factorCount (visible x0) n` for all large `n`.
* `low_complexity_excluded`: so no word with `factorCount f n ≤ n + C` for infinitely many `n` is the sequence of
  visible bits. This needs no hypothesis that the word is aperiodic.
* `sturmian_complexity_excluded`: in particular no word with at most `n + 1` blocks of each length `n`. The aperiodic
  words of that kind are the Sturmian words, of every slope and every intercept (Morse and Hedlund, 1940).

**Method.** Two kit theorems meet. `Rule30ZeroWallDiagonals.complexity_of_bounded_lag` says that a word which is not
eventually periodic, and whose repeats of length `n` with later start at most `n + K` have bounded lag, has more
than `n + K` blocks of length `n` for all large `n`. Read backwards (`repeats_of_low_complexity`), a word with at
most `n + C` blocks for infinitely many `n` has repeats at unbounded lags that fall short of their later start by a
fixed amount. Those are the pairs that `Rule30ClockNearSquares.corollary_F` forbids. A clock that starts at `T0`
is met by passing to the tail of the visible bits from `T0`, which has no more blocks (`factorCount_tail_le`).
The visible bits are not eventually periodic (`visible_not_eventuallyPeriodic`): under the clock, column `-1` is
black at odd times and the complement of column `1` at even times, so it would be eventually periodic beside the
periodic column `0`, against Jen's theorem for configurations with a leftmost black cell
(`Rule30FiniteConfigs.not_adjacent`).

**Credit.** The clocked bound is Jen's (E. Jen, J. Stat. Phys. 43, 1986). That an aperiodic word has a right-special
factor of every length, and at least `n + 1` blocks of length `n`, is Morse and Hedlund's. The exclusion of every
Sturmian word beside the clock is the Lean-verified submission `R30-20261023-8084e6`, whose proof uses the real
slope and intercept; here the hypothesis is the block count alone.
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30ClockComplexity

open Rule30Realization (evol)
open Rule30Jen (EventuallyPeriodic)
open Rule30ZeroWallDiagonals (factorCount Occurs blk code_congr countBelow_le_of_imp complexity_of_bounded_lag)

/-- The visible bits: column `1` at even times. -/
def visible (x0 : Int → Bool) (i : Nat) : Bool := evol x0 (2 * i) 1

/-- A tail of a word has at most as many blocks of each length as the word. -/
theorem factorCount_tail_le (f : Nat → Bool) (t0 n : Nat) :
    factorCount (fun i => f (i + t0)) n ≤ factorCount f n := by
  unfold factorCount
  refine countBelow_le_of_imp (2 ^ n) (fun c _ h => ?_)
  obtain ⟨i, hi⟩ := h
  refine ⟨i + t0, ?_⟩
  rw [← hi]
  unfold blk
  exact code_congr n (fun r _ => by
    show f (i + t0 + r) = f (i + r + t0)
    rw [show i + t0 + r = i + r + t0 by omega])

/-- A tail of a word that is not eventually periodic is not eventually periodic. -/
theorem tail_not_eventuallyPeriodic {f : Nat → Bool} (h : ¬ EventuallyPeriodic f) (t0 : Nat) :
    ¬ EventuallyPeriodic (fun i => f (i + t0)) := by
  rintro ⟨T, P, hP, hper⟩
  refine h ⟨T + t0, P, hP, fun t ht => ?_⟩
  have e : f (t - t0 + P + t0) = f (t - t0 + t0) := hper (t - t0) (by omega)
  rw [show t - t0 + P + t0 = t + P by omega, show t - t0 + t0 = t by omega] at e
  exact e

/-- **Low complexity gives repeats at unbounded lags.** If `f` is not eventually periodic and has at most `n + C`
blocks of length `n` for infinitely many `n`, then for some slack `K` there are pairs `i < i'` with `i' - i`
unbounded such that `f (i + s) = f (i' + s)` for every `s + K < i'`. This is
`Rule30ZeroWallDiagonals.complexity_of_bounded_lag`, read backwards. -/
theorem repeats_of_low_complexity {f : Nat → Bool} (hnp : ¬ EventuallyPeriodic f) (C : Nat)
    (hlow : ∀ N, ∃ n, N ≤ n ∧ factorCount f n ≤ n + C) :
    ∃ K, ∀ N, ∃ i i' : Nat, i < i' ∧ N ≤ i' - i ∧ ∀ s, s + K < i' → f (i + s) = f (i' + s) := by
  refine Classical.byContradiction fun hno => ?_
  have hbl : ∀ K, ∃ B, ∀ i j n, i < j → j ≤ n + K →
      (∀ r, r < n → f (i + r) = f (j + r)) → j - i ≤ B := by
    intro K
    refine Classical.byContradiction fun hK => hno ⟨K, fun N => ?_⟩
    refine Classical.byContradiction fun hN => hK ⟨N, fun i j n hij hj hag => ?_⟩
    exact Nat.le_of_not_lt fun hlt => hN ⟨i, j, hij, by omega, fun s hs => hag s (by omega)⟩
  obtain ⟨N, hN⟩ := complexity_of_bounded_lag hnp hbl C
  obtain ⟨n, hn, hle⟩ := hlow N
  have := hN n hn
  omega

/-- **The visible bits are not eventually periodic.** Under the clock, column `-1` is black at odd times and the
complement of column `1` at even times. So eventually periodic visible bits would make columns `-1` and `0` both
eventually periodic, against Jen's theorem for configurations with a leftmost black cell. -/
theorem visible_not_eventuallyPeriodic (x0 : Int → Bool) (L : Nat) (hc : x0 (-(L : Int)) = true)
    (hl : ∀ j < -(L : Int), x0 j = false) (T0 : Nat)
    (hclock : ∀ t, T0 ≤ t → evol x0 t 0 = decide (t % 2 = 1)) : ¬ EventuallyPeriodic (visible x0) := by
  rintro ⟨T, P, hP, hper⟩
  have h0 : EventuallyPeriodic fun t => evol x0 t ((-1 : Int) + 1) := by
    refine ⟨T0, 2, by omega, fun t ht => ?_⟩
    show evol x0 (t + 2) ((-1 : Int) + 1) = evol x0 t ((-1 : Int) + 1)
    rw [show (-1 : Int) + 1 = 0 by omega, hclock (t + 2) (by omega), hclock t ht,
      show (t + 2) % 2 = t % 2 by omega]
  have hm : EventuallyPeriodic fun t => evol x0 t (-1) := by
    refine ⟨T0 + 2 * T, 2 * P, by omega, fun t ht => ?_⟩
    show evol x0 (t + 2 * P) (-1) = evol x0 t (-1)
    have a := Rule30ClockNearSquares.col_m1 x0 T0 hclock t (by omega)
    have b := Rule30ClockNearSquares.col_m1 x0 T0 hclock (t + 2 * P) (by omega)
    rcases Nat.mod_two_eq_zero_or_one t with he | ho
    · obtain ⟨k, rfl⟩ : ∃ k, t = 2 * k := ⟨t / 2, by omega⟩
      have e : visible x0 (k + P) = visible x0 k := hper k (by omega)
      unfold visible at e
      rw [b.2 (by omega), a.2 he, show 2 * k + 2 * P = 2 * (k + P) by omega, e]
    · rw [b.1 (by omega), a.1 ho]
  exact Rule30FiniteConfigs.not_adjacent hc hl (-1) hm h0

/-- **The block count of the visible bits outgrows `n + C`.** A configuration with a leftmost black cell `L ≥ 1`
cells left of column `0`, whose column `0` reads the clock `0101…` from time `T0`, has for every `C` more than
`n + C` distinct blocks of length `n` in its visible bits `evol x0 (2 i) 1`, for all large `n`. -/
theorem clock_complexity (x0 : Int → Bool) (L : Nat) (hL : 1 ≤ L) (hc : x0 (-(L : Int)) = true)
    (hl : ∀ j < -(L : Int), x0 j = false) (T0 : Nat)
    (hclock : ∀ t, T0 ≤ t → evol x0 t 0 = decide (t % 2 = 1)) (C : Nat) :
    ∃ N, ∀ n, N ≤ n → n + C < factorCount (visible x0) n := by
  refine Classical.byContradiction fun hno => ?_
  have hlow : ∀ N, ∃ n, N ≤ n ∧ factorCount (fun i => visible x0 (i + T0)) n ≤ n + C := by
    intro N
    refine Classical.byContradiction fun hN => hno ⟨N, fun n hn => ?_⟩
    refine Nat.lt_of_not_le fun hle => hN ⟨n, hn, ?_⟩
    exact Nat.le_trans (factorCount_tail_le (visible x0) T0 n) hle
  have hnp := tail_not_eventuallyPeriodic (visible_not_eventuallyPeriodic x0 L hc hl T0 hclock) T0
  obtain ⟨K, hK⟩ := repeats_of_low_complexity hnp C hlow
  refine Rule30ClockNearSquares.corollary_F x0 L hL hc hl T0 hclock (K + T0) (fun N => ?_)
  obtain ⟨i, i', hii, hN, hag⟩ := hK N
  refine ⟨i + T0, i' + T0, by omega, by omega, by omega, fun s hs => ?_⟩
  have e : visible x0 (i + s + T0) = visible x0 (i' + s + T0) := hag s (by omega)
  unfold visible at e
  rw [show i + T0 + s = i + s + T0 by omega, show i' + T0 + s = i' + s + T0 by omega]
  exact e

/-- **No word of low complexity is the visible word beside a clock.** If `f` has at most `n + C` blocks of length
`n` for infinitely many `n`, no configuration with a leftmost black cell `L ≥ 1` cells left of column `0`, whose
column `0` reads the clock from time `T0`, has `f` as its visible bits. -/
theorem low_complexity_excluded (f : Nat → Bool) (C : Nat)
    (hlow : ∀ N, ∃ n, N ≤ n ∧ factorCount f n ≤ n + C)
    (x0 : Int → Bool) (L : Nat) (hL : 1 ≤ L) (hc : x0 (-(L : Int)) = true)
    (hl : ∀ j < -(L : Int), x0 j = false) (T0 : Nat)
    (hclock : ∀ t, T0 ≤ t → evol x0 t 0 = decide (t % 2 = 1))
    (hvis : ∀ i, evol x0 (2 * i) 1 = f i) : False := by
  have hf : visible x0 = f := funext hvis
  obtain ⟨N, hN⟩ := clock_complexity x0 L hL hc hl T0 hclock C
  obtain ⟨n, hn, hle⟩ := hlow N
  have := hN n hn
  rw [hf] at this
  omega

/-- **No word with at most `n + 1` blocks of each length `n`,** in particular no Sturmian word of any slope and any
intercept, is the visible word beside a clock. -/
theorem sturmian_complexity_excluded (f : Nat → Bool) (hst : ∀ n, factorCount f n ≤ n + 1)
    (x0 : Int → Bool) (L : Nat) (hL : 1 ≤ L) (hc : x0 (-(L : Int)) = true)
    (hl : ∀ j < -(L : Int), x0 j = false) (T0 : Nat)
    (hclock : ∀ t, T0 ≤ t → evol x0 t 0 = decide (t % 2 = 1))
    (hvis : ∀ i, evol x0 (2 * i) 1 = f i) : False :=
  low_complexity_excluded f 1 (fun N => ⟨N, Nat.le_refl N, hst N⟩) x0 L hL hc hl T0 hclock hvis

end Ruliology.CellularAutomata.Rule30ClockComplexity
