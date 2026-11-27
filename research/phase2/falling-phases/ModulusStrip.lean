import Ruliology.CellularAutomata.Rule30StripCertificates

/-! A strip with both exterior cells free and one permitted fall phase per site. -/
namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata Rule30StripCertificates

def fallMask (s d : Nat) : Nat := s &&& (s ^^^ d)

def fits (a s d : Nat) : Bool := (fallMask s d &&& a) == fallMask s d

def permit (w : Nat) (a : Nat → Nat) (p : Nat) : Nat :=
  (List.range w).foldl (fun m j => if a j = p then m ||| (1 <<< j) else m) 0

theorem permit_bit (w : Nat) (a : Nat → Nat) (p j : Nat) :
    (permit w a p).testBit j = decide (j < w ∧ a j = p) := by
  classical
  have go (is : List Nat) (b : Nat) :
      ((is.foldl (fun m k => if a k = p then m ||| (1 <<< k) else m) b).testBit j) =
        (b.testBit j || decide (j ∈ is ∧ a j = p)) := by
    induction is generalizing b with
    | nil => simp
    | cons k ks ih =>
      simp only [List.foldl_cons, ih]
      by_cases h : a k = p
      · by_cases e : k = j
        · subst k
          simp [h, Nat.testBit_or, Nat.testBit_shiftLeft]
        · have shift : (1 <<< k).testBit j = false := by
            rw [Nat.testBit_shiftLeft]
            by_cases hh : k ≤ j
            · have pow : 2 ≤ 2^(j-k) := Nat.pow_le_pow_right (by decide : 0 < 2) (by omega : 1 ≤ j-k)
              simp [hh, Nat.testBit_lt_two_pow (show 1 < 2^(j-k) by omega)]
            · simp [hh]
          simp [h, Ne.symm e, Nat.testBit_or, shift]
      · by_cases e : k = j
        · subst k
          simp [h]
        · simp [h, Ne.symm e]
  simpa [permit] using go (List.range w) 0

theorem fits_iff (a s d : Nat) :
    fits a s d = true ↔
      ∀ j, s.testBit j = true → d.testBit j = false → a.testBit j = true := by
  rw [fits, beq_iff_eq]
  constructor
  · intro h j on off
    have hb := congrArg (fun z : Nat => z.testBit j) h
    simp [fallMask, Nat.testBit_and, Nat.testBit_xor, on, off] at hb
    exact hb
  · intro h
    apply Nat.eq_of_testBit_eq
    intro j
    by_cases on : s.testBit j = true <;> by_cases off : d.testBit j = false <;>
      simp_all [fallMask, Nat.testBit_and, Nat.testBit_xor]

def successors (w s : Nat) : List Nat :=
  [stripStep w false false s, stripStep w false true s,
    stripStep w true false s, stripStep w true true s]

theorem mem_successors {w s d : Nat} :
    d ∈ successors w s ↔ ∃ l r : Bool, d = stripStep w l r s := by
  constructor
  · simp only [successors, List.mem_cons, List.not_mem_nil, or_false]
    rintro (h | h | h | h)
    · exact ⟨false,false,h⟩
    · exact ⟨false,true,h⟩
    · exact ⟨true,false,h⟩
    · exact ⟨true,true,h⟩
  · rintro ⟨l,r,rfl⟩
    cases l <;> cases r <;> simp [successors]

def Edge (w a s d : Nat) : Prop := d ∈ successors w s ∧ fits a s d = true

structure Run (w m : Nat) (a x : Nat → Nat) : Prop where
  bounded : ∀ t, x t < 2 ^ w
  edge : ∀ t, Edge w (permit w a (t % m)) (x t) (x (t+1))

/-- Some fixed adjacent pair repeats every full round of the calendar. -/
def Pair (w m : Nat) (x : Nat → Nat) : Prop :=
  ∃ j N, j + 1 < w ∧ ∀ t, N ≤ t →
    (x (t + m) >>> j) % 4 = (x t >>> j) % 4

