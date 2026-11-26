"""Build two aligned ether-wall tables and replay any new first signal in physical coordinates."""
from argparse import ArgumentParser
from pathlib import Path
import sys

from replay import white_rows

sys.path.insert(0,str(Path(__file__).resolve().parents[2] / "k50_1"))
from claudeCloud_ether_lock import kit_data, ether_wall_windows


def make(kit):
    _, ether, walls = kit_data(str(kit / "lean/Ruliology/CellularAutomata"))
    result = {}
    for phase in (0,2):
        pattern = lambda start, size: sum(int(ether[(3+p)%7][phase]) << i for i,p in enumerate(range(start,start+size)))
        codes = {sum(int(b) << i for i,b in enumerate(cells)) for ph,cells in walls if ph==phase}
        result[phase] = (pattern(1,6), pattern(7,7), codes)
    # Check every member, both time phases, all four exterior completions.
    # k=6,13 suffice for the local boundary and one full spatial repeat;
    # the all-k carrying theorem is Rule30Ether.trap_invariant.
    for k in (6,13):
        width = k+13
        classes = ether_wall_windows(ether,walls,k)
        for phase, codes in classes.items():
            for code in codes:
                for hi in range(4):
                    x = code | (hi << width)
                    x=(x<<1) ^ (x | (x>>1))
                    x=((x<<1) | 1) ^ (x | (x>>1))
                    assert x % (1<<width) in classes[2-phase]
    return result


def matches(row, tables):
    for phase,(first, more, walls) in tables.items():
        if row % 64 != first:
            continue
        k=6
        rem=row >> k
        while True:
            if rem % 8192 in walls:
                return k,phase
            if rem % 128 != more:
                break
            rem >>= 7
            k += 7


def main():
    p=ArgumentParser(description=__doc__)
    p.add_argument("kit",type=Path)
    p.add_argument("outfile",type=Path)
    p.add_argument("--verify",type=int,nargs="*",default=[])
    p.add_argument("--samples",type=int,default=8192)
    args=p.parse_args()
    tables=make(args.kit)
    args.outfile.write_text("".join(f"{ph} {prefix} {more} {wall}\n" for ph,(prefix,more,walls) in tables.items()
                                    for wall in sorted(walls)),encoding="ascii")
    for seed in args.verify:
        for s,row in enumerate(white_rows(seed)):
            lock = matches(row,tables)
            if lock:
                arm,phase=lock
                print(seed,s,2*s+1,arm,phase,row% (1<<(arm+13)))
                break
            if s+1==args.samples:
                print(seed,"no ether-wall through",s)
                break


if __name__ == "__main__":
    main()
