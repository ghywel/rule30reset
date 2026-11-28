import Ruliology.CellularAutomata.Rule30CenterRuns

/-! K92.4.A, ledger N44 (claudeIntel). Falls at site -2 against the runs of the singleton's centre column.

A fall at -2 at tick t is `cell t (-3) = true ∧ cell t (-2) = true` (a black cell's next value is the complement
of its western neighbour). Under a constant centre run the kit's `Rule30CenterRuns` fixes the western triangle
(`black_triangle`, `pre_triangle`; Pérez Morales and Claude). Here:
* a black run of length at least three that ends has a fall at -2 exactly two ticks before its last tick
  (`fall_at_black_end`);
* a fall at -2 inside a black run is at its last tick or two before it (`black_run_falls`);
* inside a white run, away from its last two ticks, site -2 is black at most at the tick before column 1 turns
  black (`white_run_black_m2`).
So every maximal centre run holds at most two falls at -2. -/

namespace PhaseTwo.FallRuns
open Ruliology.CellularAutomata Rule30Jen Rule30CenterRuns

theorem rule_true_mid (x y : Bool) : rule x true y = !x := by cases x <;> cases y <;> rfl
theorem rule_false_true (x : Bool) : rule x false true = !x := by cases x <;> rfl
theorem not_eq_false_iff' {x : Bool} (h : (!x) = false) : x = true := by cases x <;> simp_all
theorem eq_of_true_eq_not {x : Bool} (h : true = !x) : x = false := by cases x <;> simp_all

/-- **The fall before the end of a black run.** If the centre is black on `[a, a+L)`, `L ≥ 3`, and white at
`a+L`, then site -2 is black at `a+L-3` and white at `a+L-2`. -/
theorem fall_at_black_end {a L : Nat} (hL : 3 ≤ L) (h : ∀ i, i < L → cell (a+i) 0 = true)
    (hend : cell (a+L) 0 = false) : cell (a+L-3) (-2) = true ∧ cell (a+L-2) (-2) = false := by
  have tri := black_triangle a L h
  have c2 : cell (a+L-3) (-2) = true := tri 2 (a+L-3) (by omega) (by omega)
  have m1 : cell (a+L-2) (-1) = false := tri 1 (a+L-2) (by omega) (by omega)
  have cc : cell (a+L-2) 0 = true := by
    have := h (L-2) (by omega); rwa [show a + (L-2) = a+L-2 by omega] at this
  have cv : cell (a+L-1) 0 = true := by
    have := h (L-1) (by omega); rwa [show a + (L-1) = a+L-1 by omega] at this
  have e1 : cell (a+L) 0 = rule (cell (a+L-1) (-1)) (cell (a+L-1) 0) (cell (a+L-1) 1) := by
    rw [show a + L = (a+L-1) + 1 by omega]; rfl
  have e2 : cell (a+L-1) (-1) = rule (cell (a+L-2) (-2)) (cell (a+L-2) (-1)) (cell (a+L-2) 0) := by
    rw [show a + L - 1 = (a+L-2) + 1 by omega]; rfl
  rw [cv, rule_true_mid] at e1
  rw [m1, cc, rule_false_true] at e2
  have w1 : cell (a+L-1) (-1) = true := not_eq_false_iff' (e1 ▸ hend)
  rw [w1] at e2
  exact ⟨c2, eq_of_true_eq_not e2⟩

/-- **No fall inside a black run, away from its end.** Under a black centre on `[a, a+L)`, site -3 is white at
every `t ≥ a` with `t + 3 < a + L`, so site -2 cannot fall there. -/
theorem no_fall_inside_black {a L t : Nat} (h : ∀ i, i < L → cell (a+i) 0 = true) (hat : a ≤ t)
    (ht : t + 3 < a + L) : cell t (-3) = false :=
  black_triangle a L h 3 t hat ht

/-- **Inside a white run, column 1 never turns from black to white.** -/
theorem col_one_mono {a L t : Nat} (h0 : ∀ i, i < L → cell (a+i) 0 = false) (hat : a ≤ t)
    (ht : t + 1 < a + L) (hb : cell t 1 = true) : cell (t+1) 1 = true := by
  have hc : cell t 0 = false := by
    have := h0 (t - a) (by omega); rwa [show a + (t - a) = t by omega] at this
  have e : cell (t+1) 1 = rule (cell t 0) (cell t 1) (cell t 2) := rfl
  rw [e, hc, hb]; cases cell t 2 <;> rfl

theorem exists_least (P : Nat → Prop) (n : Nat) (hn : P n) : ∃ w, P w ∧ ∀ j, j < w → ¬ P j := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
    by_cases earlier : ∃ j, j < n ∧ P j
    · obtain ⟨j, lt, hj⟩ := earlier
      exact ih j lt hj
    · exact ⟨n, hn, fun j lt hj => earlier ⟨j, lt, hj⟩⟩

