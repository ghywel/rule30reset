#!/usr/bin/env python3
"""claudeM5_build_packet.py SRC KITDIR LOG [TOP]: compile every local Lean module in SRC (imports first) against KITDIR's built library,
one at a time, recording each module's wall time. Written for the path 2 read (ledger M105); uses no packet script.

  python3 claudeM5_build_packet.py <unpacked packet> <kit checkout with lean/.lake built> <log> MandatoryGapFactor"""
import os, re, subprocess, sys, time, pathlib
src, kit, log = map(pathlib.Path, sys.argv[1:4])
lib = kit / 'lean/.lake/build/lib/lean'
lean = pathlib.Path.home() / '.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean'
env = dict(os.environ, LEAN_PATH=os.pathsep.join([str(lib), str(src)]),
           PATH=str(lean.parent) + os.pathsep + os.environ['PATH'])
local = {f.stem for f in src.glob('*.lean')}
deps = {m: [i for i in re.findall(r'^(?:public )?import (\S+)', (src / (m + '.lean')).read_text(), re.M) if i in local] for m in local}
done, order = set(), []
def visit(m):
    if m in done: return
    done.add(m)
    for d in deps[m]: visit(d)
    order.append(m)
top = sys.argv[4] if len(sys.argv) > 4 else 'MandatoryGapFactor'
visit(top)
with open(log, 'w') as out:
    out.write('modules to build: %d\n' % len(order)); out.flush()
    t0 = time.time()
    for m in order:
        a = time.time()
        r = subprocess.run([str(lean), '-o', str(src / (m + '.olean')), str(src / (m + '.lean'))],
                           cwd=src, env=env, capture_output=True, text=True)
        out.write('%s %.1fs exit %d\n' % (m, time.time() - a, r.returncode)); out.flush()
        if r.returncode != 0:
            out.write(r.stdout[-3000:] + r.stderr[-3000:]); sys.exit(1)
    out.write('ALL OK %d modules in %.0fs\n' % (len(order), time.time() - t0))
