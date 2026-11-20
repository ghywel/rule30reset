#!/usr/bin/env python3
"""claudeCloud_r3_report.py: merge the workers of claudeCloud_r3_void_gaps.c and print the tables (pull R3, K34).

  python3 claudeCloud_r3_report.py merge TRUNK.json WORKER.jsonl      the trunk is a run with K = SPLIT; every worker
                                                                      counted it once, so it is subtracted W - 1 times
  python3 claudeCloud_r3_report.py orders FILE.json                   the two orders 3,5 and 5,3
"""
import json
import math
import sys


def merged(trunk_file, worker_file):
    trunk = json.load(open(trunk_file))
    parts = [json.loads(l) for l in open(worker_file) if l.strip()]
    W = len(parts)
    assert all(p['workers'] == W and p['split'] == trunk['K'] for p in parts), 'workers or split do not match the trunk'
    def comb(get):
        vals = [get(p) for p in parts]
        t = get(trunk)
        if isinstance(t, list):
            return [sum(v[i] for v in vals) - (W - 1) * t[i] for i in range(len(t))]
        return sum(vals) - (W - 1) * t
    out = {'K': parts[0]['K'], 'workers': W, 'overflow': sum(p['overflow'] for p in parts)}
    for k in ('seeds', 'words_at', 'void_hist', 'void_gaps_hist', 'void_changes_hist', 'void_changes_with_boundary_hist'):
        out[k] = comb(lambda p, k=k: p[k])
    for h in ('hist1', 'hist2', 'hist3'):
        out[h] = {name: comb(lambda p, h=h, name=name: p[h][name]) for name in trunk[h]}
    out['maxvoid_by_support'] = [max(p['maxvoid_by_support'][i] for p in parts) for i in range(len(trunk['maxvoid_by_support']))]
    for k in ('minpop_by_changes', 'minsupport_by_changes'):
        out[k] = [min(p[k][i] for p in parts) for i in range(8)]
    out['examples'] = [e for p in parts for e in p['examples']]
    return out


def table(d):
    K = d['K']
    print('K = %d free steps (supports to %d); finite seeds: %d; overflow: %d' % (K, 2 * K + 1, d['seeds'], d['overflow']))
    print('accepted traces at the last level: %d' % d['words_at'][2 * K + 1])
    print()
    print('VOID PHASES. ticks survived on white seed bits : seeds with exactly that many : share lasting at least one more')
    vh = d['void_hist']
    tail = [sum(vh[i:]) for i in range(len(vh))]
    for v in range(len(vh)):
        if tail[v]:
            print('  %2d  %12d  %s' % (v, vh[v], '%.3f' % (tail[v + 1] / tail[v]) if v + 1 < len(tail) and tail[v] else ''))
    print('longest Void phase by support (every 20):', {s: d['maxvoid_by_support'][s] for s in range(21, 2 * K + 2, 20)})
    print('longest of all:', max(d['maxvoid_by_support']))
    print('gaps wholly inside the Void phase: seeds with 0, 1, 2, ...:', [x for x in d['void_gaps_hist'] if x] or [0])
    print('changes of gap length wholly inside: seeds with 0, 1, 2, ...:', d['void_changes_hist'][:5])
    print('changes counting the gap in progress when the phase began:', d['void_changes_with_boundary_hist'][:5])
    print('least popcount of a seed with 0, 1, 2, 3 changes inside:', d['minpop_by_changes'][:4])
    print('least support of a seed with 0, 1, 2, 3 changes inside:', d['minsupport_by_changes'][:4])
    print()
    print('WINDOWS. black seed bits emitted during the last gaps, by pattern: windows, ticks, mean per tick, least, share of windows with none')
    for h, ng in (('hist1', 1), ('hist2', 2), ('hist3', 3)):
        for name, hist in d[h].items():
            n = sum(hist)
            if not n:
                continue
            ticks = 2 * sum(int(ch) for ch in name)
            mean = sum(i * x for i, x in enumerate(hist)) / n
            least = next(i for i, x in enumerate(hist) if x)
            print('  %-4s %12d  %2d ticks  %.4f  least %d (%d windows)  coin share of all-white 2^-%d = %.2e, expected %.3f'
                  % (name, n, ticks, mean / ticks, least, hist[least], ticks, 2.0 ** -ticks, n * 2.0 ** -ticks))
    print()
    kinds = {1: 'one change inside the Void phase', 2: 'two changes inside the Void phase', 3: 'a Void phase of 24 ticks or more',
             4: 'three gaps inside the Void phase', 5: 'a new longest Void phase'}
    for e in d['examples']:
        if e['kind'] in (1, 2, 4):
            print('example, %s: support %d, popcount %d, Void %d ticks, gaps inside %s, seed 0x%s'
                  % (kinds[e['kind']], e['support'], e['pop'], e['void'], e['gaps'], e['seed'].lstrip('0')))


def orders(f):
    d = json.load(open(f))
    print('two orders 3,5 and 5,3 from the same reset, to K2 = %d free steps: %d resets' % (d['K2'], d['two_orders']))
    print('distinct patterns of difference among the 16 emitted bits: %d' % d['xor_patterns'])
    print('bits that differ (Hamming distance): %s' % {i: x for i, x in enumerate(d['hamming_hist']) if x})
    print('black bits of 3,5 minus black bits of 5,3: %s' % {i - 16: x for i, x in enumerate(d['popdiff_hist']) if x})


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['merge']:
        d = merged(a[1], a[2])
        json.dump(d, open(a[2].rsplit('.', 1)[0] + '-merged.json', 'w'))
        table(d)
    elif a[:1] == ['orders']:
        orders(a[1])
    else:
        sys.exit(__doc__)
