#!/usr/bin/env python3
"""build_s16.py T001.json T011.json OUTDIR: assembles the portable file (ledger M152) from the tables of make_table.py and the parts.

OUTDIR/portal/Rule30Submission.lean: S10's tree is carried from research/m9/compact, declaration by declaration, and the first
part of Rule30EtherThreeDeparture (S14), through ten_ticks, from kit main.
OUTDIR/kit/...: Rule30PeriodThreeEntry and Rule30Certificates/PeriodThreeEntry, the same text on the kit's own modules, with the
two implications from the kit's left statements (part_kit.txt)."""
import json, pathlib, re, sys
HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from make_tour import tour
ROOT = HERE.parents[2]
S10 = (ROOT / 'research/m9/compact/Rule30Submission.lean').read_text(encoding='utf-8')
D = {w: json.loads(pathlib.Path(p).read_bytes()) for w, p in zip(('001', '011'), sys.argv[1:3])}
OUT = pathlib.Path(sys.argv[3])
OUT.mkdir(parents=True, exist_ok=True)
B = lambda b: 'true' if b else 'false'


def part(n):
    return (HERE / ('part_%s.txt' % n)).read_text(encoding='utf-8').rstrip('\n') + '\n'


def tree():
    names = ['Tree', 'Tree.low', 'Tree.high', 'Tree.child', 'Tree.valid', 'Tree.value', 'subset', 'Tree.bounds', 'Tree.child_valid',
             'Tree.child_value', 'subset_sound']
    starts = [x.start() for x in re.finditer(
        r'(?m)^(?:/--|inductive|def|theorem|abbrev|structure|set_option|namespace|end|open|meta|noncomputable|@)', S10)]
    out = []
    for n in names:
        s = re.search(r'(?m)^(?:inductive|def|theorem) %s(?=\s)' % re.escape(n), S10).start()
        e = [x for x in starts if x > s][0]
        doc = re.search(r'/--(?:(?!/--).)*?-/\n\Z', S10[:s], re.S)
        out.append((doc.group(0) if doc else '') + S10[s:e].rstrip() + '\n')
    return '\n'.join(out)


def departure():
    """S14's declarations through ten_ticks, byte for byte"""
    t = (ROOT / 'Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30EtherThreeDeparture.lean').read_text(encoding='utf-8')
    body = t[t.index('/-! ### The thirteen recurrent states -/'):t.index('/-- **The wake settles.**')]
    return ('/-! ### Carried from `Rule30EtherThreeDeparture` (R30-20261123-f214f2), which the verifier\'s kit does not have -/\n\n'
            'namespace Rule30EtherThreeDeparture\n\nopen Rule30EtherThree Rule30EtherThreeErosion Rule30Jen Rule30Ether\n\n'
            + body + 'end Rule30EtherThreeDeparture\n\nopen Rule30EtherThreeDeparture (IsRec ten_ticks)\n')


def tours():
    o = []
    for w, d in D.items():
        r, l = tour(d)
        g = d['gate']
        dr = ' '.join('(wordAt3 w%s %s)' % (w, x) for x in (g, '(%d+1)' % g, '(%d+2)' % g))
        o.append('/-- The letters of a closed walk of %d periods through the trap of `%s`, three bits each, the first in the low bits. -/\n'
                 'def letters%s : Nat := 0x%x\n\n'
                 'theorem tour%s : tour %s %d letters%s %d 0 %d (bitset trap%s) = true := by decide +kernel\n'
                 % (len(l), w, w, sum(e << (3 * i) for i, e in enumerate(l)), w, dr, len(l), w, r, r, w))
    return '\n'.join(o)


def wrap(items, width=118, indent='  '):
    out, line = [], indent
    for x in items:
        if len(line) + len(x) + 2 > width:
            out.append(line.rstrip())
            line = indent
        line += x + ', '
    out.append(line.rstrip().rstrip(','))
    return '\n'.join(out)


def rev(x, n):
    return int(format(x, '0%db' % n)[::-1], 2)


def letters(w):
    if w.startswith('?'):
        return 'List.replicate 6 none ++ some false :: List.replicate 17 (some true)'
    return '[' + ', '.join('none' if c == '?' else 'some ' + B(c == '1') for c in w) + ']'


