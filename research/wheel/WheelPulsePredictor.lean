module
public import WheelPulseReturn
public import Ruliology.CellularAutomata.Rule30SidewaysLocks

/-! After one full white-to-white update, two spatial sensors give the exact
next pulse of every right half. White ticks are physical times 2*s+1. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelPulsePredictor
open Rule30Ether Rule30GateTrap Rule30PeriodTwoSideways Rule30PeriodTwoCoupled WheelPulseReturn

private def c (t : Nat) : Bool := decide (t%2=1)

private theorem two_updates (x : Nat → Bool) :
    let y := drv c x 2
    y 1=true → gap (y 2) (y 3) (y 4) (y 5) = nearGap (y 2) (y 5) := by
  dsimp only
  simp only [drv,ite_true]
  generalize x 1=a; generalize x 2=b; generalize x 3=d; generalize x 4=e
  generalize x 5=f; generalize x 6=g; generalize x 7=h
  revert a b d e f g h
  decide +kernel

/-- Site two and site five determine the exact next gap at every pulse from
the second white reading onwards, with arbitrary initial right support. -/
theorem next_gap_from_second_white (R : Nat → Bool) (s : Nat) (late : 1≤s)
    (pulse : u R s=true) :
    GapAt R s (nearGap (drv altCol R (2*s+1) 2) (drv altCol R (2*s+1) 5)) := by
  cases s with
  | zero => omega
  | succ k =>
    rw [←show gap (drv altCol R (2*(k+1)+1) 2) (drv altCol R (2*(k+1)+1) 3)
        (drv altCol R (2*(k+1)+1) 4) (drv altCol R (2*(k+1)+1) 5) =
        nearGap (drv altCol R (2*(k+1)+1) 2) (drv altCol R (2*(k+1)+1) 5) from ?_]
    · exact next_gap R _ pulse
    · have wall : (fun t => altCol (2*k+1+t))=c := by
        funext t
        apply decide_eq_decide.mpr
        change (2*k+1+t)%2=0 ↔ t%2=1
        omega
      have eq (j : Nat) : drv altCol R (2*(k+1)+1) j =
          drv c (drv altCol R (2*k+1)) 2 j := by
        rw [show 2*(k+1)+1=2*k+1+2 by omega, drv_shift,wall]
      rw [eq,eq,eq,eq]
      apply two_updates
      exact (eq 1).symm.trans pulse

abbrev seed := Rule30SidewaysLocks.rh

/-- All four next gaps are attained at the same physical tick on finite
right starts. This rules out every one-bit measurement as a universal forecast. -/
theorem four_gaps_at_second_white :
    ∀ p ∈ ([(7,5),(15,4),(31,2),(39,3)] : List (Nat × Nat)), GapAt (seed p.1) 1 p.2 := by
  intro p member
  simp only [List.mem_cons,List.not_mem_nil,or_false] at member
  rcases member with rfl|rfl|rfl|rfl <;> apply next_gap_from_second_white _ 1 (by decide) <;> decide

