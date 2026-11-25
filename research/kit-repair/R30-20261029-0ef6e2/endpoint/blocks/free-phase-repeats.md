# Rotation-ordered blocks at free starting phases

**PROOF-SKETCH, ready for an independent carrying read.** Fix an irrational rotation angle \(\alpha\), an arc with two cuts, and any starting phase. Let \(q_n\) be its convergent denominators. If

\[
\limsup_{n\to\infty}\frac{q_{n+1}}{q_n}>7,
\]

then replacing the arc labels by any two fixed nonempty binary blocks gives a sequence that a Rule 30 right neighbour cannot eventually read on the white ticks of an eventually alternating column in a row with a leftmost black cell. This applies to every angle with infinitely many continued-fraction digits at least seven, including the bounded-type angle \([0;\overline7]\). The argument also gives an all-phase version for the golden half-circle using the earlier six-lag cover, and an almost-every-phase version for every fixed one-arc rotation. [S19 and its endpoint hypothesis](README.md) · [Original finite-arc exclusion](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-0ef6e2)

M181 asks about unconstrained right halves and every order of specified blocks. Here the order is prescribed by a rotation and the row has a leftmost black cell.

The statement also applies to two lists of positive gaps between black readings. Encode a gap of length \(g\) as one black reading followed by \(g-1\) white readings, then use the two resulting binary blocks.

## Repeat length on the clock of the blocks

Let \(c(t)\) be the arc label and let \(T(n)=\sum_{t<n}|B_{c(t)}|\). If the letter sequence agrees at \(a\) and \(b>a\) for \(l\) letters, the expanded words at \(T(a)\) and \(T(b)\) agree for \(T(a+l)-T(a)\) readings. The kit's clock obstruction applies when

\[
T(a)+T(b)\le T(a+l)+K
\]

with a fixed \(K\) at unbounded lags, from beyond every fixed start. The blocks are nonempty, so their clock lags are at least the letter lags. The proof uses the kit's near-square theorem for the placement of the clock and its transient. [Formal transfer](WeightedRepeatTransfer.lean)

For a rotation coding, \(T(n)/n\) tends to the positive mean \(\mu\) of the block lengths. Approximate the angle by \(p/q\) with \(|\alpha-p/q|<1/q^2\). Over \(q\) steps the rational orbit is a permuted uniform grid. Its count in an arc differs from \(q\) times the arc length by at most two. True orbit points are within \(1/q\) of the grid points, and membership can change only within \(1/q\) of a cut. Each of the two cut neighbourhoods contains at most three grid points. This bounds the discrepancy on a \(q\)-step chunk by eight at every phase. Split any prefix into whole chunks of one fixed \(q\) and a remainder shorter than \(q\), then take arbitrarily large \(q\). This proves convergence of the frequency, including when the starting point is a cut.

For rationals \(L<\mu<U\) arbitrarily close to \(\mu\), a fixed \(C\) gives \(Ln-C\le T(n)\le Un+C\) for all \(n\). These inequalities admit a common positive integer denominator. Whenever \(U(a+b)\le L(a+l)\), the three envelope errors give a fixed slack. In particular, positive surplus \(l-b\) proportional to \(a+b\) survives every choice of block lengths. S19's exact endpoint argument handles cases with only bounded slack in the letter clock.

## Three trials per convergent

Take a convergent \(p/q\) and the next denominator \(Q\). If the lag-\(q\) comparison changes a letter, assign the mismatch to a cut whose half-open crossing strip contains the starting point. Each strip has length \(|q\alpha-p|\). Two times assigned the same cut give a strictly smaller circular displacement, so their positive separation is at least \(Q\) by best approximation of the second kind. The determinant proof writes any integer pair \((h,m)\) in the basis \((p,q),(P,Q)\). When \(0<m<Q\), its coefficients \(u,v\) satisfy either \(u\ge1,\ v\le0\) or \(u\le-1,\ v\ge1\). The two basis errors have opposite signs, so the absolute error of \((h,m)\) is at least \(|q\alpha-p|\). [Formal cut and determinant lemmas](SeparatedArcCuts.lean)

Fix a cutoff \(H\) and an extra length \(E\). Try to copy \(a+q+E\) letters from \(a=H\) at lag \(q\). A failed trial has a mismatch before \(2a+q+E\). Start again immediately after such a mismatch. After three failures the three mismatches are strictly ordered, all before

\[
W=8H+7(q+E).
\]

If \(W\le Q\), three mismatches would repeat a cut label inside this window. Hence one trial succeeds with \(a\ge H\), \(b=a+q\), \(l=b+E\), and \(a+l\le W\). [Formal three-trial lemma](WeightedRepeatTransfer.lean)

At infinitely many large scales \(Q\ge(7+\sigma)q\) for some \(\sigma>0\). Choose \(0<\tau<\sigma/14\) and set \(E=\lfloor\tau q\rfloor\). For each fixed \(H\) we eventually have \(W\le Q\), \(E\ge\tau q/2\) and \(W\le(8+7\tau)q\) at these scales. Choose \(L,U\) so \((U-L)(8+7\tau)\le L\tau/2\). Then \((U-L)(a+b)\le LE\), which gives \(U(a+b)\le L(a+l)\). The resulting weighted near-squares have unbounded lags. Unbounded digits qualify directly. For bounded digits at most \(A\), a digit of at least seven gives \(Q/q\ge7+1/(A+1)\) at each sufficiently late such step.

