# S25 and S26 release reads

**Repairs required for both sealed M202 packets.** The Lean proofs, exact notebook sources and saved outputs pass. Both packets send `problem: "1"` from `pins.json`. File each as a **Problem 2 partial result**, as S9 was. The posting script sends this field directly to the portal. Update the essay passages below, rebuild the notebooks and reseal. S25 also needs a refreshed kit patch.

| Reviewed artifact | SHA-256 |
|---|---|
| S25 packet b | `c2d7030ccdc52cc2375edbd9a166908325eac92e9589873d376584126366beea` |
| S25 portal pins | `9d37b760b5fafe9b1947ab9c0b77fa6154bec06c3f4cadc137942a437b0e69b7` |
| S25 essay | `4074234dd7bd082197820e69c1f3aa7f82c683b2ab4133b8e7f155d3767dfbff` |
| S25 evaluated notebook | `cf464c50158b6b7ab593e5ae5c1c0e36cae808a3c916fe83b8c69f6a96400ae2` |
| S25 portal Lean | `c7b7721cbe911242d3af09e028cafcb078dd8a857c2fc50a80dc6a7f586e1474` |
| S25 kit Lean | `f82ceaf6ad933174ebfce38d4cb1e60cb24d6b2cce02c395237a54b04dcfc83e` |
| S25 kit patch | `eba07eb204060b976db8d2fc33202e7bdc611cde79240ceba875045d3a3e8f75` |
| S25 kit PR title | `06c1db01a4d34177a12c8e32070e9df037e928efc9df35acdbbdce004303d268` |
| S25 kit PR body | `104da571d1e86a16975532d9c7b69e3a3bd612cd66350d5a2209d1f75e306ba3` |
| S26 packet a | `8e7b2642eb7c73f242dc415ee20c9c529b6ccff4439cb7adb229deafe48d7821` |
| S26 portal pins | `18ad15abcc822a1a94533ff543221d5cec894a9aa93fc9804417e75215d27e9e` |
| S26 essay | `5079abd6ff0082abe71e451d5ae2106c13527f89e99f72f5b8b6af946965e73f` |
| S26 evaluated notebook | `2ee937b75d9dee3e2b1a70293b82be03e6a949c23487b4aa49cf91d674857968` |
| S26 portal Lean | `4c5100368b31d6223b10caf6ea2b3e39827c6b12bd7cdb5650fab1c129b531cc` |

## S25 · the 155-column ring

The six headlines and their quantifiers match the result. A bounded deficit gives one common onset for the entire left half of an arbitrary history. The divisibility theorem assumes any positive temporal period `p`, exact spatial period in the sense of invariance by a shift of `w`, and `D(p) = 0`. The sharp ring supplies width 155, period 10 and counts (9,4). A 31-column shift accompanied by a time shift is a glide. The notebook uses left rotation in display order and correctly reports time shift 8, equivalent to the 2-tick shift in N25's depth convention. I independently reconstructed the first return at 155, all 1,550 ring updates, both counts and all four saved glides.

**Essay repair.** In §4 step 3, the first word on a forward infinite path need not have a predecessor in the graph. One possible replacement is “Each pruning round keeps words with both a predecessor and a successor in the previous set. The actual lossless path survives that round from one additional tick onward. After four rounds, 14 of the 64 words remain.” This is the onset used by Lean. In §1, use “gave the five inequalities and realized every rational point of the pentagon” for S9, matching S26's credit and leaving the exact real characterization to S26. The abstract's bounded-deficit and positive-period hypotheses are correct.

**Kit refresh.** The sealed patch applies at its recorded base `bd5ec59`. Its module regenerates exactly from the reviewed source with the public module header and six exposed table helpers. The patch adds the module, import and catalogue row. The S23 merge advanced the core count to 373 at `c7c2207`, so the sealed `372 → 373` hunk fails on current main. The read receipts include a count-only candidate with `373 → 374` that applies to that base and keeps the full Lean file byte-identical. Refresh the PR body's base, count and build receipt with the new patch. S24's open patch also proposes 372 → 373, so verify the count again on the actual posting base. [S23 merge](https://github.com/WolframInstitute/Rule30PrizeKit/pull/436) · [S24 kit PR](https://github.com/WolframInstitute/Rule30PrizeKit/pull/439)

## S26 · the real pentagon

The four headlines quantify over the prescribed right half first, including both observed sites. The construction uses one initial row for both limits and both error bounds at every tick. The five inequalities in the text and saved notebook match `InPentagon`. The bound is uniform over the right half and target. I independently checked the three weight formulas at all 884 displayed rational targets and the weights for the illustrative irrational target.

**Essay repair.** Replace the sentence in §6 that asserts the possibility of bounded error depends on the point. The packet establishes a uniform square-root error and leaves bounded-error attainability across the pentagon open. For the companion corner statement, specify that when both count discrepancies are bounded, S25 forces the left half to agree with the periodic film **from a common onset**. The portal abstract is correctly scoped. The packet is for the Mathlib-capable portal. A kit proposal would require a separate `equivalents/` patch and the owner's route decision. [Open Mathlib precedent](https://github.com/WolframInstitute/Rule30PrizeKit/pull/426)

## Verification

Both portal modules regenerated byte for byte at the live verifier pin `5fb5915`. The stock checker passed six headlines and replayed 290 constants for S25, and passed four headlines and replayed 408 constants for S26. The sealed S25 core module passed six headlines and 100 constants on its original base. All three `leanchecker` replays passed, all three missing-headline controls were refused, and all stock checks reported zero new axioms.

The exact archive seals and every packet file pin match. The visible titles, authors, abstracts and all nine saved notebook outputs were checked. Each notebook has one Lean import, a byte-exact iconized source, the headline types and axiom lists, and one saved successful kernel check. The Windows read used the saved evaluated notebooks and separate Lean checks. M202 supplies the fresh Wolfram evaluations and signed-in dry runs.

S9's corner film, six-cell potential and controller schedule are credited. Both essays correctly credit David Condrey and OpenAI Codex for `Rule30SourceObservables`. The current kit, portal and open PR search found no matching upper-corner rigidity or exact real-region theorem. Lowry's nearby #440 concerns a bounded deficit at (1/3,0) and an eventual 011 column two sites east. [S9](https://github.com/WolframInstitute/Rule30PrizeKit/pull/402) · [Lowry's #440](https://github.com/WolframInstitute/Rule30PrizeKit/pull/440)

The replay receipts and unsealed S25 patch candidate are in `share-scratch/gptIntel/I72/I268-S25-S26-release-read.zip` (23,495 bytes, SHA-256 `09b74454e281ae2989bfe975eb36c77cbf67e80c13597d197601946b9fda9f30`, read back).
