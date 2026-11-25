module

public import Ruliology.CellularAutomata.Rule30FiniteConfigs

/-!
# Age 24 is sharp on the line

`Rule30TwoSidedInverse.two_step_predecessor_edge_from_age_twenty_four`: from age 24, every two-step
predecessor of the image of a configuration with a leftmost black cell has its leftmost black cell two
places inside. Age 23 does not suffice. The configuration `X23`, black at 0, 3, 4, 6, 7, 10, 11, 12 and
14, has at age 23 a predecessor `W23` and a predecessor `V23` of `W23` that is black on all of
`(-∞, -24]`, so `V23` has no leftmost black cell (`two_step_predecessor_edge_fails_at_age_twenty_three`,
`age_twenty_four_sharp`). `W23` has the true edge, at `-22`, as the age-8 theorem requires; it is black
on `[37, ∞)`, and `V23` repeats `001` from 36 on. The age-7 witness for one tick is
`Rule30TwoSidedInverse.predecessor_edge_fails_at_age_seven`.

`evol` is computed through rows written as lists (`evol_rowOf`): `rowOf L lo` is the row whose cell
`lo + i` is entry `i` of `L`, white elsewhere, and `stepL` is one tick on such rows (`step_rowOf`).
-/

@[expose] public section

namespace Ruliology.CellularAutomata
namespace Rule30TwoSidedSharp

open Rule30Jen Rule30Realization Rule30FiniteConfigs

/-! ## Rows as lists -/

/-- On the right, a configuration white beyond `hi` stays white beyond `hi + t` (as in
`Rule30TwoSidedInverse.evol_eq_false_of_gt`). -/
theorem evol_false_right {x : Int → Bool} {hi : Int} (hz : ∀ p, hi < p → x p = false) :
    ∀ (t : Nat) (p : Int), hi + t < p → evol x t p = false
  | 0, p, h => hz p (by omega)
  | t + 1, p, h => by
    show rule (evol x t (p - 1)) (evol x t p) (evol x t (p + 1)) = false
    rw [evol_false_right hz t (p - 1) (by push_cast at h; omega), evol_false_right hz t p (by push_cast at h; omega),
      evol_false_right hz t (p + 1) (by push_cast at h; omega)]
    rfl

/-- Entry `k` of `L`, white outside `0 ≤ k < L.length`. -/
def get (L : List Bool) (k : Int) : Bool := if 0 ≤ k then L.getD k.toNat false else false

/-- The row whose cell `lo + i` is entry `i` of `L`, white elsewhere. -/
def rowOf (L : List Bool) (lo : Int) (p : Int) : Bool := get L (p - lo)

/-- One tick on a row written as a list; the row moves one cell left and grows by two. -/
def stepL (L : List Bool) : List Bool :=
  (List.range (L.length + 2)).map fun (i : Nat) => rule (get L ((i : Int) - 2)) (get L ((i : Int) - 1)) (get L i)

theorem get_neg {L : List Bool} {k : Int} (h : k < 0) : get L k = false := by
  simp only [get, show ¬ (0 ≤ k) by omega, ↓reduceIte]

theorem get_ge {L : List Bool} {k : Int} (h : (L.length : Int) ≤ k) : get L k = false := by
  simp only [get, show 0 ≤ k by omega, ↓reduceIte]
  rw [List.getD_eq_getElem?_getD, List.getElem?_eq_none (by omega)]
  rfl

theorem length_stepL (L : List Bool) : (stepL L).length = L.length + 2 := by
  simp [stepL]

theorem get_stepL {L : List Bool} {k : Int} (h0 : 0 ≤ k) (h1 : k < L.length + 2) :
    get (stepL L) k = rule (get L (k - 2)) (get L (k - 1)) (get L k) := by
  have hk : k.toNat < L.length + 2 := by omega
  show (if 0 ≤ k then (stepL L).getD k.toNat false else false) = _
  simp only [h0, ↓reduceIte]
  rw [stepL, List.getD_eq_getElem?_getD, List.getElem?_map, List.getElem?_range hk]
  simp only [Option.map_some, Option.getD_some, Int.toNat_of_nonneg h0]

/-- **One tick on a list row.** -/
theorem step_rowOf (L : List Bool) (lo p : Int) :
    rule (rowOf L lo (p - 1)) (rowOf L lo p) (rowOf L lo (p + 1)) = rowOf (stepL L) (lo - 1) p := by
  simp only [rowOf]
  by_cases h0 : p - (lo - 1) < 0
  · rw [get_neg h0, get_neg (by omega), get_neg (by omega), get_neg (by omega)]
    rfl
  · by_cases h1 : p - (lo - 1) < L.length + 2
    · rw [get_stepL (by omega) h1, show p - (lo - 1) - 2 = p - 1 - lo by omega,
        show p - (lo - 1) - 1 = p - lo by omega, show p - (lo - 1) = p + 1 - lo by omega]
    · have hs : ((stepL L).length : Int) ≤ p - (lo - 1) := by rw [length_stepL]; push_cast; omega
      rw [get_ge hs, get_ge (by omega), get_ge (by omega), get_ge (by omega)]
      rfl

