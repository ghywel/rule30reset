# Long prefix repetitions for almost every finite partition of a fixed rotation

Fix an irrational angle $\alpha\in(0,1)$, a phase $\theta\in\mathbb T=\mathbb R/\mathbb Z$, and a positive
number $m$ of cuts. Take $m$ points of the circle with product Lebesgue measure. Sort them and label the
resulting intervals with any letters from a finite alphabet. Write $c(t)$ for the letter at $\theta+t\alpha$.
A union of $r$ arcs is the binary case with $m=2r$. A tuple with coincident cuts or a cut on the sampled
orbit has measure zero.

**Theorem (I127, PROOF-SKETCH pending independent read).** Let $p_n/q_n$ be the convergents of $\alpha$,
$d_n=|q_n\alpha-p_n|$, and $\Lambda=\limsup_n 1/(q_nd_n)$. For almost every cut tuple, for every
$1<\lambda<\Lambda$, there are infinitely many $n$ such that

$$
c(t)=c(t+q_n)\qquad (0\le t<\lfloor\lambda q_n\rfloor).
$$

The same times work for every labelling of these intervals. The Diophantine exponent of the word is at
least $1+\Lambda\ge1+\sqrt5$, and its exponent of repetition is at most $1+1/\Lambda$. These words violate
every uniform Jen repeat bound. This gives the strict inequality asked for in N7 at every fixed bounded-type
angle. For the golden angle $(\sqrt5-1)/2$, $\Lambda=\sqrt5$.

**Fixed-partition corollary.** For *any prescribed* $m$ cuts with $m<\Lambda$, almost every **starting phase**
has the displayed repeats for every $1<\lambda<\Lambda/m$. In particular, every fixed pair of cuts, at any
separation and any irrational angle, gives $\mathrm{Dio}\ge1+\sqrt5/2>2$ for almost every phase. This covers
the fixed half-circle problem in N7 off an exceptional null set.

## Measure of the event at one scale

