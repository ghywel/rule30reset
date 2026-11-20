#!/usr/bin/env python3
"""claudeM5_s4_kit.py: the four catalogue modules of S4's kit route, from our pinned sources (METHOD 12, step 2).

  python3 research/m29/claudeM5_s4_kit.py OUTDIR

Reads Rule30ThreePhaseReturn, Rule30RootedWhiteReturns, Rule30RecurrentStrip and Rule30ResetCompactness from this
repository's commit ab2c0fd (the sources S4's portal file carries) and writes them in the kit's module form:
  - `module`, then the imports as `public import Ruliology.CellularAutomata.<Module>`; `import Std` is dropped;
  - the module's own doc comment, then `@[expose] public section`;
  - namespaces moved from Rule30<Module> to Ruliology.CellularAutomata.Rule30<Module>, and `open` lines that name one
    of these four modules given its full name;
  - `#print` lines removed;
  - in Rule30ThreePhaseReturn, the second namespace Rule30TwoPhaseRise is left out: nothing in the chain uses it.
No proof body changes. The kit's own every-k modules are imported, not copied. Each file is written as UTF-8 with LF
line endings, and the digests printed are of the bytes written.
"""
import hashlib
import pathlib
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parents[2]
REV = 'ab2c0fd'
MODS = ['Rule30ThreePhaseReturn', 'Rule30RootedWhiteReturns', 'Rule30RecurrentStrip', 'Rule30ResetCompactness']
KITPREFIX = 'Ruliology.CellularAutomata.'


def sha(b):
    return hashlib.sha256(b).hexdigest()


def convert(name, text):
    lines = text.replace('\r\n', '\n').split('\n')
    imports, body, skipping = [], [], False
    for line in lines:
        if line.startswith('import '):
            target = line[len('import '):].strip()
            if target == 'Std':
                continue
            if not target.startswith(KITPREFIX):
                assert target in MODS, target
                target = KITPREFIX + target
            imports.append('public import ' + target)
            continue
        if line.startswith('#print '):
            continue
        if line == 'namespace Rule30TwoPhaseRise':
            skipping = True
            continue
        if skipping:
            if line == 'end Rule30TwoPhaseRise':
                skipping = False
            continue
        if line == 'namespace ' + name:
            line = 'namespace ' + KITPREFIX + name
        elif line == 'end ' + name:
            line = 'end ' + KITPREFIX + name
        elif line.startswith('open '):
            # our modules are now siblings in the kit's namespace: name them in full, which keeps an `open` of
            # Ruliology.CellularAutomata from making them ambiguous
            words = line.split(' ')
            line = ' '.join(KITPREFIX + w if w in MODS else w for w in words)
        body.append(line)
    text = '\n'.join(body).strip('\n') + '\n'
    # the module doc comment (if any) stays first; `@[expose] public section` goes just before the namespace
    ns = 'namespace ' + KITPREFIX + name
    assert text.count(ns) == 1 and text.count('end ' + KITPREFIX + name) == 1, name
    text = text.replace(ns, '@[expose] public section\n\n' + ns, 1)
    head = 'module\n\n' + ('\n'.join(imports) + '\n\n' if imports else '')
    return head + text


def main():
    out = pathlib.Path(sys.argv[1])
    out.mkdir(parents=True, exist_ok=True)
    for m in MODS:
        raw = subprocess.run(['git', '-C', str(REPO), 'show', '%s:research/m29/%s.lean' % (REV, m)],
                             capture_output=True, check=True).stdout
        data = convert(m, raw.decode('utf-8')).encode('utf-8')
        (out / (m + '.lean')).write_bytes(data)
        print('%s  source %s@%s  module %s  %d lines' % (m, sha(raw)[:16], REV, sha(data), data.count(b'\n')))


if __name__ == '__main__':
    main()
