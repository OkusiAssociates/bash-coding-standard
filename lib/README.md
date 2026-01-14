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
**Git commit:** `908f6306b3fce8c2d02af556e91aeb8527ad5009`
**Last synced:** 2026-01-13 14:36:53 +0800

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
**Git commit:** `94af891abaedcf2038ca2c3b19f2d1925a989709`
**Last synced:** 2025-12-31 09:36:02 +0800

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
**Git commit:** `5e9bf7351e8e880d734751df6033e39eb1e5c1f9`
**Last synced:** 2026-01-13 12:24:47 +0800

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
**Git commit:** `461f872245cdfd97daca41292f417113e845ee6a`
**Last synced:** 2026-01-13 12:17:30 +0800

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

### printline/ - Terminal Line Drawing Utility

**Purpose:** Draw a line from cursor position to end of terminal

**Size:** ~52KB (script + docs + version file)

**Used by:** Terminal output formatting, section dividers, header decoration

**Upstream:** /ai/scripts/printline (internal YaTTI tool)
**Git commit:** `5e6428871a638c3f6bc080c42bbe192ff917b5bd`
**Last synced:** 2025-10-09 10:11:35 +0800

**License:** GPL v3 (see LICENSES/printline.LICENSE)

**Contents:**
- `printline` - Main line drawing script (v1.0.0)
- `.version` - Version file (sourced by --help)
- `README.md` - Complete documentation with examples
- `LICENSE` - GPL v3 license

**Features:**
- ✅ Intelligent cursor position detection
- ✅ Customizable character (default '-')
- ✅ Optional prefix text
- ✅ Fast terminal width detection (uses $COLUMNS first)
- ✅ Dual-mode (executable or sourceable function)
- ✅ TTY-aware (graceful fallback for non-interactive use)

**Installed to system:**
- `printline` installed to `/usr/local/bin/printline`
- Usage: `printline [char [text]]`
- Examples:
  - `printline` - Draw line with default '-' character
  - `printline '='` - Draw line with '=' character
  - `echo -n "Section: "; printline '#'` - Print text then line
  - `printline '*' '# Header '` - Print prefix then line
  - `source printline; printline '-' 'Section: '` - Use as function

**Note:** GPL v3 is a copyleft license, distinct from BCS's CC BY-SA 4.0.

---

### bcx/ - Terminal Calculator with REPL

**Purpose:** Floating-point calculator with interactive REPL mode

**Size:** ~44KB (script + docs + LICENSE)

**Used by:** Quick calculations from command line or scripts

**Upstream:** /ai/scripts/bcx (internal YaTTI tool)
**Git commit:** `4b3338dac5259496da47ea13378e420be3023936`
**Last synced:** 2026-01-08 09:05:48 +0800

**License:** GPL v3 (see LICENSES/bcx.LICENSE)

**Contents:**
- `bcx` - Main calculator script (v1.0.0)
- `README.md` - Complete documentation with examples
- `LICENSE` - GPL v3 license

**Features:**
- ✅ Interactive REPL with readline history (arrow keys, Ctrl-R search)
- ✅ Single-expression mode for quick calculations
- ✅ Persistent command history (~/.bcx_history)
- ✅ x → * conversion in terminal mode (e.g., `3x4` becomes `3*4`)
- ✅ Clean error handling with clear feedback
- ✅ Math library support (sqrt, sin, cos, atan, log, exp, etc.)
- ✅ Proper Ctrl-C handling in REPL mode
- ✅ BCS-compliant implementation

**Installed to system:**
- `bcx` installed to `/usr/local/bin/bcx`
- Usage: `bcx [expression]`
- Examples:
  - `bcx "3.14 * 2"` - Quick calculation (returns 6.28)
  - `bcx "sqrt(144)"` - Math functions (returns 12)
  - `bcx 42x72/3.14` - x converts to * (returns ~963.8)
  - `bcx` - Interactive REPL mode
  - `result=$(bcx "42 * 72 / 3.14")` - Use in scripts

