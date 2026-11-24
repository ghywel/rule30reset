"""Counterexample-guided search over all two-step temporal pair shifts.

Branch on edges of an unliftable path. A positive result must lift its entire
language to the east. Subgraphs of a certified low-growth graph need no branch.
"""
import argparse
import json
from collections import Counter, deque
from functools import lru_cache
from itertools import product
from pathlib import Path


def words3():
    result = set()
    for seed in range(64):
        # Sites -2,-1,0,1,2,3 are initially available. Sample sites 0 and 1 three times.
        row = [(seed >> i) & 1 for i in range(6)]
        word = []
        for k in range(3):
            word.append(2*row[2-k]+row[3-k])
            row = [a ^ (b | c) for a,b,c in zip(row,row[1:],row[2:])]
        result.add(tuple(word))
    return sorted(result)


EDGES = words3()
INDEX = {e:i for i,e in enumerate(EDGES)}
assert len(EDGES)==32


def bits(mask):
    while mask:
        bit = mask & -mask
        yield bit.bit_length()-1
        mask ^= bit


def graph(mask):
    outgoing = {}
    for i in bits(mask):
        a,b,c = EDGES[i]
        outgoing.setdefault((a,b),[]).append((c,i))
    return outgoing


@lru_cache(None)
def trim(mask):
    while mask:
        begin = {EDGES[i][:2] for i in bits(mask)}
        end = {EDGES[i][1:] for i in bits(mask)}
        stay = begin & end
        nxt = sum(1<<i for i in bits(mask) if EDGES[i][:2] in stay and EDGES[i][1:] in stay)
        if mask == nxt:
            break
        mask = nxt
    return mask


def failure(mask, outgoing):
    queue = deque()
    for a,b in outgoing:
        east = 0
        for c,d in product(range(2),repeat=2):
            if (a//2 ^ ((a%2)|c)) == b%2 and (2*(a%2)+c,2*(b%2)+d) in outgoing:
                east |= 1 << (2*c+d)
        if not east:
            return (a,b)
        queue.append((a,b,east,(a,b)))
    seen = set()
    while queue:
        a,b,east,word = queue.popleft()
        key = a,b,east
        if key in seen:
            continue
        seen.add(key)
        for z,_ in outgoing[a,b]:
            nxt = 0
            for t in bits(east):
                if (b//2 ^ ((b%2)|(t%2))) != z%2:
                    continue
                for last in range(2):
                    ei = INDEX.get((2*(a%2)+t//2, 2*(b%2)+t%2, 2*(z%2)+last))
                    if ei is not None and mask & (1<<ei):
                        nxt |= 1 << (2*(t%2)+last)
            if not nxt:
                return word + (z,)
            queue.append((b,z,nxt,word+(z,)))
    return None


def ceiling(outgoing, rate):
    """k-step row sums <= rate^k certify entropy <= log(rate)."""
    if not outgoing:
        return 1
    v = {vertex:1 for vertex in outgoing}
    for k in range(1,33):
        v = {(a,b):sum(v[b,c] for c,_ in edges) for (a,b),edges in outgoing.items()}
        if max(v.values()) <= rate**k:
            return k
    return None


def only_cycles(outgoing):
    """A finite graph has positive entropy iff a vertex branches within its SCC."""
    reaches = {}
    for start in outgoing:
        seen = {start}
        stack = [start]
        while stack:
            a,b = stack.pop()
            for c,_ in outgoing[a,b]:
                dest = b,c
                if dest not in seen:
                    seen.add(dest)
                    stack.append(dest)
        reaches[start] = seen
    return all(sum((a,b) in reaches[b,c] for c,_ in adj)<=1
               for (a,b),adj in outgoing.items())


def search(rate):
    proof = {}
    def visit(mask):
        mask = trim(mask)
        if mask in proof:
            return
        outgoing = graph(mask)
        if rate==1 and only_cycles(outgoing):
            proof[mask] = ("cycles",0)
            return
        k = ceiling(outgoing,rate) if rate>1 else None
        if k is not None:
            proof[mask] = ("growth",k)
            return
        witness = failure(mask,outgoing)
        if witness is None:
            from sympy import Matrix, symbols
            vertices = list(outgoing)
            allowed = {EDGES[i] for i in bits(mask)}
            A = Matrix([[int(a[1]==b[0] and (a[0],a[1],b[1]) in allowed)
                         for b in vertices] for a in vertices])
            x = symbols("x")
            poly = A.charpoly(x).as_poly().shift(rate)
            if not all(z>=0 for z in poly.all_coeffs()):
                raise RuntimeError(f"FOUND east-closed graph above {rate}: {mask:#x}, {poly}")
            proof[mask] = ("polynomial",list(map(int,poly.all_coeffs())))
            return
        proof[mask] = ("miss",witness)
        if len(witness)==2:
            incident = sum(1<<i for i in bits(mask) if witness in (EDGES[i][:2],EDGES[i][1:]))
            visit(mask & ~incident)
        else:
            for edge in set(zip(witness,witness[1:],witness[2:])):
                visit(mask & ~(1<<INDEX[edge]))
    visit((1<<32)-1)
    return proof


if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output",type=Path)
    parser.add_argument("--rate",type=int,default=2)
    args=parser.parse_args()
    proof=search(args.rate)
    print("distinct nodes",len(proof),Counter(v[0] for v in proof.values()),flush=True)
    args.output.write_text(json.dumps({"rate":args.rate,"edges":EDGES,"proof":proof},
                                      separators=(",",":")),encoding="ascii")
