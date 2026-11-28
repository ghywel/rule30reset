import EdgePair

namespace PhaseTwo.EdgeTriple
open PhaseTwo.EdgePair Ruliology.CellularAutomata.Rule30LateTwins

/-- With an outer flip and two white ticks at the outer driver, the two
    inward follower cells are determined after three ticks. -/
theorem force_followers (w : Nat) (s : Pair) (a : w.testBit 1 = false)
    (b : w.testBit 2 = true) (c : (R w).testBit 1 = false) :
    pairIter 3 w s = pairIter 3 w (false,false) := by
  obtain ⟨i,j⟩ := s
  have d : (R w).testBit 0 = !w.testBit 0 := by
    simp only [R,Nat.testBit_shiftRight,Nat.testBit_xor,Nat.testBit_or,Nat.add_zero,a,b]
    cases w.testBit 0 <;> rfl
  cases h : w.testBit 0 <;> cases i <;> cases j <;>
    simp [pairIter,advance,a,c,d,h]

def Small3 (t u : Nat) : Prop :=
  ∃ a b : Nat, ∀ x, x >>> 3 = u → iterR t x = a ∨ iterR t x = b

theorem lift_later (p : Nat) {q u : Nat} (h : Small3 q (iterR p u)) : Small3 (p+q) u := by
  obtain ⟨a,b,H⟩ := h
  refine ⟨a,b, fun x hx => ?_⟩
  rw [iterR_add]
  exact H _ (by rw [iterR_shiftRight,hx])

theorem later {p u : Nat} (h : Small3 p u) (q : Nat) : Small3 (p+q) u := by
  obtain ⟨a,b,H⟩ := h
  refine ⟨iterR q a,iterR q b,fun x hx => ?_⟩
  rcases H x hx with ht | ht <;> rw [iterR_add,ht] <;> simp

theorem cut (x : Nat) : x >>> 2 = 2*(x >>> 3) + (x.testBit 2).toNat := by
  simp only [Nat.shiftRight_eq_div_pow,Nat.testBit_eq_decide_div_mod_eq,Nat.reducePow]
  by_cases h : x/4%2=1 <;> simp [h] <;> omega

