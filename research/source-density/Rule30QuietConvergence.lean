module
public import Rule30QuietComponents
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30QuietCorner
open Rule30Jen (cell)
open Rule30SourceObservables (bit count)
open Rule30SourceDensityRegion
open ClockComponent (blackErr)

def deviation (u : History) (j : Int) (s n : Nat) : Int :=
  ends u j s n+max (blackErr u j s n) (-blackErr u j s n)

private theorem count_nonneg (f : Nat→Bool) (n : Nat) : 0≤count f n := by
  induction n with
  | zero => simp [count]
  | succ n ih => simp only [count];cases f n <;> simp [bit] <;> omega

theorem compare_deviation {u : History} (hu : Evolution u) (j : Int) (s n : Nat) :
    deviation u j s n≤5*defects u (j+2) s n+3 ∧
    defects u (j+2) s n≤12*deviation u j s n+7 := by
  have h:=ClockComponent.defect_comparison hu j s n
  have f:=ClockComponent.source_le_defects hu j s n
  have v:=(defect_comparison hu j s n).1
  have e : 0≤defects u (j+2) s n := count_nonneg _ _
  have a : 0≤ends u j s n := count_nonneg _ _
  unfold deviation blackErr deficit at *
  omega

/-- Equivalent to f(n)/n tending to zero for a nonnegative integer count.
The definition uses only integer inequalities. -/
def Sublinear (f : Nat→Int) : Prop := ∀ k : Nat, ∃ T : Nat, ∀ n : Nat,T≤n → (k:Int)*f n≤(n:Int)

private theorem sublinear_of_bound (f g : Nat→Int) (m b : Nat)
    (h : ∀ n : Nat,f n≤(m:Int)*g n+(b:Int)) (hg : Sublinear g) : Sublinear f := by
  intro k
  obtain ⟨T,ht⟩:=hg (2*k*m)
  refine ⟨max T (2*k*b),fun n hn=>?_⟩
  have t:=ht n (by omega)
  have mul:=Int.mul_le_mul_of_nonneg_left (h n) (show 0≤(k:Int) by omega)
  have k0 : 2*k*b≤n := by omega
  have ik : (2:Int)*k*b≤n := by exact_mod_cast k0
  have alter : ((2:Int)*k*m)*g n=2*((k:Int)*((m:Int)*g n)) := by ac_rfl
  have changeOrder : (2:Int)*k*b=2*((k:Int)*b) := by ac_rfl
  simp only [Int.natCast_mul,Int.cast_ofNat_Int,alter] at t
  rw [Int.mul_add] at mul
  rw [changeOrder] at ik
  omega

theorem convergence_iff {u : History} (hu : Evolution u) (j : Int) :
    Sublinear (fun n=>deviation u j 0 n) ↔ Sublinear (fun n=>defects u (j+2) 0 n) := by
  constructor
  · exact sublinear_of_bound _ _ 12 7 (fun n=>(compare_deviation hu j 0 n).2)
  · exact sublinear_of_bound _ _ 5 3 (fun n=>(compare_deviation hu j 0 n).1)
end Ruliology.CellularAutomata.Rule30QuietCorner
