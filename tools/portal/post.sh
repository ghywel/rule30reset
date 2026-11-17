#!/bin/sh
# post.sh PACKETDIR [dry|post]: send a built submission (METHOD section 12, step 6). Dry run by default.
# Pins every file by SHA-256 (PACKETDIR/pins.json), refuses if the verifier's kit commit has moved, and sends
# only with "post", which is run once, after the owner's word.
set -e
[ -n "$1" ] || { echo "usage: post.sh PACKETDIR [dry|post]"; exit 2; }
exec wolframscript -file "$(dirname "$0")/post.wl" "$1" "${2:-dry}"
