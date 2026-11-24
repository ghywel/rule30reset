import Rule30WhiteArrivals
import Ruliology.CellularAutomata.Rule30GatePulseReturn

/-! Two consecutive zero white readings mark a pulse with odd return time.
This argument needs only a finite alternating clock and allows arbitrary
behaviour after the five-white forecast horizon. -/
namespace Ruliology.CellularAutomata.Rule30WhiteArrivalMarkers

open Rule30Jen Rule30SourceArrivals Rule30WhiteArrivalWindow Rule30GatePulseReturn
open Rule30PeriodTwoCoupled (altCol)
open Rule30WhiteArrivals
open Rule30PeriodTwoWidth13 (AltFrom)

private theorem marker_table : ∀ (r : Row) (a b c : Bool),
    let old := tick r true a
    let next := tick (tick old false b) true c
    (reading old = false ∧ reading next = false) ↔ gate next = true ∧ next.getLsbD 1 = true := by
  decide +kernel

private theorem second (t : Nat) : (row t).getLsbD 1 = cell t 2 :=
  (by decide +kernel : ∀ a b c d e f : Bool, (pack a b c d e f).getLsbD 1 = b) _ _ _ _ _ _

/-- Only the five centre colours black, white, black, white, black enter this
identity. The four affected right sites need no tail hypothesis. -/
theorem two_zeros (t : Nat) (b₀ : cell t 0 = true) (w₁ : cell (t+1) 0 = false)
    (b₂ : cell (t+2) 0 = true) (w₃ : cell (t+3) 0 = false) (b₄ : cell (t+4) 0 = true) :
    (net (t+1) = false ∧ net (t+3) = false) ↔ cell (t+3) 1 = true ∧ cell (t+3) 2 = true := by
  have early : row (t+1) = tick (row t) true (cell t 7) := by rw [physical_tick, b₀]
  have late : row (t+3) = tick (tick (row (t+1)) false (cell (t+1) 7)) true (cell (t+2) 7) := by
    rw [show t+3=t+2+1 by omega, physical_tick (t+2), b₂,
      show row (t+2) = tick (row (t+1)) (cell (t+1) 0) (cell (t+1) 7) from physical_tick _, w₁]
  have e := marker_table (row t) (cell t 7) (cell (t+1) 7) (cell (t+2) 7)
  dsimp only at e
  rw [←early, ←late, physical_gate, second, physical_reading (t+1) w₁ b₂,
    physical_reading (t+3) w₃ b₄] at e
  exact e

def FirstReturn (t d : Nat) : Prop :=
  cell t 1 = true ∧ (∀ i, 0<i → i<d → cell (t+2*i) 1 = false) ∧ cell (t+2*d) 1 = true

private theorem unique {t a b} (pa : 0<a) (pb : 0<b)
    (ha : FirstReturn t a) (hb : FirstReturn t b) : a=b := by
  apply Classical.byContradiction
  intro ne
  rcases Nat.lt_or_gt_of_ne ne with less | more
  · have := hb.2.1 a pa less
    simp [ha.2.2] at this
  · have := ha.2.1 b pb more
    simp [hb.2.2] at this

/-- After a black-first startup, two zero white net readings detect exactly
those kicks whose first return is three or five white intervals away. -/
theorem odd_return (t : Nat) (clock : ∀ j, j<13 → cell (t+j) 0 = altCol j) :
    (net (t+1) = false ∧ net (t+3) = false) ↔
      ∃ d, (d=3 ∨ d=5) ∧ FirstReturn (t+3) d := by
  have localEq := two_zeros t (by simpa [altCol] using clock 0 (by decide))
    (by simpa [altCol] using clock 1 (by decide)) (by simpa [altCol] using clock 2 (by decide))
    (by simpa [altCol] using clock 3 (by decide)) (by simpa [altCol] using clock 4 (by decide))
  rw [localEq]
  let d := nearGap (cell (t+3) 2) (cell (t+3) 5)
  have range : 0<d ∧ d≤5 := (by decide : ∀ a b, 0<nearGap a b ∧ nearGap a b≤5) _ _
  have odd : (d=3 ∨ d=5) ↔ cell (t+3) 2 = true :=
    (by decide : ∀ a b, (nearGap a b=3 ∨ nearGap a b=5) ↔ a=true) _ _
  have ret (pulse : cell (t+3) 1 = true) : FirstReturn (t+3) d :=
    ⟨pulse, finite_clock_forecast Rule30Ether.trueRight_isR30 t d pulse rfl
      (fun j hj => clock j (by omega))⟩
  constructor
  · rintro ⟨pulse,site⟩
    exact ⟨d,odd.mpr site,ret pulse⟩
  · rintro ⟨g,choice,hg⟩
    have eq := unique range.1 (by omega) (ret hg.1) hg
    exact ⟨hg.1,odd.mp (eq ▸ choice)⟩

/-- Mark the starting white sample of each pulse whose next return is odd. -/
def oddKick (T k : Nat) := whiteGate T k && cell (T+2*k+1) 2

