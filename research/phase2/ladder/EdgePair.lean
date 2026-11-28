import Ruliology.CellularAutomata.Rule30LateTwins

namespace PhaseTwo.EdgePair
open Ruliology.CellularAutomata.Rule30LateTwins

/-- Outer band and its next two inward bits, nearest the band first. -/
abbrev Pair := Bool × Bool

def advance (u : Nat) (s : Pair) : Pair :=
  (xor (u.testBit 1) ((u.testBit 0) || s.1), xor (u.testBit 0) (s.1 || s.2))

def pairIter : Nat → Nat → Pair → Pair
  | 0, _, s => s
  | n+1, u, s => pairIter n (R u) (advance u s)

theorem pairIter_add (p q u : Nat) (s : Pair) :
    pairIter (p+q) u s = pairIter q (iterR p u) (pairIter p u s) := by
  induction p generalizing u s with
  | zero => simp [pairIter,iterR]
  | succ p ih =>
    rw [show p+1+q = (p+q)+1 by omega, pairIter, ih, iterR, pairIter]

def Small (t u : Nat) : Prop :=
  ∃ a b : Pair, ∀ s, pairIter t u s = a ∨ pairIter t u s = b

theorem later {t u : Nat} (h : Small t u) (q : Nat) : Small (t+q) u := by
  obtain ⟨a,b,H⟩ := h
  refine ⟨pairIter q (iterR t u) a, pairIter q (iterR t u) b, fun s => ?_⟩
  rw [pairIter_add]
  cases H s with
  | inl e => exact Or.inl (by rw [e])
  | inr e => exact Or.inr (by rw [e])

theorem start_later (p : Nat) {q u : Nat} (h : Small q (iterR p u)) : Small (p+q) u := by
  obtain ⟨a,b,H⟩ := h
  exact ⟨a,b,fun s => by rw [pairIter_add]; apply H⟩

theorem reset_one {u : Nat} (h : u.testBit 0 = true) : Small 1 u := by
  refine ⟨(!(u.testBit 1),false), (!(u.testBit 1),true), ?_⟩
  rintro ⟨b,c⟩
  cases b <;> cases c <;> cases hu : u.testBit 1 <;> simp [pairIter, advance, h, hu]

theorem reset_two {u : Nat} (h₀ : u.testBit 0 = false) (h₁ : u.testBit 1 = true) :
    Small 2 u := by
  refine ⟨pairIter 2 u (false,false), pairIter 2 u (true,false), ?_⟩
  rintro ⟨b,c⟩
  cases b <;> cases c <;> simp [pairIter, advance,h₀,h₁]

theorem zero_pre {u k : Nat} (h₀ : u.testBit 0 = false) (h₁ : u.testBit 1 = false)
    (h : ∀ i < k, (R u).testBit i = false) :
    ∀ i < k+2, u.testBit i = false := by
  intro i
  induction i using Nat.strongRecOn with
  | ind i ih =>
    intro hi
    match i with
    | 0 => exact h₀
    | 1 => exact h₁
    | i+2 =>
      have H := h i (by omega)
      have A := ih i (by omega) (by omega)
      have B := ih (i+1) (by omega) (by omega)
      simpa [R,Nat.testBit_shiftRight,Nat.testBit_xor,Nat.testBit_or,
        show 2+i=i+2 by omega,show 1+i=i+1 by omega,A,B] using H

theorem no_low_pair {h u : Nat}
    (H : ∀ t < h, (iterR t u).testBit 0 = false ∧ (iterR t u).testBit 1 = false) :
    ∀ i < 2*h, u.testBit i = false := by
  induction h generalizing u with
  | zero => intro _ hi; omega
  | succ h ih =>
    obtain ⟨A,B⟩ := H 0 (by omega)
    have z := ih (u := R u) (fun t ht => H (t+1) (by omega))
    exact fun i hi => zero_pre A B z i (by omega)

