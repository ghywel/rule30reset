import SixComponentChecks
import SixTail

/-! Project the component certificate onto a fixed physical six-column band. -/
namespace PhaseFalls.Six
open Ruliology.CellularAutomata Rule30Jen

def levelAt (a : Nat) (i : Int) (t : Nat) := level a (t%3) (row t i)
def heightAt (a : Nat) (i : Int) (t : Nat) := height a (t%3) (row t i)

theorem levelAt_bound {a : Nat} (ha : a < 729) (i : Int) (t : Nat) :
    levelAt a i t ≤ 6 :=
  (component_bounds ha (Nat.mod_lt t (by decide : 0 < 3)) (row_lt t i)).1

theorem heightAt_bound {a : Nat} (ha : a < 729) (i : Int) (t : Nat) :
    heightAt a i t ≤ 11 :=
  (component_bounds ha (Nat.mod_lt t (by decide : 0 < 3)) (row_lt t i)).2

theorem component_progress {a : Nat} (ha : a < 729) (i : Int) (t : Nat)
    (h : allowed a (t%3) (row t i) (row (t+1) i) = true) :
    levelAt a i (t+1) < levelAt a i t ∨
      (levelAt a i (t+1) = levelAt a i t ∧
       (if levelAt a i t % 2 = 0 then heightAt a i (t+1) < heightAt a i t
        else tag (physicalEntry a i (t+1)) = tag (physicalEntry a i t))) := by
  have transition := component_edge ha (Nat.mod_lt t (by decide : 0 < 3)) (row_lt t i)
    (cell t (i-1)) (cell t (i+6))
  rw [row_step t i] at h
  simpa only [levelAt,heightAt,physicalEntry,row_step t i,show (t%3+1)%3=(t+1)%3 by omega]
    using transition h

end PhaseFalls.Six
