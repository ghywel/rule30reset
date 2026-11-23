module

public import Ruliology.CellularAutomata.Rule30RunWindow

/-! Bit-parallel certificates for sets of spatial prefixes. Each bit position names one row. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30RunPlanes
open Rule30DrivenPrefix Rule30RunWindow

structure Family where
  live : Nat
  cols : List Nat
  deriving Inhabited, DecidableEq

def col (f : Family) (j : Nat) := f.cols.getD j 0
def Known (f : Family) (i r : Nat) : Prop :=
  ∀ j, j < f.cols.length → (col f j).testBit i = r.testBit j
def Holds (f : Family) (r : Nat) : Prop := ∃ i, f.live.testBit i = true ∧ Known f i r
def restrict (f : Family) (m : Nat) : Family := { f with live := m }

def rest (a b : Nat) : Nat := a ^^^ (a &&& b)
theorem rest_bit (a b i : Nat) : (rest a b).testBit i = (a.testBit i && !b.testBit i) := by
  simp only [rest, Nat.testBit_xor, Nat.testBit_and]
  cases a.testBit i <;> cases b.testBit i <;> rfl

def plateStep (left : Nat) (p : Nat → Nat) (j : Nat) :=
  (if j=0 then left else p (j-1)) ^^^ (p j ||| p (j+1))

theorem plateStep_bit {p : Nat → Nat} {left r i k : Nat} {b : Bool}
    (hl : left.testBit i = b) (h : ∀ j, j < k+1 → (p j).testBit i = r.testBit j)
    (j : Nat) (hj : j < k) : (plateStep left p j).testBit i = (step b r).testBit j := by
  rw [step_bit]
  simp only [plateStep, Nat.testBit_xor, Nat.testBit_or, h j (by omega), h (j+1) (by omega)]
  split <;> simp_all
  exact h (j-1) (by omega)

def outCol (f : Family) (j : Nat) := plateStep f.live (plateStep 0 (col f)) j

theorem outCol_bit {f : Family} {i r j : Nat} (live : f.live.testBit i = true)
    (h : Known f i r) (hj : j+2 < f.cols.length) :
    (outCol f j).testBit i = (double r).testBit j := by
  apply plateStep_bit (k := j+1) live _ j (by omega)
  intro u hu
  apply plateStep_bit (k := j+2) (b := false) (by simp) _ u (by omega)
  exact fun v hv => h v (by omega)

/-- A common row has the same bit on every tested pair of planes. -/
def separated (a b : Nat) : List (Nat × Nat) → Bool
  | [] => a == 0 || b == 0
  | (x,y) :: ps =>
    a == 0 || b == 0 ||
      (separated (a &&& x) (b &&& y) ps && separated (rest a x) (rest b y) ps)

