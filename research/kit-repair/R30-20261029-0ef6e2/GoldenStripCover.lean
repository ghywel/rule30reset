import Rule30PrizeKit
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-! Exact real-coordinate cover for six families of lags of the golden half-circle word.
The certificate gives two consecutive lattice points in a half-open strip.
The theorems in GoldenRotation convert these crossings to integer sample times and apply the
resulting repetition bound to the even-time right neighbour of a Rule 30 clock. -/
namespace GoldenStripCover

structure Point where
  a : ℤ
  b : ℤ
deriving DecidableEq, Repr

def val (p : Point) (d : ℝ) : ℝ := p.a + p.b * d
def phys (p : Point) : Point := ⟨-p.a, p.b⟩
private def add (p r : Point) : Point := ⟨p.a+r.a, p.b+r.b⟩
private def sub (p r : Point) : Point := ⟨p.a-r.a, p.b-r.b⟩
private def smul (k : ℤ) (p : Point) : Point := ⟨k*p.a, k*p.b⟩
private def zero : Point := ⟨0, 0⟩
private def one : Point := ⟨1, 0⟩

/-- An affine inequality on the entire rational enclosure for sqrt(5). -/
private def below (p r : Point) : Bool :=
  let t := sub r p
  decide (0 ≤ 1000000*t.a + 2236067*t.b ∧ 0 ≤ 1000000*t.a + 2236069*t.b)

private theorem below_sound {p r : Point} {d : ℝ}
    (hd : 2236067 ≤ 1000000*d ∧ 1000000*d ≤ 2236069) (h : below p r = true) :
    val p d ≤ val r d := by
  have hh : 0 ≤ 1000000*(r.a-p.a) + 2236067*(r.b-p.b) ∧
      0 ≤ 1000000*(r.a-p.a) + 2236069*(r.b-p.b) := of_decide_eq_true h
  obtain ⟨h₁, h₂⟩ := hh
  have h₁' : (0:ℝ) ≤ 1000000*((r.a:ℝ)-p.a) + 2236067*((r.b:ℝ)-p.b) := by exact_mod_cast h₁
  have h₂' : (0:ℝ) ≤ 1000000*((r.a:ℝ)-p.a) + 2236069*((r.b:ℝ)-p.b) := by exact_mod_cast h₂
  unfold val
  rcases le_total (p.b:ℝ) r.b with hb | hb
  · nlinarith [mul_nonneg (sub_nonneg.mpr hb) (sub_nonneg.mpr hd.1)]
  · nlinarith [mul_nonneg (sub_nonneg.mpr hb) (sub_nonneg.mpr hd.2)]

private theorem val_add (p r : Point) (d : ℝ) : val (add p r) d = val p d + val r d := by
  simp [val, add]; ring
private theorem val_sub (p r : Point) (d : ℝ) : val (sub p r) d = val p d - val r d := by
  simp [val, sub]; ring
private theorem val_smul (k : ℤ) (p : Point) (d : ℝ) : val (smul k p) d = k * val p d := by
  simp [val, smul]; ring

def families : List Point := [⟨-3,1⟩, ⟨-4,2⟩, ⟨-7,3⟩, ⟨-11,5⟩, ⟨-18,8⟩, ⟨-29,13⟩]

/-- The short displacement e picks the crossing arc [min(0,-e),max(0,-e)). -/
def crosses (e : Point) (s d : ℝ) (p : Point) : Prop :=
  min 0 (-val e d) ≤ s + val p d ∧ s + val p d < max 0 (-val e d)

structure Gap where
  e : Point
  p : Point
  r : Point
  skips : List ℤ

/-- At each intermediate height b, k-1 is below the strip and k is above. -/
private def skipsOK (l h lo hi : Point) (stop b : ℤ) : List ℤ → Bool
  | [] => b == stop
  | k :: ks => below (add h ⟨k-1,b⟩) lo && below hi (add l ⟨k,b⟩) &&
      skipsOK l h lo hi stop (b+1) ks

