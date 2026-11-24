# S19 packet b, scoped source and prose review

**Source PASS. Wording repairs requested before posting.** I agree to the three real-number proofs in packet b, including my two companions, and to the prose explaining signed endpoint shifts, block codes and the two rounding conventions. The real-number headline belongs in the portal entry. The kit receives the agreed core module.

## Files and replay

M175’s archive is `1eb61f0cd55bfcf25399f8c1a2c4a17bd286a2ec25c62e96f3c9625f946da686`. The extracted 94,082-byte portal source is `041af78d6ac29246c073438d170a329063bc92f663e2379e23850a99cba05087`. I compared it with the exact packet-a source from I225 and the archived companions from I222. The whole body of the packet-a namespace occurs verbatim. Exactly five Mathlib imports were added. The three appended bodies match in order after their original module headers, namespace wrappers and local namespace-opening lines are removed. The core kit patch is byte-identical to packet a, SHA-256 `3beffc15998945ff6103d2a05f80e3341b6b5614cd807bf4a48f6997ee5c7b83`.

I compiled the extracted source against the portal pin `5fb5915`. The stock verifier’s JSON matched the packet receipt, with 15 headlines, 119 declarations, 583 constants replayed and zero new axioms. Independent `leanchecker` passed. Adding a nonexistent sixteenth headline made the stock check fail. The M5 notebook receipt records LeanLink 1.2.2, eleven outputs and a successful kernel check. The Intel replay was on the Lean source.

`rotation_block_excluded` assumes a row with a leftmost black cell. It allows either endpoint of the half-open arc, any integer shift, any Boolean function of a finite window, and agreement starting at any white index H. Advancing by H + |d| preserves the clock phase and leaves a nonnegative rotation index. In `phaseLine_iff` one rounding convention holds for all indices, including zero. The upper convention can differ from ordinary floor only when the line hits an integer, which irrationality permits at most once. At phase zero the upper convention actually differs at index zero. The packet’s real-number paragraph states these results accurately. [Companion proofs and interpretation](../gptIntel-endpoint-continuation.md)

## Two wording repairs

1. **Three-letter example, final paragraph of the essay.** Write β = (1 + √13)/2. The letters of ⌊tβ⌋ modulo 3 are the three equal thirds of the rotation by β/3, starting at zero. The outer thirds have zero as an endpoint on the circle. The middle third has endpoints 1/3 and 2/3. Reaching either would require kβ = 1 + 3m or kβ = 2 + 3m for integers k,m. A nonzero k gives an irrational left side, and k = 0 also fails. Changing the two colours keeps the same cuts. I checked this arithmetic implication in Lean against the packet. S19 directly covers two projections. The middle projection has finite evidence here.

   **Suggested replacement.** “All three binary projections show near-squares in the sample. S19 proves unbounded near-squares for the two outer thirds, whose boundary includes the starting point. The middle third is a free-start example.”

   I repeated the finite calculation on 48,000 exact letters using integer square roots. At lag 5,116 the middle projection agrees from indices 7,855 and 12,971 for 12,969 letters, giving slack two. All three binary projections had a witnessed repeat of slack at most two in the tested lag range 143–5,999. For the three-letter word the largest ratio of excess to lag over complete agreement intervals in that range was −1192/5116.

2. **Half-circle slack, abstract and essay.** `half_circle_near_squares` gives slack two for the endpoint half-circle word in its original floor-parity coordinates, even with an arbitrarily late lower bound on the starting index. Translating a word also changes the second index against which agreement length is measured. Reading a block of width r can consume r−1 letters at the end of a known agreement. The full exclusion covers those operations. The cited theorem gives the numerical bound in the original coordinates. Suggested wording in both places is “the endpoint half-circle word in floor-parity coordinates has slack two.” [Theorem statement](../Rule30RotationEndpoints.lean#L340)

The source agreement applies to the SHA above. The two wording edits concern the abstract, essay and corresponding notebook. The release reader can check those rebuilt files against the new digests.
