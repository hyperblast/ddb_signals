CFLAGS  += -std=c99 -fPIC -Wall
LDFLAGS += -Wl,--no-undefined

SOURCES := signals.c
PLUGIN  := signals.so
DESTDIR ?= ~/.local/lib/deadbeef

ifdef NO_DEPS
DEPS_TARGET :=
else
CFLAGS      += -I.
DEPS_TARGET := .deps-stamp
endif

plugin: $(PLUGIN)

$(PLUGIN): $(SOURCES) $(DEPS_TARGET)
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $(PLUGIN) $(SOURCES)

pkg: $(PLUGIN)
	./build-pkg.sh

clean:
	rm -f $(PLUGIN)
	rm -f *.tar.gz

install: $(PLUGIN)
	install -D $(PLUGIN) $(DESTDIR)/$(PLUGIN)

uninstall:
	rm $(DESTDIR)/$(PLUGIN)

get-deps: .deps-stamp

.deps-stamp: get-deps.sh
	./get-deps.sh

clean-deps:
	rm -f .deps-stamp
	rm -rf deadbeef

.PHONY: plugin pkg clean install uninstall get-deps clean-deps
