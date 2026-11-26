module

public import Ruliology.CellularAutomata.Rule30RotationBlocks
public import Ruliology.CellularAutomata.Rule30FiniteMaskedJen

/-!
# Blocks in the order of a rotation at every phase, beside a Rule 30 clock

Turn a circle by a fixed irrational angle and note at each step whether the point is in a fixed arc, now from any
starting phase. Let each of the two answers stand for a block of readings, and set the blocks one after another in
the order of the answers. `Rule30RotationBlocks` excludes such a concatenation beside an alternating column when the
start lies on the orbit of an end of the arc. This module treats every phase, for angles with arbitrarily large
Farey neighbours whose denominators are more than six apart in ratio.

**No real numbers.** As in `Rule30RotationBlocks`, `IrrationalLine g` stands for the floors of the multiples of the
angle, and `PhaseLine g f` for the floors `⌊θ + t α⌋` of a line of the same slope. The arc `[0, γ)` at phase `θ` is
read off two such lines `f₁ t = ⌊θ + t α⌋` and `f₂ t = ⌊θ + t α - γ⌋`, which differ by one exactly when the point is in
the arc (`arcWord`).

* `three_failures`: a letter that differs from the letter `d` later marks a failure of one of the two lines, and the
  failures of one line are at least `D` apart (`Farey.gap`). So three such letters span at least `D`.
* `repeat_of_span`: then one of three greedy trials finds the word repeating at lag `d` for long enough.
* `above_six_of_envelopes`: if the reading clock of the blocks has linear envelopes as close as the margin over six
  asks, the right neighbour of an alternating column in a row with a leftmost black cell does not read the
  concatenation, at any phase and for any arc. Jen's theorem through one finite window concludes
  (`excludes_blocks`, `visible_window`).
* `equal_envelopes`, `above_six_equal`: blocks of one length have exact envelopes, so they are excluded outright.
* `sixes_line`, `sixes_farey`, `sixes_equal`: the angle `√10 - 3 = [0; 6, 6, …]` has the required neighbours.

**Not here.** For blocks of different lengths the envelopes hold at every phase, but their proof needs the number of
letters of the arc in every window of `d` consecutive steps to vary by a bounded amount; that step is not yet in
core Lean.
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30RotationFreePhase

open Rule30RotationBlocks
open Rule30Realization (evol)

/-! ### The arc at any phase -/

/-- The letter of the arc: two lines of one slope, at most one apart, differ by one inside the arc. -/
def arcWord (f₁ f₂ : Nat → Int) (t : Nat) : Bool := decide (f₁ t - f₂ t = 1)

/-- A letter that differs from the letter `d` later marks a failure of one of the two lines to copy over `d`. -/
theorem fails_of_differs {f₁ f₂ : Nat → Int} (u : Int) {d t : Nat}
    (h : arcWord f₁ f₂ (t + d) ≠ arcWord f₁ f₂ t) :
    f₁ (t + d) ≠ f₁ t + u ∨ f₂ (t + d) ≠ f₂ t + u := by
  by_cases h₁ : f₁ (t + d) = f₁ t + u
  · by_cases h₂ : f₂ (t + d) = f₂ t + u
    · exfalso
      apply h
      unfold arcWord
      rw [h₁, h₂, show f₁ t + u - (f₂ t + u) = f₁ t - f₂ t by omega]
    · exact Or.inr h₂
  · exact Or.inl h₁

variable {g f₁ f₂ : Nat → Int}

