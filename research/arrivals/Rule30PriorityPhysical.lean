module
public import Rule30SourcePriority
public import Rule30ArrivalRepeats

/-! Source priorities on the genuine singleton and finite two-sided rows.
The finite reconstruction needs only the ordinary Rule 30 spacetime equation. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30SourcePriority
open Rule30Jen

def Evolution (u : Nat → Int → Bool) : Prop := ∀ t i, u (t+1) i =
  rule (u t (i-1)) (u t i) (u t (i+1))
def band (u : Nat → Int → Bool) (j : Int) (t : Nat) :=
  mk5 (u t j) (u t (j+1)) (u t (j+2)) (u t (j+3)) (u t (j+4))
def reading (m : Bool) (u : Nat → Int → Bool) (j : Int) (t : Nat) := tag m (band u j t)

private theorem step_pack : ∀ a b c d e f g : Bool,
    mk5 (rule a b c) (rule b c d) (rule c d e) (rule d e f) (rule e f g) =
      step (mk5 b c d e f) a g := by decide +kernel
private theorem middle_bits : ∀ a b c d e : Bool,
    bit (mk5 a b c d e) 1=b ∧ bit (mk5 a b c d e) 2=c ∧ bit (mk5 a b c d e) 3=d := by decide

theorem band_walk {u} (evolve : Evolution u) (j : Int) (a : Nat) :
    Walk (fun t => band u j (a+t)) := by
  intro t
  refine ⟨u (a+t) (j-1), u (a+t) (j+5), ?_⟩
  change band u j (a+t+1) = _
  unfold band
  rw [evolve,evolve,evolve,evolve,evolve]
  simpa only [show j+1-1=j by omega, show j+2-1=j+1 by omega, show j+3-1=j+2 by omega,
    show j+4-1=j+3 by omega,show j+1+1=j+2 by omega,show j+2+1=j+3 by omega,
    show j+3+1=j+4 by omega,show j+4+1=j+5 by omega] using
    step_pack (u (a+t) (j-1)) (u (a+t) j) (u (a+t) (j+1)) (u (a+t) (j+2))
      (u (a+t) (j+3)) (u (a+t) (j+4)) (u (a+t) (j+5))

theorem physical_middle_pair (m : Bool) {u v} (hu : Evolution u) (hv : Evolution v)
    (j k : Int) (a b : Nat)
    (eq : ∀ i, i<6 → reading m u j (a+i)=reading m v k (b+i)) :
    u (a+1) (j+1)=v (b+1) (k+1) ∧ u (a+1) (j+2)=v (b+1) (k+2) := by
  obtain ⟨x,y⟩:=middle_pair m (band_walk hu j a) (band_walk hv k b) eq
  have au:=middle_bits (u (a+1) j) (u (a+1) (j+1)) (u (a+1) (j+2)) (u (a+1) (j+3)) (u (a+1) (j+4))
  have bv:=middle_bits (v (b+1) k) (v (b+1) (k+1)) (v (b+1) (k+2)) (v (b+1) (k+3)) (v (b+1) (k+4))
  exact ⟨au.1.symm.trans (x.trans bv.1), au.2.1.symm.trans (y.trans bv.2.1)⟩

theorem physical_right_pair {u v} (hu : Evolution u) (hv : Evolution v) (j k : Int) (a b : Nat)
    (eq : ∀ i, i<5 → reading true u j (a+i)=reading true v k (b+i)) :
    u (a+1) (j+2)=v (b+1) (k+2) ∧ u (a+1) (j+3)=v (b+1) (k+3) := by
  obtain ⟨x,y⟩:=right_pair (band_walk hu j a) (band_walk hv k b) eq
  have au:=middle_bits (u (a+1) j) (u (a+1) (j+1)) (u (a+1) (j+2)) (u (a+1) (j+3)) (u (a+1) (j+4))
  have bv:=middle_bits (v (b+1) k) (v (b+1) (k+1)) (v (b+1) (k+2)) (v (b+1) (k+3)) (v (b+1) (k+4))
  exact ⟨au.2.1.symm.trans (x.trans bv.2.1), au.2.2.symm.trans (y.trans bv.2.2)⟩

/-- Both priority streams are aperiodic at every spatial band, without a
hypothesis on the center's period, white gaps or source frequencies. -/
theorem singleton_priority_aperiodic (m : Bool) (j : Int) :
    ¬ ∃ T p : Nat, 0<p ∧ ∀ t, T≤t → reading m cell j (t+p)=reading m cell j t := by
  rintro ⟨T,p,hp,per⟩
  have stepCell : Evolution cell := fun _ _ => rfl
  have cols (t : Nat) (late : T+1≤t) :
      cell (t+p) (j+1)=cell t (j+1) ∧ cell (t+p) (j+2)=cell t (j+2) := by
    have recov:=physical_middle_pair m stepCell stepCell j j (t-1+p) (t-1) (fun i hi => by
      rw [show t-1+p+i=t-1+i+p by omega];exact per _ (by omega))
    simpa only [show t-1+p+1=t+p by omega,show t-1+1=t by omega] using recov
  apply not_adjacent (j+1) ⟨T+1,p,hp,fun t ht=>(cols t ht).1⟩
  exact ⟨T+1,p,hp,fun t ht=>by simpa only [show j+1+1=j+2 by omega] using (cols t ht).2⟩

/-- Right priority on the three run-end sources starting at -2 has a finite
repeat bound: a matched n-letter block at absolute singleton ages a<b has
n ≤ b+5. Overlap and age zero are allowed. -/
theorem singleton_priority_repeat {a b n : Nat} (lt : a<b)
    (eq : ∀ i,i<n → reading true cell (-2) (a+i)=reading true cell (-2) (b+i)) : n≤b+5 := by
  by_cases small : n≤5
  · omega
  have stepCell : Evolution cell := fun _ _ => rfl
  have cols (i : Nat) (hi : i<n-4) :=
    physical_right_pair stepCell stepCell (-2) (-2) (a+i) (b+i)
      (fun h hh => by simpa only [Nat.add_assoc] using eq (i+h) (by omega))
  have bound := Rule30ArrivalMemory.adjacent_match_bound (a:=a+1) (b:=b+1) (n:=n-5)
    (by omega) (fun i hi=>by
      simpa only [Rule30ArrivalMemory.center, Rule30ArrivalMemory.right, show (-2:Int)+2=0 by decide, show (-2:Int)+3=1 by decide, show a+i+1=a+1+i by omega,show b+i+1=b+1+i by omega] using (cols i (by omega)).1)
    (fun i hi=>by
      simpa only [Rule30ArrivalMemory.center, Rule30ArrivalMemory.right, show (-2:Int)+2=0 by decide, show (-2:Int)+3=1 by decide, show a+i+1=a+1+i by omega,show b+i+1=b+1+i by omega] using (cols i (by omega)).2)
  omega

end Ruliology.CellularAutomata.Rule30SourcePriority
