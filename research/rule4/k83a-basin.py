"""Reproduce I227's finite-horizon basin split. The .cpp reads the tables made here.

Compile k83a-basin.cpp with g++ -std=c++17 -O3 -fopenmp -o basin.
Run python k83a-basin.py PATH_TO_BASIN SCRATCH_DIR from the research repository.
Requires numpy. The optional --ids file is one decimal cohort index per line.
"""
import argparse
from collections import Counter
from fractions import Fraction
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

import numpy as np

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(ROOT / 'research/k50_1'))
from gptM5_sample import Destinations, controls, lean_list, step

NAMES = ('trap', 'lock7', 'lock7b', 'ether', 'lock5')
SEED = 20261124
MASK = 2**64-1


def make_tables(directory):
    kit = ROOT / 'Rule30PrizeKit'
    dest = Destinations(kit)
    controls(dest)
    source = kit / 'lean/Ruliology/CellularAutomata/Rule30SidewaysLocks.lean'
    five = set(x for group in lean_list(source.read_text(encoding='utf8'), 'lock5Codes') for x in group)
    lines = []
    for group in (dest.trap, dest.locks[0][3], dest.locks[1][3], five):
        lines.append(' '.join(map(str, (len(group), *sorted(group)))))
    for phase in range(4):
        walls = sorted(code for p, code in dest.walls if phase == p)
        lines.append(' '.join(map(str, (dest.first_six[phase], dest.next_seven[phase], len(walls), *walls))))
    out = directory / 'kit-tables.txt'
    out.write_text('\n'.join(lines)+'\n', encoding='ascii')
    return out, dest, five


def initial(row_id, nwords):
    state = (SEED + row_id * 0x2545F4914F6CDD1D) & MASK
    row = 0
    for j in range(nwords):
        state = (state+0x9E3779B97F4A7C15) & MASK
        z = ((state ^ (state>>30))*0xBF58476D1CE4E5B9) & MASK
        z = ((z ^ (z>>27))*0x94D049BB133111EB) & MASK
        row |= (z ^ (z>>31)) << (64*j)
    return row


