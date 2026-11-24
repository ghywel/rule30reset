#!/bin/sh
# Rebuild the event and finite-left modules, then audit their headline results.
set -eu
src=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
cd "$src/../../Rule30PrizeKit/lean"
build=$(mktemp -d)
trap 'rm -rf -- "$build"' EXIT
lake build Ruliology.CellularAutomata.Rule30EventReturns \
  Ruliology.CellularAutomata.Rule30GateTrapWords \
  Ruliology.CellularAutomata.Rule30PeriodTwoWidth13 \
  Ruliology.CellularAutomata.Rule30PeriodTwoOnset
lake env sh -eu -c '
  src=$1
  build=$2
  case $(uname -s) in
    MINGW*|MSYS*) LEAN_PATH="$(cygpath -w "$build");${LEAN_PATH:-}" ;;
    *) LEAN_PATH="$build:${LEAN_PATH:-}" ;;
  esac
  export LEAN_PATH
  for mod in Rule30EventGate Rule30GE2Phase Rule30LocalEventParity Rule30EventKickExclusion Rule30EventInverse Rule30EventLeft Rule30StripLeft; do
    lean --root="$src" -o "$build/$mod.olean" "$src/$mod.lean"
  done
  cat > "$build/Audit.lean" <<END
import Rule30EventInverse
import Rule30EventKickExclusion
import Rule30GE2Phase
import Rule30StripLeft
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
#print axioms Rule30EventLeft.early_residue_27
#print axioms Rule30StripLeft.lang_all_widths
#print axioms Rule30StripLeft.no_period_two_of_strip_mass
#print axioms Rule30StripLeft.kit_classes
#print axioms Rule30StripLeft.exact_deletions
#print axioms Rule30StripLeft.no_short_after_black
#print axioms Rule30StripLeft.every_three_five_schedule
END
  lean "$build/Audit.lean"
' sh "$src" "$build"