private theorem unique_gap {R s d e} (pos : 0<d) (pos' : 0<e)
    (one : GapAt R s d) (two : GapAt R s e) : d=e := by
  by_cases smaller : d<e
  · exact False.elim (Bool.noConfusion ((two.2.1 d pos smaller).symm.trans one.2.2))
  by_cases larger : e<d
  · exact False.elim (Bool.noConfusion ((one.2.1 e pos' larger).symm.trans two.2.2))
  omega

/-- The recurring exterior two-gap is a three-site spatial event from the
second white sample: a black pulse, white site two, and black site five. -/
theorem two_gap_iff_sites (R : Nat → Bool) (s : Nat) (late : 1≤s) :
    GapAt R s 2 ↔ u R s=true ∧ drv altCol R (2*s+1) 2=false ∧
      drv altCol R (2*s+1) 5=true := by
  constructor
  · intro h
    have law := next_gap_from_second_white R s late h.1
    refine ⟨h.1,?_⟩
    have pos (a b : Bool) : 0<nearGap a b := by cases a <;> cases b <;> decide
    have eq := unique_gap (by decide : 0<2) (pos _ _) h law
    have characterize : ∀ a b : Bool, 2=nearGap a b → a=false ∧ b=true := by decide
    exact characterize _ _ eq
  · rintro ⟨black,a,b⟩
    have law := next_gap_from_second_white R s late black
    rw [a,b] at law
    exact law

/-- No Boolean measurement, even an arbitrarily chosen function of the
initial row, can encode every next return at the fixed second white tick. -/
theorem no_one_bit_forecast (read : (Nat → Bool) → Bool) (decode : Bool → Nat) :
    ¬∀ R, Rule30ZeroBoundary.FinSupp R → u R 1=true →
      0 < decode (read R) ∧ GapAt R 1 (decode (read R)) := by
  intro universal
  have predicts (a g : Nat) (mem : (a,g) ∈ ([(7,5),(15,4),(31,2),(39,3)] : List (Nat × Nat)))
      (pos : 0<g) : decode (read (seed a)) = g := by
    have observation := four_gaps_at_second_white _ mem
    obtain ⟨ok,ret⟩ := universal (seed a) (Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat _) observation.1
    exact unique_gap ok pos ret observation
  have a := predicts 7 5 (by decide) (by decide)
  have b := predicts 15 4 (by decide) (by decide)
  have d := predicts 31 2 (by decide) (by decide)
  cases ha : read (seed 7) <;> cases hb : read (seed 15) <;> cases hd : read (seed 31) <;>
    simp only [ha,hb,hd] at a b d <;> omega

/-- A finite black-first row with only site three black gives the wrong
two-sensor forecast on its first white reading. -/
theorem first_white_can_fail :
    let R := seed 4
    u R 0=true ∧ nearGap (drv altCol R 1 2) (drv altCol R 1 5)=5 ∧ GapAt R 0 3 := by
  refine ⟨by decide, by decide, ?_⟩
  exact next_gap (seed 4) 0 (by decide)

private theorem agree_positive {F : Nat → Nat → Bool} (hf : IsR30 F) (a h : Nat)
    (clock : ∀ j, j<h → F (a+j) 0 = altCol j) :
    ∀ k, k≤h → ∀ p, F (a+k) (p+1) = drv altCol (F a) k (p+1) := by
  intro k
  induction k with
  | zero => intro _ p; exact (drv_init _ _ _ (Nat.succ_pos p)).symm
  | succ k ih =>
    intro bound p
    rw [show a+(k+1)=a+k+1 by omega,hf,drv_isR30]
    have eq (q : Nat) : F (a+k) q=drv altCol (F a) k q := by
      cases q with
      | zero => exact (clock k (by omega)).trans (drv_col0 ..).symm
      | succ q => exact ih (by omega) q
    rw [eq p,eq (p+1),eq (p+2)]

/-- A black pulse at the second white tick of any finite alternating strip.
The right neighbour is white at every intervening sample and black at its
forecast return. Only the centre ticks strictly before this endpoint matter. -/
theorem finite_clock_forecast {F : Nat → Nat → Bool} (hf : IsR30 F) (a d : Nat)
    (pulse : F (a+3) 1=true) (measure : nearGap (F (a+3) 2) (F (a+3) 5)=d)
    (clock : ∀ j, j<3+2*d → F (a+j) 0=altCol j) :
    (∀ i, 0<i → i<d → F (a+3+2*i) 1=false) ∧ F (a+3+2*d) 1=true := by
  have eq := agree_positive hf a (3+2*d) clock
  have obs : u (F a) 1=true := (eq 3 (by omega) 0).symm.trans pulse
  have law := next_gap_from_second_white (F a) 1 (by decide) obs
  have code : nearGap (drv altCol (F a) 3 2) (drv altCol (F a) 3 5)=d := by
    rw [←eq 3 (by omega) 1,←eq 3 (by omega) 4,measure]
  change GapAt (F a) 1 (nearGap (drv altCol (F a) 3 2) (drv altCol (F a) 3 5)) at law
  rw [code] at law
  have bit (i : Nat) (bound : i≤d) : F (a+3+2*i) 1 = u (F a) (1+i) := by
    unfold u
    rw [show a+3+2*i=a+(2*(1+i)+1) by omega]
    exact eq _ (by omega) 0
  exact ⟨fun i pos less => (bit i (by omega)).trans (law.2.1 i pos less),
    (bit d (by omega)).trans law.2.2⟩

/-- A missed pulse deadline or a premature pulse on the genuine singleton
locates a centre discrepancy strictly before the forecast endpoint. -/
theorem singleton_clock_break (a d : Nat) (pulse : Rule30Jen.cell (a+3) 1=true)
    (measure : nearGap (Rule30Jen.cell (a+3) 2) (Rule30Jen.cell (a+3) 5)=d)
    (miss : ¬((∀ i, 0<i → i<d → Rule30Jen.cell (a+3+2*i) 1=false) ∧
      Rule30Jen.cell (a+3+2*d) 1=true)) :
    ∃ j, j<3+2*d ∧ Rule30Jen.cell (a+j) 0 ≠ altCol j := by
  classical
  apply Classical.byContradiction
  intro noBreak
  apply miss
  apply finite_clock_forecast trueRight_isR30 a d pulse measure
  intro j hj
  exact Classical.byContradiction fun mismatch => noBreak ⟨j,hj,mismatch⟩

end Ruliology.CellularAutomata.WheelPulsePredictor
