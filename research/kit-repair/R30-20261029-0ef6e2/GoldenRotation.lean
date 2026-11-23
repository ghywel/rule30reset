import GoldenStripCover
import Mathlib.Tactic.LinearCombination
import Mathlib.Tactic.Push
import Ruliology.CellularAutomata.Rule30FiniteMaskedJen

/-! Golden half-circle repetitions and the Rule 30 right neighbour. The proof
uses the six-family cover, exact integer changes of lattice coordinates, and
the window version of Jen's theorem already present at the portal pin. -/
namespace GoldenRotation

open GoldenStripCover
private noncomputable abbrev d : ℝ := Real.sqrt 5
private theorem dsq : d^2 = 5 := Real.sq_sqrt (by norm_num)
private theorem dbounds : 2 < d ∧ d < 5/2 := by
  have hn := Real.sqrt_nonneg (5:ℝ)
  dsimp [d] at *
  constructor <;> nlinarith [dsq, sq_nonneg (Real.sqrt 5 - 2), sq_nonneg (Real.sqrt 5 - 5/2)]

private structure UnitScale where
  A : ℤ
  B : ℤ
  norm : A*A - 5*B*B = 1
  Apos : 0 < A
  Bnonneg : 0 ≤ B

/-- Coefficients of (9 + 4√5)^n. The conjugate shrinks the crossing strip. -/
private def unitAt : ℕ → UnitScale
  | 0 => ⟨1,0,by decide,by decide,by decide⟩
  | n+1 =>
    let u := unitAt n
    ⟨9*u.A+20*u.B, 4*u.A+9*u.B, by nlinarith [u.norm],
      by linarith [u.Apos,u.Bnonneg], by linarith [u.Apos,u.Bnonneg]⟩

private theorem large (n : ℕ) : (n:ℤ)+1 ≤ (unitAt n).A := by
  induction n with
  | zero => decide
  | succ n ih =>
    change (_:ℤ) ≤ 9*(unitAt n).A + 20*(unitAt n).B
    push_cast
    linarith [(unitAt n).Bnonneg,(unitAt n).Apos]

private noncomputable def expand (u : UnitScale) : ℝ := u.A + u.B * d
private noncomputable def shrink (u : UnitScale) : ℝ := u.A - u.B * d

private theorem unit_prod (u : UnitScale) : expand u * shrink u = 1 := by
  have hn : (u.A:ℝ)*u.A - 5*u.B*u.B = 1 := by exact_mod_cast u.norm
  unfold expand shrink
  linear_combination hn - (u.B:ℝ)^2 * dsq

private theorem scale_bounds (u : UnitScale) (hu : 1000 ≤ u.A) :
    0 < shrink u ∧ shrink u ≤ 1/1000 := by
  have hA : (1000:ℝ) ≤ u.A := by exact_mod_cast hu
  have hB : (0:ℝ) ≤ u.B := by exact_mod_cast u.Bnonneg
  have hw : 1000 ≤ expand u := by unfold expand; linarith [mul_nonneg hB (by linarith [dbounds.1] : 0 ≤ d)]
  have hp := unit_prod u
  have hv : 0 < shrink u := by by_contra! h; nlinarith [mul_nonpos_of_nonneg_of_nonpos (show 0 ≤ expand u by linarith) h]
  exact ⟨hv, by nlinarith [mul_nonneg (show 0 ≤ expand u-1000 by linarith) hv.le]⟩

private def plus (p r : Point) : Point := ⟨p.a+r.a,p.b+r.b⟩
private def minus (p r : Point) : Point := ⟨p.a-r.a,p.b-r.b⟩
private def back (u : UnitScale) (p : Point) : Point :=
  ⟨u.A*p.a-5*u.B*p.b, u.A*p.b-u.B*p.a⟩
private def fwd (u : UnitScale) (p : Point) : Point :=
  ⟨u.A*p.a+5*u.B*p.b, u.A*p.b+u.B*p.a⟩

private theorem back_fwd (u : UnitScale) (p o : Point) :
    back u (plus o (minus (fwd u p) o)) = p := by
  cases p with | mk a b =>
   simp only [back,plus,minus,fwd,Point.mk.injEq]
   constructor <;> first
    | linear_combination a * u.norm
    | linear_combination b * u.norm

