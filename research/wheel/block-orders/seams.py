"""Find or replay a finite network of block paths for all orders on a strip."""
import argparse
import itertools
import json
from pathlib import Path

from check import target


def labels(n):
    return ["".join(s) for s in itertools.product("AB", repeat=n)]


def network(context, past, period):
    def name(phase, word):
        return word if period == 1 else f"{phase}/{word}"
    for phase in range(period):
        for word in labels(context+1):
            yield (name(phase, word), name(phase, word[:-1]),
                   name((phase+1) % period, word[1:]), word[past])


def verify(cert):
    width = cert["width"]
    seams = cert["seams"]
    context = cert.get("context", 1)
    past, period = cert.get("past",0), cert.get("period",1)
    if width < 1 or not 0 <= past < context or period < 1:
        raise ValueError("invalid seams")
    edges = list(network(context, past, period))
    if set(seams) != {a for _,a,_,_ in edges}:
        raise ValueError("missing or extra seam")
    for row in seams.values():
        if len(row) != width or set(row) - set("01"):
            raise ValueError("invalid seam row")
    for edge, a, b, letter in edges:
        row = list(map(int, seams[a]))
        extras = cert["exterior"][edge]
        word = target(letter)
        if len(extras) != len(word):
            raise ValueError("wrong number of steps")
        for gate, pair in zip(word, extras):
            if str(row[0]) != gate or pair not in ("00", "01", "10", "11"):
                raise ValueError("invalid gate or exterior")
            row.extend(map(int, pair))
            for wall in (0, 1):
                row = [(wall if i == 0 else row[i-1]) ^ (row[i] | row[i+1])
                       for i in range(len(row)-1)]
        if row != list(map(int, seams[b])):
            raise ValueError("incorrect destination seam")


def search(width, context, past, period, dimacs=None):
    from pysat.formula import CNF, IDPool
    from pysat.solvers import Cadical195
    pool = IDPool()
    def fresh(n):
        return [pool.id() for _ in range(n)]
    formula = CNF()
    def tick(x, z, black):
        c, r, out = x[0], x[1], -z[0] if black else z[0]
        for clause in ((-c,out),(-r,out),(c,r,-out)):
            formula.append(clause)
        for i in range(1,len(z)):
            l,c,r = x[i-1:i+2]
            out = z[i]
            for clause in ((-c,-out,-l),(-c,out,l),(-r,-out,-l),
                           (-r,out,l),(c,r,-out,l),(c,r,out,-l)):
                formula.append(clause)
    edges = list(network(context, past, period))
    seams = {a:fresh(width) for a in sorted({a for _,a,_,_ in edges})}
    exterior = {}
    for edge, a, b, letter in edges:
        row = seams[a]
        path = []
        word = target(letter)
        for j,gate in enumerate(word):
            formula.append([row[0] if gate == "1" else -row[0]])
            outside = fresh(2)
            path.append(outside)
            mid = fresh(width+1)
            dest = seams[b] if j+1 == len(word) else fresh(width)
            tick(row+outside, mid, False)
            tick(mid, dest, True)
            row = dest
        exterior[edge] = path
    print("testing width", width, "variables", pool.top, flush=True)
    if dimacs:
        formula.to_file(str(dimacs))
        return
    with Cadical195(bootstrap_with=formula.clauses) as solver:
        if not solver.solve():
            return None
        ones = set(x for x in solver.get_model() if x>0)
        def bits(row):
            return "".join("1" if x in ones else "0" for x in row)
        return {"width":width, "context":context, "past":past, "period":period,
                "seams":{a:bits(row) for a,row in seams.items()},
                "exterior":{ab:[bits(x) for x in path] for ab,path in exterior.items()}}


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("file", type=Path)
    p.add_argument("--search", type=int, metavar="WIDTH")
    p.add_argument("--context", type=int, default=1)
    p.add_argument("--past", type=int, default=0)
    p.add_argument("--period", type=int, default=1)
    p.add_argument("--dimacs", action="store_true", help="write the CNF to FILE without solving")
    args = p.parse_args()
    if args.search is None:
        verify(json.loads(args.file.read_text()))
        print("all paths replayed")
    else:
        if args.search < 1 or not 0 <= args.past < args.context or args.period < 1:
            p.error("width and period must be positive, and 0 <= past < context")
        cert = search(args.search, args.context, args.past, args.period, args.file if args.dimacs else None)
        if args.dimacs:
            print("wrote DIMACS")
        elif cert is None:
            print("UNSAT for this seam template (solver verdict)")
        else:
            verify(cert)
            args.file.write_text(json.dumps(cert,indent=2)+"\n", encoding="ascii")
            print("SAT with independently replayed certificate")
