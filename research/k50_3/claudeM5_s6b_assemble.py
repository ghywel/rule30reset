#!/usr/bin/env python3
"""claudeM5_s6b_assemble.py: assemble the portal form of S6's replacement, with both ages sharp (K50.3, M196).

  python3 research/k50_3/claudeM5_s6b_assemble.py OUTFILE [REV]

S6's own assembler (claudeM5_s6_assemble.py) with two changes: `Rule30TwoSidedInverse` is the amended module, which
carries the age-23 witness and the least ages (claudeM5_s6b_merge.py), read at this repository's commit REV (default
below; REV = WORKTREE reads the working file); and three headlines follow S6's six. Every other part is S6's, from the
same pinned Git blobs, normalised to LF:
  - eleven kit modules at kit commit 40017e8 (in the kit clone Rule30PrizeKit/), which the verifier's kit commit
    5fb5915 lacks: Hughes's three (Rule30LateTwins, Rule30AgeEightInverse, Rule30AgeTwentyFourInverse), the three
    every-k modules, and the five of S4 and S5. Each has its module-system lines removed (`module`, `public import`,
    `@[expose] public section`), its `#print axioms` audit lines removed, and its namespace moved from
    Ruliology.CellularAutomata.X to Rule30Submission.X;
  - our two modules, the amended one at REV and Rule30EveryKLine at f389503 (M89), treated the same way;
  - the headlines in Rule30Submission at the end.
One `open Ruliology.CellularAutomata` before the first module makes the verifier's own kit modules resolve, and the
fully qualified `open` lines of the kit's copies point to the moved copies. No proof
body changes. The result is encoded to UTF-8 once, written as bytes, and those same bytes are hashed.
"""
import hashlib
import pathlib
import re
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parents[2]
KIT, KITREV = REPO / 'Rule30PrizeKit', '40017e8'
IMPORTS = ['Rule30ZeroBoundary', 'Rule30UniversalLeftSide', 'Rule30AgedLeftDiagonals', 'Rule30LeftUnbounded',
           'Rule30FiniteConfigs', 'Rule30Prize']
KITMODS = ['Rule30LateTwins', 'Rule30AgeEightInverse', 'Rule30AgeTwentyFourInverse',
           'Rule30EveryKStatement', 'Rule30EveryKCascade', 'Rule30EveryKInverse',
           'Rule30RootedWhiteReturns', 'Rule30ThreePhaseReturn', 'Rule30RecurrentStrip',
           'Rule30ResetCompactness', 'Rule30RelaxedWindows']
REV = sys.argv[2] if len(sys.argv) > 2 else 'WORKTREE'
LOCAL = [('Rule30TwoSidedInverse', REV), ('Rule30EveryKLine', 'f389503')]
MOVED = KITMODS + [m for m, _ in LOCAL]

HEADER = '''
/-!
# Inverse ticks without the wall: Hughes's ages 8 and 24, both sharp, and every k from reset capacity

One file. First eleven kit modules that the verifier's kit revision does not have, as they stand at kit commit
40017e8, with the module-system lines removed and their namespaces moved inside `Rule30Submission`: Hughes's three
(`Rule30LateTwins`, `Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`), the three every-k modules, and the five
that give reset capacity from closed runs and from the relaxed doubling lemma. Then two modules of ours: Hughes's two
inverse theorems for every configuration of the line with a leftmost black cell, with witnesses at ages 7 and 23 that
make 8 and 24 the least ages, and the every-k chain on the line.
The headlines are in `Rule30Submission` at the end.
-/
'''

