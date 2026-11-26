# Phase 2: five proposed pulls

*claudeCloud, 26 November 2026 (ledger K92), at the owner's request for "a short, diverse, new set of pulls". These
are proposals: none is in NOW.md's table until the owner says which to open. Each names its wall
([WALLS.md](../../WALLS.md)), answers the owner's question (does it move us towards a solution or partial solution
for a prize problem?), and says what a failure would prove.*

| | Pull | Wall | Kind of work | A yes gives | A no gives |
|---|---|---|---|---|---|
| **K92.1** | Is there a weight floor against real right halves? | W1, both sides | exact search, then a hand argument | no eventual period two, for every finite configuration | the first finite left half that alternates for ever beside some right half |
| **K92.2** | What share of rows passes k checks after its support, for every k? | W1, left side alone | algebra over GF(2), exact counts | the first rungs of the kit's ladder bound, whose whole is no eventual period two | correlated passes: where an immortal row would have to live |
| **K92.3** | Is there a deadline, linear in the support, for a finite right half to enter the trap or a lock? | W1, right side | exhaustive fates, then the far field | `RD`, half of the kit's split of period two | a finite right half with an aperiodic gate outside the trap for ever |
| **K92.4** | At what ages do the seed's marks set records? | W2 | one run on the seed; scouting, with a kill rule | a lead on Problem 1 at every period | nothing; parked after one block |
| **K92.5** | Which proofs from elsewhere have crossed a wall of our two kinds, and do their hypotheses hold here? | W1 and W2 | reading | a method to test against the controls | a list of methods that cannot work, each with the control that breaks it |

Three pulls go at W1 from three directions, because it is the one wall with an elementary statement, exact tools on
both sides, and a prize-problem partial directly behind it. One scouts W2. One reads. Nothing is proposed for
Problem 2 or Problem 3 alone, or at W3 and W4: I have no first step past those walls to offer. None of the three W1
questions is untouched: each section says who asked it before and what is different now.

## K92.1. A weight floor against real right halves

**The question.** Is there a bound H ≤ qA + d for every left half that starts at a kick and is served for H ticks by
some right half, where A is its number of black cells?

**Known.** The kit has the statement in a weaker language. A left half beside an alternating centre has wall readings
in G: white at the start, black at odd ticks, no two successive even ticks white. `MassFloor q d` says H ≤ qA + d on
every G word, and any such floor gives no eventual period two (`not_eventually_period_two_of_floor`, AIOvernight).
The sharp form 7A ≥ H + 4 is kernel-checked to H = 90 and fails at arbitrarily late H: Galindo's words, cut from
AIOvernight's eternal row with one black cell in seven (PRIOR-ART P1), reach H = 7A + 9. Whether some floor holds is
open. A mass bound in the 13-column language GE2 would do as well (`noSeed_GE2_of_massBoundFun`).

Our own earlier pull M6 (claudeM5, 17 November; M15, M21) asked whether floors are the densities of the sparsest
eternal rows. Yes in G, which was known. No in the trap's gap language: there the least weight has slope about 0.275
a tick to H = 180, every periodic row weighs 0.44 or more, and the cheapest words are cheap through transients. M6
closed with one reopening test, a run to H near 300 to see whether the minimisers' deficits stay bounded. Nobody has
tried to prove a floor, and nobody has measured one against real right halves: the census of gate words that some
right half reads is two days old (I246). K84 and K88 measured lifetimes against support, never against weight.

**New** (development probes, nothing registered before them:
[floor](data/claudeCloud-floor-probe.txt), [schedules](data/claudeCloud-schedules-probe.txt)).
- The one-in-seven row demands a kick every fourth reading. Real right halves read that for 28 to 31 readings, by
  phase, and no more. This is S18 seen from the left: no right half kicks once in four for ever. An 18-column strip
  reads it for all 53 readings listed, a 22-column strip for 30.
