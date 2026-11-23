module

public import Ruliology.CellularAutomata.Rule30Prize
public import Ruliology.CellularAutomata.Rule30GateTrap
public meta import Ruliology.CellularAutomata.Rule30GateTrap
public meta import Std.Data.HashSet.Basic
public meta import Lean.Elab.Term

/-! Sharp forbidden words for the alternating column's trapped gate. -/
@[expose] public section
-- The proposal generator reuses the local executable Rule 30 definitions.
set_option compiler.relaxedMetaCheck true

namespace Ruliology.CellularAutomata.Rule30RunWindow
open Rule30DrivenPrefix

structure Window where
  width : Nat
  codes : List Nat
  deriving Inhabited, Repr, DecidableEq

def Holds (d : Window) (r : Nat) : Prop := r % 2 ^ d.width ∈ d.codes

/-- The next window from every extension of this prefix, including both right-edge cells. -/
def outputs (a b x : Nat) : List Nat :=
  let k := min a (b + 2)
  (List.range (2 ^ (b + 2 - k))).map fun e =>
    double (x % 2^k + 2^k * e) % 2^b

theorem output_mem (a b r : Nat) :
    double r % 2^b ∈ outputs a b (r % 2^a) := by
  let k := min a (b+2)
  have hk : k ≤ a := Nat.min_le_left ..
  have hb : k ≤ b+2 := Nat.min_le_right ..
  have dvd : 2^k ∣ 2^a := Nat.pow_dvd_pow 2 hk
  refine List.mem_map.mpr ⟨r / 2^k % 2^(b+2-k), List.mem_range.mpr
    (Nat.mod_lt _ (Nat.two_pow_pos _)), ?_⟩
  change double (r % 2^a % 2^k + 2^k * (r / 2^k % 2^(b+2-k))) % 2^b = _
  rw [Nat.mod_mod_of_dvd _ dvd, ← Nat.mod_mul, ← Nat.pow_add,
    show k + (b+2-k) = b+2 by omega]
  exact (double_prefix r b).symm

def widen (d : Window) : Window :=
  ⟨d.width+1, d.codes ++ d.codes.map (· + 2^d.width)⟩

theorem widen_sound {d : Window} {r : Nat} (h : Holds d r) : Holds (widen d) r := by
  change r % 2^(d.width+1) ∈ d.codes ++ _
  rw [Nat.pow_succ, Nat.mod_mul]
  have b := Nat.mod_lt (r / 2^d.width) (by decide : 0 < 2)
  rcases (show r / 2^d.width % 2 = 0 ∨ r / 2^d.width % 2 = 1 by omega) with e | e
  · simpa [e] using List.mem_append_left (d.codes.map (· + 2^d.width)) h
  · exact List.mem_append_right _ (List.mem_map.mpr ⟨_, h, by simp [e]⟩)

/-- Residue sets discard a row only when one of its residues is absent. -/
def residues (p : Nat) : List Nat → Nat
  | [] => 0
  | x :: xs => (1 <<< (x % p)) ||| residues p xs

theorem residues_sound (p : Nat) {x : Nat} {xs : List Nat} (h : x ∈ xs) :
    (residues p xs).testBit (x % p) = true := by
  induction xs with
  | nil => cases h
  | cons y ys ih =>
    rw [residues,Nat.testBit_or,Bool.or_eq_true]
    rcases List.mem_cons.mp h with e | h
    · subst y
      left
      simp [Nat.shiftLeft_eq]
    · exact Or.inr (ih h)

structure Index where
  first : Nat
  second : Nat
  deriving Inhabited

def index (xs : List Nat) : Index := ⟨residues 8191 xs, residues 8179 xs⟩
def Index.contains (a : Index) (x : Nat) : Bool :=
  a.first.testBit (x % 8191) && a.second.testBit (x % 8179)

theorem index_sound {x : Nat} {xs : List Nat} (h : x ∈ xs) : (index xs).contains x = true := by
  exact Bool.and_eq_true_iff.mpr ⟨residues_sound _ h, residues_sound _ h⟩

def forward (a b : Window) : Window :=
  let seen := index (a.codes.flatMap (outputs a.width b.width))
  ⟨b.width, b.codes.filter seen.contains⟩

def backward (a b : Window) : Window :=
  let seen := index b.codes
  ⟨a.width, a.codes.filter fun x => (outputs a.width b.width x).any seen.contains⟩

theorem forward_sound {a b : Window} {r : Nat} (ha : Holds a r) (hb : Holds b (double r)) :
    Holds (forward a b) (double r) := by
  apply List.mem_filter.mpr
  exact ⟨hb, index_sound (List.mem_flatMap.mpr ⟨_, ha, output_mem ..⟩)⟩

