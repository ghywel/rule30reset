"""Search K80's complete Y cones with the standalone solver and check its finite row."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

from claudeCloud_wheel_budget import Y_DFA, add_automaton
from claudeCloud_wheel_stay import recurrence
from wheel_bridge import table


def gate_check(gate, codes, trap, expected=None):
    if gate[0] != 1 or codes[-1] in trap:
        return False
    starts = {0}
    # At a pulse, allow exactly the words for successive blocks 2, 45 and 4525.
    # A finite observation can stop strictly inside the last block.
    tiles = ["01", "000100001", "0001000010100001"]
    bits = "".join(map(str, gate))
    for s in range(len(bits)):
        if s not in starts:
            continue
        for tile in tiles:
            tail = bits[s+1:s+1+len(tile)]
            if tile.startswith(tail):
                starts.add(s+len(tail))
    return (len(bits)-1 in starts and
            all("10001" in bits[s:s+57] for s in range(len(bits)-56)) and
            (expected is None or bits == expected))


def read(row, samples):
    # Bit zero is positive site one, and the stage starts with a white wall.
    gate, codes = [], []
    for _ in range(samples):
        gate.append(row & 1)
        codes.append(row & 65535)
        row = (row << 1) ^ (row | (row >> 1))
        row = ((row << 1) | 1) ^ (row | (row >> 1))
    return gate, codes


def check_known(kit, source):
    """Replay the eight-copy white-time finite start with all farther sites white."""
    witness = json.loads(source.read_text().splitlines()[-1])
    initial = int(witness["row"][::-1],2)
    predecessor = 0x314430c514514514514514514514514514514514514514514514514514514514514514514514514514514514514514722bdc06e14c963039852e5a06d20019a95798c009e0609868ea4a68
    assert ((predecessor << 1) | 1) ^ (predecessor | (predecessor >> 1)) == initial
    trap = set(table(kit,"trapCodes","Rule30Certificates/GateTrap"))
    gate,codes = read(initial,345)
    assert gate_check(gate[:300],codes[:300],trap)
    assert gate_check(gate[:344],codes[:344],trap)
    assert not gate_check(gate,codes,trap)
    assert "10001" not in "".join(map(str,gate[-57:]))
    print(json.dumps(dict(support=initial.bit_length(), black_predecessor_support=predecessor.bit_length(),
                          finite_black_predecessor=hex(predecessor), accepted=344, rejected=345,
                          reason="first 57-sample block missing 10001", at_300=codes[299])))


class Cone:
    def __init__(self, n, width, stream):
        self.S = n
        self.width = width
        self.T = 2 * (n-1)
        self.rows = []
        self.nv = self.clause_count = 0
        self.stream = stream
        self.clauses = self
        for t in range(self.T+1):
            self.rows.append(self.nv+1)
            self.nv += width-t

    def gate(self, s):
        return self.rows[2*s]

    def append(self, clause):
        self.stream.write(" ".join(map(str,clause))+" 0\n")
        self.clause_count += 1

    def __iadd__(self, clauses):
        for clause in clauses:
            self.append(clause)
        return self

    def evolve(self):
        for t in range(self.T):
            old, new = self.rows[t:t+2]
            w = self.width-t-1
            c, r, n = old, old+1, new if t%2==0 else -new
            self.stream.write(f"{-c} {n} 0\n{-r} {n} 0\n{c} {r} {-n} 0\n")
            for i in range(1,w):
                c = old+i
                l, r, n = c-1, c+1, new+i
                self.stream.write(f"{-c} {-n} {-l} 0\n{-c} {n} {l} 0\n{-r} {-n} {-l} 0\n{-r} {n} {l} 0\n{c} {r} {-n} {l} 0\n{c} {r} {n} {-l} 0\n")
            self.clause_count += 3 + 6*(w-1)


def solve(kit,out,task):
    expected = None
    if task.startswith("train"):
        gaps = ("45"+"2"*16)*int(task.removeprefix("train"))+"2"
        expected = "1"+"".join("0"*(int(g)-1)+"1" for g in gaps)
        samples = len(expected)
    else:
        samples = int(task)
    trap = set(table(kit, "trapCodes", "Rule30Certificates/GateTrap"))
    out.mkdir(parents=True, exist_ok=True)
    cnf = out / (task+".cnf")
    width = 16+2*(samples-1)
    with cnf.open("w", encoding="ascii", newline="\n", buffering=1024*1024) as stream:
        stream.write(" "*64+"\n")
        cone = Cone(samples, width, stream)
        cone.evolve()
        if expected:
            for i, bit in enumerate(expected):
                cone.append([cone.gate(i) if bit=="1" else -cone.gate(i)])
        else:
            add_automaton(cone,Y_DFA,"u",0)
            recurrence(cone,"10001",57)
        for v in sorted(trap):
            cone.append([-(cone.rows[-1]+i) if (v>>i)&1 else cone.rows[-1]+i for i in range(16)])
        stream.seek(0)
        stream.write(f"p cnf {cone.nv} {cone.clause_count}".ljust(64))
    with cnf.open("rb") as f:
        sha = hashlib.file_digest(f,"sha256").hexdigest()
    print(f"task={task} samples={samples} cnf={sha} variables={cone.nv} clauses={cone.clause_count}",flush=True)
    log = out / (task+".solver.log")
    with log.open("wb") as stream:
        run = subprocess.run([shutil.which("cadical"),str(cnf)],stdout=stream, stderr=subprocess.STDOUT)
    record = dict(task=task,samples=samples,cnf_sha256=sha)
    if run.returncode == 10:
        row=0
        with log.open("rt", encoding="ascii",errors="replace") as stream:
            for line in stream:
                if line.startswith("v "):
                    for value in map(int,line[2:].split()):
                        if 1 <= value <= width:
                            row |= 1 << (value-1)
        gate,codes = read(row,samples)
        assert gate_check(gate,codes,trap,expected)
        record.update(status="SAT", verified=True, finite_row=hex(row), support=row.bit_length(),
                      terminal_window=codes[-1], gate="".join(map(str,gate)))
    elif run.returncode == 20:
        record.update(status="UNSAT (solver; certificate pending)")
    else:
        raise RuntimeError(f"Unexpected solver return code {run.returncode}")
    (out/(task+".json")).write_text(json.dumps(record,indent=2)+"\n")
    print(record,flush=True)


if __name__ == "__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit",type=Path); p.add_argument("out",type=Path); p.add_argument("task")
    args=p.parse_args()
    if args.task=="known":
        check_known(args.kit.resolve(),Path(__file__).with_name("data")/"claudeCloud-trains-cone-yS16.jsonl")
    else:
        solve(args.kit.resolve(),args.out.resolve(),args.task)
