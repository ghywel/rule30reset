import Rule30Equivalents.Mixing

/-! Finite boundary histories for the fair right half of Rule 30.
Index zero of a right half denotes spatial site +1. -/

namespace K83RightCoin

open MeasureTheory Ruliology.CellularAutomata Rule30Realization
open Rule30Equivalents Genericity RandomConfigurations

/-- Draw the initial right half and prescribe the entire time trace at site zero.
The kit's unique realization gives its physical right half at time T. -/
noncomputable def after (w : ℕ → Bool) (T : ℕ) (r : ℕ → Bool) : ℕ → Bool :=
  rightHalf (evol (traceRightHalf.symm (w, r)) T)

theorem measurable_after (w : ℕ → Bool) (T : ℕ) : Measurable (after w T) :=
  measurable_rightHalf.comp ((Mixing.measurePreserving_evol T).measurable.comp
    (traceRightHalf.symm.continuous.measurable.comp (measurable_const.prodMk measurable_id)))

/-- Agreement in the right row at time zero and boundary at times 0,…,T−1
determines the entire right row at time T. -/
theorem right_congr {x y : ℤ → Bool} (right : rightHalf x = rightHalf y) (T : ℕ)
    (wall : ∀ i < T, trace x i = trace y i) :
    rightHalf (evol x T) = rightHalf (evol y T) := by
  have h : ∀ t ≤ T, ∀ p : ℤ, 1 ≤ p → evol x t p = evol y t p := by
    intro t
    induction t with
    | zero =>
      intro _ p hp
      have e := congrFun right (p-1).toNat
      simpa only [rightHalf, evol, show ((p-1).toNat : ℤ) + 1 = p by omega] using e
    | succ t ih =>
      intro ht p hp
      have hleft : evol x t (p-1) = evol y t (p-1) := by
        rcases eq_or_lt_of_le hp with eq | lt
        · subst p
          exact wall t (by omega)
        · exact ih (by omega) _ (by omega)
      simp only [evol, hleft, ih (by omega) p hp, ih (by omega) (p+1) (by omega)]
  funext n
  exact h T le_rfl (n+1) (by omega)

/-- Recovering the entire preceding right half and the boundary bit from one output right half,
when that output contains 010 arbitrarily far east. -/
private theorem back_one {x y : ℤ → Bool}
    (same : rightHalf (evol x 1) = rightHalf (evol y 1))
    (win : ∀ n : ℤ, ∃ q ≥ n,
      evol x 1 q = false ∧ evol x 1 (q+1) = true ∧ evol x 1 (q+2) = false) :
    ∀ p : ℤ, 0 ≤ p → x p = y p := by
  intro p hp
  obtain ⟨q, hq, h0, h1, h2⟩ := win (p+1)
  apply Preimages.eq_of_evol_one_eq_on_of_window (by omega : p < q) _ h0 h1 h2
  intro j hj _
  have e := congrFun same (j-1).toNat
  simpa only [rightHalf, show ((j-1).toNat : ℤ) + 1 = j by omega] using e

/-- Almost every full row has enough synchronizers in every image to decode a finite
past wall word, exclusively from the sites strictly east of it at the final time. -/
theorem ae_read_past :
    ∀ᵐ x ∂(coins ℤ), ∀ (T : ℕ) (y : ℤ → Bool),
      rightHalf (evol x T) = rightHalf (evol y T) →
        ∀ t < T, trace x t = trace y t := by
  filter_upwards [Mixing.ae_isNormal_rows] with x hnormal
  have hw (t : ℕ) (n : ℤ) : ∃ q ≥ n, evol x t q = false ∧
      evol x t (q+1) = true ∧ evol x t (q+2) = false := by
    have hd : Disjunctive fun i : ℕ => evol x t i :=
      fun k w => StrongerStatements.disjunctive_of_isNormal (hnormal t) k w
    obtain ⟨i, hi, hword⟩ := Mixing.exists_ge_of_disjunctive hd ![false,true,false] n.toNat
    refine ⟨i, by omega, ?_⟩
    have h0 := hword 0
    have h1 := hword 1
    have h2 := hword 2
    simp only [Fin.isValue, Fin.val_zero, Fin.val_one, Fin.val_two, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.cons_val_two, Matrix.head_cons, Matrix.tail_cons,
      add_zero] at h0 h1 h2
    push_cast at h0 h1 h2
    exact ⟨h0,h1,h2⟩
  intro T
  induction T with
  | zero => intro y hy t ht; omega
  | succ t ih =>
    intro y final j hj
    have one (z : ℤ → Bool) : evol (evol z t) 1 = evol z (t+1) := by rfl
    have past := back_one (x := evol x t) (y := evol y t)
      (by rw [one, one]; exact final) (by rw [one]; exact hw (t+1))
    by_cases jt : j = t
    · subst j
      exact past 0 le_rfl
    · exact ih y (funext fun n => past (n+1) (by omega)) j (by omega)

