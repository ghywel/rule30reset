"""Look for nested forcing trees inside a collection of independent physical rows."""
import argparse
from collections import defaultdict
from functools import lru_cache
from pathlib import Path

from check import gate, target, tree


@lru_cache(maxsize=200000)
def forced(prefix, word):
    return gate(prefix,len(word)) == word


def shortest(row, word, minimum):
    hi = min(len(row),2*len(word)-1)
    if hi < minimum or not forced(row[:hi],word):
        return None
    lo = minimum
    while lo < hi:
        mid = (lo+hi)//2
        if forced(row[:mid],word):
            hi = mid
        else:
            lo = mid+1
    return row[:lo]


def parse(line):
    fields = line.split()
    if len(fields) == 2:
        return fields
    n, code, _, _, _, row = fields
    order = format(int(code),"0%db"%int(n)).translate(str.maketrans("01","AB"))
    return order, row


def mine(paths, depth, output):
    children = defaultdict(set)
    roots = set()
    for path in paths:
        for line in path.read_text().splitlines():
            order, row = parse(line)
            parent = shortest(row,"1001",1)
            if parent is None:
                continue
            roots.add(parent)
            for k in range(1,min(len(order),depth)+1):
                word = order[:k]
                child = shortest(row,target(word)+"1001",len(parent)+1)
                if child is None:
                    break
                children[word[:-1],parent,word[-1]].add(child)
                parent = child
    @lru_cache(maxsize=None)
    def best(word, parent):
        options = []
        for letter in "AB":
            nxt = children.get((word,parent,letter),())
            if not nxt:
                return 0, ()
            options.append(max((best(word+letter,p)[0],p) for p in nxt))
        return 1+min(h for h,_ in options), tuple(p for _,p in options)
    height,root = max((best("",p)[0],p) for p in roots)
    def extract(word,parent):
        yield f"{word or '-'}\t{parent}\n"
        if len(word) < height:
            for letter,p in zip("AB",best(word,parent)[1]):
                yield from extract(word+letter,p)
    output.write_text("".join(extract("",root)),encoding="ascii")
    tree(output)


if __name__ == "__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("depth",type=int)
    p.add_argument("output",type=Path)
    p.add_argument("inputs",nargs="+",type=Path)
    args=p.parse_args()
    mine(args.inputs,args.depth,args.output)
