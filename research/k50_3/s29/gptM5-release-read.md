# S29 release read

gptM5, R137, 26 November 2026. **PASS on packet c and the revised kit patch.** I confirm the final R136 source and its presentation in the abstract, notebook and kit text. I also carried the depth-two theorem and read the combined packet at the owner's request.

## Statements and release corrections

- `two_classes` quantifies over every natural inverse depth and every cutoff `T ≥ 2`. Restricting to a new wall uses only sites negative relative to that wall. Restarting at time `t − T` puts the edge exactly two sites west of it. In the reverse adjacent implication, the first tick yields the depth-two start black at −1. For the depth-two start white at −1, the wall change `!c 0 || c 1` at tick one realizes the same negative row at age two. From there the wall tapes agree. Both directions preserve the expected position of the inverse edge.
- Packet a generalized the one-tick offset to the unrestricted minima. At `k = 0`, applying the kit's forward edge theorem gives `ExactAt 0 m t` whenever `m ≥ 1`, including age zero. A separate Lean client checked that control. The revised text gives the offset for the paired cutoffs `T ≥ 2` and `T + 1`.
- The notebook's age search now records the two initialized inverse bits at sites −1 and 0, so the predicate checks those positions explicitly on short rows. A proposed exact edge strictly east of the wall fails the universal test, since those cells are free. The computed outputs still give 8/9, 24/25 and 31/32. The later thresholds in the second display are recorded computations.
- `unique_parent_of_every_k` still assumes an exact age at depth two for each inverse depth. Its conclusion is at most one full-line predecessor for a black-edged recurrent row. Recurrence is periodicity of each finite edge band. The first parent can be extended by the free-wall inverse recurrence, and exactness for the deepest layer supplies the autonomous history of its band. A periodic target band is realized at any selected age of the corresponding width. The one-tick case locates the edge, and the cycle predecessors determine every finite band. N31 carried this proof. The link to CAP in the essay uses the earlier hand argument, and the existence of a uniform age for every inverse depth remains open.

## Verification

- Sealed Lean source equals packet a. The R136 proof body is unchanged in the portal source, and the entire kit module equals the R136 source. The sealed depth-two proof has only typographic changes to a docstring. The copied band lemmas match kit main except for a section heading. The revised kit depth-two module changes its opening commentary only.
- Lean 4.35.0 at the live verifier `5fb591588cfa869bfdc47946799b5ddd70a903d1`. Stock check reproduced the sealed receipt exactly, all ten headlines and 206 declarations with standard axioms only. `leanchecker` passed and a missing headline was refused.
- A fresh Wolfram build took 25.6 s and yielded seven outputs with no messages, failed outputs or local paths. The final notebook has the same title and authors as the API files, the revised 229-word abstract and the exact Lean source. I read the computed output and the kernel's acceptance of 206 declarations. The posting dry run passed against the live verifier.
- The revised patch applies cleanly to current kit main `389bede`. Both added modules rebuilt independently. The stock checker accepted four headlines and 76 declarations for `Rule30DrivenLeftDepthTwo`, and six and 73 for `Rule30DrivenParentBand`. Both passed `leanchecker`. I checked the unchanged `Ruliology.lean` import list against M214's 384-job build with the two newly built modules substituted. The two catalogue rows and patch description now state the exact ranges. The portal entry ID is filled after posting.
- The live portal list had 452 entries. The new Quint entry and its open kit PR #448 concern period-three observables. I also checked Lowry's #60 on scheduled inverse cascades and #383 on a six-tick singleton certificate. These leave the two general statements of S29 distinct. [#448](https://github.com/WolframInstitute/Rule30PrizeKit/pull/448) · [#60](https://github.com/WolframInstitute/Rule30PrizeKit/pull/60) · [#383](https://github.com/WolframInstitute/Rule30PrizeKit/pull/383)

## Approved files

| File | SHA-256 |
|---|---|
| `share-scratch/gptM5/S29/v3/S29-packet-c.zip` | `abed5d5c9fef13767b6a70e743acc6fb081d16bca4e2d69ee6de02a64bece01b` |
| `share-scratch/gptM5/S29/v2/S29-kit-b-389bede.patch` | `be64328e2499e97c67c6bf045de9fe791783e211ce1c49bdedbf33251cb49ef6` |
| `essay.nb` | `fc8546c041b5fd617d8b878a51f6a82d128878fbefcc53d0c993a0cb2ecc83c2` |
| `essay.md` | `3448ba0c16a64f3fac22d6d22cb10f960d55c804464a1be3390bc0f724ad19a6` |
| `abstract.txt` | `8c44ba263f25859ef78e9ae107821d14d9b0ef997fd13f94f8e777a899fb5f39` |
| `Rule30Submission.lean` | `024047dd5509d5556a7aa731bf808f418709f39195f4e5287af42afbb9d57742` |
| `Rule30DrivenParentBand.lean` | `16d1b55d9de1ac23739c9be3ac9c2f02f01c227a2156fb052de7104ad1ffd065` |
| `pins.json` | `0a41b60be7470a1efbf2d19c8d419529fda2094d2d88c9079fd5379d9427c385` |

The archives were read back by digest. The owner's release authorization is pending.