The hand argument extends to \(m\) fixed cuts using \(m+1\) trials and window \(2^{m+1}H+(2^{m+1}-1)(q+E)\). The ratio threshold becomes \(2^{m+1}-1\). The Lean candidate uses two cuts.

## Two other ways to supply the margin

**Almost every phase at each fixed angle and arc.** I127 and N8 give letter prefix repeats of at least \(q\) letters at lag \(q\) for almost every phase, at arbitrarily large denominators. Every such repeat expands to a prefix repeat of length at least \(T(q)\) at lag \(T(q)\). Starting at a fixed letter \(H\) costs at most \(2T(H)\) in the weighted slack. This argument needs only positive lengths. It also works for I127's almost-every finite partition with fixed angle and phase. [Metric theorem and independent read](../../metric-rotation-repeats.md)

**Golden half-circle at every phase.** S11 gives \(b-2a-q\ge0.0999q-3\) for an inclusive agreement interval at lag \(q\). Its actual witnesses control the start \(a\). Every earlier crossing in the 27-slab table has height \(p.b\le2\). The cover's time identity is \(C_0t_p=z+s+2d\,p.b+(h-1)W_p\), with \(C_0=2d v^n>0\), \(d=\sqrt5<5/2\), \(z+s\le6\), \(|W_p|\le1\), and \(0<h<10^{-6}\). The scaled lag satisfies \(C_0q\ge1-h\). Thus \(t_p\le18q\) and \(a=\max(0,t_p+1)\le19q\). Moving the start to \(a+H\) costs \(2H\) of surplus. For large \(q\) the remaining surplus is at least \(q/40\), and the sum of both start indices is at most \(40q\) when \(2H\le q\). The envelope argument therefore transfers the repeats to arbitrary positive block lengths. The finite cover and its surplus are S11's. [Exact S11 cover and scale identities](../../golden-strip-cover.md)

## Scope of the candidate

The original portal theorem concerns one reading per letter and imposes a stronger sufficient digit threshold. S19 handles every angle and all positive lengths on the two endpoint orbits. When the cuts lie on the same orbit, recoding a Sturmian word in a finite window and then applying a nonerasing morphism gives an eventually periodic or quasi-Sturmian word, within the existing bounded-excess exclusion. Nguyen's §7 also counts cut crossings and iterates the bounds on the mismatch locations, obtaining infinite unweighted Diophantine exponent for unbounded digits. Here each signed half-open crossing strip contributes at most one mismatch up to the next denominator. The bounded-type criterion and the passage to the Rule 30 reading clock are the point of the candidate. [Nguyen, §7](https://arxiv.org/html/2608.20191v2#S7) · [Bugeaud–Kim on quasi-Sturmian words](https://irma.math.unistra.fr/~bugeaud/travaux/BugeaudKimFourier.pdf) · [Adamczewski on initial repetitions](https://doi.org/10.1016/j.aam.2004.02.001)

Lean formalizes the denominator window and the weighted-envelope criterion. The conversion from the continued-fraction limsup and the arc frequency to those hypotheses is given in prose. The golden consequence also uses the height bound in the old certificate. These are the parts to carry before building a release packet. General bounded-type free phases below the criterion, including the all-phase silver question, remain open by this argument.

## Checks and proposed wording

Independent integer-floor checks at \([0;\overline7]\) used two fixed arcs and 67 rational phases at each of \(q=357\) and \(q=2549\). Every result met the letter-window bound. A constructed rational phase and arc put one mismatch near the end of each of the first two trials, so the third trial was necessary. At the smaller scale a letter surplus still became a negative weighted surplus with lengths 1 and 1000. The larger scale gave positive weighted surplus for all tested phases with those lengths in either order and with lengths 18 and 28. These checks test the bookkeeping. The denominator and envelope proofs supply the unbounded result. An independent extraction checked all 30 listed golden witnesses and found earlier heights from \(-8\) to \(2\).

The [portable builder](build_free_phase.py) takes kit main at `e92083b` and assembles the existing tail and near-square proofs, the needed S19 helpers and these two modules. The 54,761-byte source has SHA-256 `c2bebbd2dd46ac53da00f0284ab8dce64a24bee3cc7e4c11d6b1014b05da0162`. At the verifier pin `5fb5915` the stock checker passed all eight requested headlines with 294 replayed constants and zero new axioms.

**Proposed title**

Free-phase rotation orders of two blocks beside an alternating Rule 30 column

**Proposed abstract**

We give a sufficient condition for ruling out a prescribed order of two nonempty binary blocks beside an eventually alternating Rule 30 column in a row with a leftmost black cell. Read an irrational rotation through one arc, starting at any phase, and substitute one block for each of the two answers. If the limsup of consecutive convergent-denominator ratios exceeds seven, the right neighbour cannot eventually read the resulting word on the white ticks. At a convergent lag, each of the two cuts can cause at most one mismatch before the next denominator. Three attempts at a sufficiently long repeat therefore suffice. Linear envelopes for the cumulative block lengths carry the repeat to the reading clock. The weighted-window exclusion and its Rule 30 transfer are checked in Lean. Elementary frequency estimates supply the envelopes in the stated rotation case. The same transfer gives the exclusion for almost every phase of every fixed arc and angle, and the earlier golden cover supplies it at every golden half-circle phase.
