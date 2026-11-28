import Ruliology.CellularAutomata.Rule30ZeroBoundaryStripeFourComplete

namespace PhaseTwo.StripeHistory

open Ruliology.CellularAutomata Rule30ZeroBoundary Rule30ZeroBoundaryStripe
open Rule30ZeroBoundaryStripeFront Rule30ZeroBoundaryStripeFourComplete

/-- Prescribe the first m odd wall readings, then prescribe black. -/
def free {m : Nat} (p : Fin m → Bool) (s : Nat) : Bool :=
  if hs : s < m then p ⟨s, hs⟩ else true

/-- Replace the stripe prefix of an outer row by the chosen wall history. -/
def splice {m : Nat} (p : Fin m → Bool) (W : Nat) (row : Nat → Bool) (k : Nat) : Bool :=
  if k ≤ W then Theta (free p) k else row k

theorem evolves_to_stripe {m : Nat} (p : Fin m → Bool) :
    zrow (Theta (free p)) (2*m) = stripe := by
  rw [zrow_Theta_even]
  have h : (fun s => free p (s+m)) = (fun _ => true) := by
    funext s
    simp [free, show ¬s+m<m by omega]
  rw [h, Theta_true]

theorem agrees_beyond {m : Nat} (p : Fin m → Bool) :
    AgreesFrom (Theta (free p)) (1 + 8*m) := by
  have h := agrees_pre_run (Theta (free p)) 1 (by decide) (2*m)
  rw [evolves_to_stripe] at h
  exact (show 1+8*m=1+4*(2*m) by omega) ▸ h (fun _ _ => rfl)

private theorem retreat {m t : Nat} (p : Fin m → Bool) (ht : t ≤ 2*m) :
    AgreesFrom (zrow (Theta (free p)) t) (1+4*(2*m-t)) := by
  apply agrees_pre_run _ 1 (by decide)
  intro k _
  rw [← zrow_shift, show t+(2*m-t)=2*m by omega, evolves_to_stripe]

