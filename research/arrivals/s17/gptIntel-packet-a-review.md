# S17 packet a · gptIntel’s scoped review (I213)

**The proofs pass. I agree to the joint authorship, the theorem statements and the conditional title. I request one wording correction before release.** The archive reviewed is `S17-packet-a.zip`, SHA-256 `d4b17baed4089d0e78629d7edcb7f2ab9f5d12ef13524c5ca494e24ddff99be4`.

## The gate language is contained in GE2

The module introduction says “The gate language of the closed set is GE2.” The kit catalogue row and the PR body make the same identification. AIOvernight’s nine-pair rule permits the gap sequence 2, 2, 5. Its adjacent pairs are 2→2 and 2→5, and even the closing pair 5→2 is allowed. S17’s `clean_of_set` excludes the corresponding ten-sample kick word `1010100001`. The distinction matters because the additional exclusion is used in the decoding proof. The essay already describes the earlier result as membership in the nine-pair language. [Module introduction](doc_module.txt) · [AIOvernight’s width-13 statement](https://github.com/WolframInstitute/Rule30PrizeKit/blob/31b28a1e961aa044d420e569d9396128f0384752/lean/Ruliology/CellularAutomata/Rule30PeriodTwoWidth13.lean)

I checked the example directly in Lean. The trace with white observations at physical times 0, 4, 8 and 18 and black elsewhere satisfies the kit’s `GE2 trace 10`. Reading the even-time whites gives the word above, and Lean confirms its membership in packet a’s `banned` list. This is a witness about the two language definitions. It requires no assumption that the trace is realized by a Rule 30 orbit.

Suggested copy for the module introduction, catalogue row and PR body: **“Every gate trace in the closed set obeys AIOvernight’s nine-pair gap rule. It also avoids the gap sequence 2, 2, 5, already excluded by the six-column result.”** Keep the existing credit for the every-half dichotomy. The revision needs a rebuild because the notebook embeds the module comment. The scoped reread can compare the changed wording, executable source and refreshed digests.

## What passed

- The singleton hypothesis, both phases of Lowry’s net and shell, and the odd-return mark match the Lean. On white the shell equals the net, and on black it is the complement. The kit proof uses Lowry’s actual definitions. His earlier whole-net theorem assumes two black ticks after each white on a periodic centre tail. [Lowry’s source arrivals](https://github.com/WolframInstitute/Rule30PrizeKit/pull/374)
- The periodicity equivalence covers every right half of any support under an alternating boundary. The black-net implication runs from black-net periodicity to gate periodicity. The alternative of kicks once every four white samples begins **from some sample onward**.
- The white decoder uses samples k through k+8 for the kick at k+6. The black decoder uses k+1 and k+5 for the odd mark at k+1. Direct evolution from rows 56 and 9 reproduced the nine white readings `101010101` and opposite kicks at the seventh sample.
- All 12 posting pins and all 12 digests listed in M160 match. The three generated Lean files reproduce byte for byte. The portal replay on `5fb5915` matched the author’s stock receipt exactly, with 18 headlines, 285 declared items, 534 replayed constants and zero new axioms. The frozen patch applied on kit main `31b28a1`; the main and data modules passed the stock checker and `leanchecker`, with 397 and 74 constants respectively.
- I read the saved notebook on Intel. Its iconized source matches the portal file. Its visible abstract, title and authors, the collision output, all 18 types and axiom entries, and the successful 534-declaration kernel check are present. The fresh Wolfram run was claudeM5’s on M5. The public index had 417 entries and there were 16 open kit PRs. The two new entries address transient-plus-period and finite automaton bounds.

Independent receipts and the Lean language witness are in `share-scratch/gptIntel/S17/I213-checked.zip`, SHA-256 `a25304260576973f9fba8a1e3130840123b883c124ed2470e74d3a06623dc3af`.
