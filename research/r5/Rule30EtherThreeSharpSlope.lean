module

public import Ruliology.CellularAutomata.Rule30PeriodThreeEntry

/-!
# The optimal entry slope beside a period-three column

The exceptional class-10 front of the period-three ether can advance eight
cells at a tick. `extend_back` shows that the transition can be repeated
indefinitely to the west in its finite preimages. The inverse needs only a
fixed local word and reduces the support bound by one at each step.

`family` gives rows with n eight-cell advances followed by a two-cell
advance into the recurrent class. The recurrent front retreats four cells
per ten ticks, so the rows of support 7n + O(1) still miss the corresponding
trap of `Rule30PeriodThreeEntry` at tick 21n + 1. This makes the known entry
slope of three optimal for 001 and for 011 (`sharp_001`, `sharp_011`).
The witnesses can miss by only a bounded additive time from 3D for every
large enough support allowance D (`late_001`, `late_011`).
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30EtherThreeSharpSlope

open Rule30Ether Rule30EtherThree Rule30EtherThreeErosion Rule30Jen
open Rule30EtherThreeDeparture Rule30PeriodThreeEntry Rule30PeriodThreeEntryTables

private theorem rule_cancel (a b c : Bool) : rule (rule a b c) b c = a := by
  cases a <;> cases b <;> cases c <;> rfl

/-- Invert a finitely supported right row by sweeping from its white tail. -/
def back (y : Nat → Bool) (B p : Nat) : Bool :=
  if p < B then rule (y (p+1)) (back y B (p+1)) (back y B (p+2)) else false
termination_by B-p
decreasing_by all_goals omega

theorem back_white (y : Nat → Bool) {B p : Nat} (h : B ≤ p) : back y B p = false := by
  rw [back, ite_eq_right (by omega)]

theorem back_eq {y : Nat → Bool} {B : Nat} (white : ∀ p, B < p → y p = false) (p : Nat) :
    back y B p = rule (y (p+1)) (back y B (p+1)) (back y B (p+2)) := by
  by_cases h : p < B
  · rw [back, ite_eq_left h]
  · rw [back_white y (by omega), white _ (by omega), back_white y (by omega), back_white y (by omega)]
    rfl

private def stepBack (b : Bool) (v : Bool × Bool) : Bool × Bool := (rule b v.1 v.2, v.1)

private def outputs (y : Nat → Bool) (p : Nat) : Nat → List Bool
  | 0 => []
  | n+1 => y (p+1) :: outputs y (p+1) n

private theorem outputs_get (y : Nat → Bool) (p : Nat) (word : List Bool)
    (h : ∀ i, i < word.length → y (p+1+i) = word.getD i false) :
    outputs y p word.length = word := by
  induction word generalizing p with
  | nil => rfl
  | cons b word ih =>
    have h0 : y (p+1) = b := by simpa using h 0 (by simp)
    simp only [List.length_cons, outputs, h0, List.cons.injEq, true_and]
    apply ih
    intro i hi
    simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using h (i+1) (by simpa using hi)

private theorem read_back {x y : Nat → Bool}
    (h : ∀ p, x p = rule (y (p+1)) (x (p+1)) (x (p+2))) (p n : Nat) :
    (outputs y p n).foldr stepBack (x (p+n), x (p+n+1)) = (x p, x (p+1)) := by
  induction n generalizing p with
  | zero => rfl
  | succ n ih =>
    have hp : p+(n+1) = p+1+n := by omega
    simp only [outputs, hp, List.foldr_cons, ih, stepBack]
    exact Prod.ext (h p).symm rfl

private theorem phase_zero : ∀ (j : Fin 12) (s : Fin 3),
    ether3 j s = ether3 (j+4*s) 0 := by decide

