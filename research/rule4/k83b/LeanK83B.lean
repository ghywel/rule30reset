import Rule30Equivalents.Mixing

/-! Finite block upper bounds for the topological entropy of Rule 30.
The window cover below is the kit's representative construction with the word count retained. -/
namespace K83B
open Filter Topology Dynamics Uniformity Ruliology.CellularAutomata Rule30Realization
open Rule30Equivalents Rule30Equivalents.Mixing

/-- A pair word of length m+n injects into its prefix and restarted suffix. -/
theorem submultiplicative (a : ℤ) (m n : ℕ) :
    (pairWords a (m+n)).card ≤ (pairWords a m).card * (pairWords a n).card := by
  classical
  let split (w : Fin (m+n) → Bool × Bool) :=
    ((fun i : Fin m => w ⟨i.val, by omega⟩), (fun i : Fin n => w ⟨m+i.val, by omega⟩))
  have inject : Function.Injective split := by
    intro u v h
    funext i
    by_cases hlt : i.val < m
    · exact congrFun (congrArg Prod.fst h) ⟨i.val,hlt⟩
    · have e := congrFun (congrArg Prod.snd h) ⟨i.val-m,by omega⟩
      simpa [split, Nat.add_sub_of_le (by omega : m ≤ i.val)] using e
  have maps : (pairWords a (m+n)).image split ⊆ (pairWords a m) ×ˢ (pairWords a n) := by
    intro w hw
    obtain ⟨v,hv,rfl⟩ := Finset.mem_image.mp hw
    obtain ⟨x,rfl⟩ := mem_pairWords.mp hv
    refine Finset.mem_product.mpr ⟨mem_pairWords.mpr ⟨x,rfl⟩, mem_pairWords.mpr ⟨evol x m,?_⟩⟩
    funext i
    simp [split, pairWord, Rule30ZeroBoundaryBarriers.evol_restart]
  simpa [Finset.card_image_of_injective _ inject] using Finset.card_le_card maps

theorem window_cover_count (N n : ℕ) :
    coverMincard (fun x : ℤ → Bool => evol x 1) Set.univ (windowRel N) n ≤ (pairWords N (n + 2*N + 1)).card := by
  classical
  let L := n + 2 * N + 1
  -- a configuration with each pair word that occurs
  let rep : (Fin L → Bool × Bool) → (ℤ → Bool) := fun w =>
    if h : ∃ x, pairWord N L x = w then h.choose else fun _ => false
  have hcov : IsDynCoverOf (fun x : ℤ → Bool => evol x 1) Set.univ (windowRel N) n
      ((pairWords N L).image rep) := by
    intro x _
    have hw : ∃ y, pairWord N L y = pairWord N L x := ⟨x, rfl⟩
    refine ⟨rep (pairWord N L x),
      Finset.mem_coe.2 (Finset.mem_image_of_mem _ (mem_pairWords.2 hw)), ?_⟩
    have hrep : pairWord N L (rep (pairWord N L x)) = pairWord N L x := by
      simp only [rep, dite_eq_left hw]
      exact hw.choose_spec
    have hcol : ∀ s ≤ n + 2 * N, evol x s N = evol (rep (pairWord N L x)) s N ∧
        evol x s (N + 1) = evol (rep (pairWord N L x)) s (N + 1) := fun s hs => by
      have := congrFun hrep ⟨s, by omega⟩
      simp only [pairWord, Prod.mk.injEq] at this
      exact ⟨this.1.symm, this.2.symm⟩
    simp only [dynEntourage, Set.mem_iInter, Set.mem_preimage, Prod.map_iterate,
      Prod.map_apply, windowRel, Set.mem_ofPred_eq]
    intro k hk i hi1 hi2
    rw [iterate_evol_one, iterate_evol_one]
    -- the column `i` lies `N - i ≤ 2N` cells left of the column `N`
    have h := (RightHalfReturns.eq_left_of_eq_columns hcol (N - i).toNat (by omega) k
      (by omega)).1
    rw [show (N : ℤ) - ((N - i).toNat : ℕ) = i by omega] at h
    exact h
  refine hcov.coverMincard_le_card.trans ?_
  exact_mod_cast (Finset.card_image_le : ((pairWords N L).image rep).card ≤ (pairWords N L).card)


