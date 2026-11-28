# K92.4 · Which falls break alternation at the centre?

**THEOREM (Lean).** On the singleton orbit, take any fall from black to white at site −2. Seven of its eight possible five-cell patterns force an equal pair at the centre within three updates. The eighth pattern writes `0101` at the centre, and the next centre bit is exactly the bit four sites west on the fall row. If the centre eventually alternates, every sufficiently late fall must therefore read **011001** from −4 through +1 and occur on the same parity of ticks. The recurrence of falls at −2 is unconditional. Forcing exceptions arbitrarily late on the single seed remains open. [Proofs](UnmarkedLaunch.lean)

## The fall and the neighbouring birth

A fall at tick $t$ reads 11 at −3,−2. If −1 or 0 is black, it is a centre birth of width at least two by I321. Otherwise the row reads 1100 through the centre. Seen from column +1, this is an exact width-two gap with a black cap at −2. Trace it backwards using the kit's white-run dichotomy. At a quiet tick its earlier gap is one wider. At an active tick $v$ it was born, with width $w$ satisfying

$$v<t,\qquad v+1+w=t+2,\qquad t\le 2v.$$

The backward walk terminates because column 0 is black in the seed. The cap at $-w$ on row $v+1$ lies inside the seed's cone, giving $w\le v+1$ and the final inequality. For a fixed eastern birth, its unique width and the displayed identity determine the fall tick. Distinct falls therefore charge distinct births, where the observer forms part of the birth's identity. In particular the number of falls before $N$ is at most the sum of the two observers' width-at-least-two birth counts before $N$. The finite count here is an injection argument from `source_of_fall` and `east_birth_width_unique`.

No column of the singleton becomes constant, so −2 falls arbitrarily late. Thus **one fixed observer in {0,+1} has arbitrarily late primitive births of width at least two** (`cofinal_births_either_site`). Both the observer and width matter. KDRonald3 and Claude proved recurrence of adjacent black pairs and of the three-cell set {001,100} at every cut. I321 located primitive gap births. Here the accounting identifies the birth behind each individual fall. [Windows That Always Return](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261115-2d4add) · [I321 and N39](launch.md)

## Seven fall patterns and one exception

For any two whites immediately west of the centre on row $s$, a black centre stays black on the next tick. If the centre is white, site −1 stays white for one update, so the first change from white to black at $s+1$ also gives black at $s+2$. Thus a centre birth of width at least two forces an equal pair starting at $t+1$ or $t+2$. Choose the earliest. If only the later pair works, its colour is black.

A silent fall with row 11000 at −3 through +1 gives a white pair immediately at $t$. The remaining silent word 11001 gives centre readings 0101 at ticks $t$ through $t+3$. At $t+4$ the centre reads the initial bit at −4. The western neighbour at $t+2$ is black, the eastern neighbour is white, and at $t+3$ the western neighbour is the complement of that initial bit. The black centre then complements it again. In particular a fall has **four consecutive alternating updates exactly when its six-cell word is 011001**. A direct check of all 512 nine-cell cones gives 128 falls, 16 with the first three updates alternating and 8 with all four. The identities are kernel checked in `exception_trace` and `pair_spec`.

Count all falls except 11001. Each pays for a distinct equal centre pair. Falls start at least two ticks apart. The only possible collision is a late choice $t+2$ for an earlier fall with an immediate choice at that same tick for a later fall. The late choice is black and the immediate choice is white. Hence, for every $N$,

$$\#\{t<N:\ -2\text{ falls and the word differs from }11001\}
\ \le\ \#\{q<N+2:\ c_q=c_{q+1}\}.$$

This is `forcing_count_le_equal_pairs`. The coefficient one covers the five-cell exceptions. The extra bit at −4 gives a four-update test on the remaining word. Its additional witnesses have no distinctness claim here.

In an alternating tail the centre is white on every fall at −2. The eastern width-two gap at the fall was born **exactly one tick before** because the preceding centre was black. Two falls at −2 an odd distance apart, after every cutoff, would therefore rule out eventual period two (`no_period_two_of_odd_fall_separations`). This singles out the missing modulus and column in the S32 comparison. S32 proves two residues for every modulus **at least three**, at some column of every six-column strip. Its modulus-two free-exterior control still applies. [Every-modulus theorem and control](../falling-phases/every-modulus.md)

## When a white arrival can still certify a first failure

