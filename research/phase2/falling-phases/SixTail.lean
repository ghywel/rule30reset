import Ruliology.CellularAutomata.Rule30StripCertificates
import SixCheck

/-! Soundness lemmas for periodic observations of a fixed pair of sites along
a finitely ranked path. All periods here are measured in physical ticks. -/
namespace PhaseFalls
open Ruliology.CellularAutomata Rule30Jen

/-- Reading a fixed pair as functions of a common time residue would make two
adjacent singleton columns eventually periodic. -/
theorem periodic_pair_impossible (T N : Nat) (i : Int) (P : Nat)
    (left right : Nat → Bool) (pos : 0 < P)
    (reads : ∀ n, N ≤ n → cell (T+n) i = left (n%P) ∧ cell (T+n) (i+1) = right (n%P)) :
    False := by
  have equal (t : Nat) (ht : T+N ≤ t) :
      cell (t+P) i = cell t i ∧ cell (t+P) (i+1) = cell t (i+1) := by
    have a := reads (t-T) (by omega)
    have b := reads ((t-T)+P) (by omega)
    rw [show T+(t-T)=t by omega] at a
    rw [show T+(t-T+P)=t+P by omega, Nat.add_mod_right] at b
    exact ⟨b.1.trans a.1.symm,b.2.trans a.2.symm⟩
  exact not_adjacent i ⟨T+N,P,pos,fun t ht => (equal t ht).1⟩
    ⟨T+N,P,pos,fun t ht => (equal t ht).2⟩

/-- A non-increasing rank eventually becomes constant. It suffices to pin
the two outputs to phases after the rank has become constant. -/
theorem contradiction_of_flat_output (T : Nat) (rank : Nat → Nat)
    (noninc : ∀ n, rank (n+1) ≤ rank n)
    (settled : ∀ N, (∀ n, N ≤ n → rank n = rank N) →
      ∃ (i : Int) (P : Nat) (left right : Nat → Bool), 0 < P ∧
        ∀ n, N ≤ n → cell (T+n) i = left (n%P) ∧ cell (T+n) (i+1) = right (n%P)) :
    False := by
  obtain ⟨N,_,flat⟩ := Rule30StripCertificates.antitone_eventually_const rank 0
    (fun t _ => noninc t)
  obtain ⟨i,P,l,r,hp,h⟩ := settled N flat
  exact periodic_pair_impossible T N i P l r hp h

/-- At every step the rank falls or the annotation is retained. Its two
phase-indexed output bits then describe a fixed pair on the final rank. -/
theorem ranked_pair_impossible (T : Nat) (rank tag : Nat → Nat) (column : Nat → Int)
    (bit0 bit1 : Nat → Nat → Bool)
    (step_info : ∀ n, rank (n+1) < rank n ∨ (rank (n+1) = rank n ∧ tag (n+1) = tag n))
    (read : ∀ n, cell (T+n) (column (tag n)) = bit0 (tag n) ((T+n)%3) ∧
      cell (T+n) (column (tag n)+1) = bit1 (tag n) ((T+n)%3)) : False := by
  apply contradiction_of_flat_output T rank (fun n => by have := step_info n; omega)
  intro N flat
  have frozen (d : Nat) : tag (N+d) = tag N := by
    induction d with
    | zero => rfl
    | succ d ih =>
      have a := flat (N+d) (by omega)
      have b := flat (N+d+1) (by omega)
      rcases step_info (N+d) with h | h
      · omega
      · exact h.2.trans ih
  refine ⟨column (tag N),3,(fun z => bit0 (tag N) ((T+z)%3)),
    (fun z => bit1 (tag N) ((T+z)%3)),by decide,?_⟩
  intro n hn
  have h := read n
  have same := frozen (n-N)
  rw [show N+(n-N)=n by omega] at same
  rwa [same, show (T+n)%3=(T+(n%3))%3 by omega] at h

private theorem common_bound {k : Nat} (f : Fin k → Nat) :
    ∃ B, ∀ i, f i ≤ B := by
  induction k with
  | zero => exact ⟨0,fun i => Fin.elim0 i⟩
  | succ k ih =>
    obtain ⟨B,upper⟩ := ih (fun i => f i.succ)
    exact ⟨max (f 0) B, fun i => Fin.cases (Nat.le_max_left _ _)
      (fun j => Nat.le_trans (upper j) (Nat.le_max_right _ _)) i⟩

def cofinal_phase (event : Nat → Prop) (r : Fin 3) : Prop :=
  ∀ T, ∃ t, T ≤ t ∧ t%3=r.val ∧ event t

