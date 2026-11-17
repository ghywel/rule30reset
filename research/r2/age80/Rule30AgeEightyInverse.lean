module

public import Ruliology.CellularAutomata.Rule30AgeTwentyFourInverse
public import Ruliology.CellularAutomata.Rule30Prize

/-!
# Four inverse ticks at a fixed white wall

Starting at age 80, every four-tick preimage of a nonzero finite orbit has its true
edge four cells inside the image edge. The 54 transitions below start at the kit's
age-26 cycle. A word denotes an outer prefix, with its least significant bit
facing the wall. Shortening a prefix forgets interior cells and enlarges the cover.
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30AgeEightyInverse

open Rule30ZeroBoundary Rule30ZeroBoundary.IntegerForm Rule30LateTwins
open Rule30AgeTwentyFourInverse

set_option maxHeartbeats 0
set_option maxRecDepth 8192

private def prefixOf (p u : Nat) : Bool :=
  u >>> (u.log2 - p.log2) == p

private def covered (ps : List Nat) (u : Nat) : Bool := ps.any (prefixOf · u)

private def rowCovered (ps : List Nat) (Y : Nat) : Prop :=
  ∃ q p, 1 ≤ q ∧ p ∈ ps ∧ Y >>> q = p

private theorem extend_cover {ps : List Nat} {Y u q : Nat}
    (hq : 1 ≤ q) (hu : Y >>> q = u) (hc : covered ps u = true) : rowCovered ps Y := by
  obtain ⟨p, hp, h⟩ := List.any_eq_true.mp hc
  refine ⟨q + (u.log2 - p.log2), p, by omega, hp, ?_⟩
  rw [Nat.shiftRight_add, hu]
  exact beq_iff_eq.mp h

private def links (ps ns : List Nat) : Bool :=
  ps.all fun p => covered ns (R (2*p)) && covered ns (R (2*p+1))

private theorem move_cover {ps ns : List Nat} {Y : Nat}
    (h : links ps ns = true) (hy : rowCovered ps Y) : rowCovered ns (F Y) := by
  obtain ⟨q, p, hq, hp, cut⟩ := hy
  obtain ⟨k, rfl⟩ : ∃ k, q = k+1 := ⟨q-1, by omega⟩
  have hc := Bool.and_eq_true_iff.mp (List.all_eq_true.mp h p hp)
  have hd : (Y >>> k) / 2 = p := by
    rw [Nat.shiftRight_add, Nat.shiftRight_eq_div_pow (Y >>> k) 1] at cut
    exact cut
  have alt : Y >>> k = 2*p ∨ Y >>> k = 2*p+1 := by omega
  apply extend_cover (Y := F Y) (q := k+1) (u := R (Y >>> k)) (by omega) (F_shiftRight Y k)
  rcases alt with h0 | h1
  · simpa only [h0] using hc.1
  · simpa only [h1] using hc.2

private def walk (ps : List Nat) : List (List Nat) → Bool
  | [] => true
  | ns :: rest => links ps ns && walk ns rest

private theorem walk_sound (ps : List Nat) (rest : List (List Nat)) (Y : Nat)
    (h : walk ps rest = true) (hy : rowCovered ps Y) :
    rowCovered (rest.getLastD ps) (iter F rest.length Y) := by
  induction rest generalizing ps Y with
  | nil => exact hy
  | cons ns rest ih =>
    obtain ⟨h1,h2⟩ := Bool.and_eq_true_iff.mp h
    have hh := ih ns (F Y) h2 (move_cover h1 hy)
    rw [List.length_cons, show rest.length + 1 = 1 + rest.length by omega, iter_add]
    cases rest <;> exact hh

private def firstBands : List Nat := [12, 28519, 911005]

