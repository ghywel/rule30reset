module

public import Ruliology.CellularAutomata.Rule30PeriodThreeEntry
public import Ruliology.CellularAutomata.Rule30EtherThreeTrap

/-! A finite right half beside 011 reads both colours arbitrarily late at
white ticks. The two constant gates can be read by infinite ether halves.
Matching either ether on the mask would preserve one interior ether column
of a finite augmented half. The erosion theorem gives a deadline for that
match to fail. Combined with the earlier gap theorem, white gaps are
eventually bounded by 17 sampled readings, including the all-black case. -/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30PeriodThreeGateChanges

open Rule30Ether Rule30EtherThree Rule30EtherThreeErosion Rule30Jen
open Rule30PeriodThreeEntry Rule30PeriodThreeEntryTables

private theorem masked_step (l c r r' : Bool) (agree : c = false → r = r') :
    rule l c r = rule l c r' := by
  cases c with
  | false => rw [agree rfl]
  | true => cases l <;> cases r <;> cases r' <;> rfl

/-- Within a bounded time after T, a finite half disagrees with any aligned
period-three ether at a white tick of the imposed drive. The initial support
bound is D, and the time and support after restart use physical ticks. -/
theorem masked_ether_break {w : List Bool} {R : Nat → Bool} {D j φ T : Nat}
    (finite : ∀ p, D < p → R p = false)
    (align : ∀ ψ, ether3 (j+1) ψ = wordAt3 w ψ) :
    ∃ t, T ≤ t ∧ t ≤ T+3*(D+T+13)+6 ∧
      wordAt3 w (t+φ) = false ∧ half w R φ t 1 ≠ eth j φ 2 t := by
  apply Classical.byContradiction
  intro none
  let H := half w R φ
  let S := T+φ
  let B := D+T+1
  let U := 3*(D+T+13)+6
  let E : Nat → Nat → Bool := fun t p => match p with
    | 0 => eth j S 0 t
    | p+1 => H (T+t) p
  let F := drv (fun t => eth j S 0 t) (E 0)
  have phase (t p : Nat) : eth j S p t = eth j φ p (T+t) := by
    unfold eth S
    rw [show t+(T+φ) = T+t+φ by omega]
  have centre (t : Nat) : E t 1 = eth j S 1 t := by
    change H (T+t) 0 = eth j S 1 t
    rw [show H (T+t) 0 = wordAt3 w (T+t+φ) from half_zero .., phase]
    exact (align _).symm
  have mask (t : Nat) (ht : t ≤ U) (h : E t 1 = false) : E t 2 = eth j S 2 t := by
    apply Classical.byContradiction
    intro ne
    apply none
    refine ⟨T+t,by omega,by dsimp [U] at ht; omega,?_,?_⟩
    · exact (half_zero w R φ (T+t)).symm.trans h
    · rwa [← phase]
  have localRule (u : Nat) (hu : u < U) (p : Nat) :
      E (u+1) (p+1) = rule (E u p) (E u (p+1)) (E u (p+2)) := by
    cases p with
    | zero =>
      calc
        E (u+1) 1 = eth j S 1 (u+1) := centre _
        _ = rule (E u 0) (eth j S 1 u) (eth j S 2 u) := eth_rule _ _ _ _
        _ = rule (E u 0) (E u 1) (E u 2) := by
          rw [← centre u]
          apply masked_step
          intro h
          exact (mask u (by omega) h).symm
    | succ p =>
      change H (T+(u+1)) (p+1) = rule (H (T+u) p) (H (T+u) (p+1)) (H (T+u) (p+2))
      rw [show T+(u+1) = T+u+1 by omega]
      exact half_isR30 w R φ _ _
  have wall (t : Nat) : F t 0 = eth j S 0 t := drv_col0 _ _ _
  have initial (p : Nat) (hp : 1 ≤ p) : F 0 p = E 0 p := drv_init _ _ _ hp
  have follows : ∀ t, t ≤ U → ∀ p, F t p = E t p := by
    intro t
    induction t with
    | zero =>
      intro _ p
      cases p with
      | zero => exact wall 0
      | succ p => exact initial _ (by omega)
    | succ t ih =>
      intro ht p
      cases p with
      | zero => exact wall _
      | succ p =>
        rw [show F (t+1) (p+1) = rule (F t p) (F t (p+1)) (F t (p+2)) from
            drv_isR30 _ _ t p, ih (by omega), ih (by omega), ih (by omega)]
        exact (localRule t (by omega) p).symm
  have support (t p : Nat) (hp : B+t < p) : F t p = false := by
    apply drv_white (D := B) _ _ _ hp
    intro q hq
    cases q with
    | zero => omega
    | succ q =>
      change H T q = false
      exact drv_white finite T q (by dsimp [B] at hq; omega)
  have first (p : Nat) (hp : 1 ≤ p) (hq : p ≤ 1) : F 0 p = eth j S p 0 := by
    have eq : p = 1 := by omega
    subst p
    exact (initial 1 (by decide)).trans (centre 0)
  obtain ⟨t,_,hi,p,hp,hp1,ne⟩ := erode (j0 := j) (s := S) (t1 := 0) (B := B)
    (k := 1) (drv_isR30 _ _) (by decide) (fun t _ => wall t) support first
  have eq : p = 1 := by omega
  subst p
  apply ne
  exact (follows t (by dsimp [U,B] at *; omega) 1).trans (centre t)