HEADLINES = '''
namespace Rule30Submission

open Ruliology.CellularAutomata Rule30Jen Rule30Realization Rule30EveryKStatement

/-- From age 8, every predecessor of the image of a configuration with a leftmost black cell at `lo` has its
leftmost black cell at `lo - t + 1`. -/
theorem predecessor_edge_from_age_eight {x : Int → Bool} {lo : Int} (hlo : x lo = true)
    (hzero : ∀ p, p < lo → x p = false) (t : Nat) (ht : 8 ≤ t) (z : Int → Bool)
    (hz : ∀ p, rule (z (p - 1)) (z p) (z (p + 1)) = evol x t p) :
    z (lo - t + 1) = true ∧ ∀ p, p < lo - t + 1 → z p = false :=
  Rule30TwoSidedInverse.predecessor_edge_from_age_eight hlo hzero t ht z hz

/-- From age 24, every two-step predecessor has its leftmost black cell at `lo - t + 2`. -/
theorem two_step_predecessor_edge_from_age_twenty_four {x : Int → Bool} {lo : Int} (hlo : x lo = true)
    (hzero : ∀ p, p < lo → x p = false) (t : Nat) (ht : 24 ≤ t) (w v : Int → Bool)
    (hw : ∀ p, rule (w (p - 1)) (w p) (w (p + 1)) = evol x t p)
    (hv : ∀ p, rule (v (p - 1)) (v p) (v (p + 1)) = w p) :
    v (lo - t + 2) = true ∧ ∀ p, p < lo - t + 2 → v p = false :=
  Rule30TwoSidedInverse.two_step_predecessor_edge_from_age_twenty_four hlo hzero t ht w v hw hv

/-- The age 8 is sharp: at age 7 some configuration with a leftmost black cell has a predecessor of its image with
no leftmost black cell at all. -/
theorem predecessor_edge_fails_at_age_seven :
    ∃ x : Int → Bool, x 0 = true ∧ (∀ p, p < 0 → x p = false) ∧
      ∃ z : Int → Bool, (∀ p, rule (z (p - 1)) (z p) (z (p + 1)) = evol x 7 p) ∧
        ∀ q : Int, ∃ p, p < q ∧ z p = true :=
  let h := Rule30TwoSidedInverse.predecessor_edge_fails_at_age_seven
  ⟨_, h.1, h.2.1, _, h.2.2.1, h.2.2.2⟩

/-- If `0 < w` and `k ≤ K1 w`, then from age `2 ^ w` every `k`-tick predecessor of the image of a configuration
with a leftmost black cell at `lo` has its leftmost black cell at `lo - t + k`. -/
theorem kTick_edge_line {x : Int → Bool} {lo : Int} (hlo : x lo = true) (hzero : ∀ p, p < lo → x p = false)
    (k w : Nat) (hw : 0 < w) (cap : k ≤ K1 w) (t : Nat) (ht : 2 ^ w ≤ t)
    (V : Int → Bool) (hV : ∀ p, evol V k p = evol x t p) :
    V (lo - t + k) = true ∧ ∀ p, p < lo - t + k → V p = false :=
  Rule30EveryKLine.kTick_edge_line hlo hzero k w hw cap t ht V hV

/-- The kit's reset capacity `CAP` gives, for every `k`, an age from which every `k`-tick predecessor of the image
of every configuration with a leftmost black cell has its leftmost black cell `k` places in. -/
theorem every_k_line_of_cap (capacity : CAP) (k : Nat) :
    ∃ age : Nat, ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
      ∀ t, age ≤ t → ∀ V : Int → Bool, (∀ p, evol V k p = evol x t p) →
        V (lo - t + k) = true ∧ ∀ p, p < lo - t + k → V p = false :=
  Rule30EveryKLine.every_k_line_of_cap capacity k

/-- The same from the relaxed doubling lemma. -/
theorem every_k_line_of_dlMinusOne (h : Rule30RelaxedWindows.DLMinusOne) (k : Nat) :
    ∃ age : Nat, ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
      ∀ t, age ≤ t → ∀ V : Int → Bool, (∀ p, evol V k p = evol x t p) →
        V (lo - t + k) = true ∧ ∀ p, p < lo - t + k → V p = false :=
  Rule30EveryKLine.every_k_line_of_dlMinusOne h k

/-- The age 24 is sharp: at age 23 some configuration with a leftmost black cell has a two-step predecessor of its
image with no leftmost black cell at all. -/
theorem two_step_predecessor_edge_fails_at_age_twenty_three :
    ∃ x : Int → Bool, x 0 = true ∧ (∀ p, p < 0 → x p = false) ∧
      ∃ w v : Int → Bool, (∀ p, rule (w (p - 1)) (w p) (w (p + 1)) = evol x 23 p) ∧
        (∀ p, rule (v (p - 1)) (v p) (v (p + 1)) = w p) ∧ ∀ q : Int, ∃ p, p < q ∧ v p = true :=
  let h := Rule30TwoSidedInverse.two_step_predecessor_edge_fails_at_age_twenty_three
  ⟨Rule30TwoSidedInverse.X23, h.1, h.2.1, Rule30TwoSidedInverse.W23, Rule30TwoSidedInverse.V23, h.2.2.1, h.2.2.2.1,
    h.2.2.2.2⟩

/-- 8 is the least age of the one-tick theorem: its conclusion holds at every age from `a` on exactly when
`8 ≤ a`. -/
theorem one_tick_least_age (a : Nat) :
    (∀ t, a ≤ t → ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
      ∀ z : Int → Bool, (∀ p, rule (z (p - 1)) (z p) (z (p + 1)) = evol x t p) →
        z (lo - t + 1) = true ∧ ∀ p, p < lo - t + 1 → z p = false) ↔ 8 ≤ a :=
  Rule30TwoSidedInverse.one_tick_least_age a

/-- 24 is the least age of the two-tick theorem: its conclusion holds at every age from `a` on exactly when
`24 ≤ a`. -/
theorem two_tick_least_age (a : Nat) :
    (∀ t, a ≤ t → ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
      ∀ w v : Int → Bool, (∀ p, rule (w (p - 1)) (w p) (w (p + 1)) = evol x t p) →
        (∀ p, rule (v (p - 1)) (v p) (v (p + 1)) = w p) →
          v (lo - t + 2) = true ∧ ∀ p, p < lo - t + 2 → v p = false) ↔ 24 ≤ a :=
  Rule30TwoSidedInverse.two_tick_least_age a

end Rule30Submission
'''


