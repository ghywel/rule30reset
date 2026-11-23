import Rule30Lock7Certificate

/-! Reproduce the depth table using the Lean leaf checker directly. A failed
left or right branch rejects its parent. In a successful tree both branches
contribute to the leaf count and the deeper one determines the depth. -/
open Ruliology.CellularAutomata.Rule30Lock7Certificate

private def shape (m c : Nat) : Nat → Option (Nat × Nat)
  | 0 => if checkLeaf m c 47 6 then some (0,1) else none
  | extra+1 =>
    if checkLeaf m c 47 6 then some (0,1)
    else do
      let (dl, nl) ← shape (m+1) c extra
      let (dr, nr) ← shape (m+1) (2^m+c) extra
      pure (1 + max dl dr, nl + nr)

private def results := (List.range 17).map fun offset =>
  let m := 64 + offset
  (m, shape m (248139127718118986536413 % 2^m) 8)

#eval results
#guard results.map Prod.snd ==
  List.replicate 13 none ++ [some (5,11), some (4,7), some (1,2), some (0,1)]
