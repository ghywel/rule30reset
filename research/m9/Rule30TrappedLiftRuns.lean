module

public import Ruliology.CellularAutomata.Rule30Prize
public import Ruliology.CellularAutomata.Rule30RunOpen
public import Ruliology.CellularAutomata.Rule30GateTrapLadder

/-! Closed runs of four on the kit's freely driven gate-trap ladder. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30TrappedLiftRuns
open Rule30DrivenPrefix Rule30GateTrap Rule30GateTrapLadder Rule30RunWindow Rule30RunOpen
open Rule30StripCertificates Rule30TrappedRuns

private theorem enc_bit : ∀ (xs : List Bool) (i : Nat), (encList xs).testBit i = xs.getD i false
  | [], i => by simp [encList,List.getD_eq_getElem?_getD]
  | b::xs, 0 => by rw [Nat.testBit_zero]; cases b <;> simp [encList] <;> omega
  | b::xs, i+1 => by
    rw [Nat.testBit_succ]
    have e (v : Nat) : ((if b then 1 else 0)+2*v)/2=v := by cases b <;> simp <;> omega
    change (((if b then 1 else 0)+2*encList xs)/2).testBit i = xs.getD i false
    rw [e,enc_bit]

private theorem append_bit (xs : List Bool) (b : Bool) (j : Nat) (h : j<xs.length) :
    (xs++[b]).getD j false = xs.getD j false := by
  simp [List.getD_eq_getElem?_getD,List.getElem?_append,h]

private theorem lin_at : ∀ (j : Nat) (xs : List Bool), j+2<xs.length →
    (lin3 xs).getD j false = xor (xs.getD j false) (xs.getD (j+1) false || xs.getD (j+2) false)
  | j, [], h => by simp at h
  | j, [_], h => by simp at h <;> omega
  | j, [_,_], h => by simp at h <;> omega
  | 0, _::_::_::_, _ => rfl
  | j+1, a::b::c::xs, h => by
    exact lin_at j (b::c::xs) (by simp_all <;> omega)

private theorem tick_list {xs : List Bool} {r m : Nat} (l : Bool) (enough : m+1≤xs.length)
    (agree : ∀ j, j<m+1 → xs.getD j false=r.testBit j) (j : Nat) (hj : j<m) :
    (lin3 (l::xs)).getD j false = (step l r).testBit j := by
  rw [lin_at _ _ (by simp; omega),step_bit]
  cases j with
  | zero =>
    change xor l (xs.getD 0 false || xs.getD 1 false) = xor l (r.testBit 0 || r.testBit 1)
    rw [agree 0 (by omega),agree 1 (by omega)]
  | succ j =>
    change xor (xs.getD j false) (xs.getD (j+1) false || xs.getD (j+2) false) = xor (r.testBit j) (r.testBit (j+1) || r.testBit (j+2))
    rw [agree j (by omega),agree (j+1) (by omega),agree (j+2) (by omega)]

private theorem low_equal {x y k : Nat} (h : ∀ j, j<k → x.testBit j=y.testBit j) :
    x%2^k=y%2^k := by
  apply Nat.eq_of_testBit_eq
  intro j
  rw [Nat.testBit_mod_two_pow,Nat.testBit_mod_two_pow]
  by_cases e : j<k <;> simp [e, h]

/-- At width 46 the second exterior choice can reach column 46. The checked windows
use at most 45 columns. The first exterior choice is included in the packed row. -/
theorem lift_links {W : Nat} {ws : Nat → List Bool} (hW : 46≤W) (hp : LiftPath W ws) :
    Links 45 (fun t => encList (ws t)) := by
  intro t
  obtain ⟨x1,x2,next⟩ := hp.2.2 t
  let xs := ws t
  let q := encList (xs++[x1])
  have len : xs.length=W := hp.length t
  let mid := lin3 (false::(xs++[x1]))
  have ml : mid.length=W := by simp [mid,lin3_length,len]
  have first (j : Nat) (hj : j<46) : mid.getD j false = (step false q).testBit j :=
    tick_list (m := 46) false (by simp [len]; omega)
      (fun v _ => (enc_bit (xs++[x1]) v).symm) j hj
  refine ⟨q,low_equal (fun j hj => ?_),low_equal (fun j hj => ?_)⟩
  · change (encList (xs++[x1])).testBit j = (encList xs).testBit j
    rw [enc_bit,enc_bit,append_bit _ _ _ (by omega)]
  · change (double q).testBit j = (encList (ws (t+1))).testBit j
    rw [next,enc_bit]
    symm
    exact tick_list (xs := mid++[x2]) (r := step false q) (m := 45) true (by simp [ml]; omega) (fun v hv => by
      rw [append_bit mid x2 v (by omega)]; exact first v hv) j hj

