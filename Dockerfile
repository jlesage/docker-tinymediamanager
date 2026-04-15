#
# tinymediamanager Dockerfile
#
# https://github.com/jlesage/docker-tinymediamanager
#

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG TINYMEDIAMANAGER_VERSION=5.2.11
ARG MEDIAINFOLIB_VERSION=26.01
ARG ZENLIB_VERSION=0.4.41
ARG FLATLAF_VERSION=3.7
ARG TINYFILEDIALOGS_VERSION=current

# Define software download URLs.
ARG TINYMEDIAMANAGER_URL=https://gitlab.com/tinyMediaManager/tinyMediaManager.git
ARG MEDIAINFOLIB_URL=https://mediaarea.net/download/source/libmediainfo/${MEDIAINFOLIB_VERSION}/libmediainfo_${MEDIAINFOLIB_VERSION}.tar.xz
ARG ZENLIB_URL=https://mediaarea.net/download/source/libzen/${ZENLIB_VERSION}/libzen_${ZENLIB_VERSION}.tar.gz
ARG FLATLAF_URL=https://github.com/JFormDesigner/FlatLaf/archive/refs/tags/${FLATLAF_VERSION}.tar.gz
ARG TINYFILEDIALOGS_URL=https://downloads.sourceforge.net/project/tinyfiledialogs/tinyfiledialogs-${TINYFILEDIALOGS_VERSION}.zip

# Get Dockerfile cross-compilation helpers.
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

# Build tintMediaManager.
FROM --platform=$BUILDPLATFORM alpine:3.23 AS tmm-common
ARG TINYMEDIAMANAGER_VERSION
ARG TINYMEDIAMANAGER_URL
COPY src/tmm-common /build
RUN /build/build.sh "$TINYMEDIAMANAGER_VERSION" "$TINYMEDIAMANAGER_URL"

FROM --platform=$BUILDPLATFORM alpine:3.23 AS tmm
ARG TARGETARCH
ARG TINYMEDIAMANAGER_VERSION
COPY --from=xx / /
COPY --from=tmm-common /tmp/tinymediamanager/dist /tmp/dist
COPY src/tmm /build
RUN /build/build.sh "$TINYMEDIAMANAGER_VERSION"

# Build MediaInfoLib.
FROM --platform=$BUILDPLATFORM alpine:3.23 AS libmediainfo
ARG TARGETPLATFORM
ARG MEDIAINFOLIB_URL
ARG ZENLIB_URL
COPY --from=xx / /
COPY src/libmediainfo /build
RUN /build/build.sh "$MEDIAINFOLIB_URL" "$ZENLIB_URL"
RUN xx-verify \
    /tmp/libmediainfo-install/usr/lib/libmediainfo.so \
    /tmp/libmediainfo-install/usr/lib/libzen.so

# Build FlatLaf.
FROM --platform=$BUILDPLATFORM alpine:3.23 AS flatlaf
ARG TARGETPLATFORM
ARG FLATLAF_VERSION
ARG FLATLAF_URL
COPY --from=xx / /
COPY src/flatlaf /build
RUN /build/build.sh "$FLATLAF_VERSION" "$FLATLAF_URL"
RUN xx-verify  /tmp/flatlaf-install/*.so

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.23-v4.11.3

ARG DOCKER_IMAGE_VERSION

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN \
    add-pkg \
        openjdk21-jre \
        java-jna \
        # For FlatLaf (file chooser).
        # Note that we use FlatLaf as file chooser instead of tinyfiledialogs.
        gtk+3.0 \
        adwaita-icon-theme \
        # For libmediainfo.
        tinyxml2 \
        # We need a font.
        font-dejavu \
        # To parse config files.
        jq \
        yq \
        moreutils \
        # External tools.
        deno \
        ffmpeg \
        ffplay \
        yt-dlp \
        && \
    true

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/tinymediamanager-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=tmm /tmp/tinymediamanager-install /opt/tinyMediaManager
COPY --from=libmediainfo /tmp/libmediainfo-install/usr/lib /usr/lib
COPY --from=flatlaf /tmp/flatlaf-install /opt/tinyMediaManager/lib

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "tinyMediaManager" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Define mountable directories.
VOLUME ["/storage"]

# Metadata.
LABEL \
      org.label-schema.name="tinymediamanager" \
      org.label-schema.description="Docker container for tinyMediaManager" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-tinymediamanager" \
      org.label-schema.schema-version="1.0"
