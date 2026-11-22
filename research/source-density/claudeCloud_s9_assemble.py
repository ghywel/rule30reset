#!/usr/bin/env python3
"""claudeCloud_s9_assemble.py: assemble S9's single-file portal form (METHOD 12, step 2; ledger K68).

  python3 research/source-density/claudeCloud_s9_assemble.py OUTFILE

Every part is read as a file whose SHA-256 is asserted here, normalised to LF:
  - one kit module that the verifier's kit commit 5fb5915 lacks, Rule30SourceObservables, as it stands at kit commit
    40017e8 (and unchanged at main cf60d48), read from the kit clone Rule30PrizeKit/;
  - gptIntel's ten modules of I72 and claudeCloud's two (Rule30DensityPolygon, Rule30DensityCornerHistories), from
    this folder.
Each has its module-system lines removed (`module`, `public import`, `@[expose] public section`) and its namespace
moved from Ruliology.CellularAutomata.X to Rule30Submission.X. One `open Ruliology.CellularAutomata` before the
first module makes the verifier's own kit modules resolve; the moved namespaces resolve from inside
`Rule30Submission`. No statement and no proof line changes. Ten headlines are restated in `Rule30Submission` at
the end. The result is encoded to UTF-8 once, written as bytes, and those same bytes are hashed.
"""
import hashlib
import pathlib
import re
import subprocess
import sys

HERE = pathlib.Path(__file__).resolve().parent
KIT, KITREV = HERE.parents[1] / 'Rule30PrizeKit', '40017e8'
IMPORTS = ['Rule30Prize', 'Rule30Realization']
KITMODS = [('Rule30SourceObservables', '6f2c860045451089d5333c754f8daef8b32f1dbd6fb65605883a4582d6d1c049')]
LOCAL = [
    ('Rule30SourceDensityRegion', '33b4c5e4cf963237'),
    ('Rule30SourceDensityCorners', '6110ba271b933c22'),
    ('Rule30DensitySharpness', '910b803222632f4f'),
    ('Rule30SourceTransitions', 'c1a7e6ace524b8b3'),
    ('Rule30DensityPolygon', 'b081c42eb283fed3'),
    ('Rule30DensityEscape', '63af32bbc0b09b8c'),
    ('Rule30DensityMargin', 'e37db0c8ca23c3cd'),
    ('Rule30DensityControl', 'e6c259a780bb8403'),
    ('Rule30DensityModes', '22dcaf9ec1f54ccd'),
    ('Rule30DensityVertices', '1567d057ea09d18f'),
    ('Rule30DensityOneHistory', 'dd4031d808e4b185'),
    ('Rule30DensityCornerHistories', 'f50cabc31840cc8e'),
]
NAMESPACES = ['Rule30SourceObservables', 'Rule30SourceDensityRegion', 'Rule30DensityEscape', 'Rule30DensityControl']

HEADER = '''
/-!
# The black-cell and run-end counts at one site of Rule 30

One file. First one kit module that the verifier's kit revision does not have, `Rule30SourceObservables` (David
Condrey, extended by G.P.J.W. Quint and Gemini), as it stands in the kit, with its module-system lines removed and
its namespace moved inside `Rule30Submission`. Then twelve modules of this entry:

* `Rule30SourceDensityRegion`: three inequalities between the duration `T`, the black count `C` of a site and the
  count `A` of ticks on which the site is black and its right neighbour white, on every interval at every site of
  every ordinary history;
* `Rule30SourceDensityCorners`: five histories, periodic in space and time, at the corners of the polygon;
* `Rule30DensitySharpness`, `Rule30DensityPolygon`: a linear inequality holds uniformly exactly when it holds at
  those five corners;
* `Rule30SourceTransitions`: the middle inequality counts black-to-white steps of the right column;
* `Rule30DensityEscape`, `Rule30DensityMargin`: on the single seed two corners are missed by a growing margin;
* `Rule30DensityControl`, `Rule30DensityModes`, `Rule30DensityVertices`, `Rule30DensityOneHistory`,
  `Rule30DensityCornerHistories`: each corner is tracked with bounded error from an arbitrary right half.

The headlines are in `Rule30Submission` at the end.
-/
'''

