# Review of R5 sharp slope (I242), proposed as S21

claudeIntel, N18, 25 November 2026. The owner asked for a review before claudeM5 builds the notebook. Packet read:
`share-scratch/gptIntel/R5/sharp-slope/R5-sharp-slope-I242.zip`, `7213b497…`, its 20 files equal to its SHA256SUMS.

## Verdict

1. **The Lean: PASS.** The statements say what the claim says, and the carrying steps hold.
2. **The packet: not yet.** Seven repairs (§4). The one that matters for the notebook: it carries all of S16, of which its
   theorems use about a tenth, and S16's own notebook overran the portal's four minutes twice. A trimmed source is below.
3. **The result is larger than its packet.** The same inverse step answers a question left open with the ether-erosion bound,
   shows that bound's slope is the least, and makes I244's deadline sharp. **PROVED IN LEAN, mine, on I242's module:** §3.
   Not read by anyone yet.
4. **Number.** The owner's word was S20. M184 gave S20 to the K83.B packet at 13:14 UTC, with digests, so this is **S21** here until
   the owner says otherwise.

## 1. The carrying read

| Step | Read |
|---|---|
| `back`, `back_eq` | the sweep from a white tail is the finite predecessor: x(p) = y(p+1) ⊕ (x(p+1) ∨ x(p+2)) at every p, with x = 0 from B on. The support bound drops by one |
| `before_bad` | uses the inverse recurrence, agreement of the output with the ether west of d + 8, and the defects at d + 8, d + 9. The eleven outputs at d − 1 to d + 9 are then fixed, and folding them forces (1,1) at d − 2, d − 1 and (0,1) at d, d + 1 for each of the four eastern pairs. The (1,1) is the ether's, and `spread` carries agreement west to site 0, so the imposed wall is met. (0,1) is the defect pair of class 10 |
| `extend_back` | the output's value at site 0 is not used: `Z` is read only at p + 1 ≥ 1. The evolution from the new row is the given one, one tick later (`shift`) |
| `terminal_step` | `01001` after the ether at class 10 gives the two-column advance into class 4 with the next site defective, a recurrent state |
| `family` | d + 7n + 4, the n + 1 exceptional fronts at d + 8k, then d + 8n + 2. The induction moves (d, s) to (d + 8, s + 1), which keeps class 10 |
| `return_front` | `ten_ticks` 2n times, 8n columns in 20n ticks, needs the front at 7 or more: d + 2 ≥ 7 |
| `example_row` | the last front is at d + 2 > 14, so the window is the ether's; 21n + 1 is a gate tick for (001, φ = 0) and (011, φ = 2) |
| `sharp_*` | from delayed at n = pD₀ + r. The hypothesis quantifies over every φ; the witnesses have one φ each, which only strengthens it. q = 0 is harmless. Strict reading: "no affine deadline p D + r ≤ q t has p/q below 3" |
| `late_*` | 21n + 1 ≥ 3D − 95, respectively 3D − 110, from the floor of (D − 26)/7, (D − 31)/7 |

**What the headlines do not contain.** `sharp_001` and `sharp_011` are lower bounds. "Exactly three" needs `finite_enters_001` and
`finite_enters_011` of S16, which are verified there and not headlines here.

## 2. Replays and my own checks

- **Pin `5fb5915`,** the packet's source: compiles; stock `Check.lean` 8 headlines, 312 declared, 835 constants, no new axioms;
  `leanchecker`. **Kit:** 8 headlines, 15 declared, 145 constants, `leanchecker`; a missing headline fails. The patch applies to
  `e2c9d8e`, and the module in it is the repository's. Embedded source equal to the file byte for byte, no quote, no backslash, the
  abstract in the front matter equal to the file.
- **[claudeIntel_s21_check.py](claudeIntel_s21_check.py),** from the kit's definitions, no code of the packet's: both families for n = 0 to
  60. Supports 7n + 26 and 7n + 31, every exceptional front, every tenth tick of the retreat, windows 9278 and 1992 outside at
  21n + 1, the inverse word for the four pairs. All pass. The same rows stay outside longer: **to 21n + 43 and 21n + 82**, which is
  3D − 35 and 3D − 11 (COMPUTED, n ≤ 60).
- **[claudeIntel_s21_small.cpp](claudeIntel_s21_small.cpp),** the exact latest gate tick outside over *every* half of support D ≤ 29, all phases:
  between 3D − 9 and 3D + 9 beside 001 for D from 4, and between 3D + 25 and 3D + 51 beside 011 for D from 9. Every half enters by tick 440. So
  3D + O(1) is what one sees from the start.

## 3. What the step also gives (PROVED IN LEAN, unread)

[claudeIntel_extension.lean](claudeIntel_extension.lean), appended to I242's module, whose own declarations stay as they are.

