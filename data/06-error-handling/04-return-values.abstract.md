## Checking Return Values

**Always check return values explicitlyâ€”`set -e` misses pipelines, conditionals, and command substitution.**

**Why:** Better error messages with context â†' Controlled recovery/cleanup â†' Catches `set -e` blind spots â†' Debugging aid

**`set -e` blind spots:** Pipelines (except last) â†' Conditionals (`if cmd`) â†' Command substitution in assignments â†' Commands with `||`

**Patterns:**

```bash
# Pattern 1: || die (concise)
mv "$src" "$dst" || die 1 "Failed to move ${src@Q}"

# Pattern 2: || { } (with cleanup)
mv "$tmp" "$final" || { rm -f "$tmp"; die 1 "Move failed"; }

# Pattern 3: Capture $?
wget "$url"; case $? in 0) ;; 4) die 4 'Network failure' ;; esac

# Pattern 4: Command substitution
output=$(cmd) || die 1 'cmd failed'

# Pattern 5: PIPESTATUS for pipelines
cat f | grep p; ((PIPESTATUS[0])) && die 1 'cat failed'
```

**Edge cases:**
- Pipelines: Use `set -o pipefail` or check `PIPESTATUS[]`
- Command substitution: Add `|| die` or use `shopt -s inherit_errexit`
- Conditionals: Add explicit `die` in else branch

**Anti-patterns:**

```bash
# âœ— No check after command
mv "$f" "$d"

# âœ— Generic error message
mv "$f" "$d" || die 1 'failed'

# âœ— $? checked too late
cmd1; cmd2; (($?))  # Checks cmd2!

# âœ— No cleanup on failure
cp "$s" "$d" || exit 1  # Leaves partial file
```

**Ref:** BCS0604
