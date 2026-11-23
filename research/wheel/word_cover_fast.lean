module
public import word_cover_macro
public import WheelObserverTransport
@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open WheelObserverTransport Rule30GateTrap

private theorem present (xs : List Nat) (j : Nat) :
    (maskOf xs).testBit j = xs.contains j := by
  induction xs with
  | nil => simp [maskOf]
  | cons x xs ih =>
    rw [maskOf,Nat.testBit_or,ih,List.contains_cons]
    suffices h : (1 <<< x).testBit j = (j == x) by simp [h]
    rw [Nat.testBit_shiftLeft]
    by_cases eq : j=x
    · simp [eq]
    · have ne : (j==x) = false := Bool.eq_false_iff.mpr (fun h => eq (beq_iff_eq.mp h))
      by_cases le : x≤j
      · have gap : j-x≠0 := by omega
        have off : (1 : Nat).testBit (j-x)=false := Bool.eq_false_iff.mpr
          (fun h => gap (Nat.testBit_one_eq_true_iff_self_eq_zero.mp h))
        simp [le,off,ne]
      · simp [le,ne]

private theorem table_eq : trapMask = maskOf trapCodes := by decide +kernel

/-- Replace the linear walk through the 829 trap codes by its checked bitset. -/
theorem fast_admit (n : Nat) : PureThreeExit.admit true n 16 =
    fun t x => !(t+1==n) || !trapMask.testBit x := by
  funext t x
  simp [PureThreeExit.admit,table_eq,present]
end Ruliology.CellularAutomata.WordCover
