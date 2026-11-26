"""Prepare checked core patch contents in a scratch checkout at the catalog pin."""
import argparse
from pathlib import Path
import re
import subprocess


def patch(kit, candidate, output):
    # Keep staged changes in an isolated linked worktree.
    if not (kit / ".git").is_file():
        raise ValueError("pass an isolated Git worktree")

    def git(*args):
        return subprocess.check_output(["git", "-C", kit, *args])

    path = "lean/Ruliology/CellularAutomata/Rule30AlternatingFiniteSupport.lean"
    generated = (candidate / Path(path).name).read_bytes()
    assert (kit / path).read_bytes() == generated
    commit = git("rev-parse", "HEAD").decode().strip()
    marker = "public import Ruliology.CellularAutomata.Rule30PeriodTwoSideways"
    aggregate = kit / "lean/Ruliology.lean"
    initial = git("show", "HEAD:lean/Ruliology.lean").decode()
    assert initial.count(marker+"\n") == 1
    aggregate.write_bytes(initial.replace(marker+"\n", marker+"\n"+
        "public import Ruliology.CellularAutomata.Rule30AlternatingFiniteSupport\n").encode())
    readme = kit / "lean/README.md"
    catalog = git("show", "HEAD:lean/README.md").decode()
    after = next(i for i,line in enumerate(catalog.splitlines()) if line.startswith(
        "| `Rule30PeriodTwoSideways` |"))
    rows = catalog.splitlines(keepends=True)
    row = ("| `Rule30AlternatingFiniteSupport` | 2026-11-26 | For any driven right half and any horizon T, "
           "black-first alternation through tick T is equivalent to agreement with the required west at depths 1 through T. "
           "A west supported through depth B exists exactly when that required west is white at depths B+1 through T. "
           "Equality of required west prefixes is equivalent to equality of gate readings at white ticks strictly below T. "
           "Contributed by Gareth Herbert with GPT (OpenAI) as Rule 30 Prize submission [PORTAL_ID](PORTAL_URL). | "
           "`alternates_through_iff_prefix`, `supported_west_iff_white_section`, "
           "`required_west_prefix_iff_gate_prefix` |\n")
    rows.insert(after+1,row)
    readme.write_bytes("".join(rows).encode())
    root = kit / "Rule30PrizeKit.lean"
    root_old = git("show", "HEAD:Rule30PrizeKit.lean").decode()
    files = git("ls-tree", "-r", "--name-only", "HEAD", "--", "lean/Ruliology")
    count = sum(line.endswith(b".lean") for line in files.splitlines())
    root_new, matches = re.subn(r"whole catalog, \d+ modules",
                                f"whole catalog, {count+1} modules",root_old)
    assert matches==1 and f"whole catalog, {count} modules" in root_old
    root.write_bytes(root_new.encode())
    git("add","--",path,"Rule30PrizeKit.lean","lean/Ruliology.lean","lean/README.md")
    git("diff","--cached","--check")
    data=git("diff","--cached","--binary","--",path,"Rule30PrizeKit.lean","lean/Ruliology.lean","lean/README.md")
    assert (data.count(b"diff --git "),"PORTAL_ID" in data.decode())==(4,True)
    output.write_bytes(data)
    print(commit,"base;",count,"to",count+1,"catalogue modules;",len(data),"patch bytes")


if __name__ == "__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit",type=Path)
    parser.add_argument("candidate",type=Path)
    parser.add_argument("output",type=Path)
    args=parser.parse_args()
    patch(args.kit,args.candidate,args.output)
