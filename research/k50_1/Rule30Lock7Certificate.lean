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

private def verify : Certificate → Nat → Nat → Bool
  | .hit j k, m, c => checkLeaf m c j k
  | .split l r, m, c => verify l (m+1) c && verify r (m+1) (2^m+c)

/-- Bits above the supplied prefix length are ignored. -/
def accepts (tree : Certificate) (m c : Nat) : Bool := verify tree m (c%2^m)

private theorem prefix_mod (R : Nat → Bool) (m c : Nat) :
    HasPrefix m (c%2^m) R ↔ HasPrefix m c R := by
  constructor <;> intro h i hi <;> simpa [Nat.testBit_mod_two_pow,hi] using h i hi

private theorem verify_sound (tree : Certificate) {m c : Nat} (size : c<2^m)
    (pass : verify tree m c = true) : ∀ R, HasPrefix m c R → Locked R tree.deadline := by
  induction tree generalizing m c with
  | hit j k => exact fun _ h => ⟨k,leaf_sound pass h⟩
  | split l r il ir =>
    obtain ⟨left,right⟩ := Bool.and_eq_true_iff.mp pass
    apply Rule30LockCube.split_forces size
    · intro R h
      exact locked_later (Nat.le_max_left _ _) (il (by rw [Nat.pow_succ]; omega) left R h)
    · intro R h
      exact locked_later (Nat.le_max_right _ _) (ir (by rw [Nat.pow_succ]; omega) right R h)

theorem accepts_sound {tree : Certificate} {m c : Nat} (pass : accepts tree m c = true)
    {R : Nat → Bool} (pref : HasPrefix m c R) : Locked R tree.deadline :=
  verify_sound tree (Nat.mod_lt _ (Nat.two_pow_pos _)) pass R ((prefix_mod R m c).mpr pref)

/-- An accepted single leaf also identifies the phase at its specified time. -/
theorem accepted_phase {j m c : Nat} {k : Fin 7} (pass : accepts (.hit j k) m c = true)
    {R : Nat → Bool} (pref : HasPrefix m c R) :
    winW 30 R (1+2*j) ∈ cls 30 lock7Codes k.val :=
  leaf_sound pass ((prefix_mod R m c).mpr pref)

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
    exact ⟨tree,pass,bound.le⟩
  · rintro ⟨tree,pass,bound⟩ R pref
    exact locked_later bound (accepts_sound pass pref)

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

end Ruliology.CellularAutomata.Rule30Lock7Certificate
