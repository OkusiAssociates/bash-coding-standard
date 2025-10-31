## Language Best Practices

**Use `$()` for command substitution, never backticks.** `$()` nests naturally without escaping, has better syntax highlighting, and is more readable. Backticks require escaping (`\``) when nested.

**Prefer shell builtins over external commands.** Builtins are 10-100x faster (no process creation), guaranteed available, and have no PATH dependencies.

```bash
#  Builtins
result=$((x + y))
upper=${var^^}
lower=${var,,}
base=${path##*/}
dir=${path%/*}
[[ -f "$file" ]]

#  External commands
result=$(expr "$x" + "$y")
upper=$(echo "$var" | tr '[:lower:]' '[:upper:]')
base=$(basename "$path")
[ -f "$file" ]
```

**Common replacements:** `expr` ’ `$(())`, `basename` ’ `${var##*/}`, `dirname` ’ `${var%/*}`, `tr` (case) ’ `${var^^}` / `${var,,}`, `test`/`[` ’ `[[`, `seq` ’ `{1..10}` or `((i=1; i<=10; i++))`.

**Rationale:** Performance (no subshell/process spawn), reliability (no external dependencies), portability (guaranteed in bash).

**Ref:** BCS1305