theorem two_extensions {d u : Nat} (top : u.testBit d = true) :
    Small (d/2+2) u := by
  let h := d/2+1
  have hit : ∃ t < h, (iterR t u).testBit 0 = true ∨ (iterR t u).testBit 1 = true := by
    apply Classical.byContradiction
    intro hn
    have z (t : Nat) (ht : t < h) : (iterR t u).testBit 0 = false ∧ (iterR t u).testBit 1 = false := by
      cases a : (iterR t u).testBit 0 <;> cases b : (iterR t u).testBit 1 <;> simp_all
      all_goals exact False.elim (hn ⟨t,ht,by simp_all⟩)
    have := no_low_pair z d (by dsimp [h]; omega)
    simp_all
  obtain ⟨t, ht, hits⟩ := hit
  have le : t+2 ≤ d/2+2 := by dsimp [h] at ht; omega
  suffices k : Small (t+2) u by
    have := later k (d/2+2-(t+2))
    rwa [show t+2+(d/2+2-(t+2))=d/2+2 by omega] at this
  apply start_later
  by_cases bit : (iterR t u).testBit 0 = true
  · exact later (reset_one bit) 1
  · have zero : (iterR t u).testBit 0 = false := by cases b : (iterR t u).testBit 0 <;> simp_all
    exact reset_two zero (hits.resolve_left bit)

def readPair (x : Nat) : Pair := (x.testBit 1, x.testBit 0)

def pack (u : Nat) (s : Pair) : Nat := 4*u + 2*s.1.toNat + s.2.toNat

theorem repack (x : Nat) : pack (x >>> 2) (readPair x) = x := by
  unfold pack readPair
  simp only [Nat.testBit_eq_decide_div_mod_eq,Nat.shiftRight_eq_div_pow,Nat.pow_one,
    Nat.pow_zero,Nat.div_one,Nat.reducePow]
  by_cases a : x/2%2=1 <;> by_cases b : x%2=1 <;> simp [a,b] <;> omega

theorem advance_read (x : Nat) : readPair (R x) = advance (x >>> 2) (readPair x) := by
  simp only [readPair,R,advance,Nat.testBit_shiftRight,Nat.testBit_xor,Nat.testBit_or]

theorem iter_read (t x : Nat) :
    readPair (iterR t x) = pairIter t (x >>> 2) (readPair x) := by
  induction t generalizing x with
  | zero => rfl
  | succ t ih => rw [iterR, ih, R_shiftRight, advance_read]; rfl

theorem packed_two_extensions {d u : Nat} (top : u.testBit d = true) :
    ∃ a b : Nat, ∀ x, x >>> 2 = u → iterR (d/2+2) x = a ∨ iterR (d/2+2) x = b := by
  let t := d/2+2
  obtain ⟨a,b,h⟩ := two_extensions top
  refine ⟨pack (iterR t u) a, pack (iterR t u) b, fun x hx => ?_⟩
  have eq := repack (iterR t x)
  rw [iterR_shiftRight, iter_read, hx] at eq
  rcases h (readPair x) with ha | hb
  · exact Or.inl (by rw [ha] at eq; exact eq.symm)
  · exact Or.inr (by rw [hb] at eq; exact eq.symm)

theorem top_R {x d : Nat} (h : Top x d) : Top (R x) d := by
  have top := h.1
  have beyond := h.2
  constructor
  · simp [R,Nat.testBit_shiftRight,Nat.testBit_xor,Nat.testBit_or,top,beyond _ (show d<2+d by omega),
      beyond _ (show d<1+d by omega)]
  · intro i hi
    simp [R,Nat.testBit_shiftRight,Nat.testBit_xor,Nat.testBit_or,beyond i hi,
      beyond _ (show d<1+i by omega),beyond _ (show d<2+i by omega)]

theorem top_iterR {x d : Nat} (h : Top x d) (t : Nat) : Top (iterR t x) d := by
  induction t generalizing x with
  | zero => exact h
  | succ t ih => exact ih (top_R h)

def age : Nat → Nat
  | 0 => 0
  | m+1 => age m + (m+2)

