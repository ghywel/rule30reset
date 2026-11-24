"""Certify the eight R104 triples with ordinary full-line truth-table cones."""
import argparse
import json
import subprocess
from itertools import product
from pathlib import Path


def encode(width, rows):
    # The last observations are sites 0..width at time 21. Include all their
    # ancestors, including the ordinary cells to the LEFT of the clock.
    horizon = 21
    cells = {(t, x): i for i, (t, x) in enumerate(
        ((t, x) for t in range(horizon + 1)
         for x in range(t - horizon, width + horizon - t + 1)), 1)}
    clauses = []
    for (t, x), out in cells.items():
        if not t:
            continue
        parents = [cells[t-1, y] for y in (x-1, x, x+1)]
        for lo, mid, hi in product((0, 1), repeat=3):
            color = (30 >> (4*lo + 2*mid + hi)) & 1
            bad = [-var if bit else var for var, bit in zip(parents, (lo, mid, hi))]
            clauses.append(bad + [out if color else -out])
    for t in range(horizon + 1):
        clauses.append([cells[t, 0] * (1 if t in (0, 10, 21) else -1)])
    for t, row in zip((0, 10, 21), rows):
        for x in range(1, width + 1):
            clauses.append([cells[t, x] * (1 if row >> (x-1) & 1 else -1)])
    body = ''.join(' '.join(map(str, c)) + ' 0\n' for c in clauses)
    return cells, f'p cnf {len(cells)} {len(clauses)}\n' + body


def check_model(black, width, rows):
    cells = set(black)
    for t in range(22):
        assert (0 in cells) == (t in (0, 10, 21))
        if t in (0, 10, 21):
            assert sum(1 << (x-1) for x in cells if 1 <= x <= width) == rows[(0, 10, 21).index(t)]
        if t < 21:
            cells = {x for x in range(min(cells)-1, max(cells)+2)
                     if ((x-1 in cells) ^ (x in cells or x+1 in cells))}


def certify(folder, label, width, rows):
    cells, text = encode(width, rows)
    cnf, proof = folder / (label + '.cnf'), folder / (label + '.lrat')
    cnf.write_text(text)
    proc = subprocess.run(['cadical', '-q', '--lrat', '--no-binary', cnf, proof],
                          capture_output=True, text=True)
    if proc.returncode == 10:
        model = {int(n) for line in proc.stdout.splitlines() if line.startswith('v ')
                 for n in line[2:].split()}
        black = sorted(x for (t, x), var in cells.items() if t == 0 and var in model)
        check_model(black, width, rows)
        return {'status': 'SAT', 'initial_black_sites': black}
    if proc.returncode != 20:
        raise RuntimeError(proc.stdout + proc.stderr)
    for exe, marker in [('cake_lpr', 's VERIFIED UNSAT'), ('lrat-check', 'c VERIFIED')]:
        run = subprocess.run([exe, cnf, proof], capture_output=True, text=True)
        log = run.stdout + run.stderr
        (folder / (label + '.' + exe + '.log')).write_text(log)
        if run.returncode or marker not in log.splitlines():
            raise RuntimeError(log)
    return {'status': 'UNSAT', 'verified': ['cake_lpr', 'lrat-check']}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('diamonds', nargs='+', type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    for path in args.diamonds:
        clock = json.loads(path.read_bytes())
        t = clock['unequal_interval']
        frames = clock['frames'][t-1:t+2]
        assert [clock['word'][f[0]] for f in frames[:2]] == [9, 10]
        for width in sorted({27, clock['width']}):
            for lane in (1, 2):
                rows = [f[lane] % (1 << width) for f in frames]
                case = f"h{max(clock['word'])}-w{width}-p{lane}"
                result = certify(args.output, case, width, rows)
                print(json.dumps(dict(case=case, **result)), flush=True)