/-- Outer prefixes for ages 27 through 80, in chronological order. -/
private def stages : List (List Nat) := [
  [0xd, 0xc85c, 0x191cf1],
  [0xc, 0xde69, 0x37b38b],
  [0xd, 0xc8e7, 0x642e5a],
  [0xc, 0x1bd9c, 0xde69d2, 0xde69d3],
  [0xd, 0x190b9, 0x191cf1e, 0x191cf1f],
  [0x19, 0x379a7, 0x37b38b0, 0x37b38b1],
  [0x37, 0x6473c, 0x642e5a8, 0x642e5a9, 0x642e5ab],
  [0x64, 0x6f671, 0xde69d2a, 0xde69d2c, 0xde69d2d, 0xde69d2f],
  [0x6f, 0x642e5, 0x191cf1e8, 0x191cf1e9, 0x191cf1ea, 0x191cf1eb],
  [0xc8, 0xde69d, 0x1bd9c587, 0x37b38b0a, 0x37b38b0b, 0x37b38b0c, 0x37b38b0d],
  [0x1bc, 0x1bd, 0x191cf1, 0x32172d4c, 0x642e5a9a, 0x642e5a9b],
  [0x191, 0x321, 0x1bd9c5, 0x379a74bd, 0xde69d2f2, 0xde69d2f3],
  [0x1bd, 0x379, 0x32172d, 0x3239e3d0, 0x191cf1e8e, 0x191cf1e8f],
  [0x321, 0x647, 0x6f34e9, 0x37b38b0c, 0x37b38b0d8, 0x37b38b0d9],
  [0x379, 0xdec, 0x6473c7, 0x32172d4d, 0x642e5a994, 0x642e5a995, 0x642e5a997],
  [0x647, 0xc85, 0xdece2c, 0x379a74bc, 0xde69d2f74, 0xde69d2f75, 0xde69d2f76, 0xde69d2f77],
  [0xdec, 0x1bcd, 0xc85cb5, 0x3239e3d1, 0x191cf1e844, 0x191cf1e845, 0x191cf1e846, 0x191cf1e847],
  [0xc85, 0x3239, 0x1bcd3a5, 0x37b38b0d, 0x37b38b0cec, 0x37b38b0ced, 0x37b38b0cee, 0x37b38b0cef],
  [0x1bcd, 0x6f67, 0x3239e3d, 0x32172d4c, 0x32172d4dc5, 0x642e5a9b88, 0x642e5a9b89],
  [0x3239, 0xc85c, 0x6f67161, 0x379a74bd, 0x6f34e9792d, 0xde69d2f25c, 0xde69d2f25d, 0xde69d2f25f],
  [0x6f67, 0xde69, 0x642e5a9, 0x3239e3d0, 0xc8e78f47e9, 0x191cf1e8fd0, 0x191cf1e8fd1],
  [0xc85c, 0xc8e7, 0xde69d2f, 0x37b38b0c, 0xdece2c3607, 0x1bd9c586c0d, 0x37b38b0d818, 0x37b38b0d819],
  [0xde69, 0x1bd9c, 0x191cf1e8, 0x32172d4d, 0x190b96a650c, 0x642e5a99434, 0x642e5a99435, 0x642e5a99437],
  [0xc8e7, 0x190b9, 0x1bd9c586, 0x379a74bc, 0x1bcd3a5eecd, 0xde69d2f7664, 0xde69d2f7665, 0xde69d2f7666, 0xde69d2f7667],
  [0x1bd9c, 0x379a7, 0x32172d4c, 0x32172d4d, 0x3239e3d1, 0x3239e3d08b9, 0x191cf1e845dc, 0x191cf1e845dd, 0x191cf1e845de, 0x191cf1e845df],
  [0x190b9, 0x6473c, 0x379a74bd, 0x37b38b0d, 0x6f34e979, 0x6f671619da7, 0x1bd9c5867689, 0x37b38b0ced10, 0x37b38b0ced11],
  [0x379a7, 0x6f671, 0x32172d4c, 0x3239e3d0, 0xc8e78f47, 0xc85cb53713c, 0x32172d4dc4df, 0x642e5a9b89b8, 0x642e5a9b89b9, 0x642e5a9b89bb],
  [0x642e5, 0x6473c, 0x379a74bd, 0x37b38b0c, 0x1bd9c586c, 0xde69d2f25f1, 0x6f34e9792f90, 0xde69d2f25f22, 0xde69d2f25f24, 0xde69d2f25f25, 0xde69d2f25f27],
  [0x6f671, 0xde69d, 0x32172d4d, 0x3239e3d0, 0x190b96a65, 0xc8e78f47e85, 0x6473c7a3f43c, 0xc8e78f47e87f, 0x191cf1e8fd0f6, 0x191cf1e8fd0f7, 0x191cf1e8fd0fc, 0x191cf1e8fd0fd],
  [0x642e5, 0x191cf1, 0x379a74bc, 0x37b38b0c, 0x379a74bdd, 0x1bd9c586c0cd, 0xdece2c360662, 0xdece2c360663, 0x1bd9c586c0cc0, 0x37b38b0d81982, 0x37b38b0d81983, 0x37b38b0d81984, 0x37b38b0d81985],
  [0xde69d, 0x1bd9c5, 0x32172d4d, 0x3239e3d1, 0x6473c7a11, 0x32172d4ca1b9, 0x190b96a650dd0, 0x190b96a650dd6, 0x190b96a650dd7, 0x32172d4ca1ba7, 0x642e5a9943746, 0x642e5a9943747, 0x642e5a994374d],
  [0x191cf1, 0x32172d, 0x379a74bc, 0x37b38b0d, 0x6f671619d, 0x6f34e97bb327, 0x379a74bdd9914, 0x379a74bdd9915, 0x379a74bdd9918, 0x379a74bdd9919, 0x6f34e97bb323c, 0xde69d2f76646c, 0xde69d2f76646d],
  [0x1bd9c5, 0x6f34e9, 0x32172d4c, 0x3239e3d1, 0xc85cb5371, 0xc8e78f422efc, 0x6473c7a1177b1, 0x6473c7a1177b4, 0x6473c7a1177b5, 0x6473c7a1177b6, 0x6473c7a1177b7, 0x191cf1e845dec9, 0x191cf1e845deca, 0x191cf1e845decb],
  [0x32172d, 0x6473c7, 0x379a74bd, 0x37b38b0d, 0xde69d2f25, 0xdece2c33b441, 0x6f671619da215, 0xdece2c33b4424, 0xdece2c33b4425, 0xdece2c33b4426, 0xdece2c33b4427, 0x1bd9c58676885f, 0x37b38b0ced10ba, 0x37b38b0ced10bb],
  [0x6f34e9, 0xdece2c, 0x32172d4c, 0x3239e3d0, 0x191cf1e8fd, 0xc85cb5371371, 0xc85cb53713735, 0x190b96a6e26e7c, 0x190b96a6e26e7d, 0x190b96a6e26e7e, 0x190b96a6e26e7f, 0x32172d4dc4dcd0, 0x642e5a9b89b9a2, 0x642e5a9b89b9a3],
  [0x6473c7, 0xc85cb5, 0x379a74bd, 0x37b38b0c, 0x1bd9c586c0, 0xde69d2f25f25, 0x1bcd3a5e4be4e5, 0x379a74bc97c9c0, 0x379a74bc97c9c1, 0x379a74bc97c9c2, 0x379a74bc97c9c3, 0x379a74bc97c9cc, 0xde69d2f25f2736, 0xde69d2f25f2737],
  [0xdece2c, 0x1bcd3a5, 0x32172d4d, 0x3239e3d0, 0x190b96a650, 0x191cf1e8fd0fd, 0x3239e3d1fa1f90, 0x3239e3d1fa1f9d, 0x6473c7a3f43f23, 0x6473c7a3f43f26, 0x6473c7a3f43f27, 0x191cf1e8fd0fce4, 0x191cf1e8fd0fce5],
  [0xc85cb5, 0x3239e3d, 0x379a74bc, 0x37b38b0c, 0x1bcd3a5eec, 0x37b38b0d81981, 0x37b38b0d81983c, 0x6f67161b033071, 0xdece2c360660f6, 0xdece2c360660fc, 0xdece2c360660fd, 0x1bd9c586c0cc1cf, 0x37b38b0d819839d],
  [0x1bcd3a5, 0x6f67161, 0x32172d4d, 0x3239e3d1, 0x191cf1e845, 0x642e5a9943743, 0x32172d4ca1ba31, 0x642e5a99437465, 0xc85cb53286e8c0, 0x190b96a650dd182, 0x190b96a650dd183, 0x190b96a650dd184, 0x190b96a650dd185, 0x32172d4ca1ba338],
  [0x3239e3d, 0x642e5a9, 0x37b38b0d, 0x6f34e979, 0x37b38b0ced, 0xde69d2f766466, 0x379a74bdd991b5, 0xde69d2f76646d0, 0xde69d2f76646dd, 0x1bcd3a5eecc8da7, 0x379a74bdd991b46, 0x379a74bdd991b47, 0x379a74bdd991b4d, 0x6f34e97bb3236e4, 0x6f34e97bb3236e5],
  [0x6f67161, 0xde69d2f, 0x32172d4c, 0xc8e78f47, 0x642e5a9b89, 0x191cf1e845dedc, 0x191cf1e845dedd, 0x6473c7a1177b25, 0xc8e78f422ef64c, 0x191cf1e845dec91, 0x3239e3d08bbd93c, 0x6473c7a1177b24f, 0x6473c7a1177b26c, 0x6473c7a1177b26d, 0xc8e78f422ef649d],
  [0x642e5a9, 0x191cf1e8, 0x379a74bd, 0x1bd9c586c, 0xde69d2f25f, 0x1bd9c586768849, 0x37b38b0ced1091, 0xdece2c33b442fd, 0x1bd9c58676885fd, 0x37b38b0ced10bf1, 0x6f671619da217e5, 0xdece2c33b442fc9, 0xdece2c33b442ff8],
  [0xde69d2f, 0x1bd9c586, 0x3239e3d0, 0x190b96a65, 0x191cf1e8fd0, 0x190b96a6e26e7f, 0x32172d4dc4dcfd, 0x190b96a6e26e681, 0x32172d4dc4dcd01, 0x32172d4dc4dcd05, 0xc85cb537137341d, 0x190b96a6e26e6804, 0x190b96a6e26e6805, 0x190b96a6e26e683f],
  [0x191cf1e8, 0x32172d4c, 0x32172d4d, 0x37b38b0c, 0x379a74bdd, 0x1bd9c586c0c, 0x379a74bc97c9c0, 0x1bcd3a5e4be4e61, 0x379a74bc97c9cc1, 0x6f34e9792f9398d, 0x1bcd3a5e4be4e607, 0x1bcd3a5e4be4e631, 0x379a74bc97c9cc0d, 0x379a74bc97c9cc60],
  [0x1bd9c586, 0x32172d4d, 0x379a74bd, 0x6f34e979, 0x6473c7a11, 0x190b96a650d, 0x3239e3d1fa1f90, 0x191cf1e8fd0fce9, 0x3239e3d1fa1f9d1, 0x6473c7a3f43f3ac, 0x191cf1e8fd0fceb5, 0x3239e3d1fa1f9d0c, 0x3239e3d1fa1f9d68],
  [0x32172d4c, 0x32172d4d, 0x3239e3d0, 0x379a74bc, 0xc8e78f47, 0x6f671619d, 0x1bcd3a5eecc, 0x37b38b0d81983c, 0x1bd9c586c0cc1c7, 0x37b38b0d819838d, 0x6f67161b0330715, 0x37b38b0d819838a5, 0x37b38b0d819838cd, 0x6f67161b0330714c, 0x6f67161b0330714d],
  [0x3239e3d1, 0x379a74bd, 0x37b38b0c, 0x6f34e979, 0x1bd9c586c, 0xc85cb5371, 0x191cf1e845d, 0x32172d4ca1ba31, 0x32172d4ca1ba32c, 0xc85cb53286e8cb5, 0x642e5a99437465b9, 0x642e5a99437465bd, 0xc85cb53286e8cb79],
  [0x32172d4d, 0x3239e3d0, 0x37b38b0d, 0xc8e78f47, 0x190b96a65, 0xde69d2f25, 0x37b38b0ced1, 0x379a74bdd991b5, 0x379a74bdd991b75, 0x1bcd3a5eecc8dba5, 0x6f34e97bb3236e90, 0xde69d2f76646dd27, 0x1bcd3a5eecc8dba47],
  [0x32172d4c, 0x379a74bc, 0x37b38b0c, 0x1bd9c586c, 0x379a74bdd, 0x191cf1e8fd, 0x32172d4dc4d, 0x6473c7a1177b25, 0x6473c7a1177b245, 0x3239e3d08bbd923d, 0x6473c7a1177b247c, 0x191cf1e845dec91fc, 0x3239e3d08bbd923ec],
  [0x32172d4d, 0x3239e3d1, 0x379a74bd, 0x190b96a65, 0x6473c7a11, 0x37b38b0d81, 0x379a74bc97c, 0xdece2c33b442fd, 0xdece2c33b442fed, 0x6f671619da217f61, 0x1bd9c58676885fd81, 0x37b38b0ced10bfb05],
  [0x379a74bc, 0x37b38b0d, 0x6473c7a1, 0x379a74bdd, 0x6f671619d, 0x32172d4ca1, 0x3239e3d1fa1, 0x190b96a6e26e681, 0x190b96a6e26e6809, 0x642e5a9b89b9a029, 0x190b96a6e26e680a1, 0x642e5a9b89b9a028d],
  [0x3239e3d1, 0x642e5a99, 0x6f671619, 0x6473c7a11, 0xc85cb5371, 0x379a74bdd9, 0x37b38b0d819, 0x1bcd3a5e4be4e61, 0x1bcd3a5e4be4e60f, 0xde69d2f25f27306f, 0x1bcd3a5e4be4e60d9, 0xde69d2f25f27306d9],
  [0x642e5a9b, 0x6f34e97b, 0x6f67161b, 0xdece2c33b, 0x1bcd3a5e4b, 0x3239e3d08b, 0x32172d4ca1b, 0x3239e3d1fa1f9d3, 0x3239e3d1fa1f9d18, 0x191cf1e8fd0fce8c8, 0x191cf1e8fd0fce8cb, 0xc8e78f47e87e7464b],
  [0xc85cb532, 0xc8e78f42, 0xde69d2f2, 0x190b96a6e2, 0x3239e3d1fa, 0x6f671619da, 0x6f34e97bb32, 0x6f67161b033071e, 0x37b38b0d819838da, 0x1bd9c586c0cc1c6de, 0x37b38b0d819838dba, 0x1bd9c586c0cc1c6dfa]]

