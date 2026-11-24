# Lowry’s event in gate coordinates

A kick is a black observation of column 1 at a white-centre time. An event is Lowry’s spatial word
`0101001` at columns −4 through +2. One sample is two physical ticks. During five alternating
centre observations the word is present exactly when columns 1 and 2 read white, black. This
identification and the original three return rules are Troy Lowry’s. [Kit PR #376](https://github.com/WolframInstitute/Rule30PrizeKit/pull/376)

**The comparison.** GE2 alone implies Lowry’s ten-then-four rule. It admits a fourteen-tick return
followed by four, which violates his other two rules. Inside the gate trap, event gaps are only four
or six ticks and they recover the kick sequence. Outside the trap, the physical return rule excludes
an infinite family of kick words that GE2 accepts.

## Reading the event from the next kick

Let a, b, c be the first three right cells at a white-centre tick with a = 0. Two ticks later column
1 equals the complement of b OR c. If that next gate is black, b was white. If both gate samples are
white, the two-step rule makes the new column 2 the complement of the old one. Reading back from
the first black gate now gives the dictionary for any finite distance d to that kick, counting the
current sample as distance zero.

> An event occurs exactly when d is positive and even.

This is kernel-checked for any Rule 30 right half under the necessary finite stretch of centre
alternation. A separate theorem identifies the literal word on the official orbit, including the
five centre observations used to recognise it. In GE2, kick gaps are between 2 and 5. Four future
samples suffice to decode any white gate. [Gate dictionary and trapped return code](Rule30EventGate.lean)

## What GE2 alone says

The nine consecutive kick-gap pairs in GE2 are 22, 24, 25, 33, 35, 45, 52, 53 and 55. The offsets
of events strictly inside gaps 2, 3, 4 and 5 are respectively ∅, {1}, {2} and {1,3}. Thus four
event states suffice. The table is the complete first-return graph for the nine-pair language, at
every positive length, in **samples**. Letters in a target set denote alternative destinations.
[Kit gap language](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30PeriodTwoWidth13.lean) · [Exact return theorem](Rule30GE2Phase.lean)

| Starting event | Return length | Ending event |
|---|---:|---|
| A, gap 3 at +1 | 3 | A or C |
| B, gap 4 at +2 | 3 | C |
| C, gap 5 at +1 | 2 | D |
| D, gap 5 at +3 | 3 | A or C |
| D | odd ≥5 | C |
| D | even ≥6 | B |

Consecutive returns are obtained by joining arrows at the same event. In physical ticks, a ten
always has a four next. A return of eight is impossible here. An even sample gap of at least six
forces a return of three samples. An odd sample gap of at least seven instead forces two, in
conflict with Lowry’s physical rules. A path that continues with gap 2 forever can stop having
events. Claims about unbounded occurrence need a further hypothesis.

**Phase recurrence.** The only even-length arrows are C→D and D→B. Three consecutive even returns
are impossible. Any four successive events therefore visit both white phases modulo four physical
ticks. An event-free infinite tail must eventually remain in the two-sample kick cycle. An
aperiodic kick stream rules this out. Combined with the kit’s late GE2 and kick aperiodicity on
a hypothetical alternating singleton tail, this recovers Lowry’s arbitrarily late visits in both
phases and bounds the number of events needed to see both. The Lean graph theorem uses the kit’s
actual nine-pair predicate. The application to the singleton uses its existing tail theorems.
[Event graph and phase bound](Rule30GE2Phase.lean) · [Lowry’s original phase theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30EventReturns.lean)

## A physical exclusion outside the trap

Take a kick gap a ≥ 3, then k ≥ 2 consecutive gaps of 2, then an odd gap b ≥ 3. The last event in
the a-gap is two samples before its ending kick. The 2-gaps hold no event. The first event in the
b-gap is one sample after its starting kick. The resulting first return is 3 + 2k samples, odd and
at least seven, which Lowry’s parity rule excludes.

The conclusion holds for **every driven right half** during the indicated finite alternating window.
It needs neither finite support nor prior trap entry. A separate proof on the official singleton
uses Lowry’s literal word theorem directly. Within the nine-pair GE2 language the excluded factors
are exactly **5, followed by k copies of 2, followed by 5**, for k ≥ 2. Every abstract violation of
the three return rules traverses one of these factors, by the first-return table. Removing them
makes all three rules hold on completed returns. This still leaves physical realisability open for
the other allowed words. [Gate-gap exclusion](Rule30EventKickExclusion.lean) · [Lowry’s local parity certificate on arbitrary right halves](Rule30LocalEventParity.lean)

Three full-line finite controls used a white background, centre white at tick zero, and ordinary Rule
30 at every site. Times in the last column are white-phase **sample indices**. The model specifies
the finite initial row and the independent scalar replay reads the seven cells of the spatial word.

| Gate gaps | Alternating centre through tick | Physical result |
|---|---:|---|
| 5,2,5 | 28 | Finite row, events at 1, 3, 8, 10. One intervening 2 is possible. |
| 5,2,2,5 | 32 | UNSAT, checked independently by `cake_lpr` and `lrat-check`. GE2 would place events at 1, 3, 10, 12. |
| 5,2,2,4,5 | 40 | Finite row, events at 1, 3, 11, 14, 16. The first three occupy the same white phase. |

The positive rows make the threshold of two intervening gaps sharp and show that three consecutive
events can share a phase in a physical finite window. The uniform exclusion itself only needs the
centre alternation in its theorem statement. [Finite-cone encoder and scalar replay](finite_controls.py)

## What changes on K47’s trap cores

Start at the event one sample after a kick. The next **kick gap 3 gives event gap 3**, and **kick
gap 5 gives event gaps 2,3**. Every block ends with a 3. An event reached after a 3 starts the next
block, so on a two-sided trapped trace one recovers the black gate at i exactly when there is an event
at i+1 and none at i−1. The kit guarantees a kick in every five samples after trap entry. Thus this
is a reversible recoding of the trapped time traces, with the same entropy per physical time unit.
It transfers K47’s forbidden factors to events at every width. [Trap recoding](Rule30EventGate.lean) · [Local inverse on every trapped physical half](Rule30EventInverse.lean) · [Earlier five-sample coverage](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30GateTrapWords.lean)

| K47 core width | Core windows | Event windows | First returns in ticks | Ordered pairs in ticks |
|---|---:|---:|---|---|
| 16 | 760 | 303 | 4, 6 | (4,6), (6,4), (6,6) |
| 18 | 2,110 | 840 | 4, 6 | same |
| 34 | 3,535,330 | 1,394,593 | 4, 6 | same |

At every width the direct search starts from every marker window and propagates **only unmarked**
intermediate windows until that set is empty. Each further return starts from the actual preceding
landing set. Both the pinned M78 cores and cores rebuilt from the kit’s 829 entries give the same
output. Edges use K47’s two independent successive boundary observations. Every physical trapped
orbit follows edges here, while physical realisation of a projected path is a separate question.

Longer event words distinguish the widths. Write c(3)=3 and c(5)=23 in double-step units. Prefix
c(w) by a single 3 to synchronise it with a kick. Both one-gap deletions of each newly forbidden
event word below remain readable in the indicated core, so each is a minimal forbidden factor there.
[Direct core check](core_events.py) · [K47’s gate ladder](../m9/claudeCloud_m9_lift.py)

| Gate factor w | Synchronized event factor | Direct result |
|---|---|---|
| 33, 3553 | 333, 3323233 | Both forbidden at width 16 |
| 3535353 | 33233233233 | Read at 16, forbidden at 18 |
| A 3 followed by six copies of 55553 | 3 followed by c(w), 56 event gaps | Read at 18, forbidden at 34 |

On the trapped class all three of Lowry’s rules hold already at width 16. The two long-gap
implications have empty premises there. His physical theorem also constrains rows outside this
class. The [finite-left follow-up](finite-left.md) finds the bracket’s first cut at 15 white samples and its first dead end at 14. Using the full six-cell onset strip gives 5, 11 and 22 survivors at the three published kit horizons.

## Replay

From the repository root with Lean 4.35 and Lake on the path, the same kit at `40017e8`, Python
with NumPy, CaDiCaL, cake_lpr and lrat-check, run the following commands.

```sh
research/k50_2/check-lean.sh
python3 research/k50_2/ge2_events.py
python3 research/k50_2/core_events.py
evidence=$(mktemp -d)
python3 research/k50_2/finite_controls.py "$evidence"
```

The raw core and GE2 reports, two full-line seed rows, three DIMACS cones and the checked LRAT
proof are in `share-scratch/gptM5/K50.2/R67-evidence.tar.gz`, SHA-256
`03201272a8bc11349b42eb3fb63317e8425a346ebd5024f41509369ad57f2540`.