private theorem choice_white (b : Bool) :
    ∀ s, s % 3 = 0 → ether3 ((if b then 1 else 10)+2) s = b := by
  intro s hs
  rw [ether3_congr (φ' := 0) rfl (by simpa using hs)]
  cases b <;> decide

/-- Every finite half beside 011 reads the opposite of either chosen colour
at a white tick within 3(D+T+13)+6 physical ticks of T. -/
theorem opposite_011 {R : Nat → Bool} {D φ T : Nat} (finite : ∀ p, D < p → R p = false)
    (b : Bool) : ∃ t, T ≤ t ∧ t ≤ T+3*(D+T+13)+6 ∧
      (t+φ)%3 = 0 ∧ half w011 R φ t 1 = !b := by
  let j := if b then 1 else 10
  have align : ∀ ψ, ether3 (j+1) ψ = wordAt3 w011 ψ := by
    cases b
    · exact aligned3_spec (w := w011) (j0 := 11) (s := 0) (by decide)
    · exact aligned3_spec (w := w011) (j0 := 2) (s := 0) (by decide)
  obtain ⟨t,lo,hi,white,diff⟩ := masked_ether_break (φ := φ) (T := T) finite align
  rw [wordAt3_011, decide_eq_false_iff_not] at white
  have phase : (t+φ)%3 = 0 := by omega
  have bit : eth j φ 2 t = b := choice_white b _ phase
  exact ⟨t,lo,hi,phase,ne_eth (bit ▸ diff)⟩

/-- Both gate colours occur arbitrarily late on every finite half beside 011. -/
theorem both_colours_011 {R : Nat → Bool} {D φ : Nat} (finite : ∀ p, D < p → R p = false)
    (T : Nat) (b : Bool) :
    ∃ t, T ≤ t ∧ (t+φ)%3 = 0 ∧ half w011 R φ t 1 = b := by
  obtain ⟨t,lo,_,g,out⟩ := opposite_011 (φ := φ) (T := T) finite (!b)
  exact ⟨t,lo,g,by simpa using out⟩

private theorem label_after (C : PTrap) (hc : C.check = true) {i : Nat} (hi : i < C.n) :
    ∀ n, ∃ j, j < C.n ∧ C.lab j = (C.lab i+n)%C.m := by
  intro n
  induction n with
  | zero =>
    have hl := (C.step hc hi false).2.2.2.1
    exact ⟨i,hi,by simp [Nat.mod_eq_of_lt hl]⟩
  | succ n ih =>
    obtain ⟨j,hj,eq⟩ := ih
    obtain ⟨inside,_,phase,_,_⟩ := C.step hc hj false
    refine ⟨C.nxt j false,inside,?_⟩
    rw [phase,eq,Nat.mod_add_mod]
    congr 1

/-- No nonempty checked finite-width trap for 011 can force a constant gate.
The label count and width are arbitrary. -/
theorem no_constant_011_trap (C : PTrap) (hc : C.check = true)
    (word : C.w = w011) (width : 0 < C.b) (b : Bool)
    (constant : ∀ l, l < C.m → l%3 = 0 → C.u.testBit l = b) : C.n = 0 := by
  apply Classical.byContradiction
  intro ne
  let k := (3-(C.lab 0)%3)%3
  obtain ⟨i,hi,ilabel⟩ := label_after C hc (show 0<C.n by omega) k
  have phmod := C.phase_lab hc (C.lab 0) (C.lab 0) rfl k
  have iw : C.lab i%3 = 0 := by rw [ilabel,← phmod]; dsimp [k]; omega
  let R : Nat → Bool := fun p => (C.st i).testBit (p-1)
  let F := half C.w R 0
  have wfinite : ∀ p, C.b < p → R p = false := by
    intro p hp
    apply Nat.testBit_lt_two_pow
    exact Nat.lt_of_lt_of_le (C.st_lt i) (Nat.pow_le_pow_right (by decide) (by omega))
  obtain ⟨t,_,tWhite,tBit⟩ := both_colours_011 (φ := 0) wfinite 0 (!b)
  have in0 : EncF F C.b 0 0 (C.st i) := by
    refine ⟨C.st_lt i,fun p _ => ?_⟩
    have init : F 0 (p+1) = R (p+1) := drv_init _ _ _ (by omega)
    rw [show 0+1+p = p+1 by omega,init]
    rfl
  have drive (s : Nat) (_ : 0 ≤ s) : F s 0 = wordAt3 C.w (s-0) := by
    simp only [Nat.sub_zero]
    exact half_zero _ _ _ _
  obtain ⟨q,hq,code,lab⟩ := C.invariant hc (half_isR30 C.w R 0) 0 drive 0 i
    (by decide) hi (by omega) in0 t
  have qq : C.lab q%3=0 := by
    have mod := C.phase_lab hc 0 (C.lab i) (by omega) t
    rw [lab,← mod]
    omega
  have gateWhite : wordAt3 C.w (C.lab q % 3) = false := by rw [word,qq]; decide
  obtain ⟨_,_,_,lt,bit⟩ := C.step hc hq false
  have gateBit : F t 1 = b := by
    have a := (encF_head code width).symm
    simpa using a.trans ((bit gateWhite).trans (constant _ lt qq))
  change half C.w R 0 t 1 = b at gateBit
  rw [word,tBit] at gateBit
  cases b <;> contradiction

private theorem white_windows (u : Nat → Bool) {first : Nat} (white : u first = false)
    (next : ∀ i, first ≤ i → u i = false → ∃ g, 1 ≤ g ∧ g ≤ 17 ∧ u (i+g) = false) :
    ∀ k, first ≤ k → ∃ i, k ≤ i ∧ i ≤ k+16 ∧ u i = false := by
  intro k
  induction k with
  | zero => intro h; exact ⟨first,by omega,by omega,white⟩
  | succ k ih =>
    intro h
    by_cases new : k+1 = first
    · exact ⟨first,by omega,by omega,white⟩
    · obtain ⟨i,hi,far,wi⟩ := ih (by omega)
      by_cases same : i = k
      · subst i
        obtain ⟨g,lo,up,bit⟩ := next k (by omega) wi
        exact ⟨k+g,by omega,by omega,bit⟩
      · exact ⟨i,by omega,by omega,wi⟩

/-- Every seventeen consecutive gate readings eventually contain a white.
Before this result the gap theorem required a white reading to start it. -/
theorem eventually_white_windows_011 {R : Nat → Bool} {D φ : Nat}
    (finite : ∀ p, D < p → R p = false) :
    ∃ t K, (t+φ)%3 = 0 ∧ ∀ k, K ≤ k →
      ∃ i, k ≤ i ∧ i ≤ k+16 ∧ gate (half w011 R φ) t i = false := by
  let t := 3*D+822+(3-φ%3)%3
  have ph : (t+φ)%3 = 0 := by dsimp [t]; omega
  have entered := finite_enters_011 finite ph (by dsimp [t]; omega)
  obtain ⟨t',lo,ph',w⟩ := both_colours_011 (φ := φ) finite (t+18) false
  let first := (t'-t)/3
  have ht' : t+3*first = t' := by dsimp [first]; omega
  have wi : gate (half w011 R φ) t first = false := by
    unfold gate
    rwa [ht']
  refine ⟨t,first,ph,white_windows _ wi ?_⟩
  intro i hi bit
  obtain ⟨g,rg,wg,_⟩ := gaps_011 ph entered i (by dsimp [first] at hi; omega) bit
  exact ⟨g,by omega,by omega,wg⟩

end Ruliology.CellularAutomata.Rule30PeriodThreeGateChanges
