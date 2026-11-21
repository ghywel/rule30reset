module
public import Ruliology.CellularAutomata.Rule30GateTrap
@[expose] public section
namespace Ruliology.CellularAutomata.TrapClockWindow
open Rule30StripCertificates Rule30Ether Rule30PeriodTwoCoupled Rule30GateTrap
-- Unchanged definitions and proofs from the kit's Rule30GateTrapLift, commit 40017e8.
section Driven18
variable (R : Nat → Bool)

/-- The window of `R` of the columns `1..18` at time `t`. Its first sixteen cells are `win R t`. -/
def win18 (t : Nat) : List Bool := rowOf (drv altCol R) t 0 18

theorem win18_length (t : Nat) : (win18 R t).length = 18 := length_seg _ _

theorem win18_head (t : Nat) : (win18 R t).headD false = drv altCol R t 1 := rowOf_head _ t 0 17

theorem win18_eq (t : Nat) :
    win18 R t = win R t ++ [drv altCol R t 17, drv altCol R t 18] := by
  unfold win18 win rowOf
  rw [show (18 : Nat) = 16 + 1 + 1 from rfl, seg_succ, seg_succ]
  simp [List.append_assoc]

/-- From an odd time, the 18-column window two steps later is a double step of the window, with the
two values of column `19` as the exterior inputs. -/
theorem win18_step2 (t : Nat) (ht : t % 2 = 1) :
    ∃ x1 x2, win18 R (t + 2) = step2 (win18 R t) x1 x2 := by
  have h1 := rowOf_succ (drv_isR30 altCol R) t 0 18
  have h2 := rowOf_succ (drv_isR30 altCol R) (t + 1) 0 18
  rw [drv_col0] at h1 h2
  have a1 : altCol t = false := by unfold altCol; simp [ht]
  have a2 : altCol (t + 1) = true := by unfold altCol; simp; omega
  rw [a1] at h1
  rw [a2] at h2
  refine ⟨drv altCol R t 19, drv altCol R (t + 1) 19, ?_⟩
  unfold win18 step2
  rw [show t + 2 = t + 1 + 1 by omega, h2, h1]

end Driven18
end Ruliology.CellularAutomata.TrapClockWindow
