import FreePhaseFrequency
import JenBlockWindow

/-! A repeated cut is separated from the previous crossing of that cut. Measuring the
span between failed trials gives a sufficient denominator ratio strictly above six. -/

namespace RelativeCutSpan
open Ruliology.CellularAutomata Rule30RotationBlocks WeightedRepeatTransfer SeparatedArcCuts
open Rule30Realization (evol)

/-- If three lag-q failures occur, their span is at most six times the
initial cutoff plus six times the requested lag and surplus. -/
theorem repeat_of_span {α : Type} (c : Nat → α) (H q extra : Nat)
    (separated : ∀ u v z, u < v → v < z → z-u ≤ 6*(H+q+extra) →
      c (u+q) ≠ c u → c (v+q) ≠ c v → c (z+q) ≠ c z → False) :
    ∃ a, H ≤ a ∧ 2*a+q+extra ≤ 8*H+7*(q+extra) ∧
      ∀ s, s < a+q+extra → c (a+s) = c (a+q+s) := by
  classical
  apply Classical.byContradiction
  intro noRepeat
  have bad (a : Nat) (ha : H ≤ a) (endFits : 2*a+q+extra ≤ 8*H+7*(q+extra)) :
      ∃ t, a ≤ t ∧ t < 2*a+q+extra ∧ c (t+q) ≠ c t := by
    by_contra noBreak
    apply noRepeat
    refine ⟨a,ha,endFits,fun s hs => ?_⟩
    by_contra different
    apply noBreak
    exact ⟨a+s,by omega,by omega,fun h => different (by simpa [Nat.add_right_comm] using h.symm)⟩
  obtain ⟨u,hu,eu,du⟩ := bad H (by omega) (by omega)
  obtain ⟨v,hv,ev,dv⟩ := bad (u+1) (by omega) (by omega)
  obtain ⟨z,hz,ez,dz⟩ := bad (v+1) (by omega) (by omega)
  exact separated u v z (by omega) (by omega) (by omega) du dv dz

private theorem arc_shift (alpha gamma theta : ℝ) (u k : Nat) :
    arc alpha gamma (theta+(u:ℝ)*alpha) k = arc alpha gamma theta (u+k) := by
  unfold arc
  rw [Nat.cast_add, add_mul]
  simp only [add_assoc]

