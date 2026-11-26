# Carrying read of I273 (S28), and packet a

claudeIntel, N29, 26 November 2026. It answers I273's and K91's REVIEW flags, and the owner's "Please begin the review and assembly of S28 whilst claudeM5 is
currently busy". Proposal packet `share-scratch/gptIntel/K83/S28-proposal.zip`, `c196f043…`, 41,716 bytes, read back. Its 25 files match its manifest, and its
sources, builders and texts equal the committed files. Both sources regenerate byte for byte.

## Verdict

**The measure part, nine headlines: PASS.** The Lean says what the essay says, the assembly changes no proof, and the feedback attribution is right.

**The finite-support part, three headlines and the core companion: the Lean is right, but the result is known.**
- All three statements are in the kit already, two of them in K91's form and the third as Quint and Gemini's theorems in `Rule30CoupledGerms` (§3).
- METHOD §12 says a known result is not submitted as new.
- **Repair:** drop the three theorems from S28, and drop its kit route.

**Packet a**, with that repair, is assembled and checked at the verifier's pin (§4). It still needs the notebook, which only the M5 can build.

## 1. Replays (mine)

| Form | Where | Result |
|---|---|---|
| I273's portal source `e20b3b4d…` | pin `5fb5915` | Compiles in 45 s with no warnings. Stock check passes 12 headlines, 95 constants, no new axioms. A missing headline fails; `leanchecker` passes in 98 s. |
| I273's core companion `2e71657d…` | fresh worktree at kit main `aaaefdd` | 16 jobs in 64 s. Stock check passes 3 headlines, 11 constants, no new axioms. A missing headline fails; `leanchecker` passes. Patch `e7c85078…` applies. |
| Packet a's source `e737f060…` | pin `5fb5915` | Compiles in 38 s with no warnings. Stock check passes 9 headlines, 84 constants, no new axioms. A missing headline fails; `leanchecker` passes in 93 s. |

These match gptIntel's counts. [Receipt](data/claudeIntel-s28-receipt.json).

## 2. The measure part

**The assembly changes no proof.** I diffed each part against its source.
- `RightHalfPast` is `K83RightCoin` (`52c1c53b…`, read in N16) with only the namespace renamed.
- `RightHalfFeedback` is `K83Feedback` (`eaa94dd1…`, read in I235). Its namespace, one `open` line and its opening comment change.

**The statements say what the essay and abstract say.**
- `after_exact`: for every word `w`, every `T` and every measurable `E`, 2⁻ᵀ μ(F_w⁻¹E) = μ(S_w ∩ E).
  - `w` is the centre trace (site 0). Index 0 of a right half is site 1.
  - Only `w(0)` to `w(T − 1)` matter (`right_congr`), and `S_w` is closed.
  - `mass_attainable` gives the mass 2⁻ᵀ, so the output law is μ conditioned on `S_w`.
- `incompatible_pasts` needs one differing bit below `T`. `countable_long_past_null` allows inconsistent families of words, which is more than the essay claims.
- `driven_exact` allows any continuous `W` that picks the whole trace from the initial right half, so it may look ahead. `later_exact` is the case of the physical centre beside a fixed `L`. `L` is arbitrary, includes site 0 and may have infinite support.
- `reduction` takes the hypothesis for every nonempty finite `s` and every period `P + 1 ≥ 1`, with the word read from tick 0. It concludes, for each such `s`, that almost every right half gives a centre with no eventual period of any length `P ≥ 1`.
- `ae_read_all` is a statement about almost every fair *row*: its right half at tick `T` fixes every earlier cell at and east of site 0, against every other row. I273's abstract said "almost every final right half"; packet a's essay states it for the row.

**The feedback attribution.** `K83Feedback` is mine (N16), and gptIntel read it in I235. It builds on gptIntel's `K83RightCoin` (I229), which I read in N16. Both models wrote parts, so the portal author line names both. I confirm the assembled `RightHalfFeedback` is my proof unchanged.

## 3. The finite-support part

**The Lean is right.**
- The physical indexing matches the kit's conventions:
  - `glue L R` puts `L k` at site −k and black at site 0;
  - `altCol` is black at even ticks;
  - `u R s` is site 1 at the white tick 2s + 1 of the driven half;
  - "through `T`" includes `T`.
- My own check uses the literal rule on finite windows, with no kit code ([script](claudeIntel_finite_support_check.py), [output](data/claudeIntel-finite-support-check.txt)). It builds `Psi R` greedily and finds exactly one working west bit at every depth. All three statements then hold:
  - the first on 3,600 wests;
  - the second on 1,073 cases of (R, B, T), trying every west supported in 1..B;
  - the third on 400 pairs of right halves.

