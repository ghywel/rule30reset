import EveryModulusFast
import TwoFalls

namespace PhaseFalls.Moduli

/-- **Every modulus from two.** For every modulus `m ≥ 2` and every integer `i`, one of the 27 singleton columns
`i, …, i + 26` has cofinal falls at two different residues modulo `m`: six columns suffice from three
(`two_cofinal_every_modulus`), and 27 at two (`two_parities_every_27`). -/
theorem two_cofinal_every_modulus_from_two (m : Nat) (hm : 2 ≤ m) (i : Int) :
    ∃ (j : Fin 27) (r q : Fin m), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q := by
  by_cases h2 : m = 2
  · subst h2; exact two_parities_every_27 i
  · obtain ⟨j, r, q, hrq, hr, hq⟩ := two_cofinal_every_modulus m (by omega) i
    exact ⟨⟨j.val, by omega⟩, r, q, hrq, hr, hq⟩

end PhaseFalls.Moduli
