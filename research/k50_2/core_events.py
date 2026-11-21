"""Exact first and consecutive returns of Lowry's marker on the K47 trap cores.

    python3 research/k50_2/core_events.py [--cache M78_DIRECTORY] [--widths 16 18 34]

The cache is optional. Without it each core is built by the frozen K42
ladder. Results are independent of the order of the four boundary inputs.
Distances count pairs of physical ticks. A return word is between successive
events: intermediate samples must have no marker.
"""
import argparse
from hashlib import sha256
from io import BytesIO
import json
from pathlib import Path
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "research/m9"))
import claudeCloud_m9_lift as lift

TRAP = ROOT / "Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean"
PINS = {
    16: "e096325200296f610fa1247b601b5c27012578eeb8779399bafb71a41be31ef9",
    18: "02227197f2e86882b4f944831d5bb9a73757c2836fec2128e1ab9a378bb5d665",
    34: "16185c913a1a157ec87f4f72357027354664194512db118977ff145db1497976",
}
# These are K47's gate words. The extra initial 3 synchronises their event
# encodings at the distinguished marker one sample after a black gate.
GATE_WORDS = ["33", "3553", "3535353", "3" + "55553" * 6]


def cores(widths, cache):
    if cache:
        for width in widths:
            data = (cache / f"core-{width}.npy").read_bytes()
            if sha256(data).hexdigest() != PINS[width]:
                raise ValueError(f"Cached core at width {width} differs from M78")
            yield width, np.load(BytesIO(data))
        return
    codes = lift.trap_codes(TRAP)
    for width in range(16, max(widths) + 1, 2):
        graph = lift.Graph(codes, width)
        mask, _ = graph.core()
        codes = graph.codes[mask]
        if width in widths:
            yield width, codes
        del graph, mask
        if width < max(widths):
            codes = lift.extend(codes, width)


class MarkerGraph:
    def __init__(self, codes, width):
        if not (codes[:-1] < codes[1:]).all():
            raise ValueError("Expected sorted distinct core words")
        self.codes = codes
        self.hit = (codes & 3) == 2  # column 1 white and column 2 black
        self.black = (codes & 1) == 1
        self.succ = []
        for left in (0, 1):
            for right in (0, 1):
                out = lift.step2(codes, left, right, width)
                which = np.searchsorted(codes, out)
                if np.any(which >= len(codes)) or not np.array_equal(codes[which], out):
                    raise ValueError("A K47 successor leaves the core")
                self.succ.append(which.astype(np.int32))
        assert self.image(np.ones(len(codes), bool)).all()

    def image(self, mask):
        out = np.zeros(len(mask), bool)
        for successor in self.succ:
            out[successor[mask]] = True
        return out

    def returns(self, start):
        """Compute every possible first return. A live frontier at the cap fails."""
        waiting = start
        by_length = {}
        for length in range(1, 257):
            reachable = self.image(waiting)
            landed = reachable & self.hit
            if landed.any():
                by_length[length] = landed
            waiting = reachable & ~self.hit
            if not waiting.any():
                return by_length
        raise RuntimeError("A no-marker frontier survived 256 samples; table incomplete")

    def gate_excursions(self):
        """All (black-to-black gap, exact interior event offsets) on core edges."""
        result = {}
        todo = {(): self.black}
        for length in range(1, 6):
            later = {}
            for offsets, start in todo.items():
                reached = self.image(start)
                end = reached & self.black
                if end.any():
                    assert not (end & self.hit).any()
                    result[length, offsets] = int(end.sum())
                interior = reached & ~self.black
                for has_marker, part in ((False, interior & ~self.hit), (True, interior & self.hit)):
                    if part.any():
                        key = offsets + ((length,) if has_marker else ())
                        later[key] = part
            todo = later
        assert not todo, "Some black gate has no return within five samples"
        return result

    def read(self, word):
        current = self.hit
        for index, gap in enumerate(word):
            for step in range(1, gap + 1):
                current = self.image(current) & (self.hit if step == gap else ~self.hit)
                if not current.any():
                    return {"read": False, "failed_gap": index + 1, "failed_sample_in_gap": step}
        return {"read": True, "endpoints": int(current.sum()), "one_endpoint": int(self.codes[np.argmax(current)])}


def transcode(gates):
    return (3,) + tuple(g for letter in gates for g in ((3,) if letter == "3" else (2, 3)))


def inspect(width, codes):
    graph = MarkerGraph(codes, width)
    singles = graph.returns(graph.hit)
    pairs = {gap: graph.returns(landed) for gap, landed in singles.items()}
    excursions = graph.gate_excursions()
    result = {"width": width, "vertices": len(codes), "black_gates": int(graph.black.sum()),
              "marker_vertices": int(graph.hit.sum()), "returns": {g: int(s.sum()) for g, s in singles.items()},
              "pairs": {g: {h: int(t.sum()) for h, t in following.items()} for g, following in pairs.items()},
              "gate_excursions": [{"gap": g, "event_offsets": off, "endpoints": count}
                                   for (g, off), count in sorted(excursions.items())]}
    result["translated_words"] = {}
    for original in GATE_WORDS:
        event = transcode(original)
        result["translated_words"][original] = {
            "event_word": "".join(map(str, event)), "full": graph.read(event),
            "drop_first_gap": graph.read(event[1:]), "drop_last_gap": graph.read(event[:-1])}
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--widths", type=int, nargs="+", choices=PINS, default=[16, 18, 34])
    parser.add_argument("--cache", type=Path, help="Directory with M78 core-W.npy files")
    args = parser.parse_args()
    for width, codes in cores(sorted(set(args.widths)), args.cache):
        print(json.dumps(inspect(width, codes), sort_keys=True), flush=True)


if __name__ == "__main__":
    main()
