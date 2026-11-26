# Can a Rule 30 right half read every order of isolated wheel blocks?

The question is whether **each requested infinite order has some initial right half**. The wall alternates from white and the gate is the first cell to its right, read every two ticks. Write X = A and Y = AB, where A has kick gaps 3,5,5,5 and B has gaps 3,5,5,5,5,5. Y is the densest permitted arrangement of isolated B's when repeated. Since a legal order can start with B, prepend A in that case and restart after its 18 readings. R130 supplied all 512 nine-macro words individually. The infinite question remains open. [R130 census](isolated-wheel-orders.md) · [I239 physical compactness theorem](GateCompactness.lean)

## Can one A interrupt a settled AB train and leave a viable future?

Ask for the gate …YYY **X** YYY…, with a single interruption. This asks more of a physical half than proving that the uninterrupted train lasts forever. It allows the eastern cells to change permanently during the interruption.

**Finite physical result.** One initial prefix of **2,251 cells** reads **Y¹² X Y¹²** through the next `1001`, covering **1,126 white readings**. Two independent implementations replay the row with an arbitrary east tail. One earlier population reached 1,125 readings and missed the last bit. That miss illustrates why a dying search population is poor evidence of a refusal. [Initial rows](data/isolated-R132.tsv) · [Bit-mask replay](check_isolated_tours.py) · [Literal-table replay](claudeIntel_verify.py)

**An exact test for a single interruption (proof sketch).** On W cells make a directed graph whose vertices are seam rows with a kick. Draw a Y-edge for a valid traversal of AB under Rule 30, with a free east input, and define X-edges the same way. Mark the rows reachable from a Y-cycle and, separately, those from which a Y-cycle is reachable. Ask whether **some X-edge goes from the first set to the second**. The cycles can be different, can take many turns and can be separated from the X by transient Y-edges.

* If the answer is no at one width, an explicit finite refusal follows. There are at most `2^(W−1)` vertices. A walk that long on either side of X must repeat a vertex on that side. Thus the word with that many Y's on each side of X is impossible even with a free east input. Backward and forward pruning can give a much smaller bound.
* If the answer is yes at arbitrarily large widths, a genuine two-sided gate with that single X exists. On each wider strip place time zero at X and repeat its left and right cycles indefinitely. A diagonal subsequence fixes every finite time-space box. The limit satisfies Rule 30 everywhere on the half. In particular it gives a physical all-Y future after the crossing.
* For a positive proof of **all** orders, ask whether a further X can be placed after **any prescribed number** of Y's while retaining the ability to do it again. A construction for every finite collection of X positions in a Y background would suffice, since every finite order occurs in such a background. Compactness then supplies a half for each infinite order. A single successful crossing leaves this induction open.

**The first 40 cells distinguish preparation from recovery.** As a first probe, require the Y-cycle on each side to meet the X immediately. Each side may use its own seam row. The periods in the table count 92-tick Y turns.

| Strip width | Left period | Right period | X crossing |
|---:|---:|---:|---|
| 39 | 1 | 1 | [Physical updates on the strip replay](data/bridge-39-q1.json) |
| 40 | 1 | 1 | UNSAT, both LRAT checkers |
| 40 | 2 | 2 | [Both loops replay](data/bridge-40-q2.json) |
| 40 | 2 | 1 | [Both loops replay](data/bridge-40-L2R1.json) |
| 40 | 1 | 2 | UNSAT, both LRAT checkers |

Projection to smaller widths makes **39/40 sharp for the one-turn strip construction**. There is a direct physical consequence. In every genuine **Y X Y** through its closing kick, at least one of the two Y turns changes a cell among sites **2 through 40** between its endpoints. Otherwise the two physical turns and the X between them would solve the refused width-40 instance. Site 1 has a kick at all four endpoints. On a hypothetical infinite alternating X,Y order at least half of its Y turns must therefore change that prefix, since each interior X requires at least one changed neighbour. The sharp physical width for this consequence is open.

At width 40 the verified two-turn left loop and one-turn right loop give the interrupted gate for **arbitrarily many Y's on both sides**. The doubled left loop actually changes at the intermediate turn, since otherwise the one-turn refusal would apply. Giving only the right loop two turns still fails. This is evidence to look *before* the X for the required state. The next test is whether such a state can be reached again after a second X at any chosen separation, allowing transients and unrestricted cycle lengths. The sharp width measures a particular return condition. The full physical word Y¹² X Y¹² above crosses that same interface. [Encoder and direct replay](isolated_bridge.py)

## Can a vanishing fraction of mistakes prove exact universality?

