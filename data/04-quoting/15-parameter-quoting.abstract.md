## Parameter Quoting with `${parameter@Q}`

**Use `${parameter@Q}` to safely quote parameter values in error messages, logging, and debug output.**

**Rationale:** Prevents injection attacks by displaying user input literally without expansion; shows exact values including whitespace and metacharacters.

**Primary use cases:**

1. **Error messages** - Safe display of user input:
```bash
die 2 "Unknown option ${1@Q}"
# Input: --opt='$(rm -rf /)'  ’ Output: Unknown option '$(rm -rf /)'
```

2. **Argument validation:**
```bash
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

3. **Debug/logging** - Show exact values:
```bash
debug "Processing ${filename@Q}"
printf -v cmd '%s ' "${cmd_array[@]@Q}"  # Dry-run display
```

**Comparison:**

| Input | `"$var"` | `${var@Q}` |
|-------|----------|------------|
| `hello world` | `hello world` | `'hello world'` |
| `$(date)` | *executes* | `'$(date)'` (literal) |
| `$HOME` | */home/user* | `'$HOME'` (literal) |

**Use for:** Error messages, logging user input, debug output, dry-run displays

**Don't use for:** Normal logic (`process "$file"`), data output, assignments, comparisons

**Anti-pattern:**
```bash
#  Wrong - injection risk
die 2 "Unknown option $1"
#  Correct
die 2 "Unknown option ${1@Q}"
```

**Ref:** BCS0415
