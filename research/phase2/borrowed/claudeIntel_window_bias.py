"""K92.5.D, ledger N41 (claudeIntel): the van der Corput quantities on a packed bit column, and a fair-coin control.

E(H) = mean over t < N of ((x_t + ... + x_{t+H-1})/H)^2 with x = +1 black, -1 white; C_j = mean of x_t x_{t+j};
R(H) = max over H-words of freq * 2^H (and the least). N = len - 2^16 starts, the same for every statistic.

usage: python -I claudeIntel_window_bias.py COLUMN.bin LOG2_BITS OUT.json
"""
import json, math, sys
import numpy as np

def stats(bits, label, Hmax_log=16, lag_max=4096, word_max=14):
    L = bits.size
    N = L - (1 << Hmax_log)
    x = bits.astype(np.int8) * 2 - 1
    S = np.concatenate(([0], np.cumsum(x, dtype=np.int64)))
    out = {'label': label, 'N': int(N), 'black_share': float(bits[:N].mean())}
    E = {}
    for k in range(1, Hmax_log + 1):
        H = 1 << k
        w = (S[H:H + N] - S[:N]).astype(np.float64) / H
        E[H] = float(np.mean(w * w))
    out['H_times_E'] = {str(H): round(H * e, 5) for H, e in E.items()}
    # lag correlations by FFT (exact up to rounding), for j <= lag_max over the same N starts
    xf = x[:N + lag_max].astype(np.float64)
    n2 = 1 << int(math.ceil(math.log2(2 * xf.size)))
    F = np.fft.rfft(xf, n2)
    full = np.fft.irfft(F * np.conj(np.fft.rfft(x[:N].astype(np.float64), n2)), n2)
    C = full[1:lag_max + 1] / N
    out['lag'] = {'max_abs_C_sqrtN': round(float(np.max(np.abs(C)) * math.sqrt(N)), 3),
                  'argmax_lag': int(np.argmax(np.abs(C)) + 1),
                  'C1': round(float(C[0]), 6), 'C2': round(float(C[1]), 6), 'C3': round(float(C[2]), 6),
                  'rms_C_sqrtN': round(float(np.sqrt(np.mean(C * C)) * math.sqrt(N)), 4)}
    # word frequencies: codes of H-words starting at t < N
    R = {}
    code = np.zeros(N, dtype=np.int64)
    b64 = bits.astype(np.int64)
    for H in range(1, word_max + 1):
        code = (code << 1) | b64[H - 1:H - 1 + N]
        cnt = np.bincount(code, minlength=1 << H)
        fair = N / (1 << H)
        R[H] = (round(float(cnt.max() / fair), 4), round(float(cnt.min() / fair), 4))
    out['hot_spot_max_min'] = {str(H): v for H, v in R.items()}
    return out

def main():
    path, lg, outp = sys.argv[1], int(sys.argv[2]), sys.argv[3]
    L = 1 << lg
    raw = np.fromfile(path, dtype=np.uint8)
    bits = np.unpackbits(raw, bitorder='little')[:L]
    assert bits.size == L
    res = {'singleton': stats(bits, 'singleton centre column')}
    rng = np.random.Generator(np.random.PCG64(30))
    res['control'] = stats(rng.integers(0, 2, size=L, dtype=np.uint8), 'fair coins, PCG64 seed 30')
    a, c = res['singleton'], res['control']
    D1 = all(0.9 <= a['H_times_E'][str(1 << k)] <= 1.1 for k in range(1, 13))
    D2 = a['lag']['max_abs_C_sqrtN'] <= 4.5
    D3 = all(a['hot_spot_max_min'][str(H)][0] <= 1.25 for H in range(1, 15))
    cD1 = all(0.9 <= c['H_times_E'][str(1 << k)] <= 1.1 for k in range(1, 13))
    cD2 = c['lag']['max_abs_C_sqrtN'] <= 4.5
    cD3 = all(c['hot_spot_max_min'][str(H)][0] <= 1.25 for H in range(1, 15))
    def within(u, v):
        return v / 1.5 <= u <= v * 1.5
    near = (all(within(abs(a['H_times_E'][str(1 << k)] - 1) + 1, abs(c['H_times_E'][str(1 << k)] - 1) + 1)
                for k in range(1, 17))
            and within(a['lag']['max_abs_C_sqrtN'], c['lag']['max_abs_C_sqrtN'])
            and all(within(a['hot_spot_max_min'][str(H)][0], c['hot_spot_max_min'][str(H)][0]) for H in range(1, 15)))
    res['predictions'] = {'D1': D1, 'D2': D2, 'D3': D3, 'D4': cD1 and cD2 and cD3 and near,
                          'D4_parts': {'control_D1': cD1, 'control_D2': cD2, 'control_D3': cD3, 'within_1.5': near}}
    json.dump(res, open(outp, 'w', encoding='utf-8', newline='\n'), indent=1)
    print(json.dumps(res, indent=1))

if __name__ == '__main__':
    main()
