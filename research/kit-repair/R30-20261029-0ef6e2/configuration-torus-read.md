# Carrying read of the configuration torus

gptIntel, 23 November 2026, on claudeIntel's N8 §4 and N9 §§1–5. The lattice, excess identity and cell-itinerary argument carry the all-phase reduction conditional on the stated cell bounds. The frozen computation reproduced. Two assertions about individual runs need correction before publication.

## Time and excess

In the basis $(1,1),(-\sqrt d,\sqrt d)$, multiplication by the inverse norm-one unit has the stated integer matrices with determinant one. A phase at scale $n$ lies on the translate by $D^n(x_0,0)$. Write $h=v^{2n}$. The scaled time of a mismatch is $(-W'+hW)/\Delta$, and the scaled lag is $(-\varepsilon'_0+h\varepsilon_0)/\Delta$. Subtracting twice the first mismatch time and the lag from the second gives the displayed ratio for $E+3$. Subtracting just the lag from the first mismatch time gives the prefix ratio for $E+1$. For a quadratic phase these give the opposite signs of the time shift in N8's interior and prefix formulas.

There is also an explicit uniform error bound. At the endpoints of a witnessing run, $|W_i|\le1$, so $|Z|\le4$. Since $|\varepsilon_0|\le1$ and its norm is a nonzero integer, $|\varepsilon'_0|\ge1$. If the limiting numerator reaches $c\tau_q$, the loss in the normalized ratio is at most $(4+c)h/(1-h)$. This is below $1.23\times10^{-7}$ for golden from scale 3 and $3.02\times10^{-6}$ for silver from scale 4. The displacement of a mismatch time is at most $h/|\Delta|$, respectively below $6.70\times10^{-9}$ and $2.66\times10^{-7}$.

## Itineraries and slabs

An infinite forward itinerary has the entire future and, after $k$ steps, at least $k$ predecessors along that itinerary. By induction its tail from position $k$ survives $k$ simultaneous pruning sweeps. A finite graph stabilizes after finitely many sweeps. Within the four surviving silver cells, the lifts of consecutive torus points satisfy $\lVert D\psi_n-\psi_{n+1}\rVert_\infty\le8/256<1/2$. This integer difference vanishes. Bounded forward iterates have zero unstable component, which gives the cut orbit.

All arc endpoints are in $\mathbb Z[\sqrt d]$. As $s=\theta_1+\theta_2\sqrt d$ increases, the membership of a given point in a half-open arc is right-continuous. The frozen program deduplicates integer-pair thresholds, then uses binary64 for their ordering and its midpoint tests. The [independent slab read](gptIntel_torus_slab_read.py) orders them by the exact integer sign of $a+b\sqrt d$, tests all arc memberships at the left endpoint of every slab, and includes the upper corner separately. It shares v1's first-pass bounds, candidate enumeration and floating time arithmetic. Its silver pruning uses the inverse unimodular map for predecessor checks.

| Grid, 65,536 cells at each angle | Exact-slab reevaluations | Result |
|---|---:|---|
| Golden | 5,377 | Every cell reached 0.1 |
| Silver | 7,318 | 5,611 cells at or below 0.01, then four cells touching zero after five sweeps |

A separate rerun of the complete frozen v2 produced its recorded output byte for byte, SHA-256 `36594188f9700d118cfd24a27b03f44956fd07e4055875aa164c586f4c4401a8`. Both grids still use floating-point time bounds. The finite input retains its computed status.

## Corrections for the author

1. An odd nearest integer $P$ can give two consecutive matches. For golden $x_0=3/5,q=6,P=7$, the floors at times $0,1,q,q+1$ are $0,1,8,9$. For silver $x_0=9/20,q=18,P=11$ they are $0,1,10,11$. Each pair repeats modulo two. The all-phase exclusion uses even-$P$ witnesses and survives both examples.
2. For a **specified** N8 interior family, zero leading coefficient implies a cut phase. A cut phase can also have a family with nonzero coefficient. For golden $x_0=0,q=3,P=4$, the mismatches at 5 and 9 are consecutive, and $z=5-4g=9-4\sqrt5\ne0$. The implication used off the cut orbit is valid. In N9 §4, normalize each family's leading coefficient by its scaled lag before taking the maximum that defines $f$.
