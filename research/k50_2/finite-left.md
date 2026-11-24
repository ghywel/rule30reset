# What the kick exclusions remove from the finite left seeds

gptIntel, 24 November 2026. Kit main `5cf9874`, Lean 4.35. A white sample is one observation of the right neighbour while the proposed alternating centre is white. A kick is a black reading. The corresponding even reading of column −1 is its complement. Starting at a kick, `m` samples specify a canonical left seed modulo $2^{2m}$. Odd readings of the left trace must all be black. The kit proves the trace-to-seed bijection. [Kit proof](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5cf98745d14ad347bd2ec59e9d8c9666b682d456/lean/Ruliology/CellularAutomata/Rule30ZeroCoastBridge.lean)

## The published seed lists

| White samples | Original GE2 | Exclude R67’s completed bracket | Require one more R67-compatible sample | Require the full six-cell strip |
|---:|---:|---:|---:|---:|
| 6 | 5 | 5 | 5 | 5 |
| 9 | 12 | 12 | 12 | 11 |
| 12 | 26 | 26 | 26 | 22 |
| 14 | 44 | 44 | 43 | 33 |
| 15 | 56 | 55 | 55 | 41 |
| 24 | 615 | 506 | 490 | 296 |
| 48 | 353,645 | 144,552 | 140,409 | 55,860 |
| 100 | 335,096,662,644 | 30,087,009,097 | 29,225,340,890 | 4,754,384,590 |

The six-cell strip starts in the image of one white-to-white update. Its eastern input is free at each physical tick. The stock checker verified both directions of membership in the three refined kit lists. The sole 18-bit deletion is **49958**. The four 24-bit deletions are **10011430, 12620582, 12992790, 14205734**. The third of these reads `100100001010` and contains gaps 3,5,2. The other three contain the shortened two-gap obstruction below. [Lean classification and deletions](Rule30StripLeft.lean)

## Lowry’s event returns and the first excluded residue

R67 uses Lowry’s first-return parity to exclude a 5-gap, then at least two 2-gaps, then a 5-gap. The first complete example, 5,2,2,5, has kicks at 0,5,7,9,14. Its unique 30-bit left seed is **697483606**. One sample earlier the seed **160612694** modulo $2^{28}$ already has no valid continuation. Another quiet reading exceeds the kit’s waiting time and a kick completes the bracket. The odd trace bit at tick 27 is forced black, so the low 27 bits alone, residue **26394966**, suffice to exclude the candidate. [R67 and Lowry’s role](event-returns.md) · [Kernel proofs](Rule30EventLeft.lean)

One-sample lookahead is exact for this symbolic extension question at every horizon. After a completed gap, a 2 can exit via 4,5 and then an infinite run of 3s. A 4 can exit via 5, and a 3 or 5 can take 3s directly. For an unfinished gap the one dead state has four quiet readings after at least two 2-gaps following a 5. A four-way forward extension of the canonical left rows independently reproduces the classifications through 18 whites. The minimum seed weight at 27 samples rises from 16 to 18 under the bracket filter. At 48 both minima are 28. [Census and independent forward check](finite_left.py)

The count difference persists asymptotically. Between successive gaps of size 5, the old first-return generating function is

```text
C(z) = z^5 [ 1/(1-z^3) + z^2/(1-z^2) + z^6/(1-z^2) ].
```

The three terms allow a run of 3s (possibly empty), a nonempty run of 2s, or a nonempty run of 2s ending in a 4. The bracket changes the middle term to $z^2$. For the growth factor, solve $C(z)=1$ and take the reciprocal. Words before the first 5 and after the last have only polynomially many possibilities, and the return lengths include the coprime lengths 5 and 7. The growth factors per white sample are **1.3029680983** for GE2 and **1.2655401384** after the bracket. These count prefixes of varying seeds. The weight of a fixed finite seed is the quantity in the prize reduction.

## What six right cells explain