Let $s=t+1$ be the gap row and $l$ its width. Drive two western halves with the actual centre, one all white, the other with only site $-l-1$ black. Write $r$ for the XOR of their readings at −1 after $l+1$ updates and $b$ for the actual bit at $-l-2$ on row $s$. If the arrival at $s+l$ is white, the blank restart first fails at offset $l+1$ **exactly when** the next centre is black and $b\ne r$. All prior black checks agree by locality. At the next diagonal the true row and the single-cap start share every relevant input except $b$, the western tip. Flipping that tip flips the output. This proves both directions for every capped gap under the observed driver (`first_after_white_iff`).

Unbounded widths passing this test suffice for Problem 1 by Lowry's finite-first-failure criterion. They could all have white arrivals. The earlier criterion for unbounded black marks also remains available. The new test uses the centre through the following tick and can classify a gap retrospectively. Proving that either kind occurs at unbounded widths is the missing dynamical step. Lowry already gives a delayed unmarked example and controlled edits that place failures on other rows. [Marked gaps](https://github.com/WolframInstitute/Rule30PrizeKit/blob/10a4b86/lean/Ruliology/CellularAutomata/Rule30MarkedGaps.lean) · [Restart visibility](https://github.com/WolframInstitute/Rule30PrizeKit/blob/10a4b86/lean/Ruliology/CellularAutomata/Rule30RestartVisibility.lean)

## Fixed widths for clocks with isolated black ticks

In a gap of width $l$, the first black centre tick at offset $j<l$ must be followed by black. Until then the quiet centre pair lets the gap shorten by one on each update. At that first black tick its western neighbour is still white. Consequently a proposed periodic tail with isolated blacks and longest white run $g$ is excluded by **one gap of width at least $g+1$ inside that tail**. A gap of width exactly $g$ can survive only at the start of a full run of $g$ whites followed by black, making it a mark. Thus an unmarked width-$g$ gap also excludes that proposed tail. To exclude *all onset ages* by this route the appropriate witness must occur after every cutoff.

The endpoint is attainable locally at every width. Start a finite row with black cells only at $-l-1$ and $+l$. Two black fronts move into the white interval and meet at −1 and 0 on tick $l$. The centre reads $l$ whites, one black, then white. This proves sharpness of the finite-window colour argument. The seed in this control varies with $l$. [Lean statements `first_black_pairs`, `mark_at_max_white_run` and `endpoint_attained`](UnmarkedLaunch.lean)

## Measurements and replay

Birth and fall ticks run from 0 through $2^{22}-1$. I341 and I342 froze the respective programs before the two new measurements on the archived prefix. The source observations and independently stored failure offsets are the I283 archive. N39's separate run to $2^{25}$ still holds the marked width record of 23. [Archive layout, hashes and regeneration](../marks/seed-results.md) · [N39 census](claudeIntel-launch-read.md)

| Quantity | Observed |
|---|---:|
| Primitive centre births of width ≥8 | 12,172 |
| White arrivals among these | 6,642 |
| White arrivals with black on the next tick | 2,791 |
| White arrivals whose first failure is on that next tick | 1,390 (20.93% of 6,642) |
| Falls at −2 | 1,048,953 |
| Active falls giving width ≥2 centre births | 787,329 |
| Silent 11000 falls giving an additional white pair | 130,369 |
| All five-cell exceptions giving distinct equal pairs | 917,698 (87.49% of falls) |
| Remaining 11001 falls | 131,255 |

At the width-25 record the birth tick is 2,085,566 and the gap opens at 2,085,567. At offsets 25 through 29 the centre reads **00001**, the real western neighbour **00010**, and the blank restart **11001**. Their disagreement first meets a black centre at offset **29**, age **2,085,596**. It is an example beyond the one-tick law's reach.

Run `python unmarked_launch.py ARCHIVE_DIRECTORY` and `python fall_pairs.py ARCHIVE_DIRECTORY` with the two original binary files in that directory. Both reproduce the registered counts. With Lean 4.35.0 and kit `10a4b86`, place the kit's built Lean library and an empty output directory on `LEAN_PATH`. From this directory compile `MarkLaunch.lean` and then `UnmarkedLaunch.lean` to same-named oleans in that output directory. Run `leanchecker UnmarkedLaunch`. The kernel replay passed.

**Disposition.** Keep K92.4 open. For period two, try to force falls of both parities specifically at −2, or falls outside 011001 arbitrarily late. For unrestricted Problem 1, the gap widths must still grow and their restarts must have finite failures. A finite extension of the local fall window alone cannot force a future beyond every horizon: with a fixed east side, the as-yet-free westernmost cone bit toggles each next centre bit without altering the preceding ones. This is the kit's left-permutive realization mechanism. A recurrence proof must use the single seed. [Light-cone theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/10a4b86/lean/Ruliology/CellularAutomata/Rule30LightCone.lean)
