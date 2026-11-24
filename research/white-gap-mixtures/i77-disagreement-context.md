# Where a sparse periodic column would have to vary

A gap counts the white ticks between two consecutive black pulses. Fix the alphabet {9, 10, 12, h}, with h equal to 13 or 14, and allow its gaps in any order. Sample the cell immediately to the right of the driven site on the **second white tick** after each pulse.

**COMPUTED.** In a width-27 component with both sample colors and internal 9 and 10 edges, two strip paths with identical gap labels and common start and end rows can give different samples only at the bar in one of these two words, read from left to right.

```text
h  12  12  10  9  |  10  10
h  12  12  10  9  |  10  12
```

The marked pulse ends the nine-white gap. Its own following gap has ten whites. The most recent high gap is exactly five gaps back. Both words occur on pairs of strip paths for each alphabet. The assertion applies to interior samples with these seven labels available, and cyclically to closed paths with matching endpoints.

**PROOF-SKETCH for ordinary Rule 30.** If a site of a row with a leftmost black cell eventually has a periodic gap sequence on one of these alphabets, its cyclic period must contain one of the two displayed words. In fact at least one marked phase must have a non-eventually-periodic sequence of second-white samples on successive turns. Whether such a physical column exists on either alphabet remains open.

## What the two computations checked

