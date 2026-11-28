"""K92.4, claudeM5 (M236): the portal source for the modulus-two add-on, sealed at the verifier's pin 5fb5915.

The pin lacks the two kit modules the add-on builds on, which reached the kit (main 0f41bf3) with the S32 entry. They
are carried from kit main in the nested namespace Rule30Submission.KitFallResidues, with their text unchanged apart
from these edits:
  * the `module` header, `public import` lines and `@[expose] public section` are dropped (one plain file);
  * `Ruliology.CellularAutomata.Rule30FallResidues` becomes `Rule30Submission.KitFallResidues`;
  * Rule30Certificates/FallResidueStrip is carried whole;
  * from Rule30FallResidues only the definitions `Fall` and `Cofinal` are carried, with their `open` line: the rest
    of that module is the S32 entry's theorem and its tables, which the add-on does not use.
The add-on's three kit modules (claudeM5_addon_kit.py) follow, in build order, with the same edits and
`Ruliology.CellularAutomata.Rule30FallParities` becoming `Rule30Submission.FallParities`. Each part names its full
namespace, so there is no enclosing `namespace Rule30Submission`.
Usage: python3 -I claudeM5_addon_portal.py KIT_LEAN_DIR(at main, with the add-on's modules) HEADER.lean OUT.lean
"""
import pathlib, sys

CA = 'Ruliology/CellularAutomata'
PIN_IMPORTS = ['Ruliology.CellularAutomata.Rule30StripCertificates']
ADDON = ['Rule30Certificates/FallParityLag', 'Rule30Certificates/FallParityData', 'Rule30FallParities']

def rename(t):
    t = t.replace('Ruliology.CellularAutomata.Rule30FallResidues', 'Rule30Submission.KitFallResidues')
    t = t.replace('Ruliology.CellularAutomata.Rule30FallParities', 'Rule30Submission.FallParities')
    t = t.replace('open Ruliology.CellularAutomata Rule30StripCertificates Rule30FallResidues',
                  'open Ruliology.CellularAutomata Rule30StripCertificates Rule30Submission.KitFallResidues')
    return t

def plain(path, allowed):
    lines = path.read_text(encoding='utf-8').split('\n')
    assert lines[0] == 'module', path
    for l in lines:
        if l.startswith('public import '): assert l.split()[2] in allowed, (path, l)
    body = [l for l in lines[1:] if not l.startswith('public import ') and l != '@[expose] public section']
    return '\n'.join(body).strip('\n')

def main():
    kit, header, out = (pathlib.Path(a) for a in sys.argv[1:4])
    known = set(PIN_IMPORTS) | {'Ruliology.CellularAutomata.Rule30Certificates.FallResidueStrip',
                                'Ruliology.CellularAutomata.Rule30FallResidues'} | \
            {'Ruliology.CellularAutomata.' + m.replace('/', '.') for m in ADDON}
    parts = [''.join(f'import {i}\n' for i in PIN_IMPORTS), '\n', header.read_text(encoding='utf-8').rstrip('\n'), '\n']
    strip = plain(kit / CA / 'Rule30Certificates/FallResidueStrip.lean', set(PIN_IMPORTS))
    parts.append(f'\n/-! ## Carried from the kit at main: Rule30Certificates.FallResidueStrip -/\n\n{rename(strip)}\n')
    full = (kit / CA / 'Rule30FallResidues.lean').read_text(encoding='utf-8')
    start = full.index('open Ruliology.CellularAutomata.Rule30Jen\n\ndef Fall (i : Int)')
    stop = full.index('private theorem escape', start)
    defs = full[start:stop].strip('\n')
    assert defs.count('def ') == 2 and 'def Fall' in defs and 'def Cofinal' in defs, defs
    parts.append('\n/-! ## Carried from the kit at main: Fall and Cofinal, from Rule30FallResidues -/\n\n'
                 f'namespace Rule30Submission.KitFallResidues\n\n{defs}\n\nend Rule30Submission.KitFallResidues\n')
    for m in ADDON:
        parts.append(f'\n/-! ## {m.split("/")[-1]} -/\n\n{rename(plain(kit / CA / (m + ".lean"), known))}\n')
    text = ''.join(parts)
    assert '"' not in text and '\\' not in text and '#print' not in text
    assert 'Ruliology.CellularAutomata.Rule30Fall' not in text
    out.write_bytes(text.encode('utf-8'))
    print(out, len(text.encode('utf-8')), 'bytes,', text.count('\n'), 'lines')

if __name__ == '__main__':
    main()
