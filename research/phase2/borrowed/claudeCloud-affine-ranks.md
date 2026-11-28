# K92.5.A: no two-coordinate affine rank certifies Q01

claudeCloud, ledger K107 (registration) and K108 (results). Pull K92.5.A asks whether a two-coordinate affine rank
can certify mortality at the white wall by descending strictly on one recurring residue class. A yes would give Q01.
This note answers no for two coordinates, at every entry size, in both reading directions and for both classes. It
also registers the next class, three coordinates. The answer concerns the certificate class, not Q01: the believed
truth, that every finite row dies, is untouched.

## The setting

The kit's white wall in integer form is `F(y) = (y >> 1) ^ (y | (y << 1))`, with depth 1 in bit 0, and `G = F ∘ F`. A
surviving double step has `y` and `G(y)` both odd. An immortal row visits 1 and 3 mod 4 cofinally (the kit's
`free_not_eventuallyPeriodic`). So a natural rank that never rises on a surviving step and falls on every surviving
step from one chosen class gives Q01: `PrefixRank.q01_of_marked_rank`, for class 1 or 3, in core Lean (I317).

A two-coordinate interpretation lets each letter act by `T_b(x) = A_b x + c_b` on pairs of naturals, with
nonnegative integer entries, and starts from a vector `v`. There are two readings:

- **wall first.** Bit 0 is applied first and the top bit last. This is `PrefixRank.value` on the edge-first word,
  K107's screen, and the "concrete remaining test" of [termination-transfer.md](termination-transfer.md).
- **top first.** The top bit is applied first.

The rank is the first coordinate. In "form 1" the second coordinate must not rise either.

Write `Ψ = T_1`, `Z = T_0`, `A = A_1` and `c = c_1`.

## The frozen screen (K107)

[Code](claudeCloud_affine_rank.c) `22caa3f8…`, [predictions](data/claudeCloud-affine-rank-predictions.txt). Every
interpretation with all fourteen entries in 0 … E and `v ≠ 0` was read wall first, strict at 3 mod 4.

| Run | Interpretations | Stand below 2⁴ (form 0 / form 1) | Stand below 2⁶ and beyond |
|---|---|---|---|
| E = 2, rows to 2¹⁶ | 4,251,528 | 8,014 / 183 | 0 |
| E = 3, rows to 2¹⁴ | 251,658,240 | 208,457 / 2,051 | 0 |

[E = 2 output](data/claudeCloud-affine-rank-16_2.txt) · [E = 3 output](data/claudeCloud-affine-rank-14_3.txt).
**R1 (90%) holds, R2 (85%) holds and R3 (70%) holds.** No survivor reached 2⁶, so no follow-up test was due.

**Development, reported as such.** For each interpretation with entries in 0 … 3, a mask was recorded of the steps
from rows below 2⁶ that it satisfies. Then the smallest unsatisfiable sets were found. Reading wall first, the single
strict step 27 → 111 is unsatisfiable on its own for class 3. For class 1 the single step 13 → 55 is unsatisfiable,
and so is 53 → 221. Reading top first with entries 0 … 2, 27 → 111 alone again kills class 3. Class 1 then needs a
pair: 3 → 13 with 13 → 55, or 3 → 13 with 53 → 221. Both 111 = 4·27 + 3 and 55 = 4·13 + 3 hold: the double step
inserts `11` at the wall. That points to a proof.

## The theorem

**Theorem.** Take any two letter maps `T_b(x) = A_b x + c_b` on ℕ² with nonnegative integer entries, any start
vector `v ∈ ℕ²` (zero included), either reading, and any rank `ρ : ℕ² → ℕ` that is monotone for the coordinatewise
order. No such rank `ρ(state(y))` is weakly decreasing on every surviving double step and strictly decreasing on
every surviving step from one class, for class 3 or for class 1. One of three witnesses always fails: 27 → 111,
13 → 55, or the chain 3 → 13 → 55.

The rows: `G(3) = 13`, `G(13) = 55` and `G(27) = 111` are all odd, so all three steps survive. 3 and 27 are 3 mod 4
and 13 is 1 mod 4. Their letters, bit 0 first, are 3 = `11`, 13 = `1011`, 27 = `11011`, 55 = `111011` and
111 = `1111011`.

**Lemma.** Let A be a 2×2 matrix of nonnegative integers with A² ≠ 0. Then A³ ≥ A entrywise.

