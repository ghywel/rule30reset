import SparseDeadline

namespace PhaseTwo.SparseDeadline

def sites17 : List Nat := [0,1,6,7,8,11,12,27,47,54,61,64,74,95,101,108,109]
def sites18 : List Nat := sites17 ++ [121]

/-- Adding the eighteenth black site at position 121 delays the first failed
even observation from tick 126 to tick 132. -/
theorem sparse_witnesses :
    sites17.length = 17 ∧ sites18.length = 18 ∧
    pack 0 sites17 = 976130576275904007994955876276675 ∧
    pack 0 sites18 = 2659432122146107649815609076436965827 ∧
    (List.range 63).all (fun k => !fails (pack 0 sites17) k) = true ∧
    fails (pack 0 sites17) 63 = true ∧
    (List.range 66).all (fun k => !fails (pack 0 sites18) k) = true ∧
    fails (pack 0 sites18) 66 = true := by
  decide +kernel

end PhaseTwo.SparseDeadline
