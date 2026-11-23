import Rule30EtherThreeRigid

/-! Exact time from a recurrent disturbance front to the first disagreement at
site 1 of the period-three ether. The front may move right on two of its ten
phases. Distances zero and one therefore need their own entries. -/
namespace Ruliology.CellularAutomata.Rule30EtherThreeFirstDeparture
open Rule30Ether Rule30EtherThreeErosion Rule30EtherThreeRigid

/-- Phase of the recurrent front in its ten-tick displacement cycle. -/
def slot (g : Nat) (u : Bool) : Nat :=
  if g == 8 && u then 9 else [0,7,4,1,8,5,2,0,6,3].getD g 0

private def smallWait (d j : Nat) : Nat :=
  let row := match d with
    | 0 => []
    | 1 => [1,1,1,3,1,1,5,1,3,2]
    | 2 => [2,2,4,8,2,6,6,4,4,3]
    | 3 => [3,5,9,9,7,7,7,5,5,4]
    | 4 => [6,10,10,10,8,8,10,6,8,7]
    | _ => [11,11,11,13,9,11,15,9,13,12]
  row.getD j 0

/-- Wait from distance d = D − 1 to the first discrepancy at site 1. -/
def ticksToOne (d j : Nat) : Nat :=
  if d < 2 then smallWait d j
  else 10*((d-2)/4) + smallWait (2+(d-2)%4) j

theorem ticks_add_four {d : Nat} (hd : 2 ≤ d) (j : Nat) :
    ticksToOne (d+4) j = ticksToOne d j + 10 := by
  simp only [ticksToOne, ite_eq_right (show ¬d+4 < 2 by omega), ite_eq_right (show ¬d < 2 by omega)]
  have modEq : (d+4-2)%4 = (d-2)%4 := by omega
  rw [modEq]; omega

/-- The original invariant restricts the next displacement to i−1. On every
allowed transition the proposed waiting time drops by one. -/
private theorem small_step : ∀ (d : Fin 7) (g : Fin 12) (i : Fin 3) (u v : Bool),
    1 ≤ d.val → isRec g.val u = true → isRec ((g.val+3+i.val)%12) v = true →
    5*i.val+2+psiR ((g.val+3+i.val)%12) v = 5+psiR g.val u →
    ticksToOne (d.val-1+i.val) (slot ((g.val+3+i.val)%12) v) + 1 =
      ticksToOne d.val (slot g.val u) := by decide +kernel

private theorem step_duration (d g i : Nat) (u v : Bool)
    (hd : 1 ≤ d) (hg : g < 12) (hi : i < 3) (hu : isRec g u = true)
    (hv : isRec ((g+3+i)%12) v = true) (hbal : 5*i+2+psiR ((g+3+i)%12) v = 5+psiR g u) :
    ticksToOne (d-1+i) (slot ((g+3+i)%12) v) + 1 = ticksToOne d (slot g u) := by
  by_cases h : d < 7
  · exact small_step ⟨d,h⟩ ⟨g,hg⟩ ⟨i,hi⟩ u v hd hu hv hbal
  · have ih := step_duration (d-4) g i u v (by omega) hg hi hu hv hbal
    have x := ticks_add_four (d := d-4) (by omega) (slot g u)
    have y := ticks_add_four (d := d-4-1+i) (by omega) (slot ((g+3+i)%12) v)
    rw [show d-4+4 = d by omega] at x
    rw [show d-4-1+i+4 = d-1+i by omega] at y
    omega
termination_by d

private def waitAt (F : Nat → Nat → Bool) (j0 s t D : Nat) :=
  ticksToOne (D-1) (slot (cls j0 s D t) (ubit F j0 s t D))

private theorem advance {F : Nat → Nat → Bool} (hF : IsR30 F) {j0 s t D : Nat}
    (h0 : F (t+1) 0 = eth j0 s 0 (t+1)) (hd : 2 ≤ D)
    (hf : Front F j0 s t D) (hr : IsRec F j0 s t D) :
    ∃ E, 1 ≤ E ∧ Front F j0 s (t+1) E ∧ IsRec F j0 s (t+1) E ∧
      waitAt F j0 s (t+1) E + 1 = waitAt F j0 s t D := by
  obtain ⟨E,hE,rE,hl,hh,bal⟩ := rigid_step hF h0 hd hf hr
  let i := E+1-D
  have hi : i < 3 := by dsimp [i]; omega
  have eqD : E+1 = D+i := by dsimp [i]; omega
  have cc : cls j0 s E (t+1) = (cls j0 s D t+3+i)%12 := by unfold cls; omega
  unfold psi at bal
  unfold IsRec at rE
  rw [cc] at rE bal
  have step := step_duration (D-1) (cls j0 s D t) i (ubit F j0 s t D) (ubit F j0 s (t+1) E)
    (by omega) (cls_lt ..) hi hr rE (by omega)
  refine ⟨E,by omega,hE,by unfold IsRec; rw [cc]; exact rE,?_⟩
  unfold waitAt; rw [cc, ← show D-1-1+i = E-1 by omega]; exact step

