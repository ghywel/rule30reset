import Ruliology.CellularAutomata.Rule30StripCertificates

/-!
# Two falling residues in every six columns of the single seed, at every modulus from three

A column of Rule 30 from a single black cell *falls* at tick `t` when it is black at `t` and white at `t + 1`
(`Fall`). `Cofinal i r` says that column `i` falls at ticks congruent to `r` modulo `m` after every cutoff.

* `PhaseFalls.Moduli.two_cofinal_every_modulus`: for every modulus `m ≥ 3` and every integer `i`, one of the six
  columns `i, …, i + 5` has cofinal falls at two different residues modulo `m`. The column and the residues may
  depend on `m` and `i`.
* `PhaseFalls.Moduli.not_good_parity`: a control at modulus two. A four-row loop of the six-cell strip with free
  exterior cells has every fall on an even tick, and every adjacent pair changes under the lag-two shift. So the
  strip argument used here does not reach parity.

The proof. Suppose each of the six columns kept its late falls to one residue. Then the six cells follow a strip
graph with both exterior cells free and a calendar of `m` slots (`Run`). If three successive updates are quiet, the
first leaves the strip unchanged (`quiet_eq`), so one slot can be deleted from every period and any modulus above 18
reduces to 18 (`good_of_small`). Divisibility leaves the moduli 3, 4, 5, 7, 11, 13 and 17 (`good_of_dvd`), where
rank certificates show that some adjacent pair of columns repeats every period (`good3`, …, `good17`). Jen's theorem
forbids that on the single seed (`two_cofinal_from_good`).

The data modules use a checker on raw `Nat` operations (`checkFast`, `classify_stepFast`), proved sound in the
source; their certificate tables are the rank tables above, repacked into two numbers each.

The modules are in their build order. The seven data modules sit in nested namespaces `Data3`, …, `Data17`, since
they reuse the same private names, and each exports its one theorem.
-/

namespace Rule30Submission

/-! ## SixPhysical -/

/-! Coupling six observed columns to the graph with two free exterior bits.
Bit zero and ternary digit zero refer to the westernmost observed site. -/
namespace PhaseFalls.Six

open Ruliology.CellularAutomata Rule30Jen Rule30StripCertificates

def step (s : Nat) (w e : Bool) : Nat := stripStep 6 w e s

def row (T : Nat) (j : Int) : Nat := encRow T (j-1) 6

theorem row_lt (T : Nat) (j : Int) : row T j < 64 :=
  (enc_encRow 6 T (j-1)).1

theorem row_bit (T : Nat) (j : Int) (k : Nat) (hk : k<6) :
    (row T j).testBit k = cell T (j+k) := by
  simpa [row] using (enc_encRow 6 T (j-1)).2 k hk

theorem row_step (T : Nat) (j : Int) :
    row (T+1) j = step (row T j) (cell T (j-1)) (cell T (j+6)) := by
  have nxt := enc_step (enc_encRow 6 T (j-1))
  simp only [Int.sub_add_cancel] at nxt
  apply Nat.eq_of_testBit_eq
  intro k
  by_cases hk : k<6
  · rw [row_bit _ _ k hk]
    simpa [step,row] using (nxt.2 k hk).symm
  · have cut : 2^6 ≤ 2^k := Nat.pow_le_pow_right (by decide) (by omega)
    rw [Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (row_lt _ _) cut)]
    exact (Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le nxt.1 cut)).symm

/-- In a permitted edge, every site falling now has its assigned time phase. -/
def allowed (a t s d : Nat) : Bool :=
  (List.range 6).all fun k => !(s.testBit k && !d.testBit k) || t == a / 3^k % 3

theorem allowed_succ (a t T : Nat) (j : Int)
    (h : ∀ k : Nat, k<6 → cell T (j+k) = true → cell (T+1) (j+k) = false →
      t = a / 3^k % 3) :
    allowed a t (row T j) (row (T+1) j) = true := by
  apply List.all_eq_true.mpr
  intro k hk
  have bound := List.mem_range.mp hk
  simp only [row_bit _ _ k bound]
  cases on : cell T (j+k) <;> cases off : cell (T+1) (j+k) <;> try rfl
  simp [h k bound on off]

def encode (p : Nat → Nat) : Nat :=
  p 0 + 3 * p 1 + 9 * p 2 + 27 * p 3 + 81 * p 4 + 243 * p 5

theorem encode_lt (p : Nat → Nat) (hp : ∀ k, k<6 → p k<3) : encode p < 729 := by
  have := hp 0 (by decide)
  have := hp 1 (by decide)
  have := hp 2 (by decide)
  have := hp 3 (by decide)
  have := hp 4 (by decide)
  have := hp 5 (by decide)
  unfold encode
  omega

theorem encode_digit (p : Nat → Nat) (hp : ∀ k, k<6 → p k<3) (k : Nat) (hk : k<6) :
    encode p / 3^k % 3 = p k := by
  have := hp 0 (by decide)
  have := hp 1 (by decide)
  have := hp 2 (by decide)
  have := hp 3 (by decide)
  have := hp 4 (by decide)
  have := hp 5 (by decide)
  unfold encode
  rcases (show k=0 ∨ k=1 ∨ k=2 ∨ k=3 ∨ k=4 ∨ k=5 by omega) with
    rfl | rfl | rfl | rfl | rfl | rfl <;> simp only [Nat.reducePow] <;> omega

theorem encode_mod (p : Nat → Nat) (hp : ∀ k, k<6 → p k<3) (h0 : p 0=0) :
    encode p % 3 = 0 := by
  simpa [h0] using encode_digit p hp 0 (by decide)

end PhaseFalls.Six

/-! ## ModulusStrip -/

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

/-! ## ModulusCompress -/

namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata Rule30Jen

/-- Skip slot d in every round, keeping the row at the end of the idle update. -/
def insertSlot (d k : Nat) : Nat := if k < d then k else k+1

def deleteSlot (d k : Nat) : Nat := if k ≤ d then k else k-1

def expandTime (m d t : Nat) : Nat := (t/(m-1))*m + insertSlot d (t%(m-1))

def contractTime (m d t : Nat) : Nat := (t/m)*(m-1) + deleteSlot d (t%m)

theorem insert_bound {m d k : Nat} (hk : k < m-1) : insertSlot d k < m := by
  unfold insertSlot
  split <;> omega

private theorem not_insert {d k : Nat} : insertSlot d k ≠ d := by
  unfold insertSlot
  split <;> omega

theorem delete_bound {m d k : Nat} (hk : k < m) (hd : d+2 < m) :
    deleteSlot d k < m-1 := by
  unfold deleteSlot
  split <;> omega

private theorem phase_equiv {r k d : Nat} (hr : r ≠ d) :
    deleteSlot d r = k ↔ r = insertSlot d k := by
  unfold deleteSlot insertSlot
  split <;> split <;> omega

private theorem expand_phase {m d t : Nat} (hm : 1 < m) :
    expandTime m d t % m = insertSlot d (t%(m-1)) := by
  unfold expandTime
  rw [Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt]
  exact insert_bound (Nat.mod_lt _ (by omega))

private theorem divMod_succ {t p : Nat} (hp : 0 < p) :
    (t+1)/p = (t%p+1)/p + t/p ∧ (t+1)%p = (t%p+1)%p := by
  have q : t+1 = t%p+1+p*(t/p) := by have := Nat.mod_add_div t p; omega
  conv => lhs; rw [q, Nat.add_mul_div_left _ _ hp]
  exact ⟨rfl, by conv => lhs; rw [q, Nat.add_mul_mod_self_left]⟩

private theorem expand_succ {m d t : Nat} (hd : 0 < d) (hb : d+2 < m) :
    expandTime m d (t+1) = expandTime m d t + (if t%(m-1)+1=d then 2 else 1) := by
  have hp : 0 < m-1 := by omega
  have hr := Nat.mod_lt t hp
  obtain ⟨dvd,mod⟩ := divMod_succ (t:=t) hp
  unfold expandTime
  rw [dvd,mod]
  by_cases c : t%(m-1)+1 < m-1
  · rw [Nat.div_eq_of_lt c, Nat.mod_eq_of_lt c, Nat.zero_add]
    unfold insertSlot
    split <;> split <;> split <;> omega
  · have e : t%(m-1)+1=m-1 := by omega
    rw [e, Nat.div_self hp, Nat.mod_self, ite_eq_right (show m-1≠d by omega)]
    simp only [insertSlot, ite_eq_left hd, ite_eq_right (show ¬ t%(m-1)<d by omega),
      Nat.add_zero, Nat.add_mul, Nat.one_mul]
    omega

private theorem expand_contract {m d t : Nat} (hb : d+2 < m) :
    expandTime m d (contractTime m d t) = t + (if t%m=d then 1 else 0) := by
  have hp : 0 < m-1 := by omega
  have hr := Nat.mod_lt t (show 0 < m by omega)
  have hsmall := delete_bound hr hb
  have div : contractTime m d t / (m-1) = t/m := by
    unfold contractTime
    rw [Nat.add_comm, Nat.mul_comm (t/m) (m-1), Nat.add_mul_div_left _ _ hp,
      Nat.div_eq_of_lt hsmall, Nat.zero_add]
  have mod : contractTime m d t % (m-1) = deleteSlot d (t%m) := by
    unfold contractTime
    rw [Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hsmall]
  unfold expandTime
  rw [div,mod]
  have decom := Nat.div_add_mod t m
  rw [Nat.mul_comm (t/m) m]
  unfold insertSlot deleteSlot
  split <;> split <;> split <;> omega

private theorem quiet_idle {m d t : Nat} {a x : Nat → Nat} (h : Run 6 m a x)
    (hb : d+2 < m) (ht : t%m=d)
    (quiet : ∀ j, j < 6 → a j < d ∨ d+2 < a j) : x (t+1) = x t := by
  have zero (i : Nat) (hi : i ≤ 2) : permit 6 a ((t+i)%m) = 0 := by
    rw [Nat.add_mod t i m, ht, Nat.mod_eq_of_lt (show i < m by omega),
      Nat.mod_eq_of_lt (show d+i<m by omega)]
    apply Nat.eq_of_testBit_eq
    intro j
    rw [permit_bit, Nat.zero_testBit]
    by_cases hj : j < 6
    · have := quiet j hj
      simp [show a j ≠ d+i by omega]
    · simp [hj]
  have h0 := h.edge t
  have h1 := h.edge (t+1)
  have h2 := h.edge (t+2)
  rw [show permit 6 a (t%m) = 0 by simpa using zero 0 (by decide)] at h0
  rw [zero 1 (by decide)] at h1
  rw [zero 2 (by decide)] at h2
  exact quiet_eq (h.bounded t) h0 h1 h2

/-- A gap of three quiet ticks can be shortened by a uniform deletion in each
period. A paired reading in the shorter calendar lifts to the original one. -/
theorem good_of_deleted {m d : Nat} {a : Nat → Nat} (hd : 0 < d) (hb : d+2 < m)
    (quiet : ∀ j, j < 6 → a j < d ∨ d+2 < a j)
    (good : Good 6 (m-1) (fun j => deleteSlot d (a j))) : Good 6 m a := by
  intro x h
  let y (t : Nat) := x (expandTime m d t)
  have hy : Run 6 (m-1) (fun j => deleteSlot d (a j)) y := by
    refine ⟨fun t => h.bounded _, fun t => ?_⟩
    have edge := h.edge (expandTime m d t)
    rw [expand_phase (show 1<m by omega)] at edge
    have same : permit 6 (fun j => deleteSlot d (a j)) (t%(m-1)) =
        permit 6 a (insertSlot d (t%(m-1))) := by
      apply Nat.eq_of_testBit_eq
      intro j
      rw [permit_bit, permit_bit]
      by_cases hj : j < 6
      · have hn := quiet j hj
        simp only [hj, true_and]
        rw [Bool.eq_iff_iff, decide_eq_true_eq, decide_eq_true_eq]
        exact phase_equiv (by omega)
      · simp [hj]
    rw [same]
    change Edge 6 _ (x (expandTime m d t)) (x (expandTime m d (t+1)))
    rw [expand_succ hd hb]
    by_cases cut : t%(m-1)+1=d
    · rw [ite_eq_left cut]
      have atCut : (expandTime m d t + 1)%m = d := by
        rw [Nat.add_mod, expand_phase (show 1<m by omega), Nat.mod_eq_of_lt (show 1<m by omega)]
        simp only [insertSlot, ite_eq_left (show t%(m-1)<d by omega)]
        exact (congrArg (fun r => r % m) cut).trans (Nat.mod_eq_of_lt (by omega))
      have eq := quiet_idle h hb atCut quiet
      rwa [show expandTime m d t + 2 = expandTime m d t + 1 + 1 by omega, eq]
    · rwa [ite_eq_right cut]
  obtain ⟨j,N,hj,per⟩ := good y hy
  refine ⟨j,N*m,hj,fun t ht => ?_⟩
  have reads (s : Nat) : y (contractTime m d s) = x s := by
    unfold y
    rw [expand_contract hb]
    by_cases atCut : s%m=d
    · simpa only [ite_eq_left atCut] using quiet_idle h hb atCut quiet
    · rw [ite_eq_right atCut, Nat.add_zero]
  have repr : contractTime m d (t+m) = contractTime m d t+(m-1) := by
    unfold contractTime
    rw [Nat.add_div_right _ (show 0<m by omega), Nat.add_mod_right, Nat.add_mul, Nat.one_mul]
    omega
  have age : N ≤ contractTime m d t := by
    have hdiv := (Nat.le_div_iff_mul_le (show 0<m by omega)).mpr ht
    have hmul : t/m ≤ (t/m)*(m-1) := by
      simpa using (Nat.mul_le_mul_left (t/m) (show 1 ≤ m-1 by omega))
    unfold contractTime
    omega
  simpa only [← repr, reads] using per (contractTime m d t) age

private theorem quiet_gap {m : Nat} (hm : 18 < m) {a : Nat → Nat} (zero : a 0 = 0) :
    ∃ d, 0 < d ∧ d+2 < m ∧ ∀ j, j < 6 → a j < d ∨ d+2 < a j := by
  apply Classical.byContradiction
  intro nh
  let hit := (List.range 6).map (fun j => (a j+2)/3)
  have covered : ∀ k ∈ List.range 7, k ∈ hit := by
    intro k hk
    have hk := List.mem_range.mp hk
    by_cases z : k=0
    · exact List.mem_map.mpr ⟨0,List.mem_range.mpr (by decide),by omega⟩
    · let d := 3*k-2
      have member : ∃ j, j < 6 ∧ d ≤ a j ∧ a j ≤ d+2 := by
        apply Classical.byContradiction
        intro absent
        exact nh ⟨d,by dsimp [d]; omega,by dsimp [d]; omega,fun j hj => by
          by_cases lo : a j < d
          · exact Or.inl lo
          · exact Or.inr (by
              apply Classical.byContradiction
              intro hi
              exact absent ⟨j,hj,by omega,by omega⟩)⟩
      obtain ⟨j,hj,lo,hi⟩ := member
      exact List.mem_map.mpr ⟨j,List.mem_range.mpr hj,by dsimp [d] at lo hi; omega⟩
  have bad := length_le_of_subset (List.nodup_range (n:=7)) covered
  simp [hit] at bad

/-- The six-site problem at every modulus reduces to moduli 3 through 18. -/
theorem good_of_small {m : Nat} {a : Nat → Nat} (hm : 3 ≤ m)
    (ha : ∀ j, j < 6 → a j < m)
    (small : ∀ m, 3 ≤ m → m ≤ 18 → ∀ a, (∀ j, j < 6 → a j < m) → Good 6 m a) :
    Good 6 m a := by
  induction m using Nat.strongRecOn generalizing a with
  | ind m ih =>
    by_cases short : m ≤ 18
    · exact small m hm short a ha
    · apply good_of_rotated (q:=a 0) (ha 0 (by decide)) ha
      let b (j : Nat) := rotate m (a 0) (a j)
      change Good 6 m b
      have b0 : b 0 = 0 := by simp [b,rotate]
      obtain ⟨d,hd,hb,quiet⟩ := quiet_gap (by omega : 18 < m) b0
      apply good_of_deleted hd hb quiet
      exact ih (m-1) (by omega) (by omega) (fun j hj =>
        delete_bound (rotate_lt (ha 0 (by decide)) (ha j hj)) hb)

end PhaseFalls.Moduli

/-! ## ModulusSlice -/

namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata Rule30StripCertificates

def slice (w k s : Nat) : Nat := (s >>> k) % 2^w

theorem slice_bit {w k s j : Nat} (hj : j < w) :
    (slice w k s).testBit j = s.testBit (k+j) := by
  simp [slice, Nat.testBit_mod_two_pow, Nat.testBit_shiftRight, hj]

private theorem slice_step {w v k s : Nat} (hk : k+v ≤ w)
    (hs : s < 2^w) (l r : Bool) :
    slice v k (stripStep w l r s) =
      stripStep v (if k = 0 then l else s.testBit (k-1))
        (if k+v = w then r else s.testBit (k+v)) (slice v k s) := by
  apply Nat.eq_of_testBit_eq
  intro j
  have small : slice v k s < 2^v := Nat.mod_lt _ (Nat.two_pow_pos v)
  by_cases hj : j < v
  · rw [slice_bit hj, testBit_stripStep _ _ _ _ hs _ (by omega),
      testBit_stripStep _ _ _ _ small _ hj, slice_bit hj]
    congr 1
    · by_cases h : j=0
      · subst j
        simp
      · rw [ite_eq_right h, slice_bit (show j-1 < v by omega)]
        rw [ite_eq_right (show k+j ≠ 0 by omega), show k+(j-1)=k+j-1 by omega]
    · by_cases h : j+1=v
      · rw [ite_eq_left h, show k+j+1=k+v by omega]
      · rw [ite_eq_right h, slice_bit (show j+1 < v by omega)]
        rw [ite_eq_right (show k+j+1 ≠ w by omega), Nat.add_assoc]
  · have le : 2^v ≤ 2^j := Nat.pow_le_pow_right (by decide : 0<2) (by omega)
    have left : slice v k (stripStep w l r s) < 2^j :=
      Nat.lt_of_lt_of_le (Nat.mod_lt _ (Nat.two_pow_pos v)) le
    have right := Nat.lt_of_lt_of_le (stripStep_lt v
      (if k = 0 then l else s.testBit (k-1))
      (if k+v = w then r else s.testBit (k+v)) (slice v k s)) le
    rw [Nat.testBit_lt_two_pow left, Nat.testBit_lt_two_pow right]

theorem slice_run {w v k m : Nat} {a x : Nat → Nat} (hk : k+v ≤ w)
    (run : Run w m a x) : Run v m (fun j => a (k+j)) (fun t => slice v k (x t)) := by
  refine ⟨fun _ => Nat.mod_lt _ (Nat.two_pow_pos v), fun t => ?_⟩
  obtain ⟨l,r,lr⟩ := mem_successors.mp (run.edge t).1
  refine ⟨mem_successors.mpr ⟨_,_,lr ▸ slice_step hk (run.bounded t) l r⟩,
    (fits_iff _ _ _).mpr ?_⟩
  intro j on off
  by_cases hj : j < v
  · rw [slice_bit hj] at on off
    have e := (fits_iff _ _ _).mp (run.edge t).2 (k+j) on off
    rw [permit_bit, decide_eq_true_eq] at e ⊢
    exact ⟨hj,e.2⟩
  · have no : (slice v k (x t)).testBit j = false :=
      Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (Nat.mod_lt _ (Nat.two_pow_pos v))
        (Nat.pow_le_pow_right (by decide : 0<2) (by omega : v ≤ j)))
    simp [no] at on

theorem pair_bits {s d j : Nat} (h : (s >>> j) % 4 = (d >>> j) % 4) :
    s.testBit j = d.testBit j ∧ s.testBit (j+1) = d.testBit (j+1) := by
  change (s >>> j)%(2^2) = (d >>> j)%(2^2) at h
  constructor
  · simpa only [Nat.testBit_mod_two_pow, Nat.testBit_shiftRight, Nat.add_zero,
      decide_eq_true (by decide : 0<2), Bool.true_and] using
      congrArg (fun n : Nat => n.testBit 0) h
  · simpa only [Nat.testBit_mod_two_pow, Nat.testBit_shiftRight,
      decide_eq_true (by decide : 1<2), Bool.true_and] using
      congrArg (fun n : Nat => n.testBit 1) h

private theorem pair_eq_of_bits {s d j : Nat} (h₁ : s.testBit j = d.testBit j)
    (h₂ : s.testBit (j+1) = d.testBit (j+1)) : (s >>> j)%4 = (d >>> j)%4 := by
  change (s >>> j)%(2^2) = (d >>> j)%(2^2)
  apply Nat.eq_of_testBit_eq
  intro k
  cases k with
  | zero => simpa only [Nat.testBit_mod_two_pow, Nat.testBit_shiftRight, Nat.add_zero,
      decide_eq_true (by decide : 0<2), Bool.true_and] using h₁
  | succ k =>
    cases k with
    | zero => simpa only [Nat.testBit_mod_two_pow, Nat.testBit_shiftRight,
        decide_eq_true (by decide : 1<2), Bool.true_and] using h₂
    | succ k =>
      simp only [Nat.testBit_mod_two_pow, decide_eq_false (show ¬ (k+1+1 < 2) by omega), Bool.false_and]

/-- A certificate on any contiguous substrip supplies a pair in the full strip. -/
theorem good_of_slice {w v k m : Nat} {a : Nat → Nat} (hk : k+v ≤ w)
    (good : Good v m (fun j => a (k+j))) : Good w m a := by
  intro x hx
  obtain ⟨j,N,hj,h⟩ := good _ (slice_run hk hx)
  refine ⟨k+j,N,by omega,fun t ht => ?_⟩
  obtain ⟨p,q⟩ := pair_bits (h t ht)
  rw [slice_bit (show j < v by omega), slice_bit (show j < v by omega)] at p
  rw [slice_bit hj, slice_bit hj, ← Nat.add_assoc] at q
  exact pair_eq_of_bits p q

end PhaseFalls.Moduli

/-! ## ModulusRank -/

namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata Rule30StripCertificates

/-- A rank identifies an adjacent pair and its reading at each tick of a period. -/
structure Certificate where
  labels : List Nat
  ranks : Array Nat
  reads : Array Nat

def label (c : Certificate) (j : Nat) : Nat := c.labels.getD j 0

def rankAt (packed s : Nat) : Nat := (packed >>> (6*s)) % 64

def readPair (g : Nat) : Nat := g % 8

def prediction (g p : Nat) : Nat := (g >>> (3+2*p)) % 4

def layer (w a p here next : Nat) (reads : Array Nat) : Bool :=
  (List.range (2^w)).all fun s =>
    let rk := rankAt here s
    let word := reads.getD rk 0
    let j := readPair word
    (j+1 < w && (s >>> j)%4 == prediction word p) &&
      (successors w s).all fun d => !(fits a s d) || rankAt next d ≤ rk

def check (w m : Nat) (c : Certificate) : Bool :=
  (List.range m).all fun p => layer w (permit w (label c) p) p
    (c.ranks.getD p 0) (c.ranks.getD ((p+1)%m) 0) c.reads

private theorem node {w m : Nat} {c : Certificate} (ok : check w m c = true)
    {p s : Nat} (hp : p < m) (hs : s < 2^w) :
    let rk := rankAt (c.ranks.getD p 0) s
    let word := c.reads.getD rk 0
    let j := readPair word
    (j+1 < w ∧ (s >>> j)%4 = prediction word p) ∧
      ∀ d, Edge w (permit w (label c) p) s d →
        rankAt (c.ranks.getD ((p+1)%m) 0) d ≤ rk := by
  have yes := List.all_eq_true.mp (List.all_eq_true.mp ok p (List.mem_range.mpr hp))
    s (List.mem_range.mpr hs)
  simp only [Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq] at yes
  refine ⟨yes.1,fun d hd => ?_⟩
  have h := List.all_eq_true.mp yes.2 d hd.1
  simpa [hd.2] using h

theorem good_of_check {w m : Nat} {c : Certificate} (hm : 0 < m) (ok : check w m c = true) :
    Good w m (label c) := by
  intro x hx
  let rk (t : Nat) := rankAt (c.ranks.getD (t%m) 0) (x t)
  let g (t : Nat) := c.reads.getD (rk t) 0
  have reads (t : Nat) : (readPair (g t))+1 < w ∧
      (x t >>> readPair (g t))%4 = prediction (g t) (t%m) :=
    (node ok (Nat.mod_lt _ hm) (hx.bounded t)).1
  have noninc (t : Nat) : rk (t+1) ≤ rk t := by
    have he : (t%m+1)%m=(t+1)%m := by
      calc (t%m+1)%m = (t%m+1%m)%m := by rw [Nat.add_mod (t%m) 1 m, Nat.mod_mod]
        _ = (t+1)%m := (Nat.add_mod t 1 m).symm
    simpa only [rk,he] using
      (node ok (Nat.mod_lt _ hm) (hx.bounded t)).2 _ (hx.edge t)
  obtain ⟨N,_,stable⟩ := antitone_eventually_const rk 0 (fun t _ => noninc t)
  refine ⟨readPair (g N),N,(reads N).1,fun t ht => ?_⟩
  have eq (u : Nat) (hu : N ≤ u) : g u = g N := congrArg (fun k => c.reads.getD k 0) (stable u hu)
  have a := (reads t).2
  have b := (reads (t+m)).2
  rw [eq t ht] at a
  rw [eq (t+m) (by omega), Nat.add_mod_right] at b
  exact b.trans a.symm

end PhaseFalls.Moduli

/-! ## ModulusLayers -/

/-! A failure of the adjacent-pair conclusion on a strip forces failure on
its two immediate substrips. Generate just the compatible extensions. -/
namespace PhaseFalls.Moduli

def labelsOf (w : Nat) (a : Nat → Nat) := (List.range w).map a

def norm (m : Nat) (xs : List Nat) : List Nat :=
  xs.map (rotate m (xs.headD 0))

def extend (m : Nat) (bad : List (List Nat)) : List (List Nat) :=
  bad.flatMap fun xs => (List.range m).filterMap fun p =>
    let ys := xs ++ [p]
    if bad.contains (norm m ys.tail) then some ys else none

def ruledOut (m : Nat) (previous remaining : List (List Nat)) : List (List Nat) :=
  (extend m previous).filter (fun xs => !(remaining.contains xs))

def pairs (m : Nat) := (List.range m).map fun q => [0,q]

abbrev Valid (w m : Nat) (a : Nat → Nat) := ∀ j, j < w → a j < m

def Classifies (w m : Nat) (bad : List (List Nat)) : Prop :=
  ∀ a, Valid w m a → a 0 = 0 → Good w m a ∨ labelsOf w a ∈ bad

theorem pairs_classify (m : Nat) : Classifies 2 m (pairs m) := by
  intro a ha zero
  exact Or.inr (List.mem_map.mpr ⟨a 1,List.mem_range.mpr (ha 1 (by decide)),by
    simp [labelsOf, zero, show List.range 2 = [0,1] by decide]⟩)

theorem good_congr {w m : Nat} {a b : Nat → Nat}
    (h : ∀ j, j < w → a j = b j) (good : Good w m a) : Good w m b := by
  intro x hx
  apply good x
  refine ⟨hx.bounded,fun t => ?_⟩
  have eq : permit w a (t%m) = permit w b (t%m) := by
    apply Nat.eq_of_testBit_eq
    intro j
    rw [permit_bit,permit_bit]
    by_cases hj : j < w
    · rw [h j hj]
    · simp [hj]
  rw [eq]
  exact hx.edge t

private theorem sound_label {c : Certificate} {w : Nat} {a : Nat → Nat} (h : c.labels = labelsOf w a)
    (j : Nat) (hj : j < w) : label c j = a j := by
  unfold label
  rw [h,List.getD_eq_getElem?_getD]
  have bound : j < (List.range w).length := by simpa using hj
  simp only [labelsOf,List.getElem?_map,List.getElem?_eq_getElem bound,List.getElem_range,Option.map_some,Option.getD_some]

private theorem phase_extend {w m : Nat} {a : Nat → Nat} {bad : List (List Nat)} (hw : 0 < w)
    (leftWord : labelsOf w a ∈ bad)
    (rightWord : labelsOf w (fun j => rotate m (a 1) (a (j+1))) ∈ bad) (last : a w < m) :
    labelsOf (w+1) a ∈ extend m bad := by
  have endWord : labelsOf w a ++ [a w] = labelsOf (w+1) a := by
    simp only [labelsOf,List.range_succ (n:=w),List.map_append,List.map_cons,List.map_nil]
  have tailWord : norm m (labelsOf (w+1) a).tail =
      labelsOf w (fun j => rotate m (a 1) (a (j+1))) := by
    have head : ((List.range w).map (fun j => a (j+1))).headD 0 = a 1 := by
      obtain ⟨v,rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : w ≠ 0)
      simp [List.range_succ_eq_map]
    simp only [labelsOf,List.range_succ_eq_map (n:=w),List.map_cons,List.tail_cons,
      List.map_map,Function.comp_def,Nat.succ_eq_add_one,norm,head]
  apply List.mem_flatMap.mpr
  refine ⟨labelsOf w a,leftWord,List.mem_filterMap.mpr ⟨a w,List.mem_range.mpr last,?_⟩⟩
  simp [endWord,tailWord,rightWord]

