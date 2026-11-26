"""Write the kit's module-system form of Rule30NineTenthsRing.lean (M202).

Usage: python3 claudeM5_ring_kitform.py OUTPUT
Reads the reviewed module beside this script (SHA-256 1c438627...) and changes only its header and namespace:
`module`, `public import` of the kit's Rule30DensityEscape, `@[expose] public section` after the docstring,
and the namespace `Ruliology.CellularAutomata.Rule30NineTenthsRing`, as in every kit module. The public `film`
unfolds to the 155-column table, and an exposed definition may not use private ones, so the table's six helpers
(`Word`, `Pair`, `previous`, `table`, `column`, `right`) lose `private`. Nothing else changes.
"""
import hashlib
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCE = HERE / "Rule30NineTenthsRing.lean"
REVIEWED = "1c438627f906fdb381c4bb43f841ab0c1978457c4c9cd3fa5b980aa940ea1709"
HEAD = "import Ruliology.CellularAutomata.Rule30DensityEscape\n"
NAME = "Rule30NineTenthsRing"
FULL = "Ruliology.CellularAutomata." + NAME
PUBLIC = ("abbrev Word ", "abbrev Pair ", "def previous ", "def table ", "def column ", "def right ")


def kit_form(text):
    assert text.startswith(HEAD)
    body = text[len(HEAD):]
    end = body.index("-/\n") + 3
    body = body[:end] + "@[expose] public section\n" + body[end:]
    assert body.count(f"namespace {NAME}\n") == 1 and body.count(f"end {NAME}\n") == 1
    body = body.replace(f"namespace {NAME}\n", f"namespace {FULL}\n").replace(f"end {NAME}\n", f"end {FULL}\n")
    for helper in PUBLIC:
        assert body.count("private " + helper) == 1, helper
        body = body.replace("private " + helper, helper)
    return "module\n\npublic import Ruliology.CellularAutomata.Rule30DensityEscape\n" + body


if __name__ == "__main__":
    data = SOURCE.read_bytes()
    assert hashlib.sha256(data).hexdigest() == REVIEWED, "not the reviewed module"
    out = kit_form(data.decode("utf-8"))
    Path(sys.argv[1]).write_text(out, encoding="utf-8", newline="\n")
    print(hashlib.sha256(out.encode("utf-8")).hexdigest())
