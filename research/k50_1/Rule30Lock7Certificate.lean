module

public import Rule30Lock7Compactness
public import Rule30LockCube

/-! A finite certificate that every completion of a right prefix enters the period-seven lock.
A fork tests the next initial cell. Each leaf supplies its own entry time and lock phase.
The certificate is complete over deadlines by the compactness theorem. A positive cell at
site one is bit zero of the prefix code. The prescribed centre starts black.

The numerical example is Troy Lowry's 80-cell prefix from Rule30PrizeKit PR #378. -/
@[expose] public section

namespace Ruliology.CellularAutomata.Rule30Lock7Certificate
open Rule30Lock7Compactness Rule30SidewaysLocks

inductive Certificate where
  | hit (sample : Nat) (phase : Fin 7)
  | split (zero one : Certificate)
  deriving Repr

def Certificate.deadline : Certificate → Nat
  | .hit j _ => j
  | .split l r => max l.deadline r.deadline

/-- The time and phase written on a leaf of this tree. -/
def Certificate.hasHit (j : Nat) (k : Fin 7) : Certificate → Prop
  | .hit s p => j = s ∧ k = p
  | .split l r => l.hasHit j k ∨ r.hasHit j k

/-- A fully specified cone is evaluated directly. For a partial cone, ternary
evolution overapproximates its outputs. A lock class can contain all of them only
when it has at least as many words as there are fillings of the unknown cells. -/
def checkLeaf (m c j : Nat) (k : Fin 7) : Bool :=
  let tick := 1+2*j
  let words := cls 30 lock7Codes k.val
  if 30+tick ≤ m then
    words.contains (Rule30GateTrap.evolve 0 tick (decodeW (30+tick) c))
  else
    let cube := Rule30LockCube.run 0 tick (Rule30LockCube.input m c (30+tick))
    decide (2^(cube.count .any) ≤ words.length) &&
      (Rule30LockCube.expand cube).all words.contains

private theorem leaf_sound {m c j : Nat} {k : Fin 7} (pass : checkLeaf m c j k = true)
    {R : Nat → Bool} (pref : HasPrefix m c R) :
    winW 30 R (1+2*j) ∈ cls 30 lock7Codes k.val := by
  simp only [checkLeaf] at pass
  split at pass
  · rename_i full
    rw [winW_prefix (c := c) (fun i hi => pref i (by omega))]
    simpa using pass
  · have ok := (Bool.and_eq_true_iff.mp pass).2
    have hit := Rule30LockCube.check_sound (W := 30) (t := 1+2*j) (m := m) (c := c)
      (target := fun w => (cls 30 lock7Codes k.val).contains w) ok R pref
    simpa using hit

def verify : Certificate → Nat → Nat → Bool
  | .hit j k, m, c => checkLeaf m c j k
  | .split l r, m, c => verify l (m+1) c && verify r (m+1) (2^m+c)

/-- Bits above the supplied prefix length are ignored. -/
def accepts (tree : Certificate) (m c : Nat) : Bool := verify tree m (c%2^m)

private theorem prefix_mod (R : Nat → Bool) (m c : Nat) :
    HasPrefix m (c%2^m) R ↔ HasPrefix m c R := by
  constructor <;> intro h i hi <;> simpa [Nat.testBit_mod_two_pow,hi] using h i hi

private theorem verify_hit (tree : Certificate) {m c : Nat} (size : c<2^m)
    (pass : verify tree m c = true) : ∀ R, HasPrefix m c R → ∃ j k, tree.hasHit j k ∧
      j ≤ tree.deadline ∧ winW 30 R (1+2*j) ∈ cls 30 lock7Codes k.val := by
  induction tree generalizing m c with
  | hit j k => exact fun _ h => ⟨j,k,⟨rfl,rfl⟩,Nat.le_refl _,leaf_sound pass h⟩
  | split l r il ir =>
    obtain ⟨left,right⟩ := Bool.and_eq_true_iff.mp pass
    refine Rule30LockCube.split_forces (P := fun R => ∃ j k, (l.split r).hasHit j k ∧
      j ≤ (l.split r).deadline ∧ winW 30 R (1+2*j) ∈ cls 30 lock7Codes k.val) size ?_ ?_
    · intro R h
      obtain ⟨j,k,mark,bound,hit⟩ := il (by rw [Nat.pow_succ]; omega) left R h
      exact ⟨j,k,Or.inl mark,Nat.le_trans bound (Nat.le_max_left _ _),hit⟩
    · intro R h
      obtain ⟨j,k,mark,bound,hit⟩ := ir (by rw [Nat.pow_succ]; omega) right R h
      exact ⟨j,k,Or.inr mark,Nat.le_trans bound (Nat.le_max_right _ _),hit⟩

/-- Each completion actually reaches the time and phase on one of the leaves. -/
theorem accepts_hit {tree : Certificate} {m c : Nat} (pass : accepts tree m c = true)
    {R : Nat → Bool} (pref : HasPrefix m c R) : ∃ j k, tree.hasHit j k ∧
      j ≤ tree.deadline ∧ winW 30 R (1+2*j) ∈ cls 30 lock7Codes k.val :=
  verify_hit tree (m := m) (c := c%2^m) (Nat.mod_lt _ (Nat.two_pow_pos _))
    pass R ((prefix_mod R m c).mpr pref)

