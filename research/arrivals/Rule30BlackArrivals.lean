import Rule30WhiteArrivalMarkers

/-! Sample Lowry's net on the black tick immediately following each white.
A visible pulse followed four white intervals later by a zero is exactly
an odd-return start, on a late singleton GE2 tail. -/
namespace Ruliology.CellularAutomata.Rule30BlackArrivals

open Rule30Jen Rule30SourceArrivals Rule30WhiteArrivalWindow
open Rule30WhiteArrivals Rule30WhiteArrivalMarkers
open Rule30PeriodTwoWidth13 (AltFrom)

def blackNet (T k : Nat) := net (T+2*k+2)
def blackShell (T k : Nat) := shell (T+2*k+2)

private def mark (x : Row) := gate x && x.getLsbD 1

private def blackReading (x : Row) :=
  let y := tick x false false
  gate y && !y.getLsbD 1

private theorem second (t : Nat) : (row t).getLsbD 1 = cell t 2 :=
  (by decide +kernel : ∀ a b c d e f : Bool, (pack a b c d e f).getLsbD 1 = b) _ _ _ _ _ _

private theorem physical_black (t : Nat) (w : cell t 0=false) (b : cell (t+1) 0=true)
    (w' : cell (t+2) 0=false) : blackReading (row t) = net (t+1) := by
  have e : blackReading (row t) = (gate (row (t+1)) && !(row (t+1)).getLsbD 1) := by
    rw [physical_tick, w]
    exact (by decide +kernel : ∀ (r : Row) (e : Bool),
      blackReading r = (gate (tick r false e) && !(tick r false e).getLsbD 1)) _ _
  rw [e, physical_gate, second]
  simp [net, source, b, w']

/-- The rows of a finite strip are filtered by the supplied gate word and by
an extra predicate at specified observation times. -/
private def viable (gs : List Bool) (i : Nat) (rows : List Row) (test : Nat → Row → Bool) : Bool :=
  match gs with
  | [] => true
  | g :: rest =>
    let same := rows.filter (fun x => (gate x == g) && test i x)
    !same.isEmpty && viable rest (i+1) (advance same) test

private theorem viable_of_path (r : Nat → Row) (n i : Nat) (rows : List Row)
    (test : Nat → Row → Bool) (start : 0<n → r 0 ∈ rows)
    (steps : ∀ j, j+1<n → edge (r j) (r (j+1)) = true)
    (agree : ∀ j, j<n → test (i+j) (r j) = true) :
    viable (samples (fun j => gate (r j)) n) i rows test = true := by
  induction n generalizing r rows i with
  | zero => rfl
  | succ n ih =>
    rw [samples_succ, viable]
    let same := rows.filter (fun x => gate x == gate (r 0) && test i x)
    have mem : r 0 ∈ same := List.mem_filter.mpr
      ⟨start (by omega),by simpa using agree 0 (by omega)⟩
    have live := List.isEmpty_eq_false_iff.mpr (List.ne_nil_of_mem mem)
    change !same.isEmpty && viable _ (i+1) (advance same) test = true
    rw [live, Bool.not_false, Bool.true_and]
    apply ih
    · intro hn
      exact List.mem_eraseDups.mpr (List.mem_flatMap.mpr ⟨_,mem,child_of_edge (steps 0 (by omega))⟩)
    · exact fun j hj => steps (j+1) (by omega)
    · intro j hj
      rw [show i+1+j=i+(j+1) by omega]
      exact agree _ (by omega)

private def atSamples (m b c : Bool) (i : Nat) (x : Row) : Bool :=
  if i=1 then (mark x == m) && (blackReading x == b)
  else if i=5 then blackReading x == c else true

private def grade (gs : List Bool) : Bool :=
  !clean (fun i => gs.getD i false) 10 ||
    [false,true].all fun m => [false,true].all fun b => [false,true].all fun c =>
      (m == (b && !c)) || !viable gs 0 allRows (atSamples m b c)

set_option maxRecDepth 8000 in
set_option maxHeartbeats 0 in
private theorem census : (allLists 10).all grade = true := by decide +kernel

private theorem window (r : Nat → Row) (edges : validEdges r 9 = true)
    (ge : clean (fun i => gate (r i)) 10 = true) :
    mark (r 1) = (blackReading (r 1) && !blackReading (r 5)) := by
  let gs := samples (fun i => gate (r i)) 10
  have len : gs.length=10 := by simp [gs,samples]
  have ok := List.all_eq_true.mp census gs (len ▸ mem_allLists gs)
  have cl : clean (fun i => gs.getD i false) 10 = true := (clean_ext 10 (fun i hi => get_sample _ hi)).trans ge
  simp only [grade, cl, Bool.not_true, Bool.false_or] at ok
  have both (v : Bool) : v ∈ [false,true] := by cases v <;> simp
  have choice := List.all_eq_true.mp (List.all_eq_true.mp (List.all_eq_true.mp ok
    (mark (r 1)) (both _)) (blackReading (r 1)) (both _)) (blackReading (r 5)) (both _)
  have path := viable_of_path r 10 0 allRows (atSamples (mark (r 1)) (blackReading (r 1))
    (blackReading (r 5))) (fun _ => has_row _)
    (fun j hj => List.all_eq_true.mp edges j (List.mem_range.mpr (by omega))) (by
      intro j _
      by_cases a : j=1
      · subst j; simp [atSamples]
      · by_cases b : j=5
        · subst j; simp [atSamples]
        · simp [atSamples,a,b])
  change viable gs 0 allRows _ = true at path
  simpa [path] using choice

/-- Two black readings, four white intervals apart, recognize the odd-return
kick at the earlier white sample. The threshold is the one provided by GE2. -/
theorem black_marks {T : Nat} (alt : AltFrom T) :
    ∃ K, ∀ k, K≤k → oddKick T k = (blackNet T k && !blackNet T (k+4)) := by
  obtain ⟨K,hK⟩ := eventual_clean alt
  refine ⟨K+1,fun k hk => ?_⟩
  let j := k-1
  let r := fun i => row (T+2*(j+i)+1)
  have black (i : Nat) : cell (T+2*(j+i)+1+1) 0 = true := by
    rw [show T+2*(j+i)+1+1=T+2*(j+i+1) by omega]; exact (alt _).1
  have white (i : Nat) : cell (T+2*(j+i)+1+2) 0 = false := by
    rw [show T+2*(j+i)+1+2=T+2*(j+i+1)+1 by omega]; exact (alt _).2
  have ed : validEdges r 9 = true := by
    apply List.all_eq_true.mpr
    intro i _
    change edge (row (T+2*(j+i)+1)) (row (T+2*(j+(i+1))+1)) = true
    rw [show T+2*(j+(i+1))+1=T+2*(j+i)+1+2 by omega]
    exact physical_edge _ (alt _).2 (black _)
  have gates (i : Nat) : gate (r i) = whiteGate T (j+i) := physical_gate _
  have marks (i : Nat) : mark (r i) = oddKick T (j+i) := by rw [mark,gates]; exact congrArg _ (second _)
  have seen (i : Nat) : blackReading (r i) = blackNet T (j+i) :=
    physical_black _ (alt _).2 (black _) (white _)
  have eq := window r ed (by simpa only [gates] using hK j (by dsimp [j]; omega) 10)
  simpa only [marks,seen,show j+1=k by dsimp [j]; omega,show j+5=k+4 by dsimp [j]; omega] using eq

theorem black_net_aperiodic {T : Nat} (alt : AltFrom T) : ¬ EventuallyPeriodic (blackNet T) := by
  rintro ⟨L,p,hp,per⟩
  obtain ⟨K,law⟩ := black_marks alt
  apply odd_kicks_aperiodic alt
  refine ⟨K+L,p,hp,fun k hk => ?_⟩
  rw [law (k+p) (by omega),law k (by omega),per k (by omega),show k+p+4=k+4+p by omega,per (k+4) (by omega)]

theorem black_shell_complement {T : Nat} (alt : AltFrom T) (k : Nat) :
    blackShell T k = !blackNet T k := by
  have e := two_step (T+2*k+2)
  rw [show T+2*k+2+2=T+2*(k+2) by omega,(alt _).1] at e
  exact (by decide : ∀ a b : Bool, true=xor a b → a=(!b)) _ _ e

theorem black_shell_aperiodic {T : Nat} (alt : AltFrom T) : ¬ EventuallyPeriodic (blackShell T) := by
  rintro ⟨L,p,hp,per⟩
  apply black_net_aperiodic alt
  refine ⟨L,p,hp,fun k hk => ?_⟩
  have h := per k hk
  rw [black_shell_complement alt, black_shell_complement alt] at h
  exact (by decide : ∀ a b : Bool, (!a)=(!b) → a=b) _ _ h

theorem both_phases {T : Nat} (alt : AltFrom T) :
    ¬EventuallyPeriodic (whiteNet T) ∧ ¬EventuallyPeriodic (blackNet T) ∧
    ¬EventuallyPeriodic (whiteShell T) ∧ ¬EventuallyPeriodic (blackShell T) :=
  ⟨white_net_aperiodic alt,black_net_aperiodic alt,white_shell_aperiodic alt,black_shell_aperiodic alt⟩

end Ruliology.CellularAutomata.Rule30BlackArrivals
