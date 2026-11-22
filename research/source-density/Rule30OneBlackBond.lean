module

public import Ruliology.CellularAutomata.Rule30Prize
public import Ruliology.CellularAutomata.Rule30Realization

/-! Counts at the two-sites-left bond of a period-three, one-black column.
The two endpoint potentials apply to every time window after onset. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30OneBlackBond
open Rule30Jen Rule30Realization

abbrev Field := Nat → Int → Bool
def Law (F : Field) := ∀ t i, F (t+1) i = rule (F t (i-1)) (F t i) (F t (i+1))
def drive (t : Nat) : Bool := decide (t%3=2)
def Driven (F : Field) := ∀ t, F t 0 = drive t
def X (F : Field) (m : Nat) := F (3*m) (-1)
def Y (F : Field) (m : Nat) := F (3*m+1) (-1)
def A (F : Field) (t : Nat) := F t (-2) && !F t (-1)
def z (b : Bool) : Int := if b then 1 else 0

private theorem left (F : Field) (hf : Law F) (t : Nat) (i : Int) :
    F t (i-1) = xor (F (t+1) i) (F t i || F t (i+1)) := by
  rw [hf]; exact rule_left _ _ _

theorem blocks (F : Field) (hf : Law F) (hd : Driven F) (m : Nat) :
    let x := X F m; let y := Y F m; let x' := X F (m+1)
    (x && y) = false ∧ F (3*m+2) (-1) = true ∧
    F (3*m) (-2) = xor x y ∧ F (3*m+1) (-2) = !y ∧ F (3*m+2) (-2) = !x' ∧
    A F (3*m) = y ∧ A F (3*m+1) = !y ∧ A F (3*m+2) = false := by
  have l1 (t : Nat) : F t (-1) = xor (F (t+1) 0) (F t 0 || F t 1) := left F hf t 0
  have l2 (t : Nat) : F t (-2) = xor (F (t+1) (-1)) (F t (-1) || F t 0) := by
    simpa only [show (-1:Int)-1 = -2 by decide,show (-1:Int)+1 = 0 by decide] using left F hf t (-1)
  have e0 (n : Nat) : F (3*n) 0 = false := by rw [hd]; simp [drive]
  have e1 (n : Nat) : F (3*n+1) 0 = false := by rw [hd]; simp [drive,Nat.add_mod]
  have e2 (n : Nat) : F (3*n+2) 0 = true := by rw [hd]; simp [drive,Nat.add_mod]
  have d2 : F (3*m+2) (-1) = true := by
    rw [l1,show 3*m+2+1=3*(m+1) by omega,e0,e2]; simp
  have c0 : F (3*m) (-2) = xor (X F m) (Y F m) := by
    rw [l2,e0]; simp [X,Y,Bool.xor_comm]
  have c1 : F (3*m+1) (-2) = !(Y F m) := by
    rw [l2,show 3*m+1+1=3*m+2 by omega,d2,e1]; simp [Y]
  have c2 : F (3*m+2) (-2) = !(X F (m+1)) := by
    rw [l2,show 3*m+2+1=3*(m+1) by omega,d2]; simp [X]
  have hx : X F m = F (3*m) 1 := by rw [X,l1,e1,e0]; simp
  have hy : Y F m = !(F (3*m) 1 || F (3*m) 2) := by
    rw [Y,l1,show 3*m+1+1=3*m+2 by omega,e2,e1,hf (3*m) 1]; simp [rule,e0]
  have hxy : (X F m && Y F m) = false := by
    rw [hx,hy]; cases F (3*m) 1 <;> cases F (3*m) 2 <;> decide
  refine ⟨hxy,d2,c0,c1,c2,?_,?_,?_⟩
  · change (F (3*m) (-2) && !(X F m)) = Y F m
    rw [c0]
    have H : ∀ a b : Bool, (a && b)=false → (xor a b && !a)=b := by decide
    exact H _ _ hxy
  · change (F (3*m+1) (-2) && !(Y F m)) = !(Y F m)
    rw [c1]; simp
  · simp [A,d2]

def HC (F : Field) (t : Nat) : Int :=
  if t%3=0 then -3*z (X F (t/3)) else if t%3=1 then 3*z (Y F (t/3))-2 else -1

def HA (F : Field) (t : Nat) : Int :=
  if t%3=0 then 0 else if t%3=1 then 3*z (Y F (t/3))-1 else 1

theorem step (F : Field) (hf : Law F) (hd : Driven F) (t : Nat) :
    3*z (F t (-2))-2 = HC F (t+1)-HC F t ∧
    3*z (A F t)-1 = HA F (t+1)-HA F t := by
  let m := t/3
  obtain ⟨hxy,_,c0,c1,c2,a0,a1,a2⟩ := blocks F hf hd m
  have hcases : t=3*m ∨ t=3*m+1 ∨ t=3*m+2 := by dsimp [m]; omega
  rcases hcases with h|h|h
  · rw [h,c0,a0]
    simp only [HC,HA,show (3*m)%3=0 by omega,show (3*m+1)%3=1 by omega,
      show (3*m)/3=m by omega,show (3*m+1)/3=m by omega]
    cases hx : X F m <;> cases hy : Y F m <;> simp_all [z]
  · rw [h,c1,a1]
    simp only [HC,HA,show (3*m+1)%3=1 by omega,show (3*m+1+1)%3=2 by omega,
      show (3*m+1)/3=m by omega]
    cases Y F m <;> simp [z]
  · rw [h,c2,a2]
    simp only [HC,HA,show (3*m+2)%3=2 by omega,show (3*m+2+1)%3=0 by omega,
      show (3*m+2+1)/3=m+1 by omega]
    cases X F (m+1) <;> simp [z]

