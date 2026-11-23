"""Verify the physical pulse-return table, its strip thresholds, and finite rows."""
import argparse
from hashlib import sha256
import json
from pathlib import Path

import numpy as np

from exterior_defect_witness import encode, step


def bits(code, width):
    return format(code, f"0{width}b")[::-1]


def as_row(code):
    return [(code >> j) & 1 for j in range(max(1, code.bit_length()))]


def return_time(row):
    for gap in range(1, 6):
        row = step(step(row, 0), 1)
        if row[0]:
            return gap
    raise ValueError("pulse failed to return by five intervals")


def physical_table():
    outcomes = {}
    # Eleven positive cells are the whole past cone for the first five future
    # white readings. Farther cells cannot affect any entry.
    for code in range(1, 1 << 11, 2):
        outcomes.setdefault(code & 31, set()).add(return_time(as_row(code)))
    assert all(len(values) == 1 for values in outcomes.values())
    return {key: values.pop() for key, values in outcomes.items()}


def certified_components(directory, width):
    # R65's W19–23 cyclic components carry sorted 32-bit little-endian members.
    with (directory / f"W{width}.scc").open("rb") as stream:
        assert stream.readline() == b"K50SCC1\n"
        data = np.fromfile(stream, dtype="<u4")
    assert data[0] == width
    offset = 1
    while offset < len(data):
        least, count = map(int, data[offset:offset + 2])
        rows = data[offset + 2:offset + 2 + count]
        assert len(rows) == count and rows[0] == least
        yield rows
        offset += count + 2


def component(directory, width, name):
    if width >= 24:
        return np.memmap(directory / f"{name}{width}.bin", dtype="<u8", mode="r")
    # These representatives of R69's W24 components project into their ancestors.
    projected = {"X": 519, "Y": 1799}[name] & ((1 << width) - 1)
    for rows in certified_components(directory, width):
        i = rows.searchsorted(projected)
        if i < len(rows) and rows[i] == projected:
            return rows
    raise ValueError(f"missing ancestor at width {width}")


def pulse_prefixes(rows):
    hist = np.zeros(32, dtype=np.int64)
    for i in range(0, len(rows), 1_000_000):
        prefixes = np.asarray(rows[i:i + 1_000_000] & 31, dtype=np.intp)
        hist += np.bincount(prefixes, minlength=32)
    return {code: int(hist[code]) for code in range(1, 32, 2) if hist[code]}


def adequate(table, mask):
    observed = {}
    for prefix, gap in table.items():
        key = prefix & mask
        if key in observed and observed[key] != gap:
            return False
        observed[key] = gap
    return True


def sensor(table):
    length = next(k for k in range(1, 6) if adequate(table, (1 << k) - 1))
    # With a pulse already seen, site one carries no further information.
    masks = [m for m in range(0, 32, 2) if adequate(table, m)]
    compact = min(m.bit_count() for m in masks)
    sites = [[p + 1 for p in range(1, 5) if m & (1 << p)] for m in masks if m.bit_count() == compact]
    return {"minimum_prefix": length, "smallest_site_sets_within_five": sites}


def physical_witnesses(directory):
    seeds = {"X43": [0xF6EFC, 0xD1560, 0xCAC920C],
             "Y43": [0x641F0, 0x473ED18, 0x1FF5D2DC, 0x3E252BE0], "Y39": [0x2B401B1CC]}
    result = {}
    for label, black_starts in seeds.items():
        width = int(label[1:])
        core = component(directory, width, label[0])
        group = []
        for start in black_starts:
            cells = step(as_row(start), 1)
            prefix = encode(cells[:5])
            assert prefix & 1
            windows = []
            while True:
                w = encode(cells[:width])
                i = core.searchsorted(np.uint64(w))
                assert i < len(core) and core[i] == w
                windows.append(w)
                if len(windows) > 1 and cells[0]:
                    break
                assert len(windows) <= 5
                cells = step(step(cells, 0), 1)
            group.append({"black_start": hex(start), "prefix": bits(prefix, 5),
                          "gap": len(windows) - 1, "core_windows": windows})
        result[label] = group
    return result


def run(directory):
    table = physical_table()
    stages = []
    for width in range(19, 44):
        record = {"width": width}
        for name in ("X", "Y"):
            rows = component(directory, width, name)
            counts = pulse_prefixes(rows)
            record[name] = {"members": len(rows),
                            "pulse_counts": {bits(k, 5): v for k, v in counts.items()},
                            **sensor({k: table[k] for k in counts})}
        stages.append(record)
    final_prefixes = {*stages[-1]["X"]["pulse_counts"], *stages[-1]["Y"]["pulse_counts"]}
    both = {k: v for k, v in table.items() if bits(k, 5) in final_prefixes}
    assert sensor(both)["smallest_site_sets_within_five"] == [[2, 5]]
    digests = {}
    for name in ("X43.bin", "Y43.bin", "Y39.bin"):
        with (directory / name).open("rb") as stream:
            h = sha256()
            for piece in iter(lambda: stream.read(1 << 20), b""):
                h.update(piece)
            digests[name] = h.hexdigest()
    return {"unrestricted_eleven_cell_pulse_cones": 1024,
            "unrestricted": {bits(k, 5): table[k] for k in range(1, 32, 2)},
            "unrestricted_sensor": sensor(table), "union_W43_sensor": sensor(both),
            "widths": stages, "finite_controls": physical_witnesses(directory), "core_sha256": digests}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("core_directory", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    result = run(args.core_directory)
    args.output.write_bytes((json.dumps(result, indent=2) + "\n").encode())
    print(result["unrestricted"], result["union_W43_sensor"])
