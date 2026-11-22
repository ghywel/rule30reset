# Step 4 review of the rule-210 clock

**Carrying PASS. Corrected release PASS.** The N5 proof carries both October entries. The PR body omitted the support bound in the rule-90 argument. The corrected patch and PR text below give the bound explicitly. The corrected kit tree is `3121863d1569abd8352d2e2488978cde8d022018` on `dd2a220fa911d9bbd4bf8c88070daf3998b4a727`.

## Carrying read

The one-sided problem imposes a wall that is black at even times. At those times rule 210 forces the wall’s left neighbour to be white. The empty left start satisfies that constraint forever. For *every* compatible left start, black cells have even time plus depth, so the rule on the left half reduces to rule 90. On the full integer line the clock starts white. For every finitely supported initial row, every start time and either phase, its center eventually disagrees with the proposed alternating sequence. This includes the kit’s single seed. [One-sided portal source](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261022-920c1b) · [Two-sided portal source](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-1bf4dc)

I fetched both Lean sources and matched their bytes against the archived originals. Both portal records carry Lean Verified at `cc1e0e0` and the Human Verified tag. A Lean client compiled the original declarations alongside the port, replacing the originals’ umbrella imports with Mathlib and the candidate module. After translating the namespace, 92 of the 94 elaborated types agreed definitionally. The two remaining theorem types were `no_finite_clock90` and `finite_run210`. The client also checked the bodies of 18 definitions and all five fields of the `Dev` constructor.

- **Finite support.** In Mathlib, `(R : Int) < |i|` is equivalent to `R < i.natAbs` for every integer site. I checked the equivalence for the entire `Finite210` predicate and applied both ported theorems to their original absolute-value hypotheses and conclusions, including the propagated radius `R + T`.
- **Least witnesses.** For every inhabited decidable predicate on naturals, Lean proved that choosing from `exists_least` gives exactly `Nat.find`. I instantiated the equality at `Dev.tau`. The other two choices minimize the positive deviation index and the index of the first initially black background gate.
- **Clock contradiction.** The constructed background agrees with the candidate on the left. An odd first deviation persists until its diagonal meets the center at time `e`. For an even one, the gate immediately to its left fires by `e − 1`. If `w` is the first initially black background gate to the right, the clearing-front identity contradicts the clock at `e + 2w + 1`. If those gates are all initially white, the background is supported within radius `max R e` and the rule-90 argument applies. An eventual clock starting at `T` reduces to the clock starting white at `T` or `T + 1`, with finite support preserved.

The overlap search covered the catalogue at `dd2a220`, the changed lines in all 19 open kit PRs, and the portal index of 395 entries. The catalogue’s `Rule30Realization` and the related Jen-class entry analyze rule 210 from the single seed. The two entries being ported supply the half-line and arbitrary finite full-line results. [Related Jen-class entry](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-7e9e6e)

## Release read

For support in `[-R, R]`, the four initial sites contributing to the rule-90 center at time `2^n + 1` are `±2^n ± 1`. Choosing `2^n > R + 1` puts all four outside the support. The weaker reading that just the time exceeds the radius fails even for a parity-sparse start. With the only black cell at site `+1`, radius 1 and `n = 1`, the center is black at time 3 under both rules 90 and 210. Lean checked the witness and proved the sufficient bound for every finite rule-90 start.

The corrected module comments, catalogue row and PR body specify that bound. The PR text also identifies the driven boundary and distinguishes the gate that fires to the left from gates that are initially black to the right. I verified identical Lean code after removing comments. I checked the title, both source credit links and the catalogue import, and applied the corrected patch to a fresh Git index.

| Release file | Corrected SHA-256 |
|---|---|
| Kit patch | `a3d1f6b12386ac73e1625b083763bef42a36597d0d79cefe7de0cfd7729b22c3` |
| Lean module | `fa7f6bb5069ce6b3febca86ceb9b6d13273395c22bc26722175217b648bfefbc` |
| PR title | `43f8307f2407c3d31a8665b59e30695bb6c29bd551c5e74ad8a7adbe74acd45b` |
| PR body | `83a0c1dde1dffe8fe7d144db3bcbdf37ab2ddd0ab36eb9c689f154d2b83248b0` |
| Checker receipt | `882759b28cc0dfab3b0abf0eb5eb0674f2070e17b0c7d5bb0750e5319163f2fc` |

I reproduced the N5 tree `bc61f9304d328d164af95689aec328d28a24c2b3` from patch `731a03b2…` and tested both releases. The new module compiled without warnings on each. Native `leanchecker` passed, and the kit checker reproduced the N5 receipt field for field on all 14 public headlines. Kernel replay covered 329 constants. All 122 declared constants use only standard axioms. Both full 300-module catalogue builds completed in 303 jobs, with upstream build artifacts reused. I reran the comparison and witness clients against the corrected module.

The release files, manifests, comparison and witness clients, and transcripts are in `share-scratch/gptM5/kit-repair/R85-step-4.zip`, 60,760 bytes. The store read the archive back with SHA-256 `ca6b8548427eb99d8d347935ea58fe375534636070615186fe52248b3b98b973`. The corrected release goes to claudeIntel for matching agreement and the owner’s word to open the kit PR.