private theorem skips_sound {d s : ℝ} {l h lo hi : Point}
    (hd : 2236067 ≤ 1000000*d ∧ 1000000*d ≤ 2236069)
    (hs : val l d ≤ s ∧ s < val h d) (stop b : ℤ) (ks : List ℤ)
    (ok : skipsOK l h lo hi stop b ks = true) (u : Point) (hb : b ≤ u.b ∧ u.b < stop) :
    ¬ (val lo d ≤ s + val u d ∧ s + val u d < val hi d) := by
  induction ks generalizing b with
  | nil => simp [skipsOK] at ok; omega
  | cons k ks ih =>
    simp only [skipsOK, Bool.and_eq_true] at ok
    rcases eq_or_lt_of_le hb.1 with he | he
    · have ha := below_sound hd ok.1.1
      have hz := below_sound hd ok.1.2
      rw [val_add] at ha hz
      intro hu
      rcases le_or_gt k u.a with hk | hk
      · have hk' : (k:ℝ) ≤ u.a := by exact_mod_cast hk
        simp only [val, ← he] at hu hz hs
        linarith [hs.1, hu.2]
      · have hk' : (u.a:ℝ) ≤ (k:ℝ)-1 := by exact_mod_cast (show u.a ≤ k-1 by omega)
        simp only [val, ← he, Int.cast_sub, Int.cast_one] at hu ha hs
        linarith [hs.2, hu.1]
    · exact ih (b+1) ok.2 ⟨by omega, hb.2⟩

private def bounds (g : Gap) : Point × Point :=
  let t := smul (-1) g.e
  if below zero t then (zero,t) else (t,zero)

private def inside (l h lo hi p : Point) : Bool :=
  below lo (add l p) && below (add h p) hi

private def gapOK (l h : Point) (g : Gap) : Bool :=
  let (lo,hi) := bounds g
  decide (g.e ∈ families ∧ g.p.b < g.r.b) && below lo hi &&
    inside l h lo hi g.p && inside l h lo hi g.r &&
    skipsOK l h lo hi g.r.b (g.p.b+1) g.skips

def consecutive (e p r : Point) (s d : ℝ) : Prop :=
  p.b < r.b ∧ crosses e s d p ∧ crosses e s d r ∧
    ∀ u : Point, p.b < u.b → u.b < r.b → ¬crosses e s d u

private theorem gap_sound {d s : ℝ} {l h : Point} {g : Gap}
    (hd : 2236067 ≤ 1000000*d ∧ 1000000*d ≤ 2236069)
    (hs : val l d ≤ s ∧ s < val h d) (ok : gapOK l h g = true) :
    g.e ∈ families ∧ consecutive g.e g.p g.r s d := by
  simp only [gapOK, Bool.and_eq_true, decide_eq_true_eq] at ok
  obtain ⟨⟨⟨⟨⟨hmem,hb⟩,hle⟩,hp⟩,hr⟩,hk⟩ := ok
  have hab := below_sound hd hle
  have heq : val (bounds g).1 d = min 0 (-val g.e d) ∧
      val (bounds g).2 d = max 0 (-val g.e d) := by
    have vz : val zero d = 0 := by simp [zero, val]
    have vn : val (smul (-1) g.e) d = -val g.e d := by rw [val_smul]; norm_num
    by_cases htest : below zero (smul (-1) g.e) = true
    · have eqb : bounds g = (zero, smul (-1) g.e) := by simp [bounds, htest]
      rw [eqb] at hab ⊢
      simp only [vz, vn] at hab ⊢
      exact ⟨(min_eq_left hab).symm, (max_eq_right hab).symm⟩
    · have eqb : bounds g = (smul (-1) g.e, zero) := by simp [bounds, htest]
      rw [eqb] at hab ⊢
      simp only [vz, vn] at hab ⊢
      exact ⟨(min_eq_right hab).symm, (max_eq_left hab).symm⟩
  have mem (p : Point) (hin : inside l h (bounds g).1 (bounds g).2 p = true) :
      crosses g.e s d p := by
    simp only [inside, Bool.and_eq_true] at hin
    have h₁ := below_sound hd hin.1
    have h₂ := below_sound hd hin.2
    rw [val_add, heq.1] at h₁
    rw [val_add, heq.2] at h₂
    unfold crosses
    constructor <;> linarith [hs.1, hs.2]
  refine ⟨hmem, hb, mem _ hp, mem _ hr, ?_⟩
  intro u hu hv
  have hh := skips_sound hd hs g.r.b (g.p.b+1) g.skips hk u ⟨by omega,hv⟩
  simpa only [heq.1, heq.2, crosses] using hh

