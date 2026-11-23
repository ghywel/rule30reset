#!/usr/bin/env python3
"""claudeM5_observer_lift.py (ledger M144): the 48-sample observer, the unique 47-sample exception and the two exit rules
of I172-I181, redone with no SAT solver and none of gptIntel's code.

A window is columns 1..W at a sample (a white tick of the alternating column), bit i = column i + 1. A double step takes
two free bits, the cell beyond the strip at each tick; every right half follows one of the four.

  lift N WMAX     N layers. Layer t holds the windows outside the trap at which none of the five words starts that would end
                  by sample N - 1 (read from sixteen columns, which fix seven samples). Sweep forward (keep what the layer
                  before reaches), backward (keep what reaches the layer after), add a column, repeat. A right half whose N
                  samples are clean and whose last window is outside the trap survives every sweep. Empty: there is none.
                  When few are left, prints the words that the surviving paths read.
  first N WMAX    the same for N clean samples when one more sample came before them and is not read (I190)
  exit            the gap words 3^7 5 3 (no right half reads it) and 3^8 5 5 (read only into the trap), by the exact set of
                  windows at each width after each gap, from every black window.
  word GAPS K WMAX [free]   the gap word GAPS repeated K times, from a black sample, two-way sweeps as in lift; every window
                  outside the trap, or with no trap condition ("free")
  rows            the finite rows of I174 and I181, replayed cell by cell.

    python3 claudeM5_observer_lift.py TRAPCODES MODE ...
"""
import sys
import numpy as np

CODES = np.zeros(1 << 16, bool)
CODES[[int(x) for x in open(sys.argv[1]).read().split()]] = True
WORDS = ['00000', '11', '101', '10001', '1001001']


def MASK(W):
    return np.uint64((1 << W) - 1)


def step(w, a, b, W):
    m = MASK(W)
    y = (((w << np.uint64(1))) ^ (w | (w >> np.uint64(1)) | np.uint64(a << (W - 1)))) & m
    return (((y << np.uint64(1)) | np.uint64(1)) ^ (y | (y >> np.uint64(1)) | np.uint64(b << (W - 1)))) & m


def succ(w, W):
    return [step(w, a, b, W) for a in (0, 1) for b in (0, 1)]


def has(sorted_arr, x):
    if len(sorted_arr) == 0:
        return np.zeros(len(x), bool)
    p = np.searchsorted(sorted_arr, x)
    p[p == len(sorted_arr)] = 0
    return sorted_arr[p] == x


def base(N):
    w = np.arange(1 << 16, dtype=np.uint64)
    bits = [w & np.uint64(1)]
    v = w
    for _ in range(6):                        # the sample j steps on is fixed by 1 + 2 j <= 13 columns
        v = step(v, 0, 0, 16)
        bits.append(v & np.uint64(1))
    starts = {}
    for p in WORDS:
        ok = np.ones(len(w), bool)
        for j, c in enumerate(p):
            ok &= bits[j] == int(c)
        starts[p] = ok
    out = []
    for t in range(N):
        keep = ~CODES.copy()
        for p in WORDS:
            if t + len(p) <= N:
                keep &= ~starts[p]
        out.append(w[keep])
    return out


def sweeps(L, W):
    N = len(L)
    for t in range(1, N):
        reach = np.unique(np.concatenate(succ(L[t - 1], W))) if len(L[t - 1]) else np.zeros(0, np.uint64)
        L[t] = L[t][has(reach, L[t])]
    fwd = [len(x) for x in L]
    for t in range(N - 2, -1, -1):
        ok = np.zeros(len(L[t]), bool)
        for s in succ(L[t], W):
            ok |= has(L[t + 1], s)
        L[t] = L[t][ok]
    return fwd


def words(L, W, cap=200000):
    """the gate words of the paths through the layers"""
    cur = {int(x): {''} for x in L[0]}
    for t in range(len(L)):
        nxt = {}
        for x, ws in cur.items():
            ws = {w + str(x & 1) for w in ws}
            if t + 1 == len(L):
                nxt.setdefault('end', set()).update(ws)
                continue
            a = np.array([x], dtype=np.uint64)
            for s in {int(y[0]) for y in succ(a, W)}:
                if has(L[t + 1], np.array([s], dtype=np.uint64))[0]:
                    nxt.setdefault(s, set()).update(ws)
        cur = nxt
        if sum(len(v) for v in cur.values()) > cap:
            return None
    return sorted(cur.get('end', set()))


def lift(N, WM):
    L = base(N)
    for W in range(16, WM + 1):
        if W > 16:
            L = [np.unique(np.concatenate([x, x + np.uint64(1 << (W - 1))])) for x in L]
        start = len(L[0])
        fwd = sweeps(L, W)
        tot = sum(len(x) for x in L)
        print(f'N={N} W={W}: first layer {start}, last layer after the forward sweep {fwd[-1]}, left after both {tot}', flush=True)
        if tot == 0:
            print(f'N={N}: no right half has {N} clean samples and an outside last window (empty at width {W})')
            return
        if W >= 24 and tot < 40000:
            ws = words(L, W)
            if ws is not None and len(ws) <= 12:
                print('   words still read:', ws, flush=True)


