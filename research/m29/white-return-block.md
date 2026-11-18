# Every three phases contain one with arbitrarily deep resets

**R44, computer-assisted proof.** Fix any pointed recurrent Rule 30 edge strip starting black, and any tick s. At least one fixed tick among s, s+1 and s+2 contains closed black runs of length 1 modulo 3 arbitrarily far from the edge. The chosen tick can depend on the strip and s. This advances M39's sufficient condition for every k. That condition requires the conclusion at each prescribed tick.

## The two-anchor argument

Number wheels inward from the black edge. The next tick of wheel i+2 is the XOR of wheel i with the OR of wheels i+1 and i+2. A pointed recurrent strip has a common period from the same time origin on every finite prefix. Such a strip has permanently white wheels arbitrarily far in, and the wheel two places beyond each of the white anchors used below is permanently black. [Rooted proof](Rule30RootedWhiteReturns.lean)

To see why there must be more anchors, two consecutive temporal column profiles determine the preceding column by the same XOR formula. Distinct depths in a black-edged strip therefore have different pairs. A repeated pair would propagate back to a second copy of the zero exterior, contradicting the first black wheel. A prefix with clock P can use at most 4^P pairs. At the first loss of that clock, the preceding wheel must be white, since any black tick would fix the child's next state and transmit the clock. At a white wheel the child integrates the preceding temporal word by XOR. At the first loss it is complemented after P ticks, hence has a black tick. The next wheel latches black. Recurrence carries this conclusion back to the common time origin. The Lean lemmas are `first_clock_loss` and `unbounded_anchors`. They generalise the kit's single-seed backward-profile and antiperiod arguments to the pointed strips in M39.

Choose two such white anchors A and B with B ≥ A+3. Read from A through B+3, following three consecutive ticks simultaneously. At each wheel pack the three observed colors in a word, earliest tick in bit zero. Save the last two words a,b and masks u,v of the ticks where the open black run has length 1 or 2 modulo 3. At A+2 the state is (x,7,7 XOR x,x), where x is the unrestricted column at A+1. For each new column c:

1. Bits 1 and 2 of c must equal the low two bits of a XOR (b OR c), by Rule 30. Bit zero is free.
2. A zero of c under a one of u closes a reset run. Otherwise the next state is (b,c,c AND NOT(u OR v),c AND u). Runs start after the common white at A, so every rejection by this test has both white endpoints.

There are 20 reachable states and 22 allowed transitions. When c is zero at B, the only two surviving states have a previous column of 3 or 7. Their combined successor sets have sizes 2, 2 and 0 over the next three wheels. Thus **some reset occurs in those three phases between A and B+3 inclusive**. The recurrence check always passes on a physical strip, so rejection there certifies a completed run. Reversing the direction of reading preserves the delimited run. The extra bit for full inverse-register synchronisation is available on its edge side when A is chosen deep.

Choose A beyond any requested depth. If all three fixed phases had a last reset, A could be chosen beyond all three last resets. This proves the headline. [Lean certificate for intervals of arbitrary length](Rule30ThreePhaseReturn.lean) · [Independent state enumeration](gptM5_three_phase_return.py)

The two-phase version identifies a restrictive failure mode. If both s and s+1 have reset-free tails, **at every sufficiently deep white B the first child rises from 0 at s to 1 at s+1**. In the two-bit automaton, a child other than binary 10 cannot survive two more wheels after that child. `two_phase_rise` checks this for arbitrary interval length. Once a source profile and phase are given, simultaneous avoidance leaves one candidate child at a white, and kills the interval if the source bit is zero. This provides a deterministic test where the two separate lifts would otherwise branch.

## The fixed-size box and a local obstruction

Within just the eight wheels A through A+7, at least one of **five** consecutive phases has a closed black run of exactly one or four cells. Lean independently checks all initial bits and boundary inputs, and proves its unbounded-depth corollary by finite pigeonhole. Kernel axioms for the local box are propext and Quot.sound. [Five-phase theorem](Rule30WhiteResetBox.lean)

A periodic ring shows why unrestricted single-phase forcing fails, even if the neighborhood is arbitrarily wide. In wheel order the five successive width-eight rows are `01110000`, `01100100`, `01101111`, `00100100`, `00111111`, then the first again. Wheel 0 stays white and wheel 2 black. Across the last row and the first row the closed runs have lengths six and three respectively. Tiling in space defeats even a two-phase unrestricted local claim. Its temporal period is five. Physical recurrent edge strips have dyadic prefix periods; the ring supplies a counterexample only to dropping that condition and the black edge. Finite SAT patches survive all the tested centered windows, including three or four avoided phases at radius 16 through a total of 13 time slices. [Ring replay](gptM5_white_ring.cpp) · [Window probe](gptM5_white_window.py)

## Which doubling remains open

At a permanently white wheel let b be the column immediately before it, with least period P. The two possible children are complementary. The child's period map flips exactly when the number of black ticks in b over P ticks is odd. The other wheels through the next white inherit the clock from a nonwhite driver. Backward determinism also recovers every earlier column from the next white interface, so its least period is exactly P or 2P respectively. Any rooted infinite tail avoiding resets in a prescribed phase would have to pass infinitely many **odd-source, period-doubling** intervals in that same phase. A proof that every such interval supplies a reset would suffice. This condition asks only about the doubling intervals.

| Least source period | Lifts tested | Whole intervals with no reset in the marked phase | Of these, doubling |
|---:|---:|---:|---:|
| 1 | 2 | 0 | 0 |
| 2 | 4 | 0 | 0 |
| 4 | 24 | 2 | 0 |
| 8 | 480 | 4 | 0 |
| 16 | 130,560 | 33 | 0 |

The scan allowed arbitrary source profiles. Each lift met a reset or the next white by wheel 72; none hit the resource cutoff. The 39 reset-free returns reduce to eight source profiles up to rotation. Each has a nonzero spatial cycle under backward reconstruction, which excludes the black edge. The directly observable complete intervals on the four kit strips each contain a reset in all 16 phases. Independently, the paired-row graph excludes a reset-free doubling at every temporal period for gaps 5 through 19. The SAT runs at half-periods 32 and 64 include undecided longer gaps; those carry no exclusion. The swap argument for the paired graph tracks a phase and its half-period translate, with complementary first child bits driven by the same external bit. A genuine doubled periodic orbit gives a path to the swapped ordered pair and back in the same strongly connected component. [Return scan](gptM5_white_excursions.cpp) · [Root check](gptM5_white_roots.cpp) · [Gap graph](gptM5_white_gap_graph.py) · [SAT test](gptM5_white_gap_sat.py)

**Decision.** Close the route that tries to force a reset in the prescribed phase using only the local white wheel. Keep M29 open for the period-doubling condition. The next discriminating test is whether physical rootedness and the phase swap exclude a reset-free odd-source excursion at arbitrary gap. The two-phase rise theorem gives a deterministic subcase, and a physically rooted bad doubling would refute the proposed sufficient lemma. Extending a width table alone would leave this question unchanged. The three-phase theorem cannot select the phase required by the k-layer inverse schedule, so the maintainer's every-k theorem is still open.

The replays and checked witnesses are in `share-scratch/gptM5/M29/r44-white-returns.json`, SHA-256 `0141cc1e44827b265c53330ae3ed586a6e6b46bb10aceb5f5a79d0d186c9d787`. The Lean files run separately with the kit's Lean 4.35.0 environment at 077038d via `lake env lean /absolute/path/to/file.lean`.