/-- **Three letters that differ at lag `d` span at least `D`.** Each marks a failure of one of the two lines, and two
failures of one line are at least `D` apart. -/
theorem three_failures (hg : IrrationalLine g) (h₁ : PhaseLine g f₁) (h₂ : PhaseLine g f₂)
    {u U : Int} {d D : Nat} (F : Farey g u d U D) {x y z : Nat} (xy : x < y) (yz : y < z) (short : z < x + D)
    (dx : arcWord f₁ f₂ (x + d) ≠ arcWord f₁ f₂ x)
    (dy : arcWord f₁ f₂ (y + d) ≠ arcWord f₁ f₂ y)
    (dz : arcWord f₁ f₂ (z + d) ≠ arcWord f₁ f₂ z) : False := by
  rcases fails_of_differs u dx with a | a <;> rcases fails_of_differs u dy with b | b <;>
    rcases fails_of_differs u dz with c | c
  · have := Farey.gap hg h₁ F a b xy; omega
  · have := Farey.gap hg h₁ F a b xy; omega
  · have := Farey.gap hg h₁ F a c (by omega); omega
  · have := Farey.gap hg h₂ F b c yz; omega
  · have := Farey.gap hg h₁ F b c yz; omega
  · have := Farey.gap hg h₂ F a c (by omega); omega
  · have := Farey.gap hg h₂ F a b xy; omega
  · have := Farey.gap hg h₂ F a b xy; omega

/-! ### A repeat from three trials -/

/-- If no three letters that differ at lag `q` lie within six times the cutoff, the lag and the surplus, one of three
greedy trials finds the word repeating at lag `q` from a start `a ≥ H` for `a + q + extra` letters. -/
theorem repeat_of_span {α : Type} (c : Nat → α) (H q extra : Nat)
    (separated : ∀ u v z, u < v → v < z → z - u ≤ 6 * (H + q + extra) →
      c (u + q) ≠ c u → c (v + q) ≠ c v → c (z + q) ≠ c z → False) :
    ∃ a, H ≤ a ∧ 2 * a + q + extra ≤ 8 * H + 7 * (q + extra) ∧
      ∀ s, s < a + q + extra → c (a + s) = c (a + q + s) := by
  classical
  apply Classical.byContradiction
  intro noRepeat
  have bad (a : Nat) (ha : H ≤ a) (endFits : 2 * a + q + extra ≤ 8 * H + 7 * (q + extra)) :
      ∃ t, a ≤ t ∧ t < 2 * a + q + extra ∧ c (t + q) ≠ c t := by
    apply Classical.byContradiction
    intro noBreak
    apply noRepeat
    refine ⟨a, ha, endFits, fun s hs => ?_⟩
    apply Classical.byContradiction
    intro different
    apply noBreak
    refine ⟨a + s, by omega, by omega, fun h => different ?_⟩
    rw [show a + q + s = a + s + q by omega]
    exact h.symm
  obtain ⟨u, hu, eu, du⟩ := bad H (by omega) (by omega)
  obtain ⟨v, hv, ev, dv⟩ := bad (u + 1) (by omega) (by omega)
  obtain ⟨z, hz, ez, dz⟩ := bad (v + 1) (by omega) (by omega)
  exact separated u v z (by omega) (by omega) (by omega) du dv dz

/-! ### Jen through one finite window -/

/-- Two equal stretches of readings beside an alternating column, the second starting late enough, contradict the
finite-left masked Jen theorem. -/
theorem visible_window (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start a b l : Nat) (ab : a < b)
    (clock : ∀ t, evol x (start + t) i = decide (t % 2 = 1))
    (reachable : 0 ≤ i - lo + ((start + 2 * b : Nat) : Int))
    (long : i - lo + ((start + 2 * b : Nat) : Int) ≤ 2 * (l : Int))
    (same : ∀ s, s < l → evol x (start + 2 * (a + s)) (i + 1) = evol x (start + 2 * (b + s)) (i + 1)) : False := by
  let m := (i - lo + ((start + 2 * b : Nat) : Int)).toNat
  have edge : (m : Int) = i - lo + ((start + 2 * b : Nat) : Int) := Int.toNat_of_nonneg reachable
  apply Rule30FiniteMaskedJen.window_jen_col leftBlack leftWhite (t₁ := start + 2 * a)
    (t₂ := start + 2 * b) (i := i) m (by omega) (by omega)
  · intro s _
    rw [Nat.add_assoc, Nat.add_assoc, clock, clock]
    have parity : (2 * a + s) % 2 = (2 * b + s) % 2 := by omega
    rw [parity]
  · intro s hs
    unfold Rule30FiniteMaskedJen.orCol
    simp only [Nat.add_assoc, clock]
    by_cases parity : s % 2 = 0
    · have ha : (2 * a + s) % 2 = 0 := by omega
      have hb : (2 * b + s) % 2 = 0 := by omega
      simp only [ha, hb, Nat.reduceEqDiff, decide_false, Bool.false_or]
      have e := same (s / 2) (by omega)
      rwa [show 2 * (a + s / 2) = 2 * a + s by omega, show 2 * (b + s / 2) = 2 * b + s by omega] at e
    · have ha : (2 * a + s) % 2 = 1 := by omega
      have hb : (2 * b + s) % 2 = 1 := by omega
      simp [ha, hb]

