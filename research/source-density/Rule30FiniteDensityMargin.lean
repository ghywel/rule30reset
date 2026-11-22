module
public import Rule30DensityEscape
public import Ruliology.CellularAutomata.Rule30FiniteConfigs
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30FiniteDensityMargin
open Rule30Jen Rule30Realization Rule30SourceDensityRegion Rule30DensityEscape

private theorem physical_edge {x : Int→Bool} {L j : Int} (atEdge : x L=true)
    (left : ∀ i,i<L → x i=false) {a b d : Nat} (lt : a<b) (reach : j-(d:Int)=L-b)
    (eq : ∀ k,k≤d → evol x (a+k) j=evol x (b+k) j ∧ evol x (a+k) (j+1)=evol x (b+k) (j+1)) : False := by
  have walk (z : Nat) : ∀ k,k+z≤d →
      evol x (a+k) (j-z)=evol x (b+k) (j-z) ∧ evol x (a+k) (j-z+1)=evol x (b+k) (j-z+1) := by
    induction z with
    | zero => simpa using eq
    | succ z ih =>
      intro k hk
      have h:=ih k (by omega)
      constructor
      · rw [show j-((z+1:Nat):Int)=j-(z:Int)-1 by omega,
          Rule30FiniteConfigs.evol_left x (a+k) (j-z),Rule30FiniteConfigs.evol_left x (b+k) (j-z)]
        rw [Nat.add_assoc,Nat.add_assoc,(ih (k+1) (by omega)).1,h.1,h.2]
      · simpa only [show j-((z+1:Nat):Int)+1=j-(z:Int) by omega] using h.1
  have impossible:=(walk d 0 (by omega)).1
  simp only [Nat.add_zero,reach] at impossible
  rw [Rule30FiniteConfigs.evol_eq_false_of_lt left a _ (by omega),
      Rule30FiniteConfigs.evol_left_edge atEdge left] at impossible
  contradiction

/-- If the chosen site is d places to the right of the moving edge at the
start, the loss-free run has strictly fewer than d+2p+3 ticks. -/
theorem interval_gain {x L} (atEdge : x L=true) (left : ∀ i,i<L → x i=false)
    (m : Bool) (j : Int) (s d : Nat) (edgeDistance : (d:Int)=j-(L-s)) :
    ∃ t,s≤t ∧ t<s+d+2*period m+3 ∧ 0<loss m (band (evol x) j t) (band (evol x) j (t+1)) := by
  apply Classical.byContradiction;intro deny
  have hp : 0<period m := by cases m <;> decide
  let k:=d+1+period m
  apply physical_edge atEdge left (a:=s+1) (b:=s+1+period m) (d:=k) (j:=j) (by omega) (by dsimp [k];omega)
  intro i hi
  have h:=tight_columns (u:=evol x) (fun _ _=>rfl) m j (s+i) (fun a ha=>by
    have nonneg:=(band_edge (u:=evol x) (fun _ _=>rfl) m j (s+i+a)).1
    apply Classical.byContradiction;intro nz
    exact deny ⟨s+i+a,by omega,by dsimp [k] at hi;omega,by omega⟩)
  simpa only [show s+i+1=s+1+i by omega,show s+1+i+period m=s+1+period m+i by omega] using
    And.intro h.1.symm h.2.symm

def duration (m : Bool) (d : Nat) : Nat→Nat
  | 0 => 0
  | k+1 => 2*duration m d k+d+2*period m+3

theorem duration_formula (m : Bool) (d k : Nat) :
    duration m d k+(d+2*period m+3)=2^k*(d+2*period m+3) := by
  induction k with
  | zero => simp [duration]
  | succ k ih =>
    rw [Nat.pow_succ,show 2^k*2*(d+2*period m+3)=2*(2^k*(d+2*period m+3)) by ac_rfl,←ih,duration]
    omega

private theorem mono {u} (hu : Evolution u) (m : Bool) (j : Int) {a b : Nat} (ab : a≤b) :
    accumulated m u j a≤accumulated m u j b := by
  induction b with
  | zero => have : a=0 := by omega
            rw [this];omega
  | succ b ih =>
    by_cases e : a=b+1
    · rw [e];omega
    · have h:=ih (by omega);have pos:=(band_edge hu m j b).1;rw [accumulated_step];omega

theorem block_gain {x L} (atEdge : x L=true) (left : ∀ i,i<L → x i=false)
    (m : Bool) (j : Int) (s d k n : Nat) (dist : (d:Int)=j-(L-s)) (enough : duration m d k≤n) :
    accumulated m (evol x) j s+k ≤ accumulated m (evol x) j (s+n) := by
  have early (k : Nat) : accumulated m (evol x) j s+k ≤ accumulated m (evol x) j (s+duration m d k) := by
    induction k with
    | zero => simp [duration]
    | succ k ih =>
      obtain ⟨t,lo,hi,gain⟩:=interval_gain atEdge left m j (s+duration m d k) (d+duration m d k) (by omega)
      have b:=mono (u:=evol x) (fun _ _=>rfl) m j lo
      have e:=mono (u:=evol x) (fun _ _=>rfl) m j (a:=t+1) (b:=s+duration m d (k+1)) (by
        simp only [duration];omega)
      rw [accumulated_step] at e;omega
  have h:=mono (u:=evol x) (fun _ _=>rfl) m j (a:=s+duration m d k) (b:=s+n) (by omega)
  exact Int.le_trans (early k) h

theorem finite_left_margin {x L} (atEdge : x L=true) (left : ∀ i,i<L → x i=false)
    (m : Bool) (j : Int) (s d k n : Nat) (dist : (d:Int)=j-(L-s)) (enough : duration m d k≤n) :
    (k:Int)-(if m then 6 else 4) ≤ base m*(n:Int)+weight m*ends (evol x) j s n - slope m*black (evol x) j s n := by
  have h:=block_gain atEdge left m j s d k n dist enough
  have hb : black (evol x) j 0 (s+n)=black (evol x) j 0 s+black (evol x) j s n := by
    simpa only [black,Nat.zero_add] using Rule30SourceObservables.count_add (fun t=>evol x t j) s n
  have ha : ends (evol x) j 0 (s+n)=ends (evol x) j 0 s+ends (evol x) j s n := by
    simpa only [ends,Nat.zero_add] using Rule30SourceObservables.count_add
      (fun t=>Rule30SourceObservables.source (evol x t j) (evol x t (j+1))) s n
  have p:=(range_potential m (band (evol x) j s)).2
  have q:=(range_potential m (band (evol x) j (s+n))).1
  unfold accumulated at h;rw [ha,hb,Int.natCast_add] at h
  simp only [Int.mul_add] at h;omega
end Ruliology.CellularAutomata.Rule30FiniteDensityMargin
