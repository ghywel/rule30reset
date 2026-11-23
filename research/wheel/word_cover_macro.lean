module
public import word_cover_base
public meta import word_cover_base
public meta import Lean

/-! Compute an untrusted width checkpoint as syntax. The neighbouring
equalities still go through independent kernel reduction. -/
public section
namespace Ruliology.CellularAutomata.WordCover
open Lean

syntax "wordCheckpoint " num num num : term
syntax "wordStage " num num num num : term
macro_rules
  | `(wordCheckpoint $size:num $code:num $width:num) => `(wordStage $size $code $width 2)
  | `(wordStage $size:num $code:num $width:num $stage:num) => do
    let w := width.getNat
    let previous := PureThreeExit.layers (word size.getNat code.getNat) true (w-2)
    let candidates := PureThreeExit.lift (w-1) (PureThreeExit.admit true size.getNat w) 0 previous
    let front := PureThreeExit.right w candidates
    let grid := match stage.getNat with
      | 0 => candidates
      | 1 => front
      | _ => PureThreeExit.left w front
    let blocks ← grid.toArray.mapM fun rows => do
      let n := Syntax.mkNumLit (toString rows.length)
      let bits := rows.foldr (fun x rest => x + (rest <<< w)) 0
      let packed := Syntax.mkNumLit (toString bits)
      `(($n, $packed))
    `(decodeGrid $width [$[$blocks],*])
end Ruliology.CellularAutomata.WordCover