def Good (w m : Nat) (a : Nat → Nat) : Prop :=
  ∀ x, Run w m a x → Pair w m x

private def quietTriple (s : Nat) : Bool :=
  (successors 6 s).all fun d =>
    if fits 0 s d && s != d then
      (successors 6 d).all fun e =>
        !(fits 0 d e) || (successors 6 e).all fun f => !(fits 0 e f)
    else true

private theorem quietTriple_ok : (List.range 64).all quietTriple = true := by decide +kernel

/-- Among three consecutive quiet updates of a six-site strip, the first is idle.
The exterior bits at all three ticks are unrestricted. -/
theorem quiet_eq {s d e f : Nat} (hs : s < 64)
    (h₀ : Edge 6 0 s d) (h₁ : Edge 6 0 d e) (h₂ : Edge 6 0 e f) : d = s := by
  apply Classical.byContradiction
  intro hne
  have a := List.all_eq_true.mp (List.all_eq_true.mp quietTriple_ok _ (List.mem_range.mpr hs)) d h₀.1
  have b := List.all_eq_true.mp (by simpa [h₀.2, Ne.symm hne] using a :
    (successors 6 d).all (fun e => !(fits 0 d e) || (successors 6 e).all fun f => !(fits 0 e f)) = true) e h₁.1
  simp only [h₁.2, Bool.not_true, Bool.false_or] at b
  have c := List.all_eq_true.mp b f h₂.1
  simp [h₂.2] at c

def rotate (m q r : Nat) : Nat := if q ≤ r then r-q else r+(m-q)

theorem rotate_lt {m q r : Nat} (hq : q < m) (hr : r < m) : rotate m q r < m := by
  unfold rotate
  split <;> omega

theorem rotate_add_iff {m q r u : Nat} (hq : q < m) (hr : r < m) (hu : u < m) :
    (u+q)%m = r ↔ u = rotate m q r := by
  have hm : u+q < 2*m := by omega
  by_cases b : u+q < m
  · rw [Nat.mod_eq_of_lt b]
    unfold rotate
    split <;> omega
  · rw [Nat.mod_eq_sub_mod (by omega : m ≤ u+q), Nat.mod_eq_of_lt (by omega : u+q-m < m)]
    unfold rotate
    split <;> omega

theorem good_of_rotated {w m q : Nat} {a : Nat → Nat} (hq : q < m)
    (ha : ∀ j, j < w → a j < m)
    (good : Good w m (fun j => rotate m q (a j))) : Good w m a := by
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
  obtain ⟨j,N,hj,per⟩ := good y hy
  refine ⟨j,N+q,hj,fun t ht => ?_⟩
  simpa only [y, show t-q+m+q=t+m by omega, show t-q+q=t by omega] using
    per (t-q) (by omega)

theorem good_of_dvd {w d m : Nat} {a : Nat → Nat} (h : d ∣ m)
    (good : Good w d (fun j => a j % d)) : Good w m a := by
  intro x hx
  have hsmall : Run w d (fun j => a j % d) x := by
    refine ⟨hx.bounded, fun t => ?_⟩
    refine ⟨(hx.edge t).1, (fits_iff _ _ _).mpr ?_⟩
    intro j on off
    have he := (fits_iff _ _ _).mp (hx.edge t).2 j on off
    rw [permit_bit, decide_eq_true_eq] at he ⊢
    exact ⟨he.1, by rw [he.2, Nat.mod_mod_of_dvd _ h]⟩
  obtain ⟨j,N,hj,per⟩ := good x hsmall
  obtain ⟨k, rfl⟩ := h
  refine ⟨j,N,hj,fun t ht => ?_⟩
  clear hx
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Nat.mul_succ, ← Nat.add_assoc, per (t+d*k) (by omega)]
    exact ih

end PhaseFalls.Moduli
