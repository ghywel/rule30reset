module
public import WheelObserverLowerBound

/-! Six samples after trap entry the complete five-word filter is clean.
Only twenty width-16 states are needed for the backward layers of the last forbidden factor. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelObserverCleanup
open Rule30GateTrap Rule30GateTrapWords Rule30PeriodTwoSideways Rule30StripCertificates Rule30Ether
open Rule30PeriodTwoCoupled
open WheelGateObserver WheelObserverLowerBound

/-- Low bit first, seven successive white samples estimated with a free east bit set to zero.
All candidate labels below are separately checked across all four eastern choices. -/
private def tape (x : Nat) : Nat → Nat
  | 0 => 0
  | n+1 => x%2 + 2*tape (tick true (tick false x)) n

private def bvTick (w : BitVec 16) (wall east : Bool) : BitVec 16 :=
  ((w <<< 1) ||| (if wall then 1 else 0)) ^^^
  (w ||| (w >>> 1) ||| (if east then 0x8000 else 0))

private def bvStep (w : BitVec 16) (x y : Bool) := bvTick (bvTick w false x) true y
private def unpack (w : BitVec 16) := seg w.getLsbD 16

private theorem real_step (w : BitVec 16) (x y : Bool) :
    unpack (bvStep w x y) = step2 (unpack w) x y := by
  cases x <;> cases y <;> simp [bvStep,bvTick,unpack,step2,seg,lin3,Nat.reduceAdd]

private theorem get_seg : ∀ (n : Nat) (f : Nat → Bool) (i : Nat), i<n → (seg f n).getD i false = f i
  | n+1, f, 0, _ => rfl
  | n+1, f, i+1, h => get_seg n _ i (by omega)

private theorem unpack_inj {w v : BitVec 16} (h : unpack w=unpack v) : w=v := by
  apply BitVec.eq_of_getLsbD_eq
  intro i hi
  have eq := congrArg (fun l : List Bool => l.getD i false) h
  simpa only [unpack,get_seg 16 _ i hi] using eq

private def tag (w : BitVec 16) : Nat :=
  let x := w.toNat
  let y := tape x 7
  let bitAt (test : Bool) (j : Nat) := test.toNat <<< j
  bitAt (x==49415) 1 ||| bitAt ([13534,46302].contains x) 2 |||
    bitAt ([20836,53604,61796].contains x) 3 ||| bitAt ([10690,18882,43458,51650].contains x) 4 |||
    bitAt ([952,9144,33720,41912].contains x) 5 ||| bitAt (y%128==73) 6 |||
    bitAt (y%64==36) 7 ||| bitAt (y%32==18) 8 ||| bitAt (y%16==9) 9 |||
    bitAt (y%8==4) 10 ||| bitAt (y%4==2) 11 ||| bitAt (y%2==1) 12

private def needed (b : Bool) : Nat := if b then 0x127f else 0xdbf

private def closed (w v : BitVec 16) : Bool :=
  let need := (tag v >>> 1) &&& needed (w.getLsbD 0)
  (need ||| tag w) == tag w

private def valid (w : BitVec 16) : Bool :=
  !(tag w).testBit 0 && (!w.getLsbD 0 || (tag w).testBit 12) &&
    closed w (bvStep w false false) && closed w (bvStep w false true) &&
    closed w (bvStep w true false) && closed w (bvStep w true true)

set_option maxRecDepth 20000 in
set_option maxHeartbeats 0 in
private theorem certificate : trapCodes.all (fun c => decide (c<65536) && valid (BitVec.ofNat 16 c)) = true := by decide +kernel

private theorem representation {l : List Bool} (mem : l∈trap) :
    ∃ w : BitVec 16, unpack w=l ∧ valid w=true := by
  obtain ⟨c,hc,rfl⟩ := List.mem_map.mp mem
  have both := List.all_eq_true.mp certificate c hc
  simp only [Bool.and_eq_true,decide_eq_true_eq] at both
  have small : c<65536 := both.1
  refine ⟨BitVec.ofNat 16 c, ?_, both.2⟩
  change decode ((BitVec.ofNat 16 c).toNat)=decode c
  simp [BitVec.toNat_ofNat, Nat.mod_eq_of_lt small]