private theorem eth_class (j s p t : Nat) : eth j s p t = ether3 (cls j s p t) 0 := by
  unfold eth cls
  have a := phase_zero ⟨(j+p)%12, Nat.mod_lt _ (by decide)⟩
    ⟨(t+s)%3, Nat.mod_lt _ (by decide)⟩
  change ether3 ((j+p)%12) ((t+s)%3) = ether3 ((j+p)%12+4*((t+s)%3)) 0 at a
  rw [ether3_congr (j' := (j+p)%12) (φ' := (t+s)%3) (by omega) (by omega),a]
  apply ether3_congr _ rfl
  omega

private theorem before_bad {x y : Nat → Bool}
    (inv : ∀ p, x p = rule (y (p+1)) (x (p+1)) (x (p+2)))
    {j s d : Nat} (hd : 2 ≤ d) (hc : cls j s d 0 = 10)
    (pre : ∀ p, p < d+8 → y p = eth j s p 1)
    (bit0 : y (d+8) ≠ eth j s (d+8) 1)
    (bit1 : y (d+9) ≠ eth j s (d+9) 1) :
    (∀ p, p < d → x p = eth j s p 0) ∧
    x d ≠ eth j s d 0 ∧ x (d+1) ≠ eth j s (d+1) 0 := by
  have classAt (i : Nat) : cls j s (d-2+i) 1 = i % 12 := by unfold cls at hc ⊢; omega
  let word := [false,false,true,false,false,true,true,true,true,false,true]
  have sample : ∀ i, i < word.length → y (d-2+1+i) = word.getD i false := by
    intro i hi
    have iw : i < 11 := hi
    have digit (p : Nat) (h : p = d-2+(1+i)) : eth j s p 1 = ether3 (1+i) 0 := by
      rw [h, eth_class, classAt]
      exact ether3_congr (by omega) rfl
    if h : i < 9 then
      rw [pre _ (by omega), digit _ (by omega)]
      have table : ∀ k : Fin 9, ether3 (1+k) 0 = word.getD k false := by decide
      exact table ⟨i,h⟩
    else
      rcases (by omega : i = 9 ∨ i = 10) with rfl | rfl
      · rw [show d-2+1+9 = d+8 by omega]
        have h := ne_eth bit0
        rw [digit (d+8) (by omega)] at h
        exact h
      · rw [show d-2+1+10 = d+9 by omega]
        have h := ne_eth bit1
        rw [digit (d+9) (by omega)] at h
        exact h
  have hword := outputs_get y (d-2) word sample
  have left := read_back inv (d-2) 11
  change (outputs y (d-2) word.length).foldr stepBack _ = _ at left
  rw [hword] at left
  have final : ∀ a b : Bool, word.foldr stepBack (a,b) = (true,true) := by decide
  have hleft : (x (d-2), x (d-1)) = (true,true) := by
    rw [final, show d-2+1 = d-1 by omega] at left
    exact left.symm
  have rword : outputs y d 9 = word.drop 2 := by
    change outputs y d (word.drop 2).length = word.drop 2
    apply outputs_get y d (word.drop 2)
    intro i hi
    have len : (word.drop 2).length = 9 := rfl
    rw [len] at hi
    have h := sample (i+2) (show i+2 < 11 by omega)
    rw [show d-2+1+(i+2) = d+1+i by omega] at h
    have table : ∀ k : Fin 9, word.getD (k+2) false = (word.drop 2).getD k false := by decide
    exact h.trans (table ⟨i,hi⟩)
  have right := read_back inv d 9
  rw [rword] at right
  have rightPair : ∀ a b : Bool, (word.drop 2).foldr stepBack (a,b) = (false,true) := by decide
  rw [rightPair] at right
  have ec (i : Nat) : eth j s (d-2+i) 0 = ether3 (8+i) 0 := by
    rw [eth_class]
    apply ether3_congr _ rfl
    unfold cls at hc ⊢
    omega
  have spread : ∀ n p, p+n = d-2 →
      x p = eth j s p 0 ∧ x (p+1) = eth j s (p+1) 0 := by
    intro n
    induction n with
    | zero =>
      intro p hp
      have eq : p = d-2 := by omega
      subst p
      exact ⟨(congrArg Prod.fst hleft).trans (ec 0).symm,
        (show x (d-2+1) = true by rw [show d-2+1 = d-1 by omega]; exact congrArg Prod.snd hleft).trans (ec 1).symm⟩
    | succ n ih =>
      intro p hp
      obtain ⟨a,b⟩ := ih (p+1) (by omega)
      refine ⟨?_,a⟩
      rw [inv p, pre _ (by omega), a, b, eth_rule, rule_cancel]
  refine ⟨fun p hp => ?_, ?_, ?_⟩
  · if he : p = d-1 then
      subst p
      simpa [show d-2+1 = d-1 by omega] using (spread 0 (d-2) (by omega)).2
    else
      exact (spread (d-2-p) p (by omega)).1
  · have value : x d = false := (congrArg Prod.fst right).symm
    rw [value, ← show d-2+2 = d by omega, ec 2]
    decide
  · have value : x (d+1) = true := (congrArg Prod.snd right).symm
    rw [value, ← show d-2+3 = d+1 by omega, ec 3]
    decide

