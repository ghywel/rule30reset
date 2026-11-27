"""Check a uniform three-tick quiet-step lemma and test strictly phase-fixed pairs."""

import argparse
from collections import Counter
from pathlib import Path

# The earlier replay is meant to be run as a script. Reuse its functions without
# running its command-line parser.
source = Path(__file__).with_name("claudeCloud_phases.py").read_text(encoding="utf-8")
functions = {"__name__": "phase_graph_functions"}
exec(source.split("\ndef main():", 1)[0], functions)
make_steps = functions["make_steps"]
judge = functions["judge"]


def quiet_control():
    for width in range(3, 7):
        quiet = [[d for d in ds if s & ~d == 0] for s, ds in enumerate(make_steps(width))]
        paths = Counter()
        for s, ds in enumerate(quiet):
            for d in ds:
                for e in quiet[d]:
                    for _ in quiet[e]:
                        paths[s != d] += 1
        print(f"{width} sites, 3 quiet updates: {paths[False]} idle first, {paths[True]} changing first")


def strict_check(modulus, limit):
    # An assignment is live only when both substrip restrictions are live.
    strict_fail = {(r,) for r in range(modulus)}
    result = []
    for width in range(2, limit + 1):
        steps = make_steps(width)
        candidates = sorted({a + (r,) for a in strict_fail if a[0] == 0
                             for r in range(modulus) if a[1:] + (r,) in strict_fail})
        live = [a for a in candidates if not judge(width, modulus, [{r} for r in a], steps)[1]]
        result.append((len(candidates), len(live)))
        strict_fail = {tuple((a + d) % modulus for a in phases)
                       for d in range(modulus) for phases in live}
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--last", type=int, default=18)
    args = parser.parse_args()
    quiet_control()
    for m in range(3, args.last + 1):
        print(m, strict_check(m, 6), flush=True)