/-- `t` ticks on a list row. -/
def iterL : Nat → List Bool → List Bool
  | 0, L => L
  | t + 1, L => stepL (iterL t L)

/-- **`evol` on a list row**, tick by tick. -/
theorem evol_rowOf (L : List Bool) (lo : Int) : ∀ (t : Nat) (p : Int),
    evol (rowOf L lo) t p = rowOf (iterL t L) (lo - t) p
  | 0, p => by simp [evol, iterL]
  | t + 1, p => by
    show rule (evol (rowOf L lo) t (p - 1)) (evol (rowOf L lo) t p) (evol (rowOf L lo) t (p + 1)) = _
    rw [evol_rowOf L lo t, evol_rowOf L lo t, evol_rowOf L lo t, step_rowOf,
      show lo - (t : Int) - 1 = lo - ((t + 1 : Nat) : Int) by push_cast; omega]
    rfl

/-! ## The witness -/

/-- The seed, cells `0, …, 14`. -/
def seedL : List Bool :=
  [true, false, false, true, true, false, true, true, false, false, true, true, true, false, true]

/-- Black at 0, 3, 4, 6, 7, 10, 11, 12 and 14. -/
def X23 : Int → Bool := rowOf seedL 0

/-- Its row at age 23, cells `-23, …, 37`. -/
def R23 : List Bool :=
  [true, true, false, true, true, true, true, false, true, true, false, false, true, true, true, false, false,
    false, false, true, true, true, true, true, false, false, false, false, false, false, false, true, true,
    false, false, false, true, true, true, true, true, false, false, true, true, true, false, true, true, true,
    false, false, true, true, true, true, true, false, false, true, true]

theorem R23_eq : iterL 23 seedL = R23 := by decide +kernel

/-- The middle of the one-step predecessor, cells `-22, …, 36`. -/
def wMid : List Bool :=
  [true, false, true, false, false, true, false, true, false, false, false, false, true, false, false, false,
    false, false, false, true, false, false, true, true, true, true, true, true, true, false, true, false, false,
    false, false, false, true, false, false, true, true, true, false, false, true, true, false, false, true,
    true, false, true, false, false, true, false, false, false, false]

/-- A predecessor of `evol X23 23`: white on `(-∞, -23]`, black on `[37, ∞)`. -/
def W23 (p : Int) : Bool := if p ≤ -23 then false else if 37 ≤ p then true else wMid.getD (p + 22).toNat false

/-- The middle of the two-step predecessor, cells `-23, …, 35`. -/
def vMid : List Bool :=
  [false, true, false, true, true, false, true, false, true, true, true, true, false, true, true, true, true,
    true, true, false, true, true, false, true, false, false, true, false, false, true, false, true, true, true,
    true, true, false, true, true, true, false, false, true, true, false, true, false, false, false, false,
    true, false, true, true, true, false, false, false, false]

/-- A predecessor of `W23`: black on `(-∞, -24]`, and `001` repeated from 36 on. -/
def V23 (p : Int) : Bool :=
  if p ≤ -24 then true else if 36 ≤ p then (p - 36) % 3 == 2 else vMid.getD (p + 23).toNat false

theorem w_middle : ∀ k : Nat, k < 61 →
    rule (W23 (-23 + k - 1)) (W23 (-23 + k)) (W23 (-23 + k + 1)) = get R23 k := by
  decide +kernel

theorem v_middle : ∀ k : Nat, k < 61 →
    rule (V23 (-24 + k - 1)) (V23 (-24 + k)) (V23 (-24 + k + 1)) = W23 (-24 + k) := by
  decide +kernel

theorem seed_zero : X23 0 = true := by decide

theorem seed_left : ∀ p, p < 0 → X23 p = false := fun _ hp => get_neg (by omega)

theorem seed_right : ∀ p, 14 < p → X23 p = false := fun _ hp => get_ge (by simp only [seedL]; simp; omega)

theorem evol_X23 (p : Int) : evol X23 23 p = get R23 (p + 23) := by
  rw [X23, evol_rowOf, R23_eq]
  simp only [rowOf]
  congr 1

theorem W23_left {p : Int} (h : p ≤ -23) : W23 p = false := by simp [W23, h]

theorem W23_right {p : Int} (h : 37 ≤ p) : W23 p = true := by
  simp [W23, show ¬ p ≤ -23 by omega, h]

