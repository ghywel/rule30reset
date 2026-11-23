"""Replay two black-first finite Rule 30 rows and check their exact W43 core membership."""
import argparse
from bisect import bisect_left
from hashlib import file_digest
import json
from mmap import ACCESS_READ, mmap
from pathlib import Path
from struct import unpack_from


def step(row, wall):
    # Explicit zeros to the east. Each update can extend support by one.
    tape = [wall, *row, 0, 0]
    return [left ^ (centre | right) for left, centre, right in zip(tape, tape[1:], tape[2:])]


def encode(row):
    return sum(bit << index for index, bit in enumerate(row))


def check_control(record, directory):
    component = record["component"]
    width = record["width"]
    bound = int(record["black_start"], 16)
    row = [(bound >> j) & 1 for j in range(bound.bit_length())]
    row = step(row, 1)
    assert encode(row) == int(record["white_start"], 16)

    windows = []
    for _ in record["word"]:
        windows.append(encode(row[:width]))
        row = step(step(row, 0), 1)
    assert windows == record["core_windows"]
    assert "".join(str(code & 1) for code in windows) == record["word"]

    with (directory / f"{component}{width}.bin").open("rb") as stream:
        assert file_digest(stream, "sha256").hexdigest() == record["core"]
        with mmap(stream.fileno(), 0, access=ACCESS_READ) as raw:
            assert len(raw) % 8 == 0
            offsets = range(0, len(raw), 8)

            def value(offset):
                return unpack_from("<Q", raw, offset)[0]

            for code in windows:
                index = bisect_left(offsets, code, key=value)
                assert index < len(offsets) and value(offsets[index]) == code
    print(component, record["black_start"], record["word"], len(windows), "core windows verified")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("core_directory", type=Path)
    args = parser.parse_args()
    source = Path(__file__).with_name("data") / "exterior-defect-controls.json"
    for control in json.loads(source.read_bytes()):
        check_control(control, args.core_directory)
