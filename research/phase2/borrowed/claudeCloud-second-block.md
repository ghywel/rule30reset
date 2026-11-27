# K92.5, second block: rule 30 among its relatives, a read of the 30/180 front, and the questions after both blocks

*claudeCloud, 27 November 2026 (ledger K98, K99). The owner asked for a block on K92.5 that uses gptIntel's examples
and widens the questions the pull invites. K98 widened them to nine families and registered an atlas of rule 30's
relatives. While I was paused, gptIntel replayed the atlas, answered all nine families from primary sources and the
kit, proved two hybrid theorems, and split the pull into the children K92.5.A to D (I313 to I324,
[handoff](k98-nine-questions.md), [atlas read](atlas-results.md)). This note gives my own reading of the atlas, a
different-model read of gptIntel's front theorem, one addition to the square root, and the question set as it stands
after both blocks.*

## 1. The atlas, scored

The systems are the 128 time and space hybrids of the eight rules *left xor f(centre, right)* that keep white white
(240, 60, 90, 150, 120, 180, 210, 30). A time hybrid (A, B) applies A at even ticks; a space hybrid applies A at odd
depths beside the wall and at even sites on the line. Beside a white wall a finite row survives while depth 1 is black
at every even tick (the kit's `Rule30WallDeadlines.zr`). Definitions, frozen code and the eleven predictions are in
the [registration](data/claudeCloud-atlas-predictions.txt). COMPUTED throughout.

**Nine of eleven predictions held** (my count from my own outputs; it agrees with I315). A1, A2, A4, both A5, B1,
both B2 and B4 held. **A3 failed** (60%): five of the twenty hybrids of rule 30 have immortal rows at the wall. **B3
failed** (55%): six have a periodic column on the line that is not white. The independent Python replay agrees with
the C++ program on all 256 small blocks ([check](data/claudeCloud-atlas-check.txt)).

Four things the tables show, beyond the scores (read after the runs; [reader](claudeCloud_atlas_read.py),
[output](data/claudeCloud-atlas-read.txt)):

1. **Every immortal row found in a nonlinear relative is a cycle of bounded width.** 65 of the 128 systems have a row
   alive at tick 4,096 (27 time and 38 space hybrids, as I315 counts). For the least such rows (up to four at each
   width), every one returns to an earlier row within 20,000 ticks in 64 of those systems. The exception is the kit's linear space hybrid (150, 90), whose immortal rows grow. A rule 30
   immortal could not be a cycle: rule 30 moves the far edge out one cell at every tick.
2. **When both rules move the far edge out at every tick** (f(0, 1) = 1: rules 90, 150, 210 and 30), 32 systems in
   all, exactly one has an immortal row: the same linear space hybrid (150, 90). Its mirror, with rule 90 at the odd
   depths, has none to width 22.
3. **The order decides in nine pairs.** One order has a wall immortal and the other none to width 22: time (180, 30)
   against (30, 180), time (180, 150) against (150, 180), and seven space pairs, among them the kit's own (150, 90)
   against (90, 150). Both time pairs are the same three-cell trap 7 → 2 → 7: rule 180 sends 7 to 2, and any rule
   with f(0, 1) = f(1, 0) = 1 sends 2 back to 7.
4. **The hard class.** Besides rule 30 itself, 21 relatives have neither a wall candidate to width 22 nor a periodic
   column on the line from any start below 1,024, rules 45 and 75 (normalised) among them:

   | Mode | Pairs (A, B) |
   |---|---|
   | time | (60, 210), (60, 30), (90, 30), (150, 180), (150, 210), (120, 30), (180, 210) = rule 75, (210, 60), (210, 150), (210, 180) = rule 45, (210, 30), (30, 60), (30, 90), (30, 120), (30, 210) |
   | space | (90, 30), (150, 210), (210, 150), (210, 30), (30, 90), (30, 210) |

   None of them has a proved wall theorem. A proof of mortality for any one, by a method that is not a reduction to a
   linear rule, would be the first. Time (150, 180) is the closest to gptIntel's theorem: it shares rule 180, it
   does not erode on the line, it dies at the wall through width 22 with lifetimes near 2W (40 at width 22), and its
   reversal holds the same 7 → 2 → 7 trap.

## 2. The 30/180 front: different-model read (K92.5.B)

gptIntel's [HybridWallFront.lean](HybridWallFront.lean) (SHA-256 `239f226b…`) proves, for one rule 30 tick then one
rule 180 tick: the leftmost black cell moves east at least one site every four ticks, for any infinite east; every
fixed site is white from some tick on, in both orders; beside the wall a row of width W fails an even check by tick
4·max(W − 3, 0) + 6; the reversed order holds the row 7 for ever.

| Check | Result |
|---|---|
| Compiles with core Lean 4.35.0 (Std only), 34 s | yes |
| Axioms of the five headline theorems | `propext`, `Quot.sound` only |
| `leanchecker` | passes |
| The statements say what I315 says: frames, masks, the deadline in ticks, the reversed order | yes; the wall is the kit's, with depth 1 at site −1 |
| Four ticks clear L from every window L … L + 6, west white (my code, tables only) | yes, all 128; one pair leaves L black in 16 of them, exactly when L + 1 and L + 2 are white |
| The speed is sharp: starts below 2¹², 800 ticks | least advance 200 sites, the bound exactly |
| The three-cell map at the wall | [0, 0, 2, 1, 5, 3, 3, 2], as stated; first white even tick at most 6 |
| The deadline against the atlas, widths 1 to 22 | holds everywhere, attained at W ≤ 3; observed lifetimes are near 2W, half the proved slope |
| The reversed order from row 7 | 7, 2, 7, 2, … for ever |

[Check program](claudeCloud_front_check.py), [output](data/claudeCloud-front-check.txt).

**Novelty.** Time-alternating rules are a studied framework: Paul and Das, *Temporally Non-Uniform Cellular Automata:
Surjectivity, Reversibility and Cyclic Behavior* (arXiv:2411.17421). I read the abstract and, in v2, sections I and
II and section III through Theorem 4. They take periodic boundaries for finite lattices and study surjectivity,
injectivity, reversibility and cycles. In what I read there is no erosion, no fixed wall and none of these pairs.
Section IV on, and v3, are unread. A Wolfram Demonstration that flips between two elementary rules was seen in a
search result only. Two web searches found no erosion theorem for a time hybrid. NOT FOUND, which is not a novelty
clearance.

**Verdict: PASS.** The proofs are right and the statements are as posted. On kit fit, the result is a control, and
a small one. The order effect at the wall is the local three-cell trap above, and on the line the system erodes, which
rule 30 cannot do. As a control it says two things. A proof of Q01 that would also apply to time (180, 30) must fail,
because that system has an immortal row. And passing every numerical "rule-30-like" test does not exclude a short
proof of mortality. I would put it in the kit only beside a statement that bites harder: a wall theorem for a member
of the hard class, (150, 180) first.

## 3. The square root is affine in its west input

Wolfram's note (NKS p. 956, read in full: it is one sentence) names the three-colour, radius-½ rules 11736, 11739
and 11742, whose square is rule 30. It gives no formula. In gptIntel's coordinates (white 0, black 2, table entry
3a + b; [TernaryRoot.lean](TernaryRoot.lean)), the second code is a polynomial over GF(3):

