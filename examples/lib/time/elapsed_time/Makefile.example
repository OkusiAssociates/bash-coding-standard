# Makefile - Install elapsed_time
# BCS1212 compliant

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
COMPDIR ?= /etc/bash_completion.d
DESTDIR ?=

USER_PREFIX  ?= $(HOME)/.local
USER_BINDIR  ?= $(USER_PREFIX)/bin
USER_COMPDIR ?= $(HOME)/.local/share/bash-completion/completions

.PHONY: all install install-user uninstall uninstall-user check help

all: help

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 elapsed_time $(DESTDIR)$(BINDIR)/elapsed_time
	@if [ -d $(DESTDIR)$(COMPDIR) ]; then \
	  install -m 644 .bash_completion $(DESTDIR)$(COMPDIR)/elapsed_time; \
	fi
	@if [ -z "$(DESTDIR)" ]; then $(MAKE) --no-print-directory check; fi

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/elapsed_time
	rm -f $(DESTDIR)$(COMPDIR)/elapsed_time

install-user:
	install -d $(USER_BINDIR)
	install -m 755 elapsed_time $(USER_BINDIR)/elapsed_time
	@if [ -d $(USER_COMPDIR) ]; then \
	  install -m 644 .bash_completion $(USER_COMPDIR)/elapsed_time; \
	fi

uninstall-user:
	rm -f $(USER_BINDIR)/elapsed_time
	rm -f $(USER_COMPDIR)/elapsed_time

check:
	@command -v elapsed_time >/dev/null 2>&1 \
	  && echo 'elapsed_time: OK' \
	  || echo 'elapsed_time: NOT FOUND (check PATH)'

help:
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@echo '  install        Install to $(PREFIX) (requires sudo)'
	@echo '  install-user   Install to ~/.local/bin'
	@echo '  uninstall      Remove system install'
	@echo '  uninstall-user Remove user install'
	@echo '  check          Verify installation'
	@echo '  help           Show this message'
	@echo ''
	@echo 'Install from GitHub:'
	@echo '  git clone https://github.com/Open-Technology-Foundation/elapsed_time.git'
	@echo '  cd elapsed_time && sudo make install'
