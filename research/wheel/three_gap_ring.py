"""Identify K75's observed film and satisfy its unresolved cone using the 84-ring."""

import argparse
import json
from pathlib import Path

from claudeCloud_wheel_runs import Cone
from wheel_bridge import table


def build_ring():
    # Temporal bit zero is a white tick. Of the right trace, only the bits
    # at the three white ticks enter the inverse equation across the centre.
    centre = 0b101010
    def west(current, east):
        later = (current >> 1) | ((current & 1) << 5)
        return later ^ (current | east)
    pair = (west(centre,1), centre)
    seen, columns = {}, []
    while pair not in seen:
        seen[pair] = len(columns)
        columns.append(pair[1])
        pair = (west(*pair), pair[0])
    assert seen[pair] == 0 and len(columns) == 84
    # Time zero in the kit is the preceding black tick.
    rows = [sum(((columns[-i % 84] >> ((t+5) % 6)) & 1) << i for i in range(84)) for t in range(6)]
    return rows


def main(kit):
    rows = build_ring()
    def cell(t,i):
        return (rows[t%6] >> (i%84)) & 1
    assert all(cell(t+1,i) == (cell(t,i-1) ^ (cell(t,i) | cell(t,i+1)))
               for i in range(84) for t in range(6))
    assert all(cell(t,i) == cell(0,i-14*t) for i in range(84) for t in range(6))
    assert all(cell(t,0) == (t%2==0) for t in range(6))
    assert [cell(t,1) for t in (1,3,5)] == [1,0,0]
    # This row is the October ring also carried by Rule30ClockDensityExamples.
    old = 9979311498932161696903037
    cuts = [c for c in range(84) if all(cell(0,i) == (old >> ((c+i)%84) & 1) for i in range(84))]
    assert cuts == [65]
    trap = sorted(table(kit,"trapCodes","Rule30Certificates/GateTrap"))
    windows = [(rows[t] >> 1) & 65535 for t in (1,3,5)]
    assert all(w not in trap for w in windows)
    path = Path(__file__).parent / "data/claudeCloud-wheel-observer-sat.jsonl"
    old_probes = {d["N"]:d for d in (json.loads(l) for l in path.read_bytes().splitlines())}

    original = list(map(int,old_probes[100]["row"]))
    trace = []
    for t in range(199):
        trace.append(original[:12])
        left = [t%2] + original
        original = [left[i] ^ (original[i]|original[i+1]) for i in range(len(original)-1)]
    matches = []
    for phase in (1,3,5):
        for start in range(0,len(trace),2):
            end = start
            while end < len(trace) and all(trace[end][i]==cell(phase+end-start,i+1) for i in range(12)):
                end += 1
            matches.append((end-start,start,end-1,phase))

    n = 200
    cone = Cone(n)
    cone.gap_language(0,n)
    cone.forbid_codes(n-1,trap)
    assert cone.digest() == old_probes[n]["cnf_sha256"]
    valuation = [False] * (cone.nv+1)
    for (t,x), v in cone.var.items():
        valuation[v] = bool(cell(t+1,x))
    assert all(any(valuation[abs(literal)] == (literal>0) for literal in clause) for clause in cone.clauses)
    return {"rotation":14,"spatial_period":84,"temporal_period":6,"phase_of_archived_row":cuts[0],
            "black_start_row":hex(rows[0]),"white_windows":windows,"twelve_column_match":max(matches),
            "k75_cone":{"samples":n,"variables":cone.nv,"clauses":len(cone.clauses),"sha256":cone.digest(),
                        "status":"SAT","finite_row": "".join(str(cell(1,i)) for i in range(1,17+cone.T))}}


if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit",type=Path)
    print(json.dumps(main(parser.parse_args().kit),indent=2))
