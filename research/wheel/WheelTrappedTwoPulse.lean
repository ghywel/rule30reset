module
public import WheelKickRelay
public import Ruliology.CellularAutomata.Rule30SidewaysLocks

/-! The next two black-to-black gaps read from one trapped white-time row. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelTrappedTwoPulse
open Rule30GateTrap Rule30StripCertificates Rule30PeriodTwoCoupled Rule30PeriodTwoSideways
open Rule30Ether Rule30SidewaysLocks

def gap (early : Bool) : Nat := if early then 3 else 5

def Next (R : Nat → Bool) (s g : Nat) : Prop :=
  u R (s+g) = true ∧ ∀ d, 0 < d → d < g → u R (s+d) = false

def site (R : Nat → Bool) (s p : Nat) : Bool := drv altCol R (2*s+1) p

def secondEarly (R : Nat → Bool) (s : Nat) : Bool :=
  if site R s 5 then site R s 7 else !site R s 8 && site R s 9

private theorem evolve_phase (n t v : Nat) (h : t%2=v%2) (w : List Bool) :
    evolve t n w = evolve v n w := by
  induction n generalizing t v w with
  | zero => rfl
  | succ n ih =>
    change evolve (t+1) n (lin3 (altCol t :: w)) = evolve (v+1) n (lin3 (altCol v :: w))
    rw [show altCol t = altCol v by simp [altCol,h]]
    exact ih _ _ (by omega) _

private theorem fifth (R : Nat → Bool) (t n : Nat) (odd : t%2=1) (width : 5+n≤16) :
    drv altCol R (t+n) 5 = (evolve 1 n ((win R t).take (5+n))).getD 4 false := by
  have take : (win R t).take (5+n) = rowOf (drv altCol R) t 0 (5+n) :=
    seg_take 16 (5+n) (fun i => drv altCol R t (0+i+1)) width
  rw [take, ←evolve_phase n t 1 odd, ←rowOf_evolve R n t 5]
  rfl

private def branchOK (w : List Bool) : Bool :=
  !w.headD false || (if w.getD 4 false then
    (evolve 1 6 (w.take 11)).getD 4 false == w.getD 6 false
  else
    (evolve 1 10 (w.take 15)).getD 4 false == (!w.getD 7 false && w.getD 8 false))

set_option maxRecDepth 10000 in
private theorem branches : trap.all branchOK = true := by decide +kernel

theorem selector_at_return (R : Nat → Bool) (s : Nat)
    (inside : win R (2*s+1) ∈ trap) (pulse : u R s = true) :
    site R (s+gap (site R s 5)) 5 = secondEarly R s := by
  let t := 2*s+1
  have odd : t%2=1 := by dsimp [t]; omega
  have ok := List.all_eq_true.mp branches _ inside
  simp only [branchOK,win_head,show drv altCol R (2*s+1) 1 = true from pulse,
    Bool.not_true,Bool.false_or] at ok
  have at5 : (win R t).getD 4 false = site R s 5 := rfl
  change (if (win R t).getD 4 false then _ else _) = true at ok
  rw [at5] at ok
  have at7 : (win R t).getD 6 false = site R s 7 := rfl
  have at8 : (win R t).getD 7 false = site R s 8 := rfl
  have at9 : (win R t).getD 8 false = site R s 9 := rfl
  cases h : site R s 5 with
  | false =>
    simp only [h,Bool.false_eq_true,ite_false] at ok
    change drv altCol R (2*(s+gap false)+1) 5 = _
    rw [show 2*(s+gap false)+1=t+10 by dsimp [gap,t]; omega, fifth R t 10 odd (by decide)]
    simp only [secondEarly,h,Bool.false_eq_true,ite_false,←at8,←at9]
    exact beq_iff_eq.mp ok
  | true =>
    simp only [h,ite_true] at ok
    change drv altCol R (2*(s+gap true)+1) 5 = _
    rw [show 2*(s+gap true)+1=t+6 by dsimp [gap,t]; omega, fifth R t 6 odd (by decide)]
    simp only [secondEarly,h,ite_true,←at7]
    exact beq_iff_eq.mp ok

private theorem first (R : Nat → Bool) (s : Nat) (inside : win R (2*s+1) ∈ trap)
    (pulse : u R s = true) : Next R s (gap (site R s 5)) := by
  have early : u R (s+3) = site R s 5 := by
    simpa only [u,site,show 2*(s+3)+1=2*s+1+6 by omega] using
      WheelKickRelay.trapped_selector R (2*s+1) (by omega) inside pulse
  rw [←early]
  rcases gaps_of_entry R (by omega : (2*s+1)%2=1) inside s (by omega) pulse with
    ⟨h1,h2,h3⟩ | ⟨h1,h2,h3,h4,h5⟩
  · rw [h3]
    refine ⟨h3, fun d hd hb => ?_⟩
    change d<3 at hb
    rcases (by omega : d=1 ∨ d=2) with rfl|rfl
    · exact h1
    · exact h2
  · rw [h3]
    refine ⟨h5, fun d hd hb => ?_⟩
    change d<5 at hb
    rcases (by omega : d=1 ∨ d=2 ∨ d=3 ∨ d=4) with rfl|rfl|rfl|rfl
    · exact h1
    · exact h2
    · exact h3
    · exact h4