private def lastBands : List Nat := stages.getLastD firstBands

private theorem cover_certificate : walk firstBands stages = true := by decide +kernel

private theorem aged_cover (Y t : Nat) (hY : Y ≠ 0) (ht : 80 ≤ t) :
    rowCovered lastBands (iter F t Y) := by
  let a := t - 54
  let q := Y.log2 + a - 19
  let Z := iter F a Y
  have ha : 26 ≤ a := by dsimp [a]; omega
  have hq : 1 ≤ q := by dsimp [q]; omega
  have base := band_from_age_twenty_six hY ha
  change inC20 (Z >>> q) = true at base
  have small : covered firstBands (Z >>> q) = true := by
    simp only [inC20, Bool.or_eq_true, beq_iff_eq] at base
    rcases base with ((h | h) | h) | h <;> rw [h] <;> decide +kernel
  have hh := walk_sound firstBands stages Z cover_certificate (extend_cover hq rfl small)
  change rowCovered lastBands (iter F 54 Z) at hh
  rwa [show t = a + 54 by dsimp [a]; omega, iter_add]

/-- The even bit of each pair holds the current cell; the odd bit holds its neighbour
one site closer to the wall. The current cell feeds the next inverse layer. -/
private def advance (b : Bool) (s : Nat) : Nat :=
  ((s &&& 85) <<< 1) ||| ((((s <<< 2) ||| b.toNat) ^^^ (s ||| (s >>> 1))) &&& 85)

