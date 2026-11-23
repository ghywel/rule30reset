module
public import Ruliology.CellularAutomata.Rule30FiniteMaskedJen
public import Ruliology.CellularAutomata.Rule30Prize

/-! Finite-duration comparison with the rotating 84-cell ether. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelPureThreeDeadline
open Rule30Realization Rule30FiniteMaskedJen Rule30Jen

/-- Observations needed to carry a clock through n updates. The last eastern bit is unused. -/
def Matches (x y : Int → Bool) (n : Nat) : Prop :=
  (∀ t, t ≤ n → evol x t 0 = evol y t 0) ∧
  ∀ t, t < n → orCol x 0 t = orCol y 0 t

/-- The cross-configuration form of the kit's masked sideways reconstruction. -/
theorem west_of_match {x y : Int → Bool} {n : Nat} (h : Matches x y n) :
    ∀ d t : Nat, t+d ≤ n →
      evol x t (-(d:Int)) = evol y t (-(d:Int)) ∧
      (t+d < n → orCol x (-(d:Int)) t = orCol y (-(d:Int)) t) := by
  intro d
  induction d with
  | zero =>
    intro t ht
    simpa using And.intro (h.1 t (by omega)) (h.2 t)
  | succ d ih =>
    intro t ht
    have eq : evol x t (-(d.succ:Int)) = evol y t (-(d.succ:Int)) := by
      rw [show -(d.succ:Int) = -(d:Int)-1 by omega, evol_left', evol_left',
        (ih (t+1) (by omega)).1, (ih t (by omega)).2 (by omega)]
    refine ⟨eq, fun _ => ?_⟩
    unfold orCol
    rw [eq, show -(d.succ:Int)+1 = -(d:Int) by omega, (ih t (by omega)).1]

/-- Given the matched history, the westmost discrepant bit reaches site −1
at the last tick. The two update inputs there except the western one agree. -/
private theorem mismatch_ray {x y : Int → Bool} {d : Nat} (pos : 0<d)
    (past : Matches x y (d-1)) (miss : x (-(d:Int)) ≠ y (-(d:Int))) :
    ∀ t k : Nat, 0<k → t+k=d → evol x t (-(k:Int)) ≠ evol y t (-(k:Int)) := by
  intro t
  induction t with
  | zero =>
    intro k _ h
    obtain rfl : k=d := by omega
    exact miss
  | succ t ih =>
    intro k hk h
    have diff := ih (k+1) (by omega) (by omega)
    have same := (west_of_match past k t (by omega)).1
    have east := (west_of_match past (k-1) t (by omega)).1
    rw [show -((k-1:Nat):Int)=-(k:Int)+1 by omega] at east
    rw [show -((k+1:Nat):Int)=-(k:Int)-1 by omega] at diff
    change rule _ _ _ ≠ rule _ _ _
    rw [same,east]
    exact fun eq => diff (Bool.xor_left_inj.mp eq)

/-- At the first spatial mismatch, a compensating gate bit keeps the centre on
the ring. If the old centre is black, such compensation is impossible. -/
theorem last_tick_fork {x y : Int → Bool} {d : Nat} (pos : 0<d)
    (past : Matches x y (d-1)) (miss : x (-(d:Int)) ≠ y (-(d:Int))) :
    (evol x d 0 = evol y d 0 ↔ orCol x 0 (d-1) ≠ orCol y 0 (d-1)) := by
  obtain ⟨h,rfl⟩ : ∃ h, d=h+1 := ⟨d-1,by omega⟩
  have ne := mismatch_ray pos past miss h 1 (by omega) (by omega)
  change evol x h (-1) ≠ evol y h (-1) at ne
  change (xor (evol x h (-1)) (orCol x 0 h) = xor (evol y h (-1)) (orCol y 0 h)) ↔ _
  simp only [Nat.add_one_sub_one]
  revert ne
  cases evol x h (-1) <;> cases evol y h (-1) <;> cases orCol x 0 h <;>
    cases orCol y 0 h <;> decide

/-- The same radius-t initial segment gives the same central cell. -/
private theorem cone {x y : Int → Bool} (t : Nat) (p : Int)
    (h : ∀ i, p-t ≤ i → i ≤ p+t → x i = y i) : evol x t p = evol y t p := by
  induction t generalizing p with
  | zero => exact h p (by omega) (by omega)
  | succ t ih =>
    change rule _ _ _ = rule _ _ _
    rw [ih (p-1) (fun i a b => h i (by omega) (by omega)),
        ih p (fun i a b => h i (by omega) (by omega)),
        ih (p+1) (fun i a b => h i (by omega) (by omega))]

