"""Build the wheel proofs against the kit and replay the public headlines."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time


PIN = "8e1cc847a758a892ec4b51182cdf325b1c483f9a"
EXTERIOR_PIN = "7c764eff648a5e795aa3d4afe346db243b6db337"
KICK_PIN = "b686c1d2547d27c4451f5691861a63f3cc4caf9f"
OBSERVER_PIN = "f41bb494d64f120e0e6f07ab68d799a6018396cc"
MODULES = ("WheelMarkerData", "WheelMarkerGraph", "WheelMarkerCheck", "WheelTiles", "WheelMarker", "WheelReturn")
HEADLINES = {
    "WheelTiles": ("tiles_of_pulse", "seven_secondary", "seven_b_secondary", "five_long_tile",
                   "no_seventeen_secondary", "secondary_sixteen_witness", "midpoint_of_gate",
                   "five_clock_needs_three"),
    "WheelMarker": ("marker_enters", "wheel_enters", "singleton_wheel_enters",
                    "wheel_bars_secondary", "singleton_white_break"),
    "WheelReturn": ("singleton_return_break",),
    "WheelThreeGapExterior": ("driven_ring", "outside_forever", "arbitrarily_long_finite",
                              "no_periodic_white_tail"),
    "WheelKickRelay": ("six_tick_relay", "trapped_pulse_prefix", "trapped_selector"),
    "WheelGateObserver": ("cleanb_spec", "clean_of_entry", "entry_iff_clean", "bounded_detection",
                          "rd_iff_event", "outside_iff_bounded_defects"),
    "WheelObserverLowerBound": ("physical", "same_reading", "physical_labels", "no_classifier_47",
                                "no_short_classifier"),
    "WheelObserverCleanup": ("no_33_after_six", "clean_after_six", "five_fails", "detect_after_six",
                             "confirms_after_53", "first_confirmation_53", "uniform_confirmation_delay_iff"),
    "WheelTwoGapRecurrence": ("two_gap_iff_five_sites", "four_sites_ambiguous", "no_two_gap_of_entry", "finite_two_gap_forever",
                              "outside_iff_recurs", "outside_iff_frequent", "rd_iff_late_quiet_blocks"),
    "WheelObserverTransport": ("nextRow_link", "sound_of_cut", "layer_sound_path"),
    "WheelObserverExact": ("sound_48", "enter_iff_some_clean_48", "rd_iff_clean_48",
                           "outside_iff_defect_in_every_48"),
    "WheelPulseReturn": ("next_gap", "next_gap_of_core_prefix"),
    "WheelPulsePredictor": ("next_gap_from_second_white", "four_gaps_at_second_white",
                            "two_gap_iff_sites", "no_one_bit_forecast", "first_white_can_fail", "finite_clock_forecast",
                            "singleton_clock_break"),
    "WheelTrappedTwoPulse": ("selector_at_return", "two_pulse", "six_cells_insufficient",
                             "eight_cells_insufficient", "mature_eight_cells_insufficient",
                             "three_site_selector", "unique_three_sites"),
}


def logged(cmd, cwd, env, log):
    start = time.monotonic()
    with log.open("wb") as stream:
        status = subprocess.run(cmd, cwd=cwd, env=env, stdout=stream, stderr=subprocess.STDOUT)
    if status.returncode:
        raise RuntimeError(f"{cmd[0]} exited {status.returncode}. See {log}")
    return round(time.monotonic()-start, 3)


def replay(kit, work, exterior=False, kick=False, observer=False, exact=False, jobs=2, pulse=False):
    kit = kit.resolve()
    work = work.resolve()
    work.mkdir(parents=True, exist_ok=True)
    pin, modules = PIN, MODULES
    deps = ["Rule30Prize","Rule30GateTrapWords","Rule30SidewaysLocks","Rule30MaskedJen"]
    if exterior:
        pin, modules = EXTERIOR_PIN, ("WheelThreeGapExterior",)
        deps = ["Rule30Prize","Rule30GateTrap","Rule30FiniteMaskedJen"]
    if kick:
        pin, modules = KICK_PIN, ("WheelKickRelay",)
        deps = ["Rule30Prize","Rule30GateTrap"]
    if observer or exact:
        pin = OBSERVER_PIN
        modules = ("WheelGateObserver", "WheelObserverLowerBound", "WheelObserverCleanup",
                   "WheelTwoGapRecurrence", "WheelObserverTransport")
        deps = ["Rule30Prize", "Rule30GateTrapWords", "Rule30PeriodTwoWidth13", "Rule30DrivenPrefix",
                "Rule30SidewaysLocks", "Rule30Ether"]
    if exact:
        modules += ("WheelObserverPlanes", "WheelObserverCheck", "WheelObserverScan",
                    "WheelObserverProof", "WheelObserverAllPages", "WheelObserverExact")
    if pulse:
        pin = OBSERVER_PIN
        modules = ("WheelPulseReturn", "WheelPulsePredictor", "WheelKickRelay", "WheelTrappedTwoPulse")
        deps = ["Rule30Prize", "Rule30SidewaysLocks", "Rule30GateTrap"]
    if subprocess.check_output(["git","rev-parse","HEAD"],cwd=kit,text=True).strip() != pin:
        raise ValueError(f"The replay uses kit {pin}")
    lean = kit/"lean"
    source = Path(__file__).resolve().parent
    ns = "Ruliology.CellularAutomata."
    logged(["lake","build",*(ns+d for d in deps)],lean,None,work/"kit-build.log")
    env = dict(os.environ, LEAN_PATH=os.pathsep.join(map(str,(work,lean/".lake/build/lib/lean"))))
    record = {}
    for name in modules:
        folder = source
        if name == "WheelObserverPlanes":
            folder = work
            logged([sys.executable, source/"make_observer_planes.py", kit, work/(name+".lean")],
                   lean, env, work/"generate-planes.log")
        if name == "WheelObserverAllPages":
            folder = work
            elapsed = logged([sys.executable, source/"make_observer_pages.py", kit, work, work,
                              "--jobs", str(jobs)], lean, env, work/"build-pages.log")
        src = folder/(name+".lean")
        r = dict(sha256=hashlib.sha256(src.read_bytes()).hexdigest())
        if name == "WheelObserverAllPages":
            r["build_seconds"] = elapsed
        else:
            r["build_seconds"] = logged(["lean","-j1","-R",folder,"-o",work/(name+".olean"),src],
                                        lean,env,work/(name+"-build.log"))
        if name in HEADLINES:
            names = [ns+name+"."+h for h in HEADLINES[name]]
            cmd = ["lean","--run",kit/"Check.lean",name,"--claim","partial"]
            for h in names:
                cmd.extend(["--headline",h])
            log = work/(name+"-stock.log")
            r["stock_seconds"] = logged(cmd,lean,env,log)
            receipt = json.loads(next(x for x in log.read_bytes().splitlines() if x.startswith(b"{")))
            if (receipt["verdict"] != "pass" or not receipt["importsStatements"] or
                    not receipt["replay"]["ok"] or receipt["newAxioms"] or
                    [h["name"] for h in receipt["headlines"] if h["ok"]] != names or
                    not all(d["standardAxioms"] for d in receipt["declared"])):
                raise ValueError(f"Unexpected stock verdict in {log}")
            r.update(headlines=HEADLINES[name],constants=receipt["replay"]["constants"],new_axioms=[])
            (work/(name+"-stock.json")).write_bytes((json.dumps(receipt)+"\n").encode())
        record[name] = r
        print(name,r,flush=True)
    (work/"replay.json").write_bytes((json.dumps(dict(kit=pin,modules=record),indent=2)+"\n").encode())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit",type=Path)
    parser.add_argument("output",type=Path)
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--exterior", action="store_true", help="Replay the four exterior headlines.")
    group.add_argument("--kick", action="store_true", help="Replay the three phase-slip relay headlines.")
    group.add_argument("--observer", action="store_true", help="Replay the observer controls and physical transport.")
    group.add_argument("--exact-observer", action="store_true", help="Also generate and check the 256 proof pages.")
    group.add_argument("--pulse", action="store_true", help="Replay the one- and two-pulse spatial forecasts.")
    parser.add_argument("--jobs", type=int, default=2, help="Parallel Lean processes for the exact observer.")
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error("--jobs must be positive")
    replay(args.kit,args.output,args.exterior,args.kick,args.observer,args.exact_observer,args.jobs,args.pulse)
