## Language Best Practices

#### Command Substitution
Always use `$()` instead of backticks for command substitution.

```bash
#  Correct - modern syntax
var=$(command)
result=$(cat "$file" | grep pattern)

#  Wrong - deprecated syntax
var=`command`
result=`cat "$file" | grep pattern`
```

**Rationale:** `$()` provides better readability, nests without escaping, has superior syntax highlighting, and is the modern POSIX preference.

**Nesting example:**
```bash
#  Easy to read with $()
outer=$(echo "inner: $(date +%T)")

#  Confusing with backticks (requires escaping)
outer=`echo "inner: \`date +%T\`"`
```

#### Builtin Commands vs External Commands
Always prefer shell builtins over external commands for performance and reliability.

```bash
#  Good - bash builtins
addition=$((x + y))
string=${var^^}  # uppercase
string=${var,,}  # lowercase
if [[ -f "$file" ]]; then

#  Avoid - external commands
addition=$(expr "$x" + "$y")
string=$(echo "$var" | tr '[:lower:]' '[:upper:]')
string=$(echo "$var" | tr '[:upper:]' '[:lower:]')
if [ -f "$file" ]; then
```

**Rationale:** Builtins are 10-100x faster (no process creation), have no PATH dependencies, are guaranteed in bash, and avoid subshell/pipe failures.

**Common replacements:**

| External Command | Builtin Alternative | Example |
|-----------------|---------------------|---------|
| `expr` | `$(())` | `$((x + y))` instead of `$(expr $x + $y)` |
| `basename` | `${var##*/}` | `${path##*/}` instead of `$(basename "$path")` |
| `dirname` | `${var%/*}` | `${path%/*}` instead of `$(dirname "$path")` |
| `tr` (case) | `${var^^}` or `${var,,}` | `${str,,}` instead of `$(echo "$str" \| tr A-Z a-z)` |
| `test`/`[` | `[[` | `[[ -f "$file" ]]` instead of `[ -f "$file" ]` |
| `seq` | `{1..10}` or `for ((i=1; i<=10; i++))` | Much faster for loops |

**When external commands are necessary:**
```bash
# Some operations have no builtin equivalent
checksum=$(sha256sum "$file")
current_user=$(whoami)
sorted_data=$(sort "$file")
```