private def scan : Nat → Nat → Nat → Nat
  | 0, _, s => s
  | n+1, u, s => scan n (u >>> 1) (advance (u.testBit 0) s)

private def closes (p : Nat) : Bool :=
  chk (fun s => scan (p.log2+1) p s == 0) 0 8

private theorem reset_certificate : lastBands.all closes = true := by decide +kernel

private def pack (a b c d e f g h : Bool) : Nat :=
  a.toNat*2 + b.toNat + c.toNat*8 + d.toNat*4 +
  e.toNat*32 + f.toNat*16 + g.toNat*128 + h.toNat*64

private theorem pack_lt (a b c d e f g h : Bool) : pack a b c d e f g h < 256 := by
  revert a b c d e f g h
  decide +kernel

private theorem advance_pack (x a b c d e f g h : Bool) :
    advance x (pack a b c d e f g h) =
      pack b (xor x (b || a)) d (xor b (d || c))
           f (xor d (f || e)) h (xor f (h || g)) := by
  revert x a b c d e f g h
  decide +kernel

private def register (L : Nat → Bool) (i : Nat) : Nat :=
  pack (zrow L 3 i) (zrow L 3 (i+1)) (zrow L 2 i) (zrow L 2 (i+1))
       (zrow L 1 i) (zrow L 1 (i+1)) (zrow L 0 i) (zrow L 0 (i+1))