private theorem facts {w : BitVec 16} (ok : valid w=true) :
    (tag w).testBit 0=false ∧ (w.getLsbD 0=true → (tag w).testBit 12=true) ∧
    ∀ x y, closed w (bvStep w x y)=true := by
  simp only [valid,Bool.and_eq_true,Bool.not_eq_true',Bool.or_eq_true] at ok
  obtain ⟨⟨⟨⟨⟨start,last⟩,a⟩,b⟩,c⟩,d⟩ := ok
  refine ⟨start,fun h => ?_,?_⟩
  · rcases last with no | yes
    · exact Bool.noConfusion (h.symm.trans no)
    · exact yes
  · intro x y
    cases x <;> cases y <;> assumption

private theorem clear {w v : BitVec 16} {j : Nat} (h : closed w v=true)
    (off : (tag w).testBit j=false) (matchBit : (needed (w.getLsbD 0)).testBit j=true) :
    (tag v).testBit (j+1)=false := by
  have eq := congrArg (fun n : Nat => n.testBit j) (beq_iff_eq.mp h)
  change (((tag v >>> 1) &&& needed (w.getLsbD 0)) ||| tag w).testBit j = (tag w).testBit j at eq
  simpa only [Nat.testBit_or,Nat.testBit_and,Nat.testBit_shiftRight,off,matchBit,Bool.and_true,
    Bool.or_false,Nat.add_comm 1 j] using eq

theorem no_33_after_six {R : Nat → Bool} {a s : Nat} (entry : InTrap R a) (late : a+6≤s) :
    ¬Reads (u R) s (gapWord [3,3]) := by
  intro read
  let b := s-6
  let window := fun j => win R (2*(b+j)+1)
  have mem (j : Nat) : window j ∈ trap := by
    have e := win_mem_trap R (t0:=2*a+1) (by omega) entry (b+j-a)
    simpa only [window,show 2*a+1+2*(b+j-a)=2*(b+j)+1 by dsimp [b]; omega] using e
  let v (j : Nat) := (representation (mem j)).choose
  have rep (j : Nat) : unpack (v j)=window j := (representation (mem j)).choose_spec.1
  have ok (j : Nat) : valid (v j)=true := (representation (mem j)).choose_spec.2
  have head (j : Nat) : (v j).getLsbD 0 = u R (b+j) := by
    have e := congrArg (fun l : List Bool => l.headD false) (rep j)
    exact e.trans (win_head R _)
  have blank (j : Nat) (bound : j≤12) : (tag (v j)).testBit j=false := by
    induction j with
    | zero => exact (facts (ok 0)).1
    | succ j ih =>
      obtain ⟨x,y,h⟩ := win_step2 R (2*(b+j)+1) (by omega)
      have transition : v (j+1) = bvStep (v j) x y := by
        apply unpack_inj
        rw [real_step,rep,rep]
        simpa only [window,show 2*(b+(j+1))+1=2*(b+j)+1+2 by omega] using h
      apply clear (w:=v j) (by rw [transition]; exact (facts (ok j)).2.2 x y) (ih (by omega))
      by_cases early : j<6
      · exact (by decide +kernel : ∀ z : Bool, ∀ i : Fin 6, (needed z).testBit i.val=true) _ ⟨j,early⟩
      · let i := j-6
        have len : i < (gapWord [3,3]).length := by change i<7; dsimp [i]; omega
        have val := read i len
        rw [head, show b+j=s+i by dsimp [b,i];omega,val]
        have it : i<6 := by dsimp [i];omega
        have kt := (by decide +kernel : ∀ k : Fin 6,
          (needed ((gapWord [3,3]).getD k.val false)).testBit (6+k.val)=true) ⟨i,it⟩
        simpa only [show 6+i=j by dsimp [i];omega] using kt
  have last := read 6 (by decide)
  have lastbit : (v 12).getLsbD 0 = true := by
    rw [head,show b+12=s+6 by dsimp [b];omega]
    exact last
  exact Bool.noConfusion ((blank 12 (by decide)).symm.trans ((facts (ok 12)).2.1 lastbit))

private theorem none_at_six {R : Nat → Bool} {a s : Nat} (entry : InTrap R a) (late : a+6 ≤ s) :
    ∀ w ∈ forbidden, ¬Reads (u R) s w := by
  have gap := gaps_of_entry R (t0:=2*a+1) (by omega) entry s (by omega)
  have every := u_black_within_five_of_entry R (t0:=2*a+1) (by omega) entry s (by omega)
  intro w member
  simp only [forbidden,List.mem_cons,List.not_mem_nil,or_false] at member
  rcases member with rfl | rfl | rfl | rfl | rfl
  · intro read
    rcases every with h | h | h | h | h
    · exact Bool.noConfusion (h.symm.trans (read 0 (by decide)))
    · exact Bool.noConfusion (h.symm.trans (read 1 (by decide)))
    · exact Bool.noConfusion (h.symm.trans (read 2 (by decide)))
    · exact Bool.noConfusion (h.symm.trans (read 3 (by decide)))
    · exact Bool.noConfusion (h.symm.trans (read 4 (by decide)))
  · intro read
    rcases gap (read 0 (by decide)) with h | h <;>
      exact Bool.noConfusion (h.1.symm.trans (read 1 (by decide)))
  · intro read
    rcases gap (read 0 (by decide)) with h | h <;>
      exact Bool.noConfusion (h.2.1.symm.trans (read 2 (by decide)))
  · intro read
    rcases gap (read 0 (by decide)) with h | h
    · exact Bool.noConfusion (h.2.2.symm.trans (read 3 (by decide)))
    · exact Bool.noConfusion (h.2.2.2.1.symm.trans (read 4 (by decide)))
  · exact no_33_after_six entry late

/-- Starting six samples after entry, all finite windows are clean. -/
theorem clean_after_six {R : Nat → Bool} {a s : Nat} (entry : InTrap R a) (late : a+6≤s)
    (n : Nat) : Clean (u R) s n := by
  intro off w mem _
  exact none_at_six entry (by omega : a+6≤s+off) w mem

/-- The concrete finite witness enters at the first white sample. -/
private theorem sharp_seed :
    let R := Rule30SidewaysLocks.rh 0x7fffff80fc
    Rule30ZeroBoundary.FinSupp R ∧ InTrap R 0 ∧ ¬Clean (u R) 5 7 := by
  let x := 0x7fffff80fc
  let R := Rule30SidewaysLocks.rh x
  refine ⟨Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat x, ?_, ?_⟩
  · change Rule30SidewaysLocks.winW 16 R 1 ∈ trap
    rw [Rule30SidewaysLocks.winW_prefix (Rule30SidewaysLocks.rh_prefix x 17)]
    decide +kernel
  · intro clean
    apply clean 0 (gapWord [3,3]) (by decide) (by decide)
    intro j hj
    change j<7 at hj
    change drv altCol (Rule30SidewaysLocks.rh x) (2*(5+0+j)+1) 1 = _
    rw [physical x _ 0]
    exact (by decide +kernel : ∀ k : Fin 7, (packed 0x7fffff80fc (2*(5+0+k.val)+1)).testBit 0 =
      (gapWord [3,3]).getD k.val false) ⟨j,hj⟩

theorem five_fails :
    ∃ R, Rule30ZeroBoundary.FinSupp R ∧ InTrap R 0 ∧ ¬Clean (u R) 5 7 :=
  ⟨_,sharp_seed⟩

/-- For a sound length-n+1 filter, an entry at a is detected by a+6+n. -/
theorem detect_after_six {n : Nat} (sound : Sound n) {R : Nat → Bool} {a : Nat}
    (entry : InTrap R a) (k : Nat) :
    cleanb (u R) (a+6+k) (n+1) = true ∧ InTrap R (a+6+k+n) := by
  have clean := clean_after_six entry (by omega : a+6≤a+6+k) (n+1)
  exact ⟨(cleanb_spec ..).mpr clean,sound R _ clean⟩

/-- The online filter fires at the endpoint of a complete clean 48-sample window. -/
def ConfirmsAt (R : Nat → Bool) (t : Nat) : Prop :=
  ∃ s, t=s+47 ∧ cleanb (u R) s 48=true

/-- Every entry gives a confirmation at offset 53 and at each later endpoint. -/
theorem confirms_after_53 {R : Nat → Bool} {a : Nat} (entry : InTrap R a) (k : Nat) :
    ConfirmsAt R (a+53+k) :=
  ⟨a+6+k,by omega,(cleanb_spec ..).mpr (clean_after_six entry (by omega) 48)⟩

/-- The finite offset-five witness enters at zero and has its first confirmation
at sample 53. All earlier complete windows include samples 5 through 11. -/
theorem first_confirmation_53 :
    let R := Rule30SidewaysLocks.rh 0x7fffff80fc
    Rule30ZeroBoundary.FinSupp R ∧ InTrap R 0 ∧
      ConfirmsAt R 53 ∧ ∀ t, t<53 → ¬ConfirmsAt R t := by
  obtain ⟨finite,entry,dirty⟩ := sharp_seed
  refine ⟨finite,entry,confirms_after_53 entry 0,?_⟩
  rintro t early ⟨s,rfl,pass⟩
  have clean := (cleanb_spec ..).mp pass
  apply dirty
  intro off w mem bound
  have excluded := clean (5-s+off) w mem (by omega)
  simpa only [show s+(5-s+off)=5+off by omega] using excluded

/-- Exactly the uniform response deadlines for the 48-sample, five-word filter,
with all 48 observations taken at or after entry. The lower bound is attained
on a finite row entering at sample zero. -/
theorem uniform_confirmation_delay_iff (d : Nat) :
    (∀ (R : Nat → Bool) (a : Nat), InTrap R a →
      ∃ t, a+47≤t ∧ t≤a+d ∧ ConfirmsAt R t) ↔ 53≤d := by
  constructor
  · intro uniform
    obtain ⟨_,entry,_,earlier⟩ := first_confirmation_53
    obtain ⟨t,_,deadline,pass⟩ := uniform _ 0 entry
    have lower : ¬t<53 := fun early => earlier t early pass
    omega
  · intro enough R a entry
    exact ⟨a+53,by omega,by omega,confirms_after_53 entry 0⟩

end Ruliology.CellularAutomata.WheelObserverCleanup