def count (f : Nat → Bool) (a : Nat) : Nat → Int
  | 0 => 0
  | n+1 => count f a n + z (f (a+n))

/-- Exact endpoint identities on arbitrary half-open windows. -/
theorem endpoint (F : Field) (hf : Law F) (hd : Driven F) (a : Nat) :
    ∀ n, 3*count (fun t => F t (-2)) a n-2*(n:Int) = HC F (a+n)-HC F a ∧
         3*count (A F) a n-(n:Int) = HA F (a+n)-HA F a := by
  intro n; induction n with
  | zero => simp [count]
  | succ n ih =>
    have hs := step F hf hd (a+n)
    simp only [count,show a+(n+1)=a+n+1 by omega,Int.natCast_succ]
    omega

theorem range (F : Field) (t : Nat) : -3 ≤ HC F t ∧ HC F t ≤ 1 ∧ -1 ≤ HA F t ∧ HA F t ≤ 2 := by
  unfold HC HA
  cases X F (t/3) <;> cases Y F (t/3) <;> by_cases h : t%3=0 <;> by_cases h' : t%3=1 <;> simp [h,h',z]

/-- On any window the scaled black-count discrepancy is at most four and
the scaled source-count discrepancy is at most three. -/
theorem discrepancy (F : Field) (hf : Law F) (hd : Driven F) (a n : Nat) :
    let C := count (fun t => F t (-2)) a n
    let B := count (A F) a n
    (-4 ≤ 3*C-2*(n:Int)) ∧ 3*C-2*(n:Int) ≤ 4 ∧ -3 ≤ 3*B-(n:Int) ∧ 3*B-(n:Int) ≤ 3 := by
  dsimp only
  have he := endpoint F hf hd a n
  have h1 := range F a
  have h2 := range F (a+n)
  omega

/-- In a union of aligned triples, every triple contributes exactly one 10;
the black count equals 2n plus the difference of the endpoint flank bits. -/
theorem aligned (F : Field) (hf : Law F) (hd : Driven F) (m n : Nat) :
    count (fun t => F t (-2)) (3*m) (3*n) = 2*(n:Int)+z (X F m)-z (X F (m+n)) ∧
    count (A F) (3*m) (3*n) = (n:Int) := by
  have he := endpoint F hf hd (3*m) (3*n)
  simp only [HC,HA,show (3*m)%3=0 by omega,show (3*m+3*n)%3=0 by omega,
    show (3*m)/3=m by omega,show (3*m+3*n)/3=m+n by omega,ite_true,Int.natCast_mul] at he
  omega

/-- The physical result from any ordinary full-line initial row, at any site and onset. -/
theorem physical (r : Int → Bool) (i : Int) (S : Nat)
    (h : ∀ t, evol r (S+t) i = drive t) (a n : Nat) :
    let C := count (fun t => evol r (S+t) (i-2)) a n
    let B := count (fun t => evol r (S+t) (i-2) && !(evol r (S+t) (i-1))) a n
    (-4 ≤ 3*C-2*(n:Int)) ∧ 3*C-2*(n:Int) ≤ 4 ∧ -3 ≤ 3*B-(n:Int) ∧ 3*B-(n:Int) ≤ 3 := by
  let F : Field := fun t j => evol r (S+t) (i+j)
  have hf : Law F := by
    intro t j; dsimp [F,evol]; congr 1 <;> congr 1 <;> omega
  have hd : Driven F := by intro t; simpa [F] using h t
  have ha : A F = (fun t => evol r (S+t) (i-2) && !(evol r (S+t) (i-1))) := by
    funext t; simp [A,F,show i+(-2)=i-2 by omega,show i+(-1)=i-1 by omega]
  simpa [ha,F,show i+(-2)=i-2 by omega] using discrepancy F hf hd a n

def exampleRow : Int → Bool := conf (fun _ => false) drive

/-- The same ordinary orbit realizes both signs of each uniform discrepancy bound. -/
theorem sharp :
    (∀ t, evol exampleRow t 0 = drive t) ∧
    (∀ i, (1:Int) ≤ i → exampleRow i = false) ∧
    3*count (fun t => evol exampleRow t (-2)) 3 4 - 8 = 4 ∧
    3*count (fun t => evol exampleRow t (-2)) 1 2 - 4 = -4 ∧
    3*count (A (evol exampleRow)) 4 3 - 3 = 3 ∧
    3*count (A (evol exampleRow)) 1 3 - 3 = -3 := by
  have hd := (realize (fun _ => false) drive).2
  have hf : Law (evol exampleRow) := fun _ _ => rfl
  refine ⟨hd,(realize (fun _ => false) drive).1,?_,?_,?_,?_⟩
  · exact (endpoint (evol exampleRow) hf hd 3 4).1.trans (by decide +kernel)
  · exact (endpoint (evol exampleRow) hf hd 1 2).1.trans (by decide +kernel)
  · exact (endpoint (evol exampleRow) hf hd 4 3).2.trans (by decide +kernel)
  · exact (endpoint (evol exampleRow) hf hd 1 3).2.trans (by decide +kernel)

end Ruliology.CellularAutomata.Rule30OneBlackBond
