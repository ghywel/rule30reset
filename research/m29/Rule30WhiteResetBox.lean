import Ruliology.CellularAutomata.Rule30AgedLeftDiagonals

/-! Five consecutive phases at a permanently white wheel. One of them has a
closed black run of length one or four within eight wheels, including both
white endpoints. The tick and the position are allowed to depend on the wheel. -/
namespace Rule30WhiteResetBox
open Ruliology.CellularAutomata.Rule30AgedLeftDiagonals

def hit (r : Nat → Bool) (i n : Nat) : Bool :=
  !r i && (List.range n).all (fun k => r (i+1+k)) && !r (i+1+n)

def inBox (r : Nat → Bool) : Bool :=
  (List.range 6).any (fun i => hit r i 1) || (List.range 3).any (fun i => hit r i 4)

private def five (a b c d e : Bool) : Nat → Bool
  | 0 => a
  | 1 => b
  | 2 => c
  | 3 => d
  | _ => e

private def sim (drive init : Nat → Bool) : Nat → Nat → Bool
  | _, 0 => false
  | t, 1 => drive t
  | _, 2 => true
  | 0, k+3 => init k
  | t+1, k+3 => xor (sim drive init t (k+1)) (sim drive init t (k+2) || sim drive init t (k+3))

private def covered (r : Nat → Nat → Bool) : Bool :=
  inBox (r 0) || inBox (r 1) || inBox (r 2) || inBox (r 3) || inBox (r 4)

set_option maxRecDepth 10000 in
set_option maxHeartbeats 10000000 in
private theorem certificate : ∀ a b c d e f g h i j : Bool,
    covered (sim (five a b c d e) (five f g h i j)) = true := by decide +kernel

private theorem rectangle (r : Nat → Nat → Bool)
    (white : ∀ t, r t 0 = false) (black : ∀ t, r t 2 = true)
    (step : ∀ t i, r (t+1) (i+2) = xor (r t i) (r t (i+1) || r t (i+2))) :
    inBox (r 0) || inBox (r 1) || inBox (r 2) || inBox (r 3) || inBox (r 4) := by
  let a := five (r 0 1) (r 1 1) (r 2 1) (r 3 1) (r 4 1)
  let b := five (r 0 3) (r 0 4) (r 0 5) (r 0 6) (r 0 7)
  have h := certificate (r 0 1) (r 1 1) (r 2 1) (r 3 1) (r 4 1)
    (r 0 3) (r 0 4) (r 0 5) (r 0 6) (r 0 7)
  change covered (sim a b) = true at h
  have agree : ∀ t, t<5 → ∀ k, k<8 → sim a b t k = r t k := by
    intro t
    induction t with
    | zero =>
      intro _ k hk
      have cs : k=0 ∨ k=1 ∨ k=2 ∨ k=3 ∨ k=4 ∨ k=5 ∨ k=6 ∨ k=7 := by omega
      rcases cs with h|h|h|h|h|h|h|h <;> subst k <;> simp [sim,a,b,five,white,black]
    | succ t ih =>
      intro ht k hk
      match k with
      | 0 => exact (white _).symm
      | 1 =>
        have cs : t=0 ∨ t=1 ∨ t=2 ∨ t=3 := by omega
        rcases cs with h|h|h|h <;> subst t <;> rfl
      | 2 => exact (black _).symm
      | k+3 =>
        change xor (sim a b t (k+1)) (sim a b t (k+2) || sim a b t (k+3)) = _
        rw [ih (by omega) _ (by omega), ih (by omega) _ (by omega), ih (by omega) _ (by omega)]
        exact (step t (k+1)).symm
  unfold covered at h
  unfold inBox hit at h ⊢
  simp only [List.range_succ,List.range_zero,List.any_append,List.any_nil,
    List.all_append,List.all_nil,List.any_cons,List.all_cons] at h ⊢
  simpa (disch := decide) only [agree] using h

