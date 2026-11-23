module
public import Ruliology.CellularAutomata.Rule30Prize
public import Ruliology.CellularAutomata.Rule30GateTrap

/-! The gate observer's onset and lower bounds at the public verifier pin.
The gate and closed 829-window trap are the kit's. The short prefix congruence
is adapted from Rule30SidewaysLocks.seg_congr, which appeared after that pin. -/
@[expose] public section
namespace Rule30Submission
open Ruliology.CellularAutomata
open Rule30GateTrap Rule30Ether Rule30PeriodTwoCoupled Rule30PeriodTwoSideways Rule30StripCertificates Rule30Jen

def InTrap (R : Nat → Bool) (s : Nat) : Prop := win R (2*s+1) ∈ trap
abbrev rh := Rule30ZeroBoundary.IntegerForm.rowOfNat

private theorem seg_congr : ∀ (m : Nat) {f g : Nat → Bool}, (∀ i, i < m → f i = g i) → seg f m = seg g m
  | 0, _, _, _ => rfl
  | m + 1, f, g, h => by
    show f 0 :: seg (fun i => f (i + 1)) m = g 0 :: seg (fun i => g (i + 1)) m
    rw [h 0 (by omega), seg_congr m (fun i hi => h (i + 1) (by omega))]

def tick (wall : Bool) (x : Nat) : Nat :=
  (((x <<< 1) ||| wall.toNat) ^^^ (x ||| (x >>> 1)))

def packed (seed : Nat) : Nat → Nat
  | 0 => seed
  | t+1 => tick (altCol t) (packed seed t)

private theorem bit_zero (b : Bool) (x : Nat) :
    (tick b x).testBit 0 = rule b (x.testBit 0) (x.testBit 1) := by
  simp only [tick,rule,Nat.testBit_xor,Nat.testBit_or,Nat.testBit_shiftRight,Nat.testBit_shiftLeft]
  cases b <;> rfl

private theorem bit_succ (b : Bool) (x j : Nat) :
    (tick b x).testBit (j+1) = rule (x.testBit j) (x.testBit (j+1)) (x.testBit (j+2)) := by
  have low : b.toNat.testBit (j+1)=false := by
    cases b with
    | false => exact Nat.zero_testBit _
    | true => exact Bool.eq_false_iff.mpr (fun h => by have := Nat.testBit_one_eq_true_iff_self_eq_zero.mp h; omega)
  simp only [tick,rule,Nat.testBit_xor,Nat.testBit_or,Nat.testBit_shiftRight,Nat.testBit_shiftLeft,
    low, show j+1≥1 by omega, decide_true, Bool.true_and, Nat.add_one_sub_one, Bool.or_false,
    show 1+(j+1)=j+2 by omega]

theorem physical (x t p : Nat) : drv altCol (rh x) t (p+1) = (packed x t).testBit p := by
  induction t generalizing p with
  | zero => exact drv_init _ _ _ (by omega)
  | succ t ih =>
    cases p with
    | zero =>
      rw [drv_isR30, drv_col0, ih 0, ih 1]
      exact (bit_zero _ _).symm
    | succ p =>
      rw [drv_isR30, ih p, ih (p+1), ih (p+2)]
      exact (bit_succ _ _ _).symm

def outerSeed : Nat := 0xa224d3200017fb5ccd115f23a59
def innerSeed : Nat := 0x4319fc9fcd612848b70077729985e4b9

def reading (R : Nat → Bool) (s : Nat) (j : Fin 47) : Bool := u R (s+j.val)

theorem same_reading : reading (rh outerSeed) 0 = reading (rh innerSeed) 10 := by
  funext j
  change drv altCol (rh outerSeed) (2*(0+j.val)+1) 1 = drv altCol (rh innerSeed) (2*(10+j.val)+1) 1
  rw [physical outerSeed _ 0,physical innerSeed _ 0]
  exact (by decide +kernel : ∀ i : Fin 47, (packed outerSeed (2*(0+i.val)+1)).testBit 0 =
    (packed innerSeed (2*(10+i.val)+1)).testBit 0) j