theorem accepts_sound {tree : Certificate} {m c : Nat} (pass : accepts tree m c = true)
    {R : Nat → Bool} (pref : HasPrefix m c R) : Locked R tree.deadline := by
  obtain ⟨j,k,_,bound,hit⟩ := accepts_hit pass pref
  exact locked_later bound ⟨k,hit⟩

/-- An accepted single leaf also identifies the phase at its specified time. -/
theorem accepted_phase {j m c : Nat} {k : Fin 7} (pass : accepts (.hit j k) m c = true)
    {R : Nat → Bool} (pref : HasPrefix m c R) :
    winW 30 R (1+2*j) ∈ cls 30 lock7Codes k.val :=
  leaf_sound (m := m) (c := c%2^m) (j := j) (k := k) pass ((prefix_mod R m c).mpr pref)

private theorem complete_at (j n m c : Nat) (enough : 30+(1+2*j) ≤ m+n)
    (all : ∀ R, HasPrefix m c R → Locked R j) :
    ∃ tree, verify tree m c = true ∧ tree.deadline = j := by
  induction n generalizing m c with
  | zero =>
    obtain ⟨k,hit⟩ := all (rh c) (rh_prefix c m)
    have full : 30+(1+2*j) ≤ m := by omega
    rw [winW_prefix (c := c) (rh_prefix c (30+(1+2*j)))] at hit
    exact ⟨.hit j k, by simpa [verify,checkLeaf,full] using hit, rfl⟩
  | succ n ih =>
    obtain ⟨l,pl,dl⟩ := ih (m+1) c (by omega) (fun R h => all R (fun i hi => h i (by omega)))
    obtain ⟨r,pr,dr⟩ := ih (m+1) (2^m+c) (by omega) (fun R h => all R (fun i hi => by
      simpa only [Nat.testBit_two_pow_add_gt hi] using h i (by omega)))
    exact ⟨.split l r, by simp [verify,pl,pr], by simp [Certificate.deadline,dl,dr]⟩

/-- At each proposed deadline the certificates are exact, including when the
successful phase differs from branch to branch. -/
theorem deadline_iff (m c j : Nat) :
    (∀ R, HasPrefix m c R → Locked R j) ↔
    ∃ tree, accepts tree m c = true ∧ tree.deadline ≤ j := by
  constructor
  · intro h
    obtain ⟨tree,pass,bound⟩ := complete_at j (31+2*j-m) m (c%2^m) (by omega)
      (fun R pref => h R ((prefix_mod R m c).mp pref))
    exact ⟨tree,pass,by omega⟩
  · rintro ⟨tree,pass,bound⟩ R pref
    exact locked_later bound (accepts_sound pass pref)

/-- The exhaustive I49 check and the branching certificates express the same
fixed-deadline property for every length and prefix code. -/
theorem checkCover_iff_certificate (m c j : Nat) : checkCover m c j = true ↔
    ∃ tree, accepts tree m c = true ∧ tree.deadline ≤ j :=
  (checkCover_spec m c j).trans (deadline_iff m c j)

/-- A finite certificate exists exactly for those prefixes whose every
completion eventually reaches a phase of the seven-lock. -/
theorem eventual_iff (m c : Nat) :
    (∀ R, HasPrefix m c R → ∃ j, Locked R j) ↔ ∃ tree, accepts tree m c = true := by
  rw [uniform_lock_iff]
  constructor
  · rintro ⟨j,h⟩
    obtain ⟨tree,pass,_⟩ := (deadline_iff m c j).mp h
    exact ⟨tree,pass⟩
  · rintro ⟨tree,pass⟩
    exact ⟨tree.deadline,fun _ pref => accepts_sound pass pref⟩

set_option maxRecDepth 10000
set_option maxHeartbeats 0

/-- The original prefix in #378 closes at one leaf, in phase 6 at tick 95. -/
theorem lowry_one_leaf : accepts (.hit 47 6) 80 248139127718118986536413 = true := by
  decide +kernel

/-- Naming phase 5 at the same tick fails on the very same initial data. -/
theorem lowry_wrong_phase : accepts (.hit 47 5) 80 248139127718118986536413 = false := by
  decide +kernel

section Refinement
open Rule30LockCube (Tri tor txor line run input slice known)

private def Wider (a b : Tri) : Prop := a = .any ∨ a = b
private inductive WiderRow : List Tri → List Tri → Prop where
  | nil : WiderRow [] []
  | cons {a b u v} (head : Wider a b) (tail : WiderRow u v) : WiderRow (a::u) (b::v)

private theorem tor_wider {a b x y : Tri} (h : Wider a x) (g : Wider b y) :
    Wider (tor a b) (tor x y) := by
  cases a <;> cases b <;> cases x <;> cases y <;> simp_all [Wider,tor]

