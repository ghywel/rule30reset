module
public import Ruliology.CellularAutomata.Rule30Prize
public import WheelMarkerCheck
public import WheelTiles
public import Ruliology.CellularAutomata.Rule30MaskedJen

/-! A visible wheel fragment forces the hidden gate trap, also in the true singleton under a finite alternating segment. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelMarker
open Rule30GateTrap Rule30StripCertificates Rule30GateTrapWords Rule30Ether Rule30PeriodTwoCoupled

private theorem facts {w : BitVec 16} (h : validRow w = true) :
    (suffixes w).testBit 0 = false ∧
    (w.getLsbD 0 = true → (suffixes w).testBit 39 = false → w.toNat ∈ trapCodes) ∧
    ∀ x y, closedEdge w (step w x y) = true := by
  simp only [validRow, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true] at h
  obtain ⟨⟨⟨⟨⟨a,b⟩,e00⟩,e01⟩,e10⟩,e11⟩ := h
  refine ⟨a, ?_, ?_⟩
  · intro white clear
    rcases b with (h | h) | h
    · exact Bool.noConfusion (white.symm.trans h)
    · exact Bool.noConfusion (h.symm.trans clear)
    · simpa only [List.contains_iff_mem] using h
  · intro x y
    cases x <;> cases y
    · exact e00
    · exact e01
    · exact e10
    · exact e11

private theorem selector (j : Nat) (hj : j < 40) :
    (selectSamples (marker.getD j false)).testBit j = true := by
  have all : ∀ k : Fin 40, (selectSamples (marker.getD k.val false)).testBit k.val = true := by decide +kernel
  exact all ⟨j,hj⟩

private theorem advance {w v : BitVec 16} {j : Nat} (e : closedEdge w v = true)
    (seen : (selectSamples (w.getLsbD 0)).testBit j = true)
    (clear : (suffixes w).testBit j = false) : (suffixes v).testBit (j+1) = false := by
  have eq := congrArg (fun n : Nat => n.testBit j) (beq_iff_eq.mp e)
  change (((suffixes v >>> 1) &&& selectSamples (w.getLsbD 0)) ||| suffixes w).testBit j = (suffixes w).testBit j at eq
  simpa only [Nat.testBit_or, Nat.testBit_and, Nat.testBit_shiftRight,seen,clear,Bool.and_true,Bool.or_false,Nat.add_comm 1 j] using eq

private theorem enc_lt : ∀ l : List Bool, encList l < 2^l.length
  | [] => by decide
  | b::r => by
    have ih := enc_lt r
    cases b <;> simp [encList,Nat.pow_succ] <;> omega

private def pack (w : List Bool) := BitVec.ofNat 16 (encList w)

private theorem unpack_pack {w : List Bool} (hw : w.length = 16) : unpack (pack w) = w := by
  have h := enc_lt w
  rw [hw] at h
  rw [unpack_decode, pack, BitVec.toNat_ofNat, Nat.mod_eq_of_lt h, decode_encList hw]

private theorem get_seg : ∀ (n : Nat) (f : Nat → Bool) (i : Nat), i<n → (seg f n).getD i false = f i
  | n+1, f, 0, _ => rfl
  | n+1, f, i+1, h => get_seg n _ i (by omega)

private theorem unpack_inj {w v : BitVec 16} (h : unpack w = unpack v) : w = v := by
  apply BitVec.eq_of_getLsbD_eq
  intro i hi
  have eq := congrArg (fun l : List Bool => l.getD i false) h
  simpa only [unpack,get_seg 16 _ i hi] using eq

private theorem real_step {F : Nat → Nat → Bool} (hf : IsR30 F) (t : Nat)
    (h0 : F t 0 = false) (h1 : F (t+1) 0 = true) :
    rowOf F (t+2) 0 16 = step2 (rowOf F t 0 16) (F t 17) (F (t+1) 17) := by
  rw [show t+2=t+1+1 by omega,rowOf_succ hf (t+1),rowOf_succ hf t,h0,h1]
  rfl

/-- The forty observations constrain an actual Rule 30 strip, including a finite stretch
of the genuine singleton. The centre is required only for the 78 update ticks. -/
theorem marker_enters
    {F : Nat → Nat → Bool} (hf : IsR30 F) (A : Nat)
    (wall : ∀ j, j<39 → F (A+2*j) 0 = false ∧ F (A+2*j+1) 0 = true)
    (reading : ∀ j, j<40 → F (A+2*j) 1 = marker.getD j false) :
    rowOf F (A+78) 0 16 ∈ trap := by
  let state (j : Nat) := pack (rowOf F (A+2*j) 0 16)
  have rep (j : Nat) : unpack (state j) = rowOf F (A+2*j) 0 16 := unpack_pack (length_seg _ _)
  have obs (j : Nat) (hj : j<40) : (state j).getLsbD 0 = marker.getD j false := by
    have head := congrArg (fun l : List Bool => l.headD false) (rep j)
    exact head.trans (reading j hj)
  have clear (j : Nat) (hj : j<40) : (suffixes (state j)).testBit j = false := by
    induction j with
    | zero => exact (facts (valid _)).1
    | succ j ih =>
      have prev := wall j (by omega)
      let x := F (A+2*j) 17
      let y := F (A+2*j+1) 17
      have e : state (j+1) = step (state j) x y := by
        apply unpack_inj
        rw [unpack_step, rep, rep, show A+2*(j+1)=A+2*j+2 by omega]
        exact real_step hf _ prev.1 prev.2
      rw [e]
      apply advance ((facts (valid _)).2.2 x y) _ (ih (by omega))
      rw [obs j (by omega)]
      exact selector j (by omega)
  have last : (state 39).getLsbD 0 = true := obs 39 (by decide)
  have member := (facts (valid (state 39))).2.1 last (clear 39 (by decide))
  have eq := rep 39
  rw [unpack_decode] at eq
  exact eq ▸ List.mem_map_of_mem (f := decode) member

