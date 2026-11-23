/-! Prototype: the ordered ring Z[sqrt 5] in core Lean, ordered by multiplying by the unit 9 + 4 sqrt 5. -/
structure Q5 where
  a : Int
  b : Int
  deriving DecidableEq, Repr

namespace Q5
theorem ext' {x y : Q5} (h : x.a = y.a) (k : x.b = y.b) : x = y := by cases x; cases y; simp_all

instance : Add Q5 := ⟨fun x y => ⟨x.a + y.a, x.b + y.b⟩⟩
instance : Neg Q5 := ⟨fun x => ⟨-x.a, -x.b⟩⟩
instance : Sub Q5 := ⟨fun x y => ⟨x.a - y.a, x.b - y.b⟩⟩
instance : Mul Q5 := ⟨fun x y => ⟨x.a * y.a + 5 * (x.b * y.b), x.a * y.b + x.b * y.a⟩⟩
instance : NatCast Q5 := ⟨fun n => ⟨n, 0⟩⟩
instance : IntCast Q5 := ⟨fun n => ⟨n, 0⟩⟩
instance (n : Nat) : OfNat Q5 n := ⟨⟨n, 0⟩⟩
instance : SMul Nat Q5 := ⟨fun n x => (n : Q5) * x⟩
instance : SMul Int Q5 := ⟨fun n x => (n : Q5) * x⟩
def npow (x : Q5) : Nat → Q5 | 0 => 1 | n + 1 => npow x n * x
instance : HPow Q5 Nat Q5 := ⟨npow⟩

@[simp] theorem add_a (x y : Q5) : (x + y).a = x.a + y.a := rfl
@[simp] theorem add_b (x y : Q5) : (x + y).b = x.b + y.b := rfl
@[simp] theorem neg_a (x : Q5) : (-x).a = -x.a := rfl
@[simp] theorem neg_b (x : Q5) : (-x).b = -x.b := rfl
@[simp] theorem sub_a (x y : Q5) : (x - y).a = x.a - y.a := rfl
@[simp] theorem sub_b (x y : Q5) : (x - y).b = x.b - y.b := rfl
@[simp] theorem mul_a (x y : Q5) : (x * y).a = x.a * y.a + 5 * (x.b * y.b) := rfl
@[simp] theorem mul_b (x y : Q5) : (x * y).b = x.a * y.b + x.b * y.a := rfl
@[simp] theorem ofNat_a (n : Nat) : (OfNat.ofNat n : Q5).a = n := rfl
@[simp] theorem ofNat_b (n : Nat) : (OfNat.ofNat n : Q5).b = 0 := rfl
@[simp] theorem zero_a : (0 : Q5).a = 0 := rfl
@[simp] theorem zero_b : (0 : Q5).b = 0 := rfl
@[simp] theorem one_a : (1 : Q5).a = 1 := rfl
@[simp] theorem one_b : (1 : Q5).b = 0 := rfl
@[simp] theorem million_a : (1000000 : Q5).a = 1000000 := rfl
@[simp] theorem million_b : (1000000 : Q5).b = 0 := rfl
@[simp] theorem natCast_a (n : Nat) : ((n : Q5)).a = n := rfl
@[simp] theorem natCast_b (n : Nat) : ((n : Q5)).b = 0 := rfl
@[simp] theorem intCast_a (n : Int) : ((n : Q5)).a = n := rfl
@[simp] theorem intCast_b (n : Int) : ((n : Q5)).b = 0 := rfl

instance : Lean.Grind.CommRing Q5 where
  add_zero x := ext' (by simp) (by simp)
  add_comm x y := ext' (by simp; omega) (by simp; omega)
  add_assoc x y z := ext' (by simp; omega) (by simp; omega)
  mul_assoc x y z := ext' (by simp; grind) (by simp; grind)
  mul_one x := ext' (by simp) (by simp)
  one_mul x := ext' (by simp) (by simp)
  left_distrib x y z := ext' (by simp; grind) (by simp; grind)
  right_distrib x y z := ext' (by simp; grind) (by simp; grind)
  zero_mul x := ext' (by simp) (by simp)
  mul_zero x := ext' (by simp) (by simp)
  pow_zero _ := rfl
  pow_succ _ _ := rfl
  ofNat_succ n := ext' (by show ((n + 1 : Nat) : Int) = (n : Int) + 1; omega) (by show (0 : Int) = 0 + 0; rfl)
  neg_add_cancel x := ext' (by simp; omega) (by simp; omega)
  sub_eq_add_neg x y := ext' (by simp; omega) (by simp; omega)
  neg_zsmul i x := ext' (by show (((-i : Int) : Q5) * x).a = (-((i : Q5) * x)).a; simp; grind)
                        (by show (((-i : Int) : Q5) * x).b = (-((i : Q5) * x)).b; simp; grind)
  intCast_neg i := ext' (by simp) (by simp)
  mul_comm x y := ext' (by simp; grind) (by simp; grind)

