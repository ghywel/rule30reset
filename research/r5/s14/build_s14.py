#!/usr/bin/env python3
"""build_s14.py OUTDIR: assembles S14 from its parts (ledger M138).

OUTDIR/portal/Rule30Submission.lean     one file for the verifier's pin, which has no Rule30EtherThreeNotAbsorption: the
                                        table of trap001fifteen is carried from the kit's main, declaration by declaration
OUTDIR/kit/...                          three modules and one data module in the kit's module form
"""
import pathlib, re, sys
HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
import claudeM5_r5_reach_tables as t
import claudeM5_r5_reach_lean as rl
sys.set_int_max_str_digits(0)
ROOT = HERE.parents[2]
KITSRC = ROOT / 'Rule30PrizeKit/lean/Ruliology/CellularAutomata'


def part(n):
    return (HERE / ('part_%s.txt' % n)).read_text().rstrip() + '\n'


DOC_DEP = '''/-!
# Leaving the period-3 ether: one path and an exact time

Setting of `Rule30EtherThreeErosion`: `F` is a rule-30 evolution of the columns `p ≥ 1` whose column `0` is ether column
`j0` with phase offset `s`. That column may read either word of least period three. The *front* is the first column that
differs from the ether; its state is the class of its column and whether the next column differs too. `wake_good` proves
that from a good front `5 D + 2 t + ψ` does not increase.

* Thirteen of the good states are closed (`IsRec`), and from a recurrent front `5 D + 2 t + ψ`, with `ψ` the class itself
  (and `2` for one state), is **exactly conserved** until the front reaches column `1`, for every right side (`rigid_step`,
  `rigid_path`). Any other good front settles to a recurrent one within its rank, at most five ticks, if it has room: a
  front at column `rank + 2` or beyond does (`settles`).
* So two recurrent fronts beside the same ether column that start at one column with one value of `ψ` are at one column at
  every later tick through their first arrival at column `1`, whatever lies to the right (`same_path`). From column `7` or
  beyond, ten ticks take a recurrent front exactly four columns left (`ten_ticks`).
* From a recurrent front the tick at which column `1` first leaves the ether is a formula in its column and state
  (`first_departure`).
* From an aligned prefix of **any** length `N ≥ 3` that breaks at the next tick, it is a formula in `N`, the class of
  column `N` and one bit (`departure_after_exit`). The cells beyond the prefix are arbitrary. At one class and bit, twelve
  more columns cost thirty more ticks for `N ≥ 4` (`exitWait_add_twelve`); from `N = 3` one exit state gives 28.

Two other backgrounds have exact front speeds in `Rule30MovingWall`. Here the whole path is fixed, and the first departure
with it.
-/
'''
DOC_REACH = '''/-!
# The 15-trap for `001` is closed to ether prefixes and to white prefixes

`Rule30EtherThreeNotAbsorption` refutes `AbsorptionT t001` with a second trap, `trap001fifteen`. Here a set of windows of
twenty cells, one for each phase of the drive, holds that trap's states cut to twenty cells and is closed under
predecessors: if the next window is in the set, so is this one, whatever the cell beyond. No window of the aligned
period-3 ether is in it, and none whose first sixteen cells are white. So a right half that shows either at some tick is
from then on in no state of the trap whose label reads the drive's phase, whatever lies beyond those cells.

* `accR`: membership, a layered automaton that reads a window from cell `20` down to cell `1` (`54,576` windows).
* `chk`, `chk_sound`: one recursion along the automaton that checks closure under predecessors.
* `back`: membership at a tick gives membership at every earlier tick of the drive.
* `no_fifteen_after_ether`, `no_fifteen_after_white`: the two consequences.

Refuting entry by a set of windows closed under predecessors is L. Hallee's method (`lhallee/rule30-open`,
`Columns.ReachRefuted`).
-/
'''
DOC_GATE = '''/-!
# The gate of `001`

`Rule30EtherThreeTrap` reduces the word `001` to `AbsorptionT t001`, that every finite right half enters one trap, and
`Rule30EtherThreeNotAbsorption` proves that false. The masked form of Jen's theorem asks only about the white ticks of the
center. On the first white tick of each `001` column `1` is eventually white if the center ends in `001`
(`skeleton_001`). The second is the one white phase left: call column `1` there the *gate*.

* `gate_of_t001`, `gate_of_fifteen`: a right half that enters `t001` at a label of the drive's phase has a gate that repeats
  `1100000` from some tick on; one that so enters `trap001fifteen` has `11000`.
* `GatePeriodic` (open): the gate of every finitely supported right half, from every phase, is eventually periodic. It
  excludes `001` as an eventual tail of the center column (`not_eventually_001_of_gatePeriodic`). It is the form for `001`
  of `Rule30Ether.Lock`, which is for period four. It follows if, from every drive phase, each finitely supported right half
  enters some checked trap of positive width for `001` (`gatePeriodic_of_some_trap`).
* `GateEntry` (open): those gates eventually repeat `1100000` or `11000`. It implies `GatePeriodic` and names no trap.

`Rule30PeriodThreeLanguage.col1_001` restricts the gate of the center's own orbit. L. Hallee (`lhallee/rule30-open`) proves
that the gate of every right half avoids `010`, `101` and `1001` from its reading `14` on (`Columns.ThreeRuns`), that entry
into some trap suffices and entry into `t001` or `trap001fifteen` fails (`Columns.Traps001`).
-/
'''