| Theorem | Content |
|---|---|
| `extend_back_tail`, `family_tail` | the inverse step and the run of any length before **any tail** that is itself a row of Rule 30 and its successors |
| `holds_tail` | that row shows the ether west of d at every tick up to 21n + 5 |
| `erosion_slope` | beside every ether column (all 12, all phases), for every n: ether on 1..k and beyond k + w, w = 7n + 5, not ether, and ether on 1..k through tick 21n + 5 = 3w − 10. So **the slope of `erosion3_fin`'s 3w + 6 is the least** |
| `constant_gate_011`, `gate_slope_011` | a finite half beside 011, white beyond 7n + 17, reads one colour, either one, at every gate tick through 21n + 5, from any phase. So **I244's deadline has the least slope**, which M185's first remark asks |
| `endless` | **some right half keeps the exceptional front for ever,** eight columns a tick (compactness) |
| `not_eroded` | beside every ether column, for arbitrarily large k: a right half that first differs from the ether at k + 1 and has the ether on 1..k **for ever**; column p is ether from tick (p − k)/8 on |
| `stays_001`, `stays_011` | so a half that is not the ether stays outside S16's trap at every gate tick: the second branch of `enters_or_constant_*` has more in it than the ether |

**Why this matters.** Perez Morales's entry (R30-20261024-1fc962) says under *Not claimed*: "erosion with an infinite right side, which is open
and equivalent to 'no infinite run of B'". `endless` is an infinite run of B, so the answer is no. He also lists "the measured worst
case 3w + 2". COMPUTED: with two defects in the ether as terminal, w = 7n + 2 and the departure is at tick **3w** exactly, for n to 40
([claudeIntel_tails_check.py](claudeIntel_tails_check.py), which also checks both Lean families cell by cell). An exact travelling
wave of speed 8 does not exist (the recurrence r(p − 8) = r(p − 1) ⊕ (r(p) ∨ r(p + 1)) has no continuation off the ether), and the finite
witnesses do not converge: R_n and R_(n+1) differ at the third cell past the front for every n tried. The half of `endless` is by compactness and not explicit.

*Checks.* Kit form `35581d1b…` (39,621 bytes): builds in 9 s, 18 headlines, 30 declared, 263 constants, no new axioms, `leanchecker`.
Trimmed portal form `314652c9…` (67,762 bytes) at the pin: 18 headlines, 59 declared, 331 constants, no new axioms, `leanchecker`, a
missing headline fails. Both come from [claudeIntel_build_s21.py](claudeIntel_build_s21.py); with `--no-extension` it gives I242's module byte for
byte and a trimmed portal form of it.

*Priority.* Searched: the portal's 425 abstracts for erosion, infinite run, infinite right, `EtherThreeErosion`; the kit's period-three modules
and README; both prior-art files and the ledgers. Only Perez Morales's own sentence. K81 and S13's compactness is the same device.

## 4. Repairs before the build

1. **Build time.** Of the packet's 835 constants the eight headlines use 197. S16's notebook took 47 to 54 s on the M5 and overran the
   portal's check twice (M158), and this one adds to it. Under equal load here: **104 s for the packet's source, 23 s for the trimmed one with
   the extension**, of which about 15 s is loading the kit. In a profile, type checking took 190 s in the one and 15 s in the trim without the extension. The trim keeps every used S16
   paragraph byte for byte. I recommend it, with S16 cited for the upper bound.
2. **Header.** The embedded source opens with S16's docstring, "At period three every finite right half enters the least gate trap".
   It should open with this submission's. The builder does that and says what is carried.
3. **Abstract.** It says that the optimal slope "is exactly three" by `sharp_001` and `sharp_011`, which are the lower half. It has no
   headline in code, and names neither `Rule30EtherThreeErosion` nor `Rule30EtherThreeDeparture`. Proposed text (245 words, with §3): [proposed-abstract.txt](proposed-abstract.txt).
4. **Essay.** (a) "The initial choices d = 22 … put the final tick on the gate phase": the phase does that, d gives the class. (b) One
   picture and no table. Worth adding, all cheap: the four eastern pairs swept through the eleven bits; the rows for n = 3 as a picture against
   the ether; support, tick and window for a few n. (c) The same three sentences as in 3.
5. **Kit patch.** The count in `Rule30PrizeKit.lean` is not changed (366 to 367 on `e92083b`). The row has no "as Rule 30 Prize submission
   [id](page)" (METHOD §12). It must be rebased: main is `e92083b`.
6. **PR text.** No title file; the body needs the submission link, checks, credit (Perez Morales, S14, S16) and "not claimed". `agent.txt`, `post.sh`,
   `post.wl`, `pins.json` are missing, which are claudeM5's in the build.
7. **One entry or two.** M185 suggests I244 with this one. I agree: they share the front and the same readers, and `gate_slope_011`
   is the bridge. If I244 joins, its S16 import means carrying the entry tables again, and then the time of repair 1 returns. So:
   **I242 with the extension as S21, trimmed; I244 in the same kit pull request, or as its own entry.** The author decides.

## 5. Novelty and the chain test

Repeated independently: `find_known.py` on eleven terms, the portal's list (425 entries, 13:03 UTC), open kit pull requests (17, none on this), the kit's
new modules since the packet (#421 is on gate words, #424 is ours). The chain test: the parameter is the slope, and the new value
closes the interval [5/2, 3]. No chain. `P75` in PRIOR-ART names the right entries. For §3 the entry to cite is Perez Morales's.

## 6. Not checked

- **The Wolfram cells.** This host has no Wolfram. I read them: the table, inverse, seed, advance and front agree with the kit's
  definitions, and `DataRange -> {0, 211}` is right for n = 10. They have not been run by me.
- The notebook (not built), the PR page, gptM5's carrying read (asked in I242, not in yet).
- My extension has no second reader.
