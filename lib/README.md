# Vendored Dependencies

This directory contains vendored copies of external dependencies to ensure the Bash Coding Standard (BCS) works out-of-box without requiring the `/ai/scripts` development environment.

## Vendored Dependencies

### agents/ - Claude Agent Wrappers

**Purpose:** Claude CLI wrapper scripts for BCS-specific tasks

**Dependencies:**
- **bcs-rulet-extractor** (v1.0.1, ~5KB)
  - Purpose: Extract concise rulets from .complete.md rulefiles using Claude AI
  - Used by: `bcs generate-rulets` subcommand
  - Upstream: /ai/scripts/claude/agents/bcs-rulet-extractor
  - Last synced: 2025-10-25

- **bcs-compliance** (v1.0.1, ~900B)
  - Purpose: BCS compliance checking wrapper for Claude
  - Used by: External compliance checking workflows
  - Upstream: /ai/scripts/claude/agents/bcs-compliance
  - Last synced: 2025-10-25

**License:** Part of Indonesian Open Technology Foundation project
**Requirements:** Claude Code CLI (`claude` command in PATH)

---

### md2ansi/ - Markdown to ANSI Renderer

**Purpose:** Beautiful terminal display of markdown documents

**Size:** ~60KB (2 scripts + 5 library files)

**Used by:** `bcs display` command (optional enhancement)

**Upstream:** https://github.com/Open-Technology-Foundation/md2ansi.bash
**Git commit:** `6e8d7dc28e341232388875287f48c5c47a5c6d3e`
**Last synced:** 2025-10-18 14:38:51 +0800

**License:** MIT (see LICENSES/md2ansi.LICENSE)

**Contents:**
- `md2ansi` - Main markdown renderer script
- `md` - Wrapper script that pipes md2ansi through less for pagination
- `lib/ansi-colors.sh` - ANSI color definitions
- `lib/parser.sh` - Markdown parsing engine
- `lib/renderer.sh` - ANSI rendering engine
- `lib/tables.sh` - Table rendering support
- `lib/utils.sh` - Utility functions

**Installed to system:**
- Both `md2ansi` and `md` are installed to `/usr/local/bin/` for system-wide access
- Use `md file.md` for paginated viewing or `md2ansi file.md` for direct output

---

### mdheaders/ - Markdown Header Level Manipulation

**Purpose:** CLI tool for modifying markdown header levels (upgrade, downgrade, normalize)

**Size:** ~54KB (2 scripts + docs)

**Used by:** General markdown document manipulation

**Upstream:** /ai/scripts/Markdown/mdheaders
**Git commit:** `6837187071ecf602be393dabd19f9bd16ef46372`
**Last synced:** 2025-10-23 11:06:57 +0800

**License:** GPL v3 (see LICENSES/mdheaders.LICENSE)

**Contents:**
- `mdheaders` - Main CLI tool for header manipulation
- `libmdheaders.bash` - Library file sourced by mdheaders

