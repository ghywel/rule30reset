-- Proposed addition to Rule30EtherThreeSharpSlope (claudeIntel, N18). claudeIntel_build_s21.py appends what follows BEGIN to I242's
-- module, whose own declarations stay as they are, and adds the lines after HEADER to the module's docstring.
-- HEADER
--
-- The step needs nothing of the tail. `family_tail` gives the same run before any tail that is itself a row of Rule 30 and its
-- successors, and `holds_tail` how long that row shows the ether. With an ether tail, the bound 3w + 6 of
-- `Rule30EtherThreeErosion.erosion3_fin` has the least slope (`erosion_slope`). With a white one, a finite half beside 011 reads a
-- constant gate, of either colour, for three ticks a cell (`constant_gate_011`, `gate_slope_011`). By compactness one right half
-- keeps the exceptional front for ever (`endless`), so a right half that is not the ether can show the ether on columns 1..k for
-- ever: erosion needs the finite side (`not_eroded`). Beside 001 and 011 such a half never enters the trap (`stays_001`,
-- `stays_011`).

-- BEGIN

/-! ### Any tail -/

/-- Invert a row that is the row `T` from `B` on, by sweeping west. -/
def backTail (T y : Nat → Bool) (B p : Nat) : Bool :=
  if p < B then rule (y (p+1)) (backTail T y B (p+1)) (backTail T y B (p+2)) else T p
termination_by B-p
decreasing_by all_goals omega

theorem backTail_tail (T y : Nat → Bool) {B p : Nat} (h : B ≤ p) : backTail T y B p = T p := by
  rw [backTail, ite_eq_right (by omega)]

