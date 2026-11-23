module

public import Ruliology.CellularAutomata.Rule30RunWindow
public meta import Ruliology.CellularAutomata.Rule30RunWindow
public meta import Lean.Elab.Term

/-! Reconstruct the finite window certificate, then check its local implications. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30RunCertificate
open Rule30RunWindow Rule30TrappedRuns
set_option maxRecDepth 100000
set_option maxHeartbeats 0
set_option Elab.async false

meta def fronts (a : Window) : List Window → List Mark
  | [] => []
  | b :: bs =>
    let s := index (a.codes.flatMap (outputs a.width b.width))
    let box : Window := ⟨b.width, b.codes.filter s.contains⟩
    ⟨s,box⟩ :: fronts box bs

meta def backs : List Window → List Mark
  | [] => []
  | a :: ds =>
    match backs ds with
    | [] => [⟨⟨0,0⟩, a⟩]
    | m :: ms =>
      let s := index m.box.codes
      let box : Window := ⟨a.width, a.codes.filter fun x =>
        (outputs a.width m.box.width x).any s.contains⟩
      ⟨s,box⟩ :: m :: ms

meta def boundWidths : List Nat → List Nat
  | [] => []
  | x :: xs => (xs.foldl (fun acc y => min y (acc.head! + 2) :: acc) [x]).reverse

meta def bitsOf : List Bool → Nat
  | [] => 0
  | b :: bs => b.toNat + 2 * bitsOf bs

meta def nextMask (ds : List Window) : Nat :=
  let proposed := ds.map fun d => d.width + (decide (d.codes.length ≤ 320 ∧ d.width < 46)).toNat
  let ws := (boundWidths (boundWidths proposed).reverse).reverse
  bitsOf (List.zipWith (fun d w => d.width < w) ds ws)

meta def generate (ds : List Window) (m : Nat) : Nat → Except String (List Pass)
  | 0 => .error "unfinished window certificate"
  | fuel+1 => do
    let a :: ds' := liftAt m ds | .error "empty schedule"
    let fs := fronts a ds'
    let bs := backs (a :: fs.map Mark.box)
    let result := bs.map Mark.box
    let pass : Pass := ⟨m, fs, bs⟩
    if result.any (fun d => d.codes.isEmpty) then return [pass]
    let grow := nextMask result
    if grow == 0 then throw "window refinement stabilized with a path"
    return pass :: (← generate result grow fuel)

open Lean Elab Term

meta def packed (w : Window) : Expr := Id.run do
  let mut parts : List (Nat × Nat) := []
  let mut n := 0
  let mut data := 0
  for x in w.codes do
    data := data ||| (x <<< (48*n))
    n := n+1
    if n == 12 then
      parts := (n,data)::parts
      n := 0
      data := 0
  if n != 0 then parts := (n,data)::parts
  return mkApp2 (mkConst ``chunks) (mkNatLit w.width) (toExpr parts.reverse)

meta def markTerm (m : Mark) : Expr :=
  let s := mkApp2 (mkConst ``Index.mk) (mkNatLit m.mask.first) (mkNatLit m.mask.second)
  mkApp2 (mkConst ``Mark.mk) s (packed m.box)

meta def passTerm (p : Pass) : MetaM Expr := do
  let marks (ms : List Mark) := Meta.mkListLit (mkConst ``Mark) (ms.map markTerm)
  return mkApp3 (mkConst ``Pass.mk) (mkNatLit p.grow) (← marks p.front) (← marks p.back)

elab "trappedRunCertificate%" : term => do
  match generate initial 0 150 with
  | .error e => throwError "{e}"
  | .ok ps =>
    let mut names : Array Expr := #[]
    for p in ps do
      let name := (← getMainModule) ++ Name.mkSimple ("round" ++ toString names.size)
      let value ← passTerm p
      addDecl <| .defnDecl {
        name := name
        levelParams := []
        type := mkConst ``Pass
        value := value
        hints := .abbrev
        safety := .safe }
      names := names.push (Lean.mkConst name)
    Meta.mkListLit (mkConst ``Pass) names.toList

noncomputable def certificate : List Pass := trappedRunCertificate%

noncomputable def pass (i : Nat) : Pass := certificate.getD i default
noncomputable def state : Nat → List Window
  | 0 => initial
  | i+1 => (pass i).back.map Mark.box

theorem stage {i r : Nat} (ok : verifies (state i) (pass i)) (h : Trace r (state i)) :
    Trace r (state (i+1)) := verifies_sound ok h

end Ruliology.CellularAutomata.Rule30RunCertificate
