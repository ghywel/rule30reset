import LagCert
import ModulusSingleton

/-! The coverage of `ModulusLayers` and the singleton step of `ModulusSingleton`, for `GoodAny` and any width.

A certificate on a contiguous substrip, or on the assignment shifted by a phase, gives `GoodAny` on the strip. The
substrip pruning then classifies every assignment of a width, and `GoodAny` at every assignment of a width-`W`
strip forces, through Jen's theorem, a column with falls at two residues in every `W` adjacent singleton columns. -/
namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata Rule30StripCertificates Rule30Jen

private theorem pair_eq_of_bits' {s d j : Nat} (h₁ : s.testBit j = d.testBit j)
    (h₂ : s.testBit (j+1) = d.testBit (j+1)) : (s >>> j)%4 = (d >>> j)%4 := by
  change (s >>> j)%(2^2) = (d >>> j)%(2^2)
  apply Nat.eq_of_testBit_eq
  intro k
  cases k with
  | zero => simpa only [Nat.testBit_mod_two_pow, Nat.testBit_shiftRight, Nat.add_zero,
      decide_eq_true (by decide : 0<2), Bool.true_and] using h₁
  | succ k =>
    cases k with
    | zero => simpa only [Nat.testBit_mod_two_pow, Nat.testBit_shiftRight,
        decide_eq_true (by decide : 1<2), Bool.true_and] using h₂
    | succ k =>
      simp only [Nat.testBit_mod_two_pow, decide_eq_false (show ¬ (k+1+1 < 2) by omega), Bool.false_and]

theorem goodAny_of_slice {w v k m : Nat} {a : Nat → Nat} (hk : k+v ≤ w)
    (good : GoodAny v m (fun j => a (k+j))) : GoodAny w m a := by
  intro x hx
  obtain ⟨j, L, N, hL, hj, h⟩ := good _ (slice_run hk hx)
  refine ⟨k+j, L, N, hL, by omega, fun t ht => ?_⟩
  obtain ⟨p, q⟩ := pair_bits (h t ht)
  rw [slice_bit (show j < v by omega), slice_bit (show j < v by omega)] at p
  rw [slice_bit hj, slice_bit hj, ← Nat.add_assoc] at q
  exact pair_eq_of_bits' p q

theorem goodAny_congr {w m : Nat} {a b : Nat → Nat} (h : ∀ j, j < w → a j = b j)
    (good : GoodAny w m a) : GoodAny w m b :=
  fun x hx => good x (run_congr (fun j hj => (h j hj).symm) hx)

theorem goodAny_of_rotated {w m q : Nat} {a : Nat → Nat} (hq : q < m)
    (ha : ∀ j, j < w → a j < m)
    (good : GoodAny w m (fun j => rotate m q (a j))) : GoodAny w m a := by
  intro x hx
  let y (t : Nat) := x (t+q)
  have hy : Run w m (fun j => rotate m q (a j)) y := by
    refine ⟨fun t => hx.bounded _, fun t => ?_⟩
    have e := hx.edge (t+q)
    change Edge w _ (x (t+q)) (x (t+1+q))
    rw [show t+1+q = t+q+1 by omega]
    have same : permit w (fun j => rotate m q (a j)) (t%m) = permit w a ((t+q)%m) := by
      apply Nat.eq_of_testBit_eq
      intro j
      rw [permit_bit, permit_bit]
      by_cases hj : j < w
      · simp only [hj, true_and, Nat.add_mod t q m, Nat.mod_eq_of_lt hq]
        rw [Bool.eq_iff_iff, decide_eq_true_eq, decide_eq_true_eq]
        exact ⟨fun e => (rotate_add_iff hq (ha j hj) (Nat.mod_lt _ (by omega))).mpr e.symm |>.symm,
          fun e => (rotate_add_iff hq (ha j hj) (Nat.mod_lt _ (by omega))).mp e.symm |>.symm⟩
      · simp [hj]
    rwa [same]
  obtain ⟨j, L, N, hL, hj, per⟩ := good y hy
  refine ⟨j, L, N+q, hL, hj, fun t ht => ?_⟩
  simpa only [y, show t-q+L+q=t+L by omega, show t-q+q=t by omega] using per (t-q) (by omega)

def ClassifiesAny (w m : Nat) (bad : List (List Nat)) : Prop :=
  ∀ a, Valid w m a → a 0 = 0 → GoodAny w m a ∨ labelsOf w a ∈ bad

theorem pairs_classifyAny (m : Nat) : ClassifiesAny 2 m (pairs m) := by
  intro a ha zero
  exact Or.inr (List.mem_map.mpr ⟨a 1, List.mem_range.mpr (ha 1 (by decide)), by
    simp [labelsOf, zero, show List.range 2 = [0,1] by decide]⟩)