theorem V23_left {p : Int} (h : p ≤ -24) : V23 p = true := by simp [V23, h]

theorem V23_right {p : Int} (h : 36 ≤ p) : V23 p = ((p - 36) % 3 == 2) := by
  simp [V23, show ¬ p ≤ -24 by omega, h]

/-- `W23` is a predecessor of the image at age 23. -/
theorem w_pred : ∀ p, rule (W23 (p - 1)) (W23 p) (W23 (p + 1)) = evol X23 23 p := by
  intro p
  by_cases h1 : p ≤ -24
  · rw [W23_left (p := p - 1) (by omega), W23_left (p := p) (by omega), W23_left (p := p + 1) (by omega),
      evol_eq_false_of_lt seed_left 23 p (by omega)]
    rfl
  · by_cases h2 : 38 ≤ p
    · rw [W23_right (p := p - 1) (by omega), W23_right (p := p) (by omega), W23_right (p := p + 1) (by omega),
        evol_false_right seed_right 23 p (by omega)]
      rfl
    · have hk := w_middle (p + 23).toNat (by omega)
      rw [show (-23 : Int) + ((p + 23).toNat : Int) = p by omega] at hk
      rw [hk, evol_X23, Int.toNat_of_nonneg (by omega)]

/-- `V23` is a predecessor of `W23`. -/
theorem v_pred : ∀ p, rule (V23 (p - 1)) (V23 p) (V23 (p + 1)) = W23 p := by
  intro p
  by_cases h1 : p ≤ -25
  · rw [V23_left (p := p - 1) (by omega), V23_left (p := p) (by omega), V23_left (p := p + 1) (by omega),
      W23_left (by omega)]
    rfl
  · by_cases h2 : 37 ≤ p
    · rw [V23_right (p := p - 1) (by omega), V23_right (p := p) (by omega), V23_right (p := p + 1) (by omega),
        W23_right h2]
      have h3 : (p - 1 - 36) % 3 = 0 ∨ (p - 1 - 36) % 3 = 1 ∨ (p - 1 - 36) % 3 = 2 := by omega
      rcases h3 with h | h | h
      · rw [h, show (p - 36) % 3 = 1 by omega, show (p + 1 - 36) % 3 = 2 by omega]
        rfl
      · rw [h, show (p - 36) % 3 = 2 by omega, show (p + 1 - 36) % 3 = 0 by omega]
        rfl
      · rw [h, show (p - 36) % 3 = 0 by omega, show (p + 1 - 36) % 3 = 1 by omega]
        rfl
    · have hk := v_middle (p + 24).toNat (by omega)
      rw [show (-24 : Int) + ((p + 24).toNat : Int) = p by omega] at hk
      exact hk

/-- `V23` has no leftmost black cell. -/
theorem v_no_left_edge : ∀ q : Int, ∃ p, p < q ∧ V23 p = true :=
  fun q => ⟨min (q - 1) (-24), by omega, V23_left (by omega)⟩

/-- `W23` has the true edge, `0 - 23 + 1`. -/
theorem w_edge : W23 (-22) = true ∧ ∀ p, p < -22 → W23 p = false :=
  ⟨by decide, fun _ hp => W23_left (by omega)⟩

/-- **Age 23 fails.** A configuration with its leftmost black cell at 0 has, at age 23, a two-step
predecessor with no leftmost black cell. -/
theorem two_step_predecessor_edge_fails_at_age_twenty_three :
    X23 0 = true ∧ (∀ p, p < 0 → X23 p = false) ∧
    (∀ p, rule (W23 (p - 1)) (W23 p) (W23 (p + 1)) = evol X23 23 p) ∧
    (∀ p, rule (V23 (p - 1)) (V23 p) (V23 (p + 1)) = W23 p) ∧
    ∀ q : Int, ∃ p, p < q ∧ V23 p = true :=
  ⟨seed_zero, seed_left, w_pred, v_pred, v_no_left_edge⟩

/-- **The age 24 of `two_step_predecessor_edge_from_age_twenty_four` is sharp:** its conclusion fails at 23. -/
theorem age_twenty_four_sharp : ¬ ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
    ∀ w v : Int → Bool, (∀ p, rule (w (p - 1)) (w p) (w (p + 1)) = evol x 23 p) →
      (∀ p, rule (v (p - 1)) (v p) (v (p + 1)) = w p) → ∀ p, p < lo - 23 + 2 → v p = false := by
  intro h
  have h' := h X23 0 seed_zero seed_left W23 V23 w_pred v_pred (-24) (by omega)
  rw [V23_left (by omega)] at h'
  exact absurd h' (by decide)

end Rule30TwoSidedSharp
end Ruliology.CellularAutomata
