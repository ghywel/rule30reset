"""Write the kit's module-system form of Rule30RunTransitionWindows.lean (M199).

Usage: python3 claudeM5_i93_kitform.py OUTPUT
Reads the reviewed module beside this script (SHA-256 008768bc...) and changes only its header:
`module`, `public import` for its two imports, and `@[expose] public section` after the docstring.
"""
import hashlib
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCE = HERE / "Rule30RunTransitionWindows.lean"
REVIEWED = "008768bc9d00c3230eb87b784b5788be7ace9ee1cca9588551d4b0f05a6e2fa7"
HEAD = ("import Ruliology.CellularAutomata.Rule30RunTransitions\n"
        "import Ruliology.CellularAutomata.Rule30FiniteStrips\n")


def kit_form(text):
    assert text.startswith(HEAD)
    body = text[len(HEAD):]
    end = body.index("-/\n") + 3
    body = body[:end] + "\n@[expose] public section\n" + body[end:]
    return ("module\n\npublic import Ruliology.CellularAutomata.Rule30RunTransitions\n"
            "public import Ruliology.CellularAutomata.Rule30FiniteStrips\n" + body)


if __name__ == "__main__":
    data = SOURCE.read_bytes()
    assert hashlib.sha256(data).hexdigest() == REVIEWED, "not the reviewed module"
    out = kit_form(data.decode("utf-8"))
    Path(sys.argv[1]).write_text(out, encoding="utf-8", newline="\n")
    print(hashlib.sha256(out.encode("utf-8")).hexdigest())
