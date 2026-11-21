module

public import Ruliology.CellularAutomata.Rule30Blocks
public import Rule30Lock7Compactness
public import Rule30MaskTransversals

/-! Permanent counterexamples to recognising the seven-lock at the age-364
singleton start from too few observations. Site 1 is the nearest positive cell.
Each finite witness changes the actual right half at precisely its stated sites.
The final lower bound applies even if the observer can look arbitrarily far to the right. -/

@[expose] public section
namespace Ruliology.CellularAutomata.Rule30Age364Observations

namespace Packed

open Ruliology.CellularAutomata Rule30SidewaysLocks Rule30StripCertificates
open Rule30GateTrap Rule30PeriodTwoSideways Rule30Ether Rule30PeriodTwoCoupled Rule30Jen
open Rule30ZeroBoundary.IntegerForm

set_option maxRecDepth 65536
set_option maxHeartbeats 8000000

/-- All positive cells packed in a natural number, bit 0 at site 1. The centre is prescribed. -/
def rightStep (b : Bool) (x : Nat) : Nat := (2*x+b.toNat) ^^^ (x ||| (x >>> 1))
def rightRow (seed : Nat) : Nat → Nat
  | 0 => seed
  | t+1 => rightStep (altCol t) (rightRow seed t)

theorem drv_rightRow (seed t i : Nat) :
    drv altCol (rh seed) t (i+1)=(rightRow seed t).testBit i := by
  induction t generalizing i with
  | zero => rfl
  | succ t ih =>
    rw [drv_isR30]
    cases i with
    | zero =>
      rw [drv_col0,ih 0,ih 1]
      rw [show rightRow seed (t+1)=rightStep (altCol t) (rightRow seed t) by rfl]
      unfold rightStep
      rw [Nat.testBit_xor,Nat.testBit_or,Nat.testBit_shiftRight,
        testBit_two_mul_add_zero _ _ (by cases altCol t <;> decide)]
      cases h : altCol t <;> simp [rule]
    | succ i =>
      rw [ih i,ih (i+1),ih (i+2)]
      rw [show rightRow seed (t+1)=rightStep (altCol t) (rightRow seed t) by rfl]
      unfold rightStep
      rw [Nat.testBit_xor,Nat.testBit_or,Nat.testBit_shiftRight,
        testBit_two_mul_add_succ _ _ _ (by cases altCol t <;> decide)]
      simp [rule,Nat.add_left_comm]

theorem win_rightRow (w seed t : Nat) :
    winW w (rh seed) t = decodeW w (rightRow seed t) := by
  unfold winW rowOf decodeW
  apply Rule30SidewaysLocks.seg_congr
  intro i _
  simpa using drv_rightRow seed t i

end Packed

open Ruliology.CellularAutomata BusyBeaverLifetimes Rule30SidewaysLocks Rule30GateTrap
open Rule30Lock7Compactness Rule30StripCertificates

set_option maxRecDepth 65536
set_option maxHeartbeats 16000000

/-- Bit zero is site one at the physical singleton start. -/
def actualCode := Rule30Blocks.plane 364 >>> 366

private theorem singleton_eq (t : Nat) : Rule30Jen.cell t=TwoColor.cell 30 1 t := by
  induction t with
  | zero => rfl
  | succ t ih =>
    rw [Rule30Blocks.cell_succ]
    funext j
    change Rule30Jen.rule (Rule30Jen.cell t (j-1)) (Rule30Jen.cell t j) (Rule30Jen.cell t (j+1)) = _
    rw [ih]; rfl

theorem actual_bits (i : Nat) :
    actualCode.testBit i=Rule30Jen.cell 364 ((i+1:Nat):Int) := by
  rw [singleton_eq,Rule30Blocks.cell_eq 364 ((i+1:Nat):Int) (by omega)]
  unfold actualCode
  rw [Nat.testBit_shiftRight]
  congr 1
  omega

def mask : List Nat → Nat
  | [] => 0
  | p::ps => (2^(p-1)) ||| mask ps

theorem mask_bit {ps : List Nat} (nz : 0∉ps) (i : Nat) :
    (mask ps).testBit i=decide (i+1∈ps) := by
  induction ps with
  | nil => simp [mask]
  | cons p ps ih =>
    have h : 0∉ps:=fun h => nz (List.mem_cons_of_mem _ h)
    have hp : p≠0:=fun e => nz (by simp [e])
    rw [mask,Nat.testBit_or,Nat.testBit_two_pow,ih h]
    have eq : p-1=i ↔ i+1=p := by omega
    simp [List.mem_cons,eq]

def seed (ps : List Nat) := actualCode ^^^ mask ps

