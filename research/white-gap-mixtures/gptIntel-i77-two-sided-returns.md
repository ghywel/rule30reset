# A black sample needs room on both sides of its mark

**COMPUTED, with checked LRAT (I249–I250).** Consider an eventual periodic Rule 30 column of isolated black pulses, with at least nine white ticks after each pulse, in a row with a leftmost black cell. N12 requires some marked phase to have a non-eventually-periodic sequence of samples. Here a mark is the pulse at the bar below, and its sample is the bit immediately to the right two ticks after the pulse.

```text
a  12  14  12  12  10  9  |  10  b        a ∈ {10,14}, b ∈ {10,12}
```

R121 gave at least thirteen pulse intervals between successive marks, and excluded a black sample at the later mark when the separation is thirteen. The new tests exclude black at **either** mark for separations **13, 14 and 15**. A varying mark therefore needs at least sixteen pulse intervals on both sides, including across the cyclic wrap. [Nine-gap transfer](gptM5-n12-return-read.md) · [R121 physical continuity](gptM5-physical-returns.md)

For m ≥ 2 marks in a period, the two adjacent cyclic separations at a varying mark are distinct. All other separations are at least thirteen, which gives **p ≥ 13m + 6** for the number p of pulses. For m = 1 the two sides are the same cyclic separation p, giving p ≥ 16 from this argument. With the earlier lower bound of eighteen pulses, any qualifying period of **18–31 pulses** has exactly one marked phase. The eight legal gap sizes are 9–16 by ResetMixtures. The marked factors are disjoint and each costs at least 108 ticks, excluding the spacer. Equivalently each separation of d pulses costs at least 10d + 18 ticks. Thus m ≥ 2 also gives a time period of at least 148m + 60 ticks. [Earlier period census](periodic-gap-requirements.md)

## Keeping the same right row between gaps

Use the same width-29 all-gap recurrent component as R121. A hypothetical column eventually projects there since the recurrent physical tail must use both sample colours. The sample at a pulse row r is black precisely when its first bit is white or its second and third bits are both white. Propagate sets of rows from both ends of the two-factor word, intersecting with that black predicate at the chosen mark in both passes. The resulting sets are necessary domains for the physical row at every pulse. The CNF uses these domains and the labelled graph edges. Every gap choice is evaluated inside one shrinking physical right cone. In particular the next pulse's far cells come from the same initial row.

| Pulse separation | Earlier mark black | Later mark black |
|---:|---|---|
| 13 | UNSAT, 760,586 clauses | UNSAT, 523,364 clauses |
| 14 | UNSAT, 828,921 clauses | UNSAT, 625,306 clauses |
| 15 | UNSAT, 938,369 clauses | UNSAT, 820,109 clauses |

Both `cake_lpr` and `lrat-check` accepted each refutation. The 14+14 three-mark check with the middle mark black has its own checked refutation. Removing the recurrent constraints from the 13-pulse later-black test gives a **272-tick physical witness**, with samples white then black. In a separate control, the 14-pulse later-black crop starting at pulse 8 and ending at pulse 22 is satisfiable while respecting the full word's projected domains there. Its full cone is unsatisfiable. These controls show why the isolated mark or a short suffix misses the obstruction.

## The 37-tick obstruction

In the 13-pulse earlier-black case, the narrowest obstruction found uses only pulses 3 through 6, before the first marked sample. The 29-cell projected domains are listed in pulse order, using the nearest cell as the low bit.

| Pulse | Required 29-cell rows | Surviving 30-cell rows from pulse 3 |
|---:|---|---|
| 3 | 25205029, 377526565, 427858213 | Both 30th-bit choices for each |
| 4 | 397669413, 515109925 | 934540325, 1051980837 |
| 5 | 204655685, 405982277 | 741526597 |
| 6 | 38068261, 71622693 | Empty |

An independent enumeration through the gaps (12, 12, 10) gives the counts 6, 2, 1, 0. Both shorter two-gap crops have continuous witnesses, lasting 26 and 24 ticks respectively. The full physical crop has 1,939 variables and 14,283 clauses, and both LRAT checkers pass. `Rule30MarkedReturnSeam.no_continuous_seam` isolates the physical implication from the four explicit projected domains. The separate width-29 computation supplies the domains for the marked-return application. [Conditional Lean source](Rule30MarkedReturnSeam.lean)

## Parking decision

No new submission. The results improve the cyclic spacing restriction at every period length, but the proof relies on the width-29 recurrent reader and N12's computed nine-gap localization. The local seam only checks the physics once its four domains are known. S8 already gives the submitted three-gap necessity. Keep R117’s unconditional close-return capture as a separate existing Lean result. Reopen I77 for a compact invariant that derives the pulse domains, a period-independent argument bounding the motion of the hidden disagreement through a mark, or a continuous recurrent history with a black mark between two returns that exposes what can pass.

## Reproduction

The source uses Python with NumPy and SciPy, CaDiCaL, `cake_lpr` and `lrat-check`. Use `g29.bin` from the R121 bundle, SHA-256 `d79529fa600d360a0893034d2cee58c1a72b6de15b58cb56984a4d610420df1f`. Keep the output in a scratch directory. The larger CaDiCaL proofs initially exceeded the default CakeML heap. The evidence bundle includes their dependency slices, still checked against the original CNFs by both checkers.

```sh
python check-i77-mark-context.py g29.bin out/first13 13 --black 0
python check-i77-mark-context.py g29.bin out/seam13 13 --black 0 --crop 3 6
python check-i77-mark-context.py g29.bin out/free13 13 --black 1 --free
python check-i77-mark-context.py g29.bin out/last15 15 --black 1
```
