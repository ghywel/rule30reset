# Carrying read of the two reformulations in K8 §5

**Finite intersection.** Fix one compatible strip and take its full phase
space, the inverse limit of its finite periodic phase sets. A phase can be
a coherent choice of residues without being an ordinary nonnegative tick.
For consecutive white wheels let Bad_i be the phases with no closed run
of length 1 mod 3 between them, allowing either delimiting zero to be the
white endpoint. A following free symbol towards the edge is available
when these intervals are sufficiently deep. Bad_i is clopen since a finite
band decides it. A black run cannot pass through a white. Thus infinitely
many resets in each phase is equivalent to an empty intersection of Bad_i
over each infinite tail of intervals, assuming the white sequence is
unbounded. Compactness makes this equivalent to some finite consecutive
subintersection being empty for each starting interval. Infinitely many
individual intervals good in all phases suffice. PASS with inclusive
endpoints and compact phases.

**Preimages.** Write F(x)=4x XOR (2x OR x), with wheel 0 the low bit and
x odd. Reduction modulo 2^w commutes with F. A point is recurrent exactly
when each finite prefix is on a cycle: simultaneous return to a longer
prefix also returns every shorter one. Each such y has exactly one recurrent
predecessor, because its predecessor on each finite cycle is unique and
these predecessors project compatibly.

Fix the output y and scan inward. Given two consecutive unknown parent
bits, the output equation determines the next shallower parent bit.
M39's four-register calculation says that a word collapses all entrances
exactly when it contains a complete reset. With arbitrarily deep resets,
any two global preimages agree below each such reset, hence everywhere.

Conversely choose a fixed cut beyond the last complete reset. The sets of
possible parent pairs at that cut, obtained by starting arbitrarily at
greater depths, decrease with depth and each has at least two elements.
They stabilize on at least two distinct pairs. For each pair the tree of
extensions compatible with y has arbitrarily long branches and finite
branching. Compactness gives an infinite outer extension for each, still
distinct at the same cut. The inward scan is deterministic. It remains to
check that both choices actually reach a legal odd parent at the edge.

Here is a direct low-bit argument valid on **every** recurrent odd strip.
At wheels 0–2 the bits are 1,1,0 by the local recurrence on a periodic
prefix. Wheel 3 alternates; wheel 4 latches black. Wheel 5 then agrees
with wheel 3. The update for wheel 6 is the complement of (5 OR 6);
it is zero following every black 5 and one at the intervening phase.
Thus 6 agrees with 3 as well. Wheel 7 is reset to zero following every
black 5 and retains zero at the other step. In increasing wheel order the
two phase words at 2–7 are 001000 and 011110. The first contains the
closed run at 3–5 and the second at 2–7. Both have the following free bit
on their shallow side. Make the cut above 7. Both outer extensions then
merge with the true recurrent predecessor before reaching the edge. They
give two distinct odd preimages. One is off the recurrent set since the
recurrent predecessor is unique. PASS on the equivalence; whether every
recurrent point actually has a unique preimage remains open.