/-- If every assignment of one residue to each of a finite list of sites
eventually fails again, a single fixed site has two distinct cofinal residues. -/
theorem two_cofinal_of_no_assignment {w : Nat} (event : Fin w → Nat → Prop)
    (escapes : ∀ (assignment : Fin w → Fin 3) (T : Nat),
      ∃ (j : Fin w) (t : Nat), T ≤ t ∧ event j t ∧ t%3 ≠ (assignment j).val) :
    ∃ (j : Fin w) (r q : Fin 3), r ≠ q ∧ cofinal_phase (event j) r ∧ cofinal_phase (event j) q := by
  classical
  apply Classical.byContradiction
  intro no
  have single (j : Fin w) : ∃ r : Fin 3, ∀ q, q ≠ r → ¬ cofinal_phase (event j) q := by
    by_cases h : ∃ r, cofinal_phase (event j) r
    · obtain ⟨r,hr⟩ := h
      exact ⟨r, fun q neq hq => no ⟨j,r,q,Ne.symm neq,hr,hq⟩⟩
    · exact ⟨0, fun q _ hq => h ⟨q,hq⟩⟩
  let phase (j : Fin w) := Classical.choose (single j)
  have cutoff (j : Fin w) (q : Fin 3) :
      ∃ B, ∀ t, B ≤ t → t%3=q.val → event j t → q=phase j := by
    by_cases eq : q = phase j
    · exact ⟨0,fun _ _ _ _ => eq⟩
    · have rare := Classical.choose_spec (single j) q eq
      apply Classical.byContradiction
      intro noBound
      apply rare
      intro T
      apply Classical.byContradiction
      intro absent
      exact noBound ⟨T,fun t ht hm he => (absent ⟨t,ht,hm,he⟩).elim⟩
  let B (j : Fin w) (q : Fin 3) := Classical.choose (cutoff j q)
  let C (j : Fin w) := Classical.choose (common_bound (B j))
  obtain ⟨M,hm⟩ := common_bound C
  obtain ⟨j,t,late,hit,off⟩ := escapes phase M
  let q : Fin 3 := ⟨t%3,by omega⟩
  have hq : B j q ≤ C j := Classical.choose_spec (common_bound (B j)) q
  have eq := Classical.choose_spec (cutoff j q) t (Nat.le_trans hq (Nat.le_trans (hm j) late)) rfl hit
  exact off (congrArg Fin.val eq)
end PhaseFalls

namespace PhaseFalls.Six
open Ruliology.CellularAutomata.Rule30Jen

/-- Table entry at a physical tick in the strip starting at i. -/
def physicalEntry (a : Nat) (i : Int) (t : Nat) := entry a (t%3) (row t i)

theorem physical_read {a : Nat} (ha : a < 729) (i : Int) (t : Nat) :
    let g := tag (physicalEntry a i t)
    idx g < 5 ∧ cell t (i+(idx g : Int)) = bit0 g (t%3) ∧
      cell t (i+(idx g : Int)+1) = bit1 g (t%3) := by
  obtain ⟨hi,l,r⟩ := current ha (Nat.mod_lt t (by decide : 0<3)) (row_lt t i)
  let k := idx (tag (physicalEntry a i t))
  have hk : k < 5 := hi
  refine ⟨hi,(row_bit t i k (by omega)).symm.trans l,?_⟩
  change cell t (i+(k : Int)+1) = _
  rw [show i+(k : Int)+1=i+((k+1 : Nat):Int) by omega]
  exact (row_bit t i (k+1) (by omega)).symm.trans r

theorem physical_progress {a : Nat} (ha : a < 729) (i : Int) (t : Nat)
    (permitted : allowed a (t%3) (row t i) (row (t+1) i) = true) :
    let x := physicalEntry a i t
    let y := physicalEntry a i (t+1)
    rk y < rk x ∨ (rk y = rk x ∧ tag y = tag x) := by
  rw [row_step t i] at permitted
  have h := edge ha (Nat.mod_lt t (by decide : 0<3)) (row_lt t i)
    (cell t (i-1)) (cell t (i+6)) permitted
  simpa only [physicalEntry,row_step t i, show (t%3+1)%3=(t+1)%3 by omega] using h

/-- In six adjacent singleton columns, imposing one permitted falling residue
per site always fails again, however late the observation begins. -/
theorem assignment_escape (i : Int) (assignment : Fin 6 → Fin 3) (T : Nat) :
    ∃ (j : Fin 6) (t : Nat), T ≤ t ∧
      (cell t (i+j.val) = true ∧ cell (t+1) (i+j.val) = false) ∧ t%3 ≠ (assignment j).val := by
  apply Classical.byContradiction
  intro no
  let p (k : Nat) := if h : k < 6 then (assignment ⟨k,h⟩).val else 0
  have hp (k : Nat) (h : k < 6) : p k < 3 := by
    simp [p,h]
  let a := encode p
  have ha : a < 729 := encode_lt p hp
  let x (n : Nat) := physicalEntry a i (T+n)
  apply ranked_pair_impossible T (fun n => rk (x n)) (fun n => tag (x n))
    (fun v => i + (idx v : Int)) bit0 bit1
  · intro n
    have permitted : allowed a ((T+n)%3) (row (T+n) i) (row (T+n+1) i) = true := by
      apply allowed_succ
      intro k hk b w
      rw [encode_digit p hp k hk]
      simp [p,hk]
      apply Classical.byContradiction
      intro off
      exact no ⟨⟨k,hk⟩,T+n,by omega,⟨b,w⟩,off⟩
    simpa only [x, show T+(n+1)=T+n+1 by omega] using physical_progress ha i (T+n) permitted
  · intro n
    exact (physical_read ha i (T+n)).2

/-- Some fixed column in each six-site strip has two distinct fall phases
that recur arbitrarily late. No rate of recurrence is assumed. -/
theorem two_cofinal_in_six (i : Int) :
    ∃ (j : Fin 6) (r q : Fin 3), r ≠ q ∧
      cofinal_phase (fun t => cell t (i+j.val) = true ∧ cell (t+1) (i+j.val) = false) r ∧
      cofinal_phase (fun t => cell t (i+j.val) = true ∧ cell (t+1) (i+j.val) = false) q :=
  two_cofinal_of_no_assignment _ (assignment_escape i)

end PhaseFalls.Six
