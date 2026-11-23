module

public import Ruliology.CellularAutomata.Rule30RunPlanes
public meta import Ruliology.CellularAutomata.Rule30RunPlanes
public meta import Std.Data.HashSet.Basic
public meta import Lean.Elab.Term

/-! The search proposes plane tables. Only the checked transfers enter the theorem. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30RunPlaneData
open Rule30RunPlanes Rule30TrappedRuns Rule30GateTrap
open Lean Elab Term
set_option maxHeartbeats 0
set_option maxRecDepth 100000
set_option Elab.async false

meta structure Work where
  codes : Array Nat
  slot : Slot
  deriving Inhabited

meta def packFlags (bs : Array Bool) : Nat := Id.run do
  let mut v := 0
  for i in [:bs.size] do
    if bs[i]! then v := v ||| (1 <<< i)
  return v

meta def selected (cs : Array Nat) (m : Nat) : Array Nat := Id.run do
  let mut xs := #[]
  for i in [:cs.size] do
    if m.testBit i then xs := xs.push cs[i]!
  return xs

meta def shifts (n active : Nat) : List Move := Id.run do
  if active == 2^n-1 then return []
  let mut masks := Array.replicate (n.log2+1) 0
  let mut rank := 0
  for i in [:n] do
    if active.testBit i then
      let delta := i-rank
      for j in [:masks.size] do
        if delta.testBit j then
          let pos := rank + ((delta >>> j) <<< j)
          masks := masks.modify j (· ||| (1 <<< pos))
      rank := rank+1
  let ms := masks.toList.zipIdx.filterMap fun (m,j) =>
    if m == 0 then none else some (⟨2^j,m⟩ : Move)
  return if ms.isEmpty then [⟨0,0⟩] else ms

meta def initWork (c : Option Bool) : Work :=
  let f := start c
  ⟨trapCodes.toArray, ⟨[], false, 0, f, trapCodes.length, f.live, f.live, [], []⟩⟩

meta def freshen (w : Work) (grow : Bool) : Work := Id.run do
  let s := w.slot
  let old := Rule30RunPlanes.back s
  let ms := shifts w.codes.size old.live
  let base := compact old ms
  let cs := selected w.codes old.live
  let f := if grow then Rule30RunPlanes.widen base cs.size else base
  let rows := if grow then cs ++ cs.map (· + 2^s.fresh.cols.length) else cs
  return ⟨rows, ⟨ms, grow, cs.size, f, rows.size, f.live, f.live, [], []⟩⟩

meta def widthLimit (ws : Array Nat) : Array Nat := Id.run do
  let mut out := #[]
  for w in ws do
    if let some last := out.back? then out := out.push (min w (last+2)) else out := out.push w
  return out

meta def growAt (ws : Array Work) : Array Bool :=
  let proposed := ws.map fun x =>
    let w := x.slot.fresh.cols.length
    w + (decide (w < 46 ∧ (selected x.codes x.slot.back).size ≤ 256)).toNat
  let widths := (widthLimit (widthLimit proposed).reverse).reverse
  Array.zipWith (fun x w => decide (x.slot.fresh.cols.length < w)) ws widths

meta def imageSet (a b : Work) (mask : Nat) : Std.HashSet Nat := Id.run do
  let mut out : Std.HashSet Nat := ∅
  for x in selected a.codes mask do
    for y in Rule30RunWindow.outputs a.slot.fresh.cols.length b.slot.fresh.cols.length x do
      out := out.insert y
  return out

meta def onePass (old : Array Work) (grow : Array Bool) : Array Work := Id.run do
  let mut ws := Array.zipWith freshen old grow
  for i in [1:ws.size] do
    let a := ws[i-1]!
    let b := ws[i]!
    let seen := imageSet a b a.slot.front
    let f := packFlags (b.codes.map seen.contains)
    let js := if f == b.slot.fresh.live then [] else (List.range b.slot.fresh.cols.length).reverse
    ws := ws.set! i {b with slot := {b.slot with front := f, back := f, forwardBits := js}}
  for u in [:ws.size-1] do
    let i := ws.size-2-u
    let a := ws[i]!
    let b := ws[i+1]!
    let seen := Std.HashSet.ofList (selected b.codes b.slot.back).toList
    let keep := packFlags (a.codes.map fun x =>
      (Rule30RunWindow.outputs a.slot.fresh.cols.length b.slot.fresh.cols.length x).any seen.contains)
    let m := keep &&& a.slot.front
    let js := if m == a.slot.front then [] else (List.range b.slot.fresh.cols.length).reverse
    ws := ws.set! i {a with slot := {a.slot with back := m, backwardBits := js}}
  return ws

meta def makePasses (old : Array Work) (grow : Array Bool) : Nat → Except String (List (List Slot))
  | 0 => .error "the finite width schedule was exhausted"
  | k+1 => do
    let ws := onePass old grow
    let result := (ws.map Work.slot).toList
    if ws.any (fun w => w.slot.back == 0) then return [result]
    let next := growAt ws
    if !next.any id then throw "a path survives the selected window widths"
    return result :: (← makePasses ws next k)

meta def movesTerm (ms : List Move) := Meta.mkListLit (Lean.mkConst ``Move)
  (ms.map fun m => mkApp2 (Lean.mkConst ``Move.mk) (mkNatLit m.shift) (mkNatLit m.selected))

def descending (n : Nat) := (List.range n).reverse

meta def slotTerm (s : Slot) : MetaM Expr := do
  let js (v : List Nat) := mkApp (Lean.mkConst ``descending) (mkNatLit v.length)
  let f := mkApp2 (Lean.mkConst ``Family.mk) (mkNatLit s.fresh.live) (toExpr s.fresh.cols)
  return mkAppN (Lean.mkConst ``Slot.mk) #[← movesTerm s.shifts, toExpr s.grow, mkNatLit s.count,
    f, mkNatLit s.lanes, mkNatLit s.front, mkNatLit s.back, js s.forwardBits, js s.backwardBits]

elab "trappedRunPlanes%" : term => do
  let old := (colours.map initWork).toArray
  match makePasses old (Array.replicate old.size false) (1+30*old.size) with
  | .error e => throwError "{e}"
  | .ok ps =>
    let mut names : Array Expr := #[]
    let tp := mkApp (Lean.mkConst ``List [.zero]) (Lean.mkConst ``Slot)
    for p in ps do
      let name := (← getMainModule) ++ Name.mkSimple ("planes" ++ toString names.size)
      let vals ← p.mapM fun s => liftM (slotTerm s)
      let v ← Meta.mkListLit (Lean.mkConst ``Slot) vals
      addDecl <| .defnDecl {name, levelParams := [], type := tp, value := v, hints := .abbrev, safety := .safe}
      names := names.push (Lean.mkConst name)
    Meta.mkListLit tp names.toList

noncomputable def data : List (List Slot) := trappedRunPlanes%
noncomputable def slots (n : Nat) := data.getD n []
noncomputable def frames : Nat → List Family
  | 0 => colours.map start
  | n+1 => (slots n).map Rule30RunPlanes.back

end Ruliology.CellularAutomata.Rule30RunPlaneData
