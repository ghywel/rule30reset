"""K92.4, claudeM5 (M234): certificates for the modulus-two strip theorem, in LagCert's formats (lag_final,
ev_final, prod_final; the earlier lag_cert functions are the development versions).

Graph: a strip of w cells (bit 0 west), both exterior cells free, nodes n = p * 2^w + s for the tick parity p, an
edge only when every falling cell is permitted at p. Ranks are heights in the condensation, so a step never raises
the rank and keeps it only inside one strongly connected component. A nontrivial component gets a class: its
period d (breadth-first levels), a pair constant on each cyclic class, and that pair's reading at each position.
Every certificate is checked here, by simulating the Lean checker, before it is written.
"""
import sys
from math import gcd

M = 2

def step(w, zw, ze, s):
    return ((((s << 1) | zw) ^ (s | (s >> 1) | (ze << (w - 1)))) % (1 << w))

def permit(a, p):
    return sum(1 << j for j, x in enumerate(a) if x == p)

def graph(a):
    w = len(a); N = 1 << w
    succ = [[] for _ in range(M * N)]
    for p in range(M):
        pm = permit(a, p)
        for s in range(N):
            u = p * N + s
            for zw in (0, 1):
                for ze in (0, 1):
                    d = step(w, zw, ze, s)
                    fall = s & ~d
                    if fall & ~pm: continue
                    succ[u].append(((p + 1) % M) * N + d)
    return succ

def scc(succ):
    n = len(succ); index = [-1]*n; low = [0]*n; on = [False]*n; st = []; comp = [-1]*n; nc = 0; cnt = 0
    for s0 in range(n):
        if index[s0] != -1: continue
        stack = [(s0, 0)]; index[s0] = low[s0] = cnt; cnt += 1; st.append(s0); on[s0] = True
        while stack:
            v, i = stack[-1]
            if i < len(succ[v]):
                stack[-1] = (v, i + 1); w = succ[v][i]
                if index[w] == -1:
                    index[w] = low[w] = cnt; cnt += 1; st.append(w); on[w] = True; stack.append((w, 0))
                elif on[w]: low[v] = min(low[v], index[w])
            else:
                stack.pop()
                if low[v] == index[v]:
                    while True:
                        x = st.pop(); on[x] = False; comp[x] = nc
                        if x == v: break
                    nc += 1
                if stack:
                    u = stack[-1][0]; low[u] = min(low[u], low[v])
    return comp, nc

def heights(succ, comp, nc):
    # Tarjan numbers components in reverse topological order: successors' components come first.
    members = [[] for _ in range(nc)]
    for v, c in enumerate(comp): members[c].append(v)
    h = [0]*nc
    for c in range(nc):
        best = 0
        for v in members[c]:
            for w in succ[v]:
                if comp[w] != c: best = max(best, h[comp[w]] + 1)
        h[c] = best
    return h, members

def classes_for(succ, comp, nc, members, width, need_rigid=True):
    """Per nontrivial component: (period, levels, pair, word) or None if no rigid pair."""
    out = {}
    for c in range(nc):
        mem = members[c]
        nontriv = len(mem) > 1 or any(w == mem[0] for w in succ[mem[0]])
        if not nontriv: continue
        lev = {mem[0]: 0}; q = [mem[0]]; g = 0
        for v in q:
            for w in succ[v]:
                if comp[w] != c: continue
                if w not in lev: lev[w] = lev[v] + 1; q.append(w)
                else: g = gcd(g, abs(lev[v] + 1 - lev[w]))
        d = g
        found = None
        if need_rigid:
            for j in range(width - 1):
                word = [-1]*d; ok = True
                for v in mem:
                    s = v % (1 << width)  # caller passes node -> state via width; product overrides
                    rd = (s >> j) & 3; k = lev[v] % d
                    if word[k] == -1: word[k] = rd
                    elif word[k] != rd: ok = False; break
                if ok: found = (j, [x if x >= 0 else 0 for x in word]); break
        out[c] = (d, lev, found)
    return out

def bits(x):
    return max(1, x.bit_length())

def pack(fields, width):
    v = 0
    for i, f in enumerate(fields):
        assert 0 <= f < (1 << width), (f, width)
        v |= f << (width * i)
    return v

