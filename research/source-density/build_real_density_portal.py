"""Build either I72 proof for the pre-S9 portal kit. Pass --ring for ring rigidity."""
import argparse
import hashlib
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
KIT = HERE.parents[1] / "Rule30PrizeKit"
REV = "71151d02213022d5c3c7e5823ed5d0bb15c43c1c"
SOURCES = (
    "Rule30SourceObservables", "Rule30SourceDensityRegion", "Rule30DensityPolygon",
    "Rule30DensityControl", "Rule30DensityModes", "Rule30DensityVertices", "Rule30DensityMixtures",
)


def carry(name):
    path = f"lean/Ruliology/CellularAutomata/{name}.lean"
    raw = subprocess.check_output(["git", "-C", str(KIT), "show", f"{REV}:{path}"])
    source = raw.decode("utf-8").replace("\r\n", "\n")
    # The portal needs only the count-order lemmas and the arbitrary schedule.
    if name == "Rule30DensityPolygon":
        opening = source.index("/-- The linear inequality holds")
        source = (source[:opening] + source[source.index("private theorem count_nonneg"):
                  source.index("/-- The five faces")] + source[source.rindex("\nend "):])
        source = source.replace("rw [h n hf];exact Int.le_refl _", "rw [h n hf]")
    if name == "Rule30DensityControl":
        # Mathlib reserves the token <i for principal segments.
        source = source.replace("k<i)", "k < i)")
    if name == "Rule30DensityMixtures":
        source = source[:source.index("private theorem count_range")] + source[source.rindex("\nend "):]
    return "\n".join(line for line in source.splitlines() if
                     line not in {"module", "@[expose] public section"} and
                     not line.startswith("public import ")).strip()


def main(out, ring=False):
    name = "Rule30NineTenthsRing" if ring else "Rule30RealDensityRegion"
    modules = ("Rule30SourceObservables", "Rule30SourceDensityRegion", "Rule30DensityEscape") if ring else SOURCES
    src = (HERE / f"{name}.lean").read_text(encoding="utf-8")
    imports, body = src.split("/-!", 1)
    imports = [line for line in imports.splitlines() if line.startswith("import Mathlib.")]
    parts = ["import Ruliology.CellularAutomata.Rule30Realization",
             "import Ruliology.CellularAutomata.Rule30Prize", *imports]
    parts.extend(carry(module) for module in modules)
    parts.append("/-!" + body.replace(f"namespace {name}", "namespace Rule30Submission")
                 .replace(f"end {name}", "end Rule30Submission"))
    data = ("\n\n".join(parts).rstrip() + "\n").encode("utf-8")
    out.write_bytes(data)
    print(f"{hashlib.sha256(data).hexdigest()}  {len(data)} bytes  {out.name}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("--ring", action="store_true")
    args = parser.parse_args()
    main(args.output, args.ring)

