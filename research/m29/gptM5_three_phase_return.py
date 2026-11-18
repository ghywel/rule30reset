"""Full reachable graph for three consecutive phases from a white/black anchor.
A white column returns all three run residues to zero. Prove a three-step exit.
"""
import json
from gptM5_white_time_cover import advance, successors

def following(z):
    a,b,one,two=z
    for c in successors(a,b,3):
        r=advance(c,one,two,7)
        if r is not None:
            yield (b,c,*r)

def main():
    seen=set()
    fresh={(x,7,7^x,x) for x in range(8)}
    while fresh:
        seen.update(fresh)
        fresh={v for z in fresh for v in following(z)}-seen
    white={z for z in seen if z[1]==0}
    after=white
    sizes=[len(white)]
    for _ in range(3):
        after={v for z in after for v in following(z)}
        sizes.append(len(after))
    assert sizes[-1]==0
    return dict(states=sorted(seen),white_states=sorted(white),after_white_counts=sizes,
                transitions=sum(len(list(following(z))) for z in seen))
if __name__=="__main__":print(json.dumps(main()))