private theorem clock_at {T : Nat} (alt : AltFrom T) (k j : Nat) :
    cell (T+2*k+j) 0 = altCol j := by
  obtain ⟨m,even | odd⟩ := Rule30PeriodTwoWidth13.exists_half j
  · rw [even, show T+2*k+2*m = T+2*(k+m) by omega, (alt _).1]
    simp [altCol]
  · rw [odd, show T+2*k+(2*m+1) = T+2*(k+m)+1 by omega, (alt _).2]
    simp [altCol]

theorem oddKick_iff_return {T : Nat} (alt : AltFrom T) (k : Nat) :
    oddKick T (k+1) = true ↔ ∃ d, (d=3 ∨ d=5) ∧ FirstReturn (T+2*(k+1)+1) d := by
  let t := T+2*k
  have loc := two_zeros t (alt k).1 (alt k).2
    (by simpa [t, show T+2*k+2=T+2*(k+1) by omega] using (alt (k+1)).1)
    (by simpa [t, show T+2*k+3=T+2*(k+1)+1 by omega] using (alt (k+1)).2)
    (by simpa [t, show T+2*k+4=T+2*(k+2) by omega] using (alt (k+2)).1)
  have both := loc.symm.trans (odd_return t (fun j _ => clock_at alt k j))
  simpa only [oddKick, whiteGate, Bool.and_eq_true, t,
    show T+2*k+3=T+2*(k+1)+1 by omega] using both

private theorem no_ones_table : ∀ (r : Row) (a b : Bool),
    reading r = true → reading (tick (tick r false a) true b) = false := by decide +kernel

private theorem equality_marks {T : Nat} (alt : AltFrom T) (k : Nat) :
    (whiteNet T k == whiteNet T (k+1)) = oddKick T (k+1) := by
  let t := T+2*k
  have b₀ : cell t 0=true := (alt k).1
  have w₁ : cell (t+1) 0=false := (alt k).2
  have b₂ : cell (t+2) 0=true := by dsimp [t]; rw [show T+2*k+2=T+2*(k+1) by omega]; exact (alt _).1
  have w₃ : cell (t+3) 0=false := by dsimp [t]; rw [show T+2*k+3=T+2*(k+1)+1 by omega]; exact (alt _).2
  have b₄ : cell (t+4) 0=true := by dsimp [t]; rw [show T+2*k+4=T+2*(k+2) by omega]; exact (alt _).1
  have h := no_ones_table (row (t+1)) (cell (t+1) 7) (cell (t+2) 7)
  rw [←w₁, ←physical_tick, ←b₂, ←physical_tick, physical_reading _ w₁ b₂,
    physical_reading _ w₃ b₄] at h
  rw [b₂, w₁] at h
  have z := two_zeros t b₀ w₁ b₂ w₃ b₄
  change (net (t+1) == net (T+2*(k+1)+1)) = (cell (T+2*(k+1)+1) 1 && cell (T+2*(k+1)+1) 2)
  rw [show T+2*(k+1)+1=t+3 by dsimp [t]; omega]
  exact (by decide : ∀ a b x y : Bool, (a=true → b=false) →
    ((a=false ∧ b=false) ↔ x=true ∧ y=true) → (a==b)=(x&&y)) _ _ _ _ h z

/-- A binary stream whose changes repeat every p steps repeats every 2p.
The first difference between two copies p apart stays constant. -/
private theorem periodic_of_equalities (f : Nat → Bool)
    (per : EventuallyPeriodic (fun n => f n == f (n+1))) : EventuallyPeriodic f := by
  obtain ⟨L,p,hp,per⟩ := per
  let dif := fun n => xor (f (n+p)) (f n)
  have step (n : Nat) (hn : L≤n) : dif (n+1) = dif n := by
    have h := per n hn
    change (f (n+p) == f (n+p+1)) = (f n == f (n+1)) at h
    dsimp [dif]; rw [show n+1+p=n+p+1 by omega]
    exact (by decide : ∀ a b c d : Bool, (a==b)=(c==d) → xor b d=xor a c) _ _ _ _ h
  have same (n : Nat) (hn : L≤n) (k : Nat) : dif (n+k)=dif n := by
    induction k with
    | zero => rfl
    | succ k ih => exact (step (n+k) (by omega)).trans ih
  refine ⟨L,2*p,by omega,fun n hn => ?_⟩
  have h := same n hn p
  change xor (f (n+p+p)) (f (n+p)) = xor (f (n+p)) (f n) at h
  rw [show n+2*p=n+p+p by omega]
  exact (by decide : ∀ a b c : Bool, xor a b=xor b c → a=c) _ _ _ h

/-- The timetable of kicks followed by a three- or five-interval gap must
itself be aperiodic under the hypothetical alternating singleton centre. -/
theorem odd_kicks_aperiodic {T : Nat} (alt : AltFrom T) : ¬ EventuallyPeriodic (oddKick T) := by
  rintro ⟨L,p,hp,per⟩
  apply white_net_aperiodic alt
  apply periodic_of_equalities
  refine ⟨L,p,hp,fun n hn => ?_⟩
  dsimp only
  rw [equality_marks alt (n+p), equality_marks alt n, show n+p+1=n+1+p by omega]
  exact per (n+1) (by omega)

end Ruliology.CellularAutomata.Rule30WhiteArrivalMarkers
