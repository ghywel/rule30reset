module

public import Ruliology.CellularAutomata.Rule30FirstCheckDegree
public import Ruliology.CellularAutomata.Rule30PlantedSurvivor

/-!
# First checks in the planted survivor

Use the same wall trace in both systems and read the physical cell of each
reconstructed start. At depth `2*n+1` the planting flips exactly the all-black
free word once `n ≥ L`. At depth `2*n` it leaves every word unchanged.
The coefficient omitting the third free bit gives the exact ordinary-phase
degree when planting cancels the top monomial at an odd width.
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30PlantedFirstCheck

open Rule30ZeroBoundary Rule30FirstChecks Rule30FirstCheckDegree Rule30PlantedSurvivor

/-- The conjugated start realises the prescribed trace. -/
theorem planted_trace (L : Nat) (hL : 1 ≤ L) (f : Nat → Bool) (t : Nat) :
    Tn L (psi L (Theta f)) t 1 = alt f t := by
  rw [Tn_depth1 L hL, psiInv_psi, Theta_col]

def plantedCheck (L n : Nat) (l : List Bool) : Bool :=
  psi L (Theta (word l)) (2 * n + 1)

def plantedOther (L n : Nat) (l : List Bool) : Bool :=
  psi L (lam (altO (word l))) (2 * n)

/-- The conjugated reconstruction also realises the opposite-phase trace. -/
theorem planted_other_trace (L : Nat) (hL : 1 ≤ L) (f : Nat → Bool) (t : Nat) :
    Tn L (psi L (lam (altO f))) t 1 = altO f t := by
  rw [Tn_depth1 L hL, psiInv_psi]
  exact (realization (altO f)).1 t

private theorem theta_black : Theta (fun _ => true) = stripe := by
  have h := Theta_unique (L := stripe) (f := fun _ => true)
    (fun _ => by rw [zrow_stripe]; rfl) (fun _ => by rw [zrow_stripe]; rfl)
  exact h.symm.trans (funext (zrow_stripe 0))

private theorem all_iff (l : List Bool) :
    l.all id = true ↔ ∀ s, s < l.length → word l s = true := by
  induction l with
  | nil => simp
  | cons b l ih =>
    simp only [List.all_cons, Bool.and_eq_true, id_eq, ih]
    constructor
    · rintro ⟨hb, hl⟩ s hs
      cases s with
      | zero => exact hb
      | succ s => exact hl s (by simp_all)
    · intro h
      exact ⟨h 0 (by simp), fun s hs => h (s+1) (by simp_all)⟩

private theorem stripe_corner (n : Nat) (l : List Bool) (hl : l.length = n) :
    pf (Theta (word l)) (2*n+1) = l.all id := by
  apply Bool.eq_iff_iff.mpr
  rw [pf_iff, all_iff]
  constructor
  · intro h s hs
    apply Theta_inverse_dep (word l) (fun _ => true) s
    intro k hk
    rw [theta_black]
    cases k with
    | zero => rfl
    | succ k => exact h _ (by omega) (by omega)
  · intro h j _ hj
    rw [← theta_black]
    exact Theta_dep _ _ _ (fun s hs => h s (by omega))

/-- The full truth-table correction in the ordinary phase. -/
theorem corner_identity (L n : Nat) (l : List Bool) (hl : l.length = n) :
    plantedCheck L n l = xor (check n l) (decide (L ≤ n) && l.all id) := by
  unfold plantedCheck psi check
  rw [stripe_corner n l hl, show site L (2*n+1) = decide (L ≤ n) from
    decide_eq_decide.mpr (by omega)]

theorem other_unchanged (L n : Nat) (l : List Bool) :
    plantedOther L n l = otherCheck n l := by
  unfold plantedOther psi
  rw [show site L (2*n) = false from decide_eq_false (by omega)]
  simp [otherCheck, lam]

