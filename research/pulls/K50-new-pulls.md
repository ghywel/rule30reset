# Four new pulls from the kit (K50, 21 November 2026)

*Written by claudeCloud after reading KIT.md and KIT-INDEX.md whole at kit `40017e8`, at the owner's word: derive new
pulls, with key attention to recent third-party submissions. Each pull names the outside work it stands on, what it
would teach, and a first test with predictions and a kill. Nothing here has been run. Status words as in METHOD §4.*

## K50.1 · RD: does every finite right half end in the gate trap or in a periodic gate?

**Stands on.** AIOvernight's `RD` (`Rule30PeriodTwoWidth13`, 9 November): every finitely supported right half driven
by the alternating column enters the kit's gate trap at some odd time, or has an eventually periodic gate. The kit
proves RD ∧ Q01Gap ⇒ CQ01, and says: "The finiteness of the right half is used only in `RD`". Templates for a proof:
Elbaz's `Rule30EtherSingleCell` (period 4: one black cell, and every half white on 1..30, enters); Lowry's
`Rule30WhiteTailErosion`; Villafuerte's `Rule30CoupledEmptyRight`. The warning: Hallee's 15-trap, which refuted the
same kind of statement at period 3 (`Rule30EtherThreeNotAbsorption`).

**Why now.** RD is the one place where the right half's finiteness enters period 2, and no pull has touched it.
Placego measured 1,442 of 1,500 random right halves in the trap by tick 6,001, median entry 29 (L1612, MEASURED). The
other 58 were not followed. R5 (K38) is the same question at period 3, where every cut entered, slowly.

**What it would teach.**
- *True and proved:* CQ01 follows from the left statement alone. The web of §3 loses a hypothesis.
- *False:* some finite right half lives for ever outside the trap with an aperiodic gate. That is a new closed set,
  as the 15-trap was, and period 2 needs a weaker entry statement before anyone leans on RD.

**First test** (exact; the cloud host or the Intel).
1. The 58: regenerate L1612's sample, follow every half that has not entered to 10^6 ticks. Trap, periodic gate, or
   neither.
2. The closed sets: the windows of W = 16 to 24 columns with arbitrarily long histories under the alternating double
   step, the outer column free (the method of K47). Its parts: the trap's lifts, the ether family, anything else.
3. Cuts of the alternating ether at N columns, as K38 did for period 3: the speed of departure, and the wait.

**Predictions.** (0.6) Each of the 58 enters the trap or shows a periodic gate. (0.5) At 20 columns there are two
closed families and no third. (0.55) The wait after departure is bounded in the support, unlike R5's.

**Kill.** A third closed set that a finite half can enter: RD is refuted, and the weaker form is written down. A
wait with no bound and the look of chance: RD is "an erratic orbit meets a set", and it is parked.

**Record searched.** KIT-INDEX rows `Rule30PeriodTwoWidth13`, `Rule30GateTrap`, `Rule30EtherSingleCell`,
`Rule30WhiteTailErosion`, `Rule30CoupledEmptyRight`, `Rule30EtherThreeNotAbsorption`; the definition of `RD` at the
source; placego L1612. Still to search before any run: placego's ledger for "RD" and "right half" with "enters".

## K50.2 · Lowry's events, read in gate coordinates

**Stands on.** Lowry's `Rule30EventReturns` (20 November, kit #376). Under an alternating centre the spatial word
0101001 at sites −4 to +2 returns after a multiple of four ticks, six ticks, or ten ticks. A gap of twelve or more
forces a six next, and a ten forces a four. On an alternating tail of the single seed the word comes arbitrarily
late in both white phases modulo four. With it, the same day: `Rule30SourceArrivals`, `Rule30EdgeSourcePulse`.

**The connection.** Six and ten ticks are the gate trap's gaps 3 and 5; multiples of four are the ether family's.
The four left cells of his word are the first four depths of Theta, which are affine in at most three free bits
(`Rule30LinearCharts`), and the free bits are the complement of the gate. The two right cells are in the gate's
window. So his event is a function of a short piece of the gate word. Either his three rules follow from GE2 and
the trap's lifts, or they see something our ladder does not.

**What it would teach.** Whether the newest outside line on period 2 lies inside M9's ladder. If inside, the lifts
at 18 to 34 columns give stronger rules on his events at once. If outside, there is a constraint the lifts miss.

**First test** (exact, small). The return grammar of the event from (a) GE2 alone, (b) the 16-, 18- and 34-column
cores of K47. Compare with his three rules.

**Predictions.** (0.75) His rules follow from GE2 with the 18-column lift. (0.6) The lifts give at least one rule on
his events that his module does not have.

**Kill.** None needed: one block decides.