private theorem register_step (L : Nat → Bool) (i : Nat) :
    advance (zrow L 4 (i+1)) (register L i) = register L (i+1) := by
  unfold register
  rw [advance_pack, zrow_inv L 3 i, zrow_inv L 2 i, zrow_inv L 1 i, zrow_inv L 0 i]

private theorem scan_row (L : Nat → Bool) (Z : Nat)
    (hz : ∀ k, 1 ≤ k → zrow L 4 k = rowOfNat Z k) (q n : Nat) :
    scan n (Z >>> q) (register L q) = register L (q+n) := by
  induction n generalizing q with
  | zero => rfl
  | succ n ih =>
    simp only [scan, ← Nat.shiftRight_add, Nat.testBit_shiftRight, Nat.add_zero]
    rw [show Z.testBit q = zrow L 4 (q+1) from (hz (q+1) (by omega)).symm,
      register_step, ih]
    congr 1 <;> omega

private theorem oldest_white (a b c d e f g h : Bool)
    (hz : pack a b c d e f g h = 0) : g = false := by
  revert a b c d e f g h
  decide +kernel

private theorem finite_of_cover {L : Nat → Bool} {Z : Nat}
    (hc : rowCovered lastBands Z)
    (hz : ∀ k, 1 ≤ k → zrow L 4 k = rowOfNat Z k) : FinSupp L := by
  obtain ⟨q, p, hq, hp, cut⟩ := hc
  let n := p.log2+1
  have h := chk_sound _ 8 0 (List.all_eq_true.mp reset_certificate p hp)
    (register L q) (pack_lt ..)
  have zero : register L (q+n) = 0 := by
    rw [← scan_row L Z hz, cut]
    simpa only [Nat.zero_add] using (beq_iff_eq.mp h)
  have outside : Z >>> (q+n) = 0 := by
    rw [Nat.shiftRight_add, cut, Nat.shiftRight_eq_div_pow]
    exact Nat.div_eq_of_lt (Nat.lt_log2_self)
  have tail (d : Nat) : register L ((q+n)+d) = 0 := by
    rw [← scan_row L Z hz, outside, zero]
    induction d with
    | zero => rfl
    | succ d ih => exact ih
  refine ⟨q+n, fun k hk => ?_⟩
  obtain ⟨d,rfl⟩ : ∃ d, k = (q+n)+d := ⟨k-(q+n), by omega⟩
  rw [← zrow_zero_of_pos L (by omega)]
  exact oldest_white _ _ _ _ _ _ _ _ (tail d)