/-- The full history driven by ether column j in phase s. -/
def driven (j s : Nat) (R : Nat → Bool) := drv (fun t => eth j s 0 t) R

private theorem wall (j s t : Nat) (R : Nat → Bool) : driven j s R t 0 = eth j s 0 t :=
  drv_col0 _ _ _

private theorem eth_shift (j s p t : Nat) : eth j s p (t+1) = eth j (s+1) p t := by
  unfold eth
  rw [show t+1+s = t+(s+1) by omega]

private theorem shift (j s : Nat) (R Y : Nat → Bool)
    (h : ∀ p, 1 ≤ p → driven j s R 1 p = Y p) (t p : Nat) :
    driven j s R (t+1) p = driven j (s+1) Y t p := by
  induction t generalizing p with
  | zero =>
    cases p with
    | zero => rw [wall,wall,eth_shift]
    | succ p => exact (h _ (by omega)).trans (drv_init _ _ _ (by omega)).symm
  | succ t ih =>
    cases p with
    | zero => rw [wall,wall,eth_shift]
    | succ p =>
      change rule (driven j s R (t+1) p) (driven j s R (t+1) (p+1))
          (driven j s R (t+1) (p+2)) =
        rule (driven j (s+1) Y t p) (driven j (s+1) Y t (p+1))
          (driven j (s+1) Y t (p+2))
      rw [ih,ih,ih]

/-- Any finite row with an exceptional front has a finite predecessor with
the exceptional front eight places west, when the phase is moved back by one.
The support bound drops by one. -/
theorem extend_back {j s d B : Nat} {Y : Nat → Bool}
    (hd : 2 ≤ d) (hc : cls j s d 0 = 10)
    (white : ∀ p, B < p → Y p = false)
    (F : Front (driven j (s+1) Y) j (s+1) 0 (d+8))
    (bad : IsB (driven j (s+1) Y) j (s+1) 0 (d+8)) :
    ∃ R, (∀ p, B ≤ p → R p = false) ∧
      Front (driven j s R) j s 0 d ∧ IsB (driven j s R) j s 0 d ∧
      ∀ t p, driven j s R (t+1) p = driven j (s+1) Y t p := by
  let X := back Y B
  let last := driven j (s+1) Y
  have agree (p : Nat) (hp : 0 < p) : last 0 p = Y p := drv_init _ _ _ hp
  -- The value of the output at site zero is immaterial to the inverse.
  let Z : Nat → Bool := last 0
  have eqY (p : Nat) : Z (p+1) = Y (p+1) := agree _ (by omega)
  have inv (p : Nat) : X p = rule (Z (p+1)) (X (p+1)) (X (p+2)) := by
    rw [eqY]
    exact back_eq white p
  have hbad : last 0 (d+9) ≠ eth j (s+1) (d+9) 0 := by
    unfold IsB isBad at bad
    simp only [Bool.and_eq_true] at bad
    have u := bad.2
    unfold ubit at u
    exact bne_iff_ne.mp u
  obtain ⟨pre,b0,b1⟩ := before_bad inv hd hc
    (fun p hp => (F.1 p hp).trans (eth_shift _ _ _ _).symm)
    (by rw [eth_shift]; exact F.2)
    (by rw [eth_shift]; exact hbad)
  have init (p : Nat) (hp : 0 < p) : driven j s X 0 p = X p := drv_init _ _ _ hp
  have all (p : Nat) : driven j s X 0 p = X p := by
    cases p with
    | zero => rw [wall, pre 0 (by omega)]
    | succ p => exact init _ (by omega)
  refine ⟨X, fun p h => back_white _ h, ⟨fun p hp => (all p).trans (pre p hp), ?_⟩, ?_, ?_⟩
  · rwa [all]
  · unfold IsB isBad ubit
    rw [hc, all]
    simpa using bne_iff_ne.mpr b1
  · apply shift
    intro p hp
    obtain ⟨a,rfl⟩ : ∃ a, p=a+1 := ⟨p-1,by omega⟩
    change rule (driven j s X 0 a) (driven j s X 0 (a+1)) (driven j s X 0 (a+2)) = Y (a+1)
    rw [all,all,all, inv a, rule_cancel, eqY]

