module
public import Rule30QuietCorner
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30QuietCornerSharp
open Rule30Jen (rule)
open Rule30Realization (evol)
open Rule30SourceDensityRegion Rule30QuietCorner
set_option maxRecDepth 100000
set_option maxHeartbeats 0
private def rows2 : Array Nat := #[63,1,67,100]
private def film2 (t : Nat) (i : Int) := (rows2.getD (t%4) 0).testBit ((i%7).toNat)
private theorem wrap2 : ((List.range 4).all fun t => (List.range 7).all fun i =>
    film2 (t+1) i == rule (film2 t ((i:Int)-1)) (film2 t i) (film2 t ((i:Int)+1)))=true := by decide +kernel
private theorem step2 : Evolution film2 := by
  intro t i
  let ti:=t%4
  let j:=(i%7).toNat
  have ht : ti<4 := Nat.mod_lt _ (by decide)
  have hj : j<7 := by dsimp [j];omega
  have atCell:=List.all_eq_true.mp (List.all_eq_true.mp wrap2 ti (List.mem_range.mpr ht)) j (List.mem_range.mpr hj)
  have eq:=beq_iff_eq.mp atCell
  have index : (j:Int)=i%7 := by dsimp [j];omega
  simpa only [film2,ti,index,show (t%4+1)%4=(t+1)%4 by omega,
    show (t%4)%4=t%4 by omega,show (i%7)%7=i%7 by omega,
    show (i%7-1)%7=(i-1)%7 by omega,show (i%7+1)%7=(i+1)%7 by omega] using eq

private def rows4 : Array Nat := #[1]
private def film4 (t : Nat) (i : Int) := (rows4.getD (t%1) 0).testBit ((i%2).toNat)
private theorem wrap4 : ((List.range 1).all fun t => (List.range 2).all fun i =>
    film4 (t+1) i == rule (film4 t ((i:Int)-1)) (film4 t i) (film4 t ((i:Int)+1)))=true := by decide +kernel
private theorem step4 : Evolution film4 := by
  intro t i
  let ti:=t%1
  let j:=(i%2).toNat
  have ht : ti<1 := Nat.mod_lt _ (by decide)
  have hj : j<2 := by dsimp [j];omega
  have atCell:=List.all_eq_true.mp (List.all_eq_true.mp wrap4 ti (List.mem_range.mpr ht)) j (List.mem_range.mpr hj)
  have eq:=beq_iff_eq.mp atCell
  have index : (j:Int)=i%2 := by dsimp [j];omega
  simpa only [film4,ti,index,show (t%1+1)%1=(t+1)%1 by omega,
    show (t%1)%1=t%1 by omega,show (i%2)%2=i%2 by omega,
    show (i%2-1)%2=(i-1)%2 by omega,show (i%2+1)%2=(i+1)%2 by omega] using eq


/-- D=1,E=2 on the four-tick film, and D=4,E=1 on the static stripe. -/
theorem sharp_slopes :
    (∃ u : History, Evolution u ∧ (∀ t,u (t+4)=u t) ∧ deficit u 0 0 4=1 ∧ defects u 2 0 4=2) ∧
    (∃ u : History, Evolution u ∧ (∀ t,u (t+1)=u t) ∧ deficit u 0 0 1=4 ∧ defects u 2 0 1=1) := by
  constructor
  · refine ⟨film2,step2,fun t=>?_,by decide +kernel,by decide +kernel⟩
    funext i;unfold film2;rw [show (t+4)%4=t%4 by omega]
  · refine ⟨film4,step4,fun t=>?_,by decide +kernel,by decide +kernel⟩
    funext i;unfold film4;rw [show (t+1)%1=t%1 by omega]

/-- The initial seeds have binary codes 14 and 224 at sites zero and above.
With the observed bond starting at 2, each additive constant is met in three ticks. -/
def seed (n : Nat) (i : Int) := decide (0≤i) && n.testBit i.toNat

theorem sharp_startup :
    defects (evol (seed 14)) 4 0 3 - 2*deficit (evol (seed 14)) 2 0 3=7 ∧
    deficit (evol (seed 224)) 2 0 3 - 4*defects (evol (seed 224)) 4 0 3=3 := by decide +kernel
end Ruliology.CellularAutomata.Rule30QuietCornerSharp