/-- A white run's column 1 is a step from white to black at some tick `a + ℓ` (possibly after the run). -/
theorem col_one_step {a L : Nat} (h0 : ∀ i, i < L → cell (a+i) 0 = false) :
    ∃ ℓ, ∀ t, a ≤ t → t < a + L → cell t 1 = decide (a + ℓ ≤ t) := by
  by_cases ex : ∃ i, i < L ∧ cell (a+i) 1 = true
  · obtain ⟨i0, hi0⟩ := ex
    obtain ⟨ℓ, hℓ, hmin⟩ := exists_least (fun i => i < L ∧ cell (a+i) 1 = true) i0 hi0
    have below : ∀ i, i < ℓ → cell (a+i) 1 = false := fun i hi => by
      cases hc : cell (a+i) 1 with
      | false => rfl
      | true => exact (hmin i hi ⟨by have := hℓ.1; omega, hc⟩).elim
    have above : ∀ j, ℓ + j < L → cell (a+ℓ+j) 1 = true := by
      intro j
      induction j with
      | zero => intro _; rw [Nat.add_zero]; exact hℓ.2
      | succ j ih =>
        intro hj
        have := col_one_mono h0 (t := a+ℓ+j) (by omega) (by omega) (ih (by omega))
        rw [show a + ℓ + (j+1) = a+ℓ+j+1 by omega]; exact this
    refine ⟨ℓ, fun t hat htL => ?_⟩
    by_cases lt : t < a + ℓ
    · have := below (t - a) (by omega)
      rw [show a + (t - a) = t by omega] at this
      rw [this, decide_eq_false (by omega)]
    · have := above (t - (a+ℓ)) (by omega)
      rw [show a + ℓ + (t - (a+ℓ)) = t by omega] at this
      rw [this, decide_eq_true (by omega)]
  · refine ⟨L, fun t hat htL => ?_⟩
    cases hc : cell t 1 with
    | false => rw [decide_eq_false (by omega)]
    | true => exact (ex ⟨t - a, by omega, by rw [show a + (t - a) = t by omega]; exact hc⟩).elim

/-- **Inside a white run, away from its last two ticks, site -2 is black only at the tick before column 1 turns
black.** -/
theorem white_run_black_m2 {a L t : Nat} (h0 : ∀ i, i < L → cell (a+i) 0 = false) (hat : a ≤ t)
    (ht : t + 2 < a + L) (hb : cell t (-2) = true) :
    ∃ ℓ, (∀ s, a ≤ s → s < a + L → cell s 1 = decide (a + ℓ ≤ s)) ∧ t + 1 = a + ℓ := by
  obtain ⟨ℓ, h1⟩ := col_one_step h0
  refine ⟨ℓ, h1, ?_⟩
  have tri : cell t (-2) = preRow 2 (a + ℓ - t) := pre_triangle a ℓ L h0 h1 2 t hat ht
  have p := preRow_eq_true (tri.symm.trans hb)
  omega

/-- **At most two falls at -2 in a black run.** Under a black centre on `[a, a+L)` that ends at `a+L`, a fall at
a tick `t` of the run is at `a+L-3` or at `a+L-1`. -/
theorem black_run_falls {a L t : Nat} (h : ∀ i, i < L → cell (a+i) 0 = true) (hend : cell (a+L) 0 = false)
    (hat : a ≤ t) (htL : t < a + L) (fall : cell t (-3) = true ∧ cell t (-2) = true) :
    t + 3 = a + L ∨ t + 1 = a + L := by
  by_cases inner : t + 3 < a + L
  · have := no_fall_inside_black h hat inner
    rw [this] at fall; exact absurd fall.1 (by decide)
  · rcases (show t + 3 = a + L ∨ t + 2 = a + L ∨ t + 1 = a + L by omega) with e | e | e
    · exact Or.inl e
    · -- the tick a+L-2: site -1 is white there, and the run's end makes site -2 white
      have m1 : cell t (-1) = false := black_triangle a L h 1 t hat (by omega)
      have cc : cell t 0 = true := by
        have := h (t - a) (by omega); rwa [show a + (t - a) = t by omega] at this
      have cv : cell (t+1) 0 = true := by
        have := h (t + 1 - a) (by omega); rwa [show a + (t + 1 - a) = t + 1 by omega] at this
      have e1 : cell (t+2) 0 = rule (cell (t+1) (-1)) (cell (t+1) 0) (cell (t+1) 1) := rfl
      have e2 : cell (t+1) (-1) = rule (cell t (-2)) (cell t (-1)) (cell t 0) := rfl
      rw [show t + 2 = a + L by omega, hend, cv, rule_true_mid] at e1
      rw [m1, cc, rule_false_true, fall.2] at e2
      have w1 : cell (t+1) (-1) = true := not_eq_false_iff' e1.symm
      rw [w1] at e2
      exact absurd e2 (by decide)
    · exact Or.inr e

end PhaseTwo.FallRuns