- Anchored at a kick, the least weight served by a real right half is well above the G line from H = 60:

  | H | 20 | 30 | 40 | 50 | 60 | 70 | 80 | 90 | 100 | 110 | 120 |
  |---|---|---|---|---|---|---|---|---|---|---|---|
  | least weight, real right halves | 5 | 7 | 8 | 10 | 14 | 18 | 21 | 22 | 26 | 29 | 31 |
  | the kit's line in G, ⌈(H + 4)/7⌉ | 4 | 5 | 7 | 8 | 10 | 11 | 12 | 14 | 15 | 17 | 18 |

  Exact to H = 86 by I246's census; beyond it, a 22-column strip (a superset) and a sample of real right halves (a
  subset) agree. The sparsest gates start 3, 4, 4, 4 and go on in 3s and 5s. From H = 60 the least weight climbs at
  about 0.28 a tick, which is M6's gap-language slope: once a right half is in the trap, the gap language is what
  it reads.
- The anchor matters. Periodic schedules with gaps 2, 3, 5 and 2,5 are read to the end of the census, and at their
  kicks their wests weigh 0.43H or more, as M6 found for periodic gap rows; at a white tick that is not a kick the
  ring of gate 2 weighs H/7. One tick earlier, at the black tick, the least weight is 8, 11, 13, 17, 20, 23, 26, 29,
  32, 36, 40 at depths 21 to 121.

So this pull is M6's question asked again where the demands are real, with a proof as its aim and not a floor row.

**Why it bears on a prize problem.** A floor gives L(B) ≤ qB + d: no finite left half alternates for ever beside any
right half, so no finite configuration has an eventually alternating centre. Kicks recur, because no column is
eventually constant, so the anchor costs nothing. That is Problem 1 for period two.

**First block.** Exact least weights to H near 300 by depth-first search over gate words on a strip, pruned by
weight, each minimiser replayed on the whole line: M6's reopening test, in the exact frame. The minimisers' grammar,
and why a sparse stretch must be paid for later; one conjecture with constants. Then the hard part: a charging
argument that pays each tick from a black cell, tested first against the controls (M10) and the kit's ranking
barriers.

**Kill rule.** If the least weight stops growing in step with H at any depth reached, the pull turns into the hunt
for an immortal finite left half. If it grows steadily and no charging rule survives the controls, park at W1 with
the table.

## K92.2. The k-th check past the support

**The question.** Over the rows of width at most 2n that pass every check their own cells decide, what share passes
the next k checks? Is it at most Cθᵏ with θ < 1, for every n?

**Known.** Inside the support the counts are exact fair-coin counts (`first_check_count`, `mean_ladder`). Past it the
kit has one theorem, ours: for two of any three consecutive n the first check passes a share between 1/40 and 39/40
(`first_check_balanced`), and its degree in the free bits is n or n − 1 (`check_degree`). On 26 November
Benboubakeur and others posted the second: at one width in every seven consecutive widths, more than 1/16 of the
first-check survivors fail the second check (portal R30-20261126-65dcb1, Lean Verified, outside the kit; we have
read its abstract only). Their companion entry says that one immortal row would bring up to 4,096 at every large
width of the same parity (R30-20261126-e2e0e2). The kit proves that a geometric bound on the survivors past the
support, for every n and every j, gives no eventual period two (`noSeed_of_geometric_ladder_bound`). Nothing covers
three checks, or k. The planted survivor differs from rule 30 in one top monomial of each check (M10), so any
argument must see that monomial.

**Why it bears on a prize problem.** The full bound is the kit's ladder hypothesis, and so period two. Its first
rungs are the first theorems on the far side of W1 that hold at every depth: all but a share Cθᵏ of the rows that
outlive their support fail within k further checks.

**First block.** Read both portal entries at the source, and how `first_check_balanced` is proved: does either
method carry from one check to the next? Exact joint tables of the first twelve checks past the support for n up to
24, in both phases and for the controls; the degree and bias of products of checks. A result for one more check is
one more term (METHOD §12): the aim is every k, or the mechanism. If their method already reaches every k, the pull
is to join it, with credit, and not to repeat it.

**Kill rule.** If the joint tables factor like fair coins and the first-check proof has no handle on a product of
two checks, park at W1 with the tables. If they do not factor, the correlated class is the next pull.

## K92.3. A deadline for finite right halves

**The question.** Let T(D) be the first tick by which every right half white beyond site D, beside an alternating
centre, has shown 48 clean readings (the trap) or entered a known lock. Is T(D) finite for every D, and does it grow
linearly?

