module
public import WheelGateObserver
public import Ruliology.CellularAutomata.Rule30Ether

/-! A single visible two-gap and the finite-right dichotomy. The assumption
on exterior paths isolates precisely what the finite recurrent-component check supplies. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelTwoGapRecurrence
open WheelGateObserver Rule30GateTrap Rule30GateTrapWords Rule30PeriodTwoSideways
open Rule30Ether Rule30PeriodTwoCoupled

def TwoAt (R : Nat → Bool) (s : Nat) : Prop := Reads (u R) s [true,false,true]
def Hit43 (R : Nat → Bool) (s : Nat) : Prop := ∃ i, i+3≤43 ∧ TwoAt R (s+i)
def Recurrent (R : Nat → Bool) : Prop := ∀ t, ∃ s, t≤s ∧ TwoAt R s
def Frequent (R : Nat → Bool) : Prop := ∃ t, ∀ s, t≤s → Hit43 R s
def Aperiodic (R : Nat → Bool) : Prop := ¬Rule30Jen.EventuallyPeriodic (u R)

/-- A finite-graph input about arbitrary right halves, including those of infinite support. -/
def ExteriorRecurrence : Prop := ∀ R, Aperiodic R → (∀ a, ¬InTrap R a) → Frequent R

private theorem reads_three (g : Nat → Bool) (s : Nat) :
    Reads g s [true,false,true] ↔ g s = true ∧ g (s+1) = false ∧ g (s+2) = true := by
  constructor
  · intro h
    exact ⟨h 0 (by decide),h 1 (by decide),h 2 (by decide)⟩
  · rintro ⟨a,b,c⟩ i hi
    have z : i=0 ∨ i=1 ∨ i=2 := by change i<3 at hi; omega
    rcases z with rfl|rfl|rfl <;> assumption

/-- A spatial four-tick forecast for the exterior two-gap. Sites are counted east from the wall. -/
theorem two_gap_iff_five_sites (R : Nat → Bool) (s : Nat) :
    let x := drv altCol R (2*s+1)
    TwoAt R s ↔ x 1=true ∧ x 2=false ∧ x 3=false ∧ (x 4=true ∨ x 5=true) := by
  let x := drv altCol R (2*s+1)
  let c := fun i : Nat => decide (i%2=1)
  have wall : (fun t => altCol (2*s+1+t))=c := by
    funext t
    apply decide_eq_decide.mpr
    change (2*s+1+t)%2=0 ↔ t%2=1
    omega
  have at_ (j : Nat) : u R (s+j) = drv c x (2*j) 1 := by
    unfold u
    rw [show 2*(s+j)+1=2*s+1+2*j by omega, drv_shift,wall]
  have local_ (r : Nat → Bool) :
      (drv c r 0 1=true ∧ drv c r 2 1=false ∧ drv c r 4 1=true) ↔
        (r 1=true ∧ r 2=false ∧ r 3=false ∧ (r 4=true ∨ r 5=true)) := by
    cases h1 : r 1 <;> cases h2 : r 2 <;> cases h3 : r 3 <;>
      cases h4 : r 4 <;> cases h5 : r 5 <;> simp [drv,c,Rule30Jen.rule,h1,h2,h3,h4,h5]
  change Reads (u R) s _ ↔ _
  rw [reads_three]
  rw [show u R s = drv c x 0 1 from at_ 0, at_ 1, at_ 2]
  exact local_ x

/-- The fifth positive site is necessary even for finite black-first starts.
The empty row and a row with just site six black agree on the four nearer
sites at their first white tick and give opposite four-tick forecasts. -/
theorem four_sites_ambiguous :
    ∃ (R S : Nat → Bool), Rule30ZeroBoundary.FinSupp R ∧ Rule30ZeroBoundary.FinSupp S ∧
      (∀ j, 1≤j → j≤4 → drv altCol R 1 j = drv altCol S 1 j) ∧
      ¬TwoAt R 0 ∧ TwoAt S 0 := by
  let empty := fun _ : Nat => false
  let one := fun j : Nat => decide (j=6)
  refine ⟨empty,one,⟨0,fun _ _ => rfl⟩,⟨6,fun j hj => by simp [one,show j≠6 by omega]⟩,?_,?_,?_⟩
  · intro j lo hi
    have : j=1 ∨ j=2 ∨ j=3 ∨ j=4 := by omega
    rcases this with rfl|rfl|rfl|rfl <;> decide
  · intro h
    have := (two_gap_iff_five_sites empty 0).mp h
    exact (by decide : ¬(drv altCol empty 1 4=true ∨ drv altCol empty 1 5=true)) this.2.2.2
  · exact (two_gap_iff_five_sites one 0).mpr (by decide)

theorem no_two_gap_of_entry {R : Nat → Bool} {a s : Nat} (entry : InTrap R a) (late : a≤s) :
    ¬TwoAt R s := by
  have g := gaps_of_entry R (t0:=2*a+1) (by omega) entry s (by omega)
  intro read
  rcases g (read 0 (by decide)) with h | h <;>
    exact Bool.noConfusion (h.2.1.symm.trans (read 2 (by decide)))

