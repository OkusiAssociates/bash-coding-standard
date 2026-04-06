# Endless Loop Constructs: `while ((1))` vs `while :` vs `while true`

Three ways to write an infinite loop in Bash. All are correct; they
differ in mechanism and speed. BCS recommends `while ((1))`. See BCS0503.

## Quick Comparison

| Construct      | Type              | POSIX | Speed   |
|----------------|-------------------|:-----:|---------|
| `while ((1))`  | Arithmetic eval   | No    | Fastest |
| `while :`      | Builtin command   | Yes   | ~14% slower |
| `while true`   | Builtin command   | Yes   | ~21% slower |

Percentages from benchmark at 1M iterations (i9-13900HX, Bash 5.2.21).
At 2M iterations the gap widens slightly: `:` is ~14%, `true` is ~23%.

## How Each Works

### `while ((1))`

```bash
while ((1)); do
  # ...
  ((i++)) || break
done
```

Pure arithmetic evaluation. Bash evaluates the integer `1` as truthy
inside `(( ))` -- no command lookup, no dispatch, no return-code
conversion. The condition is resolved entirely within the arithmetic
evaluator.

### `while :`

```bash
while :; do
  # ...
  ((i++)) || break
done
```

`:` is a shell builtin that does nothing and returns 0. Despite being
a no-op, Bash must still identify the token as a command, look it up in
the builtin table, dispatch it, and collect its exit status. This lookup
and dispatch overhead accounts for the ~14% difference.

### `while true`

```bash
while true; do
  # ...
  ((i++)) || break
done
```

`true` is also a shell builtin (not `/usr/bin/true` -- Bash resolves
builtins before PATH). It goes through the same lookup-dispatch cycle
as `:`, but `true` is a "regular" builtin while `:` is a "special"
builtin. Special builtins have a slightly shorter dispatch path in
Bash's internals, which explains why `:` is consistently faster than
`true` despite both doing the same thing.

## The Idiom Pattern

All three constructs need the same internal structure -- a counter
that exits via `break`:

```bash
# BCS pattern -- counting up to N
i=-$iterations
while ((1)); do
  ((i++)) || break
  # ... work ...
done
```

**Why `((i++)) || break` works:** `((i++))` returns exit status 1 when
the post-increment result is 0 (i.e., when `i` was -1 and becomes 0 --
but wait, it's the *pre-increment* value that `((expr))` tests). The
expression evaluates to the value of `i` *after* increment. When `i`
reaches 0, `((0))` is falsy, triggering `break`.

Correction: `((i++))` evaluates to the *new* value of `i`. Starting
from `-N`, after N increments `i` reaches 0, `((0))` returns status 1,
and `|| break` fires.

**Why not `for ((i=0; i<N; i+=1))`?** Both work. The `while ((1))`
pattern is used in benchmarks to isolate the loop-condition cost from
the iteration mechanism. In production code, `for ((...))` is usually
clearer for counted loops.

## When It Doesn't Matter

The difference between these constructs is ~0.1 microseconds per
iteration. A script that parses arguments (10 iterations) or reads a
config file (100 lines) will never notice.

The distinction matters in:
- Tight inner loops processing millions of items
- Benchmarks measuring other constructs (loop overhead must be minimal)
- Consistent style across a codebase (pick one, use it everywhere)

## Common Mistakes

```bash
# wrong -- external command, forks a process
while /usr/bin/true; do             # always use the builtin

# wrong -- unnecessary comparison
while [[ 1 == 1 ]]; do             # string comparison on constants
while [ 1 ]; do                    # POSIX test on constant, also slower

# wrong -- variable-based "flag" loops
running=true
while $running; do                 # unquoted expansion, fragile
  # ...
  running=false
done
# better
local -i running=1
while ((running)); do
  # ...
  running=0
done
```

The flag-variable pattern using `$running` as a command is particularly
dangerous: if `running` contains anything other than `true` or `false`,
it executes as a command. The arithmetic version is safe and cannot
execute arbitrary strings.

## POSIX Considerations

`while ((1))` uses `(( ))` which is a Bash extension (also ksh, zsh).
For scripts requiring strict POSIX compliance, `while :` is correct.

BCS targets Bash 5.2+ exclusively and does not require POSIX
compatibility, so `while ((1))` is the standard choice.

## Notes

- `:` is a POSIX "special builtin"; `true` is a "regular builtin". Both
  are always builtin in Bash -- neither forks `/usr/bin/true`.
- `while ((1))` and `while ((42))` are identical; any non-zero integer
  is truthy. Convention is `1`.
- `break N` exits N levels of nesting: `break 2` exits two enclosing loops.
- BCS uses `i+=1` for increments, never `i++`, because `((i++))` returns
  falsy when `i` is 0, which triggers `set -e`. Inside a `while ((1))`
  benchmark loop, `((i++)) || break` deliberately exploits this for the
  exit condition, but that's the only sanctioned use.
