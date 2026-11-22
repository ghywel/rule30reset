module
public import Rule30PriorityPhysical

/-! A right-moving alternating front hides a left-moving perturbation from the leftmost 10 observation. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30LeftPriorityLoss
open Rule30Jen Rule30SourcePriority

def evenBit (j : Int) : Bool := decide (j%2=0)
def front (z j : Int) : Bool := decide (j≤z ∧ (j%2=0 ∨ j=z))

private theorem rule_iff (a b c : Bool) : rule a b c=true ↔
    (a=true ∧ b=false ∧ c=false) ∨ (a=false ∧ (b=true ∨ c=true)) := by
  cases a <;> cases b <;> cases c <;> decide

private theorem front_step (z j : Int) :
    front (z+1) j=rule (front z (j-1)) (front z j) (front z (j+1)) := by
  apply Bool.eq_iff_iff.mpr
  simp only [rule_iff, front, decide_eq_true_eq, decide_eq_false_iff_not]
  omega

private theorem stationary (j : Int) :
    evenBit j=rule (evenBit (j-1)) (evenBit j) (evenBit (j+1)) := by
  apply Bool.eq_iff_iff.mpr
  simp only [rule_iff, evenBit, decide_eq_true_eq, decide_eq_false_iff_not]
  omega

def ordinary (h t : Nat) (j : Int) := front ((t : Int)-h) j
def perturbed (h : Nat) : Nat → Int → Bool
  | 0,j => if j=(h:Int)+1 then true else ordinary h 0 j
  | t+1,j => rule (perturbed h t (j-1)) (perturbed h t j) (perturbed h t (j+1))

theorem ordinary_evolves (h : Nat) : Evolution (ordinary h) := by
  intro t j
  unfold ordinary
  rw [show ((t+1:Nat):Int)-h=((t:Int)-h)+1 by omega]
  apply front_step

theorem perturbed_evolves (h : Nat) : Evolution (perturbed h) := fun _ _ => rfl

private theorem incoming (h t : Nat) (before : t≤h) :
    (∀ j : Int, j<(h:Int)+1-t → perturbed h t j=ordinary h t j) ∧
    perturbed h t ((h:Int)+1-t)=true := by
  induction t with
  | zero =>
    constructor
    · intro j hj; simp only [perturbed]; split <;> rename_i e
      · omega
      · rfl
    · simp [perturbed]
  | succ t ih =>
    obtain ⟨agree,edge⟩ := ih (by omega)
    constructor
    · intro j hj
      rw [perturbed_evolves h,ordinary_evolves h,agree _ (by omega),agree _ (by omega),agree _ (by omega)]
    · let j : Int := (h:Int)+1-(t+1)
      change perturbed h (t+1) j=true
      rw [perturbed_evolves h,agree _ (by dsimp [j]; omega),agree _ (by dsimp [j]; omega),
        show j+1=(h:Int)+1-t by dsimp [j];omega,edge]
      have zeroLeft : ordinary h t (j-1)=false := by
        apply decide_eq_false; dsimp [j]; omega
      have zeroHere : ordinary h t j=false := by
        apply decide_eq_false; dsimp [j]; omega
      rw [zeroLeft,zeroHere];rfl

private theorem stationary_left {u : Nat → Int → Bool} (hu : Evolution u) (h : Nat)
    (atContact : ∀ j : Int, j≤0 → u h j=evenBit j) :
    ∀ n (j : Int), j≤0 → u (h+n) j=evenBit j := by
  intro n
  induction n with
  | zero => simpa using atContact
  | succ n ih =>
    intro j hj
    change u (h+n+1) j=evenBit j
    rw [hu,ih _ (by omega),ih _ hj]
    by_cases neg : j<0
    · rw [ih _ (by omega)]; exact (stationary _).symm
    · have : j=0 := by omega
      subst j; cases u (h+n) (0+1) <;> decide

