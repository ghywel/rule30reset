#!/usr/bin/env python3
"""Portal forms for the K83.C additions at the verifier's pin (claudeM5, M194).

    python3 -I build_portal.py KIT S20SOURCE OUT

KIT is kit main with the modules (for the carried sources), S20SOURCE is the portal Rule30Submission.lean of S20 (build_s20.py).
The pin has neither `Rule30HorizontalWords` nor Galindo's certificates nor `Rule30TerminalCensus`, so those that are used are
carried under `Rule30Submission`, unchanged but for their namespace lines and the five-cell parts, which are left out.
Writes OUT/s20d/Rule30Submission.lean (S20 with the hearing modules) and OUT/s22/Rule30Submission.lean (the census test).
"""
import pathlib, re, sys

kit, s20, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])
here = pathlib.Path(__file__).resolve().parent
CA = kit / 'lean/Ruliology/CellularAutomata'


def body_of(text):
    """Drop module keywords, imports and the leading doc comment."""
    lines = [l for l in text.split('\n') if not l.startswith(('import ', 'public import ')) and l.strip() not in ('module', '@[expose] public section')]
    t = '\n'.join(lines).lstrip('\n')
    return re.sub(r'^/-!.*?-/\n', '', t, count=1, flags=re.S).lstrip('\n')


def sub(t, pairs):
    for a, b in pairs:
        assert a in t, a
        t = t.replace(a, b)
    return t


NS = [('Ruliology.CellularAutomata.Rule30Certificates.HorizontalDiversity', 'Rule30Submission.Rule30Certificates.HorizontalDiversity'),
      ('namespace Ruliology.CellularAutomata.Rule30HorizontalDiversity', 'namespace Rule30Submission.Rule30HorizontalDiversity'),
      ('end Ruliology.CellularAutomata.Rule30HorizontalDiversity', 'end Rule30Submission.Rule30HorizontalDiversity')]
words = sub(body_of((CA / 'Rule30HorizontalWords.lean').read_text()), NS)
words = '/-! ### Carried: `Rule30HorizontalWords` (Galindo, kit `e2c9d8e`), namespaces moved under `Rule30Submission` -/\n\n' + words

# ---------- S20 with the hearing modules
four = sub(body_of((CA / 'Rule30Certificates/HorizontalDiversity.lean').read_text()), NS[:1])
four = '/-! ### Carried: the four-cell certificate of `Rule30HorizontalDiversity` (Galindo, kit `e2c9d8e`) -/\n\n' + four
src = s20.read_text()
imports = [l for l in src.split('\n') if l.startswith('import ')]
rest = src[len('\n'.join(imports)):]
imports += ['import Ruliology.CellularAutomata.Rule30Prize', 'import Ruliology.CellularAutomata.Rule30MaskedJen',
            'import Ruliology.CellularAutomata.Rule30Realization', 'import Mathlib.Tactic']
doc_add = ('\nWhat a wall hears. The pair word of columns -1 and 0 is a wall word with the OR word of columns 0 and 1, so the entropy is\n'
           'the growth rate of the OR words summed over all walls (`HearingRate.entropy_eq_mask_growth`), and any bound uniform in the\n'
           'wall bounds it (`HearingRate.entropy_le_of_mask`). A strip of d + 1 cells is exact for d + 1 readings\n'
           '(`ExactHearingStrip.exact_at_width`). Every rational rate above the worst wall has a finite integer table, and any such\n'
           'table bounds both the entropy and the single seed\'s horizontal words under an eventual period\n'
           '(`LookaheadHearing.strict_rate_has_certificate`, `LookaheadHearing.both_of_certificate`). `Rule30HorizontalWords` and the\n'
           'four-cell certificate are carried from the kit, which the verifier\'s pin predates.\n')
m = re.search(r'-/\n', rest)
rest = rest[:m.start()] + doc_add + rest[m.start():]
def H(f):
    """A hearing module's body with its quoted local notation replaced by the qualified name."""
    t = body_of((here / f).read_text())
    t = re.sub(r'^local notation .*\n', '', t, flags=re.M)
    t = t.replace('Ruliology.CellularAutomata.Rule30Certificates.HorizontalDiversity.', 'Rule30Submission.Rule30Certificates.HorizontalDiversity.')
    return re.sub(r'(?<![\w.])segment(?![\w])', 'Rule30Certificates.HorizontalDiversity.segment', t)


pair = sub(H('PairHearing.lean'), [('namespace HearingRate', 'namespace Rule30Submission.HearingRate'), ('end HearingRate', 'end Rule30Submission.HearingRate'),
    ('open Rule30Equivalents.Mixing Rule30Equivalents.PairTraceEntropy', 'open Rule30Equivalents.Mixing Rule30Submission'),
    ('Rule30HorizontalDiversity.uniform_mask_bound', 'Rule30Certificates.HorizontalDiversity.genuine_channel_bound')])