theorem backward_sound {a b : Window} {r : Nat} (ha : Holds a r) (hb : Holds b (double r)) :
    Holds (backward a b) r := by
  apply List.mem_filter.mpr
  exact ⟨ha, List.any_eq_true.mpr ⟨_, output_mem .., index_sound hb⟩⟩

/-- Successive frames describe the same orbit, including its first row. -/
def Trace (r : Nat) : List Window → Prop
  | [] => True
  | d :: ds => Holds d r ∧ Trace (double r) ds

def sweepF (a : Window) : List Window → List Window
  | [] => [a]
  | b :: bs => a :: sweepF (forward a b) bs

theorem sweepF_sound {ds : List Window} {a : Window} {r : Nat} (h : Trace r (a::ds)) :
    Trace r (sweepF a ds) := by
  induction ds generalizing a r with
  | nil => exact h
  | cons b bs ih => exact ⟨h.1, ih ⟨forward_sound h.1 h.2.1, h.2.2⟩⟩

def sweepB : List Window → List Window
  | [] => []
  | a :: ds =>
    match sweepB ds with
    | [] => [a]
    | b :: bs => backward a b :: b :: bs

theorem sweepB_sound {ds : List Window} {r : Nat} (h : Trace r ds) :
    Trace r (sweepB ds) := by
  induction ds generalizing r with
  | nil => trivial
  | cons a ds ih =>
    have ht := ih h.2
    simp only [sweepB]
    cases eq : sweepB ds with
    | nil => exact ⟨h.1, trivial⟩
    | cons b bs =>
      rw [eq] at ht
      exact ⟨backward_sound h.1 ht.1, ht⟩

def sweep : List Window → List Window
  | [] => []
  | a :: ds => sweepB (sweepF a ds)

theorem sweep_sound {ds : List Window} {r : Nat} (h : Trace r ds) :
    Trace r (sweep ds) := by
  cases ds with
  | nil => trivial
  | cons a ds => exact sweepB_sound (sweepF_sound h)

/-- A bit in the schedule asks to expose one further cell at that sampled time. -/
def liftAt : Nat → List Window → List Window
  | _, [] => []
  | m, a :: ds =>
    (if m.testBit 0 then widen a else a) :: liftAt (m / 2) ds

theorem liftAt_sound {r m : Nat} {ds : List Window} (h : Trace r ds) :
    Trace r (liftAt m ds) := by
  induction ds generalizing r m with
  | nil => trivial
  | cons a ds ih =>
    exact ⟨by change Holds (if _ then _ else _) _; split <;> first | exact widen_sound h.1 | exact h.1,
      ih h.2⟩

theorem trace_ne (r : Nat) (ds : List Window) (h : Trace r ds) :
    ds.any (fun d => d.codes.isEmpty) = false := by
  induction ds generalizing r with
  | nil => rfl
  | cons a ds ih =>
    have hn : a.codes ≠ [] := List.ne_nil_of_mem h.1
    rw [List.any_cons, ih _ h.2]
    simp [hn]

/-- An untrusted separator and an explicit result keep kernel evaluation local to one edge. -/
structure Mark where
  mask : Index
  box : Window
  deriving Inhabited

def fValid (a b : Window) (m : Mark) : Bool :=
  (a.codes.all fun x => (outputs a.width b.width x).all m.mask.contains) &&
    decide (m.box = ⟨b.width, b.codes.filter m.mask.contains⟩)

def bValid (a b : Window) (m : Mark) : Bool :=
  (b.codes.all m.mask.contains) &&
    decide (m.box = ⟨a.width, a.codes.filter fun x =>
      (outputs a.width b.width x).any m.mask.contains⟩)

theorem fValid_sound {a b : Window} {m : Mark} {r : Nat} (ok : fValid a b m)
    (ha : Holds a r) (hb : Holds b (double r)) : Holds m.box (double r) := by
  obtain ⟨cov, eq⟩ := Bool.and_eq_true_iff.mp ok
  rw [of_decide_eq_true eq]
  exact List.mem_filter.mpr ⟨hb, List.all_eq_true.mp (List.all_eq_true.mp cov _ ha) _ (output_mem ..)⟩

theorem bValid_sound {a b : Window} {m : Mark} {r : Nat} (ok : bValid a b m)
    (ha : Holds a r) (hb : Holds b (double r)) : Holds m.box r := by
  obtain ⟨cov, eq⟩ := Bool.and_eq_true_iff.mp ok
  rw [of_decide_eq_true eq]
  exact List.mem_filter.mpr ⟨ha, List.any_eq_true.mpr ⟨_, output_mem .., List.all_eq_true.mp cov _ hb⟩⟩

def fChain (a : Window) : List Window → List Mark → Bool
  | [], [] => true
  | b :: bs, m :: ms => fValid a b m && fChain m.box bs ms
  | _, _ => false

