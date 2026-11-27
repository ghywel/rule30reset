import SixTail
import SixPlateau

/-! A finite time window forcing two fall residues at a single site of a
six-column strip. The bound uses one possible rank decrease per doubling. -/
namespace PhaseFalls.Six
open Ruliology.CellularAutomata.Rule30Jen

def windowEnd (U c : Nat) : Nat → Nat
  | 0 => U
  | n+1 => 2 * windowEnd U c n + c

theorem windowEnd_formula (U c n : Nat) : windowEnd U c n + c = 2^n * (U+c) := by
  induction n with
  | zero => simp [windowEnd]
  | succ n ih =>
    rw [windowEnd, Nat.pow_succ, Nat.mul_comm (2^n) 2, Nat.mul_assoc, ← ih]
    omega

private theorem window_mono {U c n m : Nat} (h : n ≤ m) :
    windowEnd U c n ≤ windowEnd U c m := by
  induction h with
  | refl => omega
  | step _ ih => rw [windowEnd]; omega

private theorem frozen_or_lower (rank tag : Nat → Nat) (s n : Nat)
    (steps : ∀ k, k < n → rank (s+k+1) < rank (s+k) ∨
      (rank (s+k+1)=rank (s+k) ∧ tag (s+k+1)=tag (s+k))) :
    rank (s+n) ≤ rank s ∧
      (rank (s+n)=rank s → ∀ k, k ≤ n → tag (s+k) = tag s) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [show s+(n+1)=s+n+1 by omega]
    obtain ⟨le,freeze⟩ := ih (fun k hk => steps k (by omega))
    rcases steps n (by omega) with drop | same
    · exact ⟨by omega,fun eq => by omega⟩
    · refine ⟨by omega,fun eq k hk => ?_⟩
      by_cases prev : k ≤ n
      · exact freeze (by omega) k prev
      · rw [show k=n+1 by omega, ← Nat.add_assoc]
        exact same.2.trans (freeze (by omega) n (by omega))