**Dependencies:** bc (command-line calculator)

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
**Git commit:** `4e345b55d6cf8961760440f2d55103aa90834515`
**Last synced:** 2026-01-13 14:36:19 +0800

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
**Git commit:** `79bcd61bcbede56e7b593d1d1758be907ad2b8ee`
**Last synced:** 2025-10-26 07:08:48 +0800

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
**Git commit:** `f132ecea3631bd1add3afc50d713b064109eae06`
**Last synced:** 2026-01-13 14:26:19 +0800

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

**License:** ▲️ No explicit license (internal YaTTI utility)

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

**License:** ▲️ No explicit license (internal YaTTI utility)

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

### Update printline

```bash
# Sync with upstream
cd /ai/scripts/printline
git pull

# Copy to BCS lib/
cd /ai/scripts/Okusi/bash-coding-standard
cp /ai/scripts/printline/printline lib/printline/
cp /ai/scripts/printline/.version lib/printline/
chmod +x lib/printline/printline

# Update this README with new git commit hash
cd /ai/scripts/printline
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

**printline:**
- ✅ Elegant terminal line drawing utility
- ✅ Useful for script output formatting and section dividers
- ✅ Dual-mode operation (executable or sourceable)
- ✅ Intelligent cursor position detection
- ✅ Self-contained (~52KB including docs)

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

## Automated Sync System

### Using sync-lib.sh

The repository includes an automated sync utility that updates all vendored dependencies at once:

```bash
# Sync all libraries from upstream
./lib/sync-lib.sh

# Dry-run mode (show what would be synced)
./lib/sync-lib.sh --dry-run