private theorem val_back (u : UnitScale) (p : Point) :
    val (back u p) d = shrink u * val p d := by
  simp [val,back,shrink]
  linear_combination (u.B:ℝ)*p.b*dsq

private structure Config (u : UnitScale) (θ : ℝ) where
  o : Point
  s : ℝ
  z : ℝ
  hs : s = expand u * θ + val o d
  hz : z = -shrink u * θ + val (phys o) d
  sb : 0 ≤ s ∧ s < 1
  zb : -1 < z ∧ z ≤ 5

/-- Choose an integer lattice translate with reduced internal coordinate in [0,1). -/
private noncomputable def config (u : UnitScale) (θ : ℝ) : Config u θ := by
  let y : ℝ := (u.B:ℝ)*θ
  let b : ℤ := -⌊y⌋
  let k : ℝ := expand u * θ + (b:ℝ)*d
  let a : ℤ := -⌊k⌋
  let s := k + (a:ℝ)
  let z := -shrink u * θ + val (phys ⟨a,b⟩) d
  have sy : 0 ≤ y+(b:ℝ) ∧ y+(b:ℝ) < 1 := by
    dsimp [b]; push_cast; constructor <;> linarith [Int.floor_le y,Int.lt_floor_add_one y]
  have sb : 0 ≤ s ∧ s < 1 := by
    dsimp [s,a]; push_cast; constructor <;> linarith [Int.floor_le k,Int.lt_floor_add_one k]
  have hsum : s + z = 2*d*(y+(b:ℝ)) := by
    dsimp [z,s,k,y,expand,shrink,phys,val]; push_cast; ring
  refine ⟨⟨a,b⟩,s,z,?_,rfl,sb,?_⟩
  · dsimp [s,k,val]; ring
  · constructor <;> nlinarith [mul_nonneg (le_trans (by norm_num) dbounds.1.le) sy.1,
      mul_nonneg (show 0 ≤ d by linarith [dbounds.1]) (show 0 ≤ 1-(y+b) by linarith [sy.2]),dbounds.2,sb.1,sb.2]

private def tick {u θ} (c : Config u θ) (p : Point) := (back u (plus c.o p)).b

private theorem lattice_internal {u θ} (c : Config u θ) (p : Point) :
    shrink u * (c.s + val p d) = θ + val (back u (plus c.o p)) d := by
  rw [c.hs,val_back]
  have hh := unit_prod u
  simp only [plus,val,Int.cast_add]
  linear_combination θ * hh

private theorem lattice_time {u θ} (c : Config u θ) (p : Point) :
    (2*d*shrink u)*(tick c p:ℝ) = c.z + val (phys p) d + shrink u^2*(c.s + val p d) := by
  let k := plus c.o p
  have hback : val (phys (back u k)) d = expand u * val (phys k) d := by
    simp [back,val,phys,expand]
    linear_combination -(u.B:ℝ)*k.b*dsq
  have htime : 2*d*(tick c p:ℝ) = val (back u k) d + val (phys (back u k)) d := by
    simp [tick,val,phys,k]; ring
  have hsum : val (phys k) d = val (phys c.o) d + val (phys p) d := by
    simp [k,plus,phys,val]; ring
  have hint := lattice_internal c p
  change shrink u * (c.s + val p d) = θ + val (back u k) d at hint
  rw [show 2*d*shrink u*(tick c p:ℝ) = shrink u*(2*d*(tick c p:ℝ)) by ring, htime,hback,hsum,c.hz]
  linear_combination (val (phys c.o) d + val (phys p) d) * unit_prod u - shrink u * hint

private theorem lag_time (u : UnitScale) (e : Point) :
    (2*d*shrink u)*((back u e).b:ℝ) = val (phys e) d + shrink u^2 * val e d := by
  have hphys : val (phys (back u e)) d = expand u * val (phys e) d := by
    simp [back,val,phys,expand]
    linear_combination -(u.B:ℝ)*e.b*dsq
  have ht : 2*d*((back u e).b:ℝ) = val (back u e) d + val (phys (back u e)) d := by
    simp [val,phys]; ring
  rw [show 2*d*shrink u*((back u e).b:ℝ) = shrink u*(2*d*((back u e).b:ℝ)) by ring,ht,hphys,val_back]
  linear_combination val (phys e) d * unit_prod u

