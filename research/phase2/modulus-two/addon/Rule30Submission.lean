import Ruliology.CellularAutomata.Rule30StripCertificates

/-!
# Falls on both parities in every 27 adjacent columns of the single seed

A column of Rule 30 from a single black cell *falls* at tick `t` when it is black at `t` and white at `t + 1`
(`Fall`). `Cofinal i r` says that column `i` falls at ticks congruent to `r` modulo `m` after every cutoff.

* `Rule30Submission.FallParities.two_parities_every_27`: for every integer `i`, one of the 27 columns
  `i, …, i + 26` has cofinal falls at both residues modulo 2, that is, on even ticks and on odd ticks.
* `Rule30Submission.FallParities.goodAny27`: the strip statement behind it. Give each of 27 cells one tick parity at
  which it may fall, and let both exterior cells vary freely. Then every path of the strip has an adjacent pair of
  cells that eventually repeats with some lag (`GoodAny`).

This is the modulus left open by the entry R30-20261127-157e8c, which proves two cofinal falling residues in every
six columns for every modulus from three, and shows by a four-row loop that its six-cell, lag-`m` argument stops at
two. The loop has period four. Jen's theorem forbids two eventually periodic singleton columns with any periods, so
here the pair may repeat with any lag. Records give each node a rank, a class and a position (`pairAny_of_records`).
Fifteen certificates of widths 4 to 20 are checked over every node (`checkLag`), or over the product of where the
two halves of the strip eventually stay (`checkEv`, `checkProd`). A classification by substrips then rules out every
assignment of 27 cells (`goodAny27`). The step to the single seed is as in that entry, for 27 columns and any lag
(`two_cofinal_from_goodAny`).

The kit's revision at the verifier lacks the two modules of that entry the proof uses. They are carried from the kit's
main in the namespace `Rule30Submission.KitFallResidues`: `Rule30Certificates.FallResidueStrip` whole, and the
definitions `Fall` and `Cofinal` of `Rule30FallResidues`.
-/

/-! ## Carried from the kit at main: Rule30Certificates.FallResidueStrip -/

/-!
# The strip with free exterior cells and one permitted fall residue per site

Support for `Rule30FallResidues`. A node is a row of `w` cells, and an edge is one Rule 30 update with both exterior
cells free in which only the sites assigned to the current slot of an `m`-slot calendar may fall (`Run`). `Good`
says that on every such path some adjacent pair eventually repeats every `m` ticks.

* `quiet_eq`: among three successive quiet updates of a six-cell strip, the first is idle.
* `good_of_dvd`: one residue modulo `m` is one residue modulo a divisor, and a repeating pair lifts back.
* The rank check (`check`, `Certificate`): each node has a rank that no edge raises, and each rank names an adjacent
  pair with its reading at each slot.
* `Classifies`: the assignments still possible at a width, built from the two narrower restrictions.
-/


/-! A strip with both exterior cells free and one permitted fall phase per site. -/
namespace Rule30Submission.KitFallResidues

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

end Rule30Submission.KitFallResidues

namespace Rule30Submission.KitFallResidues

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

end Rule30Submission.KitFallResidues

namespace Rule30Submission.KitFallResidues

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

end Rule30Submission.KitFallResidues

/-! A failure of the adjacent-pair conclusion on a strip forces failure on
its two immediate substrips. Generate just the compatible extensions. -/
namespace Rule30Submission.KitFallResidues

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

end Rule30Submission.KitFallResidues

/-! ## Carried from the kit at main: Fall and Cofinal, from Rule30FallResidues -/

namespace Rule30Submission.KitFallResidues

open Ruliology.CellularAutomata.Rule30Jen

def Fall (i : Int) (t : Nat) : Prop := cell t i = true ∧ cell (t+1) i = false

def Cofinal {m : Nat} (i : Int) (r : Fin m) : Prop :=
  ∀ T, ∃ t, T ≤ t ∧ t%m = r.val ∧ Fall i t

end Rule30Submission.KitFallResidues

/-! ## FallParityLag -/

/-!
# Adjacent pairs that repeat with any lag, on the strip with one permitted fall residue per site

Support for `Rule30FallParities`. Jen's theorem forbids two eventually periodic singleton columns with any periods, so
the strip argument of `Rule30FallResidues` needs only `GoodAny`: every path of the strip graph has an adjacent pair
that eventually repeats with some lag.

* `pairAny_of_records`: a rank that no edge raises, and along edges of equal rank a class whose position advances by
  one modulo its period, with the class's pair reading the class's word, give `PairAny` on every path.
* `checkLag`, `checkEv`, `checkProd`: the records as a table over every node; a table that only marks where paths
  eventually stay (`EvIn`); and a table over the product of two such sets, for a strip cut in two.
* `classify_stepAny`, `of_emptyAny`: the coverage by substrips of `Rule30FallResidues`, for `GoodAny`.
* The checks use only raw `Nat` operations and loops on `Nat.rec`'s predecessor, so that the kernel evaluates them
  quickly; each is proved sound.
-/


namespace Rule30Submission.FallParities

open Ruliology.CellularAutomata Rule30StripCertificates Rule30Submission.KitFallResidues

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
        simp [Nat.testBit_shiftLeft]
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
    simp [this, h]
  · have : Nat.ble q r = false := by
      cases e : Nat.ble q r
      · rfl
      · exact absurd (Nat.ble_eq.mp e) h
    simp [this, h]

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

def PairAny (w : Nat) (x : Nat → Nat) : Prop :=
  ∃ j L N, 0 < L ∧ j + 1 < w ∧ ∀ t, N ≤ t → (x (t + L) >>> j) % 4 = (x t >>> j) % 4

def GoodAny (w m : Nat) (a : Nat → Nat) : Prop := ∀ x, Run w m a x → PairAny w x

/-- Runs eventually stay where `live` holds. -/
def EvIn (w m : Nat) (a : Nat → Nat) (live : Nat → Nat → Bool) : Prop :=
  ∀ x, Run w m a x → ∃ N, ∀ t, N ≤ t → live (t % m) (x t) = true

/-! ### Records -/

def rkOf (rb r : Nat) : Nat := Nat.mod r (Nat.pow 2 rb)
def clOf (rb cb r : Nat) : Nat := Nat.mod (Nat.shiftRight r rb) (Nat.pow 2 cb)
def psOf (rb cb r : Nat) : Nat := Nat.shiftRight r (Nat.add rb cb)
/-- A class record, field width 72: the pair (5 bits), the period (5 bits), then two bits per position. -/
def qj (q : Nat) : Nat := Nat.mod q 32
def qd (q : Nat) : Nat := Nat.mod (Nat.shiftRight q 5) 32
def qw (q π : Nat) : Nat := Nat.mod (Nat.shiftRight q (Nat.add 10 (Nat.mul 2 π))) 4

def nodeCond (w rb cb classes r s : Nat) : Bool :=
  let c := clOf rb cb r
  let π := psOf rb cb r
  let q := field classes 72 c
  Nat.beq c 0 || ((Nat.blt (Nat.add (qj q) 1) w && Nat.blt π (qd q)) &&
    Nat.beq (Nat.mod (Nat.shiftRight s (qj q)) 4) (qw q π))

