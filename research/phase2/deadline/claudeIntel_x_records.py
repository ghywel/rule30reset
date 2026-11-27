"""K92.3, claudeIntel N32: the record first trap entries by support, predicted from support-24 seeds alone.

Fit log N(>s) = a - lambda s on the clean seeds of exact support 24 (seeds 2^23 .. 2^24-1) for s in 400..1600.
If every seed's first trap entry had that tail, independently, the largest entry among the 2^D seeds of
support at most D would have median s_D solving 2^D f(s_D) = ln 2, where f(s) = N(>s)/2^23 (a Gumbel law
with scale 1/lambda). Compared with the census maxima for D = 8 .. 24; D below 24 is out of sample.

Usage: python -I claudeIntel_x_records.py 24-aligned.bin out.json
"""
import json
import math
import sys

import numpy as np


def main():
    cen = np.fromfile(sys.argv[1], dtype="<u2").reshape(-1, 4).astype(np.int64)
    n = len(cen)
    assert n == 1 << 24
    clean = cen[:, 0] == 1
    trap = np.where(clean, cen[:, 2], -1)
    top = trap[1 << 23:]
    top = top[top >= 0]
    ss = np.arange(400, 1601, 25)
    ns = np.array([(top > s).sum() for s in ss], dtype=float)
    slope, a = np.polyfit(ss, np.log(ns), 1)
    lam = -slope
    rows = []
    for d in range(8, 25):
        actual = int(trap[: 1 << d].max())
        # 2^d * exp(a - lam s) / 2^23 = ln 2
        med = (a + d * math.log(2) - 23 * math.log(2) - math.log(math.log(2))) / lam
        rows.append({"D": d, "census_max_first_trap": actual, "predicted_median": round(med, 1),
                     "difference_in_units_of_1_over_lambda": round((actual - med) * lam, 2)})
    out = {"fit_on": "clean seeds of exact support 24", "s_range": [400, 1600], "rate_per_sample": lam,
           "log_intercept": a, "samples_per_site": math.log(2) / lam, "records": rows}
    open(sys.argv[2], "w", encoding="ascii", newline="\n").write(json.dumps(out, indent=1) + "\n")
    print(json.dumps(out, indent=1))


if __name__ == "__main__":
    main()
