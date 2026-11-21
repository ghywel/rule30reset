#!/bin/sh
# Build the four local modules in a temporary directory against the current kit.
set -eu
src=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
cd "$src/../../Rule30PrizeKit/lean"
build=$(mktemp -d)
trap 'rm -rf -- "$build"' EXIT
lake build Ruliology.CellularAutomata.Rule30SidewaysLocks \
  Ruliology.CellularAutomata.Rule30PlantedSurvivor
lake env sh -eu -c '
  src=$1
  build=$2
  export LEAN_PATH="$build:${LEAN_PATH:-}"
  for mod in Rule30CutSplice Rule30CutAnchors Rule30CutDichotomy gptM5_sample; do
    lean --root="$src" -o "$build/$mod.olean" "$src/$mod.lean"
  done
  cat > "$build/Audit.lean" <<END
import Rule30CutDichotomy
import gptM5_sample
open Ruliology.CellularAutomata
#print axioms Rule30CutDichotomy.cut_dichotomy
#print axioms Rule30CutDichotomy.sharp_support_thresholds
#print axioms Rule30CutDichotomy.matches_iff
#print axioms K50Sample.periodic_for_all_outstanding
END
  lean "$build/Audit.lean"
' sh "$src" "$build"
