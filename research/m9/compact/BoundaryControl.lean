import Ruliology.CellularAutomata.Rule30Certificates.TrappedRunMasks

open Ruliology.CellularAutomata.Rule30DrivenPrefix
open Ruliology.CellularAutomata.Rule30TrappedRunMasks
open Ruliology.CellularAutomata.Rule30TrappedRunBoundary

/- Both rows have the correct low 44 output bits and gate colour. Replacing
the final output cell by zero loses time 46. At this input the intermediate
cell 44 is black, so Rule 30 forces the final output to one for either exterior. -/
set_option maxRecDepth 100000
set_option maxHeartbeats 0
example :
    let x := 15077656946332
    let zeroTail := 8788720699962
    let oneTail := 26380906744378
    double x % 2^44 = zeroTail % 2^44 ∧
    (table.value x 0).testBit 45 = true ∧
    (colourMask (zeroTail.testBit 0)).testBit 46 = true ∧
    (table.value zeroTail 0).testBit 46 = false ∧
    lastBit x false = true ∧ lastBit x true = true ∧
    zeroTail.testBit 44 = false ∧
    double x % 2^44 = oneTail % 2^44 ∧ oneTail.testBit 44 = true ∧
    (table.value oneTail 0).testBit 46 = true := by decide +kernel
