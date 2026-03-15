#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export CC=xx-clang
export CXX=xx-clang++

log() {
    echo ">>> $*"
}

FLATLAF_VERSION="$1"
FLATLAF_URL="$2"

if [ -z "$FLATLAF_VERSION" ]; then
    log "ERROR: FlatLaf version missing."
    exit 1
fi

if [ -z "$FLATLAF_URL" ]; then
    log "ERROR: FlatLaf URL missing."
    exit 1
fi

#
# Install required packages.
#
apk --no-cache add \
    curl \
    build-base \
    clang \

xx-apk --no-cache --no-scripts add \
    musl-dev \
    gcc \
    g++ \
    gtk+3.0-dev \
    openjdk21 \

#
# Download sources.
#

log "Downloading FlatLaf package..."
mkdir /tmp/flatlaf
curl -# -L -f ${FLATLAF_URL} | tar xz --strip 1 -C /tmp/flatlaf

#
# Compile FlatLaf.
#

library_name="libflatlaf-linux-arm64.so"
library_name="libflatlaf-linux-$(xx-info march).so"
library_name="flatlaf-${FLATLAF_VERSION}-linux-$(xx-info march).so"

log "Compiling FlatLaf..."
$CXX \
    -shared \
    -O3 \
    -fPIC \
    -fvisibility=hidden \
    /tmp/flatlaf/flatlaf-natives/flatlaf-natives-linux/src/main/cpp/ApiVersion.cpp \
    /tmp/flatlaf/flatlaf-natives/flatlaf-natives-linux/src/main/cpp/GtkFileChooser.cpp \
    /tmp/flatlaf/flatlaf-natives/flatlaf-natives-linux/src/main/cpp/GtkMessageDialog.cpp \
    /tmp/flatlaf/flatlaf-natives/flatlaf-natives-linux/src/main/cpp/JNIUtils.cpp \
    /tmp/flatlaf/flatlaf-natives/flatlaf-natives-linux/src/main/cpp/X11WmUtils.cpp \
    -I/tmp/flatlaf/flatlaf-natives/flatlaf-natives-linux/src/main/headers \
    -I$(xx-info sysroot)usr/lib/jvm/java-21-openjdk/include \
    -I$(xx-info sysroot)usr/lib/jvm/java-21-openjdk/include/linux \
    -I$(xx-info sysroot)usr/include/gtk-3.0 \
    -I$(xx-info sysroot)usr/include/glib-2.0 \
    -I$(xx-info sysroot)usr/lib/glib-2.0/include/ \
    -I$(xx-info sysroot)usr/include/pango-1.0 \
    -I$(xx-info sysroot)usr/include/harfbuzz \
    -I$(xx-info sysroot)usr/include/cairo \
    -I$(xx-info sysroot)usr/include/gdk-pixbuf-2.0 \
    -I$(xx-info sysroot)usr/include/atk-1.0 \
    -L$(xx-info sysroot)usr/lib/jvm/java-21-openjdk/lib \
    -lstdc++ \
    -ljawt \
    -lgtk-3 \
    -Wl,-rpath,/usr/lib:/usr/lib/jvm/java-21-openjdk/lib:/usr/lib/jvm/java-21-openjdk/lib/server \
    -Wl,--strip-all -Wl,--as-needed \
    -o /tmp/flatlaf/$library_name

log "Installing FlatLaf..."
mkdir /tmp/flatlaf-install
cp -v /tmp/flatlaf/$library_name /tmp/flatlaf-install/
curl -# -L -f -o /tmp/flatlaf-install/flatlaf-${FLATLAF_VERSION}-no-natives.jar \
    https://repo1.maven.org/maven2/com/formdev/flatlaf/${FLATLAF_VERSION}/flatlaf-${FLATLAF_VERSION}-no-natives.jar
