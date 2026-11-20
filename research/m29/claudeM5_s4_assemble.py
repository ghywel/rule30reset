#!/usr/bin/env python3
"""claudeM5_s4_assemble.py: assemble S4's single-file portal form (METHOD 12): the kit's three every-k modules at 3f32e1a with the
module-system lines removed, then the four local modules with their imports and #print lines removed, then the
headlines. Prints each part's source digest so a reader can redo it."""
import hashlib, subprocess, sys, pathlib
REPO = pathlib.Path(__file__).resolve().parents[2]
KIT, REV = REPO / 'Rule30PrizeKit', '3f32e1a'
OUT = pathlib.Path(sys.argv[1])
IMPORTS = ['Rule30ZeroBoundary', 'Rule30UniversalLeftSide', 'Rule30AgedLeftDiagonals', 'Rule30LeftUnbounded']
KITMODS = ['Rule30EveryKStatement', 'Rule30EveryKCascade', 'Rule30EveryKInverse']
LOCAL = ['Rule30ThreePhaseReturn', 'Rule30RootedWhiteReturns', 'Rule30RecurrentStrip', 'Rule30ResetCompactness']

def sha(b): return hashlib.sha256(b).hexdigest()

parts = ['\n'.join('import Ruliology.CellularAutomata.' + m for m in IMPORTS) + '\n', '''
/-!
# Unbounded closed runs on recurrent strips give reset capacity, and so every k

One file. First the kit's three every-k modules (`Rule30EveryKStatement`, `Rule30EveryKCascade`,
`Rule30EveryKInverse`), which the verifier's kit revision does not have, as they stand at kit commit 3f32e1a with
only the module-system lines removed. Then four modules of ours: two returns along a strip, rooted white returns,
pointed recurrent strips, and the compactness argument. The headlines are in `Rule30Submission` at the end.
-/
''']
for m in KITMODS:
    raw = subprocess.run(['git', '-C', str(KIT), 'show', '%s:lean/Ruliology/CellularAutomata/%s.lean' % (REV, m)],
                         capture_output=True, check=True).stdout
    print('kit %s@%s %s' % (m, REV, sha(raw)))
    keep = [l for l in raw.decode().split('\n')
            if l.strip() != 'module' and not l.startswith('public import ') and l.strip() != '@[expose] public section']
    parts.append('\n' + '\n'.join(keep).strip('\n') + '\n')
for m in LOCAL:
    raw = (REPO / 'research/m29' / (m + '.lean')).read_bytes()
    print('local %s %s' % (m, sha(raw)))
    keep = [l for l in raw.decode().split('\n') if not l.startswith('import ') and not l.startswith('#print ')]
    parts.append('\n' + '\n'.join(keep).strip('\n') + '\n')
parts.append('''
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
''')
src = ''.join(parts)
assert '"' not in src and '\\\\' not in src and '\\' not in src, 'quote or backslash in the source'
OUT.write_text(src)
print('Rule30Submission.lean %s %d lines %d bytes' % (sha(src.encode()), src.count('\n'), len(src.encode())))
