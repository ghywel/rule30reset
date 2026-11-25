"""Carry the released S16 source into the sharp-slope proof at the verifier pin."""
import argparse
import hashlib
from pathlib import Path


S16_SHA256 = "57a50d401f96e37997b310e57c0f8ed11d0ca7a2e030078cbb487f5570ab8edf"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("s16", type=Path, help="Rule30Submission.lean from S16 packet b")
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    carried = args.s16.read_bytes()
    if hashlib.sha256(carried).hexdigest() != S16_SHA256:
        parser.error("the carried S16 source does not match the released file")

    source = Path(__file__).with_name("Rule30EtherThreeSharpSlope.lean").read_text(encoding="utf-8")
    header, sep, body = source.partition("\nnamespace ")
    if not sep or "public import Ruliology.CellularAutomata.Rule30PeriodThreeEntry\n" not in header:
        parser.error("unexpected kit import")
    theorem = sep + body
    theorem = theorem.replace(
        "open Rule30EtherThreeDeparture Rule30PeriodThreeEntry Rule30PeriodThreeEntryTables",
        "open Rule30Submission Rule30Submission.Rule30EtherThreeDeparture",
    )
    theorem = theorem.replace(
        "Ruliology.CellularAutomata.Rule30EtherThreeSharpSlope", "Rule30Submission.SharpSlope"
    )
    theorem = theorem.replace(
        "open Rule30Ether Rule30EtherThree", "open Ruliology.CellularAutomata\nopen Rule30Ether Rule30EtherThree"
    )
    args.output.write_bytes(carried + theorem.encode("utf-8"))


if __name__ == "__main__":
    main()
