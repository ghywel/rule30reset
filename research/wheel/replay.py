"""Build the wheel proofs against the kit and replay the public headlines."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time


PIN = "8e1cc847a758a892ec4b51182cdf325b1c483f9a"
EXTERIOR_PIN = "7c764eff648a5e795aa3d4afe346db243b6db337"
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
}


def logged(cmd, cwd, env, log):
    start = time.monotonic()
    with log.open("wb") as stream:
        status = subprocess.run(cmd, cwd=cwd, env=env, stdout=stream, stderr=subprocess.STDOUT)
    if status.returncode:
        raise RuntimeError(f"{cmd[0]} exited {status.returncode}. See {log}")
    return round(time.monotonic()-start, 3)


def replay(kit, work, exterior=False):
    kit = kit.resolve()
    work = work.resolve()
    work.mkdir(parents=True, exist_ok=True)
    pin = EXTERIOR_PIN if exterior else PIN
    if subprocess.check_output(["git","rev-parse","HEAD"],cwd=kit,text=True).strip() != pin:
        raise ValueError(f"The replay uses kit {pin}")
    lean = kit/"lean"
    source = Path(__file__).resolve().parent
    ns = "Ruliology.CellularAutomata."
    deps = (["Rule30Prize","Rule30GateTrap","Rule30FiniteMaskedJen"] if exterior else
            ["Rule30Prize","Rule30GateTrapWords","Rule30SidewaysLocks","Rule30MaskedJen"])
    logged(["lake","build",*(ns+d for d in deps)],lean,None,work/"kit-build.log")
    env = dict(os.environ, LEAN_PATH=os.pathsep.join(map(str,(work,lean/".lake/build/lib/lean"))))
    record = {}
    for name in (("WheelThreeGapExterior",) if exterior else MODULES):
        src = source/(name+".lean")
        r = dict(sha256=hashlib.sha256(src.read_bytes()).hexdigest())
        r["build_seconds"] = logged(["lean","-j1","-R",source,"-o",work/(name+".olean"),src],
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
    parser.add_argument("--exterior", action="store_true", help="Replay the four I163 exterior headlines.")
    args = parser.parse_args()
    replay(args.kit,args.output,args.exterior)
