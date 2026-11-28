import FastRank

/-! Certificates for an adjacent pair that repeats with some lag, not necessarily the calendar's.

Jen's theorem forbids two eventually periodic singleton columns with any periods, so the strip method needs only
`GoodAny`: every run has an adjacent pair that eventually repeats with some lag `L`. A record attaches to a node a
rank, a class (0 for none) and a position. Along every step the rank does not increase; along a step of equal rank
both records have the same nonzero class and the position advances by one modulo the class's period; and at a node
with a nonzero class the pair named by the class reads the class's word at the node's position. Along a run the rank
is eventually constant, and the pair then repeats with the class's period.

Three checkers supply the records: a full table over every node (`checkLag`); a table that only marks where runs
eventually stay (`checkEv`); and a table over the product of two such sets for a strip cut in two (`checkProd`). -/
namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata Rule30StripCertificates

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

end PhaseFalls.Moduli
