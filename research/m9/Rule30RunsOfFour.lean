module

public import Ruliology.CellularAutomata.Rule30GateTrap

/-!
# At most three runs of four in the trapped gate, from one finite CNF

`Rule30GateTrap`: a right half `R` driven by the alternating column has the window `win R t` (columns `1..16`) at
time `t`; once it is in the kit's `trap` at an odd time it stays there, and its gate
`Rule30PeriodTwoSideways.u R s` (column `1` at time `2 s + 1`) has gaps `3` and `5` only.

This module proves, from one hypothesis `Unsat cnf` about an explicit finite CNF defined here:

* `no_four_runs_of_four`: from two samples after the window is in the trap, the gate never reads, from a black
  sample, the gaps `3, (5, 5, 5, 5, 3) × 4`: four closed runs of exactly four `5`s.
* `no_five_runs_of_four`: from the first sample in the trap on, it never reads `(5, 5, 5, 5, 3) × 5`: a run of at
  least four `5`s followed by four closed runs of exactly four. Its five-run word contains the four-run word
  twenty samples after its first sample.

`cnf` is the light-cone instance of ledger M80 with a closed-form numbering: one variable per cell `(τ, j)` of the
triangle `τ ≤ 194`, `1 ≤ j ≤ 195 - τ` (local time `τ` from an odd time, column `j`), and one selector per trap
code. Its clauses say: rule 30 on the triangle, with column `0` black exactly at odd `τ`; the window at `τ = 0` is
one of the trap codes; and column `1` spells the word at the samples `τ = 2 (2 + i)`. The hypothesis is not proved
here. The DIMACS text printed from `cnf` itself (`claudeM5_m9_print_cnf.py`; 19,939 variables, 163,905 clauses,
SHA-256 `11c3578f029c93ce9d0c0de508399c6b7106fe9c5178ebdfff6a527ebe7c6368`) is certified unsatisfiable outside
Lean: CaDiCaL's LRAT proof, checked by `cake_lpr` and by `lrat-check` (ledger M85). The kit forbids `bv_decide`,
which would check it inside Lean, and the proof (45 MB) is too large for kernel reduction (ledger M84). With
`P = 1` the same CNF is satisfiable, and its model is a right half that reads the word one sample after entry.
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30RunsOfFour

open Rule30GateTrap Rule30Ether Rule30PeriodTwoCoupled Rule30StripCertificates

/-! ## The word and the triangle -/

/-- The gaps of the four-run word, read from a black sample. -/
def gaps4 : List Nat := 3 :: (List.replicate 4 [5, 5, 5, 5, 3]).flatten

/-- The gaps of the five-run word, read from a black sample. -/
def gaps5 : List Nat := (List.replicate 5 [5, 5, 5, 5, 3]).flatten

/-- Column `1` at the samples of a gap word: black at its first sample and at the end of each gap. -/
def headsOf (g : List Nat) : List Bool := true :: g.flatMap fun k => List.replicate (k - 1) false ++ [true]

def heads : List Bool := headsOf gaps4
def heads5 : List Bool := headsOf gaps5

theorem heads_length : heads.length = 96 := by decide
theorem heads5_length : heads5.length = 116 := by decide

/-- The five-run word contains the four-run word from its sample `20`. -/
theorem heads5_shift : ∀ i, i < 96 → heads5.getD (20 + i) false = heads.getD i false := by decide

/-- Samples of history inside the trap before the word starts. -/
def P : Nat := 2
/-- The last local time, and the width of the triangle at `τ = 0`. -/
def T : Nat := 2 * (P + 95)
def M : Nat := T + 1

theorem T_val : T = 194 := rfl
theorem M_val : M = 195 := rfl

/-- The first variable of row `τ`, less one: row `τ` holds `M - τ` cells. -/
def base : Nat → Nat
  | 0 => 0
  | τ + 1 => base τ + (M - τ)

def cellId (τ j : Nat) : Nat := base τ + j
def nCells : Nat := base (T + 1)
def selId (i : Nat) : Nat := nCells + 1 + i

/-- A literal: the variable `v`, true if `b`. -/
def lit (v : Nat) (b : Bool) : Int := if b then (v : Int) else -(v : Int)

