This adds a uniform bound on resets after a first clock loss, at every clock.

**`Rule30ClockPhasePairs`.** On a recurrent strip with a first clock loss `FirstLoss d a e` and next permanently white wheel `NextWhite d a b` (`Rule30RelaxedWindows`):
- `five_ticks`: every five consecutive ticks contain one at which wheels `j`, `j + 1`, `j + 2` read white, black, white, with `a ≤ j` and `j + 2 ≤ min(b, a + 7)`, for every `e` and from every starting tick.
- `three_pairs`: among three consecutive ticks and their translates by `2^e`, one has such a singleton by `min(b, a + 6)`.
- `cofinal_singletons`: on a pointed strip, one fixed tick of any five sees such singletons at first losses beyond every depth.
- **The proof** follows the driver wheel `a + 1` from `firstLoss_cascade_and_immediate_catch`.
  - A fall of the driver is a singleton at once.
  - Two black readings or three white readings make a wheel toggle beside a white one. Its fall gives a singleton there or at the next wheel one tick later (`toggle_catch`). In the five-tick proof the antiperiod shows that wheel `a + 4` is black at some tick.
  - Four driver readings always hold one of these cases, which gives five ticks. The strip's clock moves the bound back to tick zero.
- **Against the catalogue.** `Rule30RelaxedWindows`, `Rule30DoublingLanes` and `Rule30FirstLossBounds` together give a reset in every fifteen ticks within nine wheels. Here it is five ticks, seven wheels and a run of length one. For `e ≤ 4`, `Rule30DoublingLanes` already guarantees a reset in the first interval at each tick. The new local singleton bounds hold also for clocks of 32 and more.
- **Not shown:** the prescribed tick of `DLMinusOne`. `local_paired_nfa_escapes_in_five` shows why a paired local window cannot reach it.

**Checks.** Core Lean 4.35.0 at `ea5d70e`.
- **Build.** The module builds with no warnings, and `lake build Ruliology` passes (391 jobs).
- **Stock partial check.** Three headlines pass with 64 constants and standard axioms only. A missing headline is refused, and the standalone `leanchecker` passes.
- **Catalogue.** The count goes from 387 to 388, with the row after `Rule30FirstLossBounds`.

**Credit.** The cascade, the catch after a fall, the captures for `e ≤ 4` and the run captures are G.P.J.W. Quint and Gemini's. The proof is GPT's. The review, the fifteen-tick comparison and the scope are Claude's.

Contributed by Gareth Herbert with Claude (Anthropic) and GPT (OpenAI) as Rule 30 Prize submission [R30-ID](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-ID).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
