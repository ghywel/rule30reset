import Rule30LocalEventParity

/-! A finite alternating center window excludes entire families of kick-gap factors.
A kick is a black observation of column one, sampled whenever the center is white. -/
namespace Ruliology.CellularAutomata.Rule30EventKickExclusion

open Rule30Jen Rule30EventReturns Rule30EventGate

/-- A complete gap from the kick at index i to the next at i+d. -/
def KickGap (u : Nat → Bool) (i d : Nat) : Prop :=
  0 < d ∧ u i = true ∧ (∀ j, 0 < j → j < d → u (i+j) = false) ∧ u (i+d) = true

/-- The marker two samples before the first kick in a string of 2-gaps and the marker
one sample after its last kick would give a forbidden odd return of length 3+2k. -/
private theorem forbid {u : Nat → Bool} {event : Nat → Prop} (a k b : Nat)
    (ha : 3 ≤ a) (hk : 2 ≤ k) (hb : 3 ≤ b) (odd : b%2 = 1)
    (decode : ∀ i d, i+d ≤ a+2*k+b →
      (∀ j, j<d → u (i+j) = false) → u (i+d) = true → (event i ↔ 0<d ∧ d%2=0))
    (parity : ∀ i n, 0<n → i+n ≤ a+2*k+b → event i → event (i+n) →
      (∀ j, 0<j → j<n → ¬event (i+j)) → n%2=0 ∨ n=3 ∨ n=5) :
    ¬(KickGap u 0 a ∧ (∀ j, j<k → KickGap u (a+2*j) 2) ∧ KickGap u (a+2*k) b) := by
  intro ⟨leading, twos, trailing⟩
  have atKick (j : Nat) (hj : j ≤ k) : u (a+2*j) = true := by
    by_cases h : j=k
    · subst j; exact trailing.2.1
    · exact (twos j (by omega)).2.1
  have first : event (a-2) := by
    apply (decode (a-2) 2 (by omega) ?_ ?_).mpr (by decide)
    · intro j hj
      simpa only [Nat.zero_add] using leading.2.2.1 (a-2+j) (by omega) (by omega)
    · simpa only [show a-2+2 = a by omega, Nat.zero_add] using leading.2.2.2
  have last : event (a+2*k+1) := by
    apply (decode (a+2*k+1) (b-1) (by omega) ?_ ?_).mpr (by omega)
    · intro j hj
      rw [show a+2*k+1+j = a+2*k+(1+j) by omega]
      exact trailing.2.2.1 _ (by omega) (by omega)
    · simpa only [show a+2*k+1+(b-1) = a+2*k+b by omega] using trailing.2.2.2
  have quiet (v : Nat) (hv : 0<v) (hv' : v<3+2*k) : ¬event (a-2+v) := by
    let i := a-2+v
    change ¬event i
    by_cases head : v=1
    · have ei : i=a-1 := by dsimp [i]; omega
      rw [ei, decode (a-1) 1 (by omega) (by
        intro j hj
        have : j=0 := by omega
        subst j
        simpa only [Nat.add_zero, Nat.zero_add] using leading.2.2.1 (a-1) (by omega) (by omega)) (by
        simpa only [show a-1+1=a by omega, Nat.zero_add] using leading.2.2.2)]
      decide
    have bounds : a ≤ i ∧ i ≤ a+2*k := by dsimp [i]; omega
    let j := (i-a)/2
    by_cases even : (i-a)%2=0
    · have ei : i=a+2*j := by dsimp [j]; omega
      have kb : u (i+0)=true := by rw [Nat.add_zero, ei]; exact atKick j (by omega)
      rw [decode i 0 (by omega) (by intro m hm; omega) kb]
      decide
    · have ei : i=a+2*j+1 := by dsimp [j]; omega
      have hj : j<k := by omega
      have q : u i=false := by rw [ei]; exact (twos j hj).2.2.1 1 (by decide) (by decide)
      have kb : u (i+1)=true := by
        rw [show i+1=a+2*(j+1) by omega]; exact atKick _ (by omega)
      rw [decode i 1 (by omega) (by
        intro m hm
        have hz : m=0 := by omega
        simpa only [hz, Nat.add_zero] using q) kb]
      decide

  have h := parity (a-2) (3+2*k) (by omega) (by omega) first
    (by rwa [show a-2+(3+2*k)=a+2*k+1 by omega]) quiet
  omega

/-- Every Rule 30 right half during a finite alternating-center window excludes a gap
a ≥ 3, then k ≥ 2 successive gaps of two, then an odd gap b ≥ 3. The center need
only alternate through the sampled gate pattern. -/
theorem no_long_twos_to_odd {F : Nat → Nat → Bool} (hF : Rule30Ether.IsR30 F)
    (t a k b : Nat) (ha : 3 ≤ a) (hk : 2 ≤ k) (hb : 3 ≤ b) (odd : b%2 = 1)
    (white : ∀ i, i < a+2*k+b → F (t+2*i) 0 = false)
    (black : ∀ i, i < a+2*k+b → F (t+2*i+1) 0 = true) :
    let u := fun i => F (t+2*i) 1
    ¬(KickGap u 0 a ∧ (∀ j, j<k → KickGap u (a+2*j) 2) ∧ KickGap u (a+2*k) b) := by
  dsimp only
  have shift (i j : Nat) : t+2*i+2*j=t+2*(i+j) := by omega
  apply forbid (event := fun i => Hit F (t+2*i)) a k b ha hk hb odd
  · intro i d room clear kick
    apply hit_iff_even_distance hF
    · intro j hj; rw [shift]; exact white _ (by omega)
    · intro j hj; rw [shift]; exact black _ (by omega)
    · intro j hj; rw [shift]; exact clear j hj
    · rw [shift]; exact kick
  · intro i n pos room first last quiet
    exact Rule30LocalEventParity.hit_return_parity hF (t+2*i) n pos
      (fun j hj => by rw [shift]; exact white _ (by omega))
      (fun j hj => by rw [shift]; exact black _ (by omega)) first (by rwa [shift])
      (fun j hj hj' => by rw [shift]; exact quiet j hj hj')

/-- The exclusion stated on the kit’s black-even driven gate, at every start index. -/
theorem driven_no_long_twos_to_odd (R : Nat → Bool) (s a k b : Nat)
    (ha : 3 ≤ a) (hk : 2 ≤ k) (hb : 3 ≤ b) (odd : b%2 = 1) :
    let u := fun i => Rule30PeriodTwoSideways.u R (s+i)
    ¬(KickGap u 0 a ∧ (∀ j, j<k → KickGap u (a+2*j) 2) ∧ KickGap u (a+2*k) b) := by
  let F := Rule30Ether.drv Rule30PeriodTwoCoupled.altCol R
  have shift (i : Nat) : 2*s+1+2*i=2*(s+i)+1 := by omega
  have h := no_long_twos_to_odd (F := F) (Rule30Ether.drv_isR30 _ _) (2*s+1) a k b
    ha hk hb odd (fun i _ => by
      rw [shift]; exact (Rule30Ether.drv_col0 _ _ _).trans (Rule30PeriodTwoSideways.altCol_odd _))
    (fun i _ => by
      rw [show 2*s+1+2*i+1=2*(s+i+1) by omega]
      exact (Rule30Ether.drv_col0 _ _ _).trans (Rule30PeriodTwoSideways.altCol_even _))
  simpa only [shift, Rule30PeriodTwoSideways.u, F] using h

/-- An independent specialization to the official orbit directly using Lowry’s word theorem. -/
theorem singleton_no_long_twos_to_odd (t a k b : Nat) (ha : 3 ≤ a) (hk : 2 ≤ k)
    (hb : 3 ≤ b) (odd : b%2 = 1)
    (white : ∀ i, i ≤ a+2*k+b+5 → cell (t+2*i) 0 = false)
    (black : ∀ i, i < a+2*k+b+5 → cell (t+2*i+1) 0 = true) :
    let u := fun i => cell (t+2*i) 1
    ¬(KickGap u 0 a ∧ (∀ j, j<k → KickGap u (a+2*j) 2) ∧ KickGap u (a+2*k) b) := by
  dsimp only
  have shift (i j : Nat) : t+2*i+2*j=t+2*(i+j) := by omega
  apply forbid (event := fun i => wordAt (t+2*i)) a k b ha hk hb odd
  · intro i d room clear kick
    apply word_iff_even_distance
    · intro j hj; rw [shift]; exact white _ (by omega)
    · intro j hj; rw [shift]; exact black _ (by omega)
    · intro j hj; rw [shift]; exact clear j hj
    · rw [shift]; exact kick
  · intro i n pos room first last quiet
    exact (word_returns (t+2*i) n pos
      (fun j hj => by rw [shift]; exact white _ (by omega))
      (fun j hj => by rw [shift]; exact black _ (by omega)) first (by rwa [shift])
      (fun j hj hj' => by rw [shift]; exact quiet j hj hj')).1

end Ruliology.CellularAutomata.Rule30EventKickExclusion