theorem fCons {a b : Window} {bs : List Window} {m : Mark} {ms : List Mark}
    (edge : fValid a b m) (rest : fChain m.box bs ms) : fChain a (b::bs) (m::ms) :=
  Bool.and_eq_true_iff.mpr ⟨edge,rest⟩

theorem fChain_sound {a : Window} {bs : List Window} {ms : List Mark} {r : Nat}
    (ok : fChain a bs ms) (h : Trace r (a::bs)) : Trace r (a::ms.map Mark.box) := by
  induction bs generalizing a ms r with
  | nil => cases ms <;> simp [fChain] at ok <;> exact h
  | cons b bs ih =>
    cases ms with
    | nil => simp [fChain] at ok
    | cons m ms =>
      obtain ⟨edge, rest⟩ := Bool.and_eq_true_iff.mp ok
      exact ⟨h.1, ih rest ⟨fValid_sound edge h.1 h.2.1,h.2.2⟩⟩

def bChain : List Window → List Mark → Bool
  | [], [] => true
  | [a], [m] => decide (m.box = a)
  | a::b::bs, m::n::ms => bValid a n.box m && bChain (b::bs) (n::ms)
  | _, _ => false

theorem bCons {a b : Window} {bs : List Window} {m n : Mark} {ms : List Mark}
    (edge : bValid a n.box m) (rest : bChain (b::bs) (n::ms)) :
    bChain (a::b::bs) (m::n::ms) := Bool.and_eq_true_iff.mpr ⟨edge,rest⟩

theorem bChain_sound {bs : List Window} {ms : List Mark} {r : Nat}
    (ok : bChain bs ms) (h : Trace r bs) : Trace r (ms.map Mark.box) := by
  induction bs generalizing ms r with
  | nil => cases ms <;> simp [bChain] at ok <;> trivial
  | cons a bs ih =>
    cases ms with
    | nil => cases bs <;> simp [bChain] at ok
    | cons m ms =>
      cases bs with
      | nil =>
        cases ms with
        | nil =>
          have eq : m.box = a := of_decide_eq_true ok
          exact ⟨eq.symm ▸ h.1, trivial⟩
        | cons n ms => simp [bChain] at ok
      | cons b bs =>
        cases ms with
        | nil => simp [bChain] at ok
        | cons n ms =>
          obtain ⟨edge, rest⟩ := Bool.and_eq_true_iff.mp ok
          have ht := ih rest h.2
          exact ⟨bValid_sound edge h.1 ht.1, ht⟩

structure Pass where
  grow : Nat
  front : List Mark
  back : List Mark
  deriving Inhabited

def verifies (ds : List Window) (p : Pass) : Bool :=
  match liftAt p.grow ds with
  | [] => false
  | a :: rest => fChain a rest p.front && bChain (a :: p.front.map Mark.box) p.back

theorem verifies_intro {ds : List Window} {p : Pass} (ne : (liftAt p.grow ds).isEmpty = false)
    (f : fChain (liftAt p.grow ds).head! (liftAt p.grow ds).tail p.front)
    (b : bChain ((liftAt p.grow ds).head! :: p.front.map Mark.box) p.back) : verifies ds p := by
  unfold verifies
  cases eq : liftAt p.grow ds with
  | nil => simp [eq] at ne
  | cons a rest => rw [eq] at f b; exact Bool.and_eq_true_iff.mpr ⟨f,b⟩

