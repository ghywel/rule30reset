"""Regenerate the compressed prefix certificate and compare it with the Lean input."""
import ast
from functools import lru_cache
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from twin_past import C20, edge_step, scan


def children(prefix):
    return [edge_step(2 * prefix + bit) for bit in (0, 1)]


def shorten(word, passes):
    while word > 1 and passes(word >> 1):
        word >>= 1
    return word


def has_prefix(word, prefixes):
    while word:
        if word in prefixes:
            return True
        word >>= 1
    return False


def compressed_stages():
    bands = [set(C20)]
    for _ in range(54):
        bands.append({child for p in bands[-1] for child in children(p)})

    transitions = [[scan(b, s, 4) for s in range(256)] for b in (0, 1)]

    @lru_cache(maxsize=None)
    def terminal_states(word):
        if word == 0:
            return tuple(range(256))
        outer = terminal_states(word >> 1)
        return tuple(outer[s] for s in transitions[word & 1])

    def resets(word):
        return not any(terminal_states(word))

    assert all(resets(w) for w in bands[-1])
    covers = [{shorten(w, resets) for w in bands[-1]}]
    for band in reversed(bands[:-1]):
        target = covers[-1]

        def links(prefix):
            return all(has_prefix(child, target) for child in children(prefix))

        covers.append({shorten(w, links) for w in band})
    return len(bands[-1]), [sorted(s) for s in reversed(covers)]


if __name__ == "__main__":
    source = Path(__file__).with_name("Rule30AgeEightyInverse.lean").read_text()
    def table(name):
        match = re.search(r"private def " + name + r" : [^:=]+ := (\[.*?\])\n\n", source, re.S)
        return ast.literal_eval(match.group(1))

    count, stages = compressed_stages()
    assert stages == [table("firstBands"), *table("stages")]
    print(f"{count} full words; {len(stages)} stages; {sum(map(len, stages))} prefixes "
          f"across stages; {len(stages[-1])} terminal prefixes; Lean tables match")