def class_record(j, d, word):
    assert j < 32 and 0 < d < 32 and len(word) == d
    q = j | (d << 5)
    for i, x in enumerate(word): q |= x << (10 + 2*i)
    assert q < (1 << 72)
    return q

def lag_cert(a):
    """Full any-lag table for a certified assignment a. Returns (rb, cb, nodes, classes, info)."""
    w = len(a); succ = graph(a); comp, nc = scc(succ); h, members = heights(succ, comp, nc)
    cl = classes_for(succ, comp, nc, members, w)
    ids = {}; recs = [0]
    for c, (d, lev, found) in sorted(cl.items()):
        if found is None: raise ValueError('component without a rigid pair: not certified')
        ids[c] = len(recs); recs.append(class_record(found[0], d, found[1]))
    rb = bits(max(h)); cb = bits(len(recs) - 1)
    rec = []
    for v in range(len(succ)):
        c = comp[v]
        if c in ids:
            d, lev, _ = cl[c]; rec.append(h[c] | (ids[c] << rb) | ((lev[v] % d) << (rb + cb)))
        else:
            rec.append(h[c])
    nb = rb + cb + 5
    nodes = pack(rec, nb); classes = pack(recs, 72)
    simulate_lag(a, rb, cb, nodes, classes)
    return rb, cb, nodes, classes, dict(nodes=len(succ), components=nc, live=len(ids), rb=rb, cb=cb)

def field(P, b, i): return (P >> (b*i)) % (1 << b)
def rk(rb, r): return r % (1 << rb)
def clf(rb, cb, r): return (r >> rb) % (1 << cb)
def ps(rb, cb, r): return r >> (rb + cb)

def node_cond(w, rb, cb, classes, r, s):
    c = clf(rb, cb, r); pi = ps(rb, cb, r); q = field(classes, 72, c)
    if c == 0: return True
    j = q % 32; d = (q >> 5) % 32
    return j + 1 < w and pi < d and ((s >> j) % 4) == ((q >> (10 + 2*pi)) % 4)

def edge_cond(rb, cb, classes, r, r2):
    if not rk(rb, r2) <= rk(rb, r): return False
    if rk(rb, r2) != rk(rb, r): return True
    c = clf(rb, cb, r); q = field(classes, 72, c); d = (q >> 5) % 32
    return c != 0 and clf(rb, cb, r2) == c and d > 0 and ps(rb, cb, r2) == (ps(rb, cb, r) + 1) % d

def simulate_lag(a, rb, cb, nodes, classes):
    w = len(a); N = 1 << w; nb = rb + cb + 5
    for p in range(M):
        pm = permit(a, p)
        for s in range(N):
            r = field(nodes, nb, p*N + s)
            assert node_cond(w, rb, cb, classes, r, s), ('node', p, s)
            for zw in (0, 1):
                for ze in (0, 1):
                    d = step(w, zw, ze, s)
                    f = s & (s ^ d)
                    if (f & pm) != f: continue
                    r2 = field(nodes, nb, ((p+1) % M)*N + d)
                    assert edge_cond(rb, cb, classes, r, r2), ('edge', p, s, d)

if __name__ == '__main__':
    for pat in sys.argv[1:]:
        a = [int(c) for c in pat]
        rb, cb, nodes, classes, info = lag_cert(a)
        print(pat, info, 'node bits', (rb+cb+5) * info['nodes'], 'classes bits', classes.bit_length())

def pages_tree(records, nb, pg):
    """Lean term for a Tbl holding the records in pages of 2^pg, page index bits lowest first."""
    size = 1 << pg
    n = len(records)
    L = 1
    while L * size < n: L *= 2
    pages = []
    for i in range(L):
        chunk = records[i*size:(i+1)*size]
        pages.append(pack(chunk, nb) if chunk else 0)
    def build(ps):
        if len(ps) == 1: return f'(Tbl.leaf {hex(ps[0])})'
        return f'(Tbl.node {build(ps[0::2])} {build(ps[1::2])})'
    return build(pages)

def tget_py(records, nb, pg, n):
    return records[n] if n < len(records) else 0

