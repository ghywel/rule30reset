"""Find a physical exterior lower witness without prescribing a periodic gap word."""
import argparse
import json
from pathlib import Path

from pysat.card import CardEnc, EncType
from pysat.solvers import Cadical195

from claudeCloud_wheel_runs import Cone, simulate
from wheel_bridge import table


def seek(span, minimum, trap):
    # span = 3*(number of gaps) + 2*(number of fives).
    maximum_gaps = (span - 2*minimum)//3
    assert maximum_gaps >= 1
    cone = Cone(span+1)
    cone.gap_language(0,span+1)
    cone.clauses.extend([[cone.gate(0)],[cone.gate(span)]])
    cone.forbid_codes(span, trap)
    cap = CardEnc.atmost([cone.gate(s) for s in range(1,span)],bound=maximum_gaps-1,
                         top_id=cone.nv,encoding=EncType.totalizer)
    with Cadical195(bootstrap_with=cone.clauses+cap.clauses) as solver:
        if not solver.solve():
            return None
        model = set(v for v in solver.get_model() if v>0)
    bits = [int(cone.var[0,x] in model) for x in range(1,17+2*span)]
    readings, codes = simulate(bits,span+1)
    pulses = [s for s,b in enumerate(readings) if b]
    gaps = [b-a for a,b in zip(pulses,pulses[1:])]
    assert pulses[0]==0 and pulses[-1]==span and set(gaps) <= {3,5}
    assert gaps.count(5)>=minimum and all(c not in trap for c in codes)
    return {"span":span,"gaps":"".join(map(str,gaps)), "fives":gaps.count(5),
            "initial":hex(sum(b<<j for j,b in enumerate(bits))),"initial_width":len(bits),
            "final_window":codes[-1]}


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit",type=Path)
    p.add_argument("span",type=int)
    p.add_argument("minimum",type=int)
    p.add_argument("output",type=Path)
    a=p.parse_args()
    trap=set(table(a.kit,"trapCodes","Rule30Certificates/GateTrap"))
    result=seek(a.span,a.minimum,trap)
    print(result,flush=True)
    if result:
        a.output.write_bytes((json.dumps(result,indent=2)+"\n").encode())
