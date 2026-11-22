# KIT-REPAIR steps 3 and 5 · independent review

**Both carrying reviews pass. Both release reviews pass on the corrected files below.** The N3 Lean proofs pass as written. The original public wording overstates the standard-word prefix claim in step 3 and the white-run exclusion in step 5.

| Step | Base | Reviewed patch SHA-256 | Resulting Git tree | Independent checks |
|---|---|---|---|---|
| 3 · `Rule30ClockNearSquares` | `b5b9dbd` | `30d04600ceb9ee487d020face368ad46f9ee72f743a739544211e7aab845c01f` | `a3ca59455ca8bc55f82166a59a250d0b9dc0f26e` | 12 headlines, 174 constants, 294 catalogue modules |
| 5 · `Rule30SettledRepeats` | Step 3 tree above | `86079a3f606c5b5dc845262c70f091fad503f2b5afdbf4591a4423cea3f36d4f` | `af0ec88cd5961eae3c2393631494b473a428c28c` | 6 headlines, 90 constants, 295 catalogue modules |

## Step 3

I downloaded both October portal sources and matched their bytes against the committed originals. A separate Lean client took the declarations from those sources and checked the kit constants against their original types. This covered all 44 retained declarations from the combined entry, including the 18 shared with the earlier entry that step 3 retains. The characteristic-word and block-code theorems assume a clock from time zero. The more general near-square exclusion permits a transient and uses a fixed slack at unbounded lags. [Original near-square entry](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-91b0b0) · [Original characteristic-word entry](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-0c4a33)

The replacement diagonal proof preserves the hypotheses. At an actual left edge, diagonal zero is black from time zero and diagonal one from time one. The physical Rule 30 update gives the kit’s `TailLeft.step` at every later index starting at time zero. The kit then supplies arbitrarily distant eventually black diagonals. Its finite profile bound rules out a common eventual period even when each diagonal chooses its own onset. Choosing a sufficiently distant black diagonal bounds the lifted two-column repeat strictly below the length forced by the visible-bit near-square. The proof of `corollary_F` is distinct from the kit’s earlier sampled-repeat theorem, which requires repeats exceeding their second start by arbitrarily large amounts. [Kit diagonal package](https://github.com/WolframInstitute/Rule30PrizeKit/blob/b5b9dbd/lean/Ruliology/CellularAutomata/Rule30ZeroWallDiagonals.lean) · [Earlier repeat theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/b5b9dbd/lean/Ruliology/CellularAutomata/Rule30GapRepetitions.lean)

**Release correction.** The auxiliary word `std d 0 = [true]` is not a prefix of the characteristic word, which starts with false. The prefix family begins at `std d 1`. Its lengths grow without bound. For the Fibonacci directive, the first two letters are `01`, while the two at offset four are `10`. Thus the slack-two prefix repeat does not hold at every integer length. The corrected docstring and PR body give the precise family, and the catalogue row now spells out the left-edge hypothesis. The PR title is unchanged.

## Step 5

The third downloaded source matched the committed original byte for byte. The same Lean client checked its 13 retained declarations and all nine declarations supplied by step 3. It also checked the formula for the moving-edge diagonal directly. For a row with a leftmost black cell, negative diagonals are white. A second client used that fact to derive the public finite-band version, which only asks for agreement on diagonals 0 through M. [Original settled-repeat entry](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-1d5070)

The repeat hypothesis compares **both adjacent columns** at the two starting times. In moving-edge coordinates, the backward step either gives a wider white interval at the previous tick or a birth with a black cell at one of the last two positions. Forward propagation preserves a suffix. Agreement with the earlier diagonal profile then bounds a white run preceded by black inside the band by `2P − 1`. The resulting bound on repeat length improves Jen’s bound when `M ≥ 2P`.

**Release correction.** The original title says the white run cannot lie inside the band. The single seed gives a counterexample. Columns 0 and 1 agree for three ticks starting at 0 and 4. With `P = 2`, diagonals 0 through 3 agree at ticks 2 and 4. At tick 4, diagonal 1 is black and diagonals 2 and 3 are white. The whole forced run is inside the band, and its length 2 satisfies the proved upper bound 3. With `P = 1` and `M = 2`, the same repeat attains the improved bound of 3. Lean checked both examples by kernel computation. The corrected title, module description, catalogue row and PR text describe the bound. The PR body names its step-3 dependency without a placeholder PR number.

## Verification and handoff

I applied N3’s two patches in order and reproduced trees `2ff6b1d6` and `c3437f28`. I then applied and rebuilt the corrected stack on the same kit base. Only comments changed in the Lean sources. Native kernel replay and the kit checker passed for all four builds with standard axioms only. Each JSON receipt matched the author’s receipt field for field. The complete catalogue built in 297 jobs for step 3 and 298 for the stack, reusing compiled upstream dependencies. The original-type client and counterexamples passed on the corrected stack too.

The release bundle contains both patches, module files, PR titles and bodies, manifests, receipts, Lean clients and scalar controls. It is in `share-scratch/gptM5/kit-repair/R83-steps-3-and-5.zip`, 47,733 bytes, read-back SHA-256 `df833df0c153aba0506fed4e0b38781425f3df85bee7f0507c3ab4b14dad6720`. Step 5 uses the reviewed step-3 tree as its base. Author agreement and the owner’s word to open the PRs are the remaining handoff.
