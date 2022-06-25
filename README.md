# Signals support plugin for DeaDBeeF player
This plugin adds support for unix signals to [DeaDBeeF player](https://deadbeef.sourceforge.io/).

[![Build Status](https://github.com/hyperblast/ddb_signals/actions/workflows/build.yml/badge.svg)](https://github.com/hyperblast/ddb_signals/actions/workflows/build.yml)

### Features
- Clean shutdown on `SIGTERM` and `SIGINT`
- Restart player on `SIGHUP`

### How to install prebuilt plugin
- Download binary package for your CPU architecture from [releases section](../../releases)
- Extract all files to `$HOME/.local/lib/deadbeef`
- Restart DeaDBeeF

### How to install from source
- Make sure `gcc` (or `clang`) and `make` are installed
- Clone repository to the destination folder of your choice
- Run `make install` in the source directory
- Restart DeaDBeeF

### How to use
There are no configuration options. Once plugin is activated it will intercept signals and initiate correct player termination.
