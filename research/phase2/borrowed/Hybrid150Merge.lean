import Hybrid150Edge

/-! A pair of distinct growing finite starts coalesces in one round and passes
    any chosen finite number of even checks. The fixed twelve-cell prefixes are
    the least cylinder in the registered search, ordered by width and roots. -/
namespace Hybrid150Edge

private theorem tick_local (g : Bool → Bool → Bool) (x y : Row) (i : Nat)
    (h : ∀ j, j ≤ i+1 → i ≤ j+1 → x j = y j) : tick g x i = tick g y i := by
  have r : east x i = east y i := by
    cases i with
    | zero => rfl
    | succ j => exact h j (by omega) (by omega)
  simp only [tick, h (i+1) (by omega) (by omega), h i (by omega) (by omega), r]

private theorem round_local (x y : Row) (i : Nat)
    (h : ∀ j, j ≤ i+2 → i ≤ j+2 → x j = y j) : round x i = round y i := by
  unfold round nonlin
  apply tick_local
  intro j hj hj'
  unfold linear
  apply tick_local
  exact fun k hk hk' => h k (by omega) (by omega)

def replace12 (bits : Nat) (tail : Row) (i : Nat) :=
  if i < 12 then packed bits i else tail i

/-- Equality of the whole round image with any common tail, finite or infinite. -/
theorem merge_125_159 (tail : Row) :
    round (replace12 125 tail) = round (replace12 159 tail) := by
  have small : ∀ j : Fin 10, round (packed 125) j.val = round (packed 159) j.val := by decide +kernel
  funext i
  by_cases low : i < 10
  · have plain (v : Nat) : round (replace12 v tail) i = round (packed v) i :=
      round_local _ _ _ (fun j hj _ => by simp [replace12, show j < 12 by omega])
    exact (plain 125).trans ((small ⟨i, low⟩).trans (plain 159).symm)
  · apply round_local
    intro j _ hj
    have zero (v : Nat) (hv : v < 2^8) : packed v j = false :=
      Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le hv (Nat.pow_le_pow_right
        (by decide : 0 < (2 : Nat)) (by omega : 8 ≤ j)))
    simp only [replace12, zero 125 (by decide), zero 159 (by decide)]

private theorem six_checks : ∀ j : Fin 6, clock false (packed 125) (2*j.val) 0 = true := by
  decide +kernel

/-- For m≥6 there are two already-growing rows of width 2m+3 with the same
    image after two physical ticks. Both pass every even check through 2m.
    From odd tick 13 onward their common odd readings may be prescribed freely. -/
theorem merged_survivors (m : Nat) (hm : 6 ≤ m) (f : Nat → Bool) :
    ∃ x y : Row, x ≠ y ∧ Locked x (2*m+1) ∧ Locked y (2*m+1) ∧ round x = round y ∧
      (∀ j ≤ m, run j x 0 = true ∧ run j y 0 = true) ∧
      (∀ j, 6 ≤ j → j < m → oddBit x j = f j ∧ oddBit y j = f j) := by
  let b : Nat → Bool := fun t =>
    if t < 12 then clock false (packed 125) t 0 else if t%2=0 then true else f (t/2)
  obtain ⟨x, growing, obs⟩ := finite_trace (2*m) b
  have low : ∀ i ≤ 11, x i = packed 125 i := trace_prefix 11 false _ _ (fun t ht => by
    rw [obs t (by omega)]
    simp [b, show t < 12 by omega])
  have repl : replace12 125 x = x := by
    funext i
    by_cases hi : i < 12
    · simp [replace12, hi, low i (by omega)]
    · simp [replace12, hi]
  let y := replace12 159 x
  have merged : round x = round y := by simpa only [repl] using merge_125_159 x
  have agrees (j : Nat) (hj : 0 < j) : run j x = run j y := by
    cases j with
    | zero => omega
    | succ j => simp only [run, merged]
  have outside (i : Nat) (hi : 12 ≤ i) : y i = x i := by simp [y, replace12, show ¬i<12 by omega]
  have yp : Locked y (2*m+1) := by
    refine ⟨⟨fun i hi => (outside i (by omega)).trans (growing.1.1 i hi), ?_⟩, ?_⟩
    · rw [outside _ (by omega)]; exact growing.1.2
    · rw [outside _ (by omega)]; exact growing.2
  have distinct : x ≠ y := by
    intro eq
    have hx : x 1 = false := low 1 (by decide)
    have hy : y 1 = true := rfl
    rw [eq, hy] at hx
    contradiction
  refine ⟨x, y, distinct, growing, yp, merged, ?_, ?_⟩
  · intro j hj
    have black : run j x 0 = true := by
      rw [← clock_even, obs (2*j) (by omega)]
      by_cases early : 2*j < 12
      · simpa [b, early] using six_checks ⟨j, by omega⟩
      · simp [b, early]
    refine ⟨black, ?_⟩
    cases j with
    | zero => rfl
    | succ j => rwa [← agrees (j+1) (by omega)]
  · intro j start stop
    have bit := obs (2*j+1) (by omega)
    have first : oddBit x j = f j := by
      simpa [b, oddBit, clock_odd, show ¬2*j+1<12 by omega, show (2*j+1)%2=1 by omega,
        show (2*j+1)/2=j by omega] using bit
    exact ⟨first, by simpa only [oddBit, ← agrees j (by omega)] using first⟩

end Hybrid150Edge
