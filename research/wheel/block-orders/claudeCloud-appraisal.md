# M181 appraised: what is settled, what could be submitted, and why I would park it

claudeCloud, K86 and K87, 26 November 2026, at the owner's word. Statuses as in METHOD §5. The pull: *which orders of
the blocks A = 3555 (18 readings) and B = 355555 (28 readings, one turn of the wheel) can a right half beside an
alternating column read?* The wall is white at even ticks, the gate is the cell beside it read at those ticks, and
there is no condition on the left. [The pull's notes](README.md) · [trains](claudeIntel-n19.md) ·
[isolated B's](isolated-wheel-orders.md) · [the infinite case](isolated-infinite.md)

**In short.** The first question is answered: no. Its successor is open and I see no route to it from either side. Nothing
in the pull meets METHOD §12 today, and the one fact worth a submission cannot be put in Lean. I recommend parking it,
with the three conditions of §5 for coming back.

## 1. What is settled

| Statement | Status | Where |
|---|---|---|
| No right half turns the wheel fifteen times in a row: (355555)¹⁵ is refused on 80 columns with a free edge | COMPUTED: CaDiCaL, then a 19.4 GB LRAT accepted by lrat-check and cake_lpr; **formula read, PASS** (§6) | N19 addenda 4, 5; K87 |
| So not every order of A and B is read | follows | R130 |
| Every order of up to ten blocks has a real row (1,024 of 1,024) | COMPUTED, replayed | N19 |
| Every order of up to nine of X = A, Y = AB has a real row (512 of 512); one row reads Y¹² X Y¹² (1,126 readings) | COMPUTED, replayed twice | R130, R132 |
| A word is read by some right half if and only if each of its prefixes is | PROVED in Lean with Mathlib, four headlines | I239, [GateCompactness.lean](GateCompactness.lean) |
| A costs a steady 0.80 bits a block for 50 blocks; AB a steady 3.5; B rises from 3.2 to 7 and dies | MEASURED | N19 |
| A returns on 87 columns and B on 70, on free strips; a real turn changes a cell among sites 2 to 83, or 2 to 66 | COMPUTED with LRAT | K81 |

**The successor, open:** is every infinite order of X and Y read? Its least case is X for ever, the train 3555.
K81 left that open on 23 November, and it was parked with K50.1 and I152.

## 2. Against METHOD §12, piece by piece

| Piece | In Lean | Why it is not a submission |
|---|---|---|
| The fifteen-turn refusal | no | Condition 1. The proof is 19.4 GB of LRAT against four minutes of kernel replay, and no smaller proof is known: the wheel turns for ever on a free 70-column strip, so any refusal needs at least 71 columns over many turns. It is also one more forbidden gap word, after `Rule30GateTrapWords`, `Rule30GateTrapLift` and `Rule30TrappedRuns`, though the first of its size. |
| The prefix criterion | yes, Mathlib | Condition 3. It is the closedness of a continuous image of a compact space; the Rule 30 content is locality. It is a lemma for a later entry, not an entry. |
| The censuses (1,024 and 512 orders, the tours) | no | Lists of single words (§12's table). |
| Strip refusals: no two seam rows at width 35; the width-40 bridges; no return on 72 columns | no | Facts about free strips and about proof strategies, each finite, each with an outside certificate. |
| "One missing word or entropy of at least 0.0442 bits a reading" | no | Conditional on the open successor. |
| K81's theorem, that bounded column periods force a ring (used in R132) | no, a hand proof | General, for every bound. But in a configuration with a leftmost black cell at most one column is eventually periodic (`Rule30Jen`), so its hypothesis never holds where the prize problems live. It speaks only of prescribed walls. I do not propose it. |

## 3. Why the successor is out of reach

**A yes needs an infinite object, and every way we have of making one is closed.**
- **Rings** (patterns periodic in time and space that hold an alternating column). They are the only infinite readings
  anyone has exhibited. K79 listed four, with gates 2, 3, 5 and 2,5, complete to 24 ticks. **This block: complete to 48
  ticks, and still the four** (§6). The A-train is not one (R132: tail 63,577), nor is any other gate of up to 24
  readings, nor the wheel. By K81 a right half that reads such a gate for ever has an aperiodic column or unbounded column periods.
  The 155-column ring of gate 5 is the film of S25 (M202).
- **Strips** over-read. A free 70-column strip turns the wheel for ever and no right half turns it fifteen times. So a
  strip that reads every order (width 23 for A and B, widths 34, 35 and 40 for X and Y; I239, R132) shows nothing
  about right halves.
- **A returning cylinder** cannot exist (I239: μ(FⁿX) = 4⁻ⁿ).
- **Counting the periodic strips eastward** is no way round SAT: at the A-train's period there are 2,121,209 strips of
  width 17, though none of width 88 (§6).
- **What is left is an induction on forcing prefixes** (I236's tree): a prefix that forces the word so far, extended by
  fresh cells, for ever. It needs a reason why a forcing prefix recurs. That is word for word the condition on which
  I49 is parked, and nobody has one.

**A no needs a refused word, and the evidence is against one.** The wheel announced its refusal: its cost rose from
turn 5 at every population (N19). No train of X and Y rises; all 512 nine-macro orders are read; the densest train Y
repeats on 160 columns. A refusal may exist beyond the lengths searched. I put 0.85 on every such order being read,
and 0.03 on a proof either way from the tools in hand (my judgment).

**So the pull's question is now as hard as its hardest relatives.** Each further turn has added a finite fact of a
kind we already have.

## 4. What it was for

M181 was raised to learn whether the class S19 excludes is empty. It has answered what it can: S19's example is read
for 821 readings, orders with B's apart are read at every length tried, and orders with fifteen B's together are
not read. S19 is posted and none of this changes it. A full answer would be about Rule 30 beside a prescribed wall,
an entry of S20's kind and not a step in Problem 1.

## 5. Recommendation: park

**Come back with any one of:**
1. a reason why a forcing prefix recurs (shared with I49), or any construction of one right half that reads 3555 for
   ever (K81's least case);
2. a certified refusal of a word in X and Y;
3. a proof of the wheel's refusal small enough for the kernel, by a ranking or a wider strip with a short proof. Then
   "no right half turns the wheel k times in a row" is a candidate of S10's kind.

**Not worth another turn:** orders of ten or eleven macros; wider bridges for Y X Y; the least number of turns real rows
refuse (12 to 15); the trains (3 5ʳ)ᵏ for other r; longer walks for the ring of Y (see §6). Each is one more finite fact.

**To keep as standing facts:** the fifteen-turn refusal with its second read; the two censuses; the prefix criterion in
Lean; the cost table of N19; the four rings, complete to 48 ticks.

## 6. This block's own work

**A second read of the refusal's formula, PASS (COMPUTED).** The two proof checkers show that N19's formula has no
model. Nobody else had checked what the formula says. [My reader](k86/claudeCloud_m181_cnfread.py) runs the generator
again and gets N19's digests (`a0ced262…` for fifteen turns: 64,881 variables, 382,141 clauses; `d2a06c9e…` for
sixteen). It checks that the variables are the cells of columns 1 to 81, that the unit clauses are exactly the 421
readings (a kick, then 3 5 5 5 5 5 fifteen times, each gap closed by a kick), and that every other clause holds in real
evolutions simulated with a separate rule table (60 random right halves; one flipped cell breaks four clauses). Column 81
enters only as a neighbour. So a right half that read the word would be a model. I also read the generator's 37 lines.
I did not rerun the solver or the checkers.

**The ring census (COMPUTED; registered in K86).** For a periodic gate the pair (column −1, wall) is fixed by the gate,
and a ring exists exactly when that pair returns to itself under the westward map. One walk per gate decides it.

| Gates | Words | Rings | Method |
|---|---:|---|---|
| every primitive gap word, gaps of at least 2, up to 20 readings (40 ticks) | 2,169 | 2, 3, 5 and 2,5 (7, 84, 155 and 728 columns) | the exact walk: tail and cycle of each |
| the same, 21 to 24 readings (42 to 48 ticks) | 10,046 | none | distinguished points; two settings agree on all 2,955 words of 21 and 22 readings |
| 3-gaps and 5-gaps only, 25 to 28 readings (50 to 56 ticks) | 15 | none; the wheel has a tail and ends in a cycle of 15,009,104,432 columns | distinguished points |

At each period nearly every forced pair runs, after a tail, into one large cycle: 4,259 of the 4,305 words at 48 ticks
end in one cycle of 625,938,624 columns. A forced pair that sits on its cycle is the exception, four in 12,230. The
largest cycle has 41,807,380 columns at 40 ticks, 625,938,624 at 48 and 15,009,104,432 at 56, about twenty times more
for every eight ticks. At that rate the walk for Y (92 ticks) is some 10¹⁶ columns: out of reach, and R132's 25 million
were a small part of it.
[Exact walks](k86/data/claudeCloud-rho-all-2-20.txt) · [21 to 24 readings](k86/data/claudeCloud-rings-all-21-24.txt) ·
[3 and 5 only](k86/data/claudeCloud-rings-35-25-28.txt) · programs in [k86/](k86/)

**Predictions (K86): four of six held.**
- P1 (0.92), no ring at 21 to 24 readings: **held**.
- P2 (0.95), none among the fifteen gates of 3-gaps and 5-gaps: **held**.
- P3 (0.85), at most ten cycles at each period from 42 to 56 ticks: **refuted at 42 ticks**, where the distinguished
  points find twelve cycles, of six lengths. The other seven periods have 1 to 5.
- P4, the longest cycle at 48 ticks above 10⁹ (0.6): **refuted**, 625,938,624. The wheel's above 10¹⁰ (0.5): **held**.
- P5 (0.97), the two settings agree: **held**, 0 of 2,955 differ.

## Reproduction

~~~sh
cd research/wheel/block-orders/k86
g++ -O3 -march=native -fopenmp -std=c++17 claudeCloud_m181_rho.cpp -o m181_rho
g++ -O3 -march=native -fopenmp -std=c++17 claudeCloud_m181_rings.cpp -o m181_rings
python3 claudeCloud_m181_words.py all 2 20 | ./m181_rho 34
python3 claudeCloud_m181_words.py all 21 24 | ./m181_rings 18
python3 claudeCloud_m181_words.py set 3,5 25 28 | ./m181_rings 20
python3 claudeCloud_m181_cnfread.py 'B*15' 80 a0ced262560969340945aa024a10bae1c02830438d06a24f5011b1bc5333894e 60
python3 claudeCloud_m181_east.py 3555 1 20
~~~