/-- The end of the variable wall history moves toward the wall as it is erased. -/
theorem splice_merges {m W : Nat} (p : Fin m → Bool) (row : Nat → Bool)
    (hW : 8*m+2 ≤ W) (hs : ∀ k, k ≤ W → row k = stripe k) :
    zrow (splice p W row) (2*m) = zrow row (2*m) := by
  have near (k t : Nat) (ht : t ≤ 2*m) (hk : k+t ≤ W) (h : 1+4*(2*m-t) ≤ k) :
      zrow (splice p W row) t k = zrow row t k := by
    have h1 := zrow_light_cone (L := splice p W row) (L' := Theta (free p)) t k
      (fun i _ hi => by simp only [splice, ite_eq_left (by omega : i ≤ W)])
    have h2 := zrow_light_cone (L := row) (L' := stripe) t k (fun i _ hi => hs i (by omega))
    rw [h1, h2, zrow_stripe, retreat p ht k h]
  have far (t : Nat) (ht : t ≤ 2*m) (k : Nat) (hk : W < k+t) :
      zrow (splice p W row) t k = zrow row t k := by
    induction t generalizing k with
    | zero =>
      have hp : 1 ≤ k := by omega
      rw [zrow_zero_of_pos _ hp, zrow_zero_of_pos _ hp]
      simp only [splice, ite_eq_right (by omega : ¬k ≤ W)]
    | succ t ih =>
      cases k with
      | zero => rw [zrow_wall, zrow_wall]
      | succ k =>
        have prev (j : Nat) (hj : k ≤ j) : zrow (splice p W row) t j = zrow row t j := by
          by_cases h : W < j+t
          · exact ih (by omega) _ h
          · exact near _ _ (by omega) (by omega) (by omega)
        rw [zrow_succ, zrow_succ, prev _ (by omega), prev _ (by omega), prev _ (by omega)]
  funext k
  by_cases h : W < k+2*m
  · exact far _ (by omega) _ h
  · cases k with
    | zero => rw [zrow_wall, zrow_wall]
    | succ k => exact near _ _ (by omega) (by omega) (by omega)

theorem splice_trace {m W : Nat} (p : Fin m → Bool) (row : Nat → Bool) (t : Nat) (h : t < W) :
    zrow (splice p W row) t 1 = alt (free p) t := by
  rw [← Theta_col]
  exact zrow_light_cone t 1 (fun i _ hi => by simp [splice, show i ≤ W by omega])

theorem splice_injective {m W : Nat} (row : Nat → Bool) (hW : 2*m ≤ W) :
    Function.Injective (fun p : Fin m → Bool => splice p W row) := by
  intro p q eq
  funext i
  have ht : 2*i.val+1 < W := by have := i.isLt; omega
  have hp := splice_trace p row _ ht
  have hq := splice_trace q row _ ht
  change splice p W row = splice q W row at eq
  rw [eq, hq] at hp
  unfold alt at hp
  simp only [ite_eq_right (by omega : ¬ (2*i.val+1)%2=0), show (2*i.val+1)/2 = i.val by omega,
    free, dite_eq_left i.isLt] at hp
  exact hp.symm

/-- Every five-bit outer tail inherits the kit's deadline with any of the
    prehistories, as soon as the stripe prefix is long enough. -/
theorem five_tail_exclusion {m W : Nat} (p : Fin m → Bool) (hW : 8*m+2 ≤ W) (v : Fin 32) :
    ∃ t, t ≤ W+51 ∧ t%2 = 0 ∧ zrow (splice p W (row5 W v.val)) t 1 = false := by
  obtain ⟨d, hd, hw, _, _, t, ht, he, hz⟩ := stripe_five_tail_complete W v
  have hs (k : Nat) (hk : k ≤ W) : row5 W v.val k = stripe k := by simp [row5, hk]
  have hlow : 2*m ≤ t := by
    apply Classical.byContradiction
    intro h
    have hh := zrow_light_cone (L := row5 W v.val) (L' := stripe) t 1 (fun i _ hi => hs i (by omega))
    rw [hh, zrow_stripe] at hz
    contradiction
  have merge := splice_merges p _ hW hs
  have eq : zrow (splice p W (row5 W v.val)) t 1 = zrow (row5 W v.val) t 1 := by
    rw [show t=2*m+(t-2*m) by omega, zrow_shift, merge, ← zrow_shift]
  exact ⟨t, by omega, he, eq.trans hz⟩

/-- At exact width 2n−1 (b=false) and 2n (b=true), every history survives the
    entire support and dies by the first 2n even checks. -/
def shell {m : Nat} (p : Fin m → Bool) (n : Nat) (b : Bool) :=
  splice p (2*n-1) (row5 (2*n-1) b.toNat)

/-- The odd shell has its first failed even check at physical time 2n. -/
theorem odd_shell_death {m n : Nat} (p : Fin m → Bool) (hn : 0 < n) (hW : 8*m ≤ 2*n-2) :
    (∀ s < n, zrow (shell p n false) (2*s) 1 = true) ∧
      zrow (shell p n false) (2*n) 1 = false := by
  refine ⟨fun s hs => ?_, ?_⟩
  · rw [shell, splice_trace p _ _ (by omega)]
    simp [alt]
  · have eq (i : Nat) (hi : 1 ≤ i) (h : i ≤ 2*n) : shell p n false i = Theta (free p) i := by
      by_cases hw : i ≤ 2*n-1
      · simp [shell, splice, hw]
      · have he : i = 2*n := by omega
        subst i
        rw [agrees_beyond p _ (by omega), stripe_even (by omega)]
        simp [shell, splice, row5, tail5, hw]
    have diff : shell p n false (2*n+1) ≠ Theta (free p) (2*n+1) := by
      rw [agrees_beyond p _ (by omega), stripe_odd (by omega)]
      simp [shell, splice, row5, tail5, show ¬ 2*n+1 ≤ 2*n-1 by omega]
    have := pivot eq diff
    rw [Theta_inX (free p) n] at this
    exact Bool.eq_false_iff.mpr this

open Rule30ZeroBoundarySmall Rule30ZeroBoundaryStripeFront.StripeCycles0

private theorem shell_even_seed {n : Nat} (hn : 0 < n) :
    pk (fun i => row5 (2*n-1) 1 (2*n+i)) 32 = 1 := by
  apply Nat.eq_of_testBit_eq
  intro i
  rw [testBit_pk]
  have hw : ¬ 2*n+i ≤ 2*n-1 := by omega
  have hi : 2*n+i-(2*n-1)-1 = i := by omega
  cases i with
  | zero => simp [row5, tail5, show ¬ 2*n ≤ 2*n-1 by omega, show 2*n-(2*n-1)-1 = 0 by omega]
  | succ i =>
    have bit : (1 : Nat).testBit (i+1) = false := by
      rw [show (1 : Nat) = 2^0 by decide, Nat.testBit_two_pow]
      simp
    simp [row5, tail5, hw, hi, bit]

private theorem even_base_agrees (n k : Nat) (h : k < 2*n) : row5 (2*n-1) 1 k = stripe k := by
  simp [row5, show k ≤ 2*n-1 by omega]

/-- The wall at and after arrival is read from a 32-bit window with a 4096-tick cycle. -/
theorem even_shell_read {m n j : Nat} (p : Fin m → Bool) (hn : 0 < n)
    (hW : 8*m+2 ≤ 2*n-1) (hj : j < 32) :
    zrow (shell p n true) (2*n-1+j) 1 =
      (prun (orb 32 ((2*n-1)%4096) (1,0)).1 j).testBit 0 := by
  let x := row5 (2*n-1) 1
  have hs (k : Nat) (h : k ≤ 2*n-1) : x k = stripe k := by simp [x, row5, h]
  have merge := splice_merges p x hW hs
  have e : zrow (shell p n true) (2*n-1+j) 1 = zrow x (2*n-1+j) 1 := by
    change zrow (splice p (2*n-1) x) _ _ = _
    rw [show 2*n-1+j = 2*m+(2*n-1+j-2*m) by omega, zrow_shift, merge, ← zrow_shift]
  rw [e]
  have win0 : win x (2*n) 32 0 = 1 := by rw [win_zero x _ _ (by omega)]; exact shell_even_seed hn
  have ho := win_orb x (2*n) 32 (fun k _ h => even_base_agrees n k h) (2*n-1) (by omega)
  rw [win0, show (2*n)%2=0 by omega, orb_mod 32 4096 _ cyc_1_0.2.2.1] at ho
  have hw := congrArg Prod.fst ho
  simp only at hw
  rw [hw, zrow_shift, zrow_light_cone (L' := toFun (win x (2*n) 32 (2*n-1))) j 1 (fun i h1 h2 => by
    simp only [toFun, show i ≠ 0 by omega, ite_false]
    unfold win
    rw [testBit_pk, show 2*n-(2*n-1)+(i-1)=i by omega]
    simp [show i-1 < 32 by omega]), run_toFun]
  rfl

theorem even_shell_deadline {m n : Nat} (p : Fin m → Bool) (hn : 0 < n) (hW : 8*m+2 ≤ 2*n-1) :
    ∃ j, j ≤ 31 ∧ (2*n-1+j)%2 = 0 ∧ zrow (shell p n true) (2*n-1+j) 1 = false := by
  let x := row5 (2*n-1) 1
  have hc : Cycle 32 31 (pk (fun i => x (2*n+i)) 32) ((2*n)%2) 4096 := by
    rw [show (2*n)%2=0 by omega, show pk (fun i => x (2*n+i)) 32 = 1 from shell_even_seed hn]
    exact cyc_1_0
  obtain ⟨j, hj, he, hz⟩ := front_sound x (2*n) 32 31 4096 (by omega)
    (fun k _ h => even_base_agrees n k h) (by decide) hc
  have hm := splice_merges p x hW (fun k h => by simp [x, row5, h])
  refine ⟨j, hj, he, ?_⟩
  change zrow (splice p (2*n-1) x) _ _ = false
  rw [show 2*n-1+j = 2*m+(2*n-1+j-2*m) by omega, zrow_shift, hm, ← zrow_shift,
    show 2*m+(2*n-1+j-2*m) = 2*n-1+j by omega]
  exact hz

theorem shell_diagonal {m n : Nat} (p : Fin m → Bool) (b : Bool)
    (hn : 16 ≤ n) (hW : 8*m+2 ≤ 2*n-1) :
    (shell p n b (2*n-1+b.toNat) = true ∧
      ∀ k, 2*n-1+b.toNat < k → shell p n b k = false) ∧
    (∀ s < n, zrow (shell p n b) (2*s) 1 = true) ∧
    ∃ s, n ≤ s ∧ s < 2*n ∧ zrow (shell p n b) (2*s) 1 = false := by
  have past (s : Nat) (hs : s < n) : zrow (shell p n b) (2*s) 1 = true := by
    rw [shell, splice_trace p _ _ (by omega)]
    simp [alt]
  refine ⟨?_, past, ?_⟩
  · cases b with
    | false =>
      constructor
      · simp only [Bool.toNat_false, Nat.add_zero, shell, splice, ite_eq_left (Nat.le_refl _)]
        rw [agrees_beyond p _ (by omega), stripe_odd (by omega)]
      · intro k hk
        simp only [Bool.toNat_false, Nat.add_zero] at hk
        simp [shell, splice, row5, tail5, Nat.not_le.mpr hk]
    | true =>
      constructor
      · simp [shell, splice, row5, tail5, show ¬2*n-1+1 ≤ 2*n-1 by omega]
      · intro k hk
        have h : 2*n-1 < k := by simp only [Bool.toNat_true] at hk; omega
        have h0 : k-(2*n-1)-1 ≠ 0 := by simp only [Bool.toNat_true] at hk; omega
        have hbit : (1 : Nat).testBit (k-(2*n-1)-1) = false := by
          rw [show (1 : Nat) = 2^0 by decide, Nat.testBit_two_pow]
          simp [Ne.symm h0]
        simp [shell, splice, row5, tail5, Nat.not_le.mpr h, hbit]
  · have fail : ∃ t, t ≤ 2*n+30 ∧ t%2 = 0 ∧ zrow (shell p n b) t 1 = false := by
      cases b with
      | false => exact ⟨2*n, by omega, by omega, (odd_shell_death p (by omega) (by omega)).2⟩
      | true =>
        obtain ⟨j, hj, he, hz⟩ := even_shell_deadline p (by omega) hW
        exact ⟨2*n-1+j, by omega, he, hz⟩
    obtain ⟨t, ht, he, hz⟩ := fail
    have eq : 2*(t/2) = t := by omega
    have killed : zrow (shell p n b) (2*(t/2)) 1 = false := by simpa only [shell,eq] using hz
    refine ⟨t/2, ?_, by omega, killed⟩
    apply Classical.byContradiction
    intro h
    have htrue := past (t/2) (by omega)
    rw [htrue] at killed
    contradiction



set_option maxRecDepth 24000 in
private theorem sharp_window : orb 32 4057 (1,0) = (3691128342,1) := by decide +kernel

private theorem sharp_bits :
    ∀ j : Fin 32, j.val % 2 = 1 →
      ((prun 3691128342 j.val).testBit 0 = false ↔ j.val = 31) := by decide +kernel

/-- The uniform delay of 30 ticks past the even width is attained on an unbounded residue class. -/
theorem even_shell_sharp {m n : Nat} (p : Fin m → Bool)
    (hW : 8*m+2 ≤ 2*n-1) (hr : n%2048 = 2029) :
    (∀ s < n+15, zrow (shell p n true) (2*s) 1 = true) ∧
      zrow (shell p n true) (2*n+30) 1 = false := by
  have hn : 0 < n := by omega
  have res : (2*n-1)%4096 = 4057 := by omega
  have read (j : Nat) (hj : j < 32) (ho : j%2=1) :
      (zrow (shell p n true) (2*n-1+j) 1 = false ↔ j=31) := by
    rw [even_shell_read p hn hW hj, res, sharp_window]
    exact sharp_bits ⟨j,hj⟩ ho
  constructor
  · intro s hs
    by_cases h : s < n
    · rw [shell, splice_trace p _ _ (by omega)]
      simp [alt]
    · let j := 2*s-(2*n-1)
      have he : 2*s=2*n-1+j := by dsimp [j]; omega
      have hlt : j<31 := by dsimp [j]; omega
      have hj : j%2=1 := by dsimp [j]; omega
      rw [he]
      apply Classical.byContradiction
      intro hz
      have := (read j (by omega) hj).mp (Bool.eq_false_iff.mpr hz)
      omega
  · rw [show 2*n+30=2*n-1+31 by omega]
    exact (read 31 (by decide) (by decide)).mpr rfl

end PhaseTwo.StripeHistory
