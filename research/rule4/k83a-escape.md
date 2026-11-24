# How many fresh cells can change the gate?

**An exact fork.** Fix the 28 initial sites shared by S12’s seven-lock example and its trap twin. Every infinite completion has the same first 48 gate readings. For the seven-lock’s infinite word, the shortest extension that rules the word out has **seven cells**. For every other infinite word actually realized on this prefix, including the trap twin’s word, the shortest such extension has **one cell**. This distinction is invisible in the first 48 readings. [S12’s two original examples](../k50_1/path4/release/Rule30LockPrefixCertificates.lean)

## The clock and the question

Set the wall black at physical tick zero, then alternate it forever. Gate sample s is site 1 at physical tick 2s+1. In the initial right row, bit 0 is site 1 and a fresh bit always goes immediately east of those already fixed.

For an infinite target γ and a prefix p on which it occurs, d(p,γ) is the least k such that *some* choice of k more initial cells makes γ impossible for *every* remaining eastern tail. It is infinite if p already forces γ. Define d_H in the same way for just the first H readings. A finite d_H is an upper bound on d. A lower bound on d_H alone gives no lower bound on d. In fact d is the infimum of the d_H: if a cylinder misses an infinite target, compactness of that cylinder and continuity of each reading give a finite H witnessing the miss.

## An exact infinite result at S12’s prefix

Take the low 28 bits of 157190921 as p. S12 proved that appending zero at site 29 forces capture by the 30-cell seven-lock in phase 4 at sample zero. The gate repeats `0000101` from that sample. Its finite trap twin 150212610825 instead has a one at site 29 and first reaches the 829-window trap at sample 41. This is a physical change before it can be heard at the gate.

1. **First possible audible difference.** The finite cone for samples 0 through 47, with only p fixed and a disjunction requiring some disagreement, is unsatisfiable. At sample 48 (physical tick 97) the seven-word reads black and the twin reads white. Hence 48 is sharp over all completions.
2. **Seven cells suffice to exclude the seven-word.** Append the little-endian code 87, spatial word `1110101`, giving the low 35-bit integer 23511075593. The cone with that prefix and a black gate at sample 48 is unsatisfiable. Every completion reads white there.
3. **Six cells never suffice.** For each of the 64 six-cell extensions there is a finite initial right row that spells the prescribed word up to its first aligned entry in phase 4+s of the kit’s seven-lock (modulo seven). The last entry among these witnesses is at sample 94. Checking the finite light cone up to entry and the four possible eastern assignments at every two-tick phase advance proves that every witness spells the word forever. Each witness also supplies a positive-measure subcylinder. Every shorter extension contains at least one of them.
4. **One cell suffices for every other realized target.** Appending zero forces the seven-word, so it excludes each other target. Since the target was realized on p, zero additional cells could not have excluded it. Once the good child has been taken, d for the seven-word itself is infinite.

**Conditional mass at the fork.** Of the eight ways to set sites 29–31, five put the row in phase 4 at sample zero. With little-endian code e = b₂₉ + 2b₃₀ + 4b₃₁ they are 0, 1, 2, 4 and 6. This accounts for exactly 5/8 of the conditional measure in the immediate 30-lock. Reverse counting through sample 7 found the same share at each age, with an independent forward check through sample 6. Later aligned witnesses include positive cylinders outside those five choices, so the probability of the seven-word on p is strictly greater than 5/8. The excluded seven-cell cylinder gives a first upper bound of 127/128.

A second calculation bounds how much fair mass first departs at sample 48. Of the 2²⁸ assignments to sites 29–56, independent three-valued propagation certifies 20,514,616 force white there, 235,780,657 force black and 12,140,183 remain unresolved. Thus the first-departure probability given p lies between **20,514,616/2²⁸ and 32,654,799/2²⁸ (7.64229% to 12.16486%)**. In particular the full seven-word has conditional probability at most 1−20,514,616/2²⁸. The upper endpoint allows every unresolved assignment to depart. The archive includes the native census and independent replay.

The two negative results use separate physical truth-table CNFs with 4,656 and 4,851 variables. CaDiCaL supplied LRAT refutations and both `lrat-check` and `cake_lpr` verified each proof. The positive replay uses one Boolean cell per site with an independently calculated phase transition. Neither an extrapolated suffix nor a solver timeout enters the argument. [Regenerator and witness checker](k83a_escape_check.py)