private theorem ordinary_contact (h : Nat) (j : Int) (hj : j≤0) : ordinary h h j=evenBit j := by
  unfold ordinary front evenBit
  simp only [Int.sub_self]
  by_cases e : j%2=0 <;> simp [hj,e] <;> omega

private theorem prefix_tag (a b c d e f : Bool) :
    tag false (mk5 a b c d e)=tag false (mk5 a b c d f) := by decide +revert +kernel
private theorem fixed_tag (d e : Bool) : tag false (mk5 true false true d e)=1 := by
  cases d <;> cases e <;> decide

/-- At any prescribed tick h the two evolutions have different fourth cells and identical readings at every natural tick, past and future. -/
theorem arbitrary_target_loss (h : Nat) :
    ∃ u v, Evolution u ∧ Evolution v ∧ (∀ t, reading false u (-2) t=reading false v (-2) t) ∧
      u h 1=false ∧ v h 1=true := by
  refine ⟨ordinary h,perturbed h,ordinary_evolves h,perturbed_evolves h,?_,?_,?_⟩
  · intro t
    by_cases earlier : t<h
    · have eq := (incoming h t (by omega)).1
      unfold reading band
      rw [eq _ (by omega),eq _ (by omega),eq _ (by omega),eq _ (by omega)]
      exact prefix_tag _ _ _ _ _ _
    · obtain ⟨n,rfl⟩ : ∃ n,t=h+n := ⟨t-h,by omega⟩
      have u := stationary_left (ordinary_evolves h) h (ordinary_contact h)
      have v := stationary_left (perturbed_evolves h) h (fun j hj => ((incoming h h (by omega)).1 j (by omega)).trans (ordinary_contact h j hj))
      unfold reading band
      simp only [u n _ (by decide : (-2:Int)≤0),u n _ (by decide : (-2:Int)+1≤0),u n _ (by decide : (-2:Int)+2≤0),
        v n _ (by decide : (-2:Int)≤0),v n _ (by decide : (-2:Int)+1≤0),v n _ (by decide : (-2:Int)+2≤0)]
      exact (fixed_tag _ _).trans (fixed_tag _ _).symm
  · simp [ordinary,front]
  · simpa only [show (h:Int)+1-h=1 by omega] using (incoming h h (by omega)).2

private theorem left_inj (a b c d : Bool) (e : rule a c d=rule b c d) : a=b := by
  revert e; decide +revert

private theorem one_left {u v} (hu : Evolution u) (hv : Evolution v)
    {t s : Nat} {j k : Int} (same : u t (j+1)=v s (k+1) ∧ u t (j+2)=v s (k+2))
    (next : u (t+1) (j+1)=v (s+1) (k+1)) : u t j=v s k := by
  rw [hu,hv] at next
  simp only [show j+1-1=j by omega,show k+1-1=k by omega,
    show j+1+1=j+2 by omega,show k+1+1=k+2 by omega,same.1,same.2] at next
  exact left_inj _ _ _ _ next

/-- Seven observations recover the three leftmost cells at the second reading, for either selector. -/
theorem first_three (m : Bool) {u v} (hu : Evolution u) (hv : Evolution v) (j k : Int) (a b : Nat)
    (eq : ∀ i, i<7 → reading m u j (a+i)=reading m v k (b+i)) :
    u (a+1) j=v (b+1) k ∧ u (a+1) (j+1)=v (b+1) (k+1) ∧ u (a+1) (j+2)=v (b+1) (k+2) := by
  have p := physical_middle_pair m hu hv j k a b (fun i hi => eq i (by omega))
  have q := physical_middle_pair m hu hv j k (a+1) (b+1) (fun i hi => by
    simpa only [show a+1+i=a+(i+1) by omega,show b+1+i=b+(i+1) by omega] using eq (i+1) (by omega))
  exact ⟨one_left hu hv p q.1,p⟩