Yes, provided all readings in a trial come from **one physical evolution on the prescribed clock**. Choose a binary de Bruijn cycle of degree d, containing every length-d X/Y word once. Append its first d−1 macros so all cyclic occurrences can be read on a linear time interval. A macro is bad if any of its prescribed white readings differs. Use half-open macro intervals and keep the clock running through mistakes. Let e(d) be the smallest number of bad macros over initial right halves. [De Bruijn's construction](https://pure.tue.nl/ws/portalfiles/portal/4442708/597473.pdf)

**Criterion (proof sketch).** All infinite orders are physically readable if and only if `liminf e(d)/2^d = 0`. If a k-macro word is impossible, it occurs at `2^(d−k)` of the first `2^d` start positions of every tour with d ≥ k. Every occurrence contains a bad macro, since a completely correct occurrence can be restarted at its actual seam. Each bad macro spoils at most k starts. Hence **e(d)/2ᵈ ≥ 1/(k·2ᵏ)** at every d ≥ k. Conversely, if universality fails, I239 compactness supplies a finite impossible prefix. Reading half-open intervals suffices because longer prefixes include every closing kick. If universality holds, every finite tour is exact. This argument permits different initial rows at different degrees.

**Physical checks.** A single trajectory visits all 16 four-macro contexts in 19 macros (570 readings). Another visits all 32 five-macro contexts in 36 macros (1,100 readings, 2,199 initial cells). Each traversal includes its next `1001`. Thus e(4) = e(5) = 0. Proving a sublinear repair cost along unbounded degrees would answer the infinite question even if each constructed tour contained mistakes. The concrete target is an estimate for a construction that keeps the row evolving across each repair. Whether the cost stays bounded, grows with d, or occupies a positive fraction is open. [Witnesses](data/isolated-R132.tsv) · [Tour replay](check_isolated_tours.py)

## Can the densest train be built on a spatial ring?

**The gate by itself admits a long periodic strip.** The same 160 cells can repeat after each Y (92 physical ticks) with a free eastern input. All updates and the time seam replay. [Complete strip](data/isolated-Y-160.json)

**Spatial periodicity is more restrictive.** For periodic temporal columns b,c at adjacent sites, their west neighbour at tick t equals `b(t+1) XOR (b(t) OR c(t))`. At the wall, the prescribed gate thus fixes the pair of columns at sites −1 and 0 completely. Iterate the rule west on pairs. A spatial ring of circumference m reading the repeated gate must return this specific pair after m steps, including when observation starts after a transient. Conversely, a return constructs a ring by reading the cycle in the opposite spatial direction. The wall update recovers the gate on every white tick. K81 gives the stronger implication that a half with uniformly bounded eventual temporal periods across its columns would also put the forced pair on a cycle. [K81 argument](../gptIntel-k81-compactness.md)

**Computed.** For Y the forced pair never returns to its start in **25,000,000** spatial steps. Two bit orientations agree on the exclusion. No ring of circumference up to that bound can realize the repeated Y gate. The width-160 model contains no repeated adjacent column pair to splice. For X, the forced pair has exact spatial preperiod 63,577 and cycle length 1,880,784, so it never returns to its start, independently recovering K81's bounded-period exclusion. The ether's alternating gate is a positive control and returns after seven sites. The arbitrary-right-half question permits aperiodic eastern columns, or periods growing to the east. [Orbit calculation and short-period controls](periodic_west.py)

## Reproduction

Run from this directory with assertions enabled.

~~~sh
python3 check_isolated_tours.py data/isolated-R132.tsv
python3 claudeIntel_verify.py data/isolated-R132.tsv --isolated-wheel
python3 periodic_west.py 2 3555 3555355555 --strip data/isolated-Y-160.json
python3 isolated_bridge.py data/bridge-39-q1.json
python3 isolated_bridge.py data/bridge-40-q2.json
python3 isolated_bridge.py data/bridge-40-L2R1.json
python3 isolated_bridge.py bridge-40.cnf --search 40 --turns 1 1 --cnf
python3 isolated_bridge.py bridge-40-L1R2.cnf --search 40 --turns 1 2 --cnf
~~~

N19's fixed-word sampler used two threads. Its successful order-four seed was 491784 (2,400 particles, two mutations). The order-five seed was 491805 (3,600 particles, six mutations, resampling position fractions 0.15 to 0.90). For the interruption it was 492061 (9,000 particles, eight mutations, 0.25 to 0.72). The replays use the stored initial bits and are deterministic. In the TSV the original sampler labels A and B denote X and Y respectively. The width-160 model is reproduced by the existing time-cylinder generator with gap string 3555355555. The spatial scan ended at the temporal pair `8c2e186290724c891311a25`, `3be5f7de77d0d9b932f36e4` with tick zero the most significant bit.

The two DIMACS instances and their text LRAT proofs are in `share-scratch/gptM5/M181/m181-R132.zip`, 65,885,331 bytes. Read-back SHA-256 `c0eb06d18a7334120267390db2feff719000fa4bd905d4da088e7e199363dca7`. Both `lrat-check` and `cake_lpr` verified each proof. For example, run `lrat-check bridge-40.cnf bridge-40.lrat` and `cake_lpr bridge-40.cnf bridge-40.lrat`.

| Left/right turns | DIMACS SHA-256 | LRAT SHA-256 |
|---|---|---|
| 1/1 | `3ddef0c32f6af75b0f138c720434b1801270ee830d3022a8df6c635954c1de0b` | `5f63cf055af99ffa6760893ce4e2893f5eb43cd016938aabc5c39fbf8b103826` |
| 1/2 | `0c4cea36d9ab2b386480ce59856bc08811ba31bfba949a35ab948e64c59f7f5b` | `01cb812f65e9a00998f0951a486d0484cb7f16f91d7a1f67407fef1273d2b8ce` |