/-- At the earliest depth d inconsistent with a prescribed black edge W,
no completion can match through tick d. A finite completion matches through d-1. -/
theorem sharp_edge {y : Int → Bool} {W d : Nat} (hd : 0 < d) (hw : W ≤ d)
    (early : ∀ i : Nat, W ≤ i → i < d → y (-(i:Int)) = decide (i = W))
    (bad : y (-(d:Int)) ≠ decide (d = W)) :
    (∀ x : Int → Bool, x (-(W:Int)) = true →
      (∀ i, i < -(W:Int) → x i = false) → ¬Matches x y d) ∧
    (∃ x : Int → Bool, x (-(W:Int)) = true ∧ (∀ i, i < -(W:Int) → x i = false) ∧
      (∀ i, (d:Int) < i → x i = false) ∧ Matches x y (d-1)) := by
  constructor
  · intro x hb hz h
    have eq := (west_of_match h d 0 (by omega)).1
    change x (-(d:Int)) = y (-(d:Int)) at eq
    apply bad
    by_cases e : d = W
    · subst d
      simpa using eq.symm.trans hb
    · rw [←eq, hz _ (by omega)]
      simp [e]
  · let x := fun p : Int => if p < -(W:Int) then false else if p = -(W:Int) then true
      else if p ≤ (d:Int) then y p else false
    have same : ∀ i : Int, -(d:Int) < i → i ≤ (d:Int) → x i = y i := by
      intro i hl hr
      by_cases a : i < -(W:Int)
      · let j := (-i).toNat
        have ji : -(j:Int) = i := by dsimp [j]; omega
        have k := early j (by dsimp [j]; omega) (by dsimp [j]; omega)
        have ne : j ≠ W := by omega
        simpa [x,a,ji,ne] using k.symm
      · by_cases e : i = -(W:Int)
        · subst i
          have k := early W (by omega) (by omega)
          simpa [x] using k.symm
        · simp [x,a,e,hr]
    refine ⟨x, by simp [x], fun i h => by simp [x,h], fun i h => ?_, ?_, ?_⟩
    · simp [x,show ¬i < -(W:Int) by omega,show i ≠ -(W:Int) by omega,show ¬i ≤ (d:Int) by omega]
    · intro t ht
      exact cone t 0 (fun i a b => same i (by omega) (by omega))
    · intro t ht
      unfold orCol
      simp only [Int.zero_add]
      rw [cone (x:=x) (y:=y) t 0 (fun i a b => same i (by omega) (by omega)),
          cone (x:=x) (y:=y) t 1 (fun i a b => same i (by omega) (by omega))]

/-- Black-first temporal phase, site 0 at the wall. The ring shifts 14 sites per tick. -/
def bit (k : Int) : Bool := (0xc7b9a23add2917bec2099 : Nat).testBit (k%84).toNat
def row (s : Nat) (p : Int) : Bool := bit (p+70*(s:Int))

private theorem ring_rule (k : Int) : bit (k+70) = rule (bit (k-1)) (bit k) (bit (k+1)) := by
  have tab : ∀ i : Fin 84, bit (i.val+70) = rule (bit ((i.val:Int)-1)) (bit i.val) (bit (i.val+1)) := by
    decide +kernel
  have h := tab ⟨(k%84).toNat,by omega⟩
  simpa only [bit,show ((k%84).toNat:Int) = k%84 by omega,
    show (k%84+70)%84 = (k+70)%84 by omega,show (k%84-1)%84 = (k-1)%84 by omega,
    show (k%84+1)%84 = (k+1)%84 by omega,Int.emod_emod] using h

theorem film (s t : Nat) (p : Int) : evol (row s) t p = row (s+t) p := by
  induction t generalizing p with
  | zero => rfl
  | succ t ih =>
    change rule _ _ _ = _
    rw [ih (p-1),ih p,ih (p+1)]
    unfold row
    rw [show p-1+70*((s+t:Nat):Int) = p+70*((s+t:Nat):Int)-1 by omega,
        show p+1+70*((s+t:Nat):Int) = p+70*((s+t:Nat):Int)+1 by omega,
        show p+70*((s+(t+1):Nat):Int) = (p+70*((s+t:Nat):Int))+70 by omega]
    exact (ring_rule _).symm

/-- All six temporal alignments carry the alternating centre and the pure-three white gate. -/
theorem signals (s t : Nat) :
    evol (row s) t 0 = decide ((s+t)%2=0) ∧
    ((s+t)%2=1 → evol (row s) t 1 = decide ((s+t)%6=1)) := by
  rw [film,film]
  have h : ∀ a : Fin 6, row a.val 0 = decide (a.val%2=0) ∧
      (a.val%2=1 → row a.val 1 = decide (a.val%6=1)) := by decide +kernel
  have q := h ⟨(s+t)%6, by omega⟩
  simp only [row,bit] at q ⊢
  have proj (p : Int) : (p+70*(((s+t)%6:Nat):Int))%84 = (p+70*((s+t:Nat):Int))%84 := by omega
  simpa only [proj,show (s+t)%6%2=(s+t)%2 by omega, Nat.mod_mod] using q

