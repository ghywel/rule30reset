module
public import Ruliology.CellularAutomata.Rule30Realization
public import Ruliology.CellularAutomata.Rule30SourceObservables

/-! Exact data at the western bond of an imposed 101 clock. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30QuietGate
open Rule30Jen (rule)
open Rule30Realization (evol)
open Rule30SourceObservables (bit count)

def clock (t : Nat) : Bool := decide (t % 3 ≠ 1)
def gate (x : Int → Bool) (m : Nat) : Bool := evol x (3*m+1) 1

private theorem west_step (x : Int → Bool) (t : Nat) (i : Int) :
    evol x t (i-1) = xor (evol x (t+1) i) (evol x t i || evol x t (i+1)) := by
  rw [evol, rule]
  exact (Rule30Realization.xor_xor_cancel _ _).symm

theorem western_blocks (x : Int → Bool) (h : ∀ t, evol x t 0 = clock t) (m : Nat) :
    (evol x (3*m) (-1) = true ∧
     evol x (3*m+1) (-1) = !(gate x m) ∧ evol x (3*m+2) (-1) = false) ∧
    (evol x (3*m) (-2) = gate x m ∧
     evol x (3*m+1) (-2) = !(gate x m) ∧ evol x (3*m+2) (-2) = false) := by
  have c0 : evol x (3*m) 0 = true := by rw [h]; simp [clock]
  have c1 : evol x (3*m+1) 0 = false := by rw [h]; simp [clock]
  have c2 : evol x (3*m+2) 0 = true := by rw [h]; simp [clock]
  have c3 : evol x (3*m+2+1) 0 = true := by
    rw [show 3*m+2+1=3*(m+1) by omega,h]
    simp [clock]
  have b0 : evol x (3*m) (-1) = true := by
    rw [show (-1:Int)=0-1 by decide,west_step,c0,c1]
    rfl
  have b1 : evol x (3*m+1) (-1) = !(gate x m) := by
    rw [show (-1:Int)=0-1 by decide,west_step,c1,c2]
    change xor true (false || gate x m) = !(gate x m)
    cases gate x m <;> rfl
  have b2 : evol x (3*m+2) (-1) = false := by
    rw [show (-1:Int)=0-1 by decide,west_step,c2,c3]
    rfl
  have b3 : evol x (3*m+2+1) (-1) = true := by
    rw [show (-1:Int)=0-1 by decide,west_step,c3]
    have := h (3*m+2+1+1)
    rw [show 3*m+2+1+1=3*(m+1)+1 by omega] at *
    simp [clock] at this
    rw [this]
    rfl
  refine ⟨⟨b0,b1,b2⟩,?_,?_,?_⟩
  · rw [show (-2:Int)=(-1)-1 by decide,west_step,b0,b1]
    cases gate x m <;> rfl
  · rw [show (-2:Int)=(-1)-1 by decide,west_step,b1,b2,show (-1:Int)+1=0 by decide,c1]
    cases gate x m <;> rfl
  · rw [show (-2:Int)=(-1)-1 by decide,west_step,b2,b3,show (-1:Int)+1=0 by decide,c2]
    rfl

theorem no_run_ends (x : Int → Bool) (h : ∀ t, evol x t 0 = clock t) (t : Nat) :
    (evol x t (-2) && !(evol x t (-1))) = false := by
  let m := t/3
  obtain ⟨⟨b0,b1,b2⟩,a0,a1,a2⟩ := western_blocks x h m
  rcases (show t=3*m ∨ t=3*m+1 ∨ t=3*m+2 by dsimp [m]; omega) with s|s|s
  · rw [s,a0,b0]; cases gate x m <;> decide
  · rw [s,a1,b1]; cases gate x m <;> decide
  · rw [s,a2,b2]; decide

theorem count_on_aligned (x : Int → Bool) (h : ∀ t, evol x t 0 = clock t) (m : Nat) :
    count (fun t => evol x t (-2)) (3*m) = m := by
  induction m with
  | zero => rfl
  | succ m ih =>
    obtain ⟨_,a0,a1,a2⟩ := western_blocks x h m
    rw [show 3*(m+1)=3*m+2+1 by omega]
    simp only [count,a0,a1,a2,ih]
    cases gate x m <;> simp [bit] <;> omega

theorem aligned_discrepancy (x : Int → Bool) (h : ∀ t, evol x t 0 = clock t) (n : Nat) :
    let d := 3*count (fun t => evol x t (-2)) n - (n:Int);
    -2 ≤ d ∧ d ≤ 2 := by
  let m := n/3
  have align := count_on_aligned x h m
  obtain ⟨_,a0,a1,_⟩ := western_blocks x h m
  rcases (show n=3*m ∨ n=3*m+1 ∨ n=3*m+2 by dsimp [m]; omega) with e|e|e
  · rw [e,align]; omega
  · rw [e]; simp only [count,align,a0]
    cases gate x m <;> simp [bit] <;> omega
  · rw [e]; simp only [count,align,a0,a1]
    cases gate x m <;> simp [bit] <;> omega

