module

public import Ruliology.CellularAutomata.Rule30GateTrap

/-! Window refinements for a finite sequence of Rule 30 double steps. -/

@[expose] public section
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

def verifies (ds : List Window) (p : Pass) : Bool :=
  match liftAt p.grow ds with
  | [] => false
  | a :: rest => fChain a rest p.front && bChain (a :: p.front.map Mark.box) p.back

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
