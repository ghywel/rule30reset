module

public import Ruliology.CellularAutomata.Rule30WhiteTailErosion
public import Ruliology.CellularAutomata.Rule30Realization

/-! A quantitative statement about the unconstrained white-phase bit next to a 101 drive.
Uses Lowry's bounded-witness extension of Perez Morales and Claude's period-three ether erosion.
Columns 0,1,2 of an `IsR30` strip are respectively the cell left of the drive, the drive,
and its right neighbor. The outer left input is completely free. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30QuietThirdGate
open Rule30Jen Rule30Ether Rule30EtherThree Rule30EtherThreeErosion Rule30WhiteTailErosion

def drive (t : Nat) : Bool := decide (t % 3 ≠ 1)
def align (b : Bool) : Nat := if b then 6 else 9

private theorem small_left : ∀ (s : Fin 3) (b f l : Bool),
    ¬ (s.val = 1 ∧ f = b) → rule l (drive s.val) f = drive (s.val+1) →
    l = ether3 (align b) s.val := by decide +kernel

private theorem small_drive : ∀ (s : Fin 3) (b : Bool), ether3 (align b+1) s.val = drive s.val := by decide +kernel

theorem matches_drive (t : Nat) (b : Bool) : ether3 (align b+1) t = drive t := by
  rw [ether3_congr (φ' := t%3) rfl (by omega),small_drive ⟨t%3,by omega⟩ b]
  simp [drive]

theorem left_when_absent {F : Nat → Nat → Bool} (hF : IsR30 F) (hE : ∀ t, F t 1 = drive t)
    (b : Bool) (t : Nat) (h : ¬ (t%3=1 ∧ F t 2=b)) : F t 0 = ether3 (align b) t := by
  have he := (hF t 0).symm
  simp only [Nat.zero_add,hE] at he
  have hd : drive ((t%3)+1) = drive (t+1) := by simp only [drive, Nat.add_mod, Nat.mod_mod]
  have hdt : drive (t%3) = drive t := by simp [drive]
  have hsmall := small_left ⟨t%3,by omega⟩ b (F t 2) (F t 0) h (by simpa only [hdt,hd] using he)
  change F t 0 = ether3 (align b) (t%3) at hsmall
  exact hsmall.trans (ether3_congr rfl (by omega))

private theorem five_small : ∀ j : Fin 12, ∀ s : Fin 3, ∃ r : Fin 5,
    ether3 (j.val+r.val+1) s.val = true := by decide +kernel

theorem white_defect_five {F : Nat → Nat → Bool} (hF : IsR30 F) (j s W : Nat)
    (hW : ∀ p, W < p → F 0 p = false) (n : Nat) :
    ∃ p, p ≤ W+5+n ∧ F n p ≠ eth j s p n := by
  obtain ⟨r,hr⟩ := five_small ⟨(j+W+n)%12,by omega⟩ ⟨(n+s)%3,by omega⟩
  refine ⟨W+n+r.val+1,by have := r.isLt; omega,?_⟩
  have hw := white_tail_evol hF 0 W hW n (W+n+r.val+1) (by omega)
  rw [Nat.zero_add] at hw
  have hb : eth j s (W+n+r.val+1) n = true := by
    exact (ether3_congr (j' := (j+W+n)%12+r.val+1) (φ' := (n+s)%3) (by omega) (by omega)).trans hr
  rw [hw,hb]; decide

/-- When the two boundaries agree for `B` inputs, every positive cell agrees for `B+1` rows. -/
theorem window_agree {F G : Nat → Nat → Bool} (hF : IsR30 F) (hG : IsR30 G) (B : Nat)
    (hini : ∀ p, 0 < p → F 0 p = G 0 p) (hb : ∀ s, s < B → F s 0 = G s 0) :
    ∀ n, n ≤ B → ∀ p, 0 < p → F n p = G n p := by
  intro n; induction n with
  | zero => exact fun _ => hini
  | succ n ih =>
    intro hn p hp
    obtain ⟨q,rfl⟩ : ∃ q, p=q+1 := ⟨p-1,by omega⟩
    have he : F n q = G n q := by
      cases q with
      | zero => exact hb n (by omega)
      | succ q => exact ih (by omega) _ (by omega)
    rw [hF n q,hG n q,he,ih (by omega) (q+1) (by omega),ih (by omega) (q+2) (by omega)]

/-- For either chosen color, some white-phase sample to the right of the drive has that color
at a time in the stated interval. `W` is measured from the drive itself. -/
theorem gate_deadline {F : Nat → Nat → Bool} (hF : IsR30 F) (hE : ∀ t, F t 1 = drive t)
    (W : Nat) (hW : ∀ p, W+1 < p → F 0 p = false) (b : Bool) (T : Nat) :
    ∃ t, T ≤ t ∧ t ≤ 4*T+3*W+20 ∧ t%3=1 ∧ F t 2=b := by
  apply Classical.byContradiction; intro hn
  let B := 3*(T+W)+21
  let X : Nat → Nat → Bool := fun n p => F (T+n) p
  have hX : IsR30 X := fun n q => hF (T+n) q
  let c : Nat → Bool := fun n => ether3 (align b) (n+T)
  let G := drv c (X 0)
  have hG := drv_isR30 c (X 0)
  have hi : ∀ p, 0 < p → X 0 p = G 0 p := fun p hp => (drv_init c (X 0) p hp).symm
  have hb : ∀ n, n<B → X n 0 = G n 0 := by
    intro n hnb; rw [show G n 0 = c n from drv_col0 _ _ _]
    have hh := left_when_absent hF hE b (T+n) (fun hx => hn ⟨T+n,by omega,by dsimp [B] at hnb; omega,hx⟩)
    simpa [X,c,Nat.add_comm n T] using hh
  have hWg : ∀ p, W+1+T<p → G 0 p=false := by
    intro p hp; rw [←hi p (by omega)]
    simpa [X] using white_tail_evol hF 0 (W+1) hW T p hp
  obtain ⟨n,_,hnB,p,hp1,hp2,hd⟩ := erosion_bounded hG (align b) T 0 (W+1+T+5) 1 (by decide)
    (fun n _ => by simp [drv_col0,c,eth])
    (fun n _ => by simpa only [Nat.sub_zero] using white_defect_five hG (align b) T (W+1+T) hWg n)
  have hpp : p=1 := by omega
  subst p
  have ha := window_agree hX hG B hi hb n (by dsimp [B]; omega) 1 (by decide)
  apply hd
  change G n 1 = ether3 (align b+1) (n+T)
  change X n 1 = G n 1 at ha
  rw [←ha,matches_drive,show X n 1 = drive (T+n) from hE _,Nat.add_comm n T]

/-- Any ordinary full-line orbit with a finite right support and the period-three drive
satisfies the same two-color deadline, independently of its entire left initial half. -/
theorem full_line_gate_deadline (x : Int → Bool) (W : Nat)
    (hW : ∀ p : Int, (W:Int)<p → x p=false) (hE : ∀ t, Rule30Realization.evol x t 0=drive t)
    (b : Bool) (T : Nat) : ∃ t, T ≤ t ∧ t ≤ 4*T+3*W+20 ∧ t%3=1 ∧ Rule30Realization.evol x t 1=b := by
  let F : Nat → Nat → Bool := fun t p => Rule30Realization.evol x t ((p:Int)-1)
  have hF : IsR30 F := by
    intro t p; dsimp [F,Rule30Realization.evol]
    congr 1 <;> congr 1 <;> omega
  have hF1 : ∀ t, F t 1 = drive t := by simpa [F] using hE
  obtain ⟨t,h1,h2,h3,h4⟩ := gate_deadline hF hF1 W (fun p hp => hW _ (by omega)) b T
  exact ⟨t,h1,h2,h3,by simpa [F] using h4⟩

/-- An arbitrary transient and phase cost nothing in the absolute deadline. -/
theorem after_onset (x : Int → Bool) (W S : Nat)
    (hW : ∀ p : Int, (W:Int)<p → x p=false)
    (hE : ∀ n, Rule30Realization.evol x (S+n) 0=drive n)
    (b : Bool) (T : Nat) (hT : S≤T) :
    ∃ t, T≤t ∧ t≤4*T+3*W+20 ∧ (t-S)%3=1 ∧ Rule30Realization.evol x t 1=b := by
  let F : Nat → Nat → Bool := fun t p => Rule30Realization.evol x t ((p:Int)-1)
  have hF : IsR30 F := by
    intro t p; dsimp [F,Rule30Realization.evol]
    congr 1 <;> congr 1 <;> omega
  let X : Nat → Nat → Bool := fun n p => F (S+n) p
  have hX : IsR30 X := fun n q => hF (S+n) q
  have hw : ∀ p, W+1<p → F 0 p=false := fun p hp => hW _ (by omega)
  have hwS : ∀ p, W+S+1<p → X 0 p=false := by
    intro p hp
    simpa [X] using white_tail_evol hF 0 (W+1) hw S p (by omega)
  have hX1 : ∀ n, X n 1=drive n := by simpa [X,F] using hE
  obtain ⟨n,h1,h2,h3,h4⟩ := gate_deadline hX hX1 (W+S) hwS b (T-S)
  exact ⟨S+n,by omega,by omega,by simpa using h3,by simpa [X,F] using h4⟩

/-- Closed geometric cut points give disjoint windows for successive witnesses. -/
def cut (W : Nat) : Nat → Nat
  | 0 => 0
  | n+1 => 4*cut W n+3*W+21

theorem cut_formula (W : Nat) : ∀ n, cut W n+(W+7) = 4^n*(W+7)
  | 0 => by simp [cut]
  | n+1 => by
    calc
      cut W (n+1)+(W+7) = 4*(cut W n+(W+7)) := by simp only [cut]; omega
      _ = 4*(4^n*(W+7)) := by rw [cut_formula W n]
      _ = 4^(n+1)*(W+7) := by simp [Nat.pow_succ,Nat.mul_comm,Nat.mul_assoc]

/-- Each color occurs in every geometric window, also when the left support is infinite. -/
theorem geometric_hits (x : Int → Bool) (W : Nat)
    (hW : ∀ p : Int, (W:Int)<p → x p=false) (hE : ∀ t, Rule30Realization.evol x t 0=drive t)
    (b : Bool) : ∃ s : Nat → Nat, (∀ k, s k < s (k+1)) ∧
    ∀ k, cut W k ≤ s k ∧ s k < cut W (k+1) ∧ s k%3=1 ∧ Rule30Realization.evol x (s k) 1=b := by
  have h := fun k => full_line_gate_deadline x W hW hE b (cut W k)
  let s := fun k => Classical.choose (h k)
  have hs (k : Nat) : cut W k ≤ s k ∧ s k < cut W (k+1) ∧ s k%3=1 ∧ Rule30Realization.evol x (s k) 1=b := by
    have hc := Classical.choose_spec (h k)
    change cut W k ≤ Classical.choose (h k) ∧ Classical.choose (h k) < 4*cut W k+3*W+21 ∧ _
    exact ⟨hc.1,by omega,hc.2.2⟩
  exact ⟨s,fun k => Nat.lt_of_lt_of_le (hs k).2.1 (hs (k+1)).1,hs⟩

private theorem left_read (x : Int → Bool) (t : Nat) (i : Int) :
    Rule30Realization.evol x t (i-1) = xor (Rule30Realization.evol x (t+1) i)
      (Rule30Realization.evol x t i || Rule30Realization.evol x t (i+1)) :=
  Rule30Realization.rule_left _ _ _

def gate (x : Int → Bool) (m : Nat) := !(Rule30Realization.evol x (3*m+1) 1)

/-- No support hypothesis enters the two neighboring column codes. -/
theorem block_code (x : Int → Bool) (hE : ∀ t, Rule30Realization.evol x t 0=drive t) (m : Nat) :
    let u := gate x m
    (Rule30Realization.evol x (3*m) (-1) = true ∧ Rule30Realization.evol x (3*m+1) (-1) = u ∧
     Rule30Realization.evol x (3*m+2) (-1) = false) ∧
    (Rule30Realization.evol x (3*m) (-2) = !u ∧ Rule30Realization.evol x (3*m+1) (-2) = u ∧
     Rule30Realization.evol x (3*m+2) (-2) = false) := by
  have l1 (t : Nat) : Rule30Realization.evol x t (-1) = xor (Rule30Realization.evol x (t+1) 0)
      (Rule30Realization.evol x t 0 || Rule30Realization.evol x t 1) := left_read x t 0
  have l2 (t : Nat) : Rule30Realization.evol x t (-2) = xor (Rule30Realization.evol x (t+1) (-1))
      (Rule30Realization.evol x t (-1) || Rule30Realization.evol x t 0) := by
    simpa only [show (-1:Int)-1 = -2 by decide,show (-1:Int)+1 = 0 by decide] using left_read x t (-1)
  have d0 (n : Nat) : Rule30Realization.evol x (3*n) (-1) = true := by
    rw [l1,hE,hE]; simp [drive,Nat.add_mod]
  have d1 : Rule30Realization.evol x (3*m+1) (-1) = gate x m := by
    rw [l1,hE,hE]; simp [drive,gate,Nat.add_mod]
  have d2 : Rule30Realization.evol x (3*m+2) (-1) = false := by
    rw [l1,hE,hE]; simp [drive,Nat.add_mod]
  refine ⟨⟨d0 m,d1,d2⟩,?_,?_,?_⟩
  · rw [l2,d0,d1]; simp
  · rw [l2,show 3*m+1+1=3*m+2 by omega,d2,d1]
    change (false ^^ (gate x m || Rule30Realization.evol x (3*m+1) 0)) = _
    rw [hE]; simp [drive,Nat.add_mod]
  · rw [l2,show 3*m+2+1=3*(m+1) by omega,d0,d2]
    change (true ^^ (false || Rule30Realization.evol x (3*m+2) 0)) = false
    rw [hE]; simp [drive,Nat.add_mod]

end Ruliology.CellularAutomata.Rule30QuietThirdGate