/-- A spatially uniform exponential bound on pair words controls every window cover. -/
theorem entropy_of_growth (C r : ENNReal) (hc : C ≠ ⊤) (hfin : r ≠ ⊤)
    (bound : ∀ (a : ℤ) (n : ℕ), ((pairWords a n).card : ENNReal) ≤ C * r^n) :
    coverEntropy (fun x : ℤ → Bool => evol x 1) Set.univ ≤ ENNReal.log r := by
  refine iSup₂_le fun U hU => ?_
  obtain ⟨N,hN⟩ := exists_windowRel_subset hU
  refine (coverEntropyEntourage_antitone _ _ hN).trans ?_
  have growth (n : ℕ) : ((coverMincard (fun x : ℤ → Bool => evol x 1) Set.univ (windowRel N) n :
      ℕ∞) : ENNReal) ≤ (C * r^(2*N+1))*r^n := by
    have h := ENat.toENNReal_le.2 (window_cover_count N n)
    calc _ ≤ ((pairWords N (n+2*N+1)).card : ENNReal) := by simpa using h
         _ ≤ C * r^(n+2*N+1) := bound N _
         _ = _ := by rw [Nat.add_assoc,pow_add]; ring
  calc coverEntropyEntourage (fun x : ℤ → Bool => evol x 1) Set.univ (windowRel N)
      ≤ ExpGrowth.expGrowthSup fun n : ℕ => r ^ n :=
        ExpGrowth.expGrowthSup_le_of_eventually_le
          (b := C * r^(2*N+1))
          (ENNReal.mul_ne_top hc (ENNReal.pow_ne_top hfin))
          (Eventually.of_forall growth)
    _ = _ := ExpGrowth.expGrowthSup_pow

/-- Any certified upper bound r^k on a positive block length bounds topological entropy by log r. -/
theorem entropy_of_block {k : ℕ} (hk : 0 < k) (r : ENNReal) (hr : 1 ≤ r) (hfin : r ≠ ⊤)
    (blocks : ∀ a : ℤ, ((pairWords a k).card : ENNReal) ≤ r^k) :
    coverEntropy (fun x : ℤ → Bool => evol x 1) Set.univ ≤ ENNReal.log r := by
  have bound (a : ℤ) (n : ℕ) : ((pairWords a n).card : ENNReal) ≤ 4^k * r^n := by
    induction n using Nat.strong_induction_on with
    | h n ih =>
      by_cases small : n < k
      · have base : (pairWords a n).card ≤ 4^n := by
          simpa [Fintype.card_fun, Fintype.card_prod] using Finset.card_le_univ (pairWords a n)
        calc ((pairWords a n).card : ENNReal) ≤ 4^n := by exact_mod_cast base
             _ ≤ 4^k := pow_le_pow_right₀ (by norm_num) (by omega)
             _ ≤ 4^k*r^n := le_mul_of_one_le_right' (one_le_pow₀ hr)
      · obtain ⟨b, hb⟩ := Nat.exists_eq_add_of_le (Nat.le_of_not_gt small)
        have hb' : b<n := by omega
        calc ((pairWords a n).card : ENNReal) ≤ (pairWords a k).card * (pairWords a b).card := by
               rw [hb]; exact_mod_cast submultiplicative a k b
             _ ≤ r^k * (4^k*r^b) := mul_le_mul' (blocks a) (ih b hb')
             _ = 4^k * r^n := by rw [hb,pow_add]; ring
  exact entropy_of_growth _ _ (ENNReal.pow_ne_top (by norm_num)) hfin bound

/-- Nonempty sets of possible hidden spatial pairs (sites a+1,a+2) read back from the future. -/
inductive State where | full | m5 | m10 | m1 | m4 | m2
  deriving DecidableEq
open State

def contains : State → Bool → Bool → Bool
  | full, _, _ => true
  | m5, g, _ => !g
  | m10, g, _ => g
  | m1, g, e => !g && !e
  | m4, g, e => !g && e
  | m2, g, e => g && !e

