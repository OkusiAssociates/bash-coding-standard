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
COMPLETIONDIR = $(PREFIX)/share/bash-completion/completions
MANDIR = $(PREFIX)/share/man/man1

# Trim utility scripts to install
TRIM_SCRIPTS = ltrim rtrim trim trimall trimv squeeze

.PHONY: install uninstall help check-deps install-deps

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
	@echo "  make check-deps                    # Check optional dependencies"
	@echo "  sudo make install-deps             # Install missing dependencies"

check-deps:
	@echo "Checking optional dependencies..."
	@echo ""
	@MISSING=""; \
	if ! command -v shellcheck >/dev/null 2>&1; then \
		echo "  ✗ shellcheck   (not found - recommended for script validation)"; \
		MISSING="$$MISSING shellcheck"; \
	else \
		echo "  ✓ shellcheck   ($$(shellcheck --version | grep '^version:' | awk '{print $$2}'))"; \
	fi; \
	if ! command -v jq >/dev/null 2>&1; then \
		echo "  ✗ jq           (not found - used for JSON processing)"; \
		MISSING="$$MISSING jq"; \
	else \
		echo "  ✓ jq           ($$(jq --version 2>&1))"; \
	fi; \
	if ! command -v less >/dev/null 2>&1; then \
		echo "  ✗ less         (not found - used for paging)"; \
		MISSING="$$MISSING less"; \
	else \
		echo "  ✓ less         ($$(less --version 2>&1 | head -1))"; \
	fi; \
	if ! command -v bc >/dev/null 2>&1; then \
		echo "  ✗ bc           (not found - used for calculations)"; \
		MISSING="$$MISSING bc"; \
	else \
		echo "  ✓ bc           ($$(echo 'print "version: "; 1+1' | bc -q 2>/dev/null || echo 'installed'))"; \
	fi; \
	if command -v iconv >/dev/null 2>&1; then \
		echo "  ✓ iconv        (built-in - glibc)"; \
	else \
		echo "  ✗ iconv        (not found - used for character encoding)"; \
		MISSING="$$MISSING libc-bin"; \
	fi; \
	if ! command -v claude >/dev/null 2>&1; then \
		echo "  ◉ claude       (not found - manual install required)"; \
		echo "                 Install from: https://github.com/anthropics/claude-code"; \
	else \
		echo "  ✓ claude       ($$(claude --version 2>&1 | head -1))"; \
	fi; \
	echo ""; \
	if [ -n "$$MISSING" ]; then \
		echo "Missing dependencies:$$MISSING"; \
		echo ""; \
		echo "Run 'sudo make install-deps' to install them automatically"; \
	else \
		echo "✓ All optional dependencies are installed"; \
	fi

install-deps:
	@echo "Installing optional dependencies..."
	@echo ""
	@# Detect package manager
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "Detected package manager: apt-get (Debian/Ubuntu)"; \
		MISSING=""; \
		command -v shellcheck >/dev/null 2>&1 || MISSING="$$MISSING shellcheck"; \
		command -v jq >/dev/null 2>&1 || MISSING="$$MISSING jq"; \
		command -v less >/dev/null 2>&1 || MISSING="$$MISSING less"; \
		command -v bc >/dev/null 2>&1 || MISSING="$$MISSING bc"; \
		command -v iconv >/dev/null 2>&1 || MISSING="$$MISSING libc-bin"; \
		if [ -n "$$MISSING" ]; then \
			echo "Installing:$$MISSING"; \
			apt-get update && apt-get install -y$$MISSING; \
		else \
			echo "✓ All dependencies already installed"; \
		fi; \
	elif command -v dnf >/dev/null 2>&1; then \
		echo "Detected package manager: dnf (Fedora/RHEL)"; \
		MISSING=""; \
		command -v shellcheck >/dev/null 2>&1 || MISSING="$$MISSING ShellCheck"; \
		command -v jq >/dev/null 2>&1 || MISSING="$$MISSING jq"; \
		command -v less >/dev/null 2>&1 || MISSING="$$MISSING less"; \
		command -v bc >/dev/null 2>&1 || MISSING="$$MISSING bc"; \
		command -v iconv >/dev/null 2>&1 || MISSING="$$MISSING glibc-common"; \
		if [ -n "$$MISSING" ]; then \
			echo "Installing:$$MISSING"; \
			dnf install -y$$MISSING; \
		else \
			echo "✓ All dependencies already installed"; \
		fi; \
	elif command -v pacman >/dev/null 2>&1; then \
		echo "Detected package manager: pacman (Arch Linux)"; \
		MISSING=""; \
		command -v shellcheck >/dev/null 2>&1 || MISSING="$$MISSING shellcheck"; \
		command -v jq >/dev/null 2>&1 || MISSING="$$MISSING jq"; \
		command -v less >/dev/null 2>&1 || MISSING="$$MISSING less"; \
		command -v bc >/dev/null 2>&1 || MISSING="$$MISSING bc"; \
		if [ -n "$$MISSING" ]; then \
			echo "Installing:$$MISSING"; \
			pacman -S --noconfirm$$MISSING; \
		else \
			echo "✓ All dependencies already installed"; \
		fi; \
	else \
		echo "▲ Unsupported package manager"; \
		echo "Please install manually: shellcheck jq less bc"; \
		exit 1; \
	fi
	@echo ""
	@if ! command -v claude >/dev/null 2>&1; then \
		echo "◉ Note: 'claude' must be installed manually"; \
		echo "   Install from: https://github.com/anthropics/claude-code"; \
	fi
	@echo ""
	@echo "✓ Dependencies installed"

