CFLAGS  += -std=c99 -fPIC -Wall -Wextra
LDFLAGS += -Wl,--no-undefined

ifdef RELEASE
CONFIG      := release
CFLAGS      += -O2
else
CONFIG      := debug
CFLAGS      += -O0 -g3
endif

ifdef WERROR
CFLAGS      += -Werror
endif

SOURCES     := src/signals.c
BUILD_DIR   := build/$(CONFIG)/plugin
PLUGIN_FILE := signals.so
PLUGIN_PATH := $(BUILD_DIR)/$(PLUGIN_FILE)
DEPS_STAMP  := deps/.stamp
PKG_STAMP   := build/pkg/.stamp
DESTDIR     ?= ~/.local/lib/deadbeef

ifdef NO_DEPS
DEPS_TARGET :=
else
CFLAGS      += -Ideps
DEPS_TARGET := $(DEPS_STAMP)
endif

plugin: $(PLUGIN_PATH)

$(PLUGIN_PATH): $(SOURCES) $(DEPS_TARGET)
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $(PLUGIN_PATH) $(SOURCES)

pkg: $(PKG_STAMP)

$(PKG_STAMP): $(PLUGIN_PATH) LICENSE scripts/build-pkg.sh
	scripts/build-pkg.sh

clean:
	rm -f $(PLUGIN_PATH)
	scripts/build-pkg.sh --clean

install: $(PLUGIN_PATH)
	mkdir -p $(DESTDIR)
	cp -t $(DESTDIR) $(PLUGIN_PATH)

uninstall:
	rm $(DESTDIR)/$(PLUGIN_FILE)

get-deps: $(DEPS_STAMP)

$(DEPS_STAMP): scripts/get-deps.sh
	scripts/get-deps.sh

clean-deps:
	scripts/get-deps.sh --clean

.PHONY: plugin pkg clean install uninstall get-deps clean-deps