def edgeCond (rb cb classes r r' : Nat) : Bool :=
  Nat.ble (rkOf rb r') (rkOf rb r) &&
  (!(Nat.beq (rkOf rb r') (rkOf rb r)) ||
    ((!(Nat.beq (clOf rb cb r) 0) && Nat.beq (clOf rb cb r') (clOf rb cb r)) &&
      Nat.beq (psOf rb cb r') (Nat.mod (Nat.add (psOf rb cb r) 1) (qd (field classes 72 (clOf rb cb r))))))

private theorem pos_shift {f : Nat → Nat} {d N : Nat}
    (h : ∀ t, N ≤ t → f (t+1) = (f t + 1) % d) (t : Nat) (ht : N ≤ t) (hb : f t < d) :
    ∀ k, f (t+k) = (f t + k) % d
  | 0 => by simp [Nat.mod_eq_of_lt hb]
  | k+1 => by
    rw [← Nat.add_assoc, h (t+k) (by omega), pos_shift h t ht hb k, Nat.mod_add_mod, Nat.add_assoc]

/-- The core: records along a run that satisfy the node and step conditions give a repeating pair. -/
theorem pairAny_of_records {w rb cb classes : Nat} {x ρ : Nat → Nat} {N0 : Nat}
    (node : ∀ t, N0 ≤ t → nodeCond w rb cb classes (ρ t) (x t) = true)
    (edge : ∀ t, N0 ≤ t → edgeCond rb cb classes (ρ t) (ρ (t+1)) = true) : PairAny w x := by
  have mono (t : Nat) (ht : N0 ≤ t) : rkOf rb (ρ (t+1)) ≤ rkOf rb (ρ t) := by
    have e := edge t ht
    unfold edgeCond at e
    rw [Bool.and_eq_true] at e
    exact Nat.ble_eq.mp e.1
  obtain ⟨N, hN, stable⟩ := antitone_eventually_const (fun t => rkOf rb (ρ t)) N0 mono
  have same (t : Nat) (ht : N ≤ t) :
      clOf rb cb (ρ t) ≠ 0 ∧ clOf rb cb (ρ (t+1)) = clOf rb cb (ρ t) ∧
        psOf rb cb (ρ (t+1)) = (psOf rb cb (ρ t) + 1) % qd (field classes 72 (clOf rb cb (ρ t))) := by
    have e := edge t (by omega)
    have eq : rkOf rb (ρ (t+1)) = rkOf rb (ρ t) := (stable (t+1) (by omega)).trans (stable t ht).symm
    unfold edgeCond at e
    simp only [Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at e
    have hb : Nat.beq (rkOf rb (ρ (t+1))) (rkOf rb (ρ t)) = true := by rw [eq]; exact Nat.beq_refl _
    rcases e.2 with bad | ⟨⟨c0, c1⟩, p1⟩
    · rw [hb] at bad; exact absurd bad (by decide)
    · refine ⟨fun z => ?_, Nat.eq_of_beq_eq_true c1, ?_⟩
      · rw [z] at c0; exact absurd c0 (by decide)
      · have := Nat.eq_of_beq_eq_true p1
        simpa only [raw_mod, raw_add] using this
  have cls (k : Nat) : clOf rb cb (ρ (N+k)) = clOf rb cb (ρ N) := by
    induction k with
    | zero => rfl
    | succ k ih => rw [← Nat.add_assoc, (same (N+k) (by omega)).2.1, ih]
  let c := clOf rb cb (ρ N)
  let q := field classes 72 c
  have hc (t : Nat) (ht : N ≤ t) : clOf rb cb (ρ t) = c := by
    have := cls (t - N); rwa [show N + (t - N) = t by omega] at this
  have read (t : Nat) (ht : N ≤ t) :
      qj q + 1 < w ∧ psOf rb cb (ρ t) < qd q ∧
        (x t >>> qj q) % 4 = qw q (psOf rb cb (ρ t)) := by
    have n := node t (by omega)
    unfold nodeCond at n
    simp only [Bool.or_eq_true, Bool.and_eq_true, Nat.blt_eq] at n
    rcases n with z | ⟨⟨h1, h2⟩, h3⟩
    · exact absurd (Nat.eq_of_beq_eq_true z) (same t ht).1
    · rw [hc t ht] at h1 h2 h3
      refine ⟨by simpa only [raw_add] using h1, h2, ?_⟩
      simpa only [raw_mod, raw_shr] using Nat.eq_of_beq_eq_true h3
  have step (t : Nat) (ht : N ≤ t) : psOf rb cb (ρ (t+1)) = (psOf rb cb (ρ t) + 1) % qd q := by
    have := (same t ht).2.2; rwa [hc t ht] at this
  have dpos : 0 < qd q := Nat.lt_of_le_of_lt (Nat.zero_le _) (read N (Nat.le_refl _)).2.1
  refine ⟨qj q, qd q, N, dpos, (read N (Nat.le_refl _)).1, fun t ht => ?_⟩
  have shift := pos_shift (f := fun t => psOf rb cb (ρ t)) step t ht (read t ht).2.1 (qd q)
  rw [Nat.add_mod_right, Nat.mod_eq_of_lt (read t ht).2.1] at shift
  rw [(read (t + qd q) (by omega)).2.2, (read t ht).2.2, shift]

theorem raw_div (a b : Nat) : Nat.div a b = a / b := rfl

/-! ### Shared pieces -/

/-- The permit masks are stored, one `w`-bit field per phase, and checked once against the labels. -/
noncomputable def permsOk (w m : Nat) (labels : List Nat) (perms : Nat) : Bool :=
  Nat.beq labels.length w && allBelow m fun p => Nat.beq (field perms w p) (permitFast labels p)

theorem perm_of_permsOk {w m : Nat} {labels : List Nat} {perms : Nat}
    (ok : permsOk w m labels perms = true) {p : Nat} (hp : p < m) :
    field perms w p = permit w (fun j => labels.getD j 0) p ∧ labels.length = w := by
  unfold permsOk at ok
  rw [Bool.and_eq_true] at ok
  have hl : labels.length = w := Nat.eq_of_beq_eq_true ok.1
  refine ⟨?_, hl⟩
  rw [Nat.eq_of_beq_eq_true (allBelow_spec ok.2 hp), permitFast_eq hl]

/-- A condition on the four raw successors of `s`. -/
def four (w N s : Nat) (g : Nat → Bool) : Bool :=
  g (succRaw w N 0 0 s) && g (succRaw w N 0 1 s) && g (succRaw w N 1 0 s) && g (succRaw w N 1 1 s)

theorem four_spec {w s : Nat} {g : Nat → Bool} (h : four w (Nat.pow 2 w) s g = true) {d : Nat}
    (hd : d ∈ successors w s) : g d = true := by
  obtain ⟨l, r, rfl⟩ := mem_successors.mp hd
  unfold four at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨⟨⟨e00, e01⟩, e10⟩, e11⟩ := h
  rw [stripStep_raw]
  cases l <;> cases r
  · exact e00
  · exact e01
  · exact e10
  · exact e11

theorem fit_of_edge {w m : Nat} {labels : List Nat} {perms : Nat} (ok : permsOk w m labels perms = true)
    {p s d : Nat} (hp : p < m) (hd : Edge w (permit w (fun j => labels.getD j 0) p) s d) :
    fitsRaw (field perms w p) s d = true := by
  rw [(perm_of_permsOk ok hp).1, fitsRaw_eq]; exact hd.2

private theorem mod_succ_mod (t m : Nat) : (t%m+1)%m = (t+1)%m := by
  calc (t%m+1)%m = (t%m+1%m)%m := by rw [Nat.add_mod (t%m) 1 m, Nat.mod_mod]
    _ = (t+1)%m := (Nat.add_mod t 1 m).symm

/-! ### Full tables -/

/-- Node `p * 2^w + s` has the record of width `rb + cb + 5` at that index of `nodes`. -/
structure LagCert where
  labels : List Nat
  rb : Nat
  cb : Nat
  perms : Nat
  nodes : Nat
  classes : Nat

def recOf (c : LagCert) (n : Nat) : Nat := field c.nodes (Nat.add (Nat.add c.rb c.cb) 5) n

noncomputable def checkLag (w m : Nat) (c : LagCert) : Bool :=
  permsOk w m c.labels c.perms &&
  allBelow m fun p =>
    let N := Nat.pow 2 w
    let a := field c.perms w p
    let base := Nat.mul p N
    let nextBase := Nat.mul (Nat.mod (Nat.add p 1) m) N
    allBelow N fun s =>
      let r := recOf c (Nat.add base s)
      nodeCond w c.rb c.cb c.classes r s &&
      four w N s (fun d => !(fitsRaw a s d) || edgeCond c.rb c.cb c.classes r (recOf c (Nat.add nextBase d)))

theorem lag_node {w m : Nat} {c : LagCert} (ok : checkLag w m c = true) {p s : Nat} (hp : p < m)
    (hs : s < 2^w) :
    nodeCond w c.rb c.cb c.classes (recOf c (p * 2^w + s)) s = true ∧
      ∀ d, Edge w (permit w (fun j => c.labels.getD j 0) p) s d →
        edgeCond c.rb c.cb c.classes (recOf c (p * 2^w + s)) (recOf c (((p+1)%m) * 2^w + d)) = true := by
  rw [checkLag, Bool.and_eq_true] at ok
  have hpf := allBelow_spec ok.2 hp
  dsimp only at hpf
  have hsf := allBelow_spec hpf (show s < Nat.pow 2 w from hs)
  try dsimp only at hsf
  rw [Bool.and_eq_true] at hsf
  refine ⟨by simpa only [raw_add, raw_mul, raw_pow] using hsf.1, fun d hd => ?_⟩
  have e := four_spec hsf.2 hd.1
  try dsimp only at e
  rw [fit_of_edge ok.1 hp hd] at e
  simpa only [Bool.not_true, Bool.false_or, raw_add, raw_mul, raw_pow, raw_mod] using e

theorem goodAny_of_checkLag {w m : Nat} {c : LagCert} (hm : 0 < m) (ok : checkLag w m c = true) :
    GoodAny w m (fun j => c.labels.getD j 0) := by
  intro x hx
  refine pairAny_of_records (rb := c.rb) (cb := c.cb) (classes := c.classes) (N0 := 0)
    (ρ := fun t => recOf c ((t%m) * 2^w + x t)) (fun t _ => ?_) (fun t _ => ?_)
  · exact (lag_node ok (Nat.mod_lt _ hm) (hx.bounded t)).1
  · have := (lag_node ok (Nat.mod_lt _ hm) (hx.bounded t)).2 _ (hx.edge t)
    simpa only [mod_succ_mod] using this

/-! ### Where runs eventually stay -/

/-- Record of width `rb + 1`: the rank, then a live bit. A step of equal rank must join two live nodes. -/
structure EvCert where
  labels : List Nat
  rb : Nat
  perms : Nat
  nodes : Nat

def evRec (c : EvCert) (n : Nat) : Nat := field c.nodes (Nat.add c.rb 1) n
def evLive (c : EvCert) (n : Nat) : Bool := Nat.beq (Nat.shiftRight (evRec c n) c.rb) 1

def evEdge (rb r r' : Nat) : Bool :=
  Nat.ble (rkOf rb r') (rkOf rb r) &&
    (!(Nat.beq (rkOf rb r') (rkOf rb r)) || (Nat.beq (Nat.shiftRight r rb) 1 && Nat.beq (Nat.shiftRight r' rb) 1))

noncomputable def checkEv (w m : Nat) (c : EvCert) : Bool :=
  permsOk w m c.labels c.perms &&
  allBelow m fun p =>
    let N := Nat.pow 2 w
    let a := field c.perms w p
    let base := Nat.mul p N
    let nextBase := Nat.mul (Nat.mod (Nat.add p 1) m) N
    allBelow N fun s =>
      let r := evRec c (Nat.add base s)
      four w N s (fun d => !(fitsRaw a s d) || evEdge c.rb r (evRec c (Nat.add nextBase d)))

theorem evIn_of_checkEv {w m : Nat} {c : EvCert} (hm : 0 < m) (ok : checkEv w m c = true) :
    EvIn w m (fun j => c.labels.getD j 0) (fun p s => evLive c (p * 2^w + s)) := by
  intro x hx
  let ρ (t : Nat) := evRec c ((t%m) * 2^w + x t)
  have edge (t : Nat) : evEdge c.rb (ρ t) (ρ (t+1)) = true := by
    rw [checkEv, Bool.and_eq_true] at ok
    have hp : t % m < m := Nat.mod_lt _ hm
    have hpf := allBelow_spec ok.2 hp
    dsimp only at hpf
    have hsf := allBelow_spec hpf (show x t < Nat.pow 2 w from hx.bounded t)
    try dsimp only at hsf
    have e := four_spec hsf (hx.edge t).1
    try dsimp only at e
    rw [fit_of_edge ok.1 hp (hx.edge t)] at e
    simpa only [ρ, Bool.not_true, Bool.false_or, raw_add, raw_mul, raw_pow, raw_mod, mod_succ_mod] using e
  have mono (t : Nat) (_ : 0 ≤ t) : rkOf c.rb (ρ (t+1)) ≤ rkOf c.rb (ρ t) := by
    have e := edge t
    unfold evEdge at e
    rw [Bool.and_eq_true] at e
    exact Nat.ble_eq.mp e.1
  obtain ⟨N, _, stable⟩ := antitone_eventually_const (fun t => rkOf c.rb (ρ t)) 0 mono
  refine ⟨N, fun t ht => ?_⟩
  have e := edge t
  have eq : rkOf c.rb (ρ (t+1)) = rkOf c.rb (ρ t) := (stable (t+1) (by omega)).trans (stable t ht).symm
  unfold evEdge at e
  rw [eq, Nat.beq_refl] at e
  simp only [Bool.and_eq_true, Bool.not_true, Bool.false_or] at e
  exact e.2.1

/-! ### Products of two eventual sets -/

/-- A strip of width `w` cut after `wa` cells. `ea`, `eb` list the live nodes of the two parts (fields of width
`nw`), `ia`, `ib` give each part node its index in its list (fields of width `xb`), and `nodes` holds the records of
the pairs, pair `(i, k)` at index `i * nb + k`. -/
structure ProdCert where
  labels : List Nat
  wa : Nat
  rb : Nat
  cb : Nat
  perms : Nat
  nw : Nat
  xb : Nat
  ea : Nat
  na : Nat
  ia : Nat
  eb : Nat
  nb : Nat
  ib : Nat
  nodes : Nat
  classes : Nat

def prodRec (P : ProdCert) (i k : Nat) : Nat :=
  field P.nodes (Nat.add (Nat.add P.rb P.cb) 5) (Nat.add (Nat.mul i P.nb) k)

/-- Every live node of a part appears in its list, at the index its index table gives. -/
noncomputable def listed (A : EvCert) (total e n x xb nw : Nat) : Bool :=
  allBelow total fun v => !(evLive A v) || (Nat.blt (field x xb v) n && Nat.beq (field e nw (field x xb v)) v)

noncomputable def prodNode (w m : Nat) (A B : EvCert) (P : ProdCert) (i k : Nat) : Bool :=
  let NA := Nat.pow 2 P.wa
  let NB := Nat.pow 2 (Nat.sub w P.wa)
  let eA := field P.ea P.nw i
  let eB := field P.eb P.nw k
  let p := Nat.div eA NA
  !(Nat.beq p (Nat.div eB NB) && Nat.blt p m) ||
    (let s := Nat.add (Nat.mod eA NA) (Nat.mul (Nat.mod eB NB) NA)
     let r := prodRec P i k
     let a := field P.perms w p
     let q := Nat.mod (Nat.add p 1) m
     nodeCond w P.rb P.cb P.classes r s &&
     four w (Nat.pow 2 w) s (fun d => !(fitsRaw a s d) ||
       (let nA := Nat.add (Nat.mul q NA) (Nat.mod d NA)
        let nB := Nat.add (Nat.mul q NB) (Nat.div d NA)
        !(evLive A nA && evLive B nB) ||
          edgeCond P.rb P.cb P.classes r (prodRec P (field P.ia P.xb nA) (field P.ib P.xb nB)))))

noncomputable def checkProd (w m : Nat) (A B : EvCert) (P : ProdCert) : Bool :=
  permsOk w m P.labels P.perms && Nat.ble P.wa w &&
  (listBeq A.labels (P.labels.take P.wa) && listBeq B.labels (P.labels.drop P.wa)) &&
  (listed A (Nat.mul m (Nat.pow 2 P.wa)) P.ea P.na P.ia P.xb P.nw &&
    listed B (Nat.mul m (Nat.pow 2 (Nat.sub w P.wa))) P.eb P.nb P.ib P.xb P.nw) &&
  allBelow P.na fun i => allBelow P.nb fun k => prodNode w m A B P i k

theorem listed_spec {A : EvCert} {total e n x xb nw : Nat} (h : listed A total e n x xb nw = true)
    {v : Nat} (hv : v < total) (live : evLive A v = true) :
    field x xb v < n ∧ field e nw (field x xb v) = v := by
  have := allBelow_spec h hv
  rw [live] at this
  simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true, Nat.blt_eq] at this
  exact ⟨this.1, Nat.eq_of_beq_eq_true this.2⟩

theorem run_congr {w m : Nat} {a b x : Nat → Nat} (h : ∀ j, j < w → a j = b j) (hx : Run w m a x) :
    Run w m b x := by
  refine ⟨hx.bounded, fun t => ?_⟩
  have eq : permit w a (t%m) = permit w b (t%m) := by
    apply Nat.eq_of_testBit_eq
    intro j
    rw [permit_bit, permit_bit]
    by_cases hj : j < w
    · rw [h j hj]
    · simp [hj]
  rw [← eq]
  exact hx.edge t

theorem goodAny_of_checkProd {w m : Nat} {A B : EvCert} {P : ProdCert} (hm : 0 < m)
    (hA : checkEv P.wa m A = true) (hB : checkEv (w - P.wa) m B = true)
    (ok : checkProd w m A B P = true) :
    GoodAny w m (fun j => P.labels.getD j 0) := by
  unfold checkProd at ok
  simp only [Bool.and_eq_true] at ok
  obtain ⟨⟨⟨⟨hperm, hwa⟩, hla, hlb⟩, lA, lB⟩, loop⟩ := ok
  have hwa : P.wa ≤ w := Nat.ble_eq.mp hwa
  have hlen : P.labels.length = w := (perm_of_permsOk hperm hm).2
  have eqA : A.labels = P.labels.take P.wa := by
    have := listBeq_eq A.labels (P.labels.take P.wa); rw [hla] at this; exact (beq_iff_eq.mp this.symm)
  have eqB : B.labels = P.labels.drop P.wa := by
    have := listBeq_eq B.labels (P.labels.drop P.wa); rw [hlb] at this; exact (beq_iff_eq.mp this.symm)
  let wb := w - P.wa
  let NA := 2 ^ P.wa
  let NB := 2 ^ wb
  have hNA : 0 < NA := Nat.two_pow_pos _
  have hsplit : 2 ^ w = NA * NB := by
    show 2 ^ w = 2 ^ P.wa * 2 ^ (w - P.wa)
    rw [← Nat.pow_add, Nat.add_sub_cancel' hwa]
  intro x hx
  -- the two parts are runs
  have runA : Run P.wa m (fun j => A.labels.getD j 0) (fun t => slice P.wa 0 (x t)) := by
    refine run_congr (fun j hj => ?_) (slice_run (k := 0) (v := P.wa) (by omega) hx)
    simp only [Nat.zero_add, eqA, List.getD_eq_getElem?_getD, List.getElem?_take, hj, ite_true]
  have runB : Run wb m (fun j => B.labels.getD j 0) (fun t => slice wb P.wa (x t)) := by
    refine run_congr (fun j hj => ?_) (slice_run (k := P.wa) (v := wb) (by omega) hx)
    simp only [eqB, List.getD_eq_getElem?_getD, List.getElem?_drop]
  obtain ⟨N1, h1⟩ := evIn_of_checkEv hm hA _ runA
  obtain ⟨N2, h2⟩ := evIn_of_checkEv hm hB _ runB
  -- decoding a part node
  have sA_eq (t : Nat) : slice P.wa 0 (x t) = x t % NA := by simp [slice, NA]
  have sB_eq (t : Nat) : slice wb P.wa (x t) = x t / NA := by
    have lt : x t / NA < NB := by
      rw [Nat.div_lt_iff_lt_mul hNA, Nat.mul_comm, ← hsplit]; exact hx.bounded t
    simp only [slice, Nat.shiftRight_eq_div_pow]
    exact Nat.mod_eq_of_lt lt
  have recombine (s : Nat) (hs : s < 2^w) : s % NA + (s / NA % NB) * NA = s := by
    have lt : s / NA < NB := by rw [Nat.div_lt_iff_lt_mul hNA, Nat.mul_comm, ← hsplit]; exact hs
    rw [Nat.mod_eq_of_lt lt, Nat.mul_comm]; exact Nat.mod_add_div s NA
  let nodeA (t : Nat) := (t % m) * NA + x t % NA
  let nodeB (t : Nat) := (t % m) * NB + x t / NA
  have liveA (t : Nat) (ht : max N1 N2 ≤ t) : evLive A (nodeA t) = true := by
    have := h1 t (by omega); rwa [sA_eq] at this
  have liveB (t : Nat) (ht : max N1 N2 ≤ t) : evLive B (nodeB t) = true := by
    have := h2 t (by omega); rwa [sB_eq] at this
  have boundA (t : Nat) : nodeA t < m * NA := by
    have := Nat.mod_lt (x t) hNA; have := Nat.mod_lt t hm
    calc (t % m) * NA + x t % NA < (t % m) * NA + NA := by omega
      _ = (t % m + 1) * NA := by rw [Nat.succ_mul]
      _ ≤ m * NA := Nat.mul_le_mul_right _ (by omega)
  have hNB : 0 < NB := Nat.two_pow_pos _
  have boundB (t : Nat) : nodeB t < m * NB := by
    have lt : x t / NA < NB := by rw [Nat.div_lt_iff_lt_mul hNA, Nat.mul_comm, ← hsplit]; exact hx.bounded t
    have := Nat.mod_lt t hm
    calc (t % m) * NB + x t / NA < (t % m) * NB + NB := by omega
      _ = (t % m + 1) * NB := by rw [Nat.succ_mul]
      _ ≤ m * NB := Nat.mul_le_mul_right _ (by omega)
  let i (t : Nat) := field P.ia P.xb (nodeA t)
  let k (t : Nat) := field P.ib P.xb (nodeB t)
  have idxA (t : Nat) (ht : max N1 N2 ≤ t) := listed_spec lA (by simpa [raw_mul, raw_pow] using boundA t) (liveA t ht)
  have idxB (t : Nat) (ht : max N1 N2 ≤ t) := listed_spec lB (by simpa [raw_mul, raw_pow, raw_sub] using boundB t) (liveB t ht)
  have decA (t : Nat) : nodeA t / NA = t % m ∧ nodeA t % NA = x t % NA := by
    constructor
    · show ((t % m) * NA + x t % NA) / NA = t % m
      rw [Nat.add_comm, Nat.add_mul_div_right _ _ hNA, Nat.div_eq_of_lt (Nat.mod_lt _ hNA), Nat.zero_add]
    · show ((t % m) * NA + x t % NA) % NA = x t % NA
      rw [Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_mod]
  have decB (t : Nat) : nodeB t / NB = t % m ∧ nodeB t % NB = x t / NA := by
    have lt : x t / NA < NB := by rw [Nat.div_lt_iff_lt_mul hNA, Nat.mul_comm, ← hsplit]; exact hx.bounded t
    constructor
    · show ((t % m) * NB + x t / NA) / NB = t % m
      rw [Nat.add_comm, Nat.add_mul_div_right _ _ hNB, Nat.div_eq_of_lt lt, Nat.zero_add]
    · show ((t % m) * NB + x t / NA) % NB = x t / NA
      rw [Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt lt]
  -- the product loop at the run's pair
  have at_t (t : Nat) (ht : max N1 N2 ≤ t) :
      nodeCond w P.rb P.cb P.classes (prodRec P (i t) (k t)) (x t) = true ∧
      edgeCond P.rb P.cb P.classes (prodRec P (i t) (k t)) (prodRec P (i (t+1)) (k (t+1))) = true := by
    have li := allBelow_spec loop (idxA t ht).1
    try dsimp only at li
    have lk := allBelow_spec li (idxB t ht).1
    unfold prodNode at lk
    dsimp only at lk
    rw [(idxA t ht).2, (idxB t ht).2] at lk
    simp only [raw_pow, raw_sub, raw_div, raw_mod, raw_add, raw_mul] at lk
    have dA1 : nodeA t / 2 ^ P.wa = t % m := (decA t).1
    have dA2 : nodeA t % 2 ^ P.wa = x t % 2 ^ P.wa := (decA t).2
    have dB1 : nodeB t / 2 ^ (w - P.wa) = t % m := (decB t).1
    have dB2 : nodeB t % 2 ^ (w - P.wa) = x t / 2 ^ P.wa := (decB t).2
    have hs : x t % 2 ^ P.wa + x t / 2 ^ P.wa * 2 ^ P.wa = x t := Nat.mod_add_div' (x t) _
    rw [dA1, dB1, dA2, dB2, hs, Nat.beq_refl] at lk
    have hblt : Nat.blt (t % m) m = true := Nat.blt_eq.mpr (Nat.mod_lt _ hm)
    rw [hblt] at lk
    simp only [Bool.and_true, Bool.not_true, Bool.false_or, Bool.and_eq_true] at lk
    refine ⟨lk.1, ?_⟩
    have e := four_spec lk.2 (hx.edge t).1
    try dsimp only at e
    rw [fit_of_edge hperm (Nat.mod_lt _ hm) (hx.edge t), mod_succ_mod] at e
    have la : evLive A ((t + 1) % m * 2 ^ P.wa + x (t+1) % 2 ^ P.wa) = true := liveA (t+1) (by omega)
    have lb : evLive B ((t + 1) % m * 2 ^ (w - P.wa) + x (t+1) / 2 ^ P.wa) = true := liveB (t+1) (by omega)
    rw [la, lb] at e
    simpa only [Bool.not_true, Bool.false_or, Bool.and_true] using e
  exact pairAny_of_records (N0 := max N1 N2) (fun t ht => (at_t t ht).1) (fun t ht => (at_t t ht).2)

private theorem pair_eq_of_bits' {s d j : Nat} (h₁ : s.testBit j = d.testBit j)
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

theorem goodAny_of_slice {w v k m : Nat} {a : Nat → Nat} (hk : k+v ≤ w)
    (good : GoodAny v m (fun j => a (k+j))) : GoodAny w m a := by
  intro x hx
  obtain ⟨j, L, N, hL, hj, h⟩ := good _ (slice_run hk hx)
  refine ⟨k+j, L, N, hL, by omega, fun t ht => ?_⟩
  obtain ⟨p, q⟩ := pair_bits (h t ht)
  rw [slice_bit (show j < v by omega), slice_bit (show j < v by omega)] at p
  rw [slice_bit hj, slice_bit hj, ← Nat.add_assoc] at q
  exact pair_eq_of_bits' p q

theorem goodAny_congr {w m : Nat} {a b : Nat → Nat} (h : ∀ j, j < w → a j = b j)
    (good : GoodAny w m a) : GoodAny w m b :=
  fun x hx => good x (run_congr (fun j hj => (h j hj).symm) hx)

theorem goodAny_of_rotated {w m q : Nat} {a : Nat → Nat} (hq : q < m)
    (ha : ∀ j, j < w → a j < m)
    (good : GoodAny w m (fun j => rotate m q (a j))) : GoodAny w m a := by
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
  obtain ⟨j, L, N, hL, hj, per⟩ := good y hy
  refine ⟨j, L, N+q, hL, hj, fun t ht => ?_⟩
  simpa only [y, show t-q+L+q=t+L by omega, show t-q+q=t by omega] using per (t-q) (by omega)

def ClassifiesAny (w m : Nat) (bad : List (List Nat)) : Prop :=
  ∀ a, Valid w m a → a 0 = 0 → GoodAny w m a ∨ labelsOf w a ∈ bad

theorem pairs_classifyAny (m : Nat) : ClassifiesAny 2 m (pairs m) := by
  intro a ha zero
  exact Or.inr (List.mem_map.mpr ⟨a 1, List.mem_range.mpr (ha 1 (by decide)), by
    simp [labelsOf, zero, show List.range 2 = [0,1] by decide]⟩)

theorem labelsOf_getD {w : Nat} {a : Nat → Nat} {j : Nat} (hj : j < w) : (labelsOf w a).getD j 0 = a j := by
  rw [List.getD_eq_getElem?_getD]
  have bound : j < (List.range w).length := by simpa using hj
  simp only [labelsOf, List.getElem?_map, List.getElem?_eq_getElem bound, List.getElem_range, Option.map_some,
    Option.getD_some]

/-- One width up: an assignment is good by a substrip, left in `remaining`, or one of the certified `cs`. -/
theorem classify_stepAny {w m : Nat} {previous remaining cs : List (List Nat)} (hw : 0 < w) (_hm : 0 < m)
    (prev : ClassifiesAny w m previous)
    (certs : ∀ l ∈ cs, GoodAny (w+1) m (fun j => l.getD j 0))
    (complete : ruledOut m previous remaining = cs) :
    ClassifiesAny (w+1) m remaining := by
  intro a ha zero
  rcases prev a (fun j h => ha j (by omega)) zero with good | leftWord
  · exact Or.inl (goodAny_of_slice (k:=0) (v:=w) (w:=w+1) (by omega) (by simpa using good))
  have ha1 := ha 1 (by omega)
  let b (j : Nat) := rotate m (a 1) (a (j+1))
  have hb : Valid w m b := fun j hj => rotate_lt ha1 (ha (j+1) (by omega))
  have b0 : b 0 = 0 := by simp [b, rotate]
  rcases prev b hb b0 with good | rightWord
  · have good' := goodAny_of_rotated ha1 (fun j hj => ha (1+j) (by omega))
      (show GoodAny w m (fun j => rotate m (a 1) (a (1+j))) by simpa [b, Nat.add_comm] using good)
    exact Or.inl (goodAny_of_slice (k:=1) (w:=w+1) (by omega) good')
  by_cases bad : labelsOf (w+1) a ∈ remaining
  · exact Or.inr bad
  have h := phase_extendF hw leftWord rightWord (ha w (by omega))
  have member : labelsOf (w+1) a ∈ ruledOut m previous remaining := by
    unfold ruledOut
    exact List.mem_filter.mpr ⟨h, by simp [List.contains_eq_mem, bad]⟩
  rw [complete] at member
  exact Or.inl (goodAny_congr (fun j hj => labelsOf_getD hj) (certs _ member))

theorem of_emptyAny {w m : Nat} (hw : 0 < w) (classified : ClassifiesAny w m []) {a : Nat → Nat}
    (ha : Valid w m a) : GoodAny w m a := by
  have h0 := ha 0 hw
  apply goodAny_of_rotated h0 ha
  have e := classified (fun j => rotate m (a 0) (a j))
    (fun j hj => rotate_lt h0 (ha j hj)) (by simp [rotate])
  simpa only [List.not_mem_nil, or_false] using e

end Rule30Submission.FallParities

/-! ## FallParityData -/

/-!
# Every parity assignment of a 27-cell strip forces a repeating adjacent pair

Support for `Rule30FallParities`. Fifteen certificates, of widths 4 to 20: nine as full tables (`checkLag`), and six
as tables over the product of where the two halves of the strip eventually stay (`checkEv`, `checkProd`). The
assignments still possible at each width, from 3 to 27, are those whose two narrower restrictions are; none is left
at 27 (`goodAny27`). The lists and the certificates were generated by computer search and are checked by the kernel.
-/


namespace Rule30Submission.FallParities

open Ruliology.CellularAutomata Rule30StripCertificates Rule30Submission.KitFallResidues

set_option maxRecDepth 100000
set_option maxHeartbeats 0

def lag0 : LagCert := ⟨[0, 0, 1, 1], 3, 3, 0xc3, 0x1702500100014c0080100017025001000004020660000000000000404c028030000000500500607002026, 0x40000000000000002840000000000000002840000000000000001440000000000000000000⟩
theorem lag0_ok : checkLag 4 2 lag0 = true := by decide +kernel
theorem good_0011 : GoodAny 4 2 (fun j => lag0.labels.getD j 0) := goodAny_of_checkLag (by decide) lag0_ok

def lag1 : LagCert := ⟨[0, 1, 1, 0], 4, 3, 0x69, 0x20a30010080050b60920010030010010c9000000012007000023001001000000012007000036004049, 0x40000000000000002840000000000000002840000000000000001440000000000000000000⟩
theorem lag1_ok : checkLag 4 2 lag1 = true := by decide +kernel
theorem good_0110 : GoodAny 4 2 (fun j => lag1.labels.getD j 0) := goodAny_of_checkLag (by decide) lag1_ok

def lag2 : LagCert := ⟨[0, 1, 0, 1, 0], 4, 3, 0x155, 0x940030010010010080000000b60050020a30010010000000010010070050010c9000000000000000023001007000002014001000001001001000000000000000023001007000004036001000001008049, 0x40000000000000001440000000000000002840000000000000001440000000000000000000⟩
theorem lag2_ok : checkLag 5 2 lag2 = true := by decide +kernel
theorem good_01010 : GoodAny 5 2 (fun j => lag2.labels.getD j 0) := goodAny_of_checkLag (by decide) lag2_ok

def lag3 : LagCert := ⟨[0, 1, 0, 1, 1], 4, 3, 0x345, 0xb60050020a30010010000000940030010010010010000000b60050020a30010010000000010010070050010c9000000000000000000000000000002014001000001004002000000000000000023001007000004036001000001008049, 0x40000000000000001440000000000000002840000000000000001440000000000000000000⟩
theorem lag3_ok : checkLag 5 2 lag3 = true := by decide +kernel
theorem good_01011 : GoodAny 5 2 (fun j => lag3.labels.getD j 0) := goodAny_of_checkLag (by decide) lag3_ok

def lag4 : LagCert := ⟨[0, 1, 1, 1, 0, 1], 4, 3, 0xb91, 0x20020920010010010010060030040020010060b70010010010010010010010010010010000000000000000000000000020020920010010010010060020020030010060c80010010060080010010050010010a8000000000000000000000000000000000000000000000000000000000000000037005003000000001001000003002007000000000000000048005004000000012003000001001001000000000000000001001001000000004005000009006028, 0x2840000000000000002840000000000000000040000000000000001440000000000000000000⟩
theorem lag4_ok : checkLag 6 2 lag4 = true := by decide +kernel
theorem good_011101 : GoodAny 6 2 (fun j => lag4.labels.getD j 0) := goodAny_of_checkLag (by decide) lag4_ok

def lag5 : LagCert := ⟨[0, 1, 1, 1, 1, 0, 1], 4, 3, 0x2f21, 0x20020020010040950010010010010010010040010010080060030040010020020010010040080a20010010010010010010010010010010010010010010010010010010010010010000000000000000000000000000000000000000000000000020020020010040950010010010010010010040010010080020020020010040060010010080080b30010010010010010040080030010010010010010080080010010050010010ca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002200900000700300200000000000000000100100100000000300300000200500900000000000000000000000000000003300900000700700200000000000000001500300300000000100100000100100100000000000000000000000000000000100100000100100100000000000000000700700500000000400900000900604a, 0x40000000000000001440000000000000001440000000000000002840000000000000000000⟩
theorem lag5_ok : checkLag 7 2 lag5 = true := by decide +kernel
theorem good_0111101 : GoodAny 7 2 (fun j => lag5.labels.getD j 0) := goodAny_of_checkLag (by decide) lag5_ok

def lag6 : LagCert := ⟨[0, 1, 1, 1, 1, 1, 0, 1], 4, 3, 0xbe41, 0x200200200100200200100100400409200100100100100100100100100100100100100100800a00100100500100100300700c0030010040040010010020020020010010010010010030040050010060b700100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200200200100200200100100400409200100100100100100100100100100100100100100800a0010010050010010030020020020010020020010010040040030010010010010010030060050010080c900100100100100100100100100100100300400500100600800100100100100100100100100100100600e00500100100100100100600a0010010070010010a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003700500600000000400d00000300200200000000000000000000000000000000100100000100100100000000000000000300300300000000200200000b00600400000000000000000000000000000000000000000000000000000000000000004900700600000000400d00000500200200000000000000000000000000000001200500000300300200000000000000000100100100000000100100000100100100000000000000000000000000000000000000000000000000000000000000000100100100000000100100000100100100000000000000000000000000000000400500000d00500200000000000000000900500600000000600f00000b008029, 0x2840000000000000002840000000000000000040000000000000001440000000000000000000⟩
theorem lag6_ok : checkLag 8 2 lag6 = true := by decide +kernel
theorem good_01111101 : GoodAny 8 2 (fun j => lag6.labels.getD j 0) := goodAny_of_checkLag (by decide) lag6_ok

def lag7 : LagCert := ⟨[0, 1, 1, 1, 1, 1, 1, 0, 1], 4, 3, 0x2fc81, 0x20020020010020020010010020020020010010010010010030040040010060c700100100100100100100100100100100100100100100100100100100100100100100100100100100d0050040010010010010011d90050010010060010010030080d900600100300300100100400400400100100100100100200200200100200200100100100100100100100100100100300300400100b00500100100d0050920010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020020020010020020010010020020020010010010010010030040040010060c700100100100100100100100100100100100100100100100100100100100100100100100100100100d00500400100100100100100a00500100100600100100300200200200100200200100100200200200100100100100100300400400100600800100100100100100100100100100100300300600100a00500100100d0050a300100100100100100100100100100100100100100100100100100100100100100300300400100b00500100100d00500300100100100100100100100100100100100100100100100100100100100100100300600800100600a00100100100100100100100100100100d00500500100100100100100800c0010010070010010b900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001200e00000400c00200000000000000000400a00700000000300300000200200200000000000000000000000000000000000000000000000000000000000000000100100100000000100100000100100100000000000000000000000000000000300300000300300200000000000000000200200200000000500e00015900700400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002300e00000400c00200000000000000000405900700000000500500000200200200000000000000000000000000000000000000000000000000000000000000004700500500000000300300000300200200000000000000000000000000000000100100000100100100000000000000000100100100000000100100000100100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000100100100000000000000000100100100000000100100000100100100000000000000000000000000000000000000000000000000000000000000000900500500000000700a00000500200200000000000000000000000000000000400e00000400c00200000000000000000b00700900000000600e00000d008039, 0x3a480000000000000002840000000000000000040000000000000001440000000000000001440000000000000000000⟩
theorem lag7_ok : checkLag 9 2 lag7 = true := by decide +kernel
theorem good_011111101 : GoodAny 9 2 (fun j => lag7.labels.getD j 0) := goodAny_of_checkLag (by decide) lag7_ok

def lag8 : LagCert := ⟨[0, 0, 0, 0, 0, 0, 0, 0, 1, 0], 5, 3, 0x402ff, 0x4a00080060000000008004000002c00400200000000000000000000000000000000000800400000240100020000000000000000000c00600300000000040020000008004002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020010000004002001000000000000000000040020010000000002001000000400200100000000000000000000000000000000000000000000000000000000000000000000000c0060030000000006003000000c00400200000000000000000000000000000000000400200000080040020000000000000000002c008006000000000c00b000001c00800400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005240080060000000008004000002c00400200000000000000000000000000000000000800400000240100020000000000000000001400800500000000040020000008004002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002d0007000001000a0020000000000000000000c0060030000000006003000000800400200000000000000000000000000000000000000000000000000000000000000000000000400200100000000020010000004002001000000000000000000000000000000000002001000000400200100000000000000000004002001000000000200100000040020010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004002001000000000200100000040020010000000000000000000000000000000000020010000004002001000000000000000000040020010000000002001000000400200100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014007000001000a0020000000000000000003400c00d000000000a00500000080040020000000000000000000000000000000000000000000000000000000000000000000000280080060000000008004000002c004002000000000000000000000000000000000018007000001001e00200000000000000000030008006000000001c01100000380261940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100080040010010008002001001000800400100080040020010010008004001001000800200100080040020010008004002001001800c008001002001000200100300140d00010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001001803000a001003802800200100080040020010008004002001004802800a00100080040020010030018002001001800400600300280200180010038030002001001800c0060010008004002001001801000800100200100020010008004002001000800400200100100080040010010008002001001000800400100080040020010008004002001000800400200100080040020010008004002001001800c0060010020010002001004802800a0010008004002001001803000a00100380a00020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100080040010010008002001001000800400100080040020010010008004001001000800200100080040020010008004002001001800c008001002001000200100300140d00010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001001803000a001003802800200100080040020010008004002001004802800a00100080040020010030018002001001800400600300100080040010010008002001001000800400100080040020010010008004001001000800200100080040020010008004002001001800c0080010020010002001003001401200100080040020010008004002001000800400200100080040020010008004002001001800c0060010030018002001004802800a0010008004002001001803000a00100381240020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001001800c0060010020010002001004802800a0010008004002001001803000a00100380240020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001000800400200100080040020010008004002001001800c00c0010070038002001003001401600100080040020010008004002001000800400200100080040020010008004002001001803000a001003802c00200100080040020010008004002001008001401a00100080040020010038034002001009000401e094, 0x40000000000000001440000000000000002840000000000000002840000000000000000000⟩
theorem lag8_ok : checkLag 10 2 lag8 = true := by decide +kernel
theorem good_0000000010 : GoodAny 10 2 (fun j => lag8.labels.getD j 0) := goodAny_of_checkLag (by decide) lag8_ok

def blockA0 : EvCert := ⟨[0, 0, 0, 0, 0, 0], 3, 0x3f, 0xd4d00dd0d220000000000dd0dd200000ddd00dd0dddddd1dd11ddd111113dd1dd1111111111ddd1dd11ddd11111ddd11111dd11d1dd⟩
def blockB0 : EvCert := ⟨[0, 0, 0, 0, 0, 0], 3, 0x3f, 0xd4d00dd0d220000000000dd0dd200000ddd00dd0dddddd1dd11ddd111113dd1dd1111111111ddd1dd11ddd11111ddd11111dd11d1dd⟩
def prod0 : ProdCert := ⟨[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 6, 5, 3, 0xfff, 7, 6, 0x6ad197262ab529519526445890a0c07ef9ebb74ddb355cb55aa3e78e9b345cb151e386870c0c080, 0x2d, 0x2c02b000aa90280000000000000000009e60259000000000238a100081f01e75c6da6406170005955000000000134804500000000000000003ce34030b0002892000000001c6140000000103000080040, 0x6ad197262ab529519526445890a0c07ef9ebb74ddb355cb55aa3e78e9b345cb151e386870c0c080, 0x2d, 0x2c02b000aa90280000000000000000009e60259000000000238a100081f01e75c6da6406170005955000000000134804500000000000000003ce34030b0002892000000001c6140000000103000080040, 0x127009000002016c00000046d80000a40000024000000802800000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002806000000600300000020060000018000018000000400c0000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c006000009000c00000100180000060000018000002003000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600300000580080000008010000004000000c00000100200000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004006000000e018000000400800000200007f80000008010000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100003540040008620024010008000801c0001d5004800400c00700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000007002000400e018003801c004007000001c030002003801c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000001001000200200200580040020010000004004001000800400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000014014001002807001001800100140000052fe000800a00500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000006001002000c002005001006002400000180040300030080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000300080080060010010008004016000000c002002001800400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000018004ff800300080680040080090000006001004000c00c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000c00200100180040020050008018000018000800403001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000006001000800c0020010fe000400c000004800400200900380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000800800000100100000040000000000002002000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000004004000000800800000200000000000010010000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000020020000004004000001000000000000080080001d4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054006002000800c000003001000c0040010010054006002000800c0000030010000006002000800c0040030008000000000000000000000000000000000000000000000000000000002600300100040060000018008006002000800802600300100040060000018008000003001000400600200180040000000000000000000000000000000000000000000000000000000011001000800200200000080040020010004004011001000800200200000080040000010008002002001000803200000000000000000000000000000000000000000000000000000000038024004001004800003600237e000800200200380740040010048000036002000006c004001004800803a004000000000000000000000000000000000000000000000000000000000440320020008064000006001001400400100100440320020008064000006001000000c00200080640040190020000000000000000000000000000000000000000000000000000000000c00327e0004006000004807400400b000800c00c00327e0004006000004807400000900e800400601d001801800000000000000000000000000000000000000000000000000000000030018014002003000005c00a00200280040060030018014002003000005c00a00000b8014002003002800c0060000000000000000000000000000000000000000000000000000000007800c03200100180000220190010014002003007800c03200100180000220190000044032001001806400600d0000000000000000000000000000000000000000000000000000000001400a00217e0014000005001006401000d002801403200817e0014000005001000000a00200e80140100190008000000000000000000000000000000000000000000000000000000000a005001001000a000002800800a017002001000a00500b801000a0000028008000005001001000a017002800400000000000000000000000000000000000000000000000000000000070038008032007000001c004007003806400c007003801c032007000001c0040000038008032007003801c0020000000000000000000000000000000000000000000000000000000007802c00401302400004d8002006804402602700781b0022013024000001a0020000034004013004804401a001000000000000000000000000000000000000000000000000000000000040000010008000002000000800000200000000040000010008000002000000800400000100080000020000000000000000000000000000000000000000000000000000000000000000200000080040000010000004000001000000000200000080040000010000004002000000800400000100000140000000000000000000000000000000000000000000000000000000019000006400e00007e00000080000020000000019000006400e00000e800000801d000001000e00000c800000a00000000000000000000000000000000000000000000000000000000020000008017000000c00000400000100000000020000008017000000c00000400180000080170000010000007000000000000000000000000000000000000000000000000000000000100000040098000006000002000000800000000100000040098000006000002000c00000400980000080000078000000000000000000000000000000000000000000000000000000000c00000300180000190000018000006000000000c00000300180000190000018032000003001800000600000000000000000000000000000000000000000000000000000000000000003000000c00600000180000060000018000000003000000c0060000018000006003000000c00600000180000000000000000000000000000000000000000000000000000000000000006800055400f000004400008800002a8000000006800001600f0000044000088008800001200f000002c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e000000000000000000000000000000000000000000000000000000000080000020010000004000001000000400000000080000020010000004000001000800000200100000040000070000000000000000000000000000000000000000000000000000000000400000100080000020000008000002000000000400000100080000020000008004000001000800000200000880000000000000000000000000000000000000000000000000000000002000000800400000100000040000010000000002000000800400000100000040020000008004000001000004400000000000000000000000000000000000000000000000000000000010000004002000000800000200000080000000010000004002000000800000200100000040020000008000026000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d4, 0xde850000000000000000004000000000000001548000000000000000144000000000000002a880000000000000002840000000000000002840000000000000000000⟩
theorem blockA0_ok : checkEv prod0.wa 2 blockA0 = true := by decide +kernel
theorem blockB0_ok : checkEv (12 - prod0.wa) 2 blockB0 = true := by decide +kernel
theorem prod0_ok : checkProd 12 2 blockA0 blockB0 prod0 = true := by decide +kernel
theorem good_000000000000 : GoodAny 12 2 (fun j => prod0.labels.getD j 0) := goodAny_of_checkProd (by decide) blockA0_ok blockB0_ok prod0_ok

def blockA1 : EvCert := ⟨[0, 0, 1, 0, 0, 0, 0], 4, 0x27b, 0xa41005220000006427066e100442000000000000000000000000006439066e100442000000000000a61005420000006439008a10053a000c3ce4210026308421002f9ce42100021084210011946421002430842100021084210002108421002eace421002630842100119ce421000210842100119ce42100021084210008308421000214285a⟩
def blockB1 : EvCert := ⟨[0, 0, 0, 0, 0, 0, 1], 4, 0x203f, 0x5c97002f705c420000000000002c500c6200000004210002100421000000000000000000000000005c97002f7020420000000000002f705ee20000005c97002f705ef700000000000000000000000000000000000000001084110821212c1084210842108421bdc21b86e3bdee1ba021bdee1084211a6e1bdc2108421084211a6e1bdc210842108421bdee108421bdc21b86f7⟩
def prod1 : ProdCert := ⟨[0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], 7, 5, 3, 0x8011ffb, 8, 6, 0xd5cac6c5aaa8a6a5958a88807b7a756d6c6b6a5c5a553d3b3a352c2b2a1c1b1a00, 0x21, 0x80000000000000001f00001e74000000000000000000000000000000000000001c01b01a6400000000000000000000006000000000000000170160000000000150000005130000004800000000004503ce00000000000000000000d00c0000002c00000000000000000000000000000000002802480000001c0000000000006144000000000000000000003081000000000000000000000000000000000000000, 0xeae8e5e4e2d5aaa8a5a4959492918a88858482818055474643413f3e3d3b3736352d2b2a1d1b1a0f0e0d0706030100, 0x2f, 0x2e02d000b2b02a000000000000000000a400000000000000000000000000000000000000000000000000000000000000280270009a500000000000000000000092302284000000002001f00079d01c6da00000000000000000000000000000000000000000000000000000000000000064000000000000000000061700058054051348044000040f38000000000034030b0000000000000000002802480000000000000001c6140000000103000080040, 0x68001c00000600200001a00070000018000000801800000200700000020040000028000000000000000000000000000000000000000000000000000000000000000000000000000000000000001800c00059700180000060030000060000001001800000600300000040060000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000004003000002601b000001000c0000098000002004000001000c0000008010000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400200000080040000010008000002000000400400000100080000010010000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000d002000428e002000003400816900d804c002002000002c0360020078044000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000e0040008014004000003801000e01a00c8004004000003806800400700380000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000014006001001800800000500180140060180008008000005001800800a19700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000001000000000200000080000000010000000002000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000030008010002001000000c0020030008014004001000000c0020010018030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000600100080040020000018004006001000801400200000180040023970098000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000c0020010008004000003000800c0020010040004000003000800402a79700000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000004002000000800000000100000040020000008000000001000800024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100080046970010008002000001000800400100100080020020000008004001001000800401600000000000000000000000000000000000000000000000000000000000000000000000000200200100080280020010004000002001000800200200100040040000010008002002001000852e0000000000000000000000000000000000000000000000000000000000000000000000000040040020028034004002000800000c0020010004004002000800800000600100040040020010010000000000000000000000000000000000000000000000000000000000000000000000000008004002001000800400200100000040020010008004002001000800000200100080040020010010000000000000000000000000000000000000000000000000000000000000000000000000010018010004018001801000200000c8010008001001801000200300000640080010018010006006000000000000000000000000000000000000000000000000000000000000000000000000002003002800801000300d800400001a00d8014002003002800400600000d006c00200300d800c010000000000000000000000000000000000000000000000000000000000000000000000000004006005001004800601c000800002801c0028004006005000800c00001400e000400601c001804000000000000000000000000000000000000000000000000000000000000000000000000003801402801c002801400400700000140040140038014028007002800000a0020038014004005000800000000000000000000000000000000000000000000000000000000000000000000000004002125c0080040020008008000002000803200400200640080040000010004004002000800800100000000000000000000000000000000000000000000000000000000000000000000000001e0010068024016005001003c000007001003401e0a0006803c002000003800801e003001001400200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000002000000000800000b000000800000480000080040000000008000000002400000400000000080000000000000000000000000000000000000000000000000000000000000000000000000000040000000010000018000001000000600000100080000000010000000003000000800000000100000040000000000000000000000000000000000000000000000000000000000000000000000080000000020000008000002000000600000200100000000020000000003000001000000000200000160000000000000000000000000000000000000000000000000000000000000000000000200000000060000018000006000000800000600300000000060000000004000003000000000600000000000000000000000000000000000000000000000000000000000000000000000000000600000000100000040000010000001000001000800000000100000000008000008000000001000000000000000000000000000000000000000000000000000000000000000000000000000008e0000000038000010000003000000200001a401c00000000380000000010000014000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020, 0x1440000000000000eaa100000000000000002840000000000000002840000000000000000040000000000000000000⟩
theorem blockA1_ok : checkEv prod1.wa 2 blockA1 = true := by decide +kernel
theorem blockB1_ok : checkEv (14 - prod1.wa) 2 blockB1 = true := by decide +kernel
theorem prod1_ok : checkProd 14 2 blockA1 blockB1 prod1 = true := by decide +kernel
theorem good_00100000000001 : GoodAny 14 2 (fun j => prod1.labels.getD j 0) := goodAny_of_checkProd (by decide) blockA1_ok blockB1_ok prod1_ok

def blockA2 : EvCert := ⟨[0, 0, 0, 0, 0, 0, 0, 1], 4, 0x807f, 0x3180130200000063180031800842000000000000000000000000005c850006300c420000000000000210042100000004210002100421000000000000000000000000000000000000000000000000000031801302000000271800129008420000000000000000000000000060980031806042000000000000318013020000006098003180631800000000000000000000000000000000000000000000000000000000000000000000000000000000108411082110841084211908135c21084210842108421084210842108421c170108421c6021c0463c6301c6021c1521084211e301c6021084210842118d41c2821c1701084210842108421084210842118d41c2821c170108421084210842108421084211a701c60210842108421c170108421c6021c0718⟩
def blockB2 : EvCert := ⟨[0, 0, 0, 0, 0, 0, 1], 4, 0x203f, 0x5c97002f705c420000000000002c500c6200000004210002100421000000000000000000000000005c97002f7020420000000000002f705ee20000005c97002f705ef700000000000000000000000000000000000000001084110821212c1084210842108421bdc21b86e3bdee1ba021bdee1084211a6e1bdc2108421084211a6e1bdc210842108421bdee108421bdc21b86f7⟩
def prod2 : ProdCert := ⟨[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1], 8, 5, 3, 0x20403f7f, 9, 6, 0x1d5ea74795c9e471789aaaad52a349a44aa51259248a2b1488c2a11058240a03005523d1a874320cfe7e3e9ecf477371b4d66a2d95caa3b1b8d43a1b0d03c1a070300c0200, 0x3d, 0xf3b000e80000000039e37000db5000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cf2000c40000000000c2f00000000000000000000000000000000000000000002e02d000b2b02a000000000000000000a680009c000000002602500092302286000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f00000000000000000000000000000000000000078074000000071b0006800006585c05950005000000000000134804500000000000000000000003c00003803400000000000000000000000000000000000003000002c0280000000000000000000000000000000000240207000000000000000180140000000103000080040, 0x3a9d0e572389aaaa5429548954a249228a44215088240a00aa472310c823f1f0f476371b0d45a2b15074361a078381a070300c0200, 0x2f, 0x2e02d000b2b02a000000000000000000a400000000000000000000000000000000000000000000000000000000000000280270009a500000000000000000000092302284000000002001f00079d01c6da00000000000000000000000000000000000000000000000000000000000000064000000000000000000061700058054051348044000040f38000000000034030b0000000000000000002802480000000000000001c6140000000103000080040, 0x402400000a00040000010090000028000001800400000100900000060010000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000802c00000b000800000200b000002c000003000800000200b000000c002000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000100480000120010000004012000004800000600100000040120000018004000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200200000080020000008008000002000000800200000080080000020008000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400c0000030004000001003000000c0000030004000001003000000c0010000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000801c0000180008000002007000006000001600080000020070000058002000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000040010000004004000001000000400100000040040000010004000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200200000080020000008008000002000000800200000080080000020008000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000048001c00000600200001200070000018000000801800000200700000020040000028000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000005a00000000080000318000000000400000000700000000120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c000000003800000000b000002c000000000800000000b0000000016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000480000000050000000012000004800000000100000000120000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000060000000018000006000000000200000000180000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000000000c000000003800000e0000000004000000003800000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000002002000000400000000080000020020000004000000000800400000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000004004000000800000000100000040040000008000000001000800000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000008058000001000000000200000080600000010000000002001000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000010058000002000000000400000100e000000200000000040020000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000200200000040000000008000002002000000400000000080040000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000400400000080000000010000004004000000800000000100080000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000800800000100000000020000008008000001000000000200100000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000001001000000200000000040000010010000002000000000400200000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000002002000000400000000080000020020000004000000000800400000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000400200000080000000010000004002000000800000000100080000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000005000800400200100000140020050008004028001000001400200100b0010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000a0010008004002000002800400a001000802c002000002800400200b00200000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000060002001000800400001800080600020010048004000018000800403401000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000020004002001000800000800100200040020040008000008001000801000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000008004000001000000000200000080040000010000000002001000054800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e0010068024016005001003c000007001003401e020006803c002000003800801e003001001400200000000000000000000000000000000000000000000000000000000000000000000000002800400a00100080040040050000004004005002800400a00500080000020020028004004001000400000000000000000000000000000000000000000000000000000000000000000000000009800802a00200100080080130000008008015009800802a013001000000400400980080080020008000000000000000000000000000000000000000000000000000000000000000000000000080010064004002001005c010000001005c0320080010064010002000000802e008001005c0040010000000000000000000000000000000000000000000000000000000000000000000000000060020018008004002001800c000002001800c006002001800c004000001000c006002001800800200000000000000000000000000000000000000000000000000000000000000000000000000c00400300100080040030018000004003001800c0040030018008000002001800c004003001000400000000000000000000000000000000000000000000000000000000000000000000002000000000a000002800000a000002800000a005000000000a0000000014000005000000000a000000000000000000000000000000000000000000000000000000000000000000000000000004000000006400001b000006400000a0000064032000000006400000000500000320000000064000000000000000000000000000000000000000000000000000000000000000000000000000008000000003000002e000003000002a0000030018000000003000000001500000180000000030000000000000000000000000000000000000000000000000000000000000000000000000000008000000001000000400000100000040000010008000000001000000000200000080000000010000000000000000000000000000000000000000000000000000000000000000000000000000010000000002000000800000200000080000020010000000002000000000400000100000000020000000000000000000000000000000000000000000000000000000000000000000000000000020000000004000001000000400000100000040020000000004000000000800000200000000040000000000000000000000000000000000000000000000000000000000000000000000000000040000000008000002000000800000200000080040000000008000000001000000400000000080000000000000000000000000000000000000000000000000000000000000000000000000000080000000010000004000001000000400000100080000000010000000002000000800000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000020000008000002000000800000200100000000020000000004000001000000000200000000000000000000000000000000000000000000000000000000000000000000000000000200000000040000010000004000001000000400200000000040000000008000002000000000400000b00000000000000000000000000000000000000000000000000000000000000000000001000000000400000100000040000004000004002000000000400000000020000020000000004000000400000000000000000000000000000000000000000000000000000000000000000000003000000000a000002800000a000000800000a005000000000a0000000004000005000000000a0000008000000000000000000000000000000000000000000000000000000000000000000000680000000022000009800001e00000100001180110000000022000000000800000d000000001e0000010000000000000000000000000000000000000000000000000000000000000000000000020000000004000001000000400000100000040020000000004000000000800000200000000040000010000000000000000000000000000000000000000000000000000000000000000000000040000000008000002000000800000200000080040000000008000000001000000400000000080000020000000000000000000000000000000000000000000000000000000000000000000000080000000010000004000001000000400000100080000000010000000002000000800000000100000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000400000000080000020000008000002000000800400000000080000000010000004000000000800001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000052, 0x1440000000000000001440000000000000000040000000000000002840000000000000000000⟩
theorem blockA2_ok : checkEv prod2.wa 2 blockA2 = true := by decide +kernel
theorem blockB2_ok : checkEv (15 - prod2.wa) 2 blockB2 = true := by decide +kernel
theorem prod2_ok : checkProd 15 2 blockA2 blockB2 prod2 = true := by decide +kernel
theorem good_000000010000001 : GoodAny 15 2 (fun j => prod2.labels.getD j 0) := goodAny_of_checkProd (by decide) blockA2_ok blockB2_ok prod2_ok

def blockA3 : EvCert := ⟨[0, 0, 0, 0, 0, 0, 0, 1, 0], 5, 0x1017f, 0xaaa004a8200000000426a0000c30020820000000000000000000000000000000010410000410010410000000000000000c30030c2000000002082000aaa00c1c4000000000000000000000000000000000000000000000000000000000000000aaa004a8200000000426a0001450020820000000000000000000000000000000271050000c30030820000000000000000410010410000000010410000410010410000000000000000000000000000000000000000000000000000000000000000410010410000000010410000410010410000000000000000000000000000000091050002ce00508200000000000000030c00430200000000b11000038e0124340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000820810820410820810410410c41011a7041041041041041041041041041041041041041a85a810410412c50411810c320da810c30411041010410410820810820410410410410410c3101a85041a85a810410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000820810820410820810410410c41011a70410410410410410410410410410410410410412c52c10410412c50411810c30820810820410820810410410c41011880410410410410410c3181a85041a85a810410410410410410410410410410410c31012c50412c52c10410410410410410410410410410410c63c118a04104104104104134534104104144c0413c14f4⟩
def blockB3 : EvCert := ⟨[0, 0, 0, 0, 0, 0, 1, 0], 4, 0x40bf, 0x60980009800c42000000000000021004210000000c63000420630700000000000000000000000000609800098014420000000000002c500c62000000042100021004210000000000000000000000000004210002100421000000000000105024a2000000288a0014b031be00000000000000000000000000000000000000001084110821212c1084210842108421c6021c04c3c606121021108410842119301c60210842108421084210842108421084210842108421084210842100000000000000000000000000000000000000001084110821212c10842108421084214a421484c31084110821210e10842119b01c60210842108421191214a421084210842132921084215ac21605be⟩
def prod3 : ProdCert := ⟨[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], 9, 5, 3, 0x101017f7f, 0xa, 5, 0xd5754d4748c1704b56d4b46c8aaa006a98f6357d56d57554aa16c5715400, 0x18, 0x2f6002a000000000140000000000000000000000000000000000000000000000000000000000000000000000000000000000272000000000000000000000000000000000000000000000000000000000230001e0000000000e000000000000000000000000000000000000340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c000000000000000000000000000000005012000000000000000000100000000000000000000000000000000000000000038000300a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001800010020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, 0x6a9a8691826056a5a16455500354c7318c32fcbe2b4ab2a8550b42b0a800, 0x18, 0x5c160001500000000000000000000000000000000000000000526000000000000000000000000000481100010000000000000000001e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000001a000000000000000062c00500004a000000000000000000000e031400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000601040000000000000000000000000000000000000000000000000000, 0xb7000c002011000063c0060010000000000000000000000000000000000000000000000000000006800c00200d00000340060010000000000000000000000000000000000000000000000000000005800c00200b000002c0060010000000000000000000000000000000000000000000000000000004800c002009000002400600100000000000000000000000000000000000000000000000000000038054002007000001c02a00100000000000000000000000000000000000000000000000000000038034002007000001c01a0010000000000000000000000000000000000000000000000000000002800002600500080140000130008008000000000000000000000000000000000000000000000002800001a005000801400000d00080080000000000000000000000000000000000000000000000028000016005000801400000b000800800000000000000000000000000000000000000000000000b8000012017000005c0000090000008000000000000000000000000000000000000000000000001000000800200080080000040a0000c0000000000000000000000000000000000000000000000008000002001000000400000100004800000000000000000000000000000000000000000000000000000000000000000000000000000000000010018014000003002800400600000280040060020000000000000000000000000000000000000010030030000006006000400c000006000400c002000000000000000000000000000000000000001003005000000600a000400c00000a000400c002000000000000000000000000000000000000016004000800000800100580100000010058010001000000000000000000000000000000000000004005000800000a00100100140000010010014001000000000000000000000000000000000000004006000800000c00100100180000010010018001000000000000000000000000000000000000004008000800001200100100dc000001001011e001000000000000000000000000000000000080000000000000400000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000020, 0x1440000000000000001440000000000000002840000000000000000040000000000000000000⟩
theorem blockA3_ok : checkEv prod3.wa 2 blockA3 = true := by decide +kernel
theorem blockB3_ok : checkEv (17 - prod3.wa) 2 blockB3 = true := by decide +kernel
theorem prod3_ok : checkProd 17 2 blockA3 blockB3 prod3 = true := by decide +kernel
theorem good_00000001000000010 : GoodAny 17 2 (fun j => prod3.labels.getD j 0) := goodAny_of_checkProd (by decide) blockA3_ok blockB3_ok prod3_ok

def blockA4 : EvCert := ⟨[0, 0, 0, 0, 0, 0, 0, 1, 0], 5, 0x1017f, 0xaaa004a8200000000426a0000c30020820000000000000000000000000000000010410000410010410000000000000000c30030c2000000002082000aaa00c1c4000000000000000000000000000000000000000000000000000000000000000aaa004a8200000000426a0001450020820000000000000000000000000000000271050000c30030820000000000000000410010410000000010410000410010410000000000000000000000000000000000000000000000000000000000000000410010410000000010410000410010410000000000000000000000000000000091050002ce00508200000000000000030c00430200000000b11000038e0124340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000820810820410820810410410c41011a7041041041041041041041041041041041041041a85a810410412c50411810c320da810c30411041010410410820810820410410410410410c3101a85041a85a810410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000820810820410820810410410c41011a70410410410410410410410410410410410410412c52c10410412c50411810c30820810820410820810410410c41011880410410410410410c3181a85041a85a810410410410410410410410410410410c31012c50412c52c10410410410410410410410410410410c63c118a04104104104104134534104104144c0413c14f4⟩
def blockB4 : EvCert := ⟨[0, 0, 0, 0, 0, 0, 0, 0, 1], 5, 0x200ff, 0x28106000104012082000000000000000c30030202000000030130000082002082000000000000000000000000000000000000000000000000000000000000000a070041420000000030c30000c3002082000000000000000000000000000000001041000041001041000000000000000041001041000000001041000041001041000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028106000104012082000000000000000451030202000000011111000082002082000000000000000000000000000000000000000000000000000000000000000c30004c0200000000ec300001b000208200000000000000000000000000000000a106000104030082000000000000000c30004c0200000000c106000c30030c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000820810820410820810410410820810820410410410410410c3101104041185a010410410410410410410410410410410410410410410410410410410410410410410410410410410d31411c9041041041041041270c01041041c300410c10c3c30c011cd041c05c010410410f01411cb0410410410410410c3c01c0f041c05c010410410410410410410410410410410c30c14920412514810410410d31411e80410410410410410410410410410410410410410410410410410410410410410c30c14920412704810410410d31411c90410410410410410410410410410410410410410410410410410410410410410c3441c0f041c05c010410410410410410410410410410410d11411cb041041041041041c05c010410411cd041c01c30⟩
def prod4 : ProdCert := ⟨[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], 9, 5, 3, 0x80201ff7f, 0xa, 6, 0xd5754d4748c1704b56d4b46c8aaa006a98f6357d56d57554aa16c5715400, 0x18, 0x5d60005400000000000140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004d20000000000000000000000000000000000000000000000000000000000000000000004500003c000000000000e00000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000000000000000002802400000000000000000000002000000000000000000000000000000000000000000000000001c00001801400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000080040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, 0x3aae5794e4b8ae2355aaa9295654946499224488a15852118160480a01801554390d41d063fcfe3f4f73d4ee374db35cd52a8760ec370d40f0340300400, 0x31, 0x30000000000000000000000000000000bee02d00000000002c02b000000000000000000000000000000000000000000000000000000000000000000000000000a800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000290000000000000000000000000000000000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009e600094000000000092300002200000000000000000000000000000000000000000000000002100000000000000000081f00078000000000000000075c01b6990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000175800000005540000000004d24400000004003c000000000e0000000000000000000000003403000002c02800000000000000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c00001801400000000000000000000000000000000000000000000000000000001000c0000000000000080040, 0xc4800000200400000080001890020000002000000000c00000600000040000000008008000004000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000100200000040000040010000001000000000600000300000020000000004004000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000801000000200000180080000008000000003000002c000001000000000200200000100000000000000000000000000000000000000000000000000000000000000000000000000000000000040000004012000001000000800900000040000000018000010000000800000000100100000120000000000000000000000000000000000000000000000000000000000000000000000000000000000010000002006000003c000002003000000200000000200000080000004000000000801c000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000100300000180000010018000001000000001a0000068000002000000000400e0000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000001800a000000800000c00100000040020000040000002000000800400c0040008008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000c00500000040000060008000002001000003400000100000040020060020004004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000b002800000200000580040000010008000014000000800000200100580100020020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004003c0000000000020000000000000000000f00000000000000000020022000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000340040000a0000001a16100000340160000010000006000006801c01e002004802c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020010000000000001000000000000000000040000000000000000001000800024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000380020010018030006010000000400200300080000020010070004000001000000402000300500000000000000000000000000000000000000000000000000000000000000000000000000000000000180010008018006005006000000200100580040000010008030002000000800000200c0028008000000000000000000000000000000000000000000000000000000000000000000000000000000000007000800400c003002801c0000010008038002000000800400e0010000004000001003801400400000000000000000000000000000000000000000000000000000000000000000000000000000000000380080200010038020004000001003800200e000000800600700700000040000010008010001000000000000000000000000000000000000000000000000000000000000000000000000000000000002800400300080280060020000008012001002000000400500500100000020000008004003000800000000000000000000000000000000000000000000000000000000000000000000000000000000000a002001800400a003001000000400c0008010000002003801400800000100000040020018004000000000000000000000000000000000000000000000000000000000000000000000000000000000005001000c00200500180080000020038004008000001022400a0040000008000002001000c0020000000000000000000000000000000000000000000000000000000000000000000000000000000400000018000000005000001000e002000000000c0070184000000006003800400e0020020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020, 0x1440000000000000002840000000000000002840000000000000000040000000000000000000⟩
theorem blockA4_ok : checkEv prod4.wa 2 blockA4 = true := by decide +kernel
theorem blockB4_ok : checkEv (18 - prod4.wa) 2 blockB4 = true := by decide +kernel
theorem prod4_ok : checkProd 18 2 blockA4 blockB4 prod4 = true := by decide +kernel
theorem good_000000010000000001 : GoodAny 18 2 (fun j => prod4.labels.getD j 0) := goodAny_of_checkProd (by decide) blockA4_ok blockB4_ok prod4_ok

def blockA5 : EvCert := ⟨[0, 0, 0, 0, 0, 0, 0, 1, 0, 0], 5, 0x2037f, 0x820020820000000020820000820020820000000000000000000000000000000271050000c30030820000000000000000410010410000000010410000410010410000000000000000000000000000000000000000000000000000000000000000410010410000000010410000410010410000000000000000000000000000000030c300024d005082000000000000000082002082000000002082000082002082000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a28004a020000000041e80000c30020820000000000000000000000000000000010410000410010410000000000000000c30030c2000000002082000a2800b144000000000000000000000000000000000000000000000000000000000000000a28004a020000000041c90000c30020820000000000000000000000000000000281050000c300308200000000000000004100104100000000104100004100104100000000000000000000000000000000000000000000000000000000000000004100104100000000104100004100104100000000000000000000000000000000a1050000c30030820000000000000000c30030c200000000c10f0001450111f30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000820810820410820810410410c41011a8041041041041041041041041041041041041041a05a010410412850411010c318ca010c30411041010410410820810820410410410410410c3101a05041a05a010410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000820810820410820810410410c41011a70410410410410410410410410410410410410410c30c10410410c30410c10c30410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000820810820410820810410410c41011a8041041041041041041041041041041041041041a05a010410412850411010c318ca010c30411041010410410820810820410410410410410c3101a05041a05a010410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410820810820410820810410410c41011890410410410410410c31012850412452410410410410410410410410410410410820810820410820810410410410410410410410410410410c638118b04104104104104110410104104140d0411814b3⟩
def blockB5 : EvCert := ⟨[0, 0, 0, 0, 0, 0, 0, 0, 0, 1], 5, 0x801ff, 0xa4800418200000000410400050a00208200000000000000000000000000000000d106000cb2008082000000000000000472004c820000000020820000820020820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000281060001040050820000000000000000c30030c20000000030c3000082002082000000000000000000000000000000000000000000000000000000000000000041001041000000001041000041001041000000000000000000000000000000001041000041001041000000000000000041001041000000001041000041001041000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a4800418200000000410400050a00208200000000000000000000000000000000d106000cb20080820000000000000004530044c20000000020820000820020820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000291060001040130820000000000000003c8032c820000000061320000820020820000000000000000000000000000000000000000000000000000000000000002c8004182000000004104000c8a00208200000000000000000000000000000000b10600010401408200000000000000034800418200000000f132000cb2032cb20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000820810820410820810410410820810820410410410410410820810820410820810410410410410410410410410410410c30c11040411041010410410c61411e80410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410c35411450411c52810410410410410410410410410410410c9c811ce041041041041041c85c810410410c30410c10c3cb2c81c900411c53810410410d51411cc0410410410410410c3c811450411c53010410410410410410410410410410410c30c1c87041cb24010410410d41411e90410410410410410410410410410410410410410410410410410410410410410c30c10c30415055010410410c94c11ce0410410410410410c35411450411c5a410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410c30c10c30415055010410410c9c811ce0410410410410410c35411450411c52810410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410410c30c14c70414d34010410410d41411ca0410410410410410410410410410410410410410410410410410410410410410c34c11450411c53010410410410410410410410410410410d51411cc0410410410410411c5381041041c90041c81cb2⟩
def prod5 : ProdCert := ⟨[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], 0xa, 5, 3, 0x800807ff7f, 0xb, 6, 0xd55556aa551a91416824d59a934655400754e3dc6b7d6b6d5daaaaa35463cc697d2b655caa800, 0x1c, 0x1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000069900060000000000001700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000059500000000000000000000000000000000000000000000000000000000000000000000051300048000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000003803400000000000000000000003000000000000000000000000000000000000000000000000002c00002802400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000001801400000000000000000000001000000000000000000000000000000000000000000000000000c0000080040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, 0x1d5792f24e29c4755555a4b4925549292322222c0880b01201401800aa90ea0f41a7fcff1fd3f6774dd9b736c6a8aa8ed00e00c00800, 0x27, 0x9800000000000000000000000000000000000000000000000000000000000000000000009640000000000000000000000230008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000007de00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d00000000000000000000000000000000001c6c000000000001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000180005d60155130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400000000000000000004003c000000000000000000038d3002c00000000000000000000000000000000000000000002800000000000000000000000000000000000000000000000002400002070000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000080040, 0x800100006000000000020684004000000800000c00000080000000020000000000000000000000000000000000000000000000000000000000000014a00180100120010000528006004000001c0020000028000002000001000c00a000000000000000000000000000000000000000000000000000000000000000120030020dac002000004800c0080000038004000005000000400000200180140000000000000000000000000000000000000000000000000000000000000001c0060040040004000007001801000056b000800000a000000800000400300280000000000000000000000000000000000000000000000000000000000000002800c008005000800000a003002000000c001000003c000001000000800676b00000000000000000000000000000000000000000000000000000000000000003006800c00e001000000c01a003000000c002000002000000200000125ac00800000000000000000000000000000000000000000000000000000000000000006009001801c00200000180240060000018004000004000000400000200480100000000000000000000000000000000000000000000000000000000000000000400400100080080000010010004000005001000000c0000b580000020020008000000000000000000000000000000000000000000000000000000000000000080080020010010000002002000800000a002000001800000a000000400400100000000000000000000000000000000000000000000000000000000000000001001000400200200000040040010000014004000003000000e000000800800200000000000000000000000000000000000000000000000000000000000000002002000800400400000080080020000020008000003000000c00000100100100000000000000000000000000000000000000000000000000000000000000000000000100080000000000000004000001000000000000000000000020000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800800000200280080020010000004000005000800000400100080080060000000000000000000000000000000000000000000000000000000000000000000100100000040020010004002000000800000c0010000008002001001000c000000000000000000000000000000000000000000000000000000000000000000020020000008004002000800400000100000180020000010004002002001800000000000000000000000000000000000000000000000000000000000000000004008000004001400600100080000020000020004000004000800400686b000000000000000000000000000000000000000000000000000000000000000000008014000006335800c0020010000004000007000800000a001000800c008000000000000000000000000000000000000000000000000000000000000000000010028000012006001800400200000080008d6001000001400200100180100000000000000000000000000000000000000000000000000000000000000000000200500009ac00c00300080040000010000020002000002800400200300200000000000000000000000000000000000000000000000000000000000000000020000a000001000c00200200380000040000018284000005003800800200100000000000000000000000000000000000000000000000000000000000000000000000c006000001800000800000200000060000000008006000002000000600000000000000000000000000000000000000000000000000000000000000000000001800c0000030000020000007000000c000000001000c0000080000000000000000000000000000000000000000000000000000000000000000000000000000030018000006000006000000e000001800000000200180000d600000000000000000000000000000000000000000000000000000000000000000000000000001c00200000300000020000014000002000000000800e000000800000000000000000000000000000000000000000000000000000000000000000000000000001000400000200000040000080000004000000001800800000100000000000000000000000000000000000000000000000000000000000000000000000000000200080000040000008000006000000800000000400100000020000000000000000000000000000000000000000000000000000000000000000000000000000040010000008000001000000c000001000000004a00200000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020, 0x2840000000000000002840000000000014dc5540000000000000001440000000000000000040000000000000000000⟩
theorem blockA5_ok : checkEv prod5.wa 2 blockA5 = true := by decide +kernel
theorem blockB5_ok : checkEv (20 - prod5.wa) 2 blockB5 = true := by decide +kernel
theorem prod5_ok : checkProd 20 2 blockA5 blockB5 prod5 = true := by decide +kernel
theorem good_00000001000000000001 : GoodAny 20 2 (fun j => prod5.labels.getD j 0) := goodAny_of_checkProd (by decide) blockA5_ok blockB5_ok prod5_ok

private def two3 : List (List Nat) := [[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1]]
private theorem cover3 : ruledOut 2 (pairs 2) two3 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls3 : ClassifiesAny 3 2 two3 :=
  classify_stepAny (w := 2) (by decide) (by decide) (pairs_classifyAny 2) (by simp) cover3

private def two4 : List (List Nat) := [[0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0], [0, 1, 0, 0], [0, 1, 0, 1], [0, 1, 1, 1]]
private theorem cover4 : ruledOut 2 (two3) two4 = [[0, 0, 1, 1], [0, 1, 1, 0]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls4 : ClassifiesAny 4 2 two4 :=
  classify_stepAny (w := 3) (by decide) (by decide) cls3 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl | rfl <;> first | exact good_0011 | exact good_0110) cover4

private def two5 : List (List Nat) := [[0, 0, 0, 0, 0], [0, 0, 0, 0, 1], [0, 0, 0, 1, 0], [0, 0, 1, 0, 0], [0, 0, 1, 0, 1], [0, 1, 0, 0, 0], [0, 1, 1, 1, 0], [0, 1, 1, 1, 1]]
private theorem cover5 : ruledOut 2 (two4) two5 = [[0, 1, 0, 1, 0], [0, 1, 0, 1, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls5 : ClassifiesAny 5 2 two5 :=
  classify_stepAny (w := 4) (by decide) (by decide) cls4 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl | rfl <;> first | exact good_01010 | exact good_01011) cover5

private def two6 : List (List Nat) := [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0], [0, 0, 0, 1, 0, 0], [0, 0, 0, 1, 0, 1], [0, 0, 1, 0, 0, 0], [0, 1, 0, 0, 0, 0], [0, 1, 0, 0, 0, 1], [0, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1]]
private theorem cover6 : ruledOut 2 (two5) two6 = [[0, 1, 1, 1, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls6 : ClassifiesAny 6 2 two6 :=
  classify_stepAny (w := 5) (by decide) (by decide) cls5 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_011101) cover6

private def two7 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 1, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1]]
private theorem cover7 : ruledOut 2 (two6) two7 = [[0, 1, 1, 1, 1, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls7 : ClassifiesAny 7 2 two7 :=
  classify_stepAny (w := 6) (by decide) (by decide) cls6 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_0111101) cover7

private def two8 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover8 : ruledOut 2 (two7) two8 = [[0, 1, 1, 1, 1, 1, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls8 : ClassifiesAny 8 2 two8 :=
  classify_stepAny (w := 7) (by decide) (by decide) cls7 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_01111101) cover8

private def two9 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover9 : ruledOut 2 (two8) two9 = [[0, 1, 1, 1, 1, 1, 1, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls9 : ClassifiesAny 9 2 two9 :=
  classify_stepAny (w := 8) (by decide) (by decide) cls8 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_011111101) cover9

private def two10 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover10 : ruledOut 2 (two9) two10 = [[0, 0, 0, 0, 0, 0, 0, 0, 1, 0]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls10 : ClassifiesAny 10 2 two10 :=
  classify_stepAny (w := 9) (by decide) (by decide) cls9 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_0000000010) cover10

private def two11 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover11 : ruledOut 2 (two10) two11 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls11 : ClassifiesAny 11 2 two11 :=
  classify_stepAny (w := 10) (by decide) (by decide) cls10 (by simp) cover11

private def two12 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover12 : ruledOut 2 (two11) two12 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls12 : ClassifiesAny 12 2 two12 :=
  classify_stepAny (w := 11) (by decide) (by decide) cls11 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_000000000000) cover12

private def two13 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]]
private theorem cover13 : ruledOut 2 (two12) two13 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls13 : ClassifiesAny 13 2 two13 :=
  classify_stepAny (w := 12) (by decide) (by decide) cls12 (by simp) cover13

private def two14 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1]]
private theorem cover14 : ruledOut 2 (two13) two14 = [[0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls14 : ClassifiesAny 14 2 two14 :=
  classify_stepAny (w := 13) (by decide) (by decide) cls13 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_00100000000001) cover14

private def two15 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1]]
private theorem cover15 : ruledOut 2 (two14) two15 = [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls15 : ClassifiesAny 15 2 two15 :=
  classify_stepAny (w := 14) (by decide) (by decide) cls14 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_000000010000001) cover15

private def two16 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover16 : ruledOut 2 (two15) two16 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls16 : ClassifiesAny 16 2 two16 :=
  classify_stepAny (w := 15) (by decide) (by decide) cls15 (by simp) cover16

private def two17 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover17 : ruledOut 2 (two16) two17 = [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls17 : ClassifiesAny 17 2 two17 :=
  classify_stepAny (w := 16) (by decide) (by decide) cls16 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_00000001000000010) cover17

private def two18 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover18 : ruledOut 2 (two17) two18 = [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls18 : ClassifiesAny 18 2 two18 :=
  classify_stepAny (w := 17) (by decide) (by decide) cls17 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_000000010000000001) cover18

private def two19 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover19 : ruledOut 2 (two18) two19 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls19 : ClassifiesAny 19 2 two19 :=
  classify_stepAny (w := 18) (by decide) (by decide) cls18 (by simp) cover19

private def two20 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover20 : ruledOut 2 (two19) two20 = [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls20 : ClassifiesAny 20 2 two20 :=
  classify_stepAny (w := 19) (by decide) (by decide) cls19 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_00000001000000000001) cover20

private def two21 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover21 : ruledOut 2 (two20) two21 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls21 : ClassifiesAny 21 2 two21 :=
  classify_stepAny (w := 20) (by decide) (by decide) cls20 (by simp) cover21

private def two22 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover22 : ruledOut 2 (two21) two22 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls22 : ClassifiesAny 22 2 two22 :=
  classify_stepAny (w := 21) (by decide) (by decide) cls21 (by simp) cover22

private def two23 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover23 : ruledOut 2 (two22) two23 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls23 : ClassifiesAny 23 2 two23 :=
  classify_stepAny (w := 22) (by decide) (by decide) cls22 (by simp) cover23

private def two24 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover24 : ruledOut 2 (two23) two24 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls24 : ClassifiesAny 24 2 two24 :=
  classify_stepAny (w := 23) (by decide) (by decide) cls23 (by simp) cover24

private def two25 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover25 : ruledOut 2 (two24) two25 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls25 : ClassifiesAny 25 2 two25 :=
  classify_stepAny (w := 24) (by decide) (by decide) cls24 (by simp) cover25

private def two26 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover26 : ruledOut 2 (two25) two26 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls26 : ClassifiesAny 26 2 two26 :=
  classify_stepAny (w := 25) (by decide) (by decide) cls25 (by simp) cover26

private def two27 : List (List Nat) := []
private theorem cover27 : ruledOut 2 (two26) two27 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls27 : ClassifiesAny 27 2 two27 :=
  classify_stepAny (w := 26) (by decide) (by decide) cls26 (by simp) cover27

/-- Every phase assignment of a 27-cell strip, falls on one parity per cell, forces a repeating adjacent pair. -/
theorem goodAny27 (a : Nat → Nat) (ha : ∀ j, j < 27 → a j < 2) : GoodAny 27 2 a :=
  of_emptyAny (by decide) cls27 ha

end Rule30Submission.FallParities

/-! ## Rule30FallParities -/

/-!
# Rule 30: falls on both parities in every 27 adjacent singleton columns

A column *falls* at tick `t` when it is black at `t` and white at `t + 1` (`Rule30FallResidues.Fall`).

* `two_parities_every_27`: for every integer `i`, one of the 27 columns `i, …, i + 26` of Rule 30 from a single
  black cell has falls on even ticks and on odd ticks, each after every cutoff (`Rule30FallResidues.Cofinal`).
* `two_cofinal_from_goodAny`: the step to the single seed, for any width and modulus. If every column of a strip
  kept its late falls to one residue, the strip would follow a path of the strip graph, and `GoodAny` would make two
  of its columns eventually periodic, which Jen's theorem forbids.

With `Rule30FallResidues.two_cofinal_every_modulus` (six columns for every modulus from three), every modulus from
two has two cofinal falling residues in every 27 adjacent columns. At modulus two the six-cell strip is not enough
(`Rule30FallResidues.not_good_parity`).
-/


namespace Rule30Submission.FallParities

open Ruliology.CellularAutomata Rule30StripCertificates Rule30Submission.KitFallResidues Rule30Jen

/-! ### Physical rows of any width -/

def rowW (W T : Nat) (j : Int) : Nat := encRow T (j-1) W

theorem rowW_lt (W T : Nat) (j : Int) : rowW W T j < 2^W :=
  (enc_encRow W T (j-1)).1

theorem rowW_bit (W T : Nat) (j : Int) (k : Nat) (hk : k < W) :
    (rowW W T j).testBit k = cell T (j+k) := by
  simpa [rowW] using (enc_encRow W T (j-1)).2 k hk

theorem rowW_step (W T : Nat) (j : Int) :
    rowW W (T+1) j = stripStep W (cell T (j-1)) (cell T (j+W)) (rowW W T j) := by
  have nxt := enc_step (enc_encRow W T (j-1))
  simp only [Int.sub_add_cancel] at nxt
  apply Nat.eq_of_testBit_eq
  intro k
  by_cases hk : k < W
  · rw [rowW_bit _ _ _ k hk]
    simpa [rowW] using (nxt.2 k hk).symm
  · have cut : 2^W ≤ 2^k := Nat.pow_le_pow_right (by decide) (by omega)
    rw [Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (rowW_lt _ _ _) cut)]
    exact (Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (stripStep_lt _ _ _ _) cut)).symm

/-! ### The singleton -/

private theorem escapeW {W m : Nat} (_hW : 0 < W) (hm : 0 < m) (i : Int) (a : Fin W → Fin m)
    (good : ∀ a, (∀ j, j < W → a j < m) → GoodAny W m a) (T : Nat) :
    ∃ (j : Fin W) (t : Nat), T ≤ t ∧ Fall (i+j.val) t ∧ t%m ≠ (a j).val := by
  apply Classical.byContradiction
  intro no
  let S := T*m
  have Slarge : T ≤ S := by
    simpa [S] using Nat.mul_le_mul_left T (show 1 ≤ m by omega)
  let phases (j : Nat) := if hj : j < W then (a ⟨j,hj⟩).val else 0
  let x (t : Nat) := rowW W (S+t) i
  have run : Run W m phases x := by
    refine ⟨fun t => rowW_lt _ _ _, fun t => ?_⟩
    have adv := rowW_step W (S+t) i
    refine ⟨mem_successors.mpr ⟨_, _, by simpa [x, Nat.add_assoc] using adv⟩, (fits_iff _ _ _).mpr ?_⟩
    intro j on off
    by_cases hj : j < W
    · rw [permit_bit, decide_eq_true_eq]
      refine ⟨hj, ?_⟩
      have b : Fall (i+j) (S+t) := by
        unfold x at on off
        rw [rowW_bit _ _ _ _ hj] at on off
        exact ⟨on, by simpa only [Nat.add_assoc] using off⟩
      have eq : (S+t)%m = (a ⟨j,hj⟩).val := by
        apply Classical.byContradiction
        intro neq
        exact no ⟨⟨j,hj⟩, S+t, by omega, b, neq⟩
      simpa only [S, phases, dite_eq_left hj, Nat.add_comm _ t, Nat.add_mul_mod_self_right] using eq.symm
    · have hn : (x t).testBit j = false :=
        Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (rowW_lt _ _ _)
          (Nat.pow_le_pow_right (by decide : 0<2) (by omega : W ≤ j)))
      simp [hn] at on
  have phasesBound (j : Nat) (hj : j < W) : phases j < m := by
    simpa only [phases, dite_eq_left hj] using (a ⟨j,hj⟩).isLt
  obtain ⟨j, L, N, hL, hj, per⟩ := good phases phasesBound x run
  apply not_adjacent (i+j)
  · refine ⟨S+N, L, hL, fun t ht => ?_⟩
    have left := (pair_bits (per (t-S) (by omega))).1
    unfold x at left
    rw [rowW_bit _ _ _ _ (by omega), rowW_bit _ _ _ _ (by omega),
      show S+(t-S+L)=t+L by omega, show S+(t-S)=t by omega] at left
    exact left
  · refine ⟨S+N, L, hL, fun t ht => ?_⟩
    have right := (pair_bits (per (t-S) (by omega))).2
    unfold x at right
    rw [rowW_bit _ _ _ _ hj, rowW_bit _ _ _ _ hj,
      show S+(t-S+L)=t+L by omega, show S+(t-S)=t by omega] at right
    simpa only [Int.natCast_add, Int.natCast_one, ← Int.add_assoc] using right

private theorem common_boundW {k : Nat} (f : Fin k → Nat) : ∃ B, ∀ i, f i ≤ B := by
  induction k with
  | zero => exact ⟨0, fun i => Fin.elim0 i⟩
  | succ k ih =>
    obtain ⟨B, upper⟩ := ih (fun i => f i.succ)
    exact ⟨max (f 0) B, fun i => Fin.cases (Nat.le_max_left _ _)
      (fun j => Nat.le_trans (upper j) (Nat.le_max_right _ _)) i⟩

/-- `GoodAny` at every assignment of a width-`W` strip gives, in every `W` adjacent singleton columns, a column
with cofinal falls at two distinct residues modulo `m`. -/
theorem two_cofinal_from_goodAny {W m : Nat} (hW : 0 < W) (hm : 0 < m) (i : Int)
    (good : ∀ a, (∀ j, j < W → a j < m) → GoodAny W m a) :
    ∃ (j : Fin W) (r q : Fin m), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q := by
  classical
  apply Classical.byContradiction
  intro no
  have single (j : Fin W) : ∃ r : Fin m, ∀ q, q ≠ r → ¬ Cofinal (i+j.val) q := by
    by_cases h : ∃ r : Fin m, Cofinal (i+j.val) r
    · obtain ⟨r, hr⟩ := h
      exact ⟨r, fun q neq hq => no ⟨j, r, q, Ne.symm neq, hr, hq⟩⟩
    · exact ⟨⟨0, hm⟩, fun q _ hq => h ⟨q, hq⟩⟩
  let phase (j : Fin W) := Classical.choose (single j)
  have cutoff (j : Fin W) (q : Fin m) :
      ∃ B, ∀ t, B ≤ t → t%m = q.val → Fall (i+j.val) t → q = phase j := by
    by_cases eq : q = phase j
    · exact ⟨0, fun _ _ _ _ => eq⟩
    · have rare := Classical.choose_spec (single j) q eq
      apply Classical.byContradiction
      intro noBound
      apply rare
      intro T
      apply Classical.byContradiction
      intro absent
      exact noBound ⟨T, fun t ht htq hit => (absent ⟨t, ht, htq, hit⟩).elim⟩
  let B (j : Fin W) (q : Fin m) := Classical.choose (cutoff j q)
  let C (j : Fin W) := Classical.choose (common_boundW (B j))
  obtain ⟨M, hm'⟩ := common_boundW C
  obtain ⟨j, t, late, hit, off⟩ := escapeW hW hm i phase good M
  let q : Fin m := ⟨t%m, Nat.mod_lt t hm⟩
  have hq : B j q ≤ C j := Classical.choose_spec (common_boundW (B j)) q
  have eq := Classical.choose_spec (cutoff j q) t (Nat.le_trans hq (Nat.le_trans (hm' j) late)) rfl hit
  exact off (congrArg Fin.val eq)

/-- **Modulus two.** Every 27 adjacent singleton Rule 30 columns contain a column whose black-to-white falls
start on even ticks and on odd ticks, each after every cutoff. -/
theorem two_parities_every_27 (i : Int) :
    ∃ (j : Fin 27) (r q : Fin 2), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q :=
  two_cofinal_from_goodAny (by decide) (by decide) i goodAny27

end Rule30Submission.FallParities