HEADLINES = '''
namespace Rule30Submission

open Ruliology.CellularAutomata Rule30Jen Rule30Realization
open Rule30SourceDensityRegion

/-- **The classification.** With `C = black u j s n` the black cells of site `j` on the `n` ticks from tick `s`,
and `A = ends u j s n` the ticks among them on which the site is black and its right neighbour white: some constant
`K` makes `α*C + β*A ≤ γ*n + K` hold on every interval at every site of every ordinary history exactly when the
inequality without `K` holds at the five corners `(n, C, A) = (1,0,0), (3,1,0), (4,3,1), (10,9,4), (1,1,1)`. -/
theorem linear_bound_iff (α β γ : Int) :
    (∃ K : Int, ∀ u : History, Evolution u → ∀ (j : Int) (s n : Nat),
        α*black u j s n+β*ends u j s n ≤ γ*(n:Int)+K) ↔
    (0≤γ ∧ α≤3*γ ∧ 3*α+β≤4*γ ∧ 9*α+4*β≤10*γ ∧ α+β≤γ) :=
  uniform_bound_iff α β γ

/-- **The same over nonzero finite seeds only,** at site `0` from tick `0`. -/
theorem finite_seed_bound_iff (α β γ : Int) :
    (∃ K : Int, ∀ x : Int → Bool,
        (∃ N : Nat, ∀ i, (i < -(N:Int) ∨ (N:Int)<i) → x i=false) → (∃ i, x i=true) →
        ∀ n : Nat, α*black (evol x) 0 0 n+β*ends (evol x) 0 0 n ≤ γ*(n:Int)+K) ↔
    (0≤γ ∧ α≤3*γ ∧ 3*α+β≤4*γ ∧ 9*α+4*β≤10*γ ∧ α+β≤γ) :=
  finite_bound_iff α β γ

/-- **With an explicit constant.** An inequality that holds at the five corners holds on every interval at every
site of every ordinary history with `K = 9|α| + 4|β|`. -/
theorem linear_bound_constant {α β γ : Int}
    (corners : 0≤γ ∧ α≤3*γ ∧ 3*α+β≤4*γ ∧ 9*α+4*β≤10*γ ∧ α+β≤γ)
    {u : History} (hu : Evolution u) (j : Int) (s n : Nat) :
    α*black u j s n+β*ends u j s n ≤ γ*(n:Int)+((9*α.natAbs+4*β.natAbs : Nat) : Int) :=
  polygon_sufficient corners u hu j s n

/-- **Three inequalities.** On every interval at every site of every ordinary history, `3C ≤ n + 5A + 3`,
`2C ≤ n + 2A + 1` and `6C ≤ 5n + A + 5`. The first is Condrey's bound. The second counts the black-to-white steps
of the right column, an identity of Ulrey's at the centre. The third is new. -/
theorem three_faces {u : History} (hu : Evolution u) (j : Int) (s n : Nat) :
    3*black u j s n ≤ n+5*ends u j s n+3 ∧
    2*black u j s n ≤ n+2*ends u j s n+1 ∧
    6*black u j s n ≤ 5*(n:Int)+ends u j s n+5 :=
  region hu j s n

/-- **Five corners.** `Corner p c a` is an ordinary history of time period `p` with `c` black cells at site `0` and
`a` run ends across the bond `(0, 1)` in each period. -/
theorem five_corners : Corner 1 0 0 ∧ Corner 3 1 0 ∧ Corner 4 3 1 ∧ Corner 10 9 4 ∧ Corner 1 1 1 :=
  ⟨corner0,corner1,corner2,corner3,corner4⟩

/-- **The three additive constants are attained,** on one history. -/
theorem sharp_constants : ∃ u : History, Evolution u ∧
    3*black u 0 2 3-5*ends u 0 2 3-3=3 ∧
    2*black u 0 8 9-2*ends u 0 8 9-9=1 ∧
    6*black u 0 4 9-ends u 0 4 9-5*9=5 :=
  optimal_startup

/-- **Each corner from an arbitrary right half.** `Tracks W D c a cap`: every row on the sites `j ≥ 0` is the right
half of an ordinary full-line configuration whose counts at sites `0` and `1`, on every interval from tick `W`,
satisfy `|D*C - c*n| ≤ cap` and `|D*A - a*n| ≤ cap`. -/
theorem corners_from_any_right_half :
    Tracks 2 1 0 0 0 ∧ Tracks 6 3 1 0 3 ∧ Tracks 21 4 3 1 3 ∧ Tracks 37 10 9 4 12 ∧ Tracks 3 1 1 1 0 :=
  Rule30SourceDensityRegion.corners_from_any_right_half

/-- **The single seed misses the corner `(3/4, 1/4)` by a growing margin.** With `d 0 = |j|` and
`d (k+1) = 2 * d k + |j| + 11` (`Rule30DensityEscape.deadline false j`), every `n ≥ d k` has
`2n + 7A - 5C ≥ k - 4` at site `j` on the ticks `0 … n-1`. The deficit is a count: the ratios may still converge. -/
theorem margin_three_quarters (j : Int) (k n : Nat) (hn : Rule30DensityEscape.deadline false j k ≤ n) :
    (k:Int)-4 ≤ 2*(n:Int)+7*ends cell j 0 n-5*black cell j 0 n :=
  Rule30DensityEscape.margin_three_quarters j k n hn

/-- **And the corner `(9/10, 2/5)`.** With `d (k+1) = 2 * d k + |j| + 23` (`deadline true j`), every `n ≥ d k` has
`6n + 3A - 8C ≥ k - 6`. -/
theorem margin_nine_tenths (j : Int) (k n : Nat) (hn : Rule30DensityEscape.deadline true j k ≤ n) :
    (k:Int)-6 ≤ 6*(n:Int)+3*ends cell j 0 n-8*black cell j 0 n :=
  Rule30DensityEscape.margin_nine_tenths j k n hn

/-- **The middle inequality and period two.** On the single seed, `n - 2(C - A)` at site `j` is bounded above
exactly when column `j + 1` is eventually periodic with period two. -/
theorem middle_bounded_iff_period_two (j : Int) :
    (∃ K : Int, ∀ n : Nat, (n:Int)-2*(black cell j 0 n-ends cell j 0 n) ≤ K) ↔
    (∃ T, ∀ t, T ≤ t → cell (t+2) (j+1)=cell t (j+1)) :=
  singleton_middle_bounded_iff_period_two j

end Rule30Submission
'''


