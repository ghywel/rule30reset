# The silver word's Pell agreement interval

For the phase-zero word $c(t)=\lfloor t(2-\sqrt2)\rfloor\bmod 2$, let
$q_n+p_n\sqrt2=(1+\sqrt2)^n$, $n\ge1$. The lags $q_n$ are $1,3,7,17,41,\ldots$.
At lag $q_n$, a maximal interval of agreement $c(t)=c(t+q_n)$ is

$$
[a,b]=\left[\frac{q_{n+1}-q_n}{2}+1,\ q_{n+1}-1\right].
$$

Its length is exactly two less than the later start $a+q_n$. In particular the even-time bits of column 1 cannot
eventually equal this word if column 0 eventually reads the clock $0101\ldots$ and the initial row has a leftmost
black cell at $-L$, $L\ge1$.

**Credit and status.** The interval is **PROVED** in placego. Local's L099 note on G143 states the sharp run
at every mediant. GC2187 gives the two consecutive mismatches for either sign, independently read in L1192.
ClaudeIntel's N6 recovered the interval from finite data. Steps 1–4 give a direct hand proof in N6's lag
coordinates. The Rule 30 application and the family argument below are submitted for a carrying read (I123).
[Original G143 and L099](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/proofs/G143-an-aperiodic-half-circle-code-passes-every-repeat.md)
· [GC2187 and its review in GC2193](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/wolfram-agents/UNIFORM-RECODING-DELIVERY-SCOPE.md#gc2187-hand-candidate--the-phase-zero-repetition-exponent-has-an-exact-exceptional-maximum)

## The hand proof

1. **Turn a mismatch into an integer crossing.** Write $(q,p)=(q_n,p_n)$, $(Q,P)=(q_{n+1},p_{n+1})$,
   $\rho=\sqrt2-1$ and $e=q-p\sqrt2=(1-\sqrt2)^n$. Multiplication by $1+\sqrt2$ gives
   $Q=q+2p=p+P$, $P=q+p$, and $Q-P\sqrt2=-\rho e$. The parity of $c(t)$ is the parity of
   $\lceil t\sqrt2\rceil$, and $q\sqrt2=2p+\sqrt2\,e$. Thus translating by $q$ changes the bit
   exactly when the short displacement $\sqrt2\,e$ crosses an integer. For $t>0$ both endpoints are
   irrational and $|\sqrt2\,e|<1$. For either sign of $e$ the test for a mismatch is
   $0<(m-t\sqrt2)/e<\sqrt2$ for some integer $m$.

2. **Bound the accuracy of every earlier denominator.** For $0<k<P$ and any integer $h$,
   $|h-k\sqrt2|\ge |e|$. Indeed, the determinant $qP-pQ=q^2-2p^2=(-1)^n$ makes
   $(q,p),(Q,P)$ an integer basis. Write $(h,k)=u(q,p)+v(Q,P)$. The signed error divided by $e$ is
   $u-\rho v$. If $v\ge1$ then $u\le-1$ since $k<P$. If $v\le-1$ then $u\ge1$ since $k>0$.
   If $v=0$, again $u\ge1$. In each case its absolute value is at least one.

3. **Locate two consecutive mismatches.** At $t=p$ take $m=q$ in step 1. The ratio is 1. At
   $t=p+P=Q$ take $m=q+Q$. The ratio is $1-\rho$, also inside the crossing interval.
   A mismatch at $t=p+k$ with $0<k<P$ would require
   $-1<((m-q)-k\sqrt2)/e<\rho$, contradicting step 2. Hence the whole interval
   $[p+1,Q-1]$ agrees, with a mismatch immediately on each side. It has $P-1$ letters.
   For lag 17 this gives mismatches at 12 and 41 and agreement on $[13,40]$.

4. **Check that −3 is the maximum measured by N6.** The excess of a run $[a,b]$ at lag $q$ is
   $b-2a-q$. At the displayed run it is −3. To bound all later runs, start at the mismatch $t=p$.
   Given a positive mismatch of ratio $w=(m-t\sqrt2)/e$, if $w>\rho$, step forward by $P$ and add $Q$
   to $m$. The new ratio is $w-\rho$. If $w<\rho$, step by $p$ and add $q$, giving $w+1$.
   Both remain in $(0,\sqrt2)$. Equality $w=\rho$ would force $t=-P$ by irrationality.
   This constructs mismatches indefinitely with gaps at most $P$. Every agreement run starting at
   $a\ge p+1$ therefore has at most $P-1$ letters and excess at most $P-2-a-q\le-3$.
   A run before $p$ has excess at most $p-1-q\le-3$ for $q\ge7$ (at $q=7$, $q-p=2$, and the
   next difference is $Q-P=p$). At $q=3$, time 0 mismatches and the only earlier run is $[1,1]$.
   At $q=7$, $[0,4]$ ties $[6,16]$. At $q=1$, $[2,2]$ still has the claimed flanks,
   while $[0,0]$ gives the global maximum −1. Thus $E(q_n)=-3$ for every $q_n\ge3$.

5. **Use the kit's clock theorem.** Take $i=p+1$, $i'=i+q=P+1$. The common block has
   $P-1=i'-2$ letters, exactly what `corollary_F` requires for every natural $s$ with $s+2<i'$.
   Both $i$ and $i'-i=q$ grow without bound. Given a requested lag $N$, a clock onset $T_0$, and
   a cutoff after which the visible word agrees with $c$, choose $n$ large enough for all three.
   This contradicts `corollary_F` with $K=2$. A fixed exchange of black and white preserves all the equalities.
   [Kit theorem and exact hypotheses](https://github.com/WolframInstitute/Rule30PrizeKit/blob/cf60d480c69a2f3526663b93f585a5c7398e0950/lean/Ruliology/CellularAutomata/Rule30ClockNearSquares.lean#L259-L268)

## What the same argument gives for other slopes

Let $c_\beta(t)=\lfloor t\beta\rfloor\bmod2$ for any irrational $0<\beta<1$, again at phase zero.
The clock exclusion extends to every such word. The archived G144/L100 classification supplies the first
two cases below, and GC2187/L1192 supplies the sharp run in the third. The following direct argument uses
only ordinary consecutive convergents. [G144 and L100](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/proofs/G144-the-phase-zero-half-circle-repeat-filter-has.md)

Write $u/d$ for a convergent of $\beta$, $u_-/r$ for the preceding one, and $U/D$ for the next one.
With next digit $A$, $D=Ad+r$, $U=Au+u_-$. Write $e=d\beta-u$ and $D\beta-U=-\eta e$ with $0<\eta<1$.
For $0<k<D$, every $|k\beta-h|\ge |e|$ with $h$ integral. Step 2's basis argument applies verbatim
with normalized error $u_1-\eta v_1$ for basis coefficients $u_1,v_1$. Take indices late enough that $2|e|<1$.

1. **Infinitely many even numerators.** At such an index use lag $\ell=d$. A mismatch at $1\le t<D$
   would put $t\beta$ at distance strictly less than $|e|$ from an integer, since the displacement after
   removing the even numerator is $e$. Hence $[1,D-1]$ agrees.
2. **Infinitely many digits $A\ge3$.** At such an index use $\ell=2d$, with displacement $2e$ after
   removing $2u$. A mismatch at $1\le t<D-d$ would give $(t\beta-m)/e\in(-2,0)$ for some integer $m$.
   Adding one gives $((t+d)\beta-(m+u))/e\in(-1,1)$, contradicting the denominator bound at $t+d<D$.
   Thus $[1,D-d-1]$ agrees and $D-d\ge2d$.
3. **The remaining slopes.** Eventually $u_-,u,U$ are odd and $A\le2$. The numerator recurrence forces
   $A$ even, hence $A=2$. Use $\ell=d+r$, whose numerator $u+u_-$ is even. Its signed displacement is
   $-(1+\eta)e$, by the error recurrence. Time $d$ is a mismatch. A further mismatch at $d+k$ would
   require $(k\beta-h)/e\in(-1,\eta)$ for an integer $h$, impossible when $0<k<D$. At $k=D$ the
   normalized position relative to the crossed integer is $1-\eta$, so $d+D$ is a mismatch.
   Thus $[d+1,d+D-1]$ agrees at lag $\ell$, and the later start is $d+1+\ell=D+1$.

In cases 1 and 2 the agreement includes $[1,\ell+r-1]$, since $D\ge d+r$ in case 1 and
$D-d\ge2d+r$ in case 2. Fix $H\ge1$ after any visible-word transient with $2H\ge T_0$.
Along either subsequence the preceding denominator $r$ also tends to infinity. Choose $r\ge2H$.
Starting at $H$ and $H+\ell$ leaves at least $\ell+r-H\ge H+\ell$ common letters, so even $K=0$
works. In case 3 the starts already tend to infinity and $K=2$ works. Thus the single slack $K=2$
suffices for the tail statement for every indicated slope.

The bit is the half-circle reading of rotation by $\beta/2$ started at a cut endpoint. Reflection covers
irrational $1<\beta<2$ as well, since for positive $t$ the words of slopes $\beta$ and $2-\beta$ are
letter exchanges. The other cut endpoint exchanges the letters too. N6's #9 and #19 use four endpoints
and an independently chosen phase. Their status remains a finite observation through lag 65,535.

**Exact finite control.** [The registered integer-square-root check](check_silver_pell.py) enumerates completed
runs through four times the next lag for all 13 lags from 1 to 47,321. It also tests the four flank and
endpoint bits through Pell exponent 128. The full interval and the upper bound at every lag in the
Pell subsequence follow from steps 1–4.