/-- After quadratic time, an odd-length outer band needs at most one bit per inward pair. -/
theorem outer_cover (m : Nat) :
    ∃ A : List Nat, A.length ≤ 2^m ∧ ∀ x, Top x (2*m) → iterR (age m) x ∈ A := by
  classical
  induction m with
  | zero =>
    refine ⟨[1], by decide, fun x hx => ?_⟩
    have eq : x = 1 := by
      apply Nat.eq_of_testBit_eq
      intro i
      cases i with
      | zero => exact hx.1
      | succ i => exact (hx.2 _ (by omega)).trans (((top_log2 (by decide : 1 ≠ 0)).2 _ (by simp)).symm)
    simp [age,iterR,eq]
  | succ m ih =>
    obtain ⟨A, hlen, hmem⟩ := ih
    have ex (u : Nat) : ∃ a b : Nat, ∀ y, Top u (2*m) → y >>> 2 = u →
        iterR (m+2) y = a ∨ iterR (m+2) y = b := by
      by_cases top : Top u (2*m)
      · obtain ⟨a,b,h⟩ := packed_two_extensions top.1
        exact ⟨a,b,fun y _ hy => by simpa using h y hy⟩
      · exact ⟨0,0,fun _ h _ => False.elim (top h)⟩
    let a (u : Nat) := (ex u).choose
    let b (u : Nat) := (ex u).choose_spec.choose
    have hab (u : Nat) := (ex u).choose_spec.choose_spec
    refine ⟨A.map a ++ A.map b, by simp only [List.length_append,List.length_map]; rw [Nat.pow_succ]; omega, ?_⟩
    intro x hx
    have upper : Top (x >>> 2) (2*m) := by
      constructor
      · simpa [Nat.testBit_shiftRight,show 2+2*m=2*(m+1) by omega] using hx.1
      · intro i hi
        rw [Nat.testBit_shiftRight]
        exact hx.2 _ (by omega)
    let y := iterR (age m) x
    let u := iterR (age m) (x >>> 2)
    have cut : y >>> 2 = u := iterR_shiftRight _ _ _
    have mem : u ∈ A := hmem _ upper
    have cases := hab u y (top_iterR upper _) cut
    rw [age,iterR_add]
    rcases cases with ha | hb
    · rw [ha]; exact List.mem_append_left _ (List.mem_map.mpr ⟨_,mem,rfl⟩)
    · rw [hb]; exact List.mem_append_right _ (List.mem_map.mpr ⟨_,mem,rfl⟩)


theorem age_closed (m : Nat) : 2 * age m = m * (m + 3) := by
  induction m with
  | zero => rfl
  | succ m ih =>
    simp only [age, Nat.mul_add, Nat.add_mul, Nat.mul_one, Nat.one_mul] at *
    omega

open Ruliology.CellularAutomata.Rule30ZeroBoundary.IntegerForm

/-- A common outer-band cover for *every* late physical image of every nonzero seed. -/
theorem late_outer_cover (m : Nat) :
    ∃ A : List Nat, A.length ≤ 2^m ∧ ∀ y, y ≠ 0 → ∀ t, 2*m + age m ≤ t →
      (iter F t y >>> (y.log2 + t - 2*m)) ∈ A := by
  obtain ⟨A, size, covers⟩ := outer_cover m
  refine ⟨A,size,fun y hy t ht => ?_⟩
  let s := t - age m
  let c := y.log2 + s - 2*m
  have hsplit : s + age m = t := by dsimp [s]; omega
  have hcut : c + 2*m = y.log2 + s := by dsimp [c,s]; omega
  have topAt := Top_iter (top_log2 hy) s
  have top : Top (iter F s y >>> c) (2*m) := by
    constructor
    · rw [Nat.testBit_shiftRight,hcut]; exact topAt.1
    · intro i hi
      rw [Nat.testBit_shiftRight]
      exact topAt.2 _ (by omega)
  have mem := covers _ top
  rw [← iter_F_shiftRight, ← iter_add, hsplit] at mem
  exact (show c + age m = y.log2+t-2*m by omega) ▸ mem

end PhaseTwo.EdgePair
