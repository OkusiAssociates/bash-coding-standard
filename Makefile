# Makefile - Install BCS (Bash Coding Standard)
# BCS1212 compliant

PREFIX   ?= /usr/local
BINDIR   ?= $(PREFIX)/bin
MANDIR   ?= $(PREFIX)/share/man/man1
SHAREDIR ?= $(PREFIX)/share/yatti/BCS
COMPDIR  ?= /etc/bash_completion.d
DESTDIR  ?=

.PHONY: all install uninstall check test help

all: help

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 bcs $(DESTDIR)$(BINDIR)/bcs
	install -m 755 bcscheck $(DESTDIR)$(BINDIR)/bcscheck
	install -d $(DESTDIR)$(SHAREDIR)/data/templates
	install -m 644 data/BASH-CODING-STANDARD.md $(DESTDIR)$(SHAREDIR)/data/
	install -m 644 data/[0-9]*.md $(DESTDIR)$(SHAREDIR)/data/
	install -m 644 data/templates/*.sh.template $(DESTDIR)$(SHAREDIR)/data/templates/
	rsync -a --exclude='CLAUDE.md' --exclude='.claude/' docs/ $(DESTDIR)$(SHAREDIR)/docs/
	rsync -a benchmarks/ $(DESTDIR)$(SHAREDIR)/benchmarks/
	install -d $(DESTDIR)$(SHAREDIR)/examples
	find examples/ -maxdepth 1 -type f -exec install -m 755 {} $(DESTDIR)$(SHAREDIR)/examples/ \;
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 bcs.1 $(DESTDIR)$(MANDIR)/bcs.1
	install -m 644 docs/BCS-bash.1 $(DESTDIR)$(MANDIR)/BCS-bash.1
	ln -sfn BCS-bash.1 $(DESTDIR)$(MANDIR)/bcs-bash.1
	@if [ -d $(DESTDIR)$(COMPDIR) ]; then \
	  install -m 644 bcs.bash_completion $(DESTDIR)$(COMPDIR)/bcs; \
	fi
	@if [ -d $(DESTDIR)$(PREFIX)/share/yatti/bash-coding-standard ] \
	    && [ ! -L $(DESTDIR)$(PREFIX)/share/yatti/bash-coding-standard ]; then \
	  rm -rf $(DESTDIR)$(PREFIX)/share/yatti/bash-coding-standard; \
	fi
	@ln -sfn BCS $(DESTDIR)$(PREFIX)/share/yatti/bash-coding-standard 2>/dev/null || true
	@if [ -z "$(DESTDIR)" ]; then $(MAKE) --no-print-directory check; fi

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/bcs
	rm -f $(DESTDIR)$(BINDIR)/bcscheck
	rm -f $(DESTDIR)$(MANDIR)/bcs.1
	rm -f $(DESTDIR)$(MANDIR)/BCS-bash.1
	rm -f $(DESTDIR)$(MANDIR)/bcs-bash.1
	rm -f $(DESTDIR)$(COMPDIR)/bcs
	rm -rf $(DESTDIR)$(SHAREDIR)
	rm -f $(DESTDIR)$(PREFIX)/share/yatti/bash-coding-standard

check:
	@command -v bcs >/dev/null 2>&1 \
	  && echo 'bcs: OK' \
	  || echo 'bcs: NOT FOUND (check PATH)'
	@command -v bcscheck >/dev/null 2>&1 \
	  && echo 'bcscheck: OK' \
	  || echo 'bcscheck: NOT FOUND (check PATH)'

test:
	./tests/run-all-tests.sh

help:
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@echo '  install     Install to $(PREFIX)'
	@echo '  uninstall   Remove installed files'
	@echo '  check       Verify installation'
	@echo '  test        Run test suite'
	@echo '  help        Show this message'
	@echo ''
	@echo 'Install from GitHub:'
	@echo '  git clone https://github.com/Open-Technology-Foundation/BCS.git'
	@echo '  cd BCS && sudo make install'
