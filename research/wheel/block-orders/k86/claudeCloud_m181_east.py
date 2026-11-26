#!/usr/bin/env python3
"""claudeCloud_m181_east.py: exact eastward enumeration of time-periodic strips beside the alternating column
(ledger K86, a development probe).  It lists, width by width, every strip all of whose columns have the gate's time
period (times q), column W + 1 free.  The wall is white at even ticks; the gate is column 1 at the even ticks.
Columns are N-bit integers, bit t = tick t.  A pair (u, v) of neighbours can be continued iff v(t) = 1 implies
v(t+1) = not u(t); the next column w is forced where v is white, w(t) = v(t+1) xor u(t), and free where v is black.

    python3 claudeCloud_m181_east.py GAPS Q [MAXWIDTH]      e.g.  3555 1 200
Prints the width and the number of strips of that width; stops above two million."""
import sys
def gate_bits(gaps, q):
    g=[]; 
    for _ in range(q):
        for d in gaps:
            g.append(1); g += [0]*(d-1)
    return g
def children(u, v, N, MASK):
    v1 = ((v >> 1) | (v << (N-1))) & MASK          # v1(t) = v(t+1)
    forced = ~v & MASK
    fv = (v1 ^ u) & forced                          # forced values
    # positions
    res = []
    # per-position state: -1 free, 0/1 forced
    val = [(-1 if (v >> t) & 1 else (fv >> t) & 1) for t in range(N)]
    nv = [1 - ((v >> t) & 1) for t in range(N)]    # required w(t+1) when w(t)=1
    # propagate mandatory assignments
    changed = True
    while changed:
        changed = False
        for t in range(N):
            if val[t] == 1:
                n = (t + 1) % N
                if val[n] == -1:
                    val[n] = nv[t]; changed = True
                elif val[n] != nv[t]:
                    return []
    # remaining free: w(t)=1 requires w(t+1) == nv[t] (=0 since v(t)=1 at free t)
    free = [t for t in range(N) if val[t] == -1]
    # backtracking over free positions in decreasing t so successor is decided first (cyclic care)
    out = []
    def rec(i, val):
        if i == len(free):
            # verify fully
            w = 0
            for t in range(N):
                if val[t]: w |= 1 << t
            w1 = ((w >> 1) | (w << (N-1))) & MASK
            if w & ~(w1 ^ v) & MASK: return
            out.append(w); return
        t = free[i]
        for b in (0, 1):
            val[t] = b
            ok = True
            if b == 1:
                n = (t + 1) % N
                if val[n] != -1 and val[n] != nv[t]: ok = False
            p = (t - 1) % N
            if ok and val[p] == 1 and nv[p] != b: ok = False
            if ok: rec(i + 1, val)
        val[t] = -1
    rec(0, val)
    return out
def main():
    gaps = [int(c) for c in sys.argv[1]]; q = int(sys.argv[2]); maxw = int(sys.argv[3]) if len(sys.argv) > 3 else 400
    g = gate_bits(gaps, q); N = 2 * len(g); MASK = (1 << N) - 1
    a = sum(1 << t for t in range(1, N, 2))
    # column 1 candidates: b(2s)=g(s); b(2s+1) free subject to validity with a
    level = []
    def recb(s, b):
        if s == len(g):
            b1 = ((b >> 1) | (b << (N-1))) & MASK
            # validity: b(t)=1 => b(t+1) = not a(t)
            if b & ~(b1 ^ a) & MASK: return
            level.append((a, b)); return
        if g[s]:
            recb(s + 1, b | (1 << (2*s)) | (1 << (2*s+1)))
        else:
            recb(s + 1, b)
            if not g[(s + 1) % len(g)]:
                recb(s + 1, b | (1 << (2*s+1)))
    recb(0, 0)
    print("N", N, "level1", len(level), flush=True)
    wdt = 1
    while level and wdt < maxw:
        nxt = []
        for (u, v) in level:
            for w in children(u, v, N, MASK):
                nxt.append((v, w))
        wdt += 1
        level = nxt
        print(wdt, len(level), flush=True)
        if len(level) > 2_000_000: print("too many"); break
main()
