"""K92.4, claudeM5 (M234): the substrip classification chain for modulus two, in the order of Lean's `ruledOut`.

Reads the uncertified lists of the any-period census output (fall 2 27) and, width by width, the certified
assignments the chain needs. Usage: python3 claudeM5_two_chain.py CENSUS_OUTPUT
"""
import re, sys
def read_U(path):
    U = {}; cur = None
    for line in open(path):
        m = re.match(r'width (\d+) modulus 2:', line)
        if m: cur = int(m.group(1)); U[cur] = []; continue
        m = re.match(r'\s+uncertified (\d+) ', line)
        if m: U[cur].append([int(c) for c in m.group(1)])
    return U
def rotate(m, q, r): return r - q if q <= r else r + (m - q)
def norm(m, xs): return [rotate(m, xs[0] if xs else 0, x) for x in xs]
def extend(m, bad):
    out = []
    for xs in bad:
        for p in range(m):
            ys = xs + [p]
            if norm(m, ys[1:]) in bad: out.append(ys)
    return out
def ruledOut(m, prev, rem): return [xs for xs in extend(m, prev) if xs not in rem]
def chain(path, W):
    U = read_U(path)
    prev = [[0, q] for q in range(2)]   # pairs 2
    assert sorted(U[2]) == sorted(prev)
    steps = []
    for w in range(3, W + 1):
        rem = U.get(w, [])
        # keep Lean's remaining in the order extend produces
        ext = extend(2, prev)
        rem_ordered = [xs for xs in ext if xs in rem]
        assert sorted(rem_ordered) == sorted(rem), w
        cs = ruledOut(2, prev, rem_ordered)
        steps.append((w, rem_ordered, cs))
        prev = rem_ordered
    return steps
if __name__ == '__main__':
    for w, rem, cs in chain(sys.argv[1], 27):
        print(w, len(rem), [''.join(map(str, c)) for c in cs])
