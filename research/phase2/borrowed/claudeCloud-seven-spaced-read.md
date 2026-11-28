# I338's seven-spaced cutoffs: carrying read

*claudeCloud, 28 November 2026 (ledger K106), at the owner's word: "Continue with the I338 request". I338 asked for
"the first-failure period transfer and the two refined covers". gptIntel's note:
[seven-spaced-cutoffs.md](seven-spaced-cutoffs.md).*

## What is claimed

Two families are claimed, ordinary cuts and Galindo's added-spike cuts, both with a complete law at every n ≥ 3.
- **The rows.** The reference has black bits 1, 2, 4, 8, 15, 22, … at the kit's white wall.
  - The ordinary cut keeps n spikes at 1 + 7i (with bits 2 and 4).
  - The added-spike cut also sets bit c + 17, where c = 1 + 7n is the first omitted spike.
- **The law.** For n ≥ 3, the first white odd physical tick P and the first failure G of the kit's G word are c + d,
  with d given by a disjoint cover of congruences in n.
  - Ordinary cuts: period 1,024, largest d = 19 (pin) and 17 (G).
  - Added spike: periods 2²² and 2²⁰, largest d = 49 (pin) and 43 (G).
- **The witnesses.** The published Y86, Y198, Y310 are ordinary cuts with n = 11, 27, 43. Galindo's seed2635 is the
  added-spike cut at n = 2,635, which fails at c + 29.

## The read: PASS

| Check | Result |
|---|---|
| `SevenSpacedCutoffs.lean` (SHA-256 `bf2cc46c…`, as in the receipt) compiles against kit `ea5d70e` with the kit's `Rule30MassCounterexamples`, core Lean 4.35.0 | yes |
| `leanchecker` | passes |
| Axioms of `literal_cuts`, `published_failures`, `added_literal`, `wall_read`, `window_period`, `local_period`, `firstG_of_local`, `firstPin_of_local`, `added_literal_failure` | standard only |
| The archive `I338-checks.zip` | SHA-256 `2fc6bd97…`, as recorded |
| **The two covers** | exact: every residue modulo the largest modulus has exactly one rule, in all four tables (pin and G, both families). Both `unresolved` lists are empty |
| **Direct simulation, ordinary cuts, every n from 3 to 1,100** (a full period of 1,024, and both sharp classes 203, 635 and 107, 587) | agrees with the table at every n, both tests |
| **Direct simulation, added spike, every n from 3 to 3,000** | agrees at every n, both tests |
| **Direct simulation of the sharp added-spike classes** at their least members n = 551,499, 707,147 and 1,993,291 | see below |
| The published witnesses | n = 11, 27, 43 fail at physical 87, 199, 311; n = 2,635 with the added spike at c + 29 = 18,475 |

My simulator ([`claudeCloud_seven_direct.c`](claudeCloud_seven_direct.c)) shares nothing with gptIntel's three
programs. It runs the kit's integer form y ↦ (y >> 1) ⊕ (y | (y << 1)) on whole rows, keeping only the cells inside the
wall's light cone up to the horizon. [Ordinary](data/claudeCloud-seven-ordinary-direct.txt) ·
[added spike](data/claudeCloud-seven-added-direct.txt).

**The period transfer** (I338's first request).
- **The transfers.** `firstPin_of_local` and `firstG_of_local` carry a first failure of the local window at offset d
  to the whole row at c + d. They use the window's agreement with the true readings (`localPin_sound`,
  `localG_sound`) and Galindo's `Suffix.initial_checks` before c.
- **The periodicity.** `local_period` makes the window periodic in n once 7m is a multiple of 28 and of 8.
- **What is not in Lean.** That each offset's period divides the table's modulus comes from the strip returns. Two
  programs check those (the lifting program and the forward verifier), not the kernel.
- **My check of it.** The direct simulation over a whole ordinary period confirms every ordinary class. For the added
  spike it confirms n ≤ 3,000 and the sharp classes directly, but not every class of the 2²² period. The covers'
  correctness at large n rests on the two programs, as I338 states.

**The two refined covers** (the second request). They are disjoint and complete, as checked above. Each rule's
offset is attained by its least representative in my direct runs wherever that representative is at most 3,000.

## Scope

- These are statements about the bare white-wall trace: finite mortality for the exact shifted starts of these two
  shapes, at every width.
- The ordinary law also covers any tail whose first 20 bits after the cut are white, by the light cone, as the note
  says. The next case it names, one added spike at offsets 1 to 19, is open.
- **Credit.** As I338 gives it: AIOvernight's reference and witnesses (P1, P103), and Galindo's suffix recurrence and
  progressions (`Rule30MassCounterexamples`, kit PR #410).
