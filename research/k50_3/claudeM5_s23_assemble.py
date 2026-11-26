#!/usr/bin/env python3
"""claudeM5_s23_assemble.py: the portal form of S23, Hughes's inverse ticks beside every prescribed wall (M197).

  python3 research/k50_3/claudeM5_s23_assemble.py OUTFILE

S6's method (claudeM5_s6_assemble.py): every part from a pinned Git blob, normalised to LF, its module-system and
`#print` lines removed and its namespace moved from Ruliology.CellularAutomata.X to Rule30Submission.X.
  - Hughes's three kit modules at kit commit 40017e8, which the verifier's 5fb5915 lacks, as in S6;
  - `Rule30TwoSidedInverse` at this repository's e4d7d0b (S6's module, as in the kit);
  - gptM5's `Rule30DrivenLeftInverse` at bbfbbc5 (R130, SHA-256 0337220d...).
`Rule30DrivenLeft`, `Rule30ZeroBoundary` and `Rule30FiniteConfigs` are the verifier's own. The headlines are the
module's theorems, in `Rule30Submission.Rule30DrivenLeftInverse`. No proof body changes.
"""
import hashlib
import importlib.util
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('s6', HERE / 'claudeM5_s6_assemble.py')
s6 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(s6)

IMPORTS = ['Rule30ZeroBoundary', 'Rule30FiniteConfigs', 'Rule30DrivenLeft', 'Rule30Prize']
KITMODS = ['Rule30LateTwins', 'Rule30AgeEightInverse', 'Rule30AgeTwentyFourInverse']
LOCAL = [('Rule30TwoSidedInverse', 'e4d7d0b', '2125f3cf'), ('Rule30DrivenLeftInverse', 'bbfbbc5', '0337220d')]
s6.MOVED = KITMODS + [m for m, _, _ in LOCAL]

HEADER = '''
/-!
# Hughes's inverse ticks beside every prescribed wall

One file. First Hughes's three kit modules that the verifier's kit revision does not have, as they stand at kit
commit 40017e8 (`Rule30LateTwins`, `Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`), and `Rule30TwoSidedInverse`,
Hughes's inverse theorems on the line, with the module-system lines removed and their namespaces moved inside
`Rule30Submission`. Then `Rule30DrivenLeftInverse`: the same theorems for the kit's driven left half
(`Rule30DrivenLeft.L`), beside a wall column with any values, with their least ages. Its theorems are the headlines.
-/
'''


def main():
    out = pathlib.Path(sys.argv[1])
    parts = ['\n'.join('import Ruliology.CellularAutomata.' + m for m in IMPORTS) + '\n', HEADER]
    first = True
    for m in KITMODS:
        raw, text = s6.blob(s6.KIT, s6.KITREV, 'lean/Ruliology/CellularAutomata/%s.lean' % m)
        print('kit %s@%s %s' % (m, s6.KITREV, s6.sha(raw)))
        parts.append(s6.carry(m, text, first))
        first = False
    for m, rev, pre in LOCAL:
        raw, text = s6.blob(s6.REPO, rev, 'research/k50_3/%s.lean' % m)
        assert s6.sha(raw).startswith(pre), m
        print('local %s@%s %s' % (m, rev, s6.sha(raw)))
        parts.append(s6.carry(m, text, False))
    src = ''.join(parts)
    assert '"' not in src and '\\' not in src and '\r' not in src, 'quote, backslash or CR in the source'
    for m in s6.MOVED:
        assert ('Ruliology.CellularAutomata.' + m) not in src, 'a kit namespace was left in place: ' + m
    data = src.encode('utf-8')
    out.write_bytes(data)
    print('Rule30Submission.lean %s %d lines %d bytes' % (hashlib.sha256(data).hexdigest(), src.count('\n'), len(data)))


if __name__ == '__main__':
    main()
