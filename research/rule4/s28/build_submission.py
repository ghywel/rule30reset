"""Assemble the K83 portal module and the core finite-support companion."""
import argparse
from pathlib import Path


def source(path):
    return path.read_text(encoding="utf-8").rstrip()


def body(path):
    return "\n".join(line for line in source(path).splitlines()
                     if line != "module"
                     and line != "@[expose] public section"
                     and not line.startswith(("import ", "public import ", "#print axioms "))).strip()


def rename(text, old, new):
    assert text.count(f"namespace {old}\n") == 1
    assert text.endswith(f"end {old}")
    return text.replace(f"namespace {old}\n", f"namespace {new}\n", 1).removesuffix(
        f"end {old}") + f"end {new}"


def build(output):
    root = Path(__file__).resolve().parents[1]
    past = rename(body(root / "K83RightCoin.lean"), "K83RightCoin",
                  "Rule30Submission.RightHalfPast")
    feedback = rename(body(root / "K83Feedback.lean"), "K83Feedback",
                      "Rule30Submission.RightHalfFeedback")
    feedback = feedback.replace("A read of K83RightCoin (claudeIntel). Its adaptive corollary, and the reduction of A1, in Lean.",
                                "The mass law under continuous feedback and the conditional reduction to pure periods.")
    feedback = feedback.replace("RandomConfigurations K83RightCoin",
                                "RandomConfigurations Rule30Submission.RightHalfPast")
    west_path = root / "k84/K84FiniteSupport.lean"
    old = "Ruliology.CellularAutomata.Rule30PeriodTwoSideways"
    support = source(west_path)
    intro = ("/-! Exact finite support of a west that sustains an alternating Rule 30 centre. "
             "The existing sideways inverse supplies the required west and the first-disagreement time. -/")
    support = rename(support, old, "Ruliology.CellularAutomata.Rule30AlternatingFiniteSupport")
    support = support.replace("@[expose] public section", intro + "\n\n@[expose] public section")
    support = support.replace("open Rule30Realization Rule30ZeroBoundary Rule30PeriodTwoCoupled",
                              "open Rule30Realization Rule30ZeroBoundary Rule30PeriodTwoCoupled Rule30PeriodTwoSideways")

    west = rename(body(west_path), old, "Rule30Submission.AlternatingFiniteSupport")
    west = west.replace("open Rule30Realization Rule30ZeroBoundary Rule30PeriodTwoCoupled",
                        "open Ruliology.CellularAutomata Rule30Realization Rule30ZeroBoundary\n"
                        "  Rule30PeriodTwoCoupled Rule30PeriodTwoSideways")
    portal = "\n\n".join(["import Rule30Equivalents.Mixing\nimport " + old,
                          past, feedback, west]) + "\n"
    assert '"' not in portal and chr(92) not in portal
    (output / "portal").mkdir(parents=True, exist_ok=True)
    (output / "kit").mkdir(parents=True, exist_ok=True)
    (output / "portal/Rule30Submission.lean").write_bytes(portal.encode("utf-8"))
    (output / "kit/Rule30AlternatingFiniteSupport.lean").write_bytes((support + "\n").encode("utf-8"))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    build(parser.parse_args().output)
