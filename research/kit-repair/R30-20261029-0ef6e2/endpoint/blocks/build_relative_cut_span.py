"""Assemble the free-phase ratio-six proof using the verifier pin's window form of Jen."""
import argparse
from pathlib import Path

from claudeIntel_build_free_phase import section


def build(kit, output):
    here = Path(__file__).resolve().parent
    blocks = (kit / "lean/Ruliology/CellularAutomata/Rule30RotationBlocks.lean").read_text(encoding="utf-8")
    imports = ["import Ruliology.CellularAutomata.Rule30FiniteMaskedJen",
               "import Ruliology.CellularAutomata.Rule30Realization"]
    body = ["namespace Rule30Submission", "namespace Rule30RotationBlocks",
            section(blocks, "/-! ### Sums of lengths", "/-! ### Repeats measured in lengths"),
            section(blocks, "/-- A place in a concatenation", "/-- **Blocks in the order of an arc."),
            "end Rule30RotationBlocks"]
    modules = [
        ("WeightedRepeatTransfer", "/-- In one window"),
        ("SeparatedArcCuts", "/-- A finite-left clock"),
        ("FreePhaseFrequency", "/-- **Free phases."),
        ("JenBlockWindow", None),
        ("RelativeCutSpan", None),
    ]
    for name, stop in modules:
        source = (here / (name + ".lean")).read_text(encoding="utf-8")
        for line in source.splitlines():
            if line.startswith("import Mathlib.") and line not in imports:
                imports.append(line)
        part = source[source.index("namespace "):]
        if stop:
            namespace = part.splitlines()[0].split()[1]
            part = part[:part.index(stop)].rstrip() + "\n\nend " + namespace
        body.append(part.rstrip())
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(("\n".join(imports) + "\n\n" + "\n\n".join(body)
                        + "\n\nend Rule30Submission\n").encode("utf-8"))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    build(args.kit, args.output)