theorem classify_step {w m : Nat} {previous remaining : List (List Nat)} {cs : List Certificate}
    (hw : 0 < w) (hm : 0 < m)
    (prev : Classifies w m previous)
    (certs : cs.all (check (w+1) m) = true)
    (complete : ruledOut m previous remaining = cs.map Certificate.labels) :
    Classifies (w+1) m remaining := by
  intro a ha zero
  rcases prev a (fun j h => ha j (by omega)) zero with good | leftWord
  · exact Or.inl (good_of_slice (k:=0) (v:=w) (w:=w+1) (by omega) (by simpa using good))
  have ha1 := ha 1 (by omega)
  let b (j : Nat) := rotate m (a 1) (a (j+1))
  have hb : Valid w m b := fun j hj => rotate_lt ha1 (ha (j+1) (by omega))
  have b0 : b 0 = 0 := by simp [b,rotate]
  rcases prev b hb b0 with good | rightWord
  · have good' := good_of_rotated ha1 (fun j hj => ha (1+j) (by omega))
      (show Good w m (fun j => rotate m (a 1) (a (1+j))) by simpa [b,Nat.add_comm] using good)
    exact Or.inl (good_of_slice (k:=1) (w:=w+1) (by omega) good')
  by_cases bad : labelsOf (w+1) a ∈ remaining
  · exact Or.inr bad
  have h := phase_extend hw leftWord rightWord (ha w (by omega))
  have member : labelsOf (w+1) a ∈ ruledOut m previous remaining := by
    unfold ruledOut
    exact List.mem_filter.mpr ⟨h,by simp [List.contains_eq_mem,bad]⟩
  rw [complete] at member
  obtain ⟨c,hc,eq⟩ := List.mem_map.mp member
  exact Or.inl (good_congr (sound_label eq) (good_of_check hm (List.all_eq_true.mp certs c hc)))

theorem of_empty {m : Nat} (classified : Classifies 6 m []) {a : Nat → Nat} (ha : Valid 6 m a) : Good 6 m a := by
  have h0 := ha 0 (by decide)
  apply good_of_rotated h0 ha
  have e := classified (fun j => rotate m (a 0) (a j))
    (fun j hj => rotate_lt h0 (ha j hj)) (by simp [rotate])
  simpa only [List.not_mem_nil, or_false] using e

end PhaseFalls.Moduli

/-! ## FastRank -/

/-! A kernel-light checker for the rank certificates of `ModulusRank`.

The certificate content is the same: a rank for every (phase, row) node, and for every rank an adjacent pair and its
predicted reading at each phase. It is packed into two numbers, and the check uses only `Nat` primitives the kernel
evaluates directly, loops on `Nat.rec`, and no arrays, instances or decidable propositions inside the loops.
`good_of_checkFast` gives the same `Good w m` as `good_of_check`. -/
namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata Rule30StripCertificates

theorem raw_add (a b : Nat) : Nat.add a b = a + b := rfl
theorem raw_mul (a b : Nat) : Nat.mul a b = a * b := rfl
theorem raw_pow (a b : Nat) : Nat.pow a b = a ^ b := rfl
theorem raw_mod (a b : Nat) : Nat.mod a b = a % b := rfl
theorem raw_sub (a b : Nat) : Nat.sub a b = a - b := rfl
theorem raw_shr (a b : Nat) : Nat.shiftRight a b = a >>> b := rfl
theorem raw_shl (a b : Nat) : Nat.shiftLeft a b = a <<< b := rfl
theorem raw_land (a b : Nat) : Nat.land a b = a &&& b := rfl
theorem raw_lor (a b : Nat) : Nat.lor a b = a ||| b := rfl
theorem raw_xor (a b : Nat) : Nat.xor a b = a ^^^ b := rfl

/-- `f i` for every `i < n`, counting down on `Nat.rec`'s own predecessor, so every index is a literal. -/
def allBelow (n : Nat) (f : Nat → Bool) : Bool :=
  Nat.rec (motive := fun _ => Bool) true (fun i ih => f i && ih) n

theorem allBelow_spec {n : Nat} {f : Nat → Bool} (h : allBelow n f = true) {j : Nat} (hj : j < n) :
    f j = true := by
  induction n with
  | zero => omega
  | succ n ih =>
    have h' : (f n && allBelow n f) = true := h
    rw [Bool.and_eq_true] at h'
    by_cases e : j = n
    · subst e; exact h'.1
    · exact ih h'.2 (by omega)

/-- Field `i` of width `b` in a packed number. -/
def field (P b i : Nat) : Nat := Nat.mod (Nat.shiftRight P (Nat.mul b i)) (Nat.pow 2 b)

/-- The permitted-fall mask at phase `p`, from the list of phases. -/
noncomputable def permitFast (labels : List Nat) (p : Nat) : Nat :=
  List.rec (motive := fun _ => Nat → Nat) (fun _ => 0)
    (fun hd _ ih j => Nat.lor (cond (Nat.beq hd p) (Nat.shiftLeft 1 j) 0) (ih (j+1))) labels 0

private theorem permitFast_go (p : Nat) : ∀ (xs : List Nat) (i j : Nat),
    (List.rec (motive := fun _ => Nat → Nat) (fun _ => 0)
      (fun hd _ ih j => Nat.lor (cond (Nat.beq hd p) (Nat.shiftLeft 1 j) 0) (ih (j+1))) xs i).testBit j =
      decide (i ≤ j ∧ j < i + xs.length ∧ xs.getD (j - i) 0 = p)
  | [], i, j => by simp; intro _ _; omega
  | hd :: tl, i, j => by
    show (Nat.lor (cond (Nat.beq hd p) (Nat.shiftLeft 1 i) 0) _).testBit j = _
    rw [raw_lor, Nat.testBit_or, permitFast_go p tl (i+1) j]
    by_cases e : j = i
    · subst e
      have rest : decide (j + 1 ≤ j ∧ j < j + 1 + tl.length ∧ tl.getD (j - (j + 1)) 0 = p) = false := by
        simp only [decide_eq_false_iff_not, not_and]
        intro h
        exact absurd h (by omega)
      rw [rest, Bool.or_false]
      cases h : Nat.beq hd p
      · have hne := Nat.ne_of_beq_eq_false h
        simp [hne]
      · have heq := Nat.eq_of_beq_eq_true h
        subst heq
        simp [raw_shl, Nat.testBit_shiftLeft]
    · have bit : (cond (Nat.beq hd p) (Nat.shiftLeft 1 i) 0).testBit j = false := by
        cases Nat.beq hd p
        · simp
        · show (Nat.shiftLeft 1 i).testBit j = false
          rw [raw_shl, Nat.testBit_shiftLeft]
          by_cases hij : i ≤ j
          · obtain ⟨k, hk⟩ : ∃ k, j - i = k + 1 := ⟨j - i - 1, by omega⟩
            simp only [hij, decide_true, Bool.true_and, hk, Nat.testBit_succ]
            simp
          · simp [hij]
      rw [bit, Bool.false_or]
      by_cases hij : i ≤ j
      · have k : j - i = (j - (i+1)) + 1 := by omega
        simp only [List.length_cons, k, List.getD_cons_succ]
        congr 1
        apply propext
        constructor
        · rintro ⟨_,b,c⟩; exact ⟨by omega,by omega,c⟩
        · rintro ⟨_,b,c⟩; exact ⟨by omega,by omega,c⟩
      · have : ¬ i + 1 ≤ j := by omega
        simp [hij, this]

theorem permitFast_eq {w : Nat} {labels : List Nat} (hl : labels.length = w) (p : Nat) :
    permitFast labels p = permit w (fun j => labels.getD j 0) p := by
  apply Nat.eq_of_testBit_eq
  intro j
  rw [permit_bit, permitFast, permitFast_go p labels 0 j]
  simp [hl]

/-- A strip successor with raw operations; `stripStep_raw` identifies it. -/
def succRaw (w N a z s : Nat) : Nat :=
  Nat.mod (Nat.xor (Nat.lor (Nat.shiftLeft s 1) a)
    (Nat.lor (Nat.lor s (Nat.shiftRight s 1)) (Nat.shiftLeft z (Nat.sub w 1)))) N

theorem stripStep_raw (w : Nat) (a z : Bool) (s : Nat) :
    stripStep w a z s = succRaw w (2^w) a.toNat z.toNat s := rfl

/-- Whether a step from `s` to `d` lets only the cells in `a` fall. -/
def fitsRaw (a s d : Nat) : Bool := let f := Nat.land s (Nat.xor s d); Nat.beq (Nat.land f a) f

theorem fitsRaw_eq (a s d : Nat) : fitsRaw a s d = fits a s d := by
  unfold fitsRaw fits fallMask
  apply Bool.eq_iff_iff.mpr
  simp only [beq_iff_eq, raw_land, raw_xor]
  exact ⟨Nat.eq_of_beq_eq_true, fun h => by rw [h]; exact Nat.beq_refl _⟩

/-- A packed certificate: the rank of node (p, s) is 6-bit field `p * 2^w + s` of `ranks`; the word of rank `r` is
field `r` of width `3 + 2m` of `reads` (bits 0 to 2 the pair, then two bits per phase). -/
structure FastCert where
  labels : List Nat
  ranks : Nat
  reads : Nat

def labelF (c : FastCert) (j : Nat) : Nat := c.labels.getD j 0

def edgeOk (a rk nextBase ranks s d : Nat) : Bool :=
  !(fitsRaw a s d) || Nat.ble (field ranks 6 (Nat.add nextBase d)) rk

noncomputable def checkFast (w m : Nat) (c : FastCert) : Bool :=
  Nat.beq c.labels.length w &&
  allBelow m fun p =>
    let N := Nat.pow 2 w
    let F := Nat.add 3 (Nat.mul 2 m)
    let a := permitFast c.labels p
    let base := Nat.mul p N
    let nextBase := Nat.mul (Nat.mod (Nat.add p 1) m) N
    allBelow N fun s =>
      let rk := field c.ranks 6 (Nat.add base s)
      let g := field c.reads F rk
      let j := Nat.mod g 8
      (Nat.blt (Nat.add j 1) w &&
        Nat.beq (Nat.mod (Nat.shiftRight s j) 4) (Nat.mod (Nat.shiftRight g (Nat.add 3 (Nat.mul 2 p))) 4)) &&
      (edgeOk a rk nextBase c.ranks s (succRaw w N 0 0 s) &&
        edgeOk a rk nextBase c.ranks s (succRaw w N 0 1 s) &&
        edgeOk a rk nextBase c.ranks s (succRaw w N 1 0 s) &&
        edgeOk a rk nextBase c.ranks s (succRaw w N 1 1 s))

private theorem nodeFast {w m : Nat} {c : FastCert} (ok : checkFast w m c = true)
    {p s : Nat} (hp : p < m) (hs : s < 2^w) :
    let rk := field c.ranks 6 (p * 2^w + s)
    let g := field c.reads (3 + 2*m) rk
    let j := g % 8
    (j + 1 < w ∧ (s >>> j) % 4 = (g >>> (3 + 2*p)) % 4) ∧
      ∀ d, Edge w (permit w (labelF c) p) s d →
        field c.ranks 6 (((p+1)%m) * 2^w + d) ≤ rk := by
  rw [checkFast, Bool.and_eq_true] at ok
  have hl : c.labels.length = w := by simpa [Nat.beq_eq_true_eq] using ok.1
  have hpf := allBelow_spec ok.2 hp
  simp only at hpf
  have hsf := allBelow_spec hpf (show s < Nat.pow 2 w from hs)
  simp only [Bool.and_eq_true, Nat.blt_eq, Nat.beq_eq_true_eq] at hsf
  obtain ⟨⟨hj, hr⟩, ⟨⟨⟨e00, e01⟩, e10⟩, e11⟩⟩ := hsf
  simp only [field, raw_add, raw_mul, raw_pow, raw_mod, raw_shr] at hj hr
  refine ⟨⟨by simpa only [field, raw_add, raw_mul, raw_pow, raw_mod, raw_shr] using hj,
    by simpa only [field, raw_add, raw_mul, raw_pow, raw_mod, raw_shr] using Nat.eq_of_beq_eq_true hr⟩,
    fun d hd => ?_⟩
  obtain ⟨l, r, rfl⟩ := mem_successors.mp hd.1
  have fit : fits (permit w (fun j => c.labels.getD j 0) p) s (stripStep w l r s) = true := hd.2
  rw [← permitFast_eq hl, ← fitsRaw_eq] at fit
  have pick : edgeOk (permitFast c.labels p) (field c.ranks 6 (Nat.add (Nat.mul p (Nat.pow 2 w)) s))
      (Nat.mul (Nat.mod (Nat.add p 1) m) (Nat.pow 2 w)) c.ranks s (stripStep w l r s) = true := by
    rw [stripStep_raw]
    cases l <;> cases r
    · exact e00
    · exact e01
    · exact e10
    · exact e11
  unfold edgeOk at pick
  rw [fit] at pick
  simpa [Nat.ble_eq, field, raw_add, raw_mul, raw_pow, raw_mod, raw_shr] using pick

theorem good_of_checkFast {w m : Nat} {c : FastCert} (hm : 0 < m) (ok : checkFast w m c = true) :
    Good w m (labelF c) := by
  intro x hx
  let rk (t : Nat) := field c.ranks 6 ((t%m) * 2^w + x t)
  let g (t : Nat) := field c.reads (3 + 2*m) (rk t)
  have reads (t : Nat) : (g t % 8) + 1 < w ∧ (x t >>> (g t % 8)) % 4 = (g t >>> (3 + 2*(t%m))) % 4 :=
    (nodeFast ok (Nat.mod_lt _ hm) (hx.bounded t)).1
  have noninc (t : Nat) : rk (t+1) ≤ rk t := by
    have he : (t%m+1)%m = (t+1)%m := by
      calc (t%m+1)%m = (t%m+1%m)%m := by rw [Nat.add_mod (t%m) 1 m, Nat.mod_mod]
        _ = (t+1)%m := (Nat.add_mod t 1 m).symm
    have := (nodeFast ok (Nat.mod_lt _ hm) (hx.bounded t)).2 _ (hx.edge t)
    simpa only [rk, he] using this
  obtain ⟨N, _, stable⟩ := antitone_eventually_const rk 0 (fun t _ => noninc t)
  refine ⟨g N % 8, N, (reads N).1, fun t ht => ?_⟩
  have eq (u : Nat) (hu : N ≤ u) : g u = g N := congrArg (fun k => field c.reads (3 + 2*m) k) (stable u hu)
  have a := (reads t).2
  have b := (reads (t+m)).2
  rw [eq t ht] at a
  rw [eq (t+m) (by omega), Nat.add_mod_right] at b
  exact b.trans a.symm

private theorem sound_labelF {c : FastCert} {w : Nat} {a : Nat → Nat} (h : c.labels = labelsOf w a)
    (j : Nat) (hj : j < w) : labelF c j = a j := by
  unfold labelF
  rw [h, List.getD_eq_getElem?_getD]
  have bound : j < (List.range w).length := by simpa using hj
  simp only [labelsOf, List.getElem?_map, List.getElem?_eq_getElem bound, List.getElem_range, Option.map_some,
    Option.getD_some]

theorem phase_extendF {w m : Nat} {a : Nat → Nat} {bad : List (List Nat)} (hw : 0 < w)
    (leftWord : labelsOf w a ∈ bad)
    (rightWord : labelsOf w (fun j => rotate m (a 1) (a (j+1))) ∈ bad) (last : a w < m) :
    labelsOf (w+1) a ∈ extend m bad := by
  have endWord : labelsOf w a ++ [a w] = labelsOf (w+1) a := by
    simp only [labelsOf, List.range_succ (n:=w), List.map_append, List.map_cons, List.map_nil]
  have tailWord : norm m (labelsOf (w+1) a).tail =
      labelsOf w (fun j => rotate m (a 1) (a (j+1))) := by
    have head : ((List.range w).map (fun j => a (j+1))).headD 0 = a 1 := by
      obtain ⟨v, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : w ≠ 0)
      simp [List.range_succ_eq_map]
    simp only [labelsOf, List.range_succ_eq_map (n:=w), List.map_cons, List.tail_cons,
      List.map_map, Function.comp_def, Nat.succ_eq_add_one, norm, head]
  apply List.mem_flatMap.mpr
  refine ⟨labelsOf w a, leftWord, List.mem_filterMap.mpr ⟨a w, List.mem_range.mpr last, ?_⟩⟩
  simp [endWord, tailWord, rightWord]

/-- `classify_step` with packed certificates. -/
theorem classify_stepFast {w m : Nat} {previous remaining : List (List Nat)} {cs : List FastCert}
    (hw : 0 < w) (hm : 0 < m)
    (prev : Classifies w m previous)
    (certs : cs.all (checkFast (w+1) m) = true)
    (complete : ruledOut m previous remaining = cs.map FastCert.labels) :
    Classifies (w+1) m remaining := by
  intro a ha zero
  rcases prev a (fun j h => ha j (by omega)) zero with good | leftWord
  · exact Or.inl (good_of_slice (k:=0) (v:=w) (w:=w+1) (by omega) (by simpa using good))
  have ha1 := ha 1 (by omega)
  let b (j : Nat) := rotate m (a 1) (a (j+1))
  have hb : Valid w m b := fun j hj => rotate_lt ha1 (ha (j+1) (by omega))
  have b0 : b 0 = 0 := by simp [b, rotate]
  rcases prev b hb b0 with good | rightWord
  · have good' := good_of_rotated ha1 (fun j hj => ha (1+j) (by omega))
      (show Good w m (fun j => rotate m (a 1) (a (1+j))) by simpa [b, Nat.add_comm] using good)
    exact Or.inl (good_of_slice (k:=1) (w:=w+1) (by omega) good')
  by_cases bad : labelsOf (w+1) a ∈ remaining
  · exact Or.inr bad
  have h := phase_extendF hw leftWord rightWord (ha w (by omega))
  have member : labelsOf (w+1) a ∈ ruledOut m previous remaining := by
    unfold ruledOut
    exact List.mem_filter.mpr ⟨h, by simp [List.contains_eq_mem, bad]⟩
  rw [complete] at member
  obtain ⟨c, hc, eq⟩ := List.mem_map.mp member
  exact Or.inl (good_congr (sound_labelF eq) (good_of_checkFast hm (List.all_eq_true.mp certs c hc)))


/-! ### Coverage with raw comparisons -/

/-- List equality on `Nat` lists with `Nat.beq`. -/
noncomputable def listBeq : List Nat → List Nat → Bool :=
  List.rec (motive := fun _ => List Nat → Bool)
    (fun ys => List.rec (motive := fun _ => Bool) true (fun _ _ _ => false) ys)
    (fun x _ ih ys => List.rec (motive := fun _ => Bool) false (fun y ys' _ => Nat.beq x y && ih ys') ys)

theorem listBeq_eq : ∀ (xs ys : List Nat), listBeq xs ys = (xs == ys)
  | [], [] => rfl
  | [], _ :: _ => rfl
  | _ :: _, [] => rfl
  | x :: xs, y :: ys => by
    show (Nat.beq x y && listBeq xs ys) = (x :: xs == y :: ys)
    rw [listBeq_eq xs ys]
    simp only [List.cons_beq_cons]
    congr 1

/-- `List.contains` on lists of `Nat` lists with raw comparisons. -/
noncomputable def containsFast (bad : List (List Nat)) (x : List Nat) : Bool :=
  List.rec (motive := fun _ => Bool) false (fun hd _ ih => listBeq hd x || ih) bad

theorem containsFast_eq : ∀ (bad : List (List Nat)) (x : List Nat), containsFast bad x = bad.contains x
  | [], _ => rfl
  | hd :: tl, x => by
    show (listBeq hd x || containsFast tl x) = (hd :: tl).contains x
    rw [listBeq_eq, containsFast_eq tl x, List.contains_cons]
    cases h : hd == x <;> cases h' : x == hd <;> simp_all [beq_iff_eq] <;> first | (subst_vars; simp_all) | skip

def rotateFast (m q r : Nat) : Nat := cond (Nat.ble q r) (Nat.sub r q) (Nat.add r (Nat.sub m q))

theorem rotateFast_eq (m q r : Nat) : rotateFast m q r = rotate m q r := by
  unfold rotateFast rotate
  by_cases h : q ≤ r
  · have : Nat.ble q r = true := Nat.ble_eq.mpr h
    simp [this, h, raw_sub]
  · have : Nat.ble q r = false := by
      cases e : Nat.ble q r
      · rfl
      · exact absurd (Nat.ble_eq.mp e) h
    simp [this, h, raw_sub, raw_add]

noncomputable def extendFast (m : Nat) (bad : List (List Nat)) : List (List Nat) :=
  bad.flatMap fun xs => (List.range m).filterMap fun p =>
    let ys := xs ++ [p]
    if containsFast bad (ys.tail.map (rotateFast m (ys.tail.headD 0))) then some ys else none

noncomputable def ruledOutFast (m : Nat) (previous remaining : List (List Nat)) : List (List Nat) :=
  (extendFast m previous).filter (fun xs => !(containsFast remaining xs))

theorem ruledOutFast_eq (m : Nat) (previous remaining : List (List Nat)) :
    ruledOutFast m previous remaining = ruledOut m previous remaining := by
  have hr : rotateFast m = rotate m := funext fun q => funext fun r => rotateFast_eq m q r
  unfold ruledOutFast ruledOut extendFast extend norm
  simp only [containsFast_eq, hr]

end PhaseFalls.Moduli

/-! ## FastData3 -/

/-! Generated by build_modulus_tables.py and repacked for `checkFast`. The kernel checks the rank tables and the coverage of the phase assignments. -/
namespace PhaseFalls.Moduli.Data3
set_option maxRecDepth 80000
set_option maxHeartbeats 0

private def rest3 : List (List Nat) := [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 1, 2], [0, 2, 0], [0, 2, 1], [0, 2, 2]]
private def group3_0 : List FastCert := [
  ⟨[0, 1, 0], 0x410850c40060c00810c4146004083004146, 0x5150f02a382d8⟩,
  ⟨[0, 1, 1], 0x410820c40060040810c4146001086004146, 0x5150f0547b2f8⟩,
]
private theorem group3_0_ok : group3_0.all (checkFast 3 3) = true := by decide +kernel
private def certs3 := group3_0
private theorem valid3 : certs3.all (checkFast 3 3) = true := by exact group3_0_ok
private theorem cover3 : ruledOut 3 (pairs 3) rest3 = certs3.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class3 : Classifies 3 3 rest3 :=
  classify_stepFast (by decide) (by decide) (pairs_classify 3) valid3 cover3

private def rest4 : List (List Nat) := [[0, 0, 0, 0], [0, 0, 0, 2], [0, 0, 2, 0], [0, 0, 2, 1], [0, 0, 2, 2]]
private def group4_0 : List FastCert := [
  ⟨[0, 0, 0, 1], 0x4108218200010a0c91871451030020411451030001071890000421452081081870c7, 0x2200a01260c2a8c454a13b1⟩,
  ⟨[0, 0, 1, 2], 0x410820820000410c31040c30410020820c30410001040000410820c20000451040c4, 0x270d4aa3b9⟩,
  ⟨[0, 1, 2, 0], 0xc20440020450c21040020460001040421860001041431860421040020c5042104000146, 0x44351e4541f0e9⟩,
  ⟨[0, 2, 0, 1], 0xc40421850001081c70c70411010020851861030001c71860c40020451861080070c7, 0x11e401514454ae5a9⟩,
  ⟨[0, 2, 1, 0], 0xc70421470001471840c80410410021481061430001c81021460020411021460070c8, 0x18701517844542e5a9⟩,
  ⟨[0, 2, 1, 1], 0x850c40860000850c10860c30810040850c40810001460410860040c3041086004146, 0x2035070aa1b3a9⟩,
  ⟨[0, 2, 1, 2], 0x1470421040001471860c70410410021072081430001871020c40020411821490080c7, 0x6900265515a44542e5a9⟩,
  ⟨[0, 2, 2, 0], 0x1040411450821071860c60000c3041045000103082186145104001043145104000086, 0x8335120e86a5e9⟩,
  ⟨[0, 2, 2, 1], 0xc30411440820c71861060000c30410440000c30821861450c30010441450c3000086, 0x83201a8e86a5e9⟩,
  ⟨[0, 2, 2, 2], 0x801470411040821471860c70000c3041107000143082187104104001043186145000087, 0x266a35a20e86a5e9⟩,
]
private theorem group4_0_ok : group4_0.all (checkFast 4 3) = true := by decide +kernel
private def certs4 := group4_0
private theorem valid4 : certs4.all (checkFast 4 3) = true := by exact group4_0_ok
private theorem cover4 : ruledOut 3 (rest3) rest4 = certs4.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class4 : Classifies 4 3 rest4 :=
  classify_stepFast (by decide) (by decide) class3 valid4 cover4

private def rest5 : List (List Nat) := [[0, 0, 0, 0, 2], [0, 0, 0, 2, 0], [0, 0, 0, 2, 1], [0, 0, 0, 2, 2]]
private def group5_0 : List FastCert := [
  ⟨[0, 0, 0, 0, 0], 0x411450c300008610a0c40000411472460000881070c60c30820000410c30820001440c30820070410c30820001062070860c71041450850c30012070860c71041470850c3006, 0x4010018a8002141234d4603a1⟩,
]
private theorem group5_0_ok : group5_0.all (checkFast 5 3) = true := by decide +kernel
private def certs5 := group5_0
private theorem valid5 : certs5.all (checkFast 5 3) = true := by exact group5_0_ok
private theorem cover5 : ruledOut 3 (rest4) rest5 = certs5.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class5 : Classifies 5 3 rest5 :=
  classify_stepFast (by decide) (by decide) class4 valid5 cover5

private def rest6 : List (List Nat) := []
private def group6_0 : List FastCert := [
  ⟨[0, 0, 0, 0, 2, 0], 0x410411451450000000c30c30410411052080001c908a0820410411452080001c90ca2080410411052080001c90860830820820820820410410000001041041051040410410000c30820820820820411c10031881041041051040410410000c32081c71451452081c20820822081c71451451041040410002081c71451452081c20820822061c6145145106104041003, 0x4000019a8892a4a3011cf4482⟩,
  ⟨[0, 0, 0, 0, 2, 1], 0x410410c30830000001040840410410c81430000861090840410410c814300008a1041490410410c80830000861091062490852080850410810030c51c70851c80850410410001042490852080850410810030c51c70851c80850410410001060410411480881490890000001010411482081491890c30c604104114808814908914b28a1440811482881491870c3006, 0x8404d5521180d301a812a37482⟩,
  ⟨[0, 0, 0, 0, 2, 2], 0x4104114524900020b08c0820410411051c700020b08608204104114524900020b08c0820410410c324b00020a0860831861861451450410410000001041041051040410410000821861861451450412010021c90c30c30c50c304104100008324920b0820821861860000001c71c714514518618604100024920a08208224620628a20a2432031451c7106104041003, 0x1000003032a8659aaa4a30204b4482⟩,
]
private theorem group6_0_ok : group6_0.all (checkFast 6 3) = true := by decide +kernel
private def certs6 := group6_0
private theorem valid6 : certs6.all (checkFast 6 3) = true := by exact group6_0_ok
private theorem cover6 : ruledOut 3 (rest5) rest6 = certs6.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class6 : Classifies 6 3 rest6 :=
  classify_stepFast (by decide) (by decide) class5 valid6 cover6

theorem good3 {a : Nat → Nat} (ha : Valid 6 3 a) : Good 6 3 a :=
  of_empty class6 ha
end PhaseFalls.Moduli.Data3

namespace PhaseFalls.Moduli
export Data3 (good3)
end PhaseFalls.Moduli

/-! ## FastData4 -/

/-! Generated by build_modulus_tables.py and repacked for `checkFast`. The kernel checks the rank tables and the coverage of the phase assignments. -/
namespace PhaseFalls.Moduli.Data4
set_option maxRecDepth 80000
set_option maxHeartbeats 0

private def rest3 : List (List Nat) := [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 0, 3], [0, 1, 2], [0, 2, 2], [0, 3, 0], [0, 3, 1], [0, 3, 2], [0, 3, 3]]
private def group3_0 : List FastCert := [
  ⟨[0, 1, 0], 0x10850040860410850c40060c00810c4146004083004146, 0x145503c0aa3e0ed8⟩,
  ⟨[0, 1, 1], 0x10830040860410850c40060040810c4146001086004146, 0x145503c0aa3ecef8⟩,
  ⟨[0, 1, 3], 0x40820040460410850c40060c00810c4146001083004146, 0x145503c1544eced8⟩,
  ⟨[0, 2, 0], 0x10c60050870400c31050870010c20051070050c1005187, 0x22a81a0aa2a02e0778⟩,
  ⟨[0, 2, 1], 0x430820440060400860c41460040810040c6001086004146, 0x44550b41547c8378⟩,
  ⟨[0, 2, 3], 0x40820040460400860c41460010820040c6001082004146, 0x44550341545e8778⟩,
]
private theorem group3_0_ok : group3_0.all (checkFast 3 4) = true := by decide +kernel
private def certs3 := group3_0
private theorem valid3 : certs3.all (checkFast 3 4) = true := by exact group3_0_ok
private theorem cover3 : ruledOut 4 (pairs 4) rest3 = certs3.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class3 : Classifies 3 4 rest3 :=
  classify_stepFast (by decide) (by decide) (pairs_classify 4) valid3 cover3

private def rest4 : List (List Nat) := [[0, 0, 0, 0], [0, 0, 0, 3], [0, 0, 2, 2], [0, 0, 3, 2], [0, 3, 2, 0], [0, 3, 2, 1], [0, 3, 2, 2], [0, 3, 2, 3]]
private def group4_0 : List FastCert := [
  ⟨[0, 0, 0, 1], 0x410410021820c310a0091870000410820820001041450c71451030020411451030001871890000421452081081870c7, 0x20800a0048e070d51c8354be93b1⟩,
  ⟨[0, 0, 0, 2], 0x410821020000480c71050000410820820000411050c50c30410020820c30410001051070000820c21860461050c5, 0x820028013b84c354aa8fb1⟩,
  ⟨[0, 0, 1, 2], 0x410821020000470c61050000410820820000411050c50c30410020820c60410001051060000820c21060471060c5, 0x1140013b84c354aa8fb1⟩,
  ⟨[0, 0, 3, 0], 0x410410020860c81440001870000410820820001491080c71040c30020411041430001870001450421030001451860c7, 0x500000026a8ce1c8354be93b9⟩,
  ⟨[0, 0, 3, 1], 0x410410021820c810a0091870000410820820001091480c71451030020411451030001871890000421451881081870c7, 0x20820a0048e070aa8d1154be93b1⟩,
  ⟨[0, 0, 3, 3], 0xc91470021810c91470091880000410820c700014a0890c81040c30020411041430001481870000421031871481870c8, 0x28000002086154061c82aa484bb1⟩,
  ⟨[0, 1, 2, 3], 0x421040020c50421040000c60c20440020450c21040020460420000421860421041431860000c40420c5000104042146, 0x410d517915437c2d9⟩,
  ⟨[0, 2, 2, 0], 0xc30c30010461041440000870000c30411460821461c41070c30c30010461041440021c70001440410c3000148086087, 0x40415423afe420aa93b9⟩,
  ⟨[0, 2, 2, 1], 0x1450c30010441450c30000860000c30411440820c71861061040c30010451040c30021860000c30411040000c7085086, 0xb04861aa220aa93b9⟩,
  ⟨[0, 2, 2, 2], 0x1040c30010451041830000880801850411030821851c70c81040c30011471041830021c80001450411030001850870c8, 0x112aa088e618826a6a93b9⟩,
  ⟨[0, 2, 2, 3], 0xc31430010441861460000870001040411460821481c70c70c30c30010461041440021c70001040410c3000148086087, 0x4d09545bace420aa93b9⟩,
  ⟨[0, 3, 0, 1], 0x1c90000421851c91081c90c80000c40421c100010a0891c80411010021451861030001481860c40020451861080070c8, 0x280000d201e400d51510aa6b95a9⟩,
  ⟨[0, 3, 1, 1], 0xc40421850001081c70c70000c40420850001040411c70411030020850461030001471860c40020451861080070c7, 0x41e400d5151154970fa9⟩,
  ⟨[0, 3, 3, 0], 0xc20c30421451c71071860060000c30421450001081871860410410021450c21030001861421040020411421040030c6, 0x4040080cd51f45542b91a9⟩,
  ⟨[0, 3, 3, 1], 0x1c90000421851c91081c90c80000c40421c100010a0891c80411010021451861030001481860c40020451861080070c8, 0x280000d201e400d51510aa6b95a9⟩,
  ⟨[0, 3, 3, 2], 0x1c70c50421041c714a1890080001480421c60001480891880410410021c81861430001081040c40020412491470060c8, 0x14c800c229a6a8c1a410aa6b91a9⟩,
  ⟨[0, 3, 3, 3], 0xc81470421040c81471860070000c50420c70001491081870410410021862021430001071020c40020411821490080c7, 0x570000866a8c1ad11542b91a9⟩,
]
private theorem group4_0_ok : group4_0.all (checkFast 4 4) = true := by decide +kernel
private def certs4 := group4_0
private theorem valid4 : certs4.all (checkFast 4 4) = true := by exact group4_0_ok
private theorem cover4 : ruledOut 4 (rest3) rest4 = certs4.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class4 : Classifies 4 4 rest4 :=
  classify_stepFast (by decide) (by decide) class3 valid4 cover4

