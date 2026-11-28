import Ruliology.CellularAutomata.Rule30SeedLeftSide

namespace PhaseTwo.SeedSettling

open Ruliology.CellularAutomata Rule30Diagonals Rule30FourLeftSides Rule30SeedLeftSide
open Rule30UniversalLeftSide (rowAt Ld_ofRow rowAt_add_mul)
open Rule30FiniteDiagonals (Ld)
open Rule30Realization (evol_seed)
open Rule30FourFrontsBase (F)
open Rule30FourFronts (wdA0)

private def advance (K x n : Nat) := bandRun K (n.log2+1) n x

private theorem advance_eq (K x n : Nat) : advance K x n = rowAt K x n :=
  bandRun_eq _ _ _ _ Nat.lt_log2_self

/-- Each pair advances by a number of ticks and certifies an exclusive prefix width.
The deadline uses the first previously uncovered wheel. -/
private def checks (K lo t x : Nat) : List (Nat × Nat) → Bool
  | [] => K ≤ lo
  | (dt, m) :: rest =>
    let y := advance K x dt
    decide (lo < m ∧ m ≤ K ∧ 5*(t+dt) ≤ 7*lo+30) &&
      (advance K y 16 % 2^m == y % 2^m) && checks K m (t+dt) y rest

private theorem sound {K : Nat} (cuts : List (Nat × Nat)) (lo t : Nat)
    (h : checks K lo t (rowAt K 1 t) cuts = true) :
    ∀ j, lo ≤ j → j < K → ∀ u, (7*j+30)/5 ≤ u →
      ∀ i, i ≤ j → (rowAt K 1 (u+16)).testBit i = (rowAt K 1 u).testBit i := by
  induction cuts generalizing lo t with
  | nil =>
    simp [checks] at h
    omega
  | cons cut rest ih =>
    rcases cut with ⟨dt, m⟩
    simp only [checks, Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq,
      advance_eq, ← rowAt_add'] at h
    rcases h with ⟨⟨⟨_, hm, deadline⟩, eq⟩, tail⟩
    intro j hj hK u hu i hi
    by_cases past : m ≤ j
    · exact ih m (t+dt) tail j past hK u hu i hi
    · have bits (b : Nat) (hb : b < m) :
          (rowAt K 1 (t+dt+16)).testBit b = (rowAt K 1 (t+dt)).testBit b := by
        have e := congrArg (fun v : Nat => v.testBit b) eq
        simpa [Nat.testBit_mod_two_pow, hb] using e
      have tick : t+dt ≤ u := by omega
      have e := rowAt_low hm hm bits (u-(t+dt)) i (by omega)
      rw [← rowAt_add', ← rowAt_add'] at e
      simpa only [show t+dt+16+(u-(t+dt))=u+16 by omega,
        show t+dt+(u-(t+dt))=u by omega] using e

private def cuts : List (Nat × Nat) :=
  [ (6, 11), (14, 20), (14, 32), (16, 40), (11, 46), (3, 48), (9, 51), (3, 54),
    (2, 56), (6, 59), (3, 63), (7, 67), (5, 72), (5, 77), (7, 81), (6, 85),
    (8, 87), (2, 93), (7, 101), (13, 107), (8, 112), (7, 117), (7, 128), (16, 148),
    (28, 174), (35, 194), (29, 212), (23, 244), (46, 273), (42, 300), (35, 339), (56, 376),
    (53, 432), (77, 487), (78, 550), (89, 621), (98, 683), (88, 760), (108, 834), (100, 923),
    (128, 1024), (139, 1109), (119, 1200), (129, 1296), (135, 1393), (133, 1490), (138, 1596), (149, 1721),
    (170, 1838), (167, 1966), (181, 2102), (189, 2241), (195, 2404), (228, 2589), (258, 2770), (256, 2971),
    (280, 3177), (287, 3391), (301, 3593), (281, 3816), (315, 4046), (321, 4293), (344, 4558), (374, 4818),
    (364, 5085), (373, 5366), (394, 5672), (422, 5989), (449, 6297), (429, 6613), (446, 6938), (454, 7284),
    (484, 7665), (535, 8029), (507, 8404), (527, 8820), (583, 9272), (632, 9770), (698, 10312), (758, 10844),
    (744, 11393), (770, 11988), (831, 12585), (837, 13194), (850, 13818), (877, 14463), (903, 15102), (894, 15784),
    (954, 16502), (1003, 17273), (1083, 18039), (1072, 18837), (1114, 19661), (1157, 20525), (1206, 21464), (1317, 22412),
    (1328, 23428), (1420, 24484), (1479, 25547), (1489, 26617), (1497, 27778), (1627, 28948), (1639, 30273), (1855, 31606),
    (1866, 32991), (1938, 34540), (2170, 36173), (2286, 37897), (2412, 39735), (2573, 41611), (2627, 43555), (2723, 45608),
    (2874, 47759), (3011, 50034), (3181, 52410), (3329, 54899), (3486, 57515), (3663, 60278), (3867, 63156), (4030, 66257),
    (4340, 69331), (4305, 72535), (4486, 75947), (4774, 79614), (5136, 83553), (5515, 87592), (344, 87867) ]

set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
private theorem certificate : checks 87867 0 0 1 cuts = true := by decide +kernel

/-- Every wheel of the physical prefix through j is permanently 16-periodic by
tick floor(7j/5)+6, for the entire known 16-period band. -/
theorem seed_prefix_settled {j u i : Nat} (hj : j ≤ 87866) (hi : i ≤ j)
    (hu : (7*j+30)/5 ≤ u) : D i (u+16) = D i u := by
  rw [D_eq_Sp_one (j := i) (by omega), D_eq_Sp_one (j := i) (by omega)]
  exact sound cuts 0 0 certificate j (by omega) (by omega) u hu i hi

/-- The settled phase is the kit's A0 at the physical tick. -/
theorem seed_prefix_on_A0 {j u i : Nat} (hj : j ≤ 87866) (hi : i ≤ j)
    (hu : (7*j+30)/5 ≤ u) : D i u = Sp A0 i u := by
  have per (q : Nat) : D i (u+q*16) = D i u := by
    induction q with
    | zero => simp
    | succ q ih =>
      rw [Nat.succ_mul, ← Nat.add_assoc, seed_prefix_settled hj hi (by omega), ih]
  let q := F wdA0 i
  have eq := (seed_eq_A0_from_F (j := i) (by omega) (t := u+q*16) (by dsimp [q]; omega) 0).1
  rwa [per, Sp_add_mul A0_return] at eq



private theorem seed_bit {K j : Nat} (hK : 1 < K) (hj : j < K) (t : Nat) :
    D j t = (rowAt K 1 t).testBit j := by
  rw [← Ld_ofRow hK 1 t j hj, Ld, ofRow_one, evol_seed]
  unfold D
  congr 1
  omega

private theorem mismatch {K i t : Nat} (hK : 1 < K) (hi : i < K)
    (h : (advance K 1 t).testBit i ≠ (advance K (advance K 1 t) 16).testBit i) :
    D i t ≠ D i (t+16) := by
  simpa only [seed_bit hK hi, rowAt_add' K 1 t 16, advance_eq] using h

/-- Six extra ticks in the uniform bound are necessary at wheel 85. -/
theorem sharp_allowance : D 85 124 ≠ D 85 140 :=
  mismatch (K := 86) (by decide) (by decide) (by decide +kernel)

set_option maxHeartbeats 0 in
/-- The endpoint prefix still disagrees one tick before its first return. -/
theorem endpoint_before : D 87865 117323 ≠ D 87865 117339 :=
  mismatch (K := 87867) (by decide) (by decide) (by decide +kernel)

private def boundary := advance 87868 1 117324

set_option maxHeartbeats 0 in
private theorem boundary_return : rowAt 87868 boundary 32 = boundary := by
  rw [← advance_eq]
  decide +kernel

set_option maxHeartbeats 0 in
private theorem boundary_low : rowAt 87867 (rowAt 87867 1 117324) 16 =
    rowAt 87867 1 117324 := by
  simp only [← advance_eq]
  decide +kernel

/-- The entire 16-clock prefix repeats forever starting at exactly tick 117324
(the lower witness is endpoint_before). -/
theorem endpoint_after {i u : Nat} (hi : i ≤ 87866) (hu : 117324 ≤ u) :
    D i (u+16) = D i u := by
  obtain ⟨k,rfl⟩ : ∃ k, u=117324+k := ⟨u-117324, by omega⟩
  rw [seed_bit (K := 87867) (by decide) (by omega), seed_bit (K := 87867) (by decide) (by omega),
    Nat.add_assoc, rowAt_add' 87867 1 117324, rowAt_add' 87867 1 117324,
    Rule30UniversalLeftSide.rowAt_add_period boundary_low]

set_option maxHeartbeats 0 in
private theorem boundary_phases : ∀ r : Fin 32,
    (advance 87868 boundary (r.val+16)).testBit 87867 ≠
      (advance 87868 boundary r.val).testBit 87867 := by decide +kernel

/-- Just across the boundary the new wheel flips every 16 ticks, from the
same starting time as the settled 16-clock prefix. -/
theorem next_wheel_flips {u : Nat} (hu : 117324 ≤ u) : D 87867 (u+16) ≠ D 87867 u := by
  obtain ⟨k,rfl⟩ : ∃ k, u=117324+k := ⟨u-117324, by omega⟩
  have at_phase (n : Nat) : rowAt 87868 1 (117324+n) = rowAt 87868 boundary n := by
    rw [rowAt_add', boundary, advance_eq]
  have h := boundary_phases ⟨k%32, by omega⟩
  simp only [advance_eq] at h
  have reduce (n r : Nat) (e : n=r+(k/32)*32) :
      rowAt 87868 boundary n = rowAt 87868 boundary r := by
    rw [e, rowAt_add_mul boundary_return]
  rw [seed_bit (K := 87868) (by decide) (by decide), seed_bit (K := 87868) (by decide) (by decide),
    Nat.add_assoc, at_phase, at_phase, reduce (k+16) (k%32+16) (by omega),
    reduce k (k%32) (by omega)]
  exact h

end PhaseTwo.SeedSettling
