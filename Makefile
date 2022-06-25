CFLAGS  += -std=c99 -fPIC -Wall -Wextra -Wno-unused-result -Iinclude
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
DESTDIR     ?= ~/.local/lib/deadbeef

plugin: $(PLUGIN_PATH)

$(PLUGIN_PATH): $(SOURCES)
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $(PLUGIN_PATH) $(SOURCES)

pkg: $(PLUGIN_PATH) LICENSE scripts/build-pkg.sh
	scripts/build-pkg.sh

clean:
	rm -f $(PLUGIN_PATH)
	scripts/build-pkg.sh --clean

install: $(PLUGIN_PATH)
	mkdir -p $(DESTDIR)
	cp -t $(DESTDIR) $(PLUGIN_PATH)

uninstall:
	rm $(DESTDIR)/$(PLUGIN_FILE)

.PHONY: plugin pkg clean install uninstall
