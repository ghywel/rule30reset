import WeightedRepeatTransfer
import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Algebra.Order.Floor.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.LinearCombination
import Mathlib.Tactic.Ring

/-! Two circle cuts and successive approximation vectors. The arithmetic
uses the unit determinant and opposite signed errors. The uniform length
envelope is kept as an explicit hypothesis for the physical theorem. -/

namespace SeparatedArcCuts
open Ruliology.CellularAutomata Rule30RotationBlocks WeightedRepeatTransfer
open Rule30Realization (evol)

/-- Earlier returns have error at least that of the first approximation.
The bound uses both neighbouring approximation vectors. -/
theorem error_below_next {alpha : ℝ} {p q p' q' m h sign : ℤ}
    (qPos : 0 < q) (qNextPos : 0 < q') (indexPos : 0 < m) (small : m < q')
    (det : p*q' - p'*q = sign) (unit : sign*sign = 1)
    (opposite : ((q : ℝ)*alpha-p)*((q' : ℝ)*alpha-p') < 0) :
    |(q : ℝ)*alpha-p| ≤ |(m : ℝ)*alpha-h| := by
  let u := sign*(q'*h-p'*m)
  let v := sign*(p*m-q*h)
  have coord₁ : q*u + q'*v = m := by
    dsimp [u,v]
    calc
      q * (sign * (q' * h - p' * m)) + q' * (sign * (p * m - q * h))
          = sign*m*(p*q'-p'*q) := by ring
      _ = m := by rw [det]; linear_combination m*unit
  have coord₂ : p*u + p'*v = h := by
    dsimp [u,v]
    calc
      p * (sign * (q' * h - p' * m)) + p' * (sign * (p * m - q * h))
          = sign*h*(p*q'-p'*q) := by ring
      _ = h := by rw [det]; linear_combination h*unit
  have err :
      (m : ℝ)*alpha-h = (u : ℝ)*((q : ℝ)*alpha-p)+(v : ℝ)*((q' : ℝ)*alpha-p') := by
    have hm : (q:ℝ)*u+(q':ℝ)*v = m := by exact_mod_cast coord₁
    have hh : (p:ℝ)*u+(p':ℝ)*v = h := by exact_mod_cast coord₂
    linear_combination (-alpha)*hm + hh
  have signs : (1 ≤ u ∧ v ≤ 0) ∨ (u ≤ -1 ∧ 1 ≤ v) := by
    by_cases hv : v ≤ 0
    · left
      refine ⟨?_,hv⟩
      by_contra hn
      have nonpos₁ := mul_nonpos_of_nonneg_of_nonpos qPos.le (show u ≤ 0 by omega)
      have nonpos₂ := mul_nonpos_of_nonneg_of_nonpos qNextPos.le hv
      omega
    · right
      refine ⟨?_,by omega⟩
      by_contra hn
      have nonneg := mul_nonneg qPos.le (show 0 ≤ u by omega)
      have ge := mul_le_mul_of_nonneg_left (show 1 ≤ v by omega) qNextPos.le
      omega
  rw [err]
  rcases signs with ⟨hu,hv⟩ | ⟨hu,hv⟩
  · have hu' : (1:ℝ) ≤ u := by exact_mod_cast hu
    have hv' : (v:ℝ) ≤ 0 := by exact_mod_cast hv
    rcases mul_neg_iff.mp opposite with ⟨he,hf⟩ | ⟨he,hf⟩
    · rw [abs_of_pos he]
      apply le_trans _ (le_abs_self _)
      nlinarith [mul_nonneg (sub_nonneg.mpr hu') he.le, mul_nonneg_of_nonpos_of_nonpos hv' hf.le]
    · rw [abs_of_neg he]
      apply le_trans _ (neg_le_abs _)
      nlinarith [mul_nonpos_of_nonneg_of_nonpos (sub_nonneg.mpr hu') he.le, mul_nonpos_of_nonpos_of_nonneg hv' hf.le]
  · have hu' : (u:ℝ) ≤ -1 := by exact_mod_cast hu
    have hv' : (0:ℝ) ≤ v := by exact_mod_cast (show 0 ≤ v by omega)
    rcases mul_neg_iff.mp opposite with ⟨he,hf⟩ | ⟨he,hf⟩
    · rw [abs_of_pos he]
      apply le_trans _ (neg_le_abs _)
      nlinarith [mul_nonpos_of_nonpos_of_nonneg (show (u:ℝ)+1 ≤ 0 by linarith) he.le, mul_nonpos_of_nonneg_of_nonpos hv' hf.le]
    · rw [abs_of_neg he]
      apply le_trans _ (le_abs_self _)
      nlinarith [mul_nonneg_of_nonpos_of_nonpos (show (u:ℝ)+1 ≤ 0 by linarith) he.le, mul_nonneg hv' hf.le]

/-- Floor changes with the same signed displacement give two lifts in the
same half-open interval of length equal to the magnitude of the displacement. -/
private theorem floor_break {e y : ℝ} (change : ⌊y+e⌋ ≠ ⌊y⌋) :
    ∃ z : ℤ, -(max e 0) ≤ y-z ∧ y-z < -(max e 0)+|e| := by
  by_cases he : 0 ≤ e
  · have lt : ⌊y⌋ < ⌊y+e⌋ := lt_of_le_of_ne (Int.floor_mono (by linarith)) (Ne.symm change)
    have zy := Int.floor_lt.mp lt
    refine ⟨⌊y+e⌋,?_,?_⟩ <;> rw [max_eq_left he]
    · linarith [Int.floor_le (y+e)]
    · rw [abs_of_nonneg he]
      linarith
  · have hn : e < 0 := lt_of_not_ge he
    have lt : ⌊y+e⌋ < ⌊y⌋ := lt_of_le_of_ne (Int.floor_mono (by linarith)) change
    have zy := Int.floor_lt.mp lt
    refine ⟨⌊y⌋,?_,?_⟩ <;> rw [max_eq_right hn.le]
    · linarith [Int.floor_le y]
    · rw [abs_of_neg hn]
      linarith

/-- The two floor differences code the half-open arc beginning at zero.
Subtracting the first endpoint from the phase permits any arc. -/
noncomputable def arc (alpha gamma theta : ℝ) (n : Nat) : Bool :=
  decide (⌊theta+(n:ℝ)*alpha⌋ - ⌊theta+(n:ℝ)*alpha-gamma⌋ = 1)

theorem arc_true_iff (alpha gamma theta : ℝ) (n : Nat)
    (gammaPos : 0 < gamma) (gammaLt : gamma < 1) :
    arc alpha gamma theta n = true ↔ Int.fract (theta+(n:ℝ)*alpha) < gamma := by
  let y := theta+(n:ℝ)*alpha
  change decide (⌊y⌋ - ⌊y-gamma⌋ = 1) = true ↔ Int.fract y < gamma
  rw [decide_eq_true_eq]
  have rewrite : y-gamma = (Int.fract y-gamma)+(⌊y⌋:ℝ) := by unfold Int.fract; ring
  rw [rewrite, Int.floor_add_intCast]
  have lower := Int.fract_nonneg y
  have upper := Int.fract_lt_one y
  by_cases h : Int.fract y < gamma
  · have floor : ⌊Int.fract y-gamma⌋ = -1 := by
      apply Int.floor_eq_iff.mpr
      norm_num
      constructor <;> linarith
    simp [floor,h]
  · have floor : ⌊Int.fract y-gamma⌋ = 0 := by
      apply Int.floor_eq_iff.mpr
      norm_num
      constructor <;> linarith
    simp [floor,h]

private noncomputable def firstCutStable (alpha theta : ℝ) (q : Nat) (p : ℤ) (n : Nat) : Bool :=
  decide (⌊theta+(n:ℝ)*alpha+((q:ℝ)*alpha-p)⌋ = ⌊theta+(n:ℝ)*alpha⌋)

private theorem labelled_floor_break (alpha gamma theta : ℝ) (q : Nat) (p : ℤ) (n : Nat)
    (diff : arc alpha gamma theta (n+q) ≠ arc alpha gamma theta n) :
    let y := theta+(n:ℝ)*alpha - (if firstCutStable alpha theta q p n then gamma else 0)
    ⌊y+((q:ℝ)*alpha-p)⌋ ≠ ⌊y⌋ := by
  let b := theta+(n:ℝ)*alpha
  let e := (q:ℝ)*alpha-p
  by_cases same : ⌊b+e⌋ = ⌊b⌋
  · have stable : firstCutStable alpha theta q p n = true := by simpa [firstCutStable,b,e] using same
    simp only [stable, ite_true]
    change ⌊b-gamma+e⌋ ≠ ⌊b-gamma⌋
    intro other
    apply diff
    have reduce : theta+((n+q:Nat):ℝ)*alpha = b+e+p := by push_cast; dsimp [b,e]; ring
    unfold arc
    rw [reduce, Int.floor_add_intCast, show b+e+p-gamma = (b-gamma+e)+p by ring,
      Int.floor_add_intCast,same,other]
    have cancel : (⌊b⌋+p)-(⌊b-gamma⌋+p) = ⌊b⌋-⌊b-gamma⌋ := by omega
    rw [cancel]
  · have unstable : firstCutStable alpha theta q p n = false := by
      simpa [firstCutStable,b,e] using same
    simpa [unstable,b,e] using same

/-- On a window shorter than the next denominator the two cuts supply at most
one mismatch each. This version isolates the complete geometric premise. -/
theorem separated_on_window (alpha gamma theta : ℝ) (q W : Nat) (p p' q' sign : ℤ)
    (qPos : 0 < q) (nextPos : 0 < q') (fits : (W:ℤ) ≤ q')
    (det : p*q' - p'*(q:ℤ) = sign) (unit : sign*sign = 1)
    (opposite : ((q:ℝ)*alpha-p)*((q':ℝ)*alpha-p') < 0) :
    ∃ lab : Nat → Bool, ∀ u v, u < v → v < W →
      arc alpha gamma theta (u+q) ≠ arc alpha gamma theta u →
      arc alpha gamma theta (v+q) ≠ arc alpha gamma theta v → lab u ≠ lab v := by
  let lab := firstCutStable alpha theta q p
  refine ⟨lab,fun u v huv hv d₁ d₂ same => ?_⟩
  obtain ⟨i,il,ih⟩ := floor_break (labelled_floor_break alpha gamma theta q p u d₁)
  obtain ⟨j,jl,jh⟩ := floor_break (labelled_floor_break alpha gamma theta q p v d₂)
  change firstCutStable alpha theta q p u = firstCutStable alpha theta q p v at same
  rw [← same] at jl jh
  have gap : |(((v-u:Nat):ℤ):ℝ)*alpha-((j-i:ℤ):ℝ)| < |(q:ℝ)*alpha-p| := by
    push_cast
    rw [Nat.cast_sub (Nat.le_of_lt huv)]
    exact abs_lt.mpr ⟨by linarith only [il,ih,jl,jh], by linarith only [il,ih,jl,jh]⟩
  exact (not_lt_of_ge (error_below_next (by exact_mod_cast qPos) nextPos
    (show (0:ℤ) < ((v-u:Nat):ℤ) by omega)
    (show ((v-u:Nat):ℤ) < q' by omega) det unit (by exact_mod_cast opposite))) gap

/-- A finite-left clock cannot read the variable-length arc coding if
arbitrarily late approximation pairs leave room for the weighted window.
The real continued-fraction and frequency hypotheses imply this criterion. -/
theorem free_phase_blocks_excluded (alpha gamma theta : ℝ)
    (len : Bool → Nat) (positive : ∀ b, 1 ≤ len b) (bits : Bool → Nat → Bool)
    {den low high err : Nat} (denPos : 0 < den) (slopeOrder : low ≤ high)
    (lower : ∀ n, low*n ≤ den*total (fun t => len (arc alpha gamma theta t)) n + err)
    (upper : ∀ n, den*total (fun t => len (arc alpha gamma theta t)) n ≤ high*n + err)
    (windows : ∀ H N, ∃ (q extra : Nat) (p p' Q sign : ℤ),
      0 < q ∧ N ≤ q ∧ (↑(8*H + 7*(q+extra)) : ℤ) ≤ Q ∧
      p*Q - p'*(q:ℤ) = sign ∧ sign*sign = 1 ∧
      ((q:ℝ)*alpha-p)*((Q:ℝ)*alpha-p') < 0 ∧
      (high-low)*(8*H + 7*(q+extra)) ≤ low*extra)
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start + t) i = decide (t%2=1))
    (reads : ∀ n y, y < len (arc alpha gamma theta n) →
      cutoff ≤ total (fun t => len (arc alpha gamma theta t)) n + y →
      evol x (start+2*(total (fun t => len (arc alpha gamma theta t)) n + y)) (i+1) =
        bits (arc alpha gamma theta n) y) : False := by
  refine no_clock_of_two_cut_windows (arc alpha gamma theta) len positive bits
    denPos slopeOrder lower upper ?_ x lo i leftBlack leftWhite start cutoff clock reads
  intro H N
  obtain ⟨q,extra,p,p',Q,sign,qp,ql,fit,det,hunit,opp,gain⟩ := windows H N
  exact ⟨q,extra,qp,ql,separated_on_window alpha gamma theta q _ p p' Q sign
    qp (by omega) fit det hunit opp,gain⟩

/-- A fixed ratio margin above seven supplies every late weighted window.
The two rational envelopes may be chosen as close as needed to a positive mean. -/
theorem free_phase_above_seven (alpha gamma theta : ℝ)
    (len : Bool → Nat) (positive : ∀ b, 1 ≤ len b) (bits : Bool → Nat → Bool)
    {gear den low high err : Nat} (gearPos : 0 < gear) (denPos : 0 < den) (slopeOrder : low ≤ high)
    (accurate : 30*gear*(high-low) ≤ low)
    (lower : ∀ n, low*n ≤ den*total (fun t => len (arc alpha gamma theta t)) n + err)
    (upper : ∀ n, den*total (fun t => len (arc alpha gamma theta t)) n ≤ high*n + err)
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
  refine free_phase_blocks_excluded alpha gamma theta len positive bits denPos slopeOrder
    lower upper ?_ x lo i leftBlack leftWhite start cutoff clock reads
  intro H N
  obtain ⟨q,Q,p,p',sign,large,ratio,det,hunit,opp⟩ :=
    approximations (N + 8*gear*H + 2*gear)
  let extra := q/gear
  let W := 8*H+7*(q+extra)
  have side : 8*gear*H ≤ q := by omega
  have enough : 2*gear ≤ q := by omega
  have extraPos : 1 ≤ extra := Nat.div_pos (by omega) gearPos
  have belowQ : gear*extra ≤ q := Nat.mul_div_le q gear
  have aboveQ : q ≤ 2*gear*extra := by
    have decompose : gear*extra + q%gear = q := Nat.div_add_mod q gear
    have rem := Nat.mod_lt q gearPos
    have atLeast := Nat.mul_le_mul_left gear extraPos
    calc
      q ≤ gear*extra + gear*extra := by omega
      _ = 2*gear*extra := by ring
  have fit : W ≤ Q := by
    apply Nat.le_of_mul_le_mul_left _ gearPos
    calc
      gear*W = 8*gear*H + 7*gear*q + 7*(gear*extra) := by dsimp [W]; ring
      _ ≤ (7*gear+8)*q := by rw [Nat.add_mul]; omega
      _ ≤ gear*Q := ratio
  have startBound : 8*H ≤ q := by
    have enough := Nat.mul_le_mul_right (8*H) (show 1 ≤ gear by omega)
    have assoc : gear*(8*H) = 8*gear*H := by ring
    simpa [assoc] using Nat.le_trans enough (show gear*(8*H) ≤ q by rwa [assoc])
  have endBound : W ≤ 15*q := by
    have e := Nat.div_le_self q gear
    change extra ≤ q at e
    dsimp [W]
    omega
  have gain : (high-low)*W ≤ low*extra := calc
    (high-low)*W ≤ (high-low)*(15*q) := Nat.mul_le_mul_left _ endBound
    _ ≤ (high-low)*(15*(2*gear*extra)) :=
      Nat.mul_le_mul_left _ (Nat.mul_le_mul_left 15 aboveQ)
    _ = (30*gear*(high-low))*extra := by ring
    _ ≤ low*extra := Nat.mul_le_mul_right _ accurate
  refine ⟨q,extra,p,p',(Q:ℤ),sign,by omega,by omega,?_,det,hunit,opp,gain⟩
  exact_mod_cast fit

end SeparatedArcCuts
