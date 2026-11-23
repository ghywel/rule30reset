"""Generate kernel proof shards and the theorem assembling the 65,536 starting windows.

The runner binds every successful checkpoint to the compiler, the imported object
closure, the generated source, and the resulting objects.
"""

import argparse
import concurrent.futures
import hashlib
import json
import os
import subprocess
import time
from functools import cache
from pathlib import Path

from make_observer_planes import build


def sha(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def artifacts(target):
    # Lean 4.35 can split a module over public, server and private object parts.
    parts = [target, Path(str(target) + ".server"), Path(str(target) + ".private")]
    return {path.name: sha(path) for path in parts if path.is_file()}


def inputs_for_pages(env, output):
    version = subprocess.check_output(["lean", "--version"], env=env, text=True).strip()
    query = """import Lean
open Lean
#eval do
  let env ← importModules #[{module := `WheelObserverScan}] {}
  for name in env.allImportedModuleNames do
    IO.println ((toJson (name.toString, (← findOLean name).toString)).compress)
"""
    paths = subprocess.run(
        ["lean", "-j1", "--stdin"],
        env=env,
        input=query,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=True,
    ).stdout.splitlines()
    modules = dict(json.loads(line) for line in paths)
    if not {"WheelObserverScan", "WheelObserverPlanes", "WheelObserverTransport"} <= modules.keys():
        raise ValueError("Incomplete Lean dependency inventory")
    closure = {name: artifacts(Path(path)) for name, path in modules.items()}
    if any(not parts for parts in closure.values()):
        raise FileNotFoundError("A dependency disappeared during the cache audit")
    sources = {}
    for name in (
        "WheelObserverPlanes",
        "WheelObserverCheck",
        "WheelObserverScan",
        "WheelObserverTransport",
        "WheelGateObserver",
    ):
        src = (
            output / (name + ".lean")
            if name == "WheelObserverPlanes"
            else Path(__file__).with_name(name + ".lean")
        )
        sources[name] = sha(src)
    return {"compiler": version, "imports": digest(closure), "sources": digest(sources)}


def compile_page(output, env, context, job):
    name, weight = job
    source = output / (name + ".lean")
    target = output / (name + ".olean")
    receipt = output / (name + ".ok.json")
    inputs = dict(context, source=sha(source))
    if target.is_file() and receipt.is_file():
        try:
            old = json.loads(receipt.read_bytes())
        except (ValueError, UnicodeError):
            old = {}
        if isinstance(old, dict) and old.get("inputs") == inputs and old.get("objects") == artifacts(target):
            return digest([inputs, old["objects"]])
    receipt.unlink(missing_ok=True)
    start = time.monotonic()
    with (output / (name + ".log")).open("w") as stream:
        subprocess.run(
            ["lean", "-j1", "-R", str(output), "-o", str(target), str(source)],
            env=env,
            stdout=stream,
            stderr=subprocess.STDOUT,
            check=True,
        )
    objects = artifacts(target)
    if target.name not in objects:
        raise FileNotFoundError(target)
    if sha(source) != inputs["source"]:
        raise RuntimeError(f"{source} changed while Lean was checking it")
    result = {
        "name": name,
        "weight": weight,
        "seconds": round(time.monotonic() - start, 3),
        "inputs": inputs,
        "objects": objects,
    }
    staged = receipt.with_suffix(".tmp")
    staged.write_bytes((json.dumps(result) + "\n").encode())
    staged.replace(receipt)
    return digest([inputs, objects])


def generate(output, page, cost):
    name = f"WheelObserverScan{page:03d}"
    lines = [
        "module",
        "public import WheelObserverScan",
        "@[expose] public section",
        "namespace Ruliology.CellularAutomata.WheelObserverCheck",
        "open WheelObserverPlanes WheelObserverTransport",
        "set_option maxHeartbeats 0",
        "set_option maxRecDepth 1000000",
    ]

    def visit(w, k):
        id = f"t_{w}_{k}"
        p = f"private theorem {id} : tree {30 - w} {w} {k} = true := "
        if cost(w, k) <= 128:
            lines.append(p + "by decide +kernel")
        else:
            l = visit(w + 1, k)
            r = visit(w + 1, k + (1 << w))
            lines.append(p + f"children {29 - w} {w} {k} (by decide +kernel) {l} {r}")
        return id

    def group(n, k):
        id = f"r_{n}_{k}" if n < 8 else f"pages{page:03d}"
        p = ("private " if n < 8 else "") + f"theorem {id} : roots {n} {k} = true := "
        mass = sum(cost(16, v) for v in range(k, k + (1 << n)))
        if mass <= 128:
            lines.append(p + "by decide +kernel")
        elif n == 0:
            root = visit(16, k)
            lines.append(p + f"root0 {k} {root}")
        else:
            l = group(n - 1, k)
            r = group(n - 1, k + (1 << (n - 1)))
            lines.append(p + f"roots_join {n - 1} {k} {l} {r}")
        return id

    group(8, page * 256)
    lines.append("end Ruliology.CellularAutomata.WheelObserverCheck")
    (output / f"{name}.lean").write_bytes(("\n".join(lines) + "\n").encode())
    return name, sum(cost(16, k) for k in range(256 * page, 256 * (page + 1)))


def assemble(output):
    source = ["module"] + [f"public import WheelObserverScan{p:03d}" for p in range(256)]
    source += ["@[expose] public section", "namespace Ruliology.CellularAutomata.WheelObserverCheck"]

    def pair(n, k):
        if n == 8:
            return f"pages{k // 256:03d}"
        low = pair(n - 1, k)
        high = pair(n - 1, k + 2 ** (n - 1))
        name = f"join{n}_{k}"
        source.append(f"private theorem {name} : roots {n} {k} = true := roots_join {n - 1} {k} {low} {high}")
        return name

    name = pair(16, 0)
    source += [
        "theorem top_pass (u : Nat) (hu : u < 65536) : top u = true := by",
        f"  simpa using top_of_roots {name} hu",
        "end Ruliology.CellularAutomata.WheelObserverCheck",
    ]
    (output / "WheelObserverAllPages.lean").write_bytes(("\n".join(source) + "\n").encode())


def main(args):
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    active = {w: set(map(int, keys[labels[:, 1] != 0])) for w, keys, labels in build(args.kit)}

    @cache
    def cost(w, k):
        if w == 30 or k not in active[w]:
            return 1
        return 1 + cost(w + 1, k) + cost(w + 1, k + 2**w)

    jobs = [generate(output, k, cost) for k in range(256)]
    assemble(output)
    if args.generate_only:
        return
    env = dict(
        os.environ,
        LEAN_PATH=os.pathsep.join(
            map(str, (output, args.dependencies.resolve(), args.kit.resolve() / "lean/.lake/build/lib/lean"))
        ),
    )

    context = inputs_for_pages(env, output)
    jobs.sort(key=lambda job: -job[1])
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        page_keys = list(pool.map(lambda job: compile_page(output, env, context, job), jobs))
    by_name = {name: key for (name, _), key in zip(jobs, page_keys, strict=True)}
    if context != inputs_for_pages(env, output):
        raise RuntimeError(
            "The compiler or imported modules changed during the page build; rerun with the new inputs"
        )
    compile_page(output, env, dict(context, pages=digest(by_name)), ("WheelObserverAllPages", 0))


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit", type=Path)
    p.add_argument("output", type=Path)
    p.add_argument(
        "dependencies",
        type=Path,
        help="Directory containing WheelObserverTransport and its research imports.",
    )
    p.add_argument("--generate-only", action="store_true")
    p.add_argument("--jobs", type=int, default=4)
    main(p.parse_args())
