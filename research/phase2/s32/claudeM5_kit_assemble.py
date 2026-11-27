"""S32, claudeM5: the kit form of gptIntel's sixteen modules (I312), as nine kit modules.

  Rule30Certificates/FallResidueStrip.lean        ModulusStrip, ModulusSlice, ModulusRank, ModulusLayers
  Rule30Certificates/FallResidues<m>.lean         ModulusData<m>, m = 3, 4, 5, 7, 11, 13, 17
  Rule30FallResidues.lean                         SixPhysical, ModulusCompress, ModulusSingleton, ModulusParity,
                                                  EveryModulus
Only the wrapper changes: the `module` header and public imports, `@[expose] public section`, the namespaces
(PhaseFalls.Moduli -> Ruliology.CellularAutomata.Rule30FallResidues, PhaseFalls.Six -> ...Rule30FallResidues.Six),
and the opening docstrings. Proof text is untouched.
Usage: python3 -I claudeM5_kit_assemble.py SRCDIR DOCDIR KIT/lean/Ruliology/CellularAutomata
"""
import pathlib, sys

NS = 'Ruliology.CellularAutomata.Rule30FallResidues'
P = 'Ruliology.CellularAutomata.'

def body(src, name, drop_doc=False):
    out = []
    for line in (src / f'{name}.lean').read_text(encoding='utf-8').split('\n'):
        if line.startswith('import '): continue
        out.append(line)
    t = '\n'.join(out).strip('\n')
    if drop_doc:                                  # the file's opening /-! ... -/ comment, replaced by the kit's
        assert t.startswith('/-!')
        t = t[t.index('-/') + 2:].lstrip('\n')
    assert t.count('namespace PhaseFalls.') == 1
    t = t.replace('PhaseFalls.Moduli', NS).replace('PhaseFalls.Six', NS + '.Six')
    assert 'PhaseFalls' not in t
    return t

def write(path, imports, doc, bodies):
    text = 'module\n\n' + ''.join(f'public import {i}\n' for i in imports) + '\n' + doc.strip('\n') + '\n\n@[expose] public section\n\n' + '\n\n'.join(bodies) + '\n'
    path.write_bytes(text.encode('utf-8'))
    print(path.name, len(text.encode('utf-8')), 'bytes')

def main():
    src, docs, kit = (pathlib.Path(a) for a in sys.argv[1:4])
    cert = kit / 'Rule30Certificates'
    doc = lambda n: (docs / n).read_text(encoding='utf-8')
    write(cert / 'FallResidueStrip.lean', [P + 'Rule30StripCertificates'], doc('kit_doc_strip.lean'),
          [body(src, n) for n in ('ModulusStrip', 'ModulusSlice', 'ModulusRank', 'ModulusLayers')])
    for m in (3, 4, 5, 7, 11, 13, 17):
        write(cert / f'FallResidues{m}.lean', [P + 'Rule30Certificates.FallResidueStrip'],
              doc('kit_doc_data.lean').replace('{M}', str(m)), [body(src, f'ModulusData{m}', drop_doc=True)])
    write(kit / 'Rule30FallResidues.lean',
          [P + 'Rule30Certificates.FallResidueStrip'] + [P + f'Rule30Certificates.FallResidues{m}' for m in (3, 4, 5, 7, 11, 13, 17)],
          doc('kit_doc_main.lean'),
          [body(src, n) for n in ('SixPhysical', 'ModulusCompress', 'ModulusSingleton', 'ModulusParity', 'EveryModulus')])

if __name__ == '__main__':
    main()
