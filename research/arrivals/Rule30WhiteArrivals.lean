import Rule30WhiteArrivalWindow

/-! Under an eventually alternating singleton centre, Lowry's arrival net
and distance-two shell remain aperiodic even when sampled only on white ticks.
The GE2 mode and the obstruction to periodic kicks come from the kit. -/
namespace Ruliology.CellularAutomata.Rule30WhiteArrivals

open Rule30Jen Rule30SourceArrivals Rule30WhiteArrivalWindow
open Rule30PeriodTwoWidth13

def whiteGate (T k : Nat) := cell (T+2*k+1) 1
def whiteNet (T k : Nat) := net (T+2*k+1)
def whiteShell (T k : Nat) := shell (T+2*k+1)

private def nextQ (q : Nat) (b : Bool) : Option Nat :=
  (delta 1 q false).bind (fun h => delta 1 h b)

private def feed (q : Nat) : List Bool → Option Nat
  | [] => some q
  | b :: tail => (nextQ q b).bind (fun h => feed h tail)

private theorem rejects : ∀ q : Fin 60, banned.all (fun w => (feed q.val w).isNone) = true := by
  decide +kernel

private theorem follow {g : Nat → Bool} {q : Nat → Nat}
    (step : ∀ i, nextQ (q i) (g i) = some (q (i+1)))
    (i : Nat) (w : List Bool) (reads : readsWord g i w = true) :
    feed (q i) w = some (q (i+w.length)) := by
  induction w generalizing i with
  | nil => rfl
  | cons a w ih =>
    simp only [readsWord, Bool.and_eq_true, beq_iff_eq] at reads
    rw [feed, ←reads.1, step, Option.bind_some, ih (i+1) reads.2]
    congr 2 <;> simp <;> omega

private theorem clean_of_walk {g : Nat → Bool} {q : Nat → Nat}
    (bound : ∀ i, q i < 60) (step : ∀ i, nextQ (q i) (g i) = some (q (i+1))) (n : Nat) :
    clean g n = true := by
  apply List.all_eq_true.mpr
  intro w hw
  apply List.all_eq_true.mpr
  intro i _
  cases seen : readsWord g i w with
  | false => rfl
  | true =>
    have rejected := List.all_eq_true.mp (rejects ⟨q i,bound i⟩) w hw
    have reached := follow step i w seen
    simp [reached] at rejected

private theorem black_kick {T : Nat} (alt : AltFrom T) (k : Nat) :
    kick (node (T+2*k)) = false := by
  rw [kick_node]
  change (!cell (T+2*k) 0 && _) = false
  rw [(alt k).1]; rfl

private theorem white_kick {T : Nat} (alt : AltFrom T) (k : Nat) :
    kick (node (T+2*k+1)) = whiteGate T k := by
  rw [kick_node]
  change (!cell (T+2*k+1) 0 && _) = _
  rw [(alt k).2]; rfl

/-- Every late white window in the singleton obeys the short GE2 exclusions.
The kit's other possible eventual mode, pure four, is excluded by its finite
left trace. The proof uses the actual width-13 strip and both physical ticks. -/
theorem eventual_clean {T : Nat} (alt : AltFrom T) :
    ∃ K, ∀ k, K ≤ k → ∀ n, clean (fun i => whiteGate T (k+i)) n = true := by
  obtain ⟨base,m,_,walk⟩ := path_run (fun n => node (T+n)) (node_lt _) (fun n => by
    simpa [Nat.add_assoc] using strip_path alt n)
  have mode : m = 1 := Classical.byContradiction fun h => not_pure4 alt base m h walk
  subst m
  obtain ⟨q,hq⟩ := choose_states walk
  have trans (j : Nat) : delta 1 (q j) (kick (node (T+(base+(j+1))))) = some (q (j+1)) := by
    have e := (hq (j+1)).1
    rwa [run_succ, (hq j).1, Option.bind_some] at e
  refine ⟨base+1, fun k hk n => ?_⟩
  let j := fun i => 2*(k+i)-1-base
  apply clean_of_walk (q := fun i => q (j i)) (fun i => (hq _).2) _ n
  intro i
  have first := trans (j i)
  have second := trans (j i+1)
  rw [show T+(base+(j i+1)) = T+2*(k+i) by dsimp [j]; omega, black_kick alt] at first
  rw [show T+(base+(j i+1+1)) = T+2*(k+i)+1 by dsimp [j]; omega,
    white_kick alt, show j i+1+1 = j (i+1) by dsimp [j]; omega] at second
  simpa [nextQ,first] using second