/-- The rule at the cell `(τ + 1, j)`: each clause excludes one assignment of the three cells below it with the
wrong value above. Column `0` is black exactly at odd `τ`. -/
def ruleClauses (τ j : Nat) : List (List Int) :=
  if j = 1 then
    [false, true].flatMap fun bb => [false, true].map fun cc =>
      [lit (cellId τ j) (!bb), lit (cellId τ (j + 1)) (!cc),
        lit (cellId (τ + 1) j) (xor (τ % 2 == 1) (bb || cc))]
  else
    [false, true].flatMap fun aa => [false, true].flatMap fun bb => [false, true].map fun cc =>
      [lit (cellId τ (j - 1)) (!aa), lit (cellId τ j) (!bb), lit (cellId τ (j + 1)) (!cc),
        lit (cellId (τ + 1) j) (xor aa (bb || cc))]

def allRule : List (List Int) :=
  (List.range T).flatMap fun τ => (List.range (M - τ - 1)).flatMap fun k => ruleClauses τ (k + 1)

def unitClauses : List (List Int) :=
  (List.range 96).map fun s => [lit (cellId (2 * (P + s)) 1) (heads.getD s false)]

/-- The number of trap codes. -/
def nTrap : Nat := 829

theorem trapCodes_length : trapCodes.length = nTrap := by decide +kernel

def trapClauses : List (List Int) :=
  ((List.range nTrap).map fun i => (selId i : Int)) ::
    (List.range nTrap).flatMap fun i => (List.range 16).map fun j =>
      [-(selId i : Int), lit (cellId 0 (j + 1)) ((trapCodes.getD i 0).testBit j)]

/-- The instance. -/
def cnf : List (List Int) := allRule ++ unitClauses ++ trapClauses

def nVars : Nat := nCells + nTrap

/-! ## Satisfiability -/

def litTrue (σ : Nat → Bool) (l : Int) : Bool := if 0 < l then σ l.natAbs else !σ l.natAbs

def Satisfies (σ : Nat → Bool) (F : List (List Int)) : Prop := ∀ c ∈ F, ∃ l ∈ c, litTrue σ l = true

/-- The hypothesis: no assignment satisfies every clause. -/
def Unsat (F : List (List Int)) : Prop := ∀ σ : Nat → Bool, ¬ Satisfies σ F

theorem litTrue_lit (σ : Nat → Bool) (v : Nat) (hv : 1 ≤ v) (b : Bool) :
    litTrue σ (lit v b) = (σ v == b) := by
  unfold litTrue lit
  cases b <;> cases h : σ v <;> simp [h] <;> omega

/-! ## The numbering -/

def Valid (τ j : Nat) : Prop := τ ≤ T ∧ 1 ≤ j ∧ j ≤ M - τ

theorem base_succ (τ : Nat) : base (τ + 1) = base τ + (M - τ) := rfl

theorem base_mono : ∀ {a b : Nat}, a ≤ b → base a ≤ base b
  | a, b, h => by
    induction b with
    | zero => have : a = 0 := by omega
              subst this; exact Nat.le_refl _
    | succ n ih =>
      rcases Nat.lt_or_ge a (n + 1) with h' | h'
      · exact Nat.le_trans (ih (by omega)) (by rw [base_succ]; omega)
      · have : a = n + 1 := by omega
        subst this; exact Nat.le_refl _

theorem cellId_le (τ j : Nat) (h : Valid τ j) : cellId τ j ≤ nCells := by
  obtain ⟨h1, _, h3⟩ := h
  have := base_mono (show τ + 1 ≤ T + 1 by omega)
  unfold cellId nCells
  rw [base_succ] at this
  omega

theorem one_le_cellId (τ j : Nat) (h : Valid τ j) : 1 ≤ cellId τ j := by
  unfold cellId; have := h.2.1; omega

