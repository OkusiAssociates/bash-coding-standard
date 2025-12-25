# BCS/ Directory Structure

## Overview

The `BCS/` directory provides a **numeric-indexed** parallel structure to the `data/` directory, making BCS code lookups fast and predictable. The structure combines descriptive directory names (mirroring `data/`) with numeric symlink shortcuts for convenience. All symlinks use **relative paths**, making the structure fully portable across different systems and repository locations.

## Purpose

1. **Direct BCS code mapping**: `BCS0102` → `BCS/01/02.{tier}.md`
2. **Editor integration**: Quickly open rules by BCS code
3. **Programmatic access**: Simple path construction from BCS codes
4. **Three-tier support**: All files available in complete/summary/abstract variants

## Structure

The BCS/ directory uses a **hybrid approach**:
- Descriptive directories mirror `data/` structure (e.g., `01-script-structure/`)
- Numeric symlinks provide shortcuts (e.g., `01` → `01-script-structure/`)
- This enables both human-readable paths AND quick BCS code lookups

```
BCS/
├── 00.{tier}.md                    # Header files (symlinks to data/)
├── 01 → 01-script-structure/       # Numeric shortcut (relative symlink)
├── 01-script-structure/            # Real directory (descriptive name)
│   ├── 00.{tier}.md                # Section introduction (BCS01)
│   ├── 01 → 01-layout/             # Numeric shortcut
│   ├── 01-layout/                  # Real directory
│   │   ├── 01.{tier}.md            # Subrule 01 (BCS010101)
│   │   ├── 02.{tier}.md            # Subrule 02 (BCS010102)
│   │   └── 03.{tier}.md            # Subrule 03 (BCS010103)
│   ├── 01.{tier}.md                # Rule 01 (BCS0101)
│   ├── 02 → 02-shebang/            # Numeric shortcut
│   ├── 02-shebang/                 # Real directory
│   │   └── 01.{tier}.md            # Subrule 01 (BCS010201)
│   ├── 02.{tier}.md                # Rule 02 (BCS0102)
│   └── ...
├── 02 → 02-variables/              # Numeric shortcut
├── 02-variables/                   # Real directory
│   ├── 00.{tier}.md                # Section introduction (BCS02)
│   ├── 01.{tier}.md                # Rule 01 (BCS0201)
│   ├── 05.{tier}.md                # Rule 05 (BCS0205)
│   └── ...
└── ...                             # Sections 03-12

{tier} = complete | summary | abstract
```

## BCS Code to Path Mapping

### Section Codes (2 digits)
- **BCS01** → `BCS/01/00.{tier}.md`
- **BCS02** → `BCS/02/00.{tier}.md`
- **BCS12** → `BCS/12/00.{tier}.md`

### Rule Codes (4 digits)
- **BCS0102** → `BCS/01/02.{tier}.md`
- **BCS0205** → `BCS/02/05.{tier}.md`
- **BCS1202** → `BCS/12/02.{tier}.md`

### Subrule Codes (6 digits)
- **BCS010201** → `BCS/01/02/01.{tier}.md`
- **BCS010101** → `BCS/01/01/01.{tier}.md`

### Sub-subrule Codes (8+ digits)
- **BCS01020103** → `BCS/01/02/01/03.{tier}.md`

## Algorithm

To convert a BCS code to a path:

1. Strip `BCS` prefix: `BCS0102` → `0102`
2. Split into 2-digit chunks: `0102` → `01`, `02`
3. Join with `/`: `BCS/01/02`
4. Add tier: `BCS/01/02.complete.md`
5. Special case: Section codes (2 digits) use `00.{tier}.md`

## Symlink Types

All symlinks in BCS/ use **relative paths**, making the structure fully portable:

### File Symlinks (321 .md files)

All `.md` file symlinks use **relative paths** to source files:

```bash
# From BCS/01-script-structure/02.complete.md
../../data/01-script-structure/02-shebang.complete.md

# From BCS/01-script-structure/02-shebang/01.complete.md
../../../data/01-script-structure/02-shebang/01-dual-purpose.complete.md

# From BCS/00.complete.md
../data/00-header.complete.md
```

### Directory Shortcuts (16 numeric symlinks)

Numeric directory shortcuts also use **relative paths**:

```bash
# From BCS/01
01-script-structure/

# From BCS/01-script-structure/02
02-shebang/
```

**Benefits**:
- ✓ Fully portable - works regardless of repository location
- ✓ Git-friendly (no absolute paths)
- ✓ Safe for moving, copying, or archiving the repository
- ✓ Numeric shortcuts (01, 02, etc.) enable the `BCS/01/02.md` path syntax

## Statistics

- **Total symlinks**: ~319 (all relative)
  - ~303 file symlinks (.md files to data/)
  - ~14 directory symlinks (12 sections + subrule shortcuts)
- **Total directories**: 15 (root + 12 sections + 2 subrule containers)
- **Files per rule**: 3 (complete, summary, abstract)

## Rebuilding

The structure is rebuilt using:

```bash
bcs generate --canonical
```

This command:
1. Removes existing `BCS/` directory (preserves `.claude/` subdirectory if present)
2. Creates fresh hybrid structure (descriptive directories + numeric shortcuts)
3. Generates relative symlinks for all files and directories
4. Processes sections 00-12
5. Handles nested subrule directories

**When to rebuild**:
- After adding new rules to `data/`
- After renaming rules
- After reorganizing sections
- If symlinks become broken

## Implementation Details

