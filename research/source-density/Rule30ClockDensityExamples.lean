module
public import Rule30QuietCorner
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30ClockDensityExamples
open Rule30Jen (rule)
open Rule30Realization (evol)
open Rule30SourceDensityRegion Rule30QuietCorner
set_option maxRecDepth 100000
set_option maxHeartbeats 0
private def rows3 : Array Nat := #[543, 3873, 498]
private def film3 (t : Nat) (i : Int) := (rows3.getD (t%3) 0).testBit ((i%12).toNat)
private theorem wrap3 : ((List.range 3).all fun t => (List.range 12).all fun i =>
    film3 (t+1) i == rule (film3 t ((i:Int)-1)) (film3 t i) (film3 t ((i:Int)+1)))=true := by decide +kernel
private theorem step3 : Evolution film3 := by
  intro t i
  let ti:=t%3
  let j:=(i%12).toNat
  have ht : ti<3 := Nat.mod_lt _ (by decide)
  have hj : j<12 := by dsimp [j];omega
  have atCell:=List.all_eq_true.mp (List.all_eq_true.mp wrap3 ti (List.mem_range.mpr ht)) j (List.mem_range.mpr hj)
  have eq:=beq_iff_eq.mp atCell
  have index : (j:Int)=i%12 := by dsimp [j];omega
  simpa only [film3,ti,index,show (t%3+1)%3=(t+1)%3 by omega,
    show (t%3)%3=t%3 by omega,show (i%12)%12=i%12 by omega,
    show (i%12-1)%12=(i-1)%12 by omega,show (i%12+1)%12=(i+1)%12 by omega] using eq

private def rows6 : Array Nat := #[9979311498932161696903037, 15583160379004688193773828, 8709360116963735641338767, 2223815579933998775000273, 12477368289088154056804187, 14353061421898173961922888]
private def film6 (t : Nat) (i : Int) := (rows6.getD (t%6) 0).testBit ((i%84).toNat)
private theorem wrap6 : ((List.range 6).all fun t => (List.range 84).all fun i =>
    film6 (t+1) i == rule (film6 t ((i:Int)-1)) (film6 t i) (film6 t ((i:Int)+1)))=true := by decide +kernel
private theorem step6 : Evolution film6 := by
  intro t i
  let ti:=t%6
  let j:=(i%84).toNat
  have ht : ti<6 := Nat.mod_lt _ (by decide)
  have hj : j<84 := by dsimp [j];omega
  have atCell:=List.all_eq_true.mp (List.all_eq_true.mp wrap6 ti (List.mem_range.mpr ht)) j (List.mem_range.mpr hj)
  have eq:=beq_iff_eq.mp atCell
  have index : (j:Int)=i%84 := by dsimp [j];omega
  simpa only [film6,ti,index,show (t%6+1)%6=(t+1)%6 by omega,
    show (t%6)%6=t%6 by omega,show (i%84)%84=i%84 by omega,
    show (i%84-1)%84=(i-1)%84 by omega,show (i%84+1)%84=(i+1)%84 by omega] using eq

/-- The two ordinary periodic histories have the same limiting count pair at
bond 0. Site 2 has one black cell in every three ticks on the first history,
and three consecutive black cells recur every six ticks on the second. -/
theorem same_rates_different_clock :
    (∃ u : History, Evolution u ∧ (∀ t, u (t+3)=u t) ∧ black u 0 0 3=2 ∧ ends u 0 0 3=1 ∧
      u 0 2=true ∧ u 1 2=false ∧ u 2 2=false) ∧
    (∃ v : History, Evolution v ∧ (∀ t, v (t+6)=v t) ∧ black v 0 0 6=4 ∧ ends v 0 0 6=2 ∧
      v 0 2=true ∧ v 1 2=true ∧ v 2 2=true) := by
  constructor
  · refine ⟨film3,step3,fun t=>?_,by decide +kernel,by decide +kernel,by decide +kernel⟩
    funext i; unfold film3; rw [show (t+3)%3=t%3 by omega]
  · refine ⟨film6,step6,fun t=>?_,by decide +kernel,by decide +kernel,by decide +kernel⟩
    funext i; unfold film6; rw [show (t+6)%6=t%6 by omega]
end Ruliology.CellularAutomata.Rule30ClockDensityExamples