theorem cellId_inj {τ j τ' j' : Nat} (h : Valid τ j) (h' : Valid τ' j') (e : cellId τ j = cellId τ' j') :
    τ = τ' ∧ j = j' := by
  obtain ⟨_, h2, h3⟩ := h
  obtain ⟨_, h2', h3'⟩ := h'
  unfold cellId at e
  rcases Nat.lt_trichotomy τ τ' with lt | eq | gt
  · have := base_mono (show τ + 1 ≤ τ' by omega)
    rw [base_succ] at this
    omega
  · subst eq; exact ⟨rfl, by omega⟩
  · have := base_mono (show τ' + 1 ≤ τ by omega)
    rw [base_succ] at this
    omega

/-! ## The assignment read from a right half -/

/-- The cells of `X` on the triangle, and the selector `i0`. -/
noncomputable def sigma (X : Nat → Nat → Bool) (i0 : Nat) (v : Nat) : Bool := by
  classical
  exact decide ((∃ τ j, Valid τ j ∧ cellId τ j = v ∧ X τ j = true) ∨ v = selId i0)

theorem sigma_cell (X : Nat → Nat → Bool) (i0 : Nat) {τ j : Nat} (h : Valid τ j) :
    sigma X i0 (cellId τ j) = X τ j := by
  classical
  unfold sigma
  cases hx : X τ j with
  | true => simp only [decide_eq_true_eq]; exact Or.inl ⟨τ, j, h, rfl, hx⟩
  | false =>
    simp only [decide_eq_false_iff_not, not_or, not_exists, not_and]
    refine ⟨fun τ' j' h' e hx' => ?_, ?_⟩
    · obtain ⟨rfl, rfl⟩ := cellId_inj h' h e
      rw [hx] at hx'; exact absurd hx' (by decide)
    · have := cellId_le τ j h
      unfold selId; omega

theorem sigma_sel (X : Nat → Nat → Bool) (i0 k : Nat) : sigma X i0 (selId k) = (k == i0) := by
  classical
  unfold sigma
  by_cases hk : k = i0
  · subst hk; simp
  · have : ¬ ((∃ τ j, Valid τ j ∧ cellId τ j = selId k ∧ X τ j = true) ∨ selId k = selId i0) := by
      rintro (⟨τ, j, h, e, _⟩ | e)
      · have := cellId_le τ j h; unfold selId at e; omega
      · unfold selId at e; omega
    simp only [this, decide_false]
    exact (beq_eq_false_iff_ne.2 hk).symm

/-! ## Every clause holds -/

section Clauses

variable (X : Nat → Nat → Bool) (i0 : Nat)

/-- A clause excluding one assignment `(a, b, c, y)` holds for any values satisfying `y = rule a b c` at the
cells, where `a` may be the constant centre. -/
theorem rule_lit {la lb lc ly : Int} {va vb vc vy aa bb cc : Bool}
    (ha : litTrue (sigma X i0) la = (va == !aa)) (hb : litTrue (sigma X i0) lb = (vb == !bb))
    (hc : litTrue (sigma X i0) lc = (vc == !cc)) (hy : litTrue (sigma X i0) ly = (vy == xor aa (bb || cc)))
    (hr : vy = xor va (vb || vc)) : ∃ l ∈ [la, lb, lc, ly], litTrue (sigma X i0) l = true := by
  cases aa <;> cases bb <;> cases cc <;> cases va <;> cases vb <;> cases vc <;> subst hr <;>
    simp_all

theorem rule_lit1 {lb lc ly : Int} {vb vc vy a0 bb cc : Bool}
    (hb : litTrue (sigma X i0) lb = (vb == !bb)) (hc : litTrue (sigma X i0) lc = (vc == !cc))
    (hy : litTrue (sigma X i0) ly = (vy == xor a0 (bb || cc)))
    (hr : vy = xor a0 (vb || vc)) : ∃ l ∈ [lb, lc, ly], litTrue (sigma X i0) l = true := by
  cases a0 <;> cases bb <;> cases cc <;> cases vb <;> cases vc <;> subst hr <;> simp_all

theorem lit_cell {τ j : Nat} (h : Valid τ j) (b : Bool) :
    litTrue (sigma X i0) (lit (cellId τ j) b) = (X τ j == b) := by
  rw [litTrue_lit _ _ (one_le_cellId τ j h), sigma_cell X i0 h]

/-- The rule clauses hold when `X` is rule 30 on the triangle with the centre black at odd `τ`. -/
theorem allRule_sat (hR : ∀ τ j, τ < T → 1 ≤ j → j + 1 ≤ M - τ →
      X (τ + 1) j = xor (if j = 1 then (τ % 2 == 1) else X τ (j - 1)) (X τ j || X τ (j + 1))) :
    ∀ c ∈ allRule, ∃ l ∈ c, litTrue (sigma X i0) l = true := by
  intro c hc
  simp only [allRule, List.mem_flatMap, List.mem_range] at hc
  obtain ⟨τ, hτ, k, hk, hc⟩ := hc
  have vb : Valid τ (k + 1) := ⟨by omega, by omega, by omega⟩
  have vc : Valid τ (k + 1 + 1) := ⟨by omega, by omega, by omega⟩
  have vy : Valid (τ + 1) (k + 1) := ⟨by omega, by omega, by omega⟩
  have hr := hR τ (k + 1) hτ (by omega) (by omega)
  unfold ruleClauses at hc
  split at hc
  · rename_i h1
    simp only [List.mem_flatMap, List.mem_map, List.mem_cons, List.not_mem_nil, or_false] at hc
    obtain ⟨bb, -, cc, -, rfl⟩ := hc
    have hk0 : k = 0 := by omega
    subst hk0
    simp only [Nat.zero_add, ↓reduceIte] at hr
    exact rule_lit1 X i0 (lit_cell X i0 vb _) (lit_cell X i0 vc _) (lit_cell X i0 vy _) hr
  · rename_i h1
    have va : Valid τ (k + 1 - 1) := ⟨by omega, by omega, by omega⟩
    simp only [List.mem_flatMap, List.mem_map, List.mem_cons, List.not_mem_nil, or_false] at hc
    obtain ⟨aa, -, bb, -, cc, -, rfl⟩ := hc
    simp only [h1, ↓reduceIte] at hr
    exact rule_lit X i0 (lit_cell X i0 va _) (lit_cell X i0 vb _) (lit_cell X i0 vc _) (lit_cell X i0 vy _) hr

theorem unit_sat (hw : ∀ s, s < 96 → X (2 * (P + s)) 1 = heads.getD s false) :
    ∀ c ∈ unitClauses, ∃ l ∈ c, litTrue (sigma X i0) l = true := by
  intro c hc
  simp only [unitClauses, List.mem_map, List.mem_range] at hc
  obtain ⟨s, hs, rfl⟩ := hc
  have v : Valid (2 * (P + s)) 1 := ⟨by simp only [T]; omega, by omega, by simp only [M, T]; omega⟩
  refine ⟨_, List.mem_singleton_self _, ?_⟩
  rw [lit_cell X i0 v, hw s hs]; simp

theorem trap_sat (hi : i0 < nTrap)
    (hwin : ∀ j, j < 16 → X 0 (j + 1) = (trapCodes.getD i0 0).testBit j) :
    ∀ c ∈ trapClauses, ∃ l ∈ c, litTrue (sigma X i0) l = true := by
  intro c hc
  simp only [trapClauses, List.mem_cons, List.mem_flatMap, List.mem_map, List.mem_range] at hc
  rcases hc with hc | ⟨i, hi', j, hj, hc⟩
  · rw [hc]
    refine ⟨(selId i0 : Int), List.mem_map.2 ⟨i0, List.mem_range.2 hi, rfl⟩, ?_⟩
    have hpos : (0 : Int) < (selId i0 : Int) := by unfold selId; omega
    unfold litTrue
    simp only [hpos, ↓reduceIte, Int.natAbs_natCast, sigma_sel, beq_self_eq_true]
  · rw [← hc]
    by_cases e : i = i0
    · subst e
      have v : Valid 0 (j + 1) := ⟨by omega, by omega, by simp only [M, T]; omega⟩
      refine ⟨_, List.mem_cons_of_mem _ (List.mem_singleton_self _), ?_⟩
      rw [lit_cell X i v, hwin j hj]; simp
    · refine ⟨_, List.mem_cons_self, ?_⟩
      have hneg : ¬ ((0 : Int) < -(selId i : Int)) := by omega
      unfold litTrue
      simp only [hneg, ↓reduceIte, Int.natAbs_neg, Int.natAbs_natCast, sigma_sel, Bool.not_eq_true']
      exact beq_eq_false_iff_ne.2 e

end Clauses

/-! ## The laws -/

theorem seg_getD : ∀ (n : Nat) (f : Nat → Bool) (i : Nat), i < n → (seg f n).getD i false = f i
  | 0, _, _, h => absurd h (by omega)
  | n + 1, f, 0, _ => rfl
  | n + 1, f, i + 1, h => by
    show (seg (fun i => f (i + 1)) n).getD i false = f (i + 1)
    exact seg_getD n (fun i => f (i + 1)) i (by omega)

theorem window_bits {R : Nat → Bool} {t : Nat} {code : Nat} (e : decode code = win R t) :
    ∀ j, j < 16 → drv altCol R t (j + 1) = code.testBit j := by
  intro j hj
  have : (win R t).getD j false = (decode code).getD j false := by rw [e]
  unfold win rowOf decode at this
  rw [seg_getD _ _ _ hj, seg_getD _ _ _ hj] at this
  simpa using this

/-- **No four runs of four, from two samples after entry** (from `Unsat cnf`). -/
theorem no_four_runs_of_four (H : Unsat cnf) (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0 + 4 ≤ 2 * s + 1) :
    ¬ ∀ i, i < 96 → Rule30PeriodTwoSideways.u R (s + i) = heads.getD i false := by
  intro hword
  -- the window is in the trap at `b = 2 s + 1 - 4`
  have hb := win_mem_trap R h0 hw ((2 * s + 1 - 4 - t0) / 2)
  rw [show t0 + 2 * ((2 * s + 1 - 4 - t0) / 2) = 2 * s + 1 - 4 by omega] at hb
  obtain ⟨code, hcode, e⟩ := List.mem_map.1 hb
  obtain ⟨i0, hi0, rfl⟩ := List.getElem_of_mem hcode
  have hi0' : i0 < nTrap := trapCodes_length ▸ hi0
  let X : Nat → Nat → Bool := fun τ j => drv altCol R (2 * s + 1 - 4 + τ) j
  refine H (sigma X i0) ?_
  intro c hc
  simp only [cnf, List.mem_append] at hc
  rcases hc with (hc | hc) | hc
  · refine allRule_sat X i0 (fun τ j _ hj _ => ?_) c hc
    obtain ⟨p, rfl⟩ : ∃ p, j = p + 1 := ⟨j - 1, by omega⟩
    have key := drv_isR30 altCol R (2 * s + 1 - 4 + τ) p
    show drv altCol R (2 * s + 1 - 4 + τ + 1) (p + 1) = _
    refine key.trans ?_
    split
    · rename_i h1
      have hp0 : p = 0 := by omega
      subst hp0
      unfold Rule30Jen.rule
      congr 1
      rw [drv_col0]
      unfold altCol
      rw [Bool.eq_iff_iff]
      simp only [beq_iff_eq]
      omega
    · rename_i h1
      obtain ⟨q, rfl⟩ : ∃ q, p = q + 1 := ⟨p - 1, by omega⟩
      rfl
  · refine unit_sat X i0 (fun s' hs' => ?_) c hc
    have h1 := hword s' hs'
    unfold Rule30PeriodTwoSideways.u at h1
    have e2 : 2 * s + 1 - 4 + 2 * (P + s') = 2 * (s + s') + 1 := by unfold P; omega
    exact (congrArg (fun t => drv altCol R t 1) e2).trans h1
  · refine trap_sat X i0 hi0' (fun j hj => ?_) c hc
    have g : trapCodes.getD i0 0 = trapCodes[i0]'hi0 := by
      rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hi0, Option.getD_some]
    show drv altCol R (2 * s + 1 - 4 + 0) (j + 1) = _
    exact (congrArg (fun t => drv altCol R t (j + 1)) (Nat.add_zero _)).trans
      ((window_bits e j hj).trans (congrArg (fun n => Nat.testBit n j) g.symm))

/-- **No run of at least four followed by four closed runs of four, ever in the trap** (from `Unsat cnf`). -/
theorem no_five_runs_of_four (H : Unsat cnf) (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0 ≤ 2 * s + 1) :
    ¬ ∀ i, i < 116 → Rule30PeriodTwoSideways.u R (s + i) = heads5.getD i false := by
  intro h5
  refine no_four_runs_of_four H R h0 hw (s + 20) (by omega) (fun i hi => ?_)
  rw [show s + 20 + i = s + (20 + i) by omega, h5 (20 + i) (by omega), heads5_shift i hi]

end Ruliology.CellularAutomata.Rule30RunsOfFour
