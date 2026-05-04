<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.4 `eval` avoidance

`eval` re-parses its argument as shell input. Any data that flows into the
argument becomes executable shell. The BCS prohibition (BCS1004) is
absolute outside of literals the script itself constructed.

The most common misuse — by an order of magnitude — is dynamic variable
naming: building a variable name from input and assigning to it via `eval`.
Bash 4.3+ provides namerefs (`declare -n`) and associative arrays
(`declare -A`) that solve this without re-parsing.

```bash
# scenario: dynamic-name assignment driven by user input
# wrong — eval re-parses the right-hand side
key=$1; value=$2
eval "var_$key=$value"
# attacker invokes:  ./script "x; rm -rf \$HOME #" "anything"
# ⇒ shell sees: var_x; rm -rf $HOME #=anything
```

The right-hand side is fully attacker-controlled in two places: the variable
name (`$key`) and the value (`$value`). Quoting the value does not help —
`eval` strips one layer of quoting before re-parsing.

```bash
# scenario: same dynamic-name assignment, refactored with a nameref
declare -- key=$1 value=$2
[[ $key =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || die 22 'invalid key'
declare -n ref="var_$key"
ref=$value                          # ⇒ regular assignment, no re-parse
unset -n ref
```

The nameref still requires the *name* to be validated as a shell identifier
(BCS1005) — bash will reject `ref=...` if the target name contains
metacharacters, but only after the assignment is attempted, and the error
message leaks the bad name. Validate up-front.

For variable-by-key registries the cleaner pattern is an associative array,
which sidesteps name-construction entirely:

```bash
# scenario: keyed registry; key is data, not a variable name
declare -A registry=()
registry[$key]=$value               # ⇒ key is data; no shell parsing of it
echo "${registry[$key]}"
```

The registry pattern dominates the nameref pattern when the keys are truly
data; reserve namerefs for the rare case where downstream code expects to
read a fixed variable name.

The other notorious misuse is `eval "$(getopt …)"` for argument parsing.
Replace it with the hand-rolled parser pattern (BCS0801) — a `while`/`case`
loop that walks `"$@"` directly. The few cases where `eval` survives audit
in production scripts are: re-executing a saved command line built entirely
from validated literals, and `eval "$(ssh-agent -s)"` style wrappers where
the producer is trusted and the consumer immediately exits on failure.

For every surviving `eval`, add a comment naming the trust boundary:

```bash
# eval: input is the output of `ssh-agent -s` (trusted local fork)
eval "$(ssh-agent -s)"
```

### Indirect expansion without `eval`

A frequent reason developers reach for `eval` is to read a variable whose
name is held in another variable. Bash provides `${!ref}` indirection for
exactly this — no re-parse required:

```bash
# scenario: read a value via a name held in another variable
# wrong — eval re-evaluates the entire RHS
eval "echo \$var_$key"

# right — bash parameter indirection
declare -- name="var_$key"
echo "${!name}"                     # ⇒ value of var_$key, no re-parse
```

Indirection still expects the *name* to be a valid identifier; validate
`$key` as in the nameref example above.

### Auditing existing code

Treat every `eval` as a comment-required event. A repository sweep looks
like:

```bash
# scenario: locate every eval call site for review
grep -rnE '\beval\b' --include='*.bash' --include='*.sh' . || true
# (rc=1 is fine — it just means no `eval` calls found)
```

Triage each hit into one of three buckets: trusted-literal (keep with
comment), refactor-candidate (replace with nameref/assoc-array/`${!ref}`),
or outright removal. The third category is the largest in most legacy
codebases.

### Why `declare`, `local`, `printf -v` are not safer

A common confusion: `declare "var_$key=$value"` and `local "var_$key=$value"`
*do* re-parse the right-hand side under expansion, though not as a full
shell command. `printf -v "var_$key" '%s' "$value"` is the genuinely safe
version because `printf -v` accepts the variable name as data and the
value via format processing only. When namerefs are not available
(targeting bash < 4.3), use `printf -v`:

```bash
# scenario: bash 4.2 fallback for dynamic-name assignment
[[ $key =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || die 22 'invalid key'
printf -v "var_$key" '%s' "$value"  # ⇒ name is data, value is data
```

**See also**: §20.5 command-injection vectors, §20.6 input validation,
BCS1004 eval avoidance, BCS0801 standard parsing pattern.

#fin
