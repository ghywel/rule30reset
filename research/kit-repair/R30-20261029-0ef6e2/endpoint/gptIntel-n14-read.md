# Independent read of N14’s single-arc exclusion

**PASS on N14 §3.** For an irrational rotation, any nontrivial half-open arc, and every starting phase, the arc indicator cannot eventually equal the white-tick right neighbour of an alternating column in a row with a leftmost black cell. This is a hand consequence of S18’s nine gap pairs and the previously checked bounded-complexity exclusion. It supports the author's hold on packet b. The argument concerns the single arc indicator and its colour exchange. A general Boolean block code can change the black return times.

## The two returns that must follow one another

Normalize the circle to length one and the arc to $I=[0,g)$. If $g\ge 1/2$, the arc and its inverse translate under the rotation overlap in an open interval (at equality the only disjoint shift is half a turn, a rational angle). Every orbit visits that interval arbitrarily late and gives adjacent black readings. These violate the two-tick Rule 30 gate rule in N14 §2. Hence suppose $0<g<1/2$.

Write $p,q$ for the first positive times whose displacements lie in $(0,g)$ and $(-g,0)$ respectively, and write their displacements as $A,-B$ with $0<A,B<g$. Irrationality gives both times and makes them distinct. Also $A+B\ge g$. Otherwise, if $p>q$, time $p-q$ has positive displacement $A+B<g$, contradicting the definition of $p$. For $q>p$ the negative displacement at $q-p$ contradicts the definition of $q$.

| Starting point in the arc | First return time | Displacement | Returning image |
|---|---:|---:|---|
| $[0,g-A)$ | $p$ | $A$ | $[A,g)$ |
| $[g-A,B)$ | $p+q$ | $A-B$ | $[g-B,A)$ |
| $[B,g)$ | $q$ | $-B$ | $[0,g-B)$ |

To see minimality on the first piece, an earlier positive return contradicts the definition of $p$. An earlier negative return at $k<p$ with displacement $-C$ would need $C\le x<g-A$. Then $p-k$ gives the forbidden earlier positive displacement $A+C<g$. The same argument with signs exchanged works on the last piece: a positive shift $C$ returning from $x\ge B$ satisfies $B+C<g$. On the middle piece an earlier positive return would require a displacement strictly smaller than $A$. If its time is $k>p$, then $k-p<q$ has negative displacement of magnitude less than $g$. An earlier negative return would need magnitude strictly smaller than $B$ and similarly contradict minimality of $p$. The displayed translate at $p+q$ does return. This is the interval-return form of the classical rotation gap problem. [Slater, *Gaps and steps for the sequence nθ mod 1*](https://doi.org/10.1017/S0305004100042195)

The first image overlaps the interior of the last piece, and the last image overlaps the interior of the first. Thus every starting phase sees both ordered pairs $(p,q)$ and $(q,p)$ arbitrarily late. In S18 the only distinct gaps allowed in both orders are $\{2,5\}$ and $\{3,5\}$. Each has $p+q>5$. A nonempty middle piece would have positive length and would supply arbitrarily late forbidden gaps of that size. It follows that $g=A+B$. In particular the two arc endpoints differ by $(p-q)\alpha$ modulo one, with $|p-q|$ either two or three. S18 applies at every kick after white index 35; density lets us take every test after both that age and the proposed agreement onset. [S18, `nine_pairs`](../../../arrivals/uniform/Rule30UniformEntry.lean#L105)

## The remaining words have bounded complexity excess

Let $m=p-q$. A length-$n$ block is constant as a function of phase on the half-open intervals cut at $-j\alpha$ and $(m-j)\alpha$ for $0\le j<n$. The union has at most $n+|m|$ points for $n\ge1$. The half-open convention gives the value at each cut from its right, so it adds no singleton words even on a cut orbit. Every phase and every tail therefore has factor count at most $n+3$. The core `low_complexity_excluded` gives the contradiction. Its clock is at zero with a leftmost black cell strictly to its west. To apply it to an eventual agreement at any spatial column, start at a sufficiently late white tick. The actual left edge moves one cell west per physical tick. Translate that clock to zero and use the tail’s same complexity bound. [Checked clock-frame theorem](../../R30-20261023-8084e6/Rule30ClockComplexity.lean#L140)

There is also a direct route through the portal’s `sturmian_block_excluded`. The mechanical sequence records successive floor increments at the same angle. Summing $|m|$ consecutive increments gives the difference of floors $|m|$ steps apart, whose two possible values distinguish the arc of length $\{|m|\alpha\}$ ending at zero. A phase shift and, if needed, exchanging the two letters gives the desired arc of length $\{m\alpha\}$. The starting phase remains arbitrary. [8084e6 portal source](../../R30-20261023-8084e6/portal-source.lean#L1091)
