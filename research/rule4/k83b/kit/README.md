# K83.B kit release candidate

**Ready for an independent release read.** The five-file patch adds `Rule30Equivalents.PairTraceEntropy` to the kit, exposes the word-count step in `Mixing`, and updates the aggregate import, README and catalogue. It applies to kit main at `e2c9d8ecd6440ca72895969093f67746c4ab09c8`. The local candidate commit is `a7adcb35b03ebcd27f70dd4da2bf7cb8f5672379`. Applying the patch to a clean index at that base reproduces its entire tree, `eef8616fcba422e71f4fe0c46d47916d4bfddcd7`. [Kit patch](pair-trace-entropy.patch) · [Proposed PR title and body](pr.md)

## What the kit would gain

For the full two-sided Rule 30 map, the growth rate of the words realized at any fixed pair of adjacent sites equals topological entropy. A single exact count at any positive length gives an upper bound. A reverse cover with a positive integer weight on every state bounds every word count when its four successor weights satisfy the stated row inequality. The predecessor condition ensures that every physical word appears among the paths. Counting paths can therefore overestimate the number of physical words.

One instance keeps the scope small. Its 140 states represent sets of possible five-site eastern strips. With the existing one-bit lower bound, the exact rational certificate gives **1 ≤ h < 1.232039 bits per physical tick**. The proof uses natural logarithms. In bits, log₂(1679211/714866) is approximately 1.23203877998. The lower-endpoint question B3 remains open. The stronger width-14 result, below 1.143992 bits, uses the separately checked 2,868,932-state certificate. [Original Lean statements](../lean-entropy.md) · [Width-14 review](../claudeM5-k83b-read.md)

The kit already states the pair identity informally. Di Lena and Margara proved a width-(2r+1) trace result for permutive automata, and the October notes give the two-column argument for Rule 30. The contribution formalizes that argument using the kit’s physical words and supplies the reusable weighted bound. The candidate is scoped to the kit’s full-map entropy discussion. [Corollary 4.6](https://www.cs.unibo.it/~margara/page14/assets/01-JCA07.pdf) · [October notes, §8.77](https://github.com/ghywel/placego/blob/main/archived/reports/rule30-prize/RULE30-PRIZE-8.2.md)

## Replay

From a checkout of the kit at the base above, set `packet` to the absolute path of this directory. On a fresh checkout, obtain the pinned Mathlib cache with `lake exe cache get`.

```sh
git apply --check "$packet/pair-trace-entropy.patch"
git apply "$packet/pair-trace-entropy.patch"
lake build Rule30Equivalents.PairTraceEntropy
lake build
lake env lean "$packet/CheckPairTraceEntropy.lean"
lake env leanchecker -v Rule30Equivalents.Mixing Rule30Equivalents.PairTraceEntropy
python3 equivalents/scripts/gen_check_axioms.py
git diff --exit-code -- equivalents/scripts/CheckAxioms.lean
lake env lean equivalents/scripts/CheckAxioms.lean
```

On the M5, Lean 4.35.0 and pinned Mathlib `56a005855e` built the module in 9.3 s with compiled dependencies. The targeted Lake command took 11.97 s with 3.61 GiB peak resident memory. The default root build passed. Six examples through the aggregate import checked the identity, the single-length bound, both generic weighted conclusions and the numerical bounds. All eight selected declarations and the 234 existing catalogue statements used only the standard axioms or fewer. The kit’s regenerated axiom script matched the original. Kernel replay of both edited Lean modules exited zero. [Consumer checks](CheckPairTraceEntropy.lean)

A separate integer check enumerated all 17,920 physical one-tick cases, checked the terminal mask, the 140 positive-weight inequalities and the strict rational comparison. For a negative control, change the first transition in the first table row from 1 to 140 (absent) in a disposable copy. Lean rejects the local predecessor theorem. The all-white strip with both exterior bits white already witnesses the failed lift.

| File | SHA-256 |
|---|---|
| Kit patch | `f2fc8d8202a5706e0d81bf8f3584c1bd390381c9550d67054a4cadeb25e2884d` |
| Integrated PairTraceEntropy.lean | `e4c1419c462ca28f6589ecf2461185d36aad55a8bbc2ea30a8ed165234dfb783` |
| Proposed PR text | `de794cc692a8e735f0b41aa87a33ef6ad64f5afb8e7bdcb879a9e728dcf522e0` |
| Consumer checks | `d1f834a22f9d10ba30acdaf39c7e7cbea54d389a4eb72ad66264b42bc1509c32` |

M178 covered the original mathematics. The requested read of these bytes covers the factored window proof, the single-origin bound, the five-site transition order and weights, and the scope of the catalogue and PR wording. The owner decides whether to open the kit PR after that read.
