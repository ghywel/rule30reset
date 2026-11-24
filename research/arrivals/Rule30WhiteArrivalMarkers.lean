import Rule30WhiteArrivalWindow
import Ruliology.CellularAutomata.Rule30GatePulseReturn

/-! Two consecutive zero white readings mark a pulse with odd return time.
This argument needs only a finite alternating clock and allows arbitrary
behaviour after the five-white forecast horizon. -/
namespace Ruliology.CellularAutomata.Rule30WhiteArrivalMarkers

open Rule30Jen Rule30SourceArrivals Rule30WhiteArrivalWindow Rule30GatePulseReturn
open Rule30PeriodTwoCoupled (altCol)

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

end Ruliology.CellularAutomata.Rule30WhiteArrivalMarkers
