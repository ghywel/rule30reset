"""Independent M35 replay using the preceding cycle phase and exact reset factors."""
import json
import re
from bisect import bisect_left

from gptM5_three_tick import edge_step

WIDTH = 4096
# Lookahead preserves factors that share a zero. Match ends include the extra bit.
RESET = re.compile(r'(?=(01(?:111)*0[01]))')


def cycle_slices():
    p = 1 << (WIDTH-1)
    seen = set()
    while p not in seen:
        seen.add(p)
        p = edge_step(p)
    first = p
    phases = []
    while True:
        phases.append(format(p, f'0{WIDTH}b')[::-1])
        p = edge_step(p)
        if p == first:
            return phases


def schedule(phases, w, phase):
    start = 0
    for d in range(w):
        # At inverse layer d the reference edge has retreated d positions.
        driver = phases[(phase-d) % len(phases)][WIDTH-w+d:]
        factor = RESET.search(driver, start)
        if factor is None:
            return d
        # After reading the final symbol j, both P(j) and P(j+1) agree.
        # The common parent is the reference one tick earlier. It agrees from
        # j onward, including its retreating edge and the whole exterior.
        start = factor.end(1)-1
    return w


def main():
    phases = cycle_slices()
    censored = []
    blocks = [0]*16
    shortest = WIDTH
    for phase, bits in enumerate(phases):
        factors = [(m.start(1), m.end(1)) for m in RESET.finditer(bits)]
        starts = [a for a, _ in factors]
        missing = 0
        for i in range(WIDTH):
            n = bisect_left(starts, i)
            if n == len(starts):
                missing += 1
            else:
                length = factors[n][1]-i
                depth = WIDTH-1-i
                blocks[depth//256] = max(blocks[depth//256],length)
                shortest = min(shortest,length)
        censored.append(missing)
    capacities = {w:min(schedule(phases,w,t) for t in range(len(phases)))
                  for w in (25,62,81,91,96,128,256,512,1024,2048,4096)}
    print(json.dumps(dict(period=len(phases), blocks=blocks, unfinished_per_phase=censored,
                          shortest=shortest, capacities=capacities)))


if __name__ == '__main__':
    main()
