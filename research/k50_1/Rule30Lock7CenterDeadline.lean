module

public import Rule30Lock7Prefixes
public import Rule30Lock7Compactness

/-!
# A deadline for the actual singleton centre

Start with the actual singleton at age A, impose a black-even alternating centre
on its positive half, and suppose that after E ticks the width-30 period-seven
lock is reached. The genuine centre differs from that proposed continuation no
later than A+2E ticks after the start. The comparison uses the ring in
Rule30Lock7Prefixes and the finite cone in the merged Rule30Realization module.
The bound applies to any start with such a lock witness.
-/

@[expose] public section
namespace Ruliology.CellularAutomata.Rule30Lock7CenterDeadline
open Rule30Realization Rule30PeriodTwoSideways Rule30PeriodTwoCoupled Rule30SidewaysLocks Rule30Lock7Prefixes
open Rule30ZeroBoundary (zrow)

/-- Finite-time reconstruction with two independent initial left halves, sharing the positive right half. -/
theorem finite_center_cone {x y : Int → Bool} (right : ∀ p, 1 ≤ p → x p = y p)
    {t d : Nat} (trace : ∀ s, s ≤ t+d → evol x s 0 = evol y s 0) :
    evol x t (-(d:Int)) = evol y t (-(d:Int)) := by
  let c := fun s => evol x s 0
  let c' := fun s => evol y s 0
  have rx := realize x c
  have ry := realize x c'
  have X : x = conf x c := unique (fun p hp => (rx.1 p hp).symm) (fun s => (rx.2 s).symm)
  have Y : y = conf x c' := unique (fun p hp => (right p hp).symm.trans (ry.1 p hp).symm) (fun s => (ry.2 s).symm)
  calc
    _ = evol (conf x c) t (-(d:Int)) := congrArg (fun z => evol z t (-(d:Int))) X
    _ = lc x c d t := by rw [evol_conf]; simp [show ¬1 ≤ -(d:Int) by omega]
    _ = lc x c' d t := lc_congr x d t (fun s hs => trace s (by omega))
    _ = evol (conf x c') t (-(d:Int)) := by rw [evol_conf]; simp [show ¬1 ≤ -(d:Int) by omega]
    _ = _ := congrArg (fun z => evol z t (-(d:Int))) Y.symm

theorem seed_restart (A t : Nat) (p : Int) : evol (Rule30Jen.cell A) t p = Rule30Jen.cell (A+t) p := by
  induction t generalizing p with
  | zero => rfl
  | succ t ih =>
    change Rule30Jen.rule _ _ _ = Rule30Jen.rule _ _ _
    rw [ih,ih,ih] <;> rfl

private theorem seed_packed (t : Nat) : Rule30Jen.cell t = BusyBeaverLifetimes.TwoColor.cell 30 1 t := by
  induction t with
  | zero => rfl
  | succ t ih =>
    rw [Rule30Blocks.cell_succ]
    funext j
    change Rule30Jen.rule (Rule30Jen.cell t (j-1)) (Rule30Jen.cell t j) (Rule30Jen.cell t (j+1)) = _
    rw [ih]
    rfl

private def edgeWord (a : Nat) : Nat := #[550,758,38,246].getD (a%4) 0

private theorem edgeWord_period (B : Nat) (h : 2 ≤ B) : Rule30Blocks.plane B % 1024 = edgeWord B := by
  have low (v : Nat) : Rule30Blocks.F v % 2^10 = Rule30Blocks.F (v%2^10) % 2^10 := by
    simp only [Rule30Blocks.F,Nat.xor_mod_two_pow,Nat.or_mod_two_pow,Nat.shiftLeft_eq,Nat.mod_mul_mod,Nat.mod_mod]
  have next : ∀ q : Fin 4, Rule30Blocks.F (edgeWord q) % 1024 = edgeWord (q.val+1) := by decide +kernel
  obtain ⟨j,rfl⟩ : ∃ j,B=2+j := ⟨B-2,by omega⟩
  induction j with
  | zero => decide +kernel
  | succ j ih =>
    change Rule30Blocks.F (Rule30Blocks.plane (2+j)) % 1024 = edgeWord (2+j+1)
    rw [low,ih (by omega)]
    have r := next ⟨(2+j)%4,by omega⟩
    simp only [edgeWord,Nat.mod_mod,Nat.mod_add_mod] at r ⊢
    exact r

private theorem true_left_edge_word {B : Nat} (hb : 9 ≤ B) (j : Fin 9) :
    Rule30Jen.cell B ((j.val : Int) - (B:Int)) = (edgeWord B).testBit (j.val+1) := by
  rw [seed_packed,Rule30Blocks.cell_eq _ _ (by omega)]
  rw [show (((j.val : Int) - (B:Int)) + (B:Int) + 1).toNat = j.val + 1 by omega]
  have e := Nat.testBit_mod_two_pow (Rule30Blocks.plane B) 10 (j.val+1)
  have hj := j.isLt
  rw [show 2^10=1024 by decide,edgeWord_period B (by omega)] at e
  simpa [show j.val+1 < 10 by omega] using e.symm

set_option maxRecDepth 8192 in
set_option maxHeartbeats 20000000 in
private theorem edge_table : ∀ e : Fin 7, ∀ a : Fin 728, ∃ j : Fin 9,
    tile (2*e.val) (728+a.val-j.val) ≠ (edgeWord a.val).testBit (j.val+1) := by decide +kernel

theorem nine_at_entry {B : Nat} (hb : 9 ≤ B) (e : Nat) :
    ∃ j : Fin 9, tile (2*e) (B-j.val) ≠ Rule30Jen.cell B ((j.val:Int)-(B:Int)) := by
  obtain ⟨j,ne⟩ := edge_table ⟨e%7,by omega⟩ ⟨B%728,by omega⟩
  refine ⟨j,?_⟩
  rw [true_left_edge_word hb]
  change tile (2*(e%7)) (728+B%728-j.val) ≠ (edgeWord (B%728)).testBit (j.val+1) at ne
  have hj:=j.isLt
  simpa only [tile,edgeWord,show 2*(e%7)%14 = 2*e%14 by omega,
    show (728+B%728-j.val)%728=(B-j.val)%728 by omega,
    show (B%728)%4=B%4 by omega] using ne

/-- Eight readings can match for an independent even age and ring phase.
No lock occurrence for the actual singleton at absolute age 12 is assumed here. -/
theorem eight_at_even_age :
    (∀ j : Fin 8, tile 2 (12-j.val) = Rule30Jen.cell 12 ((j.val:Int)-12)) ∧
    tile 2 (12-8) ≠ Rule30Jen.cell 12 ((8:Int)-12) := by
  constructor
  · intro j
    have eq := true_left_edge_word (B:=12) (by decide) (⟨j.val,by have := j.isLt; omega⟩ : Fin 9)
    change Rule30Jen.cell 12 ((j.val:Int)-12) = (edgeWord 12).testBit (j.val+1) at eq
    rw [eq]
    exact (by decide +kernel : ∀ i : Fin 8, tile 2 (12-i.val) = (edgeWord 12).testBit (i.val+1)) j
  · have eq := true_left_edge_word (B:=12) (by decide) (8 : Fin 9)
    change Rule30Jen.cell 12 ((8:Int)-12) = (edgeWord 12).testBit 9 at eq
    rw [eq]
    decide +kernel

def rightAt (A : Nat) (p : Nat) := Rule30Jen.cell A (p:Int)

theorem actual_forced_cone (A t d : Nat) (hd : 0 < d)
    (trace : ∀ s,s ≤ t+d → Rule30Jen.cell (A+s) 0 = altCol s) :
    zrow (Psi (rightAt A)) t d = Rule30Jen.cell (A+t) (-(d:Int)) := by
  let R := rightAt A
  let y := glue (Psi R) R
  have gy (q : Nat) (p : Int) := evol_glue (Psi R) R (Psi_inX R) (Psi_free R) q p
  have r : ∀ p : Int, 1 ≤ p → Rule30Jen.cell A p = y p := by
    intro p hp
    simp [y,glue,R,rightAt,show ¬p<0 by omega,show p≠0 by omega,Int.toNat_of_nonneg (by omega : 0≤p)]
  have eq := finite_center_cone (x:=Rule30Jen.cell A) (y:=y) (t:=t) (d:=d) r (fun s hs => by
    rw [seed_restart,trace s hs,gy,gluedRun_zero])
  rw [seed_restart,gy] at eq
  simpa [gluedRun,hd,R,show -(d:Int)<0 by omega] using eq.symm

private theorem short_starts : ∀ A E : Fin 9, E.val%2=1 → A.val+E.val<9 →
    ∃ h : Fin (A.val+2*E.val+1), Rule30Jen.cell (A.val+h.val) 0 ≠ altCol h.val := by decide +kernel

/-- With the actual right side at age A driven as if the centre alternated from black, entry
at relative odd time E forces a break in the actual centre by relative A+2E, i.e. absolute 2(A+E). -/
theorem actual_center_break {A s0 k : Nat} (hk : k<7)
    (entry : winW 30 (rightAt A) (2*s0+1) ∈ cls 30 lock7Codes k) :
    ∃ h ≤ A+2*(2*s0+1), Rule30Jen.cell (A+h) 0 ≠ altCol h := by
  let E := 2*s0+1
  let B := A+E
  by_cases hb : 9 ≤ B
  · obtain ⟨j,miss⟩ := nine_at_entry hb (k+1)
    have hj := j.isLt
    have ring := all_locked_tile (rightAt A) hk entry (B-j.val-1) 0
    rw [show B-j.val-1+1=B-j.val by omega,Nat.add_zero,Nat.add_zero] at ring
    simp only [Nat.add_zero] at ring
    by_cases witness : ∃ h : Fin (A+2*E+1), Rule30Jen.cell (A+h.val) 0 ≠ altCol h.val
    · obtain ⟨h,bad⟩ := witness
      exact ⟨h.val,by have := h.isLt;dsimp [E] at *; omega,bad⟩
    · exfalso
      have trace (s : Nat) (hs : s≤E+(B-j.val)) : Rule30Jen.cell (A+s) 0 = altCol s := by
        apply Decidable.byContradiction
        intro ne
        exact witness ⟨⟨s,by dsimp [B,E] at *;omega⟩,ne⟩
      have line := actual_forced_cone A E (B-j.val) (by omega) trace
      apply miss
      rw [←ring]
      rw [show (j.val:Int)-(B:Int) = -((B-j.val:Nat):Int) by omega]
      exact line
  · have hA : A<9 := by dsimp [B,E] at hb; omega
    have hE : E<9 := by dsimp [B] at hb; omega
    obtain ⟨z,bad⟩ := short_starts ⟨A,hA⟩ ⟨E,hE⟩ (by change E%2=1;dsimp [E];omega) (by change A+E<9;dsimp [B] at hb;omega)
    exact ⟨z.val,by have := z.isLt;dsimp [E] at *;omega,bad⟩

open Rule30Lock7Compactness

/-- A finite test on the positive right prefix alone bounds the first disagreement
with black-first alternation at every singleton age A exhibiting that prefix.
The bound is expressed in absolute physical ticks. -/
theorem actual_break_of_checkCover {m c J A : Nat}
    (checked : checkCover m c J = true) (pref : HasPrefix m c (rightAt A)) :
    ∃ h, A+h ≤ 2*(A+(1+2*J)) ∧ Rule30Jen.cell (A+h) 0 ≠ altCol h := by
  obtain ⟨k, entry⟩ := (checkCover_spec m c J).mp checked (rightAt A) pref
  rw [Nat.add_comm 1 (2*J)] at entry
  obtain ⟨h, bound, differs⟩ := actual_center_break k.isLt entry
  exact ⟨h, by omega, differs⟩

/-- If every completion eventually locks, one intercept K works for *all* singleton
ages with the prescribed prefix, even when entry phases vary across completions. -/
theorem uniform_actual_break {m c : Nat}
    (forces : ∀ R, HasPrefix m c R → ∃ j, Locked R j) :
    ∃ K, ∀ A, HasPrefix m c (rightAt A) →
      ∃ h, A+h ≤ 2*A+K ∧ Rule30Jen.cell (A+h) 0 ≠ altCol h := by
  obtain ⟨J, checked⟩ := (all_completions_iff_check m c).mp forces
  refine ⟨2*(1+2*J), fun A pref => ?_⟩
  obtain ⟨h, bound, differs⟩ := actual_break_of_checkCover checked pref
  exact ⟨h, by omega, differs⟩

end Ruliology.CellularAutomata.Rule30Lock7CenterDeadline