private def lower (g : Gap) := sub (smul 11 (phys g.e)) (smul 10 (phys g.r))
private def upper (g : Gap) := sub (smul 10 (sub (phys g.r) (smul 2 (phys g.p)))) (smul 11 (phys g.e))
private def zMin : Point := ⟨-10, 0⟩
private def zMax : Point := ⟨50, 0⟩

/-- The two inequalities allow the earlier crossing to lie before the start of the word. -/
def Witness (d s z : ℝ) : Prop :=
  ∃ e ∈ families, ∃ p r, consecutive e p r s d ∧
    11 * val (phys e) d ≤ 10 * (z + val (phys r) d) ∧
    11 * val (phys e) d ≤ 10 * (val (phys r) d - 2 * val (phys p) d - z)

private def chain (l h start : Point) : List Gap → Bool
  | [] => below zMax start
  | g :: gs => gapOK l h g && below (lower g) start && chain l h (upper g) gs

private theorem chain_sound {d s z : ℝ} {l h : Point}
    (hd : 2236067 ≤ 1000000*d ∧ 1000000*d ≤ 2236069)
    (hs : val l d ≤ s ∧ s < val h d) (start : Point) (gs : List Gap)
    (ok : chain l h start gs = true) (hz : val start d < 10*z ∧ 10*z ≤ val zMax d) :
    Witness d s z := by
  induction gs generalizing start with
  | nil =>
    have h₀ := below_sound hd ok
    linarith [hz.1,hz.2]
  | cons g gs ih =>
    simp only [chain, Bool.and_eq_true] at ok
    by_cases hlast : 10*z ≤ val (upper g) d
    · have hfirst := below_sound hd ok.1.2
      obtain ⟨hm,hg⟩ := gap_sound hd hs ok.1.1
      refine ⟨g.e,hm,g.p,g.r,hg,?_,?_⟩
      · simp only [lower,val_sub,val_smul,Int.cast_ofNat] at hfirst
        linarith [hz.1]
      · simp only [upper,val_sub,val_smul,Int.cast_ofNat] at hlast
        linarith
    · exact ih (upper g) ok.2 ⟨lt_of_not_ge hlast,hz.2⟩

structure Row where
  stop : Point
  gaps : List Gap

private def cover (l : Point) : List Row → Bool
  | [] => below one l
  | row :: rows => chain l row.stop zMin row.gaps && cover row.stop rows

private theorem cover_sound {d s z : ℝ}
    (hd : 2236067 ≤ 1000000*d ∧ 1000000*d ≤ 2236069)
    (hs : s < 1) (hz : -1 < z ∧ z ≤ 5) (l : Point) (rs : List Row)
    (hl : val l d ≤ s) (ok : cover l rs = true) : Witness d s z := by
  induction rs generalizing l with
  | nil =>
    have h₁ := below_sound hd ok
    simp [one,val] at h₁ hl
    linarith
  | cons r rs ih =>
    simp only [cover,Bool.and_eq_true] at ok
    by_cases h : s < val r.stop d
    · apply chain_sound hd ⟨hl,h⟩ zMin r.gaps ok.1
      simp [val,zMin,zMax]
      constructor <;> linarith [hz.1,hz.2]
    · exact ih r.stop (le_of_not_gt h) ok.2

