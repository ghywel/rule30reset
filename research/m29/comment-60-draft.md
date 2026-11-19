# Draft comment for kit PR #60

*The owner's word (19 November): leave a comment on #60 saying where we credit it, and remind its author that these
pull requests are still open, awaiting the requested changes. Drafted by claudeCloud (K10), checked against the
twelve threads and [posted by gptIntel](https://github.com/WolframInstitute/Rule30PrizeKit/pull/60#issuecomment-7015552999) at the owner's request.
Comments on kit pull requests carry no credit line (METHOD §12).*

---

Thank you for proving that a supplied reset schedule closes an inverse cascade of any finite height. We are using
that result in our work on #357.

**Where we credit it.** Your `run_resets` and `scheduled_cascade_closes` supply the reset and cascade steps towards
the statement requested on #357. The open step is to show that, for every k, aged nonzero finite orbits admit the
required schedules. Such a schedule would force every k-tick preimage to have its true edge k cells inside the
image edge.

- The kit already cites `Rule30InverseCascade.run_resets` in the [docstring of
  `Rule30RightWall`](https://github.com/WolframInstitute/Rule30PrizeKit/blob/35f2c6e/lean/Ruliology/CellularAutomata/Rule30RightWall.lean#L23).
- Our working repository credits this PR in [prior-art entry P6](https://github.com/ghywel/rule30reset/blob/main/PRIOR-ART.md)
  and in step 1 of the [written chain for every k](https://github.com/ghywel/rule30reset/blob/main/research/m29/every-k-chain.md).
- For the Lean module we are preparing for #357, we plan to credit this PR in the docstring and catalogue row.
  The portal verifier currently uses the kit revision of 5 November, so its version needs a local proof of the
  reset step. Once this PR is merged, the kit version can import it.

**A reminder.** This pull request is still waiting for the changes the maintainers asked for on 30 and 31 October:
the date written as `2026-10-30`, the last paragraph of the docstring, the wording of the credit line, and the
`Rule30InverseCascade` import, which sits after the module docstring so that `lake build Ruliology` fails.

Eleven more of your October pull requests are still open. The latest maintainer requests on those threads date
from 28–31 October.

- #23 and #33 were marked ready to merge after a rebase.
- #40 requests a missing credit and the order of the two module names in a catalogue row. #41 requests full dates
  and credit lines. #47 and #48 each have a credit edit and a rebase request.
- #38, #39, #52, #55 and #57 have changes requested to their content.

We would be glad to see this one in the kit.
