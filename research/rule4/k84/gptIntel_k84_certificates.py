"""Build right-only certificates for support cutoffs and absent gate prefixes."""

import argparse
import json
from pathlib import Path

from claudeCloud_k84_demand import Cone
from gptIntel_k84_support import write_cnf
from gptIntel_k84_words import decode_west


def require_prefix(cone, words):
    """Each selector implies a chronological prefix, and some selector must hold."""
    clauses = list(cone.clauses)
    selectors = []
    for index, word in enumerate(words, cone.nv + 1):
        selectors.append(index)
        for sample, bit in enumerate(word):
            reading = cone.reading(sample)
            clauses.append([-index, reading if bit == "1" else -reading])
    clauses.append(selectors)
    return clauses, cone.nv + len(selectors)


def support_cutoff(args):
    m = args.ticks // 2
    shift = args.readings - m
    with args.strip.open(encoding="utf-8-sig") as stream:
        gate_words = {int(line) >> shift for line in stream}
    return m, sorted(format(word, f"0{m}b") for word in gate_words
                     if decode_west(word, args.ticks).bit_length() <= args.width)


def absent_prefixes(args):
    words = []
    maximum = 0
    with args.counts.open(encoding="utf-8-sig") as stream:
        for line in stream:
            report = json.loads(line)
            if "exact" in report and report["m"] <= args.through:
                m = report["m"]
                maximum = max(m, maximum)
                words.extend(format(word, f"0{m}b") for word in report["new_refusals"])
    if maximum != args.through:
        raise ValueError("count file does not close the requested horizon")
    return maximum, words


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cnf", type=Path)
    modes = parser.add_subparsers(required=True)
    support = modes.add_parser("support")
    support.add_argument("strip", type=Path)
    support.add_argument("readings", type=int)
    support.add_argument("width", type=int)
    support.add_argument("ticks", type=int)
    support.set_defaults(collect=support_cutoff)
    count = modes.add_parser("counts")
    count.add_argument("counts", type=Path)
    count.add_argument("through", type=int)
    count.set_defaults(collect=absent_prefixes)
    args = parser.parse_args()
    m, words = args.collect(args)
    clauses, variables = require_prefix(Cone(2 * m), words)
    write_cnf(args.cnf, clauses, variables)
    args.cnf.with_suffix(".words").write_text("\n".join(words) + "\n", encoding="ascii")
    print(json.dumps({"readings": m, "words": len(words),
                      "variables": variables, "clauses": len(clauses)}))


if __name__ == "__main__":
    main()
