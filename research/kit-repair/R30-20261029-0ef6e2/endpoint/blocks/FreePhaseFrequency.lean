import SeparatedArcCuts
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

/-! ### The frequency of a letter

The approximations alone bound how far the sums over `q` consecutive blocks can differ, at every phase. Compare the orbit
with the grid of step `1/q` (`grid_step`, `grid_floor`): the sum of the `q` floors differs from `⌊q x⌋` by a constant and at
most three (`orbit_floor`). So a common denominator and two close envelopes are always available (`envelopes`), and the
exclusion needs no hypothesis on the block clock (`free_phase_excluded`). -/

namespace SeparatedArcCuts
open Ruliology.CellularAutomata Rule30RotationBlocks WeightedRepeatTransfer
open Rule30Realization (evol)

private def sum (f : Nat → ℤ) : Nat → ℤ
  | 0 => 0
  | n+1 => sum f n + f n

private theorem sum_le {f g : Nat → ℤ} (n : Nat) (h : ∀ t, t < n → f t ≤ g t) : sum f n ≤ sum g n := by
  induction n with
  | zero => exact le_refl _
  | succ n ih => exact add_le_add (ih fun t ht => h t (by omega)) (h n (by omega))

private theorem sum_congr {f g : Nat → ℤ} (n : Nat) (h : ∀ t, t < n → f t = g t) : sum f n = sum g n :=
  le_antisymm (sum_le n fun t ht => (h t ht).le) (sum_le n fun t ht => (h t ht).ge)

private theorem sum_head (f : Nat → ℤ) (n : Nat) : sum (fun t => f (t+1)) n + f 0 = sum f (n+1) := by
  induction n with
  | zero => simp [sum]
  | succ n ih =>
    change sum (fun t => f (t+1)) n + f (n+1) + f 0 = sum f (n+1) + f (n+1)
    rw [← ih]
    ring

private theorem sum_sub_const (f : Nat → ℤ) (v : ℤ) (n : Nat) : sum (fun t => f t - v) n = sum f n - n*v := by
  induction n with
  | zero => simp [sum]
  | succ n ih =>
    change sum (fun t => f t - v) n + (f n - v) = sum f n + f n - ((n+1 : Nat):ℤ)*v
    rw [ih]
    push_cast
    ring

private theorem window_shift (q : Nat) (p : ℤ) (u : Nat) : ∀ f : Nat → ℤ, (∀ t, f (t+q) = f t + p) →
    sum (fun t => f (t+u)) q = sum f q + u*p := by
  induction u with
  | zero => intro f _; simp
  | succ u ih =>
    intro f h
    have i := ih (fun t => f (t+1)) (fun t => by
      have := h (t+1)
      rwa [show t+1+q = t+q+1 by omega] at this)
    have s := sum_head f q
    have e : sum f (q+1) = sum f q + f q := rfl
    have z := h 0
    rw [Nat.zero_add] at z
    have g : sum (fun t => f (t+(u+1))) q = sum (fun t => (fun t => f (t+1)) (t+u)) q :=
      sum_congr q fun t _ => by rw [show t+(u+1) = t+u+1 by omega]
    rw [g, i]
    push_cast
    linarith

private noncomputable def grid (p : ℤ) (q : Nat) (x : ℝ) : ℤ := sum (fun t => ⌊x+(t:ℝ)*p/q⌋) q

private theorem grid_mono (p : ℤ) (q : Nat) {x y : ℝ} (h : x ≤ y) : grid p q x ≤ grid p q y :=
  sum_le q fun t _ => Int.floor_mono (by linarith)