> **11739: h(a, b) = b + ε(b)·a mod 3, with ε(b) = +1 if b is black (2) and −1 otherwise; ε(b) = 2 + 2b + b².**

PROVED by checking the nine entries; the other two codes differ from it only on the pair (0, 1), which never occurs
on a half-step row. So each half step is a permutation of the west cell, chosen by the east cell from the three maps
a ↦ −a, a ↦ 1 − a and a ↦ a + 2, which generate the whole affine group of GF(3), the symmetric group on three
letters. Rule 30 is permutive in its west cell through translations of GF(2), a commutative group; its square root
is permutive through a group that is not commutative. At the second half step the east bond chooses the map: 00
gives a ↦ −a, 1* gives a ↦ 1 − a, and 01 gives a ↦ a + 2.

Whether this helps K92.5.C (when does a periodic centre force the bond to repeat) is open. A bond's colour sequence is
a word in that group acting on the west, and a question about which words of S₃ a periodic mask allows is the form the
child's question takes here.

## 4. The tick-24 images (I317's question)

I317 asked whether my source notes give a way to bound the number E(n) of different tick-24 images of the A(n, n)
survivors. They do not exist: the four agents I had reading sources for families 2 to 8 stopped on a usage limit
before reporting, and I have not relaunched them, because gptIntel's reads cover the same families. One remark of my
own: the images are themselves rows that pass the remaining 2n − 12 checks. So bounding E(n) is a survivor bound on a
smaller population, and it is not a different kind of statement. The one outside pattern that bounds an exceptional
set by an injection is Mahler's (at most one Z-number in each unit interval). Its rule 30 form would be an injection of
those images into a set of size o(n). I know of no route to one.

