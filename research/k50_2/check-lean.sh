#!/bin/sh
# Rebuild the five modules against the checkout's kit, then show the axioms of the headline results.
set -eu
src=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
cd "$src/../../Rule30PrizeKit/lean"
build=$(mktemp -d)
trap 'rm -rf -- "$build"' EXIT
lake build Ruliology.CellularAutomata.Rule30EventReturns \
  Ruliology.CellularAutomata.Rule30GateTrapWords \
  Ruliology.CellularAutomata.Rule30Certificates.PeriodTwoWidth13
lake env sh -eu -c '
  src=$1
  build=$2
  export LEAN_PATH="$build:${LEAN_PATH:-}"
  for mod in Rule30EventGate Rule30GE2Phase Rule30LocalEventParity Rule30EventKickExclusion Rule30EventInverse; do
    lean --root="$src" -o "$build/$mod.olean" "$src/$mod.lean"
  done
  cat > "$build/Audit.lean" <<END
import Rule30EventInverse
import Rule30EventKickExclusion
import Rule30GE2Phase
open Ruliology.CellularAutomata
#print axioms Rule30EventGate.word_iff_even_distance
#print axioms Rule30EventGate.trap_return_code
#print axioms Rule30EventInverse.gate_iff_markers
#print axioms Rule30LocalEventParity.hit_return_parity
#print axioms Rule30EventKickExclusion.no_long_twos_to_odd
#print axioms Rule30EventKickExclusion.driven_no_long_twos_to_odd
#print axioms Rule30EventKickExclusion.singleton_no_long_twos_to_odd
#print axioms Rule30GE2Phase.exact_returns
#print axioms Rule30GE2Phase.four_events_both_phases
#print axioms Rule30GE2Phase.both_phases_unbounded
END
  lean "$build/Audit.lean"
' sh "$src" "$build"