private theorem txor_wider {a b x y : Tri} (h : Wider a x) (g : Wider b y) :
    Wider (txor a b) (txor x y) := by
  cases a <;> cases b <;> cases x <;> cases y <;> simp_all [Wider,txor]

private theorem line_wider : ∀ {u v}, WiderRow u v → WiderRow (line u) (line v)
  | [], _, .nil => .nil
  | [_], _, .cons _ .nil => .nil
  | [_,_], _, .cons _ (.cons _ .nil) => .nil
  | _::_::_::_, _, .cons ha (.cons hb (.cons hc tail)) =>
    .cons (txor_wider ha (tor_wider hb hc)) (line_wider (.cons hb (.cons hc tail)))

private theorem run_wider (t n : Nat) {u v} (h : WiderRow u v) : WiderRow (run t n u) (run t n v) := by
  induction n generalizing u v t with
  | zero => exact h
  | succ n ih => exact ih (t+1) (line_wider (.cons (Or.inr rfl) h))

private theorem slice_wider (n : Nat) (f g : Nat → Tri) (h : ∀ i, i<n → Wider (f i) (g i)) :
    WiderRow (slice f n) (slice g n) := by
  induction n generalizing f g with
  | zero => exact .nil
  | succ n ih => exact .cons (h 0 (by omega)) (ih _ _ (fun i hi => h (i+1) (by omega)))

private theorem count_wider {u v} (h : WiderRow u v) : v.count .any ≤ u.count .any := by
  induction h with
  | nil => exact Nat.le_refl _
  | @cons a b u v head _ ih =>
    rcases head with rfl | rfl
    · cases b <;> simp_all <;> omega
    · cases a <;> simp_all <;> omega

/-- Fixing more cells of the same prefix can only reduce the output unknowns. -/
theorem unknown_count_mono {m n : Nat} (more : m ≤ n) (c width ticks : Nat) :
    (run 0 ticks (input n c width)).count .any ≤
      (run 0 ticks (input m (c%2^m) width)).count .any := by
  apply count_wider
  apply run_wider
  apply slice_wider
  intro i _
  by_cases hi : i<m
  · exact Or.inr (by simp [hi,show i<n by omega,Nat.testBit_mod_two_pow])
  · exact Or.inl (by simp [hi])

/-- At 79 cells four output bits are still unknown. Every shorter prefix has
at least those four degrees of freedom in this ternary approximation. -/
theorem lowry_short_leaf_fails (m : Nat) (short : m < 80) :
    accepts (.hit 47 6) m 248139127718118986536413 = false := by
  let c := 248139127718118986536413
  have four : (run 0 95 (input 79 c 125)).count .any = 4 := by decide +kernel
  have bound := unknown_count_mono (n := 79) (m := m) (by omega) c 125 95
  rw [four] at bound
  have p := Nat.pow_le_pow_right (by decide : 0 < 2) bound
  have tooMany : ¬ 2^((run 0 95 (input m (c%2^m) 125)).count .any) ≤
      (cls 30 lock7Codes 6).length := by
    change ¬ _ ≤ 7
    omega
  change checkLeaf m (c%2^m) 47 6 = false
  simp only [checkLeaf,show ¬ 30+(1+2*47) ≤ m by omega, ↓reduceIte]
  change (decide (2^((run 0 95 (input m (c%2^m) 125)).count .any) ≤
    (cls 30 lock7Codes 6).length) && _) = false
  simp [tooMany]

end Refinement

theorem lowry_one_leaf_lengths (m : Nat) (bound : m ≤ 80) :
    accepts (.hit 47 6) m 248139127718118986536413 = true ↔ m = 80 := by
  constructor
  · intro pass
    by_cases eq : m = 80
    · exact eq
    · rw [lowry_short_leaf_fails m (by omega)] at pass
      contradiction
  · rintro rfl
    exact lowry_one_leaf

/-- Five next-cell splits suffice in the deepest branch. The root fixes sites 1 through 77. -/
def lowry77Tree : Certificate :=
  let h := Certificate.hit 47 6
  let pair := Certificate.split h h
  .split (.split (.split pair h) h) (.split pair (.split pair (.split pair h)))

theorem lowry_77_passes : accepts lowry77Tree 77 248139127718118986536413 = true := by
  decide +kernel

theorem lowry_77_phase {R : Nat → Bool} (pref : HasPrefix 77 248139127718118986536413 R) :
    winW 30 R 95 ∈ cls 30 lock7Codes 6 := by
  obtain ⟨j,k,mark,_,hit⟩ := accepts_hit lowry_77_passes pref
  simp [lowry77Tree,Certificate.hasHit] at mark
  obtain ⟨rfl,rfl⟩ := mark
  exact hit

/-- The earlier tick-nine family needs a split for this checker. The five
leaves carry two different local ticks and phases. -/
theorem five_leaves_at_nine :
    accepts (.hit 4 1) 31 2108003337 = false ∧
    accepts (.split (.split (.hit 3 0) (.hit 4 1))
      (.split (.split (.hit 4 1) (.hit 3 0)) (.hit 4 1))) 31 2108003337 = true := by
  decide +kernel

end Ruliology.CellularAutomata.Rule30Lock7Certificate
