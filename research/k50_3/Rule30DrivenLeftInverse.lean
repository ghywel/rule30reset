module

public import Ruliology.CellularAutomata.Rule30DrivenLeft
public import Ruliology.CellularAutomata.Rule30TwoSidedInverse

/-!
# One inverse tick beside a prescribed wall

The wall is at site 0, and the driven cells have negative indices. A finite start
whose leftmost black cell is at `-m` has a good eight-cell edge band by age 8
when `m ≥ 2`, and by age 9 when `m = 1`. The wall may follow any Boolean
sequence. In a predecessor its own value at site 0 can be chosen independently.
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30DrivenLeftInverse

open Rule30Jen Rule30DrivenLeft Rule30TwoSidedInverse Rule30AgeEightInverse Rule30LateTwins

/-- The edge position at age `t` when the initial edge is at depth `m`. -/
def edgePosition (m t : Nat) : Int := -(m : Int) - t

/-- Read a bit of an eight-cell word, edge first, with white outside the word. -/
private def readWord (u : Nat) (j : Int) : Bool :=
  if 0 ≤ j ∧ j < 8 then u.testBit (7 - j.toNat) else false

private theorem readWord_band (f : Int → Bool) {j : Int} (hj : 0 ≤ j) (hk : j < 8) :
    readWord (band f 0 8) j = f j := by
  rw [readWord, ite_eq_left ⟨hj, hk⟩, testBit_band_lt _ _ _ _ (by omega)]
  congr 1
  omega

/-- In moving coordinates, keep the cells through the wall and white to its right. -/
private def clip (depth : Nat) (row : Int → Bool) (j : Int) : Bool :=
  if j ≤ depth then row j else false

private def edgeRow (c : Nat → Bool) (s : Int → Bool) (m t : Nat) (j : Int) : Bool :=
  L c s t (edgePosition m t + j)

private def tape (c : Nat → Bool) (s : Int → Bool) (m : Nat) (j : Int) : Bool :=
  if j < m then s (edgePosition m 0 + j) else c (j - m).toNat

private def updateWord (depth input current : Nat) : Nat :=
  band (fun j => if j < depth then stepLine (readWord current) (j - 1)
    else if j = depth then readWord input j else false) 0 8

private def runWord (m input : Nat) : Nat → Nat
  | 0 => band (clip m (readWord input)) 0 8
  | t + 1 => updateWord (m + t + 1) input (runWord m input t)

private theorem edge_at (c : Nat → Bool) (s : Int → Bool) {m : Nat}
    (hm : 0 < m) (h₀ : ∀ p, p < -(m : Int) → s p = false) (h₁ : s (-(m : Int)) = true)
    (t : Nat) : (∀ p, p < edgePosition m t → L c s t p = false) ∧ L c s t (edgePosition m t) = true := by
  have eq : edgePosition m t = -((m + t : Nat) : Int) := by unfold edgePosition; omega
  rw [eq]
  exact Rule30DrivenLeft.edge (c := c) h₀ h₁ hm t

private theorem runWord_spec (c : Nat → Bool) (s : Int → Bool) {m : Nat}
    (hm : 0 < m) (h₀ : ∀ p, p < -(m : Int) → s p = false) (h₁ : s (-(m : Int)) = true)
    (t : Nat) :
    runWord m (band (tape c s m) 0 8) t =
      band (clip (m + t) (edgeRow c s m t)) 0 8 := by
  induction t with
  | zero =>
    simp only [runWord, Nat.add_zero]
    apply band_congr
    intro j hj
    simp only [Int.zero_add, clip]
    split
    · rw [readWord_band _ (by omega) (by omega)]
      simp only [tape, edgeRow]
      by_cases h : (j : Int) < m
      · rw [ite_eq_left h, L_zero (by unfold edgePosition; omega)]
      · have e : (j : Int) = m := by omega
        rw [e, ite_eq_right (by omega), show (m : Int) - m = 0 by omega,
          show edgePosition m 0 + (m : Int) = 0 by unfold edgePosition; omega, L_col0]
        rfl
    · rfl
  | succ t ih =>
    simp only [runWord, updateWord, ih]
    apply band_congr
    intro j hj
    simp only [Int.zero_add, clip]
    by_cases h : (j : Int) < ↑(m + t + 1)
    · rw [ite_eq_left h, ite_eq_left (by omega)]
      have read (i : Int) (hi : i ≤ j) (hl : j - 2 ≤ i) :
          readWord (band (clip (m + t) (edgeRow c s m t)) 0 8) i = edgeRow c s m t i := by
        by_cases hp : 0 ≤ i
        · rw [readWord_band _ hp (by omega), clip, ite_eq_left (by omega)]
        · rw [readWord, ite_eq_right (by omega), edgeRow,
            (edge_at c s hm h₀ h₁ t).1 _ (by omega)]
      simp only [stepLine, edgeRow] at *
      rw [read _ (by omega) (by omega), read _ (by omega) (by omega), read _ (by omega) (by omega)]
      have hl : edgePosition m (t + 1) + (j : Int) < 0 := by unfold edgePosition; omega
      rw [L_succ hl]
      have hf : edgePosition m (t + 1) = edgePosition m t - 1 := by unfold edgePosition; omega
      rw [hf]
      congr 1 <;> congr 1 <;> omega
    · rw [ite_eq_right h]
      by_cases he : (j : Int) = ↑(m + t + 1)
      · rw [ite_eq_left he, ite_eq_left (by omega), readWord_band _ (by omega) (by omega)]
        rw [tape, ite_eq_right (by omega), edgeRow,
          show edgePosition m (t + 1) + (j : Int) = 0 by unfold edgePosition; omega, L_col0]
        congr 1
        omega
      · rw [ite_eq_right he, ite_eq_right (by omega)]

