"""Check long-gap five-mark families for a prescribed source period modulo eight.

Only four internal gap lengths of paths that can actually reach a bare row at
the target width need replay. The fifth gap is long and sets the clock residue.
"""
import argparse

from gptIntel_five_cluster_box import first_column, replay
from gptIntel_gap_compression import plateau
from gptIntel_marked_path_core import ordinary_cycles, retained_paths, white_returns
from gptIntel_three_pulse_census import trace_first
from gptIntel_three_pulses import step


def test(width, ordinary, residues):
    kept = None
    for w in range(3, width + 1):
        kept, counts = retained_paths(w, ordinary, 5, kept)
    if any(counts[:5]):
        raise ValueError('a bare row before mark five needs a separate completion test')
    h, c = plateau(width, ordinary)
    if c != 8:
        raise ValueError('this test classifies residues modulo eight')
    cap = h + 2*c
    mask = (1 << width) - 1
    gaps_to_check = set()

    def follow(row, gaps):
        marked = len(gaps) + 1
        row = step(row, mask) ^ (1 - ordinary)
        if row not in kept[marked]:
            return
        if marked == 5:
            gaps_to_check.add(gaps)
            return
        for gap in range(1, cap + 1):
            follow(row, gaps + (gap,))
            row = step(row, mask) ^ ordinary
            if row not in kept[marked]:
                break

    for cycle, _ in ordinary_cycles(width, ordinary):
        for start in cycle:
            if start in kept[0]:
                follow(start, ())

    threshold = h+c+1
    required, _, possible_white = white_returns(width, ordinary, 5)
    assert threshold >= required and not possible_white
    for residue in residues:
        failed = replay_residue(gaps_to_check, threshold, c, width, ordinary, residue)
        if residue == 0 and width == (88 if ordinary else 104):
            assert not failed, 'the proposed sharp dyadic bound has a surviving row'


def replay_residue(gaps_to_check, threshold, c, width, ordinary, residue):
    failures = []
    for internal in sorted(gaps_to_check):
        last = threshold + (residue - sum(internal) - threshold) % c
        gaps = internal + (last,)
        period = sum(gaps)
        column = first_column(gaps)
        if ordinary:
            if period % 2:
                continue
            column ^= 2 * (((1 << (2*period))-1)//3)
        _, pending, _ = trace_first(column, 2*period, width)
        if pending:
            failures.append(gaps)

    print(f'ordinary={ordinary} width={width} long_gap={threshold} period_mod_8={residue} '
          f'internal_tuples={len(gaps_to_check)} still_bare={len(failures)}', flush=True)
    if failures:
        first = failures[0]
        print('representative', first, replay(first, bool(ordinary), 140), flush=True)
        if residue == 0:
            p = 1 << (sum(first)-1).bit_length()
            dyadic = first[:-1]+(p-sum(first[:-1]),)
            print('dyadic witness', dyadic, replay(dyadic, bool(ordinary), 140), flush=True)
    return bool(failures)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('ordinary', type=int, choices=(0, 1))
    parser.add_argument('width', type=int)
    parser.add_argument('--residue', type=int, choices=range(8), default=0)
    parser.add_argument('--all-residues', action='store_true',
                        help='include other admissible clock residues as controls')
    args = parser.parse_args()
    if args.ordinary and args.residue % 2:
        parser.error('five white ticks require even period for odd black weight')
    residues = range(0, 8, 2 if args.ordinary else 1) if args.all_residues else [args.residue]
    test(args.width, args.ordinary, residues)