private theorem member_data {e : Point} (he : e ∈ families) :
    -1 < val e d ∧ val e d < 1 ∧ 1 ≤ val (phys e) d ∧
      e.a ≤ 0 ∧ 1 ≤ e.b ∧ (e.a+e.b)%2 = 0 := by
  have hh : 2236067 ≤ 1000000*d ∧ 1000000*d ≤ 2236069 := by
    constructor <;> nlinarith [dsq,dbounds.1,sq_nonneg (d-2236067/1000000),sq_nonneg (d-2236069/1000000)]
  simp [families] at he
  rcases he with rfl | rfl | rfl | rfl | rfl | rfl <;>
    norm_num [val,phys] <;> refine ⟨?_,?_,?_⟩ <;> linarith [hh.1,hh.2]

private theorem strip_facts {e : Point} (he : e ∈ families) :
    -1 ≤ min 0 (-val e d) ∧ max 0 (-val e d) ≤ 1 ∧
    max 0 (-val e d) - min 0 (-val e d) < 1 := by
  have h := member_data he
  rcases le_total 0 (-val e d) with h₁ | h₁
  · rw [min_eq_left h₁,max_eq_right h₁]; refine ⟨?_,?_,?_⟩ <;> linarith [h.1,h.2.1]
  · rw [min_eq_right h₁,max_eq_left h₁]; refine ⟨?_,?_,?_⟩ <;> linarith [h.1,h.2.1]

/-- Signed times and lattice heights have the same strict order inside one strip. -/
private theorem height_lt {u θ} (c : Config u θ) (hu : 1000 ≤ u.A) {e p r : Point}
    (he : e ∈ families) (hp : crosses e c.s d p) (hr : crosses e c.s d r)
    (ht : tick c p < tick c r) : p.b < r.b := by
  have sf := strip_facts he
  have hd := scale_bounds u hu
  have hsq : shrink u^2 ≤ 1 := by nlinarith [mul_self_le_mul_self hd.1.le hd.2]
  have df₁ : -1 < val r d - val p d := by linarith [hp.2,hr.1,sf.2.2]
  have df₂ : val r d - val p d < 1 := by linarith [hp.1,hr.2,sf.2.2]
  have ht' : (tick c p:ℝ) < tick c r := by exact_mod_cast ht
  have hgt := mul_lt_mul_of_pos_left ht' (show 0 < 2*d*shrink u by nlinarith [mul_pos (show 0 < d by linarith [dbounds.1]) hd.1])
  rw [lattice_time,lattice_time] at hgt
  by_contra! h
  rcases eq_or_lt_of_le h with h | h
  · have hab : (-1:ℤ) < r.a-p.a ∧ r.a-p.a < 1 := by
      simp only [val,h] at df₁ df₂
      exact_mod_cast (show (-1:ℝ) < (r.a:ℝ)-p.a ∧ (r.a:ℝ)-p.a < 1 by constructor <;> linarith)
    have hae : r.a = p.a := by omega
    have eqp : r = p := by cases p; cases r; simp_all
    simp [eqp] at ht
  · have hb : (r.b:ℝ)+1 ≤ p.b := by exact_mod_cast (show r.b+1 ≤ p.b by omega)
    have hphys (v : Point) : val (phys v) d = 2*d*v.b-val v d := by simp [val,phys]; ring
    rw [hphys,hphys] at hgt
    have hh := mul_nonneg (show 0 ≤ 1-shrink u^2 by linarith) (show 0 ≤ 1+val r d-val p d by linarith)
    have hb' := mul_nonneg (show 0 ≤ d by linarith [dbounds.1]) (show 0 ≤ (p.b:ℝ)-r.b-1 by linarith)
    nlinarith [sq_nonneg (shrink u),dbounds.1]