theorem labelsOf_getD {w : Nat} {a : Nat → Nat} {j : Nat} (hj : j < w) : (labelsOf w a).getD j 0 = a j := by
  rw [List.getD_eq_getElem?_getD]
  have bound : j < (List.range w).length := by simpa using hj
  simp only [labelsOf, List.getElem?_map, List.getElem?_eq_getElem bound, List.getElem_range, Option.map_some,
    Option.getD_some]

/-- One width up: an assignment is good by a substrip, left in `remaining`, or one of the certified `cs`. -/
theorem classify_stepAny {w m : Nat} {previous remaining cs : List (List Nat)} (hw : 0 < w) (hm : 0 < m)
    (prev : ClassifiesAny w m previous)
    (certs : ∀ l ∈ cs, GoodAny (w+1) m (fun j => l.getD j 0))
    (complete : ruledOut m previous remaining = cs) :
    ClassifiesAny (w+1) m remaining := by
  intro a ha zero
  rcases prev a (fun j h => ha j (by omega)) zero with good | leftWord
  · exact Or.inl (goodAny_of_slice (k:=0) (v:=w) (w:=w+1) (by omega) (by simpa using good))
  have ha1 := ha 1 (by omega)
  let b (j : Nat) := rotate m (a 1) (a (j+1))
  have hb : Valid w m b := fun j hj => rotate_lt ha1 (ha (j+1) (by omega))
  have b0 : b 0 = 0 := by simp [b, rotate]
  rcases prev b hb b0 with good | rightWord
  · have good' := goodAny_of_rotated ha1 (fun j hj => ha (1+j) (by omega))
      (show GoodAny w m (fun j => rotate m (a 1) (a (1+j))) by simpa [b, Nat.add_comm] using good)
    exact Or.inl (goodAny_of_slice (k:=1) (w:=w+1) (by omega) good')
  by_cases bad : labelsOf (w+1) a ∈ remaining
  · exact Or.inr bad
  have h := phase_extendF hw leftWord rightWord (ha w (by omega))
  have member : labelsOf (w+1) a ∈ ruledOut m previous remaining := by
    unfold ruledOut
    exact List.mem_filter.mpr ⟨h, by simp [List.contains_eq_mem, bad]⟩
  rw [complete] at member
  exact Or.inl (goodAny_congr (fun j hj => labelsOf_getD hj) (certs _ member))

theorem of_emptyAny {w m : Nat} (hw : 0 < w) (classified : ClassifiesAny w m []) {a : Nat → Nat}
    (ha : Valid w m a) : GoodAny w m a := by
  have h0 := ha 0 hw
  apply goodAny_of_rotated h0 ha
  have e := classified (fun j => rotate m (a 0) (a j))
    (fun j hj => rotate_lt h0 (ha j hj)) (by simp [rotate])
  simpa only [List.not_mem_nil, or_false] using e

/-! ### Physical rows of any width -/

def rowW (W T : Nat) (j : Int) : Nat := encRow T (j-1) W

theorem rowW_lt (W T : Nat) (j : Int) : rowW W T j < 2^W :=
  (enc_encRow W T (j-1)).1

theorem rowW_bit (W T : Nat) (j : Int) (k : Nat) (hk : k < W) :
    (rowW W T j).testBit k = cell T (j+k) := by
  simpa [rowW] using (enc_encRow W T (j-1)).2 k hk

theorem rowW_step (W T : Nat) (j : Int) :
    rowW W (T+1) j = stripStep W (cell T (j-1)) (cell T (j+W)) (rowW W T j) := by
  have nxt := enc_step (enc_encRow W T (j-1))
  simp only [Int.sub_add_cancel] at nxt
  apply Nat.eq_of_testBit_eq
  intro k
  by_cases hk : k < W
  · rw [rowW_bit _ _ _ k hk]
    simpa [rowW] using (nxt.2 k hk).symm
  · have cut : 2^W ≤ 2^k := Nat.pow_le_pow_right (by decide) (by omega)
    rw [Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (rowW_lt _ _ _) cut)]
    exact (Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (stripStep_lt _ _ _ _) cut)).symm

/-! ### The singleton -/