private theorem next_black {T : Nat} (alt : AltFrom T) (k : Nat) :
    cell (T+2*k+1+1) 0 = true := by
  simpa only [show T+2*k+1+1=T+2*(k+1) by omega] using (alt (k+1)).1

/-- Six preceding readings, the current reading and two following readings
of the net on the white phase recover the right neighbour on that phase. -/
theorem eventual_gate_decoder {T : Nat} (alt : AltFrom T) :
    ∃ K, ∀ k, K ≤ k → whiteGate T (k+6) = decode (fun i => whiteNet T (k+i)) := by
  obtain ⟨K,hK⟩ := eventual_clean alt
  refine ⟨K, fun k hk => ?_⟩
  let r := fun i => row (T+2*(k+i)+1)
  have gate_eq (i : Nat) : gate (r i) = whiteGate T (k+i) := physical_gate _
  have net_eq (i : Nat) : reading (r i) = whiteNet T (k+i) :=
    physical_reading _ (alt _).2 (next_black alt _)
  have edges : validEdges r 12 = true := by
    apply List.all_eq_true.mpr
    intro i _
    change edge (row (T+2*(k+i)+1)) (row (T+2*(k+(i+1))+1)) = true
    rw [show T+2*(k+(i+1))+1 = T+2*(k+i)+1+2 by omega]
    exact physical_edge _ (alt _).2 (next_black alt _)
  have law := window r edges (by simpa only [gate_eq] using hK k hk 13)
  simpa only [gate_eq, net_eq] using law

/-- A periodic white-source stream would give the same period to the late
white gates. The black ticks of the kit's kick stream are all zero. -/
theorem white_net_aperiodic {T : Nat} (alt : AltFrom T) : ¬ EventuallyPeriodic (whiteNet T) := by
  obtain ⟨K,law⟩ := eventual_gate_decoder alt
  rintro ⟨L,p,hp,period⟩
  have gates (k : Nat) (hk : K+L+6 ≤ k) : whiteGate T (k+p) = whiteGate T k := by
    let i := k-6
    have a : i+6=k := by dsimp [i]; omega
    have b : i+p+6=k+p := by omega
    rw [←b, law (i+p) (by dsimp [i]; omega), ←a, law i (by dsimp [i]; omega)]
    apply congrArg decode
    funext d
    rw [show i+p+d=i+d+p by omega]
    exact period _ (by dsimp [i]; omega)
  apply kicks_not_eventually_periodic alt (2*(K+L+6)) (2*p) (by omega)
  intro n hn
  obtain ⟨k,even | odd⟩ := exists_half n
  · rw [even, show T+(2*k+2*p)=T+2*(k+p) by omega, black_kick alt, black_kick alt]
  · rw [odd, show T+(2*k+1+2*p)=T+2*(k+p)+1 by omega,
      show T+(2*k+1)=T+2*k+1 by omega, white_kick alt, white_kick alt]
    exact gates k (by omega)

theorem white_shell_eq {T : Nat} (alt : AltFrom T) (k : Nat) : whiteShell T k = whiteNet T k := by
  have eq := two_step (T+2*k+1)
  rw [show T+2*k+1+2=T+2*(k+1)+1 by omega, (alt _).2] at eq
  exact (by decide : ∀ a b : Bool, false = xor a b → a=b) _ _ eq

theorem white_shell_aperiodic {T : Nat} (alt : AltFrom T) : ¬ EventuallyPeriodic (whiteShell T) := by
  rw [funext (white_shell_eq alt)]
  exact white_net_aperiodic alt

end Ruliology.CellularAutomata.Rule30WhiteArrivals