## 5. The questions after both blocks

| | Question | Where it stands |
|---|---|---|
| 1 | Which relatives share the white-tail wall? | The atlas, sections 1 and 2. Open: a wall theorem for one member of the hard class (K92.5.B) |
| 2 | Collatz, Mahler and digit problems past the bijection | gptIntel: the cumulative deficit and A(n, n) ≤ 4095n (I316); the conditional count stays with K92.2 |
| 3 | Termination ranks | K92.5.A (gptIntel, I317) |
| 4 | Barriers from undecidability | gptIntel: none fixes the centre; the atlas immortals are the working counterexamples (I317) |
| 5 | Upper bounds that give equidistribution | K92.5.D (gptIntel) |
| 6 | Randomisation of one-sided permutive rules | gptIntel: the random-tail identity keeps the seed's own discrepancy (I317) |
| 7 | Toom erosion | gptIntel: blocked XOR is never monotone; the 30/180 front is the direct erosion (I317) |
| 8 | Cost of one explicit sequence | gptIntel: Fischer–Rabin encode hard sentences in the index, which cannot transfer (I317); I295.5 |
| 9 | Weaker targets still open | K92.4.A, I295.5 (gptIntel) |
| **10** | **Order at the wall.** Which wall theorems depend on the phase of the check? | New, section 1.3. For rule 30 the odd phase reduces to the even one (an odd-phase immortal x gives the even-phase immortal F(x)); for hybrids it does not. A proposed proof must say which it uses |
| **11** | **Bounded against growing immortals.** Is every immortal finite wall row of a nonlinear relative a bounded cycle? | New, section 1.1, COMPUTED to width 22. Rule 30's rows grow by one cell a tick, so for rule 30 this is Q01 itself. Its use is as a family statement: a method that proves it must tell a trap from growth |
| **12** | **Edge-growing relatives.** If both rules move the far edge out at every tick, does only linearity allow an immortal? | New, section 1.2. One immortal system in 32, linear. No row of these systems can cycle, so this is question 11 for them, and Q01 for the whole family |
| **13** | **The non-commutative square root.** Does the S₃ action of the half step constrain the bond's colours under a periodic centre? | Section 3; belongs to K92.5.C |

## 6. Verdict

Reasoned: K92.5's reading has done what the pull asked. Its table exists: gptIntel's and this note, with each method,
its hypotheses, what the kit proves, and the control that breaks it. Its proof targets now live in four children and
in K92.2. The atlas gives the children their test cases, and its hard class is the list of systems a wall method has
to be tried on. I would keep K92.5 open only as the parent of A to D, as NOW's rule requires, and add (150, 180) to
K92.5.B as its next target.

Gut: the next thing I would try is a wall proof for time (150, 180). It is chaotic on the line, rule-30-like at the
wall, shares rule 180 with the one proved case, and the front method does not reach it. A proof there would be a
nonlinear white-tail theorem of a new kind; a failure would show what the front was carrying.

## Files

| File | What it is |
|---|---|
| `claudeCloud_atlas.cpp`, `claudeCloud_atlas_check.py` | the frozen atlas and its replay (K98) |
| `claudeCloud_atlas_read.py` | the reader: the registered definitions, the fates of immortal rows, both frames |
| `claudeCloud_front_check.py` | the independent check of HybridWallFront.lean, and the order-at-the-wall sort |
| `data/claudeCloud-atlas-*.txt`, `data/claudeCloud-front-check.txt` | the outputs |
