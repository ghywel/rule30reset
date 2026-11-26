"""Append the three-step proof to the sealed S23 source in either of its forms."""
import argparse
import hashlib
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

HERE = Path(__file__).resolve().parent
BASE_SHA = "0337220db6001b1e7b6637928ced6c946714ed53ad5f8a619bc4576b920df3c9"


def build(output, portal):
    if portal:
        with TemporaryDirectory() as scratch:
            base = Path(scratch) / "s23.lean"
            subprocess.run([sys.executable, HERE / "claudeM5_s23_assemble.py", base], check=True)
            text = base.read_text(encoding="utf-8")
    else:
        text = (HERE / "Rule30DrivenLeftInverse.lean").read_text(encoding="utf-8")
        assert hashlib.sha256(text.encode()).hexdigest() == BASE_SHA
    namespace = "Rule30Submission" if portal else "Ruliology.CellularAutomata"
    end = f"end {namespace}.Rule30DrivenLeftInverse"
    assert text.rstrip().endswith(end)
    extension = (HERE / "three-step-extension.lean").read_text(encoding="utf-8")
    output.write_text(text[:text.rindex(end)] + extension.rstrip() + "\n\n" + end + "\n",
                      encoding="utf-8", newline="\n")
    print(hashlib.sha256(output.read_bytes()).hexdigest())


if __name__ == "__main__":
    script = argparse.ArgumentParser(description=__doc__)
    script.add_argument("output", type=Path)
    script.add_argument("--portal", action="store_true")
    args = script.parse_args()
    build(args.output, args.portal)