/-- Multiplication by the unit 9 + 4 sqrt 5. -/
def up (z : Q5) : Q5 := ⟨9 * z.a + 20 * z.b, 4 * z.a + 9 * z.b⟩
def it : Nat → Q5 → Q5 | 0, z => z | k + 1, z => up (it k z)
/-- Both coefficients are nonnegative after enough multiplications by the unit. -/
def nn (z : Q5) : Prop := ∃ k, 0 ≤ (it k z).a ∧ 0 ≤ (it k z).b

theorem it_up : ∀ (k : Nat) (z : Q5), it k (up z) = up (it k z)
  | 0, _ => rfl
  | k + 1, z => congrArg up (it_up k z)
theorem it_it (j k : Nat) (z : Q5) : it j (it k z) = it (j + k) z := by
  induction j with
  | zero => simp [it]
  | succ j ih => rw [show j + 1 + k = (j + k) + 1 by omega]; simp only [it, ih]
theorem keep {z : Q5} (h : 0 ≤ z.a ∧ 0 ≤ z.b) : ∀ j, 0 ≤ (it j z).a ∧ 0 ≤ (it j z).b
  | 0 => h
  | j + 1 => by have := keep h j; simp only [it, up]; omega
theorem it_add (k : Nat) (x y : Q5) : it k (x + y) = it k x + it k y := by
  induction k with
  | zero => rfl
  | succ k ih => simp only [it, ih]; exact ext' (by simp [up]; omega) (by simp [up]; omega)
theorem it_neg (k : Nat) (x : Q5) : it k (-x) = -it k x := by
  induction k with
  | zero => rfl
  | succ k ih => simp only [it, ih]; exact ext' (by simp [up]; omega) (by simp [up]; omega)
theorem it_mul_left (k : Nat) (x y : Q5) : it k x * y = it k (x * y) := by
  induction k with
  | zero => rfl
  | succ k ih => simp only [it, ← ih]; exact ext' (by simp [up]; grind) (by simp [up]; grind)
theorem it_mul (j k : Nat) (x y : Q5) : it j x * it k y = it (j + k) (x * y) := by
  rw [it_mul_left, Lean.Grind.CommSemiring.mul_comm x, it_mul_left, it_it, Lean.Grind.CommSemiring.mul_comm y]

theorem nn_add {x y : Q5} : nn x → nn y → nn (x + y) := by
  rintro ⟨j, hj⟩ ⟨k, hk⟩
  refine ⟨j + k, ?_⟩
  have h1 := keep hj k; have h2 := keep hk j
  rw [it_it] at h1 h2; rw [it_add, show j + k = k + j by omega]
  rw [show j + k = k + j by omega] at h2; simp; omega
theorem nn_mul {x y : Q5} : nn x → nn y → nn (x * y) := by
  rintro ⟨j, hj⟩ ⟨k, hk⟩
  refine ⟨j + k, ?_⟩
  rw [← it_mul]; simp
  have h1 := Int.mul_nonneg hj.1 hk.1; have h2 := Int.mul_nonneg hj.2 hk.2
  have h3 := Int.mul_nonneg hj.1 hk.2; have h4 := Int.mul_nonneg hj.2 hk.1
  omega
theorem nn_total : ∀ (n : Nat) (z : Q5), z.a.natAbs ≤ n → nn z ∨ nn (-z)
  | n, z, hn => by
    by_cases h1 : 0 ≤ z.a ∧ 0 ≤ z.b
    · exact Or.inl ⟨0, h1⟩
    by_cases h2 : z.a ≤ 0 ∧ z.b ≤ 0
    · exact Or.inr ⟨0, by simp [it]; omega⟩
    have back : nn (up z) ∨ nn (-up z) → nn z ∨ nn (-z) := by
      rintro (⟨k, h⟩ | ⟨k, h⟩)
      · exact Or.inl ⟨k + 1, by rw [it_up] at h; exact h⟩
      · exact Or.inr ⟨k + 1, by rw [it_neg, it_up] at h; rw [it_neg]; exact h⟩
    apply back
    cases n with
    | zero => omega
    | succ n =>
      by_cases h3 : 0 ≤ (up z).a ∧ 0 ≤ (up z).b
      · exact Or.inl ⟨0, h3⟩
      by_cases h4 : (up z).a ≤ 0 ∧ (up z).b ≤ 0
      · exact Or.inr ⟨0, by simp [it]; omega⟩
      exact nn_total n (up z) (by simp only [up] at *; omega)