def tables():
    o = ['/-! ### The two tables -/\n']
    for w, d in D.items():
        pairs = [a | (b << 16) for a, b in d['branches']]
        chunks = ['0x%x' % sum(p << (32 * j) for j, p in enumerate(pairs[i:i + 32])) for i in range(0, len(pairs), 32)]
        o.append('/-- The payload for `%s`: %d time sets and %d branches. -/\nmeta def leaves%s : Array Nat := #[\n%s]\n'
                 'meta def chunks%s : Array Nat := #[\n%s]\n' % (w, len(d['leaves']), len(pairs), w,
                                                              wrap(['0x%x' % x for x in d['leaves']]), w, wrap(chunks)))
    o.append('''open Lean in
/-- Each 32-bit word of a chunk holds two earlier 16-bit node indices, low word first. The elaborator only proposes a tree;
every property of it is checked in the kernel. -/
meta def makeTree (leafMasks branchChunks : Array Nat) (branchCount : Nat) : MetaM Expr := do
  let mut nodes : Array (Nat × Nat × Expr) := #[]
  for m in leafMasks do
    nodes := nodes.push (m,m,mkApp (mkConst ``Tree.leaf) (mkNatLit m))
  for i in [:branchCount] do
    let pair := (branchChunks[i/32]! >>> (32*(i%32))) % 2^32
    let (loA,hiA,left) := nodes[pair%65536]!
    let (loB,hiB,right) := nodes[pair/65536]!
    let lo := loA &&& loB
    let hi := hiA ||| hiB
    nodes := nodes.push (lo,hi,mkApp4 (mkConst ``Tree.node) (mkNatLit lo) (mkNatLit hi) left right)
  return nodes.back!.2.2
''')
    for w, d in D.items():
        o.append('open Lean Elab Term in\nnoncomputable def table%s : Tree := by_elab\n  liftM (makeTree leaves%s chunks%s %d)\n'
                 % (w, w, w, len(d['branches'])))
        o.append('def white%s : Nat := 0x%x\ndef black%s : Nat := 0x%x\n' % (w, d['white'], w, d['black']))
    when = {'001': 'the white tick before the black one of `001`', '011': 'the white tick of `011`'}
    for w, d in D.items():
        o.append('/-- The gate trap of `%s`: %d windows of the first fourteen cells at %s, the first cell in the\nlow bit. -/\n'
                 'def trap%s : List Nat := [\n%s]\n' % (w, len(d['K']), when[w], w,
                                                        wrap([str(x) for x in sorted(d['K'], key=lambda x: rev(x, 14))])))
    for w, d in D.items():
        o.append('/-- The windows of %d cells that can stay outside the trap. -/\ndef outside%s : List Nat := [\n%s]\n'
                 % (d['W1'], w, wrap([str(x) for x in sorted(d['M'], key=lambda x: rev(x, d['W1']))])))
    for w, d in D.items():
        o.append('/-- Gate words that no row of the trap of `%s` reads, each with the place of its line in a mask. -/\n'
                 'def lines%s : List (Nat × List (Option Bool)) := [\n%s]\n'
                 % (w, w, ',\n'.join('  (%d, %s)' % (a, letters(v)) for a, v in d['words'])))
    for w, d in D.items():
        dr, A, Bb, m, n, Mb = ' '.join(B(x) for x in d['DR']), d['A'], d['B'], d['m'], d['n'] - d['m'], d['Mb']
        o += ['theorem valid%s : table%s.valid = true := by decide +kernel' % (w, w),
              'theorem walk%s : walkAll table%s white%s black%s %s = true := by decide +kernel' % (w, w, w, w, dr),
              'theorem free%s : freeFrom white%s black%s 0 1 = true := by decide +kernel' % (w, w, w),
              'theorem wrap%s : leaves (fun m => m.testBit 1 == m.testBit 0) table%s = true := by decide +kernel' % (w, w),
              'theorem isTrap%s : isTrap table%s trap%s = true := by decide +kernel' % (w, w, w),
              'theorem freeA%s : freeFrom white%s black%s %d %d = true := by decide +kernel' % (w, w, w, A, m),
              'theorem freeB%s : freeFrom white%s black%s %d %d = true := by decide +kernel' % (w, w, w, Bb, n),
              'theorem first%s : table%s.low.testBit %d = true := by decide +kernel' % (w, w, A),
              'theorem middle%s : leaves (fun k => !k.testBit (%d+%d) || (k.testBit %d || k.testBit %d)) table%s = true := by\n'
              '  decide +kernel' % (w, A, m, Bb, Mb, w),
              'theorem last%s : leaves (fun k => !k.testBit (%d+%d) || k.testBit 0) table%s = true := by decide +kernel' % (w, Bb, n, w),
              'theorem outsideCodes%s : codes %d table%s 0 0 %d = outside%s := by decide +kernel' % (w, Mb, w, d['W1'], w),
              'theorem wordLines%s : (lines%s.all fun l => wordLine table%s white%s black%s l.1 l.2) = true := by decide +kernel\n'
              % (w, w, w, w, w)]
    return '\n'.join(o)


