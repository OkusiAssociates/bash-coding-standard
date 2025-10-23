# BCS/ Directory Structure

## Overview

The `BCS/` directory provides a **numeric-only** parallel structure to the `data/` directory, making BCS code lookups fast and predictable. All files are **relative symlinks** pointing back to their source files in `data/`.

## Purpose

1. **Direct BCS code mapping**: `BCS0102` → `BCS/01/02.{tier}.md`
2. **Editor integration**: Quickly open rules by BCS code
3. **Programmatic access**: Simple path construction from BCS codes
4. **Three-tier support**: All files available in complete/summary/abstract variants

## Structure

```
BCS/
├── 00.{tier}.md           # Header files
├── 01/                    # Section 01 (Script Structure)
│   ├── 00.{tier}.md       # Section introduction (BCS01)
│   ├── 01.{tier}.md       # Rule 01 (BCS0101)
│   ├── 01/                # Subrules for rule 01
│   │   ├── 01.{tier}.md   # Subrule 01 (BCS010101)
│   │   ├── 02.{tier}.md   # Subrule 02 (BCS010102)
│   │   └── 03.{tier}.md   # Subrule 03 (BCS010103)
│   ├── 02.{tier}.md       # Rule 02 (BCS0102)
│   ├── 02/                # Subrules for rule 02
│   │   └── 01.{tier}.md   # Subrule 01 (BCS010201)
│   └── ...
├── 02/                    # Section 02 (Variables)
│   ├── 00.{tier}.md       # Section introduction (BCS02)
│   ├── 01.{tier}.md       # Rule 01 (BCS0201)
│   ├── 05.{tier}.md       # Rule 05 (BCS0205)
│   └── ...
└── ...                    # Sections 03-14

{tier} = complete | summary | abstract
```

## BCS Code to Path Mapping

### Section Codes (2 digits)
- **BCS01** → `BCS/01/00.{tier}.md`
- **BCS02** → `BCS/02/00.{tier}.md`
- **BCS14** → `BCS/14/00.{tier}.md`

### Rule Codes (4 digits)
- **BCS0102** → `BCS/01/02.{tier}.md`
- **BCS0205** → `BCS/02/05.{tier}.md`
- **BCS1402** → `BCS/14/02.{tier}.md`

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

## Relative Symlinks

All symlinks are **relative**, making the structure portable:

```bash
# From BCS/01/02.complete.md
../../data/01-script-structure/02-shebang.complete.md

# From BCS/01/02/01.complete.md
../../../data/01-script-structure/02-shebang/01-dual-purpose.complete.md
```

**Benefits**:
- Works regardless of repository location
- Git-friendly (no absolute paths)
- Safe for moving or copying the repository

## Statistics

- **Total symlinks**: 318
- **Total directories**: 17 (root + 14 sections + 2 subrule containers)
- **Files per rule**: 3 (complete, summary, abstract)

## Rebuilding

The structure is rebuilt using:

```bash
./rebuild-bcs-directory.sh
```

This script:
1. Removes existing `BCS/` directory
2. Creates fresh numeric structure
3. Generates relative symlinks for all files
4. Processes sections 00-14
5. Handles nested subrule directories

**When to rebuild**:
- After adding new rules to `data/`
- After renaming rules
- After reorganizing sections
- If symlinks become broken

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
cat "$(./test-bcs-lookup.sh BCS0102)"

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
# Count files
find BCS -type l | wc -l     # Should be 318
find BCS -type d | wc -l     # Should be 17

# Test symlinks
file BCS/01/02.complete.md   # Should show relative path
cat BCS/01/02.complete.md    # Should display content

# Test lookups
./test-bcs-lookup.sh         # Should show all tests passing
```

## Troubleshooting

**Broken symlinks**:
```bash
find BCS -type l ! -exec test -e {} \; -print
```

**Missing files**:
```bash
./test-bcs-lookup.sh | grep "✗"
```

**Rebuild from scratch**:
```bash
rm -rf BCS/
./rebuild-bcs-directory.sh
```

## Future Enhancements

Potential improvements:
1. **Auto-regeneration**: Hook into git pre-commit to rebuild if `data/` changed
2. **Tier selection**: Environment variable `BCS_DEFAULT_TIER`
3. **Caching**: Pre-compute commonly accessed paths
4. **Validation**: Detect missing tier variants (rule has complete but not abstract)
5. **Shell completion**: Bash/Zsh completion for BCS codes

## See Also

- `rebuild-bcs-directory.sh` - Regeneration script
- `test-bcs-lookup.sh` - Lookup demonstration and testing
- `BASH-CODING-STANDARD.md` - Primary documentation (symlink determines default tier)
- `CLAUDE.md` - Repository documentation for AI assistants

#fin