/-- White-time column-one bit at phase n of the original wheel. -/
def gateBit (n : Nat) : Bool := (0x4842108 : Nat).testBit (n%28)

private theorem alignment (p : Fin 28) : ∃ q : Fin 28, ∀ j : Fin 40,
    gateBit (p.val+q.val+j.val) = marker.getD j.val false := by
  have all : ∀ k : Fin 28, ∃ q : Fin 28, ∀ j : Fin 40,
      gateBit (k.val+q.val+j.val) = marker.getD j.val false := by decide +kernel
  exact all p

theorem trap_next {F : Nat → Nat → Bool} (hf : IsR30 F) (t : Nat)
    (h0 : F t 0 = false) (h1 : F (t+1) 0 = true) (inside : rowOf F t 0 16 ∈ trap) :
    rowOf F (t+2) 0 16 ∈ trap := by
  apply mem_of_inM (length_seg _ _)
  change inM (mask trap) (rowOf F (t+2) 0 16) = true
  rw [real_step hf t h0 h1]
  exact allSucc_spec (List.all_eq_true.mp trapClosed_ok _ inside) _ _

/-- All 28 alignments enter by the 67th white sample, using the finite centre segment alone. -/
theorem wheel_enters
    {F : Nat → Nat → Bool} (hf : IsR30 F) (A : Nat) (phase : Fin 28)
    (wall : ∀ j, j<66 → F (A+2*j) 0 = false ∧ F (A+2*j+1) 0 = true)
    (seen : ∀ j, j<67 → F (A+2*j) 1 = gateBit (phase.val+j)) :
    rowOf F (A+132) 0 16 ∈ trap := by
  obtain ⟨q,hq⟩ := alignment phase
  have hit := marker_enters hf (A+2*q.val) (fun j hj => by
    simpa only [show A+2*q.val+2*j = A+2*(q.val+j) by omega] using wall (q.val+j) (by omega))
    (fun j hj => by
      rw [show A+2*q.val+2*j = A+2*(q.val+j) by omega, seen _ (by omega), ← Nat.add_assoc]
      exact hq ⟨j,hj⟩)
  have persist (j : Nat) (hj : q.val+39+j≤66) : rowOf F (A+2*(q.val+39+j)) 0 16 ∈ trap := by
    induction j with
    | zero => simpa only [show A+2*(q.val+39+0)=A+2*q.val+78 by omega] using hit
    | succ j ih =>
      have wallj := wall (q.val+39+j) (by omega)
      rw [show A+2*(q.val+39+(j+1))=A+2*(q.val+39+j)+2 by omega]
      exact trap_next hf _ wallj.1 wallj.2 (ih (by omega))
  simpa only [show A+2*(q.val+39+(66-(q.val+39)))=A+132 by omega] using
    persist (66-(q.val+39)) (by omega)

/-- Masked Jen applied at lag 56. A genuine eventually period-two centre forces a
white-time wheel disagreement in every doubling window, whether or not a marker occurred. -/
theorem singleton_white_break {T : Nat}
    (hc : ∀ t, T ≤ t → Rule30Jen.cell (t+2) 0 = Rule30Jen.cell t 0)
    (n : Nat) (hn : T+56≤n) : ∃ s, n≤s ∧ s<2*n ∧ Rule30Jen.cell s 0 = false ∧
      Rule30Jen.cell s 1 ≠ Rule30Jen.cell (s-56) 1 := by
  have iter (k t : Nat) (ht : T≤t) : Rule30Jen.cell (t+2*k) 0 = Rule30Jen.cell t 0 := by
    induction k with
    | zero => rfl
    | succ k ih => rw [show t+2*(k+1)=t+2*k+2 by omega, hc _ (by omega), ih]
  exact Rule30MaskedJen.periodic_window (P := 56) (by decide) (iter 28) n hn

/-- The finite-centre hypothesis and the observations both refer to cells of the genuine singleton. -/
theorem singleton_wheel_enters (A : Nat) (p : Fin 28)
    (wall : ∀ j, j<66 → Rule30Jen.cell (A+2*j) 0 = false ∧ Rule30Jen.cell (A+2*j+1) 0 = true)
    (seen : ∀ j, j<67 → Rule30Jen.cell (A+2*j) 1 = gateBit (p.val+j)) :
    rowOf trueRight (A+132) 0 16 ∈ trap :=
  wheel_enters trueRight_isR30 A p wall seen

/-- The long main-wheel observation alone bars any subsequent 17-tick return to U2
as long as the alternating drive continues. -/
theorem wheel_bars_secondary (R : Nat → Bool) (A : Nat) (p : Fin 28) (white : A%2=1)
    (seen : ∀ j, j<67 → drv altCol R (A+2*j) 1 = gateBit (p.val+j))
    {t : Nat} (later : A+132≤t) (q : Fin 14) (aligned : (t+q.val)%2=1) :
    ¬ ∀ j, j<17 → drv altCol R (t+j) 1 = WheelTiles.secondary (q.val+j) := by
  have wall (j : Nat) (_ : j<66) : drv altCol R (A+2*j) 0 = false ∧
      drv altCol R (A+2*j+1) 0 = true := by
    simp only [drv_col0,altCol,show (A+2*j)%2=1 by omega,show (A+2*j+1)%2=0 by omega]
    decide
  have hit := wheel_enters (drv_isR30 altCol R) A p wall seen
  exact WheelTiles.no_seventeen_secondary R (by omega : (A+132)%2=1) hit later q aligned

end Ruliology.CellularAutomata.WheelMarker
