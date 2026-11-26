import Ruliology.CellularAutomata.Rule30PeriodTwoSideways

/-! A change at the finite eastern tip can travel away from the gate forever.
Site zero carries the same arbitrary boundary drive in both evolutions. -/
namespace RecordTips

open Ruliology.CellularAutomata
open Rule30Ether (drv drv_col0)
open Rule30Jen (rule)
open Rule30ZeroBoundary.IntegerForm (rowOfNat)

private def tip (r : Nat → Bool) (k w : Nat) : Prop :=
  ∀ i, r (k + i) = w.testBit i

private def next (w : Nat) := w ^^^ ((w >>> 1) ||| (w >>> 2))

private theorem advance {c x : Nat → Bool} {t k w : Nat}
    (h : tip (drv c x t) k w) : tip (drv c x (t+1)) (k+1) (next w) := by
  intro i
  rw [show k+1+i = (k+i)+1 by omega]
  change rule _ _ _ = _
  rw [show k+i+1 = k+(i+1) by omega, show k+i+2 = k+(i+2) by omega,
      h i, h (i+1), h (i+2)]
  simp [next, rule, Nat.testBit_xor, Nat.testBit_or, Nat.add_comm]

private def pair (a b : Nat → Bool) (k : Nat) : Prop :=
  (tip a k 7 ∧ tip b k 11) ∨ (tip a k 4 ∧ tip b k 12)

private theorem common {a b : Nat → Bool} {k : Nat} (h : pair a b k) :
    a k = b k ∧ a (k+1) = b (k+1) := by
  rcases h with ⟨ha, hb⟩ | ⟨ha, hb⟩ <;>
    exact ⟨(ha 0).trans (hb 0).symm, (ha 1).trans (hb 1).symm⟩

/-- For arbitrary common drive, a 1110/1101 tip swap (near to far, then all
white) keeps the two driven rows equal through the second moving tip site. -/
theorem swap {c x y : Nat → Bool} {k : Nat}
    (hp : ∀ p, p ≤ k+1 → drv c x 0 p = drv c y 0 p)
    (hx : ∀ i, drv c x 0 (k+i) = (7 : Nat).testBit i)
    (hy : ∀ i, drv c y 0 (k+i) = (11 : Nat).testBit i)
    (t p : Nat) (hlt : p ≤ k+t+1) : drv c x t p = drv c y t p := by
  suffices inv : ∀ n,
      pair (drv c x n) (drv c y n) (k+n) ∧
      ∀ j, j ≤ k+n+1 → drv c x n j = drv c y n j from (inv t).2 p hlt
  intro n
  induction n with
  | zero => exact ⟨Or.inl ⟨hx, hy⟩, hp⟩
  | succ n ih =>
    have hnew : pair (drv c x (n+1)) (drv c y (n+1)) (k+n+1) := by
      rcases ih.1 with ⟨ha, hb⟩ | ⟨ha, hb⟩
      · exact Or.inr ⟨advance ha, advance hb⟩
      · exact Or.inl ⟨advance ha, advance hb⟩
    refine ⟨hnew, ?_⟩
    intro j hj
    rcases (show j ≤ k+n ∨ j = k+n+1 ∨ j = k+n+1+1 by omega) with h | rfl | rfl
    · cases j with
      | zero => simp only [drv_col0]
      | succ j =>
        change rule _ _ _ = rule _ _ _
        rw [ih.2 j (by omega), ih.2 (j+1) (by omega), ih.2 (j+2) (by omega)]
    · exact (common hnew).1
    · exact (common hnew).2

/-- The two K92.3 rows agree through site 22+t at every physical tick. -/
theorem records (c : Nat → Bool) (t p : Nat) (h : p ≤ 22+t) :
    drv c (rowOfNat 7693847) t p = drv c (rowOfNat 11888151) t p := by
  apply swap (k := 21) (t := t) (p := p) (hlt := by omega)
  · intro j hj
    cases j with
    | zero => simp only [drv_col0]
    | succ j =>
      have checked : ∀ i : Fin 22,
          (7693847 : Nat).testBit i = (11888151 : Nat).testBit i := by decide
      exact checked ⟨j, by omega⟩
  all_goals
    intro i
    rw [show 21+i = (i+20)+1 by omega]
    change Nat.testBit _ (i+20) = _
    rw [Nat.testBit_add]

theorem gates (s : Nat) :
    Rule30PeriodTwoSideways.u (rowOfNat 7693847) s =
    Rule30PeriodTwoSideways.u (rowOfNat 11888151) s :=
  records _ _ _ (by omega)

#print axioms records
#print axioms gates

end RecordTips