private theorem floor_stays (y ε : ℝ)
    (avoid : ∀ m : ℤ, ¬(min 0 (-ε) ≤ y-m ∧ y-m < max 0 (-ε))) : ⌊y+ε⌋ = ⌊y⌋ := by
  by_contra h
  rcases lt_or_gt_of_ne h with h | h
  · have hh : y+ε < (⌊y⌋:ℝ) := (Int.floor_lt).mp h
    apply avoid ⌊y⌋
    constructor
    · linarith [min_le_left (0:ℝ) (-ε), Int.floor_le y]
    · linarith [le_max_right (0:ℝ) (-ε)]
  · have hh : ((⌊y⌋+1:ℤ):ℝ) ≤ y+ε := (Int.le_floor).mp (show ⌊y⌋+1 ≤ ⌊y+ε⌋ by omega)
    apply avoid (⌊y⌋+1)
    push_cast at hh ⊢
    constructor
    · linarith [min_le_right (0:ℝ) (-ε)]
    · linarith [le_max_left (0:ℝ) (-ε), Int.lt_floor_add_one y]

/-- The golden half-circle coding at an arbitrary real intercept. -/
noncomputable def word (θ : ℝ) (t : ℕ) : Bool := decide (⌊θ+(t:ℝ)*(d-1)⌋ % 2 = 1)

/-- An intervening floor change would lift to a crossing strictly between the witnesses. -/
private theorem copied {u θ} (c : Config u θ) (hu : 1000 ≤ u.A) {e p r : Point}
    (he : e ∈ families) (gap : consecutive e p r c.s d) (t q : ℕ) (hq : (q:ℤ) = (back u e).b)
    (hp : tick c p < t) (hr : (t:ℤ) < tick c r) : word θ t = word θ (t+q) := by
  let y := θ+(t:ℝ)*(d-1)
  let ε := shrink u * val e d
  have hv := (scale_bounds u hu).1
  have stable : ⌊y+ε⌋ = ⌊y⌋ := by
    apply floor_stays
    intro m hit
    let base : Point := ⟨-(t:ℤ)-m,t⟩
    let v := minus (fwd u base) c.o
    have hback : back u (plus c.o v) = base := back_fwd u base c.o
    have hh := lattice_internal c v
    rw [hback] at hh
    have hw : shrink u*(c.s + val v d) = y-m := by
      dsimp only [base,val] at hh
      push_cast at hh
      dsimp [y,val]; linarith
    have hb : -ε = shrink u * (-val e d) := by dsimp [ε]; ring
    have hlo : min 0 (-ε) = shrink u * min 0 (-val e d) := by
      rw [hb,mul_min_of_nonneg _ _ hv.le, mul_zero]
    have hhi : max 0 (-ε) = shrink u * max 0 (-val e d) := by
      rw [hb,mul_max_of_nonneg _ _ hv.le, mul_zero]
    rw [hlo,hhi,←hw] at hit
    have hc : crosses e c.s d v := ⟨le_of_mul_le_mul_left hit.1 hv,lt_of_mul_lt_mul_left hit.2 hv.le⟩
    have ht : tick c v = t := by change (back u (plus c.o v)).b = t; rw [hback]
    exact gap.2.2.2 v (height_lt c hu he gap.2.1 hc (by omega))
      (height_lt c hu he hc gap.2.2.1 (by omega)) hc
  let k := -(back u e).a-(back u e).b
  have hk : k % 2 = 0 := by
    have eqk : k = -(u.A-u.B)*(e.a+e.b) + 2*(2*u.B*e.b) := by dsimp [k,back]; ring
    rw [eqk,Int.add_emod,Int.mul_emod _ (e.a+e.b), (member_data he).2.2.2.2.2]
    simp
  have eqr : (q:ℝ) = (back u e).b := by exact_mod_cast hq
  have hy : θ+((t+q:ℕ):ℝ)*(d-1) = (y+ε)+(k:ℝ) := by
    have hb := val_back u e
    dsimp [k,y,ε]; push_cast; rw [eqr]
    simp only [val] at hb ⊢
    linarith
  unfold word
  rw [hy,Int.floor_add_intCast,stable,Int.add_emod,hk]
  simp [y]

