# Physical checks on the X and Y excursion schedules

## Three X excursions at spacing six are impossible

Let E be the eight gaps 33535555 and A the pair 25, in white-to-white intervals. No right half of the alternating wall reads E A⁶ E A⁶ E, even with an arbitrary terminal window. This is a finite statement about 187 gate readings from a white wall and black gate.

The original two K80 encodings constrain the terminal 16-cell window to be outside the trap. I reproduced both CNFs byte for byte, one with the additional final gap of two. A second encoding numbers the rows backwards, separates each local OR from the XOR and omits the endpoint condition. CaDiCaL 3.1.0 produced a text LRAT for each instance. Both lrat-check and the verified CakeML checker accepted all three. [Generator](gptIntel-k80-cuts.py) · [CNF and uncompressed proof digests](gptIntel-k80-results.json).

## Twenty-one periodic columns suffice

Suppose that the first 21 positive columns beside an alternating wall eventually have one common time period N ≤ 24 physical ticks. On that tail the sampled gate has one of the cyclic gap words 2, 3, 5 or 25. Eventual periodicity permits a joint starting white tick after all 21 onsets. If N is odd, Rule 30's left-permutive identity applied to columns 1 and 2 would force the alternating wall to have odd period.

For even N I wrapped each column through N ticks, imposed Rule 30 on all W positive columns and left the eastern input at each tick free. A real strip projects to this cylinder. One occurrence of each free eastern cell per phase suffices because the last column, its next reading and its left neighbour are periodic. I excluded every phase of each of the four proposed gate words, using only site 1 on white ticks. These CNFs are independent of the list of ring columns in K80.

| Common period N | 2 | 4 | 6 | 8 | 10 | 12 | 14 | 16 | 18 | 20 | 22 | 24 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Sufficient W in K80 | 3 | 5 | 3 | 11 | 6 | 8 | 6 | 22 | 9 | 8 | 14 | 11 |
| Least W on this cylinder | 2 | 4 | 2 | 10 | 5 | 7 | 5 | 21 | 8 | 7 | 13 | 10 |

Each of the 24 exclusions passed both independent LRAT checkers. At one column below each new bound the solver produced a satisfying cylinder, and I checked every cell and the gate's exclusion directly. Those lower bounds apply to a strip with a free eastern input. Whether the witnesses extend to infinite physical right halves with the same periods is a separate question. In K80's forward enumeration the last period word arrived without a local check on its own update. Imposing that final update accounts for the one-column improvement. [Cylinders and proof producer](gptIntel-k80-strips.py) · [All twelve finite controls](gptIntel-k80-results.json).

## A 344-sample stay on Y’s schedule

K80's eight-copy train gives a finite right row whose last black cell at the starting white tick is site 599. It is the exact one-step image of a finite black-wall start of support 598. Inverting the row from its white eastern tail gives the predecessor recorded in the receipt. A forward Rule 30 update with a black boundary reproduces the full 599-bit row. With the remaining sites white, its gate satisfies the Y schedule at 300 readings and extends to **344 consecutive readings**. The complete gaps parse into the blocks 2, 45 or 4525, allowing the observation to end inside the final block. The gate contains 10001 in every 57-sample window up to this length. Its 16-cell window is 8352 at sample index 299. At length 345 the latest block of 57 lacks 10001, while the endpoint remains outside the trap. These are readings compatible with Y's temporal schedule; they do not individually certify continuous residence in Y's spatial component. [Exact finite start and gate](gptIntel-k80-results.json) · [Physical replay](gptIntel-k80-stays.py).

## Reproduction and Intel runs

Run from the research repository root using kit `80994b1` and the host research Python. The cases below write to a scratch folder.

```text
rule30-python research/wheel/gptIntel-k80-cuts.py Rule30PrizeKit scratch cloud-original
rule30-python research/wheel/gptIntel-k80-cuts.py Rule30PrizeKit scratch cloud-plus-two
rule30-python research/wheel/gptIntel-k80-cuts.py Rule30PrizeKit scratch unrestricted
rule30-python research/wheel/gptIntel-k80-strips.py scratch/strips
rule30-python research/wheel/gptIntel-k80-stays.py Rule30PrizeKit scratch known
```

The K80 long searches use the same complete physical cone, grammar, terminal exclusion and 57-sample recurrence as the original questions. They stream the formula before invoking standalone CaDiCaL without a conflict or time cap. In the sixteen-copy test the gate is fixed to `(45 2¹⁶)¹⁶ 2`, 659 samples. Three detached Intel processes started on 23 November with scratch `%LOCALAPPDATA%/Rule30/gptIntel/K80`. The generator commands are

```text
rule30-python research/wheel/gptIntel-k80-stays.py Rule30PrizeKit scratch 400
rule30-python research/wheel/gptIntel-k80-stays.py Rule30PrizeKit scratch 500
rule30-python research/wheel/gptIntel-k80-stays.py Rule30PrizeKit scratch train16
```

Each process writes its problem digest to `<case>.stdout`, solver progress to `<case>.solver.log`, and diagnostics to `<case>.stderr`. Once the solver exits, the driver writes `<case>.json` in the same directory. A positive receipt carries the finite row and the complete gate, checked by physical evolution and a separate tile parser. A negative is a computed refusal until an LRAT replay. To collect a finished case, verify the reported CNF digest and the receipt, copy the receipt into the research record, update the ledger and tell claudeCloud. The stored CNF can be rerun directly after a host restart. The general-stay and fixed-train questions have different implications for RD.

**24 November, I198.** The 659-sample train ended at 01:44 UTC. CaDiCaL reported UNSAT after 19,458,970 conflicts and 10,192.48 seconds. The checked input digest is `95e221ece34ea4ff4acba02423c6df3bc4430e125a2423598eb8299f55487246` (887,658 variables, 5,315,496 clauses). A proof-producing replay is running on that exact input. Its launcher checks the text LRAT with both lrat-check and cake_lpr and writes `train16-proof.json` only on success. The proof itself is on the Intel scratch NVMe at `D:/Rule30Scratch/gptIntel/K80/train16.lrat`. The solver-only receipt, terminal log and launcher are in `share-scratch/gptIntel/K80/I198-train16-solver.zip`, SHA-256 `f9a23be1d7122098b51408913658e58ec0a7762d08a5494cd1b7409cffe48994`.

The host rebooted at 10:15 UTC with neither general Y run at a verdict. The original logs remain in `K80/`. The two runs restarted in `K80/restart-20261124/` on the same CNFs. Their SHA-256 prefixes are `912d009f` (400) and `c6741410` (500). A refusal of the single train leaves the general return budget open.

All four proof archives were read back from `share-scratch/gptIntel/I184/`.

| Archive | Bytes | SHA-256 |
|---|---:|---|
| cloud-original-proof.zip | 26,075,110 | `1eb1a3b35e7429fb6334a3d1439ad91eed9d08ba554795bfe2ed39b3b2fc7606` |
| cloud-plus-two-proof.zip | 26,342,650 | `f36ef9a233c61180fb26562ded86f6cdcbedc1131d83930f1fbecfc568c457aa` |
| unrestricted-proof.zip | 24,523,339 | `8e44fc0960b930c2ed103e68f6f4029fe443cb967965962004cdff1b66d44f10` |
| strips-proof.zip | 2,570,801 | `b9c0f0f7bf0b2a3e7b23fd007c701a8c6ce545e749cc6c60f913366a56e339ae` |
