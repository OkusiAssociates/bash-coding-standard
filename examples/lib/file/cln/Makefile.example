PREFIX    ?= /usr/local
BINDIR    ?= $(PREFIX)/bin
MANDIR    ?= $(PREFIX)/share/man/man1
COMPDIR   ?= /etc/bash_completion.d
DESTDIR   ?=

.PHONY: all install uninstall check test help

all: help

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 cln $(DESTDIR)$(BINDIR)/cln
	install -d $(DESTDIR)$(MANDIR)
	install -m 0644 cln.1 $(DESTDIR)$(MANDIR)/cln.1
	install -d $(DESTDIR)$(COMPDIR)
	install -m 0644 cln.bash_completion $(DESTDIR)$(COMPDIR)/cln

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/cln
	rm -f $(DESTDIR)$(MANDIR)/cln.1
	rm -f $(DESTDIR)$(COMPDIR)/cln

check:
ifeq ($(DESTDIR),)
	@command -v cln >/dev/null && cln --version || echo 'cln not found in PATH'
endif

test:
	@shellcheck cln
	@bash tests/run-all-tests.sh

help:
	@echo 'Targets:'
	@echo '  install    Install cln, man page, and bash completion'
	@echo '  uninstall  Remove installed files'
	@echo '  check      Verify installation'
	@echo '  test       Run shellcheck and test suite'
	@echo '  help       Show this message (default)'