/-- A coded word whose repeats outlast their second start by any amount, in readings, is not read beside an
alternating column. -/
theorem excludes_blocks {α : Type} (c : Nat → α) (len : α → Nat) (positive : ∀ v, 1 ≤ len v)
    (bits : α → Nat → Bool)
    (reps : ∀ H C : Nat, ∃ a b l, H ≤ a ∧ a < b ∧ C ≤ b - a ∧
      (∀ s, s < l → c (a + s) = c (b + s)) ∧
      total (fun t => len (c t)) a + total (fun t => len (c t)) b + C ≤ total (fun t => len (c t)) (a + l))
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start + t) i = decide (t % 2 = 1))
    (reads : ∀ n y, y < len (c n) → cutoff ≤ total (fun t => len (c t)) n + y →
      evol x (start + 2 * (total (fun t => len (c t)) n + y)) (i + 1) = bits (c n) y) : False := by
  let w := fun t => len (c t)
  have pos : ∀ t, 1 ≤ w t := fun t => positive _
  let C := (lo - i).toNat + (i - lo + (start : Int)).toNat + 1
  obtain ⟨a, b, l, late, ab, lag, agree, room⟩ := reps cutoff C
  have bound (t : Nat) : t ≤ total w t := by simpa [total] using le_total w pos 0 t
  have grows := le_total w pos a (b - a)
  rw [Nat.add_sub_of_le (Nat.le_of_lt ab)] at grows
  change total w a + total w b + C ≤ total w (a + l) at room
  apply visible_window x lo i leftBlack leftWhite start (total w a) (total w b)
    (total w (a + l) - total w a) (by omega) clock
  · have hb := bound b
    dsimp [C] at lag
    omega
  · dsimp [C] at room
    omega
  · intro s hs
    obtain ⟨j, hj, y, hy, offset⟩ := locate w a s l (by omega)
    have eqw (e : Nat) (h : e < l) : w (a + e) = w (b + e) := congrArg len (agree e h)
    have hy' : y < w (b + j) := eqw j hj ▸ hy
    have shift := total_shift w a b j (fun e he => eqw e (by omega))
    have other : total w b + s = total w (b + j) + y := by omega
    have cut := bound a
    rw [offset, other, reads _ _ hy (by change cutoff ≤ total w (a + j) + y; omega),
      reads _ _ hy' (by change cutoff ≤ total w (b + j) + y; omega), agree j hj]

/-! ### Envelopes of the reading clock -/

/-- Linear envelopes for the reading clock: the readings of the first `n` letters lie between lines of slopes
`low / den` and `high / den`, up to `err`, and the slopes differ by at most `1 / (30 gear)` of the lower one. -/
def Envelopes (w : Nat → Nat) (gear : Nat) : Prop :=
  ∃ den low high err : Nat, 0 < den ∧ low ≤ high ∧ 30 * gear * (high - low) ≤ low ∧
    (∀ n, low * n ≤ den * total w n + err) ∧ ∀ n, den * total w n ≤ high * n + err

/-- Envelopes turn a surplus of letters into a surplus of readings. -/
theorem slack_of_envelopes (w : Nat → Nat) {den low high err a b l : Nat}
    (positive : 0 < den)
    (lower : ∀ n, low * n ≤ den * total w n + err)
    (upper : ∀ n, den * total w n ≤ high * n + err)
    (margin : high * (a + b) ≤ low * (a + l)) :
    total w a + total w b ≤ total w (a + l) + 3 * err := by
  have gain : 3 * err ≤ den * (3 * err) := by
    simpa using Nat.mul_le_mul_right (3 * err) (show 1 ≤ den by omega)
  apply Nat.le_of_mul_le_mul_left _ positive
  simp only [Nat.mul_add] at margin ⊢
  have first := upper a
  have second := upper b
  have finish := lower (a + l)
  rw [Nat.mul_add] at finish
  omega

theorem total_const (L n : Nat) : total (fun _ => L) n = L * n := by
  induction n with
  | zero => rfl
  | succ n ih => rw [total_succ, ih, Nat.mul_succ]

/-- Blocks of one length have exact envelopes. -/
theorem equal_envelopes (L gear : Nat) : Envelopes (fun _ => L) gear :=
  ⟨1, L, L, 0, by omega, Nat.le_refl _, by simp, fun n => by rw [total_const]; omega,
    fun n => by rw [total_const]; omega⟩

/-! ### Every phase above ratio six -/

/-- **Every phase, every arc, any two nonempty blocks**, given envelopes of their reading clock. The angle needs, for
one positive `gear`, arbitrarily large Farey neighbours `u / d` and `U / D` with `(6 gear + 16) d ≤ gear D`. -/
theorem above_six_of_envelopes (hg : IrrationalLine g) (h₁ : PhaseLine g f₁) (h₂ : PhaseLine g f₂)
    (len : Bool → Nat) (positive : ∀ b, 1 ≤ len b) (bits : Bool → Nat → Bool)
    {gear : Nat} (gearPos : 0 < gear)
    (env : Envelopes (fun t => len (arcWord f₁ f₂ t)) (2 * gear))
    (approximations : ∀ N, ∃ (u : Int) (d : Nat) (U : Int) (D : Nat),
      N ≤ d ∧ (6 * gear + 16) * d ≤ gear * D ∧ Farey g u d U D)
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start + t) i = decide (t % 2 = 1))
    (reads : ∀ n y, y < len (arcWord f₁ f₂ n) →
      cutoff ≤ total (fun t => len (arcWord f₁ f₂ t)) n + y →
      evol x (start + 2 * (total (fun t => len (arcWord f₁ f₂ t)) n + y)) (i + 1) =
        bits (arcWord f₁ f₂ n) y) : False := by
  let c := arcWord f₁ f₂
  let w := fun t => len (c t)
  obtain ⟨den, low, high, err, denPos, order, accurate, lower, upper⟩ := env
  apply excludes_blocks c len positive bits ?_ x lo i leftBlack leftWhite start cutoff clock reads
  intro H N
  obtain ⟨u, q, U, Q, large, ratio, F⟩ := approximations (N + 8 * gear * H + 2 * gear + gear * (N + 3 * err))
  let extra := q / gear
  have side : 8 * gear * H ≤ q := by omega
  have extraPos : 1 ≤ extra := Nat.div_pos (by omega) gearPos
  have below : gear * extra ≤ q := Nat.mul_div_le q gear
  have above : q ≤ 2 * gear * extra := by
    have decompose : gear * extra + q % gear = q := Nat.div_add_mod q gear
    have rem := Nat.mod_lt q gearPos
    have atLeast := Nat.mul_le_mul_left gear extraPos
    have e : 2 * gear * extra = gear * extra + gear * extra := by grind
    omega
  have span : 6 * (H + q + 2 * extra) < Q := by
    apply Nat.lt_of_mul_lt_mul_left (a := gear)
    have e₁ : gear * (6 * (H + q + 2 * extra)) = 6 * (gear * H) + 6 * (gear * q) + 12 * (gear * extra) := by grind
    have e₂ : (6 * gear + 16) * q = 6 * (gear * q) + 16 * q := by grind
    have e₃ : 8 * gear * H = 8 * (gear * H) := by grind
    omega
  obtain ⟨a, late, finish, agree⟩ := repeat_of_span c H q (2 * extra) (fun u' v z uv vz short =>
    three_failures hg h₁ h₂ F uv vz (by omega))
  refine ⟨a, a + q, a + q + 2 * extra, late, by omega, by omega, agree, ?_⟩
  have startBound : 8 * H ≤ q := by
    have mult := Nat.mul_le_mul_right (8 * H) (show 1 ≤ gear by omega)
    have e : gear * (8 * H) = 8 * gear * H := by grind
    omega
  have endBound : a + (a + q) ≤ 22 * q := by
    have e : extra ≤ q := Nat.div_le_self q gear
    omega
  have gain : (high - low) * (a + (a + q)) ≤ low * extra := by
    have s₁ := Nat.mul_le_mul_left (high - low) endBound
    have s₂ := Nat.mul_le_mul_left (high - low) (Nat.mul_le_mul_left 22 above)
    have s₃ : 30 * (2 * gear) * (high - low) ≤ low := accurate
    have s₄ := Nat.mul_le_mul_right extra s₃
    have e₁ : (high - low) * (22 * (2 * gear * extra)) = 44 * (gear * (high - low)) * extra := by grind
    have e₂ : 30 * (2 * gear) * (high - low) * extra = 60 * (gear * (high - low)) * extra := by grind
    have e₃ : 44 * (gear * (high - low)) * extra ≤ 60 * (gear * (high - low)) * extra :=
      Nat.mul_le_mul_right _ (Nat.mul_le_mul_right _ (by omega))
    omega
  have margin : high * (a + (a + q)) ≤ low * (a + (a + q + extra)) := by
    have e₁ : high * (a + (a + q)) = (high - low) * (a + (a + q)) + low * (a + (a + q)) := by
      rw [← Nat.add_mul, Nat.sub_add_cancel order]
    have e₂ : low * (a + (a + q + extra)) = low * (a + (a + q)) + low * extra := by
      rw [show a + (a + q + extra) = (a + (a + q)) + extra by omega, Nat.mul_add]
    omega
  have slack := slack_of_envelopes w denPos lower upper margin
  have reserve : N + 3 * err ≤ extra := (Nat.le_div_iff_mul_le gearPos).mpr (by
    rw [Nat.mul_comm]; omega)
  have more := le_total w (fun t => positive (c t)) (a + (a + q + extra)) extra
  rw [show a + (a + q + extra) + extra = a + (a + q + 2 * extra) by omega] at more
  change total w a + total w (a + q) + N ≤ total w (a + (a + q + 2 * extra))
  omega

