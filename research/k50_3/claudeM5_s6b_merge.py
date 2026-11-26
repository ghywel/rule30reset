#!/usr/bin/env python3
"""claudeM5_s6b_merge.py: put N23's age-23 witness into Rule30TwoSidedInverse, beside the age-7 witness (K50.3, M196).

  python3 research/k50_3/claudeM5_s6b_merge.py OUTFILE

Reads two reviewed blobs of this repository and writes the amended module:
  - Rule30TwoSidedInverse.lean at e4d7d0b (M88, SHA-256 2125f3cf..., read in R74, in the kit since #385 byte for byte);
  - Rule30TwoSidedSharp.lean at 7d16473 (N23, SHA-256 727cae4d..., read in R126).
What changes, and nothing else:
  1. The module docstring gains two bullets: the age-23 witness, and the least ages.
  2. N23's body follows the age-7 witness under "Age 24 is sharp", with N23's own docstring as the section's.
     N23's copy of the right-hand lemma (`evol_false_right`) is dropped for the module's own `evol_eq_false_of_gt`.
     Its generic names get a prefix, so that a module opening this namespace beside another meets no clash:
     get, rowOf, stepL, iterL become listGet, listRow, listStep, listIter (and their lemmas), and the witness
     lemmas carry the witness's name (seed_zero becomes X23_zero, w_pred becomes W23_pred, and so on).
  3. A last section, "The least ages", states the two conclusions as `OneTickEdge t` and `TwoTickEdge t` and proves
     that each holds at every age from `a` on exactly when 8 <= a, and 24 <= a (R126 checked the second in a consumer).
No proof step of either blob changes beyond the renaming.
"""
import hashlib
import pathlib
import re
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parents[2]
OLD = ('e4d7d0b', 'research/k50_3/Rule30TwoSidedInverse.lean', '2125f3cf304a9d4e863e')
N23 = ('7d16473', 'research/k50_3/Rule30TwoSidedSharp.lean', '727cae4d5d1a83460206')


def blob(rev, path, pre):
    raw = subprocess.run(['git', '-C', str(REPO), 'show', '%s:%s' % (rev, path)], capture_output=True, check=True).stdout
    assert hashlib.sha256(raw).hexdigest().startswith(pre), path
    return raw.decode('utf-8')


def rep(s, a, b):
    assert s.count(a) == 1, (s.count(a), a[:80])
    return s.replace(a, b)


old = blob(*OLD)
sharp = blob(*N23)

# 1. the module docstring
old = rep(old, '''* `predecessor_edge_fails_at_age_seven`: the age 8 cannot be lowered. The configuration with black cells
  at `0` and `3` has, at age 7, a predecessor black on `(-∞, -9]` and on `[11, ∞)`: it has no leftmost
  black cell.
''', '''* `predecessor_edge_fails_at_age_seven`: the age 8 cannot be lowered. The configuration with black cells
  at `0` and `3` has, at age 7, a predecessor black on `(-∞, -9]` and on `[11, ∞)`: it has no leftmost
  black cell.
* `two_step_predecessor_edge_fails_at_age_twenty_three`, `age_twenty_four_sharp`: the age 24 cannot be
  lowered. The configuration with black cells at `0, 3, 4, 6, 7, 10, 11, 12` and `14` has, at age 23, a
  predecessor of its image with the true edge, and a predecessor of that one which is black on all of
  `(-∞, -24]`: it has no leftmost black cell.
* `one_tick_least_age`, `two_tick_least_age`: so 8 and 24 are the least ages. Each conclusion holds at
  every age from `a` on exactly when `8 ≤ a`, and when `24 ≤ a`.
''')

# 2. N23's body, from its first section to the end of its namespace, under N23's docstring (rewrapped, its pointers
# to this module made local)
assert '`V23` repeats `001` from 36 on.' in sharp and '(`step_rowOf`).' in sharp
doc = '''Age 23 does not suffice for `two_step_predecessor_edge_from_age_twenty_four`. The configuration `X23`, black
at 0, 3, 4, 6, 7, 10, 11, 12 and 14, has at age 23 a predecessor `W23` of its image, and a predecessor `V23`
of `W23` that is black on all of `(-∞, -24]`, so `V23` has no leftmost black cell
(`two_step_predecessor_edge_fails_at_age_twenty_three`, `age_twenty_four_sharp`). `W23` has the true edge,
at `-22`, as the age-8 theorem requires; it is black on `[37, ∞)`, and `V23` repeats `001` from 36 on.

`evol` is computed through rows written as lists (`evol_listRow`): `listRow L lo` is the row whose cell
`lo + i` is entry `i` of `L`, white elsewhere, and `listStep` is one tick on such rows (`step_listRow`).
'''
body = sharp[sharp.index('/-! ## Rows as lists -/'):sharp.index('end Rule30TwoSidedSharp')]
i = body.index('/-- On the right, a configuration white beyond `hi`')
j = body.index('/-- Entry `k` of `L`')
assert 'theorem evol_false_right' in body[i:j]
body = body[:i] + body[j:]
body = body.replace('evol_false_right', 'evol_eq_false_of_gt')
body = rep(body, '/-! ## Rows as lists -/', '/-! ### Rows as lists -/')
body = rep(body, '/-! ## The witness -/', '/-! ### The witness -/')
for a, b in [('get_neg', 'listGet_neg'), ('get_ge', 'listGet_ge'), ('get_stepL', 'listGet_listStep'),
             ('length_stepL', 'length_listStep'), ('step_rowOf', 'step_listRow'), ('evol_rowOf', 'evol_listRow'),
             ('rowOf', 'listRow'), ('stepL', 'listStep'), ('iterL', 'listIter'),
             ('seedL', 'seed23'), ('wMid', 'W23mid'), ('vMid', 'V23mid'),
             ('w_middle', 'W23_middle'), ('v_middle', 'V23_middle'),
             ('seed_zero', 'X23_zero'), ('seed_left', 'X23_left'), ('seed_right', 'X23_right'),
             ('w_pred', 'W23_pred'), ('v_pred', 'V23_pred'), ('v_no_left_edge', 'V23_no_left_edge'), ('w_edge', 'W23_edge')]:
    body = re.sub(r'(?<![\w.])' + a + r'(?![\w?\'])', b, body)