private theorem coeff_congr_len : ∀ (S : List Bool) (F G : List Bool → Bool),
    (∀ l, l.length = S.length → F l = G l) → coeff S F = coeff S G
  | [], _, _, h => h [] rfl
  | false :: S, F, G, h =>
    coeff_congr_len S _ _ (fun l hl => h (false :: l) (by simp [hl]))
  | true :: S, F, G, h => by
    unfold coeff
    rw [coeff_congr_len S (fun l => F (false :: l)) (fun l => G (false :: l))
      (fun l hl => h (false :: l) (by simp [hl])),
      coeff_congr_len S (fun l => F (true :: l)) (fun l => G (true :: l))
      (fun l hl => h (true :: l) (by simp [hl]))]

private theorem coeff_zero (S : List Bool) : coeff S (fun _ => false) = false := by
  induction S with
  | nil => rfl
  | cons b S ih => cases b <;> simp [coeff, ih]

private theorem coeff_corner (S : List Bool) : coeff S (fun l => l.all id) = S.all id := by
  induction S with
  | nil => rfl
  | cons b S ih => cases b <;> simp [coeff, coeff_zero, ih]

/-- Every proper coefficient survives the planting. Only the top toggles. -/
theorem coefficient (L n : Nat) (S : List Bool) (hS : S.length = n) :
    coeff S (plantedCheck L n) = xor (coeff S (check n)) (decide (L ≤ n) && S.all id) := by
  rw [coeff_congr_len S (plantedCheck L n) _ (fun l hl => corner_identity L n l (hl.trans hS)),
    coeff_xor]
  by_cases h : L ≤ n <;> simp [h, coeff_corner, coeff_zero]

theorem planted_top (L n : Nat) (hn : 1 ≤ n) :
    coeff (List.replicate n true) (plantedCheck L n) =
      xor (decide (n % 2 = 1)) (decide (L ≤ n)) := by
  rw [coefficient L n _ (List.length_replicate ..), top_coefficient n hn]
  simp

theorem planted_omit_one (L n : Nat) (hn : 2 ≤ n) :
    coeff (true :: false :: List.replicate (n - 2) true) (plantedCheck L n) =
      decide (n % 2 = 0) := by
  rw [coefficient L n _ (by simp; omega), omit_coefficient n hn]
  simp

theorem planted_other_degree (L n : Nat) (hn : 1 ≤ n) : IsDegree n (plantedOther L n) n := by
  rw [show plantedOther L n = otherCheck n from funext (other_unchanged L n)]
  exact otherCheck_degree n hn

/-- Insert a zero in position two of a word of length at least two. -/
private def insertThird : List Bool → List Bool
  | [] => []
  | x :: l => x :: ins l

private def restricted (F : Nat → List Bool → Bool) (m : Nat) : Bool :=
  xs (m + 2) (fun l => F (m + 3) (insertThird l))

private theorem restrict_snoc (F : Nat → List Bool → Bool)
    (D : Nat → List Bool → Bool)
    (hD : ∀ n p, p.length = n →
      xor (F (n + 1) (p ++ [false])) (F (n + 1) (p ++ [true])) = D n p) (m : Nat) :
    restricted F (m + 1) = xs (m + 2) (fun l => D (m + 3) (insertThird l)) := by
  unfold restricted
  rw [xs_snoc]
  apply xs_congr
  intro l hl
  obtain _ | ⟨x, _ | ⟨y, t⟩⟩ := l
  · simp at hl
  · simp at hl
  exact hD (m + 3) (x :: y :: false :: t) (by simp_all)

private theorem restricted_hc (m : Nat) :
    xs (m + 2) (fun l => hc (m + 3) (insertThird l)) = false :=
  xs_head fun l => hc_cons (m + 3) false true (ins l)

/-- The derivative in the last free bit keeps the parity of the time-one cell on this subcube. -/
private theorem restricted_bcell (m : Nat) : restricted bcell m = false := by
  induction m with
  | zero => decide
  | succ m ih =>
    rw [restrict_snoc bcell _ bcell_flip, xs_xor, restricted_hc, xs_not]
    simpa [restricted] using ih

/-- The corresponding parity at time zero stays one. The time-one correction has parity zero. -/
private theorem restricted_check (m : Nat) : restricted check m = true := by
  induction m with
  | zero => decide
  | succ m ih =>
    rw [restrict_snoc check _ check_flip, xs_xor, xs_xor, restricted_hc, xs_not, xs_not]
    change xor (xor false (restricted bcell m)) (restricted check m) = true
    rw [restricted_bcell, ih]
    rfl