/-- Offset zero denotes the white wheel. The returned offsets put the entire
factor inside [j,j+7], and both endpoints are white at the same tick. -/
theorem white_five_by_eight {d : Nat → Nat → Bool} (hd : Recurrence d) (j s : Nat)
    (hw : ∀ t, d j t = false) (hb : ∀ t, d (j+2) t = true) :
    ∃ dt i n : Nat, dt<5 ∧ (n=1 ∨ n=4) ∧ i+1+n≤7 ∧
      hit (fun k => d (j+k) (s+dt)) i n = true := by
  let r := fun t k => d (j+k) (s+t)
  have local_step : ∀ t i, r (t+1) (i+2) = xor (r t i) (r t (i+1) || r t (i+2)) := by
    intro t i
    simpa [r,Nat.add_assoc] using hd.2.2 (j+i) (s+t)
  have h := rectangle r (fun t => by simpa [r] using hw (s+t)) (fun t => hb (s+t)) local_step
  have pick : ∃ dt, dt<5 ∧ inBox (r dt) = true := by
    simp only [Bool.or_eq_true] at h
    rcases h with (((h|h)|h)|h)|h
    · exact ⟨0,by decide,h⟩
    · exact ⟨1,by decide,h⟩
    · exact ⟨2,by decide,h⟩
    · exact ⟨3,by decide,h⟩
    · exact ⟨4,by decide,h⟩
  obtain ⟨dt,hdt,h⟩ := pick
  simp only [inBox,Bool.or_eq_true,List.any_eq_true,List.mem_range] at h
  rcases h with ⟨i,hi,h⟩ | ⟨i,hi,h⟩
  · exact ⟨dt,i,1,hdt,Or.inl rfl,by omega,h⟩
  · exact ⟨dt,i,4,hdt,Or.inr rfl,by omega,h⟩

/-- If each of finitely many colors is bounded in depth, they have a common bound. -/
private theorem common_bound (A : Nat → Nat → Prop) (n : Nat)
    (each : ∀ t, t<n → ∃ m, ∀ j, m≤j → ¬A t j) :
    ∃ m, ∀ t, t<n → ∀ j, m≤j → ¬A t j := by
  induction n with
  | zero => exact ⟨0,fun _ h => by omega⟩
  | succ n ih =>
    obtain ⟨m,hm⟩ := ih (fun t ht => each t (by omega))
    obtain ⟨k,hk⟩ := each n (by omega)
    refine ⟨max m k,?_⟩
    intro t ht j hj
    by_cases e : t=n
    · subst t; exact hk j (by omega)
    · exact hm t (by omega) j (by omega)

/-- Among any five consecutive phases of one strip, a single phase contains
ordinary reset runs at arbitrarily large depths. -/
theorem one_of_five_unbounded {d : Nat → Nat → Bool} (hd : Recurrence d)
    (anchors : ∀ lo, ∃ j, lo≤j ∧ (∀ t, d j t=false) ∧ (∀ t, d (j+2) t=true)) (s : Nat) :
    ∃ dt, dt<5 ∧ ∀ lo, ∃ j n, lo≤j ∧ (n=1 ∨ n=4) ∧
      hit (fun k => d k (s+dt)) j n=true := by
  classical
  let A := fun t j => ∃ n, (n=1 ∨ n=4) ∧ hit (fun k => d k (s+t)) j n=true
  apply Classical.byContradiction
  intro missing
  have bounded : ∀ t, t<5 → ∃ m, ∀ j, m≤j → ¬A t j := by
    intro t ht
    apply Classical.byContradiction
    intro unbounded
    apply missing
    refine ⟨t,ht,?_⟩
    intro lo
    apply Classical.byContradiction
    intro absent
    apply unbounded
    exact ⟨lo,fun j hj ⟨n,hn,hit'⟩ => absent ⟨j,n,hj,hn,hit'⟩⟩
  obtain ⟨m,hm⟩ := common_bound A 5 bounded
  obtain ⟨j,hj,hw,hb⟩ := anchors m
  obtain ⟨t,i,n,ht,hn,_,hh⟩ := white_five_by_eight hd j s hw hb
  apply hm t ht (j+i) (by omega)
  refine ⟨n,hn,?_⟩
  simpa [hit,Nat.add_assoc] using hh

#print axioms one_of_five_unbounded
#print axioms white_five_by_eight
end Rule30WhiteResetBox