/-- The value of the width-dependent uniform age. -/
def threshold (m : Nat) : Nat := if m = 1 then 9 else 8

private theorem narrowTable :
    ∀ (width : Fin 7) (input : Fin 128),
      EdgeGood8 (runWord (width.val + 1) (128 + input.val) (threshold (width.val + 1))) = true := by
  decide +kernel

private theorem stable (u : Nat) (h : EdgeGood8 u = true) : EdgeGood8 (R u) = true := by
  simp only [EdgeGood8, Bool.or_eq_true, beq_iff_eq] at h
  rcases h with rfl | rfl <;> decide

private theorem band_next (c : Nat → Bool) (s : Int → Bool) {m : Nat}
    (hm : 0 < m) (h₀ : ∀ p, p < -(m : Int) → s p = false) (h₁ : s (-(m : Int)) = true)
    (t : Nat) (wide : 8 ≤ m + t) :
    band (L c s (t + 1)) (edgePosition m (t + 1)) 8 = R (band (L c s t) (edgePosition m t) 8) := by
  rw [← band_step _ _ _ (edge_at c s hm h₀ h₁ t).1]
  apply band_congr
  intro j hj
  have h : edgePosition m (t + 1) + (j : Int) = edgePosition m t - 1 + (j : Int) := by unfold edgePosition; omega
  rw [h, L_succ (by unfold edgePosition; omega)]
  rfl

private theorem band_interior (c : Nat → Bool) (s : Int → Bool) (m t : Nat) (h : 8 ≤ m + t) :
    band (clip (m + t) (edgeRow c s m t)) 0 8 = band (L c s t) (edgePosition m t) 8 := by
  apply band_congr
  intro j hj
  simp only [Int.zero_add, clip, edgeRow]
  rw [ite_eq_left (by omega)]

