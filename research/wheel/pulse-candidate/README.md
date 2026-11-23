# Two cells predict the next pulse beside an alternating Rule 30 column

**Internal proposal for a Problem 1 partial.** At a black pulse in the immediate right neighbour of an alternating column, read the two cells at positive sites 2 and 5. Starting at the second white tick, these bits in the order `00, 01, 10, 11` give gaps of 4, 2, 5, 3 white intervals respectively, for every right half. Every intervening white reading and the next black reading are determined. Four finite rows realize all four gaps at this same age. A single observed bit cannot select among them. A finite example gives the wrong two-site answer one white reading earlier. On the actual singleton, any missed deadline or premature pulse locates an alternating-centre discrepancy strictly before the predicted endpoint. Whether its centre can alternate forever remains open. [Isolated Lean module](Rule30Submission.lean)

**Proposed public credit** is Gareth Herbert; Claude (Anthropic); GPT (OpenAI). Bosdure, Claude, Gemini and Grok established the trap and its 3/5 gap law. Lowry’s packed-prefix transport and separate seven-cell return theorem, and Quint’s two-tick right-germ identities, are the closest external comparisons. The project’s original site-5 relay handled trapped pulses. This proposal carries the first-return theorem for all right halves and its finite-clock consequence. The exact trapped second-return selector has its own research proof. [Bosdure and collaborators](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261027-230bc7) · [Prior work and chain test](../pulse-forecast.md#prior-work-and-the-chain-test)

## Four public headlines

- `next_gap_from_second_white` gives the full physical first return, including every intervening white reading.
- `no_one_bit_forecast` excludes every Boolean measurement with a fixed positive-gap decoder, already on finite starts.
- `first_white_can_fail` gives the finite counterexample to starting the two-site rule one reading earlier.
- `singleton_clock_break` converts a failed prediction on the genuine singleton into a finite witness of a centre discrepancy.

## Verification

The source SHA-256 is `e23630e1655bef2192b47da38fb29f4adca54f8d118e94c1776fd33885bb54f7` (11,177 bytes). The independent clean build at the portal pin reproduced the original object byte for byte. Lean 4.35.0 and the stock checker reported four passing headlines, 63 replayed constants, and zero new axioms on each of these pins. [Full portal receipt, three pin checks and mutation](verification.json)

| Kit use | Exact commit | Stock verdict |
|---|---|---|
| Portal verifier | `5fb591588cfa869bfdc47946799b5ddd70a903d1` | pass |
| Wheel research | `f41bb494d64f120e0e6f07ab68d799a6018396cc` | pass |
| Kit main at review | `80994b1ae1e31c629367ec6133e2c3db63700a0a` | pass |

A separate mutation changed the output for sites `00` from 4 to 5. The stock Lean compiler rejected `two_updates` at line 101. Independent evolution of the finite black-first row 15 gives sites `00` at tick 3 and gate readings `10001` at ticks 3, 5, 7, 9, 11, directly contradicting the mutated deadline.

To reproduce from the research repository root on a POSIX shell, set `kit` to the absolute checkout of one of the listed commits. The local Lean toolchain must match its `lean-toolchain`.

```sh
src="$PWD/research/wheel/pulse-candidate"
out=$(mktemp -d)
cd "$kit/lean"
lake build Ruliology.CellularAutomata.Rule30Prize Ruliology.CellularAutomata.Rule30GateTrap
export LEAN_PATH="$out:$PWD/.lake/build/lib/lean"
lean -j1 -R "$src" -o "$out/Rule30Submission.olean" "$src/Rule30Submission.lean"
lean --run "$kit/Check.lean" Rule30Submission --claim partial \
  --headline Rule30Submission.next_gap_from_second_white \
  --headline Rule30Submission.no_one_bit_forecast \
  --headline Rule30Submission.first_white_can_fail \
  --headline Rule30Submission.singleton_clock_break
```
