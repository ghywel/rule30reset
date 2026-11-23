module
public import Ruliology.CellularAutomata.Rule30GateTrapWords
public import Ruliology.CellularAutomata.Rule30PeriodTwoWidth13
public import Ruliology.CellularAutomata.Rule30Prize

/-! A finite gate-only observer for the period-two trap, conditional on a
one-window soundness certificate. All starts and lengths count white samples. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelGateObserver
open Rule30GateTrap Rule30GateTrapWords Rule30PeriodTwoSideways

def forbidden : List (List Bool) :=
  [[false,false,false,false,false], [true,true], [true,false,true],
   [true,false,false,false,true], [true,false,false,true,false,false,true]]

/-- Only words wholly inside the measured block count. -/
def Clean (g : Nat → Bool) (start length : Nat) : Prop :=
  ∀ off w, w ∈ forbidden → off+w.length ≤ length → ¬Reads g (start+off) w

/-- An executable scan, including only complete forbidden words. -/
def cleanb (g : Nat → Bool) (start length : Nat) : Bool :=
  (List.range (length+1)).all fun off => forbidden.all fun w =>
    !(decide (off+w.length≤length) && (List.range w.length).all (fun j => g (start+off+j) == w.getD j false))

theorem cleanb_spec (g : Nat → Bool) (start length : Nat) :
    cleanb g start length = true ↔ Clean g start length := by
  simp only [cleanb,List.all_eq_true,List.mem_range,Bool.not_eq_true',Bool.and_eq_false_iff,
    decide_eq_false_iff_not]
  constructor
  · intro checked off w mem bound read
    rcases checked off (by omega) w mem with impossible | bad
    · exact impossible bound
    · have ok : (List.range w.length).all (fun j => g (start+off+j) == w.getD j false) = true := by
        apply List.all_eq_true.mpr
        intro j hj
        exact beq_iff_eq.mpr (read j (List.mem_range.mp hj))
      rw [ok] at bad
      contradiction
  · intro clean off _ w mem
    by_cases bound : off+w.length≤length
    · right
      cases check : (List.range w.length).all (fun j => g (start+off+j) == w.getD j false) with
      | false => rfl
      | true =>
        apply False.elim
        apply clean off w mem bound
        intro j hj
        exact beq_iff_eq.mp (List.all_eq_true.mp check j (List.mem_range.mpr hj))
    · exact Or.inl bound

def InTrap (R : Nat → Bool) (s : Nat) : Prop := win R (2*s+1) ∈ trap

private theorem none_at {R : Nat → Bool} {a s : Nat} (entry : InTrap R a) (late : a+10 ≤ s) :
    ∀ w ∈ forbidden, ¬Reads (u R) s w := by
  have two := TwoWordsOK_of_entry R (t0:=2*a+1) (by omega) entry s (by omega)
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
    rcases two.1 (read 0 (by decide)) with h | h <;>
      exact Bool.noConfusion (h.1.symm.trans (read 1 (by decide)))
  · intro read
    rcases two.1 (read 0 (by decide)) with h | h <;>
      exact Bool.noConfusion (h.2.1.symm.trans (read 2 (by decide)))
  · intro read
    rcases two.1 (read 0 (by decide)) with h | h
    · exact Bool.noConfusion (h.2.2.symm.trans (read 3 (by decide)))
    · exact Bool.noConfusion (h.2.2.2.1.symm.trans (read 4 (by decide)))
  · exact two.2.1

/-- After ten white samples all later finite windows pass, independently of size. -/
theorem clean_of_entry {R : Nat → Bool} {a s : Nat} (entry : InTrap R a)
    (late : a+10 ≤ s) (length : Nat) : Clean (u R) s length := by
  intro off w member _
  exact none_at entry (by omega : a+10 ≤ s+off) w member

/-- One externally proved soundness implication is sufficient. The input
parameter is one less than the number of observed samples. -/
def Sound (n : Nat) : Prop :=
  ∀ (R : Nat → Bool) (s : Nat), Clean (u R) s (n+1) → InTrap R (s+n)

/-- Some clean finite block iff the physical trap is entered at some sample. -/
theorem entry_iff_clean {n : Nat} (sound : Sound n) (R : Nat → Bool) :
    (∃ a, InTrap R a) ↔ ∃ s, Clean (u R) s (n+1) := by
  constructor
  · rintro ⟨a,entry⟩
    exact ⟨a+10,clean_of_entry entry (by omega) _⟩
  · rintro ⟨s,test⟩
    exact ⟨s+n,sound R s test⟩

/-- A clean-window detector can fire only after entry. It fires at least
once by endpoint a+10+n and at every later endpoint after entry at a. -/
theorem bounded_detection {n : Nat} (sound : Sound n) {R : Nat → Bool} {a : Nat}
    (entry : InTrap R a) :
    ∀ k, Clean (u R) (a+10+k) (n+1) ∧ InTrap R (a+10+k+n) := by
  intro k
  have good := clean_of_entry entry (by omega : a+10≤a+10+k) (n+1)
  exact ⟨good,sound R _ good⟩

/-- A word with an aperiodic sampled gate is the entire remaining branch of RD.
Under the one-window certificate the only question is whether some clean block
ever occurs. This statement quantifies over finite right halves. -/
theorem rd_iff_event {n : Nat} (sound : Sound n) :
    Rule30PeriodTwoWidth13.RD ↔ ∀ R : Nat → Bool, Rule30ZeroBoundary.FinSupp R →
      ¬ Rule30Jen.EventuallyPeriodic (u R) → ∃ s, Clean (u R) s (n+1) := by
  constructor
  · intro rd R finite aper
    rcases rd R finite with ⟨t,odd,inside⟩ | p
    · apply (entry_iff_clean sound R).mp
      exact ⟨t/2, by simpa only [InTrap,show 2*(t/2)+1=t by omega] using inside⟩
    · exact False.elim (aper p)
  · intro occurs R finite
    by_cases p : Rule30Jen.EventuallyPeriodic (u R)
    · exact Or.inr p
    · obtain ⟨a,hit⟩ := (entry_iff_clean sound R).mpr (occurs R finite p)
      exact Or.inl ⟨2*a+1,by omega,hit⟩

/-- Every window of an exterior trajectory contains a forbidden word. Conversely,
this property for all windows prevents entry, by eventual cleanliness. -/
theorem outside_iff_bounded_defects {n : Nat} (sound : Sound n) (R : Nat → Bool) :
    (∀ a, ¬InTrap R a) ↔ ∀ s, ∃ off w, w ∈ forbidden ∧ off+w.length ≤ n+1 ∧
      Reads (u R) (s+off) w := by
  classical
  constructor
  · intro outside s
    apply Classical.byContradiction
    intro absent
    apply outside (s+n) (sound R s ?_)
    intro off w mem bound read
    exact absent ⟨off,w,mem,bound,read⟩
  · intro defects a entry
    obtain ⟨off,w,mem,bound,reads⟩ := defects (a+10)
    exact clean_of_entry entry (by omega) (n+1) off w mem bound reads

end Ruliology.CellularAutomata.WheelGateObserver