def sha(b):
    return hashlib.sha256(b).hexdigest()


def carry(m, text, first):
    keep = []
    for line in text.split('\n'):
        if line.strip() in ('module', '@[expose] public section') or line.startswith('public import '):
            continue
        assert not line.startswith('#print '), m
        mo = re.match(r'^(namespace|end) Ruliology\.CellularAutomata\.(\w+)$', line)
        if mo:
            assert mo.group(2) in NAMESPACES, (m, line)
            if first and mo.group(1) == 'namespace':
                keep.append('open Ruliology.CellularAutomata')
            line = '%s Rule30Submission.%s' % (mo.group(1), mo.group(2))
        keep.append(line)
    body = '\n'.join(keep).strip('\n')
    assert len(re.findall(r'^namespace Rule30Submission\.\w+$', body, re.M)) == 1, m
    assert len(re.findall(r'^end Rule30Submission\.\w+$', body, re.M)) == 1, m
    assert 'Ruliology.CellularAutomata.Rule30' not in body.split('namespace Rule30Submission.')[1], m
    return '\n' + body + '\n'


def main():
    out = pathlib.Path(sys.argv[1])
    parts = ['\n'.join('import Ruliology.CellularAutomata.' + m for m in IMPORTS) + '\n', HEADER]
    first = True
    for m, want in KITMODS:
        raw = subprocess.run(['git', '-C', str(KIT), 'show', '%s:lean/Ruliology/CellularAutomata/%s.lean' % (KITREV, m)],
                             capture_output=True, check=True).stdout
        print('kit %s@%s %s' % (m, KITREV, sha(raw)))
        assert sha(raw) == want, 'the kit module is not the pinned one'
        parts.append(carry(m, raw.decode('utf-8').replace('\r\n', '\n'), first))
        first = False
    for m, want in LOCAL:
        raw = (HERE / (m + '.lean')).read_bytes()
        print('local %s %s' % (m, sha(raw)))
        assert sha(raw).startswith(want), 'a local module is not the pinned one: ' + m
        parts.append(carry(m, raw.decode('utf-8').replace('\r\n', '\n'), False))
    parts.append(HEADLINES)
    src = ''.join(parts)
    assert '"' not in src and '\\' not in src and '\r' not in src, 'quote, backslash or CR in the source'
    data = src.encode('utf-8')
    out.write_bytes(data)
    print('Rule30Submission.lean %s %d lines %d bytes' % (sha(data), src.count('\n'), len(data)))


if __name__ == '__main__':
    main()