/-- A plateau in the certificate rank pins an adjacent pair at phase three,
and cannot last until the moving left edge separates the two ages. -/
private theorem window_drop (i : Int) (s c : Nat) (hs : i.natAbs ≤ s)
    (hc : c=i.natAbs+10) (rank tag : Nat → Nat)
    (steps : ∀ k, k < s+c → rank (s+k+1) < rank (s+k) ∨
      (rank (s+k+1)=rank (s+k) ∧ tag (s+k+1)=tag (s+k)))
    (out : ∀ t, idx (tag t) < 5 ∧
      cell t (i+(idx (tag t) : Int)) = bit0 (tag t) (t%3) ∧
      cell t (i+(idx (tag t) : Int)+1) = bit1 (tag t) (t%3)) :
    rank (2*s+c) < rank s := by
  obtain ⟨le,flat⟩ := frozen_or_lower rank tag s (s+c) steps
  rw [show s+(s+c)=2*s+c by omega] at le flat
  apply Classical.byContradiction
  intro no
  have tags := flat (by omega)
  let j := i+(idx (tag s) : Int)
  have low : -(i.natAbs : Int) ≤ i := by
    have h : -i ≤ ((-i).natAbs : Int) := Int.le_natAbs
    rw [Int.natAbs_neg] at h
    omega
  have high : i ≤ (i.natAbs : Int) := Int.le_natAbs
  have hidx := (out s).1
  let d := s+i.natAbs+7
  have periodic (k : Nat) (hk : k ≤ d) :
      cell (s+k) j = cell (s+k+3) j ∧ cell (s+k) (j+1) = cell (s+k+3) (j+1) := by
    obtain ⟨_,a,b⟩ := out (s+k)
    obtain ⟨_,a',b'⟩ := out (s+(k+3))
    have eq := tags k (by dsimp [d] at hk; omega)
    have eq' := tags (k+3) (by dsimp [d] at hk; omega)
    rw [eq] at a b
    rw [eq', ← Nat.add_assoc, show (s+k+3)%3=(s+k)%3 by omega] at a' b'
    exact ⟨a.trans a'.symm,b.trans b'.symm⟩
  apply PhaseFalls.SixPlateau.lag_three_bound s d j (by dsimp [j]; omega)
    (by dsimp [d,j]; omega) (fun k hk => (periodic k hk).1) (fun k hk => (periodic k (by omega)).2)

/-- A finite-window form of the six-site escape theorem. -/
theorem window_assignment_escape_of_bound (B : Nat)
    (bound : ∀ a t s : Nat, a < 729 → t < 3 → s < 64 → rk (entry a t s) < B)
    (i : Int) (U : Nat) (hU : i.natAbs ≤ U)
    (assignment : Fin 6 → Fin 3) :
    ∃ (j : Fin 6) (t : Nat), U ≤ t ∧ t < windowEnd U (i.natAbs+10) B ∧
      (cell t (i+j.val) = true ∧ cell (t+1) (i+j.val) = false) ∧ t%3 ≠ (assignment j).val := by
  apply Classical.byContradiction
  intro no
  let p (k : Nat) := if h : k < 6 then (assignment ⟨k,h⟩).val else 0
  have hp (k : Nat) (h : k < 6) : p k < 3 := by simp [p,h]
  let a := encode p
  have ha : a < 729 := encode_lt p hp
  let x (t : Nat) := physicalEntry a i t
  let R (t : Nat) := rk (x t)
  let g (t : Nat) := tag (x t)
  let A := windowEnd U (i.natAbs+10)
  have output (t : Nat) : idx (g t) < 5 ∧
      cell t (i+(idx (g t) : Int)) = bit0 (g t) (t%3) ∧
      cell t (i+(idx (g t) : Int)+1) = bit1 (g t) (t%3) := physical_read ha i t
  have steps (t : Nat) (lo : U ≤ t) (hi : t < A B) :
      R (t+1)<R t ∨ (R (t+1)=R t ∧ g (t+1)=g t) := by
    have h : allowed a (t%3) (row t i) (row (t+1) i) = true := by
      apply allowed_succ
      intro k hk b w
      rw [encode_digit p hp k hk]
      simp [p,hk]
      exact Classical.byContradiction (fun off => no ⟨⟨k,hk⟩,t,lo,hi,⟨b,w⟩,off⟩)
    exact physical_progress ha i t h
  have count (n : Nat) (hn : n ≤ B) : R (A n)+n ≤ R U := by
    induction n with
    | zero => simp [A,windowEnd]
    | succ n ih =>
      have prior := ih (by omega)
      have l : A 0 ≤ A n := window_mono (by omega)
      change U ≤ A n at l
      have u : A (n+1) ≤ A B := window_mono hn
      change 2*A n+(i.natAbs+10) ≤ A B at u
      have dec := window_drop i (A n) (i.natAbs+10) (by omega) rfl R g
        (fun k hk => steps (A n+k) (by omega) (by omega)) output
      change R (2*A n+(i.natAbs+10))+(n+1) ≤ R U
      omega
  have impossible := count B (by omega)
  have bounded : R U < B := bound a (U%3) (row U i) ha (by omega) (row_lt U i)
  omega

/-- Within the stated window, one site has a fall on each of two distinct
residues. The witnessing site can depend on the window. -/
theorem two_phases_in_window_of_bound (B : Nat)
    (bound : ∀ a t s : Nat, a < 729 → t < 3 → s < 64 → rk (entry a t s) < B)
    (i : Int) (U : Nat) (hU : i.natAbs ≤ U) :
    ∃ (j : Fin 6) (t u : Nat), U ≤ t ∧ t < windowEnd U (i.natAbs+10) B ∧
      U ≤ u ∧ u < windowEnd U (i.natAbs+10) B ∧ t%3 ≠ u%3 ∧
      (cell t (i+j.val)=true ∧ cell (t+1) (i+j.val)=false) ∧
      (cell u (i+j.val)=true ∧ cell (u+1) (i+j.val)=false) := by
  classical
  apply Classical.byContradiction
  intro no
  let hit (j : Fin 6) (t : Nat) :=
    U ≤ t ∧ t < windowEnd U (i.natAbs+10) B ∧
      cell t (i+j.val)=true ∧ cell (t+1) (i+j.val)=false
  let pick (j : Fin 6) : Fin 3 :=
    if h : ∃ t, hit j t then ⟨(Classical.choose h)%3,by omega⟩ else 0
  obtain ⟨j,t,lo,hi,f,off⟩ := window_assignment_escape_of_bound B bound i U hU pick
  have h : ∃ t, hit j t := ⟨t,lo,hi,f⟩
  obtain ⟨lo',hi',f'⟩ := Classical.choose_spec h
  have ne : t%3 ≠ (Classical.choose h)%3 := by simpa [pick,h] using off
  exact no ⟨j,t,Classical.choose h,lo,hi,lo',hi',ne,f,f'⟩

/-- In a six-site strip, some fixed site falls at two distinct phases before
this explicit, linear-in-starting-age deadline. -/
theorem two_phases_in_window (i : Int) (U : Nat) (hU : i.natAbs ≤ U) :
    ∃ (j : Fin 6) (t u : Nat), U ≤ t ∧ t < 2048*U+2047*(i.natAbs+10) ∧
      U ≤ u ∧ u < 2048*U+2047*(i.natAbs+10) ∧ t%3 ≠ u%3 ∧
      (cell t (i+j.val)=true ∧ cell (t+1) (i+j.val)=false) ∧
      (cell u (i+j.val)=true ∧ cell (u+1) (i+j.val)=false) := by
  have bound := windowEnd_formula U (i.natAbs+10) 11
  rw [show (2:Nat)^11=2048 by decide, Nat.mul_add] at bound
  have finish : windowEnd U (i.natAbs+10) 11 = 2048*U+2047*(i.natAbs+10) := by omega
  have h := two_phases_in_window_of_bound 11
    (fun _ _ _ ha ht hs => bounded_rank ha ht hs) i U hU
  simpa only [finish] using h
end PhaseFalls.Six
