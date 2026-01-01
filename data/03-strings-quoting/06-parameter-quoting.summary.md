### Parameter Quoting with @Q

**Rule: BCS0306**

`${parameter@Q}` expands to a shell-quoted value safe for display and re-use.

---

#### The @Q Operator

```bash
name='hello world'
echo "${name@Q}"      # Output: 'hello world'

name='$(rm -rf /)'
echo "${name@Q}"      # Output: '$(rm -rf /)' (safe, literal)
```

---

#### Primary Use: Error Messages

```bash
# ✗ Wrong - injection risk
die 2 "Unknown option $1"
die 2 "Unknown option '$1'"

# ✓ Correct - safe display
die 2 "Unknown option ${1@Q}"

# Validation function
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

---

#### Dry-Run Display

```bash
run_command() {
  local -a cmd=("$@")
  if ((DRY_RUN)); then
    local -- quoted_cmd
    printf -v quoted_cmd '%s ' "${cmd[@]@Q}"
    info "[DRY-RUN] Would execute: $quoted_cmd"
    return 0
  fi
  "${cmd[@]}"
}
```

---

#### Comparison

| Input | `$var` | `"$var"` | `${var@Q}` |
|-------|--------|----------|------------|
| `hello world` | splits | `hello world` | `'hello world'` |
| `$(date)` | executes | executes | `'$(date)'` |
| `*.txt` | globs | `*.txt` | `'*.txt'` |

---

#### When to Use

**Use @Q for:** Error messages, logging user input, dry-run output

**Don't use @Q for:** Normal variable expansion, comparisons

**Key principle:** Use `${parameter@Q}` when displaying user input in error messages to prevent injection.

#fin
