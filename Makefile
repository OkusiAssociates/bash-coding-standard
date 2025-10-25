# Makefile for bash-coding-standard installation
# Usage:
#   sudo make install                  # Install to /usr/local
#   sudo make PREFIX=/usr install      # Install to /usr (system-wide)
#   sudo make uninstall                # Uninstall from /usr/local

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/yatti/bash-coding-standard

.PHONY: install uninstall help

help:
	@echo "bash-coding-standard Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  install     Install to $(PREFIX)"
	@echo "  uninstall   Uninstall from $(PREFIX)"
	@echo "  help        Show this help message"
	@echo ""
	@echo "Usage:"
	@echo "  sudo make install                  # Install to /usr/local"
	@echo "  sudo make PREFIX=/usr install      # Install to /usr"
	@echo "  sudo make uninstall                # Uninstall"

install:
	install -d $(BINDIR)
	install -m 755 bcs $(BINDIR)/
	ln -sf bcs $(BINDIR)/bash-coding-standard
	install -d -m 2775 -g bcs $(SHAREDIR)
	cp -a data $(SHAREDIR)/ && chgrp -R bcs $(SHAREDIR)/data && find $(SHAREDIR)/data -type d -exec chmod 2775 {} + && find $(SHAREDIR)/data -type f -exec chmod 664 {} +
	ln -sf BASH-CODING-STANDARD.abstract.md $(SHAREDIR)/data/BASH-CODING-STANDARD.md
	cp -a lib $(SHAREDIR)/ && chgrp -R bcs $(SHAREDIR)/lib && find $(SHAREDIR)/lib -type d -exec chmod 2775 {} + && find $(SHAREDIR)/lib -type f -exec chmod 664 {} + && chmod 775 $(SHAREDIR)/lib/agents/* $(SHAREDIR)/lib/md2ansi/md2ansi $(SHAREDIR)/lib/shlock/shlock $(SHAREDIR)/lib/trim/*.bash $(SHAREDIR)/lib/timer/timer $(SHAREDIR)/lib/post_slug/post_slug.bash $(SHAREDIR)/lib/hr2int/hr2int.bash $(SHAREDIR)/lib/remblanks/remblanks
	@if [ -d BCS ]; then \
		rm -rf $(SHAREDIR)/BCS && \
		cp -a BCS $(SHAREDIR)/ && chgrp -R bcs $(SHAREDIR)/BCS && find $(SHAREDIR)/BCS -type d -exec chmod 2775 {} + && \
		echo "  - BCS index installed"; \
	else \
		echo "  - BCS index not found (run 'bcs generate --canonical' to create)"; \
	fi
	@echo ""
	@echo "✓ Installed to $(PREFIX)"
	@echo ""
	@echo "Installed files:"
	@echo "  - Executable: $(BINDIR)/bcs (and bash-coding-standard symlink)"
	@echo "  - Standard docs (3 tiers): $(SHAREDIR)/data/BASH-CODING-STANDARD.*.md"
	@echo "  - Data directory: $(SHAREDIR)/data/ (300+ rule files + templates)"
	@echo "  - Vendored dependencies: $(SHAREDIR)/lib/ (~345KB: md2ansi, agents, shlock, trim, timer, post_slug, hr2int, remblanks)"
	@echo "  - BCS index: $(SHAREDIR)/BCS/ (convenience symlinks, if available)"
	@echo ""
	@echo "Run: bcs"
	@echo "Help: bcs --help"

uninstall:
	rm -f $(BINDIR)/bcs
	rm -f $(BINDIR)/bash-coding-standard
	rm -rf $(SHAREDIR)
	@echo ""
	@echo "✓ Uninstalled from $(PREFIX)"