**Record searched.** KIT §3 and the row; our ledgers and placego's for "0101001" (placego's hits are other words).

## K50.3 · One inverse theorem for every wall

**Stands on.** Hughes's `Rule30AgeEightInverse` and `Rule30AgeTwentyFourInverse` (11 November); Lowry's
`Rule30WallRecordAncestry` and `Rule30ResetSwap` (19 November); Villafuerte's bound that the every-k target needs
age at least 2k (#370); AIOvernight's UBE (`Rule30BlackPhaseEscape`, 9 November), which gets Problem 1 from a
statement about left halves driven by any periodic column with a black phase. Ours: the chain S2, S4, S5 for (T),
all beside the fixed white wall.

**The question.** The chain works at the far edge: resets in the edge band fix the exact edge of every predecessor
(`scheduled_edge`, "infinite support allowed"). The wall is at the other end. Does every link hold beside a wall
that follows *any* column? Then the every-k theorem is about left halves as such: about the seed's own diagram and
about UBE's frame, not only Q01's.

**What it would teach.** Whether our one chain is a tool for period 2 or for Problem 1. If the wall does not
matter, the cases already proved (k = 1 and 2 by Hughes, k = 4 in S1) hold for every configuration with a leftmost
black cell, which is a general statement and may be a submission; and (DL⁻₁) becomes the single open lemma of a theorem about the whole
left side.

**First test.** Read the Lean of `Rule30EveryKCascade` and `Rule30EveryKInverse` for each use of the white wall.
Then, exact: the ages f(1) and f(2) beside walls that are black, alternating, 001 and 011, to width 14.

**Predictions.** (0.7) The exact-edge half of (T) does not use the wall. (0.5) "Every cell-1 history occurs" needs
restating for each wall and then holds. (0.6) The ages are 8 and 24 beside every wall tried.

**Kill.** An age that grows without bound with the wall's period.

**Misgiving.** It may be nearly in PRIOR-ART P10 (left-diagonal retrodiction) already. The record search is the
first step, before the reading.

## K50.4 · Every white triangle has one family tree

**Stands on.** Quint's `Rule30ZeroBoundaryStripeCascade` (30 October): going backward, all black comes only from
100 repeated, that from 011 repeated, that from 000101 repeated, with a split at stage 8 and period doublings
after. AIOvernight's `Rule30CenterCylinders` (9 November): a white centre time with gap g is the same thing as a
black run of length 2g − 1 in the row g ticks earlier.

**By hand** (checked for the first two stages). A black run in a row has one kind of predecessor, 100 repeated,
fixed from its right end leftward; and that has 011 repeated.

**So.** A white run of the centre is a black run in a row; k rows earlier it is a patch of the k-th pattern of the
cascade, two cells wider each row. Every white triangle in every picture of rule 30 carries this past. Quint has it
beside the wall, for stripe tails. I have not found it said of the whole diagram.

**What it would teach.** Whether long white runs can be exchanged for long patches of small spatial period a fixed
number of rows earlier. The kit has tools for patches (`Rule30SpatialPeriodLifting`, ring orbits, moving waves).
White runs of the centre are where the unconditional density bound is stuck at a logarithm.

**First test** (exact). The cascade to 40 stages: branches, periods, distinct factors by length. In the seed's
diagram to 10^5 rows, every white triangle of side 12 or more with its ancestors matched to the cascade. A picture
for the owner: triangles with their family trees, coloured by stage.

**Predictions.** (0.7) One ancestry through stage 7 in the whole diagram, as beside the wall. (0.5) After the split
the number of branches grows no faster than the period. (0.2) A bound on patch length follows that beats the
logarithm.

**Kill.** Branching near four for each row: then a triangle's past is generic, and nothing is gained.

**Misgiving.** Bounding patches in the bulk still needs a reason, and every reason in the kit lives at an edge. A
long shot for Problem 2; a sure thing as a picture and a dictionary.

## Considered and not proposed

- **The death deadline 2W** (Condrey's BWH and exact-width death bounds). 2W is where a fair coin's expected number
  of survivors falls to one: a statement that chance is never beaten. Coins.
- **Conjecture S** (AIOvernight): sharp, implies no period 2, and failed by every control. But
  `Rule30FreeMiddle` bars every local accounting, and M6 closed its neighbour.
- **Quint's primitive roots as a reduction.** Placego found 15 of 16 eight-bit windows primitive: no reduction.
- **`Rule30EdgeSourcePulse` as the handle R6 lacked.** It controls only the layer of logarithmic depth.
- **The aperiodic band for the limit strip.** It does not reach the centre, which reads wheels before they settle.
- **UBE head on.** As hard as Problem 1. K50.3 is its tractable corner.
