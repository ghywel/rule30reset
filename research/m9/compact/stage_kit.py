"""Stage the two compact M9 modules and their catalogue entries in a kit checkout."""

import argparse
import re
from pathlib import Path


HERE = Path(__file__).resolve().parent
NAMESPACE = "Ruliology.CellularAutomata."
MASK_END = "end " + NAMESPACE + "Rule30TrappedRunMasks\n"
FAMILY = "Rule30TrappedRuns"
DATA_ROW = (
    "| `TrappedRunMasks` | `Rule30TrappedRuns` | 98-sample masks for spatial prefixes, "
    "including both exterior inputs at width 45, with soundness proofs |"
)
FAMILY_ROW = (
    "| `Rule30TrappedRuns` | {DATE} | For every gate-trap ladder width W ≥ 16, the word "
    "3 (55553)⁴ is excluded from sample two onward exactly when W ≥ 45. At these widths "
    "(55553)⁵ is excluded from entry. Physical right halves obey the same exclusions, "
    "and witnesses attain four closed runs at delay one and three at delay sixty. "
    "Contributed by {AUTHORS} as Rule 30 Prize submission [{ID}]({PAGE}). | "
    "`four_width_iff`, `no_four_on_lift`, `no_five_on_lift`, `four_at_width44`, "
    "`no_four_runs_of_four`, `no_five_runs_of_four`, `four_one_sample`, `three_sixty_samples` |"
)


def kit_modules():
    portal = (HERE / "Rule30Submission.lean").read_text(encoding="utf-8")
    data, physical = portal.split(MASK_END, 1)
    start = data.index("/-!")
    end = data.index("-/", start) + 2
    data = (
        data[:start]
        + "/-! Time masks for trapped-gate runs, checked under the packed double step "
        + "and both exterior choices of the width-45 ladder. -/"
        + data[end:]
        + MASK_END
    )
    boundary = (HERE / "TrappedRunBoundary.lean").read_text(encoding="utf-8")
    data += "\n" + boundary.split("@[expose] public section\n", 1)[1].lstrip()
    family = (HERE / "Rule30TrappedRuns.lean").read_text(encoding="utf-8")
    physical = physical.split("namespace Rule30Submission\n", 1)[0].strip()
    if physical not in family:
        raise ValueError("The family module must contain the reviewed physical proofs verbatim.")
    return {
        "Rule30Certificates/TrappedRunMasks.lean": data,
        "Rule30TrappedRuns.lean": family,
    }


def add_catalogue_row(text, section, row):
    if row in text.splitlines():
        return text
    header = text.index(section)
    separator = text.index("\n|---", header)
    first_row = text.index("\n", separator + 1) + 1
    return text[:first_row] + row + "\n" + text[first_row:]


def stage(kit):
    lean = kit / "lean"
    root = lean / "Ruliology/CellularAutomata"
    changes = {}
    for relative, contents in kit_modules().items():
        path = root / relative
        if path.exists() and path.read_text(encoding="utf-8") != contents:
            raise ValueError(f"Existing different module at {path}")
        changes[path] = contents

    umbrella = lean / "Ruliology.lean"
    imports = umbrella.read_text(encoding="utf-8").splitlines(keepends=True)
    family_import = f"public import {NAMESPACE}{FAMILY}\n"
    if family_import not in imports:
        after = max(i for i, line in enumerate(imports) if line.startswith("public import ")) + 1
        imports.insert(after, family_import)
        changes[umbrella] = "".join(imports)
        index = kit / "Rule30PrizeKit.lean"
        text = index.read_text(encoding="utf-8")
        pattern = r"(brings the whole catalog, )(\d+)( modules)"
        text, count = re.subn(pattern, lambda m: f"{m[1]}{int(m[2])+2}{m[3]}", text)
        if count != 1:
            raise ValueError("Expected one catalogue module count in Rule30PrizeKit.lean")
        changes[index] = text

    readme = lean / "README.md"
    text = add_catalogue_row(readme.read_text(encoding="utf-8"), "## Added in the kit", FAMILY_ROW)
    changes[readme] = add_catalogue_row(text, "## Certificate data", DATA_ROW)
    for path, contents in changes.items():
        path.write_text(contents, encoding="utf-8", newline="\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path, help="a clean or previously staged kit checkout")
    stage(parser.parse_args().kit)
