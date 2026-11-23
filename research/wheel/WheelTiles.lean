module
public import Ruliology.CellularAutomata.Rule30GateTrap
public import Ruliology.CellularAutomata.Rule30SidewaysLocks

/-! Full physical ticks between the sampled pulses of a trapped right half. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelTiles
open Rule30Ether Rule30StripCertificates Rule30PeriodTwoCoupled Rule30GateTrap Rule30SidewaysLocks

def short : List Bool := [true,true,false,true,false,false,true]
def long : List Bool := [true,true,false,true,false,false,false,true,false,false,true]

/-- A white-start cone read at its j-th physical tick. -/
def firstCell (w : List Bool) (j : Nat) : Bool := (evolve 1 j (w.take (1+j))).headD false
def spells (w word : List Bool) : Bool :=
  (List.range word.length).all fun j => firstCell w j == word.getD j false

private theorem parity_evolve (n t u : Nat) (h : t%2 = u%2) (row : List Bool) :
    evolve t n row = evolve u n row := by
  induction n generalizing t u row with
  | zero => rfl
  | succ n ih =>
    have wall : altCol t = altCol u := by simp only [altCol,h]
    simp only [evolve,wall]
    exact ih _ _ (by omega) _

theorem physical (R : Nat → Bool) {t W j : Nat} (odd : t%2 = 1) (bound : 1+j ≤ W) :
    firstCell (winW W R t) j = drv altCol R (t+j) 1 := by
  unfold firstCell winW
  have sub : (rowOf (drv altCol R) t 0 W).take (1+j) = rowOf (drv altCol R) t 0 (1+j) :=
    seg_take W (1+j) _ bound
  rw [sub, parity_evolve j 1 t (by omega), ← rowOf_evolve R j t 1]
  rfl

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
private theorem tile_check : trap.all
    (fun w => !w.headD false || spells w short || spells w long) = true := by decide +kernel

/-- The terminal black is included in each word. The tile before it takes six or ten ticks. -/
theorem tiles_of_pulse (R : Nat → Bool) {t : Nat} (odd : t%2 = 1)
    (inside : win R t ∈ trap) (pulse : drv altCol R t 1 = true) :
    (∀ j, j<short.length → drv altCol R (t+j) 1 = short.getD j false) ∨
    (∀ j, j<long.length → drv altCol R (t+j) 1 = long.getD j false) := by
  have check := List.all_eq_true.mp tile_check _ inside
  rw [win_head,pulse] at check
  simp only [Bool.not_true,Bool.false_or,Bool.or_eq_true] at check
  have read (word : List Bool) (bound : word.length ≤ 16) (ok : spells (win R t) word = true) (j : Nat)
      (hj : j<word.length) : drv altCol R (t+j) 1 = word.getD j false := by
    rw [← physical R (W := 16) odd (by omega : 1+j≤16)]
    exact beq_iff_eq.mp (List.all_eq_true.mp ok j (List.mem_range.mpr hj))
  exact check.elim (fun h => Or.inl (read short (by decide) h)) (fun h => Or.inr (read long (by decide) h))

/-- The secondary 14-physical-tick wheel recorded beside the main wheel in October. -/
def secondary (i : Nat) := (0x2cc8 : Nat).testBit (i%14)
def tenTick (i : Nat) := (0x8b : Nat).testBit (i%10)

def clockCheck (W p : Nat) (codes : List (List Nat)) (label : Nat → Bool) : Bool :=
  (List.range p).all fun k => (cls W codes k).all fun w =>
    firstCell w 0 == label (2*k) && firstCell w 1 == label (2*k+1)

private theorem clock_of_lock {W p : Nat} {word : List Bool} {codes : List (List Nat)} {label : Nat → Bool}
    (hwid : 2≤W) (hp : 0<p) (hl : lockCheck W p word codes = true) (hc : clockCheck W p codes label = true)
    (R : Nat → Bool) {t k : Nat} (odd : t%2=1) (hk : k<p) (hit : winW W R t ∈ cls W codes k)
    (n : Nat) (e : Fin 2) :
    drv altCol R (t+2*n+e.val) 1 = label (2*((k+n)%p)+e.val) := by
  have cls_now := lock_forever hl hp R odd hk hit n
  have all := List.all_eq_true.mp hc ((k+n)%p) (List.mem_range.mpr (Nat.mod_lt _ hp))
  obtain ⟨l,r⟩ := Bool.and_eq_true_iff.mp (List.all_eq_true.mp all _ cls_now)
  rw [← physical R (W := W) (by omega : (t+2*n)%2=1) (by omega : 1+e.val≤W)]
  have h : e.val=0 ∨ e.val=1 := by omega
  rcases h with h | h
  · rw [h]; exact beq_iff_eq.mp l
  · rw [h]; exact beq_iff_eq.mp r