install:
	@# Phase 0: Check and optionally install dependencies
	@echo "Checking for missing optional dependencies..."
	@MISSING=""; \
	command -v shellcheck >/dev/null 2>&1 || MISSING="$$MISSING shellcheck"; \
	command -v jq >/dev/null 2>&1 || MISSING="$$MISSING jq"; \
	command -v less >/dev/null 2>&1 || MISSING="$$MISSING less"; \
	command -v bc >/dev/null 2>&1 || MISSING="$$MISSING bc"; \
	command -v iconv >/dev/null 2>&1 || MISSING="$$MISSING libc-bin"; \
	if [ -n "$$MISSING" ]; then \
		echo "Missing dependencies:$$MISSING"; \
		echo ""; \
		read -p "Install missing dependencies? [y/N] " REPLY; \
		case "$$REPLY" in \
			[Yy]*) \
				echo "Installing dependencies..."; \
				echo ""; \
				if command -v apt-get >/dev/null 2>&1; then \
					echo "Detected package manager: apt-get (Debian/Ubuntu)"; \
					apt-get update && apt-get install -y$$MISSING || { \
						echo "▲ Warning: Dependency installation failed"; \
						echo "You can try manually: sudo make install-deps"; \
						echo ""; \
					}; \
				elif command -v dnf >/dev/null 2>&1; then \
					echo "Detected package manager: dnf (Fedora/RHEL)"; \
					MISSING_DNF=""; \
					command -v shellcheck >/dev/null 2>&1 || MISSING_DNF="$$MISSING_DNF ShellCheck"; \
					command -v jq >/dev/null 2>&1 || MISSING_DNF="$$MISSING_DNF jq"; \
					command -v less >/dev/null 2>&1 || MISSING_DNF="$$MISSING_DNF less"; \
					command -v bc >/dev/null 2>&1 || MISSING_DNF="$$MISSING_DNF bc"; \
					command -v iconv >/dev/null 2>&1 || MISSING_DNF="$$MISSING_DNF glibc-common"; \
					dnf install -y$$MISSING_DNF || { \
						echo "▲ Warning: Dependency installation failed"; \
						echo "You can try manually: sudo make install-deps"; \
						echo ""; \
					}; \
				elif command -v pacman >/dev/null 2>&1; then \
					echo "Detected package manager: pacman (Arch Linux)"; \
					MISSING_PAC=""; \
					command -v shellcheck >/dev/null 2>&1 || MISSING_PAC="$$MISSING_PAC shellcheck"; \
					command -v jq >/dev/null 2>&1 || MISSING_PAC="$$MISSING_PAC jq"; \
					command -v less >/dev/null 2>&1 || MISSING_PAC="$$MISSING_PAC less"; \
					command -v bc >/dev/null 2>&1 || MISSING_PAC="$$MISSING_PAC bc"; \
					pacman -S --noconfirm$$MISSING_PAC || { \
						echo "▲ Warning: Dependency installation failed"; \
						echo "You can try manually: sudo make install-deps"; \
						echo ""; \
					}; \
				else \
					echo "▲ Unsupported package manager"; \
					echo "Please install manually: sudo make install-deps"; \
					echo ""; \
				fi; \
				echo "✓ Dependencies installed"; \
				echo ""; \
				;; \
			*) \
				echo "Skipping dependency installation."; \
				echo "You can install them later with: sudo make install-deps"; \
				echo ""; \
				;; \
		esac; \
	else \
		echo "✓ All optional dependencies installed"; \
		echo ""; \
	fi
	@if ! command -v claude >/dev/null 2>&1; then \
		echo "◉ Note: 'claude' is not installed (optional)"; \
		echo "   Install from: https://github.com/anthropics/claude-code"; \
		echo ""; \
	fi
	@# Phase 0a: Group creation and user management
	@# Security Model: Create 'bcs' group for shared write access to installed files
	@# This enables multiple developers to maintain /usr/local/share/yatti/bash-coding-standard/
	@# without requiring root access for every edit. No SUID/SGID used (secure by design).
	@echo "Checking 'bcs' group membership..."
	@if ! getent group bcs >/dev/null 2>&1; then \
		echo "Creating 'bcs' group..."; \
		groupadd bcs || { \
			echo "✗ Failed to create 'bcs' group"; \
			echo "  You may need to run: sudo make install"; \
			exit 1; \
		}; \
		echo "✓ Group 'bcs' created"; \
	else \
		echo "✓ Group 'bcs' exists"; \
	fi
	@# Detect the actual user who ran 'sudo make install' (not root)
	@# Try SUDO_USER first (most common), then LOGNAME, finally whoami
	@REAL_USER=""; \
	if [ -n "$$SUDO_USER" ] && [ "$$SUDO_USER" != "root" ]; then \
		REAL_USER="$$SUDO_USER"; \
	elif [ -n "$$LOGNAME" ] && [ "$$LOGNAME" != "root" ]; then \
		REAL_USER="$$LOGNAME"; \
	else \
		REAL_USER=$$(whoami 2>/dev/null || echo ""); \
		if [ "$$REAL_USER" = "root" ]; then \
			REAL_USER=""; \
		fi; \
	fi; \
	if [ -n "$$REAL_USER" ]; then \
		echo "Detected user: $$REAL_USER"; \
		# Check if user is already in 'bcs' group to avoid redundant usermod calls \
		if id -nG "$$REAL_USER" 2>/dev/null | grep -qw bcs; then \
			echo "✓ User '$$REAL_USER' is already in 'bcs' group"; \
		else \
			echo "Adding user '$$REAL_USER' to 'bcs' group..."; \
			usermod -aG bcs "$$REAL_USER" || { \
				echo "▲ Warning: Failed to add user '$$REAL_USER' to 'bcs' group"; \
				echo "  You can add manually: sudo usermod -aG bcs $$REAL_USER"; \
			}; \
			echo "✓ User '$$REAL_USER' added to 'bcs' group"; \
		fi; \
		echo ""; \
		echo "◉ Important: User '$$REAL_USER' must log out and log back in"; \
		echo "  for group membership to take effect."; \
		echo ""; \
	else \
		echo "▲ Warning: Could not detect user (installing as root)"; \
		echo "  Add users to 'bcs' group manually:"; \
		echo "  sudo usermod -aG bcs <username>"; \
		echo ""; \
		echo "◉ Important: Users must log out and log back in"; \
		echo "  for group membership to take effect."; \
		echo ""; \
	fi
	@echo "To add additional users to 'bcs' group:"
	@echo "  sudo usermod -aG bcs <username>"
	@echo ""
	@# Phase 1: Detect existing symlinks in destination
	@echo "Checking for existing symlinks in $(BINDIR)..."
	@SYMLINKS=""; \
	for FILE in bcs md2ansi md mdheaders libmdheaders.bash whichx dir-sizes printline bcx \
	            shlock timer post_slug remblanks hr2int int2hr \
	            ltrim rtrim trim trimall trimv squeeze; do \
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
				for FILE in bcs md2ansi md mdheaders libmdheaders.bash whichx dir-sizes printline bcx \
				            shlock timer post_slug remblanks hr2int int2hr \
				            ltrim rtrim trim trimall trimv squeeze; do \
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
	install -m 755 lib/shlock/shlock $(BINDIR)/
	install -m 755 lib/timer/timer $(BINDIR)/
	install -m 755 lib/post_slug/post_slug.bash $(BINDIR)/post_slug
	install -m 755 lib/remblanks/remblanks $(BINDIR)/
	install -m 755 lib/hr2int/hr2int.bash $(BINDIR)/hr2int
	ln -sf hr2int $(BINDIR)/int2hr
	@for SCRIPT in $(TRIM_SCRIPTS); do \
		install -m 755 lib/trim/$$SCRIPT.bash $(BINDIR)/$$SCRIPT; \
	done
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
	@echo "Installing bash completion..."
	install -d $(COMPLETIONDIR)
	install -m 644 bcs.bash_completion $(COMPLETIONDIR)/bcs
	ln -sf bcs $(COMPLETIONDIR)/bash-coding-standard
	@echo "  - Bash completion installed to $(COMPLETIONDIR)"
	@echo "Installing manpage..."
	install -d $(MANDIR)
	install -m 644 bcs.1 $(MANDIR)/bcs.1
	ln -sf bcs.1 $(MANDIR)/bash-coding-standard.1
	@echo "  - Manpage installed to $(MANDIR)"
	@echo ""
	@echo "✓ Installed to $(PREFIX)"
	@echo ""
	@echo "Installed files (23 commands):"
	@echo "  - Main executable: $(BINDIR)/bcs (and bash-coding-standard symlink)"
	@echo "  - Markdown tools: md2ansi, md, mdheaders"
	@echo "  - Command locator: whichx (and which symlink)"
	@echo "  - Directory analyzer: dir-sizes (and dux symlink)"
	@echo "  - Line drawing: printline"
	@echo "  - Calculator: bcx"
	@echo "  - File locking: shlock"
	@echo "  - Timer: timer"
	@echo "  - URL slug: post_slug"
	@echo "  - Blank line remover: remblanks"
	@echo "  - Number converter: hr2int (and int2hr symlink)"
	@echo "  - String trim: ltrim, rtrim, trim, trimall, trimv, squeeze"
	@echo "  - Standard docs (3 tiers): $(SHAREDIR)/data/BASH-CODING-STANDARD.*.md"
	@echo "  - Data directory: $(SHAREDIR)/data/ (300+ rule files + templates)"
	@echo "  - Vendored dependencies: $(SHAREDIR)/lib/ (~544KB)"
	@echo "  - BCS index: $(SHAREDIR)/BCS/ (convenience symlinks, if available)"
	@echo "  - Bash completion: $(COMPLETIONDIR)/bcs (and bash-coding-standard)"
	@echo "  - Manpage: $(MANDIR)/bcs.1 (and bash-coding-standard.1)"
	@echo ""
	@echo "Usage examples:"
	@echo "  bcs                                  # View BCS standard"
	@echo "  bcs --help                           # Show help"
	@echo "  md file.md                           # View markdown file"
	@echo "  mdheaders upgrade file.md            # Manipulate headers"
	@echo "  which <command>                      # Locate command"
	@echo "  dir-sizes [directory]                # Show directory sizes"
	@echo "  printline [char [text]]              # Draw lines"
	@echo "  bcx '2 + 2'                          # Calculator"
	@echo "  shlock -f /tmp/mylock.lock           # File locking"
	@echo "  timer 5m                             # Timer"
	@echo "  post_slug 'My Blog Post'             # URL slug"
	@echo "  remblanks < file.txt                 # Remove blank lines"
	@echo "  hr2int 10M                           # Human to integer (10000000)"
	@echo "  int2hr 10000000                      # Integer to human (10.0M)"
	@echo "  ltrim ' text '                       # Left trim"
	@echo ""
	@echo "View documentation:"
	@echo "  man bcs                              # View manpage"
	@echo "  man bash-coding-standard             # Same (symlink)"
	@echo ""
	@echo "Check dependencies:"
	@echo "  make check-deps                      # Check optional tools"
	@echo "  sudo make install-deps               # Install missing tools"

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
	rm -f $(BINDIR)/shlock
	rm -f $(BINDIR)/timer
	rm -f $(BINDIR)/post_slug
	rm -f $(BINDIR)/remblanks
	rm -f $(BINDIR)/hr2int
	rm -f $(BINDIR)/int2hr
	@for SCRIPT in $(TRIM_SCRIPTS); do \
		rm -f $(BINDIR)/$$SCRIPT; \
	done
	rm -rf $(SHAREDIR)
	rm -f $(COMPLETIONDIR)/bcs
	rm -f $(COMPLETIONDIR)/bash-coding-standard
	rm -f $(MANDIR)/bcs.1
	rm -f $(MANDIR)/bash-coding-standard.1
	@echo ""
	@echo "✓ Uninstalled from $(PREFIX)"
