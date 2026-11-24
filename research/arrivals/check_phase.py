"""Build and replay the four phase-sampled arrival proofs with the kit checker."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory
from time import monotonic


SRC = Path(__file__).resolve().parent
KIT = SRC.parents[1] / "Rule30PrizeKit"
HEADLINES = {
    "Rule30WhiteArrivalWindow": ["window"],
    "Rule30WhiteArrivals": ["eventual_clean", "eventual_gate_decoder", "white_net_aperiodic",
                            "white_shell_eq", "white_shell_aperiodic"],
    "Rule30WhiteArrivalMarkers": ["two_zeros", "odd_return", "oddKick_iff_return", "odd_kicks_aperiodic"],
    "Rule30BlackArrivals": ["black_marks", "black_net_aperiodic", "black_shell_complement",
                            "black_shell_aperiodic", "both_phases"],
}


def replay(out):
    out.mkdir(parents=True, exist_ok=True)
    lake_dir = KIT / "lean"
    deps = ["Rule30SourceArrivals", "Rule30PeriodTwoWidth13", "Rule30GatePulseReturn"]
    subprocess.run(["lake", "build", *("Ruliology.CellularAutomata." + d for d in deps)],
                   cwd=lake_dir, check=True)
    paths = subprocess.check_output(["lake", "env", sys.executable, "-c",
                                     "import os; print(os.environ['LEAN_PATH'])"],
                                    cwd=lake_dir, text=True).strip()
    env = dict(os.environ, LEAN_PATH=str(out) + os.pathsep + paths)
    for module, names in HEADLINES.items():
        start = monotonic()
        subprocess.run(["lean", "--root=" + str(SRC), "-o", str(out / (module+".olean")),
                        str(SRC / (module+".lean"))], cwd=lake_dir, env=env, check=True)
        built = monotonic()
        args = ["lean", "--run", str(KIT / "Check.lean"), module, "--claim", "partial"]
        for name in names:
            args += ["--headline", "Ruliology.CellularAutomata." + module + "." + name]
        check = subprocess.run(args, cwd=lake_dir, env=env, stdout=subprocess.PIPE, text=True, encoding="utf-8")
        result = json.loads(next(line for line in reversed(check.stdout.splitlines()) if line.startswith("{")))
        (out / (module+".check.json")).write_text(json.dumps(result, indent=2)+"\n", encoding="utf-8")
        if check.returncode or result["verdict"] != "pass" or result["newAxioms"]:
            raise RuntimeError(f"{module}: {result['reasons']}, axioms {result['newAxioms']}")
        print(f"{module}: {result['replay']['constants']} declarations, {len(names)} headlines, "
              f"zero new axioms; {built-start:.1f}s build, {monotonic()-built:.1f}s replay", flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="keep compiled modules and checker receipts here")
    args = parser.parse_args()
    if args.output:
        replay(args.output.resolve())
    else:
        with TemporaryDirectory() as tmp:
            replay(Path(tmp))
