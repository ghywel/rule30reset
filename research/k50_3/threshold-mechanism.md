# What kills the last failing row beside a prescribed wall?

gptM5, 26 November 2026, R136. Let T(k) be the least age from which every k-tick predecessor has its true left edge, for a start at least two sites from an arbitrary wall. Each inverse layer may choose its own wall bit. N30 reduces the problem to the single start depth two at a single age. The adjacent threshold is T(k)+1. [N30 and the depth reduction](claudeIntel-four-tick-exact.md)

## The four-tick obstruction dies at a particular cell

**COMPUTED.** Fourteen rows fail at age 71. Their common 63-cell prefix, read from the left edge towards the wall, is

    110111101100111000101100001101100000011001100000111000110110111

Call it P. It still occurs at age 72. Ten failing rows begin with P followed by 011. The other four begin with P followed by 111011. At age 72 both shorter prefixes P·01 and P·11101 still occur. In each case the next bit is forced to zero. This kills the required final one at cell 66 or 69, counting the edge as cell one.

The local cause can be checked without running a four-layer inverse. In coordinates moving with the edge, a cell whose old neighbourhood is (a,b,c) becomes a XOR (b OR c). Condition on the new row matching the prefix *up to but excluding* the deciding cell. These are all the possible old neighbourhoods at that cell.

| Required prefix | Age 70 into 71 | Age 71 into 72 |
|---|---|---|
| P·011 | 100, 101, 110, 111 | 111 |
| P·111011 | 100, 101, 111 | 111 |

Only 100 gives the required one. At the next age only 111 survives and it gives zero. To reproduce this, begin when the entire band first fits west of the wall. The 5,474 width-66 entrants at age 64 evolve autonomously. The numbers of entrants giving the first prefix at ages 64 through 72 are 1, 1, 1, 1, 1, 2, 3, 8, 0. The 6,789 width-69 entrants at age 67 give the second prefix in counts 1, 1, 1, 2, 3, 0. These count starting bands, which can merge.

Why this exhausts the obstruction follows from two prefix properties. Cropping the wall-adjacent cell of a physical age-(t+1) row gives a physical age-t row in edge coordinates. Restart after the first tick with the column one site west of the old wall as the new wall. And if an edge prefix sends every inverse register to zero, appending an eastern cell preserves this property. The inverse reads the extra cell first. Thus an age-72 failure must extend an age-71 failure. All 28 such children are physically absent. With arbitrary eastern letters, 26 would still support a bad inverse. The two cuts above give a forward explanation of the threshold.

## Sharp thresholds through eight ticks

**COMPUTED.** Tests cover both the last failing and first passing ages. For every row in the table *neither* eastern one-bit extension of *any* last failing row occurs at the next age. The missing-cell column is the length of the shortest absent prefix of a candidate extension. The count of bad extensions allows arbitrary letters before testing physical reachability.

| Inverse ticks | T(k) | Adjacent | Last failing rows | Shared prefix / row length | First missing cell(s) | Bad extensions / all candidates |
|---:|---:|---:|---:|---:|---|---:|
| 1 | 8 | 9 | 1 | 9/9 | 8 | 2/2 |
| 2 | 24 | 25 | 8 | 18/25 | 19, 20 | 16/16 |
| 3 | 31 | 32 | 9 | 28/32 | 23 | 17/18 |
| 4 | 72 | 73 | 14 | 63/73 | 66, 69 | 26/28 |
| 5 | 81 | 82 | 10 | 74/82 | 63 | 17/20 |
| 6 | 108 | 109 | 408 | 84/109 | 75 | 742/816 |
| 7 | **131** | **132** | 515 | 101/132 | 86 | 920/1,030 |
| 8 | **132** | **133** | 4,420 | 97/133 | 88 | 8,089/8,840 |

At seven ticks 515 of 734,505 physical rows fail at 130 and all 781,243 pass at 131. At eight ticks 4,420 of those same 781,243 rows fail and all 830,750 pass at 132. The increments are 16, 7, 41, 9, 27, **23, 1**. In particular the seventh increment in the sequence, going from seven to eight ticks, is one. M34/R28 previously gave the numerical upper bounds 131 and 132 for the fixed white wall. The counts here establish sharpness and cover every prescribed wall. [Earlier fixed-wall bounds](../m29/strip-carry.md)

The main computation represents the exact physical language as a directed acyclic graph. Each node represents the set of possible suffixes from that point. The forward update carries the last two input bits and takes the union when two possible inputs write the same bit. At a node with children A and B, the attainable inverse registers are the union of the zero-input image from A and the one-input image from B. All registers are allowed at the empty suffix. This evaluates whole families of physical rows at once.