private def terminal (j s d p : Nat) : Bool :=
  if p < d then eth j s p 0 else p == d+1 || p == d+4

private theorem terminal_step {j s d : Nat} (hd : 2 ≤ d) (hc : cls j s d 0 = 10) :
    let F := driven j s (terminal j s d)
    Front F j s 0 d ∧ IsB F j s 0 d ∧ Front F j s 1 (d+2) ∧ IsRec F j s 1 (d+2) := by
  intro F
  have evo : IsR30 F := drv_isR30 _ _
  have ef (i : Nat) : eth j s (d-2+i) 0 = ether3 (8+i) 0 := by
    rw [eth_class]
    apply ether3_congr _ rfl
    unfold cls at hc ⊢
    omega
  have ef' (i : Nat) : eth j s (d-2+i) 1 = ether3 i 0 := by
    rw [eth_class]
    apply ether3_congr _ rfl
    unfold cls at hc ⊢
    omega
  have init (p : Nat) : F 0 p = terminal j s d p := by
    cases p with
    | zero => rw [show F 0 0 = eth j s 0 0 from wall .., terminal, ite_eq_left (by omega)]
    | succ p => exact drv_init _ _ _ (by omega)
  have eqr (p : Nat) (hp : p < d) : F 0 p = eth j s p 0 := by rw [init,terminal,ite_eq_left hp]
  have near (i : Nat) (hi : i < 7) :
      F 0 (d-2+i) = ([true,true,false,true,false,false,true] : List Bool).getD i false := by
    rw [init,terminal]
    by_cases low : i < 2
    · rw [ite_eq_left (by omega), ef]
      have ans : ∀ k : Fin 2, ether3 (8+k) 0 = ([true,true,false,true,false,false,true] : List Bool).getD k false := by decide
      exact ans ⟨i,low⟩
    · rw [ite_eq_right (by omega)]
      have ans : ∀ k : Fin 5, ((k.val == 1) || (k.val == 4)) =
          ([true,true,false,true,false,false,true] : List Bool).getD (k+2) false := by decide
      have eq1 : (d-2+i == d+1) = (i-2 == 1) := by
        apply Bool.eq_iff_iff.mpr
        simp only [beq_iff_eq]; omega
      have eq2 : (d-2+i == d+4) = (i-2 == 4) := by
        apply Bool.eq_iff_iff.mpr
        simp only [beq_iff_eq]; omega
      rw [eq1,eq2]
      simpa [show i-2+2 = i by omega] using ans ⟨i-2,by omega⟩
  have cut (i : Nat) (hi : i < 5) :
      F 1 (d-1+i) = ([false,false,true,true,true] : List Bool).getD i false := by
    have eq : d-1+i = (d-2+i)+1 := by omega
    rw [eq, evo, near _ (by omega),
      show d-2+i+1 = d-2+(i+1) by omega, near _ (by omega),
      show d-2+i+2 = d-2+(i+2) by omega, near _ (by omega)]
    have ans : ∀ k : Fin 5,
        rule (([true,true,false,true,false,false,true] : List Bool).getD k false)
          (([true,true,false,true,false,false,true] : List Bool).getD (k+1) false)
          (([true,true,false,true,false,false,true] : List Bool).getD (k+2) false) =
          ([false,false,true,true,true] : List Bool).getD k false := by decide
    exact ans ⟨i,hi⟩
  have localbit (i : Nat) : eth j s (d-1+i) 1 = ether3 (1+i) 0 := by
    rw [show d-1+i = d-2+(1+i) by omega,ef']
  have oldFront : Front F j s 0 d := ⟨eqr, by
    rw [← show d-2+2 = d by omega, near _ (by omega), ef]; decide⟩
  have oldBad : IsB F j s 0 d := by
    unfold IsB isBad ubit
    rw [hc, ← show d-2+3 = d+1 by omega, near _ (by omega), ef]
    decide
  have nextFront : Front F j s 1 (d+2) := ⟨fun p hp => by
    by_cases l : p < d-1
    · exact prefix_step (drv_isR30 _ _) (wall ..) eqr p (by omega)
    · obtain ⟨i, e, hi⟩ : ∃ i, p=d-1+i ∧ i < 3 := ⟨p-(d-1),by omega,by omega⟩
      rw [e,cut _ (by omega),localbit]
      have tab : ∀ k : Fin 3, ([false,false,true,true,true] : List Bool).getD k false = ether3 (1+k) 0 := by decide
      exact tab ⟨i,hi⟩,
    by rw [← show d-1+3 = d+2 by omega,cut _ (by omega),localbit]; decide⟩
  have c : cls j s (d+2) 1 = 4 := by unfold cls at hc ⊢; omega
  refine ⟨oldFront,oldBad,nextFront,?_⟩
  unfold IsRec ubit
  rw [c, ← show d-1+4 = d+2+1 by omega, cut _ (by omega),localbit]
  decide

/-- A finite row realizes n consecutive eight-column advances, followed by
a two-column advance into the recurrent class. -/
theorem family (j : Nat) : ∀ n d s : Nat, 2 ≤ d → cls j s d 0 = 10 →
    ∃ R, (∀ p, d+7*n+4 < p → R p = false) ∧
      (∀ k, k ≤ n → Front (driven j s R) j s k (d+8*k) ∧
        IsB (driven j s R) j s k (d+8*k)) ∧
      Front (driven j s R) j s (n+1) (d+8*n+2) ∧
      IsRec (driven j s R) j s (n+1) (d+8*n+2) := by
  intro n
  induction n with
  | zero =>
    intro d s hd hc
    obtain ⟨hf,hb,hn,hr⟩ := terminal_step hd hc
    refine ⟨terminal j s d, ?_, fun k hk => ?_, by simpa using hn, by simpa using hr⟩
    · intro p hp
      unfold terminal
      rw [ite_eq_right (by omega)]
      simp [show p ≠ d+1 by omega, show p ≠ d+4 by omega]
    · have eq : k = 0 := by omega
      subst k
      simpa using And.intro hf hb
  | succ n ih =>
    intro d s hd hc
    have next : cls j (s+1) (d+8) 0 = 10 := by unfold cls at hc ⊢; omega
    obtain ⟨Y,hy,chain,hf,hr⟩ := ih (d+8) (s+1) (by omega) next
    have start := chain 0 (by omega)
    simp only [Nat.mul_zero, Nat.add_zero] at start
    obtain ⟨R,hw,h0,hb,eval⟩ := extend_back hd hc hy start.1 start.2
    have cs (p t : Nat) : cls j s p (t+1) = cls j (s+1) p t := by
      unfold cls
      congr 1
      omega
    have ft (t p : Nat) (h : Front (driven j (s+1) Y) j (s+1) t p) :
        Front (driven j s R) j s (t+1) p :=
      ⟨fun q hq => by rw [eval,eth_shift]; exact h.1 q hq,
        by rw [eval,eth_shift]; exact h.2⟩
    have ut (t p : Nat) : ubit (driven j s R) j s (t+1) p =
        ubit (driven j (s+1) Y) j (s+1) t p := by
      unfold ubit
      rw [eval,eth_shift]
    refine ⟨R, fun p hp => hw p (by omega), ?_, ?_, ?_⟩
    · intro k hk
      cases k with
      | zero => simpa using And.intro h0 hb
      | succ k =>
        have eq : d+8*(k+1) = d+8+8*k := by omega
        obtain ⟨a,b⟩ := chain k (by omega)
        rw [eq]
        exact ⟨ft _ _ a, by unfold IsB at *; rwa [cs,ut]⟩
    · rw [show d+8*(n+1)+2 = d+8+8*n+2 by omega]
      exact ft _ _ hf
    · rw [show d+8*(n+1)+2 = d+8+8*n+2 by omega]
      unfold IsRec at *
      rwa [cs,ut]

private theorem return_front {F : Nat → Nat → Bool} {j s : Nat} (hF : IsR30 F)
    (h0 : ∀ t, F t 0 = eth j s 0 t) {d : Nat} (hd : 7 ≤ d) :
    ∀ n t, Front F j s t (d+4*n) → IsRec F j s t (d+4*n) →
      Front F j s (t+10*n) d := by
  intro n
  induction n with
  | zero => intro t h _; simpa using h
  | succ n ih =>
    intro t h r
    obtain ⟨hf,hr,_⟩ := ten_ticks hF (fun u _ => h0 u) h r (by omega)
    rw [show d+4*(n+1)-4 = d+4*n by omega] at hf hr
    simpa only [show t+10+10*n = t+10*(n+1) by omega] using ih (t+10) hf hr

private theorem example_row (w : List Bool) (trap : List Nat) (j s d g n : Nat)
    (align : ∀ k, ether3 j k = wordAt3 w k) (hd : 14 < d)
    (hc : cls j s d 0 = 10) (hg : (s+1)%3 = g%3)
    (outside : code (fun _ p => ether3 (j+p) g) 0 14 ∉ trap) :
    ∃ R, (∀ p, 7*n+d+4 < p → R p = false) ∧
      ¬ InTrap trap (half w R s) (21*n+1) := by
  obtain ⟨R,hwhite,_,hf,hr⟩ := family j n d s (by omega) hc
  let F := driven j s R
  have eq : d+8*n+2 = d+2+4*(2*n) := by omega
  rw [eq] at hf hr
  have last := return_front (drv_isR30 _ _) (wall j s · R) (show 7 ≤ d+2 by omega) (2*n) (n+1) hf hr
  rw [show n+1+10*(2*n) = 21*n+1 by omega] at last
  have same : code F (21*n+1) 14 = code (fun _ p => ether3 (j+p) g) 0 14 := by
    unfold code
    congr 1
    apply Rule30Ether.seg_congr
    intro i hi
    exact (last.1 (i+1) (by omega)).trans (ether3_congr rfl (by omega))
  have run : half w R s = F := by
    have hWall : (fun t => wordAt3 w (t+s)) = (fun t => eth j s 0 t) := by
      funext t
      unfold eth
      rw [Nat.add_zero, align]
    exact congrArg (fun c => drv c R) hWall
  exact ⟨R,fun p hp => hwhite p (by omega), by rwa [run,InTrap,same]⟩

set_option maxRecDepth 10000 in
/-- Arbitrarily large finite rows beside 001 stay outside the S16 trap at
gate ticks 21n+1, with support at most 7n+26. -/
theorem delayed_001 (n : Nat) :
    ∃ R, (∀ p, 7*n+26 < p → R p = false) ∧
      ¬ InTrap trap001 (half w001 R 0) (21*n+1) := by
  have out : code (fun _ p => ether3 p 1) 0 14 ∉ trap001 := by decide +kernel
  simpa using example_row w001 trap001 0 0 22 1 n
    (aligned3_spec (w := w001) (j0 := 0) (s := 0) (by decide))
    (by decide) (by decide) (by decide) (by simpa using out)

set_option maxRecDepth 10000 in
/-- Beside 011 the same gate ticks can miss the trap with support at most 7n+31. -/
theorem delayed_011 (n : Nat) :
    ∃ R, (∀ p, 7*n+31 < p → R p = false) ∧
      ¬ InTrap trap011 (half w011 R 2) (21*n+1) := by
  have out : code (fun _ p => ether3 (11+p) 0) 0 14 ∉ trap011 := by decide +kernel
  simpa using example_row w011 trap011 11 2 27 0 n
    (aligned3_spec (w := w011) (j0 := 11) (s := 0) (by decide))
    (by decide) (by decide) (by decide) out

private theorem affine_arith {p q r c : Nat} (h : p < 3*q) :
    let n := p*c+r
    p*(7*n+c)+r ≤ q*(21*n+1) := by
  intro n
  have a := Nat.mul_le_mul_right n (show 7*p+1 ≤ 21*q by omega)
  have l : p*(7*n+c)+r = (7*p+1)*n := by
    rw [Nat.mul_add, Nat.add_mul, Nat.one_mul, ← Nat.mul_assoc, Nat.mul_comm p 7]
    dsimp [n]
    omega
  have u : q*(21*n+1) = 21*q*n+q := by
    rw [Nat.mul_add, Nat.mul_one, ← Nat.mul_assoc, Nat.mul_comm q 21]
  rw [l,u]
  exact Nat.le_trans a (Nat.le_add_right ..)

/-- The S16 upper bound of slope three is optimal for the 001 trap. -/
theorem sharp_001 {p q r : Nat}
    (h : ∀ (R : Nat → Bool) (D : Nat), (∀ x, D < x → R x = false) → ∀ φ t, (t+φ)%3 = 1 →
      p*D+r ≤ q*t → InTrap trap001 (half w001 R φ) t) : 3*q ≤ p := by
  apply Nat.le_of_not_lt
  intro lt
  obtain ⟨R,hw,out⟩ := delayed_001 (p*26+r)
  exact out (h R _ hw 0 _ (by omega) (affine_arith lt))

/-- The S16 upper bound of slope three is optimal for the 011 trap. -/
theorem sharp_011 {p q r : Nat}
    (h : ∀ (R : Nat → Bool) (D : Nat), (∀ x, D < x → R x = false) → ∀ φ t, (t+φ)%3 = 0 →
      p*D+r ≤ q*t → InTrap trap011 (half w011 R φ) t) : 3*q ≤ p := by
  apply Nat.le_of_not_lt
  intro lt
  obtain ⟨R,hw,out⟩ := delayed_011 (p*31+r)
  exact out (h R _ hw 2 _ (by omega) (affine_arith lt))

/-- A trap miss within 95 ticks of 3D exists for every support allowance D ≥ 26. -/
theorem late_001 {D : Nat} (hD : 26 ≤ D) :
    ∃ R t, (∀ p, D < p → R p = false) ∧ t % 3 = 1 ∧ 3*D ≤ t+95 ∧
      ¬ InTrap trap001 (half w001 R 0) t := by
  let n := (D-26)/7
  obtain ⟨R,hw,out⟩ := delayed_001 n
  refine ⟨R,21*n+1,fun p hp => hw p (by dsimp [n]; omega),by omega,?_ ,out⟩
  dsimp [n]
  omega

/-- A trap miss within 110 ticks of 3D exists for every support allowance D ≥ 31. -/
theorem late_011 {D : Nat} (hD : 31 ≤ D) :
    ∃ R t, (∀ p, D < p → R p = false) ∧ (t+2)%3 = 0 ∧ 3*D ≤ t+110 ∧
      ¬ InTrap trap011 (half w011 R 2) t := by
  let n := (D-31)/7
  obtain ⟨R,hw,out⟩ := delayed_011 n
  refine ⟨R,21*n+1,fun p hp => hw p (by dsimp [n]; omega),by omega,?_ ,out⟩
  dsimp [n]
  omega

end Ruliology.CellularAutomata.Rule30EtherThreeSharpSlope