private def rest5 : List (List Nat) := [[0, 0, 0, 0, 3], [0, 0, 3, 2, 0], [0, 0, 3, 2, 1], [0, 0, 3, 2, 2], [0, 0, 3, 2, 3]]
private def group5_0 : List FastCert := [
  ⟨[0, 0, 0, 0, 0], 0x2060820000411c608b0090c420608200628a1450870090c50000411040c300008810a0c30000411062430000881070c50c30820000410c30820001040c30820060410c30820001051c60870c61042060880c30011c60870c61041460850c3005, 0x2064068a435540018810d354480ba1⟩,
  ⟨[0, 0, 0, 3, 2], 0x1040820410001040890450c01040860451c31040890480c70000411051860000881040c30000411051860000881040c70c30820000410c30820001060c30820050410c30820001071040820c30001840860c30011040820c51c71050860c3007, 0x400003c2aa86990d3545809a1⟩,
  ⟨[0, 3, 2, 1, 0], 0xc30c30000002081450820860c30c30012491041041870870c30c300000008214a0461860c30c30012490821040481870000000411041861450430820001450412081861450420870820820010061041480410c40820820010061c71450470c7, 0xe910060caa8873f0426954d72⟩,
  ⟨[0, 3, 2, 1, 1], 0xc30c30000001c71450820820c30c30012491041041880860c30c30000000821490461860c30c30012080821040471860001040411041c71450430820001450412081c71450420860820820000001041480410c40820820010092081450470c6, 0x8094add200aa8873f0426954d72⟩,
  ⟨[0, 3, 2, 1, 2], 0xc30c30000002081450820820c30c30012891041041860870c30c30011860821490481860c30c30011860821040481870000000411042081450430860001450411861c71450420870820820000001041490410c40820820010091861450480c7, 0x800006e9006866a8873f0426954d72⟩,
  ⟨[0, 3, 2, 1, 3], 0xc30c30011041c71450820820c30c30012491c71451880860c30c30000000821490461860c30c30012080821040471860000000411041c71450430820001450412081c71450420860820820000001041480410c40820820010092081450470c6, 0x8094add200aa8e73f0426954d72⟩,
]
private theorem group5_0_ok : group5_0.all (checkFast 5 4) = true := by decide +kernel
private def certs5 := group5_0
private theorem valid5 : certs5.all (checkFast 5 4) = true := by exact group5_0_ok
private theorem cover5 : ruledOut 4 (rest4) rest5 = certs5.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class5 : Classifies 5 4 rest5 :=
  classify_stepFast (by decide) (by decide) class4 valid5 cover5

private def rest6 : List (List Nat) := []
private def certs6 := ([] : List FastCert)
private theorem valid6 : certs6.all (checkFast 6 4) = true := by rfl
private theorem cover6 : ruledOut 4 (rest5) rest6 = certs6.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class6 : Classifies 6 4 rest6 :=
  classify_stepFast (by decide) (by decide) class5 valid6 cover6

theorem good4 {a : Nat → Nat} (ha : Valid 6 4 a) : Good 6 4 a :=
  of_empty class6 ha
end PhaseFalls.Moduli.Data4

namespace PhaseFalls.Moduli
export Data4 (good4)
end PhaseFalls.Moduli

/-! ## FastData5 -/

/-! Generated by build_modulus_tables.py and repacked for `checkFast`. The kernel checks the rank tables and the coverage of the phase assignments. -/
namespace PhaseFalls.Moduli.Data5
set_option maxRecDepth 80000
set_option maxHeartbeats 0

private def rest3 : List (List Nat) := [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 0, 3], [0, 0, 4], [0, 1, 2], [0, 2, 2], [0, 3, 2], [0, 4, 0], [0, 4, 1], [0, 4, 2], [0, 4, 3], [0, 4, 4]]
private def group3_0 : List FastCert := [
  ⟨[0, 1, 0], 0x10850040860010830040860410850c40060c00810c4146004083004146, 0x515500f02aa3f83ed8⟩,
  ⟨[0, 1, 1], 0x10830040860010830040860410850c40060040810c4146001086004146, 0x515500f02aa3fb3ef8⟩,
  ⟨[0, 1, 3], 0x10830040860040830040460410850c40060c00810c4146001083004146, 0x515500f02aa33b3ed8⟩,
  ⟨[0, 1, 4], 0x40820040460010850040c60410820c40060c00810c4146001083004146, 0x515501f05544fb3ed8⟩,
  ⟨[0, 2, 0], 0x10c60050870010c30050870400c31050870010c20051070050c1005187, 0x22aa01a0aa8aa02b81f78⟩,
  ⟨[0, 2, 1], 0x10830040860430850440060400850c40860040810040c6001086004146, 0x115502d02aa2f21b78⟩,
  ⟨[0, 2, 3], 0x10820040c60040820040460400860c41460010820040c6001082004146, 0x1115504d055467a1f78⟩,
  ⟨[0, 2, 4], 0x50c20050470010c60050870400c31050870010c20051070010c2005187, 0x22aa01a0aa88a01ba1f78⟩,
  ⟨[0, 3, 0], 0x10c60050870400c31050870400c20451070010c20051070050c1005187, 0x22aa06a0aa8a802f81d78⟩,
  ⟨[0, 3, 1], 0x10830040860400850c40860010850040c6004081004086001086004146, 0x115503402aa2e21df8⟩,
  ⟨[0, 3, 3], 0x10c30050870850c11050070400c60451070010c20051070010c2005187, 0x22aa06a0aa8b8023a1b78⟩,
  ⟨[0, 3, 4], 0x40820040460400860c41460400820440c60010820040c6001082004146, 0x4115503505545fa1d78⟩,
]
private theorem group3_0_ok : group3_0.all (checkFast 3 5) = true := by decide +kernel
private def certs3 := group3_0
private theorem valid3 : certs3.all (checkFast 3 5) = true := by exact group3_0_ok
private theorem cover3 : ruledOut 5 (pairs 5) rest3 = certs3.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class3 : Classifies 3 5 rest3 :=
  classify_stepFast (by decide) (by decide) (pairs_classify 5) valid3 cover3

