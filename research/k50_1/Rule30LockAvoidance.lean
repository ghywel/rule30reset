module

public import Rule30Lock7Prefixes
public import Rule30Lock7Compactness

/-! A finite prefix can certify permanent avoidance for every continuation. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30LockAvoidance

open Rule30SidewaysLocks Rule30Lock7Compactness Rule30Lock7Prefixes

/-- A disjoint invariant on W cells supplies a negative certificate for a cylinder of
initial right halves. The bound is the exact light-cone length of the witness window. -/
theorem avoiding_cylinder {W seed j : Nat} (width : W ≤ 30) (bad : List Bool → Prop)
    (closed : ∀ w, bad w → ∀ a b, bad (dstep w a b))
    (disjoint : ∀ (k : Fin 7) w, w ∈ cls 30 lock7Codes k.val → ¬bad (w.take W))
    (seen : bad (winW W (rh seed) (1+2*j))) :
    ∀ R, HasPrefix (W+(1+2*j)) seed R → ¬ ∃ h, Locked R h := by
  intro R pref
  have eq : winW W R (1+2*j) = winW W (rh seed) (1+2*j) := by
    rw [winW_prefix pref, winW_prefix (rh_prefix seed (W+(1+2*j)))]
  have stay (n : Nat) : bad (winW W R (1+2*(j+n))) := by
    induction n with
    | zero => simpa [eq] using seen
    | succ n ih =>
      rw [show 1+2*(j+(n+1))=1+2*(j+n)+2 by omega,winW_dstep W R _ (by omega)]
      exact closed _ ih _ _
  rintro ⟨h,hit⟩
  obtain ⟨k,hk⟩ := locked_later (Nat.le_max_left h j) hit
  have same := stay (max h j-j)
  rw [show j+(max h j-j)=max h j by omega] at same
  exact disjoint k _ hk (by rwa [winW_take R _ W 30 width])

end Ruliology.CellularAutomata.Rule30LockAvoidance
