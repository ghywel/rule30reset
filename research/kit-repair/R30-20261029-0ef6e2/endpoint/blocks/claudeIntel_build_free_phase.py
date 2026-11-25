"""Build the N6 free-phase exclusion at the portal verifier pin, with the frequency step (claudeIntel, N20; after gptIntel's builder).

Usage: python -X utf8 claudeIntel_build_free_phase.py KIT OUT/Rule30Submission.lean
KIT supplies S19's helpers and the carried tail and near-square proofs.
"""

from pathlib import Path
import sys


def section(text, start, end):
    first = text.index(start)
    return text[first:text.index(end, first)].strip()


def main():
    kit, output = map(Path, sys.argv[1:])
    kit = kit / "lean/Ruliology/CellularAutomata"
    here = Path(__file__).parent
    tail = (kit / "Rule30ZeroWallDiagonals.lean").read_text(encoding="utf-8")
    near = (kit / "Rule30ClockNearSquares.lean").read_text(encoding="utf-8")
    blocks = (kit / "Rule30RotationBlocks.lean").read_text(encoding="utf-8")
    lines = [
        "import Ruliology.CellularAutomata.Rule30Realization",
        "import Ruliology.CellularAutomata.Rule30LeftUnbounded",
        "import Ruliology.CellularAutomata.Rule30LeftReset",
        "namespace Rule30Submission",
        "open Ruliology.CellularAutomata",
        "namespace Tail",
        "open Rule30Diagonals (transducer_periodic)",
        "open Rule30LeftReset (EvPer EvWhite period_or_white white_forces_eq)",
        "open Rule30LeftUnbounded (B Bpow Bpow_zero win zero Trunc win_trunc zero_trunc "
        "xor_cancel pairCode pairCode_lt pairCode_inj pigeonhole code code_lt code_inj)",
        section(tail, "/-! ### The tail-left interface", "/-! ### The zero-wall diagonals"),
        "end Tail",
        "namespace Near",
        section(near, "open Rule30Realization (evol)", "/-! ## Standard words").replace(
            "Rule30ZeroWallDiagonals.", "Tail."),
        "end Near",
        section(blocks, "/-! ### Sums of lengths", "/-! ### Repeats measured in lengths"),
        section(blocks, "def NearSquare", "/-- **Near-squares of one arc."),
        section(blocks, "/-! ### Beside a clock -/", "/-- **Block codes.**").replace(
            "Rule30ClockNearSquares.", "Near."),
        section(blocks, "/-- A place in a concatenation", "/-- **Blocks in the order of an arc."),
    ]
    imports, body = lines[:3], lines[3:]
    for name in ("WeightedRepeatTransfer", "SeparatedArcCuts", "FreePhaseFrequency"):
        text = (here / (name + ".lean")).read_text(encoding="utf-8")
        for line in text.splitlines():
            if line.startswith("import Mathlib.") and line not in imports:
                imports.append(line)
        new = text[text.index("/-!"):].strip()
        body.append(new.replace(" Rule30RotationBlocks", "").replace("open Rule30Realization (evol)\n", ""))
    source = "\n".join(imports) + "\n\n" + "\n\n".join(body) + "\n\nend Rule30Submission\n"
    assert '"' not in source and chr(92) not in source
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(source.encode("utf-8"))


if __name__ == "__main__":
    main()
