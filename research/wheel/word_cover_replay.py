"""Build the factor-cover proof and replay its headlines with the kit's stock checker."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
from time import monotonic


PIN = "f41bb494d64f120e0e6f07ab68d799a6018396cc"
NS = "Ruliology.CellularAutomata."
DEPS = ["WheelPureThreeExit", "WheelGateObserver", "WheelObserverLowerBound",
        "WheelObserverCleanup", "WheelObserverTransport"]
MODULES = ["word_cover_base", "word_cover_macro", "word_cover_fast", "word_cover_split", "word_cover_language",
           "word_cover_transport", "word_cover_claims", "word_cover_short", "word_cover_long",
    "word_cover_hard", "word_cover_nine", "word_cover_third", "word_cover_adaptive", "word_cover_verified"]
HEADLINES = {
    "word_cover_fast": ["fast_admit"], "word_cover_split": ["right_split"],
    "word_cover_language": ["clean_contains_marker", "clean_47_cases"],
    "word_cover_transport": ["marker_enters", "sound_of_markers"],
    "word_cover_claims": ["exceptional_clean", "exceptional_pair"],
    "word_cover_short": ["cut0", "cut1", "cut3", "cut6", "cut7", "cut9"],
    "word_cover_long": ["cut10", "cut11"], "word_cover_hard": ["cut13"], "word_cover_third": ["cut5"],
    "word_cover_nine": ["nine_cuts","sound_48"],
    "word_cover_adaptive": ["adaptive_by_52","adaptive_first_52","uniform_adaptive_delay_iff"],
    "word_cover_verified": ["ten_markers_force_entry", "only_clean_exterior_47",
                            "sound_47_except_one","adaptive_sound"],
}


def run(args):
    kit, work = args.kit.resolve(), args.output.resolve()
    src = Path(__file__).resolve().parent
    work.mkdir(exist_ok=True, parents=True)
    pin = subprocess.check_output(["git","rev-parse","HEAD"],cwd=kit,text=True).strip()
    if pin != PIN:
        raise ValueError(f"Expected kit {PIN}, found {pin}")
    lean = kit/"lean"
    libs = [work,*[p.resolve() for p in args.library],lean/".lake/build/lib/lean"]
    env = dict(os.environ,LEAN_PATH=os.pathsep.join(map(str,libs)))
    if not args.existing:
        kit_deps = ["Rule30Prize","Rule30DrivenPrefix","Rule30GateTrapWords","Rule30SidewaysLocks",
                    "Rule30PeriodTwoWidth13"]
        subprocess.run(["lake","build",*(NS+n for n in kit_deps)],cwd=lean,check=True)
    index = {}
    sequence = args.modules or DEPS+MODULES
    for name in sequence:
        source = src/(name+".lean")
        rec = dict(source_sha256=hashlib.sha256(source.read_bytes()).hexdigest())
        if not args.existing:
            start=monotonic()
            subprocess.run(["lean","-j1","-R",src,"-o",work/(name+".olean"),source],cwd=lean,env=env,check=True)
            rec["build_seconds"]=round(monotonic()-start,3)
        if name in HEADLINES:
            names=[NS+"WordCover."+h for h in HEADLINES[name]]
            flags=[arg for n in names for arg in ("--headline",n)]
            start=monotonic()
            raw=subprocess.check_output(["lean","--run",kit/"Check.lean",name,"--claim","partial",*flags],
                                        cwd=lean,env=env)
            report=json.loads(next(line for line in raw.splitlines() if line.startswith(b"{")))
            (work/(name+"-stock.json")).write_bytes((json.dumps(report,indent=2)+"\n").encode())
            if (report["verdict"]!="pass" or not report["importsStatements"] or
                not report["replay"]["ok"] or report["newAxioms"] or
                not all(d["standardAxioms"] for d in report["declared"]) or
                [h["name"] for h in report["headlines"] if h["ok"] and h["typeMatches"]]!=names):
                raise RuntimeError(f"Stock checker failed on {name}")
            rec.update(stock_seconds=round(monotonic()-start,3),constants=report["replay"]["constants"],
                       headlines=names,new_axioms=report["newAxioms"])
        index[name]=rec
        print(name, json.dumps(rec),flush=True)
    suffix = "-".join(sequence) if args.modules else "stock"
    receipt=work/("word_cover_"+suffix+".json")
    receipt.write_bytes((json.dumps(dict(kit=pin,modules=index),indent=2)+"\n").encode())


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__);p.add_argument("kit",type=Path);p.add_argument("output",type=Path)
    p.add_argument("--existing",action="store_true",help="Stock-check previously built modules.")
    p.add_argument("--modules",nargs="+",choices=DEPS+MODULES,help="Replay selected modules with existing imports.")
    p.add_argument("--library",type=Path,action="append",default=[],help="Additional directories of built imports.")
    run(p.parse_args())
