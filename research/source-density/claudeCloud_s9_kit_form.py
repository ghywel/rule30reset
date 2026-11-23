#!/usr/bin/env python3
"""claudeCloud_s9_kit_form.py: the kit form of S9's thirteen modules (METHOD 12, step 2, the kit route; ledger K70).

  python3 research/source-density/claudeCloud_s9_kit_form.py KIT ROWS

KIT is a clean checkout of the kit at its main; ROWS is the text of the catalogue rows to add (one row per line).
It changes the checkout in place, so that `git diff` there is the patch:
  - the thirteen modules go to lean/Ruliology/CellularAutomata/, each read from this folder by an asserted SHA-256.
    Only import lines change: a bare `public import Rule30X` of one of the thirteen becomes
    `public import Ruliology.CellularAutomata.Rule30X`. Line ends are normalised to LF, as in the single file (one
    module arrived with CRLF). No declaration, namespace or docstring changes;
  - lean/Ruliology.lean gains their thirteen `public import` lines after its last one;
  - Rule30PrizeKit.lean's module count grows by thirteen;
  - lean/README.md gains the rows, after the last row of "Added in the kit".
It prints each module's digest before and after, and the count line. It refuses if a module name already exists in
the kit or if a digest is not the pinned one.
"""
import hashlib
import pathlib
import re
import sys

HERE = pathlib.Path(__file__).resolve().parent
MODULES = [
    ('Rule30SourceDensityRegion', '33b4c5e4cf963237'),
    ('Rule30SourceDensityCorners', '6110ba271b933c22'),
    ('Rule30DensitySharpness', '910b803222632f4f'),
    ('Rule30SourceTransitions', 'c1a7e6ace524b8b3'),
    ('Rule30DensityPolygon', 'b081c42eb283fed3'),
    ('Rule30DensityEscape', '63af32bbc0b09b8c'),
    ('Rule30DensityMargin', 'e37db0c8ca23c3cd'),
    ('Rule30DensityControl', 'e6c259a780bb8403'),
    ('Rule30DensityModes', '22dcaf9ec1f54ccd'),
    ('Rule30DensityVertices', '1567d057ea09d18f'),
    ('Rule30DensityOneHistory', 'dd4031d808e4b185'),
    ('Rule30DensityCornerHistories', 'f50cabc31840cc8e'),
    ('Rule30DensityMixtures', 'cb15c8dd7657430b'),
]
PREFIX = 'Ruliology.CellularAutomata.'


def sha(b):
    return hashlib.sha256(b).hexdigest()


def main():
    kit, rows_file = pathlib.Path(sys.argv[1]).resolve(), pathlib.Path(sys.argv[2]).resolve()
    names = {m for m, _ in MODULES}
    cat = kit / 'lean/Ruliology/CellularAutomata'
    for m, want in MODULES:
        raw = (HERE / (m + '.lean')).read_bytes()
        assert sha(raw).startswith(want), 'not the pinned module: ' + m
        assert not (cat / (m + '.lean')).exists(), 'the kit already has ' + m
        text = raw.decode('utf-8')
        crlf = text.count('\r\n')
        text = text.replace('\r\n', '\n')
        assert '\r' not in text, m
        changed = 0
        lines = []
        for line in text.split('\n'):
            mo = re.match(r'^public import (\w+)$', line)
            if mo and mo.group(1) in names:
                line = 'public import ' + PREFIX + mo.group(1)
                changed += 1
            lines.append(line)
        out = '\n'.join(lines).encode('utf-8')
        (cat / (m + '.lean')).write_bytes(out)
        print('%-30s %s -> %s  (%d import line(s) changed%s)' % (
            m, sha(raw)[:16], sha(out), changed, ', %d CRLF line ends made LF' % crlf if crlf else ''))

    umbrella = kit / 'lean/Ruliology.lean'
    lines = umbrella.read_text().split('\n')
    last = max(i for i, l in enumerate(lines) if l.startswith('public import '))
    lines[last + 1:last + 1] = ['public import ' + PREFIX + m for m, _ in MODULES]
    umbrella.write_text('\n'.join(lines))

    root = kit / 'Rule30PrizeKit.lean'
    text = root.read_text()
    mo = re.search(r'brings the whole catalog, (\d+) modules', text)
    old = int(mo.group(1))
    root.write_text(text.replace(mo.group(0), 'brings the whole catalog, %d modules' % (old + len(MODULES)), 1))
    print('module count %d -> %d' % (old, old + len(MODULES)))

    rows = [l for l in rows_file.read_text().split('\n') if l.startswith('| `')]
    readme = kit / 'lean/README.md'
    lines = readme.read_text().split('\n')
    start = lines.index('## Added in the kit')
    end = next(i for i in range(start + 1, len(lines)) if lines[i].startswith('## '))
    last = max(i for i in range(start, end) if lines[i].startswith('| `'))
    lines[last + 1:last + 1] = rows
    readme.write_text('\n'.join(lines))
    print('%d catalogue row(s) added after line %d of lean/README.md' % (len(rows), last + 1))


if __name__ == '__main__':
    main()
