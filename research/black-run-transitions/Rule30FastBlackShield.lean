import Lean

import Ruliology.CellularAutomata.Rule30FiniteStrips

import Ruliology.CellularAutomata.Rule30FiniteBlackRuns



/-! # A faster right-hand shield and two periodic-column exclusions

The local dynamics follow WolframInstitute/Rule30PrizeKit at 40017e8. The moving wall,

four-step agreement and end-of-run arguments extend the proofs contributed by Bosdure.

The 44-step finite certificate, all-width composition and finite-left quarter-period

specializations are the new inputs. The certificate elaborator supplies natural numbers;

the kernel checks every preimage identity by definitional equality. -/



namespace Ruliology.CellularAutomata.ShieldTables
abbrev Bits := Nat → Bool
def code : Nat → Bits → Nat
  | 0,_ => 0
  | n+1,x => code n x + (if x n then 2^n else 0)
theorem lt_code (n) (x : Bits) : code n x < 2^n := by
  induction n with
  | zero => exact (by decide : 0<1)
  | succ n ih => simp only [code,Nat.pow_succ];split <;> omega
def limit (n : Nat) := 2^(2^n)
def fullMask (n : Nat) := limit n - 1
def combine (n A B : Nat) := A ||| (B <<< (2^n))
theorem combine_spec (n A B i : Nat) (small : i<2^n) (ha : A<limit n) (c : Bool) :
    (combine n A B).testBit (i+(if c then 2^n else 0)) = (if c then B else A).testBit i := by
  unfold combine
  cases c with
  | false => simp [Nat.testBit_or,Nat.testBit_shiftLeft,show ¬2^n≤i by omega]
  | true =>
    have upper : A < 2^(i+2^n) := Nat.lt_of_lt_of_le ha (Nat.pow_le_pow_right (by decide : 0<2) (show 2^n≤i+2^n by omega))
    simp [Nat.testBit_or,Nat.testBit_shiftLeft,Nat.testBit_lt_two_pow upper]
def plane : Nat → Nat → Nat
  | 0,_ => 0
  | n+1,k =>
    let p:=plane n k
    (if k=n then combine n 0 (fullMask n) else combine n p p) % limit (n+1)
theorem plane_bound (n k) : plane n k < limit n := by
  cases n with
  | zero => exact (by decide : 0<2)
  | succ n => exact Nat.mod_lt _ (Nat.two_pow_pos _)
theorem fullMask_bit (n) (x : Bits) : (fullMask n).testBit (code n x) = true := by
  simp only [fullMask,limit,Nat.testBit_two_pow_sub_one,decide_eq_true (lt_code n x)]
theorem plane_bit (n k) (hk:k<n) (x : Bits) : (plane n k).testBit (code n x) = x k := by
  induction n with
  | zero => omega
  | succ n ih =>
    unfold plane
    rw [show limit (n+1)=2^(2^(n+1)) from rfl,Nat.testBit_mod_two_pow,decide_eq_true (lt_code (n+1) x),Bool.true_and]
    by_cases eq:k=n
    · subst k;rw [if_pos rfl,code,combine_spec n 0 _ _ (lt_code n x) (Nat.two_pow_pos _) (x n)]
      cases h:x n <;> simp [fullMask_bit]
    · rw [if_neg eq,code,combine_spec n _ _ _ (lt_code n x) (plane_bound n k) (x n)]
      simpa using ih (by omega)

def put (x : Bits) (k : Nat) (b : Bool) : Bits := fun j=>if j=k then b else x j
theorem code_congr {n x y} (eq : ∀j,j<n → x j=y j) : code n x=code n y := by
  induction n with
  | zero => rfl
  | succ n ih => rw [code,code,ih (fun j h=>eq j (by omega)),eq n (by omega)]
theorem code_put (n k : Nat) (hk:k<n) (x : Bits) (b : Bool) :
    code n (put x k b)+(if x k then 2^k else 0) = code n x+(if b then 2^k else 0) := by
  induction n with
  | zero => omega
  | succ n ih =>
    by_cases eq:k=n
    · subst k
      have same : code n (put x n b)=code n x := code_congr (fun j h=>by simp [put,show j≠n by omega])
      simp only [code,same,put,ite_true];omega
    · have z:=ih (by omega)
      simp only [code,put,show ¬n=k by omega,ite_false] at *;omega

inductive Expr where
  | bit (i : Nat)
  | lit (b : Bool)
  | xor (a b : Expr)
  | bor (a b : Expr)
  deriving DecidableEq
def Expr.val (x : Bits) : Expr → Bool
  | .bit i => x i
  | .lit b => b
  | .xor a b => Bool.xor (a.val x) (b.val x)
  | .bor a b => a.val x || b.val x
def Expr.bound (n : Nat) : Expr → Prop
  | .bit i => i<n
  | .lit _ => True
  | .bor a b | .xor a b => a.bound n ∧ b.bound n
def Expr.mask (n : Nat) : Expr → Nat
  | .bit i => plane n i
  | .lit b => if b then fullMask n else 0
  | .xor a b => a.mask n ^^^ b.mask n
  | .bor a b => a.mask n ||| b.mask n
theorem Expr.mask_bit {n : Nat} {e : Expr} (ok : e.bound n) (x : Bits) :
    (e.mask n).testBit (code n x)=e.val x := by
  induction e with
  | bit i => exact plane_bit n i ok x
  | lit b => cases b <;> simp [Expr.mask,Expr.val,fullMask_bit]
  | xor a b ia ib => simp [Expr.mask,Expr.val,Nat.testBit_xor,ia ok.1,ib ok.2]
  | bor a b ia ib => simp [Expr.mask,Expr.val,Nat.testBit_or,ia ok.1,ib ok.2]

abbrev Gate := Nat × Expr
def move (g : Gate) (x : Bits) := put x g.1 (g.2.val x)
def legal (n : Nat) (g : Gate) := g.1<n ∧ g.2.bound n
def pull (n : Nat) (g : Gate) (S : Nat) :=
  let d := 2^g.1
  let p := plane n g.1
  let z := g.2.mask n
  let allBits := fullMask n
  (S &&& (allBits ^^^ (p ^^^ z))) ||| ((S >>> d) &&& ((allBits ^^^ p) &&& z)) |||
    ((S <<< d) &&& (p &&& (allBits ^^^ z)))
theorem pull_bit {n g} (ok : legal n g) (S : Nat) (x : Bits) :
    (pull n g S).testBit (code n x) = S.testBit (code n (move g x)) := by
  have z:=code_put n g.1 ok.1 x (g.2.val x)
  change _ = S.testBit (code n (put x g.1 (g.2.val x)))
  simp only [pull,Nat.testBit_or,Nat.testBit_and,Nat.testBit_xor,Nat.testBit_shiftRight,Nat.testBit_shiftLeft,plane_bit _ _ ok.1,Expr.mask_bit ok.2,fullMask_bit]
  cases h:x g.1 <;> cases e:g.2.val x <;> simp only [h,e,Bool.false_eq_true,Bool.not_false,Bool.xor_false,Bool.xor_true,Bool.false_xor,Bool.true_xor,Bool.false_and,Bool.and_false,Bool.true_and,Bool.and_true,Bool.false_or,Bool.or_false,Bool.true_or,Bool.or_true,ite_false,ite_true,Nat.add_zero] at z ⊢ <;> try (congr 1 <;> omega)
  all_goals simp at z ⊢
  all_goals try (congr 1 <;> omega)
  have up : 2^g.1 ≤ code n x := by omega
  simp [up];congr 1 <;> omega
end Ruliology.CellularAutomata.ShieldTables