/-- Pointwise on the full infinite right half, the disagreements are exactly the listed sites. -/
theorem exact_changes {ps : List Nat} (nz : 0∉ps) (i : Nat) :
    rh (seed ps) (i+1)≠Rule30Jen.cell 364 ((i+1:Nat):Int) ↔ i+1∈ps := by
  rw [rh_prefix (seed ps) (i+1) i (by omega),←actual_bits]
  unfold seed
  rw [Nat.testBit_xor,mask_bit nz]
  by_cases h : i+1∈ps <;> cases hbit : actualCode.testBit i <;> simp [h]

structure Case where
  sites : List Nat
  tick : Nat
  code : Nat
deriving DecidableEq, Repr

def cases364 : List Case := [
  ⟨[1], 43, 45975⟩,
  ⟨[2], 11, 20836⟩,
  ⟨[3], 9, 23207⟩,
  ⟨[4], 51, 48743⟩,
  ⟨[5], 35, 65000⟩,
  ⟨[6], 19, 35304⟩,
  ⟨[7], 27, 46734⟩,
  ⟨[8], 37, 38871⟩,
  ⟨[9], 61, 13916⟩,
  ⟨[10], 27, 49415⟩,
  ⟨[11], 65, 54439⟩,
  ⟨[12], 77, 53340⟩,
  ⟨[13], 37, 18970⟩,
  ⟨[14], 537, 49415⟩,
  ⟨[15], 119, 30072⟩,
  ⟨[16], 495, 49415⟩,
  ⟨[17], 297, 19818⟩,
  ⟨[18], 261, 8872⟩,
  ⟨[19], 425, 49415⟩,
  ⟨[21], 103, 49415⟩,
  ⟨[22], 315, 30072⟩,
  ⟨[23], 439, 49415⟩,
  ⟨[24], 143, 48698⟩,
  ⟨[25], 479, 48698⟩,
  ⟨[26], 187, 49415⟩,
  ⟨[27], 513, 8872⟩,
  ⟨[28], 977, 41448⟩,
  ⟨[29], 807, 8872⟩,
  ⟨[30], 1153, 55066⟩,
  ⟨[31], 831, 49415⟩,
  ⟨[32], 173, 49415⟩,
  ⟨[33], 243, 49415⟩,
  ⟨[34], 667, 8872⟩,
  ⟨[35], 459, 62120⟩,
  ⟨[36], 175, 30072⟩,
  ⟨[37], 247, 8872⟩,
  ⟨[38], 229, 49415⟩,
  ⟨[39], 1083, 49415⟩,
  ⟨[40], 1057, 30072⟩,
  ⟨[42], 413, 33448⟩,
  ⟨[43], 529, 48698⟩,
  ⟨[44], 319, 41448⟩,
  ⟨[45], 1853, 49415⟩,
  ⟨[46], 979, 6506⟩,
  ⟨[47], 873, 49415⟩,
  ⟨[48], 565, 49415⟩,
  ⟨[50], 173, 49415⟩,
  ⟨[51], 481, 49415⟩,
  ⟨[54], 499, 8872⟩,
  ⟨[56], 681, 8872⟩,
  ⟨[58], 637, 30072⟩,
  ⟨[60], 721, 48698⟩,
  ⟨[61], 425, 49415⟩,
  ⟨[64, 65], 737, 8872⟩,
  ⟨[59, 68], 355, 49415⟩,
  ⟨[63, 67, 74], 875, 46684⟩,
  ⟨[57, 62, 66, 69, 70, 71, 75, 80, 81, 82, 86, 87, 88, 89, 90, 93, 96, 97, 98, 99, 100, 106, 107, 108, 109, 112, 117, 119, 120, 121, 123], 1167, 49415⟩,
  ⟨[20, 73], 493, 48698⟩,
  ⟨[41, 72], 315, 30072⟩,
  ⟨[49, 79], 861, 30072⟩,
  ⟨[52, 76], 989, 8872⟩,
  ⟨[53, 77], 1061, 8680⟩,
  ⟨[55, 85], 413, 30072⟩,
  ⟨[20, 78], 1657, 49415⟩,
  ⟨[41, 73], 709, 8872⟩,
  ⟨[49, 72], 863, 8872⟩,
  ⟨[52, 72], 343, 30072⟩,
  ⟨[53, 72], 611, 8872⟩,
  ⟨[55, 72], 681, 8872⟩,
  ⟨[59, 66], 565, 49415⟩,
  ⟨[63, 66, 68, 76], 677, 49415⟩,
  ⟨[57, 64], 385, 30072⟩,
  ⟨[57, 62, 65, 68, 70], 497, 30072⟩,
  ⟨[59, 65], 403, 41448⟩,
  ⟨[62, 64, 71], 545, 62120⟩,
  ⟨[57, 62, 65, 66, 68, 69, 71, 72, 73, 74, 75, 76, 77, 78, 84, 94, 95, 97, 101, 105, 106, 116, 117, 120, 125], 495, 49415⟩]