/-- **Blocks of one length**, at every phase and for every arc, above ratio six. -/
theorem above_six_equal (hg : IrrationalLine g) (h₁ : PhaseLine g f₁) (h₂ : PhaseLine g f₂)
    (L : Nat) (hL : 1 ≤ L) (bits : Bool → Nat → Bool)
    {gear : Nat} (gearPos : 0 < gear)
    (approximations : ∀ N, ∃ (u : Int) (d : Nat) (U : Int) (D : Nat),
      N ≤ d ∧ (6 * gear + 16) * d ≤ gear * D ∧ Farey g u d U D)
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start + t) i = decide (t % 2 = 1))
    (reads : ∀ n y, y < L → cutoff ≤ L * n + y →
      evol x (start + 2 * (L * n + y)) (i + 1) = bits (arcWord f₁ f₂ n) y) : False := by
  apply above_six_of_envelopes hg h₁ h₂ (fun _ => L) (fun _ => hL) bits gearPos (equal_envelopes L _)
    approximations x lo i leftBlack leftWhite start cutoff clock
  intro n y hy hc
  have e : total (fun t => (fun _ => L) (arcWord f₁ f₂ t)) n = L * n := total_const L n
  rw [e] at hc ⊢
  exact reads n y hy hc

/-! ### The angle √10 − 3 -/

