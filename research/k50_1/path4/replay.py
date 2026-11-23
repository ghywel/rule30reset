"""Build the Path 4 sources and replay their headlines with the kit's own checker."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import time


KIT = "60799e80bdc7bc8c57bf77f8d6c3ec0e9ec4bad4"
LOWRY = "0aa79befcce1b525482ada70a48d20e8afa486cc"
NAMESPACE = "Ruliology.CellularAutomata."
PR_MODULE = NAMESPACE + "Rule30LockedSeedEdge"
PR_PATH = Path(*PR_MODULE.split(".")).with_suffix(".lean")
SUPPORT = ("Rule30Lock7Compactness", "Rule30LockCube", "Rule30Lock7Prefixes", "Rule30Lock7CenterDeadline")
HEADLINES = {
    PR_MODULE: ("prefix_enters_lock7", "seed364_enters", "seed364_no_finite_left",
                "prefix_misses_seven", "seven_miss_singleton", "six_agree_991"),
    "Rule30Lock7Certificate": ("accepts_hit", "accepts_sound", "accepted_phase", "deadline_iff",
                              "checkCover_iff_certificate", "eventual_iff", "lowry_one_leaf",
                              "lowry_wrong_phase", "lowry_one_leaf_lengths", "lowry_77_passes",
                              "lowry_77_phase", "five_leaves_at_nine"),
    "Rule30Lock7CertificateCenter": ("centre_bound_of_certificate", "no_period_two_of_cofinal_certificates"),
    "Rule30Lowry378Comparison": ("checkCover_from_pr", "prefix_entry_from_leaf",
                                "centre_bound_at_matching_ages", "centre_bound_at_77_cells"),
}


def logged(command, cwd, log, env=None):
    start = time.perf_counter()
    with log.open("wb") as stream:
        run = subprocess.run(command, cwd=cwd, env=env, stdout=stream, stderr=subprocess.STDOUT)
    if run.returncode:
        raise RuntimeError(f"{command[0]} exited {run.returncode}. See {log}")
    return round(time.perf_counter() - start, 3)


def replay(kit, work):
    actual = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=kit, text=True).strip()
    if actual != KIT:
        raise ValueError(f"Use a kit worktree at {KIT}. This worktree is at {actual}.")
    pr_source = subprocess.check_output(["git", "show", f"{LOWRY}:lean/{PR_PATH.as_posix()}"], cwd=kit)
    work.mkdir(parents=True, exist_ok=True)
    src = Path(__file__).resolve().parents[1]
    lean = kit / "lean"
    kit_objects = lean / ".lake/build/lib/lean"
    sources, objects = work / "sources", work / "objects"
    sources.mkdir(exist_ok=True)
    objects.mkdir(exist_ok=True)
    deps = ["Rule30SidewaysLocks", "Rule30PlantedSurvivor", "Rule30Blocks", "Rule30Prize"]
    logged(["lake", "build", *(NAMESPACE + dep for dep in deps)], lean, work / "kit-build.log")
    env = os.environ.copy()
    env["LEAN_PATH"] = os.pathsep.join(map(str, (objects, kit_objects)))
    results = {}
    for name in (*SUPPORT, *HEADLINES):
        if name == PR_MODULE:
            source = sources / PR_PATH
            source.parent.mkdir(parents=True, exist_ok=True)
            source.write_bytes(pr_source)
            # Lean resolves each package from one object root. Keep this module
            # with its kit siblings and the independent research modules in work.
            output = (kit_objects / PR_PATH).with_suffix(".olean")
        else:
            source = sources / (name + ".lean")
            shutil.copyfile(src / source.name, source)
            output = objects / (name + ".olean")
        result = {"sha256": hashlib.sha256(source.read_bytes()).hexdigest()}
        result["build_seconds"] = logged(
            ["lean", "-R", sources, "-o", output, source],
            lean, work / (name + "-build.log"), env)
        if name in HEADLINES:
            full_name = name if name == PR_MODULE else NAMESPACE + name
            args = ["lean", "--run", kit / "Check.lean", name, "--claim", "partial"]
            expected = [full_name + "." + h for h in HEADLINES[name]]
            for h in expected:
                args.extend(["--headline", h])
            log = work / (name + "-check.log")
            result["check_seconds"] = logged(args, lean, log, env)
            artifact = next(line for line in log.read_text(encoding="utf-8-sig").splitlines() if line.startswith("{"))
            receipt = json.loads(artifact)
            if (receipt["verdict"] != "pass" or not receipt["replay"]["ok"] or receipt["newAxioms"]
                    or not receipt["importsStatements"] or [h["name"] for h in receipt["headlines"]] != expected
                    or not all(h["ok"] for h in receipt["headlines"])
                    or not all(d["standardAxioms"] for d in receipt["declared"])):
                raise ValueError(f"Unexpected stock-check result in {log}")
            (work / (name + "-check.json")).write_text(artifact + "\n", encoding="utf-8")
            result.update(constants=receipt["replay"]["constants"], headlines=len(expected))
        print(name, result, flush=True)
        results[name] = result
    (work / "summary.json").write_text(
        json.dumps(dict(kit=KIT, pr378=LOWRY, modules=results), indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path, help="kit worktree with the pinned PR commit fetched")
    parser.add_argument("work", type=Path, help="separate directory for build products and receipts")
    args = parser.parse_args()
    replay(args.kit.resolve(), args.work.resolve())