def replay(row_id, samples, dest, five):
    row = initial(row_id, (2*samples+64+63)//64)
    reading = []
    seen = [-1]*5
    for t in range(2*samples-1):
        row = step(row,t)
        if t%2:
            continue
        result = dest.classify(row, t+1)
        if result and result['width'] <= 61:
            k = NAMES.index(result['class'])
            if seen[k] < 0:
                seen[k] = t//2
        if seen[4] < 0 and row % 2**34 in five:
            seen[4] = t//2
        reading.append(row & 1)
    tail = reading[-200:]
    period = next((p for p in range(1,61) if tail[p:] == tail[:-p]),0)
    return seen + [period]


def atoms(exe, directory, dest):
    """Exclude overlap, verify phase alignment, and replay sample 0 directly."""
    word = '0101000'
    short, long = dest.locks
    if set(short[3]) & {code%2**30 for code in long[3]}:
        raise ValueError('lock cylinder overlap')
    source = []
    expected = Counter()
    for _, width, reading, lookup in dest.locks:
        offset = (word+word).index(reading)
        for code, phase in lookup.items():
            canonical = (phase+offset)%7
            source.append(f'{width} {canonical} {code}\n')
            for pair in range(4):
                bits = [0]*(width-1) + [pair&1, pair>>1]
                for j in reversed(range(1,width)):
                    bits[j-1] = (code>>j & 1) ^ (bits[j]|bits[j+1])
                parent = sum(bit<<j for j,bit in enumerate(bits))
                if step(parent,0) % (1<<width) == code:
                    expected[canonical,width] += 1
    result = subprocess.check_output([str(exe.resolve())],input=''.join(source),text=True)
    lines = [list(map(int,line.split())) for line in result.splitlines()[1:]]
    assert len(lines)==35
    past = [Fraction(0)]*7
    for s,phase,a,b,num,den in lines:
        if s==0:
            assert a==expected[phase,30] and b==expected[phase,45]
        bound = Fraction(num,den)
        assert bound==Fraction(a,1<<(31+2*s))+Fraction(b,1<<(46+2*s)) and bound>=past[phase]
        past[phase] = bound
    (directory/'atom-counts.txt').write_bytes(result.encode('ascii'))
    print('individual atom lower bounds by sample 4:', *(str(v) for v in past))


def cover(exe, directory, dest):
    """Feed the two directly testable finite families to the cylinder counter."""
    trap = bytearray(1<<16)
    ether = bytearray(1<<19)
    for code in dest.trap:
        trap[code] = 1
    for phase, wall in dest.walls:
        if phase in (0,2):
            ether[dest.first_six[phase] | (wall<<6)] = 1
    for name, width, _, lookup in dest.locks:
        largest = max(Counter(x % (1<<24) for x in lookup).values())
        print(name, 'largest 24-bit fibre', largest, 'of', 1<<(width-24))
    data = directory/'cover-families.bin'
    data.write_bytes(trap+ether)
    result = subprocess.check_output([str(exe.resolve()),str(data)],text=True)
    lines = result.splitlines()
    assert lines[0] == 'minimum cylinder widths 12 16'
    previous = (Fraction(0),Fraction(0))
    rows = [list(map(int,s.split())) for s in lines[2:]]
    assert [row[0] for row in rows] == [16,20,24,25,26,27,28]
    for width,horizon,trapped,locked,open_count,denominator in rows:
        assert horizon==128 and trapped+locked+open_count==denominator==2**width
        current = (Fraction(trapped,denominator),Fraction(locked,denominator))
        assert all(earlier<=later for earlier,later in zip(previous,current))
        previous = current
    (directory/'cover-counts.txt').write_bytes(result.encode('ascii'))
    print(result)


def main():
    arg = argparse.ArgumentParser(description=__doc__)
    arg.add_argument('exe', type=Path)
    arg.add_argument('directory', type=Path)
    arg.add_argument('--samples', type=int, default=600)
    arg.add_argument('--size', type=int, default=1048576)
    arg.add_argument('--ids', type=Path)
    arg.add_argument('--atoms', type=Path, help='also run the compiled k83a-basin-atoms.cpp')
    arg.add_argument('--cover', type=Path, help='also run the compiled k83a-basin-cover.cpp')
    args = arg.parse_args()
    directory = args.directory
    directory.mkdir(parents=True,exist_ok=True)
    table, dest, five = make_tables(directory)
    if args.atoms:
        atoms(args.atoms,directory,dest)
    if args.cover:
        cover(args.cover,directory,dest)
    ids = (np.loadtxt(args.ids, dtype='<u4', ndmin=1) if args.ids else np.arange(args.size,dtype='<u4'))
    ids.tofile(directory/'ids.bin')
    path = directory/'observations.bin'
    subprocess.run([str(args.exe.resolve()),str(table),str(args.samples),str(SEED),str(directory/'ids.bin'),str(path)],check=True)
    a = np.fromfile(path,dtype='<i4').reshape(len(ids),6)
    if ((a[:,:4]>=0).sum(axis=1)>1).any() or ((a[:,4]>=0)&(a[:,0]<0)).any():
        raise ValueError('the disjoint capture classes or lock5 containment failed')
    labels = np.where((a[:,:4]>=0).any(axis=1), (a[:,:4]>=0).argmax(axis=1), 4)
    classes = [*NAMES[:4],'unresolved']
    joined = Counter(zip(labels.tolist(),a[:,5].tolist()))
    rows = {classes[c]+'/'+str(period):n for (c,period),n in sorted(joined.items())}
    checks = sorted(set(np.linspace(0,len(ids)-1,min(48,len(ids)),dtype=int)) |
                    {int(np.flatnonzero((labels==c)&(a[:,5]==period))[0]) for c,period in joined})
    for k in checks:
        if replay(int(ids[k]),args.samples,dest,five)!=a[k].tolist():
            raise ValueError(f'scalar replay failed at index {ids[k]}')
    if not args.ids and args.size==1048576 and args.samples==600:
        frozen=(HERE/'data/claudeCloud-rule4-gate.txt').read_text(encoding='utf8')
        expected={(what=='in the trap',int(p)):int(n) for p,what,n in re.findall(
            r'^    period\s+(\d+)\s+(never entered|in the trap)\s+(\d+)',frozen,re.M)}
        assert Counter(zip((a[:,0]>=0).tolist(),a[:,5].tolist()))==expected
    times = sorted({s for s in (0,7,31,63,127,255,399,499,599,1199,2399,args.samples-1) if s<args.samples})
    hist = {s:{name:int(((a[:,k]>=0)&(a[:,k]<=s)).sum()) for k,name in enumerate(NAMES)} for s in times}
    remaining=ids[labels==4]
    np.savetxt(directory/'unresolved.txt', remaining, fmt='%d')
    obs = {
        'samples':args.samples,'rows':len(ids),'seed':SEED,'ids_sha256':hashlib.sha256(ids.tobytes()).hexdigest(),
        'records_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'scalar_controls':len(checks),
        'by_final_class_and_suffix_period':rows,'cumulative_memberships_by_zero_based_white_sample':hist,
        'unresolved_examples':remaining[:16].tolist()
    }
    (directory/'counts.json').write_text(json.dumps(obs,indent=2)+'\n',encoding='utf8')
    print(json.dumps(obs), flush=True)


if __name__=='__main__':
    main()
