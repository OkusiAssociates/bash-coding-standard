# BASH-CODING-STANDARD.md Data Tree

This directory contains the decomposed source files for `BASH-CODING-STANDARD.md`. The standard is organized into a navigable directory tree with each rule in its own file, supporting a four-tier documentation system.

---

## Directory Structure

```
data/
├── 00-header.{tier}.md                 # Document title, principles, table of contents
├── BASH-CODING-STANDARD.md             # Symlink → default tier (currently .summary.md)
├── BASH-CODING-STANDARD.complete.md    # Compiled full standard (610 KB)
├── BASH-CODING-STANDARD.summary.md     # Compiled condensed standard (373 KB)
├── BASH-CODING-STANDARD.abstract.md    # Compiled high-level overview (109 KB)
├── BASH-CODING-STANDARD.rulet.md       # Compiled concise rules (72 KB)
├── README.md                           # This file
│
├── 01-script-structure/                # Section 1: Script Structure & Layout
│   ├── 00-section.{tier}.md            #   Section introduction
│   ├── 00-script-structure.rulet.md    #   Condensed rules for section
│   ├── 01-layout.{tier}.md             #   BCS0101: Script Layout
│   ├── 01-layout/                      #   Subrule directory
│   │   ├── 01-complete-example.{tier}.md   # BCS010101
│   │   ├── 02-anti-patterns.{tier}.md      # BCS010102
│   │   └── 03-edge-cases.{tier}.md         # BCS010103
│   ├── 02-shebang.{tier}.md            #   BCS0102: Shebang
│   ├── 02-shebang/                     #   Subrule directory
│   │   └── 01-dual-purpose.{tier}.md       # BCS010201
│   ├── 03-metadata.{tier}.md           #   BCS0103: Metadata
│   └── ...                             #   (7 rules + 4 subrules total)
│
├── 02-variables/                       # Section 2: Variable Declarations & Constants
│   ├── 00-section.{tier}.md
│   ├── 00-variables.rulet.md
│   ├── 01-declarations.{tier}.md       #   BCS0201
│   └── ...                             #   (8 rules total)
│
├── 03-expansion/                       # Section 3: Variable Expansion
├── 04-quoting/                         # Section 4: Quoting & String Literals (15 rules)
├── 05-arrays/                          # Section 5: Arrays
├── 06-functions/                       # Section 6: Functions
├── 07-control-flow/                    # Section 7: Control Flow
├── 08-error-handling/                  # Section 8: Error Handling
├── 09-io-messaging/                    # Section 9: Input/Output & Messaging
├── 10-command-line-args/               # Section 10: Command-Line Arguments
├── 11-file-operations/                 # Section 11: File Operations
├── 12-security/                        # Section 12: Security Considerations
├── 13-code-style/                      # Section 13: Code Style & Best Practices
├── 14-advanced-patterns/               # Section 14: Advanced Patterns (10 rules)
│
└── templates/                          # BCS-compliant script templates
    ├── minimal.sh.template             #   ~13 lines - bare essentials
    ├── basic.sh.template               #   ~27 lines - standard scaffold
    ├── complete.sh.template            #   ~104 lines - full toolkit
    └── library.sh.template             #   ~38 lines - sourceable library
```

**Note:** `{tier}` = `complete` | `summary` | `abstract`

---

## Four-Tier Documentation System

The standard exists in four tiers with decreasing detail levels:

| Tier | Extension | Purpose | Size Limit |
|------|-----------|---------|------------|
| **Complete** | `.complete.md` | Full detail, all examples, canonical source | None |
| **Summary** | `.summary.md` | Condensed, key examples retained | ≤10,000 bytes |
| **Abstract** | `.abstract.md` | High-level overview, minimal examples | ≤1,500 bytes |
| **Rulet** | `.rulet.md` | Highly condensed rule list (section-level) | Varies |

### Tier Hierarchy

```
.complete.md  (SOURCE - manually edited)
    ↓ bcs compress
.summary.md   (DERIVED - ~62% of complete)
    ↓ bcs compress
.abstract.md  (DERIVED - ~18% of complete)

Separate: .rulet.md (Extracted via bcs generate-rulets)
```

### Compiled Standard Sizes

| Tier | Lines | Size |
|------|-------|------|
| Complete | 24,333 | 610 KB |
| Summary | 15,117 | 373 KB |
| Abstract | 4,439 | 109 KB |
| Rulet | 714 | 72 KB |

### Default Tier

The default tier is controlled by the symlink:
```
BASH-CODING-STANDARD.md → BASH-CODING-STANDARD.summary.md
```

Change the default with: `bcs default complete`

---

## File Naming Conventions

### Section Introduction Files

Each section directory contains an introduction file:
```
00-section.complete.md
00-section.summary.md
00-section.abstract.md
```

### Rule Files

Rules use numeric prefixes with descriptive names:
```
{NN}-{rule-name}.complete.md
{NN}-{rule-name}.summary.md
{NN}-{rule-name}.abstract.md
```

**Examples:**
```
01-layout.complete.md       # BCS0101
02-shebang.complete.md      # BCS0102
05-readonly-after-group.complete.md  # BCS0205
```

### Subrule Directories

When a rule has subrules, create a subdirectory:
```
02-shebang/
└── 01-dual-purpose.complete.md   # BCS010201
```

