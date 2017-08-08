CFLAGS  += -std=c99 -fPIC -Wall -I.
LDFLAGS += -Wl,--no-undefined

SOURCES := signals.c
PLUGIN  := signals.so
DESTDIR ?= ~/.local/lib/deadbeef

$(PLUGIN): $(SOURCES)
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $(PLUGIN) $(SOURCES)

clean:
	rm $(PLUGIN)

install: $(PLUGIN)
	install -D $(PLUGIN) $(DESTDIR)/$(PLUGIN)

uninstall:
	rm $(DESTDIR)/$(PLUGIN)

get-deps: .deps-stamp

.deps-stamp: get-deps.sh
	./get-deps.sh

clean-deps:
	rm -rf deadbeef

.PHONY: clean install uninstall get-deps clean-deps