/-- Both predicted gaps are first returns, from any trapped black pulse. -/
theorem two_pulse (R : Nat → Bool) (s : Nat) (inside : win R (2*s+1) ∈ trap)
    (pulse : u R s = true) :
    let g := gap (site R s 5)
    Next R s g ∧ Next R (s+g) (gap (secondEarly R s)) := by
  let g := gap (site R s 5)
  have firstGap := first R s inside pulse
  have reached : win R (2*(s+g)+1) ∈ trap := by
    rw [show 2*(s+g)+1=2*s+1+2*g by omega]
    exact win_mem_trap R (by omega) inside g
  have second := first R (s+g) reached firstGap.1
  refine ⟨firstGap,?_⟩
  rwa [show site R (s+g) 5 = secondEarly R s from selector_at_return R s inside pulse] at second

def AmbiguousAt (n g : Nat) : Prop :=
  ∃ R S, Rule30ZeroBoundary.FinSupp R ∧ Rule30ZeroBoundary.FinSupp S ∧
    win R 1 ∈ trap ∧ win S 1 ∈ trap ∧ u R 0 = true ∧ u S 0 = true ∧
    (win R 1).take n = (win S 1).take n ∧
    Next R 0 g ∧ Next S 0 g ∧ Next R g 5 ∧ Next S g 3

private theorem ambiguous (a b n g : Nat)
    (ha : win (rh a) 1 ∈ trap) (hb : win (rh b) 1 ∈ trap)
    (pa : u (rh a) 0 = true) (pb : u (rh b) 0 = true)
    (same : (win (rh a) 1).take n = (win (rh b) 1).take n)
    (ga : gap (site (rh a) 0 5) = g) (gb : gap (site (rh b) 0 5) = g)
    (sa : secondEarly (rh a) 0 = false) (sb : secondEarly (rh b) 0 = true) : AmbiguousAt n g := by
  have x := two_pulse (rh a) 0 ha pa
  have y := two_pulse (rh b) 0 hb pb
  dsimp only at x y
  rw [ga,sa,Nat.zero_add] at x
  rw [gb,sb,Nat.zero_add] at y
  exact ⟨rh a,rh b,Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat _,Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat _,
    ha,hb,pa,pb,same,x.1,y.1,x.2,y.2⟩

set_option maxRecDepth 10000 in
theorem six_cells_insufficient : AmbiguousAt 6 3 := by
  apply ambiguous 0x30c 0x48c <;> decide +kernel

set_option maxRecDepth 10000 in
theorem eight_cells_insufficient : AmbiguousAt 8 5 := by
  apply ambiguous 0xc2c 0xe2c <;> decide +kernel

private theorem emptyWindow (s : Nat) :
    win empty (2*s+1) = decode (Rule30DrivenPrefix.white s) := by
  apply Rule30Ether.seg_congr
  intro i _
  simpa only [Nat.zero_add] using (Rule30DrivenPrefix.white_sound s i).symm

private theorem emptyLate (s : Nat) (hs : 146≤s) (q : Bool)
    (pulse : (Rule30DrivenPrefix.white s).testBit 0 = true)
    (firstBit : (Rule30DrivenPrefix.white s).testBit 4 = false)
    (secondBits : (!(Rule30DrivenPrefix.white s).testBit 7 && (Rule30DrivenPrefix.white s).testBit 8) = q) :
    Next empty s 5 ∧ Next empty (s+5) (gap q) := by
  have reached := win_mem_trap empty (by decide : 293%2=1) entry_empty (s-146)
  rw [show 293+2*(s-146)=2*s+1 by omega] at reached
  have hp := (Rule30DrivenPrefix.white_gate s).symm.trans pulse
  have result := two_pulse empty s reached hp
  dsimp only at result
  have cell (j : Nat) : site empty s (j+1) = (Rule30DrivenPrefix.white s).testBit j :=
    (Rule30DrivenPrefix.white_sound s j).symm
  have fifthOff : site empty s 5 = false := (cell 4).trans firstBit
  have nextBit : secondEarly empty s = q := by
    simpa only [secondEarly,fifthOff,Bool.false_eq_true,ite_false,cell 7,cell 8] using secondBits
  rw [fifthOff,nextBit] at result
  exact result

/-- The empty half alone attains opposite predictions with the same eight-cell
observation at two pulses long after its entry into the trap. -/
theorem mature_eight_cells_insufficient :
    win empty 293 ∈ trap ∧ (win empty 335).take 8 = (win empty 535).take 8 ∧
    Next empty 167 5 ∧ Next empty 172 3 ∧ Next empty 267 5 ∧ Next empty 272 5 := by
  have a := emptyLate 167 (by decide) true (by decide +kernel) (by decide +kernel) (by decide +kernel)
  have b := emptyLate 267 (by decide) false (by decide +kernel) (by decide +kernel) (by decide +kernel)
  refine ⟨entry_empty,?_,a.1,a.2,b.1,b.2⟩
  rw [show 335=2*167+1 by decide,show 535=2*267+1 by decide,emptyWindow,emptyWindow]
  decide +kernel