theorem ten_irrational (p q : Nat) (hq : 1 ≤ q) : p * p ≠ 10 * (q * q) := by
  induction q using Nat.strongRecOn generalizing p with
  | ind q ih =>
    intro h
    obtain ⟨k, rfl⟩ : ∃ k, p = 2 * k := by
      rcases Nat.mod_two_eq_zero_or_one p with e | e
      · exact ⟨p / 2, by omega⟩
      · obtain ⟨k, rfl⟩ : ∃ k, p = 2 * k + 1 := ⟨p / 2, by omega⟩
        grind
    obtain ⟨m, rfl⟩ : ∃ m, q = 2 * m := by
      rcases Nat.mod_two_eq_zero_or_one q with e | e
      · exact ⟨q / 2, by omega⟩
      · obtain ⟨m, rfl⟩ : ∃ m, q = 2 * m + 1 := ⟨q / 2, by omega⟩
        grind
    have h' : k * k = 10 * (m * m) := by grind
    exact ih m (by omega) k (by omega) h'

/-- The floors of the multiples of `√10 - 3`. -/
def sixesFloor (t : Nat) : Int := (isqrt (10 * (t * t)) : Int) - 3 * t

theorem sixes_line : IrrationalLine sixesFloor := by
  have base := sqrt_line 10 ten_irrational
  exact ⟨fun m n hm hn => by
      have := base.floors m n hm hn
      unfold sixesFloor
      grind,
    fun p q hq => by
      obtain ⟨n, hn, h⟩ := base.irrational (p + 3 * q) q hq
      refine ⟨n, hn, ?_⟩
      unfold sixesFloor
      rcases h with h | h
      · left; grind
      · right; grind⟩

