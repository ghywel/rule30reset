---
Template: ComputationalEssay
Name: The Relaxed Doubling Lemma Gives Closed Runs at Every Depth, and So Every Number of Inverse Ticks
Author: {AUTHORS}
Date: 2026-11-20
Description: Core Lean. Closed runs at arbitrarily large depths in every row of every recurrent left-edge strip, the hypothesis of our previous entry, follow from a statement about the two stretches after each first period doubling: a tick missed by the first is caught by the second. With our earlier entries this gives the inverse-tick statement for every k from that local statement alone. It is open. Nothing here decides Q01.
Abstract: In core Lean 4.35.0 we prove that `LInfinity`, the hypothesis of our entry R30-20261120-eb2bcc, follows from a statement about two stretches of a strip at a time (`Rule30Submission.lInfinity_of_dlMinusOne`), and with it the kit's inverse-tick target for every k (`Rule30Submission.every_k_of_dlMinusOne`). On a pointed recurrent strip the least common period of the first wheels is a power of two, and it is first lost just after a wheel that is white at every tick. `DLMinusOne` says that at every such first loss, every tick has a closed run, a white cell, 3n + 1 black cells and a white cell, inside the stretch up to the next white wheel or the stretch after it. The proof is a window theorem that uses no axioms (`Rule30Submission.lInfinity_of_windows`): windows that start beyond every depth and hold a closed run at every tick give `LInfinity`, and first losses supply such windows. With our earlier entries, `LInfinity` gives `CAP` and `CAP` gives the target (`Rule30EveryKInverse`). The catalog has the per-wheel doubling criterion (`Rule30LeftAntiPeriod`), but no reset condition at doublings. `DLMinusOne` is open. Its strict form, the first stretch alone, holds by computation for every source of power-of-two period up to 32. Nothing here decides `Q01`.
Keywords: [rule 30, Rule 30 Prize, zero-boundary left half, white wall, inverse ticks, every k, closed runs, recurrent strips, period doubling, white wheels, conditional theorem, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

**Strips.** As in our entry R30-20261120-eb2bcc: wheel `j` at tick `t` is the cell `j` places in from the leftmost black cell at time `t`. A *pointed recurrent strip* is an array `d j t` that obeys the left-edge recurrence of the kit's `Rule30AgedLeftDiagonals.Recurrence`, is black at wheel 0 and tick 0, and for every `m` has a positive period common to its wheels `0` to `m` from tick 0 (`PrefixClocks`). A *closed run* in the row of tick `s` is a white cell at wheel `j`, then `n` black cells with `n` one more than a multiple of three, then a white cell (`Reset`).

**First losses and stretches.** On such a strip the least common period of the first wheels is a power of two, and it can only grow.
- A *first loss* at wheel `a`, of the clock `2^e`, has three parts (`FirstLoss d a e`):
  - `2^e` is the least common period of wheels `0` to `a`;
  - wheel `a` is white at every tick;
  - wheel `a + 1` flips after `2^e` ticks, so the clock doubles there.
- `b` is the next wheel after `a` that is white at every tick, and `c` the next after `b` (`NextWhite`).
- The *stretches* are the wheels from `a` to `b`, and from `b` to `c`.

**The hypothesis.** `DLMinusOne` says that at every first loss of every pointed recurrent strip, every tick `s` has a closed run with both white ends between `a` and `c` (`Catch d a c s`). In Lean:

```lean
def DLMinusOne : Prop := ∀ (d : Nat → Column), Recurrence d → d 0 0 = true →
  PrefixClocks d → ∀ a e b c, FirstLoss d a e → NextWhite d a b →
    NextWhite d b c → ∀ s, Catch d a c s
```

A closed run cannot pass over the white wheel `b`, since its black cells are black at tick `s` and `b` is white there (`catch_split`). So `DLMinusOne` says exactly this: a tick that the first stretch misses is caught in the second stretch, at the same tick.

**The theorems.**
- `Rule30Submission.lInfinity_of_windows`. Suppose that on every pointed recurrent strip, beyond every depth, there are wheels `a ≤ c` such that every tick has a closed run between them. Then `LInfinity`. It uses no axioms.
- `Rule30Submission.lInfinity_of_dlMinusOne : DLMinusOne → LInfinity`.
- `Rule30Submission.every_k_of_dlMinusOne : DLMinusOne → ∀ k, ∃ age, TargetAt k age`.

`LInfinity` says that the row of every tick of every pointed recurrent strip has closed runs starting at arbitrarily large depths. `TargetAt k age` is the kit's target for `k` inverse ticks beside the white wall, with two clauses. Every `k`-tick predecessor of an aged nonzero finite row is finite, with its last black cell exactly `k` cells inside the row's edge. And every history at cell 1 is realised by some predecessor. In the proof the age is the kit's: `W − 1 + 2^W`, with `W` the least width of capacity `k`.

## 2. Where it sits

| Link | Where |
|---|---|
| `CAP` gives `TargetAt k` for every `k` | the kit's `Rule30EveryKInverse`, our entry R30-20261119-ccc65f |
| `LInfinity` gives `CAP` | our entry R30-20261120-eb2bcc |
| `DLMinusOne` gives `LInfinity` | this entry |

`LInfinity` asks something of every tick of every infinite strip, at every depth. `DLMinusOne` asks it only of two stretches at a time, the two after each first clock loss. Each stretch starts at a white wheel and is fed by the column just before it, so whether it holds at a given first loss is a finite computation from that column, following both branches where the strip forks at `b`. The inverse-tick statement for every `k` now rests in Lean on this local statement alone.

## 3. Exploration

**The single cell's first losses.** Its rows from age 1,200 on, at width 450, are the 16 phases of one cycle of the band map. Here are the wheels that are white in every phase, and for each stretch between two of them, the number of phases with a closed run wholly inside it:

```wl
f[y_Integer] := BitXor[BitShiftRight[y, 1], BitOr[y, BitShiftLeft[y, 1]]];
step[w_Integer][v_Integer] := Mod[BitXor[BitShiftLeft[v, 2], BitOr[BitShiftLeft[v, 1], v]], 2^w];
band[w_Integer, y_Integer] := FromDigits[Reverse[Take[IntegerDigits[y, 2], w]], 2];
period[w_Integer, v_Integer] := SelectFirst[2^Range[0, 12], Nest[step[w], v, #] == v &, None];
rows = NestList[f, 1, 1500];
grid = Reverse[IntegerDigits[#, 2, 450]] & /@ With[{v = band[450, rows[[-1]]]}, NestList[step[450], v, period[450, v] - 1]];
whites = Select[Range[0, 449], AllTrue[grid[[All, # + 1]], # == 0 &] &];
inside[row_List, a_Integer, b_Integer] := Module[{pos = 0, ok = False, seg = row[[a + 1 ;; b + 1]]},
   Do[If[First[r] == 1 && Mod[Length[r], 3] == 1 && pos > 0 && pos + Length[r] < Length[seg], ok = True]; pos += Length[r], {r, Split[seg]}]; ok];
{whites, Table[{whites[[i]], whites[[i + 1]], Count[grid, r_ /; inside[r, whites[[i]], whites[[i + 1]]]]}, {i, 1, Length[whites] - 1}]}
```

The white wheels at 2, 7, 28 and 399 are all first losses: the clock doubles from 1 to 2, 4, 8 and 16 there. The next white wheel after 399 is 53,207, beyond this width. In each of the first three, the first stretch alone catches all 16 phases. That is the strict form of the lemma, at the single cell's first three doublings.

**A source that needs the second stretch.** A stretch can be computed from the column just before its white wheel, its *source*, without the strip it lies on. If the source has an odd number of black ticks in its period, the clock doubles. The next wheel is the source's running XOR, the one after is black, and each later wheel is the one periodic solution of the wheel rule, until a wheel is white again. Here is the source `00001` of period 5. The return to white, and the ticks of the first stretch that have no closed run:

```wl
child[a_List, b_List] := Module[{q = Length[a], t, c = ConstantArray[0, Length[a]]},
   t = First[FirstPosition[b, 1]] - 1;
   c[[Mod[t + 1, q] + 1]] = 1 - a[[t + 1]];
   Do[t = Mod[t + 1, q]; c[[Mod[t + 1, q] + 1]] = BitXor[a[[t + 1]], BitOr[b[[t + 1]], c[[t + 1]]]], {q - 1}]; c];
stretch[src_List, cap_Integer] := Module[{q = 2 Length[src], first, ws},
   first = Most[FoldList[BitXor, 0, PadRight[src, q, src]]];
   ws = {ConstantArray[0, q], first, ConstantArray[1, q]};
   While[Length[ws] <= cap && Total[Last[ws]] > 0, AppendTo[ws, child[ws[[-2]], ws[[-1]]]]];
   ws];
firstCatch[ws_List, t_Integer] := Module[{col = ws[[All, Mod[t, Length[First[ws]]] + 1]], run = 0, out = Missing[]},
   Do[If[col[[j]] == 1, run++, If[Mod[run, 3] == 1 && run > 0, out = j - 1; Break[]]; run = 0], {j, 2, Length[col]}]; out];
s1 = stretch[{0, 0, 0, 0, 1}, 400];
{Length[s1] - 1, Select[Range[0, 9], MissingQ[firstCatch[s1, #]] &]}
```

White returns at wheel 23, and ticks 1 and 9 of its period 10 have no closed run before it. The source of the next stretch is wheel 22, with an odd number of black ticks, so the clock doubles again, to 20. On that clock the two missed ticks are 1, 9, 11 and 19. Here are the period of the next stretch, its source's weight, the wheel where each of those four ticks is first caught, and whether all 20 ticks are caught:

```wl
s2 = stretch[s1[[-2]], 60];
{Length[First[s2]], Total[s1[[-2]]], Table[{t, firstCatch[s2, t]}, {t, {1, 9, 11, 19}}], AllTrue[Range[0, 19], ! MissingQ[firstCatch[s2, #]] &]}
```

The second stretch catches every tick that the first missed. A source of period 5 cannot feed a first loss on a pointed recurrent strip, since there the clocks are powers of two. So this is not a counterexample to the strict form at doublings. It shows what the relaxation buys: it does not rest on the strict form, which fails here for this standalone source, and the next stretch catches the missed ticks. In our record, every odd source of least period 1 to 16 (4,419 classes) is caught within its own first stretch, except `00001`, which needs the second.

The two stretches of `00001`, each tick a row and each wheel a column, with the first closed run of each tick in orange:

```wl
mark[ws_List] := Module[{g = Transpose[ws]},
   Table[Module[{col = g[[t]], run = 0, done = False, out = g[[t]]},
     Do[If[! done, If[col[[j]] == 1, run++, If[Mod[run, 3] == 1 && run > 0, out[[j - run ;; j - 1]] = 2; done = True]; run = 0]], {j, 2, Length[col]}]; out], {t, Length[g]}]];
GraphicsRow[{ArrayPlot[mark[s1], ColorRules -> {0 -> White, 1 -> Black, 2 -> Orange}, Frame -> False],
   ArrayPlot[mark[Take[s2, 30]], ColorRules -> {0 -> White, 1 -> Black, 2 -> Orange}, Frame -> False]}, ImageSize -> 520]
```

## 4. The proof

1. **First losses come past every depth** (`unbounded_first_losses`). Through any wheel the least common period is a power of two (`dyadic_prefix_clock`). That clock is lost after at most `4^p + 1` wheels, first just after a wheel white at every tick, where the next wheel flips (`first_clock_loss`).
2. **Each white wheel has a next one** (`exists_next_white`). On a pointed recurrent strip, white wheels come past every depth (`unbounded_anchors`). The least one beyond `a` is the next.
3. **The window theorem** (`lInfinity_of_windows`). For a depth `lo` and a tick `s`, take a window starting beyond `lo` that catches every tick. Its closed run at tick `s` starts beyond `lo`. That is `LInfinity`. The window may depend on the strip and on `lo`, but not on `s`.
4. **The relaxed lemma's windows** (`lInfinity_of_dlMinusOne`). The window is `[a, c]`, from a first loss beyond `lo` to the white wheel after next. `DLMinusOne` makes it catch every tick.
5. **Every `k`** (`every_k_of_dlMinusOne`). Compose with our entry's `cap_of_unbounded_resets` and the kit's `conditional_every_k`.

## 5. The open hypothesis

`DLMinusOne` is not proved. What is known about it:
- **Its strict form,** the first stretch alone, holds by computation outside Lean in three families:
  - every source of power-of-two period up to 32;
  - every source with exactly five black or five white ticks in its period, at every power-of-two period;
  - every first loss on every pointed recurrent strip through clock 16.

  So `DLMinusOne` holds at every first loss of clock at most 32.
- **The counts look like chance.** In a measurement in our record, over every odd source of periods 2 to 30, the share of ticks still uncaught at wheel `x` falls like `1.36 κ^x`. Here `κ = 0.8478` is the real root of `4κ³ − 2κ² − 1 = 0`, and the share does not depend on the period. That is a measurement, not a bound.
- **Busy sources are open.** Beyond period 32, sources with at least seven black and seven white ticks in their period are not settled.

## 6. Prior art and credit

- **The kit.**
  - `Rule30LeftAntiPeriod` (Quint and Gemini) has the per-wheel criterion: after a wheel white at every tick, the next wheel is periodic or antiperiodic at the same period (`D_period_or_antiperiodic`). Rowland (2006) and NKS give the doubling rule for the single cell. The criterion here, assembled for every pointed recurrent strip, is `first_clock_loss`.
  - The three every-k modules and our compactness modules are carried as in R30-20261120-eb2bcc, at kit commit `3f32e1a` and our commit `ab2c0fd`.
  - The left-edge recurrence is in `Rule30AgedLeftDiagonals` (Lowry with OpenAI Codex), and the encoding behind the clocks in `Rule30LeftUnbounded` (AIOvernight, with OpenAI Codex and Claude).
- **The relaxation is ours.** The doubling lemma at first clock losses, the window form of the implication, and the ladder of relaxations are written in our record ([every-k-chain.md](https://github.com/ghywel/rule30reset/blob/a27d0ad/research/m29/every-k-chain.md), section 3.5), where they were proved by hand and read independently. The [Lean module](https://github.com/ghywel/rule30reset/blob/a27d0ad/research/m29/Rule30RelaxedWindows.lean) is carried here with one doc comment reworded.
- **The constant** `κ` is in Wolfram (1986), p. 151, from C. and R. Feynman.
- **Novelty.** We read the portal's list of 387 entries and the kit's 15 open pull requests at 21:04 UTC on 20 November. None has a reset condition at period doublings that gives `LInfinity`, `CAP` or the target for every `k`, and none has the window theorem. The nearest entries are our own two above.

## 7. What is not proved

- `DLMinusOne` is not proved, and so neither are `LInfinity` and `CAP`. Both theorems are conditional; the window theorem is not.
- The strict form is computed outside Lean, and only in the families of section 5.
- The theorem is about the zero-boundary left half beside a fixed white wall. It says nothing about the centre column's period, and it does not decide `Q01`.

## The formal proof

The module is core Lean. It imports the kit's `Rule30ZeroBoundary`, `Rule30UniversalLeftSide`, `Rule30AgedLeftDiagonals` and `Rule30LeftUnbounded`, all present at the verifier's kit revision. Each part has its own namespace:
- the kit's three every-k modules, as `Rule30Submission.Rule30EveryKStatement`, `Rule30Submission.Rule30EveryKCascade` and `Rule30Submission.Rule30EveryKInverse`;
- two returns along a strip (`Rule30ThreePhaseReturn`, `Rule30TwoPhaseRise`);
- rooted white returns (`Rule30RootedWhiteReturns`);
- pointed recurrent strips (`Rule30RecurrentStrip`);
- the compactness argument (`Rule30ResetCompactness`);
- the relaxed windows (`Rule30RelaxedWindows`).

The three headlines are in `Rule30Submission`.

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
# The relaxed doubling lemma gives closed runs at every depth, and so every k

One file. First the kit's three every-k modules (`Rule30EveryKStatement`, `Rule30EveryKCascade`,
`Rule30EveryKInverse`), which the verifier's kit revision does not have, as they stand at kit commit 3f32e1a with
the module-system lines removed and their namespaces moved inside `Rule30Submission`. Then five modules of ours: two
returns along a strip, rooted white returns, pointed recurrent strips, the compactness argument, and the relaxed
windows. The headlines are in `Rule30Submission` at the end.
-/

/-!
# Inverse ticks for every k: the statement

The kit numbers physical cells from the white wall, with cell 1 beside it.
In a band, bit 0 is the last black cell, and bit j is j cells towards the wall.
The band and the integer encoding of a physical row therefore read in opposite
directions. This module states the target and its hypothesis; `Rule30EveryKInverse` proves the implication.
-/


open Ruliology.CellularAutomata
namespace Rule30Submission.Rule30EveryKStatement

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

end Rule30Submission.Rule30EveryKStatement

/-!
# Scheduled inverse layers at a finite Rule 30 edge

Troy Lowry's Rule30PrizeKit PR #60 gives the reset-word and scheduled-cascade
argument. Here the driver is the preceding phase of an odd edge cycle and the
cut is the one computed by Rule30EveryKStatement.firstReset.
-/


namespace Rule30Submission.Rule30EveryKCascade

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

end Rule30Submission.Rule30EveryKCascade

/-!
# The conditional inverse-tick theorem at a uniform age

Attach the minimum over edge cycles to the physical cascade and to
finite rows at a fixed white wall. All widths and tick counts are natural numbers.
-/


namespace Rule30Submission.Rule30EveryKInverse

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

end Rule30Submission.Rule30EveryKInverse

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
open Rule30Submission
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

/-! Theorem C′ on pointed recurrent strips. The open reset hypothesis is confined
to a first clock loss and exactly the two white intervals starting there. -/
namespace Rule30RelaxedWindows

open Ruliology.CellularAutomata
open Rule30AgedLeftDiagonals Rule30EveryKStatement
open Rule30RecurrentStrip (Clock Reset dyadic_prefix_clock)
open Rule30RootedWhiteReturns (Column first_clock_loss unbounded_anchors)
open Rule30ResetCompactness (LInfinity cap_of_unbounded_resets)

abbrev PrefixClocks (d : Nat → Column) := ∀ m, ∃ p, 0 < p ∧ Clock d m p
def White (d : Nat → Column) (a : Nat) := ∀ t, d a t = false

/-- The least prefix clock is p = 2^e through a. The next column flips at p,
so a + 1 is the first wheel at which that clock fails. -/
structure FirstLoss (d : Nat → Column) (a e : Nat) : Prop where
  clock : Clock d a (2^e)
  least : ∀ q, 0 < q → Clock d a q → 2^e ≤ q
  white : White d a
  flip : ∀ t, d (a+1) (t+2^e) = !(d (a+1) t)

def NextWhite (d : Nat → Column) (a b : Nat) :=
  a < b ∧ White d b ∧ ∀ i, a < i → i < b → ¬ White d i

/-- Both ends of the closed run belong to the window at the same tick s. -/
def Catch (d : Nat → Column) (a c s : Nat) :=
  ∃ j n, a ≤ j ∧ j+1+n ≤ c ∧ Reset (fun i => d i s) j n

/-- A white middle wheel cannot be strictly inside the black run. Thus a
catch in the combined window occurs wholly in one of its two stretches. -/
theorem catch_split {d : Nat → Column} {a b c s : Nat} (hab : a ≤ b) (hbc : b ≤ c)
    (white : d b s = false) : Catch d a c s ↔ Catch d a b s ∨ Catch d b c s := by
  constructor
  · rintro ⟨j, n, ha, hc, reset⟩
    by_cases left : j+1+n ≤ b
    · exact Or.inl ⟨j, n, ha, left, reset⟩
    by_cases right : b ≤ j
    · exact Or.inr ⟨j, n, right, hc, reset⟩
    have black := reset.2.2.1 (b-(j+1)) (by omega)
    rw [show j+1+(b-(j+1)) = b by omega] at black
    exact absurd (white.symm.trans black) (by decide)
  · rintro (⟨j, n, ha, hb, reset⟩ | ⟨j, n, hb, hc, reset⟩)
    · exact ⟨j, n, ha, Nat.le_trans hb hbc, reset⟩
    · exact ⟨j, n, Nat.le_trans hab hb, hc, reset⟩

/-- The first relaxation of the doubling lemma, in its rooted strip form. -/
def DLMinusOne : Prop := ∀ (d : Nat → Column), Recurrence d → d 0 0 = true →
  PrefixClocks d → ∀ a e b c, FirstLoss d a e → NextWhite d a b →
    NextWhite d b c → ∀ s, Catch d a c s

theorem unbounded_first_losses {d : Nat → Column} (hd : Recurrence d)
    (h0 : d 0 0 = true) (clocks : PrefixClocks d) (lo : Nat) :
    ∃ a e, lo ≤ a ∧ FirstLoss d a e := by
  have recurrent : ∀ i, ∃ p, 0 < p ∧ PeriodFrom (d i) 0 p := by
    intro i
    obtain ⟨p, hp, hclock⟩ := clocks i
    exact ⟨p, hp, hclock i (by omega)⟩
  obtain ⟨e, clock, least⟩ := dyadic_prefix_clock hd h0 recurrent (lo+1)
  obtain ⟨a, ha, _, clockA, white, flip⟩ :=
    first_clock_loss hd h0 recurrent (Nat.two_pow_pos e) (by omega : 1 ≤ lo+1) clock
  exact ⟨a, e, by omega, clockA,
    fun q hq hclock => least q hq (fun i hi => hclock i (by omega)), white, flip⟩

theorem exists_next_white {d : Nat → Column} (hd : Recurrence d)
    (h0 : d 0 0 = true) (clocks : PrefixClocks d) (a : Nat) :
    ∃ b, NextWhite d a b := by
  obtain ⟨b, hab, white, black⟩ := unbounded_anchors hd h0 clocks (a+1)
  clear black
  change White d b at white
  classical
  induction b using Nat.strongRecOn with
  | ind b ih =>
    by_cases earlier : ∃ i, a < i ∧ i < b ∧ White d i
    · obtain ⟨i, hai, hib, hi⟩ := earlier
      exact ih i hib hai hi
    · exact ⟨b, hab, white, fun i hai hib hi => earlier ⟨i, hai, hib, hi⟩⟩

/-- The window argument only uses unbounded starts and a catch in the
prescribed phase. Window choices can depend on the strip and the cutoff. -/
theorem lInfinity_of_windows
    (windows : ∀ (d : Nat → Column), Recurrence d → d 0 0 = true → PrefixClocks d →
      ∀ lo, ∃ a c, lo ≤ a ∧ ∀ s, Catch d a c s) : LInfinity := by
  intro d hd h0 clocks s lo
  obtain ⟨a, c, ha, catches⟩ := windows d hd h0 clocks lo
  obtain ⟨j, n, hj, _, reset⟩ := catches s
  exact ⟨j, n, Nat.le_trans ha hj, reset⟩

theorem lInfinity_of_dlMinusOne (h : DLMinusOne) : LInfinity := by
  apply lInfinity_of_windows
  intro d hd h0 clocks lo
  obtain ⟨a, e, ha, loss⟩ := unbounded_first_losses hd h0 clocks lo
  obtain ⟨b, hab⟩ := exists_next_white hd h0 clocks a
  obtain ⟨c, hbc⟩ := exists_next_white hd h0 clocks b
  exact ⟨a, c, ha, h d hd h0 clocks a e b c loss hab hbc⟩

/-- The kit's explicit settling-age witness for the physical every-k target. -/
theorem everyK_of_dlMinusOne (h : DLMinusOne) :
    EveryK (fun k => settlingBound (widthFor (cap_of_unbounded_resets
      (lInfinity_of_dlMinusOne h)) k)) :=
  Rule30EveryKInverse.conditional_every_k _

end Rule30RelaxedWindows

namespace Rule30Submission

open Ruliology.CellularAutomata Rule30EveryKStatement Rule30ResetCompactness Rule30RelaxedWindows

/-- Any windows of wheels, with starts beyond every depth on each pointed recurrent strip, that hold a closed run in
every prescribed phase give closed runs at arbitrarily large depths in every phase. -/
theorem lInfinity_of_windows :
    (∀ (d : Nat → Nat → Bool), Rule30AgedLeftDiagonals.Recurrence d → d 0 0 = true → PrefixClocks d →
      ∀ lo, ∃ a c, lo ≤ a ∧ ∀ s, Catch d a c s) → LInfinity :=
  Rule30RelaxedWindows.lInfinity_of_windows

/-- The relaxed doubling lemma, a statement about the two white intervals after each first clock loss, gives closed
runs at arbitrarily large depths in every prescribed phase of every pointed recurrent strip. -/
theorem lInfinity_of_dlMinusOne : DLMinusOne → LInfinity :=
  Rule30RelaxedWindows.lInfinity_of_dlMinusOne

/-- With the compactness theorem and the conditional every-k theorem, the same hypothesis gives the inverse-tick
target for every k. -/
theorem every_k_of_dlMinusOne : DLMinusOne → ∀ k, ∃ age, TargetAt k age :=
  fun h k => ⟨_, Rule30RelaxedWindows.everyK_of_dlMinusOne h k⟩

end Rule30Submission
", "ProjectDir" -> $Rule30PrizeKit]
```

## The formal checks

The three headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.lInfinity_of_windows", "Rule30Submission.lInfinity_of_dlMinusOne", "Rule30Submission.every_k_of_dlMinusOne"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms. The window theorem needs none:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The hypothesis and a window's catch, as Lean holds their definitions, and the lemma that splits a catch at the middle white wheel:

```wl
{rule30Submission["Rule30RelaxedWindows.DLMinusOne"]["TermForm"], rule30Submission["Rule30RelaxedWindows.Catch"]["TermForm"], rule30Submission["Rule30RelaxedWindows.catch_split"]["TypeForm"]}
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.lInfinity_of_dlMinusOne"]["KernelCheck"]
```