/-- The second gap can be read without first knowing which kind of pulse came first. -/
def threeSites (R : Nat → Bool) (s : Nat) : Bool :=
  site R s 9 && (site R s 7 || !site R s 8)

private def threeOK (w : List Bool) : Bool :=
  !w.headD false ||
  ((if w.getD 4 false then w.getD 6 false else !w.getD 7 false && w.getD 8 false) ==
   (w.getD 8 false && (w.getD 6 false || !w.getD 7 false)))

set_option maxRecDepth 10000 in
private theorem three_table : trap.all threeOK = true := by decide +kernel

theorem three_site_selector (R : Nat → Bool) (s : Nat) (inside : win R (2*s+1) ∈ trap)
    (pulse : u R s = true) : secondEarly R s = threeSites R s := by
  have check := List.all_eq_true.mp three_table _ inside
  simp only [threeOK,win_head,show drv altCol R (2*s+1) 1 = true from pulse,Bool.not_true,Bool.false_or] at check
  have a : (win R (2*s+1)).getD 4 false = site R s 5 := rfl
  have b : (win R (2*s+1)).getD 6 false = site R s 7 := rfl
  have c : (win R (2*s+1)).getD 7 false = site R s 8 := rfl
  have d : (win R (2*s+1)).getD 8 false = site R s 9 := rfl
  rw [a,b,c,d] at check
  exact beq_iff_eq.mp check

def readMask (m : Nat) (R : Nat → Bool) : Nat := encList (win R 1) &&& m

/-- Three (possibly repeated) sensors in the first 16 cells; site 1 is index zero. -/
def sensorMask (i j k : Fin 16) : Nat := (2^i.val ||| 2^j.val) ||| 2^k.val

private structure Pair where
  a : Nat
  b : Nat
  wordA : Nat
  wordB : Nat

private def pairs : List Pair :=
  [⟨0x48c,0x50c,0xfd7,0xd97⟩, ⟨0xe2c,0xc2c,0x1367,0x1667⟩,
   ⟨0x5f7c,0x3f0c,0xc107,0x4197⟩, ⟨0x5f7c,0x50ac,0xc107,0xd9a7⟩,
   ⟨0x48c,0xcac,0xfd7,0x17a7⟩, ⟨0xe2c,0x2c,0x1367,0x67⟩]

private abbrev PhysicalPair (p : Pair) : Prop :=
  win (rh p.a) 1 ∈ trap ∧ win (rh p.b) 1 ∈ trap ∧ u (rh p.a) 0 = true ∧ u (rh p.b) 0 = true ∧
  encList (win (rh p.a) 1) = p.wordA ∧ encList (win (rh p.b) 1) = p.wordB ∧
  secondEarly (rh p.a) 0 = true ∧ secondEarly (rh p.b) 0 = false

set_option maxRecDepth 10000 in
private theorem physical_pairs (p : Pair) (mem : p ∈ pairs) : PhysicalPair p := by
  simp only [pairs,List.mem_cons,List.not_mem_nil,or_false] at mem
  rcases mem with rfl|rfl|rfl|rfl|rfl|rfl <;> decide +kernel

private def indistinguishable (m : Nat) (p : Pair) : Bool :=
  (p.wordA &&& m) == (p.wordB &&& m)

set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
private theorem cover : ∀ i j k : Fin 16,
    (sensorMask i j k == 448 || pairs.any (indistinguishable (sensorMask i j k))) = true := by
  decide +kernel

/-- Among subsets of at most three sites in the 16-cell window, every choice
other than sites 7, 8 and 9 confuses two finite physical trapped pulses. -/
theorem unique_three_sites (i j k : Fin 16) (other : sensorMask i j k ≠ 448) :
    ∃ R S, Rule30ZeroBoundary.FinSupp R ∧ Rule30ZeroBoundary.FinSupp S ∧
      win R 1 ∈ trap ∧ win S 1 ∈ trap ∧ u R 0 = true ∧ u S 0 = true ∧
      readMask (sensorMask i j k) R = readMask (sensorMask i j k) S ∧
      secondEarly R 0 = true ∧ secondEarly S 0 = false := by
  have hit := cover i j k
  simp only [beq_eq_false_iff_ne.mpr other,Bool.false_or,List.any_eq_true] at hit
  obtain ⟨p,mem,eq⟩ := hit
  rcases physical_pairs p mem with ⟨ha,hb,pa,pb,wa,wb,sa,sb⟩
  refine ⟨rh p.a,rh p.b,Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat _,
    Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat _,ha,hb,pa,pb,?_,sa,sb⟩
  rw [readMask,readMask,wa,wb]
  exact beq_iff_eq.mp eq

end Ruliology.CellularAutomata.WheelTrappedTwoPulse
