"""Check ordinary one-gap witnesses and the hidden-cell consistency of a marked return."""
import json
import sys
from pathlib import Path
from runpy import run_path

import numpy as np


def check(record, hidden):
    width = record["width"]
    word, rows = (record["result"][key] for key in ("gaps", "rows"))
    advance = run_path(str(Path(__file__).with_name("check-marked-seam.py")))["advance"]
    row_mask = (1 << width) - 1
    hidden_mask = (1 << hidden) - 1
    assert width + max(word) + 1 + hidden <= 64
    possible = set(range(1 << hidden))
    edge_witnesses, first_break = [], None
    for idx, (gap, src, dst) in enumerate(zip(word, rows[:-1], rows[1:], strict=True)):
        tails = np.arange(1 << (gap + 1 + hidden), dtype=np.uint64)
        ends = advance(src | (tails << width), gap + 1)
        hit = (ends & row_mask) == dst
        assert hit.any()
        suffix = int(tails[hit][0]) % (1 << (gap + 1))
        cells = [(src | (suffix << width)) >> k & 1 for k in range(width + gap + 1)]
        for tick in range(gap + 1):
            cells = [(30 >> (4 * l + 2 * m + r)) & 1 for l, m, r in
                     zip([int(tick == 0)] + cells, cells, cells[1:])]
        assert sum(v << k for k, v in enumerate(cells)) == dst
        edge_witnesses.append(suffix)
        allowed = hit & np.isin(tails & hidden_mask, list(possible))
        previous = sorted(possible)
        possible = set(map(int, (ends[allowed] >> width) & hidden_mask))
        if previous and not possible:
            first_break = dict(edge=idx+1, incoming=previous,
                               required=sorted(set(map(int, tails[hit] & hidden_mask))))
    return dict(width=width, hidden=hidden, positive_edges=edge_witnesses,
                first_break=first_break, final_extensions=sorted(possible))


if __name__ == "__main__":
    path = Path(sys.argv[1])
    record = json.loads(path.read_text().splitlines()[-1])
    for depth in range(1, 5):
        print(json.dumps(check(record, depth)))