/-- Agreement before t+n and the first discrepancy at t+n, measured from t. -/
def FirstDeparture (F : Nat → Nat → Bool) (j0 s t n : Nat) : Prop :=
  (∀ m, m < n → F (t+m) 1 = eth j0 s 1 (t+m)) ∧ F (t+n) 1 ≠ eth j0 s 1 (t+n)

private theorem reaches {F : Nat → Nat → Bool} (hF : IsR30 F) {j0 s : Nat} (n t D : Nat)
    (h0 : ∀ w, t ≤ w → F w 0 = eth j0 s 0 w)
    (hd : 1 ≤ D) (hf : Front F j0 s t D) (hr : IsRec F j0 s t D) (hn : waitAt F j0 s t D = n) :
    FirstDeparture F j0 s t n := by
  by_cases one : D = 1
  · subst D
    have zero : n = 0 := by simpa [waitAt,ticksToOne,smallWait] using hn.symm
    rw [zero]; exact ⟨fun _ hm => by omega,by simpa using hf.2⟩
  · obtain ⟨E,he,hE,rE,dec⟩ := advance hF (h0 _ (by omega)) (by omega) hf hr
    cases n with
    | zero => omega
    | succ n =>
      obtain ⟨prior,last⟩ := reaches hF n (t+1) E (fun w hw => h0 w (by omega)) he hE rE (by omega)
      refine ⟨?_,by simpa only [show t+(n+1) = t+1+n by omega] using last⟩
      intro m hm
      cases m with
      | zero => simpa using hf.1 1 (by omega)
      | succ m => simpa only [show t+(m+1) = t+1+m by omega] using prior m (by omega)
termination_by n

/-- Closed-form first-departure time at every recurrent front, for any right
continuation. The inputs are the distance to site 1, the ether class and a
single bit immediately east of the front. -/
theorem first_departure {F : Nat → Nat → Bool} (hF : IsR30 F) {j0 s t D : Nat}
    (h0 : ∀ w, t ≤ w → F w 0 = eth j0 s 0 w)
    (hd : 1 ≤ D) (hf : Front F j0 s t D) (hr : IsRec F j0 s t D) :
    FirstDeparture F j0 s t
      (ticksToOne (D-1) (slot (cls j0 s D t) (ubit F j0 s t D))) :=
  reaches hF _ t D h0 hd hf hr rfl


/-! A visible departure from an aligned 22-site prefix. Only three transient
states can occur between the first defect at site 22 and its recurrent path. -/

private def shortState (g : Nat) (u : Bool) : Prop :=
  (g = 3 ∧ u = false) ∨ (g = 6 ∨ g = 9) ∧ u = true

private theorem short_table : ∀ (c : Fin 12) (φ : Fin 3) (x y z w : Bool),
    let g := (c.val+4*φ.val)%12
    let i := if g = 9 then 1 else 0
    shortState g (uC c.val φ.val x) →
      (∀ j, j < i → dC c.val φ.val x y z w j = false) ∧ dC c.val φ.val x y z w i = true ∧
      (g ≠ 9 → dC c.val φ.val x y z w (i+1) = true) := by
  unfold shortState
  decide +kernel

private theorem short_step {F : Nat → Nat → Bool} (hF : IsR30 F) {j0 s t D g : Nat}
    (h0 : F (t+1) 0 = eth j0 s 0 (t+1)) (hd : 2 ≤ D) (hf : Front F j0 s t D)
    (hc : cls j0 s D t = g) (hs : shortState g (ubit F j0 s t D)) :
    let i := if g = 9 then 1 else 0
    let E := D-1+i
    Front F j0 s (t+1) E ∧ cls j0 s E (t+1) = (g+3+i)%12 ∧
      (g ≠ 9 → ubit F j0 s (t+1) E = true) := by
  obtain ⟨c,φ,x,y,z,w,cl,ph,cg,bit,step⟩ := local_step hF h0 hd hf
  rw [←hc,cg,bit] at hs
  obtain ⟨before,atFront,after⟩ := short_table ⟨c,cl⟩ ⟨φ,ph⟩ x y z w hs
  rw [←hc,cg]
  let i := if (c+4*φ)%12 = 9 then 1 else 0
  obtain ⟨front,newClass,newBit⟩ := step i (by dsimp [i]; split <;> decide) before atFront
  exact ⟨front,by rw [newClass]; omega,fun h => newBit.trans (after h)⟩