# Sync specific library only
./lib/sync-lib.sh md2ansi
```

**Output format:**
```
◉ Syncing 12 libraries from /ai/scripts...
✓ shlock    synced (16KB)
✓ trim      synced (92KB, with docs)
✓ timer     synced (47KB, with docs)
...
◉ Total: 12 libraries synced, ~544KB
```

### Sync Manifest (.sync-manifest)

Located at `lib/.sync-manifest`, this file configures which dependencies to sync and how:

**Format:**
```
lib_subdir|upstream_path|file_pattern|copy_docs
```

**Fields:**
- `lib_subdir` - Target directory under `lib/` (e.g., `shlock`, `md2ansi`)
- `upstream_path` - Source directory (e.g., `/ai/scripts/lib/shlock`)
- `file_pattern` - Files to copy (space-separated, supports braces: `{a,b,c}.bash`)
- `copy_docs` - Copy `LICENSE` and `README.md`? (`yes` or `no`)

**Example entries:**
```bash
shlock|/ai/scripts/lib/shlock|shlock|no
trim|/ai/scripts/lib/str/trim|{trim,ltrim,rtrim,trimall,squeeze,trimv}.bash|yes
md2ansi|/ai/scripts/Markdown/md2ansi.bash|md2ansi md lib/*.sh|yes
bcx|/ai/scripts/bcx|bcx|yes
```

**Note:** The `.sync-manifest` file is gitignored to allow per-environment customization. A template is committed as `lib/.sync-manifest.template`.

**Special handling:**
- **agents/** - Excluded from auto-sync (vendored versions are customized for portability)
- Upstream agent versions hardcode `/ai/scripts` paths unsuitable for distribution

---

## Dependency Graph

**Installation dependencies:**
```
bcs (main script)
├── md2ansi (optional, enhances display)
├── mdheaders (independent utility)
├── whichx (independent utility)
├── dux (independent utility)
├── printline (independent utility)
├── bcx (independent utility)
└── agents/
    ├── bcs-rulet-extractor (uses Claude CLI)
    └── bcs-compliance (uses shlock, Claude CLI)
        └── shlock (MIT licensed, required by agent)
```

**Runtime dependencies:**
- **md2ansi** → Uses `lib/*.sh` (ansi-colors, parser, renderer, tables, utils)
- **mdheaders** → Requires `libmdheaders.bash` library
- **bcx** → Requires `bc` command-line calculator
- **bcs-compliance** → Requires `shlock` for locking
- **agents** → Require Claude Code CLI (`claude` command in PATH)

**No circular dependencies** - All dependencies are one-way and can be used independently.

---

## Integration Patterns

### Sourcing Vendored Libraries

**In your own scripts:**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Source trim functions
# shellcheck source=/dev/null
source /usr/local/share/yatti/bash-coding-standard/lib/trim/trim.bash
source /usr/local/share/yatti/bash-coding-standard/lib/trim/ltrim.bash

# Use the functions
cleaned=$(trim "  hello world  ")
echo "$cleaned"  # Output: "hello world"
```

**Using installed commands:**

```bash
# After 'sudo make install', these are in PATH:
md file.md                    # View markdown with pagination
mdheaders upgrade -l 2 doc.md # Upgrade headers by 2 levels
which python                  # Find command (uses whichx)
dux /var                      # Analyze directory sizes
printline '='                 # Draw horizontal line
bcx "3.14 * 2"                # Quick calculation
bcx                           # Interactive calculator REPL
```

**Sourcing from lib/ in development:**

```bash
# From bash-coding-standard directory
source lib/trim/trim.bash
source lib/timer/timer

# Use timer function
timer ls -la
# Output: Command executed in 0.003214 seconds
```

### Portable Path Resolution

**Best practice for finding vendored libs:**

```bash
# Portable library locator
find_lib_path() {
  local -- lib_name=$1

  # Check vendored path (development)
  if [[ -d "${SCRIPT_DIR}/../lib/$lib_name" ]]; then
    echo "${SCRIPT_DIR}/../lib/$lib_name"
    return 0
  fi

  # Check system installation
  if [[ -d "/usr/local/share/yatti/bash-coding-standard/lib/$lib_name" ]]; then
    echo "/usr/local/share/yatti/bash-coding-standard/lib/$lib_name"
    return 0
  fi

  return 1
}

# Use it
trim_path=$(find_lib_path trim) || die "trim library not found"
source "$trim_path/trim.bash"
```

---

## Common Issues & Troubleshooting

### Issue: "md2ansi: command not found"

**Cause:** BCS not installed system-wide, or `/usr/local/bin` not in PATH

**Solution:**
```bash
# Option 1: Install system-wide
sudo make install

# Option 2: Use vendored version directly
./lib/md2ansi/md2ansi file.md

# Option 3: Add to PATH temporarily
export PATH="$PWD/lib/md2ansi:$PATH"
```

### Issue: "bcs-rulet-extractor requires Claude Code CLI"

**Cause:** `claude` command not in PATH

**Solution:**
```bash
# Check if Claude Code is installed
which claude || echo "Not installed"

# Install Claude Code (see https://claude.com/code)
# Or skip rulet generation - not required for basic usage
```

### Issue: "shlock: Permission denied"

**Cause:** Lock file directory not writable

**Solution:**
```bash
# shlock uses /tmp by default - ensure writable
ls -ld /tmp
# Should show: drwxrwxrwt (sticky bit set)

# Or specify custom lock directory
export TMPDIR="$HOME/.cache"
```

### Issue: Symlink conflicts during `make install`

**Cause:** Development symlinks in `/usr/local/bin/` pointing to `/ai/scripts`

**Solution:**
```bash
# make install detects and warns about symlinks
# Choose one:
# 1. Remove symlinks and continue (y)
# 2. Cancel installation (n) and remove manually:

rm /usr/local/bin/bcs /usr/local/bin/md2ansi /usr/local/bin/md
rm /usr/local/bin/mdheaders /usr/local/bin/whichx /usr/local/bin/dir-sizes
rm /usr/local/bin/printline

# Then retry: sudo make install
```

### Issue: "trim.bash: No such file or directory"

**Cause:** Sourcing script file instead of symlink, or missing symlinks

**Solution:**
```bash
# Recreate trim symlinks
cd lib/trim
ln -sf trim.bash trim
ln -sf ltrim.bash ltrim
ln -sf rtrim.bash rtrim
ln -sf trimall.bash trimall
ln -sf squeeze.bash squeeze
ln -sf trimv.bash trimv
```

### Issue: Different behavior between vendored and system versions

**Cause:** Version mismatch - vendored version may be older/newer than system

**Solution:**
```bash
# Check vendored version
./lib/md2ansi/md2ansi --version

# Check system version
md2ansi --version

# Force use of vendored version
./lib/md2ansi/md2ansi file.md

# Or update vendored version
./lib/sync-lib.sh md2ansi
```

---

## Development Workflow

### Contributing Changes Back to Upstream

**When you modify vendored libraries:**

1. **Test changes** in vendored location first
2. **Copy changes back** to upstream repository
3. **Commit upstream** with proper message
4. **Update sync manifest** if file patterns changed
5. **Document in this README** under "Last synced"

**Example workflow:**

```bash
# 1. Modify vendored version
vim lib/timer/timer
./lib/timer/timer ls  # Test

# 2. Copy to upstream
cp lib/timer/timer /ai/scripts/lib/timer/

# 3. Commit upstream
cd /ai/scripts/lib/timer
git add timer
git commit -m "Fix: Handle negative time values correctly"
git push

# 4. Update lib/README.md
cd /ai/scripts/Okusi/bash-coding-standard
# Update git commit hash and sync date for timer section

# 5. Commit to BCS
git add lib/timer/timer lib/README.md
git commit -m "Update vendored timer library (fix negative time handling)"
```

### Adding New Vendored Dependencies

**Steps:**

1. **Evaluate necessity** - Is vendoring justified? (size, usage, dependencies)
2. **Add to .sync-manifest** - Configure sync source and pattern
3. **Run sync** - `./lib/sync-lib.sh new-lib`
4. **Copy LICENSE** - `cp /path/to/LICENSE lib/LICENSES/new-lib.LICENSE`
5. **Update Makefile** - Add installation rules (if command-line tool)
6. **Update lib/README.md** - Add comprehensive documentation section
7. **Update main README.md** - Add to bundled dependencies list
8. **Test installation** - `sudo make install && new-lib --version`
9. **Commit** - Detailed commit message explaining why vendored

**Checklist:**
- [ ] Added to .sync-manifest
- [ ] Synced to lib/new-lib/
- [ ] LICENSE copied to lib/LICENSES/
- [ ] Makefile updated (if CLI tool)
- [ ] lib/README.md documented
- [ ] Main README.md updated
- [ ] Installation tested
- [ ] Size documented (~XXX KB)

---

## Testing Considerations

### Testing With Vendored Dependencies

**Test priority order:**

1. **Vendored versions** - Test from `lib/` directory (what users get)
2. **Installed versions** - Test from `/usr/local/bin/` (after `make install`)
3. **System versions** - Test fallback behavior (if system version exists)

**Test isolation:**

```bash
# Test vendored version exclusively
PATH="/tmp/empty:$PATH" ./lib/md2ansi/md2ansi file.md

# Test installed version exclusively
PATH="/usr/local/bin:/usr/bin:/bin" md2ansi file.md

# Test with system version priority
PATH="/usr/bin:/usr/local/bin" md2ansi file.md
```

### Test Suite Integration

**Current test coverage:**

- `tests/test-data-structure.sh` - Validates all vendored files exist
- `tests/test-environment.sh` - Tests md2ansi availability and fallback
- `tests/test-integration.sh` - Tests command-line tools integration

**When adding new vendored tools:**

1. Add existence check to `test-data-structure.sh`
2. Add functionality test to `test-integration.sh` (if CLI tool)
3. Test both vendored and installed paths
4. Test graceful degradation if missing

**Example test:**

```bash
test_new_lib_availability() {
  test_section "New Lib Availability Tests"

  # Test vendored version exists
  if [[ -f "$PROJECT_DIR/lib/new-lib/new-lib" ]]; then
    pass "Vendored new-lib exists"
  else
    fail "Vendored new-lib missing"
  fi

  # Test functionality
  local -- output
  output=$(./lib/new-lib/new-lib --version 2>&1 || true)

  if [[ "$output" =~ [0-9]+\.[0-9]+ ]]; then
    pass "new-lib reports version"
  else
    fail "new-lib version check failed"
  fi
}
```

---

## Performance Characteristics

### Startup Time Impact

**Fast (< 1ms overhead):**
- ✅ **shlock** - Simple file-based locking
- ✅ **remblanks** - Single grep invocation
- ✅ **hr2int** - Pure Bash arithmetic
- ✅ **printline** - Pure Bash, no subprocesses

**Medium (1-10ms overhead):**
- ▲️ **trim** - Pure Bash string manipulation (no subshells)
- ▲️ **whichx** - PATH search with stat calls
- ▲️ **timer** - Uses EPOCHREALTIME (Bash 5.0+ feature)

**Heavier (10-100ms overhead):**
- ▲️ **md2ansi** - Loads 5 library files (~60KB total)
- ▲️ **mdheaders** - Loads libmdheaders.bash (~20KB)
- ▲️ **post_slug** - Calls iconv, sed, tr subprocesses
- ▲️ **dux** - Spawns du subprocess (unavoidable)

**Slow (> 100ms):**
- ❌ **Claude agents** - Network calls to Claude API (seconds)

### Runtime Performance

**Benchmark comparisons (1000 iterations):**

```bash
# trim vs sed (trimming whitespace)
timer -f for i in {1..1000}; do trim "  hello  "; done
# Pure Bash: 0.234s

timer -f for i in {1..1000}; do echo "  hello  " | sed 's/^ *//;s/ *$//'; done
# Subprocess: 2.104s (9x slower)