theorem verifies_sound {ds : List Window} {p : Pass} {r : Nat} (ok : verifies ds p)
    (h : Trace r ds) : Trace r (p.back.map Mark.box) := by
  have h' := liftAt_sound (m := p.grow) h
  unfold verifies at ok
  cases eq : liftAt p.grow ds with
  | nil => simp [eq] at ok
  | cons a rest =>
    rw [eq] at h' ok
    obtain ⟨f,b⟩ := Bool.and_eq_true_iff.mp ok
    exact bChain_sound b (fChain_sound f h')

/-- A closed literal decodes least-significant 48-bit cells first. -/
def unpack (p : Nat) : Nat → List Nat
  | 0 => []
  | n+1 => p % (2^48) :: unpack (p >>> 48) n

def literal (width n packed : Nat) : Window := ⟨width, unpack packed n⟩

def chunks (width : Nat) (parts : List (Nat × Nat)) : Window :=
  ⟨width, parts.flatMap fun (n,p) => unpack p n⟩

def check : List Window → List Pass → Bool
  | ds, [] => ds.any (fun d => d.codes.isEmpty)
  | ds, p :: ps => verifies ds p && check (p.back.map Mark.box) ps

theorem check_refutes {ds : List Window} {ps : List Pass} (ok : check ds ps)
    {r : Nat} (h : Trace r ds) : False := by
  induction ps generalizing ds with
  | nil => exact Bool.noConfusion ((trace_ne _ _ h).symm.trans ok)
  | cons p ps ih =>
    obtain ⟨hp,ht⟩ := Bool.and_eq_true_iff.mp ok
    exact ih ht (verifies_sound hp h)

end Ruliology.CellularAutomata.Rule30RunWindow

namespace Ruliology.CellularAutomata.Rule30TrappedRuns
open Rule30GateTrap Rule30RunWindow

def block : List Nat := [5,5,5,5,3]
def headsOf (g : List Nat) : List Bool :=
  true :: g.flatMap fun k => List.replicate (k-1) false ++ [true]
def closed (n : Nat) : List Bool := headsOf (3 :: (List.replicate n block).flatten)
def five : List Bool := headsOf (List.replicate 5 block).flatten

def entry (c : Option Bool) : Window :=
  ⟨16, match c with
       | none => trapCodes
       | some b => trapCodes.filter fun x => x.testBit 0 == b⟩

def colours : List (Option Bool) := none :: none :: (closed 4).map some
def initial : List Window := colours.map entry

end Ruliology.CellularAutomata.Rule30TrappedRuns

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

namespace Ruliology.CellularAutomata.Rule30RunPlaneData
open Rule30RunPlanes Rule30TrappedRuns Rule30GateTrap
open Lean Elab Term
set_option maxHeartbeats 0
set_option maxRecDepth 100000
set_option Elab.async false

meta structure Work where
  codes : Array Nat
  slot : Slot
  deriving Inhabited

meta def packFlags (bs : Array Bool) : Nat := Id.run do
  let mut v := 0
  for i in [:bs.size] do
    if bs[i]! then v := v ||| (1 <<< i)
  return v

meta def selected (cs : Array Nat) (m : Nat) : Array Nat := Id.run do
  let mut xs := #[]
  for i in [:cs.size] do
    if m.testBit i then xs := xs.push cs[i]!
  return xs

meta def shifts (n active : Nat) : List Move := Id.run do
  if active == 2^n-1 then return []
  let mut masks := Array.replicate (n.log2+1) 0
  let mut rank := 0
  for i in [:n] do
    if active.testBit i then
      let delta := i-rank
      for j in [:masks.size] do
        if delta.testBit j then
          let pos := rank + ((delta >>> j) <<< j)
          masks := masks.modify j (· ||| (1 <<< pos))
      rank := rank+1
  let ms := masks.toList.zipIdx.filterMap fun (m,j) =>
    if m == 0 then none else some (⟨2^j,m⟩ : Move)
  return if ms.isEmpty then [⟨0,0⟩] else ms

meta def initWork (c : Option Bool) : Work :=
  let f := start c
  ⟨trapCodes.toArray, ⟨[], false, 0, f, trapCodes.length, f.live, f.live, [], []⟩⟩

meta def freshen (w : Work) (grow : Bool) : Work := Id.run do
  let s := w.slot
  let old := Rule30RunPlanes.back s
  let ms := shifts w.codes.size old.live
  let base := compact old ms
  let cs := selected w.codes old.live
  let f := if grow then Rule30RunPlanes.widen base cs.size else base
  let rows := if grow then cs ++ cs.map (· + 2^s.fresh.cols.length) else cs
  return ⟨rows, ⟨ms, grow, cs.size, f, rows.size, f.live, f.live, [], []⟩⟩

meta def widthLimit (ws : Array Nat) : Array Nat := Id.run do
  let mut out := #[]
  for w in ws do
    if let some last := out.back? then out := out.push (min w (last+2)) else out := out.push w
  return out

meta def growAt (ws : Array Work) : Array Bool :=
  let proposed := ws.map fun x =>
    let w := x.slot.fresh.cols.length
    w + (decide (w < 46 ∧ (selected x.codes x.slot.back).size ≤ 256)).toNat
  let widths := (widthLimit (widthLimit proposed).reverse).reverse
  Array.zipWith (fun x w => decide (x.slot.fresh.cols.length < w)) ws widths

meta def imageSet (a b : Work) (mask : Nat) : Std.HashSet Nat := Id.run do
  let mut out : Std.HashSet Nat := ∅
  for x in selected a.codes mask do
    for y in Rule30RunWindow.outputs a.slot.fresh.cols.length b.slot.fresh.cols.length x do
      out := out.insert y
  return out

meta def onePass (old : Array Work) (grow : Array Bool) : Array Work := Id.run do
  let mut ws := Array.zipWith freshen old grow
  for i in [1:ws.size] do
    let a := ws[i-1]!
    let b := ws[i]!
    let seen := imageSet a b a.slot.front
    let f := packFlags (b.codes.map seen.contains)
    let js := if f == b.slot.fresh.live then [] else (List.range b.slot.fresh.cols.length).reverse
    ws := ws.set! i {b with slot := {b.slot with front := f, back := f, forwardBits := js}}
  for u in [:ws.size-1] do
    let i := ws.size-2-u
    let a := ws[i]!
    let b := ws[i+1]!
    let seen := Std.HashSet.ofList (selected b.codes b.slot.back).toList
    let keep := packFlags (a.codes.map fun x =>
      (Rule30RunWindow.outputs a.slot.fresh.cols.length b.slot.fresh.cols.length x).any seen.contains)
    let m := keep &&& a.slot.front
    let js := if m == a.slot.front then [] else (List.range b.slot.fresh.cols.length).reverse
    ws := ws.set! i {a with slot := {a.slot with back := m, backwardBits := js}}
  return ws

meta def makePasses (old : Array Work) (grow : Array Bool) : Nat → Except String (List (List Slot))
  | 0 => .error "the finite width schedule was exhausted"
  | k+1 => do
    let ws := onePass old grow
    let result := (ws.map Work.slot).toList
    if ws.any (fun w => w.slot.back == 0) then return [result]
    let next := growAt ws
    if !next.any id then throw "a path survives the selected window widths"
    return result :: (← makePasses ws next k)

meta def movesTerm (ms : List Move) := Meta.mkListLit (Lean.mkConst ``Move)
  (ms.map fun m => mkApp2 (Lean.mkConst ``Move.mk) (mkNatLit m.shift) (mkNatLit m.selected))

def descending (n : Nat) := (List.range n).reverse

meta def slotTerm (s : Slot) : MetaM Expr := do
  let js (v : List Nat) := mkApp (Lean.mkConst ``descending) (mkNatLit v.length)
  let f := mkApp2 (Lean.mkConst ``Family.mk) (mkNatLit s.fresh.live) (toExpr s.fresh.cols)
  return mkAppN (Lean.mkConst ``Slot.mk) #[← movesTerm s.shifts, toExpr s.grow, mkNatLit s.count,
    f, mkNatLit s.lanes, mkNatLit s.front, mkNatLit s.back, js s.forwardBits, js s.backwardBits]

