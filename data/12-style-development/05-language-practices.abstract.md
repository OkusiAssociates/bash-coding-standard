## Language Best Practices

**Use `$()` for command substitution and prefer builtins over external commands (10-100x faster).**

### Command Substitution
Use `$()` â†' readable, nestable, better editor support. Never use backticks.

```bash
outer=$(echo "inner: $(date +%T)")  # âœ“ nests naturally
outer=`echo "inner: \`date +%T\`"`  # âœ— requires escaping
```

### Builtins vs External Commands
Prefer builtinsâ€”no process creation, no PATH dependency, no pipe failures.

| External | Builtin |
|----------|---------|
| `expr $x + $y` | `$((x + y))` |
| `basename "$p"` | `${p##*/}` |
| `dirname "$p"` | `${p%/*}` |
| `tr A-Z a-z` | `${var,,}` |
| `[ -f "$f" ]` | `[[ -f "$f" ]]` |
| `seq 1 10` | `{1..10}` |

### Anti-Patterns

```bash
var=`command`              # â†' var=$(command)
$(expr "$x" + "$y")        # â†' $((x + y))
[ -f "$file" ]             # â†' [[ -f "$file" ]]
```

**Ref:** BCS1205
