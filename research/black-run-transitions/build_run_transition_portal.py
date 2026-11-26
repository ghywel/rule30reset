"""Assemble the single Lean module for the portal's older kit pin.

Usage: py build_run_transition_portal.py KIT OUTPUT
KIT must contain the history of the public RunTransitions module.
"""
import argparse
from pathlib import Path
import subprocess


KIT_REV = "71151d0"
BASE = "Ruliology.CellularAutomata"
KIT_SOURCE = f"lean/{BASE.replace('.', '/')}/Rule30RunTransitions.lean"
HERE = Path(__file__).resolve().parent


def span(text, first, after):
    return text[text.index(first):text.index(after)].rstrip()


def build(kit, output):
    original = subprocess.check_output(
        ["git", "-C", str(kit), "show", f"{KIT_REV}:{KIT_SOURCE}"], encoding="utf-8"
    )
    palette = [
        span(original, "def allIn", "/-- The center column reads"),
        span(original, "def ones", "theorem force_white"),
        span(original, "theorem getD_ones", "theorem occ_ones"),
        span(original, "theorem length_ones", "/-- A prefix forcing"),
        span(original, "def cyc", "/-- Reading `w` from time"),
        span(original, "def runsWord", "/-- Two sevens"),
    ]
    source = (HERE / "Rule30RunTransitionWindows.lean").read_text(encoding="utf-8")
    source = source[source.index("/-!"):]
    module = f"{BASE}.Rule30RunTransitionWindows"
    source = source.replace(f"namespace {module}", f"namespace Rule30Submission\nopen {BASE}", 1)
    source = source.replace(f"end {module}", "end Rule30Submission")
    header = (
        f"import {BASE}.Rule30FiniteStrips\n"
        f"import {BASE}.Rule30FiniteConfigs\n\n"
        "/- Kurtuluş's existing window palette, from the kit's Rule30RunTransitions. -/\n"
        f"namespace {BASE}.Rule30RunTransitions\n"
        "open Rule30StripCertificates\n\n"
    )
    result = (header + "\n\n".join(palette) + f"\nend {BASE}.Rule30RunTransitions\n\n"
              + source.rstrip() + "\n")
    output.write_text(result, encoding="utf-8", newline="\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    build(args.kit.resolve(), args.output.resolve())