private theorem escapeW {W m : Nat} (hW : 0 < W) (hm : 0 < m) (i : Int) (a : Fin W → Fin m)
    (good : ∀ a, (∀ j, j < W → a j < m) → GoodAny W m a) (T : Nat) :
    ∃ (j : Fin W) (t : Nat), T ≤ t ∧ Fall (i+j.val) t ∧ t%m ≠ (a j).val := by
  apply Classical.byContradiction
  intro no
  let S := T*m
  have Slarge : T ≤ S := by
    simpa [S] using Nat.mul_le_mul_left T (show 1 ≤ m by omega)
  let phases (j : Nat) := if hj : j < W then (a ⟨j,hj⟩).val else 0
  let x (t : Nat) := rowW W (S+t) i
  have run : Run W m phases x := by
    refine ⟨fun t => rowW_lt _ _ _, fun t => ?_⟩
    have adv := rowW_step W (S+t) i
    refine ⟨mem_successors.mpr ⟨_, _, by simpa [x, Nat.add_assoc] using adv⟩, (fits_iff _ _ _).mpr ?_⟩
    intro j on off
    by_cases hj : j < W
    · rw [permit_bit, decide_eq_true_eq]
      refine ⟨hj, ?_⟩
      have b : Fall (i+j) (S+t) := by
        unfold x at on off
        rw [rowW_bit _ _ _ _ hj] at on off
        exact ⟨on, by simpa only [Nat.add_assoc] using off⟩
      have eq : (S+t)%m = (a ⟨j,hj⟩).val := by
        apply Classical.byContradiction
        intro neq
        exact no ⟨⟨j,hj⟩, S+t, by omega, b, neq⟩
      simpa only [S, phases, dite_eq_left hj, Nat.add_comm _ t, Nat.add_mul_mod_self_right] using eq.symm
    · have hn : (x t).testBit j = false :=
        Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (rowW_lt _ _ _)
          (Nat.pow_le_pow_right (by decide : 0<2) (by omega : W ≤ j)))
      simp [hn] at on
  have phasesBound (j : Nat) (hj : j < W) : phases j < m := by
    simpa only [phases, dite_eq_left hj] using (a ⟨j,hj⟩).isLt
  obtain ⟨j, L, N, hL, hj, per⟩ := good phases phasesBound x run
  apply not_adjacent (i+j)
  · refine ⟨S+N, L, hL, fun t ht => ?_⟩
    have left := (pair_bits (per (t-S) (by omega))).1
    unfold x at left
    rw [rowW_bit _ _ _ _ (by omega), rowW_bit _ _ _ _ (by omega),
      show S+(t-S+L)=t+L by omega, show S+(t-S)=t by omega] at left
    exact left
  · refine ⟨S+N, L, hL, fun t ht => ?_⟩
    have right := (pair_bits (per (t-S) (by omega))).2
    unfold x at right
    rw [rowW_bit _ _ _ _ hj, rowW_bit _ _ _ _ hj,
      show S+(t-S+L)=t+L by omega, show S+(t-S)=t by omega] at right
    simpa only [Int.natCast_add, Int.natCast_one, ← Int.add_assoc] using right

private theorem common_boundW {k : Nat} (f : Fin k → Nat) : ∃ B, ∀ i, f i ≤ B := by
  induction k with
  | zero => exact ⟨0, fun i => Fin.elim0 i⟩
  | succ k ih =>
    obtain ⟨B, upper⟩ := ih (fun i => f i.succ)
    exact ⟨max (f 0) B, fun i => Fin.cases (Nat.le_max_left _ _)
      (fun j => Nat.le_trans (upper j) (Nat.le_max_right _ _)) i⟩

/-- `GoodAny` at every assignment of a width-`W` strip gives, in every `W` adjacent singleton columns, a column
with cofinal falls at two distinct residues modulo `m`. -/
theorem two_cofinal_from_goodAny {W m : Nat} (hW : 0 < W) (hm : 0 < m) (i : Int)
    (good : ∀ a, (∀ j, j < W → a j < m) → GoodAny W m a) :
    ∃ (j : Fin W) (r q : Fin m), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q := by
  classical
  apply Classical.byContradiction
  intro no
  have single (j : Fin W) : ∃ r : Fin m, ∀ q, q ≠ r → ¬ Cofinal (i+j.val) q := by
    by_cases h : ∃ r : Fin m, Cofinal (i+j.val) r
    · obtain ⟨r, hr⟩ := h
      exact ⟨r, fun q neq hq => no ⟨j, r, q, Ne.symm neq, hr, hq⟩⟩
    · exact ⟨⟨0, hm⟩, fun q _ hq => h ⟨q, hq⟩⟩
  let phase (j : Fin W) := Classical.choose (single j)
  have cutoff (j : Fin W) (q : Fin m) :
      ∃ B, ∀ t, B ≤ t → t%m = q.val → Fall (i+j.val) t → q = phase j := by
    by_cases eq : q = phase j
    · exact ⟨0, fun _ _ _ _ => eq⟩
    · have rare := Classical.choose_spec (single j) q eq
      apply Classical.byContradiction
      intro noBound
      apply rare
      intro T
      apply Classical.byContradiction
      intro absent
      exact noBound ⟨T, fun t ht htq hit => (absent ⟨t, ht, htq, hit⟩).elim⟩
  let B (j : Fin W) (q : Fin m) := Classical.choose (cutoff j q)
  let C (j : Fin W) := Classical.choose (common_boundW (B j))
  obtain ⟨M, hm'⟩ := common_boundW C
  obtain ⟨j, t, late, hit, off⟩ := escapeW hW hm i phase good M
  let q : Fin m := ⟨t%m, Nat.mod_lt t hm⟩
  have hq : B j q ≤ C j := Classical.choose_spec (common_boundW (B j)) q
  have eq := Classical.choose_spec (cutoff j q) t (Nat.le_trans hq (Nat.le_trans (hm' j) late)) rfl hit
  exact off (congrArg Fin.val eq)

end PhaseFalls.Moduli
