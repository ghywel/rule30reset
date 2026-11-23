"""Certify the two sharp exit rules for a long exterior three-gap rhythm."""
import json
from pathlib import Path

from audit_gap_observers import read_row, sample_bits
from certify_mixed_cuts import options, verified_solve
from mixed_cut_strength import formula
from wheel_bridge import table


def run(args):
    trap = sorted(table(args.kit, "trapCodes", "Rule30Certificates/GateTrap"))
    proofs, models = {}, {}
    for word,width,endpoint in (("3"*7+"53",19,[]), ("3"*8+"55",23,trap)):
        _, n, clauses = formula(sample_bits(word),width,endpoint,False)
        proof, model = verified_solve(args.output/(word+"-cut"),n,clauses,args)
        assert model is None
        proofs[word] = dict(width=width, requires_exterior_endpoint=bool(endpoint), **proof)
    for word,exterior in (("3"*6+"53",True), ("3"*7+"55",True), ("3"*8+"55",False),
                          ("3"*18+"5",True)):
        bits = sample_bits(word)
        rows,n,clauses = formula(bits,16,trap if exterior else [],True)
        rec, model = verified_solve(args.output/(word+"-physical"),n,clauses,args)
        assert model is not None
        initial = "".join(str(int(v in model)) for v in rows[0])
        code = read_row(initial,bits)
        assert (code not in trap) == exterior
        models[word] = dict(initial=hex(int(initial[::-1],2)), initial_width=len(initial),
                            endpoint=code, outside=exterior, cnf=rec["cnf"])
    path=args.output/"pure-three-exit.json"
    path.write_bytes((json.dumps({"proofs":proofs,"physical":models},indent=2)+"\n").encode())
    print(path)


if __name__=="__main__":
    run(options())
