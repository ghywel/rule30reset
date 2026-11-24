"""Cross-check the nine-bit decoder on finite six-cell strips with GE2.

Words are printed in time order. GE2 exclusions are generated from its nine
allowed pairs. No pulse-return colouring or abstract phase is used by the strip.
"""
from itertools import product
from white_net import gap_graph


def dictionary():
    edges, label, gate = gap_graph(True)
    walks = {(s, label[s], 0) for s in range(len(edges))}
    for i in range(1, 9):
        walks = {(t, 2*word + label[t], gate[t] if i == 6 else g)
                 for s, word, g in walks for t in edges[s]}
    ans = {word: g for _, word, g in walks}
    assert all(ans[word] == g for _, word, g in walks)
    return ans


def forbidden():
    pairs = {(2,2), (2,4), (2,5), (3,3), (3,5), (4,5), (5,2), (5,3), (5,5)}
    return ['11', '00000'] + ['1'+'0'*(a-1)+'1'+'0'*(b-1)+'1'
                              for a, b in product(range(2, 6), repeat=2) if (a,b) not in pairs]


def local_monitor():
    bad = forbidden()
    prefixes = sorted({w[:i] for w in bad for i in range(len(w))}, key=lambda w: (-len(w), w))
    return {p: {b: next((s for s in prefixes if (p+str(b)).endswith(s)), '')
                for b in (0,1) if not any((p+str(b)).endswith(w) for w in bad)} for p in prefixes}


def test(left, right, table, graph, monitor):
    # No history is assumed for either the physical row or the gate-word reader.
    states = {(x, '', 0, 0) for x in graph}
    for i in range(left+9+right):
        after = set()
        for x, prefix, word, marked in states:
            g = x[0]
            if g not in monitor[prefix]:
                continue
            p = monitor[prefix][g]
            v = 2*word + (x[0] ^ x[1]) if left <= i < left+9 else word
            y = g if i == left+6 else marked
            after.update((z, p, v, y) for z in graph[x])
        states = after
    return sorted({(w,g) for _,_,w,g in states if table.get(w, 0) != g})


if __name__ == '__main__':
    table = dictionary()
    print('nine-bit words', len(table), 'kicks', [format(w,'09b') for w in sorted(table) if table[w]])
    print('forbidden pairs as words', forbidden())
    graph = {}
    for x in product((0,1), repeat=6):
        ys = set()
        for a,b in product((0,1), repeat=2):
            row = x
            for wall,e in ((0,a),(1,b)):
                padded = (wall,*row,e)
                row = tuple(l ^ (c|r) for l,c,r in zip(padded,padded[1:],padded[2:]))
            ys.add(row)
        graph[x] = ys
    monitor = local_monitor()
    minima = []
    for pred in range(11):
        for succ in range(11):
            if any(p <= pred and s <= succ for p,s in minima):
                continue
            errors = test(pred,succ,table,graph,monitor)
            if not errors:
                minima.append((pred,succ))
            if (pred,succ) in ((0,0),(0,10),(10,0)):
                print('padding',pred,succ,'wrong (word,gate)',errors)
    print('Pareto minima, six-cell strip with GE2 factors', minima)
