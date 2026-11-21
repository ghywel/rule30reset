# Which controls share Rule 30’s spatial reset and first-check degree?

Q01 asks whether every finite start beside a white wall eventually has a white cell at depth one at an even tick.
The alternating 90/150 hybrid and the planted system each have a finite row that stays black there at every even tick.
A proposed sufficient condition for Q01 fails if either system satisfies all its hypotheses.

The **spatial reset** is a run of 3m+1 black cells flanked by two whites, with the wall at depth zero available as
a white flank. The table asks whether this word occurs at tick 0, 1 or 2 for every nonzero finite start.
The **first check** fixes the depth-one cell black at even times and takes its odd-time values as free bits
f₀, …, fₙ₋₁. It reads depth 2n+1 of the physical starting row reconstructed from that trace.
The degree is the highest order of a nonzero monomial in the check’s Boolean polynomial over GF(2).

| System | Spatial reset by tick 2 | First check with n ≥ 1 free bits |
|---|---|---|
| Rule 30 | Yes. Tick 2 is sharp in the kit. | Degree n for odd n and n−1 for even n. |
| Rule 90 | No. The width-four seed `0111` misses on all three rows. | Constant. It is white exactly when 3 divides 2n+1. |
| Rule 150 | Yes. The outer edge is isolated by tick 1. The seed `11` needs one tick. | Constant black. |
| Alternating 90/150 hybrid | Yes. The outer edge is isolated by tick 2. Its immortal seed `11` needs both ticks. | Degree 1 for every n. Both colours occur even among finite immortal starts. |
| Planted system at L ≥ 1 | Yes for every L. The seed `11` first resets at tick 2. | Below n=L it agrees with Rule 30. From n=L onward, for n≥2, the degree is n for even n and n−1 for odd n. At n=L=1 the check is identically zero. |

These two rows apply at all widths. The predecessor, twin and healing entries retain the hypotheses and evidence in ledger K43–K44.

## Why the reset occurs

1. At an **odd** outermost depth k the hybrid applies rule 150. If the inner neighbour is white, the outer cell
   is already isolated. If it is black, the two black bits cancel at depth k on the next tick, while the new
   outer cell at k+1 is black. An even top becomes odd after one tick. The immortal seed evolves as
   `11 → 011 → 1101` in increasing depth order. The first isolated outer cell appears in the third row.
2. Rule 150 has the same cancellation at **every** outer depth. Rule 90 has the counterexample
   `0111 → 11011 → 110111`. All the delimited black runs in these three rows have length two or three.
3. For L≥1 the planting map leaves depths 1 and 2 fixed. A changed cell requires agreement below it with the
   stripe, which begins `10`. Any row that changes therefore already has `010` at the wall, and its relabelled
   row has the same prefix. For an ordinary finite inverse image the Rule 30 theorem transfers along the conjugacy.
   The exceptional planted seed itself begins `10` and already has the word at tick 0. More generally, a planted
   trajectory and its conjugate Rule 30 trajectory agree on the existence of a spatial reset at every tick.

The hybrid is consequently a counterexample to deriving Q01 from edge advance and the occurrence of the reset word
alone. An argument that uses what the word *does to a predecessor* has an additional hypothesis.

## What planting changes in the degree calculation

1. Write Cₙ(f) for the Rule 30 check at depth 2n+1. When n ≥ L, planting toggles this cell exactly
   where the first 2n seed cells agree with the fixed stripe. Reconstruction is triangular, so this prefix
   agreement is equivalent to having every one of the n odd-time free bits black. In physical seed coordinates,

   ```text
   planted check = C_n(f) XOR ([n ≥ L] · f₀ · f₁ · … · fₙ₋₁).
   ```

2. Thus only the coefficient of the full product toggles. For every n≥3 the Rule 30 coefficient of the product
   omitting the **third** free bit is one. The proof fixes that bit white and sums the kit’s last-bit derivative
   over the remaining cube. At n=3 the check and its time-one correction have parities one and zero.
   The derivative preserves both parities. This supplies the lower bound n−1 when the full product cancels.
3. In the opposite clock phase the physical check is at even depth 2n. Planting fixes every even depth,
   so the whole function agrees with Rule 30 and has degree n for every n≥1.
4. The hybrid reconstruction preserves ternary XOR on the free bits, so its first check is affine. The kit’s
   family of finite immortal rows has a free parameter that sets the colour at both depths 4j+3 and 4j+5.
   These pairs cover every odd check depth from 3 onward, giving nonconstancy for every n≥1.

The planted system retains unbounded degree in both phases. The exact parity pattern of the main-phase degree
distinguishes Rule 30 from each fixed plant once the threshold is reached.

## What the counting barrier covers

At a width bound W and horizon t, the planted survivor count equals Rule 30’s count plus one exactly when
W≥2L−1 and t≥2⌈W/2⌉. At every other point the counts agree. Given any finite table one may choose L large enough
for agreement throughout it. The full width-and-time table contains the extra survivor. This distinction corrects
the shorthand in M10 and K43. The count formula and Rule 30 degree are prior kit results.
[Rule30PlantedSurvivor](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30PlantedSurvivor.lean) ·
[Rule30FirstCheckDegree](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8eb17a7cb2eeee1817e2d42241157c71b5/lean/Ruliology/CellularAutomata/Rule30FirstCheckDegree.lean)

## Replay

From the repository root, with Lean 4.35.0 and the kit at `40017e8`, run

```sh
cd Rule30PrizeKit/lean
lake build Ruliology.CellularAutomata.Rule30HybridWall Ruliology.CellularAutomata.Rule30WallDeadlines \
  Ruliology.CellularAutomata.Rule30ResetFreeThree Ruliology.CellularAutomata.Rule30PlantedSurvivor \
  Ruliology.CellularAutomata.Rule30FirstCheckDegree
for proof in ../../research/m10/*.lean; do
  lake env lean "$proof" || exit 1
done
```

The physical witnesses and all-width statements are in
[hybrid reset](Rule30HybridReset.lean), [uniform-rule resets](Rule30UniformReset.lean),
[planted reset](Rule30PlantedReset.lean), [linear first checks](Rule30LinearFirstCheck.lean) and
[planted first checks](Rule30PlantedFirstCheck.lean).
