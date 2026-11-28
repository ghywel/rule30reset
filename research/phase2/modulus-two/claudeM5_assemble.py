"""K92.4, claudeM5 (M234): assemble a portal source from S32's modules and this folder's.

As S32's assembler (research/phase2/s32/claudeM5_assemble.py): each module's import lines are dropped and its body
is placed inside `namespace Rule30Submission` in build order, with the one kit import hoisted. The seven repacked
data modules reuse private names, so FastData<m> goes into PhaseFalls.Moduli.Data<m> and exports good<m>.
light:    S32's statement with the fast checker (FastRank, FastData3 to FastData17, EveryModulusFast).
combined: light, and the modulus-two theorem and the every-modulus-from-two headline.
Usage: python3 -I claudeM5_assemble.py light|combined FALLING_PHASES_DIR LEAN_DIR HEADER OUT.lean
"""
import pathlib, sys

S32 = ['SixPhysical', 'ModulusStrip', 'ModulusCompress', 'ModulusSlice', 'ModulusRank', 'ModulusLayers']
DATA = ['FastData3', 'FastData4', 'FastData5', 'FastData7', 'FastData11', 'FastData13', 'FastData17']
LIGHT = [('s32', m) for m in S32] + [('new', 'FastRank')] + [('new', m) for m in DATA] + \
        [('s32', 'ModulusSingleton'), ('s32', 'ModulusParity'), ('new', 'EveryModulusFast')]
COMBINED = LIGHT + [('new', m) for m in ['LagCert', 'TwoCerts', 'TwoCover', 'TwoFalls', 'EveryModulusTwo']]

def main():
    mode, s32, new, header, out = sys.argv[1], pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3]), \
        pathlib.Path(sys.argv[4]), pathlib.Path(sys.argv[5])
    order = {'light': LIGHT, 'combined': COMBINED}[mode]
    names = [n for _, n in order]
    parts = ['import Ruliology.CellularAutomata.Rule30StripCertificates\n\n',
             header.read_text(encoding='utf-8').rstrip('\n') + '\n\n', 'namespace Rule30Submission\n']
    kit = set()
    for where, name in order:
        src = (s32 if where == 's32' else new) / f'{name}.lean'
        body = []
        for line in src.read_text(encoding='utf-8').split('\n'):
            if line.startswith('import '):
                mod = line.split()[1]
                if mod.startswith('Ruliology.'): kit.add(mod)
                else: assert mod in names and names.index(mod) < names.index(name), (name, mod)
                continue
            body.append(line)
        text = '\n'.join(body).strip('\n')
        if name.startswith('FastData'):
            m = name[len('FastData'):]
            assert text.count('namespace PhaseFalls.Moduli\n') == 1 and text.count('end PhaseFalls.Moduli') == 1
            assert text.count(f'theorem good{m} ') == 1
            text = text.replace('namespace PhaseFalls.Moduli\n', f'namespace PhaseFalls.Moduli.Data{m}\n')
            text = text.replace('end PhaseFalls.Moduli', f'end PhaseFalls.Moduli.Data{m}')
            text += f'\n\nnamespace PhaseFalls.Moduli\nexport Data{m} (good{m})\nend PhaseFalls.Moduli'
        parts.append(f'\n/-! ## {name} -/\n\n{text}\n')
    assert kit == {'Ruliology.CellularAutomata.Rule30StripCertificates'}, kit
    parts.append('\nend Rule30Submission\n')
    text = ''.join(parts)
    assert '"' not in text and '\\' not in text
    out.write_bytes(text.encode('utf-8'))
    print(out, len(text.encode('utf-8')), 'bytes,', text.count('\n'), 'lines')

if __name__ == '__main__':
    main()
