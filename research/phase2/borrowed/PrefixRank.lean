import Ruliology.CellularAutomata.Rule30ZeroBoundary

/-! Obstructions to marking a single residue class for strict descent in the original wall word. -/
namespace PrefixRank
open Ruliology.CellularAutomata.Rule30ZeroBoundary.IntegerForm (G)

def bits (y : Nat) : List Bool := if y = 0 then [] else ((List.range (y.log2+1)).reverse).map (y.testBit ·)

def value {α : Type} (T : Bool → α → α) : List Bool → α → α
  | [], z => z
  | b::w, z => T b (value T w z)

def StrictAt (q : Nat) (rank : Nat → Nat) :=
  ∀ y, y%4 = q → G y%2 = 1 → rank (G y) < rank y

private theorem append_value {α : Type} (T : Bool → α → α) (u w : List Bool) (z : α) :
    value T (u++w) z = value T u (value T w z) := by
  induction u with
  | nil => rfl
  | cons b u ih => exact congrArg (T b) ih

private theorem monotone_value {α : Type} {T : Bool → α → α} {le : α → α → Prop}
    (hm : ∀ b u v, le u v → le (T b u) (T b v)) (w : List Bool) (u v : α) (h : le u v) :
    le (value T w u) (value T w v) := by
  induction w with
  | nil => exact h
  | cons b w ih => exact hm b _ _ ih

private theorem prefix_witness {α : Type} {T : Bool → α → α} {le : α → α → Prop}
    (hm : ∀ b u v, le u v → le (T b u) (T b v)) (read : α → Nat)
    (hr : ∀ u v, le u v → read u ≤ read v) (z : α)
    (q y : Nat) (w : List Bool) (hclass : y%4 = q) (hsurv : G y%2 = 1)
    (hprefix : bits (G y) = bits y ++ w) (increases : le z (value T w z)) :
    ¬ StrictAt q (fun v => read (value T (bits v) z)) := by
  intro h
  have strict := h y hclass hsurv
  dsimp only at strict
  rw [hprefix, append_value] at strict
  exact (Nat.not_lt_of_ge (hr _ _ (monotone_value hm _ _ _ increases))) strict

/-- Neither cofinal residue can supply strict descent for a bottom-initialized, monotone
    edge-first word interpretation, with a monotone natural-number readout. -/
theorem no_bottom_rank {α : Type} {T : Bool → α → α} {le : α → α → Prop}
    (hm : ∀ b u v, le u v → le (T b u) (T b v)) (read : α → Nat)
    (hr : ∀ u v, le u v → read u ≤ read v) (z : α) (bottom : ∀ v, le z v) :
    ¬ StrictAt 1 (fun v => read (value T (bits v) z)) ∧
    ¬ StrictAt 3 (fun v => read (value T (bits v) z)) := by
  exact ⟨prefix_witness hm read hr z 1 13 [true,true] (by decide) (by decide) (by decide) (bottom _),
    prefix_witness hm read hr z 3 3 [false,true] (by decide) (by decide) (by decide) (bottom _)⟩

private def affine (a b : Bool → Nat) (i : Bool) (x : Nat) := a i * x + b i

private theorem extensive (a b : Bool → Nat) (i : Bool) (hi : a i ≠ 0) (x : Nat) :
    x ≤ affine a b i x := by
  have h := Nat.mul_le_mul_right x (show 1 ≤ a i by omega)
  simp [affine] at *
  omega

/-- In scalar natural affine interpretations the terminal can be any natural value. -/
theorem no_scalar_rank (a b : Bool → Nat) (z : Nat) :
    ¬ StrictAt 1 (fun v => value (affine a b) (bits v) z) ∧
    ¬ StrictAt 3 (fun v => value (affine a b) (bits v) z) := by
  have mono (i : Bool) (u v : Nat) (h : u ≤ v) : affine a b i u ≤ affine a b i v :=
    Nat.add_le_add_right (Nat.mul_le_mul_left _ h) _
  by_cases ha1 : a true = 0
  · constructor
    · intro h
      have s := h 13 (by decide) (by decide)
      change affine a b true _ < affine a b true _ at s
      simp [affine, ha1] at s
    · intro h
      have s := h 3 (by decide) (by decide)
      change affine a b true _ < affine a b true _ at s
      simp [affine, ha1] at s
  · constructor
    · apply prefix_witness (le := (· ≤ ·)) mono id (fun _ _ h => h) z 1 13 [true,true]
        (by decide) (by decide) (by decide)
      exact Nat.le_trans (extensive a b true ha1 z) (extensive a b true ha1 _)
    · by_cases ha0 : a false = 0
      · intro h
        have s := h 27 (by decide) (by decide)
        change affine a b true (affine a b true (affine a b false _)) <
          affine a b true (affine a b true (affine a b false _)) at s
        simp [affine, ha0] at s
      · apply prefix_witness (le := (· ≤ ·)) mono id (fun _ _ h => h) z 3 3 [false,true]
          (by decide) (by decide) (by decide)
        exact Nat.le_trans (extensive a b true ha1 z) (extensive a b false ha0 _)