private theorem window (x t : Nat) :
    win (rh x) t = Rule30GateTrap.decode (packed x t) := by
  unfold win rowOf Rule30GateTrap.decode
  apply seg_congr 16
  intro i hi
  simp only [Nat.zero_add]
  exact physical x t i

theorem physical_labels :
    ¬InTrap (rh outerSeed) 46 ∧ InTrap (rh innerSeed) 0 ∧ InTrap (rh innerSeed) 56 := by
  have inside : InTrap (rh innerSeed) 0 := by
    unfold InTrap
    rw [window]
    decide +kernel
  refine ⟨?_,inside,?_⟩
  · unfold InTrap
    rw [window]
    decide +kernel
  · exact win_mem_trap (rh innerSeed) (t0:=1) (by decide) inside 56

/-- No function of the observed 47 bits accepts every block starting ten or
more samples after entry and rejects every block whose endpoint is outside. -/
theorem no_classifier_47 :
    ¬∃ f : (Fin 47 → Bool) → Bool,
       (∀ R : Nat → Bool, Rule30ZeroBoundary.FinSupp R → ∀ s,
        ¬InTrap R (s+46) → f (reading R s) = false) ∧
       (∀ R : Nat → Bool, Rule30ZeroBoundary.FinSupp R → ∀ a s,
        InTrap R a → a+10≤s → f (reading R s) = true) := by
  rintro ⟨f,reject,accept⟩
  have a := reject (rh outerSeed) (Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat _) 0 physical_labels.1
  have b := accept (rh innerSeed) (Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat _) 0 10
    physical_labels.2.1 (by decide)
  rw [same_reading,b] at a
  contradiction

/-- The same physical pair excludes every shorter nonempty sliding-window classifier. -/
theorem no_short_classifier (n : Nat) (positive : 0<n) (width : n≤47) :
    ¬∃ f : (Fin n → Bool) → Bool,
       (∀ R : Nat → Bool, Rule30ZeroBoundary.FinSupp R → ∀ s,
        ¬InTrap R (s+n-1) → f (fun j => u R (s+j.val)) = false) ∧
       (∀ R : Nat → Bool, Rule30ZeroBoundary.FinSupp R → ∀ a s,
        InTrap R a → a+10≤s → f (fun j => u R (s+j.val)) = true) := by
  rintro ⟨f,reject,accept⟩
  let k := 47-n
  have same : (fun j : Fin n => u (rh outerSeed) (k+j.val)) =
      (fun j : Fin n => u (rh innerSeed) (10+k+j.val)) := by
    funext j
    obtain e := congrFun same_reading ⟨k+j.val,by have := j.isLt; dsimp [k]; omega⟩
    simpa only [reading,Nat.zero_add,Nat.add_assoc] using e
  have outside : ¬InTrap (rh outerSeed) (k+n-1) := by
    simpa only [show k+n-1=46 by dsimp [k]; omega] using physical_labels.1
  have a := reject (rh outerSeed) (Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat _) k outside
  have b := accept (rh innerSeed) (Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat _) 0 (10+k)
    physical_labels.2.1 (by omega)
  rw [same,b] at a
  contradiction


