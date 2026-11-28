# A finite-time bound for ten cells with two prescribed drivers

**Paper proof.** Fix any time-dependent values of the two outer drivers. Of the 1,024 possible starts on the next ten inward cells, at most **27 distinct words** remain after **22,528 ticks**. The drivers may be different on every tick. The bound concerns distinct images. Several starts can still share one image.

In coordinates following the growing outer edge, the cell update is

```text
a_i(t+1) = a_{i-2}(t) XOR (a_{i-1}(t) OR a_i(t)).
```

Index the block from its exterior toward the wall. All ten cells share the same two prescribed columns at indices −2 and −1. Start with any set of words. For a general block length B, let S_j(t) be the set of their outermost j-bit prefixes at tick t, including the empty prefix for j=0. The prefix evolves from itself and the common drivers, so each time step maps S_j(t) onto S_j(t+1). The sum of the prefix counts is nonincreasing and at most 2^(B+1)−1 initially.

Divide the first (B+1)·2^(B+1) ticks into 2^(B+1) disjoint intervals of B+1 transitions. At least one interval contains no drop in any prefix count. Within it, all prefix maps are bijective. Write u for its starting tick and use times 0 through B+1 relative to u in the argument below.

At time 0 make a binary tree of the attainable prefixes. If a prefix ending at i has both children, its two (i+2)-bit extensions differ at just the appended cell. They must stay distinct throughout the interval, and the shallower cells stay identical for both extensions. Consequently their common cell i must be white throughout times 0 through B. A black tick there would reset the appended cell to the same value in both children.

Fix one path whose first black bit at time 0 is at q. Two fork parents at positions i and i+k with q<i cannot have k equal to 1, 2 or 3.

- If k=1, both columns are white through B. The update at the second column forces the column immediately before the pair white through B−1. Repeat toward q, losing one tick at each step. This forces q white at time 0.
- If k=2, the update at i+2 reads the OR of the middle cell and itself, since i is white. The middle cell must be white through B−1. The adjacent-pair argument applies.
- If k=3, write x and y for the two middle columns. At i+3, white at the next tick forces x=y through B−1. At i+2 the update is y'=x OR y, since i is white. Thus x and y are constant through B−1. The recurrence at i+1 then forces i−1 white through B−2. The adjacent pair at i−1 and i propagates to q. In all three cases the propagation fits inside the interval since both fork children lie in the B-cell block.

The first child after q cannot fork, since q is black at time 0. If h cells remain after q, possible fork positions therefore lie in h−1 places and are at least four apart. A path has at most ceil(max(0,h−1)/4) forks. A finite binary tree with at most k forks on any path has at most 2^k leaves, by induction at the first fork. Partition by the first black position at time 0 and include the one possible all-white word. For B=10 the ten contributions, in increasing h, are 1,1,2,2,2,2,4,4,4,4. Their sum plus one is 27. Later deterministic steps can only reduce the number of words. This proves the claimed bound for arbitrary drivers and starting sets.

## Application to the physical width

With a fixed exterior word u its evolution is autonomous. Its two innermost cells supply a common driver for the ten new cells, and the whole exterior has the same final value for all continuations. Hence the paper lemma gives `OneBlock 10 22528 27`. Iterating m times yields at most 27^m possible outer words of length 10m at every physical age at least 22,538m. The iteration and transfer from the moving frame to the physical row are kernel-checked for arbitrary block size, time and bound. [BlockCover.lean](BlockCover.lean)

For a fixed immortal of initial width b, the descendant of matching exact width W has age W−b. Put m=floor(W/22540). Once 2m≥b, this age is at least 22,538m. For each allowed outer word, at most 2^floor((W−10m)/2) choices of the remaining inner cells pass their own pre-support even checks. Additional checks can only decrease the count. The number of width-W candidates satisfying the outer condition and all even checks before tick W is therefore at most

```text
27^m · 2^floor((W−10m)/2) = 2^floor(W/2) · (27/32)^m.
```

This bound saves an exponential factor against the kit’s 2^floor(W/2) bound for pinned starts up to width W. Its right-hand side still grows exponentially. The argument gives no bound on how long the remaining rows pass checks after the support. The ten-cell lemma above is independently reasoned through, but its prefix-tree argument has not been formalized in Lean. The three-cell theorem in the main report gives a fully kernel-checked alternative with a weaker asymptotic saving.