/-- Moving the phase by one step of the grid adds one to the sum of the floors. -/
private theorem grid_step {p v : ℤ} {q u : Nat} (hq : 0 < q) (h : (u:ℤ)*p = 1+v*q) (x : ℝ) :
    grid p q (x+1/q) = grid p q x + 1 := by
  have hq' : (q:ℝ) ≠ 0 := by exact_mod_cast hq.ne'
  have hr : (u:ℝ)*p = 1+v*q := by exact_mod_cast h
  let F : Nat → ℤ := fun t => ⌊x+(t:ℝ)*p/q⌋
  have term (t : Nat) : ⌊x+1/q+(t:ℝ)*p/q⌋ = F (t+u) - v := by
    have e : x+1/q+(t:ℝ)*p/q = x+((t+u:Nat):ℝ)*p/q-v := by
      have : ((t+u:Nat):ℝ)*p/q = (t:ℝ)*p/q+(1+v*q)/q := by
        rw [← hr]; push_cast; ring
      rw [this, add_div, mul_div_cancel_right₀ _ hq']
      ring
    change _ = ⌊x+((t+u:Nat):ℝ)*p/q⌋ - v
    rw [e, Int.floor_sub_intCast]
  have period (t : Nat) : F (t+q) = F t + p := by
    have e : x+((t+q:Nat):ℝ)*p/q = x+(t:ℝ)*p/q+p := by
      have : ((t+q:Nat):ℝ)*p/q = (t:ℝ)*p/q+(q*p)/q := by push_cast; ring
      rw [this, mul_div_assoc (q:ℝ), mul_div_cancel₀ _ hq']
      ring
    change ⌊x+((t+q:Nat):ℝ)*p/q⌋ = ⌊x+(t:ℝ)*p/q⌋ + p
    rw [e, Int.floor_add_intCast]
  unfold grid
  rw [sum_congr q fun t _ => term t, sum_sub_const, window_shift q p u F period, h]
  change sum F q + (1+v*q) - q*v = sum F q + 1
  ring

private theorem grid_nat {p v : ℤ} {q u : Nat} (hq : 0 < q) (h : (u:ℤ)*p = 1+v*q) (x : ℝ) (n : Nat) :
    grid p q (x+n/q) = grid p q x + n := by
  induction n with
  | zero => simp
  | succ n ih =>
    have e : x+((n+1:Nat):ℝ)/q = x+n/q+1/q := by push_cast; ring
    rw [e, grid_step hq h, ih]
    push_cast
    ring

private theorem grid_int {p v : ℤ} {q u : Nat} (hq : 0 < q) (h : (u:ℤ)*p = 1+v*q) (k : ℤ) :
    grid p q (k/q) = grid p q 0 + k := by
  rcases Int.le_total 0 k with hk | hk
  · obtain ⟨n,rfl⟩ := Int.eq_ofNat_of_zero_le hk
    have := grid_nat hq h 0 n
    simpa using this
  · obtain ⟨n,hn⟩ := Int.eq_ofNat_of_zero_le (show 0 ≤ -k by omega)
    have e : k = -(n:ℤ) := by omega
    have := grid_nat hq h (k/q) n
    have z : (k:ℝ)/q+n/q = 0 := by rw [e]; push_cast; ring
    rw [z] at this
    omega

/-- The sum over the grid is `⌊q x⌋` up to a constant and one. -/
private theorem grid_floor {p v : ℤ} {q u : Nat} (hq : 0 < q) (h : (u:ℤ)*p = 1+v*q) (x : ℝ) :
    grid p q 0 + ⌊(q:ℝ)*x⌋ ≤ grid p q x ∧ grid p q x ≤ grid p q 0 + ⌊(q:ℝ)*x⌋ + 1 := by
  have hq' : (0:ℝ) < q := by exact_mod_cast hq
  have lo : ((⌊(q:ℝ)*x⌋:ℤ):ℝ)/q ≤ x := by
    rw [div_le_iff₀ hq', mul_comm x]
    exact Int.floor_le _
  have hi : x ≤ ((⌊(q:ℝ)*x⌋+1:ℤ):ℝ)/q := by
    rw [le_div_iff₀ hq', mul_comm x]
    push_cast
    exact (Int.lt_floor_add_one _).le
  have a := grid_mono p q lo
  have b := grid_mono p q hi
  rw [grid_int hq h] at a b
  omega

private noncomputable def orbit (alpha : ℝ) (q : Nat) (x : ℝ) : ℤ := sum (fun t => ⌊x+(t:ℝ)*alpha⌋) q

/-- The sum along the true orbit is `⌊q x⌋` up to a constant and at most three. -/
private theorem orbit_floor {alpha : ℝ} {p v : ℤ} {q u : Nat} (hq : 0 < q) (h : (u:ℤ)*p = 1+v*q)
    (close : |(q:ℝ)*alpha-p| ≤ 1/q) (x : ℝ) :
    grid p q 0 + ⌊(q:ℝ)*x⌋ - 1 ≤ orbit alpha q x ∧ orbit alpha q x ≤ grid p q 0 + ⌊(q:ℝ)*x⌋ + 2 := by
  have hq' : (0:ℝ) < q := by exact_mod_cast hq
  have near (t : Nat) (ht : t < q) : |(t:ℝ)*alpha-(t:ℝ)*p/q| ≤ 1/q := by
    have e : (t:ℝ)*alpha-(t:ℝ)*p/q = (t:ℝ)/q*((q:ℝ)*alpha-p) := by
      field_simp
    rw [e, abs_mul, abs_of_nonneg (by positivity)]
    have r : (t:ℝ)/q ≤ 1 := by
      rw [div_le_one hq']
      exact_mod_cast ht.le
    calc (t:ℝ)/q*|(q:ℝ)*alpha-p| ≤ 1*|(q:ℝ)*alpha-p| := mul_le_mul_of_nonneg_right r (abs_nonneg _)
      _ ≤ 1/q := by rw [one_mul]; exact close
  have up : orbit alpha q x ≤ grid p q (x+1/q) := sum_le q fun t ht => Int.floor_mono (by
    have := (abs_le.mp (near t ht)).2
    linarith)
  have down : grid p q (x-1/q) ≤ orbit alpha q x := sum_le q fun t ht => Int.floor_mono (by
    have := (abs_le.mp (near t ht)).1
    linarith)
  have s := grid_step hq h x
  have s' := grid_step hq h (x-1/q)
  rw [sub_add_cancel] at s'
  have g := grid_floor hq h x
  omega

private theorem floor_gap (a b : ℝ) : ⌊b⌋ ≤ ⌊a⌋-⌊a-b⌋ ∧ ⌊a⌋-⌊a-b⌋ ≤ ⌊b⌋+1 := by
  have e : a = (a-b)+b := by ring
  have l := Int.le_floor_add (a-b) b
  have u := Int.le_floor_add_floor (a-b) b
  rw [← e] at l u
  omega

/-- The number of visits to the arc in `q` consecutive steps, at any two phases, differs by at most seven. -/
private theorem visits {alpha gamma : ℝ} {p v : ℤ} {q u : Nat} (hq : 0 < q) (h : (u:ℤ)*p = 1+v*q)
    (close : |(q:ℝ)*alpha-p| ≤ 1/q) (x y : ℝ) :
    (orbit alpha q x - orbit alpha q (x-gamma)) - (orbit alpha q y - orbit alpha q (y-gamma)) ≤ 7 := by
  have a := orbit_floor hq h close x
  have b := orbit_floor hq h close (x-gamma)
  have c := orbit_floor hq h close y
  have d := orbit_floor hq h close (y-gamma)
  have e := floor_gap ((q:ℝ)*x) ((q:ℝ)*gamma)
  have f := floor_gap ((q:ℝ)*y) ((q:ℝ)*gamma)
  rw [← mul_sub] at e f
  omega

private theorem arc_value (alpha gamma theta : ℝ) (n : Nat) (gammaPos : 0 < gamma) (gammaLt : gamma < 1)
    (len : Bool → Nat) :
    (len (arc alpha gamma theta n) : ℤ) = len false +
      ((len true : ℤ)-len false)*(⌊theta+(n:ℝ)*alpha⌋-⌊theta+(n:ℝ)*alpha-gamma⌋) := by
  have g := floor_gap (theta+(n:ℝ)*alpha) gamma
  have z : ⌊gamma⌋ = 0 := Int.floor_eq_zero_iff.mpr ⟨gammaPos.le,gammaLt⟩
  rw [z] at g
  unfold arc
  rcases (by omega : ⌊theta+(n:ℝ)*alpha⌋-⌊theta+(n:ℝ)*alpha-gamma⌋ = 0 ∨
    ⌊theta+(n:ℝ)*alpha⌋-⌊theta+(n:ℝ)*alpha-gamma⌋ = 1) with e | e <;> rw [e] <;> simp

private theorem chunk {alpha gamma theta : ℝ} (gammaPos : 0 < gamma) (gammaLt : gamma < 1) (len : Bool → Nat) (a n : Nat) :
    (total (fun t => len (arc alpha gamma theta t)) (a+n) : ℤ) =
      total (fun t => len (arc alpha gamma theta t)) a + n*len false +
        ((len true : ℤ)-len false)*
          (orbit alpha n (theta+(a:ℝ)*alpha)-orbit alpha n (theta+(a:ℝ)*alpha-gamma)) := by
  induction n with
  | zero => simp [orbit, sum]
  | succ n ih =>
    have e₁ : orbit alpha (n+1) (theta+(a:ℝ)*alpha) =
        orbit alpha n (theta+(a:ℝ)*alpha) + ⌊theta+((a+n:Nat):ℝ)*alpha⌋ := by
      change orbit alpha n _ + ⌊theta+(a:ℝ)*alpha+(n:ℝ)*alpha⌋ = _
      congr 2
      push_cast
      ring
    have e₂ : orbit alpha (n+1) (theta+(a:ℝ)*alpha-gamma) =
        orbit alpha n (theta+(a:ℝ)*alpha-gamma) + ⌊theta+((a+n:Nat):ℝ)*alpha-gamma⌋ := by
      change orbit alpha n _ + ⌊theta+(a:ℝ)*alpha-gamma+(n:ℝ)*alpha⌋ = _
      congr 2
      push_cast
      ring
    change ((total (fun t => len (arc alpha gamma theta t)) (a+n) + len (arc alpha gamma theta (a+n)) : Nat) : ℤ) = _
    rw [e₁, e₂]
    push_cast
    rw [ih, arc_value alpha gamma theta (a+n) gammaPos gammaLt len]
    push_cast
    ring

private theorem total_bound (w : Nat → Nat) (B : Nat) (h : ∀ t, w t ≤ B) (n : Nat) : total w n ≤ B*n := by
  induction n with
  | zero => simp [total]
  | succ n ih =>
    change total w n + w n ≤ B*(n+1)
    rw [Nat.mul_add, Nat.mul_one]
    exact Nat.add_le_add ih (h n)

/-- Sums over `q` consecutive terms between `m` and `m+D` give linear envelopes with denominator `q`. -/
private theorem envelope (w : Nat → Nat) {q m D B : Nat} (hq : 0 < q) (hB : ∀ t, w t ≤ B)
    (low : ∀ a, total w a + m ≤ total w (a+q)) (high : ∀ a, total w (a+q) ≤ total w a + (m+D)) (n : Nat) :
    m*n ≤ q*total w n + (m*q+q*(B*q)) ∧ q*total w n ≤ (m+D)*n + (m*q+q*(B*q)) := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
    rcases Nat.lt_or_ge n q with hn | hn
    · constructor
      · exact Nat.le_trans (Nat.mul_le_mul_left m hn.le) (by omega)
      · have t := total_bound w B hB n
        have t' := Nat.mul_le_mul_left q (Nat.le_trans t (Nat.mul_le_mul_left B hn.le))
        omega
    · obtain ⟨k,rfl⟩ : ∃ k, n = k+q := ⟨n-q,by omega⟩
      obtain ⟨i,j⟩ := ih k (by omega)
      have a := Nat.mul_le_mul_left q (low k)
      have b := Nat.mul_le_mul_left q (high k)
      rw [Nat.mul_add] at a b
      rw [Nat.mul_add, Nat.mul_add]
      have c : q*m = m*q := Nat.mul_comm ..
      have d : q*(m+D) = (m+D)*q := Nat.mul_comm ..
      omega

/-- The error of the first of two neighbouring approximations, from the determinant and the opposite signs. -/
private theorem error_small {alpha : ℝ} {p p' sign : ℤ} {q Q : Nat} (hq : 0 < q) (hQ : q ≤ Q)
    (det : p*(Q:ℤ)-p'*(q:ℤ) = sign) (unit : sign*sign = 1)
    (opposite : ((q:ℝ)*alpha-p)*((Q:ℝ)*alpha-p') < 0) : |(q:ℝ)*alpha-p| ≤ 1/q := by
  have hq' : (0:ℝ) < q := by exact_mod_cast hq
  have hQ' : (q:ℝ) ≤ Q := by exact_mod_cast hQ
  have d : (p:ℝ)*Q-p'*q = sign := by exact_mod_cast det
  have s : (sign:ℝ) = 1 ∨ (sign:ℝ) = -1 := by
    rcases Int.mul_eq_one_iff_eq_one_or_neg_one.mp unit with ⟨e,_⟩ | ⟨e,_⟩
    · left; exact_mod_cast e
    · right; exact_mod_cast e
  have key : (q:ℝ)*((Q:ℝ)*alpha-p')-Q*((q:ℝ)*alpha-p) = sign := by rw [← d]; ring
  rw [le_div_iff₀ hq']
  rcases mul_neg_iff.mp opposite with ⟨he,hf⟩ | ⟨he,hf⟩
  · rw [abs_of_pos he]
    rcases s with s | s <;> nlinarith [mul_pos he hq', mul_neg_of_pos_of_neg hq' hf,
      mul_le_mul_of_nonneg_right hQ' he.le]
  · rw [abs_of_neg he]
    rcases s with s | s <;> nlinarith [mul_neg_of_neg_of_pos he hq', mul_pos hq' hf,
      mul_le_mul_of_nonneg_right hQ' (neg_pos.mpr he).le]

/-- A multiple of `p` that is one more than a multiple of `q`. -/
private theorem inverse {p p' sign : ℤ} {q Q : Nat} (hq : 0 < q) (det : p*(Q:ℤ)-p'*(q:ℤ) = sign) (unit : sign*sign = 1) :
    ∃ (u : Nat) (v : ℤ), (u:ℤ)*p = 1+v*q := by
  have hq' : (q:ℤ) ≠ 0 := by omega
  refine ⟨((sign*Q)%q).toNat, sign*p'-(sign*Q)/q*p, ?_⟩
  rw [Int.toNat_of_nonneg (Int.emod_nonneg _ hq'), Int.emod_def]
  linear_combination sign*det+unit

/-- Any two positive block lengths in the order of an arc, at any phase, have linear envelopes as close as wanted. -/
theorem envelopes {alpha gamma theta : ℝ} (gammaPos : 0 < gamma) (gammaLt : gamma < 1) (len : Bool → Nat)
    (positive : ∀ b, 1 ≤ len b) (gear : Nat)
    (approximations : ∀ N, ∃ (q Q : Nat) (p p' sign : ℤ), N ≤ q ∧ q ≤ Q ∧ p*(Q:ℤ)-p'*(q:ℤ) = sign ∧
      sign*sign = 1 ∧ ((q:ℝ)*alpha-p)*((Q:ℝ)*alpha-p') < 0) :
    ∃ den low high err : Nat, 0 < den ∧ low ≤ high ∧ 30*gear*(high-low) ≤ low ∧
      (∀ n, low*n ≤ den*total (fun t => len (arc alpha gamma theta t)) n + err) ∧
      ∀ n, den*total (fun t => len (arc alpha gamma theta t)) n ≤ high*n + err := by
  let D := 7*(len true+len false)
  obtain ⟨q,Q,p,p',sign,large,order,det,unit,opposite⟩ := approximations (60*gear*D+D+1)
  have hq : 0 < q := by omega
  obtain ⟨u,v,huv⟩ := inverse hq det unit
  have close := error_small hq order det unit opposite
  let w := fun t => len (arc alpha gamma theta t)
  have pos : ∀ t, 1 ≤ w t := fun t => positive _
  have base : q ≤ total w q := by
    have := le_total w pos 0 q
    simpa [total] using this
  have spread (a : Nat) : total w (a+q) ≤ total w a + (total w q+D) ∧ total w a + total w q ≤ total w (a+q) + D := by
    have c := chunk (alpha := alpha) (theta := theta) gammaPos gammaLt len a q
    have c₀ := chunk (alpha := alpha) (theta := theta) gammaPos gammaLt len 0 q
    rw [Nat.zero_add] at c₀
    have z : total (fun t => len (arc alpha gamma theta t)) 0 = 0 := rfl
    rw [z] at c₀
    have v₁ := visits (gamma := gamma) hq huv close (theta+(a:ℝ)*alpha) (theta+((0:Nat):ℝ)*alpha)
    have v₂ := visits (gamma := gamma) hq huv close (theta+((0:Nat):ℝ)*alpha) (theta+(a:ℝ)*alpha)
    generalize orbit alpha q (theta+(a:ℝ)*alpha)-orbit alpha q (theta+(a:ℝ)*alpha-gamma) = A at c v₁ v₂
    generalize orbit alpha q (theta+((0:Nat):ℝ)*alpha)-orbit alpha q (theta+((0:Nat):ℝ)*alpha-gamma) = A₀ at c₀ v₁ v₂
    have hD : (D:ℤ) = 7*((len true:ℤ)+len false) := by simp [D]
    change ((total w (a+q) : Nat):ℤ) = _ at c
    change ((total w q : Nat):ℤ) = _ at c₀
    have lt := Int.natCast_nonneg (len true)
    have lf := Int.natCast_nonneg (len false)
    have e : ((total w (a+q) : Nat):ℤ) - total w a - total w q = ((len true:ℤ)-len false)*(A-A₀) := by
      rw [c, c₀]
      push_cast
      ring
    have up : ((len true:ℤ)-len false)*(A-A₀) ≤ 7*((len true:ℤ)+len false) := by
      nlinarith [mul_nonneg lt (show (0:ℤ) ≤ 7-(A-A₀) by omega), mul_nonneg lf (show (0:ℤ) ≤ 7+(A-A₀) by omega)]
    have down : -(7*((len true:ℤ)+len false)) ≤ ((len true:ℤ)-len false)*(A-A₀) := by
      nlinarith [mul_nonneg lt (show (0:ℤ) ≤ 7+(A-A₀) by omega), mul_nonneg lf (show (0:ℤ) ≤ 7-(A-A₀) by omega)]
    constructor <;> omega
  have hB (t : Nat) : w t ≤ len true+len false := by
    change len (arc alpha gamma theta t) ≤ _
    cases arc alpha gamma theta t <;> omega
  have big : D ≤ total w q := by omega
  have env := envelope w (q := q) (m := total w q-D) (D := 2*D) hq hB
    (fun a => by have := (spread a).2; omega) (fun a => by have := (spread a).1; omega)
  refine ⟨q, total w q-D, total w q-D+2*D, _, hq, by omega, ?_, fun n => (env n).1, fun n => (env n).2⟩
  have e : total w q-D+2*D-(total w q-D) = 2*D := by omega
  rw [e, show 30*gear*(2*D) = 60*gear*D by ring]
  omega

/-- **Free phases.** Read an irrational rotation by `alpha` through an arc of length `gamma`, from any phase `theta`, and set two
nonempty blocks in the order of the answers. If neighbouring approximations of `alpha` from both sides, with arbitrarily large
denominators `q < Q`, have `Q/q` at least `7 + 8/gear`, then beside a column that alternates, in a row with a leftmost black
cell, the right neighbour does not read this on its white ticks, from any reading on. -/
theorem free_phase_excluded (alpha gamma theta : ℝ) (gammaPos : 0 < gamma) (gammaLt : gamma < 1)
    (len : Bool → Nat) (positive : ∀ b, 1 ≤ len b) (bits : Bool → Nat → Bool) {gear : Nat} (gearPos : 0 < gear)
    (approximations : ∀ N, ∃ (q Q : Nat) (p p' sign : ℤ),
      N ≤ q ∧ (7*gear+8)*q ≤ gear*Q ∧ p*(Q:ℤ)-p'*(q:ℤ)=sign ∧
      sign*sign=1 ∧ ((q:ℝ)*alpha-p)*((Q:ℝ)*alpha-p') < 0)
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start + t) i = decide (t%2=1))
    (reads : ∀ n y, y < len (arc alpha gamma theta n) →
      cutoff ≤ total (fun t => len (arc alpha gamma theta t)) n + y →
      evol x (start+2*(total (fun t => len (arc alpha gamma theta t)) n + y)) (i+1) =
        bits (arc alpha gamma theta n) y) : False := by
  obtain ⟨den,low,high,err,denPos,order,accurate,lower,upper⟩ :=
    envelopes (theta := theta) gammaPos gammaLt len positive gear (fun N => by
      obtain ⟨q,Q,p,p',sign,large,ratio,det,unit,opposite⟩ := approximations N
      refine ⟨q,Q,p,p',sign,large,?_,det,unit,opposite⟩
      apply Nat.le_of_mul_le_mul_left _ gearPos
      have : gear*q ≤ (7*gear+8)*q := Nat.mul_le_mul_right q (by omega)
      omega)
  exact free_phase_above_seven alpha gamma theta len positive bits gearPos denPos order accurate lower upper
    approximations x lo i leftBlack leftWhite start cutoff clock reads

/-! ### An instance: all digits seven -/

/-- The denominators of the convergents of `[0; 7, 7, 7, …]`, shifted by one. -/
def sevens : Nat → Nat
  | 0 => 0
  | 1 => 1
  | n+2 => 7*sevens (n+1) + sevens n

private theorem sevens_pos (n : Nat) : 1 ≤ sevens (n+1) := by
  induction n with
  | zero => exact le_refl _
  | succ n ih =>
    change 1 ≤ 7*sevens (n+1) + sevens n
    omega

private theorem sevens_mono (n : Nat) : sevens n ≤ sevens (n+1) := by
  cases n with
  | zero => exact Nat.zero_le _
  | succ n =>
    change sevens (n+1) ≤ 7*sevens (n+1) + sevens n
    omega

private theorem sevens_large (n : Nat) : n ≤ sevens (n+1) := by
  induction n with
  | zero => exact Nat.zero_le _
  | succ n ih =>
    have := sevens_pos n
    change n+1 ≤ 7*sevens (n+1) + sevens n
    omega

private theorem sevens_det (n : Nat) :
    (sevens n : ℤ)*sevens (n+2) - sevens (n+1)*sevens (n+1) = -(-1)^n := by
  induction n with
  | zero => simp [sevens]
  | succ n ih =>
    have e : (sevens (n+3) : ℤ) = 7*sevens (n+2) + sevens (n+1) := by simp [sevens]
    have e' : (sevens (n+2) : ℤ) = 7*sevens (n+1) + sevens n := by simp [sevens]
    rw [show n+1+2 = n+3 by omega, show n+1+1 = n+2 by omega, e, pow_succ]
    linear_combination (-1:ℤ)*ih + (sevens (n+2) : ℤ)*(-e')

private theorem sevens_error {alpha : ℝ} (h : alpha*alpha = 1-7*alpha) (n : Nat) :
    (sevens (n+2) : ℝ)*alpha - sevens (n+1) = -alpha*((sevens (n+1) : ℝ)*alpha - sevens n) := by
  induction n with
  | zero =>
    simp [sevens]
    linarith
  | succ n ih =>
    have e : (sevens (n+3) : ℝ) = 7*sevens (n+2) + sevens (n+1) := by simp [sevens]
    have e' : (sevens (n+2) : ℝ) = 7*sevens (n+1) + sevens n := by simp [sevens]
    rw [show n+1+2 = n+3 by omega, show n+1+1 = n+2 by omega, e]
    linear_combination (sevens (n+2) : ℝ)*h

/-- `free_phase_excluded` at the angle with all digits seven, `alpha = (√53 - 7)/2`: any arc, any phase, any two blocks. -/
theorem sevens_excluded (alpha gamma theta : ℝ) (alphaPos : 0 < alpha) (root : alpha*alpha = 1-7*alpha)
    (gammaPos : 0 < gamma) (gammaLt : gamma < 1)
    (len : Bool → Nat) (positive : ∀ b, 1 ≤ len b) (bits : Bool → Nat → Bool)
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start + t) i = decide (t%2=1))
    (reads : ∀ n y, y < len (arc alpha gamma theta n) →
      cutoff ≤ total (fun t => len (arc alpha gamma theta t)) n + y →
      evol x (start+2*(total (fun t => len (arc alpha gamma theta t)) n + y)) (i+1) =
        bits (arc alpha gamma theta n) y) : False := by
  have nonzero (n : Nat) : (sevens (n+1) : ℝ)*alpha - sevens n ≠ 0 := by
    induction n with
    | zero => simpa [sevens] using alphaPos.ne'
    | succ n ih =>
      rw [show n+1+1 = n+2 by omega, sevens_error root]
      exact mul_ne_zero (neg_ne_zero.mpr alphaPos.ne') ih
  refine free_phase_excluded alpha gamma theta gammaPos gammaLt len positive bits (gear := 64) (by decide)
    (fun N => ?_) x lo i leftBlack leftWhite start cutoff clock reads
  refine ⟨sevens (N+2), sevens (N+3), sevens (N+1), sevens (N+2), -(-1)^(N+1), ?_, ?_, sevens_det (N+1), ?_, ?_⟩
  · have := sevens_large (N+1)
    rw [show N+1+1 = N+2 by omega] at this
    omega
  · have e : sevens (N+3) = 7*sevens (N+2) + sevens (N+1) := rfl
    have e' : sevens (N+2) = 7*sevens (N+1) + sevens N := rfl
    have := sevens_mono N
    omega
  · rw [neg_mul_neg, ← mul_pow]
    norm_num
  · have h := nonzero (N+1)
    rw [show N+1+1 = N+2 by omega] at h
    have e := sevens_error root (N+1)
    rw [show N+1+2 = N+3 by omega, show N+1+1 = N+2 by omega] at e
    push_cast
    rw [e]
    have := mul_pos alphaPos (pow_pos (abs_pos.mpr h) 2)
    rw [sq_abs] at this
    nlinarith

end SeparatedArcCuts
