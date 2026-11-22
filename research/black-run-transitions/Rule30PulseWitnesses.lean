import Rule30PulseRelay
import Ruliology.CellularAutomata.Rule30EtherThreeReach
namespace Ruliology.CellularAutomata.ShieldCascade.Witnesses
open Rule30Jen Rule30Realization Rule30EtherThree EchoGeometry
def init (z : Nat) (p : Int) := z.testBit (p-1).toNat
/-- Bitwise ordinary-realization bridge, as in the I80 physical control. -/
theorem actual (c : Nat→Bool) (z : Nat) (t i : Nat) :
    (rowN c z t).testBit i=evol (conf (init z) c) t ((i:Int)+1) := by
  induction t generalizing i with
  | zero=>
    have eq:=(realize (init z) c).1 ((i:Int)+1) (by omega)
    simpa [rowN,evol,init] using eq.symm
  | succ t ih=>
    rw [rowN,testBit_stepN,evol,ih i,ih (i+1)]
    congr 1
    cases i with
    | zero=>simpa using ((realize (init z) c).2 t).symm
    | succ i=>simp [ih]


def hasBand (z k : Nat) := ∀ i : Fin k, z.testBit (2*i.val)=false ∧ z.testBit (2*i.val+1)=true
instance (z k) : Decidable (hasBand z k) := by unfold hasBand;infer_instance

theorem initialBand {z k} (h : hasBand z k) (c : Nat→Bool) : WBAt (conf (init z) c) 0 0 k := by
  intro i lo hi
  have a:=h ⟨i-1,by omega⟩
  simp only at a
  have pos : (1:Int) ≤ 0+2*(i:Int)-1 := by omega
  have pos' : (1:Int) ≤ 0+2*(i:Int) := by omega
  rw [evol,evol,(realize (init z) c).1 _ pos,(realize (init z) c).1 _ pos']
  simp only [init,show (0+2*(i:Int)-1-1).toNat=2*(i-1) by omega,
    show (0+2*(i:Int)-1).toNat=2*(i-1)+1 by omega]
  exact a

def duration (k : Nat) := 4*k + (if 5≤k then 4 else 0)
def data (i : Fin 7) : Nat × Nat × Nat :=
  [(2,26,30),(26,442,74),(62,746,234),(310,103338,126122),(6673618,25780906,4734634),(139736600,410823338,424266410),(1119936524,7294511786,7251897002)].getD i.val (0,0,0)
private theorem numerics : ∀i : Fin 7,
    let d := data i
    let k := i.val+1
    d.1.testBit 0 = false ∧ hasBand d.2.1 k ∧ hasBand d.2.2 k ∧
    (rowN d.1.testBit d.2.1 (duration k)).testBit 0 ≠ (rowN d.1.testBit d.2.2 (duration k)).testBit 0 := by decide +kernel

def Reads (k T : Nat) := ∀ (x y : Int→Bool), DriveEq x y 0 0 0 → evol x 0 0=false → evol y 0 0=false →
  WBAt x 0 0 k → WBAt y 0 0 k → ∀t,t<T → evol x t 1=evol y t 1

theorem sharp (i : Fin 7) : Reads (i.val+1) (duration (i.val+1)) ∧
    ¬Reads (i.val+1) (duration (i.val+1)+1) := by
  let k:=i.val+1
  constructor
  · intro x y d wx wy bx b'y t ht
    by_cases split : 5≤k
    · have c : Chain (fun n=>9*n) k (k+1) := .extend (k:=1) (by omega) (.stop 1)
      simpa only [Nat.zero_add,Int.zero_add] using cascade_agreement nineBuilds c 0 0 0 0 d (fun p h h' => by omega) wx wy bx b'y t (by change t<duration k at ht; simp [duration,split] at ht; omega)
    · simpa only [Nat.zero_add,Int.zero_add] using cascade_agreement nineBuilds (.stop k) 0 0 0 0 d (fun p h h' => by omega) wx wy bx b'y t (by change t<duration k at ht; simp [duration,split] at ht; omega)
  · intro assumed
    obtain ⟨white,a,b,no⟩:=numerics i
    let d:=data i
    let c:=d.1.testBit
    have e:=assumed (conf (init d.2.1) c) (conf (init d.2.2) c)
      (fun n => by simp only [Nat.zero_add];exact ((realize _ c).2 n).trans ((realize _ c).2 n).symm)
      (((realize _ c).2 0).trans white) (((realize _ c).2 0).trans white)
      (initialBand a c) (initialBand b c) (duration k) (Nat.lt_succ_self _)
    exact no ((actual c _ (duration k) 0).trans (e.trans (actual c _ (duration k) 0).symm))
end Ruliology.CellularAutomata.ShieldCascade.Witnesses
