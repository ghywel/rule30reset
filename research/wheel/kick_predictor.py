"""Prospective Rule 30 wheel departures and signed Vitruvian phase changes."""

import argparse
import json


WHEEL = "00010011010001001101000100110100010011010001001101001101"
ROTATIONS = {WHEEL[i:] + WHEEL[:i]: i for i in range(56)}


def phase_at(word, tick):
    """Even global phase offset of a complete 56-tick word, or None."""
    pos = ROTATIONS.get(word)
    if pos is not None and (tick - pos) % 2 == 0:
        return (tick - pos) % 56
    return None


def signed_kick(old, new):
    return (-17 * (((new - old) % 56) // 2) + 14) % 28 - 14


def read_display(trace, start=0, active=None, last=None):
    """Read the published display convention wherever all 56 ticks are supplied."""
    states, departures, changes = [], [], []
    for i in range(len(trace) - 55):
        t = start + i
        if active is not None and trace[i] != WHEEL[(t - active) % 56]:
            departures.append((t, active))
            active = None
        if active is None:
            active = phase_at(trace[i:i+56], t)
            if active is not None:
                if last is not None and last != active:
                    changes.append((t, active, signed_kick(last, active)))
                last = active
        states.append(active)
    return states, departures, changes


def confirmed_phase(history, start=0):
    """Current display lock that an observer can certify from the past alone."""
    if len(history) < 56:
        return None
    states, _, _ = read_display(history, start)
    return states[-1] if states[-1] == phase_at(history[-56:], start + len(history) - 56) else None


def pulse_warning(row, tick, phase):
    """The six-tick decision. Bit zero of row is positive site 1."""
    pos = (tick - phase) % 56
    if tick % 2 or WHEEL[pos] != "1" or row & 15 != 7:
        return None
    bit = (row >> 4) & 1
    expected = int(WHEEL[(pos + 6) % 56])
    return {"site_5": bit, "wheel_expects": expected, "target_tick": tick + 6,
            "departs": bit != expected}


def common_trace(row, width, tick, horizon):
    """Certified gate readings. Unknown exterior inputs are allowed anew at each tick."""
    mask = (1 << width) - 1
    ones = row & mask
    zeros = mask ^ ones
    bits = []
    while (ones | zeros) & 1:
        bits.append("1" if ones & 1 else "0")
        if len(bits) == horizon + 1:
            break
        wall = tick % 2
        left_one = (ones << 1) | wall
        left_zero = (zeros << 1) | (1 - wall)
        or_one = ones | (ones >> 1)
        or_zero = zeros & (zeros >> 1)
        ones = ((left_one & or_zero) | (left_zero & or_one)) & mask
        zeros = ((left_one & or_one) | (left_zero & or_zero)) & mask
        tick += 1
    return "".join(bits)


def forecast(row, width, tick, phase, horizon=160):
    """Forecast from this snapshot only, given an already established wheel phase."""
    if width < 1 or row < 0 or row >= 1 << width or tick < 0 or horizon < 0:
        raise ValueError("Use a nonnegative row of the specified width, tick and horizon.")
    if phase not in range(0, 56, 2) or int(WHEEL[(tick - phase) % 56]) != row & 1:
        raise ValueError("The current reading must fit the supplied even wheel phase.")
    bits = common_trace(row, width, tick, horizon)
    departure = next((tick+i for i, bit in enumerate(bits) if bit != WHEEL[(tick+i-phase) % 56]), None)
    changes = read_display(bits, tick, phase, phase)[2] if departure is not None else []
    pulse = pulse_warning(row, tick, phase) if width >= 5 else None
    # With 1110 the symbolic six-tick relay can outlast a narrow three-valued prefix.
    if pulse is not None and pulse["departs"]:
        assert departure in (None, tick+6)
        departure = tick + 6
    matches = departure - 1 if departure is not None else tick + len(bits) - 1
    if pulse is not None and not pulse["departs"]:
        matches = max(matches, tick + 6)
    kick = None
    if changes:
        time, new, notches = changes[0]
        kick = {"tick": time, "phase": new, "notches": notches}
    return {"issued": tick, "phase": phase, "common_gate_through": tick + len(bits) - 1,
            "old_phase_matches_through": matches, "departure": departure, "next_kick": kick,
            "pulse": pulse}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("prefix", help="Current positive sites in order 1, 2, 3, …; e.g. 1110100.")
    parser.add_argument("--tick", required=True, type=int, help="Absolute tick, with a white wall at tick zero.")
    ph = parser.add_mutually_exclusive_group(required=True)
    ph.add_argument("--phase", type=int, help="Previously established even display offset, from 0 to 54.")
    ph.add_argument("--history", help="Column-one history from tick zero through the current tick.")
    parser.add_argument("--horizon", type=int, default=160, help="Physical ticks to propagate the prefix.")
    args = parser.parse_args()
    if not args.prefix or set(args.prefix) - {"0", "1"}:
        parser.error("prefix must be a nonempty string of binary cells")
    phase = args.phase
    if args.history is not None:
        if len(args.history) != args.tick + 1 or set(args.history) - {"0", "1"}:
            parser.error("history must contain one binary reading per tick through --tick")
        phase = confirmed_phase(args.history)
        if phase is None:
            parser.exit(0, "The supplied history has not yet established a current display phase.\n")
    try:
        result = forecast(int(args.prefix[::-1], 2), len(args.prefix), args.tick, phase, args.horizon)
    except ValueError as exc:
        parser.error(str(exc))
    print(json.dumps(result, indent=2))
