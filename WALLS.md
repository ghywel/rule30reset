# WALLS

*The hard places. A wall is one missing statement that many lines of work have run into, usually under different
names. Phase 1's parked pulls are filed here under the wall that stopped each, with what would reopen it. Written at
the owner's word on 26 November 2026 (K92). Whoever moves a wall, or parks a pull at one, rewrites its section and
names the post.*

**The test for every pull** (the owner, 26 November): *does this pull move us towards a solution or partial solution
for a prize problem?* A pull names its wall, the first statement past the wall that it aims at, and what a failure
would prove.

| | Wall | The missing statement, in one line | What it stops |
|---|---|---|---|
| **W1** | The white tail | A finite row's own white cells must end a periodic centre, and nothing is proved once its last black cell has been read. | Problem 1: period two, and every period by the same reduction |
| **W2** | One orbit | Known bulk recurrences on the single seed still leave the prize-column criteria open. | Problem 2 whole; Problem 1 through its weakest sufficient conditions |
| **W3** | The doubling step | At the left edge every result holds through finitely many clock doublings; none passes from period 2ᵉ to 2ᵉ⁺¹. | The every-k chain; the left-edge routes to Problem 1 |
| **W4** | Hearing from below | We can bound from above what the right side sends, and refuse words; we cannot show that any given thing is sent. | No prize problem directly; whether the classes we exclude are empty |
| **W5** | Lower bounds on computation | No technique bounds from below the cost of computing one fixed sequence. | Problem 3 |

The kit's names are in `code`; [KIT.md](KIT.md) §3 has the web of implications and §4 the barriers. Phase-1 pulls are
cited by their ledger names; their full entries are in [the archived NOW](archive/now/now-phase1-2026-11-26.md), and
the submissions S1 to S29 in [SUBMISSIONS.md](SUBMISSIONS.md).

## W1. The white tail

**In plain words.** Take a row with finitely many black cells to the left of the centre. For the centre to alternate
for ever, the left half must pass a check at every black tick (its nearest cell is black), and at every white tick it
fixes what the right half must show (the demand; a black demand is a *kick*). Each cell of the left half is first
felt at the centre at one tick, in order of depth. Until the last black cell has been felt, checks and demands behave
exactly like fair coins: of the 4ⁿ rows of width at most 2n, 2ⁿ − ones n pass every check through tick 2n
(`first_check_count`); over all fillings of the next digits the survivors follow a fair-coin chain (`mean_ladder`);
beside a prescribed wall of T ticks the right halves that serve it have fair mass exactly 2⁻ᵀ (S28); along the tree
of gate words each decoded cell is white half the time (K88, measured). After that the remaining checks are decided
by white cells, that is by the row's own past, and there every proof stops. The kit digest has it in one line: the
fair-coin laws are exact at the start and unproved after a finite row's support ends.

**The missing statement.** Any one of these gives *no eventual period two*:
- `Q01`: no finite left half passes its own checks for ever. In the kit it is also "every natural reaches an even
  number under G", "no Theta f is finite", mortality and the repeat budget.
- a geometric bound on the survivors past the support, S n (2j) ≤ C · V n · θʲ (`noSeed_of_geometric_ladder_bound`);
- L(B) < ∞ for every B: no finite left half alternates for ever beside any right half (K84);
- a **weight floor**: a left half that starts at a kick and is served for H ticks has at least (H − d)/q black
  cells (`MassFloor`, with `not_eventually_period_two_of_floor`; `noSeed_GE2_of_massBoundFun` in the 13-column
  language; `MassDiverges` in the trap);
- the kit's split, `RD` with `Q01Gap`: every finite right half enters the trap or a lock, and inside the trap no
  finite left half survives (`CQ01_of_RD_of_Q01Gap`).

For every period at once the same wall is `UBE`: every finite left start driven by a periodic word with a black phase
fails a check. `UBE` gives Problem 1 (`problem1_of_UBE`). Period three has it as `Left001` and `Left011`, period four
as `Absorption` and `Lock`.

