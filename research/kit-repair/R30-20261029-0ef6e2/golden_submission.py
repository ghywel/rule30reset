"""Write the self-contained golden N6 Rule30Submission.lean to stdout."""
from pathlib import Path
import sys


def source():
    folder = Path(__file__).resolve().parent
    imports = []
    bodies = []
    for name in ("GoldenStripCover.lean", "GoldenRotation.lean"):
        lines = (folder / name).read_text(encoding="utf-8").splitlines(keepends=True)
        while lines and lines[0].startswith("import "):
            line = lines.pop(0)
            if line != "import GoldenStripCover\n" and line not in imports:
                imports.append(line)
        bodies.append("".join(lines).strip())
    return "".join(imports) + "\nnamespace Rule30Submission\n\n" + "\n\n".join(bodies) + "\n\nend Rule30Submission\n"


if __name__ == "__main__":
    sys.stdout.buffer.write(source().encode("utf-8"))
