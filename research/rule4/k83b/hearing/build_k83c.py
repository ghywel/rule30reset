#!/usr/bin/env python3
"""Kit forms of the K83.C modules (claudeM5, M194).

    python3 -I build_k83c.py OUT KIT

KIT is a kit with S20's PairTraceEntropy, whose credit line the new modules take.

From PairHearing.lean (claudeM5, M191), ExactHearingStrip.lean, LookaheadHearing.lean and TerminalHearing.lean (gptIntel, I257),
all read (I257, M193), write OUT/equivalents/Rule30Equivalents/{PairHearing,ExactHearingStrip,LookaheadHearing}.lean and
OUT/lean/Ruliology/CellularAutomata/Rule30TerminalHearing.lean. Only headers, imports and namespaces change; every proof is kept.
"""
import pathlib, re, sys

here = pathlib.Path(__file__).resolve().parent
out = pathlib.Path(sys.argv[1])
kitdir = pathlib.Path(sys.argv[2])
CREDIT = re.search(r'^Contributed by [^\n]*$', (kitdir / 'equivalents/Rule30Equivalents/PairTraceEntropy.lean').read_text(encoding='utf-8'), re.M).group(0)


def split(text):
    lines = text.split('\n')
    imports = [l for l in lines if l.startswith('import ')]
    body = '\n'.join(l for l in lines if not l.startswith('import ')).lstrip('\n')
    return imports, body


def kit(src, imports, doc, renames, path):
    text = (here / src).read_text(encoding='utf-8')
    old_imports, body = split(text)
    body = re.sub(r'^/-!.*?-/\n', '', body, count=1, flags=re.S)
    for a, b in renames:
        assert a in body, (src, a)
        body = body.replace(a, b)
    head = 'module\n\n' + ''.join('public import %s\n' % i for i in imports) + '\n/-!\n' + doc.strip() + '\n\n' + CREDIT + '\n-/\n\n@[expose] public section\n\n'
    p = out / path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(head + body.lstrip('\n'), encoding='utf-8')
    print(path, len(p.read_bytes()), 'bytes')


kit('PairHearing.lean', ['Rule30Equivalents.PairTraceEntropy', 'Ruliology.CellularAutomata.Rule30HorizontalDiversity'], '''
# What a wall hears

Fix the readings of column 0 (the wall) and count the words read by the OR of columns 0 and 1. The column to the west is the
wall a tick later plus that reading, so a pair word of columns -1 and 0 is a wall word with an OR word. The topological entropy
is therefore the growth rate of the OR words summed over all walls, `log 2` plus the growth of their mean
(`entropy_eq_mask_growth`). A bound on the OR words beside every wall, uniform in the wall, bounds the entropy
(`entropy_le_of_mask`). The core bounds of `Rule30MaskedForkRate`, `Rule30HorizontalDiversity` and Quint's six-cell strip are of
this kind; the four- and five-cell certificates give `log (5/2)` and `log (39/16)` (`entropy_galindo_four`, `entropy_galindo`).
''', [('namespace HearingRate', 'namespace Rule30Equivalents.PairHearing'), ('end HearingRate', 'end Rule30Equivalents.PairHearing')],
    'equivalents/Rule30Equivalents/PairHearing.lean')

kit('ExactHearingStrip.lean', ['Ruliology.CellularAutomata.Rule30HorizontalWords', 'Mathlib.Tactic'], '''
# Exact strips beside a prescribed wall

A strip of d + 1 cells east of the wall, with the next cell free at every tick, reads exactly the physical OR words of length at
most d + 1, for every prescribed wall and every continuation of it (`exact_at_width`, `realize_word`).
''', [('namespace ExactHearingStrip', 'namespace Rule30Equivalents.ExactHearingStrip'), ('end ExactHearingStrip', 'end Rule30Equivalents.ExactHearingStrip')],
    'equivalents/Rule30Equivalents/ExactHearingStrip.lean')

kit('LookaheadHearing.lean', ['Rule30Equivalents.ExactHearingStrip', 'Rule30Equivalents.PairHearing'], '''
# Integer certificates for what a wall hears

A finite table of integer weights on sets of strips, knowing the next wall bits, bounds the OR words beside every wall, and so
both the full-map entropy and the single seed's horizontal words under an eventual centre period (`both_of_certificate`).
Conversely every rational rate strictly above the physical worst-wall rate has such a table, with width and look-ahead read off a
single block count (`strict_rate_has_certificate`, `physical_block_certificate`); a wall of period P needs P block tests
(`periodic_phase_bound`). At the limiting rate itself a constant need not exist: beside the all-white wall the count is n + 1.
The finite-memory hierarchy for joint spectral radii of nonnegative matrices is due to Gaubert and Stott (MTNS 2018).
''', [('namespace LookaheadHearing', 'namespace Rule30Equivalents.LookaheadHearing'), ('end LookaheadHearing', 'end Rule30Equivalents.LookaheadHearing'),
      ('open ExactHearingStrip HearingRate', 'open Rule30Equivalents.ExactHearingStrip Rule30Equivalents.PairHearing'),
      ('private def ceiling', 'def ceiling'), ('private theorem weight_bounds', 'theorem weight_bounds')],
    'equivalents/Rule30Equivalents/LookaheadHearing.lean')

kit('TerminalHearing.lean', ['Ruliology.CellularAutomata.Rule30TerminalCensus'], '''
# A wall bound sets the pair density in the terminal census

Galindo's `Rule30TerminalCensus` bounds the single seed's horizontal words by disjoint age pairs. Any uniform bound K (p/q)^n on
the OR words beside a wall, with `p^b < 4^a q^b`, makes a mean of a/b pairs at unbounded widths sufficient for Problem 1
(`problem1_of_hearing_and_pairs`). With the five-cell 39/32 of `Rule30HorizontalDiversity`, one pair per seven positions suffices
(`one_in_seven`); Galindo's census used 3/20. Whether the single seed has that many pairs is open.
''', [('namespace TerminalHearing', 'namespace Ruliology.CellularAutomata.Rule30TerminalHearing'), ('end TerminalHearing', 'end Ruliology.CellularAutomata.Rule30TerminalHearing')],
    'lean/Ruliology/CellularAutomata/Rule30TerminalHearing.lean')
