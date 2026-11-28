import Ruliology.CellularAutomata.Rule30FirstChecks

namespace PhaseTwo.ExactShellLoss

open Ruliology.CellularAutomata Rule30ZeroBoundary Rule30FirstChecks

/-- For even list length, the finite row passes every earlier even check
and fails at the physical tick equal to the list length. -/
def death (l : List Bool) : Nat :=
  if ok l ∧ ¬ ok (l ++ [false]) then 1 else 0

private theorem white_padding (l : List Bool) : toRow (l ++ [false]) = toRow l := by
  funext i
  by_cases hi : i ≤ l.length
  · exact toRow_snoc_le l false i hi
  · have right := toRow_fin l i (by omega)
    by_cases last : i = l.length + 1
    · subst i
      rw [toRow_snoc_last, right]
    · rw [toRow_fin _ _ (by simp; omega), right]

theorem death_iff (l : List Bool) (he : l.length % 2 = 0) :
    death l = 1 ↔ ok l ∧ zrow (toRow l) l.length 1 = false := by
  unfold death
  have ext := ok_snoc l false
  rw [white_padding] at ext
  cases hz : zrow (toRow l) l.length 1 <;> by_cases h : ok l <;> simp_all

/-- Fill the nearest w bits arbitrarily and append z exterior white bits. -/
def padded (w z : Nat) : Nat :=
  cubeSum w (fun l => death (l ++ List.replicate z false))

/-- Exact positive width w with z trailing white cells before the tested tick. -/
def shell (w z : Nat) : Nat :=
  cubeSum (w-1) (fun l => death (l ++ true :: List.replicate z false))

private theorem leaf_sum (k : Nat) (p : List Bool) :
    cubeSum k (fun l => death (p ++ l)) + lastWhite k p = cnt k p := by
  induction k generalizing p with
  | zero =>
    simp only [cubeSum, List.append_nil, lastWhite, cnt, death]
    by_cases hp : ok (p ++ [false])
    · simp [hp, ok_of_snoc p false hp]
    · simp [hp]
  | succ k ih =>
    simp only [cubeSum, lastWhite, cnt]
    have a := ih (p ++ [false])
    have b := ih (p ++ [true])
    simp only [List.append_assoc, List.cons_append, List.nil_append] at a b
    omega

theorem first_deaths (n : Nat) : padded (2*n) 0 = ones n := by
  have h := leaf_sum (2*n) []
  have c := first_check_count n
  rw [count_constrained] at h
  simp only [List.nil_append, show 2*n/2 = n by omega] at h
  unfold padded
  simp only [List.replicate_zero, List.append_nil]
  unfold firstCheck at c
  omega

theorem ok_prefix_of_append (l t : List Bool) (h : ok (l ++ t)) : ok l := by
  induction t generalizing l with
  | nil => simpa using h
  | cons b t ih =>
    apply ok_of_snoc l b
    apply ih (l ++ [b])
    simpa using h

theorem count_ok (k : Nat) (p : List Bool) :
    cubeSum k (fun l => if ok (p ++ l) then 1 else 0) = cnt k p := by
  induction k generalizing p with
  | zero => simp [cubeSum, cnt]
  | succ k ih =>
    simp only [cubeSum, cnt]
    have a := ih (p ++ [false])
    have b := ih (p ++ [true])
    simp only [List.append_assoc, List.cons_append, List.nil_append] at a b
    omega

private theorem short_bound (w z : Nat) : padded w z ≤ 2^(w/2) := by
  rw [← count_constrained]
  have h := count_ok w []
  simp only [List.nil_append] at h
  rw [← h]
  apply cubeSum_le
  intro l
  by_cases hv : ok (l ++ List.replicate z false)
  · have hl := ok_prefix_of_append _ _ hv
    simp [death, hl, hv]
    split <;> omega
  · simp [death, hv]

private theorem split_last (w z : Nat) : padded (w+1) z = padded w (z+1) + shell (w+1) z := by
  unfold padded shell
  rw [cubeSum_snoc, cubeSum_add]
  simp [List.append_assoc, List.replicate_succ]

private theorem spread (w h z K : Nat)
    (small : ∀ j < h, 128 * shell (w+h-j) (z+j) < K) :
    128 * padded (w+h) z + h ≤ 128 * padded w (z+h) + h*K := by
  induction h generalizing z with
  | zero => simp
  | succ h ih =>
    have first := small 0 (by omega)
    simp only [Nat.sub_zero, Nat.add_zero] at first
    have rest := ih (z+1) (fun j hj => by
      have later := small (j+1) (by omega)
      simpa only [show w + h.succ - (j+1) = w+h-j by omega,
        show z+(j+1) = z+1+j by omega] using later)
    rw [show w+h.succ = (w+h)+1 by omega, split_last, show h.succ*K = h*K+K by exact Nat.succ_mul _ _]
    rw [show w+h.succ = w+h+1 by omega] at first
    rw [show z+1+h = z+(h+1) by omega] at rest
    omega

private theorem good_pair (m : Nat) :
    2^(m+1) ≤ 8 * ones (m+1) ∨ 2^(m+2) ≤ 8 * ones (m+2) := by
  have h := adjacent m
  have a := Nat.min_le_left (ones (m+1)) (2^(m+1)-ones (m+1))
  have b := Nat.min_le_left (ones (m+2)) (2^(m+2)-ones (m+2))
  unfold gap at h
  rw [pow_one_more, pow_two_more]
  omega

theorem good_shell {n : Nat} (hn : 4 ≤ n) (good : 2^n ≤ 8 * ones n) :
    ∃ j < 8, 2^n ≤ 128 * shell (2*n-j) j := by
  let w := 2*n-8
  have wh : w+8 = 2*n := by dsimp [w]; omega
  have hw : w/2 = n-4 := by dsimp [w]; omega
  have scale : 2^n = 16*2^(n-4) := by
    exact (congrArg (2^·) (show n = (n-4)+4 by omega)).trans (pow_four_more _)
  apply Classical.byContradiction
  intro no
  have small (j : Nat) (hj : j < 8) : 128 * shell (w+8-j) (0+j) < 2^n := by
    rw [wh, Nat.zero_add]
    apply Nat.lt_of_not_ge
    intro ge
    exact no ⟨j, hj, ge⟩
  have h := spread w 8 0 (2^n) small
  have short := short_bound w 8
  rw [hw] at short
  rw [wh, first_deaths, Nat.zero_add] at h
  omega

/-- For at least one of each pair of consecutive cube indices ≥4, a single
exact width among its last eight contributes at least 2^n/128 first deaths. -/
theorem every_pair_has_shell (m : Nat) (hm : 3 ≤ m) :
    ∃ n, (n = m+1 ∨ n = m+2) ∧ ∃ j < 8, 2^n ≤ 128 * shell (2*n-j) j := by
  rcases good_pair m with left | right
  · exact ⟨m+1, Or.inl rfl, good_shell (by omega) left⟩
  · exact ⟨m+2, Or.inr rfl, good_shell (by omega) right⟩

end PhaseTwo.ExactShellLoss