private theorem seg_bit : ∀ (f : Nat → Bool) (n j : Nat), j<n → (seg f n).getD j false=f j
  | _,0,_,h => absurd h (by omega)
  | _,_+1,0,_ => rfl
  | f,n+1,j+1,h => seg_bit (fun u => f (u+1)) n j (by omega)

private theorem bounds : trapCodes.all (fun n => decide (n<2^16)) = true := by decide +kernel
private theorem low_trap {xs : List Bool} (h : xs.take 16 ∈ trap) : encList xs % 2^16 ∈ trapCodes := by
  obtain ⟨c,hc,eq⟩ := List.mem_map.mp h
  have limit : c<2^16 := of_decide_eq_true (List.all_eq_true.mp bounds _ hc)
  have id : encList xs % 2^16 = c % 2^16 := by
    apply low_equal
    intro j hj
    have e := congrArg (fun l : List Bool => l.getD j false) eq
    change (seg (fun i => c.testBit i) 16).getD j false = (xs.take 16).getD j false at e
    rw [seg_bit _ _ _ hj] at e
    simpa [enc_bit,List.getD_eq_getElem?_getD,List.getElem?_take,hj] using e.symm
  rwa [id,Nat.mod_eq_of_lt limit]

/-- No width of the kit ladder from 46 upward reads four closed runs after two steps. -/
theorem no_four_on_lift {W : Nat} (hW : 46≤W) {ws : Nat → List Bool}
    (hp : LiftPath W ws) (s : Nat) (hs : 2≤s) :
    ¬ ∀ i, i<96 → (ws (s+i)).headD false = (closed 4).getD i false := by
  intro word
  let start := s-2
  apply no_open_trace (lift_links hW hp) start
  apply of_frames
  intro i hi
  have il : i<98 := by simpa only [show initial.length=98 by decide] using hi
  have ic : i<colours.length := by simpa only [initial,List.length_map] using hi
  have cell : initial[i]'hi = entry (colours[i]'ic) := by simp only [initial,List.getElem_map]
  rw [cell]
  refine ⟨by simp [entry],?_⟩
  have ht := low_trap (hp.take16_mem (by omega) (start+i))
  cases i with
  | zero => exact ht
  | succ i =>
    cases i with
    | zero => exact ht
    | succ i =>
      have il' : i<(closed 4).length := by rw [show (closed 4).length=96 by decide]; omega
      have colour : colours[i+1+1] = some ((closed 4)[i]) := by simp [colours]
      rw [colour]
      apply List.mem_filter.mpr
      refine ⟨ht,beq_iff_eq.mpr ?_⟩
      rw [Nat.testBit_mod_two_pow]
      have time : start+(i+1+1)=s+i := by dsimp [start]; omega
      have w := word i (by omega)
      rw [List.getD_eq_getElem?_getD,List.getElem?_eq_getElem il'] at w
      change (encList (ws (start+(i+1+1)))).testBit 0 = (closed 4)[i]
      rw [enc_bit,time]
      simpa [List.getD_eq_getElem?_getD,List.headD_eq_head?_getD,List.head?_eq_getElem?] using w

/-- No width of the kit ladder from 46 upward reads five blocks from any sample. -/
theorem no_five_on_lift {W : Nat} (hW : 46≤W) {ws : Nat → List Bool}
    (hp : LiftPath W ws) (s : Nat) :
    ¬ ∀ i, i<116 → (ws (s+i)).headD false = five.getD i false := by
  intro word
  have suffix : ∀ i, i<96 → five.getD (20+i) false = (closed 4).getD i false := by decide
  apply no_four_on_lift hW hp (s+20) (by omega)
  intro i hi
  rw [Nat.add_assoc,word (20+i) (by omega),suffix _ hi]


private def strip44 (x : Nat) := seg (fun i => x.testBit i) 44
private def follow (a b : Nat) : Bool :=
  decide (strip44 b = step2 (strip44 a) (a.testBit 44) (a.testBit 45))
private def edges (a : Nat) : List Nat → Bool
  | [] => true
  | b::bs => follow a b && edges b bs
private def coast (w : List Bool) : Nat → List Bool
  | 0 => w
  | n+1 => step2 (coast w n) false false
private def walk44 (a : Nat) : List Nat → Nat → List Bool
  | [], n => coast (strip44 a) n
  | _::_, 0 => strip44 a
  | b::bs, n+1 => walk44 b bs n

private theorem walk_zero (a : Nat) (bs : List Nat) : walk44 a bs 0 = strip44 a := by
  cases bs <;> rfl

private theorem walk_next {a : Nat} {bs : List Nat} (ok : edges a bs) (n : Nat) :
    ∃ x y, walk44 a bs (n+1) = step2 (walk44 a bs n) x y := by
  induction bs generalizing a n with
  | nil => exact ⟨false,false,by simp only [walk44,coast]⟩
  | cons b bs ih =>
    obtain ⟨localStep,tail⟩ := Bool.and_eq_true_iff.mp ok
    cases n with
    | zero => exact ⟨a.testBit 44, a.testBit 45, (walk_zero b bs).trans (of_decide_eq_true localStep)⟩
    | succ n => exact ih tail n

-- Each integer carries the 44 cells, followed by its two exterior choices.
private def first44 : Nat := 251490522
private def rest44 : List Nat := [
    1057861496, 3807884183, 16428689178, 17655611477672, 48651827486375, 39451745367694,
    7000882740828, 9232369550442, 8276727919272, 14837065032359, 14871157510798, 17012327252572,
    3940897835114, 16592948627368, 2866707881383, 11200010907534, 10110095880540, 322906548586,
    1160561517032, 5486283841383, 1706712687566, 24557952161436, 4771541868090, 37792453223800,
    422781666711, 1720951318298, 24253393538728, 6319900081831, 8537250555534, 49202549869148,
    18420718864490, 16715602544552, 37685340482983, 172156534670, 714396131676, 37968941571434,
    37689766735336, 17795461398119, 49148712567950, 18576930414684, 52523949791594, 9501329990120,
    4964005519207, 18067425899470, 50262029035164, 8788720699962, 13211386841464, 12176552419735,
    15962322624026, 24672171976168, 5419916084839, 2192509118606, 7717483258972, 16292672176746,
    8564016679080, 13757757203623, 9261987790990, 8498960499292, 15237645822058, 16477792757672,
    7732109004199, 16385958352782, 8031831710044, 16620396474730, 3022738827752, 11821916955495,
    12860811908558, 15257931634332, 15781574696506, 4916429940088, 3113343501719, 12996015073050,
    14069908672168, 9948425903783, 1039692621454, 3993286249052, 17178671990890, 1313530316712,
    4723665640871, 2254012825486, 10656209264988, 3198023228778, 12524676443624, 17332807564903,
    821091419278, 3033210101852, 12891107367274, 15194174022120, 16263690035047, 8292302140366,
    14615367927452, 14342184315450, 14220923251064, 10937278112151, 3445705121306, 13263448126952,
    12423540790887]

/-- The freely driven width-44 strip actually reads the four-run word at delay two. -/
theorem four_at_width44 : ∃ ws, LiftPath 44 ws ∧ ∀ i, i<96 →
    (ws (2+i)).headD false = (closed 4).getD i false := by
  let ws := walk44 first44 rest44
  have checks : edges first44 rest44 = true := by decide +kernel
  refine ⟨ws,⟨length_seg 44 _,?_,walk_next checks⟩,?_⟩
  · exact List.mem_map.mpr ⟨28890, by decide +kernel, by decide +kernel⟩
  · decide +kernel

end Ruliology.CellularAutomata.Rule30TrappedLiftRuns
