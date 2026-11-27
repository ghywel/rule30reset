"""S32, claudeM5: assemble the portal source from gptIntel's sixteen modules (I312), unchanged apart from the wrapper.

Each module's import lines are dropped, and its body, with its own namespace, is placed inside
`namespace Rule30Submission`. The one kit import is hoisted. The order is the build order of every-modulus.md.
The seven data modules reuse the same private names (rest3, group3_0, ...), which one file cannot hold twice. So
ModulusData<m> goes into the nested namespace PhaseFalls.Moduli.Data<m>, and its one public theorem good<m> is
exported back to PhaseFalls.Moduli. Nothing else in any module changes.
Usage: python3 -I claudeM5_assemble.py SRCDIR HEADER OUT.lean
"""
import pathlib, sys

ORDER = ['SixPhysical', 'ModulusStrip', 'ModulusCompress', 'ModulusSlice', 'ModulusRank', 'ModulusLayers',
         'ModulusData3', 'ModulusData4', 'ModulusData5', 'ModulusData7', 'ModulusData11', 'ModulusData13',
         'ModulusData17', 'ModulusSingleton', 'ModulusParity', 'EveryModulus']

def main():
    src, header, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])
    parts = ['import Ruliology.CellularAutomata.Rule30StripCertificates\n\n', header.read_text(encoding='utf-8').rstrip('\n') + '\n\n',
             'namespace Rule30Submission\n']
    kit = set()
    for name in ORDER:
        body = []
        for line in (src / f'{name}.lean').read_text(encoding='utf-8').split('\n'):
            if line.startswith('import '):
                mod = line.split()[1]
                if mod.startswith('Ruliology.'): kit.add(mod)
                else: assert mod in ORDER, mod
                continue
            body.append(line)
        text = '\n'.join(body).strip('\n')
        if name.startswith('ModulusData'):
            m = name[len('ModulusData'):]
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
