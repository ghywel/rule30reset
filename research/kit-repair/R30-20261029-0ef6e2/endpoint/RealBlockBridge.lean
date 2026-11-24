import RealBridge

/-! A release-facing corollary of the endpoint theorem, with independent observation onset
and an arbitrary finite Boolean readout of a real rotation. -/

namespace RotationRealBridge

open Ruliology.CellularAutomata.Rule30RotationEndpoints
open Ruliology.CellularAutomata.Rule30Realization (evol)

private theorem endpoint_letter (y γ : ℝ) (h₀ : 0 < γ) (h₁ : γ < 1) (b : Bool) :
    (Int.fract ((if b then γ else 0) + y) < γ) ↔
      ⌊y + (if b then γ else -γ)⌋ - ⌊y⌋ = (if b then 1 else -1) := by
  cases b
  · simp only [Bool.false_eq_true, ite_false, zero_add]
    rw [arc_floor _ γ h₀ h₁, show y - γ = y + -γ by ring]
    omega
  · simp only [ite_true]
    rw [arc_floor _ γ h₀ h₁, add_comm γ, add_sub_cancel_right]

/-- The white ticks are numbered from a white tick 'a' of the eventual clock. Agreement
may begin at any later white index 'H'. Read any Boolean function of 'r' consecutive arc
observations. The signed 'd' allows the window to start before or after either endpoint.
The convention for the arc is [0, γ). -/
theorem rotation_block_excluded (x : ℤ → Bool) (lo i : ℤ)
    (hlo : x lo = true) (hleft : ∀ j < lo, x j = false)
    (α γ : ℝ) (hα : Irrational α) (h₀ : 0 < γ) (h₁ : γ < 1)
    (d : ℤ) (b : Bool) (a H r : ℕ) (read : (Fin r → Bool) → Bool)
    (clock : ∀ t, evol x (a + t) i = decide (t % 2 = 1))
    (visible : ∀ t : ℕ, H ≤ t → evol x (a + 2 * t) (i + 1) =
      read (fun s => decide (Int.fract ((if b then γ else 0) +
        ((t : ℝ) + d + (s.val : ℝ)) * α) < γ))) : False := by
  let k := H + d.natAbs
  let q := ((k : ℤ) + d).toNat
  have hk : H ≤ k := by dsimp [k]; omega
  have hq : (k : ℤ) + d = q := by dsimp [q, k]; omega
  have shift (t s : ℕ) : ((t + k : ℕ) : ℝ) + d + (s : ℝ) = ((t + q + s : ℕ) : ℝ) := by
    have eq : (k : ℝ) + d = q := by exact_mod_cast hq
    push_cast
    linarith
  let θ := if b then γ else -γ
  let e : ℤ := if b then 1 else -1
  refine arc_excluded x lo i hlo hleft (real_line α hα) (real_phase α θ) (a + 2*k) q r
    (fun v => read (fun s => decide (v s.val = e))) ?_ ?_ ?_
  · intro v w h
    congr 1
    funext s
    rw [h s.val s.isLt]
  · intro t
    rw [show a + 2*k + t = a + (2*k+t) by omega, clock, show (2*k+t)%2 = t%2 by omega]
  · intro t
    rw [show a + 2*k + 2*t = a + 2*(t+k) by omega, visible (t+k) (by omega)]
    congr 1
    funext s
    rw [shift, decide_eq_decide, endpoint_letter _ γ h₀ h₁]

end RotationRealBridge
