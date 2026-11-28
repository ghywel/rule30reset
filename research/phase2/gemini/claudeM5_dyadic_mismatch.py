"""I295.5, claudeM5 (M229): dyadic mismatches on the single seed's centre, and I295's first-test event.

For P = 2^k and t in [P, 2P): a mismatch is c(t) != c(t + P). The first-test event at u (P <= u < 2P - 1) is
c(u) = c(u + P) = 1 with the cells at site -1 different at u and u + P; Rule 30 then forces c(u + 1) != c(u + 1 + P),
since a black centre's next value is the complement of its western neighbour.
Per k: the share of mismatches in [P, 2P), the least mismatch offset t - P, the share and least offset of first-test
events, and whether every mismatch in the interval at u + 1 is explained by such an event at u (the transfer).
Input: the windows file of claudeM5_seed_windows.c (K92.4): per age, the 64 cells west of the centre and the 64 from
the centre east, as two little-endian words (bit 63 of the first is site -1; bit 0 of the second is the centre).
Usage: python3 -I claudeM5_dyadic_mismatch.py WINDOWS KMAX [OUT.json]
"""
import json, sys
import numpy as np

def main():
    path, kmax = sys.argv[1], int(sys.argv[2])
    d = np.fromfile(path, dtype='<u8').reshape(-1, 2)
    c = (d[:, 1] & np.uint64(1)).astype(np.int8)
    w = ((d[:, 0] >> np.uint64(63)) & np.uint64(1)).astype(np.int8)
    N = len(c)
    out = []
    for k in range(1, kmax + 1):
        P = 1 << k
        if 3 * P > N: break
        t = np.arange(P, 2 * P)
        mis = c[t] != c[t + P]
        u = np.arange(P, 2 * P - 1)
        ev = (c[u] == 1) & (c[u + P] == 1) & (w[u] != w[u + P])
        assert (mis[1:][ev]).all(), 'the first-test event must force a mismatch one tick later'
        explained = mis[1:].sum() and ev.sum() / mis[1:].sum()
        row = dict(k=k, P=P, mismatch_share=float(mis.mean()), least_mismatch_offset=int(np.argmax(mis)) if mis.any() else None,
                   endpoint_mismatch=bool(mis[0]), event_share=float(ev.mean()), least_event_offset=int(np.argmax(ev)) if ev.any() else None,
                   share_of_mismatches_from_events=float(explained))
        out.append(row)
        print(row, flush=True)
    if len(sys.argv) > 3: json.dump(out, open(sys.argv[3], 'w'), indent=1)

if __name__ == '__main__':
    main()
