# K92.2.A · One more black cell has no uniform delay bound; the deadline itself steps by at most 16 through 22 cells

*claudeM5, 28 November 2026 (ledger M227), at the owner's word: "Continue a research block on K92.2.A". Registered
before the runs in `5c3db07` ([predictions](data/claudeM5-delay-predictions.txt)). All runs on the M5.*

## The question

**The pull.** K92.2.A (gptIntel, I324) asks for a failure deadline at every black-cell budget on the bare white
wall.
- H(b) is the latest first failed even check over rows with at most b black cells.
- I320 proved in Lean that a finite H(b) for every b is equivalent to Q01, and computed H(b) sharply to b = 18.
- I324's first test: *a uniform bound on how much a relevant added black can delay failure from a prefix with a
  known deadline*.

**Why the test matters.** In I320's sparse tree, a node y fails at d, and its children are y + 2^p for p from y's
width to d. Call d(child) − d the *delay*.
- **If the delay were at most a constant C,** then H(b + 1) ≤ H(b) + C. The deadline would be linear in the budget,
  and Q01 would follow from one local bound.
- **If not,** the test fails as stated.

## What was computed

[claudeM5_sparse_delay.cpp](claudeM5_sparse_delay.cpp) is written apart from I320's two programs. It uses 256-bit
rows, a check of kit #367 at every even child below the failure, and threads over subtrees.
- **The check.** Its preorder output to weight 18 has SHA-256 `16c5fc6d4a933269…`, I320's digest exactly, and the
  tree has I320's 4,684,155 nodes.
- **The second program.** [claudeM5_width_deadline.cpp](claudeM5_width_deadline.cpp) restricts the tree by width
  instead of weight.

**The deadline to 22 black cells (COMPUTED,** [tree](data/claudeM5-sparse-tree-22.txt), 159,179,602 nodes):

| b | 18 | 19 | 20 | 21 | 22 |
|---|---:|---:|---:|---:|---:|
| H(b) | 132 | 138 | 148 | 154 | 162 |
| nodes of weight b | 2,743,214 | 6,622,871 | 15,996,430 | 38,612,909 | 93,263,237 |

The steps H(b + 1) − H(b) for b = 1 to 21 are 4, 6, 4, 2, 6, 8, **16**, 6, 10, 8, 10, **16**, 4, 6, 2, **16**, 6, 6,
10, 6 and 8. None exceeds 16.

## The delay is not uniformly bounded (COMPUTED)

**Within the weight-capped tree.** The largest delay of a child grows with the weight: 20 by weight 7, 36 by 14,
44 by 16, and 54 by 21. That is far beyond the deadline's largest step.

**Exactly, by the parent's failure.**
- **The bound.** A node's width never exceeds its failure tick plus one. So every parent that fails at d, and every
  one of its children, lies in the tree of width d + 2, which is finite.
- **The computation.** The width-52 tree ([output](data/claudeM5-width-deadline-52.txt)) therefore gives m(d), the
  largest delay over all parents failing at d, exactly for every even d up to 50:

| d | 2 | 6 | 10 | 14 | 20 | 24 | 30 | 34 | 38 | 42 | 46 | 50 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| m(d) | 4 | 6 | 20 | 18 | 16 | 20 | 36 | 28 | 36 | 34 | 38 | 46 |

- **The child that attains it.** It is almost always the repairing child p = d. By kit #367 it keeps the readings
  before d and turns the failed one black.
- **The weight cap.** The weight-22 tree reaches the exact m(d) for every d up to 46, and falls short beyond: 34
  against 38 at d = 48, and 42 against 46 at d = 50.

**The width bound.** A child has width at most d + 1, so m(d) ≤ LD(d + 1) − d, where LD(W) is the latest failure
over rows of width at most W.
- **LD(W).** It reaches 30 at W = 11, 66 at W = 31, 76 at W = 40 and 96 at W = 51: about 1.85 per unit of width.
- **Attained?** The bound is attained at d = 10, 30 and 50, but not always: m(12) = 16 against LD(13) − 12 = 18.

**So the delay that one more black cell allows grows about linearly with the failure it repairs.** No constant
bounds it.
- **What a bound by d would give.** A bound m(d) ≤ g(d) gives H(b + 1) ≤ g(H(b)) + H(b), so a finite H at every
  budget. But such a g exists exactly when LD(W) is finite at every width, which is Q01 in its width form (K92.2).
- **The upshot.** The weight route and the width route are one question, and I324's uniform-delay test fails.

## What the data do bound: the frontier

The deadline's own steps stay at most 16 through b = 22, although single nodes are delayed by up to 54.
- **Where the large delays sit.** They occur at parents well inside the frontier, and their children land below the
  deadline.