def sha(b):
    return hashlib.sha256(b).hexdigest()


def blob(repo, rev, path):
    if rev == 'WORKTREE':
        raw = (repo / path).read_bytes()
        return raw, raw.decode('utf-8').replace('\r\n', '\n')
    raw = subprocess.run(['git', '-C', str(repo), 'show', '%s:%s' % (rev, path)], capture_output=True, check=True).stdout
    return raw, raw.decode('utf-8').replace('\r\n', '\n')


def carry(m, text, first):
    keep = []
    for line in text.split('\n'):
        if line.strip() in ('module', '@[expose] public section') or line.startswith('public import '):
            continue
        if line.startswith('#print '):     # the kit's audit lines: messages, not proof
            continue
        if line == 'namespace Ruliology.CellularAutomata.' + m:
            if first:
                keep.append('open Ruliology.CellularAutomata')
            line = 'namespace Rule30Submission.' + m
        elif line in ('end Ruliology.CellularAutomata.' + m, 'end ' + m):
            line = 'end Rule30Submission.' + m
        keep.append(line)
    body = '\n'.join(keep).strip('\n')
    # references to the other moved modules, in fully qualified `open` lines, point to their moved copies
    for n in MOVED:
        body = re.sub(r'\bRuliology\.CellularAutomata\.' + n + r'\b', 'Rule30Submission.' + n, body)
    assert body.count('namespace Rule30Submission.' + m) == 1 and body.count('end Rule30Submission.' + m) == 1, m
    return '\n' + body + '\n'


def main():
    out = pathlib.Path(sys.argv[1])
    parts = ['\n'.join('import Ruliology.CellularAutomata.' + m for m in IMPORTS) + '\n', HEADER]
    first = True
    for m in KITMODS:
        raw, text = blob(KIT, KITREV, 'lean/Ruliology/CellularAutomata/%s.lean' % m)
        print('kit %s@%s %s' % (m, KITREV, sha(raw)))
        parts.append(carry(m, text, first))
        first = False
    for m, rev in LOCAL:
        raw, text = blob(REPO, rev, 'research/k50_3/%s.lean' % m)
        print('local %s@%s %s' % (m, rev, sha(raw)))
        parts.append(carry(m, text, False))
    parts.append(HEADLINES)
    src = ''.join(parts)
    assert '"' not in src and '\\' not in src and '\r' not in src, 'quote, backslash or CR in the source'
    for m in MOVED:
        assert ('Ruliology.CellularAutomata.' + m) not in src, 'a kit namespace was left in place: ' + m
    data = src.encode('utf-8')
    out.write_bytes(data)
    print('Rule30Submission.lean %s %d lines %d bytes' % (sha(data), src.count('\n'), len(data)))


if __name__ == '__main__':
    main()