namespace Ruliology.CellularAutomata.ShieldTables
def both (n a : Nat) := combine n a a
def runGates : List Gate → Bits → Bits
  | [],x => x
  | g::gs,x => runGates gs (move g x)
def readBack (n : Nat) : List Gate → Nat → Nat
  | [],s => s
  | g::gs,s => pull n g (readBack n gs s)
theorem readBack_bit {n} (p : List Gate) (h : ∀g,g∈p → legal n g) (s) (x) :
    (readBack n p s).testBit (code n x) = s.testBit (code n (runGates p x)) := by
  induction p generalizing x with
  | nil => rfl
  | cons g gs ih =>
    rw [readBack,pull_bit (h g (by simp)),ih (fun z hz=>h z (by simp [hz]))];rfl

def Expr.ok (n : Nat) : Expr → Bool
  | .bit i => decide (i<n)
  | .lit _ => true
  | .xor a b | .bor a b => a.ok n && b.ok n
theorem Expr.ok_sound {n : Nat} (e : Expr) (h : e.ok n=true) : e.bound n := by
  induction e with
  | bit i => exact (of_decide_eq_true h : i<n)
  | lit b => trivial
  | xor a b ia ib | bor a b ia ib =>
    simp only [Expr.ok,Bool.and_eq_true] at h;exact ⟨ia h.1,ib h.2⟩

def Expr.sub (env : Nat → Expr) : Expr → Expr
  | .bit k => env k
  | .lit b => .lit b
  | .xor a b => .xor (a.sub env) (b.sub env)
  | .bor a b => .bor (a.sub env) (b.sub env)
theorem Expr.sub_val (e : Expr) (env : Nat→Expr) (x) :
    (e.sub env).val x=e.val (fun i=>(env i).val x) := by
  induction e <;> simp [Expr.sub, Expr.val, *]

def symbols : List Gate → (Nat→Expr) → (Nat→Expr)
  | [],env => env
  | g::gs,env => symbols gs (fun i=>if i=g.1 then g.2.sub env else env i)
theorem symbols_val (p : List Gate) (env : Nat→Expr) (x) (i) :
    ((symbols p env) i).val x = (runGates p (fun k=>(env k).val x)) i := by
  induction p generalizing env with
  | nil => rfl
  | cons g gs ih =>
    rw [symbols,ih,runGates]
    congr 2;funext j;by_cases h:j=g.1 <;> simp [h,move,put,Expr.sub_val]

def updateExpr (i : Nat) (b : Bool) : Expr :=
  .xor (.bit i) (.bor (.bit (i+1)) (if i+2<19 then .bit (i+2) else .lit b))
def gates (b : Bool) : List Gate :=
  (List.range 18).map (fun i => (i,updateExpr i b)) ++
  (List.range 18).reverse.map (fun i=>(i+1,Expr.bit i)) ++ [(0,Expr.lit true)]
private theorem bounds : ∀ b : Bool,(gates b).all (fun g => decide (g.1<19) && g.2.ok 19)=true := by decide +kernel
theorem legal_gates (b : Bool) (g) (mem:g∈gates b) : legal 19 g := by
  have z:=List.all_eq_true.mp (bounds b) g mem
  simp only [Bool.and_eq_true,decide_eq_true_eq] at z
  exact ⟨z.1,Expr.ok_sound _ z.2⟩
def wire (i : Nat) (b : Bool) : Expr :=
  if i=0 then .lit true else updateExpr (i-1) b
private theorem wiring : ∀b:Bool,∀i:Fin 19,symbols (gates b) Expr.bit i.val=wire i.val b := by decide +kernel
theorem next_bit (b) (x : Bits) (i : Nat) (hi:i<19) :
    runGates (gates b) x i = (wire i b).val x := by
  have z:=symbols_val (gates b) Expr.bit x i
  rw [wiring b ⟨i,hi⟩] at z
  exact z.symm

def back (s : Nat) := readBack 19 (gates false) s &&& readBack 19 (gates true) s
theorem back_sound {a s : Nat} (cert : a &&& back s = a) (x : Bits) (b : Bool) (mem : a.testBit (code 19 x)=true) :
    s.testBit (code 19 (runGates (gates b) x))=true := by
  have z:=congrArg (fun r:Nat=>r.testBit (code 19 x)) cert
  simp only [Nat.testBit_and,back,mem,Bool.true_and,Bool.and_eq_true,
    readBack_bit _ (legal_gates false),readBack_bit _ (legal_gates true)] at z
  cases b with
  | false => exact z.1
  | true => exact z.2
end Ruliology.CellularAutomata.ShieldTables

namespace Ruliology.CellularAutomata.ShieldTables
def terminal :=
  (List.range 10).foldl (fun s i=>s &&& (if i%2=1 then plane 19 (i+1) else fullMask 19 ^^^ plane 19 (i+1))) (fullMask 19)
def remaining : Nat → Nat
  | 0 => terminal
  | t+1 => back (remaining t)
theorem zero_time : remaining 0 = terminal := rfl
end Ruliology.CellularAutomata.ShieldTables

namespace Ruliology.CellularAutomata.ShieldTables
theorem checkpoint {n r s : Nat} (prev : remaining n=r) (test : back r=s) : remaining (n+1)=s :=
  (congrArg back prev).trans test