OPTS = 'set_option maxRecDepth 100000\nset_option maxHeartbeats 0\nset_option Elab.async false\n\n'
DOC, DOC_TABLES = (HERE / 'doc_module.txt').read_text(encoding='utf-8'), (HERE / 'doc_tables.txt').read_text(encoding='utf-8')
OPENS = ('open Rule30Jen Rule30Ether Rule30EtherThree Rule30EtherThreeErosion Rule30StripCertificates\n'
         'open Rule30DrivenPrefix (step step_bit)\n')
CA = 'public import Ruliology.CellularAutomata.'
PROOF = ['walk', 'lines', 'ether', 'entry', 'main', 'runs', 'least', 'slope', 'left']
data = '\n'.join([part('defs'), tables(), tours(), part('chase')])
portal = ('module\n\n' + ''.join(CA + m + '\n' for m in ('Rule30EtherThreeErosion', 'Rule30EtherThreeSkeleton',
                                                       'Rule30EtherThreeLeft', 'Rule30DrivenPrefix'))
          + 'public meta import Lean.Elab.Term\n\n' + DOC + '\n@[expose] public section\n\n' + OPTS
          + 'namespace Rule30Submission\nopen Ruliology.CellularAutomata\n' + OPENS + '\n'
          + '\n'.join(["/-! ### Sets of times on spatial prefixes, carried from the kit's `Rule30TrappedRunMasks` -/\n", tree(), data]
                      + [part(n) for n in PROOF[:7]] + [departure()] + [part(n) for n in PROOF[7:]])
          + '\nend Rule30Submission\n')
K = OUT / 'kit/lean/Ruliology/CellularAutomata'
(OUT / 'portal').mkdir(parents=True, exist_ok=True)
(K / 'Rule30Certificates').mkdir(parents=True, exist_ok=True)
NS = 'namespace Ruliology.CellularAutomata.Rule30PeriodThreeEntry'
kit_data = ('module\n\n' + CA + 'Rule30Certificates.TrappedRunMasks\n' + CA + 'Rule30EtherThree\n'
            'public meta import Lean.Elab.Term\n\n' + DOC_TABLES + '\n@[expose] public section\n\n' + OPTS + NS + 'Tables\n'
            'open Rule30TrappedRunMasks (Tree subset)\nopen Rule30DrivenPrefix (step)\nopen Rule30EtherThree\n\n'
            + data.replace('``Tree.', '``Rule30TrappedRunMasks.Tree.') + '\nend Ruliology.CellularAutomata.Rule30PeriodThreeEntryTables\n')
kit = ('module\n\n' + CA + 'Rule30Certificates.PeriodThreeEntry\n' + CA + 'Rule30EtherThreeDeparture\n'
       + CA + 'Rule30PeriodThreeLanguage\n\n' + DOC + '\n@[expose] public section\n\n' + OPTS + NS + '\n'
       + OPENS + 'open Rule30TrappedRunMasks (Tree subset subset_sound)\nopen Rule30PeriodThreeEntryTables\n'
       'open Rule30EtherThreeDeparture (IsRec ten_ticks)\n\n'
       + '\n'.join(part(n) for n in PROOF + ['kit']) + '\nend Ruliology.CellularAutomata.Rule30PeriodThreeEntry\n')
assert '"' not in portal and '\\' not in portal
for f, t in ((OUT / 'portal/Rule30Submission.lean', portal), (K / 'Rule30Certificates/PeriodThreeEntry.lean', kit_data),
             (K / 'Rule30PeriodThreeEntry.lean', kit)):
    f.write_bytes(t.encode('utf-8'))
    print(f.relative_to(OUT), len(t.encode('utf-8')))
