"""Measure fixed-word certificate widths and checkpoint sizes for the basis."""

import argparse
from pathlib import Path
import json

from wheel_bridge import table, tick


def grids(word, trap, limit=40, endpoint=False):
    points=[[int(b)] for b in word]
    for w in range(2,limit+1):
        mask = (1<<w)-1
        cand=[[v for x in rows for v in (x,x+(1<<(w-1))) if w!=16 or (endpoint and t<len(word)-1) or v not in trap] for t,rows in enumerate(points)]
        def succ(x):
            return [tick(tick(x+(e<<w),0),1) & mask for e in range(4)]
        front=[cand[0]]
        for rows in cand[1:]:
            kids={y%8191 for x in front[-1] for y in succ(x)}
            front.append([x for x in rows if x%8191 in kids])
        rev=[front[-1]]
        for rows in reversed(front[:-1]):
            keep={x%8191 for x in rev[-1]}
            rev.append([x for x in rows if any(y%8191 in keep for y in succ(x))])
        points=list(reversed(rev))
        yield w,points,(w,sum(map(len,cand)),sum(map(len,front)),sum(map(len,points)),max(map(len,points)))
        if not points[0]:
            break


def lift(word, trap, limit=40, endpoint=False):
    effort=[]
    for w,points,stats in grids(word,trap,limit,endpoint):
        effort.append(stats)
    return dict(word=word,width=w,empty=not points[0],work=sum(c+f for _,c,f,_,_ in effort),
                checkpoint_bits=sum(w*b for w,_,_,b,_ in effort),layers=effort)


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit",type=Path);p.add_argument("basis",type=Path);p.add_argument("output",type=Path)
    p.add_argument("--key",default="physical_exclusions")
    p.add_argument("--endpoint",action="store_true")
    p.add_argument("--width",type=int,default=40,help="Largest strip width to measure")
    a=p.parse_args(); trap=set(table(a.kit,"trapCodes","Rule30Certificates/GateTrap"))
    items=[]
    for word in json.loads(a.basis.read_bytes())[a.key]:
        result=lift(word,trap,limit=a.width,endpoint=a.endpoint)
        print(word,len(word),result["width"],result["empty"],result["work"],result["checkpoint_bits"],flush=True)
        items.append(result)
    a.output.write_text(json.dumps(items,indent=2)+"\n",encoding="utf-8")
