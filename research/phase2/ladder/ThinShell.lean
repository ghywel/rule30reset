import EdgeTriple
import ExactShellLoss

namespace PhaseTwo.ThinShell
open Ruliology.CellularAutomata Rule30ZeroBoundary IntegerForm Rule30LateTwins
open Rule30FirstChecks PhaseTwo.EdgeTriple

/-- The exact finite image, so membership can be tested by trying all words
    of length 3m+1 with their outermost bit black. -/
def Admissible (m v : Nat) : Prop :=
  ∃ u, Top u (3*m) ∧ iterR (age3 m) u = v

theorem small_cover (m : Nat) :
    ∃ A : List Nat, A.length ≤ 2^m ∧ ∀ v, Admissible m v → v ∈ A := by
  obtain ⟨A, len, mem⟩ := outer_cover3 m
  exact ⟨A, len, fun _ ⟨u, hu, eq⟩ => eq ▸ mem u hu⟩

theorem aged_band {x : Nat} (nz : x ≠ 0) {m t : Nat} (ht : 3*m + age3 m ≤ t) :
    Admissible m (iter F t x >>> (x.log2+t-3*m)) := by
  let s := t-age3 m
  let c := x.log2+s-3*m
  have split : s+age3 m=t := by dsimp [s]; omega
  have cut : c+3*m=x.log2+s := by dsimp [c,s]; omega
  have top := Top_iter (top_log2 nz) s
  refine ⟨iter F s x >>> c, ⟨?_, ?_⟩, ?_⟩
  · rw [Nat.testBit_shiftRight, cut]; exact top.1
  · intro i hi
    rw [Nat.testBit_shiftRight]
    exact top.2 _ (by omega)
  · rw [← iter_F_shiftRight, ← iter_add, split, show c+age3 m=x.log2+t-3*m by omega]

/-- Only the admissible part of each selected width has to die. The margin
    pays for the ancestor width and the time that builds the outer band. -/
theorem q01_of_admissible_exclusion
    (holes : ∀ b r : Nat, r < 2 → ∃ p m k, b + 3*m + age3 m ≤ p ∧ p%2=r ∧
      ∀ y, Top y p → Admissible m (y >>> (p-3*m)) → ∃ s < k, iter G s y % 2 = 0) :
    Q01 := by
  apply Q01_iff_integer.mpr
  intro x
  apply Classical.byContradiction
  intro no
  have alive (s : Nat) : iter G s x % 2 = 1 := by have := not_exists.mp no s; omega
  have nz : x ≠ 0 := by
    have h := alive 0
    change x % 2 = 1 at h
    omega
  obtain ⟨p,m,k,room,par,drop⟩ := holes x.log2 (x.log2%2) (by omega)
  let q := (p-x.log2)/2
  have width : x.log2+2*q=p := by dsimp [q]; omega
  have band := aged_band nz (m := m) (t := 2*q) (by omega)
  have top := Top_iter (top_log2 nz) (2*q)
  rw [width] at top band
  obtain ⟨s, _, white⟩ := drop _ top band
  rw [← iter_G_eq_iter_F_two_mul] at white
  have h := alive (q+s)
  rw [iter_add] at h
  omega

/-- Count pre-support survivors for each listed outer word. Lists run from
    the wall outwards; the L inner cells supply all the free choices here. -/
def pinCount (L : Nat) (bands : List (List Bool)) : Nat :=
  (bands.map fun band => cubeSum L (fun l => if ok (l ++ band) then 1 else 0)).sum

theorem pinCount_le (L : Nat) (bands : List (List Bool)) :
    pinCount L bands ≤ bands.length * 2^(L/2) := by
  have per (band : List Bool) :
      cubeSum L (fun l => if ok (l ++ band) then 1 else 0) ≤ 2^(L/2) := by
    have h := PhaseTwo.ExactShellLoss.count_ok L []
    simp only [List.nil_append] at h
    rw [← count_constrained, ← h]
    apply cubeSum_le
    intro l
    by_cases h : ok (l ++ band)
    · simp [h, PhaseTwo.ExactShellLoss.ok_prefix_of_append l band h]
    · simp [h]
  induction bands with
  | nil => simp [pinCount]
  | cons band bands ih =>
    simp only [pinCount,List.map_cons,List.sum_cons,List.length_cons,Nat.succ_mul] at *
    have := per band
    omega

end PhaseTwo.ThinShell
