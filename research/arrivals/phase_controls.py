"""Synchronized phase-graph controls and a scalar check of the black-tick channel."""
from itertools import product
from white_net import gap_graph, scalar
from white_net_bridge import local_monitor


def stable(initial, image):
    levels = [initial]
    while True:
        level = image(levels[-1])
        if level == levels[-1]:
            return levels
        assert level < levels[-1]
        levels.append(level)


def pair_control(refined):
    graph, label, gate = gap_graph(refined)
    equal = {(p,q) for p in range(len(graph)) for q in range(len(graph)) if label[p] == label[q]}
    steps = {s: {(p,q) for p in graph[s[0]] for q in graph[s[1]] if (p,q) in equal} for s in equal}
    past = stable(equal, lambda level: set().union(*(steps[s] for s in level)))
    future = stable(equal, lambda level: {s for s in equal if steps[s] & level})
    disagree = {s for s in equal if gate[s[0]] != gate[s[1]]}
    minima = []
    for l, p in enumerate(past):
        for r, f in enumerate(future):
            if not p & f & disagree and not any(a<=l and b<=r for a,b in minima):
                minima.append((l,r))
    print('exclude 225', refined, 'past/future stabilize', len(past)-1, len(future)-1,
          'all minimal windows', minima, 'permanent opposite pairs', len(past[-1] & future[-1] & disagree))


def black_source(row):
    # On the following black tick only the spatial 10 at +1 can contribute.
    mid = scalar(row, 0)
    return mid[0] & (1-mid[1])


def black_control(left, right, constrained):
    rows = list(product((0,1), repeat=6))
    next_rows = {r: {scalar((*scalar((*r,a),0),b),1) for a,b in product((0,1),repeat=2)} for r in rows}
    mon = local_monitor() if constrained else {'': {0:'',1:''}}
    states = {(r,'',0,0,0) for r in rows}
    for i in range(left+5+right):
        out = set()
        for r,p,mark,b0,b4 in states:
            if r[0] not in mon[p]:
                continue
            m = r[0]&r[1] if i==left else mark
            first = black_source(r) if i==left else b0
            last = black_source(r) if i==left+4 else b4
            out.update((s,mon[p][r[0]],m,first,last) for s in next_rows[r])
        states = out
    return sorted({(m,a,b) for _,_,m,a,b in states if m != a*(1-b)})


if __name__ == '__main__':
    for refined in (False,True):
        pair_control(refined)
    for constrained in (True,False):
        minima = []
        for left in range(6):
            for right in range(8):
                if any(l<=left and r<=right for l,r in minima):
                    continue
                errors = black_control(left,right,constrained)
                if not errors:
                    minima.append((left,right))
                if (left,right) in ((0,0),(5,7)):
                    print('black GE2',constrained,'padding',left,right,'wrong (odd,b0,b4)',errors)
        print('black GE2',constrained,'minimal padding in rectangle',minima)
