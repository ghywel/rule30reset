"""S33, claudeM5: the kit form of gptIntel's ClockPhasePairs.lean as Ruliology.CellularAutomata.Rule30ClockPhasePairs.

Only the wrapper changes: the `module` header, the public import, an opening docstring and `@[expose] public section`;
the namespace ClockPhasePairs becomes Ruliology.CellularAutomata.Rule30ClockPhasePairs; the three `#print axioms`
lines go. The proof text is untouched.
Usage: python3 -I claudeM5_s33_kit.py CLOCK.lean DOC.lean OUT.lean
"""
import pathlib, sys
src, doc, out = (pathlib.Path(a) for a in sys.argv[1:4])
lines = src.read_text(encoding='utf-8').split('\n')
assert lines[0] == 'import Ruliology.CellularAutomata.Rule30RelaxedWindows'
body = '\n'.join(l for l in lines[1:] if not l.startswith('#print axioms')).strip('\n')
NS = 'Ruliology.CellularAutomata.Rule30ClockPhasePairs'
for a, b in [('namespace ClockPhasePairs\n', f'namespace {NS}\n'), ('end ClockPhasePairs', f'end {NS}')]:
    assert body.count(a) == 1, a
    body = body.replace(a, b)
text = ('module\n\npublic import Ruliology.CellularAutomata.Rule30RelaxedWindows\n\n' + doc.read_text(encoding='utf-8').strip('\n')
        + '\n\n@[expose] public section\n\n' + body + '\n')
out.write_bytes(text.encode('utf-8'))
print(out, len(text.encode('utf-8')), 'bytes')