private theorem prepend {F j0 s t n} (h : F t 1 = eth j0 s 1 t)
    (later : FirstDeparture F j0 s (t+1) n) : FirstDeparture F j0 s t (n+1) := by
  refine ⟨?_,by simpa only [show t+(n+1) = (t+1)+n by omega] using later.2⟩
  intro m hm; cases m with
  | zero => simpa using h
  | succ m => simpa only [show t+(m+1) = (t+1)+m by omega] using later.1 m (by omega)

private theorem nine {F : Nat → Nat → Bool} (hF : IsR30 F) {j0 s t D : Nat}
    (h0 : ∀ w, t ≤ w → F w 0 = eth j0 s 0 w)
    (hd : 2 ≤ D) (hf : Front F j0 s t D) (hc : cls j0 s D t = 9) (hu : ubit F j0 s t D = true) :
    FirstDeparture F j0 s t (ticksToOne (D-1) 7 + 1) := by
  obtain ⟨front,cl,_⟩ := short_step hF (h0 _ (by omega)) hd hf hc (Or.inr ⟨Or.inr rfl,hu⟩)
  simp only [ite_true] at front cl
  rw [show D-1+1 = D by omega] at front cl
  have cls1 : cls j0 s D (t+1) = 1 := cl
  have rec1 : IsRec F j0 s (t+1) D := by
    unfold IsRec; rw [cls1]; cases ubit F j0 s (t+1) D <;> decide
  have next := first_departure hF (fun w hw => h0 w (by omega)) (by omega) front rec1
  rw [cls1] at next
  apply prepend (hf.1 1 (by omega))
  exact next

private theorem six {F : Nat → Nat → Bool} (hF : IsR30 F) {j0 s t D : Nat}
    (h0 : ∀ w, t ≤ w → F w 0 = eth j0 s 0 w)
    (hd : 3 ≤ D) (hf : Front F j0 s t D) (hc : cls j0 s D t = 6) (hu : ubit F j0 s t D = true) :
    FirstDeparture F j0 s t (ticksToOne (D-2) 7 + 2) := by
  obtain ⟨front,cl,bit⟩ := short_step hF (h0 _ (by omega)) (by omega) hf hc (Or.inr ⟨Or.inl rfl,hu⟩)
  apply prepend (hf.1 1 (by omega))
  exact nine hF (fun w hw => h0 w (by omega)) (D := D-1) (by omega) front cl (bit (by decide))

private theorem at_twenty_two {F : Nat → Nat → Bool} (hF : IsR30 F) {j0 s t : Nat}
    (h0 : ∀ w, t ≤ w → F w 0 = eth j0 s 0 w) (hf : Front F j0 s t 22)
    (hstate : (cls j0 s 22 t = 3 ∧ eth j0 s 23 t = false) ∨
              (cls j0 s 22 t = 6 ∧ eth j0 s 23 t = true)) :
    FirstDeparture F j0 s t (if F t 23 then 51 else 48) := by
  cases b : F t 23 <;> rcases hstate with ⟨cl,ref⟩ | ⟨cl,ref⟩
  · have bit : ubit F j0 s t 22 = false := by unfold ubit; rw [show 22+1=23 by decide,b,ref]; rfl
    obtain ⟨front,cc,bb⟩ := short_step hF (h0 _ (by omega)) (by decide) hf cl (Or.inl ⟨rfl,bit⟩)
    exact prepend (hf.1 1 (by decide)) (six hF (fun w hw => h0 w (by omega)) (D := 21) (by decide) front cc (bb (by decide)))
  · have bit : ubit F j0 s t 22 = true := by unfold ubit; rw [show 22+1=23 by decide,b,ref]; rfl
    exact six hF h0 (by decide) hf cl bit
  · have bit : ubit F j0 s t 22 = true := by unfold ubit; rw [show 22+1=23 by decide,b,ref]; rfl
    have rec' : IsRec F j0 s t 22 := by unfold IsRec; rw [cl,bit]; decide
    have h := first_departure hF h0 (by decide) hf rec'; rw [cl,bit] at h; exact h
  · have bit : ubit F j0 s t 22 = false := by unfold ubit; rw [show 22+1=23 by decide,b,ref]; rfl
    have rec' : IsRec F j0 s t 22 := by unfold IsRec; rw [cl,bit]; decide
    have h := first_departure hF h0 (by decide) hf rec'; rw [cl,bit] at h; exact h


open Rule30EtherThree

/-- Column zero of the chosen ether is aligned to the repeating word 001. -/
def Aligned001 (j0 s : Nat) : Prop :=
  ∀ p : Fin 3, eth j0 s 0 p.val = decide (p.val = 2)


