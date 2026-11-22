module
public import Ruliology.CellularAutomata.Rule30ClockNearSquares

/-! Two applications of the kit clock theorem. The arithmetic input in the second theorem is
the prefix equality proved by hand for the quarter-phase silver word in `silver-quarter.md`. -/

@[expose] public section
namespace Rule30RotationRepeats

open Ruliology.CellularAutomata
open Rule30Realization (evol)

/-- Integer squares certify the nearest integers to `t√2` for `0 ≤ t ≤ 18`. At lag 7 the rounded
displacement is 10 up to time 10, then 9 at time 11. The lower natural subtraction also covers `t=0`. -/
theorem quarter_base_certificate :
    ∃ v : Nat → Nat,
      (∀ t : Fin 19, (2 * v t - 1) ^ 2 ≤ 8 * (t : Nat) ^ 2 ∧
        8 * (t : Nat) ^ 2 < (2 * v t + 1) ^ 2) ∧
      (∀ t : Fin 11, v (t.val + 7) = v t + 10) ∧ v 18 = v 11 + 9 := by
  refine ⟨fun t => ([0,1,3,4,6,7,8,10,11,13,14,16,17,18,20,21,23,24,25] : List Nat).getD t 0, ?_⟩
  decide

/-- Unbounded common lags and excesses on half-open intervals exclude an eventual visible word.
The clock onset is measured in physical ticks and the word onset in even-time samples. -/
theorem no_eventual_visible_of_repeats
    (x : Int → Bool) (L T0 H : Nat) (hL : 1 ≤ L) (hc : x (-(L : Int)) = true)
    (hl : ∀ j < -(L : Int), x j = false)
    (hclock : ∀ t, T0 ≤ t → evol x t 0 = decide (t % 2 = 1))
    (c : Nat → Bool) (hvis : ∀ t, H ≤ t → evol x (2 * t) 1 = c t)
    (hrepeats : ∀ B : Nat, ∃ a b q : Nat, B ≤ q ∧ 2 * a + q + B ≤ b ∧
      ∀ t : Nat, a ≤ t → t < b → c t = c (t + q)) : False := by
  apply Rule30ClockNearSquares.corollary_F x L hL hc hl T0 hclock 0
  intro N
  obtain ⟨a, b, q, hq, hb, agree⟩ := hrepeats (N + 2 * (H + T0) + 1)
  let i := a + H + T0
  refine ⟨i, i + q, by dsimp [i]; omega, by omega, by dsimp [i]; omega, ?_⟩
  intro s hs
  rw [hvis _ (by dsimp [i]; omega), hvis _ (by dsimp [i]; omega)]
  have inside : i + s < b := by dsimp [i] at *; omega
  have e := agree (i + s) (by dsimp [i]; omega) inside
  simpa only [Nat.add_right_comm i s q] using e

/-- Multiplication by `3 − 2√2` on the coefficients of `t√2 − r/2`. -/
def pellPair (start : Nat × Nat) : Nat → Nat × Nat
  | 0 => start
  | n + 1 =>
    let z := pellPair start n
    (3 * z.1 + z.2, 8 * z.1 + 3 * z.2)

private theorem growth (u v : Nat) (hu : 0 < u) (n : Nat) :
    u + n ≤ (pellPair (u, v) n).1 := by
  induction n with
  | zero => simp [pellPair]
  | succ n ih =>
    change u + (n + 1) ≤ 3 * (pellPair (u, v) n).1 + (pellPair (u, v) n).2
    omega

private theorem quarter_difference (n : Nat) :
    (pellPair (11, 31) n).1 = (pellPair (7, 20) n).1 + (pellPair (4, 11) n).1 ∧
    (pellPair (11, 31) n).2 = (pellPair (7, 20) n).2 + (pellPair (4, 11) n).2 := by
  induction n with
  | zero => decide
  | succ n ih =>
    obtain ⟨hx, hy⟩ := ih
    simp only [pellPair]
    constructor <;> omega

/-- The quarter-phase prefix identity alone suffices for the eventual-clock exclusion. -/
theorem no_eventual_visible_of_quarter_prefixes
    (x : Int → Bool) (L T0 H : Nat) (hL : 1 ≤ L) (hc : x (-(L : Int)) = true)
    (hl : ∀ j < -(L : Int), x j = false)
    (hclock : ∀ t, T0 ≤ t → evol x t 0 = decide (t % 2 = 1))
    (c : Nat → Bool) (hvis : ∀ t, H ≤ t → evol x (2 * t) 1 = c t)
    (hcopy : ∀ n t, t < (pellPair (11, 31) n).1 → c t = c (t + (pellPair (7, 20) n).1)) :
    False := by
  apply no_eventual_visible_of_repeats x L T0 H hL hc hl hclock c hvis
  intro B
  refine ⟨0, (pellPair (11, 31) B).1, (pellPair (7, 20) B).1, ?_, ?_, ?_⟩
  · have h := growth 7 20 (by decide) B
    omega
  · have h := growth 4 11 (by decide) B
    have hx := (quarter_difference B).1
    omega
  · intro t _ ht
    exact hcopy B t ht

end Rule30RotationRepeats
