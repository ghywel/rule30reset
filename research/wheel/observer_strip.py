"""A second proof of the complete observer using sampled windows with arbitrary east inputs."""
import argparse
import json
from pathlib import Path
import numpy as np
from complete_observer import transitions
from exterior_gap_core import successors
from wheel_bridge import table


def reach(width, inside):
    prefixes, edges = transitions()
    bank = np.full((len(prefixes),2),-1,dtype=np.int32)
    for i,b,j in edges:
        bank[i,b]=j
    # Widths up to 22 are direct exhaustions. A state packs a window and its current DFA state.
    allw=np.arange(1<<width,dtype=np.int64)
    active=allw[~inside[allw&65535]]*16
    seen={}
    layers=[]
    for sample in range(1,10000):
        w,q = active>>4, active & 15
        j=bank[q,w&1]
        ok = j>=0
        w,j = w[ok],j[ok]
        layers.append(len(w))
        if not len(w):
            return {"width":width,"first_impossible":sample,"states_by_sample":layers}
        nxt=[]
        for v in successors(w,width):
            good=~inside[v&65535]
            nxt.append(v[good]*16+j[good])
        active=np.unique(np.concatenate(nxt))
        if len(active)<500000:
            key=active.tobytes()
            if key in seen:
                return {"width":width,"cycle_return":sample,"cycle_from":seen[key],"states_by_sample":layers}
            seen[key]=sample
    raise RuntimeError("inconclusive")


def lifted(inside, first=16, limit=40):
    """Widen a stabilized layer by admitting both values of the next spatial bit."""
    prefixes, edges = transitions()
    bank=np.full((len(prefixes),2),-1,dtype=np.int32)
    for i,b,j in edges:
        bank[i,b]=j
    w=first
    allw=np.arange(1<<w,dtype=np.int64)
    active=allw[~inside[allw&65535]]*16
    sample=1
    records=[]
    while w<=limit:
        rows,states=active>>4,active&15
        nextq=bank[states,rows&1]
        valid=nextq>=0
        rows,nextq=rows[valid],nextq[valid]
        if not len(rows):
            print("first impossible",sample,flush=True)
            return
        parts=[]
        for v in successors(rows,w):
            good=~inside[v&65535]
            parts.append(v[good]*16+nextq[good])
        nxt=np.unique(np.concatenate(parts))
        # Wait for a fixed reachable set at this width. In a sparse layer a
        # nontrivial period can be handled by increasing the width earlier.
        if np.array_equal(nxt,active):
            records.append((w,sample,len(nxt)))
            print(records[-1],flush=True)
            nxt=np.concatenate((nxt,nxt+(1<<(w+4))))
            w+=1
        active=nxt
        sample+=1
    raise ValueError("No bound through the requested width")


if __name__=="__main__":
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("kit",type=Path)
    ap.add_argument("width",type=int,nargs="+")
    ap.add_argument("--lift",action="store_true")
    args=ap.parse_args()
    inside=np.zeros(65536,dtype=bool)
    inside[table(args.kit,"trapCodes","Rule30Certificates/GateTrap")]=True
    for w in args.width:
        if args.lift:
            lifted(inside,w)
            continue
        value=reach(w,inside)
        print(json.dumps(value),flush=True)
