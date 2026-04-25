# SPDX-License-Identifier: GPL-3.0-or-later
# Makefile - Install BCS (Bash Coding Standard)
# BCS1212 compliant

PREFIX   ?= /usr/local
BINDIR   ?= $(PREFIX)/bin
MANDIR   ?= $(PREFIX)/share/man/man1
SHAREDIR ?= $(PREFIX)/share/yatti/BCS
COMPDIR  ?= /etc/bash_completion.d
DESTDIR  ?=

# Directory of this Makefile (trailing slash). Used to anchor all source
# paths so 'make install' works regardless of the invoking CWD and never
# picks up a like-named file from a parent directory.
srcdir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: all install uninstall check test help

all: help

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $(srcdir)bcs $(DESTDIR)$(BINDIR)/bcs
	install -m 755 $(srcdir)bcscheck $(DESTDIR)$(BINDIR)/bcscheck
	install -m 755 $(srcdir)bcsdisplay $(DESTDIR)$(BINDIR)/bcsdisplay
	install -m 755 $(srcdir)bcstemplate $(DESTDIR)$(BINDIR)/bcstemplate
	install -m 755 $(srcdir)bcscodes $(DESTDIR)$(BINDIR)/bcscodes
	install -m 755 $(srcdir)bcsgenerate $(DESTDIR)$(BINDIR)/bcsgenerate
	install -d $(DESTDIR)$(SHAREDIR)
	install -m 644 $(srcdir)LICENSE $(DESTDIR)$(SHAREDIR)/LICENSE
	install -m 644 $(srcdir)COPYING $(DESTDIR)$(SHAREDIR)/COPYING
	install -d $(DESTDIR)$(SHAREDIR)/data
	install -m 644 $(srcdir)data/LICENSE $(DESTDIR)$(SHAREDIR)/data/LICENSE
	install -m 644 $(srcdir)data/BASH-CODING-STANDARD.md $(DESTDIR)$(SHAREDIR)/data/
	install -m 644 $(srcdir)data/[0-9]*.md $(DESTDIR)$(SHAREDIR)/data/
	install -d $(DESTDIR)$(SHAREDIR)/examples/templates
	install -m 644 $(srcdir)examples/templates/*.sh.template $(DESTDIR)$(SHAREDIR)/examples/templates/
	install -d $(DESTDIR)$(SHAREDIR)/docs
	cp -a $(srcdir)docs/. $(DESTDIR)$(SHAREDIR)/docs/
	rm -f $(DESTDIR)$(SHAREDIR)/docs/CLAUDE.md
	rm -rf $(DESTDIR)$(SHAREDIR)/docs/.claude
	install -d $(DESTDIR)$(SHAREDIR)/benchmarks
	cp -a $(srcdir)benchmarks/. $(DESTDIR)$(SHAREDIR)/benchmarks/
	install -d $(DESTDIR)$(SHAREDIR)/examples
	find $(srcdir)examples/ -maxdepth 1 -type f -exec install -m 755 {} $(DESTDIR)$(SHAREDIR)/examples/ \;
	install -d $(DESTDIR)$(SHAREDIR)/examples/lib
	cd $(srcdir) && tar --exclude='mk-index*' --exclude='BASH-CODING-STANDARD.md' -cf - examples/lib | tar -xf - -C $(DESTDIR)$(SHAREDIR)/
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 $(srcdir)bcs.1 $(DESTDIR)$(MANDIR)/bcs.1
	install -m 644 $(srcdir)docs/BCS-bash.1 $(DESTDIR)$(MANDIR)/BCS-bash.1
	ln -sfn BCS-bash.1 $(DESTDIR)$(MANDIR)/bcs-bash.1
	@if [ -d $(DESTDIR)$(COMPDIR) ]; then \
	  install -m 644 $(srcdir)bcs.bash_completion $(DESTDIR)$(COMPDIR)/bcs; \
	  install -m 644 $(srcdir)bcscheck.bash_completion $(DESTDIR)$(COMPDIR)/bcscheck; \
	  install -m 644 $(srcdir)bcsdisplay.bash_completion $(DESTDIR)$(COMPDIR)/bcsdisplay; \
	  install -m 644 $(srcdir)bcstemplate.bash_completion $(DESTDIR)$(COMPDIR)/bcstemplate; \
	  install -m 644 $(srcdir)bcscodes.bash_completion $(DESTDIR)$(COMPDIR)/bcscodes; \
	  install -m 644 $(srcdir)bcsgenerate.bash_completion $(DESTDIR)$(COMPDIR)/bcsgenerate; \
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
	rm -f $(DESTDIR)$(BINDIR)/bcsdisplay
	rm -f $(DESTDIR)$(BINDIR)/bcstemplate
	rm -f $(DESTDIR)$(BINDIR)/bcscodes
	rm -f $(DESTDIR)$(BINDIR)/bcsgenerate
	rm -f $(DESTDIR)$(MANDIR)/bcs.1
	rm -f $(DESTDIR)$(MANDIR)/BCS-bash.1
	rm -f $(DESTDIR)$(MANDIR)/bcs-bash.1
	rm -f $(DESTDIR)$(COMPDIR)/bcs
	rm -f $(DESTDIR)$(COMPDIR)/bcscheck
	rm -f $(DESTDIR)$(COMPDIR)/bcsdisplay
	rm -f $(DESTDIR)$(COMPDIR)/bcstemplate
	rm -f $(DESTDIR)$(COMPDIR)/bcscodes
	rm -f $(DESTDIR)$(COMPDIR)/bcsgenerate
	rm -rf $(DESTDIR)$(SHAREDIR)
	rm -f $(DESTDIR)$(PREFIX)/share/yatti/bash-coding-standard

check:
	@command -v bcs >/dev/null 2>&1 \
	  && echo 'bcs: OK' \
	  || echo 'bcs: NOT FOUND (check PATH)'
	@command -v bcscheck >/dev/null 2>&1 \
	  && echo 'bcscheck: OK' \
	  || echo 'bcscheck: NOT FOUND (check PATH)'
	@command -v bcsdisplay >/dev/null 2>&1 \
	  && echo 'bcsdisplay: OK' \
	  || echo 'bcsdisplay: NOT FOUND (check PATH)'
	@command -v bcstemplate >/dev/null 2>&1 \
	  && echo 'bcstemplate: OK' \
	  || echo 'bcstemplate: NOT FOUND (check PATH)'
	@command -v bcscodes >/dev/null 2>&1 \
	  && echo 'bcscodes: OK' \
	  || echo 'bcscodes: NOT FOUND (check PATH)'
	@command -v bcsgenerate >/dev/null 2>&1 \
	  && echo 'bcsgenerate: OK' \
	  || echo 'bcsgenerate: NOT FOUND (check PATH)'

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
