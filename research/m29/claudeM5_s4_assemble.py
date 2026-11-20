#!/usr/bin/env python3
"""claudeM5_s4_assemble.py: assemble S4's single-file portal form (METHOD 12).

  python3 research/m29/claudeM5_s4_assemble.py OUTFILE

Every part is read from a pinned Git blob, so the result does not depend on the checkout's line endings:
  - the kit's three every-k modules at kit commit 3f32e1a (in the kit clone Rule30PrizeKit/), with the
    module-system lines removed (`module`, `public import`, `@[expose] public section`) and their namespaces moved
    from Ruliology.CellularAutomata.Rule30EveryK* to Rule30Submission.Rule30EveryK*, so that the file can be imported
    beside the kit's own copies (METHOD 12, step 2; gptIntel's repair in I33);
  - our four modules at this repository's commit ab2c0fd, with their imports and #print lines removed;
  - the two headlines in Rule30Submission.
Two `open` lines make the moved names resolve: Ruliology.CellularAutomata before the kit's copies, and
Rule30Submission before the compactness module. No proof body changes. Each fragment is normalised to LF, the
result is encoded to UTF-8 once, written as bytes, and those same bytes are hashed.
"""
import hashlib
import pathlib
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parents[2]
KIT, KITREV = REPO / 'Rule30PrizeKit', '3f32e1a'
OURREV = 'ab2c0fd'
IMPORTS = ['Rule30ZeroBoundary', 'Rule30UniversalLeftSide', 'Rule30AgedLeftDiagonals', 'Rule30LeftUnbounded']
KITMODS = ['Rule30EveryKStatement', 'Rule30EveryKCascade', 'Rule30EveryKInverse']
LOCAL = ['Rule30ThreePhaseReturn', 'Rule30RootedWhiteReturns', 'Rule30RecurrentStrip', 'Rule30ResetCompactness']

HEADER = '''
/-!
# Unbounded closed runs on recurrent strips give reset capacity, and so every k

One file. First the kit's three every-k modules (`Rule30EveryKStatement`, `Rule30EveryKCascade`,
`Rule30EveryKInverse`), which the verifier's kit revision does not have, as they stand at kit commit 3f32e1a with
the module-system lines removed and their namespaces moved inside `Rule30Submission`. Then four modules of ours: two
returns along a strip, rooted white returns, pointed recurrent strips, and the compactness argument. The headlines are
in `Rule30Submission` at the end.
-/
'''

HEADLINES = '''
namespace Rule30Submission

open Ruliology.CellularAutomata Rule30EveryKStatement Rule30ResetCompactness

/-- Closed runs at arbitrarily large depths in every prescribed phase of every pointed recurrent strip give the
kit's reset capacity `CAP`. -/
theorem cap_of_unbounded_resets : LInfinity → CAP :=
  Rule30ResetCompactness.cap_of_unbounded_resets

/-- With the conditional every-k theorem, the same hypothesis gives the inverse-tick target for every k. -/
theorem every_k_of_unbounded_resets : LInfinity → ∀ k, ∃ age, TargetAt k age :=
  fun deep k => ⟨_, Rule30EveryKInverse.conditional_every_k (Rule30ResetCompactness.cap_of_unbounded_resets deep) k⟩

end Rule30Submission
'''


def sha(b):
    return hashlib.sha256(b).hexdigest()


def blob(repo, rev, path):
    raw = subprocess.run(['git', '-C', str(repo), 'show', '%s:%s' % (rev, path)], capture_output=True, check=True).stdout
    return raw, raw.decode('utf-8').replace('\r\n', '\n')


def main():
    out = pathlib.Path(sys.argv[1])
    parts = ['\n'.join('import Ruliology.CellularAutomata.' + m for m in IMPORTS) + '\n', HEADER]
    for i, m in enumerate(KITMODS):
        raw, text = blob(KIT, KITREV, 'lean/Ruliology/CellularAutomata/%s.lean' % m)
        print('kit %s@%s %s' % (m, KITREV, sha(raw)))
        keep = []
        for line in text.split('\n'):
            if line.strip() in ('module', '@[expose] public section') or line.startswith('public import '):
                continue
            if line == 'namespace Ruliology.CellularAutomata.' + m:
                if i == 0:
                    keep.append('open Ruliology.CellularAutomata')
                line = 'namespace Rule30Submission.' + m
            elif line == 'end Ruliology.CellularAutomata.' + m:
                line = 'end Rule30Submission.' + m
            keep.append(line)
        body = '\n'.join(keep).strip('\n')
        assert ('namespace Rule30Submission.' + m) in body and ('end Rule30Submission.' + m) in body, m
        parts.append('\n' + body + '\n')
    for m in LOCAL:
        raw, text = blob(REPO, OURREV, 'research/m29/%s.lean' % m)
        print('local %s@%s %s' % (m, OURREV, sha(raw)))
        keep = []
        for line in text.split('\n'):
            if line.startswith('import ') or line.startswith('#print '):
                continue
            if line == 'namespace Rule30ResetCompactness':
                keep.append('open Rule30Submission')
            keep.append(line)
        parts.append('\n' + '\n'.join(keep).strip('\n') + '\n')
    parts.append(HEADLINES)
    src = ''.join(parts)
    assert '"' not in src and '\\' not in src and '\r' not in src, 'quote, backslash or CR in the source'
    assert 'Ruliology.CellularAutomata.Rule30EveryK' not in src, 'a kit namespace was left in place'
    data = src.encode('utf-8')
    out.write_bytes(data)
    print('Rule30Submission.lean %s %d lines %d bytes' % (sha(data), src.count('\n'), len(data)))


if __name__ == '__main__':
    main()
