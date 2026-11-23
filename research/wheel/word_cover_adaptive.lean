module
public import word_cover_claims
public import WheelObserverCleanup

/-! The 47-reading filter with its single exception has sharp delay 52. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open Rule30GateTrap Rule30GateTrapWords Rule30PeriodTwoSideways Rule30SidewaysLocks
open WheelGateObserver WheelObserverCleanup

/-- The 47-sample filter reports a positive reading only for a full clean window
which differs from the exceptional word. -/
def AdaptiveAt (R : Nat → Bool) (t : Nat) : Prop :=
  ∃ s, t=s+46 ∧ Clean (u R) s 47 ∧ ¬Reads (u R) s exceptional

private theorem previous_passes {R : Nat → Bool} {a : Nat} (entry : InTrap R a)
    (ex : Reads (u R) (a+6) exceptional) :
    Clean (u R) (a+5) 47 ∧ ¬Reads (u R) (a+5) exceptional := by
  have white (i : Nat) (hi : i<4) : u R (a+6+i)=false :=
    (ex i (by change i<47; omega)).trans
      ((by decide +kernel : ∀ j : Fin 4, exceptional.getD j.val false = false) ⟨i,hi⟩)
  have blk : u R (a+5)=true := by
    rcases u_black_within_five_of_entry R (t0:=2*a+1) (by omega) entry (a+5) (by omega)
        with h|h|h|h|h
    · exact h
    · exact False.elim (Bool.noConfusion (h.symm.trans (white 0 (by decide))))
    · exact False.elim (Bool.noConfusion (h.symm.trans (white 1 (by decide))))
    · exact False.elim (Bool.noConfusion (h.symm.trans (white 2 (by decide))))
    · exact False.elim (Bool.noConfusion (h.symm.trans (white 3 (by decide))))
  refine ⟨?_, fun observed => Bool.noConfusion (blk.symm.trans (observed 0 (by decide)))⟩
  intro off w mem _ read
  cases off with
  | succ j =>
    have clean := clean_after_six entry (by omega : a+6≤a+5+(j+1)) w.length
    exact clean 0 w mem (by omega) read
  | zero =>
    simp only [forbidden,List.mem_cons,List.not_mem_nil,or_false] at mem
    rcases mem with rfl|rfl|rfl|rfl|rfl
    · exact Bool.noConfusion (blk.symm.trans (read 0 (by decide)))
    · exact Bool.noConfusion ((white 0 (by decide)).symm.trans (read 1 (by decide)))
    · exact Bool.noConfusion ((white 1 (by decide)).symm.trans (read 2 (by decide)))
    · exact Bool.noConfusion ((white 3 (by decide)).symm.trans (read 4 (by decide)))
    · exact Bool.noConfusion ((white 2 (by decide)).symm.trans (read 3 (by decide)))

/-- At least one of the two full windows ending 51 and 52 intervals after
entry certifies membership, when observations begin at entry. -/
theorem adaptive_by_52 {R : Nat → Bool} {a : Nat} (entry : InTrap R a) :
    AdaptiveAt R (a+51) ∨ AdaptiveAt R (a+52) := by
  by_cases ex : Reads (u R) (a+6) exceptional
  · exact Or.inl ⟨a+5,by omega,previous_passes entry ex⟩
  · exact Or.inr ⟨a+6,by omega,clean_after_six entry (by omega) 47,ex⟩

/-- The same black-first finite seed that attains the six-sample cleanup
deadline attains 52 for the 47-sample filter. -/
theorem adaptive_first_52 :
    let R := rh 0x7fffff80fc
    Rule30ZeroBoundary.FinSupp R ∧ InTrap R 0 ∧ AdaptiveAt R 52 ∧
      ∀ t, t<52 → ¬AdaptiveAt R t := by
  let x := 0x7fffff80fc
  let R := rh x
  have hit : InTrap R 0 := by
    change winW 16 R 1 ∈ trap
    rw [winW_prefix (rh_prefix x 17)]
    decide +kernel
  have factor : Reads (u R) 5 (gapWord [3,3]) := by
    intro j hj
    change j<7 at hj
    change Rule30Ether.drv Rule30PeriodTwoCoupled.altCol (rh x) (2*(5+j)+1) 1 = _
    rw [WheelObserverLowerBound.physical x _ 0]
    exact (by decide +kernel : ∀ k : Fin 7,
      (WheelObserverLowerBound.packed 0x7fffff80fc (2*(5+k.val)+1)).testBit 0 =
        (gapWord [3,3]).getD k.val false) ⟨j,hj⟩
  have early (t : Nat) (ht : t<52) : ¬AdaptiveAt R t := by
    rintro ⟨s,rfl,clean,_⟩
    have bad := clean (5-s) (gapWord [3,3]) (by decide) (by change 5-s+7≤47;omega)
    exact bad (by simpa only [show s+(5-s)=5 by omega] using factor)
  rcases adaptive_by_52 hit with first|second
  · exact False.elim (early 51 (by decide) first)
  · exact ⟨Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat x,hit,second,early⟩

/-- Exactly the uniform deadlines for a complete 47-sample observation taken after entry. -/
theorem uniform_adaptive_delay_iff (d : Nat) :
    (∀ (R : Nat → Bool) (a : Nat), InTrap R a →
      ∃ t, a+46≤t ∧ t≤a+d ∧ AdaptiveAt R t) ↔ 52≤d := by
  constructor
  · intro universal
    obtain ⟨_,entry,_,earlier⟩ := adaptive_first_52
    obtain ⟨t,_,bound,hit⟩ := universal _ 0 entry
    have lower : ¬t<52 := fun h => earlier t h hit
    omega
  · intro bound R a entry
    rcases adaptive_by_52 entry with hit|hit
    · exact ⟨a+51,by omega,by omega,hit⟩
    · exact ⟨a+52,by omega,by omega,hit⟩
end Ruliology.CellularAutomata.WordCover
