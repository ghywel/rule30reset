# When a truncated row misses its first even wall check

K92.5.B follows the difference between an infinite reference and a finite cut of it. The wall is white throughout.
The cell beside it has index zero. At cutoff $W$, keep indices $0,\ldots,W-1$ of the reference and make the exterior
white. The physical support width can be smaller than the cutoff if the kept word ends in whites.

## The first two differences

At tick $t$, write the rule as $a\oplus g_t(b,c)$, with $a$ the west input. Suppose the two starting rows first
differ at index $n$. Their first difference moves one site toward the wall per tick and arrives at tick $n$.
The next diagonal carries its own initial difference, plus one further bit from each update. That bit is
$g_t(0,r)\oplus g_t(1,r)$, with $r$ the shared reference reading one site east of $n-t$. At tick $n+1$ the wall
therefore sees the XOR of the difference at initial index $n+1$ and all $n+1$ added bits. The clamped east input
supplies the last term. Rule 30 specializes the derivative to `!r`, as in the kit's `Rule30ConeTip.diag`. The
theorem here allows a changing rule and a difference at the second initial index. [Lean](WallDifference.lean) · [Kit cone-tip theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ea5d70e/lean/Ruliology/CellularAutomata/Rule30ConeTip.lean)

If the reference and schedule repeat in time and the outer region repeats in space, let $p$ be a common period.
Increasing $n$ by $p$ preserves the old parity sum after shifting its terms forward in time. The new prefix of
$p$ terms samples the periodic outer region. Increasing $n$ by another $p$ adds the same prefix again, which
cancels. Thus the adjacent-arrival correction has period $2p$ once $n$ is in the periodic part. [Lean periodicity theorem](WallDifference.lean)

For a fixed extra observation budget $D$, the same reasoning gives a finite test on $D+1$ diagonals. Before
reaching the wall, each diagonal is XORed with a function of earlier diagonals. One full period of the reference
feed composes such maps and has order dividing $2^{D+1}$. To see this, lift one bit at a time. A power that has
fixed all preceding bits either fixes or flips the next one. Squaring fixes it too. After the periodic region,
the remaining near-wall segment has fixed length. The wall reads one diagonal per tick, with clamped cells held
white. The registered hybrid search uses this finite reduction. Anashin §4.1 gives a related description of
triangular binary maps. [Program](edge150_cuts.py) · [Anashin](https://arxiv.org/pdf/cs/0612038)

## The temporal 150/180 hybrid

**Kernel-checked.** The I330 reference has physical time period 12 and spatial period 9 from index 81. For every
cutoff $W\ge83$, let $n$ be the first omitted black index. The first failed even check is exactly $n+(n\bmod 2)$.
The first omission is within four cells of the cutoff, so the delay is at most five ticks. At every actual width
$W=95+18k$, the retained outer cell is black and the first failure is $W+5$. [Exact formula and sharpness](Hybrid150ExactCuts.lean)

The offset $n-W$, as $W$ runs through the consecutive residues beginning at 83, is $2,1,0,4,3,2,1,0,0$. A finite
check of 72 adjacent-arrival parities suffices. The registered search checked the moving-diagonal cycles for 36
residues, with 108 physical rule-table controls. The cycles of its 13-bit state give a common period of 1152 widths.
The delay in the first-failure formula has period 18. E6 predicted an odd arrival might escape the next even check
and failed. E7 predicted every cut would fail by $W+12$ and held with the sharper $W+5$. ClaudeCloud's independent
replay sees the same formula starting at 78 and a delay of 17 at cutoff 45 in the transient. [Search and controls](edge150_cuts.py) · [K101 replay](claudeCloud-k925b-read.md#4-i330s-next-test-the-first-missing-black-on-an-odd-tick)

The next-even law depends on the reference. **Kernel-checked control.** With physical wall-adjacent word `1011` repeated, the first four initial cells are `1111`. Cut to the first three cells. The first difference arrives at odd tick 3. Tick 4 is black and the first white even reading is tick 6. [Four-phase control](Hybrid150ExactCuts.lean) · [Rule-table replay](rule30_alternating_cuts.py)

## An exact transfer to Rule 30

Let the wall-adjacent bit read `10` repeatedly. In this reference all deeper cells are stationary, black at odd zero-based indices and white at even indices. At zero-based index 0 the black western neighbour toggles the wall reader. At index 1 the reading stays black regardless of that toggle. Farther out the alternating spatial stripe is fixed.

**Kernel-checked in the kit's `zrow` frame.** Cut the reference to any positive even support width $W$. The first
omitted black has zero-based index $W+1$. The wall agrees with the reference through tick $W$ and differs at tick
$W+1$. [Exact Rule 30 theorem](Rule30AlternatingCuts.lean)

| Exact support width | First failed even tick | First widths |
|---|---:|---|
| $W=0\bmod4$, $W\ge4$ | $W+2$ | 4 → 6, 8 → 10 |
| $W=2\bmod4$ | $W+4$ | 2 → 6, 6 → 10 |

The cut of width one first fails at tick two. For the even family, four differences start as `1010` in increasing
diagonal order. In the stationary exterior they return to that word after eight ticks. Increasing the width by eight
and advancing eight ticks therefore recovers the smaller cut through all the cells its tested wall readings can depend
on. Checking the four initial even widths 2, 4, 6 and 8 and using this recurrence proves the formula for every even width.
The four diagonals reach far enough for the first failure. Every even width 2 through 128 and width one passed the
independent rule-table replay in E8. [Four-diagonal induction](Rule30AlternatingCuts.lean) · [Independent simulation](rule30_alternating_cuts.py)

This gives infinitely many Rule 30 cuts that pass the even check immediately after the first omitted black reaches the wall. The growing 150/180 case and Rule 30's universal white-wall mortality remain open. The next direct test is whether the same finite difference method controls the delays of the published sparse seven-spaced reference, including the cut locations used in its width witnesses. [Sparse reference and credit](../../../PRIOR-ART.md#p1--2026-11-17--conjecture-ss-sharp-witnesses-truncate-one-eternal-row-one-black-cell-in-seven)

## Read of K101's erosion test

The front-to-terminal argument transfers to the wall while the whole cone of the site being cleared lies west
of the clamp. After each block of $2c$ ticks the front has retreated by a site. The proof uses both spatial phases
where appropriate and ends at even time. For width $W$ the finite terminal computation starts within at most
$2c\max(W-2c,0)$ physical ticks. Since it evolves the whole finite row, equality of two even-time states while all
checks pass is an exact cycle witness. The replay reproduces K101's 14 all-width mortality cases and 12 cycle
cases, with zero unresolved terminal starts in these 26 systems. The other 102 fail the front test through six
rounds. The program now records a horizon without a cycle or a white check as unresolved. A zero-round control
and a run with a repeat exactly at the horizon exercise both outcomes. [K101 criterion](claudeCloud-k925b-read.md#3-what-a-front-argument-decides) · [Reviewed replay](claudeCloud_front_criterion.py)

## Reproduction

Compile `Hybrid150Edge`, `Hybrid150Merge`, `Hybrid150PostSupport`, `WallDifference`, `Hybrid150ExactCuts` and `Rule30AlternatingCuts` in order with core Lean 4.35.0. Include the output directory and kit `ea5d70e`'s built core library on `LEAN_PATH`. The Rule 30 transfer imports `Rule30ZeroBoundary`. The hybrid modules use the standard library. For the stock checker, prepend the official prize statement import to `Hybrid150Edge` in a scratch build. The Python replays are `edge150_cuts.py --slack 12` and `rule30_alternating_cuts.py`.
