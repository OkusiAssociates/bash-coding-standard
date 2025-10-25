# Makefile for bash-coding-standard installation
# Usage:
#   sudo make install                  # Install to /usr/local
#   sudo make PREFIX=/usr install      # Install to /usr (system-wide)
#   sudo make uninstall                # Uninstall from /usr/local
#
# Note: Install will detect and warn about existing symlinks in BINDIR
#       before installation. This protects development symlinks from being
#       silently overwritten. User confirmation is required to proceed.

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
	@# Phase 1: Detect existing symlinks in destination
	@echo "Checking for existing symlinks in $(BINDIR)..."
	@SYMLINKS=""; \
	for FILE in bcs md2ansi md mdheaders libmdheaders.bash whichx dir-sizes printline bcx; do \
		if [ -L "$(BINDIR)/$$FILE" ]; then \
			TARGET=$$(readlink -f "$(BINDIR)/$$FILE" 2>/dev/null || echo "<broken symlink>"); \
			SYMLINKS="$$SYMLINKS$(BINDIR)/$$FILE -> $$TARGET\n"; \
		fi; \
	done; \
	if [ -n "$$SYMLINKS" ]; then \
		echo ""; \
		echo "▲ Warning: The following files are symlinks and will be removed:"; \
		printf "$$SYMLINKS" | sed 's/^/  /'; \
		echo ""; \
		read -p "Remove these symlinks and continue? [y/N] " REPLY; \
		case "$$REPLY" in \
			[Yy]*) \
				echo "Removing symlinks..."; \
				for FILE in bcs md2ansi md mdheaders libmdheaders.bash whichx dir-sizes printline bcx; do \
					[ -L "$(BINDIR)/$$FILE" ] && rm -f "$(BINDIR)/$$FILE"; \
				done; \
				echo "✓ Symlinks removed"; \
				echo ""; \
				;; \
			*) \
				echo "Installation cancelled."; \
				exit 1; \
				;; \
		esac; \
	else \
		echo "✓ No conflicting symlinks found"; \
		echo ""; \
	fi
	@# Phase 2: Normal installation
	install -d $(BINDIR)
	install -m 755 bcs $(BINDIR)/
	ln -sf bcs $(BINDIR)/bash-coding-standard
	install -m 755 lib/md2ansi/md2ansi $(BINDIR)/
	install -m 755 lib/md2ansi/md $(BINDIR)/
	install -m 755 lib/mdheaders/mdheaders $(BINDIR)/
	install -m 755 lib/mdheaders/libmdheaders.bash $(BINDIR)/
	install -m 755 lib/whichx/whichx $(BINDIR)/
	ln -sf whichx $(BINDIR)/which
	install -m 755 lib/dux/dir-sizes $(BINDIR)/
	ln -sf dir-sizes $(BINDIR)/dux
	install -m 755 lib/printline/printline $(BINDIR)/
	install -m 755 lib/bcx/bcx $(BINDIR)/
	install -d -m 2775 -g bcs $(SHAREDIR)
	cp -a data $(SHAREDIR)/ && chgrp -R bcs $(SHAREDIR)/data && find $(SHAREDIR)/data -type d -exec chmod 2775 {} + && find $(SHAREDIR)/data -type f -exec chmod 664 {} +
	ln -sf BASH-CODING-STANDARD.abstract.md $(SHAREDIR)/data/BASH-CODING-STANDARD.md
	cp -a lib $(SHAREDIR)/ && chgrp -R bcs $(SHAREDIR)/lib && find $(SHAREDIR)/lib -type d -exec chmod 2775 {} + && find $(SHAREDIR)/lib -type f -exec chmod 664 {} + && chmod 775 $(SHAREDIR)/lib/agents/* $(SHAREDIR)/lib/md2ansi/md2ansi $(SHAREDIR)/lib/md2ansi/md $(SHAREDIR)/lib/mdheaders/mdheaders $(SHAREDIR)/lib/mdheaders/libmdheaders.bash $(SHAREDIR)/lib/whichx/whichx $(SHAREDIR)/lib/dux/dir-sizes $(SHAREDIR)/lib/printline/printline $(SHAREDIR)/lib/bcx/bcx $(SHAREDIR)/lib/shlock/shlock $(SHAREDIR)/lib/trim/*.bash $(SHAREDIR)/lib/timer/timer $(SHAREDIR)/lib/post_slug/post_slug.bash $(SHAREDIR)/lib/hr2int/hr2int.bash $(SHAREDIR)/lib/remblanks/remblanks
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
	@echo "  - Executables: $(BINDIR)/bcs (and bash-coding-standard symlink)"
	@echo "  - Markdown tools: $(BINDIR)/md2ansi, $(BINDIR)/md, $(BINDIR)/mdheaders"
	@echo "  - Command locator: $(BINDIR)/whichx (and which symlink)"
	@echo "  - Directory analyzer: $(BINDIR)/dir-sizes (and dux symlink)"
	@echo "  - Line drawing: $(BINDIR)/printline"
	@echo "  - Calculator: $(BINDIR)/bcx"
	@echo "  - Standard docs (3 tiers): $(SHAREDIR)/data/BASH-CODING-STANDARD.*.md"
	@echo "  - Data directory: $(SHAREDIR)/data/ (300+ rule files + templates)"
	@echo "  - Vendored dependencies: $(SHAREDIR)/lib/ (~544KB: md2ansi, mdheaders, whichx, dux, printline, bcx, agents, shlock, trim, timer, post_slug, hr2int, remblanks)"
	@echo "  - BCS index: $(SHAREDIR)/BCS/ (convenience symlinks, if available)"
	@echo ""
	@echo "Run: bcs"
	@echo "Help: bcs --help"
	@echo "Markdown viewer: md file.md  (or md2ansi file.md)"
	@echo "Header manipulation: mdheaders {upgrade|downgrade|normalize} file.md"
	@echo "Command locator: which <command>  (or whichx <command>)"
	@echo "Directory sizes: dir-sizes [directory]  (or dux [directory])"
	@echo "Line drawing: printline [char [text]]"
	@echo "Calculator: bcx [expression]  (or bcx for interactive mode)"

uninstall:
	rm -f $(BINDIR)/bcs
	rm -f $(BINDIR)/bash-coding-standard
	rm -f $(BINDIR)/md2ansi
	rm -f $(BINDIR)/md
	rm -f $(BINDIR)/mdheaders
	rm -f $(BINDIR)/libmdheaders.bash
	rm -f $(BINDIR)/whichx
	rm -f $(BINDIR)/which
	rm -f $(BINDIR)/dir-sizes
	rm -f $(BINDIR)/dux
	rm -f $(BINDIR)/printline
	rm -f $(BINDIR)/bcx
	rm -rf $(SHAREDIR)
	@echo ""
	@echo "✓ Uninstalled from $(PREFIX)"
