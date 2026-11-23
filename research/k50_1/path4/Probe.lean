import Rule30Lock7Certificate

/-! Finite diagnostic for the short proof of Lowry's example and the earlier
31-bit branching example. Each length uses the nearest positive cells first. -/
open Ruliology.CellularAutomata.Rule30Lock7Certificate

#eval (List.range 81).filter (fun m => accepts (.hit 47 6) m 248139127718118986536413)

-- The five leaves use the same split order as Rule30LockCube.entry_nine.
#eval (accepts (.hit 4 1) 31 2108003337,
  accepts (.split (.split (.hit 3 0) (.hit 4 1))
    (.split (.split (.hit 4 1) (.hit 3 0)) (.hit 4 1))) 31 2108003337)