## A trapped row and a long Y train

We also tested actual prefixes of a finite row already in the trap (first 16-cell code 65180) and K80’s 598-bit finite predecessor that follows the Y schedule for 344 readings. The entries below are the **exact finite-horizon** depths d₆₄ for the respective seed’s own first 64 readings. An infinity means all completions agree for those 64 samples. Each missed depth was tested by physical SAT, with matching completions for every shorter extension. On the trapped row every displayed entry also holds at H=80. [Solver and physical seed definitions](k83a_escape.py) · [K80’s finite Y row](../wheel/gptIntel-k80-results.json)

| Initial sites | 16 | 24 | 28 | 32 | 40 | 48 | 56 | 64 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Trapped seed | 1 | 2 | 1 | 2 | 2 | ∞ | ∞ | ∞ |
| Y seed | 1 | 2 | 2 | 6 | 4 | 1 | ∞ | ∞ |

There is a stronger kind of positive witness that does not require a target. Find two extensions of the same p on which *every* completion forces opposite colours at the same sample. At least one of those extensions excludes any prescribed target, including one never sampled. The table gives the shortest shared depth found by three-valued propagation through 512 readings up to depth 12. The word codes are little-endian and give a replayable witness for either colour.

| Seed | Prefix width | Extra cells | Sample | White extension | Black extension |
|---|---:|---:|---:|---:|---:|
| Trapped | 16 | 3 | 14 | 4 | 1 |
| Trapped | 24 | 8 | 32 | 52 | 161 |
| Trapped | 32 | 3 | 32 | 1 | 5 |
| Trapped | 40 | 4 | 42 | 9 | 0 |
| Y | 16 | 4 | 15 | 3 | 10 |
| Y | 24 | 7 | 31 | 92 | 5 |
| Y | 40 | 11 | 54 | 61 | 1309 |
| Y | 48 | 6 | 54 | 13 | 40 |

The forecast of a pair *past* width 48 failed on both seeds at this search depth. Widths 56, 64, 80 and 96 produced none. There was also no pair at width 48 on the trapped row or width 32 on Y. The S12 good-child control correctly gave none. The ternary rule discards correlations, so its negative rows do not rule out a short physical witness. The positive bounds are unconditional: for instance, on the Y width-48 cylinder, every gate atom has conditional probability at most 63/64. [Two-colour search](k83a_two_colours.py)

## What would settle the forward question?

Positive mass for a single target forces its conditional probability to approach one along almost every row spelling it. The two-colour certificates measure exactly the kind of leakage that can challenge this. At successive disjoint prefixes along such a row, a derailing cylinder of length k removes conditional mass 2⁻ᵏ. Divergence of the sum of these losses almost surely on every compatible aperiodic target would exclude all such atoms. A single lock example, or even an entire finite grid, does not establish that divergence. The seven/one example explains why a detector trained only on a long visible gate word can assign the wrong depth. [Measure argument, restart and its exact quantifiers](right-coin-past.md)

**Next experiment.** At the residual prefixes where ternary propagation gave no pair, retain correlations using the physical SAT cone. Seek opposite monochromatic cylinders along the *same* nested trapped row at a succession of fresh disjoint blocks. A successful proof needs recurrence or a summable bound for the exceptions. Counting more rows that eventually reach the trap cannot establish this, since the trap still permits aperiodic gates. [Separate basin counts and proofs](k83a-basin.md)

## Reproduction

Fetch `share-scratch/gptIntel/K83A/escape.zip` from the shared store and extract it. Run the following in the research repository. The checker rebuilds byte-identical CNFs from the physical rule, verifies the positive witnesses and checks both counterexample rows. The exploratory SAT search additionally needs the `python-sat` package.

```text
python research/rule4/k83a_escape_check.py EXTRACTED/lock-certified.json REBUILT
lrat-check REBUILT/prefix28-read48.cnf EXTRACTED/proof/prefix28-read48.lrat
cake_lpr REBUILT/prefix28-read48.cnf EXTRACTED/proof/prefix28-read48.lrat
lrat-check REBUILT/prefix35-white48.cnf EXTRACTED/proof/prefix35-white48.lrat
cake_lpr REBUILT/prefix35-white48.cnf EXTRACTED/proof/prefix35-white48.lrat
python research/rule4/k83a_escape.py train 32 64 6
python research/rule4/k83a_two_colours.py
```
