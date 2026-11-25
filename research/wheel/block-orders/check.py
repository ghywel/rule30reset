"""Independent replay of complete-cone witnesses and all-completion prefix trees."""
import argparse
import itertools
from pathlib import Path


def target(order, long_run=5):
    gaps = (g for letter in order for g in [3] + [5]*(3 if letter == "A" else long_run))
    return "".join("1" + "0"*(g-1) for g in gaps)


def gate(prefix, samples):
    """Exact three-valued local table, with an arbitrary infinite eastern tail."""
    width = len(prefix)
    mask = (1 << width) - 1
    one = int(prefix[::-1], 2)
    zero = mask ^ one
    result = []
    for t in range(2*samples-1):
        if t % 2 == 0:
            result.append("1" if one & 1 else "0" if zero & 1 else "?")
        l1, l0 = (one << 1) | (t % 2), (zero << 1) | (1-t%2)
        o1, o0 = one | (one >> 1), zero & (zero >> 1)
        one, zero = mask & ((l0 & o1) | (l1 & o0)), mask & ((l1 & o1) | (l0 & o0))
    return "".join(result)


def physical(path, long_run):
    by_order = {}
    for line in path.read_text().splitlines():
        n, code, seed, start, length, p = line.split()
        order = format(int(code), "0%db" % int(n)).translate(str.maketrans("01","AB"))
        w = target(order,long_run) + "1"
        assert len(w)-1 == int(length) and len(p) == 2*int(length)+1
        assert gate(p,len(w)) == w and order not in by_order
        by_order[order] = (int(seed),int(start))
    depth = max(map(len,by_order))
    print("verified physical counts", [sum(len(w)==n for w in by_order) for n in range(1,depth+1)])


def tree(path):
    nodes = {}
    for line in path.read_text().splitlines():
        order,p = line.split()
        order = "" if order == "-" else order
        assert order not in nodes and not (set(p)-set("01"))
        w = target(order)+"1001"
        assert gate(p,len(w)) == w, order
        nodes[order] = p
    depth = max(map(len,nodes))
    for n in range(1,depth+1):
        for word in itertools.product("AB",repeat=n):
            w = "".join(word)
            parent, child = nodes[w[:-1]], nodes[w]
            assert child.startswith(parent) and len(child)>len(parent)
            if w[-1]=="A":
                other=nodes[w[:-1]+"B"]
                assert not other.startswith(child) and not child.startswith(other)
    print("verified full tree",depth,len(nodes),"root",nodes[""],"leaf widths",
          min(len(p) for w,p in nodes.items() if len(w)==depth),
          max(len(p) for w,p in nodes.items() if len(w)==depth))


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("mode",choices=["physical","tree","roots"])
    p.add_argument("file",type=Path,nargs="?")
    p.add_argument("--long-run",type=int,default=5)
    a=p.parse_args()
    if not __debug__:
        p.error("Run without -O")
    if a.mode=="roots":
        for k in range(1,8):
            good = ["".join(x) for x in itertools.product("01",repeat=k) if gate("".join(x),4)=="1001"]
            if good:
                print(k,good)
                break
    elif a.mode=="tree":
        tree(a.file)
    else:
        physical(a.file,a.long_run)
