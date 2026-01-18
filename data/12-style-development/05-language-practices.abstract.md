## Language Best Practices

**Use `$()` for command substitution and prefer builtins over external commands for 10-100x performance gains.**

### Command Substitution
Use `$()` not backticks → nests naturally, better readability.

```bash
# ✓ Modern - nests cleanly
outer=$(echo "inner: $(date +%T)")

# ✗ Deprecated - requires escaping
outer=`echo "inner: \`date +%T\`"`
```

### Builtins vs External Commands
Builtins: no process spawn, no PATH dependency, no pipe failures.

| External | Builtin |
|----------|---------|
| `expr $x + $y` | `$((x + y))` |
| `basename "$p"` | `${p##*/}` |
| `dirname "$p"` | `${p%/*}` |
| `tr A-Z a-z` | `${var,,}` |
| `[ -f ]` | `[[ -f ]]` |
| `seq 1 10` | `{1..10}` |

```bash
# ✓ Builtin - instant
result=$((i * 2))
string=${var,,}

# ✗ External - spawns process each call
result=$(expr $i \* 2)
```

Use externals only when no builtin exists (sha256sum, sort, whoami).

**Ref:** BCS1205
