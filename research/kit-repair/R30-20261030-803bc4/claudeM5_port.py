#!/usr/bin/env python3
"""claudeM5_port.py: the kit form of portal entry R30-20261030-803bc4 (KIT-REPAIR.md, repair 2).

  python3 research/kit-repair/R30-20261030-803bc4/claudeM5_port.py

Reads portal-source.lean (the portal's file, SHA-256 33c82f32…) and writes Rule30FiniteRoots.lean beside it. Only
these change:
  - the module-system header (`module`, `public import`, `@[expose] public section`);
  - the namespace Rule30FinitePastDraft, which becomes Ruliology.CellularAutomata.Rule30FiniteRoots;
  - the headline wrappers' namespace Rule30Submission, which becomes the same;
  - the five working docstrings (preparation notes with internal post numbers), replaced by a module docstring and
    four section headers;
  - the opens of the headline section.
Every declaration and every proof line is kept as it is; the script checks that the declaration lines are unchanged.
"""
import hashlib, pathlib, re

D = pathlib.Path(__file__).resolve().parent
src = (D / 'portal-source.lean').read_text()
assert hashlib.sha256(src.encode()).hexdigest().startswith('33c82f32'), 'not the pinned portal source'
lines = src.split('\n')

HEADER = '''module

public import Ruliology.CellularAutomata.Rule30Prize
public import Ruliology.CellularAutomata.Rule30Realization

/-!
# Finite ancestors of finite rows: a unique root and age, a finite-parent test, and exact counts

For every nonzero finite row `y` of rule 30 on the line (`Rule30Realization.evol` on `Int → Bool`):

* `finite_root_age`: `y` has a unique root and age. A root is a finite nonzero row with no finite nonzero
  predecessor; there is exactly one root `x` and one age `n` with `evol x n = y`, and `2 n` is at most the distance
  between the extreme black cells of `y`.
* `finite_parent_test`: if the extreme black cells of `y` are at `l` and `r`, a predecessor `p` of `y` that is white
  at every cell from `r` on is finite exactly when `y (l + 1)` and `p (l + 1)` are both black.
* `normalized_ancestor_bijection`: `n`-step evolution, normalized to start at cell 0, is a bijection from the
  normalized finite rows of width `w` onto the normalized rows of width `w + 2 n` that have an `n`-step finite past.
* `finite_word_enumeration`, `finite_parent_enumeration`, `finite_parent_count`, `finite_parent_small_widths`:
  exhaustive, duplicate-free enumerations. Of the normalized rows of width `w ≥ 4`, exactly `2 ^ (w - 4)` have a
  finite predecessor; at widths 1, 2 and 3 there are 0, 0 and 1.

**Method.** Each tick moves both extreme black cells out by one (endpoint growth). Two rows with the same image that
agree far to the right are equal, by reconstruction from right to left (left-permutivity). Normalized `n`-step
evolution is an exact translated-image bijection. Counts are the lengths of proved-exhaustive, duplicate-free lists of
actual rows, so no cardinality library is needed.

**Credit.** The finite ancestor and its age are described in Antti Karttunen's OEIS entries of February 2016
(A269165, the earliest finite ancestor, and A269166, its age; A269160 is one step of rule 30 on binary words). No
priority is claimed for that structure, which this module states and proves for the kit's `evol`. Injectivity on
configurations that agree far to the right is `Rule30Equivalents.Preimages.eq_of_evol_one_eq_of_right` in the
equivalents library, which also builds the white-right preimage. It is reproved here in core Lean, since the catalog
does not import the equivalents. The endpoint arguments specialise the edge facts of `Rule30FiniteConfigs` and
`Rule30FrozenRuler`.
-/

@[expose] public section
'''

SECTIONS = {
    'FiniteParentCriterionDraft.lean': '/-! ## The finite test for the white-right parent\n\nThe parent is an actual '
        'predecessor whose right tail is white. Its existence is in the equivalents library (`Preimages`); only its '
        'finiteness test is proved here. -/',
    'NormalizedFinitePastDraft.lean': '/-! ## Normalized finite ancestors and their exact image\n\nNormalizing an '
        '`n`-step image translates it right by `n`. -/',
    'FinitePastCountDraft.lean': '/-! ## Counting normalized finite parents\n\nCounts are lengths of exhaustive, '
        'duplicate-free enumerations of actual rows, built on `Rule30Jen.allLists`. Width zero is empty, width one is '
        'a singleton, and from width two the interior is free. -/',
    'SubmissionHeadlinesDraft.lean': '/-! ## The headline statements -/',
}

out, i = [], 0
first = True
while i < len(lines):
    l = lines[i]
    m = re.match(r'^/- BEGIN carrying body: (\S+) -/$', l)
    if i < 6:                                   # the preparation header and the first BEGIN line
        i += 1
        continue
    if m:
        name = m.group(1)
        j = i + 1
        while lines[j].strip() == '':
            j += 1
        assert lines[j].startswith('/-!'), name
        while not lines[j].rstrip().endswith('-/'):
            j += 1
        out.append(SECTIONS[name])
        i = j + 1
        continue
    if first and l.startswith('/-!'):            # the first block's working docstring: replaced by HEADER
        while not lines[i].rstrip().endswith('-/'):
            i += 1
        i += 1
        first = False
        continue
    l = l.replace('namespace Ruliology.CellularAutomata.Rule30FinitePastDraft',
                  'namespace Ruliology.CellularAutomata.Rule30FiniteRoots')
    l = l.replace('end Ruliology.CellularAutomata.Rule30FinitePastDraft', 'end Ruliology.CellularAutomata.Rule30FiniteRoots')
    if l == 'namespace Rule30Submission':
        l = 'namespace Ruliology.CellularAutomata.Rule30FiniteRoots'
    elif l == 'end Rule30Submission':
        l = 'end Ruliology.CellularAutomata.Rule30FiniteRoots'
    elif l == 'open Ruliology.CellularAutomata.Rule30Realization':
        l = 'open Rule30Jen Rule30Realization'
    elif l == 'open Ruliology.CellularAutomata.Rule30FinitePastDraft':
        i += 1
        continue
    out.append(l)
    i += 1

body = HEADER + '\n'.join(out).lstrip('\n')
body = re.sub(r'\n{3,}', '\n\n', body)
assert 'Draft' not in body and 'GC2' not in body and 'UNCOMPILED' not in body and 'Rule30Submission' not in body
decl = re.compile(r'^(theorem|def|structure|inductive|abbrev|lemma|instance|private) ')
a = [l for l in src.split('\n') if decl.match(l)]
b = [l for l in body.split('\n') if decl.match(l)]
assert a == b, 'a declaration line changed'
(D / 'Rule30FiniteRoots.lean').write_text(body)
print('Rule30FiniteRoots.lean: %d lines, %d declarations kept, SHA-256 %s' % (
    body.count('\n'), len(b), hashlib.sha256(body.encode()).hexdigest()))
