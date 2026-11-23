#!/usr/bin/env python3
"""claudeCloud_wheel_sensor_history.py: how many matched ticks do gptIntel's 18 sensor rules need? (ledger K77,
addendum 2)

The rules of research/wheel/data/kick-sensors.json are stated after 140 matched ticks of the wheel. This repeats
K77's test of them (claudeCloud_wheel_exterior.py, `sensors`) with a matched history of H ticks: real rows, by SAT
on the light cone. A rule holds when each of its patterns of cells has a row one way and none the other, and the
patterns it does not list cannot occur.

    python3 claudeCloud_wheel_sensor_history.py KITFILE SENSORS.json H [H ...]      H even
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm9'))
import claudeCloud_m9_lift as L          # noqa: E402
import claudeCloud_wheel_exterior as E   # noqa: E402


def main():
    kit, path = sys.argv[1], sys.argv[2]
    trap = [int(c) for c in L.trap_codes(kit)]
    d = json.load(open(path))
    for H in map(int, sys.argv[3:]):
        bad = []
        for rule in d['sensors']:
            target, lead, sites = rule['target_phase'], rule['lead'], rule['sites']
            yes, no = rule['depart_if'], rule['stay_or_other_departure_if']
            k = len(sites)
            for p in [format(i, '0%db' % k) for i in range(1 << k)]:
                a, _ = E.sensor_case(trap, target, lead, sites, p, True, history=H)
                b, _ = E.sensor_case(trap, target, lead, sites, p, False, history=H)
                want = ('SAT', 'UNSAT') if p in yes else (('UNSAT', 'SAT') if p in no else ('UNSAT', 'UNSAT'))
                if (a, b) != want:
                    bad.append((target, lead, sites, p, a, b))
        failing = sorted({(x[0], x[1]) for x in bad})
        print('after %d matched ticks: %d of 18 rules hold as stated; failing (target, lead): %s' % (H, 18 - len(failing), failing))
        sys.stdout.flush()


if __name__ == '__main__':
    main()