**Known.** Period three has exactly this: entry by tick 3D + 170 beside 001 and 3D + 820 beside 011, with slope
three sharp (S16, S21). For period two every right half is in a closed set of 777 windows by white sample 35 (S18),
48 clean readings certify the trap (S15), and `RD` is equivalent to every finite half with an aperiodic gate showing
them (`dichotomy_iff_clean`). Two components of the 24-column window graph still allow an aperiodic gate (K50.1),
and one finite seed keeps the schedule Y for 470 readings (N21). No table by support exists.

**Why it bears on a prize problem.** `RD` with `Q01Gap` gives CQ01 (`CQ01_of_RD_of_Q01Gap`). `RD` alone is a named
open statement of the kit about every finite right half.

**First block.** The fate and entry tick of every right half with D up to about 24; the record holders at each D and
what they share with N21's seed; how the white far field ends a stay outside the trap; a fitted T(D). The right-hand
twin of `q01_width_le_52`. A half that reaches neither the trap nor a known lock by the horizon is recorded as
UNKNOWN and is the interesting case.

**Kill rule.** If T(D) grows faster than linearly, or a half survives every horizon tried, the pull becomes the
study of that half. If T(D) is linear and the far field gives no argument in two blocks, park at W1 with the table.

## K92.4. The seed's marks

**The question.** A mark is an age with l white cells immediately left of the centre, a black cell beyond them, and a
black centre l ticks later. Marks of unbounded width give Problem 1 (`problem1_of_marks`, Lowry). At what ages do
record marks, record first failures and record centre runs fall, and do those ages follow the left edge's clocks?

**Why it bears on a prize problem.** Honestly: only if a pattern appears. The left edge is the one place where
recurrence is proved (diagonal j repeats with period 2ʲ). A record law tied to those clocks would be the first lead
on carrying a proved recurrence into the bulk, which is all of W2. Finite data cannot prove anything here.

**First block.** One run of the seed to age 2²² or beyond: the record tables, and the record ages against powers of
two and against the white diagonals D2, D7, D28, D399.

**Kill rule.** If record widths track log₂ of the age and the ages show no arithmetic pattern, park at W2 after this
one block.

## K92.5. Borrowed tools

**The question.** Which proofs elsewhere have crossed a wall of the white-tail kind or the one-orbit kind, and which
of their hypotheses hold for rule 30?

**Three places to read.**
1. *Collatz-type results.* The wall readings conjugate the left half's map to the shift, so Q01 says that a closed
   invariant set of rows holds no natural number. Terras and Everett's density theorem is our free-bit count. What
   are the analogues of Korec, of Krasikov and Lagarias, and of Tao's almost-all theorem, and what replaces the
   affine structure they lean on?
2. *Rule 30's siblings.* The rules left ⊕ (centre·right + α·centre + β·right) are 120, 180, 210 and 30. For 210 the
   kit has both answers: the clock survives beside an empty left half, and no finite configuration has an
   alternating centre, through rule 90 (`Rule30Rule210Clock`). What holds for 120 and 180? Is a white-tail statement
   proved for any nonlinear rule by a method that is not a reduction to a linear one?
3. *One orbit.* Proofs of aperiodicity or normality for one explicit sequence: automatic and substitution sequences,
   renormalisation. Does any hypothesis fit the seed, whose left edge is dyadic?

**What comes back.** One table: the method, its hypotheses, which of them the kit proves for rule 30, and the control
that breaks it. Each row goes through the prior-art rules of METHOD, with the paper read in full.

**Kill rule.** Two blocks.

## How I would run them

The owner's aim (METHOD §3) is to turn orderly structures into general rules, not to widen a census. By that aim:

1. **K92.2 first.** It is algebra on exact laws, and a third party moved it on the day this was written.
2. **K92.3 second.** Its table is new, but the point is the mechanism by which the white far field ends a stay
   outside the trap, not the table.
3. **K92.1 third.** Its question is the oldest of the three, and its first block is a search.
4. **K92.5** is reading, for whoever is waiting on a run.
5. **K92.4** is one run with a yes or no, and the first to drop.

One worker of each model on each pull from the first block: one builds, one attacks. When a pull stops, its entry
goes into WALLS.md under its wall, with where it stopped and what would reopen it.
