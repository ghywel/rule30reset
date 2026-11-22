#!/usr/bin/env python3
"""claudeCloud_lean_replay.py: the Lean half of the carrying read of path 3, the density polygon (ledger K67).

It compiles Lean modules from SRC, imports first, against a kit checkout whose `lean/` library is already built,
writing every output into OUT (nothing is written into SRC), and then runs the kit's own `Check.lean` on each module
with its headlines. It uses no script from the packet under review: the modules are read as text and compiled by
the stock `lean` of the toolchain the kit pins.

    python3 claudeCloud_lean_replay.py KIT SRC OUT PLAN.json REPORT.json

KIT        a kit checkout; KIT/lean/.lake/build/lib/lean must hold the built modules the sources import
SRC        the directory of .lean sources (an unpacked packet, or this folder)
OUT        an empty directory for the .olean files and the checker's JSON
PLAN.json  {"Module": ["headline", ...], ...}: headlines are given without the module's namespace when
           "namespace" maps the module to one, or in full
REPORT.json  what was built and checked: per module the time, the verdict, the constants replayed, the declarations,
           each headline's axioms; and the totals

Exit status 0 only if every module compiles and every check passes.
"""
import hashlib
import json
import os
import pathlib
import re
import subprocess
import sys
import time


def main():
    kit, src, out = (pathlib.Path(a).resolve() for a in sys.argv[1:4])
    plan = json.load(open(sys.argv[4]))
    lib = kit / 'lean/.lake/build/lib/lean'
    assert lib.is_dir(), 'build the kit modules first: ' + str(lib)
    out.mkdir(parents=True, exist_ok=True)
    tool = pathlib.Path.home() / '.elan/toolchains/leanprover--lean4---v4.35.0/bin'
    lean = tool / 'lean'
    env = dict(os.environ, LEAN_PATH=os.pathsep.join([str(lib), str(out)]), PATH=str(tool) + os.pathsep + os.environ['PATH'])
    version = subprocess.run([str(lean), '--version'], capture_output=True, text=True).stdout.strip()
    kit_rev = subprocess.run(['git', '-C', str(kit), 'rev-parse', 'HEAD'], capture_output=True, text=True).stdout.strip()

    local = {f.stem for f in src.glob('*.lean')}
    deps = {m: [i for i in re.findall(r'^(?:public )?import (\S+)', (src / (m + '.lean')).read_text(), re.M) if i in local]
            for m in local}
    order, seen = [], set()

    def visit(m):
        if m in seen:
            return
        seen.add(m)
        for d in deps[m]:
            visit(d)
        order.append(m)
    for m in plan['modules']:
        visit(m)

    report = dict(lean=version, kit=kit_rev, modules=[], ok=True)
    for m in order:
        text = (src / (m + '.lean')).read_bytes()
        t0 = time.time()
        r = subprocess.run([str(lean), '--root=' + str(src), '-o', str(out / (m + '.olean')), str(src / (m + '.lean'))],
                           cwd=out, env=env, capture_output=True, text=True)
        rec = dict(module=m, sha256=hashlib.sha256(text).hexdigest(), bytes=len(text), compile_seconds=round(time.time() - t0, 1),
                   compiled=(r.returncode == 0), messages=(r.stdout + r.stderr).strip()[-2000:],
                   forbidden=sorted(set(re.findall(r'\b(sorry|native_decide|axiom|unsafe|implemented_by|extern)\b', text.decode()))))
        heads = plan['modules'].get(m)
        if r.returncode == 0 and heads is not None:
            ns = plan.get('namespace', {}).get(m, '')
            full = [(ns + '.' + h) if ns and '.' not in h else h for h in heads]
            args = [str(lean), '--run', str(kit / 'Check.lean'), m, '--claim', 'partial']
            for h in full:
                args += ['--headline', h]
            t1 = time.time()
            c = subprocess.run(args, cwd=out, env=env, capture_output=True, text=True)
            line = [l for l in c.stdout.splitlines() if l.startswith('{')]
            js = json.loads(line[-1]) if line else {}
            (out / (m + '-check.json')).write_text(json.dumps(js, indent=1, sort_keys=True))
            rec.update(check_seconds=round(time.time() - t1, 1), check_exit=c.returncode, verdict=js.get('verdict'),
                       constants=js.get('replay', {}).get('constants'), replay_ok=js.get('replay', {}).get('ok'),
                       new_axioms=js.get('newAxioms'), imports_statements=js.get('importsStatements'),
                       declared=len(js.get('declared', [])),
                       declared_all_standard=all(d.get('standardAxioms') for d in js.get('declared', [])),
                       declared_names=sorted(d['name'] for d in js.get('declared', [])),
                       headlines=[dict(name=h.get('name'), found=h.get('found'), ok=h.get('ok'), axioms=h.get('axioms'))
                                  for h in js.get('headlines', [])], reasons=js.get('reasons'))
            if c.returncode != 0 or js.get('verdict') != 'pass':
                report['ok'] = False
        if r.returncode != 0:
            report['ok'] = False
        report['modules'].append(rec)
        print('%-34s compile %s %5.1fs%s' % (m, 'ok  ' if rec['compiled'] else 'FAIL', rec['compile_seconds'],
              ('  check %s, %d constants, %d headlines, new axioms %s' % (rec.get('verdict'), rec.get('constants') or 0,
               len(rec.get('headlines', [])), rec.get('new_axioms'))) if 'verdict' in rec else ''), flush=True)
        if not rec['compiled']:
            print(rec['messages'])
            break
    checked = [x for x in report['modules'] if 'verdict' in x]
    report['totals'] = dict(modules=len(report['modules']), checked=len(checked),
                            headlines=sum(len(x['headlines']) for x in checked),
                            constants=sum(x['constants'] or 0 for x in checked),
                            all_pass=all(x['verdict'] == 'pass' for x in checked) and report['ok'])
    json.dump(report, open(sys.argv[5], 'w'), indent=1, sort_keys=True)
    print('totals: %s' % report['totals'])
    sys.exit(0 if report['ok'] else 1)


if __name__ == '__main__':
    main()
