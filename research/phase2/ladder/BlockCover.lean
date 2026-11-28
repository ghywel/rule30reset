import Ruliology.CellularAutomata.Rule30LateTwins

namespace PhaseTwo.BlockCover
open Ruliology.CellularAutomata Rule30ZeroBoundary IntegerForm Rule30LateTwins

/-- With the exterior word fixed, the whole output after H ticks has a
cover of size M as the B new interior bits range freely. -/
def OneBlock (B H M : Nat) : Prop :=
  ∀ u, ∃ C : List Nat, C.length ≤ M ∧
    ∀ x : Nat, x >>> B = u → iterR H x ∈ C

private theorem flat_length {f : Nat → List Nat} {M : Nat}
    (bound : ∀ u, (f u).length ≤ M) (L : List Nat) :
    (L.flatMap f).length ≤ L.length * M := by
  induction L with
  | nil => simp
  | cons a L ih =>
    simp only [List.flatMap_cons, List.length_append, List.length_cons, Nat.succ_mul]
    have := bound a
    omega

/-- One block per H ticks. The same list covers all initial words of
length at most B*m, including words whose outermost bit is zero. -/
theorem iterated_cover {B H M : Nat} (one : OneBlock B H M) (m : Nat) :
    ∃ C : List Nat, C.length ≤ M^m ∧
      ∀ x : Nat, x < 2^(B*m) → iterR (H*m) x ∈ C := by
  classical
  let E u := Classical.choose (one u)
  have size (u : Nat) : (E u).length ≤ M := (Classical.choose_spec (one u)).1
  have covers (u x : Nat) (h : x >>> B = u) : iterR H x ∈ E u :=
    (Classical.choose_spec (one u)).2 x h
  induction m with
  | zero =>
    refine ⟨[0], by simp, fun x hx => ?_⟩
    simp at hx
    simp [hx, iterR]
  | succ m ih =>
    obtain ⟨C, hC, hits⟩ := ih
    refine ⟨C.flatMap E, ?_, fun x hx => ?_⟩
    · rw [Nat.pow_succ]
      exact Nat.le_trans (flat_length size C) (Nat.mul_le_mul_right M hC)
    · have upper : x >>> B < 2^(B*m) := by
        rw [Nat.shiftRight_eq_div_pow, Nat.div_lt_iff_lt_mul (Nat.two_pow_pos _)]
        simpa [Nat.mul_succ, Nat.pow_add] using hx
      apply List.mem_flatMap.mpr
      refine ⟨iterR (H*m) (x >>> B), hits _ upper, ?_⟩
      rw [Nat.mul_succ, iterR_add]
      exact covers _ _ (iterR_shiftRight (H*m) x B)

/-- The leading packed word, most significant bit at the black outer edge. -/
def leading (k y : Nat) : Nat := y >>> (y.log2 + 1 - k)

private theorem width_at {y : Nat} (nz : y ≠ 0) (t : Nat) :
    (iter F t y).log2 = y.log2 + t := by
  have ht := Top_iter (top_log2 nz) t
  have nonzero : iter F t y ≠ 0 := by
    intro e
    have bad := ht.1
    simp [e] at bad
  exact Top_unique (top_log2 nonzero) ht

/-- At physical age at least (B+H)*m, a single list of size at most
M^m covers the leading B*m cells of every nonzero seed. -/
theorem physical_cover {B H M : Nat} (one : OneBlock B H M) (m : Nat) :
    ∃ C : List Nat, C.length ≤ M^m ∧ ∀ y t : Nat, y ≠ 0 → (B+H)*m ≤ t →
      leading (B*m) (iter F t y) ∈ C := by
  obtain ⟨C, size, cover⟩ := iterated_cover one m
  refine ⟨C, size, fun y t nz aged => ?_⟩
  rw [Nat.add_mul] at aged
  let a := t-H*m
  let cut := y.log2+a+1-B*m
  have eq : t = a+H*m := by dsimp [a]; omega
  have top : (iter F a y).log2 = y.log2 + a := width_at nz a
  have fit : y.log2 + a + 1 = B*m + cut := by dsimp [a,cut]; omega
  have short : (iter F a y) >>> cut < 2^(B*m) := by
    rw [Nat.shiftRight_eq_div_pow, Nat.div_lt_iff_lt_mul (Nat.two_pow_pos _), ← Nat.pow_add, ← fit, ← top]
    exact Nat.lt_log2_self
  have shift : y.log2 + t + 1 - B*m = cut + H*m := by omega
  unfold leading
  rw [width_at nz, shift, eq, iter_add, iter_F_shiftRight]
  exact cover _ short

end PhaseTwo.BlockCover
