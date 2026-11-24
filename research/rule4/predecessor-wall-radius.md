# How far right does one Rule 30 step reveal the previous wall?

**K83.A, 24 November 2026.** Write the old wall and its right tail as `u₀,u₁,…` and the present right half as `y₁,y₂,…`, where `yᵢ = uᵢ₋₁ XOR (uᵢ OR uᵢ₊₁)`. Let R be the shortest present prefix that forces the same old wall for *every* compatible predecessor. For independent fair present bits, **E[R] = 8**. The full distribution has probability generating function

$$\mathbb E[t^R]=\frac{t^3}{4-2t-t^3}.$$

**Exact rule.** Start with a virtual zero immediately before `y₂`. Read rightward from `y₂` until a zero closes a run of ones of length 1 modulo 3. Its position is R. Count `y₁` as one of the R bits because it selects the wall colour. The earliest decisions are `010 → black` and `110 → white`. An all-zero output never decides.

**Proof.** Given a prefix of length n and an eastern pair `(uₙ,uₙ₊₁)=(b,c)`, the inverse rule reconstructs its unique predecessor block. All four choices extend to infinite old rows. Encode the reconstructed `u₀` by a mask M whose bit `2b+c` is the wall value for that pair. The empty prefix has mask 12. On appending a bit y, the new function satisfies `M′(b,c) = M(y XOR (b OR c),b)`. A constant mask decides the wall. A nonconstant mask has two actual completions with opposite walls, proving optimality even among exact prefix decoders. With a fair old row those completions have positive conditional probability, since the four pairs have equal weight.

For deciding *when* the mask becomes constant, identify M with its bitwise complement, taking representative `min(M,15−M)`. The complete reachable table is

| Representative | Read 0 | Read 1 |
|---:|---:|---:|
| 0 (decided) | 0 | 0 |
| 1 | 1 | 2 |
| 2 | 0 | 3 |
| 3 (initially) | 1 | 1 |

After the first bit, states 1, 2, 3 record the trailing run of ones modulo 3 as 0, 1, 2, respectively. This proves the run test. From state 1, reading `0` restarts after one bit (probability 1/2), `10` decides after two bits (1/4), and `11` followed by either bit restarts after three (1/4). If H is the generating function of the additional reading time from state 1, then `H = tH/2 + t²/4 + t³H/4`. Multiplying by t for the first bit gives the displayed law, with value 1 and derivative 8 at t=1.

For a width-n measurement the unresolved probability is exactly `Cₙ/2ⁿ`, with `(C₀,C₁,C₂)=(1,2,4)` and `Cₙ=Cₙ₋₁+2Cₙ₋₃` for n≥3. Indeed the generating function of C is `(1+z+2z²)/(1−z−2z³)`, obtained from the survival generating function `(1−E[tᴿ])/(1−t)` at `t=2z`. The decay rate is the familiar κ≈0.847810, the positive root of `4κ³−2κ²−1=0`. The replay independently evolves every old row of widths 2 through 14 and checks the wall counts and run criterion for every current prefix through width 12. [Python replay](predecessor-wall-radius.py)

**Use for K83.A.** Under a fair old wall and tail, the conditional chance that the old wall was black equals the number of set mask bits divided by four. On prescribing the old wall but leaving its old right tail fair, R still has the displayed law. It depends only on `y₂,y₃,…`, which are fair by the same four-completion count using only `u₁,u₂,…`. Conditioning on the old wall does change the law of the full current half. This calculation quantifies information about one past wall. The distribution of a future gate under repeated forcing is a separate question.

The project’s K5 fair-coin comparison already tracks the run residue. Its wheel 0 is white and wheel 2 is forced black. For the present predecessor radius the virtual white sits immediately before the first fair bit in the search, and every later bit is fair. This boundary convention determines the initial counts and the mean. [K5 comparison](../m29/k5/claudeCloud_row_chain.py)

**Prior art.** Wolfram gave the eastern-pair inversion and the four finite predecessors in 1986. The cyclic multiplicity criterion and its growth constant are credited to Carl and Richard Feynman. The current kit corrects the printed cyclic criterion and proves generic full-line uniqueness from cofinal `010`. Jen gives the four-pair recurrence for Rule 30, and Spencer’s Proposition 3.1 gives both length-three wall decisions. The present calculation identifies the earliest deciding prefix at this boundary and its fair reading law. OEIS A203175 also lists the shifted count sequence in another enumeration. [Wolfram, §§4 and 9](https://content.wolfram.com/sw-publications/2020/07/random-sequence-generation-cellular-automata.pdf) · [NKS, p. 1087](https://wolframscience.com/nks/notes-10-10--cryptographic-properties-of-rule-30/) · [Jen, §4(a)](https://content.wolfram.com/sites/13/2018/02/03-5-2.pdf) · [Spencer, Proposition 3.1](https://arxiv.org/pdf/1306.3546#page=24) · [Kit transfer map](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ebda8cefa92d2ba2ec4d67fc14f69fa31908c0cc/lean/Ruliology/CellularAutomata/Rule30Predecessors.lean) · [Kit full-line theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ebda8cefa92d2ba2ec4d67fc14f69fa31908c0cc/equivalents/Rule30Equivalents/Preimages.lean) · [OEIS A203175](https://oeis.org/A203175)
