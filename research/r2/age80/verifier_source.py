"""Print the single Lean module for the verifier at kit 5fb5915."""
from pathlib import Path
import subprocess
import sys

KIT_REV = "8ff5467a397820c0a462ab750bd006160d340146"
NAMESPACE = "Ruliology.CellularAutomata."
DEPENDENCIES = ("Rule30LateTwins", "Rule30AgeEightInverse", "Rule30AgeTwentyFourInverse")


def declarations(source, module, target):
    # Move only the namespace wrapper. All declarations and their proofs are unchanged.
    begin = "namespace " + NAMESPACE + module + "\n"
    end = source.rindex("\nend ")
    body = source.split(begin, 1)[1]
    body = body[:body.rindex("\nend ")]
    assert source[end:].strip() in ("end " + module, "end " + NAMESPACE + module)
    return f"namespace {target}\n{body}\nend {target}\n"


def main():
    kit = Path(sys.argv[1])
    print("import Ruliology.CellularAutomata.Rule30Prize")
    print("import Ruliology.CellularAutomata.Rule30ZeroBoundary")
    print("\nopen Ruliology.CellularAutomata\n")
    print("/- The verifier predates the following three catalogue modules. Their declarations")
    print("   are reproduced from kit " + KIT_REV + ". -/")
    for name in DEPENDENCIES:
        path = "lean/Ruliology/CellularAutomata/" + name + ".lean"
        source = subprocess.check_output(["git", "-C", str(kit), "show", KIT_REV + ":" + path],
                                         text=True)
        print(declarations(source, name, "Rule30Submission." + name))
    name = "Rule30AgeEightyInverse"
    print(declarations(Path(__file__).with_name(name + ".lean").read_text(), name, "Rule30Submission"))


if __name__ == "__main__":
    main()
