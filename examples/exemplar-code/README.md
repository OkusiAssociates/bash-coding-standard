# Exemplar Code Reference

Production-grade scripts demonstrating BCS patterns. Use these as references when inline examples in the standard are condensed.

---

## Scripts Overview

| Script | Lines | Primary Patterns |
|--------|-------|------------------|
| **clip** | 408 | Core messaging, color support, option parsing |
| **checkpoint** | 2748 | Trap handling, temp files, SSH, concurrency |
| **cln** | 197 | File operations, validation |
| **dir-sizes** | 167 | Loops, arrays, arithmetic |
| **hr2int/int2hr** | 109 | Function libraries, dual-purpose |
| **install.sh** | 353 | Installation script, user prompts, file operations |
| **internetip** | 335 | Dual-purpose scripts, function export |
| **lsd** | 100 | Simple script structure |
| **md2ansi** | 1460 | Here documents, string processing |
| **nukedir** | 249 | Security patterns, dry-run |
| **oknav** | 751 | Parallel execution, dispatcher, TUI |
| **ok_master** | 129 | SSH wrapper, error handling |
| **common.inc.sh** | 274 | Sourced library, associative arrays |
| **validip** | 74 | Pure function library |
| **watchip** | 168 | Logging, monitoring patterns |
| **whichx** | 161 | Conditional logic, PATH handling |

---

## Pattern Index

### BCS01: Script Structure & Layout

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| 13-step structure | `clip` | 1-60 | Complete script organization |
| Shebang | `clip` | 1 | `#!/usr/bin/env bash` |
| set -euo pipefail | `clip` | 10 | Error handling initialization |
| shopt settings | `clip` | 11 | `inherit_errexit shift_verbose extglob nullglob` |
| Metadata block | `clip` | 14-16 | VERSION, SCRIPT_PATH, SCRIPT_NAME |
| main() function | `clip` | 350-408 | Entry point pattern |
| #fin marker | `clip` | 408 | End of script indicator |

### BCS02: Variables & Data Types

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| Type declarations | `clip` | 18-20 | `declare -i`, `declare --` |
| Boolean flags | `clip` | 18 | `declare -i COMPRESS=0` |
| Readonly pattern | `checkpoint` | 20-26 | `readonly -- VAR1 VAR2` |
| Indexed arrays | `oknav/oknav` | 45 | `declare -a SERVERS=()` |
| Associative arrays | `oknav/common.inc.sh` | 129-131 | `declare -A ALIAS_TO_FQDN=()` |
| Derived variables | `clip` | 15 | `SCRIPT_NAME=${SCRIPT_PATH##*/}` |

### BCS03: Strings & Quoting

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| Single quotes (static) | `clip` | 42 | `prefix+=" ${GREEN}...${NC}"` |
| Double quotes (vars) | `clip` | 46 | `for msg in "$@"` |
| Parameter expansion | `checkpoint` | 26 | `${SCRIPT_PATH##*/}` |
| Here document | `md2ansi` | 200-250 | `<<'EOF'` (quoted) |

### BCS04: Functions & Libraries

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| Function definition | `clip` | 31-47 | `function_name() { ... }` |
| Local variables | `clip` | 32 | `local -- status="..."` |
| Function export | `internetip/internetip` | 29 | `declare -fx func1 func2` |
| Dual-purpose script | `internetip/internetip` | 1-40 | Sourced + executed modes |
| Library pattern | `internetip/validip` | 1-74 | Pure function library |

### BCS05: Control Flow

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| [[ ]] conditionals | `clip` | 28 | `[[ -t 2 ]] && ...` |
| (( )) arithmetic | `clip` | 43 | `((VERBOSE)) || return 0` |
| Case statement | `clip` | 35-42 | `case "$status" in` |
| for loop (array) | `oknav/oknav` | 475-485 | `for server in "${SERVERS[@]}"` |
| while (args) | `clip` | 290-340 | `while (($# > 0)); do` |
| Process substitution | `checkpoint` | 450 | `< <(find ...)` |

### BCS06: Error Handling

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| die() function | `clip` | 47 | `die() { ... exit "${1:-0}"; }` |
| Trap cleanup | `checkpoint` | 85-110 | `trap 'cleanup $?' EXIT` |
| Exit code checking | `oknav/oknav` | 680 | `cmd || { exit_code=$?; ... }` |
| Error suppression | `clip` | 47 | `|| :` pattern |