def lag_cert_records(a):
    w = len(a); succ = graph(a); comp, nc = scc(succ); h, members = heights(succ, comp, nc)
    cl = classes_for(succ, comp, nc, members, w)
    ids = {}; recs = [0]
    for c, (d, lev, found) in sorted(cl.items()):
        if found is None: raise ValueError('component without a rigid pair: not certified')
        ids[c] = len(recs); recs.append(class_record(found[0], d, found[1]))
    rb = bits(max(h)); cb = bits(len(recs) - 1)
    rec = []
    for v in range(len(succ)):
        c = comp[v]
        if c in ids:
            d, lev, _ = cl[c]; rec.append(h[c] | (ids[c] << rb) | ((lev[v] % d) << (rb + cb)))
        else:
            rec.append(h[c])
    nb = rb + cb + 5
    simulate_lag(a, rb, cb, pack(rec, nb), pack(recs, 72))
    return rb, cb, rec, pack(recs, 72)

def lag_lean(name, a, pg=6):
    rb, cb, rec, classes = lag_cert_records(a)
    nb = rb + cb + 5
    pg = min(pg, len(a) + 1)
    tree = pages_tree(rec, nb, pg)
    lab = ', '.join(str(x) for x in a)
    return f'def {name} : LagCert := ⟨[{lab}], {rb}, {cb}, {pg}, {tree}, {hex(classes)}⟩'

# ---- final formats (flat tables, permit masks as data) -------------------------------------------------------------
def perms_of(a):
    return pack([permit(a, p) for p in range(M)], len(a))

def components(succ, state_of, width):
    comp, nc = scc(succ); h, members = heights(succ, comp, nc)
    info = {}
    for c in range(nc):
        mem = members[c]
        if not (len(mem) > 1 or any(w == mem[0] for w in succ[mem[0]])): continue
        lev = {mem[0]: 0}; q = [mem[0]]; g = 0
        for v in q:
            for w in succ[v]:
                if comp[w] != c: continue
                if w not in lev: lev[w] = lev[v] + 1; q.append(w)
                else: g = gcd(g, abs(lev[v] + 1 - lev[w]))
        found = None
        for j in range(width - 1):
            word = [-1]*g; ok = True
            for v in mem:
                rd = (state_of(v) >> j) & 3; k = lev[v] % g
                if word[k] == -1: word[k] = rd
                elif word[k] != rd: ok = False; break
            if ok: found = (j, word); break
        info[c] = (g, lev, found)
    return comp, h, info

def lag_records(succ, state_of, width):
    comp, h, info = components(succ, state_of, width)
    ids = {}; recs = [0]
    for c, (d, lev, found) in sorted(info.items()):
        if found is None: raise ValueError('component without a rigid pair: not certified')
        ids[c] = len(recs); recs.append(class_record(found[0], d, found[1]))
    rb = bits(max(h)); cb = bits(len(recs) - 1)
    rec = []
    for v in range(len(succ)):
        c = comp[v]
        if c in ids:
            d, lev, _ = info[c]; rec.append(h[c] | (ids[c] << rb) | ((lev[v] % d) << (rb + cb)))
        else: rec.append(h[c])
    return rb, cb, rec, pack(recs, 72)

def lag_final(a):
    w = len(a); succ = graph(a)
    rb, cb, rec, classes = lag_records(succ, lambda v: v % (1 << w), w)
    nodes = pack(rec, rb + cb + 5)
    simulate_lag(a, rb, cb, nodes, classes)
    return dict(labels=a, rb=rb, cb=cb, perms=perms_of(a), nodes=nodes, classes=classes, size=len(succ))

def ev_final(b):
    w = len(b); succ = graph(b); comp, nc = scc(succ); h, members = heights(succ, comp, nc)
    live = [False]*len(succ)
    for c in range(nc):
        mem = members[c]
        if len(mem) > 1 or any(x == mem[0] for x in succ[mem[0]]):
            for v in mem: live[v] = True
    rb = bits(max(h))
    rec = [h[comp[v]] | ((1 if live[v] else 0) << rb) for v in range(len(succ))]
    nodes = pack(rec, rb + 1)
    # simulate checkEv
    N = 1 << w
    for p in range(M):
        pm = permit(b, p)
        for s in range(N):
            r = rec[p*N + s]
            for d in set(step(w, zw, ze, s) for zw in (0,1) for ze in (0,1)):
                f = s & (s ^ d)
                if (f & pm) != f: continue
                r2 = rec[((p+1) % M)*N + d]
                assert (r2 % (1 << rb)) <= (r % (1 << rb))
                if (r2 % (1 << rb)) == (r % (1 << rb)): assert (r >> rb) == 1 and (r2 >> rb) == 1
    return dict(labels=b, rb=rb, perms=perms_of(b), nodes=nodes, live=live, size=len(succ))

