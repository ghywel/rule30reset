import Ruliology.CellularAutomata.Rule30EventReturns
import Ruliology.CellularAutomata.Rule30GateTrap

/-! Lowry's marker in the odd-time gate.  A kick is a black sample of column one.
On a white-center sample, the distance in double steps to the first kick
(including the current sample) determines the marker. -/
namespace Ruliology.CellularAutomata.Rule30EventGate

open Rule30Ether Rule30Jen Rule30EventReturns Rule30PeriodTwoCoupled Rule30PeriodTwoSideways

/-- The two right cells which recognize Lowry's word under five alternating center observations. -/
def Hit (F : Nat → Nat → Bool) (t : Nat) : Prop := F t 1 = false ∧ F t 2 = true

/-- At a white gate, a following kick rules out the marker. If the next gate is
also white, the two marker readings are complementary. Only two center observations are needed. -/
theorem toggle {F : Nat → Nat → Bool} (hF : IsR30 F) (t : Nat)
    (white : F t 0 = false) (black : F (t+1) 0 = true) (quiet : F t 1 = false) :
    Hit F t ↔ F (t+2) 1 = false ∧ ¬Hit F (t+2) := by
  unfold Hit
  rw [show t+2=t+1+1 by omega, hF (t+1) 0, hF (t+1) 1, hF t 0, hF t 1, hF t 2,
    white, black, quiet]
  cases F t 2 <;> cases F t 3 <;> cases F t 4 <;> decide

/-- Relative to the first black sample of column one, the marker is present exactly
at positive even double-step distances before it. The center may be arbitrary beyond the kick. -/
theorem hit_iff_even_distance {F : Nat → Nat → Bool} (hF : IsR30 F) (t d : Nat)
    (white : ∀ k, k<d → F (t+2*k) 0=false)
    (black : ∀ k, k<d → F (t+2*k+1) 0=true)
    (quiet : ∀ k, k<d → F (t+2*k) 1=false) (kick : F (t+2*d) 1=true) :
    Hit F t ↔ 0<d ∧ d%2=0 := by
  induction d generalizing t with
  | zero => simp [Hit, show F t 1=true by simpa using kick]
  | succ d ih =>
    have q : F t 1=false := by simpa using quiet 0 (by omega)
    rw [toggle hF t (by simpa using white 0 (by omega)) (by simpa using black 0 (by omega)) q]
    have shift (k : Nat) : t+2+2*k=t+2*(k+1) := by omega
    have shifted := ih (t+2)
      (fun k h => by rw [shift]; exact white _ (by omega))
      (fun k h => by rw [shift]; exact black _ (by omega))
      (fun k h => by rw [shift]; exact quiet _ (by omega))
      (by rw [shift]; exact kick)
    rw [shifted]
    cases d with
    | zero => simpa using kick
    | succ d =>
      have nextQuiet : F (t+2) 1=false := by simpa using quiet 1 (by omega)
      simp only [nextQuiet, true_and, Nat.zero_lt_succ, true_and]
      omega

private theorem seed_rule : IsR30 (fun t p => cell t (p : Int)) := by
  intro t p
  change rule (cell t (((p+1 : Nat) : Int)-1)) _ _ = _
  simp [Int.natCast_add, Int.add_assoc]

/-- The gate dictionary for Lowry's literal seven-cell word at sites -4 through +2.
The five center samples used by the kit's word recognition are included at short distances. -/
theorem word_iff_even_distance (t d : Nat)
    (white : ∀ k, k ≤ max d 2 → cell (t+2*k) 0=false)
    (black : ∀ k, k < max d 2 → cell (t+2*k+1) 0=true)
    (quiet : ∀ k, k<d → cell (t+2*k) 1=false) (kick : cell (t+2*d) 1=true) :
    wordAt t ↔ 0<d ∧ d%2=0 := by
  rw [word_iff_marker t (by simpa using white 0 (by omega))
    (by simpa using black 0 (by omega)) (by simpa using white 1 (by omega))
    (by simpa [Nat.add_assoc] using black 1 (by omega)) (by simpa using white 2 (by omega))]
  exact hit_iff_even_distance seed_rule t d (fun k hk => white k (by omega))
    (fun k hk => black k (by omega)) quiet kick

