# Recognizing the two period-three words from two sites to the left

Take any ordinary Rule 30 orbit on the integer line. In a window of N ticks let C count black cells at j, and A count horizontal 10s at (j,j+1). Let E count the starting ticks of triples at j+2 that contain other than two black cells. This reads two extra ticks of the target column. All results below allow an arbitrary window onset, including age zero.

## The two-black word 011

Put D = N+6A−3C. The sharp comparison is

```
E ≤ 2D+7                 D ≤ 4E+3.
```

On five consecutive cells one can assign integer potentials so that the one-tick differences E−2D and D−4E are each at most the drop in the corresponding potential. The ranges have diameters seven and three. Summing cancels every intermediate potential. A physical seven-site ring of period four has D=1 and E=2 per period. A stationary alternating row has D=4 and E=1 per tick. With the observed bond starting at site 2, finite seeds encoded by the integers 14 and 224 attain the additive constants in three ticks. The slopes also apply to arbitrary-length finite-seed tests, since a finite seed can agree with each periodic row on the entire backward cone of a given window.

In overlapping triples with exactly two black cells, the bit leaving the triple equals the bit entering it three ticks later. Hence **D stays bounded above exactly when j+2 eventually repeats 011 up to phase**. Otherwise E increases without bound and D tends to infinity. The singleton specialization at j=−2 gives an equivalent formulation of the open two-black period-three centre case. The kit bridge also proves explicitly that the kit's finite-left hypothesis `C3w0 w011` would force D to be unbounded. The hypothesis remains open.

The two density coordinates can be read separately. At each tick a 10 forces a bad triple, and −2E−3 ≤ 3C−N ≤ 4E+3. If V=A+|3C−N|, then V ≤ 5E+3 and E ≤ 12V+7. Consequently (C/N,A/N) tends to (1/3,0) exactly when the fraction of bad triples tends to zero. A zero fraction allows infinitely many exceptions.

A complementary consequence of the kit's ether erosion applies to any row initially white at every site greater than W (W≥0). If site 0 reads 101 in three-tick blocks from age S, both values of site +1 occur at a white phase in every [T,4T+3W+20] for T≥S. At onset zero, writing uₘ for the complement of the white-phase right bit, the two columns immediately to the left read (!uₘ,uₘ,0) and (1,uₘ,0). Both neighbours carry the same remaining irregularity question. The recurrence bound excludes a constant tail in uₘ. Whether it excludes longer periods is the next question.

## The one-black word 001

A reference target repeating 001 forces |3C−2N|≤4 and |3A−N|≤3 on every interval after onset. In a three-tick block the immediate left column has bits (x,y,1) with xy=0. The observed bond fires exactly once, and the black count is 2+x−x′, where x′ starts the next block. Across complete blocks the interior terms cancel. Accounting for both partial ends gives the stated bounds. One ordinary evolution attains both signs of both bounds.

The two scalar density limits do not identify this class. At one observed bond there are periodic solutions with (C/N,A/N) tending to (2/3,1/3) on a width-12, period-three ring and on a width-84, period-six ring. The first has one black target tick in every three. The second has three consecutive black target ticks every six. These are ordinary physical orbits with their spatial and temporal seams checked in Lean.

The **ordered** pair of observed bits carries more information. Compare two ordinary solutions with equal movies at j and j+1 throughout 35 ticks. If the target j+2 of the reference solution spells a fixed phase of 001 throughout, the other target must have the same bit at tick 17, counting the first tick as zero. The condition only pins the reference. The two targets can differ at the middle of a 33-tick observation under the identical promise. The finite seeds 295147769660386472397 and 295139605975528796621 give this example at target site 34.

The upper proof relaxes both right tails to width-13 strips and checks three unsatisfiable formulas, one per phase. The finite seed pair gives sharp symmetric radius 17 for full-line observations. The LRAT proofs pass two independent checkers. The local test is one-sided in its premise: the candidate clock explains the left movie. For an infinite tail, a matching reference at the same phase in each centred window suffices, even if the outside completions change each time. The physical target must then follow that phase. No equivalence between the two density limits alone and eventual 001 follows.

Allowing the target to lie off-centre cuts the shortest observation to **29 frames**. The target is fixed at offset 23, with 23 earlier frames and five later ones. The three width-13 upper certificates passed both LRAT checkers. For each of the 28 possible targets in 28 frames there is a physical finite-seed pair with identical observed movies and opposite target bits. The same holds for every other target offset in 29 frames. All 56 pairs have a scalar replay.

## Other finite-left rows

The growing margins at the two higher-density corners in I72 extend to every row with a leftmost black site L and arbitrary right half. At starting age s put d=j−(L−s)≥0. If N≥(2ᵏ−1)(d+2p+3), then the p=4 deficit 2N+7A−5C is at least k−4, or, using p=10, the deficit 6N+3A−8C is at least k−6. Long zero-loss stretches would force equal columns up to the later moving edge.

## Provenance and replay

Condrey's source count and Quint and Gemini's extension give the density question. Herbert's period-three left and language reductions already distinguish the two primitive words. The driving and erosion argument uses Perez Morales and Claude’s period-three ether erosion and Lowry’s white-tail bound. Our additions are the sharp defect comparison, its consequences at the actual centre, the quantitative white-phase return, and the ordered-movie test with its optimal radius. [Condrey #253](https://github.com/WolframInstitute/Rule30PrizeKit/pull/253) · [Quint and Gemini #297](https://github.com/WolframInstitute/Rule30PrizeKit/pull/297) · [Period-three left reductions](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30EtherThreeLeft.lean) · [Period-three language](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30PeriodThreeLanguage.lean)

The shared I73/quiet-corner.zip includes eight Lean modules, the two local dependencies, the official receipts and a scalar enumeration of all 128 physical seven-cell neighbourhoods. Set RULE30_KIT_CHECKOUT to the official checkout at 40017e8 and run `python replay.py`. The white-phase theorem is separately replayable from I73/quiet-third-gate.zip. I74 holds the six LRAT proofs, explicit CNFs, lower witness and source for the movie result. The ledger records the packet hashes and verification levels.

[Optimal ternary readings and the phase-free defect count (I75)](clock-observers.md).