/-- Move the origin to the first failed trial before applying the existing
two-cut lemma. The absolute time of the third failure may exceed Q. -/
theorem three_failures (alpha gamma theta : ℝ) (q Q : Nat) (p p' sign : ℤ)
    (hq : 0 < q) (hQ : 0 < Q) (det : p*Q-p'*(q:ℤ) = sign) (unit : sign*sign=1)
    (opposite : ((q:ℝ)*alpha-p)*((Q:ℝ)*alpha-p') < 0)
    (u v z : Nat) (uv : u < v) (vz : v < z) (short : z-u < Q)
    (du : arc alpha gamma theta (u+q) ≠ arc alpha gamma theta u)
    (dv : arc alpha gamma theta (v+q) ≠ arc alpha gamma theta v)
    (dz : arc alpha gamma theta (z+q) ≠ arc alpha gamma theta z) : False := by
  let phase := theta+(u:ℝ)*alpha
  obtain ⟨lab,isolated⟩ := separated_on_window alpha gamma phase q Q p p' Q sign hq
    (by exact_mod_cast hQ) (by rfl) det unit (by exact_mod_cast opposite)
  have moved (a : Nat) (h : u ≤ a)
      (diff : arc alpha gamma theta (a+q) ≠ arc alpha gamma theta a) :
      arc alpha gamma phase ((a-u)+q) ≠ arc alpha gamma phase (a-u) := by
    dsimp [phase]
    rw [arc_shift,arc_shift,show u+(a-u+q)=a+q by omega,show u+(a-u)=a by omega]
    exact diff
  have d0 := moved u (by omega) du
  have d1 := moved v (by omega) dv
  have d2 := moved z (by omega) dz
  have h01 := isolated (u-u) (v-u) (by omega) (by omega) d0 d1
  have h02 := isolated (u-u) (z-u) (by omega) short d0 d2
  have h12 := isolated (v-u) (z-u) (by omega) short d1 d2
  generalize lab (u-u) = b₀ at h01 h02
  generalize lab (v-u) = b₁ at h01 h12
  generalize lab (z-u) = b₂ at h02 h12
  cases b₀ <;> cases b₁ <;> cases b₂ <;> contradiction

/-- Every arc and every phase, with arbitrary nonempty replacement blocks.
The approximation hypothesis asks for a fixed margin over a ratio of six. -/
theorem above_six (alpha gamma theta : ℝ) (gammaPos : 0 < gamma) (gammaLt : gamma < 1)
    (len : Bool → Nat) (positive : ∀ b, 1 ≤ len b) (bits : Bool → Nat → Bool)
    {gear : Nat} (gearPos : 0 < gear)
    (approximations : ∀ N, ∃ (q Q : Nat) (p p' sign : ℤ),
      N ≤ q ∧ (6*gear+16)*q ≤ gear*Q ∧ p*(Q:ℤ)-p'*(q:ℤ)=sign ∧
      sign*sign=1 ∧ ((q:ℝ)*alpha-p)*((Q:ℝ)*alpha-p') < 0)
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start+t) i = decide (t%2=1))
    (reads : ∀ n y, y < len (arc alpha gamma theta n) →
      cutoff ≤ total (fun t => len (arc alpha gamma theta t)) n + y →
      evol x (start+2*(total (fun t => len (arc alpha gamma theta t)) n+y)) (i+1) =
        bits (arc alpha gamma theta n) y) : False := by
  let c := arc alpha gamma theta
  let w := fun t => len (c t)
  obtain ⟨den,low,high,err,denPos,order,accurate,lower,upper⟩ :=
    envelopes (theta := theta) gammaPos gammaLt len positive (2*gear) (fun N => by
      obtain ⟨q,Q,p,p',sign,large,ratio,det,unit,opposite⟩ := approximations N
      refine ⟨q,Q,p,p',sign,large,?_,det,unit,opposite⟩
      apply Nat.le_of_mul_le_mul_left _ gearPos
      have := Nat.mul_le_mul_right q (show gear ≤ 6*gear+16 by omega)
      omega)
  apply JenBlockWindow.excludes_blocks c len positive bits ?_ x lo i leftBlack leftWhite start cutoff clock reads
  intro H N
  obtain ⟨q,Q,p,p',sign,large,ratio,det,unit,opp⟩ := approximations (N+8*gear*H+2*gear+gear*(N+3*err))
  let extra := q/gear
  have side : 8*gear*H ≤ q := by omega
  have extraPos : 1 ≤ extra := Nat.div_pos (by omega) gearPos
  have below : gear*extra ≤ q := Nat.mul_div_le q gear
  have above : q ≤ 2*gear*extra := by
    have decompose : gear*extra + q%gear = q := Nat.div_add_mod q gear
    have rem := Nat.mod_lt q gearPos
    have atLeast := Nat.mul_le_mul_left gear extraPos
    calc
      q ≤ gear*extra + gear*extra := by omega
      _ = 2*gear*extra := by ring
  have span : 6*(H+q+2*extra) < Q := by
    apply Nat.lt_of_mul_lt_mul_left (a := gear)
    calc
      gear*(6*(H+q+2*extra)) = 6*(gear*H)+6*(gear*q)+12*(gear*extra) := by ring
      _ < (6*gear+16)*q := by
        rw [Nat.add_mul, Nat.mul_assoc 6 gear q]
        rw [Nat.mul_assoc 8 gear H] at side
        omega
      _ ≤ gear*Q := ratio
  obtain ⟨a,late,finish,agree⟩ := repeat_of_span c H q (2*extra) (fun u v z uv vz short =>
    three_failures alpha gamma theta q Q p p' sign (by omega) (by omega) det unit opp u v z uv vz (by omega))
  refine ⟨a,a+q,a+q+2*extra,late,by omega,by omega,agree,?_⟩
  have startBound : 8*H ≤ q := by
    have mult := Nat.mul_le_mul_right (8*H) (show 1 ≤ gear by omega)
    have e : gear*(8*H) = 8*gear*H := by ring
    omega
  have endBound : a+(a+q) ≤ 22*q := by
    have e : extra ≤ q := Nat.div_le_self q gear
    omega
  have gain : (high-low)*(a+(a+q)) ≤ low*extra := calc
    _ ≤ (high-low)*(22*q) := Nat.mul_le_mul_left _ endBound
    _ ≤ (high-low)*(22*(2*gear*extra)) := Nat.mul_le_mul_left _ (Nat.mul_le_mul_left _ above)
    _ = (44*gear*(high-low))*extra := by ring
    _ ≤ low*extra := Nat.mul_le_mul_right _ (by
      rw [show 30*(2*gear)=60*gear by ring] at accurate
      exact le_trans (Nat.mul_le_mul_right _ (by omega)) accurate)
  have margin : high*(a+(a+q)) ≤ low*(a+(a+q+extra)) := by
    rw [show a+(a+q+extra) = (a+(a+q))+extra by omega, Nat.mul_add low]
    calc
      high*(a+(a+q)) = (high-low)*(a+(a+q))+low*(a+(a+q)) := by
        rw [← Nat.add_mul,Nat.sub_add_cancel order]
      _ ≤ _ := by omega
  have slack := slack_of_envelopes w denPos lower upper margin
  have reserve : N+3*err ≤ extra := (Nat.le_div_iff_mul_le gearPos).mpr (by
    rw [Nat.mul_comm]; omega)
  have more := le_total w (fun t => positive (c t)) (a+(a+q+extra)) extra
  rw [show a+(a+q+extra)+extra = a+(a+q+2*extra) by omega] at more
  change total w a+total w (a+q)+N ≤ total w (a+(a+q+2*extra))
  omega

/-- Consecutive approximants of the root of a² + 6a = 1. -/
private theorem six_pairs (N : Nat) :
    ∃ p q : Nat, N ≤ q ∧ 0 < p ∧ p ≤ q ∧ q ≤ 7*p ∧
      (((p:ℤ)*(6*q+p)-(q:ℤ)*q)^2 = 1) := by
  induction N with
  | zero => exact ⟨1,6,by decide,by decide,by decide,by decide,by decide⟩
  | succ N ih =>
    obtain ⟨p,q,large,pos,order,upper,unit⟩ := ih
    refine ⟨q,6*q+p,by omega,by omega,by omega,by omega,?_⟩
    push_cast
    rw [show (q:ℤ)*(6*(6*q+p)+q)-(6*q+p)*(6*q+p) =
      -((p:ℤ)*(6*q+p)-q*q) by ring, neg_sq]
    exact unit

/-- At the bounded-type angle [0; 6, 6, …], every phase, arc and pair
of nonempty blocks is excluded. -/
theorem sixes_excluded (alpha gamma theta : ℝ) (pos : 0 < alpha)
    (root : alpha*alpha = 1-6*alpha) (gammaPos : 0 < gamma) (gammaLt : gamma < 1)
    (len : Bool → Nat) (positive : ∀ b, 1 ≤ len b) (bits : Bool → Nat → Bool)
    (x : Int → Bool) (lo i : Int) (leftBlack : x lo = true)
    (leftWhite : ∀ j < lo, x j = false) (start cutoff : Nat)
    (clock : ∀ t, evol x (start+t) i = decide (t%2=1))
    (reads : ∀ n y, y < len (arc alpha gamma theta n) →
      cutoff ≤ total (fun t => len (arc alpha gamma theta t)) n + y →
      evol x (start+2*(total (fun t => len (arc alpha gamma theta t)) n+y)) (i+1) =
        bits (arc alpha gamma theta n) y) : False := by
  apply above_six alpha gamma theta gammaPos gammaLt len positive bits (gear := 128) (by decide)
    _ x lo i leftBlack leftWhite start cutoff clock reads
  intro N
  obtain ⟨p,q,large,hp,order,upper,unit⟩ := six_pairs N
  let s : ℤ := p*(6*(q:ℤ)+p)-(q:ℤ)*q
  refine ⟨q,6*q+p,p,q,s,large,by omega,by push_cast; rfl,?_,?_⟩
  · simpa [s,pow_two] using unit
  · have nonzero : (q:ℝ)*alpha-p ≠ 0 := by
      intro zero
      have vanished : (p:ℝ)*(6*q+p)-q*q=0 := by
        rw [show (p:ℝ) = q*alpha by linarith]
        linear_combination (q:ℝ)^2 * root
      have castUnit : ((p:ℝ)*(6*q+p)-(q:ℝ)*q)^2=1 := by exact_mod_cast unit
      rw [vanished] at castUnit
      norm_num at castUnit
    push_cast
    have e : (6*(q:ℝ)+p)*alpha-q = -alpha*(q*alpha-p) := by
      linear_combination (q:ℝ)*root
    rw [e]
    nlinarith [mul_pos pos (sq_pos_of_ne_zero nonzero)]

end RelativeCutSpan