private theorem continuous_after (w : ℕ → Bool) (T : ℕ) : Continuous (after w T) :=
  continuous_rightHalf.comp ((continuous_pi (continuous_evol T)).comp
    (traceRightHalf.symm.continuous.comp (continuous_const.prodMk continuous_id)))

/-- The closed set of right rows attainable after the indicated driven history. -/
def attainable (w : ℕ → Bool) (T : ℕ) : Set (ℕ → Bool) := Set.range (after w T)

theorem closed_attainable (w : ℕ → Bool) (T : ℕ) : IsClosed (attainable w T) :=
  (isCompact_range (continuous_after w T)).isClosed

/-- The exact law of a forced right half at a fixed time: it is the fair law restricted
to the closed set of rows with this boundary history, renormalized by 2^T. -/
theorem after_exact (w : ℕ → Bool) (T : ℕ) (E : Set (ℕ → Bool)) (hE : MeasurableSet E) :
    (2⁻¹ : ENNReal)^T * coins ℕ (after w T ⁻¹' E) =
      coins ℕ (attainable w T ∩ E) := by
  let C := Set.pi (Finset.range T : Set ℕ) (fun i => {w i})
  let A := after w T ⁻¹' E
  have hC : MeasurableSet C :=
    MeasurableSet.pi (Finset.range T).countable_toSet (fun _ _ => measurableSet_singleton _)
  have hA : MeasurableSet A := measurable_after w T hE
  have mass : coins ℕ C = (2⁻¹ : ENNReal)^T := by
    dsimp only [C]
    rw [coins_pi, Finset.prod_congr rfl fun i _ => coin_singleton (w i),
      Finset.prod_const, Finset.card_range]
  let F := fun x : ℤ → Bool => rightHalf (evol x T)
  have same : traceRightHalf ⁻¹' (C ×ˢ A) =ᵐ[coins ℤ] F ⁻¹' (attainable w T ∩ E) := by
    filter_upwards [ae_read_past] with x hx
    apply propext
    change (trace x ∈ C ∧ after w T (rightHalf x) ∈ E) ↔
      (F x ∈ attainable w T ∧ F x ∈ E)
    have forward (h : trace x ∈ C) : F x = after w T (rightHalf x) := by
      have repr := traceRightHalf.apply_symm_apply (w, rightHalf x)
      rw [traceRightHalf_apply] at repr
      apply right_congr (congrArg Prod.snd repr).symm
      intro i hi
      exact (h i (Finset.mem_range.mpr hi)).trans ((congrFun (congrArg Prod.fst repr) i).symm)
    constructor
    · rintro ⟨hc,he⟩
      exact ⟨⟨rightHalf x, (forward hc).symm⟩, forward hc ▸ he⟩
    · rintro ⟨⟨r,hr⟩,he⟩
      have rep := traceRightHalf.apply_symm_apply (w,r)
      rw [traceRightHalf_apply] at rep
      have hc : trace x ∈ C := by
        intro i hi
        exact (hx T (traceRightHalf.symm (w,r)) hr.symm i (Finset.mem_range.mp hi)).trans
          (congrFun (congrArg Prod.fst rep) i)
      exact ⟨hc, forward hc ▸ he⟩
  calc
    (2⁻¹ : ENNReal)^T * coins ℕ A = ((coins ℕ).prod (coins ℕ)) (C ×ˢ A) := by
      rw [Measure.prod_prod, mass]
    _ = coins ℤ (traceRightHalf ⁻¹' (C ×ˢ A)) :=
      (measurePreserving_traceRightHalf.measure_preimage (hC.prod hA).nullMeasurableSet).symm
    _ = coins ℤ (F ⁻¹' (attainable w T ∩ E)) := measure_congr same
    _ = coins ℕ (attainable w T ∩ E) := (measurePreserving_rightHalf.comp
      (Mixing.measurePreserving_evol T)).measure_preimage
        (((closed_attainable w T).measurableSet.inter hE).nullMeasurableSet)

/-- A deterministic T-tick drive multiplies the probability of any event by at most 2^T. -/
theorem after_bound (w : ℕ → Bool) (T : ℕ) (E : Set (ℕ → Bool)) (hE : MeasurableSet E) :
    (2⁻¹ : ENNReal)^T * coins ℕ (after w T ⁻¹' E) ≤ coins ℕ E := by
  rw [after_exact w T E hE]
  exact measure_mono Set.inter_subset_right

theorem mass_attainable (w : ℕ → Bool) (T : ℕ) :
    coins ℕ (attainable w T) = (2⁻¹ : ENNReal)^T := by
  simpa using (after_exact w T Set.univ MeasurableSet.univ).symm

/-- Families of successively longer prescribed pasts have null common range. The words
need not be periodic, or even mutually consistent. -/
theorem long_past_null (walls : ℕ → ℕ → Bool) :
    coins ℕ (⋂ T : ℕ, attainable (walls T) T) = 0 := by
  apply le_antisymm _ zero_le
  apply ge_of_tendsto' (ENNReal.tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num :
    (2⁻¹ : ENNReal) < 1))
  intro T
  rw [← mass_attainable (walls T) T]
  exact measure_mono (Set.iInter_subset _ T)

/-- Two distinct past wall words can label the same present right half only on a null set. -/
theorem incompatible_pasts (w v : ℕ → Bool) (T : ℕ) (hd : ∃ j < T, w j ≠ v j) :
    coins ℕ (attainable w T ∩ attainable v T) = 0 := by
  let F := fun x : ℤ → Bool => rightHalf (evol x T)
  have measurableIntersection := (closed_attainable w T).measurableSet.inter
      (closed_attainable v T).measurableSet
  rw [← (measurePreserving_rightHalf.comp
    (Mixing.measurePreserving_evol T)).measure_preimage measurableIntersection.nullMeasurableSet]
  apply measure_eq_zero_iff_ae_notMem.mpr
  filter_upwards [ae_read_past] with x hx
  change x ∉ F ⁻¹' (attainable w T ∩ attainable v T)
  rintro ⟨⟨r, hr⟩, ⟨s, hs⟩⟩
  obtain ⟨j,hj,ne⟩ := hd
  have get (w : ℕ → Bool) (r : ℕ → Bool) (h : after w T r = F x) : trace x j = w j := by
    have rep := traceRightHalf.apply_symm_apply (w,r)
    rw [traceRightHalf_apply] at rep
    exact (hx T (traceRightHalf.symm (w,r)) h.symm j hj).trans (congrFun (congrArg Prod.fst rep) j)
  exact ne ((get w r hr).symm.trans (get v s hs))

/-- Countably many proposed backward histories (in particular all eventually periodic
pasts) still make a null set of present right halves. -/
theorem countable_long_past_null {ι : Type} [Countable ι] (walls : ι → ℕ → ℕ → Bool) :
    coins ℕ (⋃ i, ⋂ T, attainable (walls i T) T) = 0 :=
  measure_iUnion_null (fun i => long_past_null (walls i))

/-- Null right-row events stay null after any finite prescribed wall transient. -/
theorem after_null (w : ℕ → Bool) (T : ℕ) {E : Set (ℕ → Bool)} (hE : MeasurableSet E)
    (hzero : coins ℕ E = 0) : coins ℕ (after w T ⁻¹' E) = 0 := by
  have bound := after_bound w T E hE
  rw [hzero, nonpos_iff_eq_zero, mul_eq_zero] at bound
  exact bound.resolve_left (pow_ne_zero _ (ENNReal.inv_ne_zero.mpr (by norm_num)))

end K83RightCoin