theorem isqrt_eq {n a : Nat} (lo : a * a ≤ n) (hi : n < (a + 1) * (a + 1)) : isqrt n = a := by
  obtain ⟨b₁, b₂⟩ := isqrt_spec n
  rcases Nat.lt_trichotomy (isqrt n) a with h | h | h
  · have : (isqrt n + 1) * (isqrt n + 1) ≤ a * a := Nat.mul_le_mul (by omega) (by omega)
    omega
  · exact h
  · have : (a + 1) * (a + 1) ≤ isqrt n * isqrt n := Nat.mul_le_mul (by omega) (by omega)
    omega

theorem sixes_floor_of {q a : Nat} (lo : a * a ≤ 10 * (q * q)) (hi : 10 * (q * q) < (a + 1) * (a + 1)) :
    sixesFloor q = (a : Int) - 3 * q := by
  unfold sixesFloor
  rw [isqrt_eq lo hi]

/-- Consecutive convergents `p / q` of `√10 - 3`, from `1 / 6` by `(p, q) ↦ (q, 6 q + p)`. The sign of
`(3 q + p)² - 10 q²`, one or minus one, says on which side of the angle `p / q` lies. -/
theorem six_pairs (N : Nat) :
    ∃ p q : Nat, N ≤ q ∧ 1 ≤ p ∧ p ≤ q ∧ q ≤ 7 * p ∧
      ((3 * q + p) * (3 * q + p) + 1 = 10 * (q * q) ∨ (3 * q + p) * (3 * q + p) = 10 * (q * q) + 1) := by
  induction N with
  | zero => exact ⟨1, 6, by omega, by omega, by omega, by omega, Or.inr (by decide)⟩
  | succ N ih =>
    obtain ⟨p, q, large, pos, order, upper, side⟩ := ih
    refine ⟨q, 6 * q + p, by omega, by omega, by omega, by omega, ?_⟩
    rcases side with h | h
    · right; grind
    · left; grind