body = re.sub(r'(?<![\w.])get(?![\w?\'])', 'listGet', body)
body = rep(body, '''  (List.range (L.length + 2)).map fun (i : Nat) => rule (listGet L ((i : Int) - 2)) (listGet L ((i : Int) - 1)) (listGet L i)''',
           '''  (List.range (L.length + 2)).map fun (i : Nat) =>
    rule (listGet L ((i : Int) - 2)) (listGet L ((i : Int) - 1)) (listGet L i)''')
assert 'Rule30TwoSidedSharp' not in body and 'evol_false_right' not in body

LEAST = '''
/-! ## The least ages -/

/-- The conclusion of `predecessor_edge_from_age_eight` at age `t`, for every configuration with a leftmost
black cell and every predecessor of its image. -/
def OneTickEdge (t : Nat) : Prop :=
  ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
    ∀ z : Int → Bool, (∀ p, rule (z (p - 1)) (z p) (z (p + 1)) = evol x t p) →
      z (lo - t + 1) = true ∧ ∀ p, p < lo - t + 1 → z p = false

/-- The conclusion of `two_step_predecessor_edge_from_age_twenty_four` at age `t`. -/
def TwoTickEdge (t : Nat) : Prop :=
  ∀ (x : Int → Bool) (lo : Int), x lo = true → (∀ p, p < lo → x p = false) →
    ∀ w v : Int → Bool, (∀ p, rule (w (p - 1)) (w p) (w (p + 1)) = evol x t p) →
      (∀ p, rule (v (p - 1)) (v p) (v (p + 1)) = w p) →
        v (lo - t + 2) = true ∧ ∀ p, p < lo - t + 2 → v p = false

/-- **8 is the least age.** The one-tick conclusion holds at every age from `a` on exactly when `8 ≤ a`. -/
theorem one_tick_least_age (a : Nat) : (∀ t, a ≤ t → OneTickEdge t) ↔ 8 ≤ a := by
  refine ⟨fun h => ?_, fun ha t ht x lo hlo hzero z hz =>
    predecessor_edge_from_age_eight hlo hzero t (by omega) z hz⟩
  rcases Nat.lt_or_ge a 8 with ha | ha
  · obtain ⟨h0, hl, hz, hb⟩ := predecessor_edge_fails_at_age_seven
    obtain ⟨p, hp, hpb⟩ := hb (-6)
    have h' := (h 7 (by omega) sharpX 0 h0 hl sharpZ hz).2 p (by omega)
    rw [hpb] at h'
    exact absurd h' (by decide)
  · exact ha

/-- **24 is the least age.** The two-tick conclusion holds at every age from `a` on exactly when `24 ≤ a`. -/
theorem two_tick_least_age (a : Nat) : (∀ t, a ≤ t → TwoTickEdge t) ↔ 24 ≤ a := by
  refine ⟨fun h => ?_, fun ha t ht x lo hlo hzero w v hw hv =>
    two_step_predecessor_edge_from_age_twenty_four hlo hzero t (by omega) w v hw hv⟩
  rcases Nat.lt_or_ge a 24 with ha | ha
  · have h' := (h 23 (by omega) X23 0 X23_zero X23_left W23 V23 W23_pred V23_pred).2 (-24) (by omega)
    rw [V23_left (p := -24) (by omega)] at h'
    exact absurd h' (by decide)
  · exact ha

'''

tail = 'end Ruliology.CellularAutomata.Rule30TwoSidedInverse\n'
assert old.endswith(tail)
new = old[:-len(tail)] + '/-! ## Age 24 is sharp\n\n' + doc.strip('\n') + '\n-/\n\n' + body.rstrip('\n') + '\n' + LEAST + tail
data = new.encode('utf-8')
pathlib.Path(sys.argv[1]).write_bytes(data)
print('Rule30TwoSidedInverse.lean', hashlib.sha256(data).hexdigest(), new.count('\n'), 'lines', len(data), 'bytes')
