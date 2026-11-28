module

public import Ruliology.CellularAutomata.Rule30Certificates.FallResidueStrip

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

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30FallParities

open Ruliology.CellularAutomata Rule30StripCertificates Rule30FallResidues

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

end Ruliology.CellularAutomata.Rule30FallParities
