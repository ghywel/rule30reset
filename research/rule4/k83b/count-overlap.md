# Upper bounds from exact temporal overlaps

Every observed word of two Rule 30 columns supplies a path in a graph with vertices the physical words of length $r$. An edge is a physical word of length $r+1$, connecting its first $r$ letters to its last $r$. At $r=14$ this gives a verified upper bound of **1.202988706922 bits per tick** on topological entropy. The registered prediction of a bound below 1.20 bits at $r=12$ failed.

| Overlap $r$ | Vertices | Physical edges | Upper growth factor | Upper entropy, bits/tick |
|---:|---:|---:|---:|---:|
| 8 | 2,916 | 6,964 | 2.399834085823 | 1.262934667570 |
| 10 | 16,476 | 38,616 | 2.358369438788 | 1.237789734331 |
| 12 | 89,844 | 207,544 | 2.326504644492 | 1.218164067207 |
| 14 | 476,596 | 1,089,000 | 2.302160961809 | 1.202988706922 |

**Physical graph.** Prescribe the $r$ decisive western bits of an $(r+1)$-tick word. Starting from an eastern prefix with its farther sites free, propagate cellwise known zeros and ones under Rule 30. Record a fully determined eastern word. Otherwise split on the next free initial site and repeat. At width $r+1$ every reading is determined. Deduplicate the eastern words and restore the free last western bit. Every physical word occurs by its finite light cone. Every accepted word has at least one realization by the driven half and the western triangular reconstruction. [Graph and integer weights](count-overlap.cpp)

**Inequality for all times.** Write $A$ for the graph adjacency matrix. The certificate gives a strictly positive integer vector $v$ with $Av\le qv$. The number of paths of length $k$ is at most $q^k (\sum_i v_i)/(\min_i v_i)$, and every physical word of length $k+r$ gives such a path. At $r=14$ the upper multiplier is $2302160961809/10^{12}$. It was checked against every edge using integer arithmetic. The same weights give $Av\ge(2302160961808/10^{12})v$, placing this finite graph's own growth factor in an interval of width $10^{-12}$. Adjacent short words can have incompatible physical witnesses. The lower endpoint and cycles of this graph therefore provide no lower bound on the entropy of the physical Rule 30 process.

**Limit.** Increasing $r$ imposes longer physical-word tests, giving nested outer approximations. At each length $r+1$ the outer language is already exact, so its entropy is at most $\log N(r+1)/(r+1)$ by subdivision into disjoint blocks. The right side converges to the entropy of the physical pair shift by subadditivity, and the physical shift lies in every outer approximation. This proves convergence of the finite-graph entropy from above. It gives no rate of convergence useful at $r=14$. The separate spatial strip certificate in this work block gives a stronger finite upper bound. [Counts and the pair-entropy identity](count-pairs.md)

**Reproduction.** Compile with `g++ -O3 -std=c++17 -fopenmp count-overlap.cpp -o count-overlap`. The number 160 in the first command specifies the number of iterations for finding the integer weights. The final componentwise check proves the bound regardless of iteration count. A separate Python verifier reconstructs every edge using the sideways recurrence, independently of the graph builder’s three-valued cones. It accepts the stated numerator and rejects it when reduced by one. [Independent integer verifier](count-overlap-check.py)

```text
count-overlap 14 160 overlap14-certificate.tsv
python count-overlap-check.py 14 2302160961809 1000000000000 overlap14-certificate.tsv
```