theorem seven_secondary (R : Nat → Bool) {t k : Nat} (odd : t%2=1) (hk : k<7)
    (hit : winW 30 R t ∈ cls 30 lock7Codes k) (n : Nat) (e : Fin 2) :
    drv altCol R (t+2*n+e.val) 1 = secondary (2*((k+n)%7)+e.val+4) :=
  clock_of_lock (label := fun i => secondary (i+4)) (by decide) (by decide) lock7_ok (by decide +kernel)
    R odd hk hit n e

theorem seven_b_secondary (R : Nat → Bool) {t k : Nat} (odd : t%2=1) (hk : k<7)
    (hit : winW 45 R t ∈ cls 45 lock7bCodes k) (n : Nat) (e : Fin 2) :
    drv altCol R (t+2*n+e.val) 1 = secondary (2*((k+n)%7)+e.val+2) :=
  clock_of_lock (label := fun i => secondary (i+2)) (by decide) (by decide) lock7b_ok (by decide +kernel)
    R odd hk hit n e

theorem five_long_tile (R : Nat → Bool) {t k : Nat} (odd : t%2=1) (hk : k<5)
    (hit : winW 34 R t ∈ cls 34 lock5Codes k) (n : Nat) (e : Fin 2) :
    drv altCol R (t+2*n+e.val) 1 = tenTick (2*((k+n)%5)+e.val) :=
  clock_of_lock (by decide) (by decide) lock5_ok (by decide +kernel) R odd hk hit n e

/-- Both pulse tiles are black again three physical ticks after their leading black. -/
theorem pulse_three_ticks (R : Nat → Bool) {t : Nat} (odd : t%2=1)
    (inside : win R t ∈ trap) (pulse : drv altCol R t 1 = true) : drv altCol R (t+3) 1 = true := by
  rcases tiles_of_pulse R odd inside pulse with small | large
  · exact small 3 (by decide)
  · exact large 3 (by decide)

/-- From trap entry, an aligned reading of the October 14-tick word must disagree in any
17 consecutive physical ticks. Physical odd times are the kit's white boundary phase. -/
theorem no_seventeen_secondary (R : Nat → Bool) {t0 t : Nat} (odd : t0%2=1)
    (inside : win R t0 ∈ trap) (later : t0≤t) (p : Fin 14) (aligned : (t+p.val)%2=1) :
    ¬ ∀ j, j<17 → drv altCol R (t+j) 1 = secondary (p.val+j) := by
  intro reads
  let r := (20-p.val)%14
  have phase : (p.val+r)%14=6 := by dsimp [r]; omega
  have span : r<14 := Nat.mod_lt _ (by decide)
  have white : (t+r)%2=1 := by omega
  have trapped := win_mem_trap R odd inside ((t+r-t0)/2)
  rw [show t0+2*((t+r-t0)/2)=t+r by omega] at trapped
  have lead := reads r (by omega)
  have tail := reads (r+3) (by omega)
  simp only [secondary,phase] at lead
  simp only [secondary,show (p.val+(r+3))%14=9 by omega] at tail
  have actual := pulse_three_ticks R white trapped lead
  rw [show t+r+3=t+(r+3) by omega,tail] at actual
  contradiction

/-- Sharpness within a physical trapped row. The five-lock seed attains 16 ticks. -/
theorem secondary_sixteen_witness :
    ∃ t p : Nat, win (rh 28998) (15+2*0) ∈ trap ∧ 15≤t ∧ p<14 ∧ (t+p)%2=1 ∧
      ∀ j : Fin 16, drv altCol (rh 28998) (t+j.val) 1 = secondary (p+j.val) := by
  have clk (n : Nat) (e : Fin 2) := five_long_tile (rh 28998) (t:=15) (k:=0)
    (by decide) (by decide) lock5_entry n e
  have cases : ∃ off : Fin 10, ∃ p : Fin 14, (15+off.val+p.val)%2=1 ∧
      ∀ j : Fin 16, tenTick (2*((0+(off.val+j.val)/2)%5)+(off.val+j.val)%2) =
        secondary (p.val+j.val) := by decide +kernel
  obtain ⟨off,p,aligned,hit⟩ := cases
  refine ⟨15+off.val,p.val,lock5_win_trap (by decide : 0<5) lock5_entry,by omega,p.isLt,aligned,?_⟩
  intro j
  let v := off.val+j.val
  have eq := clk (v/2) ⟨v%2,Nat.mod_lt _ (by decide)⟩
  change drv altCol (rh 28998) (15+2*(v/2)+v%2) 1 = _ at eq
  rw [show 15+2*(v/2)+v%2=15+off.val+j.val by dsimp [v]; omega] at eq
  exact eq.trans (hit j)

end Ruliology.CellularAutomata.WheelTiles