def lift_after_first(N, WM):
    """N clean samples at 1..N of a right half whose sample 0 exists and is not read; last window outside"""
    b = base(N)
    L = [np.arange(1 << 16, dtype=np.uint64)[~CODES]] + b
    for W in range(16, WM + 1):
        if W > 16:
            L = [np.unique(np.concatenate([x, x + np.uint64(1 << (W - 1))])) for x in L]
        sweeps(L, W)
        tot = sum(len(x) for x in L)
        if W % 4 == 0 or tot == 0:
            print(f'{N} clean samples after one unread sample, W={W}: left after both {tot}', flush=True)
        if tot == 0:
            return
        if W >= 27 and tot < 40000:
            ws = words(L, W)
            if ws is not None and len(ws) <= 6:
                print('   words still read (first letter not observed):', ws, flush=True)


def after(S, W, gap, trap_free):
    """windows reached from the black windows S after exactly this gap, white in between"""
    cur = S
    for s in range(1, gap + 1):
        cur = np.unique(np.concatenate(succ(cur, W)))
        if trap_free:
            cur = cur[~CODES[(cur & np.uint64(0xFFFF)).astype(np.int64)]]
        black = (cur & np.uint64(1)) == 1
        cur = cur[black] if s == gap else cur[~black]
    return cur


def exits():
    for name, word, outside in (('3^7 5 3, any right half', [3] * 7 + [5, 3], False), ('3^8 5 5 ending outside', [3] * 8 + [5, 5], True)):
        for W in range(16, 25):
            S = np.arange(1, 1 << W, 2, dtype=np.uint64)
            if outside:
                S = S[~CODES[(S & np.uint64(0xFFFF)).astype(np.int64)]]
            sizes = [len(S)]
            for g in word:
                S = after(S, W, g, outside)
                sizes.append(len(S))
            print(f'{name}: width {W}: {sizes}', flush=True)
            if len(S) == 0:
                break


def rows():
    def run(x, n):
        out = []
        for t in range(2 * n):
            x = ((x << 1) | (1 if t % 2 == 0 else 0)) ^ (x | (x >> 1))
            if t % 2 == 0:
                out.append(x)
        return out
    E = '00001001000010010000100001000010000100100001000'
    a = run(0xa224d3200017fb5ccd115f23a59, 60)
    print('outside row reads the word at samples 0..46:', ''.join(str(x & 1) for x in a[:47]) == E, '| window 46 code', a[46] & 0xFFFF, 'inside', bool(CODES[a[46] & 0xFFFF]), '| first inside', next(i for i, x in enumerate(a) if CODES[x & 0xFFFF]))
    b = run(0x4319fc9fcd612848b70077729985e4b9, 70)
    print('inside row: inside at 0', bool(CODES[b[0] & 0xFFFF]), '| reads the word at 10..56:', ''.join(str(x & 1) for x in b[10:57]) == E)
    c = run(0x7fffff80fc, 120)
    g = ''.join(str(x & 1) for x in c)
    clean = lambda s: not any(w in s for w in WORDS)
    print('0x7fffff80fc: inside at 0', bool(CODES[c[0] & 0xFFFF]), '| gate', g[:12], '| first clean 48 ends at', next(t for t in range(47, 120) if clean(g[t - 47:t + 1])), '| first clean 47 other than the exception ends at', next(t for t in range(46, 120) if clean(g[t - 46:t + 1]) and g[t - 46:t + 1] != E))


def word(gaps, K, WM, outside):
    bits = '1' + ''.join('0' * (int(g) - 1) + '1' for g in gaps * K)
    w = np.arange(1 << 16, dtype=np.uint64)
    L = [w[((w & np.uint64(1)) == int(b)) & (~CODES if outside else True)] for b in bits]
    for W in range(16, WM + 1):
        if W > 16:
            L = [np.unique(np.concatenate([x, x + np.uint64(1 << (W - 1))])) for x in L]
        sweeps(L, W)
        tot = sum(len(x) for x in L)
        if W % 4 == 0 or tot == 0:
            print(f'({gaps})^{K} {"outside" if outside else "free"}, {len(bits)} samples, W={W}: left after both {tot}', flush=True)
        if tot == 0:
            return


mode = sys.argv[2]
if mode == 'word':
    word(sys.argv[3], int(sys.argv[4]), int(sys.argv[5]), len(sys.argv) < 7)
elif mode == 'lift':
    lift(int(sys.argv[3]), int(sys.argv[4]))
elif mode == 'first':
    lift_after_first(int(sys.argv[3]), int(sys.argv[4]))
elif mode == 'exit':
    exits()
else:
    rows()
