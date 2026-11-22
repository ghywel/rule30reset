module
public import Rule30QuietCorner
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30QuietCorner
open Rule30Jen (cell rule)
open Rule30SourceObservables (source bit count)
open Rule30SourceDensityRegion

private theorem bit01 (b : Bool) : 0≤bit b ∧ bit b≤1 := by cases b <;> decide
private theorem count_mono (f : Nat→Bool) {a b : Nat} (h : a≤b) : count f a≤count f b := by
  induction b with
  | zero => have : a=0 := by omega
            rw [this];omega
  | succ b ih =>
    by_cases eq : a=b+1
    · rw [eq];omega
    · have h':=ih (by omega);have i:=bit01 (f b);simp only [count];omega

theorem bounded_count_iff (f : Nat→Bool) :
    (∃ B : Int, ∀ n, count f n ≤ B) ↔ ∃ T, ∀ t,T≤t → f t=false := by
  constructor
  · rintro ⟨B,bound⟩
    apply Classical.byContradiction;intro den
    have later (a : Nat) : ∃ t,a≤t ∧ f t=true := by
      apply Classical.byContradiction;intro absent
      apply den;refine ⟨a,fun t ht=>?_⟩
      cases e : f t with
      | false => rfl
      | true => exact False.elim (absent ⟨t,ht,e⟩)
    have many (k : Nat) : ∃ n,(k:Int) ≤ count f n := by
      induction k with
      | zero => exact ⟨0,by simp [count]⟩
      | succ k ih =>
        obtain ⟨a,ha⟩:=ih
        obtain ⟨t,ht,hf⟩:=later a
        have z:=count_mono f ht
        exact ⟨t+1,by simp only [count,hf,bit,ite_true];omega⟩
    obtain ⟨n,hn⟩:=many (B.toNat+1);have h:=bound n;omega
  · rintro ⟨T,tail⟩
    refine ⟨count f T,fun n=>?_⟩
    induction n with
    | zero => exact count_mono f (Nat.zero_le _)
    | succ n ih =>
      by_cases le : n+1≤T
      · exact count_mono f le
      · simpa only [count,tail n (by omega),bit,Bool.false_eq_true,ite_false,Int.add_zero] using ih

/-- The two-black period-three word, in the physical reading direction.
The start may be moved to its white phase. -/
def Tail011 (f : Nat→Bool) : Prop := ∃ s, ∀ k : Nat,
  f (s+3*k)=false ∧ f (s+3*k+1)=true ∧ f (s+3*k+2)=true

private theorem local_period : ∀ a b c d : Bool,
    outside a b c=false → outside b c d=false → a=d := by decide
private theorem one_white : ∀ a b c : Bool, outside a b c=false →
    (a=false ∨ b=false ∨ c=false) := by decide
private theorem fill : ∀ a b : Bool, outside false a b=false → a=true ∧ b=true := by decide

theorem tail_iff_good_triples (f : Nat→Bool) : Tail011 f ↔
    ∃ T,∀ t,T≤t → outside (f t) (f (t+1)) (f (t+2))=false := by
  constructor
  · rintro ⟨s,blocks⟩;refine ⟨s,fun t ht=>?_⟩
    let k:=(t-s)/3
    have curr:=blocks k;have nx:=blocks (k+1)
    have q : t=s+3*k ∨ t=s+3*k+1 ∨ t=s+3*k+2 := by dsimp [k];omega
    rcases q with h|h|h
    · rw [h,curr.1,curr.2.1,curr.2.2];decide
    · rw [h,curr.2.1,show s+3*k+1+1=s+3*k+2 by omega,curr.2.2,
         show s+3*k+1+2=s+3*(k+1) by omega,nx.1];decide
    · rw [h,curr.2.2,show s+3*k+2+1=s+3*(k+1) by omega,nx.1,
         show s+3*k+2+2=s+3*(k+1)+1 by omega,nx.2.1];decide
  · rintro ⟨T,good⟩
    have shift3 (t : Nat) (ht : T≤t) : f t=f (t+3) :=
      local_period _ _ _ _ (good t ht) (good (t+1) (by omega))
    have white : ∃ s,T≤s ∧ f s=false := by
      rcases one_white _ _ _ (good T (by omega)) with h|h|h
      · exact ⟨T,by omega,h⟩
      · exact ⟨T+1,by omega,h⟩
      · exact ⟨T+2,by omega,h⟩
    obtain ⟨s,st,ws⟩:=white;refine ⟨s,fun k=>?_⟩
    have form:=good s st;rw [ws] at form
    induction k with
    | zero => simpa only [Nat.mul_zero,Nat.add_zero] using And.intro ws (fill _ _ form)
    | succ k ih =>
      rcases ih with ⟨a,b,c⟩
      have h0:=shift3 (s+3*k) (by omega)
      have h1:=shift3 (s+3*k+1) (by omega)
      have h2:=shift3 (s+3*k+2) (by omega)
      simpa only [show s+3*k+3=s+3*(k+1) by omega,show s+3*k+1+3=s+3*(k+1)+1 by omega,
        show s+3*k+2+3=s+3*(k+1)+2 by omega] using
        And.intro (h0.symm.trans a) (And.intro (h1.symm.trans b) (h2.symm.trans c))

theorem bounded_deficit_iff {u} (hu : Evolution u) (j : Int) :
    (∃ K : Int,∀ n, deficit u j 0 n≤K) ↔ Tail011 (fun t=>u t (j+2)) := by
  have good := tail_iff_good_triples (fun t=>u t (j+2))
  have bound := bounded_count_iff (fun t=>outside (u t (j+2)) (u (t+1) (j+2)) (u (t+2) (j+2)))
  rw [good,← bound]
  constructor
  · rintro ⟨K,bd⟩;refine ⟨2*K+7,fun n=>?_⟩
    have h:=(defect_comparison hu j 0 n).1;have b:=bd n
    simp only [defects,Nat.zero_add] at h;omega
  · rintro ⟨K,bd⟩;refine ⟨4*K+3,fun n=>?_⟩
    have h:=(defect_comparison hu j 0 n).2;have b:=bd n
    simp only [defects,Nat.zero_add] at h;omega

theorem singleton_bounded_iff (j : Int) :
    (∃ K : Int,∀ n,deficit cell j 0 n≤K) ↔ Tail011 (fun t=>cell t (j+2)) :=
  bounded_deficit_iff (fun _ _=>rfl) j
end Ruliology.CellularAutomata.Rule30QuietCorner
