"""S33, claudeM5: the portal source for gptIntel's ClockPhasePairs (I321, I327), sealed at the verifier's pin.

The verifier's kit revision (5fb5915) lacks four modules the proof needs. They are carried from kit main ea5d70e
in nested namespaces of Rule30Submission, with their authors' text unchanged apart from these edits:
  * the `module` header, `public import` lines and `@[expose] public section` are dropped (one plain file);
  * `Ruliology.CellularAutomata.Rule30<X>` becomes `Rule30Submission.Kit<X>` for the four carried modules;
  * Rule30ThreePhaseReturn, Rule30RootedWhiteReturns and Rule30RecurrentStrip are carried whole;
  * Rule30RelaxedWindows is trimmed: its definitions, DLMinusOne, unbounded_first_losses, exists_next_white, DL,
    dlMinusOne_of_dl and firstLoss_cascade_and_immediate_catch are kept; lInfinity_of_windows,
    lInfinity_of_dlMinusOne and everyK_of_dlMinusOne (which need the every-k chain) and the two certificates after
    the cascade are left out, and so are the two `open` lines of the modules left behind.
The headline module is ClockPhasePairs.lean, its namespace ClockPhasePairs becoming Rule30Submission.ClockPhasePairs,
with its opens pointed at the carried namespaces and its three `#print axioms` lines dropped. Each part names its
full namespace, so there is no enclosing `namespace Rule30Submission`.

Usage: python3 -I claudeM5_s33_assemble.py KIT_LEAN_DIR(at ea5d70e) CLOCK.lean HEADER.lean OUT.lean
"""
import pathlib, sys

CARRIED = ['Rule30ThreePhaseReturn', 'Rule30RootedWhiteReturns', 'Rule30RecurrentStrip', 'Rule30RelaxedWindows']
PIN_IMPORTS = ['Ruliology.CellularAutomata.Rule30Prize', 'Ruliology.CellularAutomata.Rule30AgedLeftDiagonals',
               'Ruliology.CellularAutomata.Rule30LeftUnbounded']

def rename(t):
    for m in CARRIED:
        t = t.replace(f'Ruliology.CellularAutomata.{m}', f'Rule30Submission.Kit{m[len("Rule30"):]}')
    return t

def carry(kit, m):
    lines = (kit / f'Ruliology/CellularAutomata/{m}.lean').read_text(encoding='utf-8').split('\n')
    imports = [l.split()[2] for l in lines if l.startswith('public import ')]
    assert lines[0] == 'module'
    body = [l for l in lines[1:] if not l.startswith('public import ') and l != '@[expose] public section']
    text = '\n'.join(body).strip('\n')
    if m == 'Rule30RelaxedWindows':
        cut1 = text.index('/-- The window argument only uses')
        keep2 = text.index('def DL : Prop')
        cut2 = text.index('private def backColPair')
        end = text.index('end Ruliology.CellularAutomata.Rule30RelaxedWindows')
        text = text[:cut1].rstrip('\n') + '\n\n' + text[keep2:cut2].rstrip('\n') + '\n\n' + text[end:]
        for line in ['open Rule30AgedLeftDiagonals Rule30EveryKStatement\n',
                     'open Ruliology.CellularAutomata.Rule30ResetCompactness (LInfinity cap_of_unbounded_resets)\n']:
            assert text.count(line) == 1, line
        text = text.replace('open Rule30AgedLeftDiagonals Rule30EveryKStatement\n', 'open Rule30AgedLeftDiagonals\n')
        text = text.replace('open Ruliology.CellularAutomata.Rule30ResetCompactness (LInfinity cap_of_unbounded_resets)\n', '')
        for gone in ('Rule30EveryK', 'ResetCompactness', 'LInfinity', 'everyK'):
            assert gone not in text, gone
    for i in imports:          # Rule30RelaxedWindows' one import serves only the parts left out
        assert i in PIN_IMPORTS or i.split('.')[-1] in CARRIED or (m, i) == ('Rule30RelaxedWindows',
            'Ruliology.CellularAutomata.Rule30ResetCompactness'), (m, i)
    return rename(text)

def main():
    kit, clock, header, out = (pathlib.Path(a) for a in sys.argv[1:5])
    parts = [''.join(f'import {i}\n' for i in PIN_IMPORTS), '\n', header.read_text(encoding='utf-8').rstrip('\n'), '\n']
    for m in CARRIED:
        parts.append(f'\n/-! ## Carried from the kit at ea5d70e: {m} -/\n\n{carry(kit, m)}\n')
    src = clock.read_text(encoding='utf-8').split('\n')
    assert src[0] == 'import Ruliology.CellularAutomata.Rule30RelaxedWindows'
    body = '\n'.join(l for l in src[1:] if not l.startswith('#print axioms')).strip('\n')
    for a, b in [('open Rule30AgedLeftDiagonals Rule30RootedWhiteReturns Rule30RelaxedWindows',
                  'open Rule30AgedLeftDiagonals KitRootedWhiteReturns KitRelaxedWindows'),
                 ('Rule30RecurrentStrip.Clock', 'KitRecurrentStrip.Clock'),
                 ('namespace ClockPhasePairs\n', 'namespace Rule30Submission.ClockPhasePairs\n'),
                 ('end ClockPhasePairs', 'end Rule30Submission.ClockPhasePairs')]:
        assert body.count(a) == 1, a
        body = body.replace(a, b)
    parts.append(f'\n/-! ## The theorems -/\n\n{body}\n')
    text = ''.join(parts)
    assert '"' not in text and '\\' not in text and '#print' not in text
    out.write_bytes(text.encode('utf-8'))
    print(out, len(text.encode('utf-8')), 'bytes,', text.count('\n'), 'lines')

if __name__ == '__main__':
    main()