Each row records the first W cells to the right at a pulse. An edge of label q is exactly one realizable ordinary history over the next q+1 ticks. The reader can choose a different unobserved completion at the next edge. Keep strongly connected components with both sample colors and internal edges of labels 9 and 10. A hypothetical finite-left sparse period uses both labels by S8, and its nonperiodic second-white output uses both colors infinitely often. [Ordinary edge construction](ordinary-gaps.md) · [S8](https://github.com/WolframInstitute/Rule30PrizeKit/pull/398) · [Phase and finite-left arguments](sparse-word-growth.md).

An unordered pair is counted when a pair of walks from a common row reaches it using identical labels, and some pair of walks from there can reach a common row, again using identical labels. Concatenating these witnesses gives precisely the positions at which fixed input and endpoints leave a choice. The initial and final common rows can differ.

| Width | h | Rows in qualifying components | Pairs with common endpoints | Pairs with opposite samples | Longest preceding path on 9, 10, 12, grouped by pair |
|---:|---:|---:|---:|---:|---|
| 22 | 13 | 8,461 | 683,645 | 636 | 4 for 124 pairs, 6 for 512 |
| 22 | 14 | 8,301 | 688,126 | 701 | 4 for 189 pairs, 6 for 512 |
| 27 | 13 | 85,024 | 23,081,149 | 3,059 | 4 for every pair |
| 27 | 14 | 84,610 | 24,547,001 | 9,382 | 4 for every pair |

Every opposite-sample pair in the table admits arbitrarily long **following** paths using just 9, 10 and 12 inside the common-endpoint product. The bound on the preceding distance is directional. At width 22 the preceding four labels were already (12,12,10,9). For h = 13 the next two labels could be any of (10,10), (10,12), (12,10), (12,12). For h = 14 only the first two occurred. At width 27 the 13-alphabet loses both continuations starting in 12. Both R102 predictions passed.

The first calculation lifts admissible row pairs from smaller widths and searches for a reachable cycle when the high gap is suppressed. Projection preserves every actual common-endpoint path, including the opposite samples and the required component labels. Unique exact raw rows at width 27 recover the input graph. The second calculation uses the target graph alone. It computes components with Kosaraju's algorithm, searches the full triangular space of row pairs, computes the sample by two individual Rule 30 updates and reads five previous and two following labels about the same pair. It shares the archived one-gap data with the first calculation. This checks the pair computation independently of the projection argument. [First calculation](disagreement-context.cpp) · [Direct replay](check-disagreement-context.cpp).

## Why a cyclic word is compulsory

1. Mark each phase of the hypothesized gap period where one of the two displayed words occurs, including across the wrap. Replace the second-white output at marked phases by white. This marking depends only on the periodic input.
2. Give every strip row its input phase. Along a periodic drive an infinite strip path eventually stays in one strongly connected component of this finite graph. Two walks of equal length with the same endpoints there have identical masked output. Otherwise an unmarked discrepancy would survive. To inspect a position near an end, extend both walks with the same walks in that recurrent phase component until all five previous and two following labels are present.
3. On any infinite path choose a vertex and phase visited infinitely often. For two nonempty return walks there, concatenate them in both orders. Both orders start and end at that vertex and have identical input because the return lengths are multiples of the gap period. Their masked output words therefore commute. Every return output is a power of the same primitive word, by the commuting-words lemma applied with one fixed nonempty return. Thus the infinite masked output is eventually periodic.
4. The sparse phase theorem and finite-left masked Jen force the full second-white sequence to be non-eventually-periodic on the hypothesized physical column. If the sample subsequence at each of the finitely many marked phases were eventually periodic, interleaving these subsequences with the masked output would make the whole sequence eventually periodic. This proves the claimed necessity, subject to the computed finite premise. [Earlier common-endpoint argument](periodic-gap-requirements.md) · [Earlier three-gap localization on eight letters](second-white-context.md).

For example, the cyclic family `(h,10,12,12,10,9,12^m)`, where the exponent counts consecutive twelve-white gaps, passes I87's individual requirements (12,10,9), (10,12), (12,12) and a 13 or 14 for every m ≥ 1. Its unique h is always followed by 10. The new criterion excludes the entire family as a finite-left periodic column. This comparison is with those four word tests. It does not require the example to be readable at width 27.

## Which marked discrepancies can occur on one ordinary cone?

I82 exhibits two closed strip paths on a particular 13-clock and two on a particular 14-clock. At their first differing sample, retain the rows at the preceding pulse, the marked pulse and the next pulse. The initial pulse is tick 0, the marked pulse is tick 10, its sample is tick 12, and the last pulse is tick 21. Exact enumeration counts the right completions realizing **all three rows** on each path. The two branches prescribe different local starting rows. A positive for each gives two physical histories on this interval. The longer shared-endpoint loop imposes additional constraints.

| Archived clock | Width | Right completions giving the black branch | Right completions giving the white branch |
|---|---:|---:|---:|
| 13 | 27 | 0 | 24,576 |
| 13 | 28 | 0 | 49,152 |
| 14 | 27 | 65,536 | 139,520 |
| 14 | 31 | 0 | 84,352 |

**COMPUTED, with certified existence judgments.** Over 21 ticks the observed cells see exactly 21 additional initial right bits. The enumerator tests all 2,097,152 choices per triple and checks a witness cell by cell for each positive. An independent CNF uses the eight-entry Rule 30 truth table on the full cone, gives the left cells ordinary updates, and requires the driving site to be black precisely at ticks 0, 10 and 21 in this interval. CaDiCaL returned five finite initial rows which we evolved with white background in both directions. In the three negative cases both `cake_lpr` and `lrat-check` verified the LRAT refutations. The prediction that at least one width-27 clock would pass on both branches succeeded. The prediction that both would pass failed on the 13-clock. [Right-completion enumerator](check-marked-seam.py) · [Full-line certificate replay](certify-marked-seam.py).

## Release judgment and the next test

The original I77 rank replay checked 155,648 exterior-labelled edges on 69,632 states, with maximum rank seven. The rank eventually stabilizes. Infinitely many long gaps force a visit to phase 15 at the stable rank, ruling out odd rank. At even rank the right neighbor is white on white phases 1 and 2 and black on every later white phase. GrammarRuns covers gaps all at least ten and ResetMixtures covers any gap at least seventeen among gaps of at least nine. The posted S8 theorem now also excludes every ordering on 9, 15 and 16 by requiring the adjacent gaps (12,10,9). A standalone submission for that original exclusion would duplicate S8. [I77 and its independent rank checker](README.md).

The new result localizes output variation for both entire alphabets. A submission would need a compact Lean certificate for the width-27 premise and a second reader for the ordinary-history inference. For the 13-alphabet, apply the two-gap compatibility test to all triples around the 3,059 opposite-sample pairs. Its known black branch already fails there. For the 14-alphabet, the exhibited width-27 pair survives the local test on both branches, so carry a common ordinary continuation across more of the path towards its shared endpoints, or do the complete product at a greater width. The dated fixed-clock results already exclude both specific clocks. Excluding either entire support is a separate open question. [Earlier fixed-clock physical controls](second-white-context.md#continuous-history-controls-and-kit-relevance).

## Replay

The two source archives are `share-scratch/gptIntel/I81/ordinary-gap-language.zip` (SHA-256 `a279bf2d5b2da5503f874a9c3b61e8c54e27d6436c776e953f5207c540577bdb`) and `share-scratch/gptIntel/I82/periodic-gap-requirements.zip` (SHA-256 `6000120f12a4b40e5ef224e794b0deff8ac34fd54a83d8e8608917d0b1694e62`). I81's indexed width-27 graph has 134,955 rows and SHA-256 `93fcdbf755b71b468c308a872f9c544dcfb2f1192cd9170582b1336a204a7cbf`. I82's width-22 raw graph has SHA-256 `37fe5fe63d6a96f6f68cc93aeec54fe563a40a4cb4987562556251182e97580d`. The seam frames come from `share-scratch/gptIntel/I82/four-letter-diamonds.zip` (SHA-256 `6d933318bf64f7c07718b6476d72ef7bcab1ab923174387c2b015e5eb05f2ddd`).

The read-back companion archive is `share-scratch/gptM5/I77/i77-marked-pulse.zip`, SHA-256 `dfc447f86db187e33bad729a4b7c5a743bf888ee283d4708af2c0e5c4b1d812f`. It supplies the graph inputs, frames, four programs, complete outputs, finite initial rows and refutations. Extract it and run `sh replay.sh` on a little-endian host with a C++20 compiler, Python with NumPy, CaDiCaL, `cake_lpr` and `lrat-check`. The optional argument `22` runs the smaller graph replay and all physical checks. The script compares graph and enumeration output byte for byte and checks all eight full-line existence decisions.