/-- One step backwards upon reading the wall x(a) and first eastern bit x(a+1).
A missing transition means no assignment of the unobserved eastern cell is possible. -/
def prev : State → Bool × Bool → Option State
  | full, (_, false) => some m5
  | full, (_, true) => some m10
  | m5, (false, false) => some m1
  | m5, (false, true) => none
  | m5, (true, false) => some m4
  | m5, (true, true) => some m10
  | m10, (false, false) => some m4
  | m10, (false, true) => some m10
  | m10, (true, false) => some m1
  | m10, (true, true) => none
  | m1, (false, false) => some m1
  | m1, (true, true) => some m10
  | m1, _ => none
  | m4, (false, false) => some m1
  | m4, (true, false) => some m4
  | m4, (true, true) => some m2
  | m4, _ => none
  | m2, (false, true) => some m10
  | m2, (true, false) => some m1
  | m2, _ => none

/-- The complete local table, including necessity and sufficiency for one physical update. -/
theorem preimage_table : ∀ (s : State) (b g u v : Bool),
    ((prev s (b,g)).elim false (fun q => contains q u v)) =
      (decide (u = g) && (List.any [false,true] fun e =>
        contains s (xor b (u || v)) (xor u (v || e)))) := by intro s; cases s <;> decide

abbrev Letter := Bool × Bool
def alphabet : List Letter := [(false,false),(false,true),(true,false),(true,true)]

/-- Append the read letter at the latest time; the recursion reads from late times to early times. -/
def addLetter {n : ℕ} (l : Letter) (w : Fin n → Letter) : Fin (n+1) → Letter := Fin.lastCases l w

def choices {n : ℕ} (s : State) (l : Letter) (old : State → List (Fin n → Letter)) :=
  (prev s l).elim [] (fun q => (old q).map (addLetter l))

def candidates : (n : ℕ) → State → List (Fin n → Letter)
  | 0, _ => [Fin.elim0]
  | n+1,s => alphabet.flatMap fun l => choices s l (candidates n)

private theorem word_extension (a : ℤ) (n : ℕ) (x : ℤ → Bool) :
    addLetter (evol x n a, evol x n (a+1)) (pairWord a n x) = pairWord a (n+1) x := by
  funext i
  refine Fin.lastCases ?_ (fun j => ?_) i
  · simp [addLetter, pairWord]
  · simp [addLetter, pairWord]

/-- Every physical pair word reaches one of the candidates at its final hidden state. -/
theorem candidate_of_physical (a : ℤ) (x : ℤ → Bool) (n : ℕ) (s : State)
    (h : contains s (evol x n (a+1)) (evol x n (a+2)) = true) :
    pairWord a n x ∈ candidates n s := by
  induction n generalizing s with
  | zero => simp only [candidates,List.mem_singleton]; funext i; exact Fin.elim0 i
  | succ n ih =>
    let l : Letter := (evol x n a, evol x n (a+1))
    have ss : (prev s l).elim false (fun q => contains q (evol x n (a+1)) (evol x n (a+2))) = true := by
      rw [preimage_table]
      simp only [decide_true, Bool.true_and, List.any_cons, List.any_nil, Bool.or_false]
      have old := h
      simp only [evol,Rule30Jen.rule] at old
      rw [show a+1-1=a by omega, show a+2-1=a+1 by omega,
        show a+1+1=a+2 by omega, show a+2+1=a+3 by omega] at old
      cases he : evol x n (a+3) <;> simp [he] at old ⊢ <;> simp [old]
    obtain ⟨q,hq⟩ : ∃ q, prev s l = some q := by
      cases hprev : prev s l with
      | none => simp [hprev] at ss
      | some q => exact ⟨q,rfl⟩
    have ih' := ih q (by simpa [hq] using ss)
    refine List.mem_flatMap.mpr ⟨l, ?_, ?_⟩
    · rcases l with ⟨b,g⟩; cases b <;> cases g <;> decide
    · simpa [choices,hq] using
        (List.mem_map.mpr ⟨pairWord a n x, ih', word_extension a n x⟩ :
          pairWord a (n+1) x ∈ (candidates n q).map (addLetter l))

def weight : State → ℕ
  | full => 504 | m5 | m10 => 318 | m1 | m2 => 209 | m4 => 275

def wopt (s : State) (l : Letter) := (prev s l).elim 0 weight

/-- Integer upper certificate for the four outgoing transitions of each reachable state. -/
theorem weight_table : ∀ s : State,
    21 * ((alphabet.map fun l => wopt s l).sum) ≤ 53 * weight s := by intro s; cases s <;> decide

