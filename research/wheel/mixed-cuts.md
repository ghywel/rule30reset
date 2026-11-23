# Two mixed gap words outside the period-two trap

Sample the cell immediately right of an alternating wall at each white-wall tick. Start at a black sample. A digit counts the number of samples to the next black sample, including its arrival. Thus each repetition of `33355` lasts 19 samples (38 physical ticks), and each repetition of `333355` lasts 22 samples (44 ticks).

## Finite cuts and their consequence

The width-31 classification established three possible eventual words for a gate with only 3- and 5-gaps that stays outside the kit’s trap. ClaudeCloud’s K77 eliminates both mixed words. After a white-wall kick, **seven complete repetitions of `33355` cannot end outside the trap**, and **nine complete repetitions of `333355` cannot end outside**. The first cut uses 55 positive sites, the second 44. Both hold for every right exterior, even one with infinite support. The word can start at any late occurrence of the indicated kick. [K77’s wider lifts](claudeCloud-tails.md) · [Width-31 classification](exterior-tails.md).

To see why the cuts suffice, restrict any proposed right half to the tested strip. At its eastern boundary every next input is free. A physical evolution supplies such an input and therefore satisfies every interior update. An infinite mixed tail with any rotation contains the tested phase and the entire finite run from it. Closure of the trap makes a run ending outside remain outside at all earlier samples of that run. That would satisfy the corresponding rejected formula. The only surviving exterior gate in the classification is **eventually one kick every three samples**. The October rotating 84-ring realizes it. On a full line with a leftmost black cell and an eventually alternating wall, masked Jen already excludes this periodic gate. The remaining prize question is how the singleton could acquire the 3/5 gap law.

## Stronger physical test

Remove *every* clause about the trap. **Six complete repetitions of `33355` are physically attainable, and seven are impossible.** The finite initial row `0x6313f2973417e999be6ed08a17`, with site one in the low bit and all farther sites white, gives a physical witness through tick 228. Its last window is trap code 3495. The unrestricted width-55 cut for seven repetitions has 29,582 variables and 102,012 clauses. Its LRAT refutation passed lrat-check and CakeML’s cake_lpr. Thus the bound applies inside and outside the trap. The positive row proves sharpness with unrestricted trap membership.

For `333355`, nine repetitions are also physically impossible with unrestricted trap membership. The 44-column strip without the trap predicate admits a model, as does width 60. At width 72 a second independently checked strip cut excludes that same reading. A full triangular physical cone gives the same answer, checked from a separate CNF with 169,504 variables and 591,229 clauses. **Eight complete repetitions are attained by a finite right row supported through site 346. Thus eight is the sharp physical maximum.** Its 177 white samples span 352 physical ticks. The independently replayable starting row is in the [proof and witness index](data/mixed-cut-receipts.json).

The kit already rules out three consecutive 3-gaps after entry. Both mixed words start with this factor. Accordingly, any actual occurrence stays outside at least until the beginning of the last such triple. In the two maximal witnesses the first trap entries occur at physical ticks 214 of 228 for `33355` and 340 of 352 for `333355`. Both end at trap code 3495. The kit law also gives a quick independent qualitative deduction: one further repetition after either K77 cut is impossible, because the cut forces trap membership and the next triple contradicts it. The unrestricted certificates give one fewer repetition in each case. [Kit’s five forbidden words](https://github.com/WolframInstitute/Rule30PrizeKit/blob/f41bb49/lean/Ruliology/CellularAutomata/Rule30GateTrapWords.lean#L769).

## Reproduction

The [published-formula replay](certify_mixed_cuts.py) regenerates every negative in ClaudeCloud’s [published SHA-256 prefixes](data/claudeCloud-wheel-exterior-sat.txt) and the two neighboring satisfying strips. The log contains ten negatives despite K77’s request referring to six. The stored strips include a freely driven east bit at each physical tick and verify the boundary, every local update, gate sample and trap test. A positive strip certifies existence for that strip with that forcing. A positive *physical* run requires an initial light cone which survives without supplying those free bits.

The [independent encoder](mixed_cut_strength.py) uses a separate Boolean variable for the OR in each Rule 30 update. It checks the two decisive cuts with trap exclusion only at the last sample. It then removes that clause family too. [Physical threshold search](mixed_physical_threshold.py) uses triangular cones and replays positive models from finite initial rows. [Witnesses and proof index](data/mixed-cut-receipts.json).

```text
python research/wheel/certify_mixed_cuts.py Rule30PrizeKit wheel-mixed
python research/wheel/mixed_cut_strength.py Rule30PrizeKit wheel-mixed
python research/wheel/mixed_physical_threshold.py Rule30PrizeKit
python research/wheel/mixed_physical_threshold.py Rule30PrizeKit --search wheel-mixed
```

Use the kit trap table in f41bb49, NumPy, python-sat, CaDiCaL, lrat-check and cake_lpr. The corresponding .lrat.zst files in the shared-store folder `share-scratch/gptIntel/I170/mixed-cuts/` decompress to the proof digest in the index. The CNF generator checks the original published digest prefix before certifying any K77 cut.
