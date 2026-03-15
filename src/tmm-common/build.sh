#!/bin/sh
#
# This script builds tinyMediaManager using the offical method. This produces
# both the amd64 and arm64 versions.
#

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() {
    echo ">>> $*"
}

TINYMEDIAMANAGER_VERSION="${1:-}"
TINYMEDIAMANAGER_URL="${2:-}"

if [ -z "$TINYMEDIAMANAGER_VERSION" ]; then
    log "ERROR: tinyMediaManager version missing."
    exit 1
fi

if [ -z "$TINYMEDIAMANAGER_URL" ]; then
    log "ERROR: tinyMediaManager URL missing."
    exit 1
fi

#
# Install required packages.
#
apk --no-cache add \
    bash \
    coreutils \
    git \
    patch \
    openjdk21-jdk \
    maven \

#
# Download sources.
#

log "Downloading tinyMediaManager package..."
git clone "$TINYMEDIAMANAGER_URL" /tmp/tinymediamanager
git -C /tmp/tinymediamanager checkout "tinyMediaManager-$TINYMEDIAMANAGER_VERSION"

#
# Compile tinyMediaManager.
#

log "Patching tinyMediaManager..."
PATCHES="
    default-settings.patch
    no-update.patch
    default-file-chooser-path.patch
    theme.patch
    hide-menu-items.patch
    browser-links.patch
    is-docker.patch
"

for patch in $PATCHES; do
    log "  Applying $patch..."
    patch -p1 -d /tmp/tinymediamanager < "$SCRIPT_DIR"/"$patch"
done

log "Compiling tinyMediaManager..."
(
    cd /tmp/tinymediamanager
    mvn -ntp -T 1C -P dist clean package
)

log "Generating version..."
echo "version=$TINYMEDIAMANAGER_VERSION" >> /tmp/tinymediamanager/dist/version
echo "human.version=$TINYMEDIAMANAGER_VERSION" >> /tmp/tinymediamanager/dist/version
echo "build=$(git -C /tmp/tinymediamanager rev-parse --short HEAD)" >> /tmp/tinymediamanager/dist/version
echo "date=$(date '+%Y-%m-%d %H\:%M')" >> /tmp/tinymediamanager/dist/version

log "Generating changelog.txt..."
(
    cd /tmp/tinymediamanager
    ./generate_changelog.sh
    cp -v changelog.txt /tmp/tinymediamanager/dist/
)