def checked (c : Case) : Bool := decide (0∉c.sites ∧ c.tick%2=1 ∧ c.code∈trapCodes ∧
    (Packed.rightRow (seed c.sites) c.tick)%2^16=c.code)

/-- Finite kernel certificate from the physical data. -/
theorem all_checked : cases364.length=76 ∧ cases364.Nodup ∧ cases364.all checked=true := by
  decide +kernel

private theorem decode_low (x : Nat) : decodeW 16 x=decode (x%2^16) := by
  apply Rule30SidewaysLocks.seg_congr
  intro i hi
  symm
  simpa [hi] using (Nat.testBit_mod_two_pow x 16 i)

/-- Every row reaches its reported 16-cell code at its indicated odd tick; this physical
completion never reaches any target phase at any time; and every other positive site stays fixed
in its initial condition, including infinitely many sites to the right of the finite prefix. -/
theorem all_avoiders {c : Case} (hc : c∈cases364) :
    (∀ i, rh (seed c.sites) (i+1)≠Rule30Jen.cell 364 ((i+1:Nat):Int) ↔ i+1∈c.sites) ∧
    winW 16 (rh (seed c.sites)) c.tick=decode c.code ∧
    win (rh (seed c.sites)) c.tick∈trap ∧
    ¬∃ j, Locked (rh (seed c.sites)) j := by
  have good:=List.all_eq_true.mp all_checked.2.2 c hc
  obtain ⟨nz,odd,inside,eqn⟩:=of_decide_eq_true good
  have winEq : winW 16 (rh (seed c.sites)) c.tick=decode c.code := by
    rw [Packed.win_rightRow,decode_low,eqn]
  have tr : win (rh (seed c.sites)) c.tick∈trap := by
    change winW 16 (rh (seed c.sites)) c.tick∈trap
    rw [winEq]
    exact List.mem_map_of_mem inside
  refine ⟨exact_changes nz,winEq,tr,?_⟩
  rintro ⟨j,hit⟩
  let first:=c.tick/2
  let t:=max j first
  have hj : j≤t:=Nat.le_max_left _ _
  have ht : first≤t:=Nat.le_max_right _ _
  have barred:=locked_outside_trap (locked_later hj hit)
  have h:=win_mem_trap (rh (seed c.sites)) odd tr (t-first)
  exact barred (by simpa only [show c.tick+2*(t-first)=1+2*t by dsimp [first] at *;omega] using h)

open Ruliology.CellularAutomata Rule30Lock7Compactness Rule30SidewaysLocks

/-- Fix the listed one-based positive sites of the physical singleton row, and require every
completion to enter some phase of the period-seven lock eventually. -/
def ForcesObs (a : List Nat) : Prop :=
  ∀ R : Nat → Bool, (∀ i, i+1∈a → R (i+1)=Rule30Jen.cell 364 ((i+1:Nat):Int)) →
    ∃ j, Locked R j

def witnessSupports : List (List Nat) := cases364.map Case.sites

theorem supports_distinct : witnessSupports.length=76 ∧ witnessSupports.Nodup := by decide +kernel

/-- Any such observations that force eventual entry must meet every one of the 76 change supports. -/
theorem hits_of_forcing (a : List Nat) (forces : ForcesObs a) :
    ∀ e, e∈witnessSupports → ∃ p, p∈e ∧ p∈a := by
  intro e he
  obtain ⟨c,hc,eqn⟩:=List.mem_map.mp he
  subst e
  obtain ⟨changes,_,_,avoids⟩:=all_avoiders hc
  apply Classical.byContradiction
  intro no
  apply avoids
  apply forces (rh (seed c.sites))
  intro i hi
  apply Classical.byContradiction
  intro differs
  exact no ⟨i+1,(changes i).mp differs,hi⟩

open Ruliology.CellularAutomata.Rule30MaskTransversals

theorem edge_is_witness {e : List Nat} (h : e∈edges) : e∈witnessSupports := by
  have check : edges.all (fun s=>witnessSupports.contains s)=true := by decide +kernel
  exact List.contains_iff_mem.mp (List.all_eq_true.mp check e h)

/-- Every forcing set of observations of the age-364 positive row hits the classified hypergraph. -/
theorem forces_hits_edges {a : List Nat} (h : ForcesObs a) : Hits a edges :=
  fun e he => hits_of_forcing a h e (edge_is_witness he)

