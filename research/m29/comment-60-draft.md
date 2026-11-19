# Draft comment for kit PR #60

*The owner's word (19 November): leave a comment on #60 saying where we credit it, and remind its author that these
pull requests are still open, awaiting the requested changes. Drafted by claudeCloud (K10). Not yet posted. To be
checked line by line against the twelve threads by gptIntel, then posted from the owner's GitHub account on the M5.
Comments on kit pull requests carry no credit line (METHOD §12).*

---

Thank you for this result. We are building on it, so here is where we credit it, with a reminder about this pull
request.

**Where we credit it.** `run_resets` and `scheduled_cascade_closes` are the mechanism behind the statement the
maintainers asked for on #357: an age f(k), for every number k of inverse ticks, from which every k-tick preimage of
a nonzero finite orbit has its true edge k cells inside. We cite this pull request:

- in the kit, in the docstring of `Rule30RightWall`, which names `Rule30InverseCascade.run_resets`;
- in our working repository, in the [prior-art record](https://github.com/ghywel/rule30reset/blob/main/PRIOR-ART.md)
  (entry P6) and in step 1 of the
  [written chain for every k](https://github.com/ghywel/rule30reset/blob/main/research/m29/every-k-chain.md);
- in the Lean module we are preparing for #357. The portal's verifier checks against a kit commit of 5 November, so
  that module proves the reset step itself, and credits this pull request in its docstring and its catalogue row. If
  this pull request is merged, we will import it instead.

**A reminder.** This pull request is still waiting for the changes the maintainers asked for on 30 and 31 October:
the date written as `2026-10-30`, the last paragraph of the docstring, the wording of the credit line, and the
`Rule30InverseCascade` import, which sits after the module docstring so that `lake build Ruliology` fails.

Eleven more of your pull requests from 25 to 30 October are open in the same state. Each has a request from the
maintainers, made between 28 and 31 October, with no reply since:

- #23 and #33 need only a rebase;
- #40, #41, #47 and #48 need a credit or date line, and #47 and #48 a rebase as well;
- #38, #39, #52, #55 and #57 have changes requested to their content.

We would be glad to see this one in the kit.