def threeCharge (x : Int → Bool) (t : Nat) : Int :=
    3*(bit (evol x t (-2)) + bit (evol x (t+1) (-2)) + bit (evol x (t+2) (-2))) - 3

theorem three_charge (x : Int → Bool) (h : ∀ t, evol x t 0 = clock t) (m : Nat) :
    threeCharge x (3*m) = 0 ∧
    threeCharge x (3*m+1) = 3*(bit (gate x (m+1)) - bit (gate x m)) ∧
    threeCharge x (3*m+2) = 0 := by
  obtain ⟨_,a0,a1,a2⟩ := western_blocks x h m
  obtain ⟨_,n0,n1,_⟩ := western_blocks x h (m+1)
  have r1 : 3*m+1+1=3*m+2 := by omega
  have r2 : 3*m+1+2=3*(m+1) := by omega
  have r4 : 3*m+2+2=3*(m+1)+1 := by omega
  simp only [threeCharge,r1,r2,r4,a0,a1,a2,n0,n1]
  cases gate x m <;> cases gate x (m+1) <;> decide

def TailPeriod (f : Nat → Bool) (p : Nat) : Prop :=
  ∃ T, ∀ t, T ≤ t → f (t+p) = f t

private theorem block_period (f g : Nat → Bool) (fixedBlack : Bool)
    (blocks : ∀ m, f (3*m) = (fixedBlack || g m) ∧
      f (3*m+1) = !g m ∧ f (3*m+2) = false) (p : Nat) :
    TailPeriod f p ↔ ∃ q, p = 3*q ∧ TailPeriod g q := by
  constructor
  · rintro ⟨T,h⟩
    have zero (t : Nat) (r : t%3=2) : f t = false := by
      rw [show t=3*(t/3)+2 by omega]
      exact (blocks _).2.2
    have divides : p%3=0 := by
      apply Classical.byContradiction
      intro different
      have force (t : Nat) (ht : T≤t) (r : t%3=0 ∨ t%3=1) : f t=false := by
        have hit : (t+p)%3=2 ∨ (t+p+p)%3=2 := by
          have once := Nat.add_mod t p 3
          have twice := Nat.add_mod (t+p) p 3
          have v : p%3=1 ∨ p%3=2 := by omega
          rcases r with r|r <;> rcases v with v|v <;>
            rw [r,v] at once <;> rw [once,v] at twice <;> omega
        rcases hit with a|a
        · exact (h t ht).symm.trans (zero _ a)
        · exact ((h (t+p) (by omega)).trans (h t ht)).symm.trans (zero _ a)
      have e0 := force (3*T) (by omega) (by omega)
      have e1 := force (3*T+1) (by omega) (by omega)
      rw [(blocks T).1] at e0
      rw [(blocks T).2.1] at e1
      cases g T <;> simp_all
    refine ⟨p/3,by omega,T,?_⟩
    intro m hm
    have e := h (3*m+1) (by omega)
    rw [show 3*m+1+p=3*(m+p/3)+1 by omega,(blocks _).2.1,(blocks m).2.1] at e
    simpa using e
  · rintro ⟨q,rfl,T,h⟩
    refine ⟨3*T,?_⟩
    intro t ht
    let m := t/3
    have e := h m (by dsimp [m]; omega)
    rcases (show t=3*m ∨ t=3*m+1 ∨ t=3*m+2 by dsimp [m]; omega) with s|s|s
    · rw [s,show 3*m+3*q=3*(m+q) by omega,(blocks (m+q)).1,(blocks m).1,e]
    · rw [s,show 3*m+1+3*q=3*(m+q)+1 by omega,(blocks (m+q)).2.1,(blocks m).2.1,e]
    · rw [s,show 3*m+2+3*q=3*(m+q)+2 by omega,(blocks (m+q)).2.2,(blocks m).2.2]

/-- Each of the two western columns has exactly three times the eventual gate periods. -/
theorem western_periods (x : Int → Bool) (h : ∀ t, evol x t 0 = clock t) (p : Nat) :
    (TailPeriod (fun t => evol x t (-1)) p ↔ ∃ q, p=3*q ∧ TailPeriod (gate x) q) ∧
    (TailPeriod (fun t => evol x t (-2)) p ↔ ∃ q, p=3*q ∧ TailPeriod (gate x) q) := by
  exact ⟨block_period _ _ true (fun m => (western_blocks x h m).1) p,
    block_period _ _ false (fun m => (western_blocks x h m).2) p⟩

end Ruliology.CellularAutomata.Rule30QuietGate
