"""Remove the trap hypothesis from the K77 mixed-word cuts and test actual attainability."""

import json

from certify_mixed_cuts import options, replay, verified_solve
from audit_gap_observers import read_row, sample_bits
from wheel_bridge import table


def formula(bits, width, trap, physical):
    """Independent OR/XOR strip, terminal row first. Physical=True gives a shrinking cone."""
    ticks = 2 * (len(bits) - 1)
    rows = []
    nv = 0
    for t in range(ticks, -1, -1):
        size = 16 + ticks - t if physical else width + 1
        rows.append(range(nv + 1, nv + size + 1))
        nv += size
    rows.reverse()
    clauses = []
    for t in range(ticks):
        old = rows[t]
        targets = rows[t + 1] if physical else rows[t + 1][:-1]
        for i, new in enumerate(targets):
            center, right = old[i : i + 2]
            nv += 1
            g = nv
            clauses.extend(([-center, g], [-right, g], [center, right, -g]))
            if i:
                left = old[i - 1]
                clauses.extend(([-left, -g, -new], [left, g, -new], [left, -g, new], [-left, g, new]))
            else:
                driver = -g if t % 2 else g
                clauses.extend(([-driver, new], [driver, -new]))
    for i, b in enumerate(bits):
        v = rows[2 * i][0]
        clauses.append([v if b == "1" else -v])
    for code in trap:
        clauses.append([-v if code & (1 << i) else v for i, v in enumerate(rows[-1][:16])])
    return rows, nv, clauses


def query(args, word, width, count, mode):
    bits = sample_bits(word * count)
    physical = mode == "physical"
    trap = sorted(table(args.kit, "trapCodes", "Rule30Certificates/GateTrap"))
    out = args.output / f"{mode}-{word}-{width}-{count}"
    rows, nv, clauses = formula(bits, width, trap if mode == "endpoint" else [], physical)
    receipt, model = verified_solve(out, nv, clauses, args)
    receipt.update(
        word=word,
        width=None if physical else width,
        count=count,
        mode=mode,
        status="UNSAT" if model is None else "SAT",
    )
    if model is not None and physical:
        initial = "".join(str(int(v in model)) for v in rows[0])
        final = read_row(initial, bits)
        receipt.update(initial=initial, final_window=final, final_inside=final in trap)
    elif model is not None:
        initial = sum(int(v in model) << j for j, v in enumerate(rows[0][:width]))
        east = [int(row[-1] in model) for row in rows[:-1]]
        replay(bits, initial, east, width, set())
        receipt.update(initial=hex(initial), east="".join(map(str, east)))
    (out / "receipt.json").write_bytes((json.dumps(receipt, indent=2) + "\n").encode())
    print(out.name, receipt["status"], flush=True)
    return receipt


if __name__ == "__main__":
    args = options()
    for word, width, count in (("33355", 55, 7), ("333355", 44, 9)):
        assert query(args, word, width, count, "endpoint")["status"] == "UNSAT"
        if query(args, word, width, count, "strip")["status"] == "SAT":
            query(args, word, width, count, "physical")
    for width in (60, 72):
        query(args, "333355", width, 9, "strip")