theorem nn_antisymm {z : Q5} : nn z → nn (-z) → z = 0 := by
  rintro ⟨j, hj⟩ ⟨k, hk⟩
  have h1 := keep hj k; have h2 := keep hk j
  rw [it_it] at h1 h2; rw [it_neg, show j + k = k + j by omega] at h2
  simp at h2
  have hz : ∀ m, (it m z).a = 0 → (it m z).b = 0 → z.a = 0 ∧ z.b = 0 := by
    intro m; induction m with
    | zero => exact fun p q => ⟨p, q⟩
    | succ m ih => intro p q; simp only [it, up] at p q; exact ih (by omega) (by omega)
  obtain ⟨p, q⟩ := hz (k + j) (by omega) (by omega)
  exact ext' (by simpa using p) (by simpa using q)
theorem nn_pos_mul {x y : Q5} (hx : nn x) (hy : nn y) (nx : x ≠ 0) (ny : y ≠ 0) : x * y ≠ 0 := by
  have strict : ∀ {z : Q5}, nn z → z ≠ 0 → ∃ k, 0 < (it k z).a ∧ 0 < (it k z).b := by
    rintro z ⟨k, h⟩ hz
    by_cases hp : 0 < (it k z).a ∨ 0 < (it k z).b
    · exact ⟨k + 1, by simp only [it, up]; omega⟩
    · exact absurd (nn_antisymm ⟨k, h⟩ ⟨k, by rw [it_neg]; simp; omega⟩) hz
  obtain ⟨j, hj⟩ := strict hx nx; obtain ⟨k, hk⟩ := strict hy ny
  intro e
  have h := it_mul j k x y
  rw [e] at h
  have zero_it : ∀ m, it m 0 = (0 : Q5) := by
    intro m; induction m with
    | zero => rfl
    | succ m ih => simp only [it, ih]; rfl
  rw [zero_it] at h
  have ha := congrArg Q5.a h
  simp at ha
  have := Int.mul_pos hj.1 hk.1; have := Int.mul_pos hj.2 hk.2
  omega

instance : LE Q5 := ⟨fun x y => nn (y - x)⟩
instance : LT Q5 := ⟨fun x y => x ≤ y ∧ ¬ y ≤ x⟩
theorem le_def {x y : Q5} : x ≤ y ↔ nn (y - x) := Iff.rfl
theorem swap (x y : Q5) : x - y = -(y - x) := ext' (by simp; omega) (by simp; omega)