theorem white_flip {u : Nat} (h₀ : u.testBit 0 = false) (h₁ : u.testBit 1 = true)
    (h₀' : (R u).testBit 0 = false) : Small3 3 u := by
  let out (w : Nat) := pack (iterR 3 w) (pairIter 3 w (false,false))
  refine ⟨out (2*u), out (2*u+1), fun x hx => ?_⟩
  let w := x >>> 2
  have link : w >>> 1 = u := by dsimp [w]; rw [←Nat.shiftRight_add]; exact hx
  have a : w.testBit 1 = false := by simpa only [←link,Nat.testBit_shiftRight] using h₀
  have b : w.testBit 2 = true := by simpa only [←link,Nat.testBit_shiftRight] using h₁
  have c : (R w).testBit 1 = false := by
    rw [←link,← R_shiftRight,Nat.testBit_shiftRight] at h₀'
    exact h₀'
  have eq := repack (iterR 3 x)
  rw [iterR_shiftRight,iter_read,force_followers w _ a b c] at eq
  dsimp [w] at eq
  have wc := cut x
  rw [hx] at wc
  cases h : x.testBit 2 <;> simp [h] at wc <;> rw [wc] at eq
  · exact Or.inl eq.symm
  · exact Or.inr eq.symm

theorem black_then {u d : Nat} (top : Top u d) (h : u.testBit 0 = true) :
    Small3 (1 + ((d+1)/2+2)) u := by
  let w := 2 * R u + (!u.testBit 1).toNat
  have wu : w >>> 1 = R u := by
    dsimp [w]; rw [Nat.shiftRight_eq_div_pow]; cases u.testBit 1 <;> simp <;> omega
  have high : w.testBit (d+1) = true := by
    have h' := (top_R top).1
    rwa [←wu,Nat.testBit_shiftRight,Nat.add_comm] at h'
  obtain ⟨a,b,hab⟩ := packed_two_extensions high
  refine ⟨a,b,fun x hx => ?_⟩
  rw [iterR_add]; apply hab
  have x3 : x.testBit 3 = true := by
    simpa only [←hx,Nat.testBit_shiftRight] using h
  have x4 : x.testBit 4 = u.testBit 1 := by
    simp only [←hx,Nat.testBit_shiftRight]
  have fix : (R x).testBit 2 = !u.testBit 1 := by
    simp only [R,Nat.testBit_shiftRight,Nat.testBit_xor,Nat.testBit_or,Nat.reduceAdd,x3,x4]
    cases u.testBit 1 <;> rfl
  change R x >>> 2 = w
  rw [cut, R_shiftRight, hx, fix]

def cost (d : Nat) := d + 4

theorem three_extensions {u d : Nat} (top : Top u d) : Small3 (cost d) u := by
  let k := d/2+1
  by_cases early : ∃ t < k+1, (iterR t u).testBit 0 = true
  · obtain ⟨t,ht,black⟩ := early
    have hit := lift_later t (black_then (top_iterR top t) black)
    have bound : t+(1+((d+1)/2+2)) ≤ cost d := by dsimp [cost,k] at *; omega
    simpa [Nat.add_sub_of_le bound] using later hit (cost d-(t+(1+((d+1)/2+2))))
  · have white (t : Nat) (ht : t < k+1) : (iterR t u).testBit 0 = false := by
      cases h : (iterR t u).testBit 0
      · rfl
      · exact False.elim (early ⟨t,ht,h⟩)
    have flip : ∃ t < k, (iterR t u).testBit 1 = true := by
      apply Classical.byContradiction
      intro no
      have quiet (t : Nat) (ht : t < k) : (iterR t u).testBit 0 = false ∧ (iterR t u).testBit 1 = false := by
        refine ⟨white t (by omega),?_⟩
        cases h : (iterR t u).testBit 1
        · rfl
        · exact False.elim (no ⟨t,ht,h⟩)
      have z := no_low_pair quiet d (by dsimp [k]; omega)
      simp [top.1] at z
    obtain ⟨t,ht,bit⟩ := flip
    have next : (R (iterR t u)).testBit 0 = false := by
      rw [← iterR_succ']; exact white (t+1) (by omega)
    have hit := lift_later t (white_flip (white t (by omega)) bit next)
    have bound : t+3 ≤ cost d := by dsimp [cost,k] at *; omega
    simpa [Nat.add_sub_of_le bound] using later hit (cost d-(t+3))

def age3 : Nat → Nat
  | 0 => 0
  | m+1 => age3 m + (3*m+4)

/-- After quadratic time, an outer band of length 3m+1 needs at most one bit per three inward cells. -/
theorem outer_cover3 (m : Nat) :
    ∃ A : List Nat, A.length ≤ 2^m ∧ ∀ x, Top x (3*m) → iterR (age3 m) x ∈ A := by
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
    simp [age3,iterR,eq]
  | succ m ih =>
    obtain ⟨A, hlen, hmem⟩ := ih
    have ex (u : Nat) : ∃ a b : Nat, ∀ y, Top u (3*m) → y >>> 3 = u →
        iterR (3*m+4) y = a ∨ iterR (3*m+4) y = b := by
      by_cases top : Top u (3*m)
      · obtain ⟨a,b,h⟩ := three_extensions top
        exact ⟨a,b,fun y _ hy => by simpa [cost] using h y hy⟩
      · exact ⟨0,0,fun _ h _ => False.elim (top h)⟩
    let a (u : Nat) := (ex u).choose
    let b (u : Nat) := (ex u).choose_spec.choose
    have hab (u : Nat) := (ex u).choose_spec.choose_spec
    refine ⟨A.map a ++ A.map b, by simp only [List.length_append,List.length_map]; rw [Nat.pow_succ]; omega, ?_⟩
    intro x hx
    have upper : Top (x >>> 3) (3*m) := by
      constructor
      · simpa [Nat.testBit_shiftRight,show 3+3*m=3*(m+1) by omega] using hx.1
      · intro i hi
        rw [Nat.testBit_shiftRight]
        exact hx.2 _ (by omega)
    let y := iterR (age3 m) x
    let u := iterR (age3 m) (x >>> 3)
    have cut : y >>> 3 = u := iterR_shiftRight _ _ _
    have mem : u ∈ A := hmem _ upper
    have cases := hab u y (top_iterR upper _) cut
    rw [age3,iterR_add]
    rcases cases with ha | hb
    · rw [ha]; exact List.mem_append_left _ (List.mem_map.mpr ⟨_,mem,rfl⟩)
    · rw [hb]; exact List.mem_append_right _ (List.mem_map.mpr ⟨_,mem,rfl⟩)


theorem age3_closed (m : Nat) : 2 * age3 m = m * (3*m + 5) := by
  induction m with
  | zero => rfl
  | succ m ih =>
    simp only [age3, Nat.mul_add, Nat.add_mul, Nat.mul_one, Nat.one_mul] at *
    omega

open Ruliology.CellularAutomata.Rule30ZeroBoundary.IntegerForm

/-- A common outer-band cover for *every* late physical image of every nonzero seed. -/
theorem late_outer_cover3 (m : Nat) :
    ∃ A : List Nat, A.length ≤ 2^m ∧ ∀ y, y ≠ 0 → ∀ t, 3*m + age3 m ≤ t →
      (iter F t y >>> (y.log2 + t - 3*m)) ∈ A := by
  obtain ⟨A, size, covers⟩ := outer_cover3 m
  refine ⟨A,size,fun y hy t ht => ?_⟩
  let s := t - age3 m
  let c := y.log2 + s - 3*m
  have hsplit : s + age3 m = t := by dsimp [s]; omega
  have hcut : c + 3*m = y.log2 + s := by dsimp [c,s]; omega
  have topAt := Top_iter (top_log2 hy) s
  have top : Top (iter F s y >>> c) (3*m) := by
    constructor
    · rw [Nat.testBit_shiftRight,hcut]; exact topAt.1
    · intro i hi
      rw [Nat.testBit_shiftRight]
      exact topAt.2 _ (by omega)
  have mem := covers _ top
  rw [← iter_F_shiftRight, ← iter_add, hsplit] at mem
  exact (show c + age3 m = y.log2+t-3*m by omega) ▸ mem

end PhaseTwo.EdgeTriple