theorem recurrent_of_frequent {R} (h : Frequent R) : Recurrent R := by
  obtain ⟨a, bound⟩ := h
  intro t
  obtain ⟨i,_,hit⟩ := bound (max a t) (Nat.le_max_left ..)
  exact ⟨max a t+i, by omega, hit⟩

theorem outside_of_recurrent {R} (recurs : Recurrent R) : ∀ a, ¬InTrap R a := by
  intro a ent
  obtain ⟨s,late,hit⟩ := recurs a
  exact no_two_gap_of_entry ent late hit

/-- The kit's explicit ether-wall configuration has finite right support, a two-gap at
every even white sample, and stays outside forever. Aperiodicity is essential. -/
theorem finite_two_gap_forever :
    ∃ R, Rule30ZeroBoundary.FinSupp R ∧ (∀ s, u R s = decide (s%2=0)) ∧
      Rule30Jen.EventuallyPeriodic (u R) ∧ Recurrent R ∧ (∀ a, ¬InTrap R a) := by
  let w := [true,false,true,false]
  -- The phase-one row wsA from Rule30EtherWallWitness.
  let ws := [false,true,true,false,false,false,true,true,false,true,false,false,false]
  let R := config 3 1 6 ws
  have wh : wordAt w = altCol := by
    funext t
    change w.getD (t%4) false = decide (t%2=0)
    have small := Nat.mod_lt t (by decide : 0<4)
    have parity : t%2=t%4%2 := by omega
    rw [parity]
    generalize t%4 = k at small ⊢
    rcases k with _|_|_|_|k <;> first | rfl | omega
  have signal (s : Nat) : u R s = decide (s%2=0) := by
    have row := config_pure_ether w 3 1 6 1 (by decide) (by decide) (by decide)
      ws (by decide) (by decide) (2*s+1)
    simp only [rowOf,etherRow,Rule30StripCertificates.seg,List.cons.injEq,and_true] at row
    change drv altCol R (2*s+1) 1 = _
    rw [←wh]
    change drv (wordAt w) (config 3 1 6 ws) (2*s+1) 1 = _
    rw [row]
    by_cases even : s%2=0
    · have h : (2*s+1+1)%4=2 := by omega
      simp [ether,etherTable,h,even]
    · have h : (2*s+1+1)%4=0 := by omega
      simp [ether,etherTable,h,even]
  have per : Rule30Jen.EventuallyPeriodic (u R) := by
    refine ⟨0,2,by decide,fun t _ => ?_⟩
    simp only [signal,show (t+2)%2=t%2 by omega]
  have recurs : Recurrent R := by
    intro s
    refine ⟨2*s,by omega,(reads_three ..).mpr ?_⟩
    simp only [signal]
    simp [show 2*s%2=0 by omega,show (2*s+1)%2=1 by omega,show (2*s+2)%2=0 by omega]
  exact ⟨R,⟨19,config_finite 3 1 6 _⟩,signal,per,recurs,outside_of_recurrent recurs⟩

theorem outside_iff_recurs (graph : ExteriorRecurrence) {R} (ap : Aperiodic R) :
    (∀ a, ¬InTrap R a) ↔ Recurrent R :=
  ⟨fun out => recurrent_of_frequent (graph R ap out), outside_of_recurrent⟩

theorem outside_iff_frequent (graph : ExteriorRecurrence) {R} (ap : Aperiodic R) :
    (∀ a, ¬InTrap R a) ↔ Frequent R :=
  ⟨graph R ap, fun h => outside_of_recurrent (recurrent_of_frequent h)⟩

theorem rd_iff_late_quiet_blocks (graph : ExteriorRecurrence) :
    Rule30PeriodTwoWidth13.RD ↔ ∀ R, Rule30ZeroBoundary.FinSupp R → Aperiodic R →
      ∀ t, ∃ s, t≤s ∧ ¬Hit43 R s := by
  classical
  constructor
  · intro rd R fin ap t
    rcases rd R fin with ⟨k,odd,ent⟩ | periodic
    · have entry : InTrap R (k/2) := by simpa only [InTrap,show 2*(k/2)+1=k by omega] using ent
      refine ⟨max t (k/2),Nat.le_max_left ..,?_⟩
      rintro ⟨i,_,hit⟩
      exact no_two_gap_of_entry entry (by omega) hit
    · exact False.elim (ap periodic)
  · intro quiet R fin
    by_cases ap : Aperiodic R
    · by_cases entered : ∃ a, InTrap R a
      · obtain ⟨a,h⟩ := entered
        exact Or.inl ⟨2*a+1,by omega,h⟩
      · have freq := graph R ap (fun a h => entered ⟨a,h⟩)
        obtain ⟨k,bound⟩ := freq
        obtain ⟨s,late,absent⟩ := quiet R fin ap k
        exact False.elim (absent (bound s late))
    · exact Or.inr (Classical.byContradiction ap)

end Ruliology.CellularAutomata.WheelTwoGapRecurrence