/-- Every four-tick predecessor, initially allowed infinite support, agrees at all
positive depths with a finite row whose high bit is exactly four sites inside the
ending edge. The fixed wall discards the initial value at depth zero. -/
theorem aged_four_step_predecessor (Y t : Nat) (hY : Y ≠ 0) (ht : 80 ≤ t)
    (L : Nat → Bool) (hL : ∀ k, 1 ≤ k → zrow L 4 k = rowOfNat (iter F t Y) k) :
    ∃ A : Nat, (∀ k, 1 ≤ k → rowOfNat A k = L k) ∧
      iter F 4 A = iter F t Y ∧ Top A (Y.log2 + t - 4) := by
  obtain ⟨W, hW⟩ := finite_of_cover (aged_cover Y t hY ht) hL
  let A := natOfRow L W
  have ha : ∀ k, 1 ≤ k → rowOfNat A k = L k := rowOfNat_natOfRow hW
  have him : iter F 4 A = iter F t Y := by
    apply rowOfNat_ext
    intro k
    rw [← zrow_rowOfNat, zrow_congr ha, hL _ (by omega)]
  have hedge := Top_iter (top_log2 hY) t
  have hn : A ≠ 0 := by
    intro h
    rw [← him, h] at hedge
    have hz : iter F 4 0 = 0 := by decide
    simp [hz, Top] at hedge
  have htop := Top_iter (top_log2 hn) 4
  rw [him] at htop
  have he := Top_unique htop hedge
  exact ⟨A, ha, him, by rw [show Y.log2 + t - 4 = A.log2 by omega]; exact top_log2 hn⟩