private def rest4 : List (List Nat) := [[0, 0, 0, 0], [0, 0, 0, 4], [0, 0, 2, 2], [0, 0, 3, 2], [0, 3, 2, 0], [0, 3, 2, 1], [0, 3, 2, 2], [0, 3, 2, 3], [0, 3, 2, 4]]
private def group4_0 : List FastCert := [
  ⟨[0, 0, 0, 1], 0x410410021820c310a0091870410410020821451040060c70000410820820001061450c71451030020411451030001871890000421452081081870c7, 0x202000a00130e0dc3551c20d54bfa4bb1⟩,
  ⟨[0, 0, 0, 2], 0x1470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21c50461050c6, 0xa0c0003420eb8470d54aaa37b1⟩,
  ⟨[0, 0, 0, 3], 0xc30410021820c314a0091871041440020c12061450060470000410821060001491c80c71040c30020412061430001c71880000421032481491880c7, 0x1147700013162aa2772c20d54a212bb1⟩,
  ⟨[0, 0, 1, 2], 0x1470000821021470460c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xa000003420eb8470d54aaa37b1⟩,
  ⟨[0, 0, 4, 0], 0x410410020860c81440001870410410020821041490080c70000410820820001451040c71040c30020411041430001870001450421030001451860c7, 0x14000000026aa36e1c20d54bfa4bb9⟩,
  ⟨[0, 0, 4, 1], 0x410410021820c810a0091870410410020821451090080c70000410820820001061450c71451030020411451030001871890000421451881081870c7, 0x202080a00120e0dc2aa8d44554bfa4bb1⟩,
  ⟨[0, 0, 4, 2], 0x1470000821021470460c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xa000003420eb8470d54aaa37b1⟩,
  ⟨[0, 0, 4, 3], 0xc30410021820c71490071881041470020c11041470080480000410821070001451880c81040c30020411041430001881870000421031871451870c8, 0x280826e2aa2661c20d54a212bb1⟩,
  ⟨[0, 0, 4, 4], 0xc91470021810c91470091880410410020c710414a0090c80000410820820001461040c81040c30020411041430001481870000421031871481870c8, 0x280000000820615506e1c20d54afa4bb1⟩,
  ⟨[0, 1, 2, 3], 0xc30421850001080471470421040020c30421040000c70c20440020450c21040020470420000421860421041431871820440020c3182104002147, 0x100640435518d0d543dd1ac9⟩,
  ⟨[0, 2, 2, 0], 0xc30411060001490880870c30c30010442061480000870000c30411460821491c81070c30c30010461041440021c71041440010c3206148006087, 0x20a001104155143aff9020aaa5ba9⟩,
  ⟨[0, 2, 2, 1], 0xc30411440000c70860861450c30010441450c30000860000c30411440820c71861061040c30010451040c30021861450c30011041450c7006086, 0x8c32061aa8820aaa5ba9⟩,
  ⟨[0, 2, 2, 2], 0x1450411040001880870c80c30c30010451041840000880801850411040821851c70c80c30c30011471041840021c81041040010c31c7186005088, 0x44cd54621333a3392686aa5ba9⟩,
  ⟨[0, 2, 2, 3], 0xc30411040001490880871041440010432061480000870001040411460821491c80c70c30c30010461041440021c71041040010c3206148006087, 0x20a00110415517bae39020aaa5ba9⟩,
  ⟨[0, 2, 2, 4], 0x1850411040001860870880c30c30010471041840000880000c30411450821861c41080c30c30010451041840021c81041040010c3145185007088, 0x8d8554729523a3f9020aaa5ba9⟩,
  ⟨[0, 4, 0, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000d0805e4d03551644554aee53a9⟩,
  ⟨[0, 4, 1, 1], 0x1c90000421851c91081c90c80000c40421c200010a0491c80000c40420850001040410c80411030020850461030001481860c40020451861080070c8, 0x2800000d0801e400355154455495c37a9⟩,
  ⟨[0, 4, 2, 1], 0xc40421850001081c70c71820410020c51821010001c70410c40021850421080070c70411030021450411030021471820c40020451821040020c7, 0x13a600035515445541bc3aa9⟩,
  ⟨[0, 4, 3, 0], 0xc20c30421452021071860070410410020c31481090081870000c30420410001091481470410410021860c21030001471421040020411821040030c7, 0x1d000002066435551ed15542ee43a9⟩,
  ⟨[0, 4, 3, 1], 0x1c90000421851c91081c90c80410410021c20c910a0091c80000c404204100010a1490c80411010020851861030001481860c40020451861080070c8, 0x2a00000d0801e4103551744554aee53a9⟩,
  ⟨[0, 4, 3, 2], 0x1c70c50421041c71481860090410410021c60c814a0081890001480420410001480890c90410410021881c71430001091040c40020411861480070c9, 0x4400c34a066aa301a7442aa6ee43a9⟩,
  ⟨[0, 4, 3, 3], 0x1c20c50421041c21481860080491480021c60c91480091880000c504204800014a1090c80410410021861c21430001081020c40020411821480070c8, 0xa00000d382066aa301a7445542ee43a9⟩,
  ⟨[0, 4, 3, 4], 0xc21470421040c21471860070410410020c71081440061870000c50420410001491080c70410410021862021430001071020c40020411821490080c7, 0x570000012aaa321ad445542ee43a9⟩,
  ⟨[0, 4, 4, 0], 0xc20c30421452081071860070410410020c31421090081870000c30420410001061451470410410021860c21030001471421040020411821040030c7, 0x1a010002466435551ed15542ee43a9⟩,
]
private theorem group4_0_ok : group4_0.all (checkFast 4 5) = true := by decide +kernel
private def group4_1 : List FastCert := [
  ⟨[0, 4, 4, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000d0805e4d03551644554aee53a9⟩,
  ⟨[0, 4, 4, 2], 0x1c70c50421041c71481860080410410021c61031480091880001440420410001450860c80410410021861c71430001081040c40020411861480070c8, 0x800000c34a266aa339a6442aa6ee43a9⟩,
  ⟨[0, 4, 4, 3], 0x1c20c50421041c71481890080411480021c60c21480091880000c50420480001451040c80410410021861021430001881020c40020411c21450060c8, 0x2800000c0ca026aa303a7445542ee43a9⟩,
  ⟨[0, 4, 4, 4], 0xc81470421040c81471860070410410020c71021490081870000c50420410001451040c70410410021862021430001071020c40020411821490080c7, 0x14700002066aa321ad445542ee43a9⟩,
]
private theorem group4_1_ok : group4_1.all (checkFast 4 5) = true := by decide +kernel
private def certs4 := group4_0 ++ group4_1
private theorem valid4 : certs4.all (checkFast 4 5) = true := by simp only [certs4, List.all_append, group4_0_ok, group4_1_ok, Bool.and_true]
private theorem cover4 : ruledOut 5 (rest3) rest4 = certs4.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class4 : Classifies 4 5 rest4 :=
  classify_stepFast (by decide) (by decide) class3 valid4 cover4

private def rest5 : List (List Nat) := [[0, 0, 0, 0, 4], [0, 0, 3, 2, 0], [0, 0, 3, 2, 1], [0, 0, 3, 2, 2], [0, 0, 3, 2, 3], [0, 0, 3, 2, 4]]
private def group5_0 : List FastCert := [
  ⟨[0, 0, 0, 0, 0], 0x2060820000411c608b0090c420608200628a1450870090c51040820c300010408804a0011040820c62491040880470050000411040c30000881040c30000411061c30000851040c50c30820000410c30820001040c30820060410c30820001051c60870c61042060880c30011c60870c61041460850c3005, 0x805003a8a48d5540006681134d5463849a1⟩,
]
private theorem group5_0_ok : group5_0.all (checkFast 5 5) = true := by decide +kernel
private def certs5 := group5_0
private theorem valid5 : certs5.all (checkFast 5 5) = true := by exact group5_0_ok
private theorem cover5 : ruledOut 5 (rest4) rest5 = certs5.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class5 : Classifies 5 5 rest5 :=
  classify_stepFast (by decide) (by decide) class4 valid5 cover5

private def rest6 : List (List Nat) := []
private def certs6 := ([] : List FastCert)
private theorem valid6 : certs6.all (checkFast 6 5) = true := by rfl
private theorem cover6 : ruledOut 5 (rest5) rest6 = certs6.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class6 : Classifies 6 5 rest6 :=
  classify_stepFast (by decide) (by decide) class5 valid6 cover6

theorem good5 {a : Nat → Nat} (ha : Valid 6 5 a) : Good 6 5 a :=
  of_empty class6 ha
end PhaseFalls.Moduli.Data5

namespace PhaseFalls.Moduli
export Data5 (good5)
end PhaseFalls.Moduli

/-! ## FastData7 -/

/-! Generated by build_modulus_tables.py and repacked for `checkFast`. The kernel checks the rank tables and the coverage of the phase assignments. -/
namespace PhaseFalls.Moduli.Data7
set_option maxRecDepth 80000
set_option maxHeartbeats 0

private def rest3 : List (List Nat) := [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 0, 3], [0, 0, 4], [0, 0, 5], [0, 0, 6], [0, 1, 2], [0, 2, 2], [0, 3, 2], [0, 4, 2], [0, 5, 2], [0, 6, 0], [0, 6, 1], [0, 6, 2], [0, 6, 3], [0, 6, 4], [0, 6, 5], [0, 6, 6]]
private def group3_0 : List FastCert := [
  ⟨[0, 1, 0], 0x10850040860010830040860010830040860010830040860410850c40060c00810c4146004083004146, 0x51555000f02aaa3ff83fed8⟩,
  ⟨[0, 1, 1], 0x10830040860010830040860010830040860010830040860410850c40060040810c4146001086004146, 0x51555000f02aaa3ffb3fef8⟩,
  ⟨[0, 1, 3], 0x10830040860010830040860010830040860040830040460410850c40060c00810c4146001083004146, 0x51555000f02aaa3f3b3fed8⟩,
  ⟨[0, 1, 4], 0x10830040860010830040860040830040460010850040860410850c40060c00810c4146001083004146, 0x51555000f02aaa3cfb3fed8⟩,
  ⟨[0, 1, 5], 0x10830040860040830040460010850040860010830040860410850c40060c00810c4146001083004146, 0x51555000f02aaa33fb3fed8⟩,
  ⟨[0, 1, 6], 0x40820040460010850040c60010820040c60010820040c60410820c40060c00810c4146001083004146, 0x51555015f055544ffb3fed8⟩,
  ⟨[0, 2, 0], 0x10c60050870010c30050870010c30050870010c30050870400c31050870010c20051070050c1005187, 0x22aaa001a0aaa8aaa02ab81ff78⟩,
  ⟨[0, 2, 1], 0x10830040860010830040860010830040860430850440060400850c40860040810040c6001086004146, 0x11555002d02aaa2af21fb78⟩,
  ⟨[0, 2, 3], 0x10820040c60010820040c60010820040c60040820040460400860c41460010820040c6001082004146, 0x111555054d055546a7a1ff78⟩,
  ⟨[0, 2, 4], 0x10c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c2005187, 0x22aaa001a0aaa8a8a029ba1ff78⟩,
  ⟨[0, 2, 5], 0x10c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c2005187, 0x22aaa001a0aaa8a2a026ba1ff78⟩,
  ⟨[0, 2, 6], 0x50c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaa001a0aaa88aa01aba1ff78⟩,
  ⟨[0, 3, 0], 0x10c60050870010c30050870010c30050870400c31050870400c20451070010c20051070050c1005187, 0x22aaa006a0aaa8aa802af81fd78⟩,
  ⟨[0, 3, 1], 0x10830040860010830040860010830040860400850c40860010850040c6004081004086001086004146, 0x11555003402aaa2ae21fdf8⟩,
  ⟨[0, 3, 3], 0x10c30050870010c30050870010c30050870850c11050070400c60451070010c20051070010c2005187, 0x22aaa006a0aaa8ab802a3a1fb78⟩,
  ⟨[0, 3, 4], 0x10820040c60010820040c60040820040460400860c41460400820440c60010820040c6001082004146, 0x41155505350555469fa1fd78⟩,
  ⟨[0, 3, 5], 0x10c30050870050c20050470010c60050870400c31050870400c20451070010c20051070010c2005187, 0x22aaa006a0aaa8a28026fa1fd78⟩,
  ⟨[0, 3, 6], 0x50c20050470010c60050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaa006a0aaa88a801afa1fd78⟩,
  ⟨[0, 4, 0], 0x10c60050870010c30050870400c31050870010c20051070400c30450870010c20051070050c1005187, 0x22aaa01a20aaa8aa202bb81f778⟩,
  ⟨[0, 4, 1], 0x10830040860010830040860400850c40860010850040c6001083004086004081004086001086004146, 0x1155500d002aaa2ba21f7f8⟩,
  ⟨[0, 4, 3], 0x10c30050870010c30050870400c31050870050c10051070400c60450870010c20051070010c2005187, 0x22aaa01a20aaa8aa202b3a1f778⟩,
  ⟨[0, 4, 4], 0x10c30050870010c30050870850c11050070010c60051070400c30450870010c20051070010c2005187, 0x22aaa01a20aaa8ae2028ba1ef78⟩,
  ⟨[0, 4, 5], 0x10820040c60040820040460400860c41460010820040c60400820440c60010820040c6001082004146, 0x101155504d50555467ba1f778⟩,
  ⟨[0, 4, 6], 0x50c20050470010c60050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaa01a20aaa88a201bba1f778⟩,
]
private theorem group3_0_ok : group3_0.all (checkFast 3 7) = true := by decide +kernel
private def group3_1 : List FastCert := [
  ⟨[0, 5, 0], 0x10c60050870400c31050870010c20051070010c30050870400c30450870010c20051070050c1005187, 0x22aaa06820aaa8a8a02eb81df78⟩,
  ⟨[0, 5, 1], 0x10830040860400850c40860010850040c6001083004086001083004086004081004086001086004146, 0x11555034002aaa2ea21dff8⟩,
  ⟨[0, 5, 3], 0x10c30050870400c31050870010c20051070050c20050470400c60450870010c20051070010c2005187, 0x22aaa06820aaa8a8202e7a1df78⟩,
  ⟨[0, 5, 4], 0x10c30050870400c31050870050c10051070010c60050870400c30450870010c20051070010c2005187, 0x22aaa06820aaa8a8a02cba1df78⟩,
  ⟨[0, 5, 5], 0x10c30050870850c11050070010c60051070010c30050870400c30450870010c20051070010c2005187, 0x22aaa06820aaa8b8a022ba1bf78⟩,
  ⟨[0, 5, 6], 0x40820040460400860c41460010820040c60010820040c60400820440c60010820040c6001082004146, 0x40115550355055545eba1df78⟩,
]
private theorem group3_1_ok : group3_1.all (checkFast 3 7) = true := by decide +kernel
private def certs3 := group3_0 ++ group3_1
private theorem valid3 : certs3.all (checkFast 3 7) = true := by simp only [certs3, List.all_append, group3_0_ok, group3_1_ok, Bool.and_true]
private theorem cover3 : ruledOut 7 (pairs 7) rest3 = certs3.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class3 : Classifies 3 7 rest3 :=
  classify_stepFast (by decide) (by decide) (pairs_classify 7) valid3 cover3

private def rest4 : List (List Nat) := [[0, 0, 0, 0], [0, 0, 0, 6], [0, 0, 2, 2], [0, 0, 3, 2], [0, 3, 2, 0], [0, 3, 2, 1], [0, 3, 2, 2], [0, 3, 2, 3], [0, 3, 2, 4], [0, 3, 2, 5], [0, 3, 2, 6]]
private def group4_0 : List FastCert := [
  ⟨[0, 0, 0, 1], 0x410410021820c310a0091870410410020821451040060c70410410020821451080060c70410410020821451080060c70000410820820001061450c71451030020411451030001871890000421452081081870c7, 0x200200a0a0001350e0fdc35551c020d554bffa4abb1⟩,
  ⟨[0, 0, 0, 2], 0x1470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21c50461050c6, 0xaa0c000037420eeb84470d554aaaa357b1⟩,
  ⟨[0, 0, 0, 3], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70c31440020820c31440060470000410820c60001461040c71040c30020411041430001471890000421032081481870c7, 0x20020280a00013506155507ce1c320d554bf3a4abb1⟩,
  ⟨[0, 0, 0, 4], 0x410410021820c314a0091870410410020821041480060c70c31440020820c31440060470410410020c61041460070c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20020200a000134061555076e1cc20d554bcfa4abb1⟩,
  ⟨[0, 0, 0, 5], 0xc30410021820c314a0091881041440020c11c61450060481c70410021061c71480090c81040410021c224614800a0c800004108210200014a1890c81040c30020411c71430001881890000421032491481870c8, 0x10011d3200003c34b16e2aaa27772c020d554a2a12abb1⟩,
  ⟨[0, 0, 1, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaa00000037420eeb84470d554aaaa357b1⟩,
  ⟨[0, 0, 4, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaa00000037420eeb84470d554aaaa357b1⟩,
  ⟨[0, 0, 5, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaa00000037420eeb84470d554aaaa357b1⟩,
  ⟨[0, 0, 6, 0], 0x410410020860c81440001870410410020821041490080c70410410020821041450060c70410410020821041450060c70000410820820001451040c71040c30020411041430001870001450421030001451860c7, 0x14000000002826aaa37ee1c020d554bffa4abb9⟩,
  ⟨[0, 0, 6, 1], 0x410410021820c810a0091870410410020821451090080c70410410020821451080060c70410410020821451080060c70000410820820001061450c71451030020411451030001871890000421451881081870c7, 0x200208a0a0001250e0fdc2aaa8d5445554bffa4abb1⟩,
  ⟨[0, 0, 6, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaa00000037420eeb84470d554aaaa357b1⟩,
  ⟨[0, 0, 6, 3], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70c31440020820c31440060470000410820c60001461040c71040c30020411041430001471890000421031881481870c7, 0x20020880a00012506155507ce1c320d554bf3a4abb1⟩,
  ⟨[0, 0, 6, 4], 0x410410021820c814a0091870410410020821041490080c70c31440020820c31440060470410410020c61041460070c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20020800a000124061555076e1cc20d554bcfa4abb1⟩,
  ⟨[0, 0, 6, 5], 0xc30410021820c71490071881041470020c11041470080481890410021071891450080c810404100218210414a0090c80000410821020001451870c81040c30020411041430001881870000421031871451870c8, 0x28000002808826ee2aaa26661c020d554a2a12abb1⟩,
  ⟨[0, 0, 6, 6], 0xc91470021810c91470091880410410020c710414a0090c80410410020821041470060c80410410020821041470060c80000410820820001461040c81040c30020411041430001481870000421031871481870c8, 0x28000000000082506155507ee1c020d554affa4abb1⟩,
  ⟨[0, 1, 2, 3], 0x1c20430021851c21090080481420440021c31421090080480000c30421450001070461480421040020c30421040000c80c20440020450c21040020480420000421860421041431881820440020c3182104002148, 0x2d00002064c043555188d0d55417dd0bac9⟩,
  ⟨[0, 2, 2, 0], 0xc30c30011062081480090870820820011042061480090c70000c30411040001490880870c30c30010442061480000870000c30411460821491c81070c30c30010461041440021c71041440010c3206148006087, 0x28000a20a0001110415551543acff91820aaaa4bba9⟩,
  ⟨[0, 2, 2, 1], 0x820820011441c70c70061060820820011041450c80071060000c30411040000c70850861450c30010441450c30000860000c30411440820c71861061040c30010451040c30021861450c30011041450c7006086, 0x444500008dc320061aaa8f820aaaa4bba9⟩,
  ⟨[0, 2, 2, 2], 0xc30c30011041451880070881041040010c31451860070880001450411040001850870c80c30c30010451041840000880801850411040821851c70c80c30c30011471041840021c81041040010c31c7186005088, 0x544cd5547e213733ae33902686aaa4bba9⟩,
  ⟨[0, 2, 2, 3], 0xc30c30011042061480090871041040010c32061480090870000c30411040001490880871041440010432061480000870001040411460821491c80c70c30c30010461041440021c71041040010c3206148006087, 0x28000a20a000151041555177baee390020aaaa4bba9⟩,
  ⟨[0, 2, 2, 4], 0xc30c30011041451880070881041040010c31451860070880001850411040001850870880c30c30010471041840000880000c30411450821861c41080c30c30010451041840021c81041040010c31c7186005088, 0x544cd5547e013723ae3f90020aaaa4bba9⟩,
  ⟨[0, 2, 2, 5], 0xc30c30011041451890070881041850010c31c71860080880000c30411070001890880880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x2704cd5545c685743aeff90020aaaa4bba9⟩,
  ⟨[0, 2, 2, 6], 0xc31850011041c71860080880c30c30011071451890080880000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c3145185007088, 0x2c044d55474695543afff90020aaaa4bba9⟩,
  ⟨[0, 4, 2, 6], 0x411850021040411850070c81020c40020471421860020480000c50421040001851c70c81020410020c52421810001c80410c500210404218a0090c80c20410021450c21840021481020c40020c11421860070c8, 0xe0000004404d5546e233773a5574555431b82baa9⟩,
]
private theorem group4_0_ok : group4_0.all (checkFast 4 7) = true := by decide +kernel
private def group4_1 : List FastCert := [
  ⟨[0, 5, 2, 0], 0x1820c30020451821030020481c20000421831c21091480c80000c30421c50001090481481420410020c31421010000c80410c30021450421070061480c20410021450c21040021480411040020c30411040050c8, 0x23400684004c13555188b0d55405bb2daa9⟩,
  ⟨[0, 6, 0, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000d00802de4fd03555165445554afee52ba9⟩,
  ⟨[0, 6, 1, 1], 0x1c90000421851c91081c90c80c50410021c20c510a0091c81450410020c21451070060c80000c40421420001070460c80000c40420850001040410c80411030020850461030001481860c40020451861080070c8, 0x280000000d008029e4f0035551754455549a5c32fa9⟩,
  ⟨[0, 6, 2, 1], 0x1c20000421851c21081c90c81420410021c31421080091c80000c40421450001070460c81820410020c51821010000c80410c40021850421080070c80411030021450411030021481820c40020451821040020c8, 0x280000000d08025a60c00355514544555419bc33aa9⟩,
  ⟨[0, 6, 3, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821861070050c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000d00806de4dd03555165445554afee52ba9⟩,
  ⟨[0, 6, 4, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821491070060c804104100208214510a0090c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2a8000000d008025e4fd03555165445554afee52ba9⟩,
  ⟨[0, 6, 5, 0], 0xc20c30421452021071860070410410020c31481090081870410410021451821090080c70410410021451821060080c70000c30420410001071461470410410021860c21030001471421040020411821040030c7, 0x1d40000000292a68355551e0d155542fee42ba9⟩,
  ⟨[0, 6, 5, 1], 0x1c90000421851c91081c90c80410410021c20c910a0091c804104100208214510a0090c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2a0000000d00800de43d03555175445554afee52ba9⟩,
  ⟨[0, 6, 5, 2], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80001450420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa0000000c034a0866aaa30a1a75445554afee42ba9⟩,
  ⟨[0, 6, 5, 3], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80c41440020820c61450070480000c50420c60001481070c80410410020861c71430001081040c40020411861480070c8, 0xa0000000c174a1866aaa30e1a77445554af2e42ba9⟩,
  ⟨[0, 6, 5, 4], 0x1c70c50421041c71481860090410410021c60c814a0081890c61480020820c41480090490410410020c81041470060c90000c50420410001451040c90410410020861c71430001091040c40020411861480070c9, 0x44000c234a6866aaa30a1a7d445554acee42ba9⟩,
  ⟨[0, 6, 5, 5], 0x1c20c50421041c21481860080491480021c60c91480091880410410020c810214a0090c80410410020c41821450070c80000c50420410001471060c80410410021861c21430001081020c40020411821480070c8, 0xa0000000d23821a66aaa30c1a754455542fee42ba9⟩,
  ⟨[0, 6, 5, 6], 0xc21470421040c21471860070410410020c71081440061870410410020c41821490080c70410410020c41821460080c70000c50420410001471060c70410410021862021430001071020c40020411821490080c7, 0x547000000292aaaa3341ad54455542fee42ba9⟩,
  ⟨[0, 6, 6, 0], 0xc20c30421452081071860070410410020c31421090081870410410021451821060080c70410410021451821060080c70000c30420410001071461470410410021860c21030001471421040020411821040030c7, 0x1aa0100000292a68355551e0d155542fee42ba9⟩,
  ⟨[0, 6, 6, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000d00802de4fd03555165445554afee52ba9⟩,
  ⟨[0, 6, 6, 2], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80001450420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x80000000c034a2866aaa32a1a65445554afee42ba9⟩,
  ⟨[0, 6, 6, 3], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80c41440020820c61450070480000c50420c60001481070c80410410020861c71430001081040c40020411861480070c8, 0x80000000c174a3866aaa32e1a67445554af2e42ba9⟩,
  ⟨[0, 6, 6, 4], 0x1c70c50421041c71481860080410410021c61031480091880c41440020820c61450070480410410020c61041480070c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x80000000c534a6066aaa33a1a6d445554acee42ba9⟩,
  ⟨[0, 6, 6, 5], 0x1c20c50421041c71481890080411480021c60c21480091880410410020c81021440060c80410410020c41821450070c80000c50420410001471060c80410410021861021430001881020c40020411c21450060c8, 0x280000000c18ca3a26aaa30c3a754455542fee42ba9⟩,
  ⟨[0, 6, 6, 6], 0xc81470421040c81471860070410410020c71021490081870410410020c41821450080c70410410020c41821460080c70000c50420410001471060c70410410021862021430001071020c40020411821490080c7, 0x1547000000292aaaa3341ad54455542fee42ba9⟩,
]
private theorem group4_1_ok : group4_1.all (checkFast 4 7) = true := by decide +kernel
private def certs4 := group4_0 ++ group4_1
private theorem valid4 : certs4.all (checkFast 4 7) = true := by simp only [certs4, List.all_append, group4_0_ok, group4_1_ok, Bool.and_true]
private theorem cover4 : ruledOut 7 (rest3) rest4 = certs4.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class4 : Classifies 4 7 rest4 :=
  classify_stepFast (by decide) (by decide) class3 valid4 cover4

private def rest5 : List (List Nat) := [[0, 0, 0, 0, 6], [0, 0, 3, 2, 0], [0, 0, 3, 2, 1], [0, 0, 3, 2, 2], [0, 0, 3, 2, 3], [0, 0, 3, 2, 4], [0, 0, 3, 2, 5], [0, 0, 3, 2, 6]]
private def group5_0 : List FastCert := [
  ⟨[0, 0, 0, 0, 0], 0x2060820000411c608b00b0c420608200628a1450870090c51040820c300010408804a0011040820c62491040880470052060821040001c60870440c02060821062431450850440452060820c30001c608704b1002060820c62841450890490450000411040c300008810a0c30000411062430000881070c50c30820000410c30820001040c30820060410c30820001051c60870c61042060880c30011c60870c61041460850c3005, 0x8201882045107be8a450d55540000668811134d5546038481a1⟩,
]
private theorem group5_0_ok : group5_0.all (checkFast 5 7) = true := by decide +kernel
private def certs5 := group5_0
private theorem valid5 : certs5.all (checkFast 5 7) = true := by exact group5_0_ok
private theorem cover5 : ruledOut 7 (rest4) rest5 = certs5.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class5 : Classifies 5 7 rest5 :=
  classify_stepFast (by decide) (by decide) class4 valid5 cover5

private def rest6 : List (List Nat) := []
private def certs6 := ([] : List FastCert)
private theorem valid6 : certs6.all (checkFast 6 7) = true := by rfl
private theorem cover6 : ruledOut 7 (rest5) rest6 = certs6.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class6 : Classifies 6 7 rest6 :=
  classify_stepFast (by decide) (by decide) class5 valid6 cover6

theorem good7 {a : Nat → Nat} (ha : Valid 6 7 a) : Good 6 7 a :=
  of_empty class6 ha
end PhaseFalls.Moduli.Data7

namespace PhaseFalls.Moduli
export Data7 (good7)
end PhaseFalls.Moduli

/-! ## FastData11 -/

/-! Generated by build_modulus_tables.py and repacked for `checkFast`. The kernel checks the rank tables and the coverage of the phase assignments. -/
namespace PhaseFalls.Moduli.Data11
set_option maxRecDepth 80000
set_option maxHeartbeats 0

private def rest3 : List (List Nat) := [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 0, 3], [0, 0, 4], [0, 0, 5], [0, 0, 6], [0, 0, 7], [0, 0, 8], [0, 0, 9], [0, 0, 10], [0, 1, 2], [0, 2, 2], [0, 3, 2], [0, 4, 2], [0, 5, 2], [0, 6, 2], [0, 7, 2], [0, 8, 2], [0, 9, 2], [0, 10, 0], [0, 10, 1], [0, 10, 2], [0, 10, 3], [0, 10, 4], [0, 10, 5], [0, 10, 6], [0, 10, 7], [0, 10, 8], [0, 10, 9], [0, 10, 10]]
private def group3_0 : List FastCert := [
  ⟨[0, 1, 0], 0x10850040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146004083004146, 0x515555500000f02aaaaa3ffff83fffed8⟩,
  ⟨[0, 1, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060040810c4146001086004146, 0x515555500000f02aaaaa3ffffb3fffef8⟩,
  ⟨[0, 1, 3], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860040830040460410850c40060c00810c4146001083004146, 0x515555500000f02aaaaa3fff3b3fffed8⟩,
  ⟨[0, 1, 4], 0x10830040860010830040860010830040860010830040860010830040860010830040860040830040460010850040860410850c40060c00810c4146001083004146, 0x515555500000f02aaaaa3ffcfb3fffed8⟩,
  ⟨[0, 1, 5], 0x10830040860010830040860010830040860010830040860010830040860040830040460010850040860010830040860410850c40060c00810c4146001083004146, 0x515555500000f02aaaaa3ff3fb3fffed8⟩,
  ⟨[0, 1, 6], 0x10830040860010830040860010830040860010830040860040830040460010850040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555500000f02aaaaa3fcffb3fffed8⟩,
  ⟨[0, 1, 7], 0x10830040860010830040860010830040860040830040460010850040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555500000f02aaaaa3f3ffb3fffed8⟩,
  ⟨[0, 1, 8], 0x10830040860010830040860040830040460010850040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555500000f02aaaaa3cfffb3fffed8⟩,
  ⟨[0, 1, 9], 0x10830040860040830040460010850040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555500000f02aaaaa33fffb3fffed8⟩,
  ⟨[0, 1, 10], 0x40820040460010850040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60410820c40060c00810c4146001083004146, 0x515555501555f05555544ffffb3fffed8⟩,
  ⟨[0, 2, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c1005187, 0x22aaaaa00001a0aaaaa8aaaaa02aaab81ffff78⟩,
  ⟨[0, 2, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860430850440060400850c40860040810040c6001086004146, 0x115555500002d02aaaaa2aaaf21fffb78⟩,
  ⟨[0, 2, 3], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c6001082004146, 0x1115555505554d05555546aaa7a1ffff78⟩,
  ⟨[0, 2, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c2005187, 0x22aaaaa00001a0aaaaa8aaa8a02aa9ba1ffff78⟩,
  ⟨[0, 2, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaa00001a0aaaaa8aaa2a02aa6ba1ffff78⟩,
  ⟨[0, 2, 6], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaa00001a0aaaaa8aa8aa02a9aba1ffff78⟩,
  ⟨[0, 2, 7], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaa00001a0aaaaa8aa2aa02a6aba1ffff78⟩,
  ⟨[0, 2, 8], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaa00001a0aaaaa8a8aaa029aaba1ffff78⟩,
  ⟨[0, 2, 9], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaa00001a0aaaaa8a2aaa026aaba1ffff78⟩,
  ⟨[0, 2, 10], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaa00001a0aaaaa88aaaa01aaaba1ffff78⟩,
  ⟨[0, 3, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070050c1005187, 0x22aaaaa00006a0aaaaa8aaaa802aaaf81fffd78⟩,
  ⟨[0, 3, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6004081004086001086004146, 0x115555500003402aaaaa2aaae21fffdf8⟩,
  ⟨[0, 3, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070400c60451070010c20051070010c2005187, 0x22aaaaa00006a0aaaaa8aaab802aaa3a1fffb78⟩,
  ⟨[0, 3, 4], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460400820440c60010820040c6001082004146, 0x4115555505553505555546aa9fa1fffd78⟩,
]
private theorem group3_0_ok : group3_0.all (checkFast 3 11) = true := by decide +kernel
private def group3_1 : List FastCert := [
  ⟨[0, 3, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaa00006a0aaaaa8aaa2802aa6fa1fffd78⟩,
  ⟨[0, 3, 6], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaa00006a0aaaaa8aa8a802a9afa1fffd78⟩,
  ⟨[0, 3, 7], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaa00006a0aaaaa8aa2a802a6afa1fffd78⟩,
  ⟨[0, 3, 8], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaa00006a0aaaaa8a8aa8029aafa1fffd78⟩,
  ⟨[0, 3, 9], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaa00006a0aaaaa8a2aa8026aafa1fffd78⟩,
  ⟨[0, 3, 10], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaa00006a0aaaaa88aaa801aaafa1fffd78⟩,
  ⟨[0, 4, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070050c1005187, 0x22aaaaa0001a20aaaaa8aaaa202aabb81fff778⟩,
  ⟨[0, 4, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086004081004086001086004146, 0x11555550000d002aaaaa2aaba21fff7f8⟩,
  ⟨[0, 4, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070400c60450870010c20051070010c2005187, 0x22aaaaa0001a20aaaaa8aaaa202aab3a1fff778⟩,
  ⟨[0, 4, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070400c30450870010c20051070010c2005187, 0x22aaaaa0001a20aaaaa8aaae202aa8ba1ffef78⟩,
  ⟨[0, 4, 5], 0x10820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60400820440c60010820040c6001082004146, 0x1011555550554d505555546aa7ba1fff778⟩,
  ⟨[0, 4, 6], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaa0001a20aaaaa8aa8a202a9bba1fff778⟩,
  ⟨[0, 4, 7], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaa0001a20aaaaa8aa2a202a6bba1fff778⟩,
  ⟨[0, 4, 8], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaa0001a20aaaaa8a8aa2029abba1fff778⟩,
  ⟨[0, 4, 9], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaa0001a20aaaaa8a2aa2026abba1fff778⟩,
  ⟨[0, 4, 10], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaa0001a20aaaaa88aaa201aabba1fff778⟩,
  ⟨[0, 5, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070050c1005187, 0x22aaaaa0006820aaaaa8aaa8a02aaeb81ffdf78⟩,
  ⟨[0, 5, 1], 0x10830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086004081004086001086004146, 0x115555500034002aaaaa2aaea21ffdff8⟩,
  ⟨[0, 5, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470400c60450870010c20051070010c2005187, 0x22aaaaa0006820aaaaa8aaa8202aae7a1ffdf78⟩,
  ⟨[0, 5, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870400c30450870010c20051070010c2005187, 0x22aaaaa0006820aaaaa8aaa8a02aacba1ffdf78⟩,
  ⟨[0, 5, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0006820aaaaa8aab8a02aa2ba1ffbf78⟩,
  ⟨[0, 5, 6], 0x10820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60400820440c60010820040c6001082004146, 0x40115555505535505555546a9eba1ffdf78⟩,
  ⟨[0, 5, 7], 0x10c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0006820aaaaa8aa28a02a6eba1ffdf78⟩,
  ⟨[0, 5, 8], 0x10c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0006820aaaaa8a8a8a029aeba1ffdf78⟩,
]
private theorem group3_1_ok : group3_1.all (checkFast 3 11) = true := by decide +kernel
private def group3_2 : List FastCert := [
  ⟨[0, 5, 9], 0x10c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0006820aaaaa8a2a8a026aeba1ffdf78⟩,
  ⟨[0, 5, 10], 0x50c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0006820aaaaa88aa8a01aaeba1ffdf78⟩,
  ⟨[0, 6, 0], 0x10c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaa001a020aaaaa8aaa2a02abab81ff7f78⟩,
  ⟨[0, 6, 1], 0x10830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086004081004086001086004146, 0x1155555000d0002aaaaa2abaa21ff7ff8⟩,
  ⟨[0, 6, 3], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaa001a020aaaaa8aaa2202aba7a1ff7f78⟩,
  ⟨[0, 6, 4], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaa001a020aaaaa8aaa0a02ab9ba1ff7f78⟩,
  ⟨[0, 6, 5], 0x10c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa001a020aaaaa8aaa2a02ab2ba1ff7f78⟩,
  ⟨[0, 6, 6], 0x10c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa001a020aaaaa8aae2a02a8aba1feff78⟩,
  ⟨[0, 6, 7], 0x10820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x1001155555054d5505555546a7aba1ff7f78⟩,
  ⟨[0, 6, 8], 0x10c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa001a020aaaaa8a8a2a029baba1ff7f78⟩,
  ⟨[0, 6, 9], 0x10c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa001a020aaaaa8a2a2a026baba1ff7f78⟩,
  ⟨[0, 6, 10], 0x50c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa001a020aaaaa88aa2a01ababa1ff7f78⟩,
  ⟨[0, 7, 0], 0x10c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaa0068020aaaaa8aa8aa02aeab81fdff78⟩,
  ⟨[0, 7, 1], 0x10830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086004081004086001086004146, 0x115555500340002aaaaa2aeaa21fdfff8⟩,
  ⟨[0, 7, 3], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaa0068020aaaaa8aa8a202aea7a1fdff78⟩,
  ⟨[0, 7, 4], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaa0068020aaaaa8aa88a02ae9ba1fdff78⟩,
  ⟨[0, 7, 5], 0x10c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0068020aaaaa8aa82a02ae6ba1fdff78⟩,
  ⟨[0, 7, 6], 0x10c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0068020aaaaa8aa8aa02acaba1fdff78⟩,
  ⟨[0, 7, 7], 0x10c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0068020aaaaa8ab8aa02a2aba1fbff78⟩,
  ⟨[0, 7, 8], 0x10820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x4001155555053555055555469eaba1fdff78⟩,
  ⟨[0, 7, 9], 0x10c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0068020aaaaa8a28aa026eaba1fdff78⟩,
  ⟨[0, 7, 10], 0x50c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0068020aaaaa88a8aa01aeaba1fdff78⟩,
  ⟨[0, 8, 0], 0x10c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaa01a0020aaaaa8aa2aa02baab81f7ff78⟩,
  ⟨[0, 8, 1], 0x10830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x115555500d00002aaaaa2baaa21f7fff8⟩,
]
private theorem group3_2_ok : group3_2.all (checkFast 3 11) = true := by decide +kernel
private def group3_3 : List FastCert := [
  ⟨[0, 8, 3], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaa01a0020aaaaa8aa2a202baa7a1f7ff78⟩,
  ⟨[0, 8, 4], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaa01a0020aaaaa8aa28a02ba9ba1f7ff78⟩,
  ⟨[0, 8, 5], 0x10c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa01a0020aaaaa8aa22a02ba6ba1f7ff78⟩,
  ⟨[0, 8, 6], 0x10c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa01a0020aaaaa8aa0aa02b9aba1f7ff78⟩,
  ⟨[0, 8, 7], 0x10c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa01a0020aaaaa8aa2aa02b2aba1f7ff78⟩,
  ⟨[0, 8, 8], 0x10c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa01a0020aaaaa8ae2aa028aaba1efff78⟩,
  ⟨[0, 8, 9], 0x10820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x1000115555504d555055555467aaba1f7ff78⟩,
  ⟨[0, 8, 10], 0x50c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa01a0020aaaaa88a2aa01baaba1f7ff78⟩,
  ⟨[0, 9, 0], 0x10c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaa0680020aaaaa8a8aaa02eaab81dfff78⟩,
  ⟨[0, 9, 1], 0x10830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x115555503400002aaaaa2eaaa21dffff8⟩,
  ⟨[0, 9, 3], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaa0680020aaaaa8a8aa202eaa7a1dfff78⟩,
  ⟨[0, 9, 4], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaa0680020aaaaa8a8a8a02ea9ba1dfff78⟩,
  ⟨[0, 9, 5], 0x10c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0680020aaaaa8a8a2a02ea6ba1dfff78⟩,
  ⟨[0, 9, 6], 0x10c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0680020aaaaa8a88aa02e9aba1dfff78⟩,
  ⟨[0, 9, 7], 0x10c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0680020aaaaa8a82aa02e6aba1dfff78⟩,
  ⟨[0, 9, 8], 0x10c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0680020aaaaa8a8aaa02caaba1dfff78⟩,
  ⟨[0, 9, 9], 0x10c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaa0680020aaaaa8b8aaa022aaba1bfff78⟩,
  ⟨[0, 9, 10], 0x40820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x4000115555503555505555545eaaba1dfff78⟩,
]
private theorem group3_3_ok : group3_3.all (checkFast 3 11) = true := by decide +kernel
private def certs3 := group3_0 ++ group3_1 ++ group3_2 ++ group3_3
private theorem valid3 : certs3.all (checkFast 3 11) = true := by simp only [certs3, List.all_append, group3_0_ok, group3_1_ok, group3_2_ok, group3_3_ok, Bool.and_true]
private theorem cover3 : ruledOut 11 (pairs 11) rest3 = certs3.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class3 : Classifies 3 11 rest3 :=
  classify_stepFast (by decide) (by decide) (pairs_classify 11) valid3 cover3

private def rest4 : List (List Nat) := [[0, 0, 0, 0], [0, 0, 0, 10], [0, 0, 2, 2], [0, 0, 3, 2], [0, 3, 2, 0], [0, 3, 2, 1], [0, 3, 2, 2], [0, 3, 2, 3], [0, 3, 2, 4], [0, 3, 2, 5], [0, 3, 2, 6], [0, 3, 2, 7], [0, 3, 2, 8], [0, 3, 2, 9], [0, 3, 2, 10]]
private def group4_0 : List FastCert := [
  ⟨[0, 0, 0, 1], 0x410410021820c310a0091870410410020821451040060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70000410820820001061450c71451030020411451030001871890000421452081081870c7, 0x20000200aaa0a00000135550e0fffdc3555551c00020d55554bffffa4aaabb1⟩,
  ⟨[0, 0, 0, 2], 0x1470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21c50461050c6, 0xaaaa0c0000003777420eeeeb8444470d55554aaaaaa35557b1⟩,
  ⟨[0, 0, 0, 3], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470000410820c60001461040c71040c30020411041430001471890000421032081481870c7, 0x20000202aa80a00000135550615555507ffce1c00320d55554bfff3a4aaabb1⟩,
  ⟨[0, 0, 0, 4], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000202aa00a00000135540615555507ff6e1c00c20d55554bffcfa4aaabb1⟩,
  ⟨[0, 0, 0, 5], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000202a820a00000135510615555507fdee1c03020d55554bff3fa4aaabb1⟩,
  ⟨[0, 0, 0, 6], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000202a0a0a00000135450615555507f7ee1c0c020d55554bfcffa4aaabb1⟩,
  ⟨[0, 0, 0, 7], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x2000020282a0a00000135150615555507dfee1c30020d55554bf3ffa4aaabb1⟩,
  ⟨[0, 0, 0, 8], 0x410410021820c314a0091870410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x200002020aa0a000001345506155555077fee1cc0020d55554bcfffa4aaabb1⟩,
  ⟨[0, 0, 0, 9], 0xc30410021820c314a0091881041440020c11c61450060481c70410021061c71480090c81040410021c224614800a0c818704100210218714a0090c81040410021821c71480090c81870410021021871480090c81040410021821c71480090c80000410821020001481870c81040c30020411c71430001881890000421032491481870c8, 0x1000011d54320000003cff74b16eee2aaaaa2777772c00020d55554a2aaa12aaabb1⟩,
  ⟨[0, 0, 1, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaa000000003777420eeeeb8444470d55554aaaaaa35557b1⟩,
  ⟨[0, 0, 4, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaa000000003777420eeeeb8444470d55554aaaaaa35557b1⟩,
  ⟨[0, 0, 5, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaa000000003777420eeeeb8444470d55554aaaaaa35557b1⟩,
  ⟨[0, 0, 6, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaa000000003777420eeeeb8444470d55554aaaaaa35557b1⟩,
  ⟨[0, 0, 7, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaa000000003777420eeeeb8444470d55554aaaaaa35557b1⟩,
  ⟨[0, 0, 8, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaa000000003777420eeeeb8444470d55554aaaaaa35557b1⟩,
  ⟨[0, 0, 9, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaa000000003777420eeeeb8444470d55554aaaaaa35557b1⟩,
  ⟨[0, 0, 10, 0], 0x410410020860c81440001870410410020821041490080c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70000410820820001451040c71040c30020411041430001870001450421030001451860c7, 0x140000000000002aa826aaaaa37ffee1c00020d55554bffffa4aaabb9⟩,
  ⟨[0, 0, 10, 1], 0x410410021820c810a0091870410410020821451090080c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70000410820820001061450c71451030020411451030001871890000421451881081870c7, 0x20000208aaa0a00000125550e0fffdc2aaaaa8d55544555554bffffa4aaabb1⟩,
  ⟨[0, 0, 10, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaa000000003777420eeeeb8444470d55554aaaaaa35557b1⟩,
  ⟨[0, 0, 10, 3], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470000410820c60001461040c71040c30020411041430001471890000421031881481870c7, 0x20000208aa80a00000125550615555507ffce1c00320d55554bfff3a4aaabb1⟩,
  ⟨[0, 0, 10, 4], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000208aa00a00000125540615555507ff6e1c00c20d55554bffcfa4aaabb1⟩,
  ⟨[0, 0, 10, 5], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000208a820a00000125510615555507fdee1c03020d55554bff3fa4aaabb1⟩,
  ⟨[0, 0, 10, 6], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000208a0a0a00000125450615555507f7ee1c0c020d55554bfcffa4aaabb1⟩,
  ⟨[0, 0, 10, 7], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x2000020882a0a00000125150615555507dfee1c30020d55554bf3ffa4aaabb1⟩,
]
private theorem group4_0_ok : group4_0.all (checkFast 4 11) = true := by decide +kernel
private def group4_1 : List FastCert := [
  ⟨[0, 0, 10, 8], 0x410410021820c814a0091870410410020821041490080c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x200002080aa0a000001245506155555077fee1cc0020d55554bcfffa4aaabb1⟩,
  ⟨[0, 0, 10, 9], 0xc30410021820c71480071881041470020c11041470090481890410021071891450090c810404100218210414a0090c81870410021021871450070c81040410021821041480070c81870410021021871450070c81040410021821041480070c80000410821020001451870c81040c30020411041430001881870000421031871451870c8, 0xa8000000000080aa8826eeee2aaaaa2666661c00020d55554a2aaa12aaabb1⟩,
  ⟨[0, 0, 10, 10], 0xc91470021810c91470091880410410020c710414a0090c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80000410820820001461040c81040c30020411041430001481870000421031871481870c8, 0x280000000000000000825550615555507ffee1c00020d55554affffa4aaabb1⟩,
  ⟨[0, 1, 2, 3], 0x1c20430021851c21080090481420440021c31421080090481820430021451821080070481420440021831421080070481820430021451821080070481420440021831421080070480000c30421450001070461480421040020c30421040000c80c20440020450c21040020480420000421860421041431881820440020c3182104002148, 0x2800000000000daa0000662064ccc0435555518888d0d555541557dd0aabac9⟩,
  ⟨[0, 2, 2, 0], 0xc30c30011062081480090870820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70000c30411040001490880870c30c30010442061480000870000c30411460821491c81070c30c30010461041440021c71041440010c3206148006087, 0x2aa8000aaa20a000001155104155555155543ac00ff91ff820aaaaaa4aabba9⟩,
  ⟨[0, 2, 2, 1], 0x820820011441c70c70061060820820011041450c80071060820820011041450c70061060820820011041450c70061060820820011041450c70061060820820011041450c70061060000c30411040000c70850861450c30010441450c30000860000c30411440820c71861061040c30010451040c30021861450c30011041450c7006086, 0x4554450000008ffdc32000061aaaaa8fff820aaaaaa4aabba9⟩,
  ⟨[0, 2, 2, 2], 0xc30c30011041451880070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880001450411040001850870c80c30c30010451041840000880801850411040821851c70c80c30c30011471041840021c81041040010c31c7186005088, 0x55544cd555547ffe21377733aeee3390002686aaaaa4aabba9⟩,
  ⟨[0, 2, 2, 3], 0xc30c30011042061480090871041040010c32061480090870c30c30011042061480090871041040010c32061480090870c30c30011042061480090871041040010c32061480090870000c30411040001490880871041440010432061480000870001040411460821491c80c70c30c30010461041440021c71041040010c3206148006087, 0x2aa8000aaa20a00000155510415555517777baeeee39000020aaaaaa4aabba9⟩,
  ⟨[0, 2, 2, 4], 0xc30c30011041451880070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880001850411040001850870880c30c30010471041840000880000c30411450821861c41080c30c30010451041840021c81041040010c31c7186005088, 0x55544cd555547ffe01377723aeee3f9000020aaaaaa4aabba9⟩,
  ⟨[0, 2, 2, 5], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041850010c31c71860080880000c30411070001890880880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x255704cd55554555c68577743aeeeff9000020aaaaaa4aabba9⟩,
  ⟨[0, 2, 2, 6], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c31850011041c71860080880c30c30011071451890080880000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x255c04cd55554557468577543aeefff9000020aaaaaa4aabba9⟩,
  ⟨[0, 2, 2, 7], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041850010c31c71860080880c30c30011071451890080880820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x257104cd5555455d468577543aeecff9001820aaaaaa4aabba9⟩,
  ⟨[0, 2, 2, 8], 0xc30c30011041451890070881041040010c31451850070880c31850011041c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x25c504cd55554575468575543aef0ff9007820aaaaaa4aabba9⟩,
  ⟨[0, 2, 2, 9], 0xc30c30011041451890070881041850010c31c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x271504cd555545d5468575543aec0ff901f820aaaaaa4aabba9⟩,
  ⟨[0, 2, 2, 10], 0xc31850011041c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c3145185007088, 0x2c55044d55554755469555543af00ff907f820aaaaaa4aabba9⟩,
  ⟨[0, 4, 2, 6], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080490411c60021040411c70080c91020c40020481421c50020490000c50421040001c72060c91020410020c51821c10002090410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x1551a00aaaaa8aae092bb87b0577773a0055745555540031b82aabaa9⟩,
  ⟨[0, 5, 2, 7], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080490411c60021450411c70080c91020c40020481421c50020491420000421041821c62080c90000c60421440001c70482091020410020c61421c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x10002aaaaa8ab8f12bb9e70571d73a01557455555400c5b82aadaa9⟩,
  ⟨[0, 6, 2, 8], 0x1421430021041821c60080491021030021451821c60080490411c60021040411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082090000c50421040001c70460c91020410020c51821c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x40002aaaaa8ae2892b87bb0577773a0545745555540319b82ab3aa9⟩,
  ⟨[0, 7, 2, 9], 0x1421430021041821c60080490411c60021450411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082091420410021041821c60080c90000c60421440001c70480c91020410020c61421c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x100002aaaaa8b8af12b9ee7051dd73a1515745555540c69b82acbaa9⟩,
  ⟨[0, 8, 2, 10], 0x411850021040411850070c81020c40020471421860020481420000421041421861c70c810204100214324218600a1c814204100210414218a0090c81c20410021441c21860090c80000c50421c40001880490c81020410020c51c21810000c80410c50021040421880070c80c20410021450c21840021481020c40020c11421860070c8, 0x1000000ea000000000443344d555546f3223377573a54557455555431a9b82b2baa9⟩,
  ⟨[0, 9, 2, 0], 0x1820c30020451821030020471420000421831421081470c71820410021431821080071471420410021831421080070c71820410021431821080070c71420410021831421080070c70000c30421460001060471471420410020c31421010000c70410c30021460421060071470c20410021460c21040021470411040020c30411040050c7, 0x16ee8000dddd615555518008b0d5555406a9bb2cabaa9⟩,
  ⟨[0, 10, 0, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000d0000802aade4fffd03555551655544555554afffee52aaba9⟩,
  ⟨[0, 10, 1, 1], 0x1c90000421851c91081c90c80c50410021c20c510a0091c81450410020c21451070060c81860410021421861080070c81450410021821451080070c81860410021421861080070c81450410021821451080070c80000c40421420001070460c80000c40420850001040410c80411030020850461030001481860c40020451861080070c8, 0x2800000000000d2a80803989e4f330035555517555445555549aaa5c32aafa9⟩,
  ⟨[0, 10, 2, 1], 0x1c20000421851c21081c90c81420410021c31421080091c81820410021451821080070c81c20410021851c21080090c81820410021c51821080090c81c20410021851c21080090c80000c40421c50001080490c81820410020c51821010000c80410c40021850421080070c80411030021450411030021481820c40020451821040020c8, 0x28aa000000000db748026e9a60c000035555514555445555541aa9bc32abaa9⟩,
]
private theorem group4_1_ok : group4_1.all (checkFast 4 11) = true := by decide +kernel
private def group4_2 : List FastCert := [
  ⟨[0, 10, 3, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000d0000802aede4ffdd03555551655544555554afffee52aaba9⟩,
  ⟨[0, 10, 4, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000d0000802bade4ff7d03555551655544555554afffee52aaba9⟩,
  ⟨[0, 10, 5, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000d0000802eade4fdfd03555551655544555554afffee52aaba9⟩,
  ⟨[0, 10, 6, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000d0000803aade4f7fd03555551655544555554afffee52aaba9⟩,
  ⟨[0, 10, 7, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000d0000806aade4dffd03555551655544555554afffee52aaba9⟩,
  ⟨[0, 10, 8, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821491070060c804104100208214510a0090c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2a80000000000d00008022ade4fffd03555551655544555554afffee52aaba9⟩,
  ⟨[0, 10, 9, 0], 0xc20c30421452021071860070410410020c31481090081870410410021451821090080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70000c30420410001071461470410410021860c21030001471421040020411821040030c7, 0x1d5540000000002aa92a6aa835555551e000d15555542fffee42aaba9⟩,
  ⟨[0, 10, 9, 1], 0x1c90000421851c91081c90c80410410021c20c910a0091c804104100208214510a0090c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2a00000000000d0000800aade43ffd03555551755544555554afffee52aaba9⟩,
  ⟨[0, 10, 9, 2], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80001450420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000c00034a0aa866aaaaa30aaa1a755544555554afffee42aaba9⟩,
  ⟨[0, 10, 9, 3], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480000c50420c60001481070c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000c00174a0ab866aaaaa30aae1a755744555554afff2e42aaba9⟩,
  ⟨[0, 10, 9, 4], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000c00534a0ae066aaaaa30aba1a755d44555554affcee42aaba9⟩,
  ⟨[0, 10, 9, 5], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000c01434a0b8866aaaaa30aea1a757544555554aff3ee42aaba9⟩,
  ⟨[0, 10, 9, 6], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000c05034a0e2866aaaaa30baa1a75d544555554afcfee42aaba9⟩,
  ⟨[0, 10, 9, 7], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000c14034a18a866aaaaa30eaa1a775544555554af3fee42aaba9⟩,
  ⟨[0, 10, 9, 8], 0x1c70c50421041c71481860090410410021c60c814a0081890c61480020820c41480090490410410020c81041470060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90000c50420410001451040c90410410020861c71430001091040c40020411861480070c9, 0x4400000c20034a6aa866aaaaa30aaa1a7d5544555554acffee42aaba9⟩,
  ⟨[0, 10, 9, 9], 0x1c20c50421041c21481860080491480021c60c91480091880410410020c810214a0090c80410410020c41821450070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80000c50420410001471060c80410410021861c21430001081020c40020411821480070c8, 0xa00000000000d2aa3821ffa66aaaaa30d541a7555445555542fffee42aaba9⟩,
  ⟨[0, 10, 9, 10], 0xc21470421040c21471860070410410020c71081440061870410410020c41821490080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70000c50420410001471060c70410410021862021430001071020c40020411821490080c7, 0x55547000000002aa92aaaaaa335541ad555445555542fffee42aaba9⟩,
  ⟨[0, 10, 10, 0], 0xc20c30421452081071860070410410020c31421090081870410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70000c30420410001071461470410410021860c21030001471421040020411821040030c7, 0x1aaaa0100000002aa92a6aa835555551e000d15555542fffee42aaba9⟩,
  ⟨[0, 10, 10, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000d0000802aade4fffd03555551655544555554afffee52aaba9⟩,
  ⟨[0, 10, 10, 2], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80001450420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000c00034a2aa866aaaaa32aaa1a655544555554afffee42aaba9⟩,
  ⟨[0, 10, 10, 3], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480000c50420c60001481070c80410410020861c71430001081040c40020411861480070c8, 0x800000000000c00174a2ab866aaaaa32aae1a655744555554afff2e42aaba9⟩,
  ⟨[0, 10, 10, 4], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000c00534a2ae066aaaaa32aba1a655d44555554affcee42aaba9⟩,
  ⟨[0, 10, 10, 5], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000c01434a2b8866aaaaa32aea1a657544555554aff3ee42aaba9⟩,
  ⟨[0, 10, 10, 6], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000c05034a2e2866aaaaa32baa1a65d544555554afcfee42aaba9⟩,
]
private theorem group4_2_ok : group4_2.all (checkFast 4 11) = true := by decide +kernel
private def group4_3 : List FastCert := [
  ⟨[0, 10, 10, 7], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000c14034a38a866aaaaa32eaa1a675544555554af3fee42aaba9⟩,
  ⟨[0, 10, 10, 8], 0x1c70c50421041c71481860080410410021c61031480091880c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000c50034a62a866aaaaa33aaa1a6d5544555554acffee42aaba9⟩,
  ⟨[0, 10, 10, 9], 0x1c20c50421041c71481890080411480021c60c21480091880410410020c81021440060c80410410020c41821450070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80000c50420410001471060c80410410021861021430001881020c40020411c21450060c8, 0x2800000000000c1558ca3ffa26aaaaa30d543a7555445555542fffee42aaba9⟩,
  ⟨[0, 10, 10, 10], 0xc81470421040c81471860070410410020c71021490081870410410020c41821450080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70000c50420410001471060c70410410021862021430001071020c40020411821490080c7, 0x155547000000002aa92aaaaaa335541ad555445555542fffee42aaba9⟩,
]
private theorem group4_3_ok : group4_3.all (checkFast 4 11) = true := by decide +kernel
private def certs4 := group4_0 ++ group4_1 ++ group4_2 ++ group4_3
private theorem valid4 : certs4.all (checkFast 4 11) = true := by simp only [certs4, List.all_append, group4_0_ok, group4_1_ok, group4_2_ok, group4_3_ok, Bool.and_true]
private theorem cover4 : ruledOut 11 (rest3) rest4 = certs4.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class4 : Classifies 4 11 rest4 :=
  classify_stepFast (by decide) (by decide) class3 valid4 cover4

private def rest5 : List (List Nat) := [[0, 0, 0, 0, 10], [0, 0, 3, 2, 0], [0, 0, 3, 2, 1], [0, 0, 3, 2, 2], [0, 0, 3, 2, 3], [0, 0, 3, 2, 4], [0, 0, 3, 2, 5], [0, 0, 3, 2, 6], [0, 0, 3, 2, 7], [0, 0, 3, 2, 8], [0, 0, 3, 2, 9], [0, 0, 3, 2, 10]]
private def group5_0 : List FastCert := [
  ⟨[0, 0, 0, 0, 0], 0x2060820000411c608b00b0c420608200628a1450870090c51040820c300010408804a0011040820c62491040880470052060821040001c60870440c02060821062431450850440452060820c30001c608704b1002060820c62841450890490452060821040001c608704b0c02060821062831450890490452060820c30001c608704b1002060820c62841450890490452060821040001c608704b0c02060821062831450890490452060820c30001c608704b1002060820c62841450890490450000411040c300008810a0c30000411062430000881070c50c30820000410c30820001040c30820060410c30820001051c60870c61042060880c30011c60870c61041460850c3005, 0x82aa018800204500107bffe8a45550d5555540000006688881111134d5555460003848001a1⟩,
]
private theorem group5_0_ok : group5_0.all (checkFast 5 11) = true := by decide +kernel
private def certs5 := group5_0
private theorem valid5 : certs5.all (checkFast 5 11) = true := by exact group5_0_ok
private theorem cover5 : ruledOut 11 (rest4) rest5 = certs5.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class5 : Classifies 5 11 rest5 :=
  classify_stepFast (by decide) (by decide) class4 valid5 cover5

private def rest6 : List (List Nat) := []
private def certs6 := ([] : List FastCert)
private theorem valid6 : certs6.all (checkFast 6 11) = true := by rfl
private theorem cover6 : ruledOut 11 (rest5) rest6 = certs6.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class6 : Classifies 6 11 rest6 :=
  classify_stepFast (by decide) (by decide) class5 valid6 cover6

theorem good11 {a : Nat → Nat} (ha : Valid 6 11 a) : Good 6 11 a :=
  of_empty class6 ha
end PhaseFalls.Moduli.Data11

namespace PhaseFalls.Moduli
export Data11 (good11)
end PhaseFalls.Moduli

/-! ## FastData13 -/

/-! Generated by build_modulus_tables.py and repacked for `checkFast`. The kernel checks the rank tables and the coverage of the phase assignments. -/
namespace PhaseFalls.Moduli.Data13
set_option maxRecDepth 80000
set_option maxHeartbeats 0

private def rest3 : List (List Nat) := [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 0, 3], [0, 0, 4], [0, 0, 5], [0, 0, 6], [0, 0, 7], [0, 0, 8], [0, 0, 9], [0, 0, 10], [0, 0, 11], [0, 0, 12], [0, 1, 2], [0, 2, 2], [0, 3, 2], [0, 4, 2], [0, 5, 2], [0, 6, 2], [0, 7, 2], [0, 8, 2], [0, 9, 2], [0, 10, 2], [0, 11, 2], [0, 12, 0], [0, 12, 1], [0, 12, 2], [0, 12, 3], [0, 12, 4], [0, 12, 5], [0, 12, 6], [0, 12, 7], [0, 12, 8], [0, 12, 9], [0, 12, 10], [0, 12, 11], [0, 12, 12]]
private def group3_0 : List FastCert := [
  ⟨[0, 1, 0], 0x10850040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146004083004146, 0x51555555000000f02aaaaaa3fffff83ffffed8⟩,
  ⟨[0, 1, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060040810c4146001086004146, 0x51555555000000f02aaaaaa3fffffb3ffffef8⟩,
  ⟨[0, 1, 3], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860040830040460410850c40060c00810c4146001083004146, 0x51555555000000f02aaaaaa3ffff3b3ffffed8⟩,
  ⟨[0, 1, 4], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860040830040460010850040860410850c40060c00810c4146001083004146, 0x51555555000000f02aaaaaa3fffcfb3ffffed8⟩,
  ⟨[0, 1, 5], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860040830040460010850040860010830040860410850c40060c00810c4146001083004146, 0x51555555000000f02aaaaaa3fff3fb3ffffed8⟩,
  ⟨[0, 1, 6], 0x10830040860010830040860010830040860010830040860010830040860010830040860040830040460010850040860010830040860010830040860410850c40060c00810c4146001083004146, 0x51555555000000f02aaaaaa3ffcffb3ffffed8⟩,
  ⟨[0, 1, 7], 0x10830040860010830040860010830040860010830040860010830040860040830040460010850040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x51555555000000f02aaaaaa3ff3ffb3ffffed8⟩,
  ⟨[0, 1, 8], 0x10830040860010830040860010830040860010830040860040830040460010850040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x51555555000000f02aaaaaa3fcfffb3ffffed8⟩,
  ⟨[0, 1, 9], 0x10830040860010830040860010830040860040830040460010850040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x51555555000000f02aaaaaa3f3fffb3ffffed8⟩,
  ⟨[0, 1, 10], 0x10830040860010830040860040830040460010850040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x51555555000000f02aaaaaa3cffffb3ffffed8⟩,
  ⟨[0, 1, 11], 0x10830040860040830040460010850040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x51555555000000f02aaaaaa33ffffb3ffffed8⟩,
  ⟨[0, 1, 12], 0x40820040460010850040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60410820c40060c00810c4146001083004146, 0x51555555015555f055555544fffffb3ffffed8⟩,
  ⟨[0, 2, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c1005187, 0x22aaaaaa000001a0aaaaaa8aaaaaa02aaaab81fffff78⟩,
  ⟨[0, 2, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860430850440060400850c40860040810040c6001086004146, 0x11555555000002d02aaaaaa2aaaaf21ffffb78⟩,
  ⟨[0, 2, 3], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c6001082004146, 0x111555555055554d055555546aaaa7a1fffff78⟩,
  ⟨[0, 2, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c2005187, 0x22aaaaaa000001a0aaaaaa8aaaa8a02aaa9ba1fffff78⟩,
  ⟨[0, 2, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaa000001a0aaaaaa8aaaa2a02aaa6ba1fffff78⟩,
  ⟨[0, 2, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaa000001a0aaaaaa8aaa8aa02aa9aba1fffff78⟩,
  ⟨[0, 2, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaa000001a0aaaaaa8aaa2aa02aa6aba1fffff78⟩,
  ⟨[0, 2, 8], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaa000001a0aaaaaa8aa8aaa02a9aaba1fffff78⟩,
  ⟨[0, 2, 9], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaa000001a0aaaaaa8aa2aaa02a6aaba1fffff78⟩,
  ⟨[0, 2, 10], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaa000001a0aaaaaa8a8aaaa029aaaba1fffff78⟩,
  ⟨[0, 2, 11], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaa000001a0aaaaaa8a2aaaa026aaaba1fffff78⟩,
  ⟨[0, 2, 12], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaa000001a0aaaaaa88aaaaa01aaaaba1fffff78⟩,
]
private theorem group3_0_ok : group3_0.all (checkFast 3 13) = true := by decide +kernel
private def group3_1 : List FastCert := [
  ⟨[0, 3, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070050c1005187, 0x22aaaaaa000006a0aaaaaa8aaaaa802aaaaf81ffffd78⟩,
  ⟨[0, 3, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6004081004086001086004146, 0x11555555000003402aaaaaa2aaaae21ffffdf8⟩,
  ⟨[0, 3, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070400c60451070010c20051070010c2005187, 0x22aaaaaa000006a0aaaaaa8aaaab802aaaa3a1ffffb78⟩,
  ⟨[0, 3, 4], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460400820440c60010820040c6001082004146, 0x4115555550555535055555546aaa9fa1ffffd78⟩,
  ⟨[0, 3, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaa000006a0aaaaaa8aaaa2802aaa6fa1ffffd78⟩,
  ⟨[0, 3, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaa000006a0aaaaaa8aaa8a802aa9afa1ffffd78⟩,
  ⟨[0, 3, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaa000006a0aaaaaa8aaa2a802aa6afa1ffffd78⟩,
  ⟨[0, 3, 8], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaa000006a0aaaaaa8aa8aa802a9aafa1ffffd78⟩,
  ⟨[0, 3, 9], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaa000006a0aaaaaa8aa2aa802a6aafa1ffffd78⟩,
  ⟨[0, 3, 10], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaa000006a0aaaaaa8a8aaa8029aaafa1ffffd78⟩,
  ⟨[0, 3, 11], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaa000006a0aaaaaa8a2aaa8026aaafa1ffffd78⟩,
  ⟨[0, 3, 12], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaa000006a0aaaaaa88aaaa801aaaafa1ffffd78⟩,
  ⟨[0, 4, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070050c1005187, 0x22aaaaaa00001a20aaaaaa8aaaaa202aaabb81ffff778⟩,
  ⟨[0, 4, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086004081004086001086004146, 0x1155555500000d002aaaaaa2aaaba21ffff7f8⟩,
  ⟨[0, 4, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070400c60450870010c20051070010c2005187, 0x22aaaaaa00001a20aaaaaa8aaaaa202aaab3a1ffff778⟩,
  ⟨[0, 4, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070400c30450870010c20051070010c2005187, 0x22aaaaaa00001a20aaaaaa8aaaae202aaa8ba1fffef78⟩,
  ⟨[0, 4, 5], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60400820440c60010820040c6001082004146, 0x101155555505554d5055555546aaa7ba1ffff778⟩,
  ⟨[0, 4, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaa00001a20aaaaaa8aaa8a202aa9bba1ffff778⟩,
  ⟨[0, 4, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaa00001a20aaaaaa8aaa2a202aa6bba1ffff778⟩,
  ⟨[0, 4, 8], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaa00001a20aaaaaa8aa8aa202a9abba1ffff778⟩,
  ⟨[0, 4, 9], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaa00001a20aaaaaa8aa2aa202a6abba1ffff778⟩,
  ⟨[0, 4, 10], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaa00001a20aaaaaa8a8aaa2029aabba1ffff778⟩,
  ⟨[0, 4, 11], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaa00001a20aaaaaa8a2aaa2026aabba1ffff778⟩,
  ⟨[0, 4, 12], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaa00001a20aaaaaa88aaaa201aaabba1ffff778⟩,
]
private theorem group3_1_ok : group3_1.all (checkFast 3 13) = true := by decide +kernel
private def group3_2 : List FastCert := [
  ⟨[0, 5, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaa00006820aaaaaa8aaaa8a02aaaeb81fffdf78⟩,
  ⟨[0, 5, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086004081004086001086004146, 0x11555555000034002aaaaaa2aaaea21fffdff8⟩,
  ⟨[0, 5, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaa00006820aaaaaa8aaaa8202aaae7a1fffdf78⟩,
  ⟨[0, 5, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaa00006820aaaaaa8aaaa8a02aaacba1fffdf78⟩,
  ⟨[0, 5, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00006820aaaaaa8aaab8a02aaa2ba1fffbf78⟩,
  ⟨[0, 5, 6], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60400820440c60010820040c6001082004146, 0x40115555550555355055555546aa9eba1fffdf78⟩,
  ⟨[0, 5, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00006820aaaaaa8aaa28a02aa6eba1fffdf78⟩,
  ⟨[0, 5, 8], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00006820aaaaaa8aa8a8a02a9aeba1fffdf78⟩,
  ⟨[0, 5, 9], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00006820aaaaaa8aa2a8a02a6aeba1fffdf78⟩,
  ⟨[0, 5, 10], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00006820aaaaaa8a8aa8a029aaeba1fffdf78⟩,
  ⟨[0, 5, 11], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00006820aaaaaa8a2aa8a026aaeba1fffdf78⟩,
  ⟨[0, 5, 12], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00006820aaaaaa88aaa8a01aaaeba1fffdf78⟩,
  ⟨[0, 6, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaa0001a020aaaaaa8aaaa2a02aabab81fff7f78⟩,
  ⟨[0, 6, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086004081004086001086004146, 0x115555550000d0002aaaaaa2aabaa21fff7ff8⟩,
  ⟨[0, 6, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaa0001a020aaaaaa8aaaa2202aaba7a1fff7f78⟩,
  ⟨[0, 6, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaa0001a020aaaaaa8aaaa0a02aab9ba1fff7f78⟩,
  ⟨[0, 6, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa0001a020aaaaaa8aaaa2a02aab2ba1fff7f78⟩,
  ⟨[0, 6, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa0001a020aaaaaa8aaae2a02aa8aba1ffeff78⟩,
  ⟨[0, 6, 7], 0x10820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x100115555550554d55055555546aa7aba1fff7f78⟩,
  ⟨[0, 6, 8], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa0001a020aaaaaa8aa8a2a02a9baba1fff7f78⟩,
  ⟨[0, 6, 9], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa0001a020aaaaaa8aa2a2a02a6baba1fff7f78⟩,
  ⟨[0, 6, 10], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa0001a020aaaaaa8a8aa2a029ababa1fff7f78⟩,
  ⟨[0, 6, 11], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa0001a020aaaaaa8a2aa2a026ababa1fff7f78⟩,
  ⟨[0, 6, 12], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa0001a020aaaaaa88aaa2a01aababa1fff7f78⟩,
]
private theorem group3_2_ok : group3_2.all (checkFast 3 13) = true := by decide +kernel
private def group3_3 : List FastCert := [
  ⟨[0, 7, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaa00068020aaaaaa8aaa8aa02aaeab81ffdff78⟩,
  ⟨[0, 7, 1], 0x10830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086004081004086001086004146, 0x11555555000340002aaaaaa2aaeaa21ffdfff8⟩,
  ⟨[0, 7, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaa00068020aaaaaa8aaa8a202aaea7a1ffdff78⟩,
  ⟨[0, 7, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaa00068020aaaaaa8aaa88a02aae9ba1ffdff78⟩,
  ⟨[0, 7, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00068020aaaaaa8aaa82a02aae6ba1ffdff78⟩,
  ⟨[0, 7, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00068020aaaaaa8aaa8aa02aacaba1ffdff78⟩,
  ⟨[0, 7, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00068020aaaaaa8aab8aa02aa2aba1ffbff78⟩,
  ⟨[0, 7, 8], 0x10820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x400115555550553555055555546a9eaba1ffdff78⟩,
  ⟨[0, 7, 9], 0x10c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00068020aaaaaa8aa28aa02a6eaba1ffdff78⟩,
  ⟨[0, 7, 10], 0x10c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00068020aaaaaa8a8a8aa029aeaba1ffdff78⟩,
  ⟨[0, 7, 11], 0x10c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00068020aaaaaa8a2a8aa026aeaba1ffdff78⟩,
  ⟨[0, 7, 12], 0x50c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00068020aaaaaa88aa8aa01aaeaba1ffdff78⟩,
  ⟨[0, 8, 0], 0x10c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaa001a0020aaaaaa8aaa2aa02abaab81ff7ff78⟩,
  ⟨[0, 8, 1], 0x10830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x11555555000d00002aaaaaa2abaaa21ff7fff8⟩,
  ⟨[0, 8, 3], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaa001a0020aaaaaa8aaa2a202abaa7a1ff7ff78⟩,
  ⟨[0, 8, 4], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaa001a0020aaaaaa8aaa28a02aba9ba1ff7ff78⟩,
  ⟨[0, 8, 5], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa001a0020aaaaaa8aaa22a02aba6ba1ff7ff78⟩,
  ⟨[0, 8, 6], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa001a0020aaaaaa8aaa0aa02ab9aba1ff7ff78⟩,
  ⟨[0, 8, 7], 0x10c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa001a0020aaaaaa8aaa2aa02ab2aba1ff7ff78⟩,
  ⟨[0, 8, 8], 0x10c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa001a0020aaaaaa8aae2aa02a8aaba1fefff78⟩,
  ⟨[0, 8, 9], 0x10820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x100011555555054d555055555546a7aaba1ff7ff78⟩,
  ⟨[0, 8, 10], 0x10c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa001a0020aaaaaa8a8a2aa029baaba1ff7ff78⟩,
  ⟨[0, 8, 11], 0x10c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa001a0020aaaaaa8a2a2aa026baaba1ff7ff78⟩,
  ⟨[0, 8, 12], 0x50c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa001a0020aaaaaa88aa2aa01abaaba1ff7ff78⟩,
]
private theorem group3_3_ok : group3_3.all (checkFast 3 13) = true := by decide +kernel
private def group3_4 : List FastCert := [
  ⟨[0, 9, 0], 0x10c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaa00680020aaaaaa8aa8aaa02aeaab81fdfff78⟩,
  ⟨[0, 9, 1], 0x10830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x11555555003400002aaaaaa2aeaaa21fdffff8⟩,
  ⟨[0, 9, 3], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaa00680020aaaaaa8aa8aa202aeaa7a1fdfff78⟩,
  ⟨[0, 9, 4], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaa00680020aaaaaa8aa8a8a02aea9ba1fdfff78⟩,
  ⟨[0, 9, 5], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00680020aaaaaa8aa8a2a02aea6ba1fdfff78⟩,
  ⟨[0, 9, 6], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00680020aaaaaa8aa88aa02ae9aba1fdfff78⟩,
  ⟨[0, 9, 7], 0x10c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00680020aaaaaa8aa82aa02ae6aba1fdfff78⟩,
  ⟨[0, 9, 8], 0x10c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00680020aaaaaa8aa8aaa02acaaba1fdfff78⟩,
  ⟨[0, 9, 9], 0x10c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00680020aaaaaa8ab8aaa02a2aaba1fbfff78⟩,
  ⟨[0, 9, 10], 0x10820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x40001155555505355550555555469eaaba1fdfff78⟩,
  ⟨[0, 9, 11], 0x10c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00680020aaaaaa8a28aaa026eaaba1fdfff78⟩,
  ⟨[0, 9, 12], 0x50c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa00680020aaaaaa88a8aaa01aeaaba1fdfff78⟩,
  ⟨[0, 10, 0], 0x10c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaa01a00020aaaaaa8aa2aaa02baaab81f7fff78⟩,
  ⟨[0, 10, 1], 0x10830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x1155555500d000002aaaaaa2baaaa21f7ffff8⟩,
  ⟨[0, 10, 3], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaa01a00020aaaaaa8aa2aa202baaa7a1f7fff78⟩,
  ⟨[0, 10, 4], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaa01a00020aaaaaa8aa2a8a02baa9ba1f7fff78⟩,
  ⟨[0, 10, 5], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa01a00020aaaaaa8aa2a2a02baa6ba1f7fff78⟩,
  ⟨[0, 10, 6], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa01a00020aaaaaa8aa28aa02ba9aba1f7fff78⟩,
  ⟨[0, 10, 7], 0x10c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa01a00020aaaaaa8aa22aa02ba6aba1f7fff78⟩,
  ⟨[0, 10, 8], 0x10c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa01a00020aaaaaa8aa0aaa02b9aaba1f7fff78⟩,
  ⟨[0, 10, 9], 0x10c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa01a00020aaaaaa8aa2aaa02b2aaba1f7fff78⟩,
  ⟨[0, 10, 10], 0x10c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa01a00020aaaaaa8ae2aaa028aaaba1effff78⟩,
  ⟨[0, 10, 11], 0x10820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x100001155555504d55550555555467aaaba1f7fff78⟩,
  ⟨[0, 10, 12], 0x50c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa01a00020aaaaaa88a2aaa01baaaba1f7fff78⟩,
]
private theorem group3_4_ok : group3_4.all (checkFast 3 13) = true := by decide +kernel
private def group3_5 : List FastCert := [
  ⟨[0, 11, 0], 0x10c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaa06800020aaaaaa8a8aaaa02eaaab81dffff78⟩,
  ⟨[0, 11, 1], 0x10830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x11555555034000002aaaaaa2eaaaa21dfffff8⟩,
  ⟨[0, 11, 3], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaa06800020aaaaaa8a8aaa202eaaa7a1dffff78⟩,
  ⟨[0, 11, 4], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaa06800020aaaaaa8a8aa8a02eaa9ba1dffff78⟩,
  ⟨[0, 11, 5], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa06800020aaaaaa8a8aa2a02eaa6ba1dffff78⟩,
  ⟨[0, 11, 6], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa06800020aaaaaa8a8a8aa02ea9aba1dffff78⟩,
  ⟨[0, 11, 7], 0x10c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa06800020aaaaaa8a8a2aa02ea6aba1dffff78⟩,
  ⟨[0, 11, 8], 0x10c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa06800020aaaaaa8a88aaa02e9aaba1dffff78⟩,
  ⟨[0, 11, 9], 0x10c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa06800020aaaaaa8a82aaa02e6aaba1dffff78⟩,
  ⟨[0, 11, 10], 0x10c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa06800020aaaaaa8a8aaaa02caaaba1dffff78⟩,
  ⟨[0, 11, 11], 0x10c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaa06800020aaaaaa8b8aaaa022aaaba1bffff78⟩,
  ⟨[0, 11, 12], 0x40820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x40000115555550355555055555545eaaaba1dffff78⟩,
]
private theorem group3_5_ok : group3_5.all (checkFast 3 13) = true := by decide +kernel
private def certs3 := group3_0 ++ group3_1 ++ group3_2 ++ group3_3 ++ group3_4 ++ group3_5
private theorem valid3 : certs3.all (checkFast 3 13) = true := by simp only [certs3, List.all_append, group3_0_ok, group3_1_ok, group3_2_ok, group3_3_ok, group3_4_ok, group3_5_ok, Bool.and_true]
private theorem cover3 : ruledOut 13 (pairs 13) rest3 = certs3.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class3 : Classifies 3 13 rest3 :=
  classify_stepFast (by decide) (by decide) (pairs_classify 13) valid3 cover3

private def rest4 : List (List Nat) := [[0, 0, 0, 0], [0, 0, 0, 12], [0, 0, 2, 2], [0, 0, 3, 2], [0, 3, 2, 0], [0, 3, 2, 1], [0, 3, 2, 2], [0, 3, 2, 3], [0, 3, 2, 4], [0, 3, 2, 5], [0, 3, 2, 6], [0, 3, 2, 7], [0, 3, 2, 8], [0, 3, 2, 9], [0, 3, 2, 10], [0, 3, 2, 11], [0, 3, 2, 12]]
private def group4_0 : List FastCert := [
  ⟨[0, 0, 0, 1], 0x410410021820c310a0091870410410020821451040060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70000410820820001061450c71451030020411451030001871890000421452081081870c7, 0x200000200aaaa0a0000001355550e0ffffdc35555551c000020d555554bfffffa4aaaabb1⟩,
  ⟨[0, 0, 0, 2], 0x1470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21c50461050c6, 0xaaaaa0c000000037777420eeeeeb84444470d555554aaaaaaa355557b1⟩,
  ⟨[0, 0, 0, 3], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470000410820c60001461040c71040c30020411041430001471890000421032081481870c7, 0x200000202aaa80a00000013555506155555507fffce1c000320d555554bffff3a4aaaabb1⟩,
  ⟨[0, 0, 0, 4], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x200000202aaa00a00000013555406155555507fff6e1c000c20d555554bfffcfa4aaaabb1⟩,
  ⟨[0, 0, 0, 5], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x200000202aa820a00000013555106155555507ffdee1c003020d555554bfff3fa4aaaabb1⟩,
  ⟨[0, 0, 0, 6], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x200000202aa0a0a00000013554506155555507ff7ee1c00c020d555554bffcffa4aaaabb1⟩,
  ⟨[0, 0, 0, 7], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x200000202a82a0a00000013551506155555507fdfee1c030020d555554bff3ffa4aaaabb1⟩,
  ⟨[0, 0, 0, 8], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x200000202a0aa0a00000013545506155555507f7fee1c0c0020d555554bfcfffa4aaaabb1⟩,
  ⟨[0, 0, 0, 9], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000020282aa0a00000013515506155555507dffee1c300020d555554bf3fffa4aaaabb1⟩,
  ⟨[0, 0, 0, 10], 0x410410021820c314a0091870410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x2000002020aaa0a000000134555061555555077ffee1cc00020d555554bcffffa4aaaabb1⟩,
  ⟨[0, 0, 0, 11], 0xc30410021820c314a0091881041440020c11c61450060481c70410021061c71480090c81040410021c224614800a0c818704100210218714a0090c81040410021821c71480090c81870410021021871480090c81040410021821c71480090c81870410021021871480090c81040410021821c71480090c80000410821020001481870c81040c30020411c71430001881890000421032491481870c8, 0x10000011d5543200000003cfff74b16eeee2aaaaaa27777772c000020d555554a2aaaa12aaaabb1⟩,
  ⟨[0, 0, 1, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaa00000000037777420eeeeeb84444470d555554aaaaaaa355557b1⟩,
  ⟨[0, 0, 4, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaa00000000037777420eeeeeb84444470d555554aaaaaaa355557b1⟩,
  ⟨[0, 0, 5, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaa00000000037777420eeeeeb84444470d555554aaaaaaa355557b1⟩,
  ⟨[0, 0, 6, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaa00000000037777420eeeeeb84444470d555554aaaaaaa355557b1⟩,
  ⟨[0, 0, 7, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaa00000000037777420eeeeeb84444470d555554aaaaaaa355557b1⟩,
  ⟨[0, 0, 8, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaa00000000037777420eeeeeb84444470d555554aaaaaaa355557b1⟩,
  ⟨[0, 0, 9, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaa00000000037777420eeeeeb84444470d555554aaaaaaa355557b1⟩,
  ⟨[0, 0, 10, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaa00000000037777420eeeeeb84444470d555554aaaaaaa355557b1⟩,
  ⟨[0, 0, 11, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaa00000000037777420eeeeeb84444470d555554aaaaaaa355557b1⟩,
  ⟨[0, 0, 12, 0], 0x410410020860c81440001870410410020821041490080c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70000410820820001451040c71040c30020411041430001870001450421030001451860c7, 0x14000000000000002aaa826aaaaaa37fffee1c000020d555554bfffffa4aaaabb9⟩,
  ⟨[0, 0, 12, 1], 0x410410021820c810a0091870410410020821451090080c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70000410820820001061450c71451030020411451030001871890000421451881081870c7, 0x200000208aaaa0a0000001255550e0ffffdc2aaaaaa8d5555445555554bfffffa4aaaabb1⟩,
  ⟨[0, 0, 12, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaa00000000037777420eeeeeb84444470d555554aaaaaaa355557b1⟩,
  ⟨[0, 0, 12, 3], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470000410820c60001461040c71040c30020411041430001471890000421031881481870c7, 0x200000208aaa80a00000012555506155555507fffce1c000320d555554bffff3a4aaaabb1⟩,
]
private theorem group4_0_ok : group4_0.all (checkFast 4 13) = true := by decide +kernel
private def group4_1 : List FastCert := [
  ⟨[0, 0, 12, 4], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x200000208aaa00a00000012555406155555507fff6e1c000c20d555554bfffcfa4aaaabb1⟩,
  ⟨[0, 0, 12, 5], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x200000208aa820a00000012555106155555507ffdee1c003020d555554bfff3fa4aaaabb1⟩,
  ⟨[0, 0, 12, 6], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x200000208aa0a0a00000012554506155555507ff7ee1c00c020d555554bffcffa4aaaabb1⟩,
  ⟨[0, 0, 12, 7], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x200000208a82a0a00000012551506155555507fdfee1c030020d555554bff3ffa4aaaabb1⟩,
  ⟨[0, 0, 12, 8], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x200000208a0aa0a00000012545506155555507f7fee1c0c0020d555554bfcfffa4aaaabb1⟩,
  ⟨[0, 0, 12, 9], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000020882aa0a00000012515506155555507dffee1c300020d555554bf3fffa4aaaabb1⟩,
  ⟨[0, 0, 12, 10], 0x410410021820c814a0091870410410020821041490080c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x2000002080aaa0a000000124555061555555077ffee1cc00020d555554bcffffa4aaaabb1⟩,
  ⟨[0, 0, 12, 11], 0xc30410021820c71480071881041470020c11041470090481890410021071891450090c810404100218210414a0090c81870410021021871450070c81040410021821041480070c81870410021021871450070c81040410021821041480070c81870410021021871450070c81040410021821041480070c80000410821020001451870c81040c30020411041430001881870000421031871451870c8, 0xa800000000000080aaa8826eeeee2aaaaaa26666661c000020d555554a2aaaa12aaaabb1⟩,
  ⟨[0, 0, 12, 12], 0xc91470021810c91470091880410410020c710414a0090c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80000410820820001461040c81040c30020411041430001481870000421031871481870c8, 0x28000000000000000000082555506155555507fffee1c000020d555554afffffa4aaaabb1⟩,
  ⟨[0, 1, 2, 3], 0x1c20430021851c21080090481420440021c31421080090481820430021451821080070481420440021831421080070481820430021451821080070481420440021831421080070481820430021451821080070481420440021831421080070480000c30421450001070461480421040020c30421040000c80c20440020450c21040020480420000421860421041431881820440020c3182104002148, 0x280000000000000daaa00006662064cccc043555555188888d0d55555415557dd0aaabac9⟩,
  ⟨[0, 2, 2, 0], 0xc30c30011062081480090870820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70000c30411040001490880870c30c30010442061480000870000c30411460821491c81070c30c30010461041440021c71041440010c3206148006087, 0x2aaa8000aaaa20a0000001155510415555551555543ac000ff91fff820aaaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 1], 0x820820011441c70c70061060820820011041450c80071060820820011041450c70061060820820011041450c70061060820820011041450c70061060820820011041450c70061060820820011041450c70061060820820011041450c70061060000c30411040000c70850861450c30010441450c30000860000c30411440820c71861061040c30010451040c30021861450c30011041450c7006086, 0x455544500000008fffdc320000061aaaaaa8ffff820aaaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 2], 0xc30c30011041451880070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880001450411040001850870c80c30c30010451041840000880801850411040821851c70c80c30c30011471041840021c81041040010c31c7186005088, 0x555544cd5555547fffe213777733aeeee33900002686aaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 3], 0xc30c30011042061480090871041040010c32061480090870c30c30011042061480090871041040010c32061480090870c30c30011042061480090871041040010c32061480090870c30c30011042061480090871041040010c32061480090870000c30411040001490880871041440010432061480000870001040411460821491c80c70c30c30010461041440021c71041040010c3206148006087, 0x2aaa8000aaaa20a000000155551041555555177777baeeeee390000020aaaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 4], 0xc30c30011041451880070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880001850411040001850870880c30c30010471041840000880000c30411450821861c41080c30c30010451041840021c81041040010c31c7186005088, 0x555544cd5555547fffe013777723aeeee3f90000020aaaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 5], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041850010c31c71860080880000c30411070001890880880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x2555704cd5555545555c685777743aeeeeff90000020aaaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 6], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c31850011041c71860080880c30c30011071451890080880000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x2555c04cd55555455574685777543aeeefff90000020aaaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 7], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041850010c31c71860080880c30c30011071451890080880820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x2557104cd555554555d4685777543aeeecff90001820aaaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 8], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c31850011041c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x255c504cd55555455754685775543aeef0ff90007820aaaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 9], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041850010c31c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x2571504cd55555455d54685775543aeec0ff9001f820aaaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 10], 0xc30c30011041451890070881041040010c31451850070880c31850011041c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x25c5504cd55555457554685755543aef00ff9007f820aaaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 11], 0xc30c30011041451890070881041850010c31c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x2715504cd5555545d554685755543aec00ff901ff820aaaaaaa4aaabba9⟩,
  ⟨[0, 2, 2, 12], 0xc31850011041c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c3145185007088, 0x2c555044d55555475554695555543af000ff907ff820aaaaaaa4aaabba9⟩,
  ⟨[0, 4, 2, 6], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080490411c60021040411c70080c91020c40020481421c50020490000c50421040001c72060c91020410020c51821c10002090410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x15551a00aaaaaa8aaae092bbb87b05777773a0005574555555400031b82aaabaa9⟩,
]
private theorem group4_1_ok : group4_1.all (checkFast 4 13) = true := by decide +kernel
private def group4_2 : List FastCert := [
  ⟨[0, 5, 2, 7], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080490411c60021450411c70080c91020c40020481421c50020491420000421041821c62080c90000c60421440001c70482091020410020c61421c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x10002aaaaaa8aab8f12bbb9e705771d73a00155745555554000c5b82aaadaa9⟩,
  ⟨[0, 6, 2, 8], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080490411c60021040411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082090000c50421040001c70460c91020410020c51821c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x40002aaaaaa8aae2892bb87bb05777773a0054574555555400319b82aab3aa9⟩,
  ⟨[0, 7, 2, 9], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080490411c60021450411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082091420410021041821c60080c90000c60421440001c70480c91020410020c61421c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x100002aaaaaa8ab8af12bb9ee70571dd73a0151574555555400c69b82aacbaa9⟩,
  ⟨[0, 8, 2, 10], 0x1421430021041821c60080491021030021451821c60080490411c60021040411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082091420410021041821c60080c91820410021442021c700a0c90000c50421840001c90480c91020410020c51821c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x1000000000000402002aaaaaa8ae2bc92b87bbb05777573a05455745555554031a9b82ab2baa9⟩,
  ⟨[0, 9, 2, 11], 0x1421430021041821c60080490411c60021450411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082091420410021041821c60080c91820410021442021c700a0c91420410021842021c800a0c90000c60421440001c90480c91020410020c61421c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x500000000000100a002aaaaaa8b8af712b9eee7051dd573a151557455555540c6a9b82acabaa9⟩,
  ⟨[0, 10, 2, 12], 0x411850021040411850070c81020c40020471421860020481420000421041421861c70c810204100214324218600a1c814204100210414218a0090c81c20410021441c21860090c81420410021c41421880090c81c20410021441c21860090c80000c50421c40001880490c81020410020c51c21810000c80410c50021040421880070c80c20410021450c21840021481020c40020c11421860070c8, 0x10000000eaa00000000004433344d5555546f332233775573a5455574555555431aa9b82b2abaa9⟩,
  ⟨[0, 11, 2, 0], 0x1820c30020451821030020471420000421831421081470c71820410021431821080071471420410021831421080070c71820410021431821080070c71420410021831421080070c71820410021431821080070c71420410021831421080070c70000c30421460001060471471420410020c31421010000c70410c30021460421060071470c20410021460c21040021470411040020c30411040050c7, 0x16eee8000ddddd61555555180008b0d55555406aa9bb2caabaa9⟩,
  ⟨[0, 12, 0, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000000000d00000802aaade4ffffd03555555165555445555554affffee52aaaba9⟩,
  ⟨[0, 12, 1, 1], 0x1c90000421851c91081c90c80c50410021c20c510a0091c81450410020c21451070060c81860410021421861080070c81450410021821451080070c81860410021421861080070c81450410021821451080070c81860410021421861080070c81450410021821451080070c80000c40421420001070460c80000c40420850001040410c80411030020850461030001481860c40020451861080070c8, 0x280000000000000d2aa808039989e4f3330035555551755554455555549aaaa5c32aaafa9⟩,
  ⟨[0, 12, 2, 1], 0x1c20000421851c21081c90c81420410021c31421080091c81820410021451821080070c81c20410021851c21080090c81820410021c51821080090c81c20410021851c21080090c81820410021c51821080090c81c20410021851c21080090c80000c40421c50001080490c81820410020c51821010000c80410c40021850421080070c80411030021450411030021481820c40020451821040020c8, 0x28aaa0000000000db7748026ee9a60c0000035555551455554455555541aaa9bc32aabaa9⟩,
  ⟨[0, 12, 3, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000000000d00000802aaede4fffdd03555555165555445555554affffee52aaaba9⟩,
  ⟨[0, 12, 4, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000000000d00000802abade4fff7d03555555165555445555554affffee52aaaba9⟩,
  ⟨[0, 12, 5, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000000000d00000802aeade4ffdfd03555555165555445555554affffee52aaaba9⟩,
  ⟨[0, 12, 6, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000000000d00000802baade4ff7fd03555555165555445555554affffee52aaaba9⟩,
  ⟨[0, 12, 7, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000000000d00000802eaade4fdffd03555555165555445555554affffee52aaaba9⟩,
  ⟨[0, 12, 8, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000000000d00000803aaade4f7ffd03555555165555445555554affffee52aaaba9⟩,
  ⟨[0, 12, 9, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000000000d00000806aaade4dfffd03555555165555445555554affffee52aaaba9⟩,
  ⟨[0, 12, 10, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821491070060c804104100208214510a0090c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2a8000000000000d000008022aade4ffffd03555555165555445555554affffee52aaaba9⟩,
  ⟨[0, 12, 11, 0], 0xc20c30421452021071860070410410020c31481090081870410410021451821090080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70000c30420410001071461470410410021860c21030001471421040020411821040030c7, 0x1d555400000000002aaa92a6aaa8355555551e0000d155555542ffffee42aaaba9⟩,
  ⟨[0, 12, 11, 1], 0x1c90000421851c91081c90c80410410021c20c910a0091c804104100208214510a0090c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2a0000000000000d00000800aaade43fffd03555555175555445555554affffee52aaaba9⟩,
  ⟨[0, 12, 11, 2], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80001450420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa0000000000000c000034a0aaa866aaaaaa30aaaa1a75555445555554affffee42aaaba9⟩,
  ⟨[0, 12, 11, 3], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480000c50420c60001481070c80410410020861c71430001081040c40020411861480070c8, 0xa0000000000000c000174a0aab866aaaaaa30aaae1a75557445555554affff2e42aaaba9⟩,
  ⟨[0, 12, 11, 4], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa0000000000000c000534a0aae066aaaaaa30aaba1a7555d445555554afffcee42aaaba9⟩,
  ⟨[0, 12, 11, 5], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa0000000000000c001434a0ab8866aaaaaa30aaea1a75575445555554afff3ee42aaaba9⟩,
]
private theorem group4_2_ok : group4_2.all (checkFast 4 13) = true := by decide +kernel
private def group4_3 : List FastCert := [
  ⟨[0, 12, 11, 6], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa0000000000000c005034a0ae2866aaaaaa30abaa1a755d5445555554affcfee42aaaba9⟩,
  ⟨[0, 12, 11, 7], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa0000000000000c014034a0b8a866aaaaaa30aeaa1a75755445555554aff3fee42aaaba9⟩,
  ⟨[0, 12, 11, 8], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa0000000000000c050034a0e2a866aaaaaa30baaa1a75d55445555554afcffee42aaaba9⟩,
  ⟨[0, 12, 11, 9], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa0000000000000c140034a18aa866aaaaaa30eaaa1a77555445555554af3ffee42aaaba9⟩,
  ⟨[0, 12, 11, 10], 0x1c70c50421041c71481860090410410021c60c814a0081890c61480020820c41480090490410410020c81041470060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90000c50420410001451040c90410410020861c71430001091040c40020411861480070c9, 0x44000000c200034a6aaa866aaaaaa30aaaa1a7d555445555554acfffee42aaaba9⟩,
  ⟨[0, 12, 11, 11], 0x1c20c50421041c21481860080491480021c60c91480091880410410020c810214a0090c80410410020c41821450070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80000c50420410001471060c80410410021861c21430001081020c40020411821480070c8, 0xa0000000000000d2aaa3821fffa66aaaaaa30d5541a755554455555542ffffee42aaaba9⟩,
  ⟨[0, 12, 11, 12], 0xc21470421040c21471860070410410020c71081440061870410410020c41821490080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70000c50420410001471060c70410410021862021430001071020c40020411821490080c7, 0x5555470000000002aaa92aaaaaaa3355541ad55554455555542ffffee42aaaba9⟩,
  ⟨[0, 12, 12, 0], 0xc20c30421452081071860070410410020c31421090081870410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70000c30420410001071461470410410021860c21030001471421040020411821040030c7, 0x1aaaaa01000000002aaa92a6aaa8355555551e0000d155555542ffffee42aaaba9⟩,
  ⟨[0, 12, 12, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x280000000000000d00000802aaade4ffffd03555555165555445555554affffee52aaaba9⟩,
  ⟨[0, 12, 12, 2], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80001450420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x80000000000000c000034a2aaa866aaaaaa32aaaa1a65555445555554affffee42aaaba9⟩,
  ⟨[0, 12, 12, 3], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480000c50420c60001481070c80410410020861c71430001081040c40020411861480070c8, 0x80000000000000c000174a2aab866aaaaaa32aaae1a65557445555554affff2e42aaaba9⟩,
  ⟨[0, 12, 12, 4], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x80000000000000c000534a2aae066aaaaaa32aaba1a6555d445555554afffcee42aaaba9⟩,
  ⟨[0, 12, 12, 5], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x80000000000000c001434a2ab8866aaaaaa32aaea1a65575445555554afff3ee42aaaba9⟩,
  ⟨[0, 12, 12, 6], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x80000000000000c005034a2ae2866aaaaaa32abaa1a655d5445555554affcfee42aaaba9⟩,
  ⟨[0, 12, 12, 7], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x80000000000000c014034a2b8a866aaaaaa32aeaa1a65755445555554aff3fee42aaaba9⟩,
  ⟨[0, 12, 12, 8], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x80000000000000c050034a2e2a866aaaaaa32baaa1a65d55445555554afcffee42aaaba9⟩,
  ⟨[0, 12, 12, 9], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x80000000000000c140034a38aa866aaaaaa32eaaa1a67555445555554af3ffee42aaaba9⟩,
  ⟨[0, 12, 12, 10], 0x1c70c50421041c71481860080410410021c61031480091880c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x80000000000000c500034a62aa866aaaaaa33aaaa1a6d555445555554acfffee42aaaba9⟩,
  ⟨[0, 12, 12, 11], 0x1c20c50421041c71481890080411480021c60c21480091880410410020c81021440060c80410410020c41821450070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80000c50420410001471060c80410410021861021430001881020c40020411c21450060c8, 0x280000000000000c15558ca3fffa26aaaaaa30d5543a755554455555542ffffee42aaaba9⟩,
  ⟨[0, 12, 12, 12], 0xc81470421040c81471860070410410020c71021490081870410410020c41821450080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70000c50420410001471060c70410410021862021430001071020c40020411821490080c7, 0x15555470000000002aaa92aaaaaaa3355541ad55554455555542ffffee42aaaba9⟩,
]
private theorem group4_3_ok : group4_3.all (checkFast 4 13) = true := by decide +kernel
private def certs4 := group4_0 ++ group4_1 ++ group4_2 ++ group4_3
private theorem valid4 : certs4.all (checkFast 4 13) = true := by simp only [certs4, List.all_append, group4_0_ok, group4_1_ok, group4_2_ok, group4_3_ok, Bool.and_true]
private theorem cover4 : ruledOut 13 (rest3) rest4 = certs4.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class4 : Classifies 4 13 rest4 :=
  classify_stepFast (by decide) (by decide) class3 valid4 cover4

private def rest5 : List (List Nat) := [[0, 0, 0, 0, 12], [0, 0, 3, 2, 0], [0, 0, 3, 2, 1], [0, 0, 3, 2, 2], [0, 0, 3, 2, 3], [0, 0, 3, 2, 4], [0, 0, 3, 2, 5], [0, 0, 3, 2, 6], [0, 0, 3, 2, 7], [0, 0, 3, 2, 8], [0, 0, 3, 2, 9], [0, 0, 3, 2, 10], [0, 0, 3, 2, 11], [0, 0, 3, 2, 12]]
private def group5_0 : List FastCert := [
  ⟨[0, 0, 0, 0, 0], 0x2060820000411c608b00b0c420608200628a1450870090c51040820c300010408804a0011040820c62491040880470052060821040001c60870440c02060821062431450850440452060820c30001c608704b1002060820c62841450890490452060821040001c608704b0c02060821062831450890490452060820c30001c608704b1002060820c62841450890490452060821040001c608704b0c02060821062831450890490452060820c30001c608704b1002060820c62841450890490452060821040001c608704b0c02060821062831450890490452060820c30001c608704b1002060820c62841450890490450000411040c300008810a0c30000411062430000881070c50c30820000410c30820001040c30820060410c30820001051c60870c61042060880c30011c60870c61041460850c3005, 0x82aaa01880002045000107bfffe8a455550d55555540000000668888811111134d5555546000038480001a1⟩,
]
private theorem group5_0_ok : group5_0.all (checkFast 5 13) = true := by decide +kernel
private def certs5 := group5_0
private theorem valid5 : certs5.all (checkFast 5 13) = true := by exact group5_0_ok
private theorem cover5 : ruledOut 13 (rest4) rest5 = certs5.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class5 : Classifies 5 13 rest5 :=
  classify_stepFast (by decide) (by decide) class4 valid5 cover5

private def rest6 : List (List Nat) := []
private def certs6 := ([] : List FastCert)
private theorem valid6 : certs6.all (checkFast 6 13) = true := by rfl
private theorem cover6 : ruledOut 13 (rest5) rest6 = certs6.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class6 : Classifies 6 13 rest6 :=
  classify_stepFast (by decide) (by decide) class5 valid6 cover6

theorem good13 {a : Nat → Nat} (ha : Valid 6 13 a) : Good 6 13 a :=
  of_empty class6 ha
end PhaseFalls.Moduli.Data13

namespace PhaseFalls.Moduli
export Data13 (good13)
end PhaseFalls.Moduli

/-! ## FastData17 -/

/-! Generated by build_modulus_tables.py and repacked for `checkFast`. The kernel checks the rank tables and the coverage of the phase assignments. -/
namespace PhaseFalls.Moduli.Data17
set_option maxRecDepth 80000
set_option maxHeartbeats 0

private def rest3 : List (List Nat) := [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 0, 3], [0, 0, 4], [0, 0, 5], [0, 0, 6], [0, 0, 7], [0, 0, 8], [0, 0, 9], [0, 0, 10], [0, 0, 11], [0, 0, 12], [0, 0, 13], [0, 0, 14], [0, 0, 15], [0, 0, 16], [0, 1, 2], [0, 2, 2], [0, 3, 2], [0, 4, 2], [0, 5, 2], [0, 6, 2], [0, 7, 2], [0, 8, 2], [0, 9, 2], [0, 10, 2], [0, 11, 2], [0, 12, 2], [0, 13, 2], [0, 14, 2], [0, 15, 2], [0, 16, 0], [0, 16, 1], [0, 16, 2], [0, 16, 3], [0, 16, 4], [0, 16, 5], [0, 16, 6], [0, 16, 7], [0, 16, 8], [0, 16, 9], [0, 16, 10], [0, 16, 11], [0, 16, 12], [0, 16, 13], [0, 16, 14], [0, 16, 15], [0, 16, 16]]
private def group3_0 : List FastCert := [
  ⟨[0, 1, 0], 0x10850040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146004083004146, 0x515555555500000000f02aaaaaaaa3fffffff83ffffffed8⟩,
  ⟨[0, 1, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060040810c4146001086004146, 0x515555555500000000f02aaaaaaaa3fffffffb3ffffffef8⟩,
  ⟨[0, 1, 3], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860040830040460410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3ffffff3b3ffffffed8⟩,
  ⟨[0, 1, 4], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860040830040460010850040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3fffffcfb3ffffffed8⟩,
  ⟨[0, 1, 5], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860040830040460010850040860010830040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3fffff3fb3ffffffed8⟩,
  ⟨[0, 1, 6], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860040830040460010850040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3ffffcffb3ffffffed8⟩,
  ⟨[0, 1, 7], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860040830040460010850040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3ffff3ffb3ffffffed8⟩,
  ⟨[0, 1, 8], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860040830040460010850040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3fffcfffb3ffffffed8⟩,
  ⟨[0, 1, 9], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860040830040460010850040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3fff3fffb3ffffffed8⟩,
  ⟨[0, 1, 10], 0x10830040860010830040860010830040860010830040860010830040860010830040860040830040460010850040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3ffcffffb3ffffffed8⟩,
  ⟨[0, 1, 11], 0x10830040860010830040860010830040860010830040860010830040860040830040460010850040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3ff3ffffb3ffffffed8⟩,
  ⟨[0, 1, 12], 0x10830040860010830040860010830040860010830040860040830040460010850040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3fcfffffb3ffffffed8⟩,
  ⟨[0, 1, 13], 0x10830040860010830040860010830040860040830040460010850040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3f3fffffb3ffffffed8⟩,
  ⟨[0, 1, 14], 0x10830040860010830040860040830040460010850040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa3cffffffb3ffffffed8⟩,
  ⟨[0, 1, 15], 0x10830040860040830040460010850040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860410850c40060c00810c4146001083004146, 0x515555555500000000f02aaaaaaaa33ffffffb3ffffffed8⟩,
  ⟨[0, 1, 16], 0x40820040460010850040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60410820c40060c00810c4146001083004146, 0x515555555501555555f05555555544fffffffb3ffffffed8⟩,
  ⟨[0, 2, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c1005187, 0x22aaaaaaaa00000001a0aaaaaaaa8aaaaaaaa02aaaaaab81fffffff78⟩,
  ⟨[0, 2, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860430850440060400850c40860040810040c6001086004146, 0x115555555500000002d02aaaaaaaa2aaaaaaf21ffffffb78⟩,
  ⟨[0, 2, 3], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c6001082004146, 0x1115555555505555554d05555555546aaaaaa7a1fffffff78⟩,
  ⟨[0, 2, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8aaaaaa8a02aaaaa9ba1fffffff78⟩,
  ⟨[0, 2, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8aaaaaa2a02aaaaa6ba1fffffff78⟩,
  ⟨[0, 2, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8aaaaa8aa02aaaa9aba1fffffff78⟩,
  ⟨[0, 2, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8aaaaa2aa02aaaa6aba1fffffff78⟩,
  ⟨[0, 2, 8], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8aaaa8aaa02aaa9aaba1fffffff78⟩,
]
private theorem group3_0_ok : group3_0.all (checkFast 3 17) = true := by decide +kernel
private def group3_1 : List FastCert := [
  ⟨[0, 2, 9], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8aaaa2aaa02aaa6aaba1fffffff78⟩,
  ⟨[0, 2, 10], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8aaa8aaaa02aa9aaaba1fffffff78⟩,
  ⟨[0, 2, 11], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8aaa2aaaa02aa6aaaba1fffffff78⟩,
  ⟨[0, 2, 12], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8aa8aaaaa02a9aaaaba1fffffff78⟩,
  ⟨[0, 2, 13], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8aa2aaaaa02a6aaaaba1fffffff78⟩,
  ⟨[0, 2, 14], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8a8aaaaaa029aaaaaba1fffffff78⟩,
  ⟨[0, 2, 15], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa8a2aaaaaa026aaaaaba1fffffff78⟩,
  ⟨[0, 2, 16], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c2005187, 0x22aaaaaaaa00000001a0aaaaaaaa88aaaaaaa01aaaaaaba1fffffff78⟩,
  ⟨[0, 3, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070050c1005187, 0x22aaaaaaaa00000006a0aaaaaaaa8aaaaaaa802aaaaaaf81ffffffd78⟩,
  ⟨[0, 3, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6004081004086001086004146, 0x115555555500000003402aaaaaaaa2aaaaaae21ffffffdf8⟩,
  ⟨[0, 3, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070400c60451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8aaaaaab802aaaaaa3a1ffffffb78⟩,
  ⟨[0, 3, 4], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460400820440c60010820040c6001082004146, 0x4115555555505555553505555555546aaaaa9fa1ffffffd78⟩,
  ⟨[0, 3, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8aaaaaa2802aaaaa6fa1ffffffd78⟩,
  ⟨[0, 3, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8aaaaa8a802aaaa9afa1ffffffd78⟩,
  ⟨[0, 3, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8aaaaa2a802aaaa6afa1ffffffd78⟩,
  ⟨[0, 3, 8], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8aaaa8aa802aaa9aafa1ffffffd78⟩,
  ⟨[0, 3, 9], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8aaaa2aa802aaa6aafa1ffffffd78⟩,
  ⟨[0, 3, 10], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8aaa8aaa802aa9aaafa1ffffffd78⟩,
  ⟨[0, 3, 11], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8aaa2aaa802aa6aaafa1ffffffd78⟩,
  ⟨[0, 3, 12], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8aa8aaaa802a9aaaafa1ffffffd78⟩,
  ⟨[0, 3, 13], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8aa2aaaa802a6aaaafa1ffffffd78⟩,
  ⟨[0, 3, 14], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8a8aaaaa8029aaaaafa1ffffffd78⟩,
  ⟨[0, 3, 15], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa8a2aaaaa8026aaaaafa1ffffffd78⟩,
  ⟨[0, 3, 16], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870400c20451070010c20051070010c2005187, 0x22aaaaaaaa00000006a0aaaaaaaa88aaaaaa801aaaaaafa1ffffffd78⟩,
]
private theorem group3_1_ok : group3_1.all (checkFast 3 17) = true := by decide +kernel
private def group3_2 : List FastCert := [
  ⟨[0, 4, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070050c1005187, 0x22aaaaaaaa0000001a20aaaaaaaa8aaaaaaa202aaaaabb81ffffff778⟩,
  ⟨[0, 4, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086004081004086001086004146, 0x11555555550000000d002aaaaaaaa2aaaaaba21ffffff7f8⟩,
  ⟨[0, 4, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070400c60450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8aaaaaaa202aaaaab3a1ffffff778⟩,
  ⟨[0, 4, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8aaaaaae202aaaaa8ba1fffffef78⟩,
  ⟨[0, 4, 5], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60400820440c60010820040c6001082004146, 0x1011555555550555554d505555555546aaaaa7ba1ffffff778⟩,
  ⟨[0, 4, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8aaaaa8a202aaaa9bba1ffffff778⟩,
  ⟨[0, 4, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8aaaaa2a202aaaa6bba1ffffff778⟩,
  ⟨[0, 4, 8], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8aaaa8aa202aaa9abba1ffffff778⟩,
  ⟨[0, 4, 9], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8aaaa2aa202aaa6abba1ffffff778⟩,
  ⟨[0, 4, 10], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8aaa8aaa202aa9aabba1ffffff778⟩,
  ⟨[0, 4, 11], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8aaa2aaa202aa6aabba1ffffff778⟩,
  ⟨[0, 4, 12], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8aa8aaaa202a9aaabba1ffffff778⟩,
  ⟨[0, 4, 13], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8aa2aaaa202a6aaabba1ffffff778⟩,
  ⟨[0, 4, 14], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8a8aaaaa2029aaaabba1ffffff778⟩,
  ⟨[0, 4, 15], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa8a2aaaaa2026aaaabba1ffffff778⟩,
  ⟨[0, 4, 16], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000001a20aaaaaaaa88aaaaaa201aaaaabba1ffffff778⟩,
  ⟨[0, 5, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaaaa0000006820aaaaaaaa8aaaaaa8a02aaaaaeb81fffffdf78⟩,
  ⟨[0, 5, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086004081004086001086004146, 0x115555555500000034002aaaaaaaa2aaaaaea21fffffdff8⟩,
  ⟨[0, 5, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8aaaaaa8202aaaaae7a1fffffdf78⟩,
  ⟨[0, 5, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8aaaaaa8a02aaaaacba1fffffdf78⟩,
  ⟨[0, 5, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8aaaaab8a02aaaaa2ba1fffffbf78⟩,
  ⟨[0, 5, 6], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60400820440c60010820040c6001082004146, 0x40115555555505555535505555555546aaaa9eba1fffffdf78⟩,
  ⟨[0, 5, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8aaaaa28a02aaaa6eba1fffffdf78⟩,
  ⟨[0, 5, 8], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8aaaa8a8a02aaa9aeba1fffffdf78⟩,
]
private theorem group3_2_ok : group3_2.all (checkFast 3 17) = true := by decide +kernel
private def group3_3 : List FastCert := [
  ⟨[0, 5, 9], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8aaaa2a8a02aaa6aeba1fffffdf78⟩,
  ⟨[0, 5, 10], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8aaa8aa8a02aa9aaeba1fffffdf78⟩,
  ⟨[0, 5, 11], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8aaa2aa8a02aa6aaeba1fffffdf78⟩,
  ⟨[0, 5, 12], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8aa8aaa8a02a9aaaeba1fffffdf78⟩,
  ⟨[0, 5, 13], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8aa2aaa8a02a6aaaeba1fffffdf78⟩,
  ⟨[0, 5, 14], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8a8aaaa8a029aaaaeba1fffffdf78⟩,
  ⟨[0, 5, 15], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa8a2aaaa8a026aaaaeba1fffffdf78⟩,
  ⟨[0, 5, 16], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000006820aaaaaaaa88aaaaa8a01aaaaaeba1fffffdf78⟩,
  ⟨[0, 6, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaaaa000001a020aaaaaaaa8aaaaaa2a02aaaabab81fffff7f78⟩,
  ⟨[0, 6, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086004081004086001086004146, 0x1155555555000000d0002aaaaaaaa2aaaabaa21fffff7ff8⟩,
  ⟨[0, 6, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8aaaaaa2202aaaaba7a1fffff7f78⟩,
  ⟨[0, 6, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8aaaaaa0a02aaaab9ba1fffff7f78⟩,
  ⟨[0, 6, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8aaaaaa2a02aaaab2ba1fffff7f78⟩,
  ⟨[0, 6, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8aaaaae2a02aaaa8aba1ffffeff78⟩,
  ⟨[0, 6, 7], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x1001155555555055554d5505555555546aaaa7aba1fffff7f78⟩,
  ⟨[0, 6, 8], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8aaaa8a2a02aaa9baba1fffff7f78⟩,
  ⟨[0, 6, 9], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8aaaa2a2a02aaa6baba1fffff7f78⟩,
  ⟨[0, 6, 10], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8aaa8aa2a02aa9ababa1fffff7f78⟩,
  ⟨[0, 6, 11], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8aaa2aa2a02aa6ababa1fffff7f78⟩,
  ⟨[0, 6, 12], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8aa8aaa2a02a9aababa1fffff7f78⟩,
  ⟨[0, 6, 13], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8aa2aaa2a02a6aababa1fffff7f78⟩,
  ⟨[0, 6, 14], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8a8aaaa2a029aaababa1fffff7f78⟩,
  ⟨[0, 6, 15], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa8a2aaaa2a026aaababa1fffff7f78⟩,
  ⟨[0, 6, 16], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa000001a020aaaaaaaa88aaaaa2a01aaaababa1fffff7f78⟩,
]
private theorem group3_3_ok : group3_3.all (checkFast 3 17) = true := by decide +kernel
private def group3_4 : List FastCert := [
  ⟨[0, 7, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaaaa0000068020aaaaaaaa8aaaaa8aa02aaaaeab81ffffdff78⟩,
  ⟨[0, 7, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086004081004086001086004146, 0x115555555500000340002aaaaaaaa2aaaaeaa21ffffdfff8⟩,
  ⟨[0, 7, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8aaaaa8a202aaaaea7a1ffffdff78⟩,
  ⟨[0, 7, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8aaaaa88a02aaaae9ba1ffffdff78⟩,
  ⟨[0, 7, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8aaaaa82a02aaaae6ba1ffffdff78⟩,
  ⟨[0, 7, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8aaaaa8aa02aaaacaba1ffffdff78⟩,
  ⟨[0, 7, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8aaaab8aa02aaaa2aba1ffffbff78⟩,
  ⟨[0, 7, 8], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x400115555555505555355505555555546aaa9eaba1ffffdff78⟩,
  ⟨[0, 7, 9], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8aaaa28aa02aaa6eaba1ffffdff78⟩,
  ⟨[0, 7, 10], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8aaa8a8aa02aa9aeaba1ffffdff78⟩,
  ⟨[0, 7, 11], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8aaa2a8aa02aa6aeaba1ffffdff78⟩,
  ⟨[0, 7, 12], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8aa8aa8aa02a9aaeaba1ffffdff78⟩,
  ⟨[0, 7, 13], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8aa2aa8aa02a6aaeaba1ffffdff78⟩,
  ⟨[0, 7, 14], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8a8aaa8aa029aaaeaba1ffffdff78⟩,
  ⟨[0, 7, 15], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa8a2aaa8aa026aaaeaba1ffffdff78⟩,
  ⟨[0, 7, 16], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000068020aaaaaaaa88aaaa8aa01aaaaeaba1ffffdff78⟩,
  ⟨[0, 8, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaaaa00001a0020aaaaaaaa8aaaaa2aa02aaabaab81ffff7ff78⟩,
  ⟨[0, 8, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x115555555500000d00002aaaaaaaa2aaabaaa21ffff7fff8⟩,
  ⟨[0, 8, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8aaaaa2a202aaabaa7a1ffff7ff78⟩,
  ⟨[0, 8, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8aaaaa28a02aaaba9ba1ffff7ff78⟩,
  ⟨[0, 8, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8aaaaa22a02aaaba6ba1ffff7ff78⟩,
  ⟨[0, 8, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8aaaaa0aa02aaab9aba1ffff7ff78⟩,
  ⟨[0, 8, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8aaaaa2aa02aaab2aba1ffff7ff78⟩,
  ⟨[0, 8, 8], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8aaaae2aa02aaa8aaba1fffefff78⟩,
]
private theorem group3_4_ok : group3_4.all (checkFast 3 17) = true := by decide +kernel
private def group3_5 : List FastCert := [
  ⟨[0, 8, 9], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x1000115555555505554d55505555555546aaa7aaba1ffff7ff78⟩,
  ⟨[0, 8, 10], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8aaa8a2aa02aa9baaba1ffff7ff78⟩,
  ⟨[0, 8, 11], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8aaa2a2aa02aa6baaba1ffff7ff78⟩,
  ⟨[0, 8, 12], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8aa8aa2aa02a9abaaba1ffff7ff78⟩,
  ⟨[0, 8, 13], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8aa2aa2aa02a6abaaba1ffff7ff78⟩,
  ⟨[0, 8, 14], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8a8aaa2aa029aabaaba1ffff7ff78⟩,
  ⟨[0, 8, 15], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa8a2aaa2aa026aabaaba1ffff7ff78⟩,
  ⟨[0, 8, 16], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa00001a0020aaaaaaaa88aaaa2aa01aaabaaba1ffff7ff78⟩,
  ⟨[0, 9, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaaaa0000680020aaaaaaaa8aaaa8aaa02aaaeaab81fffdfff78⟩,
  ⟨[0, 9, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x115555555500003400002aaaaaaaa2aaaeaaa21fffdffff8⟩,
  ⟨[0, 9, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8aaaa8aa202aaaeaa7a1fffdfff78⟩,
  ⟨[0, 9, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8aaaa8a8a02aaaea9ba1fffdfff78⟩,
  ⟨[0, 9, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8aaaa8a2a02aaaea6ba1fffdfff78⟩,
  ⟨[0, 9, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8aaaa88aa02aaae9aba1fffdfff78⟩,
  ⟨[0, 9, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8aaaa82aa02aaae6aba1fffdfff78⟩,
  ⟨[0, 9, 8], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8aaaa8aaa02aaacaaba1fffdfff78⟩,
  ⟨[0, 9, 9], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8aaab8aaa02aaa2aaba1fffbfff78⟩,
  ⟨[0, 9, 10], 0x10820040c60010820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x4000115555555505553555505555555546aa9eaaba1fffdfff78⟩,
  ⟨[0, 9, 11], 0x10c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8aaa28aaa02aa6eaaba1fffdfff78⟩,
  ⟨[0, 9, 12], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8aa8a8aaa02a9aeaaba1fffdfff78⟩,
  ⟨[0, 9, 13], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8aa2a8aaa02a6aeaaba1fffdfff78⟩,
  ⟨[0, 9, 14], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8a8aa8aaa029aaeaaba1fffdfff78⟩,
  ⟨[0, 9, 15], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa8a2aa8aaa026aaeaaba1fffdfff78⟩,
  ⟨[0, 9, 16], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0000680020aaaaaaaa88aaa8aaa01aaaeaaba1fffdfff78⟩,
]
private theorem group3_5_ok : group3_5.all (checkFast 3 17) = true := by decide +kernel
private def group3_6 : List FastCert := [
  ⟨[0, 10, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaaaa0001a00020aaaaaaaa8aaaa2aaa02aabaaab81fff7fff78⟩,
  ⟨[0, 10, 1], 0x10830040860010830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x11555555550000d000002aaaaaaaa2aabaaaa21fff7ffff8⟩,
  ⟨[0, 10, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8aaaa2aa202aabaaa7a1fff7fff78⟩,
  ⟨[0, 10, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8aaaa2a8a02aabaa9ba1fff7fff78⟩,
  ⟨[0, 10, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8aaaa2a2a02aabaa6ba1fff7fff78⟩,
  ⟨[0, 10, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8aaaa28aa02aaba9aba1fff7fff78⟩,
  ⟨[0, 10, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8aaaa22aa02aaba6aba1fff7fff78⟩,
  ⟨[0, 10, 8], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8aaaa0aaa02aab9aaba1fff7fff78⟩,
  ⟨[0, 10, 9], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8aaaa2aaa02aab2aaba1fff7fff78⟩,
  ⟨[0, 10, 10], 0x10c30050870010c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8aaae2aaa02aa8aaaba1ffeffff78⟩,
  ⟨[0, 10, 11], 0x10820040c60010820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x1000011555555550554d555505555555546aa7aaaba1fff7fff78⟩,
  ⟨[0, 10, 12], 0x10c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8aa8a2aaa02a9baaaba1fff7fff78⟩,
  ⟨[0, 10, 13], 0x10c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8aa2a2aaa02a6baaaba1fff7fff78⟩,
  ⟨[0, 10, 14], 0x10c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8a8aa2aaa029abaaaba1fff7fff78⟩,
  ⟨[0, 10, 15], 0x10c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa8a2aa2aaa026abaaaba1fff7fff78⟩,
  ⟨[0, 10, 16], 0x50c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0001a00020aaaaaaaa88aaa2aaa01aabaaaba1fff7fff78⟩,
  ⟨[0, 11, 0], 0x10c60050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaaaa0006800020aaaaaaaa8aaa8aaaa02aaeaaab81ffdffff78⟩,
  ⟨[0, 11, 1], 0x10830040860010830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x115555555500034000002aaaaaaaa2aaeaaaa21ffdfffff8⟩,
  ⟨[0, 11, 3], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8aaa8aaa202aaeaaa7a1ffdffff78⟩,
  ⟨[0, 11, 4], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8aaa8aa8a02aaeaa9ba1ffdffff78⟩,
  ⟨[0, 11, 5], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8aaa8aa2a02aaeaa6ba1ffdffff78⟩,
  ⟨[0, 11, 6], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8aaa8a8aa02aaea9aba1ffdffff78⟩,
  ⟨[0, 11, 7], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8aaa8a2aa02aaea6aba1ffdffff78⟩,
  ⟨[0, 11, 8], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8aaa88aaa02aae9aaba1ffdffff78⟩,
]
private theorem group3_6_ok : group3_6.all (checkFast 3 17) = true := by decide +kernel
private def group3_7 : List FastCert := [
  ⟨[0, 11, 9], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8aaa82aaa02aae6aaba1ffdffff78⟩,
  ⟨[0, 11, 10], 0x10c30050870010c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8aaa8aaaa02aacaaaba1ffdffff78⟩,
  ⟨[0, 11, 11], 0x10c30050870010c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8aab8aaaa02aa2aaaba1ffbffff78⟩,
  ⟨[0, 11, 12], 0x10820040c60010820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x40000115555555505535555505555555546a9eaaaba1ffdffff78⟩,
  ⟨[0, 11, 13], 0x10c30050870010c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8aa28aaaa02a6eaaaba1ffdffff78⟩,
  ⟨[0, 11, 14], 0x10c30050870010c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8a8a8aaaa029aeaaaba1ffdffff78⟩,
  ⟨[0, 11, 15], 0x10c30050870050c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa8a2a8aaaa026aeaaaba1ffdffff78⟩,
  ⟨[0, 11, 16], 0x50c20050470010c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0006800020aaaaaaaa88aa8aaaa01aaeaaaba1ffdffff78⟩,
  ⟨[0, 12, 0], 0x10c60050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaaaa001a000020aaaaaaaa8aaa2aaaa02abaaaab81ff7ffff78⟩,
  ⟨[0, 12, 1], 0x10830040860010830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x1155555555000d0000002aaaaaaaa2abaaaaa21ff7fffff8⟩,
  ⟨[0, 12, 3], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8aaa2aaa202abaaaa7a1ff7ffff78⟩,
  ⟨[0, 12, 4], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8aaa2aa8a02abaaa9ba1ff7ffff78⟩,
  ⟨[0, 12, 5], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8aaa2aa2a02abaaa6ba1ff7ffff78⟩,
  ⟨[0, 12, 6], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8aaa2a8aa02abaa9aba1ff7ffff78⟩,
  ⟨[0, 12, 7], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8aaa2a2aa02abaa6aba1ff7ffff78⟩,
  ⟨[0, 12, 8], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8aaa28aaa02aba9aaba1ff7ffff78⟩,
  ⟨[0, 12, 9], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8aaa22aaa02aba6aaba1ff7ffff78⟩,
  ⟨[0, 12, 10], 0x10c30050870010c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8aaa0aaaa02ab9aaaba1ff7ffff78⟩,
  ⟨[0, 12, 11], 0x10c30050870010c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8aaa2aaaa02ab2aaaba1ff7ffff78⟩,
  ⟨[0, 12, 12], 0x10c30050870010c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8aae2aaaa02a8aaaaba1fefffff78⟩,
  ⟨[0, 12, 13], 0x10820040c60010820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x1000001155555555054d5555505555555546a7aaaaba1ff7ffff78⟩,
  ⟨[0, 12, 14], 0x10c30050870010c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8a8a2aaaa029baaaaba1ff7ffff78⟩,
  ⟨[0, 12, 15], 0x10c30050870050c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa8a2a2aaaa026baaaaba1ff7ffff78⟩,
  ⟨[0, 12, 16], 0x50c20050470010c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa001a000020aaaaaaaa88aa2aaaa01abaaaaba1ff7ffff78⟩,
]
private theorem group3_7_ok : group3_7.all (checkFast 3 17) = true := by decide +kernel
private def group3_8 : List FastCert := [
  ⟨[0, 13, 0], 0x10c60050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaaaa0068000020aaaaaaaa8aa8aaaaa02aeaaaab81fdfffff78⟩,
  ⟨[0, 13, 1], 0x10830040860010830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x115555555500340000002aaaaaaaa2aeaaaaa21fdffffff8⟩,
  ⟨[0, 13, 3], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8aa8aaaa202aeaaaa7a1fdfffff78⟩,
  ⟨[0, 13, 4], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8aa8aaa8a02aeaaa9ba1fdfffff78⟩,
  ⟨[0, 13, 5], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8aa8aaa2a02aeaaa6ba1fdfffff78⟩,
  ⟨[0, 13, 6], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8aa8aa8aa02aeaa9aba1fdfffff78⟩,
  ⟨[0, 13, 7], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8aa8aa2aa02aeaa6aba1fdfffff78⟩,
  ⟨[0, 13, 8], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8aa8a8aaa02aea9aaba1fdfffff78⟩,
  ⟨[0, 13, 9], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8aa8a2aaa02aea6aaba1fdfffff78⟩,
  ⟨[0, 13, 10], 0x10c30050870010c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8aa88aaaa02ae9aaaba1fdfffff78⟩,
  ⟨[0, 13, 11], 0x10c30050870010c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8aa82aaaa02ae6aaaba1fdfffff78⟩,
  ⟨[0, 13, 12], 0x10c30050870010c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8aa8aaaaa02acaaaaba1fdfffff78⟩,
  ⟨[0, 13, 13], 0x10c30050870010c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8ab8aaaaa02a2aaaaba1fbfffff78⟩,
  ⟨[0, 13, 14], 0x10820040c60010820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x4000001155555555053555555055555555469eaaaaba1fdfffff78⟩,
  ⟨[0, 13, 15], 0x10c30050870050c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa8a28aaaaa026eaaaaba1fdfffff78⟩,
  ⟨[0, 13, 16], 0x50c20050470010c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0068000020aaaaaaaa88a8aaaaa01aeaaaaba1fdfffff78⟩,
  ⟨[0, 14, 0], 0x10c60050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa2aaaaa02baaaaab81f7fffff78⟩,
  ⟨[0, 14, 1], 0x10830040860010830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x115555555500d00000002aaaaaaaa2baaaaaa21f7ffffff8⟩,
  ⟨[0, 14, 3], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa2aaaa202baaaaa7a1f7fffff78⟩,
  ⟨[0, 14, 4], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa2aaa8a02baaaa9ba1f7fffff78⟩,
  ⟨[0, 14, 5], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa2aaa2a02baaaa6ba1f7fffff78⟩,
  ⟨[0, 14, 6], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa2aa8aa02baaa9aba1f7fffff78⟩,
  ⟨[0, 14, 7], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa2aa2aa02baaa6aba1f7fffff78⟩,
  ⟨[0, 14, 8], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa2a8aaa02baa9aaba1f7fffff78⟩,
]
private theorem group3_8_ok : group3_8.all (checkFast 3 17) = true := by decide +kernel
private def group3_9 : List FastCert := [
  ⟨[0, 14, 9], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa2a2aaa02baa6aaba1f7fffff78⟩,
  ⟨[0, 14, 10], 0x10c30050870010c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa28aaaa02ba9aaaba1f7fffff78⟩,
  ⟨[0, 14, 11], 0x10c30050870010c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa22aaaa02ba6aaaba1f7fffff78⟩,
  ⟨[0, 14, 12], 0x10c30050870010c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa0aaaaa02b9aaaaba1f7fffff78⟩,
  ⟨[0, 14, 13], 0x10c30050870010c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8aa2aaaaa02b2aaaaba1f7fffff78⟩,
  ⟨[0, 14, 14], 0x10c30050870010c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa8ae2aaaaa028aaaaaba1effffff78⟩,
  ⟨[0, 14, 15], 0x10820040c60040820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x1000000115555555504d555555055555555467aaaaaba1f7fffff78⟩,
  ⟨[0, 14, 16], 0x50c20050470010c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa01a0000020aaaaaaaa88a2aaaaa01baaaaaba1f7fffff78⟩,
  ⟨[0, 15, 0], 0x10c60050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070050c1005187, 0x22aaaaaaaa0680000020aaaaaaaa8a8aaaaaa02eaaaaab81dffffff78⟩,
  ⟨[0, 15, 1], 0x10830040860400850c40860010850040c6001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086001083004086004081004086001086004146, 0x115555555503400000002aaaaaaaa2eaaaaaa21dfffffff8⟩,
  ⟨[0, 15, 3], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470400c60450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a8aaaaa202eaaaaa7a1dffffff78⟩,
  ⟨[0, 15, 4], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a8aaaa8a02eaaaa9ba1dffffff78⟩,
  ⟨[0, 15, 5], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a8aaaa2a02eaaaa6ba1dffffff78⟩,
  ⟨[0, 15, 6], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a8aaa8aa02eaaa9aba1dffffff78⟩,
  ⟨[0, 15, 7], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a8aaa2aa02eaaa6aba1dffffff78⟩,
  ⟨[0, 15, 8], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a8aa8aaa02eaa9aaba1dffffff78⟩,
  ⟨[0, 15, 9], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a8aa2aaa02eaa6aaba1dffffff78⟩,
  ⟨[0, 15, 10], 0x10c30050870400c31050870010c20051070010c30050870010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a8a8aaaa02ea9aaaba1dffffff78⟩,
  ⟨[0, 15, 11], 0x10c30050870400c31050870010c20051070010c30050870010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a8a2aaaa02ea6aaaba1dffffff78⟩,
  ⟨[0, 15, 12], 0x10c30050870400c31050870010c20051070010c30050870050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a88aaaaa02e9aaaaba1dffffff78⟩,
  ⟨[0, 15, 13], 0x10c30050870400c31050870010c20051070050c20050470010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a82aaaaa02e6aaaaba1dffffff78⟩,
  ⟨[0, 15, 14], 0x10c30050870400c31050870050c10051070010c60050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8a8aaaaaa02caaaaaba1dffffff78⟩,
  ⟨[0, 15, 15], 0x10c30050870850c11050070010c60051070010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870010c30050870400c30450870010c20051070010c2005187, 0x22aaaaaaaa0680000020aaaaaaaa8b8aaaaaa022aaaaaba1bffffff78⟩,
  ⟨[0, 15, 16], 0x40820040460400860c41460010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60010820040c60400820440c60010820040c6001082004146, 0x4000000115555555503555555505555555545eaaaaaba1dffffff78⟩,
]
private theorem group3_9_ok : group3_9.all (checkFast 3 17) = true := by decide +kernel
private def certs3 := group3_0 ++ group3_1 ++ group3_2 ++ group3_3 ++ group3_4 ++ group3_5 ++ group3_6 ++ group3_7 ++ group3_8 ++ group3_9
private theorem valid3 : certs3.all (checkFast 3 17) = true := by simp only [certs3, List.all_append, group3_0_ok, group3_1_ok, group3_2_ok, group3_3_ok, group3_4_ok, group3_5_ok, group3_6_ok, group3_7_ok, group3_8_ok, group3_9_ok, Bool.and_true]
private theorem cover3 : ruledOut 17 (pairs 17) rest3 = certs3.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class3 : Classifies 3 17 rest3 :=
  classify_stepFast (by decide) (by decide) (pairs_classify 17) valid3 cover3

private def rest4 : List (List Nat) := [[0, 0, 0, 0], [0, 0, 0, 16], [0, 0, 2, 2], [0, 0, 3, 2], [0, 3, 2, 0], [0, 3, 2, 1], [0, 3, 2, 2], [0, 3, 2, 3], [0, 3, 2, 4], [0, 3, 2, 5], [0, 3, 2, 6], [0, 3, 2, 7], [0, 3, 2, 8], [0, 3, 2, 9], [0, 3, 2, 10], [0, 3, 2, 11], [0, 3, 2, 12], [0, 3, 2, 13], [0, 3, 2, 14], [0, 3, 2, 15], [0, 3, 2, 16]]
private def group4_0 : List FastCert := [
  ⟨[0, 0, 0, 1], 0x410410021820c310a0091870410410020821451040060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70000410820820001061450c71451030020411451030001871890000421452081081870c7, 0x20000000200aaaaaa0a00000000135555550e0ffffffdc3555555551c00000020d55555554bfffffffa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 2], 0x1470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21c50461050c6, 0xaaaaaaa0c0000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 0, 3], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470000410820c60001461040c71040c30020411041430001471890000421032081481870c7, 0x20000000202aaaaa80a00000000135555550615555555507fffffce1c00000320d55555554bffffff3a4aaaaaabb1⟩,
  ⟨[0, 0, 0, 4], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000000202aaaaa00a00000000135555540615555555507fffff6e1c00000c20d55555554bfffffcfa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 5], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000000202aaaa820a00000000135555510615555555507ffffdee1c00003020d55555554bfffff3fa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 6], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000000202aaaa0a0a00000000135555450615555555507ffff7ee1c0000c020d55555554bffffcffa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 7], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000000202aaa82a0a00000000135555150615555555507fffdfee1c00030020d55555554bffff3ffa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 8], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000000202aaa0aa0a00000000135554550615555555507fff7fee1c000c0020d55555554bfffcfffa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 9], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000000202aa82aa0a00000000135551550615555555507ffdffee1c00300020d55555554bfff3fffa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 10], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000000202aa0aaa0a00000000135545550615555555507ff7ffee1c00c00020d55555554bffcffffa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 11], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000000202a82aaa0a00000000135515550615555555507fdfffee1c03000020d55555554bff3ffffa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 12], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x20000000202a0aaaa0a00000000135455550615555555507f7fffee1c0c000020d55555554bfcfffffa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 13], 0x410410021820c314a0091870410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x2000000020282aaaa0a00000000135155550615555555507dffffee1c30000020d55555554bf3fffffa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 14], 0x410410021820c314a0091870410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421032081481870c7, 0x200000002020aaaaa0a000000001345555506155555555077ffffee1cc0000020d55555554bcffffffa4aaaaaabb1⟩,
  ⟨[0, 0, 0, 15], 0xc30410021820c314a0091881041440020c11c61450060481c70410021061c71480090c81040410021c224614800a0c818704100210218714a0090c81040410021821c71480090c81870410021021871480090c81040410021821c71480090c81870410021021871480090c81040410021821c71480090c81870410021021871480090c81040410021821c71480090c81870410021021871480090c81040410021821c71480090c80000410821020001481870c81040c30020411c71430001881890000421032491481870c8, 0x1000000011d55554320000000003cfffff74b16eeeeee2aaaaaaaa2777777772c00000020d55555554a2aaaaaa12aaaaaabb1⟩,
  ⟨[0, 0, 1, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 4, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 5, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 6, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 7, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 8, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 9, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 10, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 11, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
]
private theorem group4_0_ok : group4_0.all (checkFast 4 17) = true := by decide +kernel
private def group4_1 : List FastCert := [
  ⟨[0, 0, 12, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 13, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 14, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 15, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 16, 0], 0x410410020860c81440001870410410020821041490080c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70410410020821041450060c70000410820820001451040c71040c30020411041430001870001450421030001451860c7, 0x140000000000000000002aaaaa826aaaaaaaa37fffffee1c00000020d55555554bfffffffa4aaaaaabb9⟩,
  ⟨[0, 0, 16, 1], 0x410410021820c810a0091870410410020821451090080c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70410410020821451080060c70000410820820001061450c71451030020411451030001871890000421451881081870c7, 0x20000000208aaaaaa0a00000000125555550e0ffffffdc2aaaaaaaa8d55555544555555554bfffffffa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 2], 0x1470000821021470460c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71061070000821421070481070c61470000821021470480c71060000410821420000481070c60000410820820000410c31060c30410020820c30410001061050000820c21050461050c6, 0xaaaaaaa000000000003777777420eeeeeeeb8444444470d55555554aaaaaaaaa35555557b1⟩,
  ⟨[0, 0, 16, 3], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470000410820c60001461040c71040c30020411041430001471890000421031881481870c7, 0x20000000208aaaaa80a00000000125555550615555555507fffffce1c00000320d55555554bffffff3a4aaaaaabb1⟩,
  ⟨[0, 0, 16, 4], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000000208aaaaa00a00000000125555540615555555507fffff6e1c00000c20d55555554bfffffcfa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 5], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000000208aaaa820a00000000125555510615555555507ffffdee1c00003020d55555554bfffff3fa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 6], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000000208aaaa0a0a00000000125555450615555555507ffff7ee1c0000c020d55555554bffffcffa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 7], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000000208aaa82a0a00000000125555150615555555507fffdfee1c00030020d55555554bffff3ffa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 8], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000000208aaa0aa0a00000000125554550615555555507fff7fee1c000c0020d55555554bfffcfffa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 9], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000000208aa82aa0a00000000125551550615555555507ffdffee1c00300020d55555554bfff3fffa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 10], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000000208aa0aaa0a00000000125545550615555555507ff7ffee1c00c00020d55555554bffcffffa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 11], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000000208a82aaa0a00000000125515550615555555507fdfffee1c03000020d55555554bff3ffffa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 12], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x20000000208a0aaaa0a00000000125455550615555555507f7fffee1c0c000020d55555554bfcfffffa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 13], 0x410410021820c814a0091870410410020821041490080c70410410020821041480060c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x2000000020882aaaa0a00000000125155550615555555507dffffee1c30000020d55555554bf3fffffa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 14], 0x410410021820c814a0091870410410020821041490080c70c31440020820c31440060470410410020c61041460070c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70410410020821041480060c70000410820820001461040c71040c30020411041430001471890000421031881481870c7, 0x200000002080aaaaa0a000000001245555506155555555077ffffee1cc0000020d55555554bcffffffa4aaaaaabb1⟩,
  ⟨[0, 0, 16, 15], 0xc30410021820c71480071881041470020c11041470090481890410021071891450090c810404100218210414a0090c81870410021021871450070c81040410021821041480070c81870410021021871450070c81040410021821041480070c81870410021021871450070c81040410021821041480070c81870410021021871450070c81040410021821041480070c81870410021021871450070c81040410021821041480070c80000410821020001451870c81040c30020411041430001881870000421031871451870c8, 0xa8000000000000000080aaaaa8826eeeeeee2aaaaaaaa2666666661c00000020d55555554a2aaaaaa12aaaaaabb1⟩,
  ⟨[0, 0, 16, 16], 0xc91470021810c91470091880410410020c710414a0090c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80410410020821041470060c80000410820820001461040c81040c30020411041430001481870000421031871481870c8, 0x280000000000000000000000000825555550615555555507fffffee1c00000020d55555554afffffffa4aaaaaabb1⟩,
  ⟨[0, 1, 2, 3], 0x1c20430021851c21080090481420440021c31421080090481820430021451821080070481420440021831421080070481820430021451821080070481420440021831421080070481820430021451821080070481420440021831421080070481820430021451821080070481420440021831421080070481820430021451821080070481420440021831421080070480000c30421450001070461480421040020c30421040000c80c20440020450c21040020480420000421860421041431881820440020c3182104002148, 0x2800000000000000000daaaaa0000666662064cccccc0435555555518888888d0d555555541555557dd0aaaaabac9⟩,
  ⟨[0, 2, 2, 0], 0xc30c30011062081480090870820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70820820011042061480090c70000c30411040001490880870c30c30010442061480000870000c30411460821491c81070c30c30010461041440021c71041440010c3206148006087, 0x2aaaaa8000aaaaaa20a000000001155555104155555555155555543ac00000ff91fffff820aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 1], 0x820820011441c70c70061060820820011041450c80071060820820011041450c70061060820820011041450c70061060820820011041450c70061060820820011041450c70061060820820011041450c70061060820820011041450c70061060820820011041450c70061060820820011041450c70061060820820011041450c70061060820820011041450c70061060000c30411040000c70850861450c30010441450c30000860000c30411440820c71861061040c30010451040c30021861450c30011041450c7006086, 0x4555554450000000008fffffdc32000000061aaaaaaaa8ffffff820aaaaaaaaa4aaaaabba9⟩,
]
private theorem group4_1_ok : group4_1.all (checkFast 4 17) = true := by decide +kernel
private def group4_2 : List FastCert := [
  ⟨[0, 2, 2, 2], 0xc30c30011041451880070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880001450411040001850870c80c30c30010451041840000880801850411040821851c70c80c30c30011471041840021c81041040010c31c7186005088, 0x55555544cd555555547fffffe21377777733aeeeeee3390000002686aaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 3], 0xc30c30011042061480090871041040010c32061480090870c30c30011042061480090871041040010c32061480090870c30c30011042061480090871041040010c32061480090870c30c30011042061480090871041040010c32061480090870c30c30011042061480090871041040010c32061480090870c30c30011042061480090871041040010c32061480090870000c30411040001490880871041440010432061480000870001040411460821491c80c70c30c30010461041440021c71041040010c3206148006087, 0x2aaaaa8000aaaaaa20a00000000155555510415555555517777777baeeeeeee39000000020aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 4], 0xc30c30011041451880070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880c30c30011041451860070881041040010c31451860070880001850411040001850870880c30c30010471041840000880000c30411450821861c41080c30c30010451041840021c81041040010c31c7186005088, 0x55555544cd555555547fffffe01377777723aeeeeee3f9000000020aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 5], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041850010c31c71860080880000c30411070001890880880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x255555704cd55555554555555c68577777743aeeeeeeff9000000020aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 6], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c31850011041c71860080880c30c30011071451890080880000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x255555c04cd55555554555557468577777543aeeeeefff9000000020aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 7], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041850010c31c71860080880c30c30011071451890080880820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x255557104cd5555555455555d468577777543aeeeeecff9000001820aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 8], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c31850011041c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x25555c504cd55555554555575468577775543aeeeef0ff9000007820aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 9], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041850010c31c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x255571504cd555555545555d5468577775543aeeeec0ff900001f820aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 10], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c31850011041c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x2555c5504cd55555554555755468577755543aeeef00ff900007f820aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 11], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c30c30011041451850070881041850010c31c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x255715504cd55555554555d55468577755543aeeec00ff90001ff820aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 12], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041040010c31451850070880c31850011041c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x255c55504cd55555554557555468577555543aeef000ff90007ff820aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 13], 0xc30c30011041451890070881041040010c31451850070880c30c30011041451850070881041850010c31c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x257155504cd5555555455d555468577555543aeec000ff9001fff820aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 14], 0xc30c30011041451890070881041040010c31451850070880c31850011041c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x25c555504cd55555554575555468575555543aef0000ff9007fff820aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 15], 0xc30c30011041451890070881041850010c31c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c31c7186005088, 0x271555504cd555555545d5555468575555543aec0000ff901ffff820aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 2, 2, 16], 0xc31850011041c71860080880c30c30011071451890080880820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80820820011041451850070c80000c30411040001860850880c30c30010441451850000880000c30411450821861c71080c30c30010451041840021c81041040010c3145185007088, 0x2c55555044d55555554755555469555555543af00000ff907ffff820aaaaaaaaa4aaaaabba9⟩,
  ⟨[0, 4, 2, 6], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080490411c60021040411c70080c91020c40020481421c50020490000c50421040001c72060c91020410020c51821c10002090410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x1555551a00aaaaaaaa8aaaaae092bbbbb87b0577777773a0000055745555555540000031b82aaaaabaa9⟩,
  ⟨[0, 5, 2, 7], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080490411c60021450411c70080c91020c40020481421c50020491420000421041821c62080c90000c60421440001c70482091020410020c61421c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x10002aaaaaaaa8aaaab8f12bbbbb9e70577771d73a00001557455555555400000c5b82aaaaadaa9⟩,
  ⟨[0, 6, 2, 8], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080490411c60021040411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082090000c50421040001c70460c91020410020c51821c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x40002aaaaaaaa8aaaae2892bbbb87bb0577777773a0000545745555555540000319b82aaaab3aa9⟩,
  ⟨[0, 7, 2, 9], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080490411c60021450411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082091420410021041821c60080c90000c60421440001c70480c91020410020c61421c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x100002aaaaaaaa8aaab8af12bbbb9ee7057771dd73a0001515745555555540000c69b82aaaacbaa9⟩,
  ⟨[0, 8, 2, 10], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080490411c60021040411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082091420410021041821c60080c91820410021442021c700a0c90000c50421840001c90480c91020410020c51821c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x10000000000000000402002aaaaaaaa8aaae2bc92bbb87bbb0577777573a00054557455555555400031a9b82aaab2baa9⟩,
  ⟨[0, 9, 2, 11], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080491421430021041821c60080490411c60021450411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082091420410021041821c60080c91820410021442021c700a0c91420410021842021c800a0c90000c60421440001c90480c91020410020c61421c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x5000000000000000100a002aaaaaaaa8aab8af712bbb9eee705771dd573a001515574555555554000c6a9b82aaacabaa9⟩,
  ⟨[0, 10, 2, 12], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080491021030021451821c60080490411c60021040411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082091420410021041821c60080c91820410021442021c700a0c91420410021842021c800a0c91820410021442021c800a0c90000c50421840001c90480c91020410020c51821c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x15000000000000000402a002aaaaaaaa8aae2bdc92bb87bbbb0577775573a0054555745555555540031aa9b82aab2abaa9⟩,
  ⟨[0, 11, 2, 13], 0x1421430021041821c60080491021030021451821c60080491421430021041821c60080490411c60021450411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082091420410021041821c60080c91820410021442021c700a0c91420410021842021c800a0c91820410021442021c800a0c91420410021842021c800a0c90000c60421440001c90480c91020410020c61421c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x5500000000000000100aa002aaaaaaaa8ab8af7712bb9eeee70571dd5573a01515557455555555400c6aa9b82aacaabaa9⟩,
  ⟨[0, 12, 2, 14], 0x1421430021041821c60080491021030021451821c60080490411c60021040411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082091420410021041821c60080c91820410021442021c700a0c91420410021842021c800a0c91820410021442021c800a0c91420410021842021c800a0c91820410021442021c800a0c90000c50421840001c90480c91020410020c51821c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x15500000000000000402aa002aaaaaaaa8ae2bddc92b87bbbbb0577755573a054555574555555554031aaa9b82ab2aabaa9⟩,
]
private theorem group4_2_ok : group4_2.all (checkFast 4 17) = true := by decide +kernel
private def group4_3 : List FastCert := [
  ⟨[0, 13, 2, 15], 0x1421430021041821c60080490411c60021450411c70080c91020c40020481421c50020491420000421041821c62080c91020410021431821c60082091420410021041821c60080c91820410021442021c700a0c91420410021842021c800a0c91820410021442021c800a0c91420410021842021c800a0c91820410021442021c800a0c91420410021842021c800a0c90000c60421440001c90480c91020410020c61421c10000c90410c50021040421c70060c90c20410021860c21c40021491020c40020c11821c60050c9, 0x5550000000000000100aaa002aaaaaaaa8b8af77712b9eeeee7051dd55573a1515555745555555540c6aaa9b82acaaabaa9⟩,
  ⟨[0, 14, 2, 16], 0x411850021040411850070c81020c40020471421860020481420000421041421861c70c810204100214324218600a1c814204100210414218a0090c81c20410021441c21860090c81420410021c41421880090c81c20410021441c21860090c81420410021c41421880090c81c20410021441c21860090c81420410021c41421880090c81c20410021441c21860090c80000c50421c40001880490c81020410020c51c21810000c80410c50021040421880070c80c20410021450c21840021481020c40020c11421860070c8, 0x1000000000eaaaa000000000000443333344d555555546f3333223377555573a54555557455555555431aaaa9b82b2aaabaa9⟩,
  ⟨[0, 15, 2, 0], 0x1820c30020451821030020471420000421831421081470c71820410021431821080071471420410021831421080070c71820410021431821080070c71420410021831421080070c71820410021431821080070c71420410021831421080070c71820410021431821080070c71420410021831421080070c71820410021431821080070c71420410021831421080070c70000c30421460001060471471420410020c31421010000c70410c30021460421060071470c20410021460c21040021470411040020c30411040050c7, 0x16eeeee8000ddddddd615555555518000008b0d5555555406aaaa9bb2caaaabaa9⟩,
  ⟨[0, 16, 0, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000802aaaaade4ffffffd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 1, 1], 0x1c90000421851c91081c90c80c50410021c20c510a0091c81450410020c21451070060c81860410021421861080070c81450410021821451080070c81860410021421861080070c81450410021821451080070c81860410021421861080070c81450410021821451080070c81860410021421861080070c81450410021821451080070c81860410021421861080070c81450410021821451080070c80000c40421420001070460c80000c40420850001040410c80411030020850461030001481860c40020451861080070c8, 0x2800000000000000000d2aaaa80803999989e4f333330035555555517555555445555555549aaaaaa5c32aaaaafa9⟩,
  ⟨[0, 16, 2, 1], 0x1c20000421851c21081c90c81420410021c31421080091c81820410021451821080070c81c20410021851c21080090c81820410021c51821080090c81c20410021851c21080090c81820410021c51821080090c81c20410021851c21080090c81820410021c51821080090c81c20410021851c21080090c81820410021c51821080090c81c20410021851c21080090c80000c40421c50001080490c81820410020c51821010000c80410c40021850421080070c80411030021450411030021481820c40020451821040020c8, 0x28aaaaa000000000000db777748026eeee9a60c000000035555555514555555445555555541aaaaa9bc32aaaabaa9⟩,
  ⟨[0, 16, 3, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000802aaaaede4fffffdd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 4, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000802aaabade4fffff7d03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 5, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000802aaaeade4ffffdfd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 6, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000802aabaade4ffff7fd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 7, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000802aaeaade4fffdffd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 8, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000802abaaade4fff7ffd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 9, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000802aeaaade4ffdfffd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 10, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000802baaaade4ff7fffd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 11, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000802eaaaade4fdffffd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 12, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000803aaaaade4f7ffffd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 13, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821861070050c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000806aaaaade4dfffffd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 14, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821491070060c804104100208214510a0090c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2a80000000000000000d00000008022aaaade4ffffffd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 15, 0], 0xc20c30421452021071860070410410020c31481090081870410410021451821090080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70000c30420410001071461470410410021860c21030001471421040020411821040030c7, 0x1d5555540000000000002aaaaa92a6aaaaa835555555551e000000d15555555542ffffffee42aaaaaba9⟩,
  ⟨[0, 16, 15, 1], 0x1c90000421851c91081c90c80410410021c20c910a0091c804104100208214510a0090c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2a00000000000000000d0000000800aaaaade43fffffd03555555551755555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 15, 2], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80001450420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c00000034a0aaaaa866aaaaaaaa30aaaaaa1a755555544555555554affffffee42aaaaaba9⟩,
  ⟨[0, 16, 15, 3], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480000c50420c60001481070c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c00000174a0aaaab866aaaaaaaa30aaaaae1a755555744555555554affffff2e42aaaaaba9⟩,
  ⟨[0, 16, 15, 4], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c00000534a0aaaae066aaaaaaaa30aaaaba1a755555d44555555554afffffcee42aaaaaba9⟩,
  ⟨[0, 16, 15, 5], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c00001434a0aaab8866aaaaaaaa30aaaaea1a755557544555555554afffff3ee42aaaaaba9⟩,
]
private theorem group4_3_ok : group4_3.all (checkFast 4 17) = true := by decide +kernel
private def group4_4 : List FastCert := [
  ⟨[0, 16, 15, 6], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c00005034a0aaae2866aaaaaaaa30aaabaa1a75555d544555555554affffcfee42aaaaaba9⟩,
  ⟨[0, 16, 15, 7], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c00014034a0aab8a866aaaaaaaa30aaaeaa1a755575544555555554affff3fee42aaaaaba9⟩,
  ⟨[0, 16, 15, 8], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c00050034a0aae2a866aaaaaaaa30aabaaa1a7555d5544555555554afffcffee42aaaaaba9⟩,
  ⟨[0, 16, 15, 9], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c00140034a0ab8aa866aaaaaaaa30aaeaaa1a755755544555555554afff3ffee42aaaaaba9⟩,
  ⟨[0, 16, 15, 10], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c00500034a0ae2aa866aaaaaaaa30abaaaa1a755d55544555555554affcfffee42aaaaaba9⟩,
  ⟨[0, 16, 15, 11], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c01400034a0b8aaa866aaaaaaaa30aeaaaa1a757555544555555554aff3fffee42aaaaaba9⟩,
  ⟨[0, 16, 15, 12], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c05000034a0e2aaa866aaaaaaaa30baaaaa1a75d555544555555554afcffffee42aaaaaba9⟩,
  ⟨[0, 16, 15, 13], 0x1c70c50421041c71481860080410410021c60c914800918804104100208210414a0090c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0xa00000000000000000c14000034a18aaaa866aaaaaaaa30eaaaaa1a775555544555555554af3ffffee42aaaaaba9⟩,
  ⟨[0, 16, 15, 14], 0x1c70c50421041c71481860090410410021c60c814a0081890c61480020820c41480090490410410020c81041470060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90410410020821041440060c90000c50420410001451040c90410410020861c71430001091040c40020411861480070c9, 0x4400000000c20000034a6aaaaa866aaaaaaaa30aaaaaa1a7d5555544555555554acfffffee42aaaaaba9⟩,
  ⟨[0, 16, 15, 15], 0x1c20c50421041c21481860080491480021c60c91480091880410410020c810214a0090c80410410020c41821450070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80000c50420410001471060c80410410021861c21430001081020c40020411821480070c8, 0xa00000000000000000d2aaaaa3821fffffa66aaaaaaaa30d555541a7555555445555555542ffffffee42aaaaaba9⟩,
  ⟨[0, 16, 15, 16], 0xc21470421040c21471860070410410020c71081440061870410410020c41821490080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70000c50420410001471060c70410410021862021430001071020c40020411821490080c7, 0x55555547000000000002aaaaa92aaaaaaaaa335555541ad555555445555555542ffffffee42aaaaaba9⟩,
  ⟨[0, 16, 16, 0], 0xc20c30421452081071860070410410020c31421090081870410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70410410021451821060080c70000c30420410001071461470410410021860c21030001471421040020411821040030c7, 0x1aaaaaaa0100000000002aaaaa92a6aaaaa835555555551e000000d15555555542ffffffee42aaaaaba9⟩,
  ⟨[0, 16, 16, 1], 0x1c90000421851c91081c90c80410410021c214310a0091c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80410410020821451070060c80000c40420410001061450c80411010020851861030001481860c40020451861080070c8, 0x2800000000000000000d0000000802aaaaade4ffffffd03555555551655555544555555554affffffee52aaaaaba9⟩,
  ⟨[0, 16, 16, 2], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80001450420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c00000034a2aaaaa866aaaaaaaa32aaaaaa1a655555544555555554affffffee42aaaaaba9⟩,
  ⟨[0, 16, 16, 3], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480000c50420c60001481070c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c00000174a2aaaab866aaaaaaaa32aaaaae1a655555744555555554affffff2e42aaaaaba9⟩,
  ⟨[0, 16, 16, 4], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c00000534a2aaaae066aaaaaaaa32aaaaba1a655555d44555555554afffffcee42aaaaaba9⟩,
  ⟨[0, 16, 16, 5], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c00001434a2aaab8866aaaaaaaa32aaaaea1a655557544555555554afffff3ee42aaaaaba9⟩,
  ⟨[0, 16, 16, 6], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c00005034a2aaae2866aaaaaaaa32aaabaa1a65555d544555555554affffcfee42aaaaaba9⟩,
  ⟨[0, 16, 16, 7], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c00014034a2aab8a866aaaaaaaa32aaaeaa1a655575544555555554affff3fee42aaaaaba9⟩,
  ⟨[0, 16, 16, 8], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c00050034a2aae2a866aaaaaaaa32aabaaa1a6555d5544555555554afffcffee42aaaaaba9⟩,
  ⟨[0, 16, 16, 9], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c00140034a2ab8aa866aaaaaaaa32aaeaaa1a655755544555555554afff3ffee42aaaaaba9⟩,
  ⟨[0, 16, 16, 10], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c00500034a2ae2aa866aaaaaaaa32abaaaa1a655d55544555555554affcfffee42aaaaaba9⟩,
  ⟨[0, 16, 16, 11], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c01400034a2b8aaa866aaaaaaaa32aeaaaa1a657555544555555554aff3fffee42aaaaaba9⟩,
  ⟨[0, 16, 16, 12], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c05000034a2e2aaa866aaaaaaaa32baaaaa1a65d555544555555554afcffffee42aaaaaba9⟩,
]
private theorem group4_4_ok : group4_4.all (checkFast 4 17) = true := by decide +kernel
private def group4_5 : List FastCert := [
  ⟨[0, 16, 16, 13], 0x1c70c50421041c71481860080410410021c61031480091880410410020821041440060c80c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c14000034a38aaaa866aaaaaaaa32eaaaaa1a675555544555555554af3ffffee42aaaaaba9⟩,
  ⟨[0, 16, 16, 14], 0x1c70c50421041c71481860080410410021c61031480091880c41440020820c61450070480410410020c61041480070c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80410410020821041440060c80000c50420410001451040c80410410020861c71430001081040c40020411861480070c8, 0x800000000000000000c50000034a62aaaa866aaaaaaaa33aaaaaa1a6d5555544555555554acfffffee42aaaaaba9⟩,
  ⟨[0, 16, 16, 15], 0x1c20c50421041c71481890080411480021c60c21480091880410410020c81021440060c80410410020c41821450070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80410410020c41821480070c80000c50420410001471060c80410410021861021430001881020c40020411c21450060c8, 0x2800000000000000000c1555558ca3fffffa26aaaaaaaa30d555543a7555555445555555542ffffffee42aaaaaba9⟩,
  ⟨[0, 16, 16, 16], 0xc81470421040c81471860070410410020c71021490081870410410020c41821450080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70410410020c41821460080c70000c50420410001471060c70410410021862021430001071020c40020411821490080c7, 0x155555547000000000002aaaaa92aaaaaaaaa335555541ad555555445555555542ffffffee42aaaaaba9⟩,
]
private theorem group4_5_ok : group4_5.all (checkFast 4 17) = true := by decide +kernel
private def certs4 := group4_0 ++ group4_1 ++ group4_2 ++ group4_3 ++ group4_4 ++ group4_5
private theorem valid4 : certs4.all (checkFast 4 17) = true := by simp only [certs4, List.all_append, group4_0_ok, group4_1_ok, group4_2_ok, group4_3_ok, group4_4_ok, group4_5_ok, Bool.and_true]
private theorem cover4 : ruledOut 17 (rest3) rest4 = certs4.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class4 : Classifies 4 17 rest4 :=
  classify_stepFast (by decide) (by decide) class3 valid4 cover4

private def rest5 : List (List Nat) := [[0, 0, 0, 0, 16], [0, 0, 3, 2, 0], [0, 0, 3, 2, 1], [0, 0, 3, 2, 2], [0, 0, 3, 2, 3], [0, 0, 3, 2, 4], [0, 0, 3, 2, 5], [0, 0, 3, 2, 6], [0, 0, 3, 2, 7], [0, 0, 3, 2, 8], [0, 0, 3, 2, 9], [0, 0, 3, 2, 10], [0, 0, 3, 2, 11], [0, 0, 3, 2, 12], [0, 0, 3, 2, 13], [0, 0, 3, 2, 14], [0, 0, 3, 2, 15], [0, 0, 3, 2, 16]]
private def group5_0 : List FastCert := [
  ⟨[0, 0, 0, 0, 0], 0x2060820000411c608b00b0c420608200628a1450870090c51040820c300010408804a0011040820c62491040880470052060821040001c60870440c02060821062431450850440452060820c30001c608704b1002060820c62841450890490452060821040001c608704b0c02060821062831450890490452060820c30001c608704b1002060820c62841450890490452060821040001c608704b0c02060821062831450890490452060820c30001c608704b1002060820c62841450890490452060821040001c608704b0c02060821062831450890490452060820c30001c608704b1002060820c62841450890490452060821040001c608704b0c02060821062831450890490452060820c30001c608704b1002060820c62841450890490452060821040001c608704b0c02060821062831450890490452060820c30001c608704b1002060820c62841450890490450000411040c300008810a0c30000411062430000881070c50c30820000410c30820001040c30820060410c30820001051c60870c61042060880c30011c60870c61041460850c3005, 0x82aaaaa018800000204500000107bfffffe8a45555550d5555555540000000006688888881111111134d5555555460000003848000001a1⟩,
]
private theorem group5_0_ok : group5_0.all (checkFast 5 17) = true := by decide +kernel
private def certs5 := group5_0
private theorem valid5 : certs5.all (checkFast 5 17) = true := by exact group5_0_ok
private theorem cover5 : ruledOut 17 (rest4) rest5 = certs5.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class5 : Classifies 5 17 rest5 :=
  classify_stepFast (by decide) (by decide) class4 valid5 cover5

private def rest6 : List (List Nat) := []
private def certs6 := ([] : List FastCert)
private theorem valid6 : certs6.all (checkFast 6 17) = true := by rfl
private theorem cover6 : ruledOut 17 (rest5) rest6 = certs6.map FastCert.labels := by rw [← ruledOutFast_eq]; decide +kernel
private theorem class6 : Classifies 6 17 rest6 :=
  classify_stepFast (by decide) (by decide) class5 valid6 cover6

theorem good17 {a : Nat → Nat} (ha : Valid 6 17 a) : Good 6 17 a :=
  of_empty class6 ha
end PhaseFalls.Moduli.Data17

namespace PhaseFalls.Moduli
export Data17 (good17)
end PhaseFalls.Moduli

/-! ## ModulusSingleton -/

namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata.Rule30Jen

def Fall (i : Int) (t : Nat) : Prop := cell t i = true ∧ cell (t+1) i = false

def Cofinal {m : Nat} (i : Int) (r : Fin m) : Prop :=
  ∀ T, ∃ t, T ≤ t ∧ t%m = r.val ∧ Fall i t

private theorem escape {m : Nat} (hm : 0 < m) (i : Int) (a : Fin 6 → Fin m)
    (good : ∀ a, (∀ j, j < 6 → a j < m) → Good 6 m a) (T : Nat) :
    ∃ (j : Fin 6) (t : Nat), T ≤ t ∧ Fall (i+j.val) t ∧ t%m ≠ (a j).val := by
  apply Classical.byContradiction
  intro no
  let S := T*m
  have Slarge : T ≤ S := by
    simpa [S] using Nat.mul_le_mul_left T (show 1 ≤ m by omega)
  let phases (j : Nat) := if hj : j < 6 then (a ⟨j,hj⟩).val else 0
  let x (t : Nat) := Six.row (S+t) i
  have run : Run 6 m phases x := by
    refine ⟨fun t => Six.row_lt _ _,fun t => ?_⟩
    have adv := Six.row_step (S+t) i
    refine ⟨mem_successors.mpr ⟨_,_,by simpa [x,Nat.add_assoc,Six.step] using adv⟩,
      (fits_iff _ _ _).mpr ?_⟩
    intro j on off
    by_cases hj : j < 6
    · rw [permit_bit, decide_eq_true_eq]
      refine ⟨hj,?_⟩
      have b : Fall (i+j) (S+t) := by
        unfold x at on off
        rw [Six.row_bit _ _ _ hj] at on off
        exact ⟨on,by simpa only [Nat.add_assoc] using off⟩
      have eq : (S+t)%m = (a ⟨j,hj⟩).val := by
        apply Classical.byContradiction
        intro neq
        exact no ⟨⟨j,hj⟩,S+t,by omega,b,neq⟩
      simpa only [S,phases,dite_eq_left hj,Nat.add_comm _ t,Nat.add_mul_mod_self_right] using eq.symm
    · have hn : (x t).testBit j = false :=
        Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (Six.row_lt _ _)
          (Nat.pow_le_pow_right (by decide : 0<2) (by omega : 6 ≤ j)))
      simp [hn] at on
  have phasesBound (j : Nat) (hj : j < 6) : phases j < m := by
    simpa only [phases,dite_eq_left hj] using (a ⟨j,hj⟩).isLt
  obtain ⟨j,N,hj,per⟩ := good phases phasesBound x run
  apply not_adjacent (i+j)
  · refine ⟨S+N,m,hm,fun t ht => ?_⟩
    have left := (pair_bits (per (t-S) (by omega))).1
    unfold x at left
    rw [Six.row_bit _ _ _ (by omega),Six.row_bit _ _ _ (by omega),
      show S+(t-S+m)=t+m by omega,show S+(t-S)=t by omega] at left
    exact left
  · refine ⟨S+N,m,hm,fun t ht => ?_⟩
    have right := (pair_bits (per (t-S) (by omega))).2
    unfold x at right
    rw [Six.row_bit _ _ _ hj,Six.row_bit _ _ _ hj,
      show S+(t-S+m)=t+m by omega,show S+(t-S)=t by omega] at right
    simpa only [Int.natCast_add,Int.natCast_one,← Int.add_assoc] using right

private theorem common_bound {k : Nat} (f : Fin k → Nat) :
    ∃ B, ∀ i, f i ≤ B := by
  induction k with
  | zero => exact ⟨0,fun i => Fin.elim0 i⟩
  | succ k ih =>
    obtain ⟨B,upper⟩ := ih (fun i => f i.succ)
    exact ⟨max (f 0) B, fun i => Fin.cases (Nat.le_max_left _ _)
      (fun j => Nat.le_trans (upper j) (Nat.le_max_right _ _)) i⟩

/-- Cofinality follows once each fixed one-phase assignment has an exception
after every starting time. The witnesses are fixed for the chosen modulus. -/
theorem two_cofinal_from_good {m : Nat} (hm : 0 < m) (i : Int)
    (good : ∀ a, (∀ j, j < 6 → a j < m) → Good 6 m a) :
    ∃ (j : Fin 6) (r q : Fin m), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q := by
  classical
  apply Classical.byContradiction
  intro no
  have single (j : Fin 6) : ∃ r : Fin m, ∀ q, q ≠ r → ¬ Cofinal (i+j.val) q := by
    by_cases h : ∃ r : Fin m, Cofinal (i+j.val) r
    · obtain ⟨r,hr⟩ := h
      exact ⟨r,fun q neq hq => no ⟨j,r,q,Ne.symm neq,hr,hq⟩⟩
    · exact ⟨⟨0,hm⟩,fun q _ hq => h ⟨q,hq⟩⟩
  let phase (j : Fin 6) := Classical.choose (single j)
  have cutoff (j : Fin 6) (q : Fin m) :
      ∃ B, ∀ t, B ≤ t → t%m=q.val → Fall (i+j.val) t → q=phase j := by
    by_cases eq : q = phase j
    · exact ⟨0,fun _ _ _ _ => eq⟩
    · have rare := Classical.choose_spec (single j) q eq
      apply Classical.byContradiction
      intro noBound
      apply rare
      intro T
      apply Classical.byContradiction
      intro absent
      exact noBound ⟨T,fun t ht htq hit => (absent ⟨t,ht,htq,hit⟩).elim⟩
  let B (j : Fin 6) (q : Fin m) := Classical.choose (cutoff j q)
  let C (j : Fin 6) := Classical.choose (common_bound (B j))
  obtain ⟨M,hm'⟩ := common_bound C
  obtain ⟨j,t,late,hit,off⟩ := escape hm i phase good M
  let q : Fin m := ⟨t%m,Nat.mod_lt t hm⟩
  have hq : B j q ≤ C j := Classical.choose_spec (common_bound (B j)) q
  have eq := Classical.choose_spec (cutoff j q) t (Nat.le_trans hq (Nat.le_trans (hm' j) late)) rfl hit
  exact off (congrArg Fin.val eq)

end PhaseFalls.Moduli

/-! ## ModulusParity -/

namespace PhaseFalls.Moduli

private def parityRow (t : Nat) : Nat := [3,36,63,1].getD (t%4) 0

private def parityEdges : Bool := (List.range 4).all fun t =>
  parityRow t < 64 &&
  (successors 6 (parityRow t)).contains (parityRow (t+1)) &&
  fits (permit 6 (fun _ => 0) (t%2)) (parityRow t) (parityRow (t+1))

private theorem parityEdges_ok : parityEdges = true := by decide +kernel

private theorem parity_run : Run 6 2 (fun _ => 0) parityRow := by
  have verify (p : Nat) (hp : p < 4) :=
    List.all_eq_true.mp parityEdges_ok p (List.mem_range.mpr hp)
  have data (t : Nat) :=
    verify (t%4) (Nat.mod_lt _ (by decide))
  refine ⟨fun t => ?_,fun t => ?_⟩
  · have fact := data t
    simp only [Bool.and_eq_true, decide_eq_true_eq] at fact
    simpa only [parityRow, Nat.mod_mod] using fact.1.1
  · have fact := data t
    simp only [Bool.and_eq_true, List.contains_iff_mem] at fact
    have here : parityRow (t%4) = parityRow t := by simp [parityRow]
    have next : parityRow (t%4+1) = parityRow (t+1) := by
      unfold parityRow
      rw [show (t%4+1)%4=(t+1)%4 by omega]
    have phase : t%4%2=t%2 := by omega
    exact ⟨by simpa only [here,next] using fact.1.2,
      by simpa only [here,next,phase] using fact.2⟩

private theorem parity_bad : (List.range 5).all (fun j =>
    (parityRow ((if j=0 then 1 else 0)+2) >>> j)%4 !=
      (parityRow (if j=0 then 1 else 0) >>> j)%4) = true := by decide +kernel

/-- The four-row loop is an admissible free-exterior strip whose falls all
start on even ticks. Every adjacent pair changes under the lag-two shift. -/
theorem not_good_parity : ¬ Good 6 2 (fun _ => 0) := by
  intro h
  obtain ⟨j,N,hj,per⟩ := h parityRow parity_run
  let r := if j=0 then 1 else 0
  have bad := List.all_eq_true.mp parity_bad j (List.mem_range.mpr (by omega))
  have eq := per (4*N+r) (by omega)
  have here : parityRow (4*N+r) = parityRow r := by
    unfold parityRow
    rw [show (4*N+r)%4=r%4 by omega]
  have next : parityRow (4*N+r+2) = parityRow (r+2) := by
    unfold parityRow
    rw [show (4*N+r+2)%4=(r+2)%4 by omega]
  rw [here,next] at eq
  change ((parityRow (r+2) >>> j)%4 != (parityRow r >>> j)%4) = true at bad
  simp [eq] at bad

end PhaseFalls.Moduli

/-! ## EveryModulusFast -/

namespace PhaseFalls.Moduli

private def checkedDivisor (m : Nat) : Prop :=
  3 ∣ m ∨ 4 ∣ m ∨ 5 ∣ m ∨ 7 ∣ m ∨ 11 ∣ m ∨ 13 ∣ m ∨ 17 ∣ m

private instance (m : Nat) : Decidable (checkedDivisor m) := by
  unfold checkedDivisor
  infer_instance

private theorem checkedDivisors :
    (List.range 19).all (fun m => decide (m < 3 ∨ checkedDivisor m)) = true := by decide +kernel

theorem good_small (m : Nat) (hm : 3 ≤ m) (hb : m ≤ 18) (a : Nat → Nat)
    (_ : Valid 6 m a) : Good 6 m a := by
  have h := of_decide_eq_true (List.all_eq_true.mp checkedDivisors m (List.mem_range.mpr (by omega)))
  rcases h with h | h
  · omega
  rcases h with h | h | h | h | h | h | h
  · exact good_of_dvd h (good3 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good4 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good5 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good7 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good11 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good13 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good17 fun j _ => Nat.mod_lt _ (by decide))

/-- For each modulus at least three, every six consecutive singleton Rule 30
columns contain a fixed column with cofinal falls on two distinct residues. -/
theorem two_cofinal_every_modulus (m : Nat) (hm : 3 ≤ m) (i : Int) :
    ∃ (j : Fin 6) (r q : Fin m), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q :=
  two_cofinal_from_good (by omega : 0 < m) i fun _ ha => good_of_small hm ha good_small

end PhaseFalls.Moduli

end Rule30Submission
