# S17 review of the light proof

**I211, 24 November 2026. PASS for preparing one joint Problem 1 partial.** I agree to include our I203 results alongside claudeM5’s light proof. My proposed title is **“If the Rule 30 centre eventually alternates, Lowry’s source net is aperiodic on each phase.”** The centre here starts from the single black cell. Whether it can alternate forever remains open.

## What the reader can recover

On each white sample, record the kick at site +1, Lowry’s net of three source arrivals, and a mark for a kick with an odd next return. The white net equals the XOR of sites +1 and +2. The black net is sampled one physical update later. Lowry’s source definition includes a delayed central source. His distance-two shell equals the net on white and its complement on black. His canonical kit definitions accept M156’s four phase conclusions directly in Lean. Credit Troy Lowry for these observables and the two-step identity, and AIOvernight for the width-13 gate-language/pure-four alternative on arbitrary paths. [Lowry’s contribution](https://github.com/WolframInstitute/Rule30PrizeKit/pull/374) · [Width-13 theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/31b28a1e961aa044d420e569d9396128f0384752/lean/Ruliology/CellularAutomata/Rule30PeriodTwoWidth13.lean)

| Assumptions | Conclusion |
|---|---|
| Any right half beside the alternating boundary | Equal consecutive white nets detect the odd mark at the **second** sample. If a next return is specified, the net records its distance parity. |
| The initial white window of the observation block belongs to the 777-window set | Nine white nets recover the kick at index 6, with two readings still to come. Black nets at indices k+1 and k+5 recover the odd mark at k+1, eight physical updates apart. Here an odd return lasts three or five white intervals. |
| Any right half beside the alternating boundary | The gate, white net and odd mark are eventually periodic together. Eventual periodicity of the black net also forces the gate to be eventually periodic. |
| Eventual alternation of the singleton centre | Masked Jen excludes eventual gate periodicity. Each phase of the net and shell, and the odd-return timetable, must be aperiodic. |

The third row strengthens M156. Its entry theorem gives two possibilities. After entry the existing decoders transfer periodicity. On a tail with one kick every four white samples, the next-return law makes the white net alternate and every odd mark vanish. These cases exhaust the possibilities for arbitrary support. The public module title should state the singleton conditional. The working title’s assertion that every half enters is stronger than the proved dichotomy. [Reviewed source](Rule30ArrivalsLight.lean) · [Four new Lean headlines](Rule30ArrivalsPeriodicity.lean)

## A check on the scope

Start the black boundary with sites 4, 5 and 6 black, or with sites 1 and 4 black, all other right sites white. Both rows read `101010101` on the first nine white nets. At the seventh reading the first row has no kick and the second has a kick. Lean proves that **any** decoder using those nine observations fails on some finite start. This illustrates why a late decoder can succeed even though the same readings are ambiguous at startup.

The direct Rule 30 truth-table check exhausted all 524,288 width-19 starts. Of these, 182,272 start their first white observation inside the closed set. Both decoders matched throughout that subset, and the adjacent-white marker matched on every start. The four physical extensions of each of the 777 windows all stayed inside.

## Release path

The M156 generator reproduces the 99,328-byte source on Windows. Its 14 headlines and the companion’s four passed on the portal pin `5fb5915` and kit main `31b28a1`. A single-file integration under the portal’s required name passed all 18 on the pin, with 534 constants replayed and zero new axioms. A public-index and open-PR check alongside P62/P64 found the cited predecessors and no duplicate of the phase and decoding statement in the records reviewed.

I recommend that claudeM5 build the notebook and matching kit change on the owner’s word. Lead with the conditional phase result, use the two finite rows as the worked example, and put the 777-window table in the proof. The submission still needs the notebook dry run and a release read of the frozen packet. Replays, integrated source and the independent enumeration are in `share-scratch/gptIntel/S17/I211/s17-path-review.zip`, SHA-256 `dbd41d7d061a178d410fc75ff4124bbf01c6426af49268cd5726977a39533c44`.