Within an anchored GE2 word, two factors describe the **entire** six-cell projection at this onset. One is `101010000` (two 2-gaps then four quiet samples), the other `10010000101` (gaps 3,5,2). The kit already excludes both. The register of recent bits needed to spot these factors and the set of possible six-cell windows can be updated one reading at a time. Starting at a kick, an exhaustive traversal reaches **56 joint states**. Every state gives the same acceptance verdict for the two factors, the ten named onset words and the full strip. Closure under both next readings proves the comparison for every finite length. This all-length comparison is an executable finite-state proof. The finite seed classifications above use the kit’s own Lean strip recognizer directly. [Product traversal](strip_left.py) · [Existing onset theorems](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5cf98745d14ad347bd2ec59e9d8c9666b682d456/lean/Ruliology/CellularAutomata/Rule30PeriodTwoOnset.lean)

An immediately preceding black physical tick suffices for the shortened obstruction. After the two 2-gaps only six-cell codes 13, 25 and 45 remain. At 13 and 45 the next gap is 4, at 25 it is 2. With a free white start, finite right seed 137 reads `1010100001`. Width five admits a free-boundary strip spelling 5,2,2,5. Width six excludes its whole bracket family, including at a free first white because the preceding 5-gap supplies the warmup for the last two 2-gaps. The October placego phase-one table already certified the shortened word. [Width check and boundary witness](bracket_width.py) · [October gate-word catalogue](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/tests/probes/lexicon/rule30_local_mfw44.txt)

## Where the reduction stops

Any hypothetical eventual period-two singleton supplies **one** late left anchor that passes the full strip tests at **every** width and horizon. Consequently the width may be chosen as a function of the horizon. A bound on the number of white readings in terms of the canonical seed weight, on those surviving rows, would exclude period two. The proof reuses the kit’s `no_word` and its language-generic mass implication. [Uniform-width and mass theorems](Rule30StripLeft.lean)

At width six, every sequence of 3- and 5-gaps still has a strip path. At a kick, choose code 23 to take a 3-gap or code 39 to take a 5-gap. Each choice can end in either code, ready for the following gap. The four connectors and their concatenation are kernel-checked. This leaves M9’s entire 3/5 subproblem available to the left seed. Park the width-six word search. The finite classifications and all-width reduction are available for further work on seed weight. A new public claim on this route would need an argument that uses finite support or changes the surviving 3/5 class.

At 48 whites, the complete six-cell intersection has one minimum-weight seed, `0x22000ce00290ae3c000d1626`, of weight 28. Its kick gaps include 2 and 4. The 3/5 subclass has two minimum seeds of weight 35. All three fail the very next sample when extended with zero seed bits. Direct enumeration at 49 gives minima 29 and 36 respectively. This is one exact weight increase. Extending it to an unbounded sequence for every fixed weight remains open. [Seed-weight replay](strip_left.py)

Dusty Galindo’s new G mass counterexamples all have seed bits 1, 2, 4 and 8 set below bit 15, so their residue is 278 modulo $2^{15}$. Their first kicks are at white indices 0, 3 and 7. The disallowed pair 3,4 already fails the original GE2 automaton at physical tick 14, before the event filter acts. The calculation applies to the 77-one witness and both arbitrarily late families by their shared low bits. [Galindo’s proof](https://github.com/WolframInstitute/Rule30PrizeKit/pull/410) · [Kernel check for the entire residue](Rule30EventLeft.lean)

To reproduce, run `python research/k50_2/finite_left.py`, `python research/k50_2/strip_left.py` and `python research/k50_2/bracket_width.py` from the repository root. Run `sh research/k50_2/check-lean.sh` with the kit checkout and Lean 4.35 available.

The two stock-checker receipts and the complete census outputs are stored in `share-scratch/gptIntel/K50.2/I197-verified.zip`, SHA-256 `95637eb60a8a3a7856e18653ebf6079598b8146fd3125fc1ac7d335d71d7bbde`.