/-- Equal infinite readings determine every cell on the left at every tick after the first. -/
theorem left_half (m : Bool) {u v} (hu : Evolution u) (hv : Evolution v) (j k : Int)
    (eq : ∀ t, reading m u j t=reading m v k t) (n t : Nat) :
    u (t+1) (j+1-n)=v (t+1) (k+1-n) ∧ u (t+1) (j+2-n)=v (t+1) (k+2-n) := by
  induction n generalizing t with
  | zero =>
    simpa using physical_middle_pair m hu hv j k t t (fun i _ => eq (t+i))
  | succ n ih =>
    have p := ih t
    have q := ih (t+1)

    have step := one_left hu hv (t:=t+1) (s:=t+1) (j:=j+1-(n+1:Nat)) (k:=k+1-(n+1:Nat))
    simp only [show j+1-(n+1:Nat)+1=j+1-n by omega,show k+1-(n+1:Nat)+1=k+1-n by omega,
      show j+1-(n+1:Nat)+2=j+2-n by omega,show k+1-(n+1:Nat)+2=k+2-n by omega] at step
    exact ⟨step p q.1,by simpa only [show j+2-(n+1:Nat)=j+1-n by omega,
      show k+2-(n+1:Nat)=k+1-n by omega] using p.1⟩

/-- Any common spatial period at the target makes the far-right cell agree as well. Periods of two finite rings always have a common multiple. -/
theorem ring_fourth (m : Bool) {u v} (hu : Evolution u) (hv : Evolution v) (j k : Int)
    (eq : ∀ t, reading m u j t=reading m v k t) (t N : Nat) (large : 2≤N)
    (perU : ∀ i : Int, u (t+1) (i+N)=u (t+1) i) (perV : ∀ i : Int, v (t+1) (i+N)=v (t+1) i) :
    u (t+1) (j+3)=v (t+1) (k+3) := by
  have p := (left_half m hu hv j k eq (N-2) t).1
  have eu := perU (j+1-(N-2:Nat))
  have ev := perV (k+1-(N-2:Nat))
  rw [show j+1-(N-2:Nat)+N=j+3 by omega] at eu
  rw [show k+1-(N-2:Nat)+N=k+3 by omega] at ev
  exact eu.trans (p.trans ev.symm)

private def small (code : Nat) : Nat → Int → Bool
  | 0,j => decide (-5≤j) && code.testBit ((j+5).toNat)
  | n+1,j => rule (small code n (j-1)) (small code n j) (small code n (j+1))

private def examplePair (n : Nat) := ([ (26,1002), (987,1996), (17,30), (8,15), (4,7), (2,3) ] : List (Nat×Nat)).getD n (0,0)

/-- Every potential target inside six left-priority readings has a concrete pair with different three-cell prefixes. -/
theorem six_insufficient_for_three (t : Fin 6) :
    ∃ u v, Evolution u ∧ Evolution v ∧ (∀ i, i<6 → reading false u 0 i=reading false v 0 i) ∧
      (u t.val 0≠v t.val 0 ∨ u t.val 1≠v t.val 1 ∨ u t.val 2≠v t.val 2) := by
  let u := small (examplePair t.val).1
  let v := small (examplePair t.val).2
  refine ⟨u,v,fun _ _ => rfl,fun _ _ => rfl,?_,?_⟩
  · have h : ∀ n i : Fin 6, reading false (small (examplePair n.val).1) 0 i.val =
        reading false (small (examplePair n.val).2) 0 i.val := by decide +kernel
    exact fun i hi => h t ⟨i,hi⟩
  · have h : ∀ n : Fin 6, (small (examplePair n.val).1 n.val 0≠small (examplePair n.val).2 n.val 0 ∨
        small (examplePair n.val).1 n.val 1≠small (examplePair n.val).2 n.val 1 ∨
        small (examplePair n.val).1 n.val 2≠small (examplePair n.val).2 n.val 2) := by decide +kernel
    exact h t

end Ruliology.CellularAutomata.Rule30LeftPriorityLoss
