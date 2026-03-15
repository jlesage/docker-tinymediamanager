# Docker container for tinyMediaManager
[![Release](https://img.shields.io/github/release/jlesage/docker-tinymediamanager.svg?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-tinymediamanager/releases/latest)
[![Docker Image Size](https://img.shields.io/docker/image-size/jlesage/tinymediamanager/latest?logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/tinymediamanager/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/jlesage/tinymediamanager?label=Pulls&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/tinymediamanager)
[![Docker Stars](https://img.shields.io/docker/stars/jlesage/tinymediamanager?label=Stars&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/tinymediamanager)
[![Build Status](https://img.shields.io/github/actions/workflow/status/jlesage/docker-tinymediamanager/build-image.yml?logo=github&branch=master&style=for-the-badge)](https://github.com/jlesage/docker-tinymediamanager/actions/workflows/build-image.yml)
[![Source](https://img.shields.io/badge/Source-GitHub-blue?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-tinymediamanager)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg?style=for-the-badge)](https://paypal.me/JocelynLeSage)

This project provides a lightweight and secure Docker container for
[tinyMediaManager](https://www.tinymediamanager.org).

Access the application's full graphical interface directly from any modern web
browser - no downloads, installs, or setup required on the client side - or
connect with any VNC client.

The web interface also offers audio playback, seamless clipboard sharing, an
integrated file manager and terminal for accessing the container's files and
shell, desktop notifications, and more.

> This Docker container is entirely unofficial and not made by the creators of
> tinyMediaManager.

---

[![tinyMediaManager logo](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/tinymediamanager-icon.png&w=110)](https://www.tinymediamanager.org)[![tinyMediaManager](https://images.placeholders.dev/?width=512&height=110&fontFamily=monospace&fontWeight=400&fontSize=52&text=tinyMediaManager&bgColor=rgba(0,0,0,0.0)&textColor=rgba(121,121,121,1))](https://www.tinymediamanager.org)

tinyMediaManager is a media management tool designed to provide metadata for
media centers like Kodi (formerly XBMC), Emby, Jellyfin, and Plex.

---

## Quick Start

**NOTE**:
    The Docker command provided in this quick start is an example, and parameters
    should be adjusted to suit your needs.

Launch the tinyMediaManager docker container with the following command:
```shell
docker run -d \
    --name=tinymediamanager \
    -p 5800:5800 \
    -v /docker/appdata/tinymediamanager:/config:rw \
    -v /home/user:/storage:rw \
    jlesage/tinymediamanager
```

Where:

  - `/docker/appdata/tinymediamanager`: Stores the application's configuration, state, logs, and any files requiring persistency.
  - `/home/user`: Contains files from the host that need to be accessible to the application.

Access the tinyMediaManager GUI by browsing to `http://your-host-ip:5800`.
Files from the host appear under the `/storage` folder in the container.

## Documentation

Full documentation is available at https://github.com/jlesage/docker-tinymediamanager.

## Support or Contact

Having troubles with the container or have questions? Please
[create a new issue](https://github.com/jlesage/docker-tinymediamanager/issues).

For other Dockerized applications, visit https://jlesage.github.io/docker-apps.