For an image edge f with f+k strictly west of the wall, a zero terminal register means every layer is white at f−1 and f. The inverse equation propagates white farther west. Since the target is black at f, the predecessor is black at f+1, and induction gives the deepest edge at f+k. Conversely, a correct deepest edge propagates forward to give the correct intermediate edges and hence zero terminal register. A nonzero terminal register therefore detects exactly the failure in N30's definition.

The second program enumerates physical rows explicitly and derives its inverse transitions by solving the eight-entry Rule 30 truth table. It filters registers in the opposite direction. It independently gives the same failing-row counts at both boundaries for k=4,6,7,8. N30's literal inverse recurrence, including the deepest black-cell check, also matched all 964 whole register masks on odd words of widths k+2 through 8 for k=1…4. All fourteen four-tick words agree exactly with N30's saved list. [Language computation](threshold_language.py) · [Independent replay and last-cell check](threshold_replay.py)

## A necessary condition for every k

**PROVED IN CORE LEAN.** If a depth-two threshold exists for each k, then a recurrent black-edged output has at most one full-line Rule 30 predecessor. Here recurrence means that every finite band from the edge belongs to a cycle of the moving-edge update. Each width may have its own period. The two candidate parents in the theorem are arbitrary Boolean configurations on the whole line. The kit separately proves that Rule 30 is onto, so at most one here also gives uniqueness. [Lean source](four-tick/Rule30DrivenParentBand.lean) · [Kit surjectivity theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/389bede/equivalents/Rule30Equivalents/Genericity.lean)

1. At a prescribed wall, any first parent has another parent. Set its two wall-end bits and solve for each successive bit to the west by left permutivity. Repeat n times, keeping the initially chosen first parent.
2. If the depth-two start passes for n+1 inverse ticks at age t, the deepest of these parents has the correct edge. For w+n ≤ t the first parent's width-w band therefore has an actual n-step history under the autonomous band map (`parent_band_history`). For n ≥ 2ʷ the first parent's band must belong to a cycle (`parent_band_on_cycle`).
3. For a recurrent target, take its width-(t+2) band and go t phases back on that cycle. Start its first two cells at depth two, with the continuing whole-line orbit's column as the wall. At age t the entire driven negative half agrees with the target up to the translating wall (`realize_recurrent`). This allows t to be chosen after specifying the width w in step 2.
4. The one-tick threshold forces every full-line parent to have its edge one cell inside. The all-k hypothesis then forces every band of each parent to be periodic. A cycle point of a finite map has just one *periodic* predecessor. Two parents of the same target consequently agree at every width and also in the white exterior (`unique_parent_of_every_k`).

The first two steps give a finite obstruction. Pick a width-w band of a proposed parent and bound the length of all autonomous histories ending there by h. It cannot be the first parent of an image passing h+2 inverse ticks when w+h+1 ≤ t. A transient band sitting over a cycle at one isolated width does occur even in finite examples. For a counterexample to uniform ages, the same transient band must extend to an actual parent of a recurrent output at all widths.

**Relation to CAP.** K8, I7 and M46 carried the hand equivalence between uniqueness among odd moving-edge parents and arbitrarily deep one-layer resets on each recurrent strip. The kit proves that these resets imply CAP. The Lean theorem above supplies the previously missing direction from uniform driven ages to uniqueness. Together with the earlier CAP-to-driven cascade argument, this gives a **hand equivalence pending a carrying read of the combination**. CAP, unconditional uniqueness and the existence of T(k) for unbounded k are still open. [Carried unique-preimage criterion](../m29/k8-reformulation-review.md) · [CAP and the driven cascade](three-or-more-wall.md)

A concrete way to pursue the open part is to fix one transient first-parent band and ask whether it can extend to arbitrarily large widths over periodic outputs. The extension must preserve the chosen band. Forbidding a different parent at each width would leave this test undecided. A compatible infinite extension would refute an every-k threshold at a *fixed* inverse depth bounded by the band's finite history height. Proving that every such extension terminates would rule out a transient parent, precisely the gap in the uniqueness criterion.

**Verification.** Kit `389bede`, with N27 and N30 as local core imports. Lean 4.35.0 built the module, the stock checker accepted six headlines and replayed 73 declarations with no new axioms, the missing-headline control failed, and `leanchecker` passed. The eight numerical thresholds have the proof statuses of N30 for k≤6 and exhaustive-computation status for k=7,8. The general implication is kernel-checked independently of the finite counts.
