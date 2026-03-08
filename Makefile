PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/yatti/BCS
OLDSHARE = $(PREFIX)/share/yatti/bash-coding-standard
COMPDIR = $(PREFIX)/share/bash-completion/completions
MANDIR = $(PREFIX)/share/man/man1

.PHONY: install uninstall help check test

install: ## Install bcs to $(PREFIX)
	install -d $(BINDIR)
	install -d $(SHAREDIR)/data/templates
	install -d $(COMPDIR)
	install -m 755 bcs $(BINDIR)/bcs
	install -m 755 bcscheck $(BINDIR)/bcscheck
	install -m 644 data/BASH-CODING-STANDARD.md $(SHAREDIR)/data/
	install -m 644 data/[0-9]*.md $(SHAREDIR)/data/
	install -m 644 data/templates/*.sh.template $(SHAREDIR)/data/templates/
	install -m 644 bcs.bash_completion $(COMPDIR)/bcs
	install -d $(MANDIR)
	install -m 644 bcs.1 $(MANDIR)/bcs.1
	@if [ -d $(OLDSHARE) ] && [ ! -L $(OLDSHARE) ]; then rm -rf $(OLDSHARE); fi
	ln -sfn BCS $(OLDSHARE)

uninstall: ## Uninstall bcs from $(PREFIX)
	rm -f $(BINDIR)/bcs $(BINDIR)/bcscheck
	rm -f $(COMPDIR)/bcs
	rm -f $(MANDIR)/bcs.1
	rm -rf $(SHAREDIR)
	rm -f $(OLDSHARE)

check: ## Run shellcheck on all scripts
	shellcheck -x bcs bcscheck examples/cln examples/which examples/md2ansi tests/run-all-tests.sh tests/test-*.sh
	shellcheck bcs.bash_completion

test: ## Run test suite
	./tests/run-all-tests.sh

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  %-15s %s\n", $$1, $$2}'
