import ModulusSlice
import SixPhysical

namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata.Rule30Jen

def Fall (i : Int) (t : Nat) : Prop := cell t i = true ∧ cell (t+1) i = false

def Cofinal {m : Nat} (i : Int) (r : Fin m) : Prop :=
  ∀ T, ∃ t, T ≤ t ∧ t%m = r.val ∧ Fall i t

private theorem escape {m : Nat} (hm : 0 < m) (i : Int) (a : Fin 6 → Fin m)
    (good : ∀ a, (∀ j, j < 6 → a j < m) → Good 6 m a) (T : Nat) :
    ∃ (j : Fin 6) (t : Nat), T ≤ t ∧ Fall (i+j.val) t ∧ t%m ≠ (a j).val := by
  apply Classical.byContradiction
  intro no
  let S := T*m
  have Slarge : T ≤ S := by
    simpa [S] using Nat.mul_le_mul_left T (show 1 ≤ m by omega)
  let phases (j : Nat) := if hj : j < 6 then (a ⟨j,hj⟩).val else 0
  let x (t : Nat) := Six.row (S+t) i
  have run : Run 6 m phases x := by
    refine ⟨fun t => Six.row_lt _ _,fun t => ?_⟩
    have adv := Six.row_step (S+t) i
    refine ⟨mem_successors.mpr ⟨_,_,by simpa [x,Nat.add_assoc,Six.step] using adv⟩,
      (fits_iff _ _ _).mpr ?_⟩
    intro j on off
    by_cases hj : j < 6
    · rw [permit_bit, decide_eq_true_eq]
      refine ⟨hj,?_⟩
      have b : Fall (i+j) (S+t) := by
        unfold x at on off
        rw [Six.row_bit _ _ _ hj] at on off
        exact ⟨on,by simpa only [Nat.add_assoc] using off⟩
      have eq : (S+t)%m = (a ⟨j,hj⟩).val := by
        apply Classical.byContradiction
        intro neq
        exact no ⟨⟨j,hj⟩,S+t,by omega,b,neq⟩
      simpa only [S,phases,dite_eq_left hj,Nat.add_comm _ t,Nat.add_mul_mod_self_right] using eq.symm
    · have hn : (x t).testBit j = false :=
        Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (Six.row_lt _ _)
          (Nat.pow_le_pow_right (by decide : 0<2) (by omega : 6 ≤ j)))
      simp [hn] at on
  have phasesBound (j : Nat) (hj : j < 6) : phases j < m := by
    simpa only [phases,dite_eq_left hj] using (a ⟨j,hj⟩).isLt
  obtain ⟨j,N,hj,per⟩ := good phases phasesBound x run
  apply not_adjacent (i+j)
  · refine ⟨S+N,m,hm,fun t ht => ?_⟩
    have left := (pair_bits (per (t-S) (by omega))).1
    unfold x at left
    rw [Six.row_bit _ _ _ (by omega),Six.row_bit _ _ _ (by omega),
      show S+(t-S+m)=t+m by omega,show S+(t-S)=t by omega] at left
    exact left
  · refine ⟨S+N,m,hm,fun t ht => ?_⟩
    have right := (pair_bits (per (t-S) (by omega))).2
    unfold x at right
    rw [Six.row_bit _ _ _ hj,Six.row_bit _ _ _ hj,
      show S+(t-S+m)=t+m by omega,show S+(t-S)=t by omega] at right
    simpa only [Int.natCast_add,Int.natCast_one,← Int.add_assoc] using right

private theorem common_bound {k : Nat} (f : Fin k → Nat) :
    ∃ B, ∀ i, f i ≤ B := by
  induction k with
  | zero => exact ⟨0,fun i => Fin.elim0 i⟩
  | succ k ih =>
    obtain ⟨B,upper⟩ := ih (fun i => f i.succ)
    exact ⟨max (f 0) B, fun i => Fin.cases (Nat.le_max_left _ _)
      (fun j => Nat.le_trans (upper j) (Nat.le_max_right _ _)) i⟩

/-- Cofinality follows once each fixed one-phase assignment has an exception
after every starting time. The witnesses are fixed for the chosen modulus. -/
theorem two_cofinal_from_good {m : Nat} (hm : 0 < m) (i : Int)
    (good : ∀ a, (∀ j, j < 6 → a j < m) → Good 6 m a) :
    ∃ (j : Fin 6) (r q : Fin m), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q := by
  classical
  apply Classical.byContradiction
  intro no
  have single (j : Fin 6) : ∃ r : Fin m, ∀ q, q ≠ r → ¬ Cofinal (i+j.val) q := by
    by_cases h : ∃ r : Fin m, Cofinal (i+j.val) r
    · obtain ⟨r,hr⟩ := h
      exact ⟨r,fun q neq hq => no ⟨j,r,q,Ne.symm neq,hr,hq⟩⟩
    · exact ⟨⟨0,hm⟩,fun q _ hq => h ⟨q,hq⟩⟩
  let phase (j : Fin 6) := Classical.choose (single j)
  have cutoff (j : Fin 6) (q : Fin m) :
      ∃ B, ∀ t, B ≤ t → t%m=q.val → Fall (i+j.val) t → q=phase j := by
    by_cases eq : q = phase j
    · exact ⟨0,fun _ _ _ _ => eq⟩
    · have rare := Classical.choose_spec (single j) q eq
      apply Classical.byContradiction
      intro noBound
      apply rare
      intro T
      apply Classical.byContradiction
      intro absent
      exact noBound ⟨T,fun t ht htq hit => (absent ⟨t,ht,htq,hit⟩).elim⟩
  let B (j : Fin 6) (q : Fin m) := Classical.choose (cutoff j q)
  let C (j : Fin 6) := Classical.choose (common_bound (B j))
  obtain ⟨M,hm'⟩ := common_bound C
  obtain ⟨j,t,late,hit,off⟩ := escape hm i phase good M
  let q : Fin m := ⟨t%m,Nat.mod_lt t hm⟩
  have hq : B j q ≤ C j := Classical.choose_spec (common_bound (B j)) q
  have eq := Classical.choose_spec (cutoff j q) t (Nat.le_trans hq (Nat.le_trans (hm' j) late)) rfl hit
  exact off (congrArg Fin.val eq)

end PhaseFalls.Moduli
