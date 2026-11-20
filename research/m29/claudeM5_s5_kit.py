#!/usr/bin/env python3
"""claudeM5_s5_kit.py: S5's catalogue module for the kit, from our pinned source (METHOD 12, step 8).

  python3 research/m29/claudeM5_s5_kit.py OUTDIR

Reads Rule30RelaxedWindows at this repository's commit a27d0ad (the source S5 carries) and writes it in the kit's
module form with the same conversion as S4's modules (claudeM5_s4_kit.py, imported and unchanged): `module` and
`public import` lines, `@[expose] public section`, the namespace under Ruliology.CellularAutomata, `open` lines that
name one of our modules given in full, and `#print` lines removed. Two doc comments are reworded so that they name
no internal post or label: the one S5's portal file rewords, and the module comment, which named "Theorem C′". It
imports Rule30ResetCompactness, which S4's kit pull request adds, so it builds on top of that pull request. No proof
body changes.
"""
import pathlib
import subprocess
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import claudeM5_s4_kit as s4  # noqa: E402

NAME, REV = 'Rule30RelaxedWindows', 'a27d0ad'
REWORD = [("/-- M62's first relaxation, in its rooted strip form. -/",
           '/-- The first relaxation of the doubling lemma, in its rooted strip form. -/'),
          ('/-! Theorem C′ on pointed recurrent strips. The open reset hypothesis is confined\n'
           'to a first clock loss and exactly the two white intervals starting there. -/',
           '/-! Windows that catch every tick, and the relaxed doubling lemma, on pointed recurrent\n'
           'strips. The open reset hypothesis is confined to a first clock loss and exactly the two\n'
           'white intervals starting there. -/')]


def main():
    out = pathlib.Path(sys.argv[1])
    out.mkdir(parents=True, exist_ok=True)
    s4.MODS.append(NAME)  # so that its import of, and opens of, our other modules are recognised
    raw = subprocess.run(['git', '-C', str(s4.REPO), 'show', '%s:research/m29/%s.lean' % (REV, NAME)],
                         capture_output=True, check=True).stdout
    text = raw.decode('utf-8')
    for a, b in REWORD:
        assert text.count(a) == 1, a
        text = text.replace(a, b)
    data = s4.convert(NAME, text).encode('utf-8')
    assert b'M62' not in data and 'Theorem C′'.encode() not in data
    (out / (NAME + '.lean')).write_bytes(data)
    print('%s  source %s@%s  module %s  %d lines' % (NAME, s4.sha(raw)[:16], REV, s4.sha(data), data.count(b'\n')))


if __name__ == '__main__':
    main()