theorem separated_sound {pairs : List (Nat × Nat)} {a b i j : Nat}
    (ok : separated a b pairs) (ha : a.testBit i = true) (hb : b.testBit j = true)
    (same : ∀ p ∈ pairs, p.1.testBit i = p.2.testBit j) : False := by
  induction pairs generalizing a b with
  | nil =>
    have na : a ≠ 0 := by intro e; simp [e] at ha
    have nb : b ≠ 0 := by intro e; simp [e] at hb
    simp [separated,na,nb] at ok
  | cons p ps ih =>
    obtain ⟨x,y⟩ := p
    have na : (a == 0) = false := by apply beq_eq_false_iff_ne.mpr; intro e; simp [e] at ha
    have nb : (b == 0) = false := by apply beq_eq_false_iff_ne.mpr; intro e; simp [e] at hb
    simp only [separated,na,nb,Bool.false_or,Bool.and_eq_true] at ok
    have e := same (x,y) List.mem_cons_self
    have tail := fun p (hp : p ∈ ps) => same p (List.mem_cons_of_mem _ hp)
    cases h : x.testBit i with
    | false =>
      have h' : y.testBit j = false := e.symm.trans h
      exact ih ok.2 (by simp [rest_bit,ha,h]) (by simp [rest_bit,hb,h']) tail
    | true =>
      have h' : y.testBit j = true := e.symm.trans h
      exact ih ok.1 (by simp [Nat.testBit_and,ha,h]) (by simp [Nat.testBit_and,hb,h']) tail

structure Move where
  shift : Nat
  selected : Nat
  deriving Inhabited

def moved (live : Nat) (m : Move) := live &&& m.selected
def stay (live : Nat) (m : Move) := rest live m.selected
def moveOK (live : Nat) (m : Move) : Bool :=
  let v := moved live m
  ((v >>> m.shift) <<< m.shift == v) && (((v >>> m.shift) &&& stay live m) == 0)

def moveBits (live : Nat) (m : Move) (v : Nat) :=
  (v &&& stay live m) ||| ((v &&& moved live m) >>> m.shift)

def move (f : Family) (m : Move) : Family :=
  ⟨moveBits f.live m f.live, f.cols.map (moveBits f.live m)⟩

theorem move_lane {live i : Nat} {m : Move} (ok : moveOK live m) (hi : live.testBit i = true) :
    ∃ k, ∀ v, (moveBits live m v).testBit k = v.testBit i := by
  obtain ⟨floor, apart⟩ := Bool.and_eq_true_iff.mp ok
  have ef := beq_iff_eq.mp floor
  have ea := beq_iff_eq.mp apart
  cases bit : m.selected.testBit i with
  | false =>
    have s : (stay live m).testBit i = true := by simp [stay,rest_bit,hi,bit]
    have f := congrArg (fun q : Nat => q.testBit i) ea
    have no : (moved live m).testBit (i + m.shift) = false := by
      simpa [Nat.testBit_and,Nat.testBit_shiftRight,s,Nat.add_comm] using f
    exact ⟨i, fun v => by simp [moveBits,Nat.testBit_or,Nat.testBit_and,Nat.testBit_shiftRight,
      s, no, Nat.add_comm]⟩
  | true =>
    have mv : (moved live m).testBit i = true := by simp [moved,Nat.testBit_and,hi,bit]
    have f := congrArg (fun q : Nat => q.testBit i) ef
    have le : m.shift ≤ i := by
      by_cases h : m.shift ≤ i
      · exact h
      · simp [Nat.testBit_shiftLeft, h, mv] at f
    let k := i - m.shift
    have e : m.shift+k = i := by dsimp [k]; omega
    have e' : k+m.shift = i := by omega
    have z := congrArg (fun q : Nat => q.testBit k) ea
    have no : (stay live m).testBit k = false := by
      simpa [Nat.testBit_and,Nat.testBit_shiftRight,e,e',mv] using z
    exact ⟨k, fun v => by simp [moveBits,Nat.testBit_or,Nat.testBit_and,Nat.testBit_shiftRight,
      no,e,mv]⟩

theorem move_sound {f : Family} {r : Nat} {m : Move} (ok : moveOK f.live m)
    (h : Holds f r) : Holds (move f m) r := by
  obtain ⟨i,hi,hc⟩ := h
  obtain ⟨k,hk⟩ := move_lane ok hi
  refine ⟨k,(hk f.live).trans hi,fun j hj => ?_⟩
  have jl : j < f.cols.length := by simpa [move] using hj
  have ev : col (move f m) j = moveBits f.live m (col f j) := by
    simp [col,move,List.getD_eq_getElem?_getD,jl]
  rw [ev,hk]
  exact hc j jl

def compact (f : Family) : List Move → Family
  | [] => f
  | m :: ms => compact (move f m) ms
def safe (f : Family) : List Move → Bool
  | [] => true
  | m :: ms => moveOK f.live m && safe (move f m) ms
theorem compact_sound {f : Family} {r : Nat} {ms : List Move} (ok : safe f ms) (h : Holds f r) :
    Holds (compact f ms) r := by
  induction ms generalizing f with
  | nil => exact h
  | cons m ms ih =>
    obtain ⟨a,b⟩ := Bool.and_eq_true_iff.mp ok
    exact ih b (move_sound a h)

def planePairs (a b : Family) (js : List Nat) : List (Nat × Nat) :=
  js.map fun j => (outCol a j,col b j)
def inRange (a b : Family) (js : List Nat) : Bool :=
  js.all fun j => j+2 < a.cols.length && j < b.cols.length

theorem no_pair {a b : Family} {x y r i k : Nat} {js : List Nat}
    (range : inRange a b js) (cert : separated x y (planePairs a b js))
    (hi : a.live.testBit i = true) (ca : Known a i r) (cb : Known b k (double r))
    (hx : x.testBit i = true) (hy : y.testBit k = true) : False := by
  apply separated_sound cert hx hy
  intro p hp
  obtain ⟨j,hj,rfl⟩ := List.mem_map.mp hp
  obtain ⟨ha,hb⟩ := Bool.and_eq_true_iff.mp (List.all_eq_true.mp range j hj)
  exact (outCol_bit hi ca (of_decide_eq_true ha)).trans (cb j (of_decide_eq_true hb)).symm

def dup (live k p : Nat) : Nat := (p &&& live) ||| ((p &&& live) <<< k)
def widen (f : Family) (k : Nat) : Family :=
  ⟨f.live ||| (f.live <<< k), f.cols.map (dup f.live k) ++ [f.live <<< k]⟩

theorem widen_sound {f : Family} {k r : Nat} (bound : f.live < 2^k)
    (h : Holds f r) : Holds (widen f k) r := by
  obtain ⟨i,hi,hc⟩ := h
  have ik : i < k := by
    by_cases e : i < k
    · exact e
    · have := Nat.testBit_lt_two_pow (i := i) (Nat.lt_of_lt_of_le bound
        (Nat.pow_le_pow_right (by decide) (by omega)))
      simp_all
  let j := if r.testBit f.cols.length then k+i else i
  have high : (f.live <<< k).testBit j = r.testBit f.cols.length := by
    dsimp [j]
    cases b : r.testBit f.cols.length <;> simp [Nat.testBit_shiftLeft,hi,show ¬k ≤ i by omega]
  have jl : (f.live ||| (f.live <<< k)).testBit j = true := by
    dsimp [j]
    cases b : r.testBit f.cols.length <;> simp [Nat.testBit_or,Nat.testBit_shiftLeft,hi]
  have same (p : Nat) : (dup f.live k p).testBit j = p.testBit i := by
    have z : f.live.testBit (k+i) = false :=
      Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le bound (Nat.pow_le_pow_right (by decide) (by omega)))
    dsimp [j]
    cases b : r.testBit f.cols.length <;>
      simp [dup,Nat.testBit_or,Nat.testBit_shiftLeft,Nat.testBit_and,hi,z,show ¬k ≤ i by omega]
  refine ⟨j,jl,fun v hv => ?_⟩
  have lim : v < f.cols.length+1 := by simpa [widen] using hv
  by_cases old : v < f.cols.length
  · have e : col (widen f k) v = dup f.live k (col f v) := by
      simp [col,widen,List.getD_eq_getElem?_getD,List.getElem?_append,old]
    rw [e,same,hc v old]
  · have e : v = f.cols.length := by omega
    subst v
    simpa [col,widen,List.getD_eq_getElem?_getD,List.getElem?_append] using high

structure Slot where
  shifts : List Move
  grow : Bool
  count : Nat
  fresh : Family
  lanes : Nat
  front : Nat
  back : Nat
  forwardBits : List Nat
  backwardBits : List Nat
  deriving Inhabited

def prepare (f : Family) (s : Slot) : Bool :=
  let c := compact f s.shifts
  safe f s.shifts && (if s.grow then c.live < 2^s.count else true) &&
    decide (s.fresh = if s.grow then widen c s.count else c)

theorem prepare_sound {f : Family} {s : Slot} {r : Nat} (ok : prepare f s)
    (h : Holds f r) : Holds s.fresh r := by
  obtain ⟨hl, he⟩ := Bool.and_eq_true_iff.mp ok
  obtain ⟨safe', range⟩ := Bool.and_eq_true_iff.mp hl
  rw [of_decide_eq_true he]
  have c := compact_sound safe' h
  split <;> rename_i e
  · exact widen_sound (of_decide_eq_true (by simpa [e] using range)) c
  · exact c

def extend (a : Family) (n : Nat) : Nat → Family
  | 0 => a
  | k+1 => extend (widen a n) (2*n) k
def room (a : Family) (n : Nat) : Nat → Bool
  | 0 => true
  | k+1 => a.live < 2^n && room (widen a n) (2*n) k
theorem extend_sound {a : Family} {n k r : Nat} (ok : room a n k) (h : Holds a r) :
    Holds (extend a n k) r := by
  induction k generalizing a n with
  | zero => exact h
  | succ k ih =>
    obtain ⟨lim,next⟩ := Bool.and_eq_true_iff.mp ok
    exact ih next (widen_sound (of_decide_eq_true lim) h)

def cut (a b : Family) (n : Nat) (x y : Nat) (js : List Nat) : Bool :=
  let k := b.cols.length+2-a.cols.length
  let src := restrict a x
  let ext := extend src n k
  x == 0 || y == 0 ||
    (room src n k && inRange ext b js && separated ext.live y (planePairs ext b js))

theorem cut_sound {a b : Family} {n x y r : Nat} {js : List Nat}
    (ok : cut a b n x y js) (ha : Holds (restrict a x) r)
    (hb : Holds (restrict b y) (double r)) : False := by
  have nx : (x == 0) = false := by
    obtain ⟨i,hi,_⟩ := ha
    apply beq_eq_false_iff_ne.mpr; intro e; simp [restrict,e] at hi
  have ny : (y == 0) = false := by
    obtain ⟨i,hi,_⟩ := hb
    apply beq_eq_false_iff_ne.mpr; intro e; simp [restrict,e] at hi
  simp only [cut,nx,ny,Bool.false_or] at ok
  obtain ⟨p,c⟩ := Bool.and_eq_true_iff.mp ok
  obtain ⟨s,range⟩ := Bool.and_eq_true_iff.mp p
  obtain ⟨i,li,ki⟩ := extend_sound s ha
  obtain ⟨j,lj,kj⟩ := hb
  exact no_pair range c li ki kj li lj

def fOK (a b : Slot) : Bool :=
  cut a.fresh b.fresh a.lanes a.front (rest b.fresh.live b.front) b.forwardBits
def bOK (a b : Slot) : Bool :=
  cut a.fresh b.fresh a.lanes (rest a.front a.back) b.back a.backwardBits

theorem fOK_sound {a b : Slot} {r : Nat} (ok : fOK a b)
    (pa : Holds (restrict a.fresh (a.front &&& a.fresh.live)) r)
    (pb : Holds b.fresh (double r)) : Holds (restrict b.fresh (b.front &&& b.fresh.live)) (double r) := by
  obtain ⟨i,hi,ci⟩ := pa
  obtain ⟨j,hj,cj⟩ := pb
  have both : a.front.testBit i = true ∧ a.fresh.live.testBit i = true := by
    simpa [restrict,Nat.testBit_and] using hi
  refine ⟨j,?_,cj⟩
  cases flag : b.front.testBit j with
  | true => simp [restrict,Nat.testBit_and,flag,hj]
  | false => exact False.elim (cut_sound ok ⟨i,both.1,ci⟩ ⟨j,by simp [restrict,rest_bit,hj,flag],cj⟩)

theorem bOK_sound {a b : Slot} {r : Nat} (ok : bOK a b)
    (pa : Holds (restrict a.fresh (a.front &&& a.fresh.live)) r)
    (pb : Holds (restrict b.fresh (b.back &&& b.front &&& b.fresh.live)) (double r)) :
    Holds (restrict a.fresh (a.back &&& a.front &&& a.fresh.live)) r := by
  obtain ⟨i,hi,ci⟩ := pa
  obtain ⟨j,hj,cj⟩ := pb
  have both : a.front.testBit i = true ∧ a.fresh.live.testBit i = true := by
    simpa [restrict,Nat.testBit_and] using hi
  have dest : b.back.testBit j = true := (Bool.and_eq_true_iff.mp
    (Bool.and_eq_true_iff.mp (by simpa only [restrict,Nat.testBit_and] using hj)).1).1
  refine ⟨i,?_,ci⟩
  cases flag : a.back.testBit i with
  | true => simp [restrict,Nat.testBit_and,flag,both]
  | false => exact False.elim (cut_sound ok ⟨i,by simp [restrict,rest_bit,both.1,flag],ci⟩ ⟨j,dest,cj⟩)

def Trace (r : Nat) : List Family → Prop
  | [] => True
  | a :: as => Holds a r ∧ Trace (double r) as

def preps : List Family → List Slot → Bool
  | [], [] => true
  | a :: as, s :: ss => prepare a s && preps as ss
  | _, _ => false

theorem preps_sound {fs : List Family} {ss : List Slot} {r : Nat}
    (ok : preps fs ss) (h : Trace r fs) : Trace r (ss.map Slot.fresh) := by
  induction fs generalizing r ss with
  | nil => cases ss <;> simp [preps] at ok <;> trivial
  | cons a as ih =>
    cases ss with
    | nil => simp [preps] at ok
    | cons s ss =>
      obtain ⟨p,q⟩ := Bool.and_eq_true_iff.mp ok
      exact ⟨prepare_sound p h.1, ih q h.2⟩

def front (s : Slot) := restrict s.fresh (s.front &&& s.fresh.live)
def back (s : Slot) := restrict s.fresh (s.back &&& s.front &&& s.fresh.live)
def fEdges (a : Slot) : List Slot → Bool
  | [] => true
  | b::bs => fOK a b && fEdges b bs
def bEdges : List Slot → Bool
  | [] => true
  | [a] => a.back == a.front
  | a::b::bs => bOK a b && bEdges (b::bs)

theorem fEdges_sound {a : Slot} {ss : List Slot} {r : Nat} (ok : fEdges a ss)
    (h : Holds (front a) r) (tail : Trace (double r) (ss.map Slot.fresh)) :
    Trace r ((a::ss).map front) := by
  induction ss generalizing a r with
  | nil => exact ⟨h,trivial⟩
  | cons b bs ih =>
    obtain ⟨pa,pb⟩ := Bool.and_eq_true_iff.mp ok
    exact ⟨h,ih pb (fOK_sound pa h tail.1) tail.2⟩

theorem bEdges_sound {ss : List Slot} {r : Nat} (ok : bEdges ss)
    (h : Trace r (ss.map front)) : Trace r (ss.map back) := by
  induction ss generalizing r with
  | nil => trivial
  | cons a ss ih =>
    cases ss with
    | nil =>
      have e : a.back = a.front := beq_iff_eq.mp ok
      exact ⟨by simpa only [back,front,e,Nat.and_self] using h.1,trivial⟩
    | cons b bs =>
      obtain ⟨p,q⟩ := Bool.and_eq_true_iff.mp ok
      have tail := ih q h.2
      exact ⟨bOK_sound p h.1 tail.1,tail⟩

def stageOK (fs : List Family) : List Slot → Bool
  | [] => false
  | a::as => preps fs (a::as) && (a.front == a.fresh.live) && fEdges a as && bEdges (a::as)

theorem prepsCons {a as s ss} (p : prepare a s) (q : preps as ss) :
    preps (a::as) (s::ss) := Bool.and_eq_true_iff.mpr ⟨p,q⟩

theorem fEdgesCons {a b bs} (p : fOK a b) (q : fEdges b bs) :
    fEdges a (b::bs) := Bool.and_eq_true_iff.mpr ⟨p,q⟩

theorem bEdgesCons {a b bs} (p : bOK a b) (q : bEdges (b::bs)) :
    bEdges (a::b::bs) := Bool.and_eq_true_iff.mpr ⟨p,q⟩

theorem stage_intro {fs a ss} (p : preps fs (a::ss)) (e : (a.front == a.fresh.live) = true)
    (f : fEdges a ss) (b : bEdges (a::ss)) : stageOK fs (a::ss) :=
  Bool.and_eq_true_iff.mpr ⟨Bool.and_eq_true_iff.mpr ⟨Bool.and_eq_true_iff.mpr ⟨p,e⟩,f⟩,b⟩

theorem stage_sound {fs : List Family} {ss : List Slot} {r : Nat}
    (ok : stageOK fs ss) (h : Trace r fs) : Trace r (ss.map back) := by
  cases ss with
  | nil => simp [stageOK] at ok
  | cons a as =>
    have ⟨p,q⟩ := Bool.and_eq_true_iff.mp ok
    have ⟨v,f⟩ := Bool.and_eq_true_iff.mp p
    have ⟨c,e⟩ := Bool.and_eq_true_iff.mp v
    have eq := beq_iff_eq.mp e
    have raw := preps_sound c h
    exact bEdges_sound q (fEdges_sound f (by simpa [front,restrict,eq] using raw.1) raw.2)

theorem no_empty {r : Nat} {fs : List Family} (h : Trace r fs) :
    fs.any (fun f => f.live == 0) = false := by
  induction fs generalizing r with
  | nil => rfl
  | cons a as ih =>
    obtain ⟨i,hi,_⟩ := h.1
    have nz : a.live ≠ 0 := by intro e; simp [e] at hi
    rw [List.any_cons, ih h.2]
    simp [nz]

def plane (p : Nat → Bool) : List Nat → Nat
  | [] => 0
  | x :: xs => (p x).toNat + 2 * plane p xs

theorem plane_bit (p : Nat → Bool) {xs : List Nat} {i : Nat} (hi : i < xs.length) :
    (plane p xs).testBit i = p xs[i] := by
  induction xs generalizing i with
  | nil => simp at hi
  | cons x xs ih =>
    cases i with
    | zero =>
      change ((p x).toNat + 2 * plane p xs).testBit 0 = p x
      rw [Nat.testBit_zero]
      cases p x <;> simp <;> omega
    | succ i =>
      rw [plane,Nat.testBit_succ]
      have e : ∀ a, ((p x).toNat + 2*a)/2 = a := by intro a; cases p x <;> simp <;> omega
      rw [e]; exact ih (by simpa using hi)

open Rule30GateTrap Rule30TrappedRuns
def guard (c : Option Bool) (x : Nat) : Bool := c.elim true (fun b => x.testBit 0 == b)
def start (c : Option Bool) : Family :=
  ⟨plane (guard c) trapCodes,(List.range 16).map fun j => plane (fun x => x.testBit j) trapCodes⟩

theorem start_sound {c : Option Bool} {r : Nat} (h : Rule30RunWindow.Holds (entry c) r) :
    Holds (start c) r := by
  have pair : r % 2^16 ∈ trapCodes ∧ guard c (r % 2^16) = true := by
    cases c with
    | none => exact ⟨h,rfl⟩
    | some b => exact List.mem_filter.mp h
  obtain ⟨i,hi,e⟩ := List.getElem_of_mem pair.1
  refine ⟨i,?_,fun j hj => ?_⟩
  · change (plane (guard c) trapCodes).testBit i = true
    rw [plane_bit _ hi,e,pair.2]
  · have jl : j<16 := by simpa [start] using hj
    have low : (r % 2^16).testBit j = r.testBit j := by rw [Nat.testBit_mod_two_pow]; simp [jl]
    simpa [col,start,List.getD_eq_getElem?_getD,jl,plane_bit _ hi,e] using low

theorem start_trace {cs : List (Option Bool)} {r : Nat}
    (h : Rule30RunWindow.Trace r (cs.map entry)) : Trace r (cs.map start) := by
  induction cs generalizing r with
  | nil => trivial
  | cons c cs ih => exact ⟨start_sound h.1, ih h.2⟩

end Ruliology.CellularAutomata.Rule30RunPlanes