/-- The black edge at depth W must disagree there or within the next six sites. -/
theorem first_miss (s W : Nat) : ∃ d : Nat, W ≤ d ∧ d ≤ W+6 ∧
    (∀ i : Nat, W ≤ i → i < d → row s (-(i:Int)) = decide (i=W)) ∧
    row s (-(d:Int)) ≠ decide (d=W) := by
  let r := ((70*(s:Int)-(W:Int))%84).toNat
  have h : ∀ k : Fin 84, ∃ z : Fin 7,
      (∀ j : Fin 7, j.val < z.val → bit ((k.val:Int)-j.val) = decide (j.val=0)) ∧
      bit ((k.val:Int)-z.val) ≠ decide (z.val=0) := by decide +kernel
  obtain ⟨z,prev,miss⟩ := h ⟨r,by dsimp [r]; omega⟩
  have bit_eq (j : Nat) : row s (-((W+j:Nat):Int)) = bit ((r:Int)-j) := by
    unfold row bit
    congr 2
    dsimp [r]
    omega
  refine ⟨W+z.val, by omega, by have := z.isLt; omega, ?_, ?_⟩
  · intro i lower upper
    let j := i-W
    have i_eq : i = W+j := by dsimp [j];omega
    have z_lt := z.isLt
    have hj : j<z.val := by omega
    have v := prev ⟨j,by omega⟩ hj
    rw [i_eq,bit_eq]
    simpa only [Nat.add_eq_left] using v
  · rw [bit_eq]
    simpa only [Nat.add_eq_left] using miss

/-- For each spatial edge and gate alignment, the maximal finite matching horizon is d-1. -/
theorem sharp_pure_three (s W : Nat) (pos : 0<W) : ∃ d : Nat, W ≤ d ∧ d ≤ W+6 ∧
    (∀ x : Int → Bool, x (-(W:Int)) = true →
      (∀ i, i < -(W:Int) → x i = false) → ¬Matches x (row s) d) ∧
    (∃ x : Int → Bool, x (-(W:Int)) = true ∧ (∀ i, i < -(W:Int) → x i = false) ∧
      (∀ i, (d:Int)<i → x i = false) ∧ Matches x (row s) (d-1)) := by
  obtain ⟨d,lower,upper,before,miss⟩ := first_miss s W
  exact ⟨d,lower,upper,sharp_edge (by omega) lower before miss⟩

/-- The edge-distance correction of six is needed by the family. -/
theorem six_is_attained :
    (∀ x : Int → Bool, x (-71) = true → (∀ i, i < -71 → x i = false) →
      ¬Matches x (row 0) 77) ∧
    ∃ x : Int → Bool, x (-71) = true ∧ (∀ i, i < -71 → x i = false) ∧
      (∀ i, 77 < i → x i = false) ∧ Matches x (row 0) 76 := by
  apply sharp_edge (W:=71) (d:=77) (by decide) (by decide)
  · intro i hlo hhi
    have tab : ∀ j : Fin 6, row 0 (-((71+j.val:Nat):Int)) = decide (71+j.val=71) := by decide +kernel
    simpa only [show 71+(i-71)=i by omega] using tab ⟨i-71,by omega⟩
  · decide +kernel

private theorem restart (A t : Nat) (p : Int) : evol (cell A) t p = cell (A+t) p := by
  induction t generalizing p with
  | zero => rfl
  | succ t ih =>
    change rule _ _ _ = rule _ _ _
    rw [ih,ih,ih]
    rfl

/-- In the true singleton, some centre or white-time gate observation must
differ by absolute tick 2A+6. A is the age at the start of the comparison. -/
theorem singleton_deadline (A s : Nat) :
    ¬ ((∀ t, t≤A+6 → cell (A+t) 0 = decide ((s+t)%2=0)) ∧
       (∀ t, t<A+6 → (s+t)%2=1 → cell (A+t) 1 = decide ((s+t)%6=1))) := by
  rintro ⟨clock,gate⟩
  by_cases zero : A=0
  · subst A
    have b := clock 0 (by decide)
    have c := clock 1 (by decide)
    have p : (s+0)%2=0 := of_decide_eq_true (show true = decide ((s+0)%2=0) from b).symm
    have q : (s+1)%2=0 := of_decide_eq_true (show true = decide ((s+1)%2=0) from c).symm
    omega
  have pos : 0<A := by omega
  obtain ⟨d,_,bound,no,_⟩ := sharp_pure_three s A pos
  apply no (cell A) (cell_left_edge A) (cell_eq_false_of_lt A)
  refine ⟨fun t ht => ?_,fun t ht => ?_⟩
  · rw [restart,clock t (by omega),(signals s t).1]
  · unfold orCol
    rw [restart,restart,clock t (by omega),(signals s t).1]
    by_cases even : (s+t)%2=0
    · simp [even]
    · have odd : (s+t)%2=1 := by omega
      simp only [show (0:Int)+1=1 by decide,gate t (by omega) odd,(signals s t).2 odd]

end Ruliology.CellularAutomata.WheelPureThreeDeadline
