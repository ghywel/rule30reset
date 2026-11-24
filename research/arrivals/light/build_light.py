#!/usr/bin/env python3
"""build_light.py TABLE.json OUT.lean: assembles the portable file (ledger M156) from make_table.py's table and the parts."""
import json, pathlib, re, sys
HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
S10 = (ROOT / 'research/m9/compact/Rule30Submission.lean').read_text(encoding='utf-8')
d = json.loads(pathlib.Path(sys.argv[1]).read_bytes())
B = lambda b: 'true' if b else 'false'


def part(n):
    return (HERE / 'parts' / ('part_%s.txt' % n)).read_text(encoding='utf-8').rstrip('\n') + '\n'


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
    return '[' + ', '.join('some ' + B(c == '1') for c in w) + ']'


def tables():
    pairs = [a | (b << 16) for a, b in d['branches']]
    chunks = ['0x%x' % sum(p << (32 * j) for j, p in enumerate(pairs[i:i + 32])) for i in range(0, len(pairs), 32)]
    o = ['/-! ### The table -/\n']
    o.append('/-- The payload: %d time sets and %d branches. -/\nmeta def leafData : Array Nat := #[\n%s]\n'
             'meta def chunkData : Array Nat := #[\n%s]\n' % (len(d['leaves']), len(pairs), wrap(['0x%x' % x for x in d['leaves']]),
                                                           wrap(chunks)))
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
    o.append('open Lean Elab Term in\nnoncomputable def table01 : Tree := by_elab\n  liftM (makeTree leafData chunkData %d)\n' % len(d['branches']))
    o.append('def white01 : Nat := 0x%x\ndef black01 : Nat := 0x%x\n' % (d['white'], d['black']))
    o.append('/-- The closed set: %d windows of the first twelve cells at a white tick, the first cell in the low bit. -/\n'
             'def closedSet : List Nat := [\n%s]\n' % (len(d['K']), wrap([str(x) for x in sorted(d['K'], key=lambda x: rev(x, 12))])))
    o.append('/-- The windows of %d cells that can stay outside the closed set. -/\ndef outside01 : List Nat := [\n%s]\n'
             % (d['W1'], wrap([str(x) for x in sorted(d['M'], key=lambda x: rev(x, d['W1']))])))
    o.append('/-- The gate words that no row of the closed set reads, each with the place of its line in a mask. -/\n'
             'def lines01 : List (Nat × List (Option Bool)) := [\n%s]\n' % ',\n'.join('  (%d, %s)' % (a, letters(v)) for a, v in d['words']))
    A, Bb, m, n, Mb = d['A'], d['B'], d['m'], d['n'] - d['m'], d['Mb']
    dr = ' '.join(B(x) for x in d['DR'])
    o += ['theorem valid01 : table01.valid = true := by decide +kernel',
          'theorem walk01 : walkAll table01 white01 black01 %s = true := by decide +kernel' % dr,
          'theorem free01 : freeFrom white01 black01 0 1 = true := by decide +kernel',
          'theorem wrap01 : leaves (fun m => m.testBit 1 == m.testBit 0) table01 = true := by decide +kernel',
          'theorem isTrap01 : isTrap table01 closedSet = true := by decide +kernel',
          'theorem freeA01 : freeFrom white01 black01 %d %d = true := by decide +kernel' % (A, m),
          'theorem freeB01 : freeFrom white01 black01 %d %d = true := by decide +kernel' % (Bb, n),
          'theorem first01 : table01.low.testBit %d = true := by decide +kernel' % A,
          'theorem middle01 : leaves (fun k => !k.testBit (%d+%d) || (k.testBit %d || k.testBit %d)) table01 = true := by\n  decide +kernel' % (A, m, Bb, Mb),
          'theorem last01 : leaves (fun k => !k.testBit (%d+%d) || k.testBit 0) table01 = true := by decide +kernel' % (Bb, n),
          'theorem outsideCodes01 : codes %d table01 0 0 %d = outside01 := by decide +kernel' % (Mb, d['W1']),
          'theorem wordLines01 : (lines01.all fun l => wordLine table01 white01 black01 l.1 l.2) = true := by decide +kernel\n']
    return '\n'.join(o)


CA = 'public import Ruliology.CellularAutomata.'
OPTS = 'set_option maxRecDepth 100000\nset_option maxHeartbeats 0\nset_option Elab.async false\n\n'
text = ('module\n\n' + ''.join(CA + m + '\n' for m in ('Rule30Ether', 'Rule30MaskedJen', 'Rule30StripCertificates', 'Rule30DrivenPrefix'))
        + 'public meta import Lean.Elab.Term\n\n' + (HERE / 'doc_module.txt').read_text(encoding='utf-8') + '\n@[expose] public section\n\n' + OPTS
        + 'namespace Rule30ArrivalsLight\nopen Ruliology.CellularAutomata\nopen Rule30Jen Rule30Ether Rule30MaskedJen Rule30StripCertificates\n'
        'open Rule30DrivenPrefix (step step_bit)\nopen Rule30PeriodTwoCoupled (altCol)\n\n'
        + '\n'.join(["/-! ### Sets of times on spatial prefixes, carried from `Rule30TrappedRunMasks` -/\n", tree(), part('defs'), tables()]
                    + [part(n) for n in ('walk', 'lines', 'entry', 'law', 'letters', 'set', 'decode', 'single')])
        + '\nend Rule30ArrivalsLight\n')
pathlib.Path(sys.argv[2]).write_text(text, encoding='utf-8')
print(len(text.encode()))
