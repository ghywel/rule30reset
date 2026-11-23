# A finite duration for 3/5 exterior runs on the singleton

Suppose the genuine Rule 30 singleton, at positive physical age A, has a white centre and a black sample at its right neighbour. Follow a finite run of successive black samples with gaps three or five, measuring gaps at the white ticks of the alternating centre. Assume the centre keeps alternating and the last window is still outside the kit’s gate trap. **The physical age T of the last black sample satisfies T < 2A + 1532.** The additive constant is an upper bound. An arbitrary clamped right half has no comparable general time limit, since the 84-ring realizes the three-gap rhythm indefinitely.

## Counting fives on finite paths

At a black white-time pulse keep the first W positive cells, with a free eastern input at each physical update. A directed edge labelled 3 or 5 requires the next black pulse to be exactly that many white samples away and the intervening windows to stay outside. Every physical run ending outside gives such a path, since the trap is closed. Start with all 32,580 possible outside pulse windows of width 16.

1. At widths 16, 21 and 26, retain each vertex that can be reached after a five-edge followed by any number of three-edges, and that can reach a five-edge after any number of three-edges. This retains all vertices between the first and last five-edge of a finite path. Each such cut costs at most one five at each end. Lift the retained windows to the next width by trying both values of the new cell. At intervening widths lift all vertices.
2. At width 31 there are 89,696 candidates. Keep the current suffix that is a prefix of either forbidden power, `33355` repeated seven times or `333355` repeated nine times. An edge completing either word is impossible by K77 and the checked physical cuts. Every starting window is allowed to begin with empty suffix memory.
3. In this product graph every internal edge of a strongly connected component has zero five-cost. The longest path in the graph of components has five-cost 23. The code checks its computed integer potential against every edge. With the six possible end losses, an exterior run has **at most 29 fives**. A physical exterior row realizes 12 fives. The upper bound leaves a genuine gap to sharpness.

For a word also avoiding eight consecutive threes, measure an edge by its duration, 3 or 5. The analogous product has 176,288 vertices. It is acyclic and the largest central duration is 248 white sample intervals. An end piece removed at one five-edge costs at most 7·3 + 5 = 26. If there are fewer than six fives, the whole path already costs at most 5·26 + 21. In every case the duration is **at most 248 + 6·26 = 404 white intervals**. [Finite-path enumeration and potential check](finite_five_budget.py) · [Counts at each width](data/finite-five-budget.json) · [The two mixed powers](mixed-cuts.md) · [Physical lower witness](data/exterior-five-witness.json).

## Where the left edge enters

If the gap word contains no run of eight threes, it costs at most 808 physical ticks. Otherwise cut it immediately before its first run of eight. The prefix **including the first seven threes of that run** still avoids eight consecutive threes. Write B for the physical age at the cut. Then (B−A)/2 + 21 ≤ 404, so B ≤ A+766. Two shorter certified words determine the remaining form.

- `333333353` cannot occur on any driven right half.
- `3333333355` forces trap entry at its endpoint.

After eight threes, a five followed by another legal gap would violate one of these two rules. Thus the remaining word is a pure run of three-gaps, possibly followed by one terminal five. This also shows that an infinite all-3/5 exterior has reached its permanent pure-three stretch within **383 white intervals** from its starting pulse. [Exit rules, physical witnesses and Lean proofs](pure-three-exit.md).

The rotating 84-ring supplies both an alternating centre and the same white-time gate as the pure-three run. A comparison begun at physical age D cannot agree on the centre through age 2D+6 and on all required white gate readings strictly before 2D+6. The singleton’s leftmost black cell is D cells west, and the ring’s forced left profile disagrees with that edge by depth D+6. [Sharp kernel deadline and exact left-edge witnesses](finite-right-pure3.md).

If B=A, start the ring comparison at the initial pulse. With a final five-gap the first wrong gate bit would be six physical ticks after the last pure-three pulse, four ticks before T. The centre still matches there and every earlier white reading agrees. Thus T−4 < 2A+6. With no terminal five the comparison lasts through T itself. If B>A, the preceding gap is five. At B−4 and B−2 the gate was white. Start the ring comparison at D=B−5 in ring phase 2, which puts phase 1, its white-wall black pulse, at B. Again it matches through T, or through T−4 if there is a terminal five, with white readings required strictly before that endpoint. In the latter case T−4 < 2D+6 = 2B−4. Consequently T < 2B ≤ 2A+1532 in this case as well. The hypotheses concern a completed black-to-black run. A longer wait for the next pulse would itself violate the gap law.

The finite prize obstruction distinguishes a long exterior burst from the wheel trap. A singleton with an indefinitely alternating centre could still have infinitely many gaps outside 3 and 5, or enter the trap and follow an admissible aperiodic gate. In particular the result leaves the period-two prize case open. [Complete 48-sample entrance test](complete-observer.md).
