#!/usr/bin/env python3
"""claudeM5_m9_print_cnf.py: print the DIMACS text of Rule30RunsOfFour.cnf from the Lean module's own definitions,
and optionally certify it (ledger M85).

  python3 research/m9/claudeM5_m9_print_cnf.py OUTDIR [--p N] [--certify]

The printer is the module's source text with two mechanical changes: an ordinary `import` in place of the module
header (an `#eval` cannot run imported module code otherwise), and no `@[expose] public section`. One `#eval` at the
end writes `cnf` as DIMACS. `--p N` replaces `def P : Nat := 2` (N = 1 is the satisfiable control; the module's
proofs need P = 2 and fail in the control, but its definitions and the printer still run). With `--certify`, CaDiCaL
writes a binary and a text LRAT proof, `cake_lpr` checks the first and `lrat-check` the second. Hardened after R71: the
outputs are deleted before each run, Lean's exit status is required (P = 2), the DIMACS digest must be the certified
one, and each checker must exit 0 and print its exact acceptance line.

Run it from the repository root, with Lean on the path; the kit's lean/ package must be built.
"""
import hashlib
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
MODULE = ROOT / 'research' / 'm9' / 'Rule30RunsOfFour.lean'
KIT = ROOT / 'Rule30PrizeKit' / 'lean'
# The DIMACS certified in M85 and replayed in R71.
EXPECTED = '11c3578f029c93ce9d0c0de508399c6b7106fe9c5178ebdfff6a527ebe7c6368'

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
    for f in (cnf, lean):              # never certify a file left by an earlier run (R71)
        if f.exists():
            f.unlink()
    lean.write_text(s + PRINTER % cnf)
    run = subprocess.run(['lake', 'env', 'lean', str(lean)], cwd=KIT, capture_output=True, text=True)
    if P == 2 and run.returncode != 0:
        raise SystemExit('Lean failed on the printer (exit %d):\n%s' % (run.returncode, run.stdout[-2000:]))
    if not cnf.exists():
        raise SystemExit('the printer wrote no DIMACS (Lean exit %d)' % run.returncode)
    data = cnf.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    print('%s: %s; module %s; Lean exit %d%s; DIMACS %s' % (
        cnf.name, data.split(b'\n', 1)[0].decode(), hashlib.sha256(MODULE.read_bytes()).hexdigest()[:16],
        run.returncode, ' (the control: its proofs need P = 2)' if P != 2 else '', digest))
    if P == 2 and digest != EXPECTED:
        raise SystemExit('the DIMACS is not the certified one (%s)' % EXPECTED)
    if '--certify' in a:
        b, t = out / (name + '.lrat'), out / (name + '.txt.lrat')
        for f in (b, t):
            if f.exists():
                f.unlink()
        r1 = subprocess.run(['cadical', '-q', '--lrat=true', str(cnf), str(b)], capture_output=True, text=True)
        c1 = subprocess.run(['cake_lpr', str(cnf), str(b)], capture_output=True, text=True)
        r2 = subprocess.run(['cadical', '-q', '--lrat=true', '--binary=false', str(cnf), str(t)],
                            capture_output=True, text=True)
        c2 = subprocess.run(['lrat-check', str(cnf), str(t)], capture_output=True, text=True)
        # exact acceptance: the solver's UNSAT exit, each checker's exit 0 and its acceptance line (R71)
        ok1 = (r1.returncode == 20 and c1.returncode == 0
               and any(l.strip() == 's VERIFIED UNSAT' for l in c1.stdout.splitlines()))
        ok2 = (r2.returncode == 20 and c2.returncode == 0
               and any(l.strip() == 'c VERIFIED' for l in (c2.stdout + c2.stderr).splitlines()))
        print('CaDiCaL exits %d and %d; cake_lpr on binary LRAT (%d bytes): exit %d, accepted %s; '
              'lrat-check on text LRAT: exit %d, accepted %s' % (r1.returncode, r2.returncode, b.stat().st_size,
                                                                 c1.returncode, ok1, c2.returncode, ok2))
        b.unlink()
        t.unlink()
        sys.exit(0 if ok1 and ok2 else 1)


if __name__ == '__main__':
    main()