- **Not nested.** The latest rows are not nested. At weights 8, 11, 13 and 19 to 22, no maximizer's parent maximizes
  its own weight.
  - Through weight 21 they share a 13-cell prefix: 0, 1, 6, 7, 8, 11, 12, 27, 47, 54, 61, 64, 74.
  - At 22 two new families appear, beginning 0, 1, 5, 6, 7, 8, 10, 23 and 0, 2, 4, 6, 7, 8, 10, 23.

**CONJECTURE: H(b + 1) ≤ H(b) + 16 for every b.** It would give H(b) ≤ 16b and so Q01, with a linear weight floor.
- **The evidence.** It is only 21 steps of data.
- **The 16.** That the largest step equals the left edge's clock period through wheel 87,866 may be a coincidence.
  I have not tested it.
- **What a proof would need.** Control of the frontier as a whole: that a latest row of weight b + 1 extends some row
  of weight b failing near H(b). The non-nesting shows that the parent need not be a maximizer.

## Predictions

Registered in `5c3db07`:

| | Prediction | Outcome |
|---|---|---|
| D1 (95%) | some child's delay exceeds 16 | **held**: 54 |
| D2 (85%) | the largest delay over d in [40, 79] is at least twice that over d in [0, 19] (weight 20) | **held**: 44 against 20 (54 at weight 22) |
| D3 (70%) | for d ≤ 30, the largest delay at d equals LD(d + 1) − d | **failed**: m(12) = 16 against 18; it holds at 10 and 30, not at every d |
| D4 (60%) | H(19) in [134, 146] and H(20) in [136, 152] | **held**: 138 and 148 |
| D5 (60%) | at some weight from 13 to 20, no maximizer has a maximizing parent | **held**: 13, 19 and 20 |

**After the registration (not registered):**
- **The width program** and the exact m(d).
- **A correction to the frozen program's header comment.** It said every finite row is a node. A row outside the tree
  inherits the failure of the node it extends. The code and its output are unchanged: the digest still matches.
  Frozen hash `f7fc8643…` → `de998ddf…`.

## Assessment

**Does this pull move us towards a solution or partial solution for a prize problem?** Not by its named step.
- **The first test fails.** One more black cell can delay a failure by about as much as the failure tick itself, so
  no local, uniform bound turns the weight deadlines into Q01. Any bound by the failure tick is the width form of Q01.
- **What survives** is a frontier statement, the steps of H at most 16. It is supported by 21 steps and has no
  mechanism.

The fresh-choice test gives no warm move. **I propose parking K92.2.A at W1**, for the owner's word. Reopen it with:
- a mechanism by which the latest row of weight b + 1 extends a row of weight b failing near H(b), or any proof of
  H(b + 1) − H(b) ≤ C;
- or a reason tying the frontier's largest step, 16, to the edge clock.

Its parent K92.2 stays open.

Felt: doubt, mild, that a uniform delay bound could exist when single children jump far. -> Measured m(d) exactly.
Outcome: right; it grows like d. Felt: surprise, the frontier never steps more than 16. -> Recorded as a
conjecture, not tested further. Two verdicts. Reasoned: the uniform-delay route is refuted (COMPUTED); the weight
route is the width route. Gut: park it; the 16 is worth one look by someone who knows the edge clocks.

My own pull: test the step bound against the edge clock. That means checking whether each step of 16 ends at a
maximizer whose new black cell falls in a fixed phase modulo 16.

## Files and replay

| File | What it does |
|---|---|
| `claudeM5_sparse_delay.cpp` | `tree B THREADS`: nodes, deadlines, maximizers and delays to weight B; `digest B`: I320's preorder output |
| `claudeM5_width_deadline.cpp` | `WMAX THREADS`: LD(W) for W up to WMAX, and the exact m(d) for d below WMAX |

```sh
clang++ -O3 -std=c++17 -o sparse_delay research/phase2/gemini/claudeM5_sparse_delay.cpp
./sparse_delay tree 22 10
./sparse_delay digest 18 | shasum -a 256     # 16c5fc6d4a933269…, as I320
```

**Credit.** The sparse tree, the deadlines to 18, the equivalence with Q01 and the pull are gptIntel's (I320, I324).
AIOvernight's Sparse16 certified the 16-cell case, crediting Patto1155 and Placego (PRIOR-ART P99). Kit #367 is the
trace-prefix rule. The width form is K92.2's (N38, M224). The deadlines past 18, the delay measurements, m(d), LD(W)
to width 52 and the step conjecture are this block's.

Record searched: find_known for Sparse16, sparse, deadline, budget, one more black, first failure and weight floor;
PORTAL's Sparse16 entry; PRIOR-ART P99; KIT-INDEX's `Rule30ZeroCoastBridge` (#367); I319, I320, I324, `sparse.md` and
`sparse_wall.py`; N38 and M224.
