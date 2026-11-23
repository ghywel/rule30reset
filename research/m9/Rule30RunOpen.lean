module

public import Ruliology.CellularAutomata.Rule30RunChecks

/-! The M9 width certificate also excludes traces with fresh right-boundary choices at every step. -/
@[expose] public section
namespace Ruliology.CellularAutomata.Rule30RunOpen
open Rule30RunWindow Rule30RunCertificate Rule30RunChecks Rule30TrappedRuns Rule30DrivenPrefix
set_option maxHeartbeats 0
set_option maxRecDepth 100000

def Links (w : Nat) (row : Nat → Nat) : Prop :=
  ∀ t, ∃ x, x % 2^w = row t % 2^w ∧ double x % 2^w = row (t+1) % 2^w

def At (w : Nat) (row : Nat → Nat) (t : Nat) (d : Window) : Prop :=
  d.width ≤ w ∧ Holds d (row t)

def Walk (w : Nat) (row : Nat → Nat) (t : Nat) : List Window → Prop
  | [] => True
  | a::as => At w row t a ∧ Walk w row (t+1) as

theorem restrict_mod {x y w b : Nat} (e : x%2^w=y%2^w) (le : b≤w) :
    x%2^b=y%2^b := by
  have f := congrArg (fun z => z % 2^b) e
  simpa only [Nat.mod_mod_of_dvd _ (Nat.pow_dvd_pow 2 le)] using f

private theorem move {x y w : Nat} {a : Window} (e : x%2^w=y%2^w) (le : a.width≤w) :
    Holds a x ↔ Holds a y := by
  unfold Holds
  rw [restrict_mod e le]

private theorem front_ok {row : Nat → Nat} {w t : Nat} {a b : Window} {m : Mark}
    (h : Links w row) (ok : fValid a b m) (pa : At w row t a) (pb : At w row (t+1) b) :
    At w row (t+1) m.box := by
  have eq := of_decide_eq_true (Bool.and_eq_true_iff.mp ok).2
  have le : m.box.width ≤ w := by rw [eq]; exact pb.1
  obtain ⟨x,ex,ey⟩ := h t
  exact ⟨le,(move ey le).mp (fValid_sound ok ((move ex pa.1).mpr pa.2) ((move ey pb.1).mpr pb.2))⟩

private theorem back_ok {row : Nat → Nat} {w t : Nat} {a b : Window} {m : Mark}
    (h : Links w row) (ok : bValid a b m) (pa : At w row t a) (pb : At w row (t+1) b) :
    At w row t m.box := by
  have eq := of_decide_eq_true (Bool.and_eq_true_iff.mp ok).2
  have le : m.box.width ≤ w := by rw [eq]; exact pa.1
  obtain ⟨x,ex,ey⟩ := h t
  exact ⟨le,(move ex le).mp (bValid_sound ok ((move ex pa.1).mpr pa.2) ((move ey pb.1).mpr pb.2))⟩

private theorem front_walk {row : Nat → Nat} {w t : Nat} {a : Window} {bs : List Window} {ms : List Mark}
    (link : Links w row) (ok : fChain a bs ms) (h : Walk w row t (a::bs)) :
    Walk w row t (a::ms.map Mark.box) := by
  induction bs generalizing a ms t with
  | nil => cases ms <;> simp [fChain] at ok <;> exact h
  | cons b bs ih =>
    cases ms with
    | nil => simp [fChain] at ok
    | cons m ms =>
      obtain ⟨edge,rest⟩ := Bool.and_eq_true_iff.mp ok
      exact ⟨h.1, ih rest ⟨front_ok link edge h.1 h.2.1,h.2.2⟩⟩

private theorem back_walk {row : Nat → Nat} {w t : Nat} {bs : List Window} {ms : List Mark}
    (link : Links w row) (ok : bChain bs ms) (h : Walk w row t bs) :
    Walk w row t (ms.map Mark.box) := by
  induction bs generalizing ms t with
  | nil => cases ms <;> simp [bChain] at ok <;> trivial
  | cons a bs ih =>
    cases ms with
    | nil => cases bs <;> simp [bChain] at ok
    | cons m ms =>
      cases bs with
      | nil =>
        cases ms with
        | nil =>
          have eq : m.box = a := of_decide_eq_true ok
          exact ⟨eq.symm ▸ h.1, trivial⟩
        | cons n ms => simp [bChain] at ok
      | cons b bs =>
        cases ms with
        | nil => simp [bChain] at ok
        | cons n ms =>
          obtain ⟨edge,rest⟩ := Bool.and_eq_true_iff.mp ok
          have ht := ih rest h.2
          exact ⟨back_ok link edge h.1 ht.1,ht⟩

def widths (w : Nat) (ds : List Window) := ds.all (fun d => decide (d.width≤w))

