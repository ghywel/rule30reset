"""Build the I72 real-density module for the portal's pre-S9 kit at 5fb5915."""
from pathlib import Path
import hashlib
import subprocess
import sys

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
    if name == "Rule30DensityMixtures":
        source = source[:source.index("private theorem count_range")] + source[source.rindex("\nend "):]
    return "\n".join(line for line in source.splitlines() if
                     line not in {"module", "@[expose] public section"} and
                     not line.startswith("public import ")).strip()


def main(out):
    src = (HERE / "Rule30RealDensityRegion.lean").read_text(encoding="utf-8")
    imports, body = src.split("/-!", 1)
    imports = [line for line in imports.splitlines() if line.startswith("import Mathlib.")]
    parts = ["import Ruliology.CellularAutomata.Rule30Realization",
             "import Ruliology.CellularAutomata.Rule30Prize", *imports]
    parts.extend(carry(name) for name in SOURCES)
    parts.append("/-!" + body.replace("namespace Rule30RealDensityRegion", "namespace Rule30Submission")
                 .replace("end Rule30RealDensityRegion", "end Rule30Submission"))
    data = ("\n\n".join(parts).rstrip() + "\n").encode("utf-8")
    out.write_bytes(data)
    print(f"{hashlib.sha256(data).hexdigest()}  {len(data)} bytes  {out.name}")


if __name__ == "__main__":
    main(Path(sys.argv[1]))