**Features:**
- ✅ Upgrade headers - Increase levels (# → ##)
- ✅ Downgrade headers - Decrease levels (## → #)
- ✅ Normalize headers - Auto-detect minimum level and normalize to target
- ✅ Code block awareness - Preserves fenced code blocks (``` and ~~~)
- ✅ Flexible output - stdout, file, or in-place modification with backups
- ✅ Safety features - Validates H1-H6 boundaries

**Installed to system:**
- Both `mdheaders` and `libmdheaders.bash` are installed to `/usr/local/bin/`
- Usage: `mdheaders {upgrade|downgrade|normalize} [OPTIONS] file.md`
- Examples:
  - `mdheaders upgrade -l 2 -ib README.md` (upgrade 2 levels in-place with backup)
  - `mdheaders normalize --start-level=2 doc.md` (normalize to start at H2)

**Note:** GPL v3 is a copyleft license, distinct from BCS's CC BY-SA 4.0.

---

### whichx/ - Robust Command Locator

**Purpose:** Enhanced 'which' command implementation with proper error handling

**Size:** ~45KB (script + docs)

**Used by:** Drop-in replacement for standard 'which' command

**Upstream:** https://github.com/Open-Technology-Foundation/whichx
**Git commit:** `6f2b28b2f87520b3a76005ab7beed5c770b72de9`
**Last synced:** 2025-10-04 13:20:39 +0800

**License:** GPL v3 (see LICENSES/whichx.LICENSE)

**Contents:**
- `whichx` - Main command locator script (v2.0)

**Features:**
- ✅ POSIX-compliant PATH searching
- ✅ Canonical path resolution (follow symlinks with `-c`)
- ✅ Show all matches in PATH (with `-a`)
- ✅ Silent mode for scripting (with `-s`)
- ✅ Enhanced error handling with specific exit codes
- ✅ Zero dependencies beyond bash

**Installed to system:**
- `whichx` installed to `/usr/local/bin/whichx`
- Symlink `which` → `whichx` created in `/usr/local/bin/`
- Drop-in replacement for system 'which' command (higher priority in PATH)
- Usage: `which <command>` or `whichx <command>`
- Examples:
  - `which ls` - Find location of ls command
  - `whichx -a python` - Find all python executables in PATH
  - `whichx -c vim` - Show canonical path (follow symlinks)

**Note:** GPL v3 is a copyleft license, distinct from BCS's CC BY-SA 4.0.

---

### dux/ - Directory Size Analyzer (dir-sizes)

**Purpose:** Display directory sizes in sorted human-readable format

**Size:** ~56KB (script + docs)

**Used by:** Disk space analysis and directory size monitoring

**Upstream:** /ai/scripts/File/dux (internal YaTTI tool)
**Git commit:** `ee0927ce87cc516ad9243a8214e48b041892d559`
**Last synced:** 2025-09-21 10:40:03 +0800

**License:** GPL v3 (see LICENSES/dux.LICENSE)

**Contents:**
- `dir-sizes` - Main directory size analyzer script (v1.2.0)
- `README.md` - Complete documentation with usage examples
- `LICENSE` - GPL v3 license

**Features:**
- ✅ Recursive size calculation (includes all nested content)
- ✅ Human-readable output with IEC units (B, KiB, MiB, GiB, TiB)
- ✅ Sorted results (smallest to largest)
- ✅ Graceful permission error handling
- ✅ Secure temporary file handling
- ✅ Signal handling for clean interruption (Ctrl+C safe)
- ✅ Fast performance using native `du` command

**Installed to system:**
- `dir-sizes` installed to `/usr/local/bin/dir-sizes`
- Symlink `dux` → `dir-sizes` created in `/usr/local/bin/`
- Usage: `dir-sizes [directory]` or `dux [directory]`
- Examples:
  - `dux` - Analyze current directory
  - `dir-sizes /var` - Analyze /var subdirectories
  - `dux ~/Documents | tail -10` - Show 10 largest directories

**Note:** GPL v3 is a copyleft license, distinct from BCS's CC BY-SA 4.0.

---

### shlock/ - Shell Locking Utility

**Purpose:** Process locking and synchronization for shell scripts

**Size:** ~16KB (single script)

**Used by:** `lib/agents/bcs-compliance` for concurrent execution control

**Upstream:** /ai/scripts/lib/shlock/
**Git commit:** `49f1439a9a0e9a9d832539d17a3c6b889f67d07e`
**Last synced:** 2025-10-24 14:48:24 +0800

**License:** MIT (see LICENSES/shlock.LICENSE)

---

### trim/ - String Trimming Utilities

**Purpose:** Pure Bash string trimming and whitespace manipulation utilities

**Size:** ~92KB (6 utilities + README + LICENSE)

**Used by:** Available for general use in scripts

**Upstream:** https://github.com/Open-Technology-Foundation/trim
**Git commit:** `8b37c556f40fad179451ada68e6553d17d811973`
**Last synced:** 2025-10-19 06:50:49 +0800

**License:** GPL v3 (see LICENSES/trim.LICENSE)

**Contents:**
- `trim` / `trim.bash` - Remove leading and trailing whitespace
- `ltrim` / `ltrim.bash` - Remove leading whitespace only
- `rtrim` / `rtrim.bash` - Remove trailing whitespace only
- `trimall` / `trimall.bash` - Normalize whitespace (trim + collapse internal spaces)
- `squeeze` / `squeeze.bash` - Collapse consecutive whitespace
- `trimv` / `trimv.bash` - Trim with direct variable assignment (no subshell)
- `README.md` - Complete documentation with examples
- `LICENSE` - GPL v3 license

**Features:**
- ✅ Zero dependencies - Pure Bash implementation
- ✅ Fast - No subprocess overhead
- ✅ Dual-mode - Use as commands OR source as functions
- ✅ Pipeline-friendly - Full stdin/stdout support

**Note:** GPL v3 is a copyleft license, distinct from BCS's CC BY-SA 4.0. These utilities remain independently licensed under GPL v3.

---

### timer/ - High-Precision Command Timer

**Purpose:** Microsecond-precision command execution timing

**Size:** ~7KB (single script + README + LICENSE)

**Used by:** Available for general use in scripts and benchmarking

**Upstream:** https://github.com/Open-Technology-Foundation/timer
**Git commit:** `f8ac47a76082d4da5c8808bdc0211a6b1e385c28`
**Last synced:** 2025-10-23 22:00:34 +0800

**License:** GPL v3 (see LICENSES/timer.LICENSE)

**Contents:**
- `timer` - High-precision command timer script with optional formatted output
- `README.md` - Complete documentation with usage examples
- `LICENSE` - GPL v3 license

**Features:**
- ✅ Zero dependencies - Pure Bash using EPOCHREALTIME
- ✅ Microsecond precision - Accurate to microseconds
- ✅ Dual-mode - Use as command or source as function
- ✅ Formatted output - Optional human-readable format (days/hours/minutes/seconds)
- ✅ Exit code preservation - Maintains command exit status

**Note:** GPL v3 is a copyleft license, distinct from BCS's CC BY-SA 4.0.

---

### post_slug/ - URL/Filename Slug Generator

**Purpose:** Convert strings into URL or filename-friendly slugs

**Size:** ~5KB (single script + LICENSE)

**Used by:** Available for general use in scripts (URL generation, file naming)

**Upstream:** https://github.com/Open-Technology-Foundation/post_slug
**Git commit:** `d4f73ff5eee87b50b3bc4c607029a099e6c11bc9`
**Last synced:** 2025-10-09 10:11:12 +0800

**License:** GPL v3 (see LICENSES/post_slug.LICENSE)

**Contents:**
- `post_slug.bash` - Slug generation function with multiple transformations
- `LICENSE` - GPL v3 license

**Features:**
- ✅ HTML entity handling - Replaces HTML entities with separator
- ✅ ASCII transliteration - Converts UTF-8 to ASCII via iconv
- ✅ Customizable separator - Default hyphen, configurable
- ✅ Case preservation option - Optional lowercase conversion
- ✅ Length limits - Filesystem-safe 255 character limit

**Dependencies:** sed, iconv, tr (standard utilities)

**Note:** GPL v3 is a copyleft license, distinct from BCS's CC BY-SA 4.0.

---

### hr2int/ - Human-Readable Number Converter

**Purpose:** Convert human-readable numbers with size suffixes to integers

**Size:** ~3KB (single script)

**Used by:** Available for general use in scripts (parsing sizes, capacity calculations)

**Upstream:** Internal YaTTI utility (no public repository)
**Last synced:** 2025-10-25 12:04:34 +0800

**License:** ⚠️ No explicit license (internal YaTTI utility)

**Contents:**
- `hr2int.bash` - Conversion functions for both directions
  - `hr2int()` - Convert human-readable to integer (1k → 1024, 1K → 1000)
  - `int2hr()` - Convert integer to human-readable (1024 → 1k, 1000 → 1K)

**Features:**
- ✅ IEC binary format - Lowercase suffixes (b,k,m,g,t,p) = powers of 1024
- ✅ SI decimal format - Uppercase suffixes (B,K,M,G,T,P) = powers of 1000
- ✅ Bidirectional - Convert both ways (hr→int, int→hr)
- ✅ Batch processing - Handle multiple values in one call

**Dependencies:** numfmt (GNU coreutils)

**Note:** No explicit license. Treated as internal YaTTI utility.

---

### remblanks/ - Comment and Blank Line Stripper

**Purpose:** Strip comments and blank lines from input

**Size:** ~534 bytes (tiny single script)

**Used by:** Available for general use in scripts (config file processing, cleanup)

**Upstream:** Internal YaTTI utility (no public repository)
**Last synced:** 2025-10-25 12:04:34 +0800

**License:** ⚠️ No explicit license (internal YaTTI utility)

**Contents:**
- `remblanks` - Simple grep-based comment/blank line remover

**Features:**
- ✅ Dual-mode - Works as pipe or with string arguments
- ✅ Tiny footprint - Only 534 bytes
- ✅ Fast - Single grep invocation
- ✅ Sourceable - Can be sourced as function

**Dependencies:** grep

**Note:** No explicit license. Treated as internal YaTTI utility.

---

## Path Resolution

The `bcs` script searches for dependencies in priority order:

1. **Bundled (lib/)** - Vendored dependencies (priority 1)
2. **System PATH** - System-installed tools (priority 2, md2ansi only)
3. **Development (/ai/scripts)** - Development environment fallback (priority 3, agents only)

This ensures:
- ✅ Works out-of-box after `git clone`
- ✅ Users can override with system installations
- ✅ Development environment still usable

---

## Updating Vendored Dependencies

### Update md2ansi

```bash
# Sync with upstream
cd /ai/scripts/Markdown/md2ansi.bash
git pull

# Copy to BCS lib/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/Markdown/md2ansi.bash/md2ansi lib/md2ansi/
cp /ai/scripts/Markdown/md2ansi.bash/md lib/md2ansi/
cp /ai/scripts/Markdown/md2ansi.bash/lib/*.sh lib/md2ansi/lib/
chmod +x lib/md2ansi/md2ansi lib/md2ansi/md

# Update this README with new git commit hash
cd /ai/scripts/Markdown/md2ansi.bash
git log -1 --format="%H %ci"
```

### Update mdheaders

```bash
# Sync with upstream
cd /ai/scripts/Markdown/mdheaders
git pull

# Copy to BCS lib/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/Markdown/mdheaders/mdheaders lib/mdheaders/
cp /ai/scripts/Markdown/mdheaders/libmdheaders.bash lib/mdheaders/
chmod +x lib/mdheaders/mdheaders lib/mdheaders/libmdheaders.bash

# Update this README with new git commit hash
cd /ai/scripts/Markdown/mdheaders
git log -1 --format="%H %ci"
```

### Update whichx

```bash
# Sync with upstream
cd /ai/scripts/File/whichx
git pull

# Copy to BCS lib/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/File/whichx/whichx lib/whichx/
chmod +x lib/whichx/whichx

# Update this README with new git commit hash
cd /ai/scripts/File/whichx
git log -1 --format="%H %ci"
```

### Update dux

```bash
# Sync with upstream
cd /ai/scripts/File/dux
git pull

# Copy to BCS lib/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/File/dux/dir-sizes lib/dux/
chmod +x lib/dux/dir-sizes

# Update this README with new git commit hash
cd /ai/scripts/File/dux
git log -1 --format="%H %ci"
```

### Update shlock

```bash
# Sync with upstream
cd /ai/scripts/lib/shlock
git pull

# Copy to BCS lib/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/lib/shlock/shlock lib/shlock/
chmod +x lib/shlock/shlock

# Update this README with new git commit hash
cd /ai/scripts/lib/shlock
git log -1 --format="%H %ci"
```

### Update agents

```bash
# Copy from /ai/scripts/claude/agents/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/claude/agents/bcs-rulet-extractor lib/agents/
cp /ai/scripts/claude/agents/bcs-compliance lib/agents/
chmod +x lib/agents/*

# Update version in this README if changed
grep VERSION lib/agents/bcs-rulet-extractor
```

### Update trim

```bash
# Sync with upstream
cd /ai/scripts/lib/str/trim
git pull

# Copy to BCS lib/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/lib/str/trim/{trim,ltrim,rtrim,trimall,squeeze,trimv}.bash lib/trim/
cp /ai/scripts/lib/str/trim/{README.md,LICENSE} lib/trim/
chmod +x lib/trim/*.bash

# Recreate symlinks
cd lib/trim
ln -sf trim.bash trim
ln -sf ltrim.bash ltrim
ln -sf rtrim.bash rtrim
ln -sf trimall.bash trimall
ln -sf squeeze.bash squeeze
ln -sf trimv.bash trimv

# Update this README with new git commit hash
cd /ai/scripts/lib/str/trim
git log -1 --format="%H %ci"
```

### Update timer

```bash
# Sync with upstream
cd /ai/scripts/lib/timer
git pull

# Copy to BCS lib/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/lib/timer/timer lib/timer/
cp /ai/scripts/lib/timer/{README.md,LICENSE} lib/timer/
chmod +x lib/timer/timer

# Update this README with new git commit hash
cd /ai/scripts/lib/timer
git log -1 --format="%H %ci"
```

### Update post_slug

```bash
# Sync with upstream
cd /ai/scripts/lib/post_slug
git pull

# Copy to BCS lib/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/lib/post_slug/post_slug.bash lib/post_slug/
cp /ai/scripts/lib/post_slug/LICENSE lib/post_slug/
chmod +x lib/post_slug/post_slug.bash

# Update this README with new git commit hash
cd /ai/scripts/lib/post_slug
git log -1 --format="%H %ci"
```

### Update hr2int

```bash
# Copy from /ai/scripts/lib/hr2int/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/lib/hr2int/hr2int.bash lib/hr2int/
chmod +x lib/hr2int/hr2int.bash

# Note: Not a git repo - manually track changes
```

### Update remblanks

```bash
# Copy from /ai/scripts/lib/remblanks/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/lib/remblanks/remblanks lib/remblanks/
chmod +x lib/remblanks/remblanks

# Note: Not a git repo - manually track changes
```

---

## Why Vendor These Dependencies?

**Agents:**
- ✅ Critical for `bcs generate-rulets` functionality
- ✅ Small size (~6KB total)
- ✅ Tightly coupled to BCS

**md2ansi:**
- ✅ Enhanced user experience (beautiful markdown display)
- ✅ Self-contained (~60KB, acceptable)
- ✅ Eliminates installation step

**mdheaders:**
- ✅ Powerful markdown header manipulation tool
- ✅ Useful for document restructuring and normalization
- ✅ Code block awareness prevents corruption
- ✅ Self-contained (~54KB including library)

**whichx:**
- ✅ Robust drop-in replacement for 'which' command
- ✅ Enhanced error handling and POSIX compliance
- ✅ Useful for scripting (silent mode, specific exit codes)
- ✅ Self-contained (~45KB including docs)

**dux:**
- ✅ Fast directory size analyzer with sorted human-readable output
- ✅ Essential for disk space analysis and monitoring
- ✅ Security hardened with proper temp file and signal handling
- ✅ Self-contained (~56KB including docs)

**shlock:**
- ✅ Required by bcs-compliance agent
- ✅ Small single script (~16KB)
- ✅ No external dependencies

**trim:**
- ✅ Pure Bash string manipulation utilities
- ✅ Zero external dependencies
- ✅ Useful for script development
- ✅ Dual-mode (command-line and sourceable functions)

**timer:**
- ✅ Pure Bash high-precision timing
- ✅ Zero external dependencies
- ✅ Microsecond precision for benchmarking
- ✅ Useful for performance analysis

**post_slug:**
- ✅ URL/filename slug generation
- ✅ UTF-8 to ASCII conversion
- ✅ Useful for web applications and file naming
- ✅ Minimal dependencies (sed, iconv, tr)

**hr2int:**
- ✅ Human-readable number conversion
- ✅ Useful for capacity/size calculations
- ✅ Bidirectional conversion (hr↔int)
- ✅ Minimal dependencies (numfmt)

**remblanks:**
- ✅ Tiny utility for config file processing
- ✅ Fast comment/blank line stripping
- ✅ Minimal dependencies (grep)

---

## Total Size

**Vendored dependencies:** ~492KB total
- agents/: 16KB
- md2ansi/: 60KB
- mdheaders/: 54KB
- whichx/: 45KB
- dux/: 56KB
- shlock/: 16KB
- trim/: 92KB
- timer/: 47KB
- post_slug/: 40KB
- hr2int/: 3KB
- remblanks/: 1KB
- LICENSES/: 286KB (incl. mdheaders, whichx, dux GPL v3)

This is a negligible increase for a repository of this size, and the benefit of "works immediately after git clone" is well worth it.

---

## External Dependencies (Not Vendored)

These tools should be installed by users via package manager:

- **Bash 5.2+** - Required (system shell)
- **ShellCheck** - Required for validation (`apt install shellcheck`)
- **Claude Code CLI** - Optional for AI features (install from https://claude.com/code)

See main README.md Prerequisites section for installation instructions.

#fin