def prod_final(a, wa):
    w = len(a); wb = w - wa
    A = ev_final(a[:wa]); B = ev_final(a[wa:])
    NA, NB = 1 << wa, 1 << wb
    EA = [n for n in range(M*NA) if A['live'][n]]
    EB = [n for n in range(M*NB) if B['live'][n]]
    IA = {n: i for i, n in enumerate(EA)}; IB = {n: k for k, n in enumerate(EB)}
    na, nb = len(EA), len(EB)
    # C graph over indices c = i * nb + k (only phase-matched pairs get edges)
    succ = [[] for _ in range(na*nb)]
    state = [0]*(na*nb)
    for i, eA in enumerate(EA):
        for k, eB in enumerate(EB):
            pA, sA = divmod(eA, NA); pB, sB = divmod(eB, NB)
            if pA != pB: continue
            p = pA; s = sA + sB * NA; c = i*nb + k; state[c] = s
            pm = permit(a, p)
            for d in set(step(w, zw, ze, s) for zw in (0,1) for ze in (0,1)):
                f = s & (s ^ d)
                if (f & pm) != f: continue
                q = (p + 1) % M
                nA = q*NA + d % NA; nB = q*NB + d // NA
                if A['live'][nA] and B['live'][nB]:
                    succ[c].append(IA[nA]*nb + IB[nB])
    rb, cb, rec, classes = lag_records(succ, lambda v: state[v], w)
    nw = max(wa, wb) + 1
    xb = bits(max(na, nb))
    ia = pack([IA.get(n, 0) for n in range(M*NA)], xb)
    ib = pack([IB.get(n, 0) for n in range(M*NB)], xb)
    P = dict(labels=a, wa=wa, rb=rb, cb=cb, perms=perms_of(a), nw=nw, xb=xb, ea=pack(EA, nw), na=na, ia=ia,
             eb=pack(EB, nw), nb=nb, ib=ib, nodes=pack(rec, rb+cb+5), classes=classes, size=na*nb)
    # simulate the product loop
    nbits = rb + cb + 5
    for i in range(na):
        for k in range(nb):
            eA, eB = EA[i], EB[k]; p = eA // NA
            if p != eB // NB or p >= M: continue
            s = eA % NA + (eB % NB) * NA; r = rec[i*nb + k]; pm = permit(a, p)
            assert node_cond(w, rb, cb, classes, r, s)
            for zw in (0,1):
                for ze in (0,1):
                    d = step(w, zw, ze, s); f = s & (s ^ d)
                    if (f & pm) != f: continue
                    q = (p+1) % M; nA = q*NA + d % NA; nB = q*NB + d // NA
                    if not (A['live'][nA] and B['live'][nB]): continue
                    assert edge_cond(rb, cb, classes, r, rec[IA[nA]*nb + IB[nB]])
    return A, B, P

def lean_list(a): return '[' + ', '.join(str(x) for x in a) + ']'
def lean_lag(name, L): return f"def {name} : LagCert := ⟨{lean_list(L['labels'])}, {L['rb']}, {L['cb']}, {hex(L['perms'])}, {hex(L['nodes'])}, {hex(L['classes'])}⟩"
def lean_ev(name, E): return f"def {name} : EvCert := ⟨{lean_list(E['labels'])}, {E['rb']}, {hex(E['perms'])}, {hex(E['nodes'])}⟩"
def lean_prod(name, P):
    f = ['labels','wa','rb','cb','perms','nw','xb','ea','na','ia','eb','nb','ib','nodes','classes']
    vals = [lean_list(P['labels']) if k == 'labels' else (hex(P[k]) if isinstance(P[k], int) and P[k] > 9 else str(P[k])) for k in f]
    return f"def {name} : ProdCert := ⟨{', '.join(vals)}⟩"