# whichx vs which (finding command)
timer -f for i in {1..100}; do whichx ls >/dev/null; done
# whichx: 0.089s

timer -f for i in {1..100}; do which ls >/dev/null; done
# which: 0.156s (1.75x slower, but negligible)
```

**Recommendation:** For tight loops, prefer pure Bash utilities (trim, timer, printline) over subprocess-heavy tools (post_slug, dux).

---

## Security Considerations

### SUID/SGID Restrictions

**▲️ Important:** Per BCS rules, **never** use SUID or SGID on Bash scripts.

All vendored utilities follow this rule:
```bash
# Check - none should have setuid/setgid
find lib/ -type f -perm /6000
# Output: (empty - correct)
```

### PATH Manipulation

**Vendored tools installed to /usr/local/bin/** take precedence over system versions in `/usr/bin/`. This is intentional but be aware:

- ✅ `whichx` → Symlinked as `which`, shadows `/usr/bin/which`
- ✅ `dir-sizes` → Symlinked as `dux`, new command (no conflict)
- ✅ `md2ansi`, `mdheaders`, `printline` → New commands (no conflict)

**Security best practice:**

```bash
# Lock down PATH in production scripts
readonly PATH=/usr/local/bin:/usr/bin:/bin
export PATH

# Or validate commands explicitly
command -v md2ansi >/dev/null || die "md2ansi not found"
```

### Input Validation

**Tools with user input:**

- **mdheaders** - Validates header level boundaries (H1-H6)
- **post_slug** - Sanitizes strings but requires validation of UTF-8 input
- **hr2int** - Validates numeric suffixes, rejects malformed input
- **whichx** - Validates command names against PATH

**When integrating:**

```bash
# Always validate before passing to vendored tools
validate_markdown_file() {
  local -- file=$1
  [[ -f "$file" ]] || die "File not found: $file"
  [[ -r "$file" ]] || die "File not readable: $file"
  [[ "$file" =~ \.md$ ]] || warn "Not a markdown file: $file"
}

