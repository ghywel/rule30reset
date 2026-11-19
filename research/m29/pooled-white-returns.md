# Pooled first returns at a fixed temporal clock

Fix a positive integer Q and a time origin. A word is a binary function on
the Q labelled ticks, extended periodically. Include every nonzero word c
once as the first wheel after a white wheel. Words of smaller least period
are included. Rotations count separately exactly when their pointed words
differ. There are N − 1 choices, where N = 2^Q.

Start D₀ = 0, D₁ = c and continue until the first positive index g(c) with
D_g = 0. Inside the excursion the rule is

    D_{j+2}(t+1) = D_j(t) XOR (D_{j+1}(t) OR D_{j+2}(t)).

A black tick in D_{j+1} forces the next bit of its child. Continuing around
the clock gives existence and uniqueness of that periodic child (kit
`child_exists` and `child_unique`). If there were no first return, this
would construct an infinite rooted chain at clock Q. The kit's
`rooted_chain_returns_bounded` would give a positive white index in that
same chain. Thus the excursion always terminates. The construction stops at
the white even if a subsequent wheel would require a doubled clock.

**Theorem (I2, carrying read K7 §3).** The sum of g(c) over this ensemble
is at most (N − 1)(N + 1). Its arithmetic mean is at most N + 1.

For each c mark the g(c) consecutive pairs (D_j,D_{j+1}) with
0 ≤ j < g(c), including the last pair whose second wheel is white.
These pairs are distinct over all choices of c and j. Indeed, from (B,C)
the preceding wheel is recovered as A(t) = C(t+1) XOR (B(t) OR C(t)).
Given two equal marks, walk both back until the earlier index is zero.
The other must then also be zero, since a positive first coordinate before
the return is nonwhite. The second coordinates at index zero give the same
pointed c. Every mark avoids (0,0), including the initial and terminal ones.
The ambient space has N² pairs, so the number of marks is at most N² − 1.

This is a count over complete excursions from all pointed first children
at one clock. It gives no estimate on the frequency of resets along a
particular orbit. The backwards rule is the kit's `child_parent_unique`
and is credited to Quint's backward recovery in PRIOR-ART P10.
