#!/usr/bin/env python3
"""claudeCloud_m9_core_pair.py: pull M9 (ledger K56). Where does the law "(5, 1) never starts 12 or more samples after
entry" live? claudeM5_m9_core.py, imported unchanged, run on a word and delay given on the command line: the minimal
columns, samples and cells of the unsatisfiable instance, and whether the trap is needed.

    python3 claudeCloud_m9_core_pair.py KITFILE OUTDIR NAME GAPWORD P
"""
import importlib.util, pathlib, sys

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('m9core', HERE / 'claudeM5_m9_core.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)

if __name__ == '__main__':
    kit, outdir, name, word, P = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], int(sys.argv[5])
    C.CASES[name] = (word, P)
    C.run(kit, outdir, name)
