import LocalBackground

/-! In every doubling interval, the temporal falls pooled over eight fixed
western columns occupy at least two residues modulo three. -/
namespace PhaseFalls
open Ruliology.CellularAutomata.Rule30Jen

/-- A pair of constant columns with no adjacent black recovers a pair with the
same property one step further west, losing one tick of observation. -/
private theorem tip (s d : Nat) (j : Int) (a b : Bool) (clean : (a && b) = false)
    (h : ∀ k, k ≤ d → cell (s+k) j = a ∧ cell (s+k) (j+1) = b) :
    (cell s (j-d) && cell s (j-d+1)) = false := by
  induction d generalizing j a b with
  | zero =>
    simpa using (show (cell s j && cell s (j+1)) = false by
      have eq := h 0 (by omega)
      simp at eq
      rw [eq.1, eq.2, clean])
  | succ d ih =>
    have west (k : Nat) (hk : k ≤ d) :
        cell (s+k) (j-1) = b ∧ cell (s+k) (j-1+1) = a := by
      obtain ⟨w,e⟩ := h k (by omega)
      have w' := (h (k+1) (by omega)).1
      rw [show s+(k+1)=s+k+1 by omega] at w'
      rw [cell_left (s+k) j, w', w, e, show j-1+1=j by omega, w]
      cases a <;> cases b <;> simp_all
    have prev := ih (j-1) b a (by rw [Bool.and_comm, clean]) west
    simpa only [show j-(d.succ : Int)=j-1-(d : Int) by omega] using prev

private theorem black_pair (s : Nat) (hs : 0 < s) :
    cell s (-(s : Int)) = true ∧ cell s (-(s : Int)+1) = true := by
  refine ⟨cell_left_edge s, ?_⟩
  cases s with
  | zero => omega
  | succ t =>
    rw [show -((t+1 : Nat) : Int)+1=-(t : Int) by omega]
    change rule (cell t (-(t : Int)-1)) (cell t (-(t : Int))) _ = true
    rw [cell_eq_false_of_lt _ _ (by omega), cell_left_edge]
    rfl

private theorem local_deadline (U r B d : Nat) (i : Int) (hU : 0 < U) (hd : (U : Int)+i=d)
    (supply : ∀ e k : Nat, e ≤ 2 → k ≤ d+e →
        ∃ n j : Nat, U+e+3*n+1 < B ∧ j ≤ 3 ∧ k=3*n+j) :
    ∃ t : Nat, ∃ j : Int, U ≤ t ∧ t < B ∧ i-3 ≤ j ∧ j ≤ i+4 ∧
      t % 3 ≠ r ∧ cell t j = true ∧ cell (t+1) j = false := by
  apply Classical.byContradiction
  intro neg
  obtain ⟨s,lo,hi,ph⟩ : ∃ s : Nat, U ≤ s ∧ s ≤ U+2 ∧ s%3=(r+1)%3 := by
    by_cases h : U%3=(r+1)%3
    · exact ⟨U,by omega,by omega,h⟩
    by_cases h' : (U+1)%3=(r+1)%3
    · exact ⟨U+1,by omega,by omega,h'⟩
    exact ⟨U+2,by omega,by omega,by omega⟩
  have quiet (n : Nat) (endpt : s+3*n+1 < B) :=
    block_at (s+3*n) i (by
      intro k hk j hL hR falls
      exact neg ⟨s+3*n+k,j,by omega,by omega,hL,hR,by omega,falls⟩)
  obtain ⟨_,_,initial,_,_⟩ := supply (s-U) 0 (by omega) (by omega)
  obtain ⟨a,b,clean,base⟩ := quiet 0 (by omega)
  simp only [Nat.mul_zero, Nat.add_zero] at base
  have chain (n : Nat) (hn : s+3*n+1 < B) : ∀ k : Nat, k ≤ 3 →
      cell (s+3*n+k) i = a ∧ cell (s+3*n+k) (i+1) = b := by
    induction n with
    | zero => simpa using base
    | succ n ih =>
      have prior := ih (by omega) 3 (by decide)
      obtain ⟨a',b',_,next⟩ := quiet (n+1) hn
      have curr := next 0 (by decide)
      rw [Nat.add_zero, show s+3*(n+1)=s+3*n+3 by omega] at curr
      rw [← curr.1, prior.1, ← curr.2, prior.2] at next
      exact next
  let reach := d+(s-U)
  have fixed (k : Nat) (hk : k ≤ reach) :
      cell (s+k) i = a ∧ cell (s+k) (i+1) = b := by
    obtain ⟨n,j,hn,hj,hk'⟩ := supply (s-U) k (by omega) hk
    have h := chain n (by omega) j hj
    simpa only [show s+3*n+j=s+k by omega] using h
  have bad := tip s reach i a b clean fixed
  rw [show i-(reach : Int) = -(s : Int) by dsimp [reach]; omega] at bad
  obtain ⟨e₀,e₁⟩ := black_pair s (by omega)
  simp [e₀,e₁] at bad

/-- In an arbitrary eight-column strip the deadline depends on the distance
from its central left site to the singleton edge at age U. -/
theorem escapes_residue_at (U d r : Nat) (i : Int) (hU : 0 < U) (hd : (U : Int)+i=d) :
    ∃ t : Nat, ∃ j : Int, U ≤ t ∧ t < U+d+6 ∧ i-3 ≤ j ∧ j ≤ i+4 ∧
      t%3 ≠ r ∧ cell t j = true ∧ cell (t+1) j = false := by
  apply local_deadline U r _ d i hU hd
  intro e k he hk
  exact ⟨k/3,k%3,by omega,by omega,by omega⟩

/-- Every proposed common falling residue fails in the half-open doubling
interval, in eight columns strictly west of the centre. -/
theorem escapes_residue (U r : Nat) (hU : 8 ≤ U) :
    ∃ t : Nat, ∃ j : Int, U ≤ t ∧ t < 2*U ∧ -10 ≤ j ∧ j ≤ -3 ∧
      t%3 ≠ r ∧ cell t j = true ∧ cell (t+1) j = false := by
  obtain ⟨t,j,h₁,h₂,h₃,h₄,h₅,h₆,h₇⟩ :=
    escapes_residue_at U (U-7) r (-7) (by omega) (by omega)
  exact ⟨t,j,h₁,by omega,by omega,by omega,h₅,h₆,h₇⟩

/-- When 3 does not divide U (in particular for dyadic U), the eight-column
strip can end at the centre itself with the same half-open doubling deadline. -/
theorem escapes_residue_near_center (U r : Nat) (hU : 8 ≤ U) (hmod : U%3 ≠ 0) :
    ∃ t : Nat, ∃ j : Int, U ≤ t ∧ t < 2*U ∧ -7 ≤ j ∧ j ≤ 0 ∧
      t%3 ≠ r ∧ cell t j = true ∧ cell (t+1) j = false := by
  apply local_deadline U r _ (U-4) (-4) (by omega) (by omega)
  intro e k he hk
  refine ⟨(k-1)/3, k-3*((k-1)/3), ?_, by omega, by omega⟩
  omega

/-- Two distinct falling time residues occur when the western strip is
pooled. Their witnessing columns can differ. -/
theorem two_falling_phases (U : Nat) (hU : 8 ≤ U) :
    ∃ t u : Nat, ∃ i j : Int, U ≤ t ∧ t < 2*U ∧ U ≤ u ∧ u < 2*U ∧
      -10 ≤ i ∧ i ≤ -3 ∧ -10 ≤ j ∧ j ≤ -3 ∧ t%3 ≠ u%3 ∧
      cell t i = true ∧ cell (t+1) i = false ∧ cell u j = true ∧ cell (u+1) j = false := by
  obtain ⟨t,i,lt,ht,li,hi,_,ct,ct'⟩ := escapes_residue U 0 hU
  obtain ⟨u,j,lu,hu,lj,hj,ne,cu,cu'⟩ := escapes_residue U (t%3) hU
  exact ⟨t,u,i,j,lt,ht,lu,hu,li,hi,lj,hj,Ne.symm ne,ct,ct',cu,cu'⟩

/-- In every dyadic shell from [8,16) onward, pooling the centre and its
seven western neighbours gives falls on two different phases modulo three. -/
theorem dyadic_two_falling_phases (m : Nat) (hm : 3 ≤ m) :
    ∃ t u : Nat, ∃ i j : Int, 2^m ≤ t ∧ t < 2^(m+1) ∧ 2^m ≤ u ∧ u < 2^(m+1) ∧
      -7 ≤ i ∧ i ≤ 0 ∧ -7 ≤ j ∧ j ≤ 0 ∧ t%3 ≠ u%3 ∧
      cell t i = true ∧ cell (t+1) i = false ∧ cell u j = true ∧ cell (u+1) j = false := by
  have size : 8 ≤ 2^m := Nat.pow_le_pow_right (by decide : 0 < 2) hm
  have rem (n : Nat) : 2^n%3 = 1 ∨ 2^n%3 = 2 := by
    induction n with
    | zero => decide
    | succ n ih =>
      rw [Nat.pow_succ,Nat.mul_mod]
      rcases ih with h | h <;> rw [h] <;> decide
  obtain ⟨t,i,lt,ht,li,hi,_,ct,ct'⟩ :=
    escapes_residue_near_center (2^m) 0 size (by have := rem m; omega)
  obtain ⟨u,j,lu,hu,lj,hj,ne,cu,cu'⟩ :=
    escapes_residue_near_center (2^m) (t%3) size (by have := rem m; omega)
  rw [Nat.pow_succ]
  exact ⟨t,u,i,j,lt,by omega,lu,by omega,li,hi,lj,hj,Ne.symm ne,ct,ct',cu,cu'⟩
end PhaseFalls