private theorem lift_walk {w t m : Nat} {row : Nat → Nat} {ds : List Window}
    (ok : widths w (liftAt m ds)) (h : Walk w row t ds) : Walk w row t (liftAt m ds) := by
  induction ds generalizing m t with
  | nil => trivial
  | cons a ds ih =>
    obtain ⟨p,q⟩ := Bool.and_eq_true_iff.mp ok
    refine ⟨⟨of_decide_eq_true p,?_⟩, ih q h.2⟩
    change Holds (if _ then _ else _) _
    split <;> first | exact widen_sound h.1.2 | exact h.1.2

private theorem open_pass {w t i : Nat} {row : Nat → Nat} (link : Links w row)
    (limit : widths w (liftAt (pass i).grow (state i))) (ok : verifies (state i) (pass i))
    (h : Walk w row t (state i)) : Walk w row t (state (i+1)) := by
  have hh := lift_walk limit h
  unfold verifies at ok
  cases eq : liftAt (pass i).grow (state i) with
  | nil => simp [eq] at ok
  | cons a as =>
    rw [eq] at hh ok
    obtain ⟨f,b⟩ := Bool.and_eq_true_iff.mp ok
    exact back_walk link b (front_walk link f hh)

theorem of_frames {row : Nat → Nat} {w t : Nat} {ds : List Window}
    (h : ∀ i (hi : i<ds.length), At w row (t+i) ds[i]) : Walk w row t ds := by
  induction ds generalizing t with
  | nil => trivial
  | cons a ds ih =>
    refine ⟨h 0 (by simp), ih ?_⟩
    intro i hi
    have v := h (i+1) (by simpa using hi)
    change At w row (t+(i+1)) ds[i] at v
    rwa [show t+1+i=t+(i+1) by omega]

private theorem no_empty {row : Nat → Nat} {w t : Nat} {ds : List Window} (h : Walk w row t ds) :
    ds.any (fun d => d.codes.isEmpty) = false := by
  induction ds generalizing t with
  | nil => rfl
  | cons a ds ih =>
    have hn : a.codes ≠ [] := List.ne_nil_of_mem h.1.2
    rw [List.any_cons, ih h.2]
    simp [hn]

private theorem limits : ∀ i, i<30 → widths 45 (liftAt (pass i).grow (state i)) = true := by decide +kernel

/-- A different exterior may be chosen at every one of the 97 edges. -/
theorem no_open_trace {row : Nat → Nat} (link : Links 45 row) (t : Nat) : ¬ Walk 45 row t initial := by
  intro h0
  have h1 := open_pass link (limits 0 (by decide)) check0 h0
  have h2 := open_pass link (limits 1 (by decide)) check1 h1
  have h3 := open_pass link (limits 2 (by decide)) check2 h2
  have h4 := open_pass link (limits 3 (by decide)) check3 h3
  have h5 := open_pass link (limits 4 (by decide)) check4 h4
  have h6 := open_pass link (limits 5 (by decide)) check5 h5
  have h7 := open_pass link (limits 6 (by decide)) check6 h6
  have h8 := open_pass link (limits 7 (by decide)) check7 h7
  have h9 := open_pass link (limits 8 (by decide)) check8 h8
  have h10 := open_pass link (limits 9 (by decide)) check9 h9
  have h11 := open_pass link (limits 10 (by decide)) check10 h10
  have h12 := open_pass link (limits 11 (by decide)) check11 h11
  have h13 := open_pass link (limits 12 (by decide)) check12 h12
  have h14 := open_pass link (limits 13 (by decide)) check13 h13
  have h15 := open_pass link (limits 14 (by decide)) check14 h14
  have h16 := open_pass link (limits 15 (by decide)) check15 h15
  have h17 := open_pass link (limits 16 (by decide)) check16 h16
  have h18 := open_pass link (limits 17 (by decide)) check17 h17
  have h19 := open_pass link (limits 18 (by decide)) check18 h18
  have h20 := open_pass link (limits 19 (by decide)) check19 h19
  have h21 := open_pass link (limits 20 (by decide)) check20 h20
  have h22 := open_pass link (limits 21 (by decide)) check21 h21
  have h23 := open_pass link (limits 22 (by decide)) check22 h22
  have h24 := open_pass link (limits 23 (by decide)) check23 h23
  have h25 := open_pass link (limits 24 (by decide)) check24 h24
  have h26 := open_pass link (limits 25 (by decide)) check25 h25
  have h27 := open_pass link (limits 26 (by decide)) check26 h26
  have h28 := open_pass link (limits 27 (by decide)) check27 h27
  have h29 := open_pass link (limits 28 (by decide)) check28 h28
  have h30 := open_pass link (limits 29 (by decide)) check29 h29
  have empty : (state 30).any (fun d => d.codes.isEmpty) = true := by decide +kernel
  exact Bool.noConfusion ((no_empty h30).symm.trans empty)

end Ruliology.CellularAutomata.Rule30RunOpen