*Proof.* Take an entry with `A_lj > 0`. If `A_ll ≥ 1`, then `(A³)_lj ≥ A_ll² A_lj ≥ A_lj`, and likewise if
`A_jj ≥ 1`. Otherwise `l ≠ j`, because `A_ll = 0 < A_lj`, and both diagonal entries are zero. Then A is
[[0, p], [q, 0]], with A² = pq·I ≠ 0, so pq ≥ 1 and A³ = pq·A ≥ A. ∎

So A^(k+2) ≥ A^k for every k ≥ 1, multiplying by A^(k−1). Then

`Ψ^(k+2) x − Ψ^k x = A^k (Ψ² x − x) = (A^(k+2) − A^k) x + A^k (A + I) c ≥ 0`   for every x ∈ ℕ² and k ≥ 1.

If instead A² = 0, then `Ψ² x = Ac + c` is a constant κ.

*Proof of the theorem.* Reading wall first, let `H = Ψ ∘ Ψ ∘ Z` (Z applied first). Then
`state(13) = H(Ψ v)`, `state(55) = H(Ψ³ v)`, `state(27) = H(Ψ² v)` and `state(111) = H(Ψ⁴ v)`. Reading top first,
let `w = Z(Ψ² v)`. Then `state(3) = Ψ² v`, `state(13) = Ψ w`, `state(55) = Ψ³ w`, `state(27) = Ψ² w` and
`state(111) = Ψ⁴ w`.

- **If A² ≠ 0:** `Ψ^(k+2) ≥ Ψ^k` holds pointwise, and `H` has a nonnegative linear part, so it preserves the order.
  In both readings `state(111) ≥ state(27)` and `state(55) ≥ state(13)` hold coordinatewise. The strict step at 27
  fails for class 3, and the strict step at 13 fails for class 1.
- **If A² = 0:** `Ψ²` is constant. Reading wall first, `H` is constant, so state(111) = state(27) and
  state(55) = state(13), and both strict steps fail. Reading top first, state(111) = Ψ⁴ w = κ = Ψ² w = state(27),
  so class 3 fails. For class 1, state(55) = Ψ³ w = κ = Ψ² v = state(3). The weak step 3 → 13 and the strict step
  13 → 55 would give ρ(state(55)) < ρ(state(13)) ≤ ρ(state(3)) = ρ(state(55)). ∎

Because the comparisons are coordinatewise or equalities, the theorem covers K107's form 0 and form 1, any monotone
readout (a coordinate, a sum, a weighted sum) and descent in any order on ℕ² that extends the coordinatewise order,
lexicographic order included. It also covers `v = 0`.

**Check.** [claudeCloud_affine_two_check.c](claudeCloud_affine_two_check.c) `b7868692…` tests all 268,435,456
interpretations with entries in 0 … 3, `v = 0` included. In both readings it confirms state(111) ≥ state(27).
Reading wall first it confirms state(55) ≥ state(13). Reading top first it confirms state(55) ≥ state(13) or
state(55) = state(3); the equality case settles 5,818,368 interpretations. It also checks both matrix lemmas on all
194,481 matrices with entries in 0 … 20. There are 0 failures.

**Relation to I317.** [termination-transfer.md](termination-transfer.md) proves the bottom-initialized case in every
dimension with prefix witnesses. It proves the scalar case with any terminal value, using the same rows (13 → 55 and
27 → 50 → 111). The theorem here lifts the scalar case to two coordinates: the lemma takes the place of "a slope is
zero or both maps are inflationary". It also settles the proposed test, that is edge-first words, a nonzero end
vector, coordinatewise weak descent and strict descent at 3 mod 4, for every entry size.

## Why three coordinates may escape, and the next screen

The lemma fails in three coordinates. If A is a 3-cycle permutation, A³ = I, so A³ ≥ A fails, and A⁴ = A is not
comparable with A². Inserting `11` at the wall then need not raise the state. The rows give no obstruction in higher
dimension either. For a D×D nonnegative integer matrix M, M^(j+L) ≥ M^j holds for j ≥ D with L = lcm(1, …, D):
insert copies of the first cycle of each walk. A general block would therefore need surviving segments that repeat a
wall-side block at least D times. But `1^k 011` dies immediately for k ≥ 3, since its low bits are `111`.

The next screen, registered in K108 before any three-coordinate run, uses
[claudeCloud_affine_rank3.c](claudeCloud_affine_rank3.c) `4a9e3615…`, with
[predictions R4–R7](data/claudeCloud-affine-rank3-predictions.txt). It covers entries 0 … 1 (117,440,512
interpretations), both readings and both classes, on rows to 2¹⁴. Its D = 2 mode reproduces the frozen
two-coordinate screen exactly.
