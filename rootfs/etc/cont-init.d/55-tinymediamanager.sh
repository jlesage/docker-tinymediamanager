#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

TMM_DATA_DIR=/config/tmm/data

mkdir -p "$TMM_DATA_DIR"

# Copy default files if needed.
[ -f "$TMM_DATA_DIR"/tmm.prop ] || cp -v /defaults/tmm.prop "$TMM_DATA_DIR"/

# vim:ft=sh:ts=4:sw=4:et:sts=4
