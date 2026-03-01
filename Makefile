PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/yatti/bash-coding-standard

.PHONY: install uninstall help check test

install: ## Install bcs to $(PREFIX)
	install -d $(BINDIR)
	install -d $(SHAREDIR)/data/templates
	install -m 755 bcs $(BINDIR)/bcs
	install -m 755 bcscheck $(BINDIR)/bcscheck
	install -m 644 data/BASH-CODING-STANDARD.md $(SHAREDIR)/data/
	install -m 644 data/[0-9]*.md $(SHAREDIR)/data/
	install -m 644 data/templates/*.sh.template $(SHAREDIR)/data/templates/

uninstall: ## Uninstall bcs from $(PREFIX)
	rm -f $(BINDIR)/bcs $(BINDIR)/bcscheck
	rm -rf $(SHAREDIR)

check: ## Run shellcheck on bcs
	shellcheck -x bcs bcscheck

test: ## Run test suite
	./tests/run-all-tests.sh

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  %-15s %s\n", $$1, $$2}'