open Ruliology.CellularAutomata.Rule30ZeroBoundary
open Ruliology.CellularAutomata.Rule30ZeroBoundary.IntegerForm

/-- The kit's aperiodicity of the free bits forces each odd mod-four class to recur. -/
theorem cofinal_class (y q : Nat) (hq : q = 1 ∨ q = 3)
    (odd : ∀ s, iter G s y % 2 = 1) (N : Nat) : ∃ s ≥ N, iter G s y % 4 = q := by
  have inX : InX (rowOfNat y) := by
    intro s
    rw [zrow_rowOfNat_col1, ← iter_G_eq_iter_F_two_mul, Nat.testBit_zero, odd]
    rfl
  have free (s : Nat) : zrow (rowOfNat y) (2*s+1) 1 = decide (iter G s y % 4 = 1) := by
    rw [zrow_rowOfNat_col1]
    change (F (iter F (2*s) y)).testBit 0 = _
    rw [← iter_G_eq_iter_F_two_mul, testBit_F_zero, Nat.testBit_succ, Nat.testBit_zero,
      Nat.testBit_zero, odd]
    have ho := odd s
    by_cases h : iter G s y % 4 = 1
    · have hh : (iter G s y / 2) % 2 ≠ 1 := by omega
      simp [h,hh]
    · have hh : (iter G s y / 2) % 2 = 1 := by omega
      simp [h,hh]
  apply Classical.byContradiction
  intro miss
  apply free_not_eventuallyPeriodic (finSupp_rowOfNat y) inX
  refine ⟨N, 1, by decide, ?_⟩
  intro s hs
  change zrow (rowOfNat y) (2*(s+1)+1) 1 = zrow (rowOfNat y) (2*s+1) 1
  rw [free, free]
  have no (j : Nat) (hj : N ≤ j) : iter G j y % 4 ≠ q := fun he => miss ⟨j,hj,he⟩
  have now := no s hs
  have nxt := no (s+1) (by omega)
  have a := odd s
  have b := odd (s+1)
  by_cases h : iter G s y % 4 = 1
  · have h' : iter G (s+1) y % 4 = 1 := by omega
    simp [h, h']
  · have h' : iter G (s+1) y % 4 ≠ 1 := by omega
    simp [h, h']

private theorem no_cofinal_descent (r : Nat → Nat) (weak : ∀ n, r (n+1) ≤ r n)
    (strict : ∀ N, ∃ n ≥ N, r (n+1) < r n) : False := by
  have down (a b : Nat) (h : a ≤ b) : r b ≤ r a := by
    induction b with
    | zero =>
      have ha : a = 0 := by omega
      subst a
      exact Nat.le_refl _
    | succ b ih =>
      by_cases he : a = b+1
      · simp [he]
      · exact Nat.le_trans (weak b) (ih (by omega))
  have imposs (v : Nat) : ∀ i, r i = v → False := by
    induction v using Nat.strongRecOn with
    | ind v ih =>
      intro i hi
      obtain ⟨j,hij,hdrop⟩ := strict i
      have bound := down i j hij
      exact ih (r (j+1)) (by omega) (j+1) rfl
  exact imposs (r 0) 0 rfl

/-- Strict descent on just one marked residue would suffice for white-wall mortality. -/
theorem q01_of_marked_rank (q : Nat) (hq : q = 1 ∨ q = 3) (rank : Nat → Nat)
    (weak : ∀ y, y%2 = 1 → G y%2 = 1 → rank (G y) ≤ rank y)
    (strict : StrictAt q rank) : Q01 := by
  apply Q01_iff_integer.mpr
  intro y
  apply Classical.byContradiction
  intro nohit
  have odd (s : Nat) : iter G s y % 2 = 1 := by
    have miss : iter G s y % 2 ≠ 0 := fun h => nohit ⟨s,h⟩
    omega
  apply no_cofinal_descent (fun s => rank (iter G s y))
  · intro n
    exact weak _ (odd n) (odd (n+1))
  · intro N
    obtain ⟨s,hs,hq'⟩ := cofinal_class y q hq odd N
    exact ⟨s,hs,strict _ hq' (odd (s+1))⟩

end PrefixRank
