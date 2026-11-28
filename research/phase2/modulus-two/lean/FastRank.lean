import ModulusLayers

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