**Proved up to it.**
- `Q01` for every start of width at most 52 (`q01_width_le_52`). The latest lone death is at tick 96 at width 52
  and 116 at width 64 (exhaustive, K84's note). The coupled lifetime is exact to support 106, with replayed lower
  bounds to 224 (I246, K88).
- From check 2 on, for two of any three consecutive n the first check after the support passes a share of rows
  between 1/40 and 39/40 (`first_check_balanced`), and its degree is n or n − 1 (`check_degree`). At one width in
  every seven consecutive widths, more than 1/16 of the first-check survivors fail the second check (Benboubakeur
  and others, portal R30-20261126-65dcb1). These two are all that is proved about checks past the support.
- Every start below 2⁵² dies within its size plus four steps of G, and that bound for every start would be Q01
  (h3artfield, portal R30-20261108-508c6c and a0fd36). One immortal row of width b would force **at least** 4,096 at every exact width w≥b+389 of the same parity (Benboubakeur et al., portal R30-20261126-e2e0e2). Consequently fewer than 4,096 finite-horizon survivors at arbitrarily large widths of each parity would give Q01. [Checked corollary](research/phase2/borrowed/SparseWidths.lean)
- In G the least weight is the one-in-seven row's (AIOvernight; PRIOR-ART P1). In the trap's gap language it has
  slope about 0.275 a tick to H = 180, while every periodic row there weighs 0.44 or more: the cheapest words are
  cheap through transients (M6, M21).
- Every right half is in a closed set of 777 windows from white sample 35 (S18); 48 clean readings certify the trap
  (S15); no right half kicks once in four for ever (S18).
- Beside 001 and 011 a right half white beyond site D enters its trap by tick 3D + 170 or 3D + 820, and slope three
  is sharp (S16, S21). For period two the finite-eastern census through support 24 has a sharp observation deadline of tick 5,539 for clean48 or one of the tested certified locks. The all-width deadline remains open. [K92.3](research/phase2/deadline/results.md)
  - Behind that deadline (N32, COMPUTED and MEASURED): the long waits are partial seven-locks. The gate reads the
    seven-lock's word `0101000` while about 11 cells agree with a lock phase, and the lock is never certified. Every
    clean seed is off that word for at most 202 samples before trap entry. The waits end at about 0.0053 per white
    sample at every support, so the records grow by about 130 samples per site by counting.
    [Partial locks](research/phase2/deadline/claudeIntel-partial-locks.md)
- Families that die or lock: the stripe prefixes, the locks of gates 2, 5 and 2,5, the ether families.

The two Benboubakeur entries on post-support survival have now had [source reads](research/phase2/ladder/sources.md). For the other portal results see the read depths in [PORTAL.md](PORTAL.md).

**Why it resists.**
- *Infinite rows do survive*: the ether, the four rings, every `Theta f`. So the finiteness must be used, and a
  periodic left half cannot stand in for it (`Rule30EtherWallWitness`).
- *The controls.* Rules 90 and 150 share every structural fact and have exact deadlines; an alternating 90/150 hybrid
  has immortal finite rows; the planted survivor differs from rule 30 in one top monomial of each check; rule 210
  keeps the clock beside an empty left half (M10 and the kit, §4). A proof must fail on each of them.
- *No ranking, no conserved quantity, no linear chart* (kit §4), also in the coupled frame and inside the gap clock.
- *The relaxed languages are too weak.* In the kit's language G (two conditions on the wall readings) a row with
  one black cell in seven passes at every length tried, and AIOvernight's portal entry states it as eternal (P1).
  Words cut from it reach H = 7A + 9 at arbitrarily late lengths, so the sharp floor fails (Galindo,
  `Rule30MassCounterexamples`); a floor common to all periodic centres has slope at most 1/14
  (`Rule30PeriodTwoNoFloor`). An 18-column strip reads that row's demand for all 53 readings listed.
- *It is of Collatz type.* The wall readings conjugate the left half's map to the shift, and the question is whether
  a closed invariant set of rows holds a natural number. No affine structure is there to help (`Rule30LinearCharts`).

**What it would take.** One statement about a row *after* its support that holds for every row at once. The smallest
ones nobody has proved:
1. **The k-th check.** The first check is balanced and the second has a first bound. Nothing covers k checks with
   a product that tends to zero: that would be mortality with a deadline for all but a vanishing share of the rows
   that outlive their support.
2. **A weight floor against real right halves.** The one-in-seven row demands a kick every fourth reading, and no
   right half gives that for more than 31 readings (S18 proves never for ever). Anchored at a kick, the least weight
   a real right half serves for H ticks is 5, 7, 8, 10, 14, 18, 21, 22, 26, 29, 31 at H = 20, 30, …, 120, where G
   allows 4, 5, 7, 8, 10, 11, 12, 14, 15, 17, 18 (K92, a development probe:
   [table](research/phase2/data/claudeCloud-floor-probe.txt)). From H = 60 it climbs at about 0.28 a tick, the
   slope M6 measured in the gap language. The anchor matters: at a white tick that is not a kick, the ring of
   gate 2 weighs H/7. K92.1 gives exact physical minima at every even H through 182 and bounds of 97 to 103 at H=300. The conjecture H≤4A+12 holds on that finite range. An unbounded, even sublinear, minimum would already exclude an immortal finite west. [Bounds and counterexample to local charging](research/phase2/floor/results.md)
3. **A deadline for finite right halves** that grows linearly with the support, as period three has. Through
   support 24 it is set by partial seven-locks, which end at a rate that does not depend on the support (N32). A
   proof would have to show that every finite right half breaks or completes such a lock within c·D samples: that a
   given thing is sent, W4's statement.

**Phase-1 pulls that stopped here.**

| Pull | Where it stopped | Reopens with |
|---|---|---|
| K84 | the excess L(B) − B follows log₂ of the gate-word count, record 24 at B = 194 | a geometric bound on the coupled survivors, or a uniform constraint on decoded white sections |
| K50.1 / K81, I152 | `RD` inside the 777-window set: a finite seed keeps Y's schedule for 470 readings (N21); no right half turns the wheel fifteen times | a certified whole-cone refusal of a Y stay, or an argument that uses the finite far field |
| M9, K50.2, M7, R3 | the trap side: lone 5-gaps, Lowry's returns, the empty right half, the gaps as fair coins | a finite-support weight argument; a reason why white seed bits cannot be accepted for ever; zero entropy of u ∅ |
| M6 | the gap floor is not the density of a periodic eternal row: slope 0.275 against 0.44; the minimisers' deficits were 4 at H = 140 to 180 | deficits that stay bounded beyond H = 180, or a proof of a floor at any slope |
| M8 | a flipped free bit reaches 6.4 times its entry depth, as in random words | a smaller language on which reach could be bounded |
| R5 | period three: the gate inside the 14-column transient | an all-time argument through that transient, or a repeatable nonconstant 011 gate |
| I66 | Lowry's net and shell are aperiodic under alternation (S17), with no way yet to use it | a way to turn source priority into an exclusion |
| M10 | the control matrix, kept as the sieve for any proposed proof | a proposed route to test |

**Phase-2 pulls that stopped here.**

| Pull | Where it stopped | Reopens with |
|---|---|---|
| K92.3 (parked at the owner's word, N33) | every finite east through support 24 certifies by tick 5,539 (I286). The long waits are partial seven-locks that end at one support-independent rate, so T(D) is linear by counting and the white far field gives no argument (I288–I293, N32) | a bound, linear in the support, on how long a partial seven-lock lasts before it breaks or completes; records growing faster than linearly; or a finite right half with unboundedly many rhythm breaks outside the trap (RD's own question, on K50.1's line) |
| I295.1 (parked at the owner's word, M219) | two submissions. S30 (R30-20261127-9b429e, in the kit as `Rule30SevenNineReset`): any safe gap list that carries Galindo's F into E is excluded, with the ten-gap motif certified (I299, N34). S31 (R30-20261127-20bf8c, kit pull request #457): every cyclic 7/9 word with no 7,7,7 and no 7,9,7,9 is excluded at every length by one 13-cell certificate (N35). Words with 7,9,7,9 but no 7,7,7 settle on 17 cells by computation, with a certificate some sixteen times larger (K93, K94, N35); words with 7,7,7 settle on no strip up to 20 cells (K94) | a 17-cell certificate for "no 7,7,7" small enough for a portal entry, or any method that excludes a word containing 7,7,7 other than pure sevens (N35) |

## W2. One orbit

**In plain words.** With fair coins on the right, the centre column is an exact fair-coin sequence whatever the left
half is (S28 has the law): aperiodic, with density one half. The seed is one row. Some local patterns recur there.
The known recurrences leave open the specific events and growth rates that would decide its centre column.

**The missing statement.** Each of these is proved, in the kit, to give Problem 1:
- **marks** (`problem1_of_marks`, Lowry): for every B there is an age with more than B white cells immediately left
  of the centre, a black cell beyond them, and a black centre that many ticks later;
- **vocabulary** (`problem1_of_five_cell_growth`, Galindo): the words on sites 0, −1, …, −w over all ages outnumber
  A(39/32)ʷ for every A. Proved: w + ⌊w/39⌋ + 1;
- **census** (`one_in_seven`, S22): one disjoint pair per seven positions at unbounded widths. On the seed the
  largest census nears one half at the widths computed (N26);
- left richness (`problem1_of_rich_left`, Kurtuluş), restart matches of every length (`problem1_of_matches`, Lowry),
  and for period two a forcing prefix at arbitrarily late ages (S12).

For Problem 2 the missing statement is any frequency at all.

K92.4's single-seed scout through age 4,194,304 found a largest mark of width 22 and a longest finite first failure of 53. The timing phases fitted on the first half did not predict held-out wide marks. An edge mechanism would have to predict a new centre event in advance. [Record ages and timing test](research/phase2/marks/seed-results.md)

The edge clock decides half of a mark (M220, PROOF-SKETCH and COMPUTED). A gap of width l is marked or not by the
seed's left diagonal l, read from a short prefix of the cells east of the centre: 9 cells to width 28, 30 to width
399, and at most about half the width in general. It does not say when a gap opens. The settled wedge ends near
x = −t/4 and its boundary recedes: diagonal j settles near tick 1.3 j, and the centre reads it at tick j.
[What an edge predictor requires](research/phase2/marks/claudeM5-edge-predictor.md)

**Proved up to it.** A run of one colour that starts at age a is no longer than a, so both colours occur in every
window [a, 2a], and the j-th black tick comes by 20(8/5)ʲ: logarithmic counts and no more. Dyer carries both bounds
to every column of a row with a leftmost black cell (portal R30-20261126-19e94d and 88998c, abstract depth). No
period up to 4096 with a transient up to 8192, and T + P ≥ 16359 for any eventual period. The seed misses two corners
of the density pentagon by counts that grow at least logarithmically, and a bounded deficit at the corner (9/10, 2/5)
would make the left half one film of 155 columns (S25).

I295.2 proves in core Lean that for every modulus m ≥ 3, each six-column singleton strip contains a fixed site
with two cofinal falling residues. Every dyadic shell from age 8 also has falls at two residues modulo three pooled over
−7 through 0. The centre milestone belongs to W1. It would exclude both period-three clocks by forcing falls
outside a single phase, even for an eventually nonperiodic trace made of nondecreasing triples.
[Every-modulus proof](research/phase2/falling-phases/every-modulus.md)

**Why it resists.** No invariant measure belongs to the seed; mixing and genericity speak of almost every point and
of no particular one. Both edges are known exactly (left diagonal j has period 2ʲ, right diagonal j about 2^(j/2)),
and the centre at tick t is t cells from each. Whatever is true of every row is too weak, because other rows have
periodic centres. Finite data never helps either: every computed fact about the seed leaves room for a longer
transient.

**What it would take.** An unbounded recurrence at the sites and phases required by a centre criterion. Or a law for *where* records fall, tied
to the left edge's clocks, the one place where recurrence is proved. For marks that law is now one statement about
single rows: at unbounded widths l the seed's row reads one black cell, l white cells and then a forcing prefix of
an edge word, ending at the centre (M220). Or the first rung between w and (39/32)ʷ for the vocabulary: any
superlinear bound.

**Phase-1 pulls that stopped here.**

| Pull | Where it stopped | Reopens with |
|---|---|---|
| I49 | forcing prefixes at four of 524,971 ages to 2²⁰ | a reason why any forcing prefix recurs |
| K83, seed side (N26) | the seed's largest census nears one half at the widths computed | abundance at every width, which is as strong as window normality |
| I72 | a bounded deficit at (1/3, 0) pins an eventual 011 two sites east; two fixed right halves defeat periods to 4,096 | an all-period argument for one fixed right half |
| K50.4, R4 | white triangles have one family tree but no bound; deep-source occupancy | a reason to bound patches in the bulk; a seed-specific bound |

**Phase-2 pulls that stopped here.**

| Pull | Where it stopped | Reopens with |
|---|---|---|
| K92.4 (parked at the owner's word, M220) | through age 2²² the widest mark is 22 and record ages follow no clock (I281–I285). The clock decides a gap's arrival from a short edge prefix (9 cells to width 28), and of the 114 marks of width at least 14 it decided one. It makes no gaps: the missing half is the launch, a row reading one black cell, l white cells and a forcing edge prefix at the centre, at unbounded l (M220) | a mechanism or proof for white gaps of unbounded width beside the centre; or a law for the arrival when the context is not an edge prefix; or a reason for the seed's own edge to be read at the centre, F(j) ≤ j at unbounded j against F(j) ≈ 1.3 j computed |

## W3. The doubling step

**In plain words.** The left side of every row with a leftmost black cell is dyadic. Diagonal j repeats with period
2ʲ, clocks double going in, and a clock that is lost is caught again by a reset. Each exact statement there is proved
through finitely many doublings, by one more finite certificate each time: source periods to 16 in Lean and 32
computed, wheels to 87,866, inverse depths to three in Lean and eight computed.

**The missing statement.** (DL⁻₁): *a tick that the doubled stretch after a first clock loss misses is caught in the
next stretch*, at every dyadic period. It gives (L∞), then (CAP), then Hughes's inverse ticks for every k: the chain
of S2, S4, S5, S6, S23 and S29. A counterexample needs a source period of at least 64.

**Bearing on the prize.** The inverse ticks are a statement about the seed's past. The routes from the left edge to
Problem 1 wait on the same step: an aperiodic band from column 0 at every depth (proved to depth 87,868 for long
periods; `problem1_of_band`), and half density along dyadic progressions (`Rule30LeftAntiPeriod`).

**Proved up to it.** The chain's links, S2, S4, S5, S6, S23 and S29. The four left sides through wheel 87,866
(`Rule30FourLeftSides`). Every white-wall band of width w settles by age 152·2^⌊w/23⌋, and the worst-case reset
capacity is monotone in width (Benboubakeur, portal R30-20261126-7b1cac, abstract depth); linear settling and
unbounded capacity, which is (CAP), are open.

**Why it resists.** Each certificate grows with the period, and the maintainers take only the statement for every
value (kit pull request #357). Five counting marks pass at every dyadic clock, and nothing settles from seven. The
measured tail of the last catch is about 1.36 κˣ with κ ≈ 0.8478 (K5): a fair-coin law again, with no uniform bound.

**What it would take.** An induction: a statement at one clock that implies itself at the doubled clock. Or a
counterexample at period 64 or more. S29 adds a lever: ages for every k force a recurrent black-edged row to have at
most one full-line parent.

**Phase-1 pulls that stopped here.**

| Pull | Where it stopped | Reopens with |
|---|---|---|
| M29, the wall (DL⁻₁), K5, K3, counting marks, the census under the relaxed lemma | (DL⁻₁) beyond source period 32; the resolution law's tail; reset-free doublings only at period 5 | a proof idea, or a counterexample at period 64 or more |
| K50.3 | ages 8/9, 24/25, 31/32, 72/73, then 81, 108, 131, 132 computed; depth two decides every k (S29) | an argument for every k, or a counterexample to uniform ages |
| R6 | c(2ᵏ) against c(2ᵏ⁺¹) tabulated to k = 27, no rule | a cancellation that survives doubling |

Noticed in that round and not pursued (K25 §5, ledger archive 4): time order matters (I25); period 5's four poor
rows (K21); two late single sources at P = 21 and 23 (K29).

## W4. Hearing from below

**In plain words.** New cells arrive from the right through the rule's OR, which lets a cell through only beside a
white one. Everything asked from above is proved: the entropy is the growth of two-column words and is below 1.143992
bits a tick (1.232039 in Lean, S20); one wall hears at most K(39/32)ⁿ words (S22); a T-tick past has mass exactly
2⁻ᵀ (S28); fifteen turns of the wheel are refused (N19). Nothing is proved from below: not that the entropy exceeds
one bit, not that a flip is heard, not that any aperiodic gate word is read for ever.

**The missing statement.** Rule 30's entropy is strictly above one bit: the words on two neighbouring columns
outnumber 2ⁿ exponentially. Its local forms: positive westward speed; every order of the blocks X and Y is read
(M181); some right half reads 3555 for ever (K81).

**Bearing on the prize.** None is known. The route from hearing to Problem 1 (S22) uses the bound from above. This
wall decides other things: whether the classes that S19 and S27 exclude are empty, and how fast K84's excess grows.
A pull here has to say why it is worth a block all the same.

**Why it resists.** A lower bound needs many right halves whose gates are known for ever. Short-memory pair languages
have zero entropy (I234); a cylinder cannot return to itself (I239, S28); the patterns periodic in space and time
beside an alternating column are four, complete to 48 ticks (K87), and one of them has no lock (K91).

**What it would take.** A construction that yields exponentially many extra two-column words: a language with hidden
states, or a horseshoe. Or a reason why a forcing prefix recurs.

**Phase-1 pulls that stopped here.**

| Pull | Where it stopped | Reopens with |
|---|---|---|
| K83 | every bound from above is in; entropy above one bit, positive speed, every flip heard are one open question | a hidden-state language or horseshoe; or pure periods null beside every finite left half |
| M181 | not every order of A and B is read; every order of X and Y is open | a reason why a forcing prefix recurs; one right half that reads 3555 for ever; a certified refusal in X and Y |
| N6 | golden and block rotation orders are refused (S11, S19, S27); below ratio six the three-trial test is sharp | a test that uses several lags at once; or a right half that reads a two-block rotation word for ever |

## W5. Lower bounds on computation

**In plain words.** Problem 3 asks that no machine compute the n-th centre cell in time O(n). The kit proves that
every machine takes at least k + 1 steps infinitely often for each k ≤ 13 (`Rule30Problem3Bounds`), and that
Problem 3 gives Problem 1. Among the forms *equivalent* to Problem 1 are "no one-tape decider in time o(n log n)" and
"not k-automatic for some k". So a lower bound against a weak machine is Problem 1 again, and against a strong one
it is harder. Dyer's entries of 26 November are about a different input, the starting row and not the time: the
language of rows with a black apex is neither regular nor context-free (portal, abstract depth).

**What it would take.** A way to bound from below the cost of one fixed sequence, with no inputs in which to encode
a hard problem. None exists for any natural sequence. No pull is proposed; a Problem 3 partial will come, if at all,
as a by-product of W1 or W2.

## Two limits of practice, which are not walls

- **Proof size.** The verifier replays a submission within four minutes. True facts with large certificates cannot be
  posted: the fifteen-turn refusal (19.4 GB of LRAT), single inverse ages past the kernel. A small proof of one of
  them is a result.
- **One more term.** A statement for the next value of a parameter, proved by one more certificate, is an instance
  (METHOD §12). I77 (sparse periodic columns, where each longer period needs its own certificate) and the single
  ages of K50.3 stopped here. They reopen with an invariant that covers every value.
