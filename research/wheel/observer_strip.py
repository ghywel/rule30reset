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


if __name__=="__main__":
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("kit",type=Path)
    ap.add_argument("width",type=int,nargs="+")
    args=ap.parse_args()
    inside=np.zeros(65536,dtype=bool)
    inside[table(args.kit,"trapCodes","Rule30Certificates/GateTrap")]=True
    for w in args.width:
        value=reach(w,inside)
        print(json.dumps(value),flush=True)