elab "trappedRunPlanes%" : term => do
  let old := (colours.map initWork).toArray
  match makePasses old (Array.replicate old.size false) (1+30*old.size) with
  | .error e => throwError "{e}"
  | .ok ps =>
    let mut names : Array Expr := #[]
    let tp := mkApp (Lean.mkConst ``List [.zero]) (Lean.mkConst ``Slot)
    for p in ps do
      let name := (← getMainModule) ++ Name.mkSimple ("planes" ++ toString names.size)
      let vals ← p.mapM fun s => liftM (slotTerm s)
      let v ← Meta.mkListLit (Lean.mkConst ``Slot) vals
      addDecl <| .defnDecl {name, levelParams := [], type := tp, value := v, hints := .abbrev, safety := .safe}
      names := names.push (Lean.mkConst name)
    Meta.mkListLit tp names.toList

noncomputable def data : List (List Slot) := trappedRunPlanes%
noncomputable def slots (n : Nat) := data.getD n []
noncomputable def frames : Nat → List Family
  | 0 => colours.map start
  | n+1 => (slots n).map Rule30RunPlanes.back

end Ruliology.CellularAutomata.Rule30RunPlaneData

namespace Ruliology.CellularAutomata.Rule30RunPlaneChecks
open Rule30RunPlanes Rule30RunPlaneData Rule30TrappedRuns
set_option maxHeartbeats 0
set_option maxRecDepth 100000

