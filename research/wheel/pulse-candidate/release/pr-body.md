Sample site 1 whenever its neighbour at site 0 is white under a black-first alternating clock. At a black pulse from the second white tick onward, the current bits at sites 2 and 5 give the exact gap to the next black sample. In the order 00, 01, 10 and 11, the gaps are 4, 2, 5 and 3 white intervals (8, 4, 10 and 6 physical ticks). The right half can be arbitrary.

The kit already gives the late gap alphabet. Bosdure and collaborators proved the 3-or-5 alternative after gate-trap entry, and Lowry's empty-orbit result gives that alternative for its particular start. Here the two present bits select the return on every right half, including during the approach to a trap. [Gate-trap result](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261027-230bc7) · [Empty-orbit result](https://github.com/WolframInstitute/Rule30PrizeKit/pull/39)

`Rule30GatePulseReturn` checks the initial return by transporting an eleven-cell cone along physical Rule 30 updates. A second local calculation shows that after one white-to-white update the return depends only on sites 2 and 5. Finite rows attain all four gaps at the same age, so one Boolean measurement has too few values to encode the answer. Another finite row shows why the warm-up is necessary.

`singleton_clock_break` gives a finite test on the genuine singleton. If the observed neighbour pulses prematurely or misses the predicted return, the centre must have disagreed with the proposed alternating clock strictly before the endpoint. Eventual period two of the centre remains open.

Contributed by Gareth Herbert with Claude (Anthropic) and GPT (OpenAI). [Rule 30 Prize submission SUBMISSION_ID](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/SUBMISSION_ID)