private theorem scaled_bound {h Q X Y A B E : ℝ}
    (hh : 0 ≤ h ∧ h ≤ 1/1000000) (hq : 1 ≤ Q)
    (ha : -1 ≤ A ∧ A ≤ 1) (hb : -1 ≤ B ∧ B ≤ 1) (he : -1 ≤ E ∧ E ≤ 1)
    (hx : 11*Q ≤ 10*Y) (hy : 11*Q ≤ 10*(Y-2*X)) :
    10999*(Q+h*E) ≤ 10000*(Y+h*B) ∧
    10999*(Q+h*E) ≤ 10000*((Y+h*B)-2*(X+h*A)) := by
  have e₁ := mul_le_mul_of_nonneg_left he.2 hh.1
  have e₂ := mul_le_mul_of_nonneg_left hb.1 hh.1
  have e₃ := mul_le_mul_of_nonneg_left ha.2 hh.1
  constructor <;> linarith [hh.2]

private theorem run {u θ} (c : Config u θ) (hu : 1000 ≤ u.A) :
    ∃ a b q : ℕ, (∃ e ∈ families, q = (back u e).b.toNat) ∧ u.A ≤ (q:ℤ) ∧ 10999*q + 20000*a ≤ 10000*b+30000 ∧
      ∀ t : ℕ, a ≤ t → t ≤ b → word θ t = word θ (t+q) := by
  obtain ⟨e,he,p,r,gap,hx,hy⟩ := golden_strip_cover c.s c.z c.sb c.zb
  have ⟨hv,hv'⟩ := scale_bounds u hu
  have hh : 0 ≤ shrink u^2 ∧ shrink u^2 ≤ 1/1000000 := by
    refine ⟨sq_nonneg _,?_⟩; nlinarith [mul_self_le_mul_self hv.le hv']
  have data := member_data he
  have sf := strip_facts he
  have ab (w : Point) (hw : crosses e c.s d w) : -1 ≤ c.s+val w d ∧ c.s+val w d ≤ 1 :=
    ⟨le_trans sf.1 hw.1,le_trans hw.2.le sf.2.1⟩
  have hh' := scaled_bound (X := c.z+val (phys p) d) (Y := c.z+val (phys r) d)
    hh data.2.2.1 (ab p gap.2.1) (ab r gap.2.2.1) ⟨data.1.le,data.2.1.le⟩ hx (by linarith)
  have tq := lag_time u e
  have tp := lattice_time c p
  have tr := lattice_time c r
  rw [←tq,←tp,←tr] at hh'
  have hc : 0 < 2*d*shrink u := mul_pos (mul_pos (by norm_num) (by linarith [dbounds.1])) hv
  have e₁ : 10999*((back u e).b:ℝ) ≤ 10000*(tick c r:ℝ) := by
    apply le_of_mul_le_mul_left (a := 2*d*shrink u) _ hc
    linarith only [hh'.1]
  have e₂ : 10999*((back u e).b:ℝ) ≤ 10000*((tick c r:ℝ)-2*(tick c p:ℝ)) := by
    apply le_of_mul_le_mul_left (a := 2*d*shrink u) _ hc
    linarith only [hh'.2]
  have i₁ : 10999*(back u e).b ≤ 10000*tick c r := by exact_mod_cast e₁
  have i₂ : 10999*(back u e).b ≤ 10000*(tick c r-2*tick c p) := by exact_mod_cast e₂
  have qbig : u.A ≤ (back u e).b := by
    dsimp [back]
    nlinarith [mul_nonneg u.Bnonneg (show 0 ≤ -e.a by linarith [data.2.2.2.1]),
      mul_nonneg u.Apos.le (show 0 ≤ e.b-1 by linarith [data.2.2.2.2.1])]
  refine ⟨(tick c p+1).toNat,(tick c r-1).toNat,(back u e).b.toNat, ⟨e,he,rfl⟩, by omega, by omega, ?_⟩
  intro t ha hb
  apply copied c hu he gap t _ (by omega) (by omega) (by omega)

/-- The six integer lags at scale n, from the six base displacements. -/
def scaleLags (n : ℕ) : List ℕ := families.map fun e => (back (unitAt n) e).b.toNat

/-- For each scale from three and each intercept, one of its six lags has
inclusive repeat excess b - 2a - q at least (999/10000)q - 3. -/
theorem golden_repeats_at_scale (θ : ℝ) (n : ℕ) (hn : 3 ≤ n) :
    ∃ q ∈ scaleLags n, ∃ a b : ℕ, n < q ∧ a ≤ b ∧
      10999*q + 20000*a ≤ 10000*b+30000 ∧
      ∀ t : ℕ, a ≤ t → t ≤ b → word θ t = word θ (t+q) := by
  have hlarge (k : ℕ) : 1000 ≤ (unitAt (3+k)).A := by
    induction k with
    | zero => decide
    | succ k ih =>
      change 1000 ≤ 9*(unitAt (3+k)).A + 20*(unitAt (3+k)).B
      linarith [(unitAt (3+k)).Bnonneg]
  have hu : 1000 ≤ (unitAt n).A := by simpa [show 3+(n-3) = n by omega] using hlarge (n-3)
  obtain ⟨a,b,q,⟨e,he,rfl⟩,hq,hlen,hs⟩ := run (config (unitAt n) θ) hu
  have hg := large n
  exact ⟨_, List.mem_map.mpr ⟨e,he,rfl⟩,a,b,by omega,by omega,hlen,hs⟩

/-- At every real phase the golden half-circle word has repeats of unbounded
lag and excess, even after discarding an arbitrary initial segment. -/
theorem unbounded_golden_repeats (θ : ℝ) (H K : ℕ) :
    ∃ a b q : ℕ, H ≤ a ∧ K < q ∧ 2*a+q+K < b ∧
      ∀ t : ℕ, a ≤ t → t ≤ b → word θ t = word θ (t+q) := by
  let n := 20*(K+2*H+3)+3
  obtain ⟨q,_,a,b,hq,_,hlen,hs⟩ := golden_repeats_at_scale θ n (by dsimp [n]; omega)
  dsimp only [n] at hq
  exact ⟨a+H,b,q,by omega,by omega,by omega,fun t ht hb => hs t (by omega) hb⟩

open Ruliology.CellularAutomata Rule30Realization

/-- An eventual period-two clock cannot have the golden half-circle coding at
any phase as its eventual even-time right neighbour. L=0 is included. -/
theorem no_eventual_golden_neighbour (x : ℤ → Bool) (L T H : ℕ) (θ : ℝ)
    (hleft : x (-(L:ℤ)) = true) (hzero : ∀ j < -(L:ℤ), x j = false)
    (clock : ∀ t, T ≤ t → evol x t 0 = decide (t%2 = 1))
    (visible : ∀ t, H ≤ t → evol x (2*t) 1 = word θ t) : False := by
  obtain ⟨a,b,q,ha,hq,hb,agree⟩ := unbounded_golden_repeats θ (H+T) L
  let m := L+2*(a+q)
  have clocks (i s : ℕ) (hi : a ≤ i) : evol x (2*i+s) 0 = decide (s%2 = 1) := by
    rw [clock _ (by omega), show (2*i+s)%2 = s%2 by omega]
  apply Rule30FiniteMaskedJen.window_jen_col hleft hzero (i := 0) (t₁ := 2*a) (t₂ := 2*(a+q))
    m (by omega) (by dsimp [m]; omega)
  · intro s _
    rw [clocks a s (by omega), clocks (a+q) s (by omega)]
  · intro s hs
    unfold Rule30FiniteMaskedJen.orCol
    rw [clocks a s (by omega), clocks (a+q) s (by omega)]
    by_cases hodd : s%2 = 1
    · simp [hodd]
    · simp only [hodd,decide_false,Bool.false_or]
      have h₁ : 2*a+s = 2*(a+s/2) := by omega
      have h₂ : 2*(a+q)+s = 2*((a+s/2)+q) := by omega
      change evol x (2*a+s) 1 = evol x (2*(a+q)+s) 1
      rw [h₁,h₂,visible _ (by omega),visible _ (by omega)]
      exact agree _ (by omega) (by dsimp [m] at hs; omega)

end GoldenRotation
