#!/usr/bin/env python3
"""build_s18.py S17SOURCE OUTDIR: S18's portable file and its kit module (ledger M168), from gptIntel's certificate.py (I216).

S17SOURCE is packet c of S17 (Rule30Submission.lean, `f016154d…`, what research/arrivals/s17/build_s17.py writes). The Lean is
gptIntel's, of uniform.template, with two edits: the carried source is nested as Rule30Submission.AlternatingArrivals, and the module
header of both forms is doc_module.txt.
"""
import pathlib
import re
import subprocess
import sys
import tempfile
HERE = pathlib.Path(__file__).resolve().parent
UNI = HERE.parent / 'uniform'
src, out = pathlib.Path(sys.argv[1]).resolve(), pathlib.Path(sys.argv[2])
DOC = (HERE / 'doc_module.txt').read_text(encoding='utf-8').strip('\n') + '\n'


def run(form):
    with tempfile.TemporaryDirectory() as d:
        f = pathlib.Path(d) / 'x.lean'
        subprocess.run([sys.executable, str(UNI / 'certificate.py'), str(src), str(f), '--form', form], check=True,
                       stdout=subprocess.DEVNULL, cwd=UNI)
        return f.read_text(encoding='utf-8')


portal = run('portal')
head = re.search(r'/-!\n.*?-/\n', portal, re.S)
portal = portal[:head.start()] + DOC + portal[head.end():]
portal = portal.replace('Rule30Submission.S17', 'Rule30Submission.AlternatingArrivals')
marker = 'namespace Rule30Submission.AlternatingArrivals\n'
assert portal.count(marker) == 1
portal = portal.replace(marker, "/-! ### Carried from `Rule30AlternatingArrivals` (R30-20261124-6af182), which the verifier's kit does not have -/\n\n" + marker)
kit = run('kit')
head = re.search(r'/-!.*?-/\n', kit, re.S)
kit = kit[:head.start()] + DOC + kit[head.end():]
assert 'S17' not in kit and 'S17' not in portal, 'internal name'
assert '"' not in portal and '\\' not in portal
for f, t in ((out / 'portal/Rule30Submission.lean', portal), (out / 'kit/lean/Ruliology/CellularAutomata/Rule30UniformEntry.lean', kit)):
    f.parent.mkdir(parents=True, exist_ok=True)
    f.write_bytes(t.encode('utf-8'))
    print(f.relative_to(out), len(t.encode('utf-8')))