Consecutive convergents have opposite signed errors and determinant of absolute value one. Hence
$q_{n+1}d_n+q_nd_{n+1}=1$. Put $u_n=q_nd_n$ and $r_n=q_{n+1}/q_n>1$ after the possible initial tie.
Then $r_n u_n+r_n^{-1}u_{n+1}=1$, so $\max(1/u_n,1/u_{n+1})\ge r_n+1/r_n$.
If infinitely many continued-fraction digits are at least two, then $r_n>2$ infinitely often, giving
$\Lambda\ge5/2$. Otherwise the denominators eventually follow the Fibonacci recurrence, so
$r_n\to\varphi=(1+\sqrt5)/2$ and $\Lambda\ge\varphi+1/\varphi=\sqrt5$. This proves the limsup form
of Hurwitz's bound used here. Also $\sum_n d_n<\infty$ by $d_n<1/q_{n+1}$ and
$q_{n+2}\ge q_{n+1}+q_n$. [Hurwitz's original theorem](https://link.springer.com/article/10.1007/BF01206656)

Choose $1<\lambda<s<\Lambda$, with $s$ finite even if $\Lambda=\infty$. Work on the infinite subsequence
where $q_nd_n<1/s$. Put $h_n=\lfloor\lambda q_n\rfloor$. For each integer $0\le t<h_n$ take the closed
arc from $\theta+t\alpha$ of signed displacement $q_n\alpha-p_n$. Its length is $d_n$, and its far end
is $\theta+(t+q_n)\alpha$ on the circle. Write $B_n$ for the union of these arcs. Its measure is at most
$h_nd_n\le\lambda/s<1$. If all $m$ cuts avoid $B_n$, none of the comparisons crosses a cut and all
$h_n$ letters agree. The set of such tuples is $E_n=(\mathbb T\setminus B_n)^m$, with measure at least
$(1-\lambda/s)^m$. Every tail union of the $E_n$ has at least this measure. So does $E=\limsup_n E_n$.

## Why the limsup has full measure

Translating $B_n$ by $\alpha$ changes the sample indices $0,\ldots,h_n-1$ to $1,\ldots,h_n$. Only the first
and last arcs can contribute to the symmetric difference. Its measure is at most $2d_n$.
Let $T_j$ translate just the $j$th cut by $\alpha$. Taking the product with the other $m-1$ coordinates gives

$$
\mu(E_n\mathbin{\triangle}T_j^{-1}E_n)\le2d_n .
$$

The sum of these measures is finite. By the first Borel–Cantelli lemma, almost every tuple belongs to
only finitely many such differences. Thus $E$ is invariant modulo null sets under each $T_j$.
For any nonzero integer frequency vector $k$, choose $j$ with $k_j\ne0$. Invariance multiplies the
$k$th Fourier coefficient of $\mathbf1_E$ by $e^{2\pi i k_j\alpha}\ne1$, so the coefficient vanishes.
Only the constant survives. An almost everywhere constant indicator with positive integral is one almost
everywhere. This proves the conclusion for the chosen $\lambda$. Intersect over rational $\lambda$ in
$(1,\Lambda)$ and shorten the runs to obtain it for every real $\lambda$ there.

The product calculation used independence of the cut coordinates at one scale. The argument allows arbitrary
dependence between successive scales. Sorting the cuts or using a jointly absolutely continuous law preserves
the full-measure conclusion. The phase was fixed throughout, so Fubini also gives the joint endpoint-and-phase
version of N7.

## Prescribe the cuts and vary only the phase

Fix the cuts $x_1,\ldots,x_m$. Construct $B_n$ at phase zero. At phase $\theta$ a crossing can occur only
when $\theta$ belongs to $\bigcup_{j=1}^m (x_j-B_n)$. Choose $1<\lambda<\Lambda/m$ and
$m\lambda<s<\Lambda$. Along the same subsequence $q_nd_n<1/s$, the complement of this union has measure
at least $1-m\lambda/s>0$. Translating $\theta$ by $\alpha$ changes this event on a set of measure at
most $2m d_n$. The summability and invariance argument on the single circle gives full measure to its
limsup. Taking countably many $\lambda$ proves the corollary. Since $\sqrt5>2$, it applies in particular to
every fixed interval with two cuts. The [endpoint-orbit proof](silver-pell.md) also treats specific phases
that a measure statement cannot decide. The general all-phase, bounded-type half-circle question remains open here.

## Exponents and the Rule 30 application

The prefix of length $q_n+h_n$ has period $q_n$. Its length divided by its period tends to $1+\lambda$
along the indicated subsequence. Such prefix powers qualify in the definition of $\mathrm{Dio}$ with an
empty initial word. For the exponent of repetition, let $r(h,c)$ be the least length of a prefix containing
two occurrences of the same length-$h$ block. The occurrences at 0 and $q_n$ give
$r(h_n,c)\le h_n+q_n$. Taking the liminf and then $\lambda\uparrow\Lambda$ gives
$\mathrm{rep}(c)\le1+1/\Lambda$, with $1/\infty=0$. For the golden angle, the convergents are
$F_{k-1}/F_k$ and $|F_k\alpha-F_{k-1}|=\alpha^k$. Binet's formula gives $F_k\alpha^k\to1/\sqrt5$.
[Definitions and the exponent identity in Bugeaud–Kim, Lemma 10.3](https://irma.math.unistra.fr/~bugeaud/travaux/complsturm3ndRev1.pdf)

In the Rule 30 coordinates of portal entry 0ef6e2, agreement on an inclusive interval $[a,b]$ at lag $q$
has excess $b-2a-q$. Fix a cutoff $H$ after which a visible word would agree with $c$. The intervals
$[H,h_n-1]$ have excess $h_n-1-2H-q_n\to\infty$. This contradicts every bound $b\le2a+q+C$.
For a clock starting at time zero the portal bridge takes $C=L$, the distance to the leftmost black cell.
For an eventual clock, restart the row at any even tick $2v$ past its onset. The leftmost black cell has
advanced left by $2v$ sites, so the restarted allowance is $L+2v$, and the sampled word is translated by
$v$. A fixed translation changes the excess by a fixed amount. Equivalently, with $2H$ past the onset, the
starts $H,H+q_n$ agree on at least $H+q_n$ letters for large $n$, which directly contradicts the kit's
`corollary_F` with $K=0$ for $L\ge1$.
[Portal repeat bound](portal-source.lean#L716-L726) · [Kit clock theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/cf60d480c69a2f3526663b93f585a5c7398e0950/lean/Ruliology/CellularAutomata/Rule30ClockNearSquares.lean#L259-L268)

N7 supplied the scale data and posed the metric question. P49 compares Nguyen's finite all-phase bounds for
badly approximable angles and Bugeaud–Kim's exponent identity. Boshernitzan and Damanik call these repetitions
pinned at the origin. Their Proposition 2 gives almost-sure constancy of the exponent in ergodic symbolic flows.
Their Theorem 5 and Corollary 1 give infinite exponents under property V and for almost every interval-exchange
length vector. Here the angle is prescribed, even at bounded type, and the variables are specified above.
The [arithmetic proof](golden-rational-cuts.md) treats N7's two named words.
[Nguyen, §7](https://arxiv.org/html/2608.20191v2) · [Boshernitzan–Damanik, §§1 and 3](https://arxiv.org/pdf/0808.2200)