def carried():
    s = (KITSRC / 'Rule30EtherThreeNotAbsorption.lean').read_text()
    out = []
    for name in ('trap001fifteen_R', 'trap001fifteen_L', 'trap001fifteen_S'):
        out.append(re.search(r'^def %s : Nat := \d+$' % name, s, re.M).group(0))
    out.append('')
    i = s.index('/-- The period-15 trap for `001`')
    j = s.index('theorem trap001fifteen_check')
    k = s.index('\n', j)
    out.append(s[i:k])
    return '\n'.join(out) + '\n'


def tables():
    tmp = HERE / 'tables.tmp'
    t.main(str(tmp))
    r = tmp.read_text()
    tmp.unlink()
    return r


def reach_body():
    b = rl.BODY
    b = b.lstrip('\n')
    return b[:b.index('end Rule30EtherThreeNoFifteen')].rstrip() + '\n'


OPEN_DEP = 'open Rule30EtherThree Rule30EtherThreeErosion Rule30Jen Rule30Ether\n'
OPEN_REACH = 'open Rule30Jen Rule30Ether Rule30EtherThree Rule30EtherThreeNotAbsorption\n'
OPEN_GATE = 'open Rule30Jen Rule30StripCertificates Rule30Ether Rule30EtherThree Rule30EtherThreeNotAbsorption\n'


def main(out):
    out = pathlib.Path(out)
    (out / 'portal').mkdir(parents=True, exist_ok=True)
    kit = out / 'kit/lean/Ruliology/CellularAutomata'
    (kit / 'Rule30Certificates').mkdir(parents=True, exist_ok=True)
    dep = part('rigid') + '\n' + part('departure') + '\n' + part('exit')
    gate = part('gate')
    body, tab = reach_body(), tables()
    hdr = 'module\n\n'
    kns = 'namespace Ruliology.CellularAutomata\nnamespace %s\n\n'
    kend = '\nend %s\nend Ruliology.CellularAutomata\n'
    (kit / 'Rule30EtherThreeDeparture.lean').write_text(
        hdr + 'public import Ruliology.CellularAutomata.Rule30EtherThreeErosion\n\n' + DOC_DEP +
        '\n@[expose] public section\n\n' + kns % 'Rule30EtherThreeDeparture' + OPEN_DEP + '\n' + dep + kend % 'Rule30EtherThreeDeparture')
    (kit / 'Rule30Certificates/EtherThreeReach20.lean').write_text(
        hdr + '/-!\nThe windows of twenty cells that can lead to `trap001fifteen`, as three layered automata, one for each phase of '
        'the drive\n(`Rule30EtherThreeNoFifteen`). A window is read from cell `20` down to cell `1`; node `0` is dead; node `n` has '
        'its two\nsuccessors in the bits `26 n` to `26 n + 12` (next cell white) and the next thirteen (black).\n-/\n'
        '\n@[expose] public section\n\nnamespace Ruliology.CellularAutomata.Rule30EtherThreeReach20\n\n' + tab +
        '\nend Ruliology.CellularAutomata.Rule30EtherThreeReach20\n')
    (kit / 'Rule30EtherThreeNoFifteen.lean').write_text(
        hdr + 'public import Ruliology.CellularAutomata.Rule30EtherThreeNotAbsorption\n'
        'public import Ruliology.CellularAutomata.Rule30Certificates.EtherThreeReach20\n\n' + DOC_REACH +
        '\n@[expose] public section\n\n' + kns % 'Rule30EtherThreeNoFifteen' + OPEN_REACH + 'open Rule30EtherThreeReach20\n\n' +
        body + kend % 'Rule30EtherThreeNoFifteen')
    (kit / 'Rule30EtherThreeGate.lean').write_text(
        hdr + 'public import Ruliology.CellularAutomata.Rule30EtherThreeNotAbsorption\n'
        'public import Ruliology.CellularAutomata.Rule30EtherThreeSkeleton\n\n' + DOC_GATE +
        '\n@[expose] public section\n\n' + kns % 'Rule30EtherThreeGate' + OPEN_GATE + '\n' + gate + kend % 'Rule30EtherThreeGate')
    p = ['import Rule30PrizeKit\n', 'import Ruliology.CellularAutomata.Rule30EtherThreeErosion\n',
         'import Ruliology.CellularAutomata.Rule30EtherThreeSkeleton\n', 'import Ruliology.CellularAutomata.Rule30EtherThreeTrap\n\n',
         'namespace Rule30Submission\n\nopen Ruliology.CellularAutomata\n\n', DOC_DEP,
         '\nnamespace Rule30EtherThreeDeparture\n\n', OPEN_DEP, '\n', dep, '\nend Rule30EtherThreeDeparture\n\n',
         '/-! ## The trap of `Rule30EtherThreeNotAbsorption`, carried from the kit -/\n\nnamespace Rule30EtherThreeNotAbsorption\n\n',
         'open Rule30Jen Rule30StripCertificates Rule30Ether Rule30EtherThree\n\n', carried(), '\nend Rule30EtherThreeNotAbsorption\n\n',
         DOC_REACH, '\nnamespace Rule30EtherThreeNoFifteen\n\n', OPEN_REACH, '\n', tab, '\n', body, '\nend Rule30EtherThreeNoFifteen\n\n',
         DOC_GATE, '\nnamespace Rule30EtherThreeGate\n\n', OPEN_GATE, '\n', gate, '\nend Rule30EtherThreeGate\n\nend Rule30Submission\n']
    src = ''.join(p)
    assert '"' not in src and '\\' not in src
    (out / 'portal/Rule30Submission.lean').write_text(src)
    for f in sorted(out.rglob('*.lean')):
        print(f.relative_to(out), f.stat().st_size)


if __name__ == '__main__':
    main(sys.argv[1])
