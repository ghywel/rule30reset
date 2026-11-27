import SixComponents
import SixWindow

/-! Recurrent components cost one doubling. Between them the transient
height decreases at every tick, so twelve more ticks suffice. -/
namespace PhaseFalls.Six
open Ruliology.CellularAutomata.Rule30Jen

private theorem decreasing (F : Nat → Nat) (U E : Nat)
    (step : ∀ t, U ≤ t → t < E → F (t+1) ≤ F t)
    {s t : Nat} (hs : U ≤ s) (st : s ≤ t) (ht : t ≤ E) : F t ≤ F s := by
  obtain ⟨d,rfl⟩ := Nat.exists_eq_add_of_le st
  induction d with
  | zero => exact Nat.le_refl _
  | succ d ih => exact Nat.le_trans (step (s+d) (by omega) (by omega)) (ih (by omega) (by omega))

/-- Each of the four transient levels costs at most twelve ticks. Each of
the three recurrent levels preserves an adjacent pair until the finite Jen
deadline. -/
theorem component_window_escape (i : Int) (U : Nat) (hU : i.natAbs ≤ U)
    (assignment : Fin 6 → Fin 3) :
    ∃ (j : Fin 6) (t : Nat), U ≤ t ∧ t < 8*U+7*(i.natAbs+10)+180 ∧
      (cell t (i+j.val)=true ∧ cell (t+1) (i+j.val)=false) ∧ t%3 ≠ (assignment j).val := by
  apply Classical.byContradiction
  intro no
  let p (k : Nat) := if h : k < 6 then (assignment ⟨k,h⟩).val else 0
  have hp (k : Nat) (h : k < 6) : p k < 3 := by simp [p,h]
  let a := encode p
  have ha : a < 729 := encode_lt p hp
  let c := i.natAbs+10
  let E := 8*U+7*c+180
  let L := levelAt a i
  let H := heightAt a i
  let G (t : Nat) := tag (physicalEntry a i t)
  have prog (t : Nat) (lo : U ≤ t) (hi : t < E) :
      L (t+1)<L t ∨ (L (t+1)=L t ∧
        (if L t%2=0 then H (t+1)<H t else G (t+1)=G t)) := by
    have permit : allowed a (t%3) (row t i) (row (t+1) i) = true := by
      apply allowed_succ
      intro k hk b w
      rw [encode_digit p hp k hk]
      simp [p,hk]
      exact Classical.byContradiction (fun off => no ⟨⟨k,hk⟩,t,lo,hi,⟨b,w⟩,off⟩)
    exact component_progress ha i t permit
  have mono {s t : Nat} (hs : U ≤ s) (st : s ≤ t) (ht : t ≤ E) : L t ≤ L s :=
    decreasing L U E (fun k hk ek => by have := prog k hk ek; omega) hs st ht
  have freeze {s e ell : Nat} (lo : U ≤ s) (hi : e ≤ E)
      (hs : L s ≤ ell) (he : ell ≤ L e) (t : Nat) (st : s ≤ t) (te : t ≤ e) : L t=ell := by
    have := mono lo st (by omega)
    have := mono (by omega : U ≤ t) te hi
    omega
  have even (s ell : Nat) (par : ell%2=0) (lo : U ≤ s) (hi : s+12 ≤ E)
      (start : L s ≤ ell) : L (s+12) < ell := by
    apply Classical.byContradiction
    intro survive
    have hnow := freeze lo hi start (by omega : ell ≤ L (s+12))
    have count (k : Nat) (hk : k ≤ 12) : H (s+k)+k ≤ H s := by
      induction k with
      | zero => simp
      | succ k ih =>
        have prior := ih (by omega)
        have edge := prog (s+k) (by omega) (by omega)
        have a₀ := hnow (s+k) (by omega) (by omega)
        have a₁ := hnow (s+k+1) (by omega) (by omega)
        simp only [a₀,a₁,par,Nat.lt_irrefl,false_or,true_and,ite_eq_left] at edge
        rw [show s+(k+1)=s+k+1 by omega]
        omega
    have := count 12 (by decide)
    have cap : H s ≤ 11 := heightAt_bound ha i s
    omega
  have odd (s ell : Nat) (par : ell%2≠0) (lo : U ≤ s) (hi : 2*s+c ≤ E)
      (start : L s ≤ ell) : L (2*s+c) < ell := by
    apply Classical.byContradiction
    intro survive
    have hnow := freeze lo hi start (by omega : ell ≤ L (2*s+c))
    have drop := window_drop i s c (by omega) rfl L G (fun k hk => by
      have q := prog (s+k) (by omega) (by omega)
      have a₀ := hnow (s+k) (by omega) (by omega)
      have a₁ := hnow (s+k+1) (by omega) (by omega)
      simpa only [a₀,a₁,ite_eq_right par] using q) (physical_read ha i)
    omega
  let s₁ := U+12
  let s₂ := 2*s₁+c
  let s₃ := s₂+12
  let s₄ := 2*s₃+c
  let s₅ := s₄+12
  let s₆ := 2*s₅+c
  have A : L U ≤ 6 := levelAt_bound ha i U
  have B : L s₁ < 6 := even U 6 (by decide) (by omega) (by dsimp [E]; omega) A
  have C : L s₂ < 5 := odd s₁ 5 (by decide) (by dsimp [s₁]; omega)
    (by dsimp [s₁,E]; omega) (by omega)
  have D : L s₃ < 4 := even s₂ 4 (by decide) (by dsimp [s₂,s₁]; omega)
    (by dsimp [s₂,s₁,E]; omega) (by omega)
  have F : L s₄ < 3 := odd s₃ 3 (by decide) (by dsimp [s₃,s₂,s₁]; omega)
    (by dsimp [s₃,s₂,s₁,E]; omega) (by omega)
  have J : L s₅ < 2 := even s₄ 2 (by decide) (by dsimp [s₄,s₃,s₂,s₁]; omega)
    (by dsimp [s₄,s₃,s₂,s₁,E]; omega) (by omega)
  have K : L s₆ < 1 := odd s₅ 1 (by decide) (by dsimp [s₅,s₄,s₃,s₂,s₁]; omega)
    (by dsimp [s₅,s₄,s₃,s₂,s₁,E]; omega) (by omega)
  have zero := even s₆ 0 (by decide) (by dsimp [s₆,s₅,s₄,s₃,s₂,s₁]; omega)
    (by dsimp [s₆,s₅,s₄,s₃,s₂,s₁,E]; omega) (by omega)
  omega

