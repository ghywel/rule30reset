#!/usr/bin/env python3
"""build_s16.py T001.json T011.json OUTDIR: assembles the portable file (ledger M152) from the tables of make_table.py and the parts.

OUTDIR/Rule30Submission.lean: S10's tree is carried from research/m9/compact, declaration by declaration."""
import json, pathlib, re, sys
HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
S10 = (ROOT / 'research/m9/compact/Rule30Submission.lean').read_text()
D = {w: json.load(open(p)) for w, p in zip(('001', '011'), sys.argv[1:3])}
OUT = pathlib.Path(sys.argv[3])
OUT.mkdir(parents=True, exist_ok=True)
B = lambda b: 'true' if b else 'false'


def part(n):
    return (HERE / ('part_%s.txt' % n)).read_text().rstrip('\n') + '\n'


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
              'theorem wrap%s : (table%s.leaves fun m => m.testBit 1 == m.testBit 0) = true := by decide +kernel' % (w, w),
              'theorem isTrap%s : isTrap table%s trap%s = true := by decide +kernel' % (w, w, w),
              'theorem freeA%s : freeFrom white%s black%s %d %d = true := by decide +kernel' % (w, w, w, A, m),
              'theorem freeB%s : freeFrom white%s black%s %d %d = true := by decide +kernel' % (w, w, w, Bb, n),
              'theorem first%s : table%s.low.testBit %d = true := by decide +kernel' % (w, w, A),
              'theorem middle%s : (table%s.leaves fun k => !k.testBit (%d+%d) || (k.testBit %d || k.testBit %d)) = true := by\n'
              '  decide +kernel' % (w, w, A, m, Bb, Mb),
              'theorem last%s : (table%s.leaves fun k => !k.testBit (%d+%d) || k.testBit 0) = true := by decide +kernel' % (w, w, Bb, n),
              'theorem outsideCodes%s : table%s.codes %d 0 0 %d = outside%s := by decide +kernel' % (w, w, Mb, d['W1'], w),
              'theorem wordLines%s : (lines%s.all fun l => wordLine table%s white%s black%s l.1 l.2) = true := by decide +kernel\n'
              % (w, w, w, w, w)]
    return '\n'.join(o)


HEAD = '''module

public import Ruliology.CellularAutomata.Rule30EtherThreeErosion
public import Ruliology.CellularAutomata.Rule30EtherThreeSkeleton
public import Ruliology.CellularAutomata.Rule30EtherThreeLeft
public import Ruliology.CellularAutomata.Rule30DrivenPrefix
public meta import Lean.Elab.Term

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Rule30Submission
open Ruliology.CellularAutomata
open Rule30Jen Rule30Ether Rule30EtherThree Rule30EtherThreeErosion Rule30StripCertificates
open Rule30DrivenPrefix (step step_bit)

'''
src = HEAD + '\n'.join([tree(), part('walk'), part('lines'), tables(), part('ether'), part('entry'), part('main'), part('runs'),
                        part('left')]) + '\nend Rule30Submission\n'
assert '"' not in src and '\\' not in src
(OUT / 'Rule30Submission.lean').write_text(src)
print('Rule30Submission.lean', len(src.encode()))
