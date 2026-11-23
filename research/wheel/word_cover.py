"""Factor-minimal covers of the 48-sample clean language by forced trap entries."""

import argparse
import json
from pathlib import Path
from time import monotonic

import numpy as np
from pysat.solvers import Cadical195

from mixed_cut_strength import formula
from trap_observer import FACTORS
from wheel_bridge import graph, table, tick


def clean_words(n):
    words = [""]
    for _ in range(n):
        words = [s+b for s in words for b in "01" if not (s+b).endswith(FACTORS)]
    return words


def strip(kit, width, n):
    states, edges, inside = graph(kit, width)
    outside = states[~inside]
    level = {"0": outside[outside % 2 == 0], "1": outside[outside % 2 == 1]}
    excluded = set()
    for k in range(2, n+1):
        children = {}
        for s, rows in level.items():
            dest = np.unique(edges[rows])
            dest = dest[~inside[dest]]
            for b in "01":
                word = s+b
                if word.endswith(FACTORS) or word[1:] not in level:
                    continue
                matching = dest[dest % 2 == int(b)]
                if len(matching):
                    children[word] = matching
                else:
                    excluded.add(word)
        level = children
    return sorted(excluded, key=lambda s: (len(s), s)), sorted(level)


def physical(kit, words, known):
    """Exact physical tests for words with no shorter known entry-forcing factor."""
    trap = table(kit, "trapCodes", "Rule30Certificates/GateTrap")
    basis, tested, possible, last_words = [], 0, {}, {}
    for length in range(1, 1+len(words[0])):
        # Only proper factors of the requested full-length language can contribute.
        cand = {s[i:i+length] for s in words for i in range(len(s)-length+1)}
        cand = [s for s in sorted(cand) if not any(b in s for b in basis)]
        if not cand:
            break
        rows, _, clauses = formula("0"*length, 16, [], True)
        del clauses[-length:]
        for code in trap:
            clauses.append([-v if code & (1 << i) else v for i, v in enumerate(rows[-1][:16])])
        gate = [row[0] for row in rows[::2]]
        positive = []
        with Cadical195(bootstrap_with=clauses) as sat:
            for word in cand:
                if word in known:
                    basis.append(word)
                    continue
                tested += 1
                assumptions = [v if b == "1" else -v for v, b in zip(gate, word)]
                if sat.solve(assumptions=assumptions):
                    model = {v for v in sat.get_model() if v>0}
                    initial = sum(1<<j for j,v in enumerate(rows[0]) if v in model)
                    row = initial
                    for j,b in enumerate(word):
                        assert row & 1 == int(b)
                        if j+1 < len(word):
                            row = tick(tick(row,0),1)
                    assert row & 65535 not in trap
                    positive.append(word)
                else:
                    basis.append(word)
        possible[length] = len(positive)
        if length >= len(words[0])-2:
            last_words[length] = positive
        print(length, len(cand), len(positive), len(basis), tested, flush=True)
    return basis, tested, possible, last_words


def smallest_covers(words, basis):
    """Count all minimum subsets of the factor-minimal physical basis."""
    from itertools import combinations
    masks = [sum(1<<i for i,w in enumerate(words) if b in w) for b in basis]
    target = (1<<len(words))-1
    for size in range(1,len(basis)+1):
        hits = []
        for chosen in combinations(range(len(basis)),size):
            mask = 0
            for i in chosen:
                mask |= masks[i]
            if mask == target:
                hits.append(chosen)
        if hits:
            return hits
    raise ValueError("Factor dictionary fails to cover the requested words")


def main(args):
    start = monotonic()
    words = clean_words(args.length)
    exclusions, live = strip(args.kit, args.width, args.length)
    print("clean, exterior strip survivors, minimal strip factors:",len(words),len(live),len(exclusions),
          "seconds",round(monotonic()-start,2),flush=True)
    record = dict(length=args.length,width=args.width,clean=len(words),
                  strip_exclusions=exclusions,strip_survivors=live)
    if args.physical:
        basis, tested, possible, last_words = physical(args.kit, words, set(exclusions))
        by_length = {}
        for n in (args.length-1,args.length):
            all_words = clean_words(n)
            remaining = [w for w in all_words if not any(v in w for v in basis)]
            assert remaining == last_words.get(n,[])
            found = smallest_covers([w for w in all_words if w not in remaining],basis)
            signatures = {}
            for w in all_words:
                signature = tuple(i for i, factor in enumerate(basis) if factor in w)
                if signature:
                    signatures.setdefault(signature, w)
            minimal = {ids: w for ids,w in signatures.items()
                       if not any(set(sub) < set(ids) for sub in signatures)}
            by_length[n] = dict(clean_words=len(all_words), exterior_words=remaining,
                                minimum=len(found[0]), covers=found,
                                minimal_signatures=[dict(ids=ids,word=w) for ids,w in sorted(minimal.items())])
        record.update(physical_exclusions=basis,physical_tests=tested,physical_counts=possible,
                      minimum_covers=by_length)
    args.output.write_text(json.dumps(record,indent=2)+"\n",encoding="utf-8")


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit",type=Path);p.add_argument("output",type=Path)
    p.add_argument("--width",type=int,default=16);p.add_argument("--length",type=int,default=48)
    p.add_argument("--physical",action="store_true")
    main(p.parse_args())
