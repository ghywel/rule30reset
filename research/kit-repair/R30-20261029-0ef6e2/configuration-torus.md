# Every phase at once: the configuration torus of a half-circle coding

**Status.** §§1–4 are a PROOF-SKETCH by claudeIntel (N9), not yet second-read. §5 is COMPUTED: the frozen
interval certificate v2 in floating point with explicit margins, recorded in N9 addendum 4. Together they extend
N8 §4 from quadratic phases to every phase, at the golden and silver angles.

**Result (PROOF-SKETCH with a COMPUTED certificate).**

- **Golden.** Jen's bound excludes the half-circle word at every phase. In fact, at every scale $n\ge3$ some lag of
  that scale has a run with excess at least $0.0999\,q-3$, uniformly in the phase.
- **Silver.** Jen's bound excludes the word at every phase off the cut orbit $\mathbb Z+\mathbb Zg$. At such a phase,
  infinitely many scales carry a run with excess at least $0.0099\,q-3$. The cut orbit is excluded by `corollary_F`
  instead (silver-pell's family theorem, PROVED). At phase zero Jen's bound does not exclude the word: silver-pell
  steps 1–4 prove this on the Pell lags, and G143 states it for every lag.

## Setting

As in N8: $c(t)=\lfloor x_0+tg\rfloor\bmod2$ with $g=\sqrt5-1$ or $g=2-\sqrt2$, so that
$\mathbb Z[g]=\mathbb Z[\sqrt d]$, and $\Delta=g-g'$.

- At a lag $q$ with $P=\mathrm{round}(qg)$ even, put $\varepsilon=qg-P$.
- Time $t\ge0$ is a mismatch iff $x_0+\lambda\in I_\varepsilon$ for the $\lambda=tg-m\in\mathbb Z[g]$ of some
  integer $m$. Here $I_\varepsilon=[-\varepsilon,0)$ if $\varepsilon>0$ and $[0,-\varepsilon)$ if $\varepsilon<0$.
- The time is $t=(\lambda-\lambda')/\Delta$.
- Consecutive mismatches $t_1<t_2$ bound a run of excess $E=t_2-2t_1-q-3$. The prefix run has $E=t_1-q-1$.
- Lags with $P$ odd are not used. They can have longer runs: at golden $x_0=3/5$, $q=6$, $P=7$, the floors at times
  $0,1,6,7$ are $0,1,8,9$, so times 0 and 1 match (gptIntel, I146). The arguments below use even-$P$ witnesses only.

## 1. The configuration is an affine lattice

Let $M=\{(\lambda',\lambda):\lambda\in\mathbb Z[g]\}$ and $\Gamma(x_0)=M+(x_0,x_0)\subset\mathbb R^2$.

- Each point $p=(W',W)$ of $\Gamma$ carries the integer time $t(p)=(W-W')/\Delta$. The point is a mismatch at lag
  $q$ iff $W\in I_\varepsilon$ and $t(p)\ge0$. Since $|\varepsilon|<1$, a time is carried by at most one point with
  $W\in I_\varepsilon$.
- In the coordinates $(W',W)=\theta_1(1,1)+\theta_2(-\sqrt d,\sqrt d)$ the lattice $M$ is $\mathbb Z^2$, and
  $\Gamma(x_0)=\mathbb Z^2+(x_0,0)$. So the phase is the point $\theta=(x_0,0)$ of the torus
  $\mathbb R^2/\mathbb Z^2$, and $x_0\mapsto x_0+1$ does not move it.

## 2. The unit acts as a hyperbolic automorphism

Let $v=u^2$ be the norm-one unit: $v=9-4\sqrt5$ (golden) or $3-2\sqrt2$ (silver). Then $0<v<1$ and $v'=1/v$.

- Multiplication by $v^{-1}$ preserves $\mathbb Z[g]$. In $\theta$ it is
  $D=\begin{pmatrix}9&20\\4&9\end{pmatrix}$ or $\begin{pmatrix}3&4\\2&3\end{pmatrix}$, with $\det D=1$.
- Fix a family $\varepsilon_n=v^n\varepsilon_0$. Since $v\equiv1\bmod2\mathbb Z[g]$, $P$ stays even along it; the
  certificate also checks this.
- At scale $n$, rescale internal coordinates by $v^{-n}$ and physical ones by $v'^{-n}=v^n$. The configuration
  becomes $\Gamma_n=\mathbb Z^2+\theta_n$, with $\theta_n=D^n(x_0,0)\bmod\mathbb Z^2$.
- A point of $\Gamma_n$ is a mismatch iff $W\in I_{\varepsilon_0}$ and $t\ge0$, where exactly
  $$t\,v^n=\tau+v^{2n}W/\Delta,\qquad \tau:=-W'/\Delta.$$
- The stable line of 0 is $\{W=0\}$: physical coordinates contract, internal ones expand.

## 3. The exact excess

Let $p_1,p_2\in\Gamma_n$ be consecutive mismatches of $\varepsilon_0$. Put $Z=W_2-2W_1-\varepsilon_0$, with $Z'$
formed in the same way from the primed coordinates. Substituting the time formula and
$q=(v^n\varepsilon_0-v^{-n}\varepsilon_0')/\Delta$ gives

$$\frac{E+3}{q}=\frac{Z'-v^{2n}Z}{\varepsilon_0'-v^{2n}\varepsilon_0}.$$

The prefix run gives the same identity with $E+1$ and $Z=W_1-\varepsilon_0$. As $n\to\infty$ the ratio tends to
$Z'/\varepsilon_0'=(\tau_2-2\tau_1-\tau_q)/\tau_q$.

- **The function $f$.** Let $f(\theta)$ be the largest such limit over the runs of one fundamental domain of
  families, $|\varepsilon_0|\in(v,1]$. Only $|N(\varepsilon_0)|\le2(A+1)|\Delta|$ can give a non-negative value (N8's
  norm cut, which is phase-independent). That leaves 36 golden families and 12 silver ones.
- So the largest excess at scale $n$ is $q\,f(\theta_n)$ up to the corrections displayed.
- **Calibration.** At the rational phases 1/3, 2/7 and 3/5, every $|N|\le4$ lag up to 9,000 matches this to $O(1)$
  (N9 addendum 1).
- **Robust order.** Two mismatches of one family have $W$-difference $\mu\in\mathbb Z[g]$ with
  $0<|\mu|<|\varepsilon_0|\le1$. Their $\tau$-difference is $|\mu'|/|\Delta|\ge1/|\Delta|$, so a perturbation of
  $\tau$ by $10^{-6}$ never reorders them.

## 4. From the torus to every phase

- **Cut orbit.** $x_0\in\mathbb Z+\mathbb Zg$ iff some point of $\Gamma(x_0)$ has $W=0$, i.e. an exact hit, iff
  $\theta_0$ lies on the stable line of 0 modulo $\mathbb Z^2$. Then $\theta_n\to0$.
- **Quadratic phases.** $(x_0,x_0)$ lies on the stable line of the periodic point $(x_0',x_0)$, shifted by
  $x_0-x_0'=\xi\Delta$. Along that orbit a family's normalised excess is its N8 coefficient $\Phi$ divided by its scaled
  lag, and $f$ is the maximum of these quotients over families, not of the $\Phi$ themselves. N8's constant $\xi-3$ is
  the bounded time shift. N8's $\Phi=0$ implies a cut phase for that family; a cut phase can have families with
  $\Phi\ne0$, for example golden $x_0=0$, $q=3$, $P=4$, whose consecutive mismatches at 5 and 9 give $z=9-4\sqrt5$
  (gptIntel, I146). Off the cut orbit no family has $\Phi=0$, which is the direction used here.
- **Golden, given a uniform bound.** Suppose every cell of a grid has a certified lower bound $f_{lo}\ge c$ that is
  valid for the exact scale-$n$ configuration ($n\ge n_0$). Then every phase has, at every scale $n\ge n_0$, a run of
  excess at least $(c-\delta_n)q-3$, with $\delta_n=O(v^{2n})$.
- **Silver, given an invariant-set bound.** Let $S_0$ be the cells with $f_{lo}\le c$. Let $S^*$ be the fixpoint of
  $S\leftarrow S\cap\mathrm{succ}(S)\cap\mathrm{pred}(S)$ under the exact cell enclosure of $D$, and suppose
  $S^*\subset[-\rho,\rho]^2$ with $(\lVert D\rVert_\infty+1)\rho<\tfrac12$.
  1. Suppose a phase has excess below $(c-\delta_n)q-3$ at every lag of every scale $n\ge n_1$.
  2. Then each $\theta_n$ lies in a cell of $S_0$, and the cell itinerary is a forward-infinite path in $S_0$. Its
     $k$-th cell survives $k$ sweeps, so the tail lies in $S^*$.
  3. On the box the lift is exact, $\psi_{n+1}=D\psi_n$, and the orbit stays bounded. So $\psi_n$ has no unstable
     component: $W(\psi_n)=0$, an exact hit, and $x_0\in\mathbb Z+\mathbb Zg$.
- **The reflected time.** In §3, $E+3=n$ with $x_0-ng\equiv-z\pmod1$, where $z=w_2-2w_1-\varepsilon$ and
  $|z|\le3|\varepsilon|$. A run of large excess is a near-visit of the backward orbit to the cut at time $-(E+3)$,
  which is how the cut-orbit families of N7 keep $E=\xi-3$.

## 5. The certificate

[claudeIntel_torus_certificate_v2.py](claudeIntel_torus_certificate_v2.py) uses the frozen families of
[claudeIntel_configuration_torus.py](claudeIntel_configuration_torus.py), imported unchanged. It also uses v1's
bound, [claudeIntel_torus_certificate.py](claudeIntel_torus_certificate.py), as a first pass.

- **Cells.** On each cell of a 256 × 256 grid, $W$ and $\tau$ of every lattice point are affine. Margins are
  $10^{-9}$ in $W$ and $10^{-6}$ in $\tau$.
- **Slabs.** Every $W$ is $s+c$ with $s=\theta_1+\theta_2\sqrt d$ and $c\in\mathbb Z[\sqrt d]$, so all
  mismatch statuses of all families change only at thresholds $s\in\mathbb Z[\sqrt d]$. These are compared exactly.
  Distinct thresholds in a cell differ by more than $10^{-4}$.
- **Bound.** On each slab between thresholds the statuses are fixed. Points near the time origin are split both
  ways, and each run is bounded at the cell's corners. The cell's bound is the minimum over slabs of the maximum
  over families. A family subset only lowers the bound, so N8's norm cut is not needed for the logic.
- **Finite scales.** The $\tau$ margin covers the exact correction $v^{2n}W/\Delta$ for $n\ge3$ (golden) and
  $n\ge4$ (silver). Mismatch order cannot change, by §3's robust-order remark.

**Results (N9 addendum 4).**

- *Golden.* Every one of the 65,536 cells has $f_{lo}\ge0.1$, without any subdivision.
- *Silver*, $c=0.01$. 8.6% of cells are possibly passing. The fixpoint is the four cells touching 0, so
  $\rho=1/256$ and $8\rho=0.031<1$, and §4's local step applies.

**Checks.**

- The bound never exceeded the sampled $f$ on 1,000 random cells (median slack $10^{-4}$).
- Direct integer excesses at rational phases match the torus to $O(1/q)$, for $|N|=4$ families and for the largest
  norms 14 to 44.

**History.** The first certificate (v1) split ambiguous points independently and failed: its frozen predictions
and the diagnosis are in N9 addendum 3. The sampled exploratory run is in addendum 2.
