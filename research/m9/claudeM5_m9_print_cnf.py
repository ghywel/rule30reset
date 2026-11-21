#!/usr/bin/env python3
"""claudeM5_m9_print_cnf.py: print the DIMACS text of Rule30RunsOfFour.cnf from the Lean module's own definitions,
and optionally certify it (ledger M85).

  python3 research/m9/claudeM5_m9_print_cnf.py OUTDIR [--p N] [--certify]

The printer is the module's source text with two mechanical changes: an ordinary `import` in place of the module
header (an `#eval` cannot run imported module code otherwise), and no `@[expose] public section`. One `#eval` at the
end writes `cnf` as DIMACS. `--p N` replaces `def P : Nat := 2` (N = 1 is the satisfiable control; the module's
proofs need P = 2 and fail in the control, but its definitions and the printer still run). With `--certify`, CaDiCaL
writes a binary and a text LRAT proof, `cake_lpr` checks the first and `lrat-check` the second.

Run it from the repository root, with Lean on the path; the kit's lean/ package must be built.
"""
import hashlib
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
MODULE = ROOT / 'research' / 'm9' / 'Rule30RunsOfFour.lean'
KIT = ROOT / 'Rule30PrizeKit' / 'lean'

PRINTER = '''
open Ruliology.CellularAutomata.Rule30RunsOfFour in
def dimacsText : String :=
  let body := cnf.foldl (fun acc c => acc ++ (" ".intercalate (c.map toString)) ++ " 0\\n") ""
  s!"p cnf {nVars} {cnf.length}\\n" ++ body

#eval IO.FS.writeFile "%s" dimacsText
'''


def main():
    a = sys.argv[1:]
    out = pathlib.Path(a[0]).resolve()
    out.mkdir(parents=True, exist_ok=True)
    P = int(a[a.index('--p') + 1]) if '--p' in a else 2
    src = MODULE.read_text()
    head = 'module\n\npublic import Ruliology.CellularAutomata.Rule30GateTrap'
    assert src.count(head) == 1 and src.count('@[expose] public section\n') == 1 and src.count('def P : Nat := 2') == 1
    s = src.replace(head, 'import Ruliology.CellularAutomata.Rule30GateTrap').replace('@[expose] public section\n', '')
    if P != 2:
        s = s.replace('def P : Nat := 2', 'def P : Nat := %d' % P)
    name = 'runs-of-four-P%d' % P
    cnf = out / (name + '.cnf')
    lean = out / (name + '.lean')
    lean.write_text(s + PRINTER % cnf)
    subprocess.run(['lake', 'env', 'lean', str(lean)], cwd=KIT, capture_output=True, text=True)
    data = cnf.read_bytes()
    print('%s: %s; module %s; DIMACS %s' % (cnf.name, data.split(b'\n', 1)[0].decode(),
                                          hashlib.sha256(MODULE.read_bytes()).hexdigest()[:16],
                                          hashlib.sha256(data).hexdigest()))
    if '--certify' in a:
        b, t = out / (name + '.lrat'), out / (name + '.txt.lrat')
        r1 = subprocess.run(['cadical', '-q', '--lrat=true', str(cnf), str(b)], capture_output=True, text=True)
        c1 = subprocess.run(['cake_lpr', str(cnf), str(b)], capture_output=True, text=True)
        r2 = subprocess.run(['cadical', '-q', '--lrat=true', '--binary=false', str(cnf), str(t)],
                            capture_output=True, text=True)
        c2 = subprocess.run(['lrat-check', str(cnf), str(t)], capture_output=True, text=True)
        ok1 = r1.returncode == 20 and 's VERIFIED UNSAT' in c1.stdout
        ok2 = r2.returncode == 20 and 'c VERIFIED' in (c2.stdout + c2.stderr)
        print('CaDiCaL UNSAT, cake_lpr on binary LRAT (%d bytes): %s; lrat-check on text LRAT: %s' % (
            b.stat().st_size, ok1, ok2))
        b.unlink()
        t.unlink()
        sys.exit(0 if ok1 and ok2 else 1)


if __name__ == '__main__':
    main()
