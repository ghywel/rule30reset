#!/usr/bin/env python3
"""claudeCloud_k84_drive.py: the frozen runs of ledger K84, in order, writing to research/rule4/k84/data/.

E1  every west of support <= W, W = 52, 54, ..., 64: the west-only death bound D(W) and the longest-lived wests
    (claudeCloud_k84_wests.cpp); then the readability horizon of the demand of the 20 longest-lived at each W and of
    the kit's w52, w56, w60 (claudeCloud_k84_demand.py horizon).
E2  the coupled lifetime L(B), the longest alternation of a west of support <= B with some right half, for
    B = 26, 28, ... (claudeCloud_k84_coupled.py longest), each call capped at 900 s; it stops at the first cap.
E3  the fair mass m(s) of right halves supplying the demand of the E2 witness west, B = 24, 32, 40, 48, 56 where
    computed, through its coupled life: sequential Monte Carlo with 2^20 particles, and exact counts for the first
    14 readings as a control (claudeCloud_k84_mass.cpp).

    python3 claudeCloud_k84_drive.py WESTS_BIN MASS_BIN
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, 'data')
sys.path.insert(0, HERE)
import claudeCloud_k84_demand as D       # noqa: E402

KIT_WESTS = {'w52': '7dc2ff6fcc4fd', 'w56': '93d4b223f5b9b5', 'w60': 'e77a4e77b8f99b5'}


def run(cmd, out, timeout=None):
    with open(out, 'w') as f:
        p = subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT, timeout=timeout)
    return p.returncode


def e1(wests_bin):
    tops = []
    for W in range(52, 66, 2):
        out = os.path.join(DATA, 'k84-wests-%d.txt' % W)
        run([wests_bin, str(W), '0', '0'], out)
        best = int(open(out).readline().split()[-1])
        out2 = os.path.join(DATA, 'k84-wests-%d-top.txt' % W)
        run([wests_bin, str(W), str(best - 10), '4000'], out2)
        text = open(out2).read().split('(', 1)[0]          # the histogram ends where the list header starts
        tail = open(out2).read().split('listed):', 1)[1]
        listed = [(int(a), b) for a, b in (l.split() for l in tail.splitlines() if l.strip())]
        listed.sort(key=lambda x: (-x[0], x[1]))
        tops += [('W%d' % W, h) for _, h in listed[:20]]
    tops += [(k, v) for k, v in KIT_WESTS.items()]
    with open(os.path.join(DATA, 'k84-horizons.jsonl'), 'w') as f:
        for tag, h in tops:
            r = D.horizon(int(h, 16))
            r['tag'] = tag
            f.write(json.dumps(r) + '\n')
            f.flush()


def e2():
    path = os.path.join(DATA, 'k84-coupled.jsonl')
    with open(path, 'w') as f:
        for B in range(26, 82, 2):
            try:
                p = subprocess.run([sys.executable, '-I', os.path.join(HERE, 'claudeCloud_k84_coupled.py'), 'longest',
                                    str(B), '400'], capture_output=True, text=True, timeout=900)
                f.write(p.stdout.strip() + '\n')
                f.flush()
            except subprocess.TimeoutExpired:
                f.write(json.dumps(dict(B=B, L='UNKNOWN', reason='900 s cap')) + '\n')
                break


def e3(mass_bin):
    rows = {}
    for p in [os.path.join(DATA, 'k84-coupled.jsonl')]:
        for line in open(p):
            d = json.loads(line)
            if isinstance(d.get('L'), int):
                rows[d['B']] = d
    for B in (24, 32, 40, 48, 56):
        if B == 24 and B not in rows:
            p = subprocess.run([sys.executable, '-I', os.path.join(HERE, 'claudeCloud_k84_coupled.py'), 'longest', '24',
                                '400'], capture_output=True, text=True)
            rows[24] = json.loads(p.stdout)
        if B not in rows:
            continue
        d = rows[B]
        T, dem = D.death_and_demand(int(d['west_hex'], 16))
        n = min(len(dem), (d['L'] + 1) // 2)
        word = ''.join(map(str, dem[:n]))
        out = os.path.join(DATA, 'k84-mass-%d.txt' % B)
        with open(out, 'w') as f:
            f.write('B %d west %s L %d left death %d readings %d demand %s\n' % (B, d['west_hex'], d['L'], T, n, word))
        with open(out, 'a') as f:
            subprocess.run([mass_bin, 'smc', word, str(1 << 20), '84'], stdout=f, stderr=subprocess.STDOUT)
            subprocess.run([mass_bin, 'exact', word, str(min(14, n))], stdout=f, stderr=subprocess.STDOUT)


if __name__ == '__main__':
    os.makedirs(DATA, exist_ok=True)
    wests_bin, mass_bin = sys.argv[1], sys.argv[2]
    e1(wests_bin)
    e2()
    e3(mass_bin)
    print('done')