The BCS/ directory uses **relative symlinks** for all files and directories, implemented in the `rebuild_bcs_index()` function using `realpath --relative-to` to calculate appropriate relative paths at each nesting level.

**Benefits**:
- ✓ Fully portable - works regardless of repository location
- ✓ Fast and reliable lookup
- ✓ Git-friendly - symlinks work immediately after cloning
- ✓ Archive-friendly - tar/zip extracts work without rebuild
- ✓ No broken symlinks when moving/copying repository

**Relative path calculation**:
The script automatically computes the correct number of `../` prefixes based on directory depth:
- Root level: `../data/...`
- Section level: `../../data/...`
- Subrule level: `../../../data/...`

This ensures BCS/ can be copied anywhere and symlinks continue to work.

## Example Usage

### Bash Function for Lookup

```bash
bcs_to_path() {
  local code=$1
  local tier=${2:-complete}

  code=${code#BCS}  # Strip BCS prefix
  local len=${#code}
  local path="BCS"

  if ((len == 2)); then
    # Section: BCS01 -> BCS/01/00.tier.md
    path="$path/${code}/00.$tier.md"
  elif ((len == 4)); then
    # Rule: BCS0102 -> BCS/01/02.tier.md
    path="$path/${code:0:2}/${code:2:2}.$tier.md"
  elif ((len == 6)); then
    # Subrule: BCS010201 -> BCS/01/02/01.tier.md
    path="$path/${code:0:2}/${code:2:2}/${code:4:2}.$tier.md"
  fi

  echo "$path"
}

# Usage
vim "$(bcs_to_path BCS0102)"
cat "$(bcs_to_path BCS010201 abstract)"
```

### Editor Integration

**Vim/Neovim**:
```vim
" Open BCS rule under cursor
nnoremap <leader>b :execute '!vim $(bcs_to_path ' . expand('<cword>') . ')'<CR>
```

**VS Code** (with shell script):
```bash
code "$(bcs_to_path "$1")"
```

### Command-Line Access

```bash
# View complete tier
bcs decode BCS0102 -c -p

# Compare tiers
diff BCS/01/02/01.{abstract,complete}.md

# Search within a rule
grep -i "set -e" BCS/08/01.complete.md
```

## Integration with bcs Command

The `bcs decode` command uses this structure:

```bash
# Default tier (from BASH-CODING-STANDARD.md symlink)
bcs decode BCS0102

# Print content directly
bcs decode BCS0102 -p

# Force specific tier
bcs decode BCS0102 -c -p  # complete
bcs decode BCS0102 -a -p  # abstract

# Show all tiers
bcs decode BCS0102 --all

# Multiple codes
bcs decode BCS01 BCS02 BCS08 -p
```

**Note**: The `bcs decode` command resolves BCS codes directly to source files in the `data/` directory using an internal mapping algorithm. It does not rely on the BCS/ symlink structure for lookups, though both use the same BCS code → path mapping logic. The BCS/ directory primarily serves as a convenience for manual navigation and editor integration.

## Relationship to data/ Directory

**data/** (source):
- Descriptive directory names: `01-script-structure/`
- Descriptive file names: `02-shebang.complete.md`
- Human-readable organization
- **Canonical source files** (edit here)

**BCS/** (lookup):
- Numeric-only names: `01/02.complete.md`
- Direct BCS code mapping
- Machine-friendly structure
- **Symlinks to source files** (do not edit)

## Source Control

The `BCS/` directory should be:
- ✓ **Committed to git** (the symlinks, not their targets)
- ✓ **Tracked** (enables clone-and-use)
- ✗ **Not gitignored** (users need the structure)
- ✗ **Not manually edited** (regenerate instead)

## Verification

After rebuilding, verify:

```bash
# Count total symlinks and directories
find BCS -type l | wc -l     # Should be ~319
find BCS -type d | wc -l     # Should be 15

# Verify all symlinks are relative (not absolute)
find BCS -type l -lname "/*" | wc -l      # Should be 0 (no absolute paths)
find BCS -type l ! -lname "/*" | wc -l    # Should be ~319 (all relative)

# Test symlinks
readlink BCS/01-script-structure/02.complete.md   # Should show ../../data/...
cat BCS/01/02.complete.md                         # Should display content (via numeric shortcut)

# Test lookups with bcs decode
bcs decode BCS01 BCS0102 BCS010201 --all          # Verify all codes resolve
```

## Troubleshooting

**Broken symlinks**:
```bash
find BCS -type l ! -exec test -e {} \; -print
```

**Missing files**:
```bash
# Test various codes to ensure files exist
bcs decode BCS01 BCS02 BCS08 --all
```

**Rebuild from scratch**:
```bash
bcs generate --canonical
```

Note: The `--canonical` flag automatically rebuilds the BCS/ index directory after generating all four tier files.

## Future Enhancements

Potential improvements:
1. **Auto-regeneration**: Hook into git pre-commit to rebuild if `data/` changed
2. **Tier selection**: Environment variable `BCS_DEFAULT_TIER`
3. **Caching**: Pre-compute commonly accessed paths
4. **Validation**: Detect missing tier variants (rule has complete but not abstract)
5. **Shell completion**: Bash/Zsh completion for BCS codes

## See Also

- `bcs generate --canonical` - Regenerate standard and rebuild BCS/ index
- `bcs decode` - Look up and view BCS rules by code
- `BASH-CODING-STANDARD.md` - Primary documentation (symlink determines default tier)
- `CLAUDE.md` - Repository documentation for AI assistants
- `bcs help generate` - Full documentation for the generate subcommand
- `bcs help decode` - Full documentation for the decode subcommand

#fin
