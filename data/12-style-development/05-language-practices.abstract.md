## Language Best Practices

**Use `$()` for command substitution; prefer builtins over external commands (10-100x faster).**

### Command Substitution
Always `$()` â†' never backticks. Nests naturally without escaping.

```bash
outer=$(echo "inner: $(date +%T)")   # âœ“ Clean nesting
outer=`echo "inner: \`date +%T\`"`   # âœ— Requires escaping
```

### Builtins vs External Commands

| External | Builtin | Example |
|----------|---------|---------|
| `expr` | `$(())` | `$((x + y))` |
| `basename` | `${var##*/}` | `${path##*/}` |
| `dirname` | `${var%/*}` | `${path%/*}` |
| `tr` (case) | `${var^^}` `${var,,}` | `${str,,}` |
| `test`/`[` | `[[` | `[[ -f "$file" ]]` |
| `seq` | `{1..10}` | Brace expansion |

```bash
# âœ“ Builtin - instant (no process creation)
result=$((i * 2))
string=${var,,}

# âœ— External - spawns process each call
result=$(expr $i \* 2)
string=$(echo "$var" | tr A-Z a-z)
```

**Use external only when no builtin exists:** `sha256sum`, `sort`, `whoami`.

### Anti-patterns
- `` `command` `` â†' `$(command)`
- `[ -f "$file" ]` â†' `[[ -f "$file" ]]`
- `$(expr $x + $y)` â†' `$((x + y))`

**Ref:** BCS1205
