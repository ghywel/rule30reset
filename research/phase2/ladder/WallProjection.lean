import Ruliology.CellularAutomata.Rule30LateTwins

namespace PhaseTwo.WallProjection

open Ruliology.CellularAutomata Rule30ZeroBoundary IntegerForm Rule30LateTwins

/-- A start in the width-at-most-`2n` cube with the first `n` even checks black. -/
def EvenPinned (n y : Nat) : Prop :=
  y < 4 ^ n ∧ (List.range n).all (fun s => iter G s y % 2 == 1) = true

/-- The first `2n` cells of a row, starting at the white wall. -/
def wallHalf (n y : Nat) : Nat := y % 4 ^ n

/-- Separation of distinct age-`2n` images by their wall half. -/
def WallHalfDetermines (n : Nat) : Prop :=
  ∀ x y, EvenPinned n x → EvenPinned n y →
    wallHalf n (iter G n x) = wallHalf n (iter G n y) → iter G n x = iter G n y

theorem five_witness :
    EvenPinned 5 579 ∧ EvenPinned 5 413 ∧
      iter G 5 579 = 822074 ∧ iter G 5 413 = 411450 ∧
      wallHalf 5 (iter G 5 579) = 826 ∧ wallHalf 5 (iter G 5 413) = 826 := by
  unfold EvenPinned
  decide +kernel

theorem six_witness :
    EvenPinned 6 1277 ∧ EvenPinned 6 2997 ∧
      iter G 6 1277 = 6561921 ∧ iter G 6 2997 = 13164673 ∧
      wallHalf 6 (iter G 6 1277) = 129 ∧ wallHalf 6 (iter G 6 2997) = 129 := by
  unfold EvenPinned
  decide +kernel

theorem not_wallHalfDetermines_five : ¬ WallHalfDetermines 5 := by
  intro h
  obtain ⟨hx, hy, ageX, ageY, wallX, wallY⟩ := five_witness
  have eq := h _ _ hx hy (wallX.trans wallY.symm)
  rw [ageX, ageY] at eq
  omega

theorem not_wallHalfDetermines_six : ¬ WallHalfDetermines 6 := by
  intro h
  obtain ⟨hx, hy, ageX, ageY, wallX, wallY⟩ := six_witness
  have eq := h _ _ hx hy (wallX.trans wallY.symm)
  rw [ageX, ageY] at eq
  omega

/-- With no pin, even fixing the top bit does not restore separation. -/
theorem unpinned_equal_width_witness :
    1234 < 4 ^ 6 ∧ 1700 < 4 ^ 6 ∧
      (iter G 6 1234).log2 = 22 ∧ (iter G 6 1700).log2 = 22 ∧
      iter G 6 1234 ≠ iter G 6 1700 ∧
      wallHalf 6 (iter G 6 1234) = wallHalf 6 (iter G 6 1700) := by
  decide +kernel

/-- No start with exact top bit `p` passes all of its first `k` even checks. -/
def MissingTop (p k : Nat) : Prop :=
  ∀ y, Top y p → ∃ s < k, iter G s y % 2 = 0

/-- An immortal inhabits every larger top position of its own parity. -/
theorem immortal_at_top_of_parity {x p : Nat} (alive : ∀ s, iter G s x % 2 = 1)
    (h : x.log2 ≤ p) (parity : p % 2 = x.log2 % 2) :
    ∃ y, Top y p ∧ ∀ s, iter G s y % 2 = 1 := by
  have nz : x ≠ 0 := by
    have h0 := alive 0
    change x % 2 = 1 at h0
    omega
  let q := (p - x.log2) / 2
  have hp : p = x.log2 + 2 * q := by dsimp [q]; omega
  refine ⟨iter G q x, ?_, ?_⟩
  · rw [iter_G_eq_iter_F_two_mul, hp]
    exact Top_iter (top_log2 nz) _
  · intro s
    simpa only [iter_add] using alive (q + s)

/-- The missing top positions can use independent finite horizons and need only
    be unbounded within each parity. -/
theorem q01_iff_unbounded_missing_tops :
    Q01 ↔ ∀ b r : Nat, r < 2 → ∃ p k, b ≤ p ∧ p % 2 = r ∧ MissingTop p k := by
  constructor
  · intro q01 b r hr
    have bounded (M : Nat) : ∃ k, ∀ y < M, ∃ s < k, iter G s y % 2 = 0 := by
      induction M with
      | zero => exact ⟨0, fun _ hy => by omega⟩
      | succ M ih =>
        obtain ⟨k, deaths⟩ := ih
        obtain ⟨s, white⟩ := Q01_iff_integer.mp q01 M
        refine ⟨max k (s + 1), fun y hy => ?_⟩
        by_cases eq : y = M
        · exact ⟨s, by omega, eq ▸ white⟩
        · obtain ⟨t, ht, htWhite⟩ := deaths y (by omega)
          exact ⟨t, by omega, htWhite⟩
    let p := 2 * b + r
    obtain ⟨k, deaths⟩ := bounded (2 ^ (p + 1))
    refine ⟨p, k, by dsimp [p]; omega, by dsimp [p]; omega, ?_⟩
    intro y hy
    apply deaths y
    have nz : y ≠ 0 := by
      intro eq
      have bit := hy.1
      simp [eq] at bit
    rw [← Top_unique (top_log2 nz) hy]
    exact Nat.lt_log2_self
  · intro holes
    apply Q01_iff_integer.mpr
    intro x
    apply Classical.byContradiction
    intro no
    have alive (s : Nat) : iter G s x % 2 = 1 := by
      have := not_exists.mp no s
      omega
    obtain ⟨p, k, hb, parity, missing⟩ := holes x.log2 (x.log2 % 2) (by omega)
    obtain ⟨y, hy, hyAlive⟩ := immortal_at_top_of_parity alive hb parity
    obtain ⟨s, _, white⟩ := missing y hy
    have := hyAlive s
    omega

/-- For the diagonal K92.2 test, it suffices to certify the two exact
    widths `2n - 1` and `2n` at arbitrarily large `n`. -/
theorem q01_of_missing_diagonal_top_pair
    (holes : ∀ b, ∃ n, b + 2 ≤ n ∧ MissingTop (2 * n - 2) (2 * n) ∧
      MissingTop (2 * n - 1) (2 * n)) : Q01 := by
  apply q01_iff_unbounded_missing_tops.mpr
  intro b r hr
  obtain ⟨n, hn, evenTop, oddTop⟩ := holes b
  by_cases h : r = 0
  · exact ⟨2 * n - 2, 2 * n, by omega, by omega, evenTop⟩
  · exact ⟨2 * n - 1, 2 * n, by omega, by omega, oddTop⟩

end PhaseTwo.WallProjection