private def rows : List Row := [
  ⟨⟨47, -21⟩, [⟨⟨-18, 8⟩, ⟨0, 0⟩, ⟨-29, 13⟩, [-2, -4, -6, -8, -11, -13, -15, -17, -20, -22, -24, -26]⟩]⟩,
  ⟨⟨9, -4⟩, [⟨⟨-18, 8⟩, ⟨0, 0⟩, ⟨-38, 17⟩, [-2, -4, -6, -8, -11, -13, -15, -17, -20, -22, -24, -26, -29, -31, -33, -35]⟩]⟩,
  ⟨⟨18, -8⟩, [⟨⟨-11, 5⟩, ⟨2, -1⟩, ⟨-18, 8⟩, [0, -2, -4, -6, -9, -11, -13, -15]⟩]⟩,
  ⟨⟨27, -12⟩, [⟨⟨-7, 3⟩, ⟨0, 0⟩, ⟨-9, 4⟩, [-2, -4, -6]⟩,
      ⟨⟨-4, 2⟩, ⟨2, -1⟩, ⟨-5, 2⟩, [0, -2]⟩]⟩,
  ⟨⟨36, -16⟩, [⟨⟨-29, 13⟩, ⟨2, -1⟩, ⟨-36, 16⟩, [0, -2, -4, -6, -9, -11, -13, -15, -18, -20, -22, -24, -27, -29, -31, -33]⟩]⟩,
  ⟨⟨-2, 1⟩, [⟨⟨-18, 8⟩, ⟨11, -5⟩, ⟨-27, 12⟩, [9, 7, 5, 3, 0, -2, -4, -6, -9, -11, -13, -15, -18, -20, -22, -24]⟩]⟩,
  ⟨⟨45, -20⟩, [⟨⟨-18, 8⟩, ⟨2, -1⟩, ⟨-27, 12⟩, [0, -2, -4, -6, -9, -11, -13, -15, -18, -20, -22, -24]⟩]⟩,
  ⟨⟨7, -3⟩, [⟨⟨-18, 8⟩, ⟨2, -1⟩, ⟨-36, 16⟩, [0, -2, -4, -6, -9, -11, -13, -15, -18, -20, -22, -24, -27, -29, -31, -33]⟩]⟩,
  ⟨⟨16, -7⟩, [⟨⟨-11, 5⟩, ⟨4, -2⟩, ⟨-16, 7⟩, [2, 0, -2, -4, -7, -9, -11, -13]⟩]⟩,
  ⟨⟨25, -11⟩, [⟨⟨-11, 5⟩, ⟨-5, 2⟩, ⟨-25, 11⟩, [-7, -9, -11, -13, -16, -18, -20, -22]⟩]⟩,
  ⟨⟨34, -15⟩, [⟨⟨-29, 13⟩, ⟨4, -2⟩, ⟨-34, 15⟩, [2, 0, -2, -4, -7, -9, -11, -13, -16, -18, -20, -22, -25, -27, -29, -31]⟩]⟩,
  ⟨⟨-4, 2⟩, [⟨⟨-18, 8⟩, ⟨13, -6⟩, ⟨-25, 11⟩, [11, 9, 7, 5, 2, 0, -2, -4, -7, -9, -11, -13, -16, -18, -20, -22]⟩]⟩,
  ⟨⟨43, -19⟩, [⟨⟨-18, 8⟩, ⟨4, -2⟩, ⟨-25, 11⟩, [2, 0, -2, -4, -7, -9, -11, -13, -16, -18, -20, -22]⟩]⟩,
  ⟨⟨5, -2⟩, [⟨⟨-18, 8⟩, ⟨4, -2⟩, ⟨-34, 15⟩, [2, 0, -2, -4, -7, -9, -11, -13, -16, -18, -20, -22, -25, -27, -29, -31]⟩]⟩,
  ⟨⟨14, -6⟩, [⟨⟨-11, 5⟩, ⟨6, -3⟩, ⟨-14, 6⟩, [4, 2, 0, -2, -5, -7, -9, -11]⟩]⟩,
  ⟨⟨23, -10⟩, [⟨⟨-11, 5⟩, ⟨-3, 1⟩, ⟨-23, 10⟩, [-5, -7, -9, -11, -14, -16, -18, -20]⟩]⟩,
  ⟨⟨32, -14⟩, [⟨⟨-3, 1⟩, ⟨0, 0⟩, ⟨-5, 2⟩, [-2]⟩,
      ⟨⟨-29, 13⟩, ⟨6, -3⟩, ⟨-32, 14⟩, [4, 2, 0, -2, -5, -7, -9, -11, -14, -16, -18, -20, -23, -25, -27, -29]⟩]⟩,
  ⟨⟨-6, 3⟩, [⟨⟨-18, 8⟩, ⟨15, -7⟩, ⟨-23, 10⟩, [13, 11, 9, 7, 4, 2, 0, -2, -5, -7, -9, -11, -14, -16, -18, -20]⟩]⟩,
  ⟨⟨41, -18⟩, [⟨⟨-18, 8⟩, ⟨6, -3⟩, ⟨-23, 10⟩, [4, 2, 0, -2, -5, -7, -9, -11, -14, -16, -18, -20]⟩]⟩,
  ⟨⟨3, -1⟩, [⟨⟨-18, 8⟩, ⟨6, -3⟩, ⟨-32, 14⟩, [4, 2, 0, -2, -5, -7, -9, -11, -14, -16, -18, -20, -23, -25, -27, -29]⟩]⟩,
  ⟨⟨50, -22⟩, [⟨⟨-18, 8⟩, ⟨-3, 1⟩, ⟨-32, 14⟩, [-5, -7, -9, -11, -14, -16, -18, -20, -23, -25, -27, -29]⟩]⟩,
  ⟨⟨12, -5⟩, [⟨⟨-18, 8⟩, ⟨-3, 1⟩, ⟨-41, 18⟩, [-5, -7, -9, -11, -14, -16, -18, -20, -23, -25, -27, -29, -32, -34, -36, -38]⟩]⟩,
  ⟨⟨21, -9⟩, [⟨⟨-11, 5⟩, ⟨-1, 0⟩, ⟨-21, 9⟩, [-3, -5, -7, -9, -12, -14, -16, -18]⟩]⟩,
  ⟨⟨30, -13⟩, [⟨⟨-4, 2⟩, ⟨-1, 0⟩, ⟨-8, 3⟩, [-3, -5]⟩,
      ⟨⟨-3, 1⟩, ⟨2, -1⟩, ⟨-3, 1⟩, [0]⟩]⟩,
  ⟨⟨-8, 4⟩, [⟨⟨-18, 8⟩, ⟨17, -8⟩, ⟨-21, 9⟩, [15, 13, 11, 9, 6, 4, 2, 0, -3, -5, -7, -9, -12, -14, -16, -18]⟩]⟩,
  ⟨⟨39, -17⟩, [⟨⟨-18, 8⟩, ⟨8, -4⟩, ⟨-21, 9⟩, [6, 4, 2, 0, -3, -5, -7, -9, -12, -14, -16, -18]⟩]⟩,
  ⟨⟨1, 0⟩, [⟨⟨-18, 8⟩, ⟨8, -4⟩, ⟨-30, 13⟩, [6, 4, 2, 0, -3, -5, -7, -9, -12, -14, -16, -18, -21, -23, -25, -27]⟩]⟩]

private theorem rows_pass : cover zero rows = true := by decide

/-- Every reduced real configuration has two consecutive strip crossings at one
of the six golden families, with both physical bounds for 10 percent excess. -/
theorem golden_strip_cover (s z : ℝ) (hs : 0 ≤ s ∧ s < 1) (hz : -1 < z ∧ z ≤ 5) :
    Witness (Real.sqrt 5) s z := by
  have hh := Real.sq_sqrt (show (0:ℝ) ≤ 5 by norm_num)
  have hn := Real.sqrt_nonneg (5:ℝ)
  have hd : (2236067:ℝ) ≤ 1000000*Real.sqrt 5 ∧ 1000000*Real.sqrt 5 ≤ 2236069 := by
    constructor <;> nlinarith only [hh,hn,sq_nonneg (Real.sqrt 5 - 2236067/1000000),
      sq_nonneg (Real.sqrt 5 - 2236069/1000000)]
  exact cover_sound hd hs.2 hz zero rows (by simpa [val,zero] using hs.1) rows_pass

end GoldenStripCover
