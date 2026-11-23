"""Assemble the single-source M9 proof for the stock Rule 30 Prize submission checker."""
import argparse
from pathlib import Path


HERE = Path(__file__).resolve().parent
MODULES = (
    "Rule30RunWindow",
    "Rule30RunPlanes",
    "Rule30RunPlaneData",
    "Rule30RunPlaneChecks",
    "Rule30TrappedRuns",
)

HEAD = """module

public import Ruliology.CellularAutomata.Rule30Prize
public import Ruliology.CellularAutomata.Rule30GateTrap
public meta import Ruliology.CellularAutomata.Rule30GateTrap
public meta import Std.Data.HashSet.Basic
public meta import Lean.Elab.Term

/-! Sharp forbidden words for the alternating column's trapped gate. -/
@[expose] public section
-- The proposal generator reuses the local executable Rule 30 definitions.
set_option compiler.relaxedMetaCheck true
"""

PUBLIC = """
namespace Rule30Submission
open Ruliology.CellularAutomata
open Rule30GateTrap Rule30TrappedRuns

theorem no_four_runs_of_four (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0+4 ≤ 2*s+1) :
    ¬ ∀ i, i<96 → Rule30PeriodTwoSideways.u R (s+i) = (closed 4).getD i false :=
  Rule30TrappedRuns.no_four_runs_of_four R h0 hw s hs

theorem no_five_runs_of_four (R : Nat → Bool) {t0 : Nat} (h0 : t0 % 2 = 1)
    (hw : win R t0 ∈ trap) (s : Nat) (hs : t0 ≤ 2*s+1) :
    ¬ ∀ i, i<116 → Rule30PeriodTwoSideways.u R (s+i) = five.getD i false :=
  Rule30TrappedRuns.no_five_runs_of_four R h0 hw s hs

theorem four_one_sample :
    ∃ R, win R 1 ∈ trap ∧ ∀ i, i < (closed 4).length →
      Rule30PeriodTwoSideways.u R (1+i) = (closed 4).getD i false :=
  Rule30TrappedRuns.four_one_sample

theorem three_sixty_samples :
    ∃ R, win R 1 ∈ trap ∧ ∀ i, i < (closed 3).length →
      Rule30PeriodTwoSideways.u R (60+i) = (closed 3).getD i false :=
  Rule30TrappedRuns.three_sixty_samples

end Rule30Submission
"""


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    sections = []
    for name in MODULES:
        source = (HERE / f"{name}.lean").read_text(encoding="utf-8")
        _, body = source.split("@[expose] public section\n", 1)
        if name == "Rule30TrappedRuns":
            body = body.replace("Rule30RunChecks.no_trace", "Rule30RunPlaneChecks.no_trace")
        sections.append(body.strip() + "\n")
    args.output.write_text("\n".join([HEAD, *sections, PUBLIC]), encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()