theorem backTail_eq {T T' y : Nat → Bool} {B : Nat} (hT : ∀ p, T' (p+1) = rule (T p) (T (p+1)) (T (p+2)))
    (tail : ∀ p, B < p → y p = T' p) (p : Nat) :
    backTail T y B p = rule (y (p+1)) (backTail T y B (p+1)) (backTail T y B (p+2)) := by
  by_cases h : p < B
  · rw [backTail, ite_eq_left h]
  · rw [backTail_tail T y (by omega), tail _ (by omega), backTail_tail T y (by omega),
      backTail_tail T y (by omega), hT, rule_cancel]

/-- `extend_back` with any tail that is itself a row of Rule 30 and its successor. -/
theorem extend_back_tail {j s d B : Nat} {Y T T' : Nat → Bool} (hT : ∀ p, T' (p+1) = rule (T p) (T (p+1)) (T (p+2)))
    (hd : 2 ≤ d) (hc : cls j s d 0 = 10)
    (tail : ∀ p, B < p → Y p = T' p)
    (F : Front (driven j (s+1) Y) j (s+1) 0 (d+8))
    (bad : IsB (driven j (s+1) Y) j (s+1) 0 (d+8)) :
    ∃ R, (∀ p, B ≤ p → R p = T p) ∧
      Front (driven j s R) j s 0 d ∧ IsB (driven j s R) j s 0 d ∧
      ∀ t p, driven j s R (t+1) p = driven j (s+1) Y t p := by
  let X := backTail T Y B
  let last := driven j (s+1) Y
  have agree (p : Nat) (hp : 0 < p) : last 0 p = Y p := drv_init _ _ _ hp
  let Z : Nat → Bool := last 0
  have eqY (p : Nat) : Z (p+1) = Y (p+1) := agree _ (by omega)
  have inv (p : Nat) : X p = rule (Z (p+1)) (X (p+1)) (X (p+2)) := by
    rw [eqY]
    exact backTail_eq hT tail p
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
  refine ⟨X, fun p h => backTail_tail _ _ h, ⟨fun p hp => (all p).trans (pre p hp), ?_⟩, ?_, ?_⟩
  · rwa [all]
  · unfold IsB isBad ubit
    rw [hc, all]
    simpa using bne_iff_ne.mpr b1
  · apply shift
    intro p hp
    obtain ⟨a,rfl⟩ : ∃ a, p=a+1 := ⟨p-1,by omega⟩
    change rule (driven j s X 0 a) (driven j s X 0 (a+1)) (driven j s X 0 (a+2)) = Y (a+1)
    rw [all,all,all, inv a, rule_cancel, eqY]

private theorem cone {c x y : Nat → Bool} {N : Nat} (h : ∀ p, p ≤ N → x p = y p) (t : Nat) :
    ∀ p, p+t ≤ N → drv c x t p = drv c y t p := by
  induction t with
  | zero =>
    intro p hp
    cases p with
    | zero => rfl
    | succ p => rw [drv_init _ _ _ (by omega), drv_init _ _ _ (by omega)]; exact h _ (by omega)
  | succ t ih =>
    intro p hp
    cases p with
    | zero => rw [drv_col0, drv_col0]
    | succ p =>
      change rule (drv c x t p) (drv c x t (p+1)) (drv c x t (p+2)) =
        rule (drv c y t p) (drv c y t (p+1)) (drv c y t (p+2))
      rw [ih p (by omega), ih (p+1) (by omega), ih (p+2) (by omega)]

/-- `family` with any tail. Let `bg s` be rows with `bg (s+1)` the successor of `bg s`. Some row agrees with `bg s` beyond
`d+7n+4` and makes `n` advances of eight columns, then one of two columns into the recurrent class. -/
theorem family_tail (j : Nat) {bg : Nat → Nat → Bool}
    (hbg : ∀ s p, bg (s+1) (p+1) = rule (bg s p) (bg s (p+1)) (bg s (p+2))) : ∀ n d s : Nat, 2 ≤ d → cls j s d 0 = 10 →
    ∃ R, (∀ p, d+7*n+4 < p → R p = bg s p) ∧
      (∀ k, k ≤ n → Front (driven j s R) j s k (d+8*k) ∧
        IsB (driven j s R) j s k (d+8*k)) ∧
      Front (driven j s R) j s (n+1) (d+8*n+2) ∧
      IsRec (driven j s R) j s (n+1) (d+8*n+2) := by
  intro n
  induction n with
  | zero =>
    intro d s hd hc
    obtain ⟨hf,hb,hn,hr⟩ := terminal_step hd hc
    let R := fun p => if p ≤ d+4 then terminal j s d p else bg s p
    have same : ∀ p, p ≤ d+4 → R p = terminal j s d p := fun p hp => ite_eq_left hp
    have e0 (p : Nat) (hp : p ≤ d+4) : driven j s R 0 p = driven j s (terminal j s d) 0 p :=
      cone same 0 p hp
    have e1 (p : Nat) (hp : p ≤ d+3) : driven j s R 1 p = driven j s (terminal j s d) 1 p :=
      cone same 1 p (by omega)
    refine ⟨R, fun p hp => ite_eq_right (by omega), fun k hk => ?_, ?_, ?_⟩
    · have eq : k = 0 := by omega
      subst k
      rw [Nat.mul_zero, Nat.add_zero]
      refine ⟨⟨fun p hp => (e0 p (by omega)).trans (hf.1 p hp), ?_⟩, ?_⟩
      · rw [e0 d (by omega)]; exact hf.2
      · unfold IsB ubit at hb ⊢; rw [e0 (d+1) (by omega)]; exact hb
    · rw [Nat.mul_zero, Nat.add_zero]
      exact ⟨fun p hp => (e1 p (by omega)).trans (hn.1 p hp), by rw [e1 (d+2) (by omega)]; exact hn.2⟩
    · rw [Nat.mul_zero, Nat.add_zero]
      unfold IsRec ubit at hr ⊢; rw [e1 (d+2+1) (by omega)]; exact hr
  | succ n ih =>
    intro d s hd hc
    have next : cls j (s+1) (d+8) 0 = 10 := by unfold cls at hc ⊢; omega
    obtain ⟨Y,hy,chain,hf,hr⟩ := ih (d+8) (s+1) (by omega) next
    have start := chain 0 (by omega)
    simp only [Nat.mul_zero, Nat.add_zero] at start
    obtain ⟨R,hw,h0,hb,eval⟩ := extend_back_tail (hbg s) hd hc hy start.1 start.2
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

/-! ### How long the ether is held -/

/-- The row of `family_tail` shows the ether on every column west of `d` at every tick up to `21n + 5`. -/
theorem holds_tail (j : Nat) {bg : Nat → Nat → Bool}
    (hbg : ∀ s p, bg (s+1) (p+1) = rule (bg s p) (bg s (p+1)) (bg s (p+2))) (n : Nat) {d s : Nat} (hd : 2 ≤ d)
    (hc : cls j s d 0 = 10) :
    ∃ R, (∀ p, d+7*n+4 < p → R p = bg s p) ∧ driven j s R 0 d ≠ eth j s d 0 ∧
      ∀ t, t ≤ 21*n+5 → ∀ p, p < d → driven j s R t p = eth j s p t := by
  obtain ⟨R,ht,chain,hf,hr⟩ := family_tail j hbg n d s hd hc
  have start := (chain 0 (by omega)).1
  rw [Nat.mul_zero, Nat.add_zero] at start
  refine ⟨R, ht, start.2, fun t hT p hp => ?_⟩
  rcases Nat.lt_or_ge n t with late | early
  · have q0 : psi (driven j s R) j s (n+1) (d+8*n+2) = 4 := by
      have c : cls j s (d+8*n+2) (n+1) = 4 := by unfold cls at hc ⊢; omega
      unfold psi psiR
      rw [c]
      rfl
    have key : ∀ m, n+1+m ≤ 21*n+5 → ∃ E, Front (driven j s R) j s (n+1+m) E ∧
        IsRec (driven j s R) j s (n+1+m) E ∧
        5*E+2*m+psi (driven j s R) j s (n+1+m) E = 5*(d+8*n+2)+4 := by
      intro m
      induction m with
      | zero => intro _; exact ⟨_, hf, hr, by rw [Nat.mul_zero, Nat.add_zero, Nat.add_zero, q0]⟩
      | succ m ih =>
        intro hm
        obtain ⟨E,fE,rE,eE⟩ := ih (by omega)
        have q := psi_le rE
        obtain ⟨E',fE',rE',-,-,eE'⟩ :=
          rigid_step (F := driven j s R) (drv_isR30 _ _) (wall j s _ R) (by omega) fE rE
        exact ⟨E', fE', rE', by rw [show n+1+(m+1) = n+1+m+1 by omega]; omega⟩
    obtain ⟨E,fE,rE,eE⟩ := key (t-(n+1)) (by omega)
    rw [show n+1+(t-(n+1)) = t by omega] at fE rE eE
    have q := psi_le rE
    exact fE.1 p (by omega)
  · exact ((chain t early).1).1 p (by omega)

/-- The bound `3 w + 6` of `Rule30EtherThreeErosion.erosion3_fin` has the least slope. Beside every ether column, for every `n`,
some row is ether on the columns `1..k` and beyond `k + w`, where `w = 7n + 5`, is not the ether, and has ether on the columns
`1..k` at every tick up to `21n + 5 = 3w - 10`. -/
theorem erosion_slope (j s n : Nat) :
    ∃ (R : Nat → Bool) (k : Nat), 1 ≤ k ∧
      (∀ p, k+(7*n+5) < p → driven j s R 0 p = eth j s p 0) ∧
      driven j s R 0 (k+1) ≠ eth j s (k+1) 0 ∧
      ∀ t, t ≤ 21*n+5 → ∀ p, p ≤ k → driven j s R t p = eth j s p t := by
  let d := 2+(8+11*(j+4*s))%12
  have hd : 2 ≤ d := Nat.le_add_right ..
  have hc : cls j s d 0 = 10 := by
    unfold cls
    change (j+(2+(8+11*(j+4*s))%12)+4*(0+s))%12 = 10
    omega
  have hbg : ∀ s p, eth j (s+1) (p+1) 0 = rule (eth j s p 0) (eth j s (p+1) 0) (eth j s (p+2) 0) := fun s p => by
    rw [← eth_shift, eth_rule]
  obtain ⟨R,ht,h0,h⟩ := holds_tail j (bg := fun s p => eth j s p 0) hbg n hd hc
  refine ⟨R, d-1, by omega, fun p hp => ?_, by rwa [show d-1+1 = d by omega], fun t hT p hp => h t hT p (by omega)⟩
  rw [show driven j s R 0 p = R p from drv_init _ _ _ (by omega), ht p (by omega)]

/-- A finite half beside 011 can read one colour, either one, at every white tick of the drive that begins a period up to
`21n + 5`, with white beyond `7n + 17`, from any phase. -/
theorem constant_gate_011 (b : Bool) (n φ : Nat) :
    ∃ R : Nat → Bool, (∀ p, 7*n+17 < p → R p = false) ∧
      ∀ t, t ≤ 21*n+5 → (t+φ)%3 = 0 → half w011 R φ t 1 = b := by
  obtain ⟨j,align,colour⟩ : ∃ j, (∀ k, ether3 j k = wordAt3 w011 k) ∧ ether3 (j+1) 0 = b := by
    cases b
    · exact ⟨11, aligned3_spec (w := w011) (j0 := 11) (s := 0) (by decide), by decide⟩
    · exact ⟨2, aligned3_spec (w := w011) (j0 := 2) (s := 0) (by decide), by decide⟩
  let d := 2+(8+11*(j+4*φ))%12
  have hd : 2 ≤ d := Nat.le_add_right ..
  have hd' : d ≤ 13 := by
    change 2+(8+11*(j+4*φ))%12 ≤ 13
    omega
  have hc : cls j φ d 0 = 10 := by
    unfold cls
    change (j+(2+(8+11*(j+4*φ))%12)+4*(0+φ))%12 = 10
    omega
  obtain ⟨R,ht,-,h⟩ := holds_tail j (bg := fun _ _ => false) (fun _ _ => rfl) n hd hc
  refine ⟨R, fun p hp => ht p (by omega), fun t hT hg => ?_⟩
  have run : half w011 R φ = driven j φ R := by
    have hWall : (fun t => wordAt3 w011 (t+φ)) = (fun t => eth j φ 0 t) := by
      funext t
      unfold eth
      rw [Nat.add_zero, align]
    exact congrArg (fun c => drv c R) hWall
  rw [run, h t hT 1 (by omega), ← colour]
  exact ether3_congr rfl (by omega)

/-- So any affine deadline for the other colour beside 011 has slope at least three. -/
theorem gate_slope_011 {p q r : Nat} (b : Bool)
    (h : ∀ (R : Nat → Bool) (D : Nat), (∀ x, D < x → R x = false) → ∀ φ,
      ∃ t, q*t ≤ p*D+r ∧ (t+φ)%3 = 0 ∧ half w011 R φ t 1 = !b) : 3*q ≤ p := by
  apply Nat.le_of_not_lt
  intro lt
  let n := 17*p+r
  obtain ⟨R,hw,const⟩ := constant_gate_011 b n 0
  obtain ⟨t,hq,g,hb⟩ := h R _ hw 0
  have late : 21*n+6 ≤ t := by
    apply Nat.le_of_not_lt
    intro early
    rw [const t (by omega) g] at hb
    cases b <;> exact absurd hb (by decide)
  have a := Nat.mul_le_mul_right (7*n) (show p+1 ≤ 3*q by omega)
  have c := Nat.mul_le_mul_left q late
  have e1 : (p+1)*(7*n) = 7*(p*n)+7*n := by
    rw [Nat.add_mul, Nat.one_mul, Nat.mul_left_comm]
  have e2 : 3*q*(7*n) = 21*(q*n) := by
    rw [Nat.mul_mul_mul_comm]
  have e3 : q*(21*n+6) = 21*(q*n)+6*q := by
    rw [Nat.mul_add, Nat.mul_left_comm, Nat.mul_comm q 6]
  have e4 : p*(7*n+17)+r = 7*(p*n)+(17*p+r) := by
    rw [Nat.mul_add, Nat.mul_left_comm, Nat.mul_comm p 17, Nat.add_assoc]
  have e5 : 17*p+r = n := rfl
  omega

/-! ### An endless run -/

private def Often (P : Nat → Prop) : Prop := ∀ n, ∃ i, n ≤ i ∧ P i

private theorem often_split {P : Nat → Prop} (h : Often P) (b : Nat → Bool) :
    ∃ v, Often fun i => P i ∧ b i = v := by
  by_cases h1 : Often fun i => P i ∧ b i = true
  · exact ⟨true, h1⟩
  · refine ⟨false, fun n => ?_⟩
    unfold Often at h1
    simp only [Classical.not_forall, not_exists] at h1
    obtain ⟨u, hu⟩ := h1
    obtain ⟨i, hi, pi⟩ := h (max n u)
    exact ⟨i, by omega, pi, Bool.eq_false_iff.mpr fun e => hu i ⟨by omega, pi, e⟩⟩

private structure Pool where
  pred : Nat → Prop
  often : Often pred

private noncomputable def pools (bits : Nat → Nat → Bool) : Nat → Pool
  | 0 => ⟨fun _ => True, fun n => ⟨n, Nat.le_refl _, trivial⟩⟩
  | n+1 => ⟨_, (often_split (pools bits n).often (fun i => bits i n)).choose_spec⟩

private theorem limit (bits : Nat → Nat → Bool) :
    ∃ x : Nat → Bool, ∀ n, Often fun i => ∀ p, p < n → bits i p = x p := by
  let x := fun n => (often_split (pools bits n).often (fun i => bits i n)).choose
  have fits (n i : Nat) (h : (pools bits n).pred i) : ∀ p, p < n → bits i p = x p := by
    induction n with
    | zero => intro p hp; omega
    | succ n ih =>
      change (pools bits n).pred i ∧ bits i n = x n at h
      intro p hp
      by_cases eq : p = n
      · exact eq ▸ h.2
      · exact ih h.1 p (by omega)
  exact ⟨x, fun n bound => by
    obtain ⟨i,hi,h⟩ := (pools bits n).often bound
    exact ⟨i,hi,fits n i h⟩⟩

/-- **An endless exceptional run.** Some right half keeps the exceptional front for ever, eight columns east at each tick. -/
theorem endless (j : Nat) {d s : Nat} (hd : 2 ≤ d) (hc : cls j s d 0 = 10) :
    ∃ R, ∀ k, Front (driven j s R) j s k (d+8*k) ∧ IsB (driven j s R) j s k (d+8*k) := by
  let row := fun n => (family j n d s hd hc).choose
  have spec := fun n => (family j n d s hd hc).choose_spec
  obtain ⟨R,lim⟩ := limit row
  refine ⟨R, fun k => ?_⟩
  obtain ⟨n,hn,same⟩ := lim (d+9*k+2) k
  obtain ⟨f,b⟩ := (spec n).2.1 k hn
  have eq (p : Nat) (hp : p ≤ d+8*k+1) : driven j s R k p = driven j s (row n) k p :=
    cone (N := d+9*k+1) (fun q hq => (same q (by omega)).symm) k p (by omega)
  refine ⟨⟨fun p hp => (eq p (by omega)).trans (f.1 p hp), ?_⟩, ?_⟩
  · rw [eq _ (by omega)]; exact f.2
  · unfold IsB ubit at b ⊢; rw [eq _ (by omega)]; exact b

/-- **An infinite right side need not erode the ether.** Beside every ether column, for arbitrarily large `k`, there is a right
half that differs from the ether first at column `k + 1` and whose columns `1..k` are the ether for ever. Column `p` is the
ether at every tick `t` with `p ≤ k + 8 t`. -/
theorem not_eroded (j s K : Nat) :
    ∃ (R : Nat → Bool) (k : Nat), K < k ∧ driven j s R 0 (k+1) ≠ eth j s (k+1) 0 ∧
      ∀ t p, p ≤ k+8*t → driven j s R t p = eth j s p t := by
  let d := K+2+(8+11*(j+4*s+K))%12
  have hd : K+2 ≤ d := Nat.le_add_right ..
  have hc : cls j s d 0 = 10 := by
    unfold cls
    change (j+(K+2+(8+11*(j+4*s+K))%12)+4*(0+s))%12 = 10
    omega
  obtain ⟨R,h⟩ := endless j (by omega) hc
  have h0 := (h 0).1.2
  rw [Nat.mul_zero, Nat.add_zero] at h0
  exact ⟨R, d-1, by omega, by rwa [show d-1+1 = d by omega], fun t p hp => (h t).1.1 p (by omega)⟩

private theorem stays (w : List Bool) (trap : List Nat) (j s d g : Nat)
    (align : ∀ k, ether3 j k = wordAt3 w k) (hd : 14 < d)
    (hc : cls j s d 0 = 10)
    (outside : code (fun _ p => ether3 (j+p) g) 0 14 ∉ trap) :
    ∃ R, half w R s 0 d ≠ eth j s d 0 ∧ ∀ t, (t+s)%3 = g%3 → ¬ InTrap trap (half w R s) t := by
  obtain ⟨R,h⟩ := endless j (by omega) hc
  have run : half w R s = driven j s R := by
    have hWall : (fun t => wordAt3 w (t+s)) = (fun t => eth j s 0 t) := by
      funext t
      unfold eth
      rw [Nat.add_zero, align]
    exact congrArg (fun c => drv c R) hWall
  have h0 := (h 0).1.2
  rw [Nat.mul_zero, Nat.add_zero] at h0
  refine ⟨R, by rw [run]; exact h0, fun t ht => ?_⟩
  have same : code (driven j s R) t 14 = code (fun _ p => ether3 (j+p) g) 0 14 := by
    unfold code
    congr 1
    apply Rule30Ether.seg_congr
    intro i hi
    exact ((h t).1.1 (i+1) (by omega)).trans (ether3_congr rfl (by omega))
  rwa [run, InTrap, same]

set_option maxRecDepth 10000 in
/-- Beside 001 a right half that is not the ether stays outside the trap at every gate tick. -/
theorem stays_001 : ∃ R, half w001 R 0 0 22 ≠ ether3 22 0 ∧ ∀ t, t%3 = 1 → ¬ InTrap trap001 (half w001 R 0) t := by
  have out : code (fun _ p => ether3 p 1) 0 14 ∉ trap001 := by decide +kernel
  obtain ⟨R,h0,h⟩ := stays w001 trap001 0 0 22 1
    (aligned3_spec (w := w001) (j0 := 0) (s := 0) (by decide))
    (by decide) (by decide) (by simpa using out)
  exact ⟨R, by simpa [eth] using h0, fun t ht => h t (by omega)⟩

set_option maxRecDepth 10000 in
/-- Beside 011 likewise. -/
theorem stays_011 : ∃ R, half w011 R 2 0 27 ≠ ether3 38 2 ∧ ∀ t, (t+2)%3 = 0 → ¬ InTrap trap011 (half w011 R 2) t := by
  have out : code (fun _ p => ether3 (11+p) 0) 0 14 ∉ trap011 := by decide +kernel
  obtain ⟨R,h0,h⟩ := stays w011 trap011 11 2 27 0
    (aligned3_spec (w := w011) (j0 := 11) (s := 0) (by decide))
    (by decide) (by decide) out
  exact ⟨R, by simpa [eth] using h0, fun t ht => h t (by omega)⟩
