module
public import Ruliology.CellularAutomata.Rule30Prize
public import Ruliology.CellularAutomata.Rule30GateTrap

/-! The cell choosing the next wheel tile beside a white-first alternating wall. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelKickRelay
open Rule30Ether Rule30GateTrap Rule30PeriodTwoCoupled

def whiteFirst (t : Nat) : Bool := t % 2 == 1

private theorem driven (F : Nat → Nat → Bool) (step : IsR30 F)
    (wall : ∀ h, F h 0 = whiteFirst h) : ∀ h p, F h p = drv whiteFirst (F 0) h p := by
  intro h
  induction h with
  | zero =>
    intro p
    cases p with
    | zero => exact (wall 0).trans (drv_col0 _ _ _).symm
    | succ p => exact (drv_init _ _ _ (by omega)).symm
  | succ h ih =>
    intro p
    cases p with
    | zero => exact (wall _).trans (drv_col0 _ _ _).symm
    | succ p => rw [step, drv_isR30, ih p, ih (p+1), ih (p+2)]

/-- If the four positive cells at a white tick are 1110, the next six updates
transmit the fifth cell's bit to site one. No condition on sites six and beyond. -/
theorem six_tick_relay (F : Nat → Nat → Bool) (step : IsR30 F)
    (wall : ∀ h, F h 0 = whiteFirst h)
    (a : F 0 1 = true) (b : F 0 2 = true) (c : F 0 3 = true) (d : F 0 4 = false) :
    [F 0 1, F 1 1, F 2 1, F 3 1, F 4 1, F 5 1, F 6 1] =
      [true, true, false, true, false, false, F 0 5] ∧
    [F 1 4, F 2 3, F 3 4, F 4 3, F 5 2] =
      [!(F 0 5), !(F 0 5), F 0 5, !(F 0 5), !(F 0 5)] := by
  have same := driven F step wall
  have goal_for (x : Nat → Bool) (h1 : x 1 = true) (h2 : x 2 = true)
      (h3 : x 3 = true) (h4 : x 4 = false) :
      let G := drv whiteFirst x
      [G 0 1, G 1 1, G 2 1, G 3 1, G 4 1, G 5 1, G 6 1] =
        [true,true,false,true,false,false,x 5] ∧
      [G 1 4, G 2 3, G 3 4, G 4 3, G 5 2] = [!(x 5),!(x 5),x 5,!(x 5),!(x 5)] := by
    dsimp only
    cases e : x 5 <;> cases f : x 6 <;> cases g : x 7 <;>
      simp [drv, whiteFirst, Rule30Jen.rule, h1, h2, h3, h4, e, f, g]
  simpa only [← same] using goal_for (F 0) a b c d

private theorem prefix_check : trap.all (fun w =>
    !w.headD false || w.take 4 == [true,true,true,false]) = true := by decide +kernel

/-- Every black pulse in the physical trap has the four-cell relay prefix. -/
theorem trapped_pulse_prefix (R : Nat → Bool) (t : Nat) (inside : win R t ∈ trap)
    (pulse : drv altCol R t 1 = true) : (win R t).take 4 = [true,true,true,false] := by
  have ok := List.all_eq_true.mp prefix_check _ inside
  rw [win_head, pulse] at ok
  simpa using ok

/-- At a sampled pulse, site five alone selects the early return. The kit's
gap law gives the late return at tick ten when this bit is white. -/
theorem trapped_selector (R : Nat → Bool) (t : Nat) (white : t % 2 = 1)
    (inside : win R t ∈ trap) (pulse : drv altCol R t 1 = true) :
    drv altCol R (t+6) 1 = drv altCol R t 5 := by
  let G := fun h p => drv altCol R (t+h) p
  have hs : IsR30 G := by
    intro h p
    exact drv_isR30 altCol R (t+h) p
  have hw (h : Nat) : G h 0 = whiteFirst h := by
    change drv altCol R (t+h) 0 = _
    rw [drv_col0]
    unfold altCol whiteFirst
    by_cases odd : h % 2 = 1
    · rw [show (t+h)%2 = 0 by omega, odd]
      decide
    · rw [show (t+h)%2 = 1 by omega, show h%2 = 0 by omega]
      decide
  have pref := trapped_pulse_prefix R t inside pulse
  change [G 0 1, G 0 2, G 0 3, G 0 4] = [true,true,true,false] at pref
  simp only [List.cons.injEq, and_true] at pref
  have eq := (six_tick_relay G hs hw pref.1 pref.2.1 pref.2.2.1 pref.2.2.2).1
  exact congrArg (fun l : List Bool => l.getD 6 false) eq

end Ruliology.CellularAutomata.WheelKickRelay