### BCS07: I/O & Messaging

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| Color initialization | `clip` | 28 | TTY detection + declare |
| _msg() core | `clip` | 31-46 | FUNCNAME-based polymorphism |
| info/warn/error/die | `clip` | 43-47 | Standard message functions |
| STDOUT vs STDERR | `clip` | 43-46 | `>&2 _msg` for errors |
| Icon usage | `clip` | 35-42 | `◉ ▲ ✓ ✗` |

### BCS08: Command-Line Arguments

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| while/case parsing | `clip` | 290-340 | Standard option parsing |
| Short option deaggregation | `oknav/oknav` | 547-550 | `-pD` → `-p -D` |
| Option with value | `clip` | 300-305 | `-o DIR` pattern |
| Positional args | `clip` | 335 | Collect after options |

### BCS09: File Operations

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| File testing | `cln` | 45 | `[[ -f "$file" ]]` |
| Wildcard safety | `nukedir` | 100 | `./*` not `*` |
| Temp file handling | `checkpoint` | 500-520 | `mktemp` pattern |

### BCS10: Security

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| PATH safety | `checkpoint` | 17 | `export PATH=/usr/local/bin:...` |
| Input validation | `nukedir` | 60-80 | Path checking |
| No eval | All | - | Never used |

### BCS11: Concurrency & Jobs (NEW)

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| Background jobs | `oknav/oknav` | 475-490 | `cmd &; pids+=($!)` |
| Wait for jobs | `oknav/oknav` | 492-500 | `for pid in "${pids[@]}"; wait` |
| Parallel execution | `oknav/oknav` | 465-510 | Full parallel pattern |
| Timeout handling | `oknav/oknav` | 676 | `timeout "$T"s cmd` |
| Exponential backoff | `checkpoint` | 850-870 | `sleep $((2**attempt))` |

### BCS12: Style & Development

| Pattern | Script | Lines | Description |
|---------|--------|-------|-------------|
| 2-space indent | All | - | Consistent throughout |
| Comments | `checkpoint` | 40-60 | Section markers |
| Dry-run mode | `nukedir` | 85-95 | `((DRY_RUN)) && info ...` |
| Debug output | `clip` | - | `debug()` function |

---

## Usage in Documentation

When referencing exemplar code in the standard:

```markdown
**Full implementation**: See `examples/exemplar-code/clip` lines 31-47
```

Or for specific patterns:

```markdown
For a complete dual-purpose script example, see `internetip/internetip`.
```

---

## Adding New Exemplar Code

1. Script must be BCS-compliant (verified with `bcs check`)
2. Add symlink: `ln -s /path/to/script examples/exemplar-code/name`
3. Update this README with pattern locations
4. Run tests to verify symlink resolves

---

## Script Locations

All symlinks point to production scripts:

```
exemplar-code/
├── checkpoint → /ai/scripts/File/checkpoint/checkpoint
├── clip → /ai/scripts/clip/clip
├── cln → /ai/scripts/File/cln/cln
├── dir-sizes → /ai/scripts/File/dux/dir-sizes
├── hr2int → /ai/scripts/lib/hr2int/hr2int
├── install.sh → /ai/scripts/Okusi/oknav/install.sh
├── int2hr → /ai/scripts/lib/hr2int/int2hr
├── lsd → /ai/scripts/File/lsd/lsd
├── md2ansi → /ai/scripts/Markdown/md2ansi.bash/md2ansi
├── nukedir → /ai/scripts/File/nukedir/nukedir
├── whichx → /ai/scripts/File/whichx/whichx
├── internetip/
│   ├── internetip → /ai/scripts/Okusi/internetip/internetip
│   ├── validip → /ai/scripts/Okusi/internetip/validip
│   └── watchip → /ai/scripts/Okusi/internetip/watchip
└── oknav/
    ├── oknav → /ai/scripts/Okusi/oknav/oknav
    ├── ok_master → /ai/scripts/Okusi/oknav/ok_master
    └── common.inc.sh → /ai/scripts/Okusi/oknav/common.inc.sh
```

#fin
