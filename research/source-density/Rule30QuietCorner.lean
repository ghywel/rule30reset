module
public import Rule30SourceDensityRegion

/-! An exposed count at one bond measures departure from the two-black
period-three clock two sites to its right. All intervals are physical ticks. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30QuietCorner
open Rule30Jen (cell rule)
open Rule30SourceObservables (source bit count)
open Rule30SourceDensityRegion

def deficit (u : History) (j : Int) (s n : Nat) : Int :=
  (n:Int)+6*ends u j s n-3*black u j s n

def outside (a b c : Bool) := decide (bit a+bit b+bit c≠2)
def defects (u : History) (j : Int) (s n : Nat) :=
  count (fun t=>outside (u (s+t) j) (u (s+t+1) j) (u (s+t+2) j)) n

private def pot (lo : Bool) (a b c d e : Bool) : Int :=
  ((if lo then #[0, 0, 4, 7, 3, 0, 5, 5, 1, 0, 5, 6, 3, 0, 5, 5, 0, 0, 4, 7, 3, 0, 5, 5, 1, 0, 5, 6, 3, 0, 5, 5] else #[0, 0, 0, 0, 2, 2, 0, 1, 3, 1, 0, 0, 2, 2, 1, 0, 0, 0, 0, 0, 2, 2, 1, 0, 3, 1, 0, 0, 2, 2, 1, 0] : Array Nat).getD
    (a.toNat+2*b.toNat+4*c.toNat+8*d.toNat+16*e.toNat) 0 : Nat)
private theorem rangeP : ∀ m a b c d e, 0≤pot m a b c d e ∧ pot m a b c d e ≤ (if m then 7 else 3) := by decide +kernel
private theorem edge : ∀ m l a b c d e r : Bool,
    let x:=rule a b c
    let y:=rule b c d
    let z:=rule c d e
    let E:=bit (outside c y (rule x y z))
    let D:=1+6*bit (source a b)-3*bit a
    (if m then E-2*D else D-4*E) ≤ pot m a b c d e-pot m (rule l a b) x y z (rule d e r) := by decide +kernel

private def P (m : Bool) (u : History) (j : Int) (t : Nat) :=
  pot m (u t j) (u t (j+1)) (u t (j+2)) (u t (j+3)) (u t (j+4))

private theorem step {u : History} (hu : Evolution u) (m : Bool) (j : Int) (t : Nat) :
    let E:=bit (outside (u t (j+2)) (u (t+1) (j+2)) (u (t+2) (j+2)))
    let D:=1+6*bit (source (u t j) (u t (j+1)))-3*bit (u t j)
    (if m then E-2*D else D-4*E) ≤ P m u j t-P m u j (t+1) := by
  have up (t : Nat) (i : Int) : u (t+1) (j+i)=rule (u t (j+(i-1))) (u t (j+i)) (u t (j+(i+1))) := by
    simpa only [Int.add_sub_assoc,Int.add_assoc] using hu t (j+i)
  let a:=u t j
  have e2 : u (t+2) (j+2)=rule (u (t+1) (j+1)) (u (t+1) (j+2)) (u (t+1) (j+3)) := by
    simpa only [show (2:Int)-1=1 by decide,show (2:Int)+1=3 by decide] using up (t+1) 2
  dsimp only [P]
  rw [e2,hu t j,up t 1,up t 2,up t 3,up t 4]
  simpa only [show (1:Int)+1=2 by decide,show (1:Int)-1=0 by decide,show (2:Int)+1=3 by decide,show (2:Int)-1=1 by decide,show (3:Int)+1=4 by decide,show (3:Int)-1=2 by decide,show (4:Int)+1=5 by decide,show (4:Int)-1=3 by decide,Int.add_zero] using edge m (u t (j-1)) (u t j) (u t (j+1)) (u t (j+2))
    (u t (j+3)) (u t (j+4)) (u t (j+5))

private theorem tel {u} (hu : Evolution u) (m : Bool) (j : Int) (s n : Nat) :
    (if m then defects u (j+2) s n-2*deficit u j s n else deficit u j s n-4*defects u (j+2) s n)
       ≤ P m u j s-P m u j (s+n) := by
  induction n with
  | zero => cases m <;> simp [defects,deficit,black,ends,count]
  | succ n ih =>
    have inc:=step hu m j (s+n)
    cases m <;> simp only [defects,deficit,black,ends,count,Int.natCast_succ,
      Bool.false_eq_true,ite_false,ite_true,show s+(n+1)=s+n+1 by omega] at inc ih ⊢ <;> omega

/-- The upper and lower bounds hold on every finite interval, at every site,
for every ordinary evolution. -/
theorem defect_comparison {u} (hu : Evolution u) (j : Int) (s n : Nat) :
    defects u (j+2) s n ≤ 2*deficit u j s n + 7 ∧
    deficit u j s n ≤ 4*defects u (j+2) s n + 3 := by
  have a:=tel hu true j s n;have b:=tel hu false j s n
  have p (m : Bool) (t : Nat) : 0≤P m u j t ∧ P m u j t ≤ (if m then 7 else 3) :=
    rangeP _ _ _ _ _ _
  have l:=p true s;have e:=p true (s+n);have l':=p false s;have e':=p false (s+n)
  simp at a b l e l' e';omega

theorem singleton_comparison (j : Int) (s n : Nat) :
    defects cell (j+2) s n ≤ 2*deficit cell j s n+7 ∧ deficit cell j s n≤4*defects cell (j+2) s n+3 :=
  defect_comparison (fun _ _=>rfl) j s n
end Ruliology.CellularAutomata.Rule30QuietCorner