macro "plane_pass " name:ident n:num : command =>
  `(theorem $name : stageOK (frames $n) (slots $n) := by
      apply stage_intro
      · iterate 98 (apply prepsCons; · as_aux_lemma => decide +kernel)
        rfl
      · rfl
      · iterate 97 (apply fEdgesCons; · as_aux_lemma => decide +kernel)
        rfl
      · iterate 97 (apply bEdgesCons; · as_aux_lemma => decide +kernel)
        rfl)

plane_pass check0 0
plane_pass check1 1
plane_pass check2 2
plane_pass check3 3
plane_pass check4 4
plane_pass check5 5
plane_pass check6 6
plane_pass check7 7
plane_pass check8 8
plane_pass check9 9
plane_pass check10 10
plane_pass check11 11
plane_pass check12 12
plane_pass check13 13
plane_pass check14 14
plane_pass check15 15
plane_pass check16 16
plane_pass check17 17
plane_pass check18 18
plane_pass check19 19
plane_pass check20 20
plane_pass check21 21
plane_pass check22 22
plane_pass check23 23
plane_pass check24 24
plane_pass check25 25
plane_pass check26 26
plane_pass check27 27
plane_pass check28 28
plane_pass check29 29

theorem no_trace (r : Nat) : ¬ Rule30RunWindow.Trace r initial := by
  intro h
  have h0 : Trace r (frames 0) := start_trace h
  have h1 : Trace r (frames 1) := stage_sound check0 h0
  have h2 : Trace r (frames 2) := stage_sound check1 h1
  have h3 : Trace r (frames 3) := stage_sound check2 h2
  have h4 : Trace r (frames 4) := stage_sound check3 h3
  have h5 : Trace r (frames 5) := stage_sound check4 h4
  have h6 : Trace r (frames 6) := stage_sound check5 h5
  have h7 : Trace r (frames 7) := stage_sound check6 h6
  have h8 : Trace r (frames 8) := stage_sound check7 h7
  have h9 : Trace r (frames 9) := stage_sound check8 h8
  have h10 : Trace r (frames 10) := stage_sound check9 h9
  have h11 : Trace r (frames 11) := stage_sound check10 h10
  have h12 : Trace r (frames 12) := stage_sound check11 h11
  have h13 : Trace r (frames 13) := stage_sound check12 h12
  have h14 : Trace r (frames 14) := stage_sound check13 h13
  have h15 : Trace r (frames 15) := stage_sound check14 h14
  have h16 : Trace r (frames 16) := stage_sound check15 h15
  have h17 : Trace r (frames 17) := stage_sound check16 h16
  have h18 : Trace r (frames 18) := stage_sound check17 h17
  have h19 : Trace r (frames 19) := stage_sound check18 h18
  have h20 : Trace r (frames 20) := stage_sound check19 h19
  have h21 : Trace r (frames 21) := stage_sound check20 h20
  have h22 : Trace r (frames 22) := stage_sound check21 h21
  have h23 : Trace r (frames 23) := stage_sound check22 h22
  have h24 : Trace r (frames 24) := stage_sound check23 h23
  have h25 : Trace r (frames 25) := stage_sound check24 h24
  have h26 : Trace r (frames 26) := stage_sound check25 h25
  have h27 : Trace r (frames 27) := stage_sound check26 h26
  have h28 : Trace r (frames 28) := stage_sound check27 h27
  have h29 : Trace r (frames 29) := stage_sound check28 h28
  have h30 : Trace r (frames 30) := stage_sound check29 h29
  have empty : (frames 30).any (fun f => f.live == 0) = true := by decide +kernel
  exact Bool.noConfusion ((no_empty h30).symm.trans empty)

end Ruliology.CellularAutomata.Rule30RunPlaneChecks

namespace Ruliology.CellularAutomata.Rule30TrappedRuns
open Rule30GateTrap Rule30DrivenPrefix Rule30Ether Rule30StripCertificates
open Rule30PeriodTwoCoupled Rule30RunWindow

private def bits (a : Nat) : Nat → Bool
  | 0 => false
  | j+1 => a.testBit j

private theorem physical_gate (a s : Nat) :
    Rule30PeriodTwoSideways.u (bits a) s = (packed altCol a (2*s+1)).testBit 0 :=
  (packed_sound altCol (bits a) a (fun _ => rfl) _ 0).symm

private theorem physical_window (a t : Nat) : win (bits a) t =
    seg (fun i => (packed altCol a t).testBit i) 16 := by
  apply Rule30Ether.seg_congr
  intro i _
  simpa only [Nat.zero_add] using (packed_sound altCol (bits a) a (fun _ => rfl) t i).symm

private theorem witness {a code n s : Nat} (hc : code ∈ trapCodes)
    (hw : seg (fun i => (packed altCol a 1).testBit i) 16 = decode code)
    (hh : (List.range (closed n).length).all (fun i =>
      (packed altCol a (2*(s+i)+1)).testBit 0 == (closed n).getD i false) = true) :
    win (bits a) 1 ∈ trap ∧ ∀ i, i < (closed n).length →
      Rule30PeriodTwoSideways.u (bits a) (s+i) = (closed n).getD i false := by
  refine ⟨?_, fun i hi => ?_⟩
  · rw [physical_window, hw]
    exact List.mem_map.mpr ⟨_, hc, rfl⟩
  · rw [physical_gate]
    exact beq_iff_eq.mp (List.all_eq_true.mp hh i (List.mem_range.mpr hi))

set_option maxRecDepth 10000
set_option maxHeartbeats 0

/-- Four closed runs occur one sample after a trapped tick. -/
theorem four_one_sample :
    ∃ R, win R 1 ∈ trap ∧ ∀ i, i < (closed 4).length →
      Rule30PeriodTwoSideways.u R (1+i) = (closed 4).getD i false := by
  let a := 17911952117231624625415841284791634824617432618773606279499
  exact ⟨_, witness (a := a) (code := 44920) (by decide +kernel)
    (by decide +kernel) (by decide +kernel)⟩

/-- Three closed runs occur sixty samples after a trapped tick. -/
theorem three_sixty_samples :
    ∃ R, win R 1 ∈ trap ∧ ∀ i, i < (closed 3).length →
      Rule30PeriodTwoSideways.u R (60+i) = (closed 3).getD i false := by
  let a := 88769951030016947892698456558596051073035529750717722303543758321481268415460012
  exact ⟨_, witness (a := a) (code := 40615) (by decide +kernel)
    (by decide +kernel) (by decide +kernel)⟩

private theorem cone (R : Nat → Bool) (b x W : Nat)
    (start : ∀ j, j < W → x.testBit j = drv altCol R b (j+1)) :
    ∀ t j, j+t < W →
      (packed (fun k => altCol (b+k)) x t).testBit j = drv altCol R (b+t) (j+1) := by
  intro t
  induction t with
  | zero => exact start
  | succ t ih =>
    intro j hj
    rw [packed,step_bit,show b+(t+1) = b+t+1 by omega, drv_isR30 altCol R (b+t) j]
    unfold Rule30Jen.rule
    rw [ih j (by omega), ih (j+1) (by omega)]
    cases j with
    | zero => simp [drv_col0]
    | succ j => simp [ih j (by omega)]

private theorem packed_twice (b x : Nat) (hb : b%2=1) :
    ∀ i, iterate x i = packed (fun k => altCol (b+k)) x (2*i) := by
  intro i
  induction i with
  | zero => rfl
  | succ i ih =>
    have ho : altCol (b+2*i) = false := by unfold altCol; simp; omega
    have he : altCol (b+(2*i+1)) = true := by unfold altCol; simp; omega
    rw [iterate,ih,show 2*(i+1)=2*i+1+1 by omega, packed,packed,ho,he,double]

private theorem shift_iterate (r : Nat) : ∀ i, iterate (double r) i = iterate r (i+1)
  | 0 => rfl
  | i+1 => congrArg double (shift_iterate r i)

private theorem from_frames (ds : List Window) (r : Nat)
    (h : ∀ i (hi : i < ds.length), Holds ds[i] (iterate r i)) : Trace r ds := by
  induction ds generalizing r with
  | nil => trivial
  | cons a ds ih =>
    refine ⟨h 0 (by simp), ih _ (fun i hi => ?_)⟩
    rw [shift_iterate]
    exact h (i+1) (by simpa using hi)

private theorem seg_at : ∀ (n : Nat) (f : Nat → Bool) (j : Nat), j<n → (seg f n).getD j false = f j
  | 0, _, _, h => absurd h (by omega)
  | _+1, _, 0, _ => rfl
  | n+1, f, j+1, h => seg_at n (fun i => f (i+1)) j (by omega)

private theorem trap_bounds : trapCodes.all (fun n => n < 2^16) = true := by decide +kernel

private theorem from_trap {R : Nat → Bool} {t q : Nat} (h : win R t ∈ trap)
    (hq : ∀ j, j<16 → q.testBit j = drv altCol R t (j+1)) : q % 2^16 ∈ trapCodes := by
  obtain ⟨c,hc,eq⟩ := List.mem_map.mp h
  have bound : c < 2^16 := of_decide_eq_true (List.all_eq_true.mp trap_bounds c hc)
  suffices q % 2^16 = c by rwa [this]
  apply Nat.eq_of_testBit_eq
  intro j
  rw [Nat.testBit_mod_two_pow]
  by_cases hj : j < 16
  · have e := congrArg (fun L : List Bool => L.getD j false) eq
    change (seg (fun i => c.testBit i) 16).getD j false =
      (seg (fun i => drv altCol R t (0+i+1)) 16).getD j false at e
    rw [seg_at _ _ _ hj,seg_at _ _ _ hj] at e
    simpa [hj, hq j hj] using e.symm
  · have bound' : c < 2^j := Nat.lt_of_lt_of_le bound (Nat.pow_le_pow_right (by decide) (by omega))
    simp [hj,Nat.testBit_lt_two_pow bound']

private theorem prefix_bit : ∀ (n : Nat) (f : Nat → Bool) (j : Nat), j < n →
    (encList (seg f n)).testBit j = f j
  | 0, _, _, h => absurd h (by omega)
  | _+1, f, 0, _ => by
    rw [Nat.testBit_zero]
    simp only [seg, encList]
    cases f 0 <;> simp <;> omega
  | n+1, f, j+1, h => by
    rw [Nat.testBit_succ]
    change (((if f 0 then 1 else 0) + 2 * encList (seg (fun i => f (i+1)) n)) / 2).testBit j = _
    have e (a : Nat) : ((if f 0 then 1 else 0) + 2*a) / 2 = a := by cases f 0 <;> simp <;> omega
    rw [e]
    exact prefix_bit n _ j (by omega)

/-- Every proposed physical occurrence supplies one finite packed trace. -/
theorem occurrence_trace (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0+4 ≤ 2*s+1)
    (word : ∀ i, i<96 → Rule30PeriodTwoSideways.u R (s+i) = (closed 4).getD i false) :
    ∃ r, Trace r initial := by
  let b := 2*s+1-4
  have hb : b%2=1 := by dsimp [b]; omega
  have at_b := win_mem_trap R h0 hw ((b-t0)/2)
  rw [show t0+2*((b-t0)/2)=b by dsimp [b]; omega] at at_b
  let f := fun j => drv altCol R b (j+1)
  let r := encList (seg f 210)
  have agree (i j : Nat) (bound : j+2*i<210) :
      (iterate r i).testBit j = drv altCol R (b+2*i) (j+1) := by
    rw [packed_twice b r hb]
    exact cone R b r 210 (prefix_bit 210 f) _ _ bound
  refine ⟨r, from_frames initial r (fun i hi => ?_)⟩
  have il : i < 98 := by simpa only [show initial.length = 98 by decide] using hi
  have ht := from_trap (win_mem_trap R hb at_b i) (fun j hj => agree i j (by omega))
  have ic : i < colours.length := by simpa only [initial, List.length_map] using hi
  have cell : initial[i]'hi = entry (colours[i]'ic) := by simp only [initial, List.getElem_map]
  rw [cell]
  cases i with
  | zero => exact ht
  | succ i =>
    cases i with
    | zero => exact ht
    | succ i =>
      have il' : i < (closed 4).length := by rw [show (closed 4).length = 96 by decide]; omega
      have colour : colours[i+1+1] = some ((closed 4)[i]) := by
        simp [colours]
      rw [colour]
      apply List.mem_filter.mpr
      refine ⟨ht, beq_iff_eq.mpr ?_⟩
      rw [Nat.testBit_mod_two_pow]
      have w := word i (by omega)
      unfold Rule30PeriodTwoSideways.u at w
      have gate := agree (i+1+1) 0 (by omega)
      rw [show b+2*(i+1+1) = 2*(s+i)+1 by dsimp [b]; omega] at gate
      simpa [entry, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem il'] using gate.trans w

/-- Four closed runs of four 5-gaps cannot start two or more samples after trap entry. -/
theorem no_four_runs_of_four (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0+4 ≤ 2*s+1) :
    ¬ ∀ i, i<96 → Rule30PeriodTwoSideways.u R (s+i) = (closed 4).getD i false := by
  intro word
  obtain ⟨r,h⟩ := occurrence_trace R h0 hw s hs word
  exact Rule30RunPlaneChecks.no_trace r h

/-- The five-block word is excluded from the trapped tick itself. -/
theorem no_five_runs_of_four (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0 ≤ 2*s+1) :
    ¬ ∀ i, i<116 → Rule30PeriodTwoSideways.u R (s+i) = five.getD i false := by
  intro word
  have suffix : ∀ i, i<96 → five.getD (20+i) false = (closed 4).getD i false := by decide
  apply no_four_runs_of_four R h0 hw (s+20) (by omega)
  intro i hi
  rw [Nat.add_assoc, word (20+i) (by omega), suffix i hi]

end Ruliology.CellularAutomata.Rule30TrappedRuns


namespace Rule30Submission
open Ruliology.CellularAutomata
open Rule30GateTrap Rule30TrappedRuns

theorem no_four_runs_of_four (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0+4 ≤ 2*s+1) :
    ¬ ∀ i, i<96 → Rule30PeriodTwoSideways.u R (s+i) = (closed 4).getD i false :=
  Rule30TrappedRuns.no_four_runs_of_four R h0 hw s hs

theorem no_five_runs_of_four (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0 ≤ 2*s+1) :
    ¬ ∀ i, i<116 → Rule30PeriodTwoSideways.u R (s+i) = five.getD i false :=
  Rule30TrappedRuns.no_five_runs_of_four R h0 hw s hs

theorem four_one_sample :
    ∃ R, win R 1 ∈ trap ∧ ∀ i, i < (closed 4).length →
      Rule30PeriodTwoSideways.u R (1+i) = (closed 4).getD i false :=
  Rule30TrappedRuns.four_one_sample

theorem three_sixty_samples :
    ∃ R, win R 1 ∈ trap ∧ ∀ i, i < (closed 3).length →
      Rule30PeriodTwoSideways.u R (60+i) = (closed 3).getD i false :=
  Rule30TrappedRuns.three_sixty_samples

end Rule30Submission