/-- At the claimed age and every later age, the driven half enters Hughes's good bands. -/
theorem good_band_of_age (c : Nat → Bool) (s : Int → Bool) {m : Nat}
    (hm : 0 < m) (h₀ : ∀ p, p < -(m : Int) → s p = false) (h₁ : s (-(m : Int)) = true)
    (t : Nat) (ht : threshold m ≤ t) :
    EdgeGood8 (band (L c s t) (edgePosition m t) 8) = true := by
  have threshold_ge : 8 ≤ threshold m := by unfold threshold; split <;> omega
  by_cases wide : 8 ≤ m
  · have eq (a : Nat) : band (L c s a) (edgePosition m a) 8 =
        iterR a (band (L c s 0) (edgePosition m 0) 8) := by
      induction a with
      | zero => rfl
      | succ a ih => rw [band_next c s hm h₀ h₁ a (by omega), ih, Rule30LateTwins.iterR_succ']
    rw [eq]
    let u := band (L c s 0) (edgePosition m 0) 8
    have htop : 2 ^ 7 ≤ u := band_top _ _ (edge_at c s hm h₀ h₁ 0).2 7
    have hlt : u < 256 := band_lt _ _ _
    have hne : u ≠ 0 := by omega
    have hlog : u.log2 = 7 := (Nat.log2_eq_iff hne).2 ⟨htop, hlt⟩
    have hh := top8_from_age_eight u t hne (by omega)
    rw [hlog, show 7 + t - 7 = 0 + t by omega, iter_F_shiftRight] at hh
    simpa using hh
  · have tape0 : tape c s m 0 = true := by
      rw [tape, ite_eq_left (by omega), show edgePosition m 0 + 0 = -(m : Int) by unfold edgePosition; omega, h₁]
    let u := band (tape c s m) 0 8
    have hlo : 128 ≤ u := band_top _ _ tape0 7
    have hhi : u < 256 := band_lt _ _ _
    have entry := narrowTable ⟨m - 1, by omega⟩ ⟨u - 128, by omega⟩
    change EdgeGood8 (runWord (m - 1 + 1) (128 + (u - 128)) (threshold (m - 1 + 1))) = true at entry
    rw [show m - 1 + 1 = m by omega, show 128 + (u - 128) = u by omega,
      runWord_spec c s hm h₀ h₁, band_interior c s m _ (by omega)] at entry
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le ht
    clear ht
    induction d with
    | zero => simpa using entry
    | succ d ih =>
      change EdgeGood8 (band (L c s (threshold m + d + 1)) (edgePosition m (threshold m + d + 1)) 8) = true
      rw [band_next c s hm h₀ h₁ _ (by omega)]
      exact stable _ ih

/-- An inverse image on the driven half has the exact left edge from the stated age.
The local equation is required only at negative positions. In particular, the
predecessor's bit at the wall is arbitrary. -/
theorem predecessor_edge (c : Nat → Bool) (s z : Int → Bool) {m t : Nat}
    (hm : 0 < m) (h₀ : ∀ p, p < -(m : Int) → s p = false) (h₁ : s (-(m : Int)) = true)
    (ht : threshold m ≤ t) (hz : ∀ p, p < 0 → stepLine z p = L c s t p) :
    z (-(m : Int) - t + 1) = true ∧ ∀ p, p < -(m : Int) - t + 1 → z p = false := by
  have h8 : 8 ≤ t := by unfold threshold at ht; split at ht <;> omega
  have edge := edge_at c s hm h₀ h₁ t
  have eq : band (stepLine z) (edgePosition m t) 8 = band (L c s t) (edgePosition m t) 8 := by
    apply band_congr
    intro j hj
    exact hz _ (by unfold edgePosition; omega)
  exact predecessor_edge_of_good8 (stepLine z) z (fun _ => rfl) (edgePosition m t)
    (by rw [hz _ (by unfold edgePosition; omega)]; exact edge.2)
    (fun p hp => (hz p (by unfold edgePosition at hp; omega)).trans (edge.1 p hp))
    (by rw [eq]; exact good_band_of_age c s hm h₀ h₁ t ht)

/-! ## Sharpness, including with the prescribed predecessor wall -/

private def exampleDepth (adjacent : Bool) : Nat := if adjacent then 1 else 2

private def exampleAge (adjacent : Bool) : Nat := if adjacent then 8 else 7

private def exampleWall (adjacent : Bool) (t : Nat) : Bool := adjacent && (t == 2)

private def exampleSeed (adjacent : Bool) (p : Int) : Bool := p == -(exampleDepth adjacent : Int)

/-- Both examples have this predecessor. Its west tail is black and its wall bit is white. -/
private def cofinite (p : Int) : Bool :=
  decide (p ≤ -11) || (p == -9) || (p == -5) || (p == -2)

private theorem example_middle : ∀ (adjacent : Bool) (j : Fin 9),
    stepLine cofinite (-9 + (j.val : Int)) =
      L (exampleWall adjacent) (exampleSeed adjacent) (exampleAge adjacent) (-9 + (j.val : Int)) := by
  decide +kernel

private theorem example_predecessor (adjacent : Bool) (p : Int) (hp : p < 0) :
    stepLine cofinite p = L (exampleWall adjacent) (exampleSeed adjacent) (exampleAge adjacent) p := by
  by_cases hlo : p < -9
  · have cf (q : Int) (hq : q ≤ -11) : cofinite q = true := by simp [cofinite, hq]
    have hz : ∀ q, q < -(exampleDepth adjacent : Int) → exampleSeed adjacent q = false := by
      intro q hq
      simp [exampleSeed, show q ≠ -(exampleDepth adjacent : Int) by omega]
    have hb : exampleSeed adjacent (-(exampleDepth adjacent : Int)) = true := by simp [exampleSeed]
    have hm : 0 < exampleDepth adjacent := by cases adjacent <;> decide
    have he : edgePosition (exampleDepth adjacent) (exampleAge adjacent) = -9 := by
      cases adjacent <;> decide
    have hw := (edge_at (exampleWall adjacent) (exampleSeed adjacent) hm hz hb
      (exampleAge adjacent)).1
    rw [he] at hw
    rw [hw p hlo]
    by_cases hh : p ≤ -12
    · rw [stepLine, cf (p - 1) (by omega), cf p (by omega), cf (p + 1) (by omega)]
      rfl
    · have hp' : p = -11 ∨ p = -10 := by omega
      rcases hp' with rfl | rfl <;> decide
  · let j : Fin 9 := ⟨(p + 9).toNat, by omega⟩
    have e : -9 + (j.val : Int) = p := by dsimp [j]; omega
    simpa only [e] using example_middle adjacent j

/-- At the last age below each bound there is a predecessor with no leftmost black
cell, even when its wall bit equals the actual wall at the predecessor's time.
The two cases have initial edge depths 1 and 2, respectively. -/
theorem sharp_examples (adjacent : Bool) :
    ∃ (c : Nat → Bool) (s z : Int → Bool),
      let m : Nat := if adjacent then 1 else 2
      let t : Nat := if adjacent then 8 else 7
      s (-(m : Int)) = true ∧ (∀ p, p < -(m : Int) → s p = false) ∧
      z 0 = c (t - 1) ∧ (∀ p, p < 0 → stepLine z p = L c s t p) ∧
      ∀ q, ∃ p, p < q ∧ z p = true := by
  refine ⟨exampleWall adjacent, exampleSeed adjacent, cofinite, ?_⟩
  change exampleSeed adjacent (-(exampleDepth adjacent : Int)) = true ∧
    (∀ p, p < -(exampleDepth adjacent : Int) → exampleSeed adjacent p = false) ∧
    cofinite 0 = exampleWall adjacent (exampleAge adjacent - 1) ∧
    (∀ p, p < 0 → stepLine cofinite p =
      L (exampleWall adjacent) (exampleSeed adjacent) (exampleAge adjacent) p) ∧
    ∀ q, ∃ p, p < q ∧ cofinite p = true
  refine ⟨by simp [exampleSeed], ?_, ?_, example_predecessor adjacent, ?_⟩
  · intro p hp
    simp [exampleSeed, show p ≠ -(exampleDepth adjacent : Int) by omega]
  · cases adjacent <;> decide
  · intro q
    refine ⟨min (q - 1) (-11), by omega, ?_⟩
    simp [cofinite, show min (q - 1) (-11) ≤ -11 by omega]

/-- The exact one-tick edge at a given initial depth and age, with any forward wall
and with the predecessor also allowed to choose its own wall bit. -/
def EdgeAt (m t : Nat) : Prop :=
  ∀ (c : Nat → Bool) (s z : Int → Bool), s (-(m : Int)) = true →
    (∀ p, p < -(m : Int) → s p = false) →
    (∀ p, p < 0 → stepLine z p = L c s t p) →
    z (edgePosition m t + 1) = true ∧ ∀ p, p < edgePosition m t + 1 → z p = false

/-- Age 8 is the least uniform age for initial depth at least 2. -/
theorem least_age_nonadjacent (a : Nat) :
    (∀ m, 2 ≤ m → ∀ t, a ≤ t → EdgeAt m t) ↔ 8 ≤ a := by
  constructor
  · intro h
    by_cases ha : 8 ≤ a
    · exact ha
    · obtain ⟨c, s, z, hs, hw, _, hz, hb⟩ := sharp_examples false
      obtain ⟨p, hp, hblack⟩ := hb (edgePosition 2 7 + 1)
      have hwhite := (h 2 (by decide) 7 (by omega) c s z hs hw hz).2 p hp
      rw [hblack] at hwhite
      contradiction
  · intro ha m hm t ht c s z hs hw hz
    exact predecessor_edge c s z (by omega) hw hs
      (by unfold threshold; rw [ite_eq_right (by omega)]; omega) hz

/-- Age 9 is the least uniform age for a single black cell next to the wall. -/
theorem least_age_adjacent (a : Nat) :
    (∀ t, a ≤ t → EdgeAt 1 t) ↔ 9 ≤ a := by
  constructor
  · intro h
    by_cases ha : 9 ≤ a
    · exact ha
    · obtain ⟨c, s, z, hs, hw, _, hz, hb⟩ := sharp_examples true
      obtain ⟨p, hp, hblack⟩ := hb (edgePosition 1 8 + 1)
      have hwhite := (h 8 (by omega) c s z hs hw hz).2 p hp
      rw [hblack] at hwhite
      contradiction
  · intro ha t ht c s z hs hw hz
    exact predecessor_edge c s z (by decide) hw hs (by change 9 ≤ t; omega) hz

end Ruliology.CellularAutomata.Rule30DrivenLeftInverse
