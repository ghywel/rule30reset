# The first mismatch for the quarter-phase silver word

Take the same silver circle rotation $\alpha=(2-\sqrt2)/2$ as in [the phase-zero Pell identity](silver-pell.md).
Start a quarter of the way around the circle, at $\theta=1/4$, and read the two half-circles with cuts
at 0 and $1/2$. At an integer time $t\ge0$ its letter is the parity of
$N(t)=\lfloor t\sqrt2+1/2\rfloor$. Indeed the original floor is
$\lfloor1/2+t(2-\sqrt2)\rfloor=2t-N(t)$. Both cut orbits contain only their cut as a rational point,
because $\alpha$ is irrational. Thus this phase, and its complement at $3/4$, lie off both orbits.

**Theorem (I128, PROOF-SKETCH pending independent read).** At lags $q_s$ the first mismatch of this word
with its $q_s$-translate occurs exactly at time $T_s$, where both sequences satisfy
$z_{s+2}=6z_{s+1}-z_s$ and

$$
(q_0,q_1)=(7,41),\qquad (T_0,T_1)=(11,64).
$$

In particular the whole prefix $[0,T_s-1]$ agrees at lag $q_s$, and its Jen excess $T_s-1-q_s$ tends to
infinity. The Diophantine exponent is at least $3/2+3\sqrt2/4$. The same clock exclusion holds at every
fixed time translate of either quarter phase.

## One small interval to check

Put $\epsilon=7\sqrt2-10\in(-1,0)$. At lag 7, the nearest-integer readings $N(t)$ for $t=0,\ldots,18$ are

$$
0,1,3,4,6,7,8,10,11,13,14,16,17,18,20,21,23,24,25 .
$$

The bounds $140/99<\sqrt2<99/70$ give every entry using rational arithmetic. For $0\le t\le10$ we have
$N(t+7)-N(t)=10$. At $t=11$ it is 9, so this is the first mismatch. In lattice coordinates, a mismatch
means that $w=t\sqrt2+1/2-m$ lies between 0 and $-\epsilon$ for some integer $m$. At $t=11$ this point
is $w=11\sqrt2-31/2$. The strip width is less than one, so each time supplies at most one crossing.

## Why the first crossing stays first

Let $\kappa=3-2\sqrt2$ and $\tau=3+2\sqrt2=1/\kappa$. Multiplication by $\kappa^s$ takes
$\epsilon$ to $\epsilon_s=q_s\sqrt2-p_s$. On coefficient pairs $(q,p)$ multiplication by $\kappa$ is
$(q,p)\mapsto(3q+2p,4q+3p)$. Starting at $(7,10)$ gives positive lags and even $p_s$ throughout,
so a crossing is always a change of bit.

The half-integer translate $\mathbb Z[\sqrt2]+1/2$ is preserved in both directions since $\kappa$ and
$\kappa^{-1}$ are 1 modulo $2\mathbb Z[\sqrt2]$. Thus multiplication by $\kappa^s$ bijects **all**
crossings at the base lag with all crossings at $q_s$. If $w=t\sqrt2+1/2-m$ is a crossing, its time
after multiplication, obtained by subtracting the two real embeddings, is

$$
t_*=\tau^s t+(\kappa^s-\tau^s)w/(2\sqrt2).
$$

Hence $t_*/\tau^s$ is between $t-|\epsilon|/(2\sqrt2)$ and $t$. The error is strictly less than one.
Distinct integer crossing times therefore keep their order, and negative times stay negative while
positive times stay positive. Time zero supplies no crossing. The first crossing at lag $q_s$ must be
the image of $11\sqrt2-31/2$.

Writing that image as $T_s\sqrt2-R_s/2$, the coefficient pairs evolve by
$(T,R)\mapsto(3T+R,8T+3R)$ from $(11,31)$. Both pair matrices have trace 6 and determinant one.
This gives the recurrences and starting values in the theorem.

Finally $q_s/\tau^s\to 7/2+5/\sqrt2$ and $T_s/\tau^s\to11/2+31/(4\sqrt2)$ by the same embedding formula.
Their ratio $T_s/q_s$ tends to $(2+3\sqrt2)/4>1$. The prefix of length $q_s+T_s$ has period $q_s$,
giving the claimed lower bound on its exponent. Dropping any fixed initial number of ticks or shifting
the word by a fixed integer preserves unbounded excess, so the Rule 30 repeat bound excludes the whole
two quarter-phase orbits. [Clock hypotheses and the tail argument](metric-rotation-repeats.md#exponents-and-the-rule-30-application)
· [Exact integer control](check_silver_quarter.py)

**Verification (I129).** The direct integer test compared every position up to the predicted first mismatch
at the seven lags from 7 through 275,807. The last first mismatch was 430,441. It also checked both flank
differences through $s=64$. At kit commit `cf60d48` the kernel verified the base table by integer squares,
the implication from unbounded repeat excess and lags to an eventual-clock exclusion, and the growth of
these particular Pell pairs inside that implication. The infinite interval identity used as `hcopy` in
the last theorem is the hand argument above. [Lean statements](RotationClockBridge.lean)