i = pair.index("/-- Galindo's five-cell bound"); j = pair.index('/-- The four-cell bound')
pair = pair[:i] + pair[j:]
exact = sub(H('ExactHearingStrip.lean'), [('namespace ExactHearingStrip', 'namespace Rule30Submission.ExactHearingStrip'), ('end ExactHearingStrip', 'end Rule30Submission.ExactHearingStrip')])
look = sub(H('LookaheadHearing.lean'), [('namespace LookaheadHearing', 'namespace Rule30Submission.LookaheadHearing'), ('end LookaheadHearing', 'end Rule30Submission.LookaheadHearing'),
    ('open ExactHearingStrip HearingRate', 'open Rule30Submission.ExactHearingStrip Rule30Submission.HearingRate')])
text = '\n'.join(imports) + rest.rstrip('\n') + '\n\n' + '\n\n'.join([words, four, pair, exact, look]) + '\n'
assert '"' not in text and '\\' not in text, 'the embedded source must hold no quote and no backslash'
(out / 's20d').mkdir(parents=True, exist_ok=True)
(out / 's20d/Rule30Submission.lean').write_text(text)
print('s20d', len(text.encode()), 'bytes')

# ---------- the census test
census = body_of((CA / 'Rule30TerminalCensus.lean').read_text())
i = census.index('/-- The rate beats the five-cell bound'); j = census.index('theorem vocabulary_budget') if False else None
# keep everything except the two theorems that use the five-cell certificate
cut1 = census.index('/-- The rate beats the five-cell bound'); cut2 = census.index('\n', census.index('theorem single_width_growth'))
k = census.index('open Rule30HorizontalDiversity\n')
census = census[:cut1].rstrip('\n') + '\n\nopen Rule30Submission.Rule30HorizontalDiversity\n' + census[k + len('open Rule30HorizontalDiversity\n'):]
cut = census.index('theorem single_width_problem1')
census = census[:census.rindex('\n/--', 0, cut) if '/--' in census[cut-300:cut] else cut].rstrip('\n') + '\n\nend Ruliology.CellularAutomata.Rule30TerminalCensus\n'
census = sub(census, [('namespace Ruliology.CellularAutomata.Rule30TerminalCensus', 'namespace Rule30Submission.Rule30TerminalCensus\nopen Ruliology.CellularAutomata'),
                      ('end Ruliology.CellularAutomata.Rule30TerminalCensus', 'end Rule30Submission.Rule30TerminalCensus')])
census = '/-! ### Carried: `Rule30TerminalCensus` (Galindo, kit `86864e4`), without its two five-cell corollaries -/\n\n' + census
term = sub(H('TerminalHearing.lean'), [('namespace TerminalHearing', 'namespace Rule30Submission.TerminalHearing'), ('end TerminalHearing', 'end Rule30Submission.TerminalHearing')])
i = term.index('/-- One pair per seven'); j = term.index('end Rule30Submission.TerminalHearing')
term = term[:i] + '''/-- One pair per seven age-depth positions suffices, given Galindo's five-cell cap of the kit
(`Rule30HorizontalDiversity.five_cell_count`, 9 (39/32)^w), which the verifier's pin predates. -/
theorem one_in_seven (cap : HorizontalCap 9 39 32) (h : PairDensity 1 7) : Rule30Prize.Problem1 :=
  problem1_of_hearing_and_pairs (by decide) (by decide) cap (by decide) h

''' + term[j:]
doc = '''/-!
# A wall bound sets the pair density in Galindo's terminal census

Galindo's terminal census (kit `Rule30TerminalCensus`) bounds the single seed's horizontal words H(s) by disjoint age pairs:
4^M <= H(s)^N. A bound K (p/q)^n on the OR words beside every wall caps H(s) under an eventual centre period. Together, a mean
of a/b pairs at unbounded widths gives Problem 1 whenever p^b < 4^a q^b (`TerminalHearing.problem1_of_hearing_and_pairs`).
With the kit's five-cell 39/32, one pair per seven positions suffices (`TerminalHearing.one_in_seven`); the census used 3/20.
Whether the single seed has such pairs is open. `Rule30HorizontalWords` and the census are carried from the kit, which the
verifier's pin predates; the census's two five-cell corollaries are left out.
-/
'''
text = 'import Ruliology.CellularAutomata.Rule30Prize\nimport Ruliology.CellularAutomata.Rule30MaskedJen\nimport Ruliology.CellularAutomata.Rule30Realization\n\n' + doc + '\n' + '\n\n'.join([words, census, term]) + '\n'
assert '"' not in text and '\\' not in text
(out / 's22').mkdir(parents=True, exist_ok=True)
(out / 's22/Rule30Submission.lean').write_text(text)
print('s22', len(text.encode()), 'bytes')