### Rulet Files

One condensed rulet file per section:
```
00-{category}.rulet.md
```

**Examples:**
```
00-script-structure.rulet.md
00-variables.rulet.md
00-error-handling.rulet.md
```

### Header Files

Top-level header files for each tier:
```
00-header.complete.md
00-header.summary.md
00-header.abstract.md
00-header.rulet.md
```

---

## BCS Code Mapping

### Code Format

`BCS{section}{rule}[{subrule}]` - All numbers are **two-digit zero-padded**

| Code | Level | Example Path |
|------|-------|--------------|
| `BCS01` | Section | `01-script-structure/00-section.*.md` |
| `BCS0102` | Rule | `01-script-structure/02-shebang.*.md` |
| `BCS010201` | Subrule | `01-script-structure/02-shebang/01-dual-purpose.*.md` |
| `BCS0205` | Rule | `02-variables/05-readonly-after-group.*.md` |

### Directory to Code Mapping

```
data/01-script-structure/              → BCS01 (Section)
├── 00-section.*.md                    → (Section intro, no code)
├── 02-shebang.*.md                    → BCS0102 (Rule)
├── 02-shebang/01-dual-purpose.*.md    → BCS010201 (Subrule)
└── 03-metadata.*.md                   → BCS0103 (Rule)
```

### Lookup Commands

```bash
bcs codes                     # List all 107+ BCS codes
bcs decode BCS0102            # Get file path
bcs decode BCS0102 -p         # Print content
bcs decode BCS0102 --all      # Show all tier paths
```

---

## Editing Workflow

### Modifying Rules

**Important:** Only edit `.complete.md` files. Summary and abstract are derived.

```bash
# 1. Edit the canonical source
vim data/02-variables/05-readonly-after-group.complete.md

# 2. Regenerate derived tiers (summary, abstract)
bcs compress --regenerate

# 3. Rebuild compiled standard files
bcs generate --canonical

# 4. Verify your changes
bcs decode BCS0205 -p
```

### Adding New Rules

1. Create `.complete.md` file with correct numeric prefix
2. Run `bcs compress --regenerate` to generate summary/abstract
3. Run `bcs generate --canonical` to rebuild standards
4. Verify with `bcs codes | grep {code}`

### Deleting Rules

1. Remove all tier files for the rule
2. Run `bcs generate --canonical` to rebuild standards
3. Verify removal with `bcs codes`

### Warning

Never directly edit:
- `.summary.md` files (derived from complete)
- `.abstract.md` files (derived from complete)
- `BASH-CODING-STANDARD.*.md` compiled files (generated)

---

## Templates

Four BCS-compliant templates in `templates/`:

| Template | Lines | Contents |
|----------|-------|----------|
| `minimal.sh.template` | ~13 | `set -euo pipefail`, `error()`, `die()`, `main()` |
| `basic.sh.template` | ~27 | + VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME |
| `complete.sh.template` | ~104 | + colors, VERBOSE/DEBUG, full messaging, arg parsing |
| `library.sh.template` | ~38 | Sourceable pattern, no `set -e`, `declare -fx` exports |

### Placeholders

Templates use these placeholders:
- `{{NAME}}` - Script name
- `{{DESCRIPTION}}` - Script description
- `{{VERSION}}` - Version string (default: 1.0.0)

### Usage

```bash
bcs template -t minimal -o quick.sh -x
bcs template -t complete -n deploy -d "Deployment script" -v 2.0.0 -o deploy.sh -x
bcs template -t library -n utils -o lib-utils.sh
```

---

## Header Levels

Consistent markdown heading levels across all files:

| Level | Usage |
|-------|-------|
| `##` | Section headers (e.g., "## Script Structure & Layout") |
| `###` | Rule headers (e.g., "### Shebang and Initial Setup") |
| `####` | Sub-sections within rules |

---

## Statistics

### File Counts

| Category | Count |
|----------|-------|
| Total markdown files | 341 |
| Complete tier files | 108 |
| Summary tier files | 108 |
| Abstract tier files | 108 |
| Rulet files | 16 |
| Template files | 4 |

### Structure Counts

| Category | Count |
|----------|-------|
| Section directories | 14 |
| Main rules | 98 |
| Subrule directories | 2 (in section 01) |
| Subrules | 4 |
| Total BCS codes | 107+ |

### Directory Size

- **Total data/ directory:** ~4.4 MB
- **Compiled standards:** ~1.2 MB (all 4 tiers)

---

## Benefits of This Structure

- **Navigability**: Easy to find and edit specific rules
- **Modularity**: Each rule in its own file
- **Version control**: Cleaner git diffs when rules change
- **Collaboration**: Multiple contributors can work on different sections
- **Maintainability**: Easy to add, remove, or reorganize content
- **Multi-tier support**: Same content at different detail levels
- **Machine-parseable**: Consistent structure for AI and tooling

---

## See Also

- `bcs generate --canonical` - Rebuild all compiled standard files
- `bcs compress --regenerate` - Regenerate summary/abstract from complete
- `bcs codes` - List all BCS codes
- `bcs decode` - Look up rules by BCS code
- `../BCS/` - Numeric-indexed symlink structure for quick lookups
- `../CLAUDE.md` - AI assistant instructions for this repository

#fin