validate_markdown_file "$input"
mdheaders upgrade -l 2 "$input"
```

### Temporary Files

**Tools using temp files:**

- **dux** - Creates temp file in `$TMPDIR` (default `/tmp`), cleaned on exit
- **shlock** - Creates lock files in `$TMPDIR` (default `/tmp`)

**Security hardening:**

```bash
# Use user-specific temp directory
export TMPDIR="$HOME/.cache/bcs"
mkdir -p "$TMPDIR"
chmod 700 "$TMPDIR"

# Now tools use secure temp location
dux /var  # Uses ~/.cache/bcs/
```

### License Compliance

**GPL v3 copyleft considerations:**

Most vendored tools are GPL v3 (copyleft):
- md2ansi (MIT - permissive)
- mdheaders (GPL v3)
- whichx (GPL v3)
- dux (GPL v3)
- printline (GPL v3)
- trim (GPL v3)
- timer (GPL v3)
- post_slug (GPL v3)
- shlock (MIT - permissive)

**The BCS itself is CC BY-SA 4.0** (documentation license, compatible).

**Implication:** If you redistribute bash-coding-standard, you must:
1. Include all LICENSE files from `lib/LICENSES/`
2. Provide source code for GPL v3 components (satisfied: source is vendored)
3. Document GPL v3 status in distributions

**Makefile handles this automatically** - All licenses copied to `/usr/local/share/yatti/bash-coding-standard/lib/LICENSES/` during installation.

---

## Version Requirements

### Bash Version Compatibility

**Minimum Bash versions required:**

| Tool | Min Bash | Feature Used | Fallback |
|------|----------|--------------|----------|
| **bcs** | 5.2 | `${var@Q}`, `shopt shift_verbose` | None |
| **md2ansi** | 4.0 | Associative arrays | None |
| **mdheaders** | 4.0 | Associative arrays | None |
| **whichx** | 4.0 | `mapfile` | Manual array building |
| **dux** | 4.0 | Basic features | None |
| **printline** | 4.0 | `$COLUMNS`, arithmetic | None |
| **shlock** | 3.0 | File locking with `flock` | None |
| **trim** | 4.0 | Parameter expansion | None |
| **timer** | 5.0 | `$EPOCHREALTIME` | `date +%s.%N` |
| **post_slug** | 4.0 | Basic features | None |
| **hr2int** | 4.0 | Arithmetic | None |
| **remblanks** | 3.0 | Basic grep | None |
| **agents** | 5.0 | Process substitution | None |

**Check your Bash version:**

```bash
bash --version | head -1
# Output: GNU bash, version 5.2.15(1)-release (x86_64-pc-linux-gnu)
```

**Recommendation:** Use Bash 5.2+ for full compatibility with all tools and BCS itself.

### External Command Dependencies

**Required by vendored tools:**

- **md2ansi** - `tput` (ncurses-bin), `less` (for `md` wrapper)
- **mdheaders** - None (pure Bash)
- **whichx** - `stat` (coreutils)
- **dux** - `du`, `sort` (coreutils)
- **printline** - `tput` (optional, falls back)
- **shlock** - `flock` (util-linux)
- **trim** - None (pure Bash)
- **timer** - None (pure Bash)
- **post_slug** - `iconv`, `sed`, `tr` (coreutils)
- **hr2int** - `numfmt` (coreutils)
- **remblanks** - `grep` (coreutils)

**Install missing dependencies:**

```bash
# Debian/Ubuntu
sudo apt-get install coreutils ncurses-bin util-linux less

# Fedora/RHEL
sudo dnf install coreutils ncurses util-linux less

# macOS (most included, coreutils may need GNU versions)
brew install coreutils
```

---

## Total Size

**Vendored dependencies:** ~544KB total
- agents/: 16KB
- md2ansi/: 60KB
- mdheaders/: 54KB
- whichx/: 45KB
- dux/: 56KB
- printline/: 52KB
- bcx/: 44KB
- shlock/: 16KB
- trim/: 92KB
- timer/: 47KB
- post_slug/: 40KB
- hr2int/: 3KB
- remblanks/: 1KB
- LICENSES/: 356KB (incl. mdheaders, whichx, dux, printline, bcx GPL v3)

This is a negligible increase for a repository of this size, and the benefit of "works immediately after git clone" is well worth it.

---

## External Dependencies (Not Vendored)

These tools should be installed by users via package manager:

- **Bash 5.2+** - Required (system shell)
- **bc** - Required for bcx calculator (`apt install bc`)
- **ShellCheck** - Required for validation (`apt install shellcheck`)
- **Claude Code CLI** - Optional for AI features (install from https://claude.com/code)

See main README.md Prerequisites section for installation instructions.

#fin
