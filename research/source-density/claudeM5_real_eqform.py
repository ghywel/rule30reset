"""Write the kit's equivalents/ form of Rule30RealDensityRegion.lean (M203).

Usage: python3 claudeM5_real_eqform.py OUTPUT
Reads the reviewed module beside this script (SHA-256 61d8d0ba...) and changes only its header and namespace,
to the pattern of every module in the kit's equivalents/: `module`, `public import` for each import, a titled
module docstring with the credit line, `@[expose] public section`, and the namespace
`Rule30Equivalents.RealDensityRegion`. No declaration changes.
"""
import hashlib
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCE = HERE / "Rule30RealDensityRegion.lean"
REVIEWED = "61d8d0bafe155318377bbdadcd99b356d29cb000a94a6220e927d016d7ad2d3c"
OLD, NEW = "Rule30RealDensityRegion", "Rule30Equivalents.RealDensityRegion"
DOC_OLD = """/-! Real limiting frequencies of a black cell and a horizontal run end.
The physical construction is the arbitrary controller schedule from S9. -/
"""
DOC_NEW = """/-!
# The exact real density region at one site

Real limiting frequencies of a black cell and a horizontal run end. From any prescribed right half,
the limiting pair is attainable exactly in the closed pentagon of the core `Rule30SourceDensityRegion`
(`real_density_region`), with squared count errors at most 210000(n + 1) at every tick
(`quantitative_realization`). The physical construction is the arbitrary controller schedule of the
core `Rule30DensityControl` and `Rule30DensityMixtures`.

Contributed by Gareth Herbert with Claude (Anthropic) and GPT (OpenAI).
-/

@[expose] public section
"""


def eq_form(text):
    head, rest = text.split("/-!", 1)
    imports = [line for line in head.splitlines() if line.strip()]
    assert all(line.startswith("import ") for line in imports), imports
    body = "/-!" + rest
    assert body.count(DOC_OLD) == 1
    body = body.replace(DOC_OLD, DOC_NEW)
    assert body.count(f"namespace {OLD}\n") == 1 and body.count(f"end {OLD}\n") == 1
    body = body.replace(f"namespace {OLD}\n", f"namespace {NEW}\n").replace(f"end {OLD}\n", f"end {NEW}\n")
    return "module\n\n" + "\n".join("public " + line for line in imports) + "\n\n" + body


if __name__ == "__main__":
    data = SOURCE.read_bytes()
    assert hashlib.sha256(data).hexdigest() == REVIEWED, "not the reviewed module"
    out = eq_form(data.decode("utf-8"))
    Path(sys.argv[1]).write_text(out, encoding="utf-8", newline="\n")
    print(hashlib.sha256(out.encode("utf-8")).hexdigest())
