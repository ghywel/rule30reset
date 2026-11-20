#!/usr/bin/env python3
"""claudeM5_s5_assemble.py: assemble S5's single-file portal form (METHOD 12).

  python3 research/m29/claudeM5_s5_assemble.py OUTFILE

S5 is built on S4's file, part for part (claudeM5_s4_assemble.py, which this script imports and does not change):
  - the kit's three every-k modules at kit commit 3f32e1a, in Rule30Submission.Rule30EveryK*;
  - our four modules at this repository's commit ab2c0fd;
and adds one more module of ours, Rule30RelaxedWindows, at commit a27d0ad, with its import and #print lines removed
and one doc comment reworded so that it names no internal post ("M62's first relaxation" becomes "The first
relaxation of the doubling lemma"). S4's two headlines are left out; S5's three are in Rule30Submission at the end:
the window theorem for any windows, the relaxed doubling lemma's case of it, and the composition to every k.
Every part is read from a pinned Git blob and normalised to LF; the bytes written are the bytes hashed.
"""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import claudeM5_s4_assemble as s4  # noqa: E402

RELAXED, RELAXEDREV = 'Rule30RelaxedWindows', 'a27d0ad'
REWORD = [('/-- M62\'s first relaxation, in its rooted strip form. -/',
           '/-- The first relaxation of the doubling lemma, in its rooted strip form. -/')]

HEADER = '''
/-!
# The relaxed doubling lemma gives closed runs at every depth, and so every k

One file. First the kit's three every-k modules (`Rule30EveryKStatement`, `Rule30EveryKCascade`,
`Rule30EveryKInverse`), which the verifier's kit revision does not have, as they stand at kit commit 3f32e1a with
the module-system lines removed and their namespaces moved inside `Rule30Submission`. Then five modules of ours: two
returns along a strip, rooted white returns, pointed recurrent strips, the compactness argument, and the relaxed
windows. The headlines are in `Rule30Submission` at the end.
-/
'''

HEADLINES = '''
namespace Rule30Submission

open Ruliology.CellularAutomata Rule30EveryKStatement Rule30ResetCompactness Rule30RelaxedWindows

/-- Any windows of wheels, with starts beyond every depth on each pointed recurrent strip, that hold a closed run in
every prescribed phase give closed runs at arbitrarily large depths in every phase. -/
theorem lInfinity_of_windows :
    (∀ (d : Nat → Nat → Bool), Rule30AgedLeftDiagonals.Recurrence d → d 0 0 = true → PrefixClocks d →
      ∀ lo, ∃ a c, lo ≤ a ∧ ∀ s, Catch d a c s) → LInfinity :=
  Rule30RelaxedWindows.lInfinity_of_windows

/-- The relaxed doubling lemma, a statement about the two white intervals after each first clock loss, gives closed
runs at arbitrarily large depths in every prescribed phase of every pointed recurrent strip. -/
theorem lInfinity_of_dlMinusOne : DLMinusOne → LInfinity :=
  Rule30RelaxedWindows.lInfinity_of_dlMinusOne

/-- With the compactness theorem and the conditional every-k theorem, the same hypothesis gives the inverse-tick
target for every k. -/
theorem every_k_of_dlMinusOne : DLMinusOne → ∀ k, ∃ age, TargetAt k age :=
  fun h k => ⟨_, Rule30RelaxedWindows.everyK_of_dlMinusOne h k⟩

end Rule30Submission
'''


def main():
    out = pathlib.Path(sys.argv[1])
    parts = ['\n'.join('import Ruliology.CellularAutomata.' + m for m in s4.IMPORTS) + '\n', HEADER]
    for i, m in enumerate(s4.KITMODS):
        raw, text = s4.blob(s4.KIT, s4.KITREV, 'lean/Ruliology/CellularAutomata/%s.lean' % m)
        print('kit %s@%s %s' % (m, s4.KITREV, s4.sha(raw)))
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
        parts.append('\n' + '\n'.join(keep).strip('\n') + '\n')
    for m, rev in [(m, s4.OURREV) for m in s4.LOCAL] + [(RELAXED, RELAXEDREV)]:
        raw, text = s4.blob(s4.REPO, rev, 'research/m29/%s.lean' % m)
        print('local %s@%s %s' % (m, rev, s4.sha(raw)))
        if m == RELAXED:
            for a, b in REWORD:
                assert text.count(a) == 1, a
                text = text.replace(a, b)
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
    assert 'Ruliology.CellularAutomata.Rule30EveryK' not in src and 'M62' not in src
    data = src.encode('utf-8')
    out.write_bytes(data)
    print('Rule30Submission.lean %s %d lines %d bytes' % (s4.sha(data), src.count('\n'), len(data)))


if __name__ == '__main__':
    main()