/-- Omitting the third variable leaves a nonzero coefficient, for odd and even widths alike. -/
theorem omit_third_coefficient (m : Nat) :
    coeff (true :: true :: false :: List.replicate m true) (check (m + 3)) = true := by
  have eq : ∀ F : List Bool → Bool,
      coeff (true :: true :: false :: List.replicate m true) F =
        xs (m + 2) (fun l => F (insertThird l)) := by
    intro F
    simp only [coeff, xs, insertThird, ins, coeff_replicate]
  rw [eq]
  exact restricted_check m

/-- Below the planting threshold, the polynomial has all the kit's coefficients. -/
theorem degree_before (L n : Nat) (hn : 1 ≤ n) (h : n < L) :
    IsDegree n (plantedCheck L n) (if n % 2 = 1 then n else n - 1) := by
  obtain ⟨upper, S, hS, hs, hc⟩ := check_degree n hn
  have same (M : List Bool) (hM : M.length = n) :
      coeff M (plantedCheck L n) = coeff M (check n) := by
    simp [coefficient L n M hM, Nat.not_le.mpr h]
  exact ⟨fun M hM ht => (same M hM).trans (upper M hM ht),
    S, hS, hs, (same S hS).trans hc⟩

/-- At and above the planting threshold, the top appears at even widths.
At odd widths the top vanishes and the coefficient omitting the third bit survives. -/
theorem degree_after (L n : Nat) (hn : 2 ≤ n) (h : L ≤ n) :
    IsDegree n (plantedCheck L n) (if n % 2 = 0 then n else n - 1) := by
  have top := planted_top L n (by omega)
  by_cases heven : n % 2 = 0
  · rw [ite_eq_left heven]
    refine ⟨fun S hS hlt => ?_, List.replicate n true, by simp, by simp, ?_⟩
    · have := List.count_le_length (a := true) (l := S)
      omega
    · simpa [h, heven] using top
  · rw [ite_eq_right heven]
    have hodd : n % 2 = 1 := by omega
    obtain ⟨m, rfl⟩ : ∃ m, n = m + 3 := ⟨n - 3, by omega⟩
    refine ⟨fun S hS hlt => ?_, true :: true :: false :: List.replicate m true,
      by simp, by simp, ?_⟩
    · have := List.count_le_length (a := true) (l := S)
      rw [count_full S (by omega), hS, top]
      simp [hodd, h]
    · rw [coefficient L (m+3) _ (by simp), omit_third_coefficient]
      simp

/-- At one free bit and active planting the check is the zero function. -/
theorem planted_one_zero (L : Nat) (h : L ≤ 1) (l : List Bool) (hl : l.length = 1) :
    plantedCheck L 1 l = false := by
  rw [corner_identity L 1 l hl, decide_eq_true h]
  obtain _ | ⟨x, _ | ⟨y, t⟩⟩ := l
  · simp at hl
  · cases x <;> decide
  · simp at hl

/-- Complete degree classification in the physical planted system (`L ≥ 1`).
An identically zero check has no nonzero ANF coefficient of any degree. -/
theorem planted_degree (L n : Nat) (hL : 1 ≤ L) :
    if n = 1 ∧ L = 1 then (∀ l, l.length = n → plantedCheck L n l = false)
    else IsDegree n (plantedCheck L n)
      (if n < L then (if n % 2 = 1 then n else n - 1)
       else (if n % 2 = 0 then n else n - 1)) := by
  split
  · rintro l hl
    obtain ⟨rfl, rfl⟩ := ‹n = 1 ∧ L = 1›
    exact planted_one_zero 1 (by decide) l hl
  · split
    · by_cases h0 : n = 0
      · subst n
        refine ⟨fun S hS ht => ?_, [], rfl, rfl, ?_⟩
        · have := List.count_le_length (a := true) (l := S)
          omega
        · change plantedCheck L 0 [] = true
          rw [corner_identity L 0 [] rfl, decide_eq_false (by omega)]
          rfl
      · exact degree_before L n (by omega) (by omega)
    · exact degree_after L n (by omega) (by omega)

end Ruliology.CellularAutomata.Rule30PlantedFirstCheck