/-- Noncontiguous observations may be at arbitrary positive sites. At least 63 are necessary.
The only possible forcing lists of cardinality at most 63, up to permutation, omit site 57 or 62
from the first 64 positive sites. The sufficiency of these two masks is a separate statement. -/
theorem actual_minimum_and_two_candidates (a : List Nat) (h : ForcesObs a) :
    63≤a.length ∧ (a.length≤63 → a.Perm mask57 ∨ a.Perm mask62) :=
  ⟨minimum_of_hits a (forces_hits_edges h),fun small => classification_of_hits a small (forces_hits_edges h)⟩

open Ruliology.CellularAutomata BusyBeaverLifetimes Rule30SidewaysLocks Rule30GateTrap Rule30Lock7Compactness

set_option maxRecDepth 65536
set_option maxHeartbeats 12000000

def witness : Nat := 42535295865117307456056290627475658205

/-- The singleton at age 364 has a black centre and the displayed 64 positive cells. -/
theorem actual_prefix64 : Rule30Jen.cell 364 0=true ∧
    ∀ i : Fin 64, Rule30Jen.cell 364 ((i.val+1:Nat):Int)=(11973182651807749597:Nat).testBit i.val := by
  constructor
  · rw [singleton_eq,Rule30Blocks.cell_eq 364 0 (by decide)]
    decide +kernel
  · intro i
    rw [singleton_eq,Rule30Blocks.cell_eq 364 ((i.val+1:Nat):Int) (by omega)]
    have addr : (((i.val+1 : Nat):Int)+((364:Nat):Int)+1).toNat=i.val+366 := by omega
    rw [addr]
    have tab : ∀ k : Fin 64, (Rule30Blocks.plane 364).testBit (k.val+366) =
        (11973182651807749597:Nat).testBit k.val := by decide +kernel
    exact tab i

/-- Agree on exactly the first 63 positive cells, then disagree at site 64. -/
theorem matching63 :
    (∀ i, i<63 → rh witness (i+1)=Rule30Jen.cell 364 ((i+1:Nat):Int)) ∧
    rh witness 64≠Rule30Jen.cell 364 64 := by
  constructor
  · intro i hi
    have r:= (rh_prefix witness 63) i hi
    have a:=actual_prefix64.2 ⟨i,by omega⟩
    have tab : ∀ k : Fin 63, witness.testBit k.val = (11973182651807749597:Nat).testBit k.val := by decide +kernel
    exact r.trans ((tab ⟨i,hi⟩).trans a.symm)
  · have a:=actual_prefix64.2 ⟨63,by decide⟩
    have r:=(rh_prefix witness 64) 63 (by decide)
    change Rule30Jen.cell 364 64 = (11973182651807749597:Nat).testBit 63 at a
    rw [a,r]
    decide +kernel

theorem trap_at497 : winW 16 (rh witness) 497=decode 30072 ∧ win (rh witness) 497 ∈ trap := by
  have h : winW 16 (rh witness) 497=decode 30072 := by
    rw [Packed.win_rightRow]
    decide +kernel
  refine ⟨h,?_⟩
  change winW 16 (rh witness) 497 ∈ trap
  rw [h]
  decide +kernel

/-- Tick 497 is the first odd sample in the trap, since trap membership persists. -/
theorem first_trap_entry : ∀ j, j<248 → win (rh witness) (2*j+1) ∉ trap := by
  have before : win (rh witness) 495 ∉ trap := by
    change winW 16 (rh witness) 495 ∉ trap
    rw [Packed.win_rightRow]
    decide +kernel
  intro j hj h
  have later:=win_mem_trap (rh witness) (by omega) h (247-j)
  exact before (by simpa only [show 2*j+1+2*(247-j)=495 by omega] using later)
/-- The concrete right half never enters any of the seven lock phases, even before tick 497. -/
theorem witness_never_locks : ¬ ∃ j, Locked (rh witness) j := by
  rintro ⟨j,h⟩
  let s:=max j 248
  have hj : j≤s := Nat.le_max_left _ _
  have ht : 248≤s := Nat.le_max_right _ _
  have later:=win_mem_trap (rh witness) (by decide : 497%2=1) trap_at497.2 (s-248)
  exact locked_outside_trap (locked_later hj h)
    (by simpa only [show 497+2*(s-248)=1+2*s by omega] using later)

/-- No prefix of at most 63 positive cells at this actual singleton age forces eventual lock7 entry. -/
theorem no_forcing_through63 (m : Nat) (hm : m≤63) :
    ¬ (∀ R : Nat → Bool, (∀ i, i<m → R (i+1)=Rule30Jen.cell 364 ((i+1:Nat):Int)) →
      ∃ j, Locked R j) := by
  intro every
  exact witness_never_locks (every (rh witness) (fun i hi => matching63.1 i (by omega)))

end Ruliology.CellularAutomata.Rule30Age364Observations