instance : Std.IsLinearOrder Q5 where
  le_refl x := ⟨0, by simp [it]⟩
  le_trans x y z h k := by
    have := nn_add h k
    rw [show y - x + (z - y) = z - x from ext' (by simp; omega) (by simp; omega)] at this; exact this
  le_antisymm x y h k := by
    rw [le_def, swap] at k
    have e := nn_antisymm h k
    exact ext' (by have := congrArg Q5.a e; simp at this; omega) (by have := congrArg Q5.b e; simp at this; omega)
  le_total x y := by
    rcases nn_total _ (y - x) (Nat.le_refl _) with h | h
    · exact Or.inl h
    · exact Or.inr (by rw [le_def, swap]; exact h)
instance : Std.LawfulOrderLT Q5 where lt_iff _ _ := Iff.rfl

theorem pos_sub {x y : Q5} (h : x < y) : nn (y - x) ∧ y - x ≠ 0 := by
  refine ⟨h.1, fun e => h.2 ?_⟩
  rw [le_def, swap, e]; exact ⟨0, by simp [it]⟩
theorem mul_lt {x y c : Q5} (h : x < y) (hc : 0 < c) : c * x < c * y := by
  obtain ⟨p, q⟩ := pos_sub h
  obtain ⟨r, t⟩ := pos_sub hc
  rw [show c - 0 = c from ext' (by simp) (by simp)] at r t
  have e : c * y - c * x = c * (y - x) := ext' (by simp; grind) (by simp; grind)
  refine ⟨by rw [le_def, e]; exact nn_mul r p, fun k => ?_⟩
  rw [le_def, swap, e] at k
  exact nn_pos_mul r p t q (nn_antisymm (nn_mul r p) k)

instance : Lean.Grind.OrderedRing Q5 where
  add_le_left_iff {x y} c := by
    rw [le_def, le_def, show y + c - (x + c) = y - x from ext' (by simp; omega) (by simp; omega)]
  zero_lt_one := ⟨⟨0, by decide⟩, fun h => by
    have := nn_antisymm (z := (1 : Q5)) ⟨0, by decide⟩ h
    exact absurd this (by decide)⟩
  mul_lt_mul_of_pos_left := mul_lt
  mul_lt_mul_of_pos_right {a b c} h hc := by
    rw [Lean.Grind.CommSemiring.mul_comm a c, Lean.Grind.CommSemiring.mul_comm b c]; exact mul_lt h hc

/-- sqrt 5, its square and the rational enclosure S11's table uses. -/
def r5 : Q5 := ⟨0, 1⟩
theorem r5_sq : r5 * r5 = 5 := by decide
theorem r5_lo : (2236067 : Q5) ≤ 1000000 * r5 := ⟨6, by decide⟩
theorem r5_hi : 1000000 * r5 ≤ (2236069 : Q5) := ⟨6, by decide⟩

/-- S11's `below_sound`: an affine integer form nonnegative at both ends of the enclosure is nonnegative at sqrt 5. -/
theorem below_sound (x y : Int) (h1 : 0 ≤ 1000000 * x + 2236067 * y) (h2 : 0 ≤ 1000000 * x + 2236069 * y) :
    (0 : Q5) ≤ ⟨x, y⟩ := by
  have key : ∀ (m e : Int) (z w : Q5), 0 ≤ m → nn w → (1000000 : Q5) * z = (e : Q5) + (m : Q5) * w → 0 ≤ e → nn z := by
    intro m e z w hm hw hz he
    rcases nn_total _ z (Nat.le_refl _) with h | h
    · exact h
    · have hp : nn ((e : Q5) + (m : Q5) * w) :=
        nn_add ⟨0, by simp [it]; omega⟩ (nn_mul ⟨0, by simp [it]; omega⟩ hw)
      rw [← hz] at hp
      have hq : nn ((1000000 : Q5) * -z) := nn_mul ⟨0, by decide⟩ h
      have e0 := nn_antisymm hp (by rw [show -(1000000 * z) = (1000000 : Q5) * -z from ext' (by simp; grind) (by simp; grind)]; exact hq)
      have ha := congrArg Q5.a e0; have hb := congrArg Q5.b e0
      simp at ha hb
      rw [show z = 0 from ext' (by simp; omega) (by simp; omega)]; exact ⟨0, by decide⟩
  show nn (⟨x, y⟩ - 0)
  rw [show (⟨x, y⟩ - 0 : Q5) = ⟨x, y⟩ from ext' (by simp) (by simp)]
  by_cases hy : 0 ≤ y
  · exact key y (1000000 * x + 2236067 * y) _ ⟨-2236067, 1000000⟩ hy ⟨6, by decide⟩
      (ext' (by simp; omega) (by simp; omega)) h1
  · exact key (-y) (1000000 * x + 2236069 * y) _ ⟨2236069, -1000000⟩ (by omega) ⟨6, by decide⟩
      (ext' (by simp; omega) (by simp; omega)) h2

/-! What the port needs the tactics to do. -/
example (x y : Q5) : (x + y) * (x - y) = x * x - y * y := by grind
example (s t u : Q5) (h : s < t) (k : t ≤ u + 1) : s < u + 2 := by grind
example (s v e w : Q5) (h1 : e ≤ s + v) (h2 : s < w) (h3 : w + v ≤ 5) : e < 5 := by grind
/-- S11's margin lemma, `scaled_bound`, with its constants. -/
example (h Q Y B E hE hB : Q5) (e1 : hE = h * E) (e2 : hB = h * B) (hh : 1000000 * h ≤ 1) (hq : 1 ≤ Q)
    (hb : -h ≤ hB) (he : hE ≤ h) (hx : 11 * Q ≤ 10 * Y) : 10999 * (Q + hE) ≤ 10000 * (Y + hB) := by grind
end Q5
#print axioms Q5.mul_lt
