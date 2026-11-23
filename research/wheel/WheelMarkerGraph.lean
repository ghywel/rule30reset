module
public import WheelMarkerData
public import Ruliology.CellularAutomata.Rule30GateTrapWords

/-! A finite observation of the 17/56 wheel at the white samples forces gate-trap entry. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelMarker
open Rule30GateTrap Rule30StripCertificates Rule30GateTrapWords

/-- Each exterior bit is the eastern neighbour at that physical tick. -/
def tick (w : BitVec 16) (wall east : Bool) : BitVec 16 :=
  ((w <<< 1) ||| (if wall then 1 else 0)) ^^^
    (w ||| (w >>> 1) ||| (if east then 32768 else 0))

def step (w : BitVec 16) (x y : Bool) : BitVec 16 := tick (tick w false x) true y

def marker : List Bool := [false, false, false, true, false, false, false, false, true, false, false, true, false, false, false, false, true, false, false, false, false, true, false, false, false, false, true, false, false, false, false, true, false, false, false, false, true, false, false, true]


def suffixes (w : BitVec 16) : Nat :=
  let bank := Data.bank ((Data.bankIndex >>> (8*(w.toNat % 256))) % 256)
  let slot := (bank >>> (6 * (w.toNat / 256))) % 64
  (Data.labels >>> (40*slot)) % 2^40

def selectSamples (b : Bool) : Nat := if b then 0x9084210908 else 0x6f7bdef6f7

/-- Suffix membership of the successor implies membership one observation earlier. -/
def closedEdge (w v : BitVec 16) : Bool :=
  let need := (suffixes v >>> 1) &&& selectSamples (w.getLsbD 0)
  (need ||| suffixes w) == suffixes w

def validRow (w : BitVec 16) : Bool :=
  !(suffixes w).testBit 0 &&
  (!w.getLsbD 0 || (suffixes w).testBit 39 || trapCodes.contains w.toNat) &&
  closedEdge w (step w false false) && closedEdge w (step w false true) &&
  closedEdge w (step w true false) && closedEdge w (step w true true)

def page (hi : Nat) : Bool := (List.range 256).all fun lo => validRow (BitVec.ofNat 16 (256*hi+lo))

set_option maxRecDepth 100000
set_option maxHeartbeats 0

def unpack (w : BitVec 16) : List Bool := seg (fun i => w.getLsbD i) 16

theorem unpack_decode (w : BitVec 16) : unpack w = decode w.toNat := by rfl

theorem unpack_step (w : BitVec 16) (x y : Bool) :
    unpack (step w x y) = step2 (unpack w) x y := by
  cases x <;> cases y <;>
    simp [unpack, step, tick, step2, seg, lin3, Nat.reduceAdd]

end Ruliology.CellularAutomata.WheelMarker