open Lean Elab Command in
run_cmd do
  liftCoreM do
  let root := `Ruliology.CellularAutomata.ShieldTables
  let nameAt (prefixName : String) (i : Nat) := Name.str root (prefixName ++ toString i)
  let natTy := mkConst ``Nat
  let equality (lhs rhs : Lean.Expr) := mkApp3 (mkConst ``Eq [1]) natTy lhs rhs
  let reflexivity (val : Lean.Expr) := mkApp2 (mkConst ``Eq.refl [1]) natTy val
  let emit (n : Name) (type val : Lean.Expr) : CoreM Unit := do
    addDecl (.thmDecl {name:=n, levelParams:=[], type:=type, value:=val})
  let mut current := terminal
  let mut prev := mkConst ``terminal
  let mut previousProof := reflexivity prev
  for i in [:44] do
    current := back current
    let sn := nameAt "saved" (i+1)
    let vn := nameAt "verified" (i+1)
    let tn := nameAt "table" (i+1)
    addDecl (.defnDecl {name:=sn, levelParams:=[], type:=natTy, value:=mkNatLit current, hints:=.regular 1, safety:=.safe})
    let saved := mkConst sn
    let assertion := equality (mkApp (mkConst ``back) prev) saved
    emit vn assertion (reflexivity saved)
    let result := equality (mkApp (mkConst ``remaining) (mkNatLit (i+1))) saved
    let proof := mkAppN (mkConst ``checkpoint) #[mkNatLit i,prev,saved,previousProof,mkConst vn]
    emit tn result proof
    previousProof := mkConst tn
    prev := saved

theorem initial44 : plane 19 0 &&& remaining 44 = plane 19 0 := by
  rw [table44];decide +kernel
theorem lowTen : ∀i : Fin 10,terminal &&& plane 19 (i.val+1) =
    if i.val%2=1 then terminal else 0 := by decide +kernel
end Ruliology.CellularAutomata.ShieldTables

namespace Ruliology.CellularAutomata.ShieldTables
open Rule30Jen Rule30Realization
def reg (x : Int→Bool) (j : Int) (s t i : Nat) := if i=0 then true else evol x (s+t) (j+(i:Int))
theorem circuit_step (x : Int→Bool) (j : Int) (s t : Nat) (black : evol x (s+t) j=true) :
    code 19 (runGates (gates (evol x (s+t) (j+19))) (reg x j s t))=
      code 19 (reg x j s (t+1)) := by
  apply code_congr
  intro i hi
  rw [next_bit _ _ _ hi]
  by_cases zero:i=0
  · subst i;rfl
  · have left : reg x j s t (i-1) = evol x (s+t) (j+(i:Int)-1) := by
      by_cases one:i=1
      · subst i;simpa [reg] using black.symm
      · simp only [reg,show ¬i-1=0 by omega,ite_false];congr 1;omega
    have hc : reg x j s t i = evol x (s+t) (j+(i:Int)) := by simp [reg,zero]
    have e : i-1+1=i := by omega
    have ee : i-1+2=i+1 := by omega
    rw [wire,if_neg zero,updateExpr,Expr.val,Expr.val,Expr.val,Expr.val,left,e,hc,ee]
    change (_ ^^ (_ || _)) = (if i=0 then true else evol x (s+(t+1)) (j+i))
    rw [if_neg zero,show s+(t+1)=(s+t)+1 by omega]
    change (_ ^^ (_ || _)) = rule (evol x (s+t) (j+(i:Int)-1)) (evol x (s+t) (j+i)) (evol x (s+t) (j+i+1))
    by_cases inside:i+1<19
    · simp [inside,Expr.val,reg,rule,Int.add_assoc]
    · have last:i=18 := by omega
      subst i;simp [Expr.val,rule,show j+(18:Int)+1=j+19 by omega]

theorem physical_move {a b : Nat} (h : a &&& back b=a) (x : Int→Bool) (j : Int) (s t : Nat)
    (black : evol x (s+t) j=true) (mem : a.testBit (code 19 (reg x j s t))=true) :
    b.testBit (code 19 (reg x j s (t+1)))=true := by
  have z:=back_sound h (reg x j s t) (evol x (s+t) (j+19)) mem
  rwa [circuit_step x j s t black] at z
end Ruliology.CellularAutomata.ShieldTables

namespace Ruliology.CellularAutomata.BlackShieldSpeed
open Rule30Jen Rule30Realization

def Shield (time pairs : Nat) := ∀(x : Int→Bool) (m : Int) (s : Nat),
    (∀t,t<time → evol x (s+t) m=true) → ∀i : Nat,1≤i → i≤pairs →
    evol x (s+time) (m+2*(i:Int)-1)=false ∧ evol x (s+time) (m+2*(i:Int))=true

theorem add_shield {A B k l} (a : Shield A k) (b : Shield B l) : Shield (A+B) (k+l) := by
  intro x m s h i lower upper
  by_cases small : i≤k
  · have z:=a x m (s+B) (fun t ht => by rw [show s+B+t=s+(B+t) by omega];exact h _ (by omega)) i lower small
    simpa only [show s+B+A=s+(A+B) by omega] using z
  · have inside (t) (ht:t<B) : evol x (s+A+t) (m+2*(k:Int))=true := by
      by_cases zero:k=0
      · subst k;simp only [Int.natCast_zero,Int.mul_zero,Int.add_zero,Nat.add_assoc];exact h _ (by omega)
      · have z:=a x m (s+t) (fun j hj => by rw [show s+t+j=s+(t+j) by omega];exact h _ (by omega)) k (by omega) (by omega)
        simpa only [show s+t+A=s+A+t by omega] using z.2
    have z:=b x (m+2*(k:Int)) (s+A) inside (i-k) (by omega) (by omega)
    have shift:m+2*(k:Int)+2*((i-k:Nat):Int)=m+2*(i:Int) := by omega
    simpa only [shift,Nat.add_assoc] using z

theorem repeat_shield {T k} (h : Shield T k) (n : Nat) : Shield (T*n) (k*n) := by
  induction n with
  | zero => intro _ _ _ _ _ hi le;omega
  | succ n ih => simpa only [Nat.mul_succ] using add_shield ih h

theorem nine (r : Nat) : Shield (9*r) r := fun x m s h i hi le => Rule30FiniteBlackRuns.black_shield x m r s h i hi le
end Ruliology.CellularAutomata.BlackShieldSpeed

namespace Ruliology.CellularAutomata.BlackShieldSpeed
open Rule30Jen Rule30Realization ShieldTables

theorem end44 (x : Int→Bool) (j : Int) (s : Nat)
    (drive : ∀t, t<44 → evol x (s+t) j=true) : terminal.testBit (code 19 (reg x j s 44))=true := by
  have inv (t : Nat) (ht:t≤44) : (remaining (44-t)).testBit (code 19 (reg x j s t))=true := by
    induction t with
    | zero =>
      have z:=congrArg (fun m:Nat=>m.testBit (code 19 (reg x j s 0))) initial44
      simpa only [Nat.testBit_and,plane_bit 19 0 (by decide),reg,ite_true,Bool.true_and] using z
    | succ t ih =>
      have prev:=ih (by omega)
      have le:t<44 := by omega
      rw [show 44-t=(44-(t+1))+1 by omega,remaining] at prev
      exact physical_move (Nat.and_self _) x j s t (drive t le) prev
  exact inv 44 (by decide)

theorem ten_cells_44 : Shield 44 5 := by
  intro x j s drive i lo hi
  have mem:=end44 x j s drive
  have pixels (n : Nat) (h:n<10) : reg x j s 44 (n+1) = decide (n%2=1) := by
    have eq:=congrArg (fun m:Nat=>m.testBit (code 19 (reg x j s 44))) (lowTen ⟨n,h⟩)
    by_cases odd:n%2=1
    · simpa only [odd,ite_true,Nat.testBit_and,mem,Bool.true_and,plane_bit 19 (n+1) (by omega),decide_true] using eq
    · simpa only [odd,ite_false,Nat.testBit_and,mem,Bool.true_and,plane_bit 19 (n+1) (by omega),decide_false,Nat.zero_testBit] using eq
  have a:=pixels (2*i-2) (by omega)
  have b:=pixels (2*i-1) (by omega)
  simp only [reg,Nat.add_one_ne_zero,ite_false,show ¬(2*i-2)%2=1 by omega,decide_false,
    show j+((2*i-2+1:Nat):Int)=j+2*(i:Int)-1 by omega] at a
  simp only [reg,Nat.add_one_ne_zero,ite_false,show (2*i-1)%2=1 by omega,decide_true,
    show j+((2*i-1+1:Nat):Int)=j+2*(i:Int) by omega] at b
  exact ⟨a,b⟩

/-- The previous 9j clock loses a tick for every five pairs. -/
theorem faster_shield (j : Nat) : Shield (9*j-j/5) j := by
  have h:=add_shield (repeat_shield ten_cells_44 (j/5)) (nine (j%5))
  have eu:=Nat.mod_add_div j 5
  rw [show 44*(j/5)+9*(j%5)=9*j-j/5 by omega,show 5*(j/5)+j%5=j by omega] at h
  exact h
end Ruliology.CellularAutomata.BlackShieldSpeed

/-! The four-step agreement proof and the two periodic-word arguments are adapted
from Bosdure's Rule30BlackRuns at 40017e8. Here the initial row is arbitrary,
the site is arbitrary, and the shield takes one fewer tick per five pairs. -/
namespace Ruliology.CellularAutomata.FiniteQuarter
open Rule30Jen Rule30Realization Rule30FiniteConfigs Rule30FiniteMaskedJen BlackShieldSpeed
def WBAt (x : Int → Bool) (t : Nat) (m : Int) (j : Nat) :=
  ∀ i : Nat, 1 ≤ i → i ≤ j →
    evol x t (m + 2 * (i : Int) - 1) = false ∧ evol x t (m + 2 * (i : Int)) = true
variable {x : Int → Bool}
theorem wbAt_step1 (t : Nat) (m : Int) (j : Nat) (hm : evol x t m = false)
    (h : WBAt x t m (j + 1)) :
    evol x (t + 1) (m + 1) = true ∧
    evol x (t + 1) (m + 2) = true ∧
    WBAt x (t + 1) (m + 2) j := by
  have h1 := h 1 (by omega) (by omega)
  have hm1 : evol x t (m + 1) = false := by
    rw [show m + 1 = m + 2 * ((1 : Nat) : Int) - 1 by omega]; exact h1.1
  have hm2 : evol x t (m + 2) = true := by
    rw [show m + 2 = m + 2 * ((1 : Nat) : Int) by omega]; exact h1.2
  refine ⟨?_, ?_, fun i hi1 hij => ⟨?_, ?_⟩⟩
  · show rule (evol x t (m + 1 - 1)) (evol x t (m + 1)) (evol x t (m + 1 + 1)) = true
    rw [show m + 1 - 1 = m by omega, show m + 1 + 1 = m + 2 by omega, hm, hm1, hm2]
    rfl
  · show rule (evol x t (m + 2 - 1)) (evol x t (m + 2)) (evol x t (m + 2 + 1)) = true
    rw [show m + 2 - 1 = m + 1 by omega, hm1, hm2]
    rfl
  · have hi := h i hi1 (by omega)
    have hi' := h (i + 1) (by omega) (by omega)
    show rule (evol x t (m + 2 + 2 * (i : Int) - 1 - 1))
        (evol x t (m + 2 + 2 * (i : Int) - 1))
        (evol x t (m + 2 + 2 * (i : Int) - 1 + 1)) = false
    rw [show m + 2 + 2 * (i : Int) - 1 - 1 = m + 2 * (i : Int) by omega,
      show m + 2 + 2 * (i : Int) - 1 = m + 2 * ((i + 1 : Nat) : Int) - 1 by omega,
      show m + 2 * ((i + 1 : Nat) : Int) - 1 + 1 = m + 2 * ((i + 1 : Nat) : Int) by omega,
      hi.2, hi'.1, hi'.2]
    rfl
  · have hi' := h (i + 1) (by omega) (by omega)
    show rule (evol x t (m + 2 + 2 * (i : Int) - 1))
        (evol x t (m + 2 + 2 * (i : Int)))
        (evol x t (m + 2 + 2 * (i : Int) + 1)) = true
    rw [show m + 2 + 2 * (i : Int) - 1 = m + 2 * ((i + 1 : Nat) : Int) - 1 by omega,
      show m + 2 + 2 * (i : Int) = m + 2 * ((i + 1 : Nat) : Int) by omega,
      hi'.1, hi'.2]
    rfl

/-- **Two-step self-shielding shift.** If `evol x t m = false` and `WBAt x t m (j + 1)`, then two steps
later at column `m + 2` we have `evol x (t + 2) (m + 2) = false` and `WBAt x (t + 2) (m + 2) j`. -/
theorem wbAt_step2 (t : Nat) (m : Int) (j : Nat) (hm : evol x t m = false)
    (h : WBAt x t m (j + 1)) :
    evol x (t + 2) (m + 2) = false ∧ WBAt x (t + 2) (m + 2) j := by
  obtain ⟨c1, c2, hwb1⟩ := wbAt_step1 t m j hm h
  refine ⟨?_, fun i hi1 hij => ⟨?_, ?_⟩⟩
  · show rule (evol x (t + 1) (m + 2 - 1)) (evol x (t + 1) (m + 2)) (evol x (t + 1) (m + 2 + 1)) = false
    rw [show m + 2 - 1 = m + 1 by omega, c1, c2]
    rfl
  · have hi := hwb1 i hi1 hij
    have hleft : evol x (t + 1) (m + 2 + 2 * (i : Int) - 1 - 1) = true := by
      by_cases hi0 : i = 1
      · subst hi0
        rw [show m + 2 + 2 * ((1 : Nat) : Int) - 1 - 1 = m + 2 by omega]
        exact c2
      · have hprev := hwb1 (i - 1) (by omega) (by omega)
        rw [show m + 2 + 2 * (i : Int) - 1 - 1 = m + 2 + 2 * ((i - 1 : Nat) : Int) by omega]
        exact hprev.2
    show rule (evol x (t + 1) (m + 2 + 2 * (i : Int) - 1 - 1))
        (evol x (t + 1) (m + 2 + 2 * (i : Int) - 1))
        (evol x (t + 1) (m + 2 + 2 * (i : Int) - 1 + 1)) = false
    rw [hleft, hi.1, show m + 2 + 2 * (i : Int) - 1 + 1 = m + 2 + 2 * (i : Int) by omega, hi.2]
    rfl
  · have hi := hwb1 i hi1 hij
    show rule (evol x (t + 1) (m + 2 + 2 * (i : Int) - 1))
        (evol x (t + 1) (m + 2 + 2 * (i : Int)))
        (evol x (t + 1) (m + 2 + 2 * (i : Int) + 1)) = true
    rw [hi.1, hi.2]
    rfl

/-- **Rightmost column of `(white black)^j` stays black for `2 j` steps, then turns white.** -/
theorem wbAt_right_wall : ∀ (j t : Nat) (m : Int), evol x t m = false → WBAt x t m j →
    (∀ s, s < 2 * j → evol x (t + s) (m + 2 * (j : Int)) = true) ∧
    evol x (t + 2 * j) (m + 2 * (j : Int)) = false
  | 0, t, m, hm, _ => ⟨fun _ hs => by omega, by simpa using hm⟩
  | j + 1, t, m, hm, h => by
    obtain ⟨hm2, hwb2⟩ := wbAt_step2 t m j hm h
    obtain ⟨ih_wall, ih_end⟩ := wbAt_right_wall j (t + 2) (m + 2) hm2 hwb2
    have htop0 : evol x t (m + 2 * ((j + 1 : Nat) : Int)) = true :=
      (h (j + 1) (by omega) (by omega)).2
    have htop1 : evol x (t + 1) (m + 2 * ((j + 1 : Nat) : Int)) = true := by
      by_cases hj : j = 0
      · subst hj
        have c2 := (wbAt_step1 t m 0 hm h).2.1
        simpa using c2
      · have hw1 := ((wbAt_step1 t m j hm h).2.2 j (by omega) (by omega)).2
        rwa [show m + 2 + 2 * (j : Int) = m + 2 * ((j + 1 : Nat) : Int) by omega] at hw1
    refine ⟨fun s hs => ?_, ?_⟩
    · rcases s with _ | _ | s'
      · simpa using htop0
      · exact htop1
      · have := ih_wall s' (by omega)
        rwa [show t + 2 + s' = t + (s' + 2) by omega,
          show m + 2 + 2 * (j : Int) = m + 2 * ((j + 1 : Nat) : Int) by omega] at this
    · rwa [show t + 2 + 2 * j = t + 2 * (j + 1) by omega,
        show m + 2 + 2 * (j : Int) = m + 2 * ((j + 1 : Nat) : Int) by omega] at ih_end

/-! #### Box agreement and the `4 j`-step horizon -/

/-- Agreement inside a box `[m + 1, m + W]` whose right boundary `m + W` stays `true` at steps
`< s` and agrees at step `s`. -/
theorem box_agree (t0 t1 : Nat) (m : Int) (W : Nat)
    (hdrv : ∀ s, evol x (t0 + s) m = evol x (t1 + s) m)
    (hinit : ∀ p : Int, m + 1 ≤ p → p ≤ m + (W : Int) → evol x t0 p = evol x t1 p) :
    ∀ s : Nat, (∀ q : Int, q = m + (W : Int) →
      (∀ s', s' < s → evol x (t0 + s') q = true ∧ evol x (t1 + s') q = true) ∧
      evol x (t0 + s) q = evol x (t1 + s) q) →
      ∀ p : Int, m + 1 ≤ p → p ≤ m + (W : Int) → evol x (t0 + s) p = evol x (t1 + s) p
  | 0, _, p, hp1, hp2 => by simpa using hinit p hp1 hp2
  | s + 1, hq, p, hp1, hp2 => by
    by_cases hpW : p = m + (W : Int)
    · exact (hq p hpW).2
    · have ih := box_agree t0 t1 m W hdrv hinit s (fun q hqW =>
        ⟨fun s' hs' => (hq q hqW).1 s' (by omega),
         by
           have hw := (hq q hqW).1 s (by omega)
           rw [hw.1, hw.2]⟩)
      have hleft : evol x (t0 + s) (p - 1) = evol x (t1 + s) (p - 1) := by
        by_cases hpm : p - 1 = m
        · rw [hpm]; exact hdrv s
        · exact ih (p - 1) (by omega) (by omega)
      have hmid : evol x (t0 + s) p = evol x (t1 + s) p := ih p hp1 (by omega)
      have hright : evol x (t0 + s) (p + 1) = evol x (t1 + s) (p + 1) :=
        ih (p + 1) (by omega) (by omega)
      show evol x (t0 + s + 1) p = evol x (t1 + s + 1) p
      show rule (evol x (t0 + s) (p - 1)) (evol x (t0 + s) p) (evol x (t0 + s) (p + 1)) =
        rule (evol x (t1 + s) (p - 1)) (evol x (t1 + s) p) (evol x (t1 + s) (p + 1))
      rw [hleft, hmid, hright]

/-- Shrinking light-cone agreement on `[m + 1, m + W - s']` driven by column `m`. -/
theorem cone_agree_gen (a0 a1 : Nat) (m : Int) (W : Nat)
    (hdrv : ∀ s', evol x (a0 + s') m = evol x (a1 + s') m)
    (hrow : ∀ p : Int, m + 1 ≤ p → p ≤ m + (W : Int) → evol x a0 p = evol x a1 p) :
    ∀ s' : Nat, ∀ p : Int, m + 1 ≤ p → p + s' ≤ m + (W : Int) →
      evol x (a0 + s') p = evol x (a1 + s') p
  | 0, p, hp1, hp2 => by simpa using hrow p hp1 (by omega)
  | s' + 1, p, hp1, hp2 => by
    have ih := cone_agree_gen a0 a1 m W hdrv hrow s'
    have hleft : evol x (a0 + s') (p - 1) = evol x (a1 + s') (p - 1) := by
      by_cases hpm : p - 1 = m
      · rw [hpm]; exact hdrv s'
      · exact ih (p - 1) (by omega) (by omega)
    have hmid := ih p hp1 (by omega)
    have hright := ih (p + 1) (by omega) (by omega)
    show evol x (a0 + s' + 1) p = evol x (a1 + s' + 1) p
    show rule (evol x (a0 + s') (p - 1)) (evol x (a0 + s') p) (evol x (a0 + s') (p + 1)) =
      rule (evol x (a1 + s') (p - 1)) (evol x (a1 + s') p) (evol x (a1 + s') (p + 1))
    rw [hleft, hmid, hright]

/-- **Four-fold horizon (`4 j` steps).** If `WBAt x t0 m j` and `WBAt x t1 m j` hold with
`evol x t0 m = false`, `evol x t1 m = false`, and column `m` has the same values from `t0` and `t1`,
then column `m + 1` agrees for `4 j` steps (`0 ≤ s < 4 j`). -/
theorem wbAt_agree_four (t0 t1 : Nat) (m : Int) (j : Nat)
    (hm0 : evol x t0 m = false) (hm1 : evol x t1 m = false)
    (hwb0 : WBAt x t0 m j) (hwb1 : WBAt x t1 m j)
    (hdrv : ∀ s, evol x (t0 + s) m = evol x (t1 + s) m) :
    ∀ s, s < 4 * j → evol x (t0 + s) (m + 1) = evol x (t1 + s) (m + 1) := by
  obtain ⟨wall0, end0⟩ := wbAt_right_wall j t0 m hm0 hwb0
  obtain ⟨wall1, end1⟩ := wbAt_right_wall j t1 m hm1 hwb1
  have hinit : ∀ p : Int, m + 1 ≤ p → p ≤ m + (2 * j : Nat) → evol x t0 p = evol x t1 p := by
    intro p hp1 hp2
    by_cases hpar : (p - m) % 2 = 0
    · have hi : p = m + 2 * ((((p - m) / 2).toNat : Nat) : Int) := by omega
      rw [hi, (hwb0 _ (by omega) (by omega)).2, (hwb1 _ (by omega) (by omega)).2]
    · have hi : p = m + 2 * ((((p - m + 1) / 2).toNat : Nat) : Int) - 1 := by omega
      rw [hi, (hwb0 _ (by omega) (by omega)).1, (hwb1 _ (by omega) (by omega)).1]
  have hbox : ∀ s, s ≤ 2 * j → ∀ p : Int, m + 1 ≤ p → p ≤ m + (2 * j : Nat) →
      evol x (t0 + s) p = evol x (t1 + s) p := by
    intro s hs
    apply box_agree t0 t1 m (2 * j) hdrv hinit
    intro q hq
    subst hq
    have hcast : m + ((2 * j : Nat) : Int) = m + 2 * (j : Int) := by omega
    rw [hcast]
    refine ⟨fun s' hs' => ⟨wall0 s' (by omega), wall1 s' (by omega)⟩, ?_⟩
    by_cases hs2 : s < 2 * j
    · rw [wall0 s hs2, wall1 s hs2]
    · have hseq : s = 2 * j := by omega
      subst hseq
      rw [end0, end1]
  have hcone := cone_agree_gen (t0 + 2 * j) (t1 + 2 * j) m (2 * j)
    (fun s' => by
      rw [show t0 + 2 * j + s' = t0 + (2 * j + s') by omega,
        show t1 + 2 * j + s' = t1 + (2 * j + s') by omega]
      exact hdrv (2 * j + s'))
    (hbox (2 * j) (Nat.le_refl _))
  intro s hs
  by_cases hs2 : s ≤ 2 * j
  · exact hbox s hs2 (m + 1) (by omega) (by omega)
  · have := hcone (s - 2 * j) (m + 1) (by omega) (by omega)
    rwa [show t0 + 2 * j + (s - 2 * j) = t0 + s by omega,
      show t1 + 2 * j + (s - 2 * j) = t1 + s by omega] at this

end Ruliology.CellularAutomata.FiniteQuarter

namespace Ruliology.CellularAutomata.FiniteQuarter
open Rule30Jen Rule30Realization Rule30FiniteConfigs Rule30FiniteMaskedJen BlackShieldSpeed
variable {x : Int → Bool} {lo : Int}
local notation "col" => (fun (t : Nat) => evol x t 0)
def duration (j : Nat) := 9*j-j/5
theorem duration_shield (j : Nat) : Shield (duration j) j := faster_shield j
theorem blackAtZero (H : Nat → Nat) (hshield : ∀ j, Shield (H j) j) (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false) (T P r t1 : Nat) (hper : ∀ t, T ≤ t → col (t + P) = col t)
    (ht1 : T ≤ t1) (hrP : r < P)
    (hrun : ∀ s, s < r → col (t1 + s) = true)
    (hw0 : col (t1 + r) = false)
    (hlong : H ((P - r + 3) / 4) ≤ r) : False := by
  have hP : 0 < P := by omega
  have hj1 : P - r ≤ 4 * ((P - r + 3) / 4) := by omega
  generalize hjdef : (P - r + 3) / 4 = j at hj1 hlong
  have hperk : ∀ k t, T ≤ t → col (t + k * P) = col t := periodic_mul (f := fun t => evol x t 0) hper
  have hblack : ∀ k s, s < r → evol x (t1 + k * P + s) 0 = true := by
    intro k s hs
    have := hperk k (t1 + s) (by omega)
    show col (t1 + k * P + s) = true
    rw [show t1 + k * P + s = t1 + s + k * P by omega, this]
    exact hrun s hs
  have hwhite0 : ∀ k, evol x (t1 + r + k * P) 0 = false := by
    intro k
    have := hperk k (t1 + r) (by omega)
    show col (t1 + r + k * P) = false
    rw [this]; exact hw0
  have hwb : ∀ k, WBAt x (t1 + r + k * P) 0 j := by
    intro k
    have := hshield j x 0 (t1 + k * P + (r - H j)) (fun s hs => by
      have := hblack k (r - H j + s) (by omega)
      rwa [show t1 + k * P + (r - H j + s) = t1 + k * P + (r - H j) + s by omega] at this)
    rwa [show t1 + k * P + (r - H j) + H j = t1 + r + k * P by omega] at this
  have hdrv : ∀ k s, evol x (t1 + r + s) 0 = evol x (t1 + r + k * P + s) 0 := by
    intro k s
    have := hperk k (t1 + r + s) (by omega)
    show col (t1 + r + s) = col (t1 + r + k * P + s)
    rw [show t1 + r + k * P + s = t1 + r + s + k * P by omega, this]
  -- Column 1 agrees at every white time of the period.
  have hcol_masked : ∀ k s, s < P → evol x (t1 + r + k * P + s) 0 = false →
      evol x (t1 + r + s) 1 = evol x (t1 + r + k * P + s) 1 := by
    intro k s hs hcw
    by_cases hsPr : s < P - r
    · have := wbAt_agree_four (t1 + r) (t1 + r + k * P) 0 j
        (by simpa using hwhite0 0) (hwhite0 k) (by simpa using hwb 0) (hwb k) (hdrv k)
        s (by omega)
      simpa using this
    · -- For `P - r ≤ s < P`, `t1 + r + k * P + s` lies inside the `(k + 1)`-th black run.
      have hPk : (k + 1) * P = k * P + P := Nat.succ_mul k P
      have hb := hblack (k + 1) (s - (P - r)) (by omega)
      rw [hPk, show t1 + (k * P + P) + (s - (P - r)) = t1 + r + k * P + s by omega] at hb
      rw [hb] at hcw
      exact absurd hcw (by decide)
  -- Conclude by Masked Jen (`Rule30MaskedJen.Rule30FiniteMaskedJen.masked_jen hlo hzero 0`) from time `t1 + r`.
  refine Rule30FiniteMaskedJen.masked_jen hlo hzero 0 (T := t1 + r) (P := P) hP (fun t ht => hper t (by omega)) (fun t ht hcw => ?_)
  rw [show (0 : Int) + 1 = 1 by rfl]
  have hdm := Nat.div_add_mod (t - (t1 + r)) P
  generalize (t - (t1 + r)) / P = q at hdm
  have hmod := Nat.mod_lt (t - (t1 + r)) hP
  generalize (t - (t1 + r)) % P = s at hdm hmod
  have hq1 : (q + 1) * P = q * P + P := Nat.succ_mul q P
  have hcomm : P * q = q * P := Nat.mul_comm P q
  have hcw_q : evol x (t1 + r + q * P + s) 0 = false := by
    rwa [show t1 + r + q * P + s = t by omega]
  have hcw_q1 : evol x (t1 + r + (q + 1) * P + s) 0 = false := by
    rw [hq1, show t1 + r + (q * P + P) + s = t + P by omega]
    have hp0 : evol x (t + P) 0 = evol x t 0 := hper t (by omega)
    rw [hp0, hcw]
  have e1 := hcol_masked q s hmod hcw_q
  have e2 := hcol_masked (q + 1) s hmod hcw_q1
  rw [hq1] at e2
  rw [show t + P = t1 + r + (q * P + P) + s by omega, ← e2, e1,
    show t1 + r + q * P + s = t by omega]

theorem whiteAtZero (H : Nat → Nat) (hshield : ∀ j, Shield (H j) j) (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false) (T P s r t1 : Nat)
    (hper : ∀ t, T ≤ t → col (t + P) = col t)
    (ht1 : T ≤ t1) (hs : 9 ≤ s) (hsr : s + r < P)
    (hblk : ∀ i, i < s → col (t1 + i) = true)
    (hwht : ∀ i, i < r → col (t1 + s + i) = false)
    (hnextb : col (t1 + s + r) = true)
    (hlong : 1 + H ((P - s - r + 1) / 4) ≤ r) : False := by
  have hP : 0 < P := by omega
  have hj1 : P - s - r ≤ 4 * ((P - s - r + 1) / 4) + 2 := by omega
  generalize hjdef : (P - s - r + 1) / 4 = j at hj1 hlong
  have hperk : ∀ k t, T ≤ t → col (t + k * P) = col t := periodic_mul (f := fun t => evol x t 0) hper
  have hMul : ∀ k, (k + 1) * P = k * P + P := fun k => Nat.succ_mul k P
  have cblk : ∀ k i, i < s → evol x (t1 + k * P + i) 0 = true := by
    intro k i hi
    have := hperk k (t1 + i) (by omega)
    show col (t1 + k * P + i) = true
    rw [show t1 + k * P + i = t1 + i + k * P by omega, this]; exact hblk i hi
  have cwht : ∀ k i, i < r → evol x (t1 + s + k * P + i) 0 = false := by
    intro k i hi
    have := hperk k (t1 + s + i) (by omega)
    show col (t1 + s + k * P + i) = false
    rw [show t1 + s + k * P + i = t1 + s + i + k * P by omega, this]; exact hwht i hi
  have cnextb : ∀ k, evol x (t1 + s + r + k * P) 0 = true := by
    intro k
    have := hperk k (t1 + s + r) (by omega)
    show col (t1 + s + r + k * P) = true
    rw [this]; exact hnextb
  -- Start of the white run of period k: column 1 white, column 2 black (Lemma A).
  have hstart : ∀ k, evol x (t1 + s + k * P) 1 = false ∧ evol x (t1 + s + k * P) 2 = true := by
    intro k
    have := Rule30FiniteBlackRuns.nine_black x (t1 + k * P + (s - 9)) 0 (fun i hi => by
      have := cblk k (s - 9 + i) (by omega)
      rwa [show t1 + k * P + (s - 9 + i) = t1 + k * P + (s - 9) + i by omega] at this)
    rw [show t1 + k * P + (s - 9) + 9 = t1 + s + k * P by omega] at this
    simpa using this
  -- Column 1 is black during the rest of the white run (steps 1..r).
  have hrun1 : ∀ k i, 1 ≤ i → i ≤ r → evol x (t1 + s + k * P + i) 1 = true := by
    intro k i hi1 hir
    have c1 : evol x (t1 + s + k * P + 1) 1 = true := by
      show rule (evol x (t1 + s + k * P) (1 - 1)) (evol x (t1 + s + k * P) 1)
        (evol x (t1 + s + k * P) (1 + 1)) = true
      have h0 := cwht k 0 (by omega)
      rw [show t1 + s + k * P + 0 = t1 + s + k * P by omega] at h0
      rw [show (1 : Int) - 1 = 0 by rfl, show (1 : Int) + 1 = 2 by rfl, h0, (hstart k).1,
        (hstart k).2]
      rfl
    have := Rule30FiniteBlackRuns.black_stays x 0 (t1 + s + k * P + 1) (r - 1) (fun i' hi' => by
      have := cwht k (1 + i') (by omega)
      rwa [show t1 + s + k * P + (1 + i') = t1 + s + k * P + 1 + i' by omega] at this) c1
      (i - 1) (by omega)
    rwa [show t1 + s + k * P + 1 + (i - 1) = t1 + s + k * P + i by omega] at this
  -- At the end of the white run (`t1 + s + r + k * P`), `WBAt` holds at column 1.
  have hend : ∀ k, WBAt x (t1 + s + r + k * P) 1 j := by
    intro k i hi1 hij
    have := hshield j x 1 (t1 + s + k * P + (r - H j)) (fun i' hi' => by
        have := hrun1 k (r - H j + i') (by omega) (by omega)
        rwa [show t1 + s + k * P + (r - H j + i') = t1 + s + k * P + (r - H j) + i' by omega]
          at this) i hi1 hij
    rwa [show t1 + s + k * P + (r - H j) + H j = t1 + s + r + k * P by omega] at this
  -- One step later (`t1 + s + r + 1 + k * P`), column 1 is white and `WBAt` still holds at column 1.
  have hend1_col1 : ∀ k, evol x (t1 + s + r + k * P + 1) 1 = false := by
    intro k
    have hc1 : evol x (t1 + s + r + k * P) 1 = true := by
      have := hrun1 k r (by omega) (Nat.le_refl r)
      rwa [show t1 + s + k * P + r = t1 + s + r + k * P by omega] at this
    show rule (evol x (t1 + s + r + k * P) (1 - 1)) (evol x (t1 + s + r + k * P) 1)
      (evol x (t1 + s + r + k * P) (1 + 1)) = false
    rw [show (1 : Int) - 1 = 0 by rfl, cnextb k, hc1]
    rfl
  have hend1_wb : ∀ k, WBAt x (t1 + s + r + k * P + 1) 1 j := by
    intro k i hi1 hij
    have hc1 : evol x (t1 + s + r + k * P) 1 = true := by
      have := hrun1 k r (by omega) (Nat.le_refl r)
      rwa [show t1 + s + k * P + r = t1 + s + r + k * P by omega] at this
    have hi := hend k i hi1 hij
    have hleft : evol x (t1 + s + r + k * P) (1 + 2 * (i : Int) - 1 - 1) = true := by
      by_cases hi0 : i = 1
      · subst hi0
        rw [show (1 : Int) + 2 * ((1 : Nat) : Int) - 1 - 1 = 1 by omega]
        exact hc1
      · have hprev := hend k (i - 1) (by omega) (by omega)
        rw [show (1 : Int) + 2 * (i : Int) - 1 - 1 = 1 + 2 * ((i - 1 : Nat) : Int) by omega]
        exact hprev.2
    refine ⟨?_, ?_⟩
    · show rule (evol x (t1 + s + r + k * P) (1 + 2 * (i : Int) - 1 - 1))
          (evol x (t1 + s + r + k * P) (1 + 2 * (i : Int) - 1))
          (evol x (t1 + s + r + k * P) (1 + 2 * (i : Int) - 1 + 1)) = false
      rw [hleft, hi.1, show (1 : Int) + 2 * (i : Int) - 1 + 1 = 1 + 2 * (i : Int) by omega, hi.2]
      rfl
    · show rule (evol x (t1 + s + r + k * P) (1 + 2 * (i : Int) - 1))
          (evol x (t1 + s + r + k * P) (1 + 2 * (i : Int)))
          (evol x (t1 + s + r + k * P) (1 + 2 * (i : Int) + 1)) = true
      rw [hi.1, hi.2]
      rfl
  have hdrv : ∀ k s', evol x (t1 + s + r + 1 + s') 0 = evol x (t1 + s + r + k * P + 1 + s') 0 := by
    intro k s'
    have := hperk k (t1 + s + r + 1 + s') (by omega)
    show col (t1 + s + r + 1 + s') = col (t1 + s + r + k * P + 1 + s')
    rw [show t1 + s + r + k * P + 1 + s' = t1 + s + r + 1 + s' + k * P by omega, this]
  -- At time `t1 + s + r + 1 + k * P`, column 1 is `false` and `WBAt` holds at column 1,
  -- so for `j ≥ 1`, `wbAt_right_wall` keeps column `1 + 2 j` black for `2 j` steps and white at `2 j`.
  have hrem_agree : ∀ k s', s' < 4 * j + 1 →
      evol x (t1 + s + r + 1 + s') 1 = evol x (t1 + s + r + k * P + 1 + s') 1 := by
    intro k s' hs'
    rcases Nat.eq_zero_or_pos j with rfl | hjpos
    · have : s' = 0 := by omega
      subst this
      have a := hend1_col1 0
      simp only [Nat.zero_mul, Nat.add_zero] at a
      rw [Nat.add_zero, Nat.add_zero, a, hend1_col1 k]
    · obtain ⟨wall0, end0⟩ := wbAt_right_wall j (t1 + s + r + 1) 1
        (by simpa using hend1_col1 0) (by simpa using hend1_wb 0)
      obtain ⟨wallk, endk⟩ := wbAt_right_wall j (t1 + s + r + k * P + 1) 1
        (hend1_col1 k) (hend1_wb k)
      have hinit : ∀ p : Int, 0 + 1 ≤ p → p ≤ 0 + (2 * j + 1 : Nat) →
          evol x (t1 + s + r + 1) p = evol x (t1 + s + r + k * P + 1) p := by
        intro p hp1 hp2
        by_cases hp : p = 1
        · subst hp
          have a := hend1_col1 0
          simp only [Nat.zero_mul, Nat.add_zero] at a
          rw [a, hend1_col1 k]
        · have wb0 := hend1_wb 0
          simp only [Nat.zero_mul, Nat.add_zero] at wb0
          by_cases hpar : p % 2 = 0
          · have hi : p = 1 + 2 * (((p / 2).toNat : Nat) : Int) - 1 := by omega
            rw [hi, (wb0 _ (by omega) (by omega)).1, (hend1_wb k _ (by omega) (by omega)).1]
          · have hi : p = 1 + 2 * ((((p - 1) / 2).toNat : Nat) : Int) := by omega
            rw [hi, (wb0 _ (by omega) (by omega)).2, (hend1_wb k _ (by omega) (by omega)).2]
      have hbox : ∀ u, u ≤ 2 * j → ∀ p : Int, 0 + 1 ≤ p → p ≤ 0 + (2 * j + 1 : Nat) →
          evol x (t1 + s + r + 1 + u) p = evol x (t1 + s + r + k * P + 1 + u) p := by
        intro u hu
        apply box_agree (t1 + s + r + 1) (t1 + s + r + k * P + 1) 0 (2 * j + 1) (hdrv k) hinit
        intro q hq
        subst hq
        have hcast : (0 : Int) + ((2 * j + 1 : Nat) : Int) = 1 + 2 * (j : Int) := by omega
        rw [hcast]
        refine ⟨fun u' hu' => ⟨wall0 u' (by omega), wallk u' (by omega)⟩, ?_⟩
        by_cases hu2 : u < 2 * j
        · rw [wall0 u hu2, wallk u hu2]
        · have hueq : u = 2 * j := by omega
          subst hueq
          rw [end0, endk]
      have hcone := cone_agree_gen (t1 + s + r + 1 + 2 * j) (t1 + s + r + k * P + 1 + 2 * j) 0
        (2 * j + 1)
        (fun u' => by
          rw [show t1 + s + r + 1 + 2 * j + u' = t1 + s + r + 1 + (2 * j + u') by omega,
            show t1 + s + r + k * P + 1 + 2 * j + u' =
              t1 + s + r + k * P + 1 + (2 * j + u') by omega]
          exact hdrv k (2 * j + u'))
        (hbox (2 * j) (Nat.le_refl _))
      by_cases hs2 : s' ≤ 2 * j
      · exact hbox s' hs2 1 (by omega) (by omega)
      · have := hcone (s' - 2 * j) 1 (by omega) (by omega)
        rwa [show t1 + s + r + 1 + 2 * j + (s' - 2 * j) = t1 + s + r + 1 + s' by omega,
          show t1 + s + r + k * P + 1 + 2 * j + (s' - 2 * j) =
            t1 + s + r + k * P + 1 + s' by omega] at this
  -- Column 1 agrees at every white time of the period starting at `t1 + s`.
  have hcol_masked : ∀ k i, i < P → evol x (t1 + s + k * P + i) 0 = false →
      evol x (t1 + s + i) 1 = evol x (t1 + s + k * P + i) 1 := by
    intro k i hi hcw
    by_cases hi0 : i = 0
    · subst hi0
      have a := (hstart 0).1
      simp only [Nat.zero_mul, Nat.add_zero] at a
      simp only [Nat.add_zero]
      rw [a, (hstart k).1]
    by_cases hir : i ≤ r
    · have a := hrun1 0 i (by omega) hir
      simp only [Nat.zero_mul, Nat.add_zero] at a
      rw [a, hrun1 k i (by omega) hir]
    by_cases hi_r : i = r
    · omega
    by_cases hic : i < P - s
    · have := hrem_agree k (i - r - 1) (by omega)
      rwa [show t1 + s + r + 1 + (i - r - 1) = t1 + s + i by omega,
        show t1 + s + r + k * P + 1 + (i - r - 1) = t1 + s + k * P + i by omega] at this
    · -- For `P - s ≤ i < P`, `t1 + s + k * P + i` lies inside the `(k + 1)`-th black run.
      have hb := cblk (k + 1) (i - (P - s)) (by omega)
      rw [hMul k, show t1 + (k * P + P) + (i - (P - s)) = t1 + s + k * P + i by omega] at hb
      rw [hb] at hcw
      exact absurd hcw (by decide)
  -- Conclude by Masked Jen (`Rule30MaskedJen.Rule30FiniteMaskedJen.masked_jen hlo hzero 0`) from time `t1 + s`.
  refine Rule30FiniteMaskedJen.masked_jen hlo hzero 0 (T := t1 + s) (P := P) hP (fun t ht => hper t (by omega)) (fun t ht hcw => ?_)
  rw [show (0 : Int) + 1 = 1 by rfl]
  have hdm := Nat.div_add_mod (t - (t1 + s)) P
  generalize (t - (t1 + s)) / P = q at hdm
  have hmod := Nat.mod_lt (t - (t1 + s)) hP
  generalize (t - (t1 + s)) % P = i at hdm hmod
  have hq1 : (q + 1) * P = q * P + P := Nat.succ_mul q P
  have hcomm : P * q = q * P := Nat.mul_comm P q
  have hcw_q : evol x (t1 + s + q * P + i) 0 = false := by
    rwa [show t1 + s + q * P + i = t by omega]
  have hcw_q1 : evol x (t1 + s + (q + 1) * P + i) 0 = false := by
    rw [hq1, show t1 + s + (q * P + P) + i = t + P by omega]
    have hp0 : evol x (t + P) 0 = evol x t 0 := hper t (by omega)
    rw [hp0, hcw]
  have e1 := hcol_masked q i hmod hcw_q
  have e2 := hcol_masked (q + 1) i hmod hcw_q1
  rw [hq1] at e2
  rw [show t + P = t1 + s + (q * P + P) + i by omega, ← e2, e1,
    show t1 + s + q * P + i = t by omega]

end Ruliology.CellularAutomata.FiniteQuarter

namespace Ruliology.CellularAutomata.FiniteQuarter
open Rule30Jen Rule30Realization Rule30FiniteConfigs BlackShieldSpeed
variable {x : Int → Bool} {lo : Int}

private theorem leftmost_shift (m : Int) (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false) :
    shiftConfig x m (lo-m) = true ∧ ∀ p, p < lo-m → shiftConfig x m p = false := by
  constructor
  · simpa only [shiftConfig, Int.sub_add_cancel] using hlo
  · intro p hp
    exact hzero (p+m) (by omega)

/-- No periodic column on a row with a leftmost black cell can contain this black run and following white. -/
theorem black_quarter_of_shield (H : Nat → Nat) (shield : ∀ j, Shield (H j) j) (m : Int) (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false)
    (T P r t : Nat) (per : ∀ n, T ≤ n → evol x (n+P) m = evol x n m) (ht : T ≤ t)
    (hr : r < P) (run : ∀ s, s < r → evol x (t+s) m = true)
    (white : evol x (t+r) m = false) (long : H ((P-r+3)/4) ≤ r) : False := by
  obtain ⟨left,below⟩ := leftmost_shift m hlo hzero
  apply blackAtZero H shield left below T P r t _ ht hr _ _ long
  · simpa only [evol_shiftConfig, Int.zero_add] using per
  · simpa only [evol_shiftConfig, Int.zero_add] using run
  · simpa only [evol_shiftConfig, Int.zero_add] using white

/-- The second exclusion applies when at least nine blacks precede the white run, with another black after it. -/
theorem white_quarter_of_shield (H : Nat → Nat) (shield : ∀ j, Shield (H j) j) (m : Int) (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false)
    (T P s r t : Nat) (per : ∀ n, T ≤ n → evol x (n+P) m = evol x n m)
    (ht : T ≤ t) (hs : 9 ≤ s) (hsr : s+r < P)
    (black : ∀ a, a < s → evol x (t+a) m = true)
    (white : ∀ a, a < r → evol x (t+s+a) m = false)
    (nextBlack : evol x (t+s+r) m = true)
    (long : 1 + H ((P-s-r+1)/4) ≤ r) : False := by
  obtain ⟨left,below⟩ := leftmost_shift m hlo hzero
  apply whiteAtZero H shield left below T P s r t _ ht hs hsr _ _ _ long
  · simpa only [evol_shiftConfig, Int.zero_add] using per
  · simpa only [evol_shiftConfig, Int.zero_add] using black
  · simpa only [evol_shiftConfig, Int.zero_add] using white
  · simpa only [evol_shiftConfig, Int.zero_add] using nextBlack

/-- No periodic column on a row with a leftmost black cell can contain this black run and following white. -/
theorem black_quarter (m : Int) (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false)
    (T P r t : Nat) (per : ∀ n, T ≤ n → evol x (n+P) m = evol x n m) (ht : T ≤ t)
    (hr : r < P) (run : ∀ s, s < r → evol x (t+s) m = true)
    (white : evol x (t+r) m = false) (long : duration ((P-r+3)/4) ≤ r) : False := by
  exact black_quarter_of_shield duration duration_shield m hlo hzero T P r t per ht hr run white long

/-- The second exclusion applies when at least nine blacks precede the white run, with another black after it. -/
theorem white_quarter (m : Int) (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false)
    (T P s r t : Nat) (per : ∀ n, T ≤ n → evol x (n+P) m = evol x n m)
    (ht : T ≤ t) (hs : 9 ≤ s) (hsr : s+r < P)
    (black : ∀ a, a < s → evol x (t+a) m = true)
    (white : ∀ a, a < r → evol x (t+s+a) m = false)
    (nextBlack : evol x (t+s+r) m = true)
    (long : 1 + duration ((P-s-r+1)/4) ≤ r) : False := by
  exact white_quarter_of_shield duration duration_shield m hlo hzero T P s r t per ht hs hsr black white nextBlack long

theorem examples : duration ((64-44+3)/4) ≤ 44 ∧ 1+duration ((74-9-45+1)/4) ≤ 45 := by decide
end Ruliology.CellularAutomata.FiniteQuarter
