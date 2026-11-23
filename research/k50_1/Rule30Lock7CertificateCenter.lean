module
public import Rule30Lock7Certificate
public import Rule30Lock7CenterDeadline

/-! Consequences of a right-prefix certificate for the genuine singleton centre. -/
@[expose] public section

namespace Ruliology.CellularAutomata.Rule30Lock7CertificateCenter
open Rule30Lock7Certificate Rule30Lock7Compactness Rule30Lock7CenterDeadline
open Rule30PeriodTwoCoupled

/-- A certificate with maximum sample J gives the absolute deadline 2(A+1+2J)
at every age A where its initial cells occur. -/
theorem centre_bound_of_certificate {tree : Certificate} {m c A : Nat}
    (pass : accepts tree m c = true) (pref : HasPrefix m c (rightAt A)) :
    ∃ h, A+h ≤ 2*(A+1+2*tree.deadline) ∧ Rule30Jen.cell (A+h) 0 ≠ altCol h := by
  have checked := (checkCover_iff_certificate m c tree.deadline).mpr ⟨tree,pass,Nat.le_refl _⟩
  obtain ⟨h,bound,miss⟩ := actual_break_of_checkCover checked pref
  exact ⟨h,by omega,miss⟩

/-- A sufficient recurrence hypothesis for excluding a period-two tail. The
certificate, prefix and deadline may vary with the actual black-centre age. -/
theorem no_period_two_of_cofinal_certificates
    (recurs : ∀ B, ∃ A ≥ B, Rule30Jen.cell A 0 = true ∧
      ∃ (m c : Nat) (tree : Certificate), accepts tree m c = true ∧ HasPrefix m c (rightAt A)) :
    ¬ ∃ T, ∀ t, T ≤ t → Rule30Jen.cell (t+2) 0 = Rule30Jen.cell t 0 := by
  rintro ⟨T,per⟩
  obtain ⟨start,alt⟩ := Rule30PeriodTwo.normalize per
  obtain ⟨A,after,black,m,c,tree,pass,pref⟩ := recurs start
  obtain ⟨h,_,miss⟩ := centre_bound_of_certificate pass pref
  obtain ⟨n,even | odd⟩ : ∃ n, A = start+2*n ∨ A = start+2*n+1 :=
    ⟨(A-start)/2,by omega⟩
  · obtain ⟨q,evenTick | oddTick⟩ : ∃ q, h = 2*q ∨ h = 2*q+1 := ⟨h/2,by omega⟩
    · apply miss
      rw [show A+h = start+2*(n+q) by omega, (alt (n+q)).1]
      simp [altCol,evenTick]
    · apply miss
      rw [show A+h = start+2*(n+q)+1 by omega, (alt (n+q)).2]
      simp [altCol,oddTick,show (2*q+1)%2 = 1 by omega]
  · rw [odd,(alt n).2] at black
    contradiction

end Ruliology.CellularAutomata.Rule30Lock7CertificateCenter