theorem two_phases_within_eightfold (i : Int) (U : Nat) (hU : i.natAbs ≤ U) :
    ∃ (j : Fin 6) (t u : Nat), U ≤ t ∧ t < 8*U+7*(i.natAbs+10)+180 ∧
      U ≤ u ∧ u < 8*U+7*(i.natAbs+10)+180 ∧ t%3 ≠ u%3 ∧
      (cell t (i+j.val)=true ∧ cell (t+1) (i+j.val)=false) ∧
      (cell u (i+j.val)=true ∧ cell (u+1) (i+j.val)=false) := by
  classical
  apply Classical.byContradiction
  intro no
  let hit (j : Fin 6) (t : Nat) :=
    U ≤ t ∧ t < 8*U+7*(i.natAbs+10)+180 ∧
      cell t (i+j.val)=true ∧ cell (t+1) (i+j.val)=false
  let pick (j : Fin 6) : Fin 3 :=
    if h : ∃ t, hit j t then ⟨(Classical.choose h)%3,by omega⟩ else 0
  obtain ⟨j,t,lo,hi,f,off⟩ := component_window_escape i U hU pick
  have h : ∃ t, hit j t := ⟨t,lo,hi,f⟩
  obtain ⟨lo',hi',f'⟩ := Classical.choose_spec h
  have ne : t%3 ≠ (Classical.choose h)%3 := by simpa [pick,h] using off
  exact no ⟨j,t,Classical.choose h,lo,hi,lo',hi',ne,f,f'⟩
end PhaseFalls.Six
