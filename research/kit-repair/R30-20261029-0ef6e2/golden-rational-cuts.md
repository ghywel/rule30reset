# The two named golden words have unbounded Jen excess

N7 found long repeats in two specific four-cut words. For the irrational rotation with the same phase and
cuts, a single interval free of all cut crossings suffices to prove repeats at arbitrarily large lags.
Both examples meet the finite criterion at lag 144. The argument handles these particular words, which a
measure-one theorem cannot decide individually.

**Status (I127).** The two finite inputs below are **COMPUTED** with integer square roots. The implication
to unbounded excess is a **PROOF-SKETCH** awaiting an independent read.

## The two finite witnesses

Set $\alpha=(\sqrt5-1)/2$. Use the phase and two arcs from zero-based examples 9 and 19 in claudeIntel's
frozen generator. Subtract the phase from every cut modulo one. The resulting cuts are $y_j=x_j/2^{64}$,
with these numerators in the original encoding order.

| Word | Four cut numerators $x_j$ | Inclusive agreement interval $[a,b]$ at $q=144$ | $E=b-2a-q$ |
|---|---|---|---:|
| 9 | 7258983001689511988, 9296419589461253165, 16110373369397728468, 16216333890429968239 | [72,358] | 70 |
| 19 | 123150565432517928, 14560122122951919582, 15231742689975932610, 16502976599746550952 | [67,298] | 20 |

Take $p=89$. For every integer $a\le t\le b$ and each cut $y_j$, the two real numbers $t\alpha-y_j$ and
$(t+q)\alpha-p-y_j$ have the same floor. Thus the short segment connecting the two orbit samples avoids
every cut, including cases where a binary coding could hide two crossings. For $D=2^{64}$, the floor of
$Dt\alpha$ is $(\operatorname{isqrt}(5(Dt)^2)-Dt)\mathbin{//}2$ for $t\ge0$. All further floor tests
are integer operations. The I125 check used 4,096 comparison times and returned the table for both letter
agreement and absence of crossings. All the cuts are nonzero and the positive-time sampled positions are
irrational, so the choice of boundary convention does not affect the table.
[Exact checker](check_golden_cuts.py) · [Original cuts and phases](claudeIntel_near_square_followup.py)

## Carry the same cut-free interval to larger lags

Let $\mathcal O=\mathbb Z+\mathbb Z\alpha$ and put a prime on the other real embedding,
$\alpha'=-(1+\sqrt5)/2$. Write $\Delta=\alpha-\alpha'=\sqrt5$.
The following proof works for any fixed finite list of rational cuts $y_j=x_j/D$ relative to the phase.
Suppose the closed displacement segments for lag $q$ and integer $p$, with
$0<|\epsilon|=|q\alpha-p|<1$, avoid all the cuts at each time in $[a,b]$, where $a\ge0$, $q\ge2$
and $b-2a-q>4$.

Since $\alpha(\alpha+1)=1$, the image of $\alpha^2$ is invertible in the finite ring $\mathcal O/D\mathcal O$.
Choose an even positive power $\kappa_0$ of $\alpha$ congruent to 1 in that ring. For any positive integer
$s$, let $\kappa=\kappa_0^s$ and $\tau=\kappa'=1/\kappa$. Then $\kappa\downarrow0$ and $\tau\uparrow\infty$.
Multiplication by $\kappa$ and its inverse preserves each translate $\mathcal O-y_j$ since
$(\kappa^{\pm1}-1)y_j\in\mathcal O$. This keeps each crossing attached to the same cut.

For $w=t\alpha-m-y_j$ with $m,t$ integers, its time is $t=(w-w')/\Delta$ because $y_j$ is rational.
If $w_*=\kappa w=t_*\alpha-m_*-y_j$, conjugation gives

$$
t_*=\tau t+(\kappa-\tau)w/\Delta .
$$

Write $\epsilon_*=\kappa\epsilon=q_*\alpha-p_*$ with $q_*,p_*$ integers. The same formula with cut zero gives
$|q_*-\tau q|<\tau$. In particular $q_*$ is positive and tends to infinity.
A cut crossing at integer time $t_*$ means that some $w_*=t_*\alpha-m_*-y_j$ is between $-\epsilon_*$
and 0, endpoints included, in either order. Dividing by $\kappa>0$ gives a point in the original translate
between $-\epsilon$ and 0. Its integer time $t$ satisfies
$|t_*/\tau-t|\le(1-\kappa/\tau)|\epsilon|/\Delta<1$.

Consequently every integer in the new interval

$$
[A,B]=[\lceil\tau(a+1)\rceil,\ \lfloor\tau(b-1)\rfloor]
$$

is free of cut crossings. A crossing there would pull back to a crossing at an integer time in $[a,b]$.
Using $B\ge\tau(b-1)-1$, $A\le\tau(a+1)+1$ and $q_*<\tau(q+1)$ gives

$$
B-2A-q_* \ \ge\ \tau(b-2a-q-4)-3 .
$$

The right side diverges. For words 9 and 19 the lower bounds are respectively $66\tau-3$ and
$16\tau-3$. The new starts $A$ tend to infinity, so every fixed transient is harmless. This violates the
uniform Jen bound beside a Rule 30 clock for either word. The restart for an eventual clock is spelled out in
the [metric proof](metric-rotation-repeats.md#exponents-and-the-rule-30-application).

For these dyadic cuts one can even name the lags. We have $\alpha^3=1+2(\alpha-1)$. Squaring an element
congruent to 1 modulo $2^j$ gives one congruent to 1 modulo $2^{j+1}$ for $j\ge1$. Thus one choice is
$\kappa_0=\alpha^{3\cdot2^{63}}$. With $F_0=0,F_1=1$, the identity
$F_k\alpha-F_{k-1}=(-1)^{k-1}\alpha^k$ gives $144\alpha-89=-\alpha^{12}$. Multiplication by
$\kappa_0^s$ therefore gives the explicit lags $q_*=F_{12+3\cdot2^{63}s}$. This sequence proves
divergence without computing any of those large Fibonacci numbers.

**Sharper finite criterion (I128).** In fact any positive integer base excess suffices. Put
$h=|\epsilon|/\Delta<1$. For $t_*/\tau\in[a,b]$, the integer preimage time satisfies
$|t-t_*/\tau|<1$, so it already lies in $[a,b]$. We may use $A=\lceil\tau a\rceil$ and
$B=\lfloor\tau b\rfloor$. Using $q_*\le\tau(q+h)$ in the excess calculation gives
$B-2A-q_*\ge\tau(E-h)-3$. Both named words meet this sharper condition at lag 144.
