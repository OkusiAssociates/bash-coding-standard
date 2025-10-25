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

**Size:** ~60KB (main script + 5 library files)

**Used by:** `bcs display` command (optional enhancement)

**Upstream:** https://github.com/Open-Technology-Foundation/md2ansi.bash
**Git commit:** `6e8d7dc28e341232388875287f48c5c47a5c6d3e`
**Last synced:** 2025-10-18 14:38:51 +0800

**License:** MIT (see LICENSES/md2ansi.LICENSE)

**Contents:**
- `md2ansi` - Main markdown renderer script
- `lib/ansi-colors.sh` - ANSI color definitions
- `lib/parser.sh` - Markdown parsing engine
- `lib/renderer.sh` - ANSI rendering engine
- `lib/tables.sh` - Table rendering support
- `lib/utils.sh` - Utility functions

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
cp /ai/scripts/Markdown/md2ansi.bash/lib/*.sh lib/md2ansi/lib/
chmod +x lib/md2ansi/md2ansi

# Update this README with new git commit hash
cd /ai/scripts/Markdown/md2ansi.bash
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

**shlock:**
- ✅ Required by bcs-compliance agent
- ✅ Small single script (~16KB)
- ✅ No external dependencies

---

## Total Size

**Vendored dependencies:** ~168KB total
- agents/: 16KB
- md2ansi/: 60KB
- shlock/: 16KB
- LICENSES/: 76KB

This is a negligible increase for a repository of this size, and the benefit of "works immediately after git clone" is well worth it.

---

## External Dependencies (Not Vendored)

These tools should be installed by users via package manager:

- **Bash 5.2+** - Required (system shell)
- **ShellCheck** - Required for validation (`apt install shellcheck`)
- **Claude Code CLI** - Optional for AI features (install from https://claude.com/code)

See main README.md Prerequisites section for installation instructions.

#fin
