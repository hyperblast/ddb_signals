CFLAGS  += -std=c99 -fPIC -Wall
LDFLAGS += -Wl,--no-undefined

SOURCES     := src/signals.c
PLUGIN      := build/signals.so
DEPS_STAMP  := deps/.stamp
PKG_STAMP   := build/pkg/.stamp
DESTDIR     ?= ~/.local/lib/deadbeef

ifdef NO_DEPS
DEPS_TARGET :=
else
CFLAGS      += -Ideps
DEPS_TARGET := $(DEPS_STAMP)
endif

plugin: $(PLUGIN)

$(PLUGIN): $(SOURCES) $(DEPS_TARGET)
	mkdir -p build
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $(PLUGIN) $(SOURCES)

pkg: $(PKG_STAMP)

$(PKG_STAMP): $(PLUGIN) LICENSE scripts/build-pkg.sh
	scripts/build-pkg.sh

clean:
	rm -f $(PLUGIN)
	scripts/build-pkg.sh --clean

install: $(PLUGIN)
	install -D $(PLUGIN) $(DESTDIR)/$(PLUGIN)

uninstall:
	rm $(DESTDIR)/$(PLUGIN)

get-deps: $(DEPS_STAMP)

$(DEPS_STAMP): scripts/get-deps.sh
	scripts/get-deps.sh

clean-deps:
	scripts/get-deps.sh --clean

.PHONY: plugin pkg clean install uninstall get-deps clean-deps