/-- On the kit's driven right half this uses its actual gate stream u, with black-even driver. -/
theorem driven_marker_iff_even_distance (R : Nat → Bool) (s d : Nat)
    (quiet : ∀ k, k<d → u R (s+k)=false) (kick : u R (s+d)=true) :
    Hit (drv altCol R) (2*s+1) ↔ 0<d ∧ d%2=0 := by
  have shift (k : Nat) : 2*s+1+2*k=2*(s+k)+1 := by omega
  apply hit_iff_even_distance (drv_isR30 _ _) (2*s+1) d
  · intro k _; rw [shift, drv_col0, altCol_odd]
  · intro k _; rw [show 2*s+1+2*k+1=2*(s+k+1) by omega, drv_col0, altCol_even]
  · intro k hk; rw [shift]; exact quiet k hk
  · rw [shift]; exact kick

/-- The two right cells at the ordinary odd-time gate sample. -/
abbrev Event (R : Nat → Bool) (s : Nat) := Hit (drv altCol R) (2*s+1)

private theorem trap_first_kick (R : Nat → Bool) {t0 : Nat} (odd : t0%2=1)
    (entered : Rule30GateTrap.win R t0 ∈ Rule30GateTrap.trap) (s : Nat)
    (late : t0 ≤ 2*s+1) (start : u R s=true) :
    ∃ g, (g=3 ∨ g=5) ∧ u R (s+g)=true ∧ ∀ i, 0<i → i<g → u R (s+i)=false := by
  rcases Rule30GateTrap.gaps_of_entry R odd entered s late start with ⟨h1,h2,h3⟩ | ⟨h1,h2,h3,h4,h5⟩
  · refine ⟨3, Or.inl rfl, h3, ?_⟩
    intro i lo hi
    rcases (show i=1 ∨ i=2 by omega) with rfl|rfl
    · exact h1
    · exact h2
  · refine ⟨5, Or.inr rfl, h5, ?_⟩
    intro i lo hi
    rcases (show i=1 ∨ i=2 ∨ i=3 ∨ i=4 by omega) with rfl|rfl|rfl|rfl
    · exact h1
    · exact h2
    · exact h3
    · exact h4

private theorem inside_gap (R : Nat → Bool) (s g i : Nat) (pos : 0<i) (hi : i≤g)
    (quiet : ∀ j, 0<j → j<g → u R (s+j)=false) (kick : u R (s+g)=true) :
    Event R (s+i) ↔ 0<g-i ∧ (g-i)%2=0 := by
  apply driven_marker_iff_even_distance
  · intro k hk
    rw [Nat.add_assoc]
    exact quiet _ (by omega) (by omega)
  · rwa [show s+i+(g-i)=s+g by omega]

private theorem after_kick (R : Nat → Bool) {t0 : Nat} (odd : t0%2=1)
    (entered : Rule30GateTrap.win R t0 ∈ Rule30GateTrap.trap) (s : Nat)
    (late : t0 ≤ 2*s+1) (start : u R s=true) : Event R (s+1) := by
  obtain ⟨g, hg, kick, quiet⟩ := trap_first_kick R odd entered s late start
  exact (inside_gap R s g 1 (by decide) (by omega) quiet kick).2 (by rcases hg with rfl|rfl <;> decide)

/-- The exact event return code on any physical right half after trap entry.
Start a block at the marker one sample after a kick. A three-sample kick gap gives
the single first return 3. A five-sample kick gap gives the successive first returns
2,3. The last marker is the first marker of the next block. -/
theorem trap_return_code (R : Nat → Bool) {t0 : Nat} (odd : t0%2=1)
    (entered : Rule30GateTrap.win R t0 ∈ Rule30GateTrap.trap) (s : Nat)
    (late : t0 ≤ 2*s+1) (start : u R s=true) :
    ∃ g, (g=3 ∨ g=5) ∧ u R (s+g)=true ∧ (∀ j, 0<j → j<g → u R (s+j)=false) ∧
      ∀ i, i≤g → (Event R (s+1+i) ↔ i=0 ∨ i=g ∨ (g=5 ∧ i=2)) := by
  obtain ⟨g, hg, kick, quiet⟩ := trap_first_kick R odd entered s late start
  refine ⟨g, hg, kick, quiet, ?_⟩
  intro i hi
  by_cases last : i=g
  · subst i
    rw [show s+1+g=s+g+1 by omega]
    exact ⟨fun _ => Or.inr (Or.inl rfl), fun _ => after_kick R odd entered (s+g) (by omega) kick⟩
  · rw [show s+1+i=s+(i+1) by omega,
      inside_gap R s g (i+1) (by omega) (by omega) quiet kick]
    rcases hg with rfl|rfl <;> omega

end Ruliology.CellularAutomata.Rule30EventGate