private theorem forward_back (b : Bool) (y : Nat → Bool) (hy : y 0 = false) :
    zrow (back b y) 1 = y := by
  funext k
  cases k with
  | zero => exact (zrow_wall _ _).trans hy.symm
  | succ k => exact zrow_back _ _ _ (by omega)

private theorem next_time (L y : Nat → Bool) (n : Nat) (h : zrow L n = y) :
    zrow L (n+1) = zrow y 1 := by
  funext k
  rw [zrow_shift, h]

/-- Each of the sixteen assignments of the wall-adjacent cells at times 0,1,2,3
is attained by a finite four-tick predecessor of the stated exact width. -/
theorem all_four_tick_histories (Y t : Nat) (hY : Y ≠ 0) (ht : 80 ≤ t)
    (b₀ b₁ b₂ b₃ : Bool) :
    ∃ A : Nat, iter F 4 A = iter F t Y ∧ Top A (Y.log2 + t - 4) ∧
      rowOfNat A 1 = b₀ ∧ rowOfNat (iter F 1 A) 1 = b₁ ∧
      rowOfNat (iter F 2 A) 1 = b₂ ∧ rowOfNat (iter F 3 A) 1 = b₃ := by
  let E := rowOfNat (iter F t Y)
  let X₃ := back b₃ E
  let X₂ := back b₂ X₃
  let X₁ := back b₁ X₂
  let L := back b₀ X₁
  have s₁ : zrow L 1 = X₁ := forward_back _ _ rfl
  have s₂ : zrow L 2 = X₂ := (next_time _ _ 1 s₁).trans (forward_back _ _ rfl)
  have s₃ : zrow L 3 = X₃ := (next_time _ _ 2 s₂).trans (forward_back _ _ rfl)
  have s₄ : zrow L 4 = E := (next_time _ _ 3 s₃).trans (forward_back _ _ rfl)
  obtain ⟨A, ha, him, hedge⟩ := aged_four_step_predecessor Y t hY ht L
    (fun k _ => congrFun s₄ k)
  have clock (i : Nat) : rowOfNat (iter F i A) 1 = zrow L i 1 :=
    (zrow_rowOfNat A i 1).symm.trans (zrow_congr ha i 1)
  exact ⟨A, him, hedge, ha 1 (by decide), (clock 1).trans (congrFun s₁ 1),
    (clock 2).trans (congrFun s₂ 1), (clock 3).trans (congrFun s₃ 1)⟩

end Ruliology.CellularAutomata.Rule30AgeEightyInverse
