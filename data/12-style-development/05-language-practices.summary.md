## Language Best Practices

#### Command Substitution
Always use `$()` instead of backticks.

```bash
# ✓ Correct
var=$(command)

# ✗ Wrong - deprecated
var=`command`
```

**Rationale:** `$()` is clearer, nests naturally without escaping, has better editor support.

**Nesting:**
```bash
# ✓ Easy with $()
outer=$(echo "inner: $(date +%T)")

# ✗ Confusing with backticks
outer=`echo "inner: \`date +%T\`"`
```

#### Builtin Commands vs External Commands
Prefer shell builtins for performance (10-100x faster) and reliability.

```bash
# ✓ Good - builtins
addition=$((x + y))
string=${var^^}  # uppercase
string=${var,,}  # lowercase
if [[ -f "$file" ]]; then

# ✗ Avoid - external commands
addition=$(expr "$x" + "$y")
string=$(echo "$var" | tr '[:lower:]' '[:upper:]')
if [ -f "$file" ]; then
```

**Rationale:** Builtins have no process creation overhead, no PATH dependency, no external binary requirements.

**Common replacements:**

| External Command | Builtin Alternative | Example |
|-----------------|---------------------|---------|
| `expr` | `$(())` | `$((x + y))` |
| `basename` | `${var##*/}` | `${path##*/}` |
| `dirname` | `${var%/*}` | `${path%/*}` |
| `tr` (case) | `${var^^}` / `${var,,}` | `${str,,}` |
| `test`/`[` | `[[` | `[[ -f "$file" ]]` |
| `seq` | `{1..10}` or `for ((i=1; i<=10; i+=1))` | Brace expansion |

**When externals are necessary:**
```bash
checksum=$(sha256sum "$file")
current_user=$(whoami)
sorted_data=$(sort "$file")
```