/-- Once a preceding white sample exists, every gate-only classifier of width at most 46 still confuses a mature positive and a negative endpoint. -/
theorem no_short_classifier_after_first (n : Nat) (positive : 0<n) (width : n≤46) :
    ¬∃ f : (Fin n → Bool) → Bool,
       (∀ R : Nat → Bool, Rule30ZeroBoundary.FinSupp R → ∀ s,
        1≤s → ¬InTrap R (s+n-1) → f (fun j => u R (s+j.val)) = false) ∧
       (∀ R : Nat → Bool, Rule30ZeroBoundary.FinSupp R → ∀ a s,
        1≤s → InTrap R a → a+10≤s → f (fun j => u R (s+j.val)) = true) := by
  rintro ⟨f,reject,accept⟩
  let k := 47-n
  have same : (fun j : Fin n => u (rh outerSeed) (k+j.val)) =
      (fun j : Fin n => u (rh innerSeed) (10+k+j.val)) := by
    funext j
    obtain e := congrFun same_reading ⟨k+j.val,by have := j.isLt; dsimp [k]; omega⟩
    simpa only [reading,Nat.zero_add,Nat.add_assoc] using e
  have outside : ¬InTrap (rh outerSeed) (k+n-1) := by
    simpa only [show k+n-1=46 by dsimp [k]; omega] using physical_labels.1
  have a := reject (rh outerSeed) (Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat _) k (by dsimp [k]; omega) outside
  have b := accept (rh innerSeed) (Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat _) 0 (10+k) (by omega)
    physical_labels.2.1 (by omega)
  rw [same,b] at a
  contradiction

private def winW (W : Nat) (R : Nat → Bool) (t : Nat) : List Bool := rowOf (drv altCol R) t 0 W

-- The prefix identity from the kit's Rule30SidewaysLocks.seg_take.
private theorem seg_take : ∀ (m n : Nat) (f : Nat → Bool), n ≤ m → (seg f m).take n = seg f n
  | _, 0, _, _ => rfl
  | 0, _ + 1, _, h => absurd h (by omega)
  | m + 1, n + 1, f, h => by
    show f 0 :: (seg (fun i => f (i + 1)) m).take n = f 0 :: seg (fun i => f (i + 1)) n
    rw [seg_take m n _ (by omega)]

private def readCell (w : List Bool) (j : Nat) : Bool :=
  (evolve 1 j (w.take (1+j))).headD false

private theorem parity_evolve (n t v : Nat) (h : t%2 = v%2) (row : List Bool) :
    evolve t n row = evolve v n row := by
  induction n generalizing t v row with
  | zero => rfl
  | succ n ih =>
    have wall : altCol t = altCol v := by simp only [altCol,h]
    simp only [evolve,wall]
    exact ih _ _ (by omega) _

private theorem read_physical (R : Nat → Bool) (s j : Nat) (hj : j ≤ 4) :
    readCell (winW 9 R (2*s+1)) (2*j) = u R (s+j) := by
  unfold readCell winW u
  have sub : (rowOf (drv altCol R) (2*s+1) 0 9).take (1+2*j) =
      rowOf (drv altCol R) (2*s+1) 0 (1+2*j) :=
    seg_take 9 (1+2*j) _ (by omega)
  rw [sub, parity_evolve (2*j) 1 (2*s+1) (by omega), ← rowOf_evolve R (2*j) (2*s+1) 1,
      show 2*(s+j)+1=2*s+1+2*j by omega]
  rfl

private theorem every_five_diagrams :
    (Rule30Jen.allLists 9).all (fun w => (List.range 5).any (fun j => readCell w (2*j))) = true := by
  decide +kernel

/-- For an arbitrary driven right half, one of every five gate samples is black,
including a block that starts at the very first white sample. -/
theorem black_in_every_five (R : Nat → Bool) (s : Nat) :
    ∃ j, j<5 ∧ u R (s+j) = true := by
  let w := winW 9 R (2*s+1)
  have len : w.length = 9 := length_seg 9 (fun i => drv altCol R (2*s+1) (0+i+1))
  have mem : w ∈ Rule30Jen.allLists 9 := len ▸ Rule30Jen.mem_allLists w
  obtain ⟨j, member, hit⟩ := List.any_eq_true.mp (List.all_eq_true.mp every_five_diagrams w mem)
  have small := List.mem_range.mp member
  exact ⟨j,small,(read_physical R s j (by omega)).symm.trans hit⟩

end Rule30Submission
