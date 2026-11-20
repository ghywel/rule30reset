---
Template: ComputationalEssay
Name: Deep Closed Runs on Every Recurrent Edge Strip Give Reset Capacity, and So Every Number of Inverse Ticks
Author: {AUTHORS}
Date: 2026-11-20
Description: Core Lean. The kit's open hypothesis CAP, on the reset capacity of finite edge bands at every width, follows from one property of infinite left-edge strips: every tick's row has closed runs at arbitrarily large depths. With the kit's conditional theorem this gives the inverse-tick statement for every k from that property alone. The property is open. Nothing here decides Q01.
Abstract: In core Lean 4.35.0 we prove that the kit's reset-capacity hypothesis `CAP` follows from a property of infinite left-edge strips (`Rule30Submission.cap_of_unbounded_resets`). A pointed recurrent strip is an array of cells, wheels 0, 1, 2, … by ticks 0, 1, 2, …, that obeys rule 30's left-edge recurrence, is black at wheel 0, and for each m has a positive period common to wheels 0 to m. `LInfinity` says that in every such strip the row of every tick contains closed runs, a white cell, 3n + 1 black cells and a white cell, starting at arbitrarily large depths. With the kit's `conditional_every_k`, the same hypothesis gives for every k an age from which every k-tick predecessor of every aged nonzero finite row beside the white wall is finite, with its edge exactly k cells inside, and every history at cell 1 occurs (`Rule30Submission.every_k_of_unbounded_resets`). The catalog has this from `CAP` (`Rule30EveryKInverse`), and an open kit pull request (371) proves it without hypothesis for k ≤ 25. Nothing yet derived `CAP` itself. The proof is compactness. If no window held a closed run beyond a given depth in every periodic band, a limit of failing bands would be a pointed recurrent strip with no such run at tick 0. Nesting the windows bounds the width the schedule needs for each k. `LInfinity` is open, and nothing here decides `Q01`.
Keywords: [rule 30, Rule 30 Prize, zero-boundary left half, white wall, inverse ticks, every k, reset capacity, closed runs, recurrent strips, compactness, conditional theorem, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

**Strips.** Read rule 30 from the left edge of a configuration. *Wheel* `j` at *tick* `t` is the cell `j` places in from the leftmost black cell at time `t`, so wheel 0 is the edge. A *strip* is an array `d j t` of cells, over every wheel and every tick, that obeys the left-edge recurrence of the kit's `Rule30AgedLeftDiagonals.Recurrence`:
- `d 0 (t + 1) = d 0 t`,
- `d 1 (t + 1) = d 0 t ∨ d 1 t`,
- `d (j + 2) (t + 1) = d j t ⊕ (d (j + 1) t ∨ d (j + 2) t)`.

It is *pointed* when `d 0 0` is black, and *recurrent* when for every `m` the wheels `0` to `m` have a common positive period from tick 0 (`Clock d m p`). The period may grow with `m`, and the whole strip need not be periodic. The row of tick `s` is the word `j ↦ d j s`, read from the edge inwards.

**Closed runs.** A *closed run* in a row, at depth `j`, is a white cell at wheel `j`, then `n` black cells with `n` one more than a multiple of three, then a white cell (`Rule30RecurrentStrip.Reset`).

**The hypothesis.** `LInfinity` says: in every pointed recurrent strip, the row of every tick `s` has closed runs at every depth `lo` or beyond. In Lean:

```lean
def LInfinity : Prop := ∀ (d : Nat → Nat → Bool), Recurrence d → d 0 0 = true →
  (∀ m, ∃ p, 0 < p ∧ Clock d m p) →
  ∀ s lo, ∃ j n, lo ≤ j ∧ Reset (fun i => d i s) j n
```

**The kit's capacity.** The kit's inverse-tick theorem (`Rule30EveryKInverse`) rests on one named hypothesis, `CAP` (`Rule30EveryKStatement.CAP`). The top `w` cells of a row, its *band*, evolve on their own by a band map. On a cycle of that map, a schedule reads layer `d` of an inverse cascade from the cycle's phase `−d`, each layer stopping at the deepest *complete factor* left to it: a closed run together with the one symbol next to it on the edge side. `K1 w` is the least number of layers that schedule clears, over every cycle of width `w` and every phase of each. `CAP` says that for every `k` some width `w > 0` has `K1 w ≥ k`.

**The theorems.**
- `Rule30Submission.cap_of_unbounded_resets : LInfinity → CAP`.
- `Rule30Submission.every_k_of_unbounded_resets : LInfinity → ∀ k, ∃ age, TargetAt k age`.

`TargetAt k age` is the kit's target for `k` inverse ticks beside the white wall. For every nonzero finite seed and every time `t ≥ age`, every `k`-tick predecessor of the row at time `t`, a priori of infinite support, has three properties:
- its last black cell is exactly `k` cells inside the row's edge;
- it is the row of a natural number;
- every choice of cell 1 at times `0` to `k − 1` occurs.

In the proof the age is the kit's: `W − 1 + 2^W`, with `W` the least width of capacity `k`.

## 2. Where it sits

The kit proves the target for every `k` from `CAP`, by one argument with no cover for any particular `k`. `CAP` is a statement about finite bands at every width. Its values are known only where they are computed:
- an open kit pull request (371) evaluates `K1 300 = 25` in Lean, which gives the target for `k ≤ 25` without the hypothesis;
- our record computes 7,911 layers at width 87,867, outside Lean.

`LInfinity` has no width in it. It is a property of infinite strips, about each tick on its own, and it asks only that closed runs never stop. This entry proves that it is enough. The inverse-tick statement for every `k` now rests in Lean on `LInfinity` alone.

## 3. Exploration

**A pointed recurrent strip.** The single black cell's left side, from age 1,200: the top 96 wheels, with the edge on the left and time downwards. The black cells of each closed run are orange.

```wl
f[y_Integer] := BitXor[BitShiftRight[y, 1], BitOr[y, BitShiftLeft[y, 1]]];
step[w_Integer][v_Integer] := Mod[BitXor[BitShiftLeft[v, 2], BitOr[BitShiftLeft[v, 1], v]], 2^w];
band[w_Integer, y_Integer] := FromDigits[Reverse[Take[IntegerDigits[y, 2], w]], 2];
closedRuns[v_Integer, avail_Integer] := Module[{bits = Reverse[IntegerDigits[v, 2, avail]], pos = 0, out = {}},
   Do[If[First[r] == 1, AppendTo[out, {pos, pos + Length[r] - 1}]]; pos += Length[r], {r, Split[bits]}];
   Select[out, #[[1]] >= 2 && #[[2]] <= avail - 2 && Mod[#[[2]] - #[[1]] + 1, 3] == 1 &]];
marked[v_Integer, w_Integer] := Module[{a = Reverse[IntegerDigits[v, 2, w]]},
   Do[a[[r[[1]] + 1 ;; r[[2]] + 1]] = 2, {r, closedRuns[v, w]}]; a];
rows = NestList[f, 1, 1500];
ArrayPlot[Table[marked[band[96, rows[[a + 1]]], 96], {a, 1200, 1263}],
  ColorRules -> {0 -> White, 1 -> Black, 2 -> Orange}, ImageSize -> 420, Frame -> False]
```

These 96 wheels have already settled. Their least common period, and a check that they repeat with it from age 1,200 to age 1,480:

```wl
period[w_Integer, v_Integer] := SelectFirst[2^Range[0, 12], Nest[step[w], v, #] == v &, None];
{period[96, band[96, rows[[1201]]]], And @@ Table[band[96, rows[[a + 9]]] == band[96, rows[[a + 1]]], {a, 1200, 1480}]}
```

Each wheel is periodic, the periods grow with the depth, and every finite prefix has a common period. The rows are the first wheels of a pointed recurrent strip, and in each of them closed runs keep appearing further in. That is what `LInfinity` asks of every such strip.

**The window of the compactness step.** The first step of the proof says that for each depth `lo` there is one width `b` such that every odd band on a cycle, of width at least `b`, has a complete factor beyond `lo` that ends by wheel `b`. On the single cell's strip, take its cycle at width 600, with 16 phases. Here is the least such `b` for every phase of that cycle, at depths `lo` from 0 to 550:

```wl
W = 600;
cycle = With[{v = band[W, rows[[-1]]]}, NestList[step[W], v, period[W, v] - 1]];
runs = closedRuns[#, W] & /@ cycle;
window[lo_] := Max[Min[Append[#[[2]] + 2 & /@ Select[#, #[[1]] - 2 >= lo &], Infinity]] & /@ runs];
{Length[cycle], Table[{lo, window[lo]}, {lo, 0, 550, 50}]}
```

The window runs a little beyond the depth asked for. Here are the largest, smallest and mean excess `b − lo` over every depth from 0 to 560, and the depth where the largest occurs:

```wl
gaps = Table[window[lo] - lo, {lo, 0, 560}];
{Max[gaps], First[Ordering[gaps, -1]] - 1, Min[gaps], N[Mean[gaps], 3]}
```

Kit pull request 371 proves that through width 53,208 every odd band on a cycle is one of these 16 phases (`periodic_oddBand_eq_bPhase_of_le_53208`). A band of any greater width on a cycle has its first 600 wheels on a cycle too, and a complete factor that ends by wheel `b` lies in those wheels. So at these depths these windows are the windows of the theorem, not just of this strip.

**Nesting the windows.** The second step applies the first one layer at a time. With `u 0 = 0` and `u (k + 1)` the window for depth `u k`, the schedule clears `k` layers at every width of at least `u k` (here `u k` is never below `k`, as the proof also needs). Here are `u k`, and the capacity the schedule actually reaches on this cycle at width `u k + 1`, for `k` from 1 to 30:

```wl
capacity[w_Integer, v_Integer] := Module[{p = period[w, v], d = 0, avail = w, rs},
   While[d < w && (rs = closedRuns[Nest[step[w], v, Mod[-d, p]], avail]) =!= {}, d++; avail = Max[rs[[All, 1]]] - 2]; d];
K1seed[w_Integer] := Min[capacity[w, Mod[#, 2^w]] & /@ cycle];
u = NestList[window, 0, 30];
Table[{k, u[[k + 1]], K1seed[u[[k + 1]] + 1]}, {k, 1, 30}]
```

The capacity is never below `k`, as the proof says it cannot be. The least widths of capacity 1, 2 and 3 on this cycle are the first three windows exactly:

```wl
Table[SelectFirst[Range[3, 100], K1seed[#] >= k &], {k, 1, 3}]
```

Further in, the nesting costs about 19 wheels per layer, while the schedule itself clears a layer in about 11 wheels: 51 layers at width 570. The proof promises 30 there. Each window waits for a factor beyond the whole of the previous one, while the schedule only needs a factor beyond the cut it actually found. The proof has no reason to be sharp, and its widths are not used for the ages. The theorem's age is the kit's, at the least width of capacity `k`.

## 4. The proof

1. **One window for each depth** (`uniform_factor`). Fix a depth `lo`, and suppose no width `b` works. Then for every `i` there is a failing band: an odd band of width at least `i`, on a cycle, with no complete factor beyond `lo` inside its first `i` wheels. Split the failing bands by their bit 0, keep a half with infinitely many, split that by bit 1, and so on (`limit_prefix`). The bits kept form one infinite word `x`, and every finite prefix of `x` is the prefix of infinitely many failing bands. Run `x` by the left-edge recurrence (`orbit`). Each prefix of the result agrees, at every tick, with the orbit of a failing band of the same prefix, so it has that band's period from tick 0. The result is therefore a pointed recurrent strip. `LInfinity` gives it a closed run at tick 0, beyond `lo`. A failing band that agrees with `x` far enough to contain that run, the symbol before it and its closing white has the same complete factor, and that is a contradiction. The argument never needs a period for the whole limit strip. Each prefix carries its own clock, and that is all `LInfinity` asks for.
2. **One width for `k` layers** (`uniform_schedule`). By induction on `k` there is a depth `u` such that, from any phase of any odd band on a cycle and with any available depth at least `u`, the schedule clears `k` layers. For `k + 1`, take the window `b` of step 1 for the depth `u`. With at least `b` wheels available, the schedule's first layer finds a complete factor at depth at least `u`, since `firstReset` searches from the deepest wheel down. So the cut it leaves is at least `u`, enough for the remaining `k` layers.
3. **The capacity** (`cap_of_unbounded_resets`). Take width `max k u + 1`. Every odd band that the search in `K1` finds on a cycle returns with a genuine positive period (`walk_sound`), so step 2 applies to every phase of it. The minimum in `K1` keeps the bound, and `K1 ≥ k`.
4. **Every `k`** (`every_k_of_unbounded_resets`). Compose with the kit's `conditional_every_k`.

## 5. The open hypothesis

`LInfinity` is not proved. What is known about it:
- **In Lean, carried in this file** (`one_of_three_unbounded`). On every pointed recurrent strip and from every tick, one fixed tick among any three consecutive ones has closed runs at arbitrarily large depths. That is weaker than `LInfinity`, which needs every tick.
- **The clocks.** On a pointed recurrent strip the least common period of each prefix is a power of two (`dyadic_prefix_clock`). Every clock is eventually lost (`escapes_clock`). It is first lost just after a wheel that is white at every tick, where the next wheel turns antiperiodic and the clock doubles (`first_clock_loss`). All three are in this file.
- **A sufficient lemma.** `LInfinity` follows from a statement about those doublings: a tick that the doubled stretch after a clock loss misses is caught in the stretch after the next white wheel. The implication is proved by hand and read independently in our record, and a Lean version of it is there too. The lemma's strict form has been checked by computation in two cases: every source of power-of-two period up to 32, and every source with five black or five white ticks at every power-of-two period. So does every first clock loss on every pointed recurrent strip, through clock 16. It is open in general.

The converse of the first headline is not claimed. It is the route through `CAP` that needs `LInfinity`, not `CAP` itself.

## 6. Prior art and credit

- **The kit.**
  - `Rule30EveryKStatement`, `Rule30EveryKCascade` and `Rule30EveryKInverse` state and prove the target from `CAP`. They are our earlier entry R30-20261119-ccc65f, in the kit from pull request 368. The cascade credits Troy Lowry's kit pull request 60.
  - The verifier's kit revision does not have these three modules. This file carries them as they stand at kit commit `3f32e1a`, with only the module-system lines removed.
  - The left-edge recurrence is in `Rule30AgedLeftDiagonals` (Lowry with OpenAI Codex), and the encoding behind the clocks in `Rule30LeftUnbounded` (AIOvernight, with OpenAI Codex and Claude).
- **Capacity values.** G.P.J.W. Quint and Gemini's R30-20261120-2a993b (kit pull request 371, open) has two results: the 16-phase collapse of `K1` through width 53,208, and `CAP`'s first 25 values with the target for `k ≤ 25`. Their R30-20261120-515c76 (in the kit's main since 20 November) has the period-multiple invariance of the schedule. Neither derives `CAP` for every `k`.
- **The method.** The compactness argument is the standard one, König's lemma on the tree of failing prefixes. The use here is the observation that limits of periodic bands are pointed recurrent strips, each prefix with its own clock.
- **Ours, earlier.** The three modules after the kit's are ours, with links to their source in our record:
  - [two returns along a strip](https://github.com/ghywel/rule30reset/blob/ab2c0fd0660e521010ac3f4dff74be941b141a99/research/m29/Rule30ThreePhaseReturn.lean);
  - [rooted white returns and clock losses](https://github.com/ghywel/rule30reset/blob/ab2c0fd0660e521010ac3f4dff74be941b141a99/research/m29/Rule30RootedWhiteReturns.lean);
  - [pointed recurrent strips](https://github.com/ghywel/rule30reset/blob/ab2c0fd0660e521010ac3f4dff74be941b141a99/research/m29/Rule30RecurrentStrip.lean).

  The compactness module is [here](https://github.com/ghywel/rule30reset/blob/ab2c0fd0660e521010ac3f4dff74be941b141a99/research/m29/Rule30ResetCompactness.lean). Each module has been proved and read independently in our record. None of them has been submitted before.
- **Novelty.** We read the portal's list of 386 entries and the kit's 15 open pull requests at 19:50 UTC on 20 November. Neither has an implication into `CAP`, or into the target for every `k`, from a property of infinite strips. The nearest entries are the three above.

## 7. What is not proved

- `LInfinity` is not proved, and so neither is `CAP`. Both theorems are conditional.
- The proof is not constructive. It gives no width for a given `k`, and no age beyond the kit's, which is explicit only once the least width of capacity `k` is known.
- The theorem is about the zero-boundary left half beside a fixed white wall. It says nothing about the centre column's period, and it does not decide `Q01`.

## The formal proof

The module is core Lean. It imports the kit's `Rule30ZeroBoundary`, `Rule30UniversalLeftSide`, `Rule30AgedLeftDiagonals` and `Rule30LeftUnbounded`, all present at the verifier's kit revision. Each part has its own namespace:
- the kit's three every-k modules (`Rule30EveryKStatement`, `Rule30EveryKCascade`, `Rule30EveryKInverse`);
- two returns along a strip (`Rule30ThreePhaseReturn`, `Rule30TwoPhaseRise`);
- rooted white returns (`Rule30RootedWhiteReturns`);
- pointed recurrent strips (`Rule30RecurrentStrip`);
- the compactness argument (`Rule30ResetCompactness`).

The two headlines are in `Rule30Submission`.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

```wl
rule30Submission = LeanImportString[(*Iconize["Lean source"]*)"import Ruliology.CellularAutomata.Rule30ZeroBoundary
import Ruliology.CellularAutomata.Rule30UniversalLeftSide
import Ruliology.CellularAutomata.Rule30AgedLeftDiagonals
import Ruliology.CellularAutomata.Rule30LeftUnbounded

/-!
# Unbounded closed runs on recurrent strips give reset capacity, and so every k

One file. First the kit's three every-k modules (`Rule30EveryKStatement`, `Rule30EveryKCascade`,
`Rule30EveryKInverse`), which the verifier's kit revision does not have, as they stand at kit commit 3f32e1a with
only the module-system lines removed. Then four modules of ours: two returns along a strip, rooted white returns,
pointed recurrent strips, and the compactness argument. The headlines are in `Rule30Submission` at the end.
-/

/-!
# Inverse ticks for every k: the statement

The kit numbers physical cells from the white wall, with cell 1 beside it.
In a band, bit 0 is the last black cell, and bit j is j cells towards the wall.
The band and the integer encoding of a physical row therefore read in opposite
directions. This module states the target and its hypothesis; `Rule30EveryKInverse` proves the implication.
-/


namespace Ruliology.CellularAutomata.Rule30EveryKStatement

open Rule30ZeroBoundary Rule30ZeroBoundary.IntegerForm

abbrev bandStep := Rule30UniversalLeftSide.stepK
abbrev bandAt := Rule30UniversalLeftSide.rowAt

/-- Odd residues are exactly the width-w words with a black outer edge. -/
def OddBand (w v : Nat) : Prop := v < 2 ^ w ∧ v.testBit 0 = true

/-- Closed black run of length 3m+1. Bit j is the unconstrained symbol
read immediately after the shallow zero to finish agreement of the pair. -/
def resetAt (v j m : Nat) : Bool :=
  !(v.testBit (j + 1)) && !(v.testBit (j + 3*m + 3)) &&
    (List.range (3*m + 1)).all (fun i => v.testBit (j + 2 + i))

/-- First complete factor, scanning from the deepest available bit towards
the edge. Its two zeros, black run and following symbol all lie in the band. -/
def firstReset (v available : Nat) : Option Nat :=
  (List.range available).reverse.find? fun j =>
    (List.range (available / 3 + 1)).any fun m =>
      decide (j + 3*m + 4 ≤ available) && resetAt v j m

/-- The reference at layer d is d ticks *earlier* on the same cycle. Agreement
from wheel j outwards leaves j bits (0 through j-1) after the edge retreats.
Width w supplies sufficient fuel since a complete factor strictly spends width. -/
def schedule (w v period : Nat) : Nat → Nat → Nat → Nat
  | 0, _, _ => 0
  | fuel + 1, d, available =>
    let phase := (period - d % period) % period
    match firstReset (bandAt w v phase) available with
    | none => 0
    | some j => 1 + schedule w v period fuel (d + 1) j

def phaseCapacity (w v period : Nat) : Nat := schedule w v period w 0 w

/-- Find the first positive return. At positive width there are 2^(w-1)
odd residues, so failure within that many steps excludes exactly transients. -/
def returnPeriod (w v : Nat) : Option Nat :=
  let rec walk : Nat → Nat → Nat → Option Nat
    | 0, _, _ => none
    | fuel + 1, current, elapsed =>
      let next := bandStep w current
      if next = v then some (elapsed + 1) else walk fuel next (elapsed + 1)
  walk (2 ^ (w - 1)) v 0

/-- Worst one-layer schedule across every cycle and every phase. Enumerating
all odd initial words includes each periodic phase separately. Width zero is
excluded from CAP. This finite specification favours clarity over runtime. -/
def K1 : Nat → Nat
  | 0 => 0
  | n + 1 =>
    (List.range (2 ^ n)).foldl (fun worst i =>
      let v := 2*i + 1
      match returnPeriod (n + 1) v with
      | none => worst
      | some period => min worst (phaseCapacity (n + 1) v period)) (n + 1)

def CAP : Prop := ∀ k : Nat, ∃ w : Nat, 0 < w ∧ k ≤ K1 w

/-- The target in the kit's physical-row convention, with arbitrary
predecessor V and equality only on positive cells. -/
def PhysicalEdge (k age : Nat) : Prop :=
  ∀ (L : Nat → Bool) (m t : Nat), 1 ≤ m → L m = true →
    (∀ i, m < i → L i = false) → age ≤ t →
    ∀ V : Nat → Bool, (∀ i, 1 ≤ i → zrow V k i = zrow L t i) →
      V (m + t - k) = true ∧ ∀ i, m + t - k < i → V i = false

/-- Definitionally the kit's `Rule30LateTwins.Top`, spelled out here
on the same bits. -/
def Top (Y m : Nat) : Prop :=
  Y.testBit m = true ∧ ∀ i, m < i → Y.testBit i = false

/-- Every predecessor has a finite representative: a natural number whose row agrees with it. -/
def FinitePredecessor (k age : Nat) : Prop :=
  ∀ (Y t : Nat), Y ≠ 0 → age ≤ t → ∀ L : Nat → Bool,
    (∀ i, 1 ≤ i → zrow L k i = rowOfNat (iter F t Y) i) →
      ∃ A : Nat, (∀ i, 1 ≤ i → rowOfNat A i = L i) ∧
        iter F k A = iter F t Y ∧ Top A (Y.log2 + t - k)

/-- Every wall history occurs. Histories are specified in forward time at cell 1. -/
def AllHistories (k age : Nat) : Prop :=
  ∀ (Y t : Nat), Y ≠ 0 → age ≤ t → ∀ bits : Fin k → Bool,
    ∃ A : Nat, iter F k A = iter F t Y ∧ Top A (Y.log2 + t - k) ∧
      ∀ i : Fin k, rowOfNat (iter F i.val A) 1 = bits i

def TargetAt (k age : Nat) : Prop :=
  PhysicalEdge k age ∧ FinitePredecessor k age ∧ AllHistories k age

def EveryK (age : Nat → Nat) : Prop := ∀ k, TargetAt k (age k)

/-- Read an integer row's outer band in wheel order. Only full bands of
nonzero rows are used in the convergence statement below. -/
def topBand (w Y : Nat) : Nat :=
  (List.range w).foldl (fun word j =>
    if j ≤ Y.log2 ∧ Y.testBit (Y.log2 - j) = true then word + 2^j else word) 0

def Settled (w age : Nat) : Prop :=
  ∀ (Y t : Nat), Y ≠ 0 → age ≤ t →
    let output := iter F t Y
    let v := topBand w output
    w ≤ output.log2 + 1 ∧ OddBand w v ∧ ∃ q : Nat, 0 < q ∧ bandAt w v q = v

/-- The sharper form: any established uniform settling age at a witness
width may be used. First reset starts with free registers at the deep end. -/
def CapacityAtSettlingAge : Prop :=
  ∀ (k w age : Nat), 0 < w → k ≤ K1 w → Settled w age → TargetAt k age

/-- After w-1 ticks every nonzero seed has a full band. A further 2^w
ticks suffice by a finite-state bound. No unique cycle is assumed. -/
def settlingBound (w : Nat) : Nat := w - 1 + 2^w

/-- The least positive witness at or below any supplied witness. The fallback
is the supplied witness itself. CAP provides the endpoint of the finite search. -/
noncomputable def widthFor (capacity : CAP) (k : Nat) : Nat :=
  let witness := Classical.choose (capacity k)
  ((List.range witness).find? (fun w => decide (0 < w ∧ k ≤ K1 w))).getD witness

/-- The conditional every-k statement. Its age depends only on k through the
least capacity witness. CAP remains the open mathematical hypothesis. -/
def ConditionalEveryK : Prop :=
  ∀ capacity : CAP, EveryK (fun k => settlingBound (widthFor capacity k))

end Ruliology.CellularAutomata.Rule30EveryKStatement

/-!
# Scheduled inverse layers at a finite Rule 30 edge

Troy Lowry's Rule30PrizeKit PR #60 gives the reset-word and scheduled-cascade
argument. Here the driver is the preceding phase of an odd edge cycle and the
cut is the one computed by Rule30EveryKStatement.firstReset.
-/


namespace Ruliology.CellularAutomata.Rule30EveryKCascade

open Rule30EveryKStatement Rule30ZeroBoundary Rule30UniversalLeftSide

abbrev Row := Nat → Bool
abbrev Pair := Bool × Bool

/-- Advance the inverse register one physical cell towards the exterior. -/
def advance (b : Bool) (s : Pair) : Pair := (s.2, xor b (s.2 || s.1))

def pair (P : Row) (x : Nat) : Pair := (P x, P (x+1))

private theorem black_cycle (s : Pair) :
    advance true (advance true (advance true (advance true s))) = advance true s := by
  obtain ⟨a,b⟩ := s
  cases a <;> cases b <;> rfl

private theorem black_run (r : Nat → Pair) (start m : Nat)
    (h : ∀ i, i < 3*m+1 → r (start+i+1) = advance true (r (start+i))) :
    r (start+(3*m+1)) = advance true (r start) := by
  induction m with
  | zero => simpa using h 0 (by decide)
  | succ m ih =>
    let n := 3*m+1
    have h1 := h n (by dsimp [n]; omega)
    have h2 := h (n+1) (by dsimp [n]; omega)
    have h3 := h (n+2) (by dsimp [n]; omega)
    have prev := ih (fun i hi => h i (by omega))
    rw [show start+(3*(m+1)+1) = start+(n+2)+1 by dsimp [n]; omega,
      h3, show start+(n+2) = start+(n+1)+1 by omega, h2,
      show start+(n+1) = start+n+1 by omega, h1, prev, black_cycle]

private theorem finish_reset (b : Bool) (s : Pair) :
    advance b (advance false (advance true (advance false s))) = (true, !b) := by
  obtain ⟨a,c⟩ := s
  cases a <;> cases c <;> cases b <;> rfl

/-- After reading 0, 3m+1 black cells, 0 and a free symbol, the pair is
independent of its entrance state. The free symbol is read at depth base+3m+4. -/
theorem reset_closes (P O : Row) (base m : Nat)
    (h : ∀ n, base ≤ n → pair P (n+1) = advance (O (n+1)) (pair P n))
    (a : O (base+1) = false)
    (bs : ∀ i, i < 3*m+1 → O (base+2+i) = true)
    (c : O (base+3*m+3) = false) :
    pair P (base+3*m+4) = (true, !(O (base+3*m+4))) := by
  have run := black_run (pair P) (base+1) m (by
    intro i hi
    rw [h _ (by omega), show base+1+i+1 = base+2+i by omega, bs i hi])
  have last := h (base+3*m+3) (by omega)
  rw [last, h (base+3*m+2) (by omega), c,
    show base+3*m+2 = base+1+(3*m+1) by omega, run, h base (by omega), a, finish_reset]

/-- A word placed with its low bit at physical depth e, white outside. -/
def reference (e v x : Nat) : Bool := if x ≤ e then v.testBit (e-x) else false

/-- The cell rule inverted at physical depth n+1. -/
def Drives (O P : Row) (base : Nat) : Prop :=
  ∀ n, base ≤ n → pair P (n+1) = advance (O (n+1)) (pair P n)

theorem physical_drives (P : Row) (t : Nat) :
    Drives (zrow P (t+1)) (zrow P t) 0 := by
  intro n _
  exact Prod.ext rfl (zrow_inv P t n)

/-- The previous phase is a valid reference parent on the available band and
the white exterior. This does not require that the actual seed's earlier band
was already recurrent. -/
theorem reference_drives (w u e base : Nat) (he : 0 < e) (hw : e ≤ base+w) :
    Drives (reference e (bandStep w u)) (reference (e-1) u) base := by
  intro n hn
  refine Prod.ext rfl ?_
  change reference (e-1) u (n+2) = xor (reference e (bandStep w u) (n+1))
    (reference (e-1) u (n+1) || reference (e-1) u n)
  by_cases h0 : e ≤ n
  · simp [reference, show ¬ n+1 ≤ e by omega, show ¬ n+2 ≤ e-1 by omega,
      show ¬ n+1 ≤ e-1 by omega, show ¬ n ≤ e-1 by omega]
  by_cases h1 : e = n+1
  · subst e
    simp [reference, show ¬ n+2 ≤ n by omega, show ¬ n+1 ≤ n by omega, stepK_bit_zero (by omega : 0 < w)]
  by_cases h2 : e = n+2
  · subst e
    simp [reference, stepK_bit_one (by omega : 1 < w)]
  let j := e-(n+3)
  have hj : j+2 < w := by dsimp [j]; omega
  simp only [reference, ite_eq_left (show n+2 ≤ e-1 by omega), ite_eq_left (show n+1 ≤ e by omega),
    ite_eq_left (show n+1 ≤ e-1 by omega), ite_eq_left (show n ≤ e-1 by omega)]
  rw [show e-1-(n+2) = j by dsimp [j]; omega, show e-(n+1) = j+2 by dsimp [j]; omega,
    show e-1-(n+1) = j+1 by dsimp [j]; omega, show e-1-n = j+2 by dsimp [j]; omega,
    stepK_bit_step hj]
  cases u.testBit j <;> cases (u.testBit (j+1) || u.testBit (j+2)) <;> rfl


/-- The actual edge is black even if no bits remain available to the next
scan. Agreement covers every exterior cell, including an infinite tail. -/
def Matches (P : Row) (e v available : Nat) : Prop :=
  P e = true ∧ ∀ x, e < x+available → P x = reference e v x

theorem firstReset_spec {v available j : Nat} (h : firstReset v available = some j) :
    ∃ m, j+3*m+4 ≤ available ∧ resetAt v j m = true := by
  unfold firstReset at h
  have hh := List.find?_some h
  obtain ⟨m, _, hm⟩ := List.any_eq_true.mp hh
  exact ⟨m, of_decide_eq_true (Bool.and_eq_true_iff.mp hm).1, (Bool.and_eq_true_iff.mp hm).2⟩

/-- Common output from base+1 onwards propagates agreement of an inverse
pair at cut to the whole exterior. -/
private theorem agree_after {O P Q : Row} {base cut : Nat}
    (hp : Drives O P base) (hq : Drives O Q base) (hc : base ≤ cut)
    (eq : pair P cut = pair Q cut) : ∀ x, cut ≤ x → P x = Q x := by
  intro x hx
  obtain ⟨i,rfl⟩ := Nat.exists_eq_add_of_le hx
  suffices z : pair P (cut+i) = pair Q (cut+i) by exact congrArg Prod.fst z
  clear hx
  induction i with
  | zero => exact eq
  | succ i ih => rw [← Nat.add_assoc, hp _ (by omega), hq _ (by omega), ih]

/-- One successful cut of `firstReset`'s actual search fixes the next band and the
previous physical edge, including the cut j=0. -/
theorem scheduled_layer {P O : Row} {w u e available j : Nat}
    (full : available ≤ e) (width : available ≤ w)
    (drive : Drives O P 0)
    (matchOut : Matches O e (bandStep w u) available)
    (cut : firstReset (bandStep w u) available = some j) :
    Matches P (e-1) u j := by
  obtain ⟨m, bound, reset⟩ := firstReset_spec cut
  let v := bandStep w u
  let b := e-(j+3*m+4)
  have eb : e = b+j+3*m+4 := by dsimp [b]; omega
  let D := reference e v
  let Q := reference (e-1) u
  have dp : Drives D P b := by
    intro n hn
    dsimp [D, v]
    rw [← matchOut.2 (n+1) (by omega)]
    exact drive n (Nat.zero_le _)
  have dq : Drives D Q b := reference_drives w u e b (by omega) (by omega)
  obtain ⟨zeros, ones⟩ := Bool.and_eq_true_iff.mp reset
  obtain ⟨z1,z2⟩ := Bool.and_eq_true_iff.mp zeros
  have low : v.testBit (j+1) = false := by simpa using z1
  have high : v.testBit (j+3*m+3) = false := by simpa using z2
  have deep : D (b+1) = false := by
    simpa [D, reference, show b+1 ≤ e by omega, show e-(b+1) = j+3*m+3 by omega] using high
  have shallow : D (b+3*m+3) = false := by
    simpa [D, reference, show b+3*m+3 ≤ e by omega, show e-(b+3*m+3) = j+1 by omega] using low
  have run (i) (hi : i < 3*m+1) : D (b+2+i) = true := by
    have h := List.all_eq_true.mp ones (3*m-i) (List.mem_range.mpr (by omega))
    simpa [D, reference, show b+2+i ≤ e by omega,
      show e-(b+2+i) = j+2+(3*m-i) by omega] using h
  have same := (reset_closes P D b m dp deep run shallow).trans
    (reset_closes Q D b m dq deep run shallow).symm
  have tail := agree_after dp dq (by omega) same
  have exterior (x) (hx : e ≤ x) : P x = false := by
    rw [tail x (by omega)]
    simp [Q, reference, show ¬ x ≤ e-1 by omega]
  constructor
  · have h := congrArg Prod.snd (drive (e-1) (Nat.zero_le _))
    have he : e-1+1 = e := by omega
    change P (e-1+1+1) = xor (O (e-1+1)) (P (e-1+1) || P (e-1)) at h
    rw [he, matchOut.1, exterior e (by omega), exterior (e+1) (by omega)] at h
    cases hbit : P (e-1) <;> simp [hbit] at h ⊢
  · intro x hx
    exact tail x (by omega)


/-- Phase of the reference strip d inverse ticks from v. -/
def earlier (w v q d : Nat) := bandAt w v ((q - d%q)%q)

theorem earlier_step {w v q : Nat} (hq : 0 < q) (cycle : bandAt w v q = v) (d : Nat) :
    bandStep w (earlier w v q (d+1)) = earlier w v q d := by
  let r := d%q
  have hr : r < q := Nat.mod_lt _ hq
  have succmod : (d+1)%q = (r+1)%q := Nat.mod_add_mod .. |>.symm
  unfold earlier
  rw [succmod]
  change bandStep w (bandAt w v ((q-(r+1)%q)%q)) = bandAt w v ((q-r)%q)
  by_cases last : r+1 = q
  · rw [last]
    simp only [Nat.mod_self, Nat.sub_zero, rowAt]
    rw [show q-r = 1 by omega]
    by_cases one : q = 1
    · rw [one] at cycle ⊢
      simpa [rowAt] using cycle
    · rw [Nat.mod_eq_of_lt (by omega : 1 < q)]
      rfl
  · rw [Nat.mod_eq_of_lt (by omega : r+1 < q), Nat.mod_eq_of_lt (by omega : q-(r+1) < q)]
    change bandAt w v (q-(r+1)+1) = _
    rw [show q-(r+1)+1 = q-r by omega]
    by_cases zero : r = 0
    · simpa [zero, rowAt] using cycle
    · rw [Nat.mod_eq_of_lt (by omega : q-r < q)]

/-- From every physical k-tick preimage the computed schedule fixes the
edge at depth e-k and all cells beyond it. No support or trace condition is
imposed on the entrance row. -/
theorem scheduled_edge {w v q : Nat} (hq : 0 < q) (cycle : bandAt w v q = v)
    (fuel d a k e : Nat) (P : Row) (width : a ≤ w) (full : a ≤ e)
    (matched : Matches (zrow P k) e (earlier w v q d) a)
    (closed : k ≤ schedule w v q fuel d a) :
    zrow P 0 (e-k) = true ∧ ∀ x, e-k < x → zrow P 0 x = false := by
  induction fuel generalizing d a k e with
  | zero =>
    have hk : k = 0 := by simpa [schedule] using closed
    subst k
    exact ⟨matched.1, fun x hx => (matched.2 x (by omega)).trans
      (by simp [reference, show ¬ x ≤ e by omega])⟩
  | succ fuel ih =>
    cases k with
    | zero => exact ⟨matched.1, fun x hx => (matched.2 x (by omega)).trans
        (by simp [reference, show ¬ x ≤ e by omega])⟩
    | succ k =>
      simp only [schedule] at closed
      cases h : firstReset (earlier w v q d) a with
      | none =>
        unfold earlier at h
        simp only [h] at closed
        omega
      | some j =>
        have fj := h
        unfold earlier at h
        simp only [h] at closed
        obtain ⟨m, bound, _⟩ := firstReset_spec fj
        rw [← earlier_step hq cycle d] at fj matched
        have next := scheduled_layer full width (physical_drives P k) matched fj
        have result := ih (d+1) j k (e-1) (by omega) (by omega) next (by omega)
        simpa [show e-(k+1) = e-1-k by omega] using result

end Ruliology.CellularAutomata.Rule30EveryKCascade

/-!
# The conditional inverse-tick theorem at a uniform age

Attach the minimum over edge cycles to the physical cascade and to
finite rows at a fixed white wall. All widths and tick counts are natural numbers.
-/


namespace Ruliology.CellularAutomata.Rule30EveryKInverse

open Rule30EveryKStatement Rule30EveryKCascade Rule30ZeroBoundary
open Rule30ZeroBoundary.IntegerForm Rule30UniversalLeftSide

private theorem top_log {Y : Nat} (h : Y ≠ 0) : Top Y Y.log2 :=
  ⟨Nat.testBit_log2 h, fun i hi => Nat.testBit_lt_two_pow
    (Nat.lt_of_lt_of_le Nat.lt_log2_self (Nat.pow_le_pow_right (by omega) hi))⟩

private theorem log_of_top {Y i : Nat} (h : Top Y i) : Y.log2 = i := by
  have nz : Y ≠ 0 := by intro e; simpa [e] using h.1
  have t := top_log nz
  rcases Nat.lt_trichotomy Y.log2 i with hl | he | hg
  · exact absurd h.1 (by rw [t.2 i hl]; decide)
  · exact he
  · exact absurd t.1 (by rw [h.2 _ hg]; decide)

private theorem forward_top {Y m : Nat} (h : Top Y m) : Top (F Y) (m+1) := by
  refine ⟨testBit_F_succ_of_top h.1 h.2, fun i hi => ?_⟩
  obtain ⟨j,rfl⟩ : ∃ j, i = j+1 := ⟨i-1, by omega⟩
  rw [testBit_F_succ, h.2 (j+2) (by omega), h.2 (j+1) (by omega), h.2 j (by omega)]
  rfl

private theorem orbit_top {Y : Nat} (h : Y ≠ 0) (t : Nat) :
    Top (iter F t Y) (Y.log2+t) := by
  induction t with
  | zero => exact top_log h
  | succ t ih => exact forward_top ih

private theorem band_succ (w Y : Nat) :
    topBand (w+1) Y = if w ≤ Y.log2 ∧ Y.testBit (Y.log2-w) = true
      then topBand w Y + 2^w else topBand w Y := by
  simp [topBand, List.range_succ, List.foldl_append]

theorem band_lt (w Y : Nat) : topBand w Y < 2^w := by
  induction w with
  | zero => simp [topBand]
  | succ w ih => rw [band_succ, Nat.pow_succ]; split <;> omega

theorem band_bit (w Y i : Nat) :
    (topBand w Y).testBit i = (decide (i < w ∧ i ≤ Y.log2) && Y.testBit (Y.log2-i)) := by
  induction w with
  | zero => simp [topBand]
  | succ w ih =>
    rw [band_succ]
    split <;> rename_i h
    · rw [← Nat.or_two_pow_eq_add_of_lt (band_lt w Y), Nat.testBit_or, Nat.testBit_two_pow, ih]
      by_cases eq : i = w
      · subst i; simp [h]
      · simp [Ne.symm eq, show (i < w+1) = (i < w) by apply propext; omega]
    · by_cases eq : i = w
      · subst i; simp [ih]; grind
      · simpa [show (i < w+1) = (i < w) by apply propext; omega] using ih

private theorem band_evolves {Y w : Nat} (nz : Y ≠ 0) (full : w ≤ Y.log2+1) :
    topBand w (F Y) = bandStep w (topBand w Y) := by
  let m := Y.log2
  have top := top_log nz
  have log := log_of_top (forward_top top)
  apply Nat.eq_of_testBit_eq
  intro i
  by_cases inside : i < w
  · have fit : i ≤ m := by omega
    rw [band_bit, log]
    simp only [inside, show i ≤ Y.log2+1 by omega, and_self, decide_true, Bool.true_and]
    cases i with
    | zero =>
      rw [stepK_bit_zero (by omega), band_bit]
      simp [inside, top.1, (forward_top top).1]
    | succ i =>
      cases i with
      | zero =>
        rw [stepK_bit_one (by omega), band_bit, band_bit]
        have hm : 1 ≤ m := by omega
        let z := m-1
        have hz : m = z+1 := by dsimp [z]; omega
        change (F Y).testBit (m+1-1) = _
        rw [show m+1-1 = z+1 by omega, testBit_F_succ,
          top.2 (z+2) (by omega), show z+1 = Y.log2 by omega]
        simp [inside, show 0 < w by omega, show 1 ≤ Y.log2 by omega, top.1]
      | succ i =>
        rw [stepK_bit_step inside, band_bit, band_bit, band_bit]
        let z := m-(i+2)
        have idx : m+1-(i+2) = z+1 := by dsimp [z]; omega
        change (F Y).testBit (m+1-(i+2)) = _
        rw [idx, testBit_F_succ]
        simp [inside, show i < w by omega, show i+1 < w by omega, show i ≤ Y.log2 by omega,
          show i+1 ≤ Y.log2 by omega, show i+2 ≤ Y.log2 by omega,
          show z+2 = Y.log2-i by dsimp [z]; omega,
          show z+1 = Y.log2-(i+1) by dsimp [z]; omega, z, m]
  · have h1 := Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (band_lt w (F Y))
        (Nat.pow_le_pow_right (by decide : 0 < 2) (by omega : w ≤ i)))
    have h2 : bandStep w (topBand w Y) < 2^w := Nat.mod_lt _ (Nat.two_pow_pos _)
    rw [h1, Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le h2 (Nat.pow_le_pow_right (by decide) (by omega : w ≤ i)))]


private theorem collision (N : Nat) (a : Nat → Nat) (h : ∀ t, a t < N) :
    ∃ i j, i < j ∧ j ≤ N ∧ a i = a j := by
  apply Classical.byContradiction
  intro hn
  have nd := Rule30Jen.nodup_map_of_inj a (List.nodup_range (n := N+1)) (by
    intro i hi j hj e
    simp only [List.mem_range] at hi hj
    rcases Nat.lt_trichotomy i j with lt | eq | gt
    · exact (hn ⟨i,j,lt,by omega,e⟩).elim
    · exact eq
    · exact (hn ⟨j,i,gt,by omega,e.symm⟩).elim)
  have size := Rule30Jen.length_le_of_subset (l₂ := List.range N) nd (by
    intro x hx
    obtain ⟨t,_,rfl⟩ := List.mem_map.mp hx
    exact List.mem_range.mpr (h t))
  simp at size
  omega

private theorem orbit_add (w v i n : Nat) :
    bandAt w v (i+n) = bandAt w (bandAt w v i) n := by
  induction n with
  | zero => rfl
  | succ n ih => change bandStep w (bandAt w v (i+n)) = bandStep w (bandAt w (bandAt w v i) n); rw [ih]

private theorem push_eq {w v i j : Nat} (eq : bandAt w v i = bandAt w v j) (n : Nat) :
    bandAt w v (i+n) = bandAt w v (j+n) := by rw [orbit_add, orbit_add w v j, eq]

private theorem band_at_odd {n v : Nat} (odd : OddBand (n+1) v) (t : Nat) :
    OddBand (n+1) (bandAt (n+1) v t) := by
  induction t with
  | zero => exact odd
  | succ t ih => exact ⟨Nat.mod_lt _ (Nat.two_pow_pos _), (stepK_bit_zero (by omega) _).trans ih.2⟩

/-- A periodic odd word returns within the exact fuel used by `returnPeriod`'s search.
Dividing an odd word by two codes the 2^n words at width n+1 injectively. -/
private theorem short_return {n v q : Nat} (odd : OddBand (n+1) v) (hq : 0 < q)
    (cycle : bandAt (n+1) v q = v) :
    ∃ p, 0 < p ∧ p ≤ 2^n ∧ bandAt (n+1) v p = v := by
  let a := bandAt (n+1) v
  obtain ⟨i,j,lt,bound,eq⟩ := collision (2^n) (fun t => a t / 2) (by
    intro t
    have h := (band_at_odd odd t).1
    rw [Nat.pow_succ] at h
    dsimp [a]; omega)
  have parity (t) : a t % 2 = 1 := by simpa [a, Nat.testBit_zero] using (band_at_odd odd t).2
  have same : a i = a j := by have := parity i; have := parity j; omega
  let b := (i+1)*q
  have le : i ≤ b := Nat.le_trans (by omega : i ≤ i+1) (Nat.le_mul_of_pos_right _ hq)
  have translated := push_eq same (b-i)
  have ix : i+(b-i) = 0+(i+1)*q := by dsimp [b]; omega
  have jx : j+(b-i) = (j-i)+(i+1)*q := by dsimp [b] at *; omega
  rw [ix, jx] at translated
  unfold bandAt at translated
  rw [rowAt_add_mul cycle, rowAt_add_mul cycle] at translated
  exact ⟨j-i,by omega,by omega,translated.symm⟩

private theorem walk_finds (w v fuel elapsed : Nat)
    (h : ∃ p, elapsed < p ∧ p ≤ elapsed+fuel ∧ bandAt w v p = v) :
    ∃ q, returnPeriod.walk w v fuel (bandAt w v elapsed) elapsed = some q ∧
      0 < q ∧ bandAt w v q = v := by
  induction fuel generalizing elapsed with
  | zero => obtain ⟨_,_,_,_⟩ := h; omega
  | succ fuel ih =>
    rw [returnPeriod.walk]
    split <;> rename_i eq
    · exact ⟨elapsed+1,rfl,by omega,eq⟩
    · apply ih (elapsed+1)
      obtain ⟨p,lo,hi,hp⟩ := h
      have ne : p ≠ elapsed+1 := by rintro rfl; exact eq hp
      exact ⟨p,by omega,by omega,hp⟩


private theorem fold_bound (step : Nat → Nat → Nat) (lower : ∀ b i, step b i ≤ b)
    (xs : List Nat) (b : Nat) : xs.foldl step b ≤ b := by
  induction xs generalizing b with
  | nil => exact Nat.le_refl _
  | cons a xs ih => exact Nat.le_trans (ih _) (lower b a)

private theorem fold_hit (step : Nat → Nat → Nat) (lower : ∀ b i, step b i ≤ b)
    {i limit : Nat} (hit : ∀ a, step a i ≤ limit) (xs : List Nat) (b : Nat) (mem : i ∈ xs) :
    xs.foldl step b ≤ limit := by
  induction xs generalizing b with
  | nil => simp at mem
  | cons a xs ih =>
    rcases List.mem_cons.mp mem with rfl | hm
    · exact Nat.le_trans (fold_bound step lower xs _) (hit b)
    · exact ih _ hm

private def entry (w b i : Nat) := match returnPeriod w (2*i+1) with
  | none => b
  | some p => min b (phaseCapacity w (2*i+1) p)

private theorem entry_le (w b i : Nat) : entry w b i ≤ b := by
  unfold entry; split
  · exact Nat.le_refl _
  · exact Nat.min_le_left ..

theorem capacity_on_cycle {w v : Nat} (hw : 0 < w) (odd : OddBand w v)
    (cycle : ∃ q, 0 < q ∧ bandAt w v q = v) :
    ∃ q, 0 < q ∧ bandAt w v q = v ∧ K1 w ≤ phaseCapacity w v q := by
  obtain ⟨n,rfl⟩ : ∃ n, w = n+1 := ⟨w-1,by omega⟩
  obtain ⟨q,hq,period⟩ := cycle
  obtain ⟨p,hp,bound,ret⟩ := short_return odd hq period
  obtain ⟨q',got,pos,period'⟩ := walk_finds (n+1) v (2^n) 0 ⟨p,hp,by omega,ret⟩
  have found : returnPeriod (n+1) v = some q' := got
  have lo := odd.1
  rw [Nat.pow_succ] at lo
  have parity : v%2 = 1 := by simpa [Nat.testBit_zero] using odd.2
  have eq : 2*(v/2)+1 = v := by omega
  refine ⟨q',pos,period',fold_hit (entry (n+1)) (entry_le _) (i := v/2) ?_ _ _ ?_⟩
  · intro a; simp only [entry,eq,found]; exact Nat.min_le_right ..
  · apply List.mem_range.mpr; omega

/-- A full physical band evolves autonomously from age w-1. Finite-state
pigeonhole gives the seed-independent age in the statement. -/
theorem uniform_settling {w : Nat} (hw : 0 < w) : Settled w (settlingBound w) := by
  intro Y t nz aged
  let s := w-1
  let a (i : Nat) := topBand w (iter F (s+i) Y)
  have log (i : Nat) := log_of_top (orbit_top nz i)
  have positive (i : Nat) : iter F i Y ≠ 0 := by
    intro z; simpa [z] using (orbit_top nz i).1
  have step (i : Nat) : a (i+1) = bandStep w (a i) := by
    dsimp only [a]
    rw [← Nat.add_assoc, iter]
    exact band_evolves (w := w) (positive (s+i)) (by rw [log]; dsimp [s]; omega)
  have advanceOrbit (i n : Nat) : bandAt w (a i) n = a (i+n) := by
    induction n with
    | zero => rfl
    | succ n ih => exact (congrArg (bandStep w) ih).trans (step (i+n)).symm
  obtain ⟨i,j,lt,bound,eq⟩ := collision (2^w) a fun _ => band_lt _ _
  have st : s+2^w ≤ t := aged
  let l := t-s
  have li : i ≤ l := by dsimp [l]; omega
  have cyc := congrArg (fun x => bandAt w x (l-i)) eq
  change bandAt w (a i) (l-i) = bandAt w (a j) (l-i) at cyc
  rw [advanceOrbit, advanceOrbit, show i+(l-i) = l by omega,
    show j+(l-i) = l+(j-i) by omega] at cyc
  have tl : s+l = t := by dsimp [l]; omega
  have per : bandAt w (a l) (j-i) = a l := (advanceOrbit l _).trans cyc.symm
  dsimp only [a] at per
  rw [tl] at per
  refine ⟨by rw [log]; dsimp [s] at st; omega, ⟨band_lt _ _, ?_⟩, j-i, by omega, per⟩
  rw [band_bit]; simp [hw, Nat.testBit_log2 (positive t)]


private theorem matches_band {P : Row} {t Y w : Nat} (nz : Y ≠ 0) (full : w ≤ Y.log2+1)
    (hpre : ∀ x, 1 ≤ x → zrow P t x = rowOfNat Y x) :
    Matches (zrow P t) (Y.log2+1) (topBand w Y) w := by
  constructor
  · simpa only [hpre _ (by omega : 1 ≤ Y.log2+1), rowOfNat] using (top_log nz).1
  · intro x hx
    obtain ⟨i,rfl⟩ : ∃ i, x = i+1 := ⟨x-1,by omega⟩
    rw [hpre _ (by omega)]
    change Y.testBit i = reference (Y.log2+1) (topBand w Y) (i+1)
    by_cases hi : i ≤ Y.log2
    · have idx : Y.log2+1-(i+1) = Y.log2-i := by omega
      simp [reference,hi,band_bit,idx,show Y.log2-i < w by omega,
        show Y.log2-(Y.log2-i) = i by omega]
    · rw [(top_log nz).2 i (by omega)]
      simp [reference,hi]

private theorem integer_edge {k w age Y t : Nat} {P : Row} (hw : 0 < w) (cap : k ≤ K1 w)
    (settled : Settled w age) (nz : Y ≠ 0) (aged : age ≤ t)
    (pre : ∀ x, 1 ≤ x → zrow P k x = rowOfNat (iter F t Y) x) :
    0 < Y.log2+t+1-k ∧ P (Y.log2+t+1-k) = true ∧ ∀ x, Y.log2+t+1-k < x → P x = false := by
  let Z := iter F t Y
  have top := orbit_top nz t
  have zn : Z ≠ 0 := by intro h; have z : Z.testBit (Y.log2+t) = true := top.1; simp [h] at z
  obtain ⟨full,odd,cycle⟩ := settled Y t nz aged
  obtain ⟨q,pos,ret,bound⟩ := capacity_on_cycle hw odd cycle
  have ma := matches_band zn full pre
  have ed := scheduled_edge pos ret w 0 w k (Z.log2+1) P (Nat.le_refl _) full
    (by simpa [earlier, rowAt] using ma) (Nat.le_trans cap bound)
  have log : Z.log2 = Y.log2+t := log_of_top top
  rw [log] at ed
  have posEdge : 1 ≤ Y.log2+t+1-k := by
    apply Classical.byContradiction
    intro h
    have z : Y.log2+t+1-k = 0 := by omega
    have bad := ed.1
    rw [z,zrow_wall] at bad
    contradiction
  exact ⟨posEdge,(zrow_zero_of_pos P posEdge).symm.trans ed.1, fun x hx =>
    (zrow_zero_of_pos P (by omega : 1 ≤ x)).symm.trans (ed.2 x hx)⟩

private theorem physical_clause {k w age : Nat} (hw : 0 < w) (cap : k ≤ K1 w)
    (settled : Settled w age) : PhysicalEdge k age := by
  intro L m t hm edge finite aged P pre
  let Y := natOfRow L m
  have top : Top Y (m-1) := by
    constructor
    · simpa [Y,testBit_natOfRow,show m-1 < m by omega,show m-1+1=m by omega] using edge
    · intro i hi; simp [Y,testBit_natOfRow,show ¬ i<m by omega]
  have nz : Y ≠ 0 := by intro z; simpa [z] using top.1
  have log := log_of_top top
  have rep := rowOfNat_natOfRow finite
  have ed := integer_edge hw cap settled nz aged (P := P) (fun x hx =>
    (pre x hx).trans ((zrow_congr (fun j hj => (rep j hj).symm) t x).trans (zrow_rowOfNat Y t x)))
  simpa only [log,show m-1+t+1 = m+t by omega] using ed.2

private theorem finite_clause {k w age : Nat} (hw : 0 < w) (cap : k ≤ K1 w)
    (settled : Settled w age) : FinitePredecessor k age := by
  intro Y t nz aged L pre
  obtain ⟨positive,edge,tail⟩ := integer_edge hw cap settled nz aged pre
  let e := Y.log2+t+1-k
  let A := natOfRow L e
  have rep : ∀ x, 1 ≤ x → rowOfNat A x = L x := rowOfNat_natOfRow tail
  have image : iter F k A = iter F t Y := by
    apply Nat.eq_of_testBit_eq
    intro i
    exact (zrow_rowOfNat A k (i+1)).symm.trans ((zrow_congr rep k _).trans (pre _ (by omega)))
  refine ⟨A,rep,image,?_,?_⟩
  · have ha := rep e positive
    obtain ⟨i,hi⟩ : ∃ i, e = i+1 := ⟨e-1,by omega⟩
    rw [hi] at ha
    change A.testBit i = L (i+1) at ha
    have eq : Y.log2+t-k = i := by dsimp [e] at hi; omega
    rw [eq, ha, ← hi]; exact edge
  · intro i hi
    have ht : e < i+1 := by dsimp [e]; omega
    exact (rep (i+1) (by omega)).trans (tail _ ht)

/-- Build a physical history with prescribed cell-1 bits in forward order,
allowing arbitrary support until the physical edge theorem is applied. -/
private theorem history (k : Nat) (E : Row) (bits : Fin k → Bool) :
    ∃ L : Row, (∀ x, 1 ≤ x → zrow L k x = E x) ∧
      ∀ i : Fin k, zrow L i.val 1 = bits i := by
  induction k with
  | zero => exact ⟨E,fun _ => zrow_zero_of_pos E,fun i => Fin.elim0 i⟩
  | succ k ih =>
    obtain ⟨P,endP,wall⟩ := ih (fun i => bits i.succ)
    let L := back (bits 0) P
    have shift (i x : Nat) : zrow L (i+1) x = zrow P i x := by
      rw [Nat.add_comm i 1,zrow_shift]
      exact zrow_congr (zrow_back (bits 0) P) i x
    refine ⟨L,fun x hx => (shift k x).trans (endP x hx),?_⟩
    intro i
    refine Fin.cases ?_ (fun j => ?_) i
    · rfl
    · exact (shift j.val 1).trans (wall j)

theorem capacity_at_settling_age : CapacityAtSettlingAge := by
  intro k w age hw cap settled
  have finite := finite_clause hw cap settled
  refine ⟨physical_clause hw cap settled,finite,?_⟩
  intro Y t nz aged bits
  obtain ⟨L,pre,trace⟩ := history k (rowOfNat (iter F t Y)) bits
  obtain ⟨A,rep,image,top⟩ := finite Y t nz aged L pre
  exact ⟨A,image,top,fun i => (zrow_rowOfNat A i.val 1).symm.trans
    ((zrow_congr rep i.val 1).trans (trace i))⟩

theorem conditional_every_k : ConditionalEveryK := by
  intro capacity k
  have spec : 0 < widthFor capacity k ∧ k ≤ K1 (widthFor capacity k) := by
    unfold widthFor
    dsimp only
    cases h : (List.range (capacity k).choose).find? (fun w => decide (0 < w ∧ k ≤ K1 w)) with
    | none => exact (capacity k).choose_spec
    | some w =>
      have found := List.find?_some h
      exact of_decide_eq_true found
  exact capacity_at_settling_age k _ _ spec.1 spec.2 (uniform_settling spec.1)

end Ruliology.CellularAutomata.Rule30EveryKInverse

/-! Three temporal bits of two adjacent wheels, followed by two bit masks
recording open runs of lengths one and two modulo three at the three ticks.
Bit zero is the earliest tick. -/
namespace Rule30ThreePhaseReturn
abbrev C := BitVec 3
structure State where
  prev : C
  cur : C
  one : C
  two : C
  deriving DecidableEq, Repr

def start (x : C) : State := ⟨x,7,~~~x,x⟩

def step (z : State) (c : C) : Option State :=
  if ((c >>> 1) &&& 3) != ((z.prev ^^^ (z.cur ||| c)) &&& 3) then none
  else if (z.one &&& ~~~c) != 0 then none
  else some ⟨z.cur,c,c &&& ~~~(z.one ||| z.two),c &&& z.one⟩

def scan (z : State) : List C → Option State
  | [] => some z
  | c::cs => (step z c).bind (fun w => scan w cs)

private def states : List State := [
  ⟨0,2,2,0⟩,
  ⟨0,5,5,0⟩,
  ⟨0,7,7,0⟩,
  ⟨1,4,4,0⟩,
  ⟨1,5,5,0⟩,
  ⟨1,7,6,1⟩,
  ⟨2,7,5,2⟩,
  ⟨3,0,0,0⟩,
  ⟨3,1,0,0⟩,
  ⟨3,7,4,3⟩,
  ⟨4,6,2,4⟩,
  ⟨4,7,3,4⟩,
  ⟨5,7,2,5⟩,
  ⟨6,7,1,2⟩,
  ⟨6,7,1,6⟩,
  ⟨7,0,0,0⟩,
  ⟨7,1,0,0⟩,
  ⟨7,3,0,1⟩,
  ⟨7,7,0,3⟩,
  ⟨7,7,0,7⟩]

private theorem starts : ∀ x : C, start x ∈ states := by decide +kernel

private theorem stable : ∀ z ∈ states, ∀ c : C,
    (step z c).all (fun w => decide (w ∈ states)) = true := by
  intro z hz
  simp only [states,List.mem_cons,List.not_mem_nil,or_false] at hz
  rcases hz with rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl <;> decide +kernel

private theorem zero_trap : ∀ z ∈ states, ∀ a b c : C, scan z [0,a,b,c] = none := by
  intro z hz
  simp only [states,List.mem_cons,List.not_mem_nil,or_false] at hz
  rcases hz with rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl <;> decide +kernel

private theorem trap_after (xs : List C) (z : State) (hz : z ∈ states) (a b c : C) :
    scan z (xs ++ [0,a,b,c]) = none := by
  induction xs generalizing z with
  | nil => exact zero_trap z hz a b c
  | cons x xs ih =>
    simp only [List.cons_append,scan]
    cases he : step z x with
    | none => rfl
    | some w =>
      have h := stable z hz x
      simp [he] at h
      exact ih w h

/-- No reset-free recurrence path in three simultaneous phases from the first
white/black anchor can pass a second white column and three more wheels. -/
theorem three_phase_return (x : C) (between : List C) (a b c : C) :
    scan (start x) (between ++ [0,a,b,c]) = none :=
  trap_after between _ (starts x) a b c

end Rule30ThreePhaseReturn

namespace Rule30TwoPhaseRise
abbrev C := BitVec 2
structure State where
  prev : C
  cur : C
  one : C
  two : C
  deriving DecidableEq, Repr

def start (x : C) : State := ⟨x,3,~~~x,x⟩

def step (z : State) (c : C) : Option State :=
  if ((c >>> 1) &&& 1) != ((z.prev ^^^ (z.cur ||| c)) &&& 1) then none
  else if (z.one &&& ~~~c) != 0 then none
  else some ⟨z.cur,c,c &&& ~~~(z.one ||| z.two),c &&& z.one⟩

def scan (z : State) : List C → Option State
  | [] => some z
  | c::cs => (step z c).bind (fun w => scan w cs)

private def states : List State := [
  ⟨0,1,1,0⟩,
  ⟨0,2,2,0⟩,
  ⟨0,3,3,0⟩,
  ⟨1,0,0,0⟩,
  ⟨1,1,0,0⟩,
  ⟨1,1,0,1⟩,
  ⟨1,1,1,0⟩,
  ⟨1,3,2,1⟩,
  ⟨2,3,1,2⟩,
  ⟨3,0,0,0⟩,
  ⟨3,1,0,0⟩,
  ⟨3,3,0,1⟩,
  ⟨3,3,0,3⟩]

private theorem starts : ∀ x : C, start x ∈ states := by decide +kernel

private theorem stable : ∀ z ∈ states, ∀ c : C,
    (step z c).all (fun w => decide (w ∈ states)) = true := by
  intro z hz
  simp only [states,List.mem_cons,List.not_mem_nil,or_false] at hz
  rcases hz with rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl <;> decide +kernel

private theorem zero_trap : ∀ z ∈ states, ∀ a b c : C, a ≠ 2 → scan z [0,a,b,c] = none := by
  intro z hz
  simp only [states,List.mem_cons,List.not_mem_nil,or_false] at hz
  rcases hz with rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl <;> decide +kernel

private theorem trap_after (xs : List C) (z : State) (hz : z ∈ states) (a b c : C) (ha : a ≠ 2) :
    scan z (xs ++ [0,a,b,c]) = none := by
  induction xs generalizing z with
  | nil => exact zero_trap z hz a b c ha
  | cons x xs ih =>
    simp only [List.cons_append,scan]
    cases he : step z x with
    | none => rfl
    | some w =>
      have h := stable z hz x
      simp [he] at h
      exact ih w h

/-- A reset-free two-phase path continuing past the second white must have
child bits 0,1 there (bit zero is the earlier phase). -/
theorem two_phase_rise (x : C) (between : List C) (a b c : C) (ha : a ≠ 2) :
    scan (start x) (between ++ [0,a,b,c]) = none :=
  trap_after between _ (starts x) a b c ha

end Rule30TwoPhaseRise

/-! Backward spatial determinism pins a periodic pair to its depth. The white
interface bound counts one temporal word per white, and applies to every
pointed recurrent strip with a black edge. -/
namespace Rule30RootedWhiteReturns
open Ruliology.CellularAutomata.Rule30AgedLeftDiagonals
open Ruliology.CellularAutomata.Rule30LeftUnbounded (code code_lt code_inj pigeonhole)

abbrev Column := Nat → Bool
abbrev ProfilePair := Column × Column
private def z : Column := fun _ => false
private def sig (d : Nat → Column) : Nat → ProfilePair
  | 0 => (z,z)
  | 1 => (z,d 0)
  | n+2 => (d n,d (n+1))

private def back (v : ProfilePair) : ProfilePair :=
  (fun t => xor (v.2 (t+1)) (v.1 t || v.2 t), v.1)

private theorem back_zero : back (z,z) = (z,z) := rfl

private theorem back_sig {d : Nat → Column} (hd : Recurrence d) (i : Nat) :
    back (sig d (i+1)) = sig d i := by
  apply Prod.ext
  · funext t
    match i with
    | 0 => change xor (d 0 (t+1)) (false || d 0 t) = false
           rw [hd.1]; cases d 0 t <;> rfl
    | 1 => change xor (d 1 (t+1)) (d 0 t || d 1 t) = false
           rw [hd.2.1]; cases d 0 t <;> cases d 1 t <;> rfl
    | n+2 =>
      change xor (d (n+2) (t+1)) (d (n+1) t || d (n+2) t) = d n t
      rw [hd.2.2]; cases d n t <;> cases d (n+1) t <;> cases d (n+2) t <;> rfl
  · cases i with
    | zero => rfl
    | succ i => cases i <;> rfl

private theorem sig_pos {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0 = true) :
    ∀ n, sig d (n+1) ≠ (z,z) := by
  intro n
  induction n with
  | zero =>
    intro e
    have h := congrArg (fun v : ProfilePair => v.2 0) e
    change d 0 0 = false at h
    rw [h0] at h; contradiction
  | succ n ih =>
    intro h
    apply ih
    rw [← back_sig hd (n+1),h,back_zero]

private theorem distinct {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0 = true) :
    ∀ i j, i<j → sig d i ≠ sig d j := by
  intro i
  induction i with
  | zero =>
    intro j hj h
    cases j with
    | zero => omega
    | succ j => exact sig_pos hd h0 j h.symm
  | succ i ih =>
    intro j hj h
    cases j with
    | zero => omega
    | succ j => exact ih j (by omega) (by rw [← back_sig hd i, ← back_sig hd j,h])

private theorem period_code {a b : Column} {p : Nat} (hp : 0<p)
    (ha : PeriodFrom a 0 p) (hb : PeriodFrom b 0 p) (hc : code a p = code b p) : a=b := by
  funext t
  have decomp : t%p + (t/p)*p = t := by simpa [Nat.mul_comm] using Nat.mod_add_div t p
  calc a t = a (t%p) := by
         simpa [decomp] using period_mul ha (t/p) (t%p) (Nat.zero_le _)
       _ = b (t%p) := code_inj _ _ _ hc _ (Nat.mod_lt _ hp)
       _ = b t := by simpa [decomp] using (period_mul hb (t/p) (t%p) (Nat.zero_le _)).symm

/-- Distinct white interfaces with a common clock have distinct preceding
words. No physical path can visit infinitely many white interfaces at this clock. -/
theorem rooted_white_count {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    {p : Nat} (hp : 0<p) (n : Nat) (atWheel : Nat → Nat)
    (ordered : ∀ i j, i<j → j<n → atWheel i < atWheel j)
    (white : ∀ i, i<n → ∀ t, d (atWheel i+1) t=false)
    (clock : ∀ i, i<n → PeriodFrom (d (atWheel i)) 0 p) : n ≤ 2^p := by
  apply pigeonhole (2^p) n (fun i => code (d (atWheel i)) p)
  · exact fun i _ => code_lt _ _
  · intro i j hi hj eqcode
    have hpair : sig d (atWheel i+2) = sig d (atWheel j+2) := by
      apply Prod.ext
      · exact period_code hp (clock i hi) (clock j hj) eqcode
      · exact funext (fun t => (white i hi t).trans (white j hj t).symm)
    by_cases lt : i<j
    · have lt' := ordered i j lt hj
      exact False.elim (distinct hd h0 _ _ (by omega) hpair)
    by_cases gt : j<i
    · have gt' := ordered j i gt hi
      exact False.elim (distinct hd h0 _ _ (by omega) hpair.symm)
    omega

private theorem two_code {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    {p : Nat} (hp : 0<p) (m : Nat) (periods : ∀ i, i≤m+1 → PeriodFrom (d i) 0 p) :
    m+1 ≤ 2^p * 2^p := by
  let num := fun i => code (d (i+1)) p + 2^p * code (d i) p
  have base : 0 < 2^p := Nat.two_pow_pos _
  apply pigeonhole (2^p*2^p) (m+1) num
  · intro i _
    have h := code_lt (d i) p
    have h' := code_lt (d (i+1)) p
    have h'' := Nat.mul_le_mul_right (2^p) (show code (d i) p + 1 ≤ 2^p by omega)
    dsimp [num]; rw [Nat.mul_comm (2^p) (code (d i) p)]; rw [Nat.add_mul,Nat.one_mul] at h''; omega
  · intro i j hi hj h
    have high := congrArg (fun v => v / 2^p) h
    have low := congrArg (fun v => v % 2^p) h
    simp [num, Nat.add_mul_div_left _ _ base, Nat.div_eq_of_lt (code_lt _ _),
          Nat.mod_eq_of_lt (code_lt _ _)] at high low
    have e : sig d (i+2) = sig d (j+2) :=
      Prod.ext (period_code hp (periods _ (by omega)) (periods _ (by omega)) high)
               (period_code hp (periods _ (by omega)) (periods _ (by omega)) low)
    by_cases lt : i<j
    · exact False.elim (distinct hd h0 _ _ (by omega) e)
    by_cases gt : j<i
    · exact False.elim (distinct hd h0 _ _ (by omega) e.symm)
    omega

/-- Every black-edged strip eventually leaves any prescribed common clock. -/
theorem escapes_clock {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    {p : Nat} (hp : 0<p) : ∃ j, j ≤ 2^p*2^p+1 ∧ ¬PeriodFrom (d j) 0 p := by
  classical
  apply Classical.byContradiction
  intro h
  have hall : ∀ i, i ≤ 2^p*2^p+1 → PeriodFrom (d i) 0 p := by
    intro i hi
    apply Classical.byContradiction
    intro bad
    exact h ⟨i,hi,bad⟩
  have hbad := two_code hd h0 hp _ hall
  omega

private theorem first_at (pred : Nat → Prop) (n : Nat) (hn : pred n) :
    ∃ m, m ≤ n ∧ pred m ∧ ∀ i, i<m → ¬pred i := by
  classical
  induction n using Nat.strongRecOn with
  | ind n ih =>
    by_cases e : ∃ i, i<n ∧ pred i
    · obtain ⟨i, hin, hi⟩ := e
      obtain ⟨m, hm, hp, hfirst⟩ := ih i hin hi
      exact ⟨m, by omega, hp, hfirst⟩
    · exact ⟨n, by omega, hn, fun i hi h => e ⟨i,hi,h⟩⟩

private theorem white_flip {a x : Column} {p : Nat} (ha : PeriodFrom a 0 p)
    (step : ∀ t, x (t+1) = xor (a t) (x t)) (loss : ¬PeriodFrom x 0 p) :
    ∀ t, x (t+p) = !(x t) := by
  have same : x p ≠ x 0 := by
    intro e
    apply loss
    intro t _
    induction t with
    | zero => simpa using e
    | succ t ih =>
      rw [show t+1+p=(t+p)+1 by omega, step (t+p), step t,ha t (by omega),ih (by omega)]
  intro t
  induction t with
  | zero => cases hp : x p <;> cases h : x 0 <;> simp_all
  | succ t ih =>
    rw [show t+1+p=(t+p)+1 by omega,step (t+p),step t,ha t (by omega),ih]
    cases a t <;> cases x t <;> rfl

/-- Beyond any already settled pointed prefix, the first loss of its common
clock occurs immediately after a permanently white wheel. The next column
is antiperiodic at that clock, at every tick including the marked phase. -/
theorem first_clock_loss {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    (recurrent : ∀ j, ∃ q, 0<q ∧ PeriodFrom (d j) 0 q)
    {p m : Nat} (hp : 0<p) (hm : 1≤m)
    (hprefix : ∀ i, i≤m → PeriodFrom (d i) 0 p) :
    ∃ j, m≤j ∧ j+1 ≤ 2^p*2^p+1 ∧
      (∀ i, i≤j → PeriodFrom (d i) 0 p) ∧
      (∀ t, d j t=false) ∧ (∀ t, d (j+1) (t+p) = !(d (j+1) t)) := by
  classical
  obtain ⟨n, hn, bad⟩ := escapes_clock hd h0 hp
  obtain ⟨k, hkn, hk, first⟩ := first_at (fun i => ¬PeriodFrom (d i) 0 p) n bad
  have good : ∀ i, i<k → PeriodFrom (d i) 0 p := fun i hi => Classical.not_not.mp (first i hi)
  have hmk : m<k := by
    by_cases h : k≤m
    · exact False.elim (hk (hprefix k h))
    · omega
  obtain ⟨i, rfl⟩ : ∃ i, k=i+2 := ⟨k-2, by omega⟩
  have white : ∀ t, d (i+1) t=false := by
    intro t
    cases h : d (i+1) t with
    | false => rfl
    | true =>
      obtain ⟨q,hq,hperiod⟩ := recurrent (i+2)
      exact False.elim (hk (reset_inherits (hd.2.2 i) (good i (by omega))
        (good (i+1) (by omega)) hperiod hq (Nat.zero_le t) h))
  refine ⟨i+1,by omega,by omega,fun j hj => good j (by omega),white,?_⟩
  apply white_flip (good i (by omega)) _ hk
  intro t
  simpa only [white,Bool.false_or] using hd.2.2 i t

/-- A white wheel and a black wheel two places deeper occur beyond any cutoff.
The common-prefix clock hypothesis is satisfied by the pointed cycle systems. -/
theorem unbounded_anchors {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    (clocks : ∀ m, ∃ p, 0<p ∧ ∀ i, i≤m → PeriodFrom (d i) 0 p) (lo : Nat) :
    ∃ j, lo≤j ∧ (∀ t, d j t=false) ∧ (∀ t, d (j+2) t=true) := by
  have recurrent : ∀ j, ∃ p, 0<p ∧ PeriodFrom (d j) 0 p := by
    intro j
    obtain ⟨p,hp,h⟩ := clocks j
    exact ⟨p,hp,h j (by omega)⟩
  obtain ⟨p,hp,hprefix⟩ := clocks (lo+1)
  obtain ⟨j,hj,_,_,hw,anti⟩ := first_clock_loss hd h0 recurrent hp (by omega : 1≤lo+1) hprefix
  have blackTick : ∃ t, d (j+1) t=true := by
    cases h : d (j+1) 0 with
    | true => exact ⟨0,h⟩
    | false => exact ⟨0+p,by rw [anti 0,h]; rfl⟩
  obtain ⟨t,ht⟩ := blackTick
  have latch : ∀ k, d (j+2) (t+1+k)=true := by
    intro k
    induction k with
    | zero => simp [hd.2.2,hw,ht]
    | succ k ih =>
      rw [show t+1+(k+1)=(t+1+k)+1 by omega,hd.2.2,hw,ih]; simp
  obtain ⟨q,hq,hper⟩ := recurrent (j+2)
  refine ⟨j,by omega,hw,?_⟩
  intro u
  have le : t+1 ≤ (t+1)*q := by
    simpa using Nat.mul_le_mul_left (t+1) (show 1≤q by omega)
  have e := latch (u+(t+1)*q-(t+1))
  rw [show t+1+(u+(t+1)*q-(t+1))=u+(t+1)*q by omega, period_mul hper _ u (by omega)] at e
  exact e

end Rule30RootedWhiteReturns

/-! Least prefix clocks and unbounded resets in three successive phases of a pointed strip. -/
namespace Rule30RecurrentStrip
open Ruliology.CellularAutomata.Rule30AgedLeftDiagonals
open Rule30RootedWhiteReturns

def Clock (d : Nat → Column) (m p : Nat) := ∀ i, i ≤ m → PeriodFrom (d i) 0 p

private theorem divides_clock {d m p q} (hp : 0 < p) (h : Clock d m p)
    (least : ∀ r, 0 < r → Clock d m r → p ≤ r) (other : Clock d m q) : p ∣ q := by
  apply Nat.dvd_of_mod_eq_zero
  by_cases hz : q%p = 0
  · exact hz
  have hr : Clock d m (q%p) := by
    intro i hi t ht
    have e := period_mul (h i hi) (q/p) (t + q%p) (by omega)
    have split : q%p + q/p*p = q := by simpa [Nat.mul_comm] using Nat.mod_add_div q p
    rw [Nat.add_assoc, split] at e
    exact e.symm.trans (other i hi t ht)
  have := least (q%p) (by omega) hr
  have := Nat.mod_lt q hp
  omega

/-- The least positive common period through each wheel is a power of two. -/
theorem dyadic_prefix_clock {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0 = true)
    (recurrent : ∀ i, ∃ q, 0 < q ∧ PeriodFrom (d i) 0 q) (m : Nat) :
    ∃ e, Clock d m (2^e) ∧ ∀ q, 0 < q → Clock d m q → 2^e ≤ q := by
  have edge (t : Nat) : d 0 t = true := by
    induction t with
    | zero => exact h0
    | succ t ih => exact (hd.1 t).trans ih
  have front (t : Nat) : d 1 t = true := by
    obtain ⟨q,hq,per⟩ := recurrent 1
    obtain ⟨u, hu⟩ : ∃ u, t+q=u+1 := ⟨t+q-1, by omega⟩
    rw [← per t (by omega), hu, hd.2.1, edge, Bool.true_or]
  induction m with
  | zero =>
    refine ⟨0, ?_, fun _ hq _ => hq⟩
    intro i hi t _
    have h : i=0 := by omega
    simp [h, edge]
  | succ m ih =>
    by_cases hm : m=0
    · subst m
      refine ⟨0, ?_, fun _ hq _ => hq⟩
      intro i hi t _
      rcases (show i = 0 ∨ i = 1 by omega) with rfl | rfl <;> simp [edge, front]
    obtain ⟨e, cp, least⟩ := ih
    let p := 2^e
    have hp : 0 < p := Nat.two_pow_pos _
    by_cases inherit : PeriodFrom (d (m+1)) 0 p
    · refine ⟨e, ?_, fun q hq cq => least q hq (fun i hi => cq i (by omega))⟩
      intro i hi
      by_cases h : i=m+1
      · exact h ▸ inherit
      · exact cp i (by omega)
    obtain ⟨j,hmj,_,cj,_,anti⟩ := first_clock_loss hd h0 recurrent hp (by omega : 1≤m) cp
    have hj : j=m := by
      by_cases hu : m+1≤j
      · exact (inherit (cj _ hu)).elim
      · omega
    subst j
    refine ⟨e+1, ?_, ?_⟩
    · intro i hi t ht
      change d i (t + 2^(e+1)) = d i t
      rw [Nat.pow_succ, ← show p = 2^e from rfl, show t+p*2=t+p+p by omega]
      by_cases last : i=m+1
      · simp [last, anti]
      · rw [cp i (by omega) (t+p) (by omega), cp i (by omega) t ht]
    · intro q hq cq
      have dq := divides_clock hp cp least (fun i hi => cq i (by omega))
      obtain ⟨k,hk⟩ := dq
      have hne : q ≠ p := by
        rintro rfl
        exact inherit (cq _ (by omega))
      have hk2 : 2 ≤ k := by
        by_cases k0 : k=0
        · simp [k0] at hk; omega
        by_cases k1 : k=1
        · simp [k1] at hk; contradiction
        omega
      rw [Nat.pow_succ, hk]
      exact Nat.mul_le_mul_left p hk2

open Rule30ThreePhaseReturn

/-- A closed run at a single tick, including both white endpoints. -/
def Reset (r : Nat → Bool) (j n : Nat) : Prop :=
  n % 3 = 1 ∧ r j = false ∧ (∀ k, k < n → r (j+1+k) = true) ∧ r (j+1+n) = false

private def trailing (r : Nat → Bool) : Nat → Nat
  | 0 => 0
  | i+1 => if r (i+1) then trailing r i + 1 else 0

private theorem trailing_spec (r : Nat → Bool) (hw : r 0 = false) (i : Nat) :
    ∃ j, j + trailing r i = i ∧ r j = false ∧
      ∀ k, k < trailing r i → r (j+1+k) = true := by
  induction i with
  | zero => exact ⟨0,rfl,hw,fun k h => by simp [trailing] at h⟩
  | succ i ih =>
    obtain ⟨j,hj,hz,hb⟩ := ih
    cases h : r (i+1) with
    | false => exact ⟨i+1,by simp [trailing,h],h,fun k hk => by simp [trailing,h] at hk⟩
    | true =>
      simp only [trailing,h, ↓reduceIte]
      refine ⟨j, by omega, hz, ?_⟩
      intro k hk
      by_cases lt : k < trailing r i
      · exact hb k lt
      · rwa [show j+1+k=i+1 by omega]

private def pack (a b c : Bool) : C := BitVec.ofBool c ++ BitVec.ofBool b ++ BitVec.ofBool a
private def bits (f : Nat → Bool) := pack (f 0) (f 1) (f 2)

private theorem read_pack : ∀ a b c : Bool,
    (pack a b c).getLsbD 0 = a ∧ (pack a b c).getLsbD 1 = b ∧ (pack a b c).getLsbD 2 = c := by
  decide +kernel

private theorem read_bits (f : Nat → Bool) (i : Fin 3) : (bits f).getLsbD i.val = f i.val := by
  obtain ⟨a,b,c⟩ := read_pack (f 0) (f 1) (f 2)
  rcases (show i.val=0 ∨ i.val=1 ∨ i.val=2 by omega) with h|h|h <;> simp only [h,bits] <;> assumption

private theorem eq_bits : ∀ a b : C,
    (∀ i : Fin 3, a.getLsbD i.val = b.getLsbD i.val) → a = b := by decide +kernel

private theorem guard_clock : ∀ a b c : C,
    c.getLsbD 1 = xor (a.getLsbD 0) (b.getLsbD 0 || c.getLsbD 0) →
    c.getLsbD 2 = xor (a.getLsbD 1) (b.getLsbD 1 || c.getLsbD 1) →
    (c >>> 1) &&& 3 = (a ^^^ (b ||| c)) &&& 3 := by decide +kernel

private def col (r : Nat → Nat → Bool) (i : Nat) := bits (fun t => r t i)
private def mask (r : Nat → Nat → Bool) (i k : Nat) := bits (fun t => decide (trailing (r t) i % 3 = k))
private def state (r : Nat → Nat → Bool) (u : Nat) : State :=
  ⟨col r (u+1), col r (u+2), mask r (u+2) 1, mask r (u+2) 2⟩

private theorem state_start (r : Nat → Nat → Bool) (h : ∀ t, r t 2 = true) :
    state r 0 = start (col r 1) := by
  have startBits (t : Nat) : trailing (r t) 2 = (if r t 1 then 2 else 1) := by
    cases e : r t 1 <;> simp [trailing,h,e]
  simp only [state,start,State.mk.injEq,true_and]
  refine ⟨eq_bits _ _ (fun i => ?_), eq_bits _ _ (fun i => ?_), eq_bits _ _ (fun i => ?_)⟩
  · rw [col,read_bits,h]
    rcases (show i.val=0 ∨ i.val=1 ∨ i.val=2 by omega) with h|h|h <;> rw [h] <;> rfl
  · simp only [mask,col,read_bits,BitVec.getLsbD_not, i.isLt, decide_true, Bool.true_and, startBits]
    cases r i.val 1 <;> decide
  · simp only [mask,col,read_bits,startBits]
    cases r i.val 1 <;> decide

private theorem state_step (r : Nat → Nat → Bool) (hw : ∀ t, r t 0 = false)
    (law : ∀ t j, r (t+1) (j+2) = xor (r t j) (r t (j+1) || r t (j+2)))
    (safe : ∀ t, t < 3 → ∀ j n, ¬ Reset (r t) j n) (u : Nat) :
    step (state r u) (col r (u+3)) = some (state r (u+1)) := by
  have clk := guard_clock (col r (u+1)) (col r (u+2)) (col r (u+3))
  have bit (i k : Nat) (h : k<3) : (col r i).getLsbD k = r k i := read_bits _ ⟨k,h⟩
  have hclk := clk (by simpa only [bit _ _ (by decide : 0<3),bit _ _ (by decide : 1<3)] using law 0 (u+1))
    (by simpa only [bit _ _ (by decide : 1<3),bit _ _ (by decide : 2<3)] using law 1 (u+1))
  have hsafe (i : Fin 3) (ho : trailing (r i.val) (u+2) % 3 = 1) : r i.val (u+3) = true := by
    cases hc : r i.val (u+3) with
    | true => rfl
    | false =>
      obtain ⟨j,hj,hz,hb⟩ := trailing_spec _ (hw _) (u+2)
      exact (safe _ i.isLt j _ ⟨ho,hz,hb, by rwa [show j+1+trailing (r i.val) (u+2)=u+3 by omega]⟩).elim
  have noClose : mask r (u+2) 1 &&& ~~~(col r (u+3)) = 0 := by
    apply eq_bits
    intro i
    simp only [mask,col,BitVec.getLsbD_and,BitVec.getLsbD_not,read_bits,i.isLt,decide_true,Bool.true_and]
    by_cases ho : trailing (r i.val) (u+2)%3=1
    · simp [ho,hsafe i ho]
    · simp [ho]
  have extend (i : Fin 3) : trailing (r i.val) (u+3) =
      (if r i.val (u+3) then trailing (r i.val) (u+2) + 1 else 0) := rfl
  simp only [step,state,hclk,noClose]
  simp [State.mk.injEq,Nat.add_assoc]
  constructor <;> apply eq_bits <;> intro i <;>
    simp only [mask,col,BitVec.getLsbD_and,BitVec.getLsbD_not,BitVec.getLsbD_or,read_bits,
      i.isLt,decide_true,Bool.true_and, extend] <;>
    cases r i.val (u+3) <;> simp <;> try omega
  by_cases h1 : trailing (r i.val) (u+2)%3=1 <;>
    by_cases h2 : trailing (r i.val) (u+2)%3=2 <;> simp [h1,h2] <;> omega

private def segment (f : Nat → C) (u : Nat) : Nat → List C
  | 0 => []
  | k+1 => f u :: segment f (u+1) k

private theorem scan_segment (r : Nat → Nat → Bool)
    (ok : ∀ u, step (state r u) (col r (u+3)) = some (state r (u+1))) (u k : Nat)
    (tail : List C) : scan (state r u) (segment (col r) (u+3) k ++ tail) =
      scan (state r (u+k)) tail := by
  induction k generalizing u with
  | zero => rfl
  | succ k ih =>
    simp only [segment,List.cons_append,scan,ok,Option.bind_some]
    exact (ih (u+1)).trans (by rw [show u+1+k=u+(k+1) by omega])

private theorem beyond {d : Nat → Column} (hd : Recurrence d)
    (anchors : ∀ lo, ∃ j, lo≤j ∧ (∀ t, d j t=false) ∧ (∀ t, d (j+2) t=true)) (s lo : Nat) :
    ∃ t j n, t<3 ∧ lo≤j ∧ Reset (fun i => d i (s+t)) j n := by
  apply Classical.byContradiction
  intro missing
  obtain ⟨a,ha,white,black⟩ := anchors lo
  obtain ⟨b,hb,whiteB,_⟩ := anchors (a+3)
  let r := fun t i => d (a+i) (s+t)
  have hw (t) : r t 0=false := white _
  have hblack (t) : r t 2=true := black _
  have law (t j) : r (t+1) (j+2) = xor (r t j) (r t (j+1) || r t (j+2)) := by
    simpa [r,Nat.add_assoc] using hd.2.2 (a+j) (s+t)
  have safe (t) (ht : t<3) (j n) (hit : Reset (r t) j n) : False := by
    apply missing
    refine ⟨t,a+j,n,ht,by omega,?_⟩
    simpa [Reset,r,Nat.add_assoc] using hit
  have ok := state_step r hw law safe
  let k := b-(a+3)
  have hz : col r (k+3) = 0 := by
    apply eq_bits
    intro i
    have h : a+(k+3)=b := by dsimp [k]; omega
    rw [col,read_bits]
    simp [r,h,whiteB]
  have trap := three_phase_return (col r 1) (segment (col r) 3 k)
    (col r (k+4)) (col r (k+5)) (col r (k+6))
  rw [← state_start r hblack, ← hz, ← show 0+3=3 from rfl, scan_segment r ok, Nat.zero_add] at trap
  simp only [scan,ok,Option.bind_some] at trap
  contradiction

/-- One fixed member of any three successive ticks contains closed runs of
length one modulo three at arbitrarily great depths on the same strip. -/
theorem one_of_three_unbounded {d : Nat → Column} (hd : Recurrence d) (h0 : d 0 0=true)
    (clocks : ∀ m, ∃ p, 0<p ∧ Clock d m p) (s : Nat) :
    ∃ t, t<3 ∧ ∀ lo, ∃ j n, lo≤j ∧ Reset (fun i => d i (s+t)) j n := by
  classical
  apply Classical.byContradiction
  intro absent
  have cap (t) (ht : t<3) : ∃ lo, ∀ j n, lo≤j → ¬Reset (fun i => d i (s+t)) j n := by
    apply Classical.byContradiction
    intro h
    apply absent
    refine ⟨t,ht,fun lo => Classical.byContradiction fun hn => h ?_⟩
    exact ⟨lo, fun j n hj hr => hn ⟨j,n,hj,hr⟩⟩
  obtain ⟨a,ha⟩ := cap 0 (by decide)
  obtain ⟨b,hb⟩ := cap 1 (by decide)
  obtain ⟨c,hc⟩ := cap 2 (by decide)
  obtain ⟨t,j,n,ht,hj,h⟩ := beyond hd (unbounded_anchors hd h0 clocks) s (max a (max b c))
  rcases (show t=0 ∨ t=1 ∨ t=2 by omega) with rfl|rfl|rfl
  · exact ha j n (by omega) h
  · exact hb j n (by omega) h
  · exact hc j n (by omega) h

end Rule30RecurrentStrip

/-! Uniform reset depth on periodic finite bands, from unbounded closed runs on
each pointed recurrent strip. All widths count wheels starting at wheel zero. -/
namespace Rule30ResetCompactness
open Ruliology.CellularAutomata
open Rule30AgedLeftDiagonals Rule30UniversalLeftSide Rule30EveryKStatement
open Rule30RecurrentStrip (Clock Reset)

/-- The strip and clock hypotheses are those of the three-phase theorem.
Here the prescribed phase itself must have arbitrarily deep closed runs. -/
def LInfinity : Prop := ∀ (d : Nat → Nat → Bool), Recurrence d → d 0 0 = true →
  (∀ m, ∃ p, 0 < p ∧ Clock d m p) →
  ∀ s lo, ∃ j n, lo ≤ j ∧ Reset (fun i => d i s) j n

private def Often (P : Nat → Prop) := ∀ bound, ∃ i, bound ≤ i ∧ P i

private theorem split_often {P : Nat → Prop} (h : Often P) (f : Nat → Bool) :
    ∃ b, Often (fun i => P i ∧ f i = b) := by
  classical
  by_cases ht : Often (fun i => P i ∧ f i = true)
  · exact ⟨true, ht⟩
  · simp only [Often, Classical.not_forall, not_exists, not_and] at ht
    obtain ⟨u, hu⟩ := ht
    refine ⟨false, fun bound => ?_⟩
    obtain ⟨i, hi, pi⟩ := h (max bound u)
    exact ⟨i, by omega, pi, Bool.eq_false_iff.mpr (hu i (by omega) pi)⟩

private structure Pool where
  pred : Nat → Prop
  often : Often pred

private noncomputable def pools (bits : Nat → Nat → Bool) : Nat → Pool
  | 0 => ⟨fun _ => True, fun n => ⟨n, Nat.le_refl _, trivial⟩⟩
  | n+1 =>
    let p := pools bits n
    let pick := split_often p.often (fun i => bits i n)
    ⟨_, pick.choose_spec⟩

private theorem limit_prefix (bits : Nat → Nat → Bool) :
    ∃ x : Nat → Bool, ∀ n, Often (fun i => ∀ j, j < n → bits i j = x j) := by
  let x := fun n => (split_often (pools bits n).often (fun i => bits i n)).choose
  have matchBits (n i) (h : (pools bits n).pred i) : ∀ j, j < n → bits i j = x j := by
    induction n with
    | zero => intro j hj; omega
    | succ n ih =>
      change (pools bits n).pred i ∧ bits i n = x n at h
      intro j hj
      by_cases eq : j = n
      · exact eq ▸ h.2
      · exact ih h.1 j (by omega)
  exact ⟨x, fun n bound => by
    obtain ⟨i,hi,h⟩ := (pools bits n).often bound
    exact ⟨i,hi,matchBits n i h⟩⟩

private def orbit (x : Nat → Bool) : Nat → Nat → Bool
  | 0 => x
  | t+1 => fun | 0 => orbit x t 0
               | 1 => orbit x t 0 || orbit x t 1
               | j+2 => xor (orbit x t j) (orbit x t (j+1) || orbit x t (j+2))

private theorem orbit_prefix {x v w n} (hn : n ≤ w)
    (bits : ∀ j, j < n → v.testBit j = x j) (t : Nat) :
    ∀ j, j < n → (bandAt w v t).testBit j = orbit x t j := by
  induction t with
  | zero => exact bits
  | succ t ih =>
    intro j hj
    cases j with
    | zero => exact (stepK_bit_zero (by omega) _).trans (ih 0 hj)
    | succ j =>
      cases j with
      | zero => rw [bandAt, rowAt, stepK_bit_one (by omega), ih 0 (by omega), ih 1 hj]; rfl
      | succ j => rw [bandAt, rowAt, stepK_bit_step (by omega), ih j (by omega), ih (j+1) (by omega), ih (j+2) hj]; rfl

/-- At each desired cut depth there is one window containing a complete
factor for every periodic odd band of at least that width. -/
theorem uniform_factor (deep : LInfinity) (lo : Nat) :
    ∃ b, ∀ w v p, b ≤ w → OddBand w v → 0 < p → bandAt w v p = v →
      ∃ j m, lo ≤ j ∧ j + 3*m + 4 ≤ b ∧ resetAt v j m = true := by
  classical
  apply Classical.byContradiction
  intro fail
  simp only [not_exists, Classical.not_forall] at fail
  let w := fun i => (fail i).choose
  let vs := fun i => (fail i).choose_spec
  let v := fun i => (vs i).choose
  let ps := fun i => (vs i).choose_spec
  let p := fun i => (ps i).choose
  let data := fun i => (ps i).choose_spec
  have wide (i) : i ≤ w i := (data i).1
  have odd (i) : OddBand (w i) (v i) := (data i).2.1
  have pos (i) : 0 < p i := (data i).2.2.1
  have cyc (i) : bandAt (w i) (v i) (p i) = v i := (data i).2.2.2.1
  have bad := fun i => (data i).2.2.2.2
  obtain ⟨x, approx⟩ := limit_prefix (fun i j => (v i).testBit j)
  let d := fun j t => orbit x t j
  have recurrence : Recurrence d := ⟨fun _ => rfl, fun _ => rfl, fun _ _ => rfl⟩
  have edge : d 0 0 = true := by
    obtain ⟨i, _, hx⟩ := approx 1 1
    exact (hx 0 (by decide)).symm.trans (odd i).2
  have clocks (m) : ∃ q, 0 < q ∧ Clock d m q := by
    obtain ⟨i,hi,hx⟩ := approx (m+1) (m+1)
    have agree := orbit_prefix (Nat.le_trans hi (wide i)) hx
    refine ⟨p i, pos i, fun j hj t _ => ?_⟩
    change orbit x (t+p i) j = orbit x t j
    rw [← agree _ j (by omega), ← agree _ j (by omega), bandAt, rowAt_add_period (cyc i)]
  obtain ⟨a,n,ha,hn,hleft,hones,hright⟩ := deep d recurrence edge clocks 0 (lo+1)
  let m := n / 3
  have len : n = 3*m + 1 := by dsimp [m]; omega
  let j := a-1
  have start : j+1 = a := by dsimp [j]; omega
  let b := j+3*m+4
  obtain ⟨i,hi,hx⟩ := approx b b
  have bit (l) (hl : l < b) : (v i).testBit l = d l 0 := hx l hl
  have reset : resetAt (v i) j m = true := by
    simp only [resetAt, Bool.and_eq_true, Bool.not_eq_true', List.all_eq_true, List.mem_range]
    refine ⟨⟨(bit _ (by dsimp [b]; omega)).trans (start.symm ▸ hleft), ?_⟩, ?_⟩
    · rw [bit _ (by dsimp [b]; omega), show j+3*m+3 = a+1+n by omega]; exact hright
    · intro k hk
      rw [bit _ (by dsimp [b]; omega), show j+2+k = a+1+k by omega]; exact hones k (by omega)
  exact bad i j m ⟨by omega,hi,reset⟩


/-- Searching in descending depth returns a cut at least as deep as any
given witness. The predicate is fixed even as the search list shrinks. -/
private theorem descending_find (test : Nat → Bool) {j : Nat} (ok : test j = true)
    (n : Nat) (inside : j < n) :
    ∃ cut, (List.range n).reverse.find? test = some cut ∧ j ≤ cut := by
  induction n with
  | zero => omega
  | succ n ih =>
    simp only [List.range_succ, List.reverse_append, List.reverse_singleton,
      List.singleton_append, List.find?_cons]
    split <;> rename_i h
    · exact ⟨n, rfl, by omega⟩
    · exact ih (by apply Nat.lt_of_le_of_ne (by omega); intro eq; subst j; simp [h] at ok)

private theorem find_cut {v j m a : Nat} (fits : j+3*m+4 ≤ a) (reset : resetAt v j m = true) :
    ∃ cut, firstReset v a = some cut ∧ j ≤ cut := by
  apply descending_find _ _ a (by omega)
  apply List.any_eq_true.mpr
  exact ⟨m, List.mem_range.mpr (by omega), by simp [fits, reset]⟩

private theorem advance (w v t q : Nat) :
    bandAt w (bandAt w v t) q = bandAt w v (q+t) := by
  induction q with
  | zero => simp [bandAt, rowAt]
  | succ q ih => rw [Nat.succ_add]; exact congrArg (bandStep w) ih

private theorem phase_odd {w v} (odd : OddBand w v) (hw : 0 < w) (t : Nat) :
    OddBand w (bandAt w v t) := by
  induction t with
  | zero => exact odd
  | succ t ih => exact ⟨Nat.mod_lt _ (Nat.two_pow_pos _), (stepK_bit_zero hw _).trans ih.2⟩

/-- Any free entrance and any starting layer are allowed. A window for k+1
layers leaves at least the entire k-layer window after the first cut. -/
private theorem uniform_schedule (deep : LInfinity) (k : Nat) :
    ∃ u, ∀ w v p fuel d a, u ≤ a → a ≤ w → k ≤ fuel → 0 < w →
      OddBand w v → 0 < p → bandAt w v p = v → k ≤ schedule w v p fuel d a := by
  induction k with
  | zero => exact ⟨0, by intros; exact Nat.zero_le _⟩
  | succ k ih =>
    obtain ⟨u, smaller⟩ := ih
    obtain ⟨b, window⟩ := uniform_factor deep u
    refine ⟨b, ?_⟩
    intro w v p fuel d a ba aw kf hw odd hp cyc
    cases fuel with
    | zero => omega
    | succ fuel =>
      let t := (p - d%p)%p
      have returns : bandAt w (bandAt w v t) p = bandAt w v t := by
        rw [advance, Nat.add_comm p t]; exact rowAt_add_period cyc t
      obtain ⟨j,m,uj,fit,reset⟩ := window w _ p (by omega) (phase_odd odd hw t) hp returns
      obtain ⟨cut,hcut,jcut⟩ := find_cut (a := a) (by omega : j+3*m+4 ≤ a) reset
      obtain ⟨n, bound, _⟩ := Rule30EveryKCascade.firstReset_spec hcut
      have next := smaller w v p fuel (d+1) cut (by omega) (by omega) (by omega) hw odd hp cyc
      rw [schedule, hcut]
      change k+1 ≤ 1 + schedule w v p fuel (d+1) cut
      omega

private theorem walk_sound (w v fuel t q : Nat)
    (h : returnPeriod.walk w v fuel (bandAt w v t) t = some q) :
    0 < q ∧ bandAt w v q = v := by
  induction fuel generalizing t with
  | zero => simp [returnPeriod.walk] at h
  | succ fuel ih =>
    rw [returnPeriod.walk] at h
    split at h <;> rename_i eq
    · cases h; exact ⟨by omega, eq⟩
    · exact ih (t+1) h

private theorem fold_floor (step : Nat → Nat → Nat) (xs : List Nat) {k : Nat}
    (preserves : ∀ i ∈ xs, ∀ acc, k ≤ acc → k ≤ step acc i) (acc : Nat) (h : k ≤ acc) :
    k ≤ xs.foldl step acc := by
  induction xs generalizing acc with
  | nil => exact h
  | cons i xs ih =>
    exact ih (fun j hj => preserves j (by simp [hj])) _ (preserves i (by simp) acc h)

/-- Unbounded resets in every phase of every pointed recurrent strip suffice
for the kit's worst-phase, worst-cycle capacity to reach every depth. -/
theorem cap_of_unbounded_resets (deep : LInfinity) : CAP := by
  intro k
  obtain ⟨u, bound⟩ := uniform_schedule deep k
  let n := max k u
  refine ⟨n+1, by omega, ?_⟩
  unfold K1
  apply fold_floor
  · intro i hi acc hacc
    have small := List.mem_range.mp hi
    dsimp only
    split <;> rename_i h
    · exact hacc
    · rename_i p
      obtain ⟨hp,cyc⟩ := walk_sound (n+1) (2*i+1) (2^n) 0 p h
      apply Nat.le_min.mpr
      refine ⟨hacc, bound (n+1) (2*i+1) p (n+1) 0 (n+1) (by dsimp [n]; omega)
        (by omega) (by dsimp [n]; omega) (by omega) ?_ hp cyc⟩
      constructor
      · rw [Nat.pow_succ]; omega
      · simp [Nat.testBit_zero]
  · dsimp [n]; omega

end Rule30ResetCompactness

namespace Rule30Submission

open Ruliology.CellularAutomata Rule30EveryKStatement Rule30ResetCompactness

/-- Closed runs at arbitrarily large depths in every prescribed phase of every pointed recurrent strip give the
kit's reset capacity `CAP`. -/
theorem cap_of_unbounded_resets : LInfinity → CAP :=
  Rule30ResetCompactness.cap_of_unbounded_resets

/-- With the conditional every-k theorem, the same hypothesis gives the inverse-tick target for every k. -/
theorem every_k_of_unbounded_resets : LInfinity → ∀ k, ∃ age, TargetAt k age :=
  fun deep k => ⟨_, Rule30EveryKInverse.conditional_every_k (Rule30ResetCompactness.cap_of_unbounded_resets deep) k⟩

end Rule30Submission
", "ProjectDir" -> $Rule30PrizeKit]
```

## The formal checks

The two headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.cap_of_unbounded_resets", "Rule30Submission.every_k_of_unbounded_resets"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms are standard ones only:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

Here are the three lemmas the essay leans on: the window of section 4's first step, the three-tick theorem, and the first loss of a clock.

```wl
lemmas = {"Rule30ResetCompactness.uniform_factor", "Rule30RecurrentStrip.one_of_three_unbounded", "Rule30RootedWhiteReturns.first_clock_loss"};
AssociationMap[rule30Submission[#]["TypeForm"] &, lemmas]
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.cap_of_unbounded_resets"]["KernelCheck"]
```
