#!/usr/bin/env python3
"""build_s15.py TABLE.json OUTDIR: assembles S15 (ledger M148).

OUTDIR/portal/Rule30Submission.lean   one file for the verifier's pin, which has no Rule30TrappedRunMasks: S10's tree and its
                                      walk are carried from research/m9/compact, declaration by declaration
OUTDIR/kit/...                        Rule30GateObserver and Rule30Certificates/GateObserverTree, on the kit's own modules
"""
import json, pathlib, sys
HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
S10 = (ROOT / 'research/m9/compact/Rule30Submission.lean').read_text()
D = json.load(open(sys.argv[1]))
OUT = pathlib.Path(sys.argv[2])


def part(n):
    return (HERE / ('part_%s.txt' % n)).read_text().rstrip('\n') + '\n'


def machinery():
    i = S10.index('/-- Leaves describe the sample times')
    j = S10.index('theorem step_all')
    end = 'simpa only [Tree.follow_value] using out\n'
    k = S10.index(end, j) + len(end)
    return S10[i:k]


def wrap(items, width=118, indent='  '):
    out, line = [], indent
    for x in items:
        if len(line) + len(x) + 2 > width:
            out.append(line.rstrip())
            line = indent
        line += x + ', '
    out.append(line.rstrip().rstrip(','))
    return '\n'.join(out)


def table():
    leaves = ['0x%x' % m for m in D['leaves']]
    pairs = [a | (b << 16) for a, b in D['branches']]
    chunks = []
    for i in range(0, len(pairs), 32):
        v = 0
        for j, p in enumerate(pairs[i:i + 32]):
            v |= p << (32 * j)
        chunks.append('0x%x' % v)
    return ('''/-- The literal payload: %d time masks and %d branches. Each 32-bit word of a chunk holds two earlier 16-bit node
indices, low word first. The elaborator only proposes a tree; every property of it is checked in the kernel. -/
meta def leafMasks : Array Nat := #[
%s]
meta def branchChunks : Array Nat := #[
%s]
meta def branchCount : Nat := %d

open Lean in
meta def makeTree : MetaM Expr := do
  let mut nodes : Array (Nat × Nat × Expr) := #[]
  for m in leafMasks do
    nodes := nodes.push (m,m,mkApp (mkConst ``Tree.leaf) (mkNatLit m))
  for i in [:branchCount] do
    let pair := (branchChunks[i/32]! >>> (32*(i%%32))) %% 2^32
    let (loA,hiA,left) := nodes[pair%%65536]!
    let (loB,hiB,right) := nodes[pair/65536]!
    let lo := loA &&& loB
    let hi := hiA ||| hiB
    nodes := nodes.push (lo,hi,mkApp4 (mkConst ``Tree.node) (mkNatLit lo) (mkNatLit hi) left right)
  return nodes.back!.2.2

open Lean Elab Term in
noncomputable def table : Tree := by_elab
  liftM makeTree

/-- The times at which a reading may be white, and black, on the eleven lines; the first time of each line is in neither. -/
def whiteMask : Nat := 0x%x
def blackMask : Nat := 0x%x
''' % (len(leaves), len(pairs), wrap(leaves), wrap(chunks), len(pairs), D['white'], D['black']))


OPTS = 'set_option maxRecDepth 100000\nset_option maxHeartbeats 0\nset_option Elab.async false\n'
DOC = (HERE / 'doc_module.txt').read_text()
DOC_TREE = (HERE / 'doc_tree.txt').read_text()


def main():
    (OUT / 'portal').mkdir(parents=True, exist_ok=True)
    K = OUT / 'kit/lean/Ruliology/CellularAutomata'
    (K / 'Rule30Certificates').mkdir(parents=True, exist_ok=True)
    reads = '''/-- The gate reads the word `w` from the step `s`. -/
def Reads (v : Nat → Bool) (s : Nat) (w : List Bool) : Prop := ∀ i, i < w.length → v (s + i) = w.getD i false

'''
    opens = ('open Rule30GateTrap Rule30DrivenPrefix Rule30Ether Rule30StripCertificates Rule30PeriodTwoCoupled '
             'Rule30PeriodTwoSideways\nopen Rule30ZeroBoundary\n')
    portal = ('module\n\npublic import Ruliology.CellularAutomata.Rule30Prize\npublic import '
              'Ruliology.CellularAutomata.Rule30GateTrap\npublic meta import Lean.Elab.Term\n\n' + DOC +
              '\n@[expose] public section\n\n' + OPTS +
              'namespace Rule30Submission\nopen Ruliology.CellularAutomata\n' + opens +
              '\n/-! ### Sets of times on spatial prefixes, carried from the kit\'s `Rule30TrappedRunMasks` -/\n\n' + machinery() +
              '\n/-! ### The table -/\n\n' + table() + '\n' + part('lines') + '\n' + reads + part('observer') + '\n' + part('sharp') +
              '\nend Rule30Submission\n')
    (OUT / 'portal/Rule30Submission.lean').write_text(portal)
    tree = ('module\n\npublic import Ruliology.CellularAutomata.Rule30Certificates.TrappedRunMasks\n'
            'public meta import Lean.Elab.Term\n\n' + DOC_TREE + '\n@[expose] public section\n\n' + OPTS +
            'namespace Ruliology.CellularAutomata.Rule30GateObserverTree\nopen Rule30TrappedRunMasks (Tree checkAt '
            'step_all)\nopen Rule30GateTrap Rule30DrivenPrefix\n\n' + table().replace('``Tree.', '``Rule30TrappedRunMasks.Tree.') + '\n' + part('lines') +
            '\nend Ruliology.CellularAutomata.Rule30GateObserverTree\n')
    (K / 'Rule30Certificates/GateObserverTree.lean').write_text(tree)
    kit = ('module\n\npublic import Ruliology.CellularAutomata.Rule30Certificates.GateObserverTree\n'
           'public import Ruliology.CellularAutomata.Rule30GateTrapWords\n\n' + DOC + '\n@[expose] public section\n\n' + OPTS +
           'namespace Ruliology.CellularAutomata.Rule30GateObserver\nopen Rule30GateObserverTree Rule30GateTrapWords\n'
           'open Rule30TrappedRunMasks (Tree)\n' + opens + '\n' + part('observer') + '\n' + part('sharp') +
           '\nend Ruliology.CellularAutomata.Rule30GateObserver\n')
    (K / 'Rule30GateObserver.lean').write_text(kit)
    assert '"' not in portal and '\\' not in portal, 'the source must hold no quote and no backslash'
    for f in sorted(OUT.rglob('*.lean')):
        print(f.relative_to(OUT), f.stat().st_size)


main()