/-- Large Farey neighbours of `√10 - 3`, with ratio above six by the margin of `gear = 128`. -/
theorem sixes_farey (N : Nat) : ∃ (u : Int) (d : Nat) (U : Int) (D : Nat),
    N ≤ d ∧ (6 * 128 + 16) * d ≤ 128 * D ∧ Farey sixesFloor u d U D := by
  obtain ⟨p, q, large, pos, order, upper, side⟩ := six_pairs N
  refine ⟨p, q, q, 6 * q + p, large, by omega, by omega, by omega, ?_⟩
  rcases side with h | h
  · -- `p / q` below the angle, `q / (6 q + p)` above it
    have hD : (3 * (6 * q + p) + q) * (3 * (6 * q + p) + q) = 10 * ((6 * q + p) * (6 * q + p)) + 1 := by grind
    obtain ⟨a, ha⟩ : ∃ a, 3 * (6 * q + p) + q = a + 1 := ⟨3 * (6 * q + p) + q - 1, by omega⟩
    rw [ha] at hD
    have e₁ : sixesFloor q = p := by
      rw [sixes_floor_of (a := 3 * q + p) (by omega) (by grind)]
      omega
    have e₂ : sixesFloor (6 * q + p) = (q : Int) - 1 := by
      rw [sixes_floor_of (a := a) (by grind) (by omega)]
      omega
    refine Or.inl ⟨?_, ?_, ?_⟩
    · have := floor_above sixes_line (t := q) (by omega)
      rwa [e₁] at this
    · have := floor_below sixes_line (t := 6 * q + p) (by omega)
      rw [e₂, show -((q : Int) - 1 + 1) = -(q : Int) by omega] at this
      exact this
    · have n : q * q = p * (6 * q + p) + 1 := by grind
      have z : ((q * q : Nat) : Int) = ((p * (6 * q + p) + 1 : Nat) : Int) := congrArg _ n
      push_cast at z ⊢
      omega
  · -- `p / q` above the angle, `q / (6 q + p)` below it
    have hD : (3 * (6 * q + p) + q) * (3 * (6 * q + p) + q) + 1 = 10 * ((6 * q + p) * (6 * q + p)) := by grind
    obtain ⟨a, ha⟩ : ∃ a, 3 * q + p = a + 1 := ⟨3 * q + p - 1, by omega⟩
    rw [ha] at h
    have e₁ : sixesFloor q = (p : Int) - 1 := by
      rw [sixes_floor_of (a := a) (by grind) (by omega)]
      omega
    have e₂ : sixesFloor (6 * q + p) = q := by
      rw [sixes_floor_of (a := 3 * (6 * q + p) + q) (by omega) (by grind)]
      omega
    refine Or.inr ⟨?_, ?_, ?_⟩
    · have := floor_below sixes_line (t := q) (by omega)
      rw [e₁, show -((p : Int) - 1 + 1) = -(p : Int) by omega] at this
      exact this
    · have := floor_above sixes_line (t := 6 * q + p) (by omega)
      rwa [e₂] at this
    · have n : p * (6 * q + p) = q * q + 1 := by grind
      have z : ((p * (6 * q + p) : Nat) : Int) = ((q * q + 1 : Nat) : Int) := congrArg _ n
      push_cast at z ⊢
      omega

/-- **The angle `√10 - 3`**: blocks of one length in the order of any arc, from any phase, are not read beside an
alternating column. -/
theorem sixes_equal (h₁ : PhaseLine sixesFloor f₁) (h₂ : PhaseLine sixesFloor f₂)
    (L : Nat) (hL : 1 ≤ L) (bits : Bool → Nat → Bool)
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start + t) i = decide (t % 2 = 1))
    (reads : ∀ n y, y < L → cutoff ≤ L * n + y →
      evol x (start + 2 * (L * n + y)) (i + 1) = bits (arcWord f₁ f₂ n) y) : False :=
  above_six_equal sixes_line h₁ h₂ L hL bits (gear := 128) (by decide) sixes_farey x lo i leftBlack leftWhite
    start cutoff clock reads

end Ruliology.CellularAutomata.Rule30RotationFreePhase