**The result is known.**

| S28 theorem | Already in the kit |
|---|---|
| `alternates_through_iff_prefix` | `Rule30PeriodTwoSideways.exact_death_center` (17 October): the first depth where `L` differs from `Psi R` is the first tick that fails. If there is no such depth up to `T`, the kit's `zrow_light_cone` gives the agreement. The catalogue row says it in words: "a left row keeps the center alternating exactly until the first depth where it differs from `Psi R`". |
| `supported_west_iff_white_section` | `Rule30PeriodTwoSideways.truncation_death` (17 October): `Psi R` cut at `B` alternates exactly until its first black depth beyond `B`. That is the witness. Any other west supported in 1..B agrees with `Psi R` to `T` by the row above. |
| `required_west_prefix_iff_gate_prefix` | `Rule30CoupledGerms.Psi_eq_of_u_eq_le` and `u_eq_of_Psi_eq_le`, by Quint and Gemini (portal R30-20261104-bc49cf, in the kit), which specialise `Rule30ZeroBoundary.Theta_dep` and `Theta_inverse_dep`. Their condition 2s + 2 ≤ k is S28's 2s + 1 < k, taken for every depth k ≤ T. |

K91 found the first two and proposed folding them into `Rule30PeriodTwoSideways`. Neither I273's novelty check nor K91 found the third. With all three known, an extension would only restate the kit, so I recommend no kit route at all.

The use I246 made of them still stands: a census of gate words counts the required west prefixes. It should cite these kit theorems. As a check, over every right half on sites 1 to T + 1, the two counts agree for T = 1 to 11: 1, 2, 2, 3, 3, 5, 5, 8, 8, 12, 12 (COMPUTED).

## 4. Packet a

`share-scratch/claudeIntel/S28/S28-packet-a.zip`, 21,931 bytes, SHA-256 `b389833d81fc41cbd0beefe2fcd90d2a69073747dc1d4140879dcc8a86598bd0`, read back.
[claudeIntel_assemble_s28.py](claudeIntel_assemble_s28.py) builds it on gptIntel's `build_submission.py`, which it runs unchanged and checks against `e20b3b4d…`.

| File | SHA-256 | What changed from I273 |
|---|---|---|
| `Rule30Submission.lean` | `e737f060…` | The `AlternatingFiniteSupport` section and its import are dropped. Three internal labels in my own feedback comments are replaced: "of I229" is dropped, and "A1" becomes "almost-sure aperiodicity" and "purely periodic words". No proof changes. |
| `headlines.txt` | `58e08fb2…` | The nine measure headlines. |
| `abstract.txt` | `b1a3a867…` | Rewritten in the portal's order: the results with headlines in code, what the kit had, the method, and what is not claimed. 244 words. [Text](abstract-packet-a.txt) |
| `essay.md` | `b98a2692…` | From I273's draft. The finite-support section is dropped. The prior-work section names the kit's exact-death and prefix theorems. The front matter is added, and the source sits in one `LeanImportString` cell, byte for byte. [Template](essay-packet-a.md) |
| `title.txt` | `b510296e…` | Unchanged. |
| `authors.txt`, `agent.txt` | `c14f91c2…`, `d7fae0e9…` | The owner's form with Claude and GPT, as for S27; the agent is the one that posts. |

- **Route:** portal only. The theorems need measure theory and have no core form. `equivalents/` is possible later, at the owner's word (METHOD §12, rule 4).
- **Novelty, repeated independently:**
  - `find_known` for each term;
  - the kit at `aaaefdd`, plus `6df813b`, which arrived during the read and whose #441 and #443 are unrelated;
  - the portal's list, 447 entries, updated 17:03 UTC.

  The kit's `RandomConfigurations` has the independence and bijection of trace and right half, but no law for the image of a driven half. No portal entry states one. **Chain test:** no chain; the statements cover every `T`, every word and every continuous rule.
- **Still to do:**
  - `essay.nb`, built from `essay.md` on the M5 with `build_notebook.wl`;
  - `build.json`, `pins.json` and the `post.sh` dry run;
  - the M5 builder should confirm that `RULE30PRIZE_KIT` resolves `Rule30Equivalents.Mixing` in the notebook.

## 5. Asked

- **gptIntel** (progenitor):
  - the release read of packet a;
  - a scoped read of my two changes to the source, which is Claude's work (METHOD §12);
  - your call on the drop.

  If you keep the finite-support theorems, the proposed form passes my replay too. They would then need the kit's theorems named as their source, and no new kit module.
- **claudeM5 or gptM5:** the notebook build, `pins.json` and the dry run from packet a.
- **The owner:** nothing yet. The word to post comes after the release read.
