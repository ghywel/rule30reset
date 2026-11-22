# S6 release review

**The M91 portal packet passes. The M91 kit patch needs a rebase.** The proofs, catalogue rows and credits pass review. Kit main advanced from `10cc046` to `e303021` when #382 landed. Applying the frozen patch to that revision fails at the module count in `Rule30PrizeKit.lean`. The patch and PR body below pass on the new base. claudeM5 can adopt those exact files for the kit handoff. [R74 carrying review](review.md)

| Deliverable | SHA-256 reviewed | Verdict |
|---|---|---|
| M91 portal manifest | `374b8d2d9028e31553ccd2a26e171225007dbb32606a43c7022df5c6f49d4145` | PASS at verifier `5fb5915` |
| M91 kit patch | `4e4b5c11e584a95afc726456a4cc2a78a10c9d7c321f77174c4e15f472e1805c` | PASS at `10cc046`. Fails to apply at `e303021`. |
| Rebased kit patch | `b0b1244f45b54c368622513d26757a575efb39500f567c4a8e758288a4625fea` | PASS at `e303021` |
| Updated PR body | `6abc610ee958856ba082e9c3228edaa4e4d2e9a9baca7335c62606cc78aa792e` | PASS with the rebased patch and M91's PR title |

## Portal packet

All twelve files matched the manifest. Reassembling the eleven upstream modules and the two reviewed modules from their pinned Git blobs reproduced all 190,761 bytes of `Rule30Submission.lean`. The essay and the notebook embed that exact source. The title and abstract match the submitted metadata. The essay byline names the same contributors as the portal author field. The authors and agent fields match S5 byte for byte.

I compiled the submission in Lean 4.35.0 at the live verifier commit `5fb591588cfa869bfdc47946799b5ddd70a903d1` and ran both native kernel replay and the kit’s `Check.lean`. All six headlines passed. The checker replayed 1,242 constants, found only standard axioms among all 321 audited declarations and reproduced the author’s JSON verdict. [Verifier environment](https://www.wolframcloud.com/obj/rule-30-prize/Agents/submissions.json)

I read the delivered notebook in Wolfram and compared all six stored type forms and axiom lists against fresh LeanLink elaboration. Each matched. The embedded environment, the exact abstract, the age-7 witness and the good bands 200 and 222 are present. The saved and fresh kernel checks each accepted 1,242 constants. All eight output cells passed the notebook checks, with zero message cells, failed outputs or local paths. The pinned posting script completed its dry run on the same verifier commit.

## Scope and credit

The essay gives the exact edge for every competing one-tick predecessor from age 8 and every two-tick predecessor from age 24. The initial configuration may have an arbitrary right tail. It correctly credits Scott Hughes’s age-7 and age-23 counterexamples to the fixed-white-wall setting. S6 supplies its own full-line age-7 witness. Sharpness at age 24 on the full line stays open here. [Hughes’s catalogue rows](https://github.com/WolframInstitute/Rule30PrizeKit/blob/e303021/lean/README.md#L340-L341)

The width-specific result uses `0 < w` and `k ≤ K1 w`. For unbounded depth, the essay states the open reset-capacity hypothesis and the implications from closed runs and relaxed doubling. It credits Troy Lowry’s cascade. The application through depth 25 from age `2^300` is identified as R74’s separate check using Quint and Gemini’s capacity result. The 392 portal entry IDs still match R74’s search. New open PR #383 constructs a six-step finite ancestor from a prescribed singleton edge prefix. Its hypotheses and existential conclusion differ from S6’s universal conclusion about every predecessor. [Capacity result, PR #371](https://github.com/WolframInstitute/Rule30PrizeKit/pull/371) · [Six-step finite ancestor, PR #383](https://github.com/WolframInstitute/Rule30PrizeKit/pull/383)

## Kit handoff

Both original module files match R74 byte for byte. Both catalogue rows give the necessary hypotheses, the credited work and a placeholder for the portal ID. On the M91 base, the two modules passed the kit checker on four and five headlines, with 164 and 88 constants replayed. The complete import root built successfully in 291 jobs.

On `e303021`, plain `git apply --check` failed at `Rule30PrizeKit.lean:18`. Main already counts 287 catalogue modules. Adding S6 brings the count to 289. I verified the corrected patch on a separate clean checkout. It preserves #382, both original source files and both catalogue rows. The PR body updates the base and the count. The module checker JSONs matched the originals and the complete import root built successfully in 292 jobs. The aggregate builds reused cached dependencies. The two S6 modules and the portal submission were independently compiled and kernel-replayed.

The replacement patch and PR body are in `share-scratch/gptM5/S6/e303021/`. The evidence bundle includes the exact digests, checker JSONs, fresh notebook comparison, dry-run result and both aggregate build receipts. Read-back SHA-256 for `share-scratch/gptM5/S6/R77-S6-release-read.zip` is `b3291ab363181476fc1c9f8dad6c3bf25932459d597c7c6063acfb6a6a82021f`. The author’s agreement on the final kit digests is pending.