private theorem candidate_weight (n : ℕ) (s : State) :
    ((candidates n s).length : ℝ) ≤ (weight s : ℝ) * (53/21 : ℝ)^n := by
  induction n generalizing s with
  | zero => cases s <;> norm_num [candidates,weight]
  | succ n ih =>
    have le (l : Letter) : ((choices s l (candidates n)).length : ℝ) ≤
         (wopt s l : ℝ) * (53/21 : ℝ)^n := by
      cases h : prev s l with
      | none => simp [choices,wopt,h]
      | some q => simpa [choices,wopt,h] using ih q
    have cert : ((wopt s (false,false) : ℝ) + wopt s (false,true) + wopt s (true,false) +
        wopt s (true,true)) ≤ (53/21 : ℝ) * weight s := by
      have hnat : 21 * (wopt s (false,false) + wopt s (false,true) + wopt s (true,false) +
          wopt s (true,true)) ≤ 53*weight s := by simpa [alphabet, Nat.add_assoc] using weight_table s
      have hreal : (21:ℝ) * ((wopt s (false,false) : ℝ) + wopt s (false,true) + wopt s (true,false) +
          wopt s (true,true)) ≤ 53*weight s := by exact_mod_cast hnat
      linarith
    have parts := add_le_add (add_le_add (add_le_add (le (false,false)) (le (false,true)))
      (le (true,false))) (le (true,true))
    simp only [candidates,alphabet,List.flatMap_cons,List.flatMap_nil,List.append_nil,
      List.length_append,Nat.cast_add] at *
    rw [pow_succ]
    nlinarith [mul_le_mul_of_nonneg_right cert (by positivity : 0 ≤ (53/21:ℝ)^n)]

theorem card_pairWords_strip (a : ℤ) (n : ℕ) : ((pairWords a n).card : ℝ) ≤ 504*(53/21:ℝ)^n := by
  classical
  have sub : pairWords a n ⊆ (candidates n full).toFinset := by
    intro w hw; obtain ⟨x,rfl⟩ := mem_pairWords.mp hw
    exact List.mem_toFinset.mpr (candidate_of_physical a x n full rfl)
  have hn := (Finset.card_le_card sub).trans (List.toFinset_card_le _)
  exact (Nat.cast_le.mpr hn).trans (candidate_weight n full)

theorem entropy_le_log_53_div_21 :
    coverEntropy (fun x : ℤ → Bool => evol x 1) Set.univ ≤ ENNReal.log (ENNReal.ofReal (53/21)) := by
  apply entropy_of_growth 504 _ (by norm_num) ENNReal.ofReal_ne_top
  intro a n
  have h := ENNReal.ofReal_le_ofReal (card_pairWords_strip a n)
  simpa [ENNReal.ofReal_mul (by norm_num : (0:ℝ) ≤ 504),
    ENNReal.ofReal_pow (by norm_num : (0:ℝ) ≤ 53/21)] using h

theorem entropy_lt_log_three :
    coverEntropy (fun x : ℤ → Bool => evol x 1) Set.univ < ENNReal.log 3 := by
  refine entropy_le_log_53_div_21.trans_lt (ENNReal.log_strictMono ?_)
  exact_mod_cast (show ENNReal.ofReal (53/21) < ENNReal.ofReal 3 by
    rw [ENNReal.ofReal_lt_ofReal_iff (by norm_num)]; norm_num)


