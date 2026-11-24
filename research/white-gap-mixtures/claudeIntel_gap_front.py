"""claudeIntel, N12 (I77).  Front depth N*(v;u): both histories driven by v then u from time 0 with ANY (possibly different) initial rows; at the pulse
between v and u their first N cells agree; second-white sample after u differs.  No width cut-off."""
import subprocess, sys, os, time
CAD = sys.argv.pop(1) if len(sys.argv) > 1 and 'cadical' in sys.argv[1] else 'cadical'      # solver path may be the first argument
def build(v, u, N):
    S0 = sum(g + 1 for g in v); S = S0 + sum(g + 1 for g in u); T = S + 2
    drive = []
    for g in tuple(v) + tuple(u): drive += [1] + [0] * g
    drive += [1, 0, 0]
    nv = [0]; cl = []
    def new(): nv[0] += 1; return nv[0]
    def rule(y, l, c, r):
        if isinstance(l, tuple):
            s = 1 if l[1] == 0 else -1
            cl.append([-c, s*y]); cl.append([-r, s*y]); cl.append([c, r, -s*y])
        else:
            cl.append([-c, y, l]); cl.append([-c, -y, -l]); cl.append([-r, y, l]); cl.append([-r, -y, -l])
            cl.append([c, r, -y, l]); cl.append([c, r, y, -l])
    M = T + 1
    H = []
    for h in (0, 1):
        rows = [new() for _ in range(M)]
        hist = [rows]
        for t in range(T):
            cur = hist[-1]; nx = []
            for i in range(M - t - 1):
                y = new()
                rule(y, ('k', drive[t]) if i == 0 else cur[i-1], cur[i], cur[i+1])
                nx.append(y)
            hist.append(nx)
        H.append(hist)
    A, B = H
    for i in range(N):
        if i < len(A[S0]):
            cl.append([-A[S0][i], B[S0][i]]); cl.append([A[S0][i], -B[S0][i]])
    # consequences of the agreement, given as hints
    for d in range(1, N):
        if S0 + d <= T:
            for i in range(N - d):
                if i < len(A[S0+d]):
                    cl.append([-A[S0+d][i], B[S0+d][i]]); cl.append([A[S0+d][i], -B[S0+d][i]])
    cl.append([A[T][0]]); cl.append([-B[T][0]])
    return nv[0], cl
def solve(v, u, N, conf=400000, tag=''):
    nv, cl = build(v, u, N)
    f = os.path.join('sat', 'r%d%s.cnf' % (os.getpid(), tag))
    with open(f, 'w') as h:
        h.write('p cnf %d %d\n' % (nv, len(cl)))
        h.write('\n'.join(' '.join(map(str, c)) + ' 0' for c in cl) + '\n')
    r = subprocess.run([CAD, '-q', '-n', '-c', str(conf), f], capture_output=True)
    os.remove(f)
    return {10: True, 20: False}.get(r.returncode)
def nstar(v, u, conf=400000, start=8):
    lo = None
    if solve(v, u, 0, conf) is not True: return 'sample fixed'
    lo, hi = 0, None
    N = start
    while True:
        a = solve(v, u, N, conf)
        if a is True: lo = N; N += 6
        else: hi = N; break
    unk = a is None
    while hi - lo > 1:
        m = (lo + hi) // 2
        a = solve(v, u, m, conf)
        if a is True: lo = m
        else:
            hi = m; unk = a is None
    return '%d%s' % (lo, ' (next undecided)' if unk else '')
if __name__ == '__main__':
    for w in sys.argv[1:]:
        a, b = w.split(':')
        v = tuple(int(x) for x in a.split(',')) if a else ()
        u = tuple(int(x) for x in b.split(','))
        t0 = time.time()
        print(v, ':', u, 'N* =', nstar(v, u), round(time.time() - t0, 1), 's', flush=True)
