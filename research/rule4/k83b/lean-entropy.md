# A six-state proof that Rule 30 has entropy below log 3

For the full two-sided Rule 30 map, the [Lean source](LeanK83B.lean) proves

$$
  h_{\mathrm{top}} \le \log(53/21) < \log 3.
$$

This is at most 1.335603032 bits per tick. The kit's lower bound is one bit per tick. The lower bound and the earlier upper bound use Mathlib's `Dynamics.coverEntropy` on the entire configuration space. The new bound uses the same quantity. [Kit entropy statements](../../../Rule30PrizeKit/equivalents/Rule30Equivalents/Mixing.lean)

## The six sets and their weights

At a given time observe the pair at sites a and a+1. Retain the possible states of the two sites a+1 and a+2. Encode their values u,v by u+2v. A mask stores a set of possible codes, with 15 representing all four. To read a pair (b,g) backwards in time from a known suffix mask S, take all codes (u,v) with u=g for which some further eastern bit e satisfies

$$
 (\,b\mathbin{\mathrm{xor}}(u\lor v),\;
      u\mathbin{\mathrm{xor}}(v\lor e)\,)\in S.
$$

The local rule proves this table for every assignment to the four physical cells. The empty predecessor is a dead end.

| S | 00 | 01 | 10 | 11 | Weight |
|---:|---:|---:|---:|---:|---:|
| 15 | 5 | 10 | 5 | 10 | 504 |
| 5 | 1 | ∅ | 4 | 10 | 318 |
| 10 | 4 | 10 | 1 | ∅ | 318 |
| 1 | 1 | ∅ | ∅ | 10 | 209 |
| 4 | 1 | ∅ | 4 | 2 | 275 |
| 2 | ∅ | 10 | 1 | ∅ | 209 |

Give the empty set weight zero. For each row, 21 times the sum of its four successor weights is at most 53 times its own weight. Multiplicity matters: distinct observed letters reaching the same mask still count separately. Induction bounds the number of length-n backwards paths starting at S by its weight times (53/21)ⁿ. Every physical pair word gives a path from 15, since its actual cell at a+3 is a witness at each reversal. Allowing the successive witnesses at a+3 to vary freely gives an upper bound. Thus the number of physical pair words at any spatial location is at most 504(53/21)ⁿ.

## Why two columns suffice

Write N(n) for the number of temporal words realized at a fixed pair of adjacent columns. Translating configurations shows that N(n) is independent of the chosen pair. Splitting a word after m observations gives N(m+n) ≤ N(m)N(n).

A dynamical cover for agreement on the observed pair over n ticks must represent all N(n) words. Conversely, for the spatial window from −k to k, choose one representative for each word of length n+2k+1 at columns k,k+1. Two adjacent columns determine the history to their west by Rule 30's left permutivity; the representatives cover the window for n ticks. This is the kit’s window-cover argument before substituting its word-count bound. Submultiplicativity bounds the cover size by N(n) times the fixed number N(2k+1). Passing to the exponential growth rate eliminates the constant. Therefore the full topological entropy is exactly the exponential growth rate of these adjacent-column words.

In particular, one certified finite count N(k) gives the upper bound log(N(k))/k. Both this statement and the six-state bound apply to the physical rule on the infinite lattice. A finite estimate of collision entropy beside a randomly sampled wall does not supply a lower bound on the limiting topological entropy. Whether the entropy is strictly above log 2 remains open.

## Verification

The 16,807-byte source has SHA-256 `95c2f28cb0e699d1857bf48f909ab1012251a46d6a0d48e7a6790f757ab16317`. At the portal verifier’s kit pin `5fb591588cfa869bfdc47946799b5ddd70a903d1`, stock `Check.lean` passed all 13 headlines, checked 69 declarations and replayed 112 constants with no new axioms. Independent `leanchecker` exited zero. Adding one missing headline made the stock verifier fail as expected. The 8,700-byte replay packet `K83B-entropy-proof.zip`, SHA-256 `9f43f2973719ba0b872020001da155fd026a9a7a3506138fda74f2ac403f7734`, includes the source, original stock and negative receipts, and a portable replay driver for a built pinned kit.