/-- Spatial translation preserves the set of pair words, including the letters themselves. -/
theorem pairWords_translate (a b : ℤ) (n : ℕ) : pairWords a n = pairWords b n := by
  have sub (i j : ℤ) : pairWords i n ⊆ pairWords j n := by
    intro w hw
    obtain ⟨x,rfl⟩ := mem_pairWords.mp hw
    let y := fun p : ℤ => x (p+(i-j))
    have eqn : ∀ t k, evol y t k = evol x t (k+(i-j)) :=
      fun t k => (Rule30ZeroBoundaryBarriers.evol_shift_all (x := y) (x' := x)
        (d := i-j) (fun _ => rfl) t k).symm
    refine mem_pairWords.mpr ⟨y,?_⟩
    funext k
    simp only [pairWord, eqn, show j+(i-j)=i by omega, show j+1+(i-j)=i+1 by omega]
  exact Finset.Subset.antisymm (sub a b) (sub b a)

/-- A single measured block at one fixed spatial origin gives a certified upper rate. -/
theorem entropy_le_block_root (a : ℤ) (k : ℕ) (hk : 0 < k) :
    coverEntropy (fun x : ℤ → Bool => evol x 1) Set.univ ≤
      ENNReal.log (((pairWords a k).card : ENNReal) ^ (1/(k:ℝ))) := by
  have pos : 0 < (pairWords a k).card := Finset.card_pos.mpr
    ⟨pairWord a k (fun _ => false), mem_pairWords.mpr ⟨_,rfl⟩⟩
  have one : 1 ≤ ((pairWords a k).card : ENNReal) := by exact_mod_cast pos
  apply entropy_of_block hk _ (ENNReal.one_le_rpow one (by positivity))
    (ENNReal.rpow_ne_top_of_nonneg (by positivity) (by simp))
  intro b
  rw [pairWords_translate b a, ← ENNReal.rpow_mul_natCast]
  simp [Nat.ne_of_gt hk]

/-- The full topological entropy is exactly the exponential growth rate of a single
adjacent pair, with both the alphabet and its physical language fixed. -/
theorem entropy_eq_pair_growth (a : ℤ) :
    coverEntropy (fun x : ℤ → Bool => evol x 1) Set.univ =
      ExpGrowth.expGrowthSup fun n => ((pairWords a n).card : ENNReal) := by
  classical
  apply le_antisymm
  · refine iSup₂_le fun U hU => ?_
    obtain ⟨N,hN⟩ := exists_windowRel_subset hU
    refine (coverEntropyEntourage_antitone _ _ hN).trans ?_
    refine ExpGrowth.expGrowthSup_le_of_eventually_le
      (b := ((pairWords a (2*N+1)).card : ENNReal)) (by simp) (Eventually.of_forall fun n => ?_)
    have h := ENat.toENNReal_le.2 (window_cover_count N n)
    calc _ ≤ ((pairWords N (n+2*N+1)).card : ENNReal) := by simpa using h
         _ = ((pairWords a (n+(2*N+1))).card : ENNReal) := by rw [pairWords_translate (↑N) a, Nat.add_assoc]
         _ ≤ (pairWords a n).card * (pairWords a (2*N+1)).card := by exact_mod_cast submultiplicative a n (2*N+1)
         _ = _ := mul_comm _ _
  · let coord (i : ℤ) : SetRel (ℤ → Bool) (ℤ → Bool) := {p | p.1 i = p.2 i}
    have Ent (i : ℤ) : coord i ∈ 𝓤 (ℤ → Bool) :=
      (Pi.uniformContinuous_proj (fun _ : ℤ => Bool) i)
        (UniformSpace.uniformSpace_eq_bot.mp rfl : SetRel.id ∈ 𝓤 Bool)
    let V := coord a ∩ coord (a+1)
    have hV : V ∈ 𝓤 (ℤ → Bool) := inter_mem (Ent _) (Ent _)
    refine le_trans ?_ (coverEntropyEntourage_le_coverEntropy (fun x : ℤ → Bool => evol x 1) Set.univ hV)
    refine ExpGrowth.expGrowthSup_monotone fun n => ?_
    have bound (s : Finset (ℤ → Bool)) (hs : IsDynCoverOf (fun x : ℤ → Bool => evol x 1) Set.univ V n s) :
        (pairWords a n).card ≤ s.card := by
      have sub : pairWords a n ⊆ s.image (pairWord a n) := by
        intro w hw
        obtain ⟨x,rfl⟩ := mem_pairWords.mp hw
        obtain ⟨y,hy,hxy⟩ := hs (x := x) (Set.mem_univ _)
        refine Finset.mem_image.mpr ⟨y,hy,?_⟩
        funext k
        simp only [dynEntourage,Set.mem_iInter,Set.mem_preimage,Prod.map_iterate,
          Prod.map_apply,V,coord,Set.mem_inter_iff,Set.mem_ofPred_eq,iterate_evol_one] at hxy
        have eqs := hxy k k.isLt
        exact Prod.ext eqs.1.symm eqs.2.symm
      exact (Finset.card_le_card sub).trans Finset.card_image_le
    have hm : ((pairWords a n).card : ℕ∞) ≤ coverMincard (fun x : ℤ → Bool => evol x 1) Set.univ V n :=
      le_iInf₂ fun s hs => by exact_mod_cast bound s hs
    simpa using ENat.toENNReal_le.2 hm

end K83B