private theorem exit_table : ∀ (j : Fin 12) (s t : Fin 3) (east far : Bool),
    (∀ p : Fin 3, ether3 j.val (p.val+s.val) = decide (p.val = 2)) →
    let e := fun n => ether3 (j.val+n) (t.val+s.val)
    Rule30Jen.rule (e 21) (e 22) east ≠ ether3 (j.val+22) (t.val+1+s.val) →
    let g := (j.val+22+4*(t.val+1+s.val))%12
    let r := ether3 (j.val+23) (t.val+1+s.val)
    let flag := Rule30Jen.rule (e 22) east far
    (j.val%4 = 1 ∧ t.val = 0 ∧ g = 3 ∧ r = false ∧ flag = true) ∨
    (j.val%4 = 0 ∧ t.val = 1 ∧ g = 6 ∧ r = true ∧ flag = far) := by decide +kernel

/-- Start the clock at the last tick t of full agreement on sites 1 through 22.
In the first aligned ether class (j0 mod 4 = 1), the first site-1 disagreement
is at t+52. In the other class it is at t+49 or t+52, as site 24 at t is
white or black. Every right continuation with the stated prefix exit is covered. -/
theorem departure_after_prefix_exit {F : Nat → Nat → Bool} (hF : IsR30 F) {j0 s t : Nat}
    (ha : Aligned001 j0 s) (h0 : ∀ w, t ≤ w → F w 0 = eth j0 s 0 w)
    (agree : ∀ p, p ≤ 22 → F t p = eth j0 s p t)
    (exit : ∃ p, p ≤ 22 ∧ F (t+1) p ≠ eth j0 s p (t+1)) :
    (j0%4 = 1 ∧ t%3 = 0 ∧ FirstDeparture F j0 s t 52) ∨
    (j0%4 = 0 ∧ t%3 = 1 ∧ FirstDeparture F j0 s t (if F t 24 then 52 else 49)) := by
  have before : ∀ p, p < 22 → F (t+1) p = eth j0 s p (t+1) := by
    intro p hp
    exact prefix_step hF (h0 _ (by omega)) (D := 23) (fun q hq => agree q (by omega)) p (by omega)
  have diff : F (t+1) 22 ≠ eth j0 s 22 (t+1) := by
    obtain ⟨p,hp,hne⟩ := exit
    by_cases h : p = 22
    · simpa only [h] using hne
    · exact False.elim (hne (before p (by omega)))
  let j : Fin 12 := ⟨j0%12,by omega⟩
  let a : Fin 3 := ⟨s%3,by omega⟩
  let b : Fin 3 := ⟨t%3,by omega⟩
  have align (p : Fin 3) : ether3 j.val (p.val+a.val) = decide (p.val = 2) :=
    (ether3_congr (by dsimp [j]; omega) (by dsimp [a]; omega)).trans (ha p)
  have old (p : Nat) : ether3 (j.val+p) (b.val+a.val) = eth j0 s p t :=
    ether3_congr (by dsimp [j]; omega) (by dsimp [a,b]; omega)
  have new (p : Nat) : ether3 (j.val+p) (b.val+1+a.val) = eth j0 s p (t+1) :=
    ether3_congr (by dsimp [j]; omega) (by dsimp [a,b]; omega)
  have lost : Rule30Jen.rule (ether3 (j.val+21) (b.val+a.val)) (ether3 (j.val+22) (b.val+a.val))
      (F t 23) ≠ ether3 (j.val+22) (b.val+1+a.val) := by
    rw [old,old,new,←agree 21 (by decide),←agree 22 (by decide)]
    exact diff ∘ Eq.trans (hF t 21)
  have flag : Rule30Jen.rule (ether3 (j.val+22) (b.val+a.val)) (F t 23) (F t 24) = F (t+1) 23 := by
    rw [old,←agree 22 (by decide)]; exact (hF t 22).symm
  have cl : (j.val+22+4*(b.val+1+a.val))%12 = cls j0 s 22 (t+1) := by dsimp [j,a,b,cls]; omega
  have data := exit_table j a b (F t 23) (F t 24) align lost
  simp only [cl,new,flag] at data
  have front : Front F j0 s (t+1) 22 := ⟨before,diff⟩
  have hit := at_twenty_two hF (fun w hw => h0 w (by omega)) front
  rcases data with ⟨cj,ph,hc,hr,hflag⟩ | ⟨cj,ph,hc,hr,hflag⟩
  · have res := prepend (agree 1 (by decide)) (hit (Or.inl ⟨hc,hr⟩))
    exact Or.inl ⟨by dsimp [j] at cj; omega,ph,by simpa [hflag] using res⟩
  · have res := prepend (agree 1 (by decide)) (hit (Or.inr ⟨hc,hr⟩))
    refine Or.inr ⟨by dsimp [j] at cj; omega,ph,?_⟩
    rw [hflag] at res; cases bit : F t 24 <;> simpa [bit] using res

end Ruliology.CellularAutomata.Rule30EtherThreeFirstDeparture
