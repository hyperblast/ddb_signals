# Signals support plugin for DeaDBeeF player
This plugin adds support for unix signals to DeaDBeeF player.

[![License](https://img.shields.io/github/license/hyperblast/ddb-signals.svg)](LICENSE)
[![Build Status](https://travis-ci.org/hyperblast/ddb-signals.svg?branch=master)](https://travis-ci.org/hyperblast/ddb-signals)
[![Development builds](https://img.shields.io/badge/development-builds-orange.svg)](https://hyperblast.org/ddb_signals/builds)

### Features
- Clean shutdown on `SIGTERM` and `SIGINT`
- Restart player on `SIGHUP`

### How to build
`make` will build the plugin file. Make sure you have build tools installed.

### How to install
`make install` will copy compiled plugin file to `$HOME/.local/lib/deadbeef`.

### How to use
There are no configuration options. Once plugin is activated it will intercept signals and initiate correct player termination.
