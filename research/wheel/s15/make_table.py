#!/usr/bin/env python3
"""make_table.py TRAPCODES OUT.json: the table of S15's positive proof (ledger M147, M148; mechanism of S10).

A row is columns 1, 2, ... at a white tick of the alternating column, read as a number (bit i = column i + 1). Eleven time
lines stand one after another in one mask:
  nine factors   a gate word each; every row outside the trap;
  settle         ??????1001001 from a row in the trap;
  white          00000 from any row.
For each line and each width 1, 2, ... the windows that may stand at each time are lifted by one column and swept: backward
(a window with no successor is marked "in": its time is in the mask of every row that extends it), then forward (a window
not reached is marked "out"). The marks make a set of (row, time) closed under the double step and the line's colours:
see the walk `check` in the Lean, which is the proof. Bits below a window that is not alive are constant.
"""
import json, sys
import numpy as np

TRAP = np.zeros(1 << 16, bool)
E0 = np.zeros(0, np.uint64)
FACTORS = [(20, 0x12121), (23, 0x484842), (26, 0x484242), (29, 0x12108421), (30, 0x24210908), (30, 0x24210909),
           (31, 0x10842108), (33, 0x21084842), (38, 0x212108424)]


def word(n, c):
    return ''.join(str((c >> j) & 1) for j in range(n))


def double(x):
    y = (x << np.uint64(1)) ^ (x | (x >> np.uint64(1)))
    return ((y << np.uint64(1)) | np.uint64(1)) ^ (y | (y >> np.uint64(1)))


def successors(w, W):
    return [double(w | np.uint64(e << W)) & np.uint64((1 << W) - 1) for e in range(4)]


def among(a, x):
    if len(a) == 0:
        return np.zeros(len(x), bool)
    p = np.searchsorted(a, x)
    p[p == len(a)] = 0
    return a[p] == x


def marks(pattern, kind):
    n = len(pattern)
    L = [np.array([0, 1] if c == '?' else [int(c)], dtype=np.uint64) for c in pattern]
    for W in range(1, 46):
        if W > 1:
            L = [np.concatenate([x, x + np.uint64(1 << (W - 1))]) for x in L]
        inn = [[] for _ in range(n)]
        if W == 16 and kind != 'free':
            for t in range(n):
                tr = TRAP[L[t].astype(np.int64)]
                if kind == 'outside':
                    inn[t].append(L[t][tr])
                    L[t] = L[t][~tr]
                else:
                    L[t] = L[t][tr]
        for t in range(n - 2, -1, -1):
            ok = np.zeros(len(L[t]), bool)
            for s in successors(L[t], W):
                ok |= among(L[t + 1], s)
            inn[t].append(L[t][~ok])
            L[t] = L[t][ok]
        for t in range(1, n):
            reach = np.unique(np.concatenate(successors(L[t - 1], W))) if len(L[t - 1]) else E0
            L[t] = L[t][among(reach, L[t])]
        yield W, inn, [x.copy() for x in L]
        if sum(len(x) for x in L) == 0:
            return
    raise SystemExit('a line does not die')


def main(codes, out):
    TRAP[[int(x) for x in open(codes).read().split()]] = True
    lines = [(word(n, c), 'outside') for n, c in FACTORS] + [('??????1001001', 'inside'), ('00000', 'free')]
    off, offs, inm, al, white, black, depth = 0, [], {}, {}, 0, 0, 0
    for w, kind in lines:
        offs.append(off)
        for W, inn, L in marks(w, kind):
            for t in range(len(w)):
                b = 1 << (off + t)
                for a in inn[t]:
                    for v in a.tolist():
                        inm[(W, v)] = inm.get((W, v), 0) | b
                for v in L[t].tolist():
                    al[(W, v)] = al.get((W, v), 0) | b
        depth = max(depth, W)
        for t, c in enumerate(w):
            if t:
                white |= (c in '0?') << (off + t)
                black |= (c in '1?') << (off + t)
        off += len(w)
    sys.setrecursionlimit(10000)
    ids, nodes = {}, []

    def mk(key):
        if key not in ids:
            ids[key] = len(nodes)
            nodes.append(key)
        return ids[key]

    def grow(W, v, acc):
        acc |= inm.get((W, v), 0)
        if not al.get((W, v), 0):
            return mk(('L', acc))
        a, b = grow(W + 1, v, acc), grow(W + 1, v + (1 << W), acc)
        return a if a == b and nodes[a][0] == 'L' else mk(('N', a, b))

    root = mk(('N', grow(1, 0, 0), grow(1, 1, 0)))
    leaves = [i for i, k in enumerate(nodes) if k[0] == 'L']
    inner = [i for i, k in enumerate(nodes) if k[0] == 'N']
    new = {i: j for j, i in enumerate(leaves + inner)}
    assert inner[-1] == root
    data = dict(offsets=offs, bits=off, white=white, black=black, leaves=[nodes[i][1] for i in leaves],
                branches=[(new[nodes[i][1]], new[nodes[i][2]]) for i in inner], depth=depth)
    json.dump(data, open(out, 'w'))
    print('lines', len(lines), 'bits', off, 'offsets', offs, 'leaf masks', len(leaves), 'inner nodes', len(inner), 'last width', depth)


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
