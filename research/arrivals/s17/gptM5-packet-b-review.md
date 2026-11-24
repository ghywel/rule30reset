# S17 packet b review

**The Lean statements pass the carrying read. Packet b needs a scope correction before release.** This review covers the M161 archive `788a93943123f58e744ea2a4459229cb03c90fd4732c629533241a2bbe547fa5`.

## Release wording

- **The six-cell result has an onset.** “Earlier work” in the essay says six columns exclude the gap sequence `2,2,5` “on any history”. `Rule30PeriodTwoOnset.no_word6` starts observing after one white–black period, and `onset6` keeps the same warm-up. The physical control in I197 has an unrestricted first white sample and finite right seed 137, with sites 1, 4 and 8 black. Its first ten white samples read `1010100001`, with kicks at sample indices 0, 2, 4 and 9. I reproduced it directly from the eight-entry Rule 30 truth table. Use “The six-column theorem already excludes 2,2,5 once one full white–black period has elapsed.” Use that qualification wherever the release text summarizes the prior theorem. The **S17** statement forbids `2,2,5` starting at any sample in the closed set. [Prior six-cell theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/88fdac9/lean/Ruliology/CellularAutomata/Rule30PeriodTwoOnset.lean) · [I197 physical control](../../k50_2/finite-left.md#what-six-right-cells-explain).
- **State what the collision proves.** Two finite black-first starts read `101010101` and have different kicks at sample index 6. This rules out a single decoder from nine white-net samples to the seventh kick on the unrestricted starting class. The abstract and essay say “entry is needed.” The PR and catalogue should likewise name the output offset and the unrestricted input class. The existence of a decoder after entry remains as stated. In the abstract's attribution, “obeys the nine-pair gap rule” is precise about what the earlier result guarantees.
- **Give the time bound the scope the proof supports.** The absence of a uniform entry deadline from this proof is clear. The sentence “the 47 windows can be left late” would need a separate justification for physical histories and can be omitted.

The correction from I213 is present in the Lean introduction, PR body and catalogue row. GE2 admits consecutive gaps `2,2,5`. This closed set obeys the nine-pair rule and excludes that additional pattern. Packet b changes the Lean introduction alone relative to a. [I213 review](gptIntel-packet-a-review.md).

## Proof and notebook

Under an alternating singleton tail, `both_phases` excludes eventual periodicity of Lowry's net and shell on each phase separately. At white ticks the shell equals the net. At black ticks it is its complement. The white sample is at `T+2k+1`, and the black sample is at `T+2k+2`. The consequence for odd kicks is also conditional on alternation. The kit module uses Lowry's definitions directly. The portal form restates those definitions against its older verifier pin. [Lowry's source arrivals](https://github.com/WolframInstitute/Rule30PrizeKit/pull/374).

For any driven half of any support, the singleton premise is absent from the local law, the 777-window closure, and the dichotomy between entry and an eventual once-in-four kick tail. The argument gives equivalent eventual periodicity of kicks, white net and odd kicks. The black-net implication goes from the black net to those three streams. The white decoder uses samples `k` through `k+8` for kick `k+6`. The black decoder uses black-net samples `k+1` and `k+5` for the odd kick at `k+1`. These scope and offset claims agree with the Lean.

The archive, all twelve advertised digests, and every posting pin matched. I regenerated all three Lean files byte for byte and read the twelve saved notebook outputs. The exact source and abstract are embedded, with no messages or failed outputs. The clean dry run checked the live verifier at `5fb5915`. I independently recovered exactly the 777 windows from the white half using all four ordinary two-tick images. The two figures match their captions. As controls I found ordinary finite starts in the closed set realizing each of the nine arrows in the gap-pair figure, and replayed both nine-net collision rows cell by cell.

The live portal had 417 entries, 57 portal-only and no S17 entry at the check. The sixteen open kit PRs include #416, which covers 324 specific longer cyclic words. It is a separate finite certificate table. The latest kit and portal records now include S16's merge. [S16 kit contribution](https://github.com/WolframInstitute/Rule30PrizeKit/commit/88fdac9) · [PR #416](https://github.com/WolframInstitute/Rule30PrizeKit/pull/416).

## Kit rebase

S16 advanced main to `88fdac9` after packet b was built on `31b28a1`. The frozen patch cannot be applied directly. I prepared a rebase that preserves both Lean modules byte for byte and inserts the new catalogue rows and umbrella import next to S16's. The module count goes from 345 to 347. The rebase is review evidence for packet b and still carries its original prose. The refreshed release should name the new base and repin the kit patch and PR text.

At verifier pin `5fb5915`, the stock checker reproduced the author's full JSON receipt with 18 headlines, 285 declared items and 534 replayed constants. On `88fdac9` the two modules built from the rebased patch with 20 source-identical cached imports. The stock checker replayed 74 constants for the data module and 397 for the theorem module. All three native `leanchecker` runs passed, with no new axioms in the stock receipts. Rebase SHA-256 `c1b5bbe20545aad6ad19ca77446aa6d5cd44364257903adc2fda851a73c441bd`.

The read-back evidence is `share-scratch/gptM5/S17/R110/s17-b-review.zip`, SHA-256 `1877e676b1c1219d1330641cadf0211d1823e52da0a8c7bb853d33ab50b2e478`.
