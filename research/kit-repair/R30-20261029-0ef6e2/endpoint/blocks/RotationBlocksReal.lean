import RealBridge

/-! The block theorem for a rotation by a real angle read through a real arc: two nonempty finite blocks of readings, set
one after the other in the order of the answers to *is the point in the arc?*. Core proof: `Rule30RotationBlocks`. -/

namespace RotationRealBridge

open Ruliology.CellularAutomata.Rule30RotationBlocks
open Ruliology.CellularAutomata.Rule30Realization (evol)

private theorem arc_letter (y γ : ℝ) (h₀ : 0 < γ) (h₁ : γ < 1) (b : Bool) :
    (Int.fract ((if b then γ else 0) + y) < γ) ↔
      ⌊y + (if b then γ else -γ)⌋ - ⌊y⌋ = (if b then 1 else -1) := by
  cases b
  · simp only [Bool.false_eq_true, ite_false, zero_add]
    rw [arc_floor _ γ h₀ h₁, show y - γ = y + -γ by ring]
    omega
  · simp only [ite_true]
    rw [arc_floor _ γ h₀ h₁, add_comm γ, add_sub_cancel_right]

/-- **Blocks in the order of a rotation.** Let `letter n` be the answer to *is `e + (n + d) α` in the arc `[0, γ)` of the
circle of length one?*, with `e` one of its two ends, `0` (`b = false`) or `γ` (`b = true`), `α` irrational and `d` any
integer. Let `B false` and `B true` be nonempty lists of readings. In a row with a leftmost black cell whose column `i`
reads `0101…` from time `a`, column `i + 1` on the white ticks from `a` on is not the concatenation
`B (letter 0) ++ B (letter 1) ++ …`. -/
theorem rotation_blocks_excluded (x : ℤ → Bool) (lo i : ℤ)
    (hlo : x lo = true) (hleft : ∀ j < lo, x j = false)
    (α γ : ℝ) (hα : Irrational α) (h₀ : 0 < γ) (h₁ : γ < 1)
    (d : ℤ) (b : Bool) (a : ℕ) (B : Bool → List Bool) (hB : ∀ v, B v ≠ [])
    (letter : ℕ → Bool)
    (hletter : ∀ n : ℕ, letter n = decide (Int.fract ((if b then γ else 0) + ((n : ℝ) + d) * α) < γ))
    (clock : ∀ t, evol x (a + t) i = decide (t % 2 = 1))
    (visible : ∀ n y, y < (B (letter n)).length →
      evol x (a + 2 * (total (fun k => (B (letter k)).length) n + y)) (i + 1) = (B (letter n)).getD y false) :
    False := by
  let k := d.natAbs
  let q := ((k : ℤ) + d).toNat
  have hq : (k : ℤ) + d = q := by dsimp [q, k]; omega
  let θ := if b then γ else -γ
  let e : ℤ := if b then 1 else -1
  generalize hw : (fun k => (B (letter k)).length) = w at visible
  -- the letter at `k + n` is read off the two lines at `q + n`
  have key (n : ℕ) : letter (k + n) = decide (⌊((q + n : ℕ) : ℝ) * α + θ⌋ - ⌊((q + n : ℕ) : ℝ) * α⌋ = e) := by
    have eq : (((k + n : ℕ) : ℝ) + d) = ((q + n : ℕ) : ℝ) := by
      have : (k : ℝ) + d = q := by exact_mod_cast hq
      push_cast
      linarith
    rw [hletter, eq, decide_eq_decide, arc_letter _ γ h₀ h₁]
  have shift (n : ℕ) : total w (k + n) = total w k + total (fun j => w (k + j)) n := by
    induction n with
    | zero => rfl
    | succ n ih => rw [← Nat.add_assoc, total_succ, total_succ, ih]; omega
  have wlen (n : ℕ) : (B (decide (⌊((q + n : ℕ) : ℝ) * α + θ⌋ - ⌊((q + n : ℕ) : ℝ) * α⌋ = e))).length = w (k + n) := by
    rw [← key, ← hw]
  refine blocks_excluded x lo i hlo hleft (real_line α hα) (real_phase α θ) (fun v => (B (decide (v = e))).length)
    (fun v => List.length_pos_iff.mpr (hB _)) (fun v y => (B (decide (v = e))).getD y false) (a + 2 * total w k) q
    (fun t => ?_) (fun n y hy => ?_)
  · rw [show a + 2 * total w k + t = a + (2 * total w k + t) by omega, clock,
      show (2 * total w k + t) % 2 = t % 2 by omega]
  · have sums : total (fun j => (B (decide (⌊((q + j : ℕ) : ℝ) * α + θ⌋ - ⌊((q + j : ℕ) : ℝ) * α⌋ = e))).length) n =
        total (fun j => w (k + j)) n := by
      congr 1
      funext j
      exact wlen j
    have hy' : y < (B (letter (k + n))).length := by rw [key]; exact hy
    have v := visible (k + n) y hy'
    rw [shift, key] at v
    show evol x (a + 2 * total w k + 2 * (total (fun j =>
      (B (decide (⌊((q + j : ℕ) : ℝ) * α + θ⌋ - ⌊((q + j : ℕ) : ℝ) * α⌋ = e))).length) n + y)) (i + 1) = _
    rw [sums, show a + 2 * total w k + 2 * (total (fun j => w (k + j)) n + y) =
      a + 2 * (total w k + total (fun j => w (k + j)) n + y) by omega]
    exact v

end RotationRealBridge

