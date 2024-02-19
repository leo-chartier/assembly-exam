#!/usr/bin/env bash
#######################################
# DOS BOX launcher for Mac.
# (DosBox must be brewed first)
#######################################
set -Cue

#######################################
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN_DIR="${ROOT_DIR}/bin"
DOSBOX_BIN="$(which dosbox)"
#DOSBOX_BIN="/opt/homebrew/bin/dosbox"

#######################################
# Launch DosBox and,
# mount the bin directory as C:,
# change drive to C:
# and launch "EXAM.COM"
"$DOSBOX_BIN" -c "MOUNT c $BIN_DIR" -c "C:" -c "exam"
