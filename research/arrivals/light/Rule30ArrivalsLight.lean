module

public import Ruliology.CellularAutomata.Rule30Ether
public import Ruliology.CellularAutomata.Rule30MaskedJen
public import Ruliology.CellularAutomata.Rule30StripCertificates
public import Ruliology.CellularAutomata.Rule30DrivenPrefix
public meta import Lean.Elab.Term

/-!
# Beside an alternating column every right half enters a closed set that decodes its net

Drive a right half of rule 30, of any support, by the column that alternates, black first (`drv altCol R`; in general any `F` with
`IsR30 F` and `Alt F T`). Sample it at the white ticks. The *kick* is the first cell (`gate`), the *net* the first cell
exclusive-or the second (`net`; on the single cell this is Lowry's net, `lowry_at_white`), and the *black net* is the first cell
without the second at the black tick after it (`blackNet`, Lowry's net there).

* **The law** (`law_of_alt`). Where the next white tick is not a kick, the net is complemented. Where it is, the net before it was
  white. So the net of a kick is black exactly when its next kick is an even number of white ticks later (`net_of_return`), and two
  successive nets are equal exactly at a kick with white net (`odd_of_equal_nets`). The law is local. It needs no closed set.
* **The closed set.** `closedSet` is 777 windows of the first twelve cells at a white tick. A half in it stays in it, whatever
  lies beyond (`stays`), and from there its kicks have gaps 2 to 5 and the gate reads none of ten words (`clean_of_set`).
* **Entry.** Every right half enters, or its kicks eventually come once in four (`every_half`, `enters_or_four`).
* **The decoders.** In the set the kick is a function of nine nets (`kick_of_white_nets`), and the odd kicks, whose next one is three
  or five white ticks later (`odd_iff`), are read by two black nets four ticks apart (`odd_of_black_nets`).
* **Periodicity.** In the set the gate, the net and the odd kicks are eventually periodic together, and if the black net is
  eventually periodic then so is the gate (`periodic_together`).
* **The single cell.** If its centre ever alternates, then by masked Jen it enters (`single_enters`), and none of these streams is
  eventually periodic. The same holds for Lowry's net and shell on either phase (`both_phases`, `odd_kicks_aperiodic`,
  `lowry_odd_return`). That the centre does alternate is the open question.

The proof is one table of sets of times on spatial prefixes, walked once against itself with a white and a black tick as the step
(the method of `Rule30TrappedRunMasks`). No `Rule30PeriodTwoWidth13` is used, and the file checks in about nine seconds.
The decoders are a search over words, and the local law is a table of six cells.

What is known. The gate words are GE2, and that every right half is eventually in GE2 or reads pure fours is the content of
`Rule30PeriodTwoWidth13.path_run` (AIOvernight), from a rank certificate of 16,384 nodes of a strip of thirteen cells; the single
cell excludes the fours by `not_pure4`. What is added here is an explicit set of twelve-cell windows that is closed, the entry into
it, and 2, 2, 5, which I203's strip of six cells excludes, as one of its words. Lowry's net, shell and two-step identity are those of
`Rule30SourceArrivals` (kit pull request 374). The three streams of the single cell are gptIntel's (I203), and so is the dictionary of
the parity of the next kick (K50.2), proved here again from six cells.
-/

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Rule30ArrivalsLight
open Ruliology.CellularAutomata
open Rule30Jen Rule30Ether Rule30MaskedJen Rule30StripCertificates
open Rule30DrivenPrefix (step step_bit)
open Rule30PeriodTwoCoupled (altCol)

/-! ### Sets of times on spatial prefixes, carried from `Rule30TrappedRunMasks` -/

/-- Leaves describe the sample times a prefix may reach. Each node stores the intersection
of its children as a lower bound and their union as an upper bound. Branches read spatial
bits from low to high. The table checks these bounds before they can be used. -/
inductive Tree where
  | leaf (m : Nat)
  | node (low high : Nat) (zero one : Tree)
  deriving Inhabited

def Tree.low : Tree → Nat
  | .leaf m => m
  | .node lo _ _ _ => lo

def Tree.high : Tree → Nat
  | .leaf m => m
  | .node _ hi _ _ => hi

def Tree.child (a : Tree) (b : Bool) : Tree :=
  match a with
  | .leaf _ => a
  | .node _ _ l r => if b then r else l

def Tree.valid : Tree → Bool
  | .leaf _ => true
  | .node lo hi a b => (lo == a.low &&& b.low) && (hi == a.high ||| b.high) && a.valid && b.valid

def Tree.value (a : Tree) (r j : Nat) : Nat :=
  match a with
  | .leaf m => m
  | .node _ _ l h => if r.testBit j then h.value r (j+1) else l.value r (j+1)

/-- Every time set in a is also set in b. -/
def subset (a b : Nat) : Bool := (a &&& b) == a

theorem Tree.bounds {a : Tree} (h : a.valid = true) (r k t : Nat) :
    (a.low.testBit t = true → (a.value r k).testBit t = true) ∧
    ((a.value r k).testBit t = true → a.high.testBit t = true) := by
  induction a generalizing k with
  | leaf m => exact ⟨id,id⟩
  | node lo hi a b ia ib =>
    simp only [Tree.valid, Bool.and_eq_true, beq_iff_eq] at h
    obtain ⟨⟨⟨rfl,rfl⟩,va⟩,vb⟩ := h
    have ba := ia va (k+1)
    have bb := ib vb (k+1)
    simp only [Tree.low,Tree.high,Tree.value,Nat.testBit_and,Nat.testBit_or,Bool.and_eq_true,Bool.or_eq_true]
    cases e : r.testBit k
    · simp only [Bool.false_eq_true,ite_false]; exact ⟨fun p => ba.1 p.1,fun p => Or.inl (ba.2 p)⟩
    · simp only [ite_true]; exact ⟨fun p => bb.1 p.2,fun p => Or.inr (bb.2 p)⟩

theorem Tree.child_valid {a : Tree} (va : a.valid = true) (b : Bool) :
    (a.child b).valid = true := by
  cases a with
  | leaf => rfl
  | node lo hi l r =>
    simp only [Tree.valid,Bool.and_eq_true] at va
    cases b
    · exact va.1.2
    · exact va.2

theorem Tree.child_value (a : Tree) (r k : Nat) :
    (a.child (r.testBit k)).value r (k+1) = a.value r k := by
  cases a with
  | leaf => rfl
  | node lo hi l h => cases e : r.testBit k <;> simp [Tree.child,Tree.value,e]

theorem subset_sound {a b : Nat} (h : subset a b = true) {t : Nat} (ht : a.testBit t = true) :
    b.testBit t = true := by
  have eq := congrArg (fun v : Nat => v.testBit t) (beq_iff_eq.mp h : a &&& b = a)
  simpa [Nat.testBit_and,ht] using eq

/-! ### One period of the drive, and the finite checks -/

/-- One period: the white tick and the black tick, beside the drive colours `d0`, `d1`, of a packed row. -/
def per (d0 d1 : Bool) (x : Nat) : Nat := step d1 (step d0 x)

/-- The walk. Node `a` has read `k+3` cells of a row and `b` the first `k+1` cells of the row one period later. The four colours
are cells `k+1`, `k+2` of the row and `k`, `k+1` of the row after one tick. A branch closes when every time of `a`, moved one
step on and cut to the colours allowed, is a time of `b`. -/
def walk (colours : Nat) (a b : Tree) (x1 x2 y0 y1 : Bool) : Nat → Bool
  | 0 => subset ((a.high <<< 1) &&& colours) b.low
  | n+1 =>
    if subset ((a.high <<< 1) &&& colours) b.low then true else
    let y := xor x1 x2
    let y' := !x1
    walk colours (a.child false) (b.child (xor y0 (y1 || y))) x2 false y1 y n &&
    walk colours (a.child true) (b.child (xor y0 (y1 || y'))) x2 true y1 y' n

/-- The walk from the first three cells, which fix the first cell one period later. -/
def walkAt (table : Tree) (white black : Nat) (d0 d1 x0 x1 x2 : Bool) : Bool :=
  let y0 := xor d0 (x0 || x1)
  let y1 := xor x0 (x1 || x2)
  let w := xor d1 (y0 || y1)
  walk (if w then black else white) (((table.child x0).child x1).child x2) (table.child w) x1 x2 y0 y1 46

def walkAll (table : Tree) (white black : Nat) (d0 d1 : Bool) : Bool :=
  [false, true].all fun a => [false, true].all fun b => [false, true].all fun c => walkAt table white black d0 d1 a b c

/-- A property of every time set at a leaf. -/
def leaves (p : Nat → Bool) : Tree → Bool
  | .leaf m => p m
  | .node _ _ a b => leaves p a && leaves p b

/-- The codes of `n` more cells whose rows carry the time `t`. -/
def codes (t : Nat) (a : Tree) (k p : Nat) : Nat → List Nat
  | 0 => if a.high.testBit t then [p] else []
  | n+1 => if a.high.testBit t then codes t (a.child false) (k+1) p n ++ codes t (a.child true) (k+1) (p+2^k) n else []

/-- The time `t` depends on the first cells only. -/
def tight (t : Nat) (a : Tree) : Nat → Bool
  | 0 => a.high.testBit t == a.low.testBit t
  | n+1 => (a.high.testBit t == a.low.testBit t) || (tight t (a.child false) n && tight t (a.child true) n)

/-- Both colours are allowed at `n` successive times after `o`. -/
def freeFrom (white black o n : Nat) : Bool :=
  (List.range n).all fun i => white.testBit (o+(i+1)) && black.testBit (o+(i+1))

/-- A letter of a pattern: a colour, or any. -/
def fits (a : Option Bool) (c : Bool) : Bool :=
  match a with
  | none => true
  | some b => b == c

/-- A pattern on the line `o`: its start from the closed set, its colours, and its death. -/
def wordLine (T : Tree) (white black o : Nat) (v : List (Option Bool)) : Bool :=
  ([false, true].all fun c => !fits (v.headD none) c || leaves (fun m => !m.testBit 0 || m.testBit o) (T.child c)) &&
  ((List.range (v.length - 1)).all fun i => [false, true].all fun c =>
    !fits (v.getD (i+1) none) c || (if c then black else white).testBit (o+(i+1))) &&
  ([false, true].all fun c => !fits (v.getD (v.length - 1) none) c ||
    leaves (fun m => !m.testBit (o + (v.length - 1))) (T.child c))

/-- Bit 0 of the table says that the first twelve cells are in the list. -/
def isTrap (T : Tree) (trap : List Nat) : Bool :=
  codes 0 T 0 0 12 == trap && tight 0 T 12

/-- The windows of `W` cells one period after the window `x`, whatever the two cells beyond. -/
def images (d0 d1 : Bool) (W x : Nat) : List Nat := (List.range 4).map fun e => per d0 d1 (x+2^W*e) % 2^W

/-- Windows with a next one in the list. -/
def back (d0 d1 : Bool) (W : Nat) (A : List Nat) : List Nat := A.filter fun x => (images d0 d1 W x).any A.contains
/-- Windows with one before in the list. -/
def fwd (d0 d1 : Bool) (W : Nat) (A : List Nat) : List Nat := A.filter (A.flatMap (images d0 d1 W)).contains
def rounds (d0 d1 : Bool) (W : Nat) : Nat → List Nat → List Nat
  | 0, A => A
  | n+1, A => rounds d0 d1 W n (fwd d0 d1 W (back d0 d1 W A))
/-- The windows with one more cell. -/
def widen (W : Nat) (A : List Nat) : List Nat := A ++ A.map (· + 2^W)
/-- At each width so many rounds, then one more cell. -/
def chase (d0 d1 : Bool) : Nat → List Nat → List Nat → List Nat
  | _, [], A => A
  | W, r :: rs, A => chase d0 d1 (W+1) rs (widen W (rounds d0 d1 W r A))

/-! ### The table -/

/-- The payload: 207 time sets and 810 branches. -/
meta def leafData : Array Nat := #[
  0x3a8ce33170e3218a79001ffc, 0x3a8ce33170e3218a783ffffc, 0x3a8ce33170e3218a780003fc, 0x3a8ce33170e3218a7803fffc,
  0x3a8ce33170e3218a7807fffc, 0x3a8ce33170e3218a781ffffc, 0x3a8ce33170e3218a7800003c, 0x3a8ce33170e3218a7800000c,
  0x3a8ce33170e3218a78000004, 0x3a0de3717063608a787ffffc, 0x3a0de3717063608a783ffffc, 0x3a0de3717063608a78ffffff,
  0x3a0de3717063608a79001ffc, 0x3a0de3717063608a7800007c, 0x3a0de3717063608a78000004, 0x3a0de3717063608a781ffffc,
  0x3a8de3717063608a78ffffff, 0x3a8de3717063608a787ffffc, 0x3a8de3717063608a7800000c, 0x3a8de3717063608a78000004,
  0x3a8ce33170e3218a7801fffc, 0x3a8ce33170e3218a78000ffc, 0x3a8ce33170e3218a7800001c, 0x3a8ce33170e3218a78ffffff,
  0x3a8ce33170e3218a787ffffc, 0x388de37170e3618a7800003c, 0x388de37170e3618a7800000c, 0x388de37170e3618a78ffffff,
  0x388de37170e3618a783ffffc, 0x388de37170e3618a787ffffc, 0x388de37170e3618a7800001c, 0x388de37170e3618a79001ffc,
  0x388de37170e36188787ffffc, 0x388de37170e3618878ffffff, 0x388de37170e3618878000004, 0x388de37130e3618878000004,
  0x388de37130e3618878ffffff, 0x388de37130e36188787ffffc, 0x388de37130e361887800007c, 0x388de37130e36188780ffffc,
  0x6a99e67372c6659a19001ffc, 0x6a99e67372c6659a1807fffc, 0x6a99a66372e6659a1807fffc, 0x6a99a66372e6659a1800000c,
  0x6a99a66372e6659a1800fffc, 0x6a99e67372c6659a1800000c, 0x6a99e67372c6659a183ffffc, 0x6a99e67372c6659a181ffffc,
  0x6a99e67372c6659a1800001c, 0x6a99e67372c6659a18ffffff, 0x6a99e67372c6659a187ffffc, 0x6a99a66372e6659a180007fc,
  0x6a99a66372e6659a19001ffc, 0x6a99a66372e6659a1800007c, 0x6a99a66372e6659a18000ffc, 0x6a99a66372e6659a1801fffc,
  0x6a99e67372e6659a1800000c, 0x6a99e67372e6659a18000004, 0x6a99e67372e6659a181ffffc, 0x6a99e67372e6659a180ffffc,
  0x6a99e67362e6659a18ffffff, 0x6a99e67362e6659a187ffffc, 0x6a99e67362e6659a1800001c, 0x6a99e67362e6659a1800000c,
  0x6a99a67372c6659a187ffffc, 0x6a99a67372c6659a180ffffc, 0x6a99a67372c6659a183ffffc, 0x6a99a67372c6659a1807fffc,
  0x6a99a67372c6659a1800000c, 0x6a99a67372c6659a1800007c, 0x6a99a67372c6659a180000fc, 0x6a99e67372c6659a180000fc,
  0x6a99e67372c6659a18000ffc, 0x6a99a67372c6659a18000004, 0x6a99a66372c6659a18000004, 0x6a99a66372e6659a18000004,
  0x6a99a67362e6659a18000004, 0x6a99a67362e6659a1800000c, 0x6a99a67372e6659a1800000c, 0x6a99a67372e6659a18000004,
  0x6a99e67362e6659a183ffffc, 0x6a99e67372e6659a18ffffff, 0x6a99e67372e6659a183ffffc, 0x6a99e67372e6659a187ffffc,
  0x6a99e67372e6659a1800003c, 0x6a99e67372e6659a1800001c, 0x5a95e57272e565923800001c, 0x5a95e57272e565923800000c,
  0x5a95e57272e56592383ffffc, 0x5a95e57272e56592381ffffc, 0x5a95e57252e5659238ffffff, 0x5a95e57252e56592387ffffc,
  0x5a95e57252e5659238000004, 0x5a95e57252e565923800003c, 0x5a95e57252e565923800000c, 0x5a95655272e545923800001c,
  0x5a95655272e5459238000004, 0x5a95655272e5459239001ffc, 0x5a95655272e5459238000ffc, 0x5a95655272e545923800fffc,
  0x5a95655272e54592380ffffc, 0x5a95655272e54592381ffffc, 0x5a95655272e545923803fffc, 0x5a95655272e545923800000c,
  0x5a95e57272a54512381ffffc, 0x5a95e57272a5451239001ffc, 0x5a95e57272a54512387ffffc, 0x5a95e57272a54512380ffffc,
  0x5a95655272e54512380ffffc, 0x5a95655272e54512381ffffc, 0x5a95655272e545123801fffc, 0x5a95655272e5451239001ffc,
  0x5a95655272e545123803fffc, 0x5a95655272e545123800001c, 0x5a95e57272a5451238ffffff, 0x5a95e57272a54512380001fc,
  0x5a95e57272a545123800003c, 0x5a95e57272a54512383ffffc, 0x5a95e57272a545123800001c, 0x5a95e57272a565123800003c,
  0x5a95e57272a565123800000c, 0x5a95e57272a5651238ffffff, 0x5a95e57272a5651239001ffc, 0x5a95e57272a56512387ffffc,
  0x5a95e57272a56512383ffffc, 0x5a95e57272a565123800001c, 0x5a95e57272e5659238ffffff, 0x5a95e57272e56592387ffffc,
  0x5a95e57272e5659238000004, 0x5a95e57272e565923800007c, 0x5295455252a5659208000004, 0x5295655352a5659a08ffffff,
  0x5295655352a5659a087ffffc, 0x5295655352a5659a0800000c, 0x5295655352a5659a08000004, 0x5295655352a5659a083ffffc,
  0x5295455352a5659a08000004, 0x5295455352a5659a09001ffc, 0x5295455352a5659a0803fffc, 0x5295455352a5659a0800003c,
  0x5295455352a5659a080003fc, 0x5295655352a5659a080ffffc, 0x5295455352a5659a0800000c, 0x54010008900124503001ffc,
  0x54010008900124502007ffc, 0x540100889001245021ffffc, 0x540100889001245020ffffc, 0x54010088900124502000004,
  0x540100889001245027ffffc, 0x54010008910124502000004, 0x54010008910124503001ffc, 0x540100089101245020007fc,
  0x54010088910124502000004, 0x5401008891012450207fffc, 0x540100889101245020ffffc, 0x540100881101245023ffffc,
  0x54010088110124502000004, 0x5401008890012450200007c, 0x540100889001245023ffffc, 0x540100881101245027ffffc,
  0x5401008891012450200001c, 0x44210888810904502000004, 0x44210888810904502ffffff, 0x44210888810904503001ffc,
  0x442108888109045027ffffc, 0x442108888109045023ffffc, 0x54210888810904502000004, 0x50210888810904502000004,
  0x54210888810904502ffffff, 0x542108888109045027ffffc, 0x54010008900124502000004, 0x54010088900124503001ffc,
  0x5401008890012450200001c, 0x5401000891012450200fffc, 0x5401008890012450203fffc, 0x5401008890012450200003c,
  0x5401008890012450207fffc, 0x5401000891012450200003c, 0x54010008910124502007ffc, 0x5401000891012450203fffc,
  0x54010088910124502ffffff, 0x540100889101245027ffffc, 0x540100889101245023ffffc, 0x5401008891012450200000c,
  0x14010080900124102000004, 0x14010000910124102000004, 0x14010080110124102000004, 0x14010080910124102000004,
  0x14010000900124102000004, 0x14000080910124102000004, 0x14210888910924502ffffff, 0x14210888910924502000004,
  0x1420088891092450200001c, 0x14200888910924502000ffc, 0x14200888910924503001ffc, 0x14200888910924502000004,
  0x1421088891092450207fffc, 0x142108889109245027ffffc, 0x142108889109245023ffffc, 0x1421088891092450200007c,
  0x54210880910924102ffffff, 0x542108809109241027ffffc, 0x54210880910924102000004, 0x542108809109241023ffffc,
  0x542108809109241021ffffc, 0x54210880910920102000004, 0x54210880910824102000004]
meta def chunkData : Array Nat := #[

  0xed00e700ec00ea00e400eb000b000f00e900e8000f000a000f000900e600e5000b000e00e4000d000b0009000b00e200e100e0000c000b000b00df000a000900dd00d900dc00db0007000800da00050005000100d800d500d7000600d600070001000500d400d100d300d2000500040004000300d000cf0002000000010000,
  0x40006010c000500000015000500d6010901070007010800070006001401060000010500030000010300f0010200fa010100fe010000f600ff00100010001200fd00fc00f5001300fb00f200f6001300f900f400f800f500f200f700f60010001100100012001000f30010001000f200f100100010001100ef00de00ee00e3,
  0x12d0127012c012a012b001b001b001d01290128001d001b001c001b012600190019001a0124010401230117012200080121011c011f0120011f011e00170008011d0017001700180017011b011a01190007001700170118001700030116011101150114001600070112011301120016001600080110010a010f010b010e010d,
  0x14d014a0140014c012c014b0129001b0149014701480019012b012b012b0146012b0145001d001c0143013f014201400141001b0128001a012c001b013e013c013d001e001e001b001b012c013a013301390134013801360137001a001a001f0135012c0128001e0130001b0132012e01310130001b0019012f012c001b001a,
  0x16d0160016c01690168016b0024016a015b002401680167015c015d016601630165015b016400260027002401620161002300240024015a015f0159015e0023015d0024015c015b00240023015a002400240025015801550157002201560021015100200153015401530152002100220151015100210020014f013b014e0144,
  0x3b003a018c00380038018b018a0038003800390188017e0187002b0186018201850184002a002b002a01830037003401810180003600350034017f00340033017d0179017c002d017b0031002f017a002f0032017801750177002d00300176002f002e017401720173002b002a002c002a017100290028016f0125016e0150,
  0x4401ad0044004601ab01a601aa01a8002a01a9002b004401a700450043004401a501a001a401a201a30035002c0037003401a1002c0034019f019e004400430042019d00410040019b0189019a018d0199019501980197003c003f0196003e003e003f0194018f019301910192003c003c003d0190003c003d003c018e0038,
  0x1cd019c01cc01af01cb01ba01ca01c101c901c6003001c801bb01c70031004801c501c301c4002800280048002f01c20032002e01c001be01bf002d0030003101bd01bc01b7002d01bb00310031003201b901b401b801b601b700320032003101b500310031003001b3003101b201b0004701b1002e00320047003101ae01ac,
  0x1ed01ec0051003801eb005100510053005101e901e800510052005101e601e4019201e501920193003c01e301e201e100380051005101e0003c005001de01d701dd004c01dc01d801db01da004d004c01d9004e004e004f004e004d01d601d201d5004a01d4002b01d3002b002b004b01cf01d101cf01d001cf004400440049,
  0x20d020a0056020c0056020b00590058020900560057005602070170020601ce020501df020401f2020301f8020201fe020101ff01ec020001fc00540055005101fd01fb01fc00390053005101fa01f9003b003901eb01eb01f701f6005101f301f501f301e201f4005101eb005101ec01f101e701f001ef0054018b01ee01ea,
  0x22d0067022b022c022b00670067006002290220022802240227006002260225006400610061006602230222006400600064022100650064021f021a021e021c0063021d00630062021b0061006200610219005f0060005f0217020e021602140215005e0210005a02130212005d005c02110210005a005c020f005a005a005b,
  0x76024d006b0075024b0249024a007400750072024800720072006a02460244024500720073006a0243007202420073006a006802400237023f023c0071023e006c023d006e0070023b02390070023a0070006e006f0238006f006e023602330235006c0234006c006d006c006b0232006a023100690068022f0218022e022a,
  0x7e007f026c0230026b0253026a0260026902660268007902540267025c0079026502610254026402630262007c007b007b007c0079007d025f025a025e0078025d025b025c007b0079007b0079007c025902550258007802570256007b007a007a0079025400770079007802520241025102470250024c024f024e00760072,
  0x210028d005b005e028b028a028a0210005a005e0288027c028700800286028002850283028400800081007e0282026f028100800058007e007e027f027e007e026e027d007f007e027b0276027a008002710279007e02780277007e0059007e0275027302740080026f007e02720271008100800270026f007e0080026e007e,
  0x2ad02a002ac02a502ab02a902aa026f0281005602a802a70057007e007e02a6007e005802a402a202a300800056007e02a1005b0292005c029f029e02150215029d005a02980210029b0291029a029702990212005a0298005a020f02960294021002950292005a029302100292005e005b005a0290028c028f028e005e005c,
  0x2b5008602cc02b302cb00860087008302c902bf02c802c4008502c702c502c602c5008500850086008502c3008302c202c10083008502c00084008302be02b902bd02bc02b4008602ba02bb02ba02b30083008502b802b602b70083008302b302b502b40085008302b3008302b200830083008402b0026d02af028902ae029c,
  0x2ed0095009502ec0097009602ea02e90094009302e802e7009200910090008f02e5020802e402b102e3008202e202ca02e102d502e0008802df02dd02de02c6008e008802dc02da02db02b3008d008502d902d7008902d80089008c008b02d6008a008902d402d202d3008602c602b402d102cf02d00086008502b502ce02cd,
  0x30d00a2030c00a200a200a4030a030900a100a200a300a2030702f9030602fd0098030503040302030300a000a00098030102ff0300009f009b009f009b02fe009f009b009c02fc02fb009c009802fa0098009c02f802f402f70093009302f602f5009d009e009402f302ef02f20098009c02f1009b02f0009a009902ee02eb,
  0x32d031a032c031d00a6032b032a032503290328032000a6032603270326031f00a800a603240322032300a800a8031f0321032000a600a8031f00a8031e00a800a800a900a6031c00a6031b00a700a603190308031800a100a103170316030f03150312031400a100a2031300a200a50311030d031000a100a500a4030e030b,
  0x9100b000ae034c00ad0096034a03480093034900ac009d034703430346034500ab00930092034400910092009e0342034100940091009e033f033b0093033e0093033d033c009303390093033a0334033903380095032f009303370336009300950335009500aa0098033300930332009303310330032f00aa009300950093,
  0x36d036b036c009800b600b40099036a00b500b60368036700b700b400a000b40365036303640098035d00b40362035f0361009800b4036000b400b6035e035d00b40098035c00b400b400b5035a034b035903540358035600af035700ae00b3035500b100b1009503530350035200b100b1035100b20096034f034d034e00af,
  0x38d038a038c00b8038b038300bc00b900b8038900b9038300bb038703860383038500ba00bb038400bb00ba00b900b80381032e03800340037f0372037e0378037d037b0093037c009300950095037a009c037900980373037700980376037502fb037300980374009c0373009c00980371035b03700366036f0098036e0369,
  0xbf00be03ac039e03ab00bb03aa03a600bb03a900bb03a800bd03a700bb039f03a500bb03a403a103a3039f00bb03a200bb00bd00bb03a000bd039f00bd00bb039d0394039c039a0385039b00ba00b900b90399039803950397039600b8039500b9039500b800b9039303880392038e00b8039100b8039000b8038f00b800bc,
  0xbe03b703c003c103cb03c803ca00be00be03c903b703b703c703c603c500be00be03c500be00c703c303bb00bf03c203c103be03c003bf00be00bf03b700be00be03bd03bc00be00c600be03ba03b003b903b403b803b503b703b600be00c500be00c400bf00c303b303b200c200c303b100c000c200c100be03af03ae00be,
  0x3ed03d403ec03e203eb00ca03ea03e903d703d803e803e503d603e703e600c800c900c803e400c803d503e300c800cc03e103df03e000ca03d800c803de03dc03dd00ca03d600c803db03d803da00ca00c803d900c800cb03d703d600c800ca03d500c800c800c903d303c403d203cc03d103cd03d003cf03bf00be03bf03ce,
  0x3f702e603f6038203f503ad03f403ee03f303ef03f203f000ca03f100ca00ce00ce00cd00cd00ca]

open Lean in
/-- Each 32-bit word of a chunk holds two earlier 16-bit node indices, low word first. The elaborator only proposes a tree;
every property of it is checked in the kernel. -/
meta def makeTree (leafMasks branchChunks : Array Nat) (branchCount : Nat) : MetaM Expr := do
  let mut nodes : Array (Nat × Nat × Expr) := #[]
  for m in leafMasks do
    nodes := nodes.push (m,m,mkApp (mkConst ``Tree.leaf) (mkNatLit m))
  for i in [:branchCount] do
    let pair := (branchChunks[i/32]! >>> (32*(i%32))) % 2^32
    let (loA,hiA,left) := nodes[pair%65536]!
    let (loB,hiB,right) := nodes[pair/65536]!
    let lo := loA &&& loB
    let hi := hiA ||| hiB
    nodes := nodes.push (lo,hi,mkApp4 (mkConst ``Tree.node) (mkNatLit lo) (mkNatLit hi) left right)
  return nodes.back!.2.2

open Lean Elab Term in
noncomputable def table01 : Tree := by_elab
  liftM (makeTree leafData chunkData 810)

def white01 : Nat := 0x7a9de77372e7659af0ffdffa
def black01 : Nat := 0x8522088485088a2404ffdffa

/-- The closed set: 777 windows of the first twelve cells at a white tick, the first cell in the low bit. -/
def closedSet : List Nat := [
  1088, 3136, 576, 2624, 320, 2368, 1344, 3392, 832, 2880, 1856, 3904, 3264, 1728, 3776, 3008, 4032, 32, 2080, 1056,
  3104, 544, 2592, 1568, 3616, 288, 2336, 3360, 800, 2848, 1824, 3872, 160, 2208, 1184, 3232, 416, 2464, 1440, 928,
  2976, 4000, 96, 2144, 3168, 1632, 864, 2912, 224, 2272, 1248, 3296, 480, 2528, 1504, 3552, 2016, 4064, 2160, 1136,
  3184, 624, 2672, 368, 2416, 1392, 3440, 880, 2928, 1904, 3952, 240, 2288, 3312, 1776, 3824, 1008, 3056, 2032, 4080,
  264, 1288, 776, 2824, 3848, 136, 2184, 3208, 1672, 3720, 904, 2952, 1928, 3976, 72, 2120, 1096, 3144, 584, 2632,
  1608, 3656, 328, 2376, 3400, 1864, 3912, 200, 2248, 3272, 1736, 40, 2088, 3112, 552, 2600, 1576, 3624, 808, 2856,
  168, 2216, 1192, 3240, 680, 2728, 3752, 424, 2472, 1448, 3496, 1960, 3176, 1640, 3688, 2920, 3944, 232, 2280, 1256,
  744, 2792, 3816, 488, 2536, 1512, 3560, 1000, 3048, 4072, 2072, 3096, 1560, 3608, 792, 2840, 1816, 3864, 408, 2456,
  1432, 3480, 3992, 216, 2264, 1240, 3288, 728, 2776, 1752, 3800, 472, 2520, 3544, 2008, 4056, 2104, 1080, 3128, 568,
  2616, 312, 2360, 3384, 1848, 184, 2232, 3256, 1720, 3768, 952, 3000, 1976, 4024, 120, 2168, 1144, 3192, 632, 2680,
  3704, 376, 2424, 1400, 3448, 888, 2936, 1912, 3960, 248, 2296, 3320, 1784, 3832, 1016, 3064, 2040, 4088, 388, 2436,
  1412, 3460, 356, 2404, 1380, 868, 2916, 3940, 996, 3044, 2020, 4068, 52, 2100, 1076, 3124, 564, 2612, 1588, 3636,
  308, 2356, 180, 2228, 1204, 3252, 1716, 3764, 948, 2996, 116, 2164, 3188, 1652, 884, 2932, 2548, 3572, 2076, 1052,
  3100, 540, 2588, 284, 2332, 1308, 3356, 796, 2844, 1820, 3868, 156, 2204, 3228, 1692, 3740, 924, 2972, 1948, 3996,
  92, 2140, 1116, 604, 2652, 1628, 3676, 348, 2396, 3420, 1884, 3932, 60, 2108, 3132, 572, 2620, 1596, 3644, 2364,
  1340, 3388, 828, 2876, 188, 2236, 3260, 700, 2748, 1724, 3772, 444, 2492, 1468, 3516, 956, 3004, 1980, 4028, 2172,
  3196, 892, 2940, 252, 2300, 1276, 3324, 1532, 1020, 3068, 4092, 66, 2114, 3138, 1602, 3650, 450, 2498, 1474, 3522,
  962, 3010, 4034, 82, 2130, 1106, 3154, 338, 2386, 1362, 3410, 210, 2258, 3282, 1746, 978, 3026, 1586, 3634, 818,
  1458, 3506, 4018, 626, 2674, 1650, 3698, 1906, 3954, 242, 2290, 1266, 3314, 754, 2802, 1778, 3826, 498, 2546, 3570,
  2034, 4082, 10, 2058, 3082, 1546, 3594, 394, 2442, 1418, 3466, 906, 2954, 3978, 202, 2250, 1226, 714, 2762, 1738,
  3786, 458, 2506, 3530, 1994, 4042, 106, 2154, 1130, 3178, 618, 3690, 362, 2410, 1386, 3434, 874, 2922, 1898, 3946,
  234, 2282, 3306, 1770, 1002, 3050, 538, 2586, 1562, 3610, 282, 2330, 3354, 1818, 3866, 666, 2714, 3738, 90, 2138,
  3162, 1626, 346, 2394, 1370, 858, 2906, 3930, 218, 2266, 3290, 1754, 3802, 2522, 1498, 3546, 986, 3034, 2010, 4058,
  58, 2106, 1082, 3130, 570, 2618, 1594, 3642, 314, 2362, 3386, 2874, 1850, 3898, 186, 2234, 1210, 3258, 698, 2746,
  3770, 442, 2490, 1466, 3514, 954, 3002, 4026, 1658, 890, 2938, 2298, 1274, 3322, 762, 2810, 506, 2554, 3578, 2042,
  14, 2062, 1038, 3086, 526, 2574, 3598, 270, 2318, 1294, 3342, 142, 2190, 1166, 3214, 654, 2702, 1678, 3726, 398,
  2446, 3470, 910, 2958, 1934, 3982, 78, 2126, 3150, 1614, 3662, 846, 2894, 1870, 3918, 462, 2510, 1486, 3534, 974,
  3022, 4046, 46, 2094, 1070, 3118, 558, 302, 2350, 1326, 3374, 814, 2862, 1838, 3886, 30, 2078, 3102, 1566, 798,
  2846, 414, 2462, 222, 2270, 1246, 3294, 734, 2782, 3806, 382, 2430, 3454, 49, 2097, 561, 2609, 305, 2353, 1329,
  3377, 817, 2865, 3889, 177, 2225, 3249, 2993, 1969, 4017, 25, 2073, 1049, 3097, 537, 2585, 3609, 281, 2329, 1305,
  3353, 153, 2201, 1177, 3225, 665, 2713, 1689, 3737, 409, 2457, 3481, 921, 2969, 1945, 3993, 89, 2137, 3161, 1625,
  3673, 857, 2905, 1881, 3929, 473, 2521, 1497, 3545, 985, 3033, 4057, 45, 2093, 3117, 1581, 3629, 2861, 1837, 3885,
  429, 2477, 1453, 3501, 941, 2989, 4013, 237, 2285, 749, 2797, 2029, 7, 2055, 1031, 3079, 519, 2567, 263, 2311,
  1287, 3335, 775, 2823, 1799, 3847, 2951, 3975, 71, 2119, 1095, 583, 2631, 1607, 3655, 327, 2375, 3399, 1863, 3911,
  1063, 3111, 551, 2599, 1575, 3623, 295, 2343, 1319, 3367, 1831, 3879, 167, 2215, 1191, 3239, 679, 2727, 1703, 3751,
  2471, 3495, 935, 2983, 1959, 4007, 103, 2151, 3175, 1639, 3687, 871, 2919, 1895, 3943, 2279, 1255, 3303, 743, 2791,
  3815, 487, 2535, 1511, 3559, 999, 3047, 4071, 23, 2071, 3095, 1559, 3607, 2839, 1815, 3863, 407, 2455, 1431, 3479,
  919, 2967, 3991, 215, 2263, 1239, 3287, 727, 2775, 1751, 3799, 471, 2519, 3543, 2007, 4055, 119, 2167, 1143, 3191,
  2679, 3703, 375, 2423, 1399, 887, 2935, 3959, 247, 2295, 3319, 1783, 3831, 1015, 3063, 2039, 4087]

/-- The windows of 12 cells that can stay outside the closed set. -/
def outside01 : List Nat := [
  0, 1024, 1600, 3648, 16, 1040, 3088, 3472, 968, 3016, 4, 2244, 1220, 3268, 452, 276, 1300, 3348, 756, 2804, 3828,
  290, 2338, 1314, 2978, 1954, 2066, 2194, 1170, 3218, 2866, 1842, 126, 2686, 1662, 3710, 1, 769, 1073, 3121, 1805,
  3853, 77, 845, 3207, 1671, 3719]

/-- The gate words that no row of the closed set reads, each with the place of its line in a mask. -/
def lines01 : List (Nat × List (Option Bool)) := [
  (25, [some true, some true]),
  (27, [some false, some false, some false, some false, some false]),
  (32, [some true, some false, some true, some false, some false, some true]),
  (38, [some true, some false, some false, some true, some false, some true]),
  (44, [some true, some false, some false, some true, some false, some false, some false, some true]),
  (52, [some true, some false, some false, some false, some true, some false, some true]),
  (59, [some true, some false, some false, some false, some true, some false, some false, some true]),
  (67, [some true, some false, some false, some false, some true, some false, some false, some false, some true]),
  (76, [some true, some false, some false, some false, some false, some true, some false, some false, some false, some true]),
  (86, [some true, some false, some true, some false, some true, some false, some false, some false, some false, some true])]

theorem valid01 : table01.valid = true := by decide +kernel
theorem walk01 : walkAll table01 white01 black01 false true = true := by decide +kernel
theorem free01 : freeFrom white01 black01 0 1 = true := by decide +kernel
theorem wrap01 : leaves (fun m => m.testBit 1 == m.testBit 0) table01 = true := by decide +kernel
theorem isTrap01 : isTrap table01 closedSet = true := by decide +kernel
theorem freeA01 : freeFrom white01 black01 2 10 = true := by decide +kernel
theorem freeB01 : freeFrom white01 black01 13 10 = true := by decide +kernel
theorem first01 : table01.low.testBit 2 = true := by decide +kernel
theorem middle01 : leaves (fun k => !k.testBit (2+10) || (k.testBit 13 || k.testBit 24)) table01 = true := by
  decide +kernel
theorem last01 : leaves (fun k => !k.testBit (13+10) || k.testBit 0) table01 = true := by decide +kernel
theorem outsideCodes01 : codes 24 table01 0 0 12 = outside01 := by decide +kernel
theorem wordLines01 : (lines01.all fun l => wordLine table01 white01 black01 l.1 l.2) = true := by decide +kernel

/-! ### The walk of a table against itself -/

theorem walk_easy {a b : Tree} (va : a.valid = true) (vb : b.valid = true) (x y k t : Nat) {colours : Nat}
    (ok : subset ((a.high <<< 1) &&& colours) b.low = true) (ha : (a.value x (k+2)).testBit t = true)
    (hc : colours.testBit (t+1) = true) : (b.value y k).testBit (t+1) = true := by
  apply (b.bounds vb _ _ _).1
  apply subset_sound ok
  have hi := (a.bounds va _ _ _).2 ha
  simp [Nat.testBit_and, Nat.testBit_shiftLeft, hi, hc]

theorem step_succ (d : Bool) (a j : Nat) :
    (step d a).testBit (j+1) = xor (a.testBit j) (a.testBit (j+1) || a.testBit (j+2)) := by
  rw [step_bit]; simp

theorem step_zero (d : Bool) (a : Nat) : (step d a).testBit 0 = xor d (a.testBit 0 || a.testBit 1) := by
  rw [step_bit]; simp

theorem walk_sound {d0 d1 : Bool} (n : Nat) {a b : Tree} {colours k x t : Nat} {x1 x2 y0 y1 : Bool}
    (ok : walk colours a b x1 x2 y0 y1 n = true) (va : a.valid = true) (vb : b.valid = true)
    (hx1 : x1 = x.testBit (k+1)) (hx2 : x2 = x.testBit (k+2))
    (hy0 : y0 = (step d0 x).testBit k) (hy1 : y1 = (step d0 x).testBit (k+1))
    (ha : (a.value x (k+3)).testBit t = true) (hc : colours.testBit (t+1) = true) :
    (b.value (per d0 d1 x) (k+1)).testBit (t+1) = true := by
  induction n generalizing a b k x1 x2 y0 y1 with
  | zero => exact walk_easy va vb x _ (k+1) t ok ha hc
  | succ n ih =>
    simp only [walk] at ok
    split at ok
    · rename_i h; exact walk_easy va vb x _ (k+1) t h ha hc
    · obtain ⟨l, r⟩ := Bool.and_eq_true_iff.mp ok
      have ey : (step d0 x).testBit (k+2) = xor x1 (x2 || x.testBit (k+3)) := by rw [hx1, hx2, step_succ]
      have ez : (per d0 d1 x).testBit (k+1) = xor y0 (y1 || (step d0 x).testBit (k+2)) := by
        rw [hy0, hy1, per, step_succ]
      have next : ((a.child (x.testBit (k+3))).value x (k+1+3)).testBit t = true := by
        rw [show k+1+3 = (k+3)+1 by omega, Tree.child_value]; exact ha
      have fin : ((b.child ((per d0 d1 x).testBit (k+1))).value (per d0 d1 x) (k+1+1)).testBit (t+1) = true := by
        cases hb : x.testBit (k+3)
        · rw [hb] at next
          rw [hb] at ey
          have ey' : (step d0 x).testBit (k+2) = xor x1 x2 := by rw [ey]; simp
          rw [ey'] at ez
          rw [ez]
          exact ih l (a.child_valid va _) (b.child_valid vb _) hx2 (by rw [hb]) hy1 ey'.symm next
        · rw [hb] at next
          rw [hb] at ey
          have ey' : (step d0 x).testBit (k+2) = !x1 := by rw [ey]; simp
          rw [ey'] at ez
          rw [ez]
          exact ih r (a.child_valid va _) (b.child_valid vb _) hx2 (by rw [hb]) hy1 ey'.symm next
      simpa only [Tree.child_value] using fin

theorem walk_start {table : Tree} {white black : Nat} {d0 d1 : Bool} (ok : walkAll table white black d0 d1 = true)
    (x0 x1 x2 : Bool) : walkAt table white black d0 d1 x0 x1 x2 = true := by
  have m (b : Bool) : b ∈ [false, true] := by cases b <;> simp
  exact List.all_eq_true.mp (List.all_eq_true.mp (List.all_eq_true.mp ok x0 (m _)) x1 (m _)) x2 (m _)

/-- A time of a row passes to the next time of the row one period later, when the first cell there has an allowed colour. -/
theorem walk_all {table : Tree} {white black : Nat} {d0 d1 : Bool} (va : table.valid = true)
    (ok : walkAll table white black d0 d1 = true) (x t : Nat) (ha : (table.value x 0).testBit t = true)
    (hc : (if (per d0 d1 x).testBit 0 then black else white).testBit (t+1) = true) :
    (table.value (per d0 d1 x) 0).testBit (t+1) = true := by
  have w := walk_start ok (x.testBit 0) (x.testBit 1) (x.testBit 2)
  simp only [walkAt] at w
  have y0 : (step d0 x).testBit 0 = xor d0 (x.testBit 0 || x.testBit 1) := step_zero ..
  have y1 : (step d0 x).testBit 1 = xor (x.testBit 0) (x.testBit 1 || x.testBit 2) := step_succ ..
  have w0 : (per d0 d1 x).testBit 0 = xor d1 ((step d0 x).testBit 0 || (step d0 x).testBit 1) := by
    rw [per, step_zero]
  rw [← y0, ← y1, ← w0] at w
  have start : ((((table.child (x.testBit 0)).child (x.testBit 1)).child (x.testBit 2)).value x 3).testBit t = true := by
    rw [show (3:Nat) = 2+1 by rfl, Tree.child_value, show (2:Nat) = 1+1 by rfl, Tree.child_value, show (1:Nat) = 0+1 by rfl,
      Tree.child_value]
    exact ha
  have vc := Tree.child_valid (Tree.child_valid (Tree.child_valid va (x.testBit 0)) (x.testBit 1)) (x.testBit 2)
  have fin := walk_sound (d0 := d0) (d1 := d1) (k := 0) (x := x) (t := t) 46 w vc (Tree.child_valid va _) rfl rfl rfl rfl start hc
  rw [← Tree.child_value table (per d0 d1 x) 0]
  exact fin

/-- The rows at successive periods. -/
def rows (d0 d1 : Bool) (x : Nat) : Nat → Nat
  | 0 => x
  | i+1 => per d0 d1 (rows d0 d1 x i)

/-- A row carries its time along a line for as long as its first cells have the line's colours. -/
theorem march {table : Tree} {white black : Nat} {d0 d1 : Bool} (va : table.valid = true)
    (ok : walkAll table white black d0 d1 = true) {x o n : Nat} (start : (table.value x 0).testBit o = true)
    (cols : ∀ i, i < n → (if (rows d0 d1 x (i+1)).testBit 0 then black else white).testBit (o+(i+1)) = true) :
    ∀ i, i ≤ n → (table.value (rows d0 d1 x i) 0).testBit (o+i) = true := by
  intro i
  induction i with
  | zero => intro _; exact start
  | succ i ih =>
    intro hi
    exact walk_all va ok _ (o+i) (ih (by omega)) (cols i (by omega))

/-! ### Reading a table -/

theorem leaves_value {p : Nat → Bool} {a : Tree} (h : leaves p a = true) (r k : Nat) : p (a.value r k) = true := by
  induction a generalizing k with
  | leaf m => exact h
  | node lo hi a b ia ib =>
    simp only [leaves, Bool.and_eq_true] at h
    simp only [Tree.value]
    split
    · exact ib h.2 _
    · exact ia h.1 _

theorem mem_codes {t : Nat} (n : Nat) {a : Tree} (va : a.valid = true) {k p r : Nat} (hp : p = r % 2^k)
    (h : (a.value r k).testBit t = true) : r % 2^(k+n) ∈ codes t a k p n := by
  induction n generalizing a k p with
  | zero =>
    have hi := (a.bounds va r k t).2 h
    simp [codes, hi, hp]
  | succ n ih =>
    have hi := (a.bounds va r k t).2 h
    simp only [codes, hi, ite_true, List.mem_append]
    have kid := Tree.child_value a r k
    have split : r % 2^(k+1) = r % 2^k + 2^k * (r / 2^k % 2) := by rw [Nat.pow_succ]; exact Nat.mod_mul ..
    have bit := Nat.testBit_eq_decide_div_mod_eq (x := r) (i := k)
    have lt : r / 2^k % 2 < 2 := Nat.mod_lt _ (by decide)
    rw [show k+(n+1) = k+1+n by omega]
    cases hb : r.testBit k
    · left
      have z : r / 2^k % 2 = 0 := by rw [hb] at bit; simp at bit; omega
      refine ih (a.child_valid va _) (by rw [split, z, hp]; simp) ?_
      rw [hb] at kid; rw [kid]; exact h
    · right
      have z : r / 2^k % 2 = 1 := by rw [hb] at bit; simpa using bit.symm
      refine ih (a.child_valid va _) (by rw [split, z, hp]; simp) ?_
      rw [hb] at kid; rw [kid]; exact h

theorem codes_low {t : Nat} (n : Nat) {a : Tree} {k p c : Nat} (hp : p < 2^k) (hc : c ∈ codes t a k p n) : c % 2^k = p := by
  induction n generalizing a k p with
  | zero =>
    simp only [codes] at hc
    split at hc
    · rw [List.mem_singleton.mp hc]; exact Nat.mod_eq_of_lt hp
    · simp at hc
  | succ n ih =>
    simp only [codes] at hc
    split at hc
    · have two : (2:Nat)^(k+1) = 2^k + 2^k := by rw [Nat.pow_succ]; omega
      have dvd : (2:Nat)^k ∣ 2^(k+1) := ⟨2, Nat.pow_succ ..⟩
      rcases List.mem_append.mp hc with h | h
      · have e := ih (by omega) h
        rw [← Nat.mod_mod_of_dvd c dvd, e, Nat.mod_eq_of_lt hp]
      · have e := ih (by omega) h
        rw [← Nat.mod_mod_of_dvd c dvd, e, Nat.add_mod_right, Nat.mod_eq_of_lt hp]
    · simp at hc

/-- A row whose next `n` cells are those of a listed code carries the time. -/
theorem codes_bit {t : Nat} (n : Nat) {a : Tree} (va : a.valid = true) (ht : tight t a n = true) {k p c r : Nat}
    (hp : p < 2^k) (hc : c ∈ codes t a k p n) (same : ∀ i, i < n → r.testBit (k+i) = c.testBit (k+i)) :
    (a.value r k).testBit t = true := by
  have easy (hi : a.high.testBit t = true) (e : (a.high.testBit t == a.low.testBit t) = true) : (a.value r k).testBit t = true := by
    apply (a.bounds va r k t).1
    rw [← beq_iff_eq.mp e]
    exact hi
  induction n generalizing a k p with
  | zero =>
    simp only [codes] at hc
    split at hc
    · rename_i hi; exact easy hi ht
    · simp at hc
  | succ n ih =>
    simp only [codes] at hc
    split at hc
    · rename_i hi
      simp only [tight, Bool.or_eq_true, Bool.and_eq_true] at ht
      rcases ht with ht | ⟨tl, tr⟩
      · exact easy hi ht
      · have two : (2:Nat)^(k+1) = 2^k + 2^k := by rw [Nat.pow_succ]; omega
        have e0 : r.testBit k = c.testBit k := same 0 (by omega)
        have rest : ∀ i, i < n → r.testBit (k+1+i) = c.testBit (k+1+i) := fun i hi => by
          have := same (i+1) (by omega)
          rw [show k+(i+1) = k+1+i by omega] at this; exact this
        have fin (b : Bool) (tb : tight t (a.child b) n = true) (q : Nat) (hq : q < 2^(k+1))
            (h : c ∈ codes t (a.child b) (k+1) q n) (hb : c.testBit k = b) : (a.value r k).testBit t = true := by
          rw [← Tree.child_value a r k, e0, hb]
          refine ih (a.child_valid va _) tb hq h rest (fun hi e => ?_)
          apply ((a.child b).bounds (a.child_valid va _) r (k+1) t).1
          rw [← beq_iff_eq.mp e]
          exact hi
        rcases List.mem_append.mp hc with h | h
        · refine fin false tl p (by omega) h ?_
          have low := codes_low n (by omega) h
          have b := congrArg (fun v : Nat => v.testBit k) low
          simp only [Nat.testBit_mod_two_pow] at b
          rw [Nat.testBit_lt_two_pow hp] at b
          simpa using b
        · refine fin true tr (p+2^k) (by omega) h ?_
          have low := codes_low n (by omega) h
          have b := congrArg (fun v : Nat => v.testBit k) low
          simp only [Nat.testBit_mod_two_pow] at b
          rw [show p+2^k = 2^k+p from Nat.add_comm .., Nat.testBit_two_pow_add_eq, Nat.testBit_lt_two_pow hp] at b
          simpa using b
    · simp at hc

/-! ### The three kinds of line -/

section
variable {T : Tree} {white black : Nat} {d0 d1 : Bool}

theorem free_march (va : T.valid = true) (ok : walkAll T white black d0 d1 = true) {x o n : Nat}
    (free : freeFrom white black o n = true) (start : (T.value x 0).testBit o = true) :
    (T.value (rows d0 d1 x n) 0).testBit (o+n) = true := by
  refine march va ok start (fun i hi => ?_) n (Nat.le_refl _)
  have f := List.all_eq_true.mp free i (List.mem_range.mpr hi)
  simp only [Bool.and_eq_true] at f
  split
  · exact f.2
  · exact f.1

/-- **The closed set.** Bit 0 is carried to the row one period later. -/
theorem bit_closed (va : T.valid = true) (ok : walkAll T white black d0 d1 = true)
    (free : freeFrom white black 0 1 = true) (wrap : leaves (fun m => m.testBit 1 == m.testBit 0) T = true) {x : Nat}
    (h : (T.value x 0).testBit 0 = true) : (T.value (per d0 d1 x) 0).testBit 0 = true := by
  have a := free_march va ok (n := 1) free h
  have l := beq_iff_eq.mp (leaves_value wrap (per d0 d1 x) 0)
  rw [← l]
  exact a

theorem bit_stays (va : T.valid = true) (ok : walkAll T white black d0 d1 = true)
    (free : freeFrom white black 0 1 = true) (wrap : leaves (fun m => m.testBit 1 == m.testBit 0) T = true) {x : Nat}
    (h : (T.value x 0).testBit 0 = true) : ∀ i, (T.value (rows d0 d1 x i) 0).testBit 0 = true
  | 0 => h
  | i+1 => bit_closed va ok free wrap (bit_stays va ok free wrap h i)

/-- **Entry.** After `m + n` periods every row is in the closed set, unless after `m` it has the exceptional bit `e`. -/
theorem bit_entry (va : T.valid = true) (ok : walkAll T white black d0 d1 = true) {A B m n e : Nat}
    (freeA : freeFrom white black A m = true) (freeB : freeFrom white black B n = true)
    (first : T.low.testBit A = true)
    (middle : leaves (fun k => !k.testBit (A+m) || (k.testBit B || k.testBit e)) T = true)
    (last : leaves (fun k => !k.testBit (B+n) || k.testBit 0) T = true) (x : Nat) :
    (T.value (rows d0 d1 x m) 0).testBit e = true ∨
      (T.value (rows d0 d1 (rows d0 d1 x m) n) 0).testBit 0 = true := by
  have a := free_march va ok freeA ((T.bounds va x 0 A).1 first)
  have c := leaves_value middle (rows d0 d1 x m) 0
  rw [a] at c
  simp only [Bool.not_true, Bool.false_or, Bool.or_eq_true] at c
  rcases c with b | b
  · right
    have f := free_march va ok freeB b
    have l := leaves_value last (rows d0 d1 (rows d0 d1 x m) n) 0
    rw [f] at l
    simpa using l
  · exact Or.inl b

theorem mem_colours (c : Bool) : c ∈ [false, true] := by cases c <;> simp

/-- **A pattern that no row of the closed set reads.** -/
theorem bit_word (va : T.valid = true) (ok : walkAll T white black d0 d1 = true) {o : Nat} {v : List (Option Bool)}
    (line : wordLine T white black o v = true) (pos : 0 < v.length) {x : Nat} (h : (T.value x 0).testBit 0 = true)
    (read : ∀ i, i < v.length → fits (v.getD i none) ((rows d0 d1 x i).testBit 0) = true) : False := by
  simp only [wordLine, Bool.and_eq_true] at line
  obtain ⟨⟨st, cl⟩, en⟩ := line
  have kid (y : Nat) (t : Nat) (hy : (T.value y 0).testBit t = true) :
      ((T.child (y.testBit 0)).value y 1).testBit t = true := by rw [Tree.child_value T y 0]; exact hy
  have start : (T.value x 0).testBit o = true := by
    have r0 := read 0 pos
    have hd : v.headD none = v.getD 0 none := by cases v <;> rfl
    have s := List.all_eq_true.mp st _ (mem_colours (x.testBit 0))
    rw [hd] at s
    rw [show rows d0 d1 x 0 = x from rfl] at r0
    rw [r0] at s
    simp only [Bool.not_true, Bool.false_or] at s
    have l := leaves_value s x 1
    rw [kid x 0 h] at l
    rw [← Tree.child_value T x 0]
    simpa using l
  have all := march (n := v.length - 1) va ok start (fun i hi => by
    have c := List.all_eq_true.mp (List.all_eq_true.mp cl i (List.mem_range.mpr hi)) _ (mem_colours ((rows d0 d1 x (i+1)).testBit 0))
    rw [read (i+1) (by omega)] at c
    simpa using c) (v.length - 1) (Nat.le_refl _)
  have e := List.all_eq_true.mp en _ (mem_colours ((rows d0 d1 x (v.length-1)).testBit 0))
  rw [read (v.length - 1) (by omega)] at e
  simp only [Bool.not_true, Bool.false_or] at e
  have l := leaves_value e (rows d0 d1 x (v.length-1)) 1
  rw [kid _ _ all] at l
  simp at l

end

/-! ### Packed rows of an evolution -/

/-- `x` holds the first `L` cells of the half at tick `t`. -/
def Fits (F : Nat → Nat → Bool) (t x L : Nat) : Prop := ∀ j, j < L → x.testBit j = F t (j+1)

theorem Fits.mono {F : Nat → Nat → Bool} {t x L M : Nat} (h : Fits F t x L) (le : M ≤ L) : Fits F t x M :=
  fun j hj => h j (by omega)

theorem fits_step {F : Nat → Nat → Bool} (hF : IsR30 F) {t x L : Nat} {d : Bool} (h0 : F t 0 = d) (h : Fits F t x (L+1)) :
    Fits F (t+1) (step d x) L := by
  intro j hj
  rw [step_bit, hF t j, h j (by omega), h (j+1) (by omega)]
  unfold Rule30Jen.rule
  cases j with
  | zero => simp [h0]
  | succ j => simp [h j (by omega)]

theorem fits_per {F : Nat → Nat → Bool} (hF : IsR30 F) {t x L : Nat} {d0 d1 : Bool} (h0 : F t 0 = d0)
    (h1 : F (t+1) 0 = d1) (h : Fits F t x (L+2)) : Fits F (t+2) (per d0 d1 x) L :=
  fits_step hF h1 (fits_step hF h0 h)

/-- The drive reads `d0 d1` over the `n` periods from `t`. -/
def Drive (F : Nat → Nat → Bool) (d0 d1 : Bool) (t n : Nat) : Prop :=
  ∀ i, i < n → F (t+2*i) 0 = d0 ∧ F (t+2*i+1) 0 = d1

theorem fits_rows {F : Nat → Nat → Bool} (hF : IsR30 F) {t x L n : Nat} {d0 d1 : Bool} (hd : Drive F d0 d1 t n)
    (h : Fits F t x (L+2*n)) : ∀ i, i ≤ n → Fits F (t+2*i) (rows d0 d1 x i) (L+2*(n-i)) := by
  intro i
  induction i with
  | zero => intro _; exact h
  | succ i ih =>
    intro hi
    obtain ⟨h0, h1⟩ := hd i (by omega)
    have f := ih (by omega)
    rw [show L+2*(n-i) = L+2*(n-(i+1))+2 by omega] at f
    exact fits_per hF h0 h1 f

/-- The first `n` cells of the half at tick `t`, as a number, the first cell in the low bit. -/
def code (F : Nat → Nat → Bool) (t n : Nat) : Nat := encList (seg (fun j => F t (j+1)) n)

theorem prefix_bit : ∀ (n : Nat) (f : Nat → Bool) (j : Nat), (encList (seg f n)).testBit j = (decide (j < n) && f j)
  | 0, _, j => by simp [seg, encList]
  | n+1, f, 0 => by
    rw [Nat.testBit_zero]
    simp only [seg, encList]
    cases f 0 <;> simp <;> omega
  | n+1, f, j+1 => by
    rw [Nat.testBit_succ]
    change (((if f 0 then 1 else 0) + 2 * encList (seg (fun i => f (i+1)) n)) / 2).testBit j = _
    have e (a : Nat) : ((if f 0 then 1 else 0) + 2*a) / 2 = a := by cases f 0 <;> simp <;> omega
    rw [e, prefix_bit n _ j]
    simp

theorem code_bit (F : Nat → Nat → Bool) (t n j : Nat) : (code F t n).testBit j = (decide (j < n) && F t (j+1)) :=
  prefix_bit n _ j

theorem fits_code (F : Nat → Nat → Bool) (t L : Nat) : Fits F t (code F t L) L := by
  intro j hj
  rw [code_bit]
  simp [hj]

theorem code_of_fits {F : Nat → Nat → Bool} {t x L n : Nat} (h : Fits F t x L) (le : n ≤ L) : x % 2^n = code F t n := by
  apply Nat.eq_of_testBit_eq
  intro j
  rw [Nat.testBit_mod_two_pow, code_bit]
  by_cases hj : j < n
  · simp [hj, h j (by omega)]
  · simp [hj]

theorem code_lt (F : Nat → Nat → Bool) (t n : Nat) : code F t n < 2^n := by
  rw [← code_of_fits (fits_code F t n) (Nat.le_refl n)]
  exact Nat.mod_lt _ (Nat.two_pow_pos n)

theorem cell_of_code {F : Nat → Nat → Bool} {t n c : Nat} (h : code F t n = c) {j : Nat} (hj : j < n) :
    F t (j+1) = c.testBit j := by
  rw [← h, code_bit]
  simp [hj]

/-! ### The trap of a table -/

/-- The first twelve cells of the half at tick `t` are a window of the list. -/
def InTrap (trap : List Nat) (F : Nat → Nat → Bool) (t : Nat) : Prop := code F t 12 ∈ trap

section
variable {T : Tree} {trap : List Nat}

theorem trap_of_bit (va : T.valid = true) (is : isTrap T trap = true) {F : Nat → Nat → Bool} {t x L : Nat}
    (h : Fits F t x L) (le : 12 ≤ L) (hb : (T.value x 0).testBit 0 = true) : InTrap trap F t := by
  simp only [isTrap, Bool.and_eq_true] at is
  have m := mem_codes (t := 0) 12 va (k := 0) (p := 0) (r := x) (by simp [Nat.mod_one]) hb
  rw [beq_iff_eq.mp is.1, Nat.zero_add] at m
  unfold InTrap
  rw [← code_of_fits h le]
  exact m

theorem bit_of_trap (va : T.valid = true) (is : isTrap T trap = true) {F : Nat → Nat → Bool} {t x L : Nat}
    (h : Fits F t x L) (le : 12 ≤ L) (hb : InTrap trap F t) : (T.value x 0).testBit 0 = true := by
  simp only [isTrap, Bool.and_eq_true] at is
  refine codes_bit 12 va is.2 (k := 0) (p := 0) (c := code F t 12) (by decide) (by rw [beq_iff_eq.mp is.1]; exact hb)
    (fun i hi => ?_)
  rw [Nat.zero_add, code_bit, h i (by omega)]
  simp [hi]

end

/-! ### The trap is closed, and entry -/

theorem rows_add (d0 d1 : Bool) (x a : Nat) : ∀ b, rows d0 d1 x (a+b) = rows d0 d1 (rows d0 d1 x a) b
  | 0 => rfl
  | b+1 => by rw [← Nat.add_assoc]; exact congrArg _ (rows_add d0 d1 x a b)

theorem Drive.mono {F : Nat → Nat → Bool} {d0 d1 : Bool} {t n m : Nat} (h : Drive F d0 d1 t n) (le : m ≤ n) :
    Drive F d0 d1 t m := fun i hi => h i (by omega)

theorem Drive.shift {F : Nat → Nat → Bool} {d0 d1 : Bool} {t n : Nat} (k : Nat) (h : Drive F d0 d1 t (k+n)) :
    Drive F d0 d1 (t+2*k) n := by
  intro i hi
  have := h (k+i) (by omega)
  rwa [show t+2*(k+i) = t+2*k+2*i by omega] at this

section
variable {T : Tree} {white black : Nat} {d0 d1 : Bool} {trap : List Nat} {F : Nat → Nat → Bool}

theorem trap_row (va : T.valid = true) (ok : walkAll T white black d0 d1 = true)
    (free : freeFrom white black 0 1 = true) (wrap : leaves (fun m => m.testBit 1 == m.testBit 0) T = true)
    (is : isTrap T trap = true) (hF : IsR30 F) {t n : Nat} (hd : Drive F d0 d1 t n) (h : InTrap trap F t) :
    ∃ x, (∀ i, i ≤ n → Fits F (t+2*i) (rows d0 d1 x i) (12+2*(n-i))) ∧
      ∀ i, (T.value (rows d0 d1 x i) 0).testBit 0 = true := by
  have f := fits_code F t (12+2*n)
  exact ⟨_, fits_rows hF hd f, bit_stays va ok free wrap (bit_of_trap va is f (by omega) h)⟩

theorem trap_stays (va : T.valid = true) (ok : walkAll T white black d0 d1 = true)
    (free : freeFrom white black 0 1 = true) (wrap : leaves (fun m => m.testBit 1 == m.testBit 0) T = true)
    (is : isTrap T trap = true) (hF : IsR30 F) {t n : Nat} (hd : Drive F d0 d1 t n) (h : InTrap trap F t) :
    InTrap trap F (t+2*n) := by
  obtain ⟨x, fx, bx⟩ := trap_row va ok free wrap is hF hd h
  exact trap_of_bit va is (fx n (Nat.le_refl _)) (by omega) (bx n)

theorem trap_entry (va : T.valid = true) (ok : walkAll T white black d0 d1 = true) (is : isTrap T trap = true)
    {A B m n e W : Nat} {outs : List Nat} (freeA : freeFrom white black A m = true) (freeB : freeFrom white black B n = true)
    (first : T.low.testBit A = true) (middle : leaves (fun k => !k.testBit (A+m) || (k.testBit B || k.testBit e)) T = true)
    (last : leaves (fun k => !k.testBit (B+n) || k.testBit 0) T = true) (outCodes : codes e T 0 0 W = outs)
    (hF : IsR30 F) {t : Nat} (hd : Drive F d0 d1 t (m+n)) : InTrap trap F (t+2*(m+n)) ∨ code F (t+2*m) W ∈ outs := by
  have f := fits_code F t (12+W+2*(m+n))
  have fx := fits_rows hF hd f
  rcases bit_entry va ok freeA freeB first middle last (code F t (12+W+2*(m+n))) with h | h
  · right
    have mem := mem_codes (t := e) W va (k := 0) (p := 0) (r := rows d0 d1 (code F t (12+W+2*(m+n))) m)
      (by simp [Nat.mod_one]) h
    rw [outCodes, Nat.zero_add, code_of_fits (fx m (by omega)) (by omega)] at mem
    exact mem
  · left
    rw [← rows_add] at h
    exact trap_of_bit va is (fx (m+n) (Nat.le_refl _)) (by omega) h

/-- A half that is not in the trap at a tick was outside, and showed an exceptional window, at every earlier one. -/
theorem outside_before (va : T.valid = true) (ok : walkAll T white black d0 d1 = true)
    (free : freeFrom white black 0 1 = true) (wrap : leaves (fun m => m.testBit 1 == m.testBit 0) T = true)
    (is : isTrap T trap = true) {A B m n e W : Nat} {outs : List Nat} (freeA : freeFrom white black A m = true)
    (freeB : freeFrom white black B n = true) (first : T.low.testBit A = true)
    (middle : leaves (fun k => !k.testBit (A+m) || (k.testBit B || k.testBit e)) T = true)
    (last : leaves (fun k => !k.testBit (B+n) || k.testBit 0) T = true) (outCodes : codes e T 0 0 W = outs)
    (hF : IsR30 F) {t q : Nat} (hd : Drive F d0 d1 t (m+n+q)) (no : ¬ InTrap trap F (t+2*(m+n+q))) :
    ∀ i, i ≤ q → code F (t+2*m+2*i) W ∈ outs := by
  intro i hi
  have hd' := (hd.mono (m := i+(m+n)) (by omega)).shift i
  rcases trap_entry va ok is freeA freeB first middle last outCodes hF hd' with h | h
  · exfalso
    apply no
    have tail := (hd.mono (m := (i+(m+n))+(q-i)) (by omega)).shift (i+(m+n))
    rw [show t+2*(i+(m+n)) = t+2*i+2*(m+n) by omega] at tail
    have s := trap_stays va ok free wrap is hF tail h
    rwa [show t+2*i+2*(m+n)+2*(q-i) = t+2*(m+n+q) by omega] at s
  · rwa [show t+2*i+2*m = t+2*m+2*i by omega] at h

end

/-! ### The windows that can stay outside -/

theorem image_mem {F : Nat → Nat → Bool} (hF : IsR30 F) {d0 d1 : Bool} {t : Nat} (hd : Drive F d0 d1 t 1) (W : Nat) :
    code F (t+2) W ∈ images d0 d1 W (code F t W) := by
  obtain ⟨h0, h1⟩ := hd 0 (by omega)
  have f := fits_code F t (W+2)
  have g := code_of_fits (fits_per hF h0 h1 f) (Nat.le_refl W)
  refine List.mem_map.mpr ⟨code F t (W+2) / 2^W, ?_, ?_⟩
  · have lt := code_lt F t (W+2)
    rw [List.mem_range, Nat.div_lt_iff_lt_mul (Nat.two_pow_pos W)]
    rw [Nat.pow_add] at lt
    omega
  · have m := code_of_fits (f.mono (M := W) (by omega)) (Nat.le_refl W)
    show per d0 d1 (code F t W + 2^W * (code F t (W+2) / 2^W)) % 2^W = code F (t+2) W
    rw [← m, Nat.mod_add_div]
    exact g

/-- The window is in the list at `n + 1` successive periods from `t`. -/
def Among (F : Nat → Nat → Bool) (t n W : Nat) (A : List Nat) : Prop := ∀ i, i ≤ n → code F (t+2*i) W ∈ A

section
variable {F : Nat → Nat → Bool} {d0 d1 : Bool}

theorem among_round (hF : IsR30 F) {t n W : Nat} {A : List Nat} (hd : Drive F d0 d1 t (n+2)) (h : Among F t (n+2) W A) :
    Among F (t+2) n W (fwd d0 d1 W (back d0 d1 W A)) := by
  have im (i : Nat) (hi : i < n+2) : code F (t+2*(i+1)) W ∈ images d0 d1 W (code F (t+2*i) W) := by
    have := image_mem hF ((hd.mono (m := i+1) (by omega)).shift i) W
    rwa [show t+2*i+2 = t+2*(i+1) by omega] at this
  have b (i : Nat) (hi : i < n+2) : code F (t+2*i) W ∈ back d0 d1 W A := by
    refine List.mem_filter.mpr ⟨h i (by omega), List.any_eq_true.mpr ⟨_, im i hi, ?_⟩⟩
    exact List.contains_iff_mem.mpr (h (i+1) (by omega))
  intro i hi
  rw [show t+2+2*i = t+2*(i+1) by omega]
  refine List.mem_filter.mpr ⟨b (i+1) (by omega), List.contains_iff_mem.mpr ?_⟩
  exact List.mem_flatMap.mpr ⟨_, b i (by omega), im i (by omega)⟩

theorem among_rounds (hF : IsR30 F) {W : Nat} : ∀ (r : Nat) {t n : Nat} {A : List Nat}, Drive F d0 d1 t (n+2*r) →
    Among F t (n+2*r) W A → Among F (t+2*r) n W (rounds d0 d1 W r A)
  | 0, _, _, _, _, h => h
  | r+1, t, n, A, hd, h => by
    have s := among_round hF (n := n+2*r) hd h
    have d := ((hd.mono (m := 1+(n+2*r)) (by omega)).shift 1)
    have q := among_rounds hF r (t := t+2) (n := n) d s
    rwa [show t+2+2*r = t+2*(r+1) by omega] at q

theorem among_widen {t n W : Nat} {A : List Nat} (h : Among F t n W A) : Among F t n (W+1) (widen W A) := by
  intro i hi
  have a := h i hi
  rw [← code_of_fits ((fits_code F (t+2*i) (W+1)).mono (M := W) (by omega)) (Nat.le_refl W)] at a
  have lt := code_lt F (t+2*i) (W+1)
  have split := Nat.mod_add_div (code F (t+2*i) (W+1)) (2^W)
  have two : code F (t+2*i) (W+1) / 2^W < 2 := by
    apply Nat.div_lt_of_lt_mul
    rwa [Nat.pow_succ] at lt
  have either : code F (t+2*i) (W+1) / 2^W = 0 ∨ code F (t+2*i) (W+1) / 2^W = 1 := by
    revert two
    generalize code F (t+2*i) (W+1) / 2^W = d
    omega
  rw [← split]
  rcases either with e | e
  · rw [e, Nat.mul_zero, Nat.add_zero]
    exact List.mem_append.mpr (Or.inl a)
  · rw [e, Nat.mul_one]
    exact List.mem_append.mpr (Or.inr (List.mem_map.mpr ⟨_, a, rfl⟩))

theorem among_chase (hF : IsR30 F) : ∀ (rs : List Nat) {W t n : Nat} {A : List Nat}, Drive F d0 d1 t (n+2*rs.sum) →
    Among F t (n+2*rs.sum) W A → Among F (t+2*rs.sum) n (W+rs.length) (chase d0 d1 W rs A)
  | [], _, _, _, _, _, h => h
  | r :: rs, W, t, n, A, hd, h => by
    have e : n+2*(r :: rs).sum = (n+2*rs.sum)+2*r := by rw [List.sum_cons]; omega
    rw [e] at hd h
    have s := among_widen (among_rounds hF r hd h)
    have d := (hd.mono (m := r+(n+2*rs.sum)) (by omega)).shift r
    have q := among_chase hF rs d s
    have e1 : t+2*r+2*rs.sum = t+2*(r :: rs).sum := by rw [List.sum_cons]; omega
    have e2 : W+1+rs.length = W+(r :: rs).length := by rw [List.length_cons]; omega
    rwa [e1, e2] at q

end

/-! ### The net on a driven half obeys a local law -/

/-- Column `0` alternates from `T`: black at `T + 2k`, white at `T + 2k + 1`. -/
def Alt (F : Nat → Nat → Bool) (T : Nat) : Prop := ∀ k, F (T+2*k) 0 = true ∧ F (T+2*k+1) 0 = false

/-- The gate, or kick: the first cell at the `k`-th white tick. -/
def gate (F : Nat → Nat → Bool) (T k : Nat) : Bool := F (T+2*k+1) 1
/-- The net at the white tick: the first cell exclusive-or the second. -/
def net (F : Nat → Nat → Bool) (T k : Nat) : Bool := xor (F (T+2*k+1) 1) (F (T+2*k+1) 2)
/-- The net at the black tick after the white one: the first cell without the second. -/
def blackNet (F : Nat → Nat → Bool) (T k : Nat) : Bool := F (T+2*k+2) 1 && !F (T+2*k+2) 2

/-- The cells of a row at a white tick are those of the black row before it, whose wall is black; the two ticks after it are
those of two more. Checked on the cells of the black row before. -/
theorem localLaw : ∀ c1 c2 c3 c4 c5 c6 : Bool,
    let x := rule true c1 c2; let y := rule c1 c2 c3; let z := rule c2 c3 c4; let w := rule c3 c4 c5; let v := rule c4 c5 c6
    let x' := rule true (rule false x y) (rule x y z)
    let y' := rule (rule false x y) (rule x y z) (rule y z w)
    let z' := rule (rule x y z) (rule y z w) (rule z w v)
    let x'' := rule true (rule false x' y') (rule x' y' z')
    (x' = false → xor x' y' = !(xor x y)) ∧ (x' = true → xor x y = false) ∧ (x = true → x' = false) ∧
    (x = true → xor x y = true → (rule false x y && !rule x y z) = true → x'' = false) ∧
    ((rule false x y && !rule x y z) = true → x = true) ∧
    (x = true → xor x y = false → (rule false x y && !rule x y z) = true) := by
  decide +kernel

/-- The law of the gate `g`, the net `a` and the black net `b`. -/
structure Law (g a b : Nat → Bool) : Prop where
  toggle : ∀ k, g (k+1) = false → a (k+1) = !a k
  reset : ∀ k, g (k+1) = true → a k = false
  lone : ∀ k, g k = true → g (k+1) = false
  skip : ∀ k, g k = true → a k = true → b k = true → g (k+2) = false
  black : ∀ k, b k = true → g k = true
  odd : ∀ k, g k = true → a k = false → b k = true

theorem Law.shift {g a b : Nat → Bool} (L : Law g a b) (m : Nat) : Law (fun k => g (m+k)) (fun k => a (m+k)) (fun k => b (m+k)) where
  toggle k h := L.toggle (m+k) h
  reset k h := L.reset (m+k) h
  lone k h := L.lone (m+k) h
  skip k := L.skip (m+k)
  black k := L.black (m+k)
  odd k := L.odd (m+k)

/-- **The law.** On every right half beside an alternating column, at every white tick: at a tick that is not a kick the net is
the complement of the one before; at a kick the net before was white; kicks stand alone; and the black net sees only kicks,
every kick whose net is white, and a kick whose net is black only if the one after next is white. -/
theorem law_of_alt {F : Nat → Nat → Bool} (hF : IsR30 F) {T : Nat} (h : Alt F T) : Law (gate F T) (net F T) (blackNet F T) := by
  have main (k : Nat) :
      (gate F T (k+1) = false → net F T (k+1) = !net F T k) ∧ (gate F T (k+1) = true → net F T k = false) ∧
      (gate F T k = true → gate F T (k+1) = false) ∧
      (gate F T k = true → net F T k = true → blackNet F T k = true → gate F T (k+2) = false) ∧
      (blackNet F T k = true → gate F T k = true) ∧
      (gate F T k = true → net F T k = false → blackNet F T k = true) := by
    generalize hu : T+2*k = u
    have hb : F u 0 = true := by rw [← hu]; exact (h k).1
    have hw : F (u+1) 0 = false := by rw [← hu]; exact (h k).2
    have hb' : F (u+2) 0 = true := by have := (h (k+1)).1; rwa [show T+2*(k+1) = u+2 by omega] at this
    have hw' : F (u+3) 0 = false := by have := (h (k+1)).2; rwa [show T+2*(k+1)+1 = u+3 by omega] at this
    have hb'' : F (u+4) 0 = true := by have := (h (k+2)).1; rwa [show T+2*(k+2) = u+4 by omega] at this
    have e0 : F (u+1) 1 = rule true (F u 1) (F u 2) := by rw [← hb]; exact hF u 0
    have e1 : F (u+1) 2 = rule (F u 1) (F u 2) (F u 3) := hF u 1
    have e2 : F (u+1) 3 = rule (F u 2) (F u 3) (F u 4) := hF u 2
    have e3 : F (u+1) 4 = rule (F u 3) (F u 4) (F u 5) := hF u 3
    have e4 : F (u+1) 5 = rule (F u 4) (F u 5) (F u 6) := hF u 4
    have m1 : F (u+2) 1 = rule false (F (u+1) 1) (F (u+1) 2) := by rw [← hw]; exact hF (u+1) 0
    have m2 : F (u+2) 2 = rule (F (u+1) 1) (F (u+1) 2) (F (u+1) 3) := hF (u+1) 1
    have m3 : F (u+2) 3 = rule (F (u+1) 2) (F (u+1) 3) (F (u+1) 4) := hF (u+1) 2
    have m4 : F (u+2) 4 = rule (F (u+1) 3) (F (u+1) 4) (F (u+1) 5) := hF (u+1) 3
    have n1 : F (u+3) 1 = rule true (F (u+2) 1) (F (u+2) 2) := by rw [← hb']; exact hF (u+2) 0
    have n2 : F (u+3) 2 = rule (F (u+2) 1) (F (u+2) 2) (F (u+2) 3) := hF (u+2) 1
    have n3 : F (u+3) 3 = rule (F (u+2) 2) (F (u+2) 3) (F (u+2) 4) := hF (u+2) 2
    have q1 : F (u+4) 1 = rule false (F (u+3) 1) (F (u+3) 2) := by rw [← hw']; exact hF (u+3) 0
    have q2 : F (u+4) 2 = rule (F (u+3) 1) (F (u+3) 2) (F (u+3) 3) := hF (u+3) 1
    have r1 : F (u+5) 1 = rule true (F (u+4) 1) (F (u+4) 2) := by rw [← hb'']; exact hF (u+4) 0
    have k1 : T+2*(k+1)+1 = u+3 := by omega
    have k2 : T+2*(k+2)+1 = u+5 := by omega
    have k1' : T+2*(k+1)+2 = u+4 := by omega
    simp only [gate, net, blackNet, k1, k2, show T+2*k+1 = u+1 by omega, show T+2*k+2 = u+2 by omega]
    rw [r1, q1, q2, n1, n2, n3, m1, m2, m3, m4, e0, e1, e2, e3, e4]
    have g := localLaw (F u 1) (F u 2) (F u 3) (F u 4) (F u 5) (F u 6)
    simpa only [] using g
  exact ⟨fun k => (main k).1, fun k => (main k).2.1, fun k => (main k).2.2.1, fun k => (main k).2.2.2.1,
    fun k => (main k).2.2.2.2.1, fun k => (main k).2.2.2.2.2⟩

/-- Two successive nets are equal exactly at an odd kick. -/
theorem Law.equal {g a b : Nat → Bool} (L : Law g a b) (k : Nat) : (a k == a (k+1)) = (g (k+1) && !a (k+1)) := by
  cases h : g (k+1)
  · rw [L.toggle k h]; cases a k <;> rfl
  · rw [L.reset k h]; cases a (k+1) <;> rfl

/-! ### A search over readings -/

/-- Reads `g` as the word `w` from index `i`. -/
def Spells (u : Nat → Bool) (i : Nat) (v : List Bool) : Prop := ∀ k, k < v.length → u (i+k) = v.getD k false

/-- The gate words that rule the closed set out: gap one and six or more, the seven pairs, and 2, 2, 5. -/
def banned : List (List Bool) := [
  [true, true], [false, false, false, false, false], [true, false, true, false, false, true], [true, false, false, true, false, true],
  [true, false, false, true, false, false, false, true], [true, false, false, false, true, false, true],
  [true, false, false, false, true, false, false, true], [true, false, false, false, true, false, false, false, true],
  [true, false, false, false, false, true, false, false, false, true], [true, false, true, false, true, false, false, false, false, true]]

/-- Gate, net, black net. -/
abbrev Letter := Bool × Bool × Bool

def okLetter (q : Letter) : Bool := (!q.2.2 || q.1) && (!(q.1 && !q.2.1) || q.2.2)

def okStep (p q : Letter) : Bool := (q.1 || (q.2.1 == !p.2.1)) && (!q.1 || !p.2.1) && !(p.1 && q.1)

/-- After the letters `h`, the latest first, may `q` follow? -/
def okNext : List Letter → Letter → Bool
  | [], q => okLetter q
  | [p], q => okLetter q && okStep p q
  | p :: p' :: _, q => okLetter q && okStep p q && !(p'.1 && p'.2.1 && p'.2.2 && q.1)

def ends : List Bool → List Letter → Bool
  | [], _ => true
  | _ :: _, [] => false
  | c :: r, q :: h => (q.1 == c) && ends r h

def hasBanned (h : List Letter) : Bool := banned.any fun w => ends w.reverse h

def allLetters : List Letter := [(false,false,false), (false,true,false), (true,false,true), (true,true,false), (true,true,true),
  (false,false,true), (false,true,true), (true,false,false)]

def search (test : List Letter → Bool) : Nat → List Letter → Bool
  | 0, h => test h
  | n+1, h => allLetters.all fun q => !okNext h q || hasBanned (q :: h) || search test n (q :: h)

/-- The letters before index `k`, the latest first. -/
def hist (g a b : Nat → Bool) : Nat → List Letter
  | 0 => []
  | k+1 => (g k, a k, b k) :: hist g a b k

theorem mem_allLetters : ∀ q : Letter, q ∈ allLetters := by
  rintro ⟨a, b, c⟩
  cases a <;> cases b <;> cases c <;> decide

theorem ends_hist {g a b : Nat → Bool} : ∀ (r : List Bool) (k : Nat), ends r (hist g a b k) = true →
    r.length ≤ k ∧ ∀ i, i < r.length → g (k-1-i) = r.getD i false
  | [], _, _ => ⟨Nat.zero_le _, fun i hi => absurd hi (Nat.not_lt_zero i)⟩
  | c :: r, 0, h => by simp [hist, ends] at h
  | c :: r, k+1, h => by
    simp only [hist, ends, Bool.and_eq_true, beq_iff_eq] at h
    obtain ⟨le, at_⟩ := ends_hist r k h.2
    refine ⟨by simp; omega, fun i hi => ?_⟩
    cases i with
    | zero => simpa using h.1
    | succ i =>
      have := at_ i (by simpa using hi)
      rw [show k+1-1-(i+1) = k-1-i by omega]
      simpa using this

theorem no_banned {g a b : Nat → Bool} (clean : ∀ w ∈ banned, ∀ i, ¬ Spells g i w) (k : Nat) : hasBanned (hist g a b k) = false := by
  apply Bool.eq_false_iff.mpr
  intro h
  obtain ⟨w, hw, e⟩ := List.any_eq_true.mp h
  obtain ⟨le, at_⟩ := ends_hist _ _ e
  rw [List.length_reverse] at le at_
  refine clean w hw (k-w.length) (fun j hj => ?_)
  have := at_ (w.length-1-j) (by omega)
  rw [show k-1-(w.length-1-j) = k-w.length+j by omega] at this
  rw [this, List.getD_eq_getElem?_getD, List.getElem?_reverse (by omega), List.getD_eq_getElem?_getD]
  congr 2
  omega

theorem okNext_law {g a b : Nat → Bool} (L : Law g a b) : ∀ k, okNext (hist g a b k) (g k, a k, b k) = true := by
  have letter (k : Nat) : okLetter (g k, a k, b k) = true := by
    simp only [okLetter]
    cases hb : b k
    · cases hg : g k
      · cases a k <;> rfl
      · cases ha : a k
        · have := L.odd k hg ha; rw [hb] at this; cases this
        · rfl
    · rw [L.black k hb]
      cases a k <;> rfl
  have step (k : Nat) : okStep (g k, a k, b k) (g (k+1), a (k+1), b (k+1)) = true := by
    simp only [okStep]
    cases hg : g (k+1)
    · rw [L.toggle k hg]
      cases g k <;> simp
    · rw [L.reset k hg]
      have : g k = false := by
        cases h : g k
        · rfl
        · have := L.lone k h; rw [hg] at this; cases this
      rw [this]; cases a (k+1) <;> rfl
  intro k
  cases k with
  | zero => exact letter 0
  | succ k =>
    cases k with
    | zero => simp only [hist, okNext, letter, step, Bool.and_self]
    | succ k =>
      simp only [hist, okNext, letter, step, Bool.true_and, Bool.not_eq_true']
      cases hg : g (k+2)
      · simp
      · cases hg' : g k
        · simp
        · cases ha : a k
          · simp
          · cases hb : b k
            · simp
            · have := L.skip k hg' ha hb
              rw [show k+2 = k+2 from rfl, hg] at this
              cases this

theorem search_sound {g a b : Nat → Bool} (L : Law g a b) (clean : ∀ w ∈ banned, ∀ i, ¬ Spells g i w) {test : List Letter → Bool} :
    ∀ n k, search test n (hist g a b k) = true → test (hist g a b (k+n)) = true
  | 0, _, h => h
  | n+1, k, h => by
    have s := List.all_eq_true.mp h _ (mem_allLetters (g k, a k, b k))
    have nb : hasBanned (hist g a b (k+1)) = false := no_banned clean (k+1)
    change (!okNext (hist g a b k) (g k, a k, b k) || hasBanned (hist g a b (k+1)) || search test n (hist g a b (k+1))) = true at s
    rw [okNext_law L k, nb] at s
    simp only [Bool.not_true, Bool.false_or] at s
    rw [show k+(n+1) = (k+1)+n by omega]
    exact search_sound L clean n (k+1) s

/-! ### The closed set, and entry -/

/-- The first twelve cells of the half at the `k`-th white tick are a window of the closed set. -/
def InSet (F : Nat → Nat → Bool) (T k : Nat) : Prop := InTrap closedSet F (T+2*k+1)

theorem Alt.drive {F : Nat → Nat → Bool} {T : Nat} (h : Alt F T) (k n : Nat) : Drive F false true (T+2*k+1) n := by
  intro i _
  refine ⟨?_, ?_⟩
  · have := (h (k+i)).2; rwa [show T+2*(k+i)+1 = T+2*k+1+2*i by omega] at this
  · have := (h (k+i+1)).1; rwa [show T+2*(k+i+1) = T+2*k+1+2*i+1 by omega] at this

/-- **The closed set.** A half in it stays in it, whatever lies beyond. -/
theorem stays {F : Nat → Nat → Bool} (hF : IsR30 F) {T : Nat} (h : Alt F T) {k : Nat} (s : InSet F T k) (n : Nat) :
    InSet F T (k+n) := by
  have := trap_stays valid01 walk01 free01 wrap01 isTrap01 hF (h.drive k n) s
  rwa [show T+2*k+1+2*n = T+2*(k+n)+1 by omega] at this

/-- The windows of thirteen cells that a half outside can show for ever. -/
def tailWindows : List Nat := [1024, 16, 3268, 2338, 2194, 769, 77, 7364, 4372, 6434]

theorem tail13 : rounds false true 13 17 (widen 12 outside01) = tailWindows := by decide +kernel

/-- Their place in the cycle of four. -/
def phase (x : Nat) : Nat :=
  if x = 77 ∨ x = 769 then 0 else if x = 4372 ∨ x = 3268 ∨ x = 7364 then 1 else if x = 2194 ∨ x = 2338 ∨ x = 6434 then 2 else 3

theorem phase_lt (x : Nat) : phase x < 4 := by unfold phase; (repeat' split) <;> decide

theorem phaseOK : (tailWindows.all fun a => (a.testBit 0 == (phase a == 0)) && tailWindows.all fun b =>
    !(images false true 13 a).contains b || phase b == (phase a + 1) % 4) = true := by decide +kernel

theorem outside_from {F : Nat → Nat → Bool} (hF : IsR30 F) {T : Nat} (h : Alt F T) (out : ∀ k, ¬ InSet F T k) (k : Nat) :
    code F (T+2*(27+k)+1) 13 ∈ tailWindows := by
  have hd : Drive F false true (T+1) (10+10+(k+2*17)) := by
    have := h.drive 0 (10+10+(k+2*17)); simpa using this
  have no : ¬ InTrap closedSet F (T+1+2*(10+10+(k+2*17))) := fun s => out (20+(k+34)) (by
    unfold InSet
    rwa [show T+2*(20+(k+34))+1 = T+1+2*(10+10+(k+2*17)) by omega])
  have a : Among F (T+1+2*10) (k+2*17) 12 outside01 := fun i hi =>
    outside_before (m := 10) (n := 10) valid01 walk01 free01 wrap01 isTrap01 freeA01 freeB01 first01 middle01 last01
      outsideCodes01 hF hd no i hi
  have d : Drive F false true (T+1+2*10) (k+2*17) := (hd.mono (m := 10+(k+2*17)) (by omega)).shift 10
  have r := among_rounds hF 17 d (among_widen a)
  rw [tail13] at r
  have := r k (Nat.le_refl k)
  rwa [show T+1+2*10+2*17+2*k = T+2*(27+k)+1 by omega] at this

/-- **Every right half beside an alternating column,** of any support, enters the closed set, or from some tick on reads
a kick once in four. -/
theorem enters_or_four {F : Nat → Nat → Bool} (hF : IsR30 F) {T : Nat} (h : Alt F T) :
    (∃ k, InSet F T k) ∨ ∃ φ N, ∀ k, N ≤ k → gate F T k = decide ((k+φ) % 4 = 0) := by
  by_cases e : ∃ k, InSet F T k
  · exact Or.inl e
  right
  have mem := outside_from hF h (fun k s => e ⟨k, s⟩)
  generalize hc : (fun k => code F (T+2*(27+k)+1) 13) = c at *
  have hc' (k : Nat) : c k = code F (T+2*(27+k)+1) 13 := by rw [← hc]
  have mem' (k : Nat) : c k ∈ tailWindows := by rw [hc']; exact mem k
  have step (k : Nat) : phase (c (k+1)) = (phase (c k) + 1) % 4 := by
    have im := image_mem hF (h.drive (27+k) 1) 13
    rw [show T+2*(27+k)+1+2 = T+2*(27+(k+1))+1 by omega, ← hc', ← hc'] at im
    have row := List.all_eq_true.mp phaseOK _ (mem' k)
    simp only [Bool.and_eq_true] at row
    have cell := List.all_eq_true.mp row.2 _ (mem' (k+1))
    rw [List.contains_iff_mem.mpr im] at cell
    simpa using cell
  have at_ (k : Nat) : phase (c k) = (phase (c 0) + k) % 4 := by
    induction k with
    | zero => have := phase_lt (c 0); omega
    | succ k ih => rw [step k, ih]; omega
  refine ⟨phase (c 0) + 1, 27, fun k hk => ?_⟩
  obtain ⟨j, rfl⟩ : ∃ j, k = 27 + j := ⟨k-27, by omega⟩
  have row := List.all_eq_true.mp phaseOK _ (mem' j)
  simp only [Bool.and_eq_true, beq_iff_eq] at row
  have g : gate F T (27+j) = (c j).testBit 0 := by
    rw [hc', code_bit]; simp [gate]
  rw [g, row.1, at_ j]
  show decide ((phase (c 0) + j) % 4 = 0) = decide ((27 + j + (phase (c 0) + 1)) % 4 = 0)
  exact decide_eq_decide.mpr (by omega)

/-! ### What the gate of the closed set reads -/

theorem avoids {T : Tree} {white black : Nat} {d0 d1 : Bool} {trap : List Nat} {F : Nat → Nat → Bool}
    (va : T.valid = true) (ok : walkAll T white black d0 d1 = true) (free : freeFrom white black 0 1 = true)
    (wrap : leaves (fun m => m.testBit 1 == m.testBit 0) T = true) (is : isTrap T trap = true) (hF : IsR30 F) {t : Nat}
    (hd : ∀ n, Drive F d0 d1 t n) (h : InTrap trap F t) {o : Nat} {v : List (Option Bool)}
    (line : wordLine T white black o v = true) (pos : 0 < v.length) (i : Nat)
    (read : ∀ k, k < v.length → fits (v.getD k none) (F (t+2*(i+k)) 1) = true) : False := by
  obtain ⟨x, fx, bx⟩ := trap_row va ok free wrap is hF (hd (i+v.length)) h
  refine bit_word va ok line pos (bx i) (fun k hk => ?_)
  rw [← rows_add, fx (i+k) (by omega) 0 (by omega)]
  exact read k hk

theorem listed01 : (banned.all fun v => lines01.any fun l => l.2 == v.map some) = true := by decide +kernel
theorem banned_pos : ∀ v ∈ banned, 0 < v.length := by decide

/-- **The gate words of the closed set.** None of the ten is read from a white tick in it on. -/
theorem clean_of_set {F : Nat → Nat → Bool} (hF : IsR30 F) {T : Nat} (h : Alt F T) {k : Nat} (s : InSet F T k) :
    ∀ w ∈ banned, ∀ i, ¬ Spells (fun j => gate F T (k+j)) i w := by
  intro w hw i sp
  obtain ⟨l, hl, e⟩ := List.any_eq_true.mp (List.all_eq_true.mp listed01 w hw)
  have line := List.all_eq_true.mp wordLines01 l hl
  rw [beq_iff_eq.mp e] at line
  refine avoids valid01 walk01 free01 wrap01 isTrap01 hF (h.drive k) s line (by simpa using banned_pos w hw) i (fun j hj => ?_)
  rw [List.length_map] at hj
  have := sp j hj
  simp only [gate] at this
  rw [show T+2*k+1+2*(i+j) = T+2*(k+(i+j))+1 by omega]
  rw [this]
  simp [List.getD, hj, fits]

/-! ### The decoders -/

/-- The six words of nine nets that a kick sits in, at the seventh place. -/
def kickWords : List (List Bool) := [
  [false,false,true,false,true,false,false,true,false], [false,false,true,false,true,false,true,false,false],
  [false,false,true,false,true,false,true,false,true], [false,true,false,false,true,false,false,true,false],
  [true,false,true,false,true,false,false,true,false], [true,false,true,false,true,false,true,false,true]]

def decode (a : Nat → Bool) : Bool :=
  kickWords.any fun w => (List.range 9).all fun i => a i == w.getD i false

theorem decode_ext {a b : Nat → Bool} (h : ∀ i, i < 9 → a i = b i) : decode a = decode b := by
  have e : ∀ w : List Bool, ((List.range 9).all fun i => a i == w.getD i false) = ((List.range 9).all fun i => b i == w.getD i false) := by
    intro w
    rw [Bool.eq_iff_iff, List.all_eq_true, List.all_eq_true]
    constructor
    · intro q i hi
      rw [← h i (List.mem_range.mp hi)]; exact q i hi
    · intro q i hi
      rw [h i (List.mem_range.mp hi)]; exact q i hi
  exact congrArg (fun p => kickWords.any p) (funext e)

/-- A history of fourteen letters, latest first, agrees with the decoder at its seventh place. -/
def decodeTest (h : List Letter) : Bool :=
  (h.getD 7 default).1 == decode (fun i => (h.getD (13-i) default).2.1)

theorem decodeCheck : search decodeTest 14 [] = true := by decide +kernel

theorem decoder {g a b : Nat → Bool} (L : Law g a b) (clean : ∀ w ∈ banned, ∀ i, ¬ Spells g i w) : g 6 = decode a := by
  have t := search_sound L clean (test := decodeTest) 14 0 decodeCheck
  have e : hist g a b (0+14) = [(g 13,a 13,b 13),(g 12,a 12,b 12),(g 11,a 11,b 11),(g 10,a 10,b 10),(g 9,a 9,b 9),(g 8,a 8,b 8),
      (g 7,a 7,b 7),(g 6,a 6,b 6),(g 5,a 5,b 5),(g 4,a 4,b 4),(g 3,a 3,b 3),(g 2,a 2,b 2),(g 1,a 1,b 1),(g 0,a 0,b 0)] := rfl
  rw [e] at t
  simp only [decodeTest, List.getD, beq_iff_eq] at t
  have c : decode (fun i => ([(g 13,a 13,b 13),(g 12,a 12,b 12),(g 11,a 11,b 11),(g 10,a 10,b 10),(g 9,a 9,b 9),(g 8,a 8,b 8),
      (g 7,a 7,b 7),(g 6,a 6,b 6),(g 5,a 5,b 5),(g 4,a 4,b 4),(g 3,a 3,b 3),(g 2,a 2,b 2),(g 1,a 1,b 1),(g 0,a 0,b 0)][13-i]?.getD default).2.1) = decode a := by
    apply decode_ext
    intro i hi
    have cases : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 ∨ i = 4 ∨ i = 5 ∨ i = 6 ∨ i = 7 ∨ i = 8 := by omega
    rcases cases with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl
  rw [← c]
  exact t

/-- The history of eleven letters agrees with the black rule at its second place. -/
def blackTest (h : List Letter) : Bool :=
  ((h.getD 9 default).1 && !(h.getD 9 default).2.1) == ((h.getD 9 default).2.2 && !(h.getD 5 default).2.2)

theorem blackCheck : search blackTest 11 [] = true := by decide +kernel

theorem blackRule {g a b : Nat → Bool} (L : Law g a b) (clean : ∀ w ∈ banned, ∀ i, ¬ Spells g i w) :
    (g 1 && !a 1) = (b 1 && !b 5) := by
  have t := search_sound L clean (test := blackTest) 11 0 blackCheck
  have e : hist g a b (0+11) = [(g 10,a 10,b 10),(g 9,a 9,b 9),(g 8,a 8,b 8),(g 7,a 7,b 7),(g 6,a 6,b 6),(g 5,a 5,b 5),(g 4,a 4,b 4),
      (g 3,a 3,b 3),(g 2,a 2,b 2),(g 1,a 1,b 1),(g 0,a 0,b 0)] := rfl
  rw [e] at t
  simpa [blackTest, List.getD] using t

/-! ### Every right half: the decoders and the marks -/

theorem leastOf {P : Nat → Prop} (n : Nat) (hn : P n) : ∃ m, P m ∧ ∀ q, q < m → ¬ P q := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
    by_cases h : ∃ q, q < n ∧ P q
    · obtain ⟨q, hq, pq⟩ := h; exact ih q hq pq
    · exact ⟨n, hn, fun q hq p => h ⟨q, hq, p⟩⟩

section
variable {F : Nat → Nat → Bool} {T : Nat}

/-- **Kicks from the white nets.** Nine nets, at six past white ticks, the kick and two after, tell whether a kick is there. -/
theorem kick_of_white_nets (hF : IsR30 F) (h : Alt F T) {k : Nat} (s : InSet F T k) :
    gate F T (k+6) = decode (fun i => net F T (k+i)) := by
  have d := decoder ((law_of_alt hF h).shift k) (clean_of_set hF h s)
  simpa using d

/-- **An odd kick from two nets.** The net at two successive white ticks is equal exactly at a kick whose net is white.
It needs no closed set. -/
theorem odd_of_equal_nets (hF : IsR30 F) (h : Alt F T) (k : Nat) :
    (net F T k == net F T (k+1)) = (gate F T (k+1) && !net F T (k+1)) :=
  (law_of_alt hF h).equal k

/-- **An odd kick from two black nets,** four white ticks apart. -/
theorem odd_of_black_nets (hF : IsR30 F) (h : Alt F T) {k : Nat} (s : InSet F T k) :
    (gate F T (k+1) && !net F T (k+1)) = (blackNet F T (k+1) && !blackNet F T (k+5)) := by
  have d := blackRule ((law_of_alt hF h).shift k) (clean_of_set hF h s)
  simpa using d

/-- After a kick, the number of white ticks to the next one, when that number is `n`. -/
def NextKick (F : Nat → Nat → Bool) (T k n : Nat) : Prop :=
  1 ≤ n ∧ gate F T (k+n) = true ∧ ∀ i, 0 < i → i < n → gate F T (k+i) = false

theorem law_parity {g a b : Nat → Bool} (L : Law g a b) : ∀ (n k : Nat), g (k+(n+1)) = true →
    (∀ i, 0 < i → i < n+1 → g (k+i) = false) → a k = decide ((n+1) % 2 = 0)
  | 0, k, h, _ => by
    have := L.reset k h
    simpa using this
  | n+1, k, h, quiet => by
    have q := quiet 1 (by omega) (by omega)
    have ih := law_parity L n (k+1) (by rw [show k+1+(n+1) = k+(n+1+1) by omega]; exact h)
      (fun i hi hn => by rw [show k+1+i = k+(1+i) by omega]; exact quiet (1+i) (by omega) (by omega))
    have t := L.toggle k q
    rw [ih] at t
    have : a k = !decide ((n+1) % 2 = 0) := by
      cases h1 : a k <;> rw [h1] at t <;> cases h2 : decide ((n+1) % 2 = 0) <;> rw [h2] at t <;> first | rfl | cases t
    rw [this, ← decide_not]
    exact decide_eq_decide.mpr (by omega)

/-- **The net and the return.** A kick whose next kick is `n` white ticks later has net black exactly when `n` is even.
It needs no closed set. -/
theorem net_of_return (hF : IsR30 F) (h : Alt F T) {k n : Nat} (nk : NextKick F T k n) : net F T k = decide (n % 2 = 0) := by
  obtain ⟨n, rfl⟩ : ∃ m, n = m+1 := ⟨n-1, by have := nk.1; omega⟩
  exact law_parity (law_of_alt hF h) n k nk.2.1 nk.2.2

/-- In the closed set every kick has a next one, two to five white ticks later. -/
theorem next_kick (hF : IsR30 F) (h : Alt F T) {k : Nat} (s : InSet F T k) (g : gate F T k = true) :
    ∃ n, 2 ≤ n ∧ n ≤ 5 ∧ NextKick F T k n := by
  have none1 := (law_of_alt hF h).lone k g
  have ex : ∃ n, 1 ≤ n ∧ n ≤ 5 ∧ gate F T (k+n) = true := by
    apply Classical.byContradiction
    intro no
    refine clean_of_set hF h s [false, false, false, false, false] (by decide) 1 (fun j hj => ?_)
    have j5 : j < 5 := by simpa using hj
    have q : gate F T (k+(1+j)) = false := by
      cases e : gate F T (k+(1+j))
      · rfl
      · exact absurd ⟨1+j, by omega, by omega, e⟩ no
    have table : ([false, false, false, false, false] : List Bool).getD j false = false := by
      have : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 ∨ j = 4 := by omega
      rcases this with rfl | rfl | rfl | rfl | rfl <;> rfl
    simp only [table]
    rw [show k+(1+j) = k+(1+j) from rfl]
    exact q
  obtain ⟨n0, l0, u0, w0⟩ := ex
  -- the least kick after k
  obtain ⟨n, hn, least⟩ : ∃ n, (1 ≤ n ∧ gate F T (k+n) = true) ∧ ∀ m, (1 ≤ m ∧ gate F T (k+m) = true) → n ≤ m := by
    obtain ⟨m, hm, small⟩ := leastOf (P := fun n => 1 ≤ n ∧ gate F T (k+n) = true) n0 ⟨l0, w0⟩
    exact ⟨m, hm, fun q hq => Nat.le_of_not_lt fun l => small q l hq⟩
  have n1 : n ≠ 1 := by
    intro e; subst e; rw [none1] at hn; cases hn.2
  refine ⟨n, by omega, ?_, by omega, hn.2, fun i hi hin => ?_⟩
  · have := least n0 ⟨l0, w0⟩; omega
  · cases e : gate F T (k+i)
    · rfl
    · have := least i ⟨hi, e⟩
      omega

/-- **The odd kick.** In the closed set a kick has white net exactly when the next one is three or five white ticks later. -/
theorem odd_iff (hF : IsR30 F) (h : Alt F T) {k : Nat} (s : InSet F T k) (g : gate F T k = true) :
    net F T k = false ↔ ∃ n, (n = 3 ∨ n = 5) ∧ NextKick F T k n := by
  obtain ⟨n, l, u, nk⟩ := next_kick hF h s g
  have e := net_of_return hF h nk
  constructor
  · intro z
    rw [e] at z
    have : n = 3 ∨ n = 5 := by
      have : ¬ n % 2 = 0 := by simpa using z
      omega
    exact ⟨n, this, nk⟩
  · rintro ⟨m, hm, mk⟩
    rw [net_of_return hF h mk]
    rcases hm with rfl | rfl <;> rfl

end

/-! ### Periodicity passes between the streams -/

/-- A kick whose net is white: its next kick is an odd number of white ticks later (`odd_iff`). -/
def oddKick (F : Nat → Nat → Bool) (T k : Nat) : Bool := gate F T k && !net F T k

section
variable {F : Nat → Nat → Bool} {T : Nat}

/-- A difference that is constant under a shift repeats after twice the shift. -/
theorem periodic_of_equalities {f : Nat → Bool} (per : EventuallyPeriodic (fun k => f k == f (k+1))) : EventuallyPeriodic f := by
  obtain ⟨L, p, hp, per⟩ := per
  have flip (n : Nat) (hn : L ≤ n) : xor (f (n+1+p)) (f (n+1)) = xor (f (n+p)) (f n) := by
    have q : (f (n+p) == f (n+p+1)) = (f n == f (n+1)) := per n hn
    rw [show n+p+1 = n+1+p by omega] at q
    revert q
    cases f (n+p) <;> cases f (n+1+p) <;> cases f n <;> cases f (n+1) <;> decide
  have same (m n : Nat) (hn : L ≤ n) : xor (f (n+m+p)) (f (n+m)) = xor (f (n+p)) (f n) := by
    induction m with
    | zero => rfl
    | succ m ih =>
      have := flip (n+m) (by omega)
      rw [show n+(m+1) = n+m+1 by omega, this, ih]
  refine ⟨L, 2*p, by omega, fun n hn => ?_⟩
  have e := same p n hn
  rw [show n+p+p = n+2*p by omega] at e
  revert e
  cases f (n+2*p) <;> cases f (n+p) <;> cases f n <;> decide

/-- If the net on the white ticks is eventually periodic, so is the gate. -/
theorem gate_periodic_of_net (hF : IsR30 F) (h : Alt F T) {K : Nat} (s : InSet F T K) (per : EventuallyPeriodic (net F T)) :
    EventuallyPeriodic (gate F T) := by
  obtain ⟨L, p, hp, per⟩ := per
  have inset (k : Nat) (hk : K ≤ k) : InSet F T k := by
    have := stays hF h s (k-K)
    rwa [show K+(k-K) = k by omega] at this
  refine ⟨K+L+6, p, hp, fun k hk => ?_⟩
  obtain ⟨j, rfl⟩ : ∃ j, k = j+6 := ⟨k-6, by omega⟩
  have a := kick_of_white_nets hF h (inset j (by omega))
  have b := kick_of_white_nets hF h (inset (j+p) (by omega))
  rw [show j+6+p = j+p+6 by omega, b, a]
  exact decode_ext (fun i _ => by
    rw [show j+p+i = j+i+p by omega]; exact per (j+i) (by omega))

/-- If the gate is eventually periodic, so is the net on the white ticks. -/
theorem net_periodic_of_gate (hF : IsR30 F) (h : Alt F T) {K : Nat} (s : InSet F T K) (per : EventuallyPeriodic (gate F T)) :
    EventuallyPeriodic (net F T) := by
  obtain ⟨L, p, hp, per⟩ := per
  have inset (k : Nat) (hk : K ≤ k) : InSet F T k := by
    have := stays hF h s (k-K)
    rwa [show K+(k-K) = k by omega] at this
  -- every white tick in the set has a kick at most five ticks later
  have soon (k : Nat) (hk : K ≤ k) : ∃ n, NextKick F T k n := by
    apply Classical.byContradiction
    intro no
    refine clean_of_set hF h (inset k hk) [false, false, false, false, false] (by decide) 1 (fun j hj => ?_)
    have j5 : j < 5 := by simpa using hj
    have table : ([false, false, false, false, false] : List Bool).getD j false = false := by
      have : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 ∨ j = 4 := by omega
      rcases this with rfl | rfl | rfl | rfl | rfl <;> rfl
    simp only [table]
    cases e : gate F T (k+(1+j))
    · rfl
    · exfalso
      obtain ⟨m, hm, small⟩ := leastOf (P := fun n => 1 ≤ n ∧ gate F T (k+n) = true) (1+j) ⟨by omega, e⟩
      exact no ⟨m, hm.1, hm.2, fun i hi him => by
        cases g : gate F T (k+i)
        · rfl
        · exact absurd ⟨hi, g⟩ (small i him)⟩
  refine ⟨K+L, p, hp, fun k hk => ?_⟩
  obtain ⟨n, nk⟩ := soon k (by omega)
  have nk' : NextKick F T (k+p) n := by
    refine ⟨nk.1, ?_, fun i hi him => ?_⟩
    · rw [show k+p+n = k+n+p by omega, per (k+n) (by omega)]; exact nk.2.1
    · rw [show k+p+i = k+i+p by omega, per (k+i) (by omega)]; exact nk.2.2 i hi him
  rw [net_of_return hF h nk', net_of_return hF h nk]

/-- If the odd kicks are eventually periodic, so is the net on the white ticks. No closed set is needed. -/
theorem net_periodic_of_odd (hF : IsR30 F) (h : Alt F T) (per : EventuallyPeriodic (oddKick F T)) : EventuallyPeriodic (net F T) := by
  obtain ⟨L, p, hp, per⟩ := per
  apply periodic_of_equalities
  refine ⟨L, p, hp, fun k hk => ?_⟩
  simp only [odd_of_equal_nets hF h]
  rw [show k+p+1 = k+1+p by omega]
  exact per (k+1) (by omega)

/-- If the net on the white ticks is eventually periodic, so are the odd kicks. -/
theorem odd_periodic_of_net (hF : IsR30 F) (h : Alt F T) (per : EventuallyPeriodic (net F T)) : EventuallyPeriodic (oddKick F T) := by
  obtain ⟨L, p, hp, per⟩ := per
  refine ⟨L+1, p, hp, fun k hk => ?_⟩
  obtain ⟨j, rfl⟩ : ∃ j, k = j+1 := ⟨k-1, by omega⟩
  rw [show j+1+p = j+p+1 by omega]
  have a := odd_of_equal_nets hF h (j+p)
  have b := odd_of_equal_nets hF h j
  show (gate F T (j+p+1) && !net F T (j+p+1)) = (gate F T (j+1) && !net F T (j+1))
  rw [← a, ← b, show j+p+1 = j+1+p by omega, per j (by omega), per (j+1) (by omega)]

/-- If the net on the black ticks is eventually periodic, so are the odd kicks. -/
theorem odd_periodic_of_black (hF : IsR30 F) (h : Alt F T) {K : Nat} (s : InSet F T K) (per : EventuallyPeriodic (blackNet F T)) :
    EventuallyPeriodic (oddKick F T) := by
  obtain ⟨L, p, hp, per⟩ := per
  have inset (k : Nat) (hk : K ≤ k) : InSet F T k := by
    have := stays hF h s (k-K)
    rwa [show K+(k-K) = k by omega] at this
  refine ⟨K+L+1, p, hp, fun k hk => ?_⟩
  obtain ⟨j, rfl⟩ : ∃ j, k = j+1 := ⟨k-1, by omega⟩
  have a := odd_of_black_nets hF h (inset (j+p) (by omega))
  have b := odd_of_black_nets hF h (inset j (by omega))
  show (gate F T (j+1+p) && !net F T (j+1+p)) = (gate F T (j+1) && !net F T (j+1))
  rw [show j+1+p = j+p+1 by omega, a, b, show j+p+1 = j+1+p by omega, per (j+1) (by omega),
    show j+p+5 = j+5+p by omega, per (j+5) (by omega)]

/-- **The three streams.** Beside an alternating column every right half in the closed set has an eventually periodic gate, white
net and odd kicks together; and if its black net is eventually periodic, so are they. -/
theorem periodic_together (hF : IsR30 F) (h : Alt F T) {K : Nat} (s : InSet F T K) :
    (EventuallyPeriodic (gate F T) ↔ EventuallyPeriodic (net F T)) ∧
    (EventuallyPeriodic (net F T) ↔ EventuallyPeriodic (oddKick F T)) ∧
    (EventuallyPeriodic (blackNet F T) → EventuallyPeriodic (gate F T)) :=
  ⟨⟨net_periodic_of_gate hF h s, gate_periodic_of_net hF h s⟩, ⟨odd_periodic_of_net hF h, net_periodic_of_odd hF h⟩,
    fun per => gate_periodic_of_net hF h s (net_periodic_of_odd hF h (odd_periodic_of_black hF h s per))⟩

end

/-! ### Right halves driven from the clock -/

/-- The right half `R`, driven by the column that is black at even ticks, alternates from the start. -/
theorem alt_drv (R : Nat → Bool) : Alt (drv altCol R) 0 := by
  intro k
  rw [drv_col0, drv_col0]
  refine ⟨?_, ?_⟩
  · rw [show 0+2*k = 2*k by omega]; exact Rule30PeriodTwoSideways.altCol_even k
  · rw [show 0+2*k+1 = 2*k+1 by omega]; exact Rule30PeriodTwoSideways.altCol_odd k

/-- **Every right half,** of any support, beside the alternating column enters the closed set, or from some tick on reads
a kick once in four. -/
theorem every_half (R : Nat → Bool) : (∃ k, InSet (drv altCol R) 0 k) ∨
    ∃ φ N, ∀ k, N ≤ k → gate (drv altCol R) 0 k = decide ((k+φ) % 4 = 0) :=
  enters_or_four (drv_isR30 _ _) (alt_drv R)

/-! ### The hypothetical alternating tail of the single cell -/

/-- The centre alternates from `T`, black first. -/
def AltCenter (T : Nat) : Prop := ∀ k, cell (T+2*k) 0 = true ∧ cell (T+2*k+1) 0 = false

theorem AltCenter.alt {T : Nat} (h : AltCenter T) : Alt trueRight T := fun k => ⟨(h k).1, (h k).2⟩

/-- Masked Jen: the kicks are not eventually periodic. -/
theorem gate_not_periodic {T : Nat} (h : AltCenter T) : ¬ EventuallyPeriodic (gate trueRight T) := by
  rintro ⟨L, p, hp, per⟩
  have white (t : Nat) (ht : T ≤ t) (c : cell t 0 = false) : ∃ k, t = T+2*k+1 := by
    rcases Nat.lt_or_ge ((t-T) % 2) 1 with e | e
    · exfalso
      obtain ⟨k, rfl⟩ : ∃ k, t = T+2*k := ⟨(t-T)/2, by omega⟩
      rw [(h k).1] at c; cases c
    · exact ⟨(t-T)/2, by omega⟩
  refine masked_jen_center (T := T) (P := 2*p) (by omega) (fun t ht => ?_) (T+2*L+1) (fun t ht c => ?_)
  · obtain ⟨k, rfl | rfl⟩ : ∃ k, t = T+2*k ∨ t = T+2*k+1 := ⟨(t-T)/2, by omega⟩
    · rw [show T+2*k+2*p = T+2*(k+p) by omega, (h _).1, (h _).1]
    · rw [show T+2*k+1+2*p = T+2*(k+p)+1 by omega, (h _).2, (h _).2]
  · obtain ⟨k, rfl⟩ := white t (by omega) c
    have := per k (by omega)
    rw [show T+2*k+1+2*p = T+2*(k+p)+1 by omega]
    exact this

/-- **Entry of the single cell.** From some white tick on, the window of the single cell is in the closed set. -/
theorem single_enters {T : Nat} (h : AltCenter T) : ∃ K, InSet trueRight T K := by
  rcases enters_or_four trueRight_isR30 h.alt with s | ⟨φ, N, f⟩
  · exact s
  · exfalso
    refine gate_not_periodic h ⟨N, 4, by omega, fun k hk => ?_⟩
    rw [f (k+4) (by omega), f k hk]
    congr 1
    apply propext
    omega

/-- **White net.** If the centre alternates for ever, the net on the white ticks is not eventually periodic. -/
theorem white_net_aperiodic {T : Nat} (h : AltCenter T) : ¬ EventuallyPeriodic (net trueRight T) := fun per => by
  obtain ⟨K, s⟩ := single_enters h
  exact gate_not_periodic h (gate_periodic_of_net trueRight_isR30 h.alt s per)

/-- **Odd kicks.** If the centre alternates for ever, the kicks whose next one is three or five white ticks later are not
eventually periodic. -/
theorem odd_kicks_aperiodic {T : Nat} (h : AltCenter T) : ¬ EventuallyPeriodic (oddKick trueRight T) := fun per =>
  white_net_aperiodic h (net_periodic_of_odd trueRight_isR30 h.alt per)

/-- **Black net.** If the centre alternates for ever, the net on the black ticks is not eventually periodic. -/
theorem black_net_aperiodic {T : Nat} (h : AltCenter T) : ¬ EventuallyPeriodic (blackNet trueRight T) := fun per => by
  obtain ⟨K, s⟩ := single_enters h
  exact odd_kicks_aperiodic h (odd_periodic_of_black trueRight_isR30 h.alt s per)

/-! ### Lowry's net and shell -/

def source (j : Int) (t : Nat) : Bool := cell t j && !cell t (j+1)
def lowryNet (t : Nat) : Bool := xor (source (-1) t) (xor (source 1 t) (source 0 (t+1)))
def lowryShell (t : Nat) : Bool := xor (cell t (-2)) (cell t 2)

/-- On a white tick whose next tick is black, Lowry's net is the first cell exclusive-or the second. -/
theorem lowry_white (t : Nat) (w : cell t 0 = false) (b : cell (t+1) 0 = true) : lowryNet t = xor (cell t 1) (cell t 2) := by
  have step : cell (t+1) 0 = rule (cell t (-1)) (cell t 0) (cell t 1) := rfl
  have next : cell (t+1) 1 = rule (cell t 0) (cell t 1) (cell t 2) := rfl
  show xor (cell t (-1) && !cell t 0) (xor (cell t 1 && !cell t 2) (cell (t+1) 0 && !cell (t+1) 1)) = _
  rw [w] at step next
  have b' := b
  rw [step] at b'
  rw [w, b, next]
  exact (by decide : ∀ L x y : Bool, rule L false x = true → xor (L && !false) (xor (x && !y) (true && !rule false x y)) = xor x y)
    _ _ _ b'

/-- On a black tick whose next tick is white, Lowry's net is the first cell without the second. -/
theorem lowry_black (t : Nat) (b : cell t 0 = true) (w : cell (t+1) 0 = false) : lowryNet t = (cell t 1 && !cell t 2) := by
  show xor (cell t (-1) && !cell t 0) (xor (cell t 1 && !cell t 2) (cell (t+1) 0 && !cell (t+1) 1)) = _
  rw [b, w]
  cases cell t (-1) <;> cases cell t 1 <;> cases cell t 2 <;> rfl

/-- Lowry's identity at two ticks. -/
theorem two_step (t : Nat) : cell (t+2) 0 = xor (lowryShell t) (lowryNet t) := by
  show rule (rule (cell t (-2)) (cell t (-1)) (cell t 0)) (rule (cell t (-1)) (cell t 0) (cell t 1))
      (rule (cell t 0) (cell t 1) (cell t 2)) = _
  simp only [lowryShell, lowryNet, source]
  show rule (rule (cell t (-2)) (cell t (-1)) (cell t 0)) (rule (cell t (-1)) (cell t 0) (cell t 1))
      (rule (cell t 0) (cell t 1) (cell t 2)) = xor (xor (cell t (-2)) (cell t 2))
        (xor (cell t (-1) && !cell t 0) (xor (cell t 1 && !cell t 2)
          (rule (cell t (-1)) (cell t 0) (cell t 1) && !rule (cell t 0) (cell t 1) (cell t 2))))
  exact (by decide : ∀ a b c d e : Bool, rule (rule a b c) (rule b c d) (rule c d e) =
    xor (xor a e) (xor (b && !c) (xor (d && !e) (rule b c d && !rule c d e)))) _ _ _ _ _

section
variable {T : Nat}

/-- Lowry's net at the white and the black ticks of an alternating centre is the net of its right half. -/
theorem lowry_at_white (h : AltCenter T) (k : Nat) : lowryNet (T+2*k+1) = net trueRight T k := by
  have b := (h (k+1)).1
  rw [show T+2*(k+1) = T+2*k+1+1 by omega] at b
  exact lowry_white _ (h k).2 b

theorem lowry_at_black (h : AltCenter T) (k : Nat) : lowryNet (T+2*k+2) = blackNet trueRight T k := by
  have b := (h (k+1)).1
  have w := (h (k+1)).2
  rw [show T+2*(k+1) = T+2*k+2 by omega] at b
  rw [show T+2*(k+1)+1 = T+2*k+2+1 by omega] at w
  exact lowry_black _ b w

theorem shell_at_white (h : AltCenter T) (k : Nat) : lowryShell (T+2*k+1) = net trueRight T k := by
  have e := two_step (T+2*k+1)
  rw [show T+2*k+1+2 = T+2*(k+1)+1 by omega, (h (k+1)).2, lowry_at_white h k] at e
  exact (by decide : ∀ a b : Bool, false = xor a b → a = b) _ _ e

theorem shell_at_black (h : AltCenter T) (k : Nat) : lowryShell (T+2*k+2) = !blackNet trueRight T k := by
  have e := two_step (T+2*k+2)
  rw [show T+2*k+2+2 = T+2*(k+2) by omega, (h (k+2)).1, lowry_at_black h k] at e
  exact (by decide : ∀ a b : Bool, true = xor a b → a = !b) _ _ e

/-- **Both phases of Lowry's net and shell.** If the centre of the single cell alternates from `T`, black first, then Lowry's net
and his shell are not eventually periodic on the white ticks, nor on the black ones. -/
theorem both_phases (h : AltCenter T) :
    ¬ EventuallyPeriodic (fun k => lowryNet (T+2*k+1)) ∧ ¬ EventuallyPeriodic (fun k => lowryNet (T+2*k+2)) ∧
    ¬ EventuallyPeriodic (fun k => lowryShell (T+2*k+1)) ∧ ¬ EventuallyPeriodic (fun k => lowryShell (T+2*k+2)) := by
  have eqw : (fun k => lowryNet (T+2*k+1)) = net trueRight T := funext (lowry_at_white h)
  have eqb : (fun k => lowryNet (T+2*k+2)) = blackNet trueRight T := funext (lowry_at_black h)
  have eqsw : (fun k => lowryShell (T+2*k+1)) = net trueRight T := funext (shell_at_white h)
  have eqsb : (fun k => lowryShell (T+2*k+2)) = fun k => !blackNet trueRight T k := funext (shell_at_black h)
  refine ⟨by rw [eqw]; exact white_net_aperiodic h, by rw [eqb]; exact black_net_aperiodic h,
    by rw [eqsw]; exact white_net_aperiodic h, ?_⟩
  rw [eqsb]
  rintro ⟨L, p, hp, per⟩
  refine black_net_aperiodic h ⟨L, p, hp, fun k hk => ?_⟩
  have := per k hk
  cases h1 : blackNet trueRight T (k+p) <;> cases h2 : blackNet trueRight T k <;> simp_all

/-- **The return.** In the alternating tail of the single cell, Lowry's net at two successive white ticks is equal exactly when the
second is an odd kick: a kick whose next kick is three or five white ticks later. -/
theorem lowry_odd_return (h : AltCenter T) (k : Nat) :
    (lowryNet (T+2*k+1) == lowryNet (T+2*(k+1)+1)) = oddKick trueRight T (k+1) := by
  rw [lowry_at_white h, lowry_at_white h]
  exact odd_of_equal_nets trueRight_isR30 h.alt k

end

end Rule30ArrivalsLight
