#!/bin/sh
#
# This script produce a build of tinyMediaManager specific to a platform.
#

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() {
    echo ">>> $*"
}

TINYMEDIAMANAGER_VERSION="${1:-}"

if [ -z "$TINYMEDIAMANAGER_VERSION" ]; then
    log "ERROR: tinyMediaManager version missing."
    exit 1
fi

#
# Compile tinyMediaManager.
#

DIST_FILE="/tmp/dist/tinyMediaManager-${TINYMEDIAMANAGER_VERSION}-linux-$(xx-info arch).tar.xz"

if [ ! -f "$DIST_FILE" ]; then
    log "ERROR: $DIST_FILE not found."
    exit 1
fi

# Extract the distribution file.
mkdir /tmp/tinymediamanager-install
tar xf "$DIST_FILE" --strip 1 -C /tmp/tinymediamanager-install

# Copy version file.
cp -v /tmp/dist/version /tmp/tinymediamanager-install/

# Remove unneeded files and native libraries.
(
    TO_DELETE="
        /tmp/tinymediamanager-install/jre
        /tmp/tinymediamanager-install/lib/jna.jar
        /tmp/tinymediamanager-install/lib/jna-platform.jar
        /tmp/tinymediamanager-install/tinyMediaManager
        /tmp/tinymediamanager-install/tinyMediaManager-arm
        /tmp/tinymediamanager-install/native/linux/libtinyfiledialogs.so
    "

    for f in $TO_DELETE; do
        log "Removing $f..."
        rm -rf "$f"
    done
)

# Remove JAR containing native libraries.
for f in $(find /tmp/tinymediamanager-install -type f -name "*.jar"); do
    log "Checking $f"
    if unzip -l "$f" | grep -q -E "\.so$"; then
        log "Found native library in $f"
        log "Removing $f..."
        rm "$f"
    fi
done

log "Installed files:"
find /tmp/tinymediamanager-install -type f
