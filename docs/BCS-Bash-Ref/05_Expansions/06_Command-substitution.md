<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.6 Command substitution

`$(command)` runs `command` in a subshell, captures its standard
output, strips one or more trailing newlines, and substitutes the
result into the surrounding word. It is the foundation for capturing
the output of one command into a variable or into the arguments of
another, and is one of the most frequently used constructs in shell
scripts.

The legacy backtick form `` `command` `` is omitted from this reference
(§11 of the bash manual still documents it for portability); under the
strict-mode assumptions of this document, only `$(...)` is used. It
nests cleanly, supports embedded quotes naturally, and is unambiguously
parseable.

### Basic semantics

```bash
# scenario: capture, embed, and nest
declare -- today
today="$(date +%F)"
echo "today is $today"            # ⇒ today is 2026-05-03

declare -- count
count="$(grep -c '^pattern' file.txt)"

# Nested — read the directory of the script's directory
declare -- parent
parent="$(dirname "$(realpath -- "$0")")"
```

Each substitution forks a subshell, executes the command, and waits
for it. Variable assignments and shell-state changes inside the
substitution do *not* leak back out — they are confined to the
subshell.

### The `$(<file)` idiom

`$(<file)` is a special form recognised by bash: rather than spawning
a subshell to run a command, it reads `file` directly into the
substitution result. It is the canonical fast file-read and the
preferred replacement for `"$(cat file)"`:

```bash
# scenario: read a small file into a variable without forking
declare -- version
version="$(<VERSION)"               # no fork; trailing newlines stripped
echo "version=$version"

# Equivalent but slower (forks cat):
# version="$(cat VERSION)"
```

This is an *idiom*, not a pitfall — under heavy use (loops, large
scripts) the fork-avoidance is measurable. The same trailing-newline
stripping applies.

### Trailing newline stripping

Bash strips *all* trailing newlines from the captured output. Embedded
newlines are preserved. This is almost always what you want, but it
catches scripts that need to know whether a file ended with a newline:

```bash
# scenario: trailing newlines disappear, embedded newlines survive
declare -- multi
multi="$(printf 'a\nb\n\n\n')"
printf '[%s]\n' "$multi"            # ⇒ [a
                                    #    b]   — three trailing \n stripped

# Workaround: append a sentinel and trim it
declare -- exact
exact="$(printf 'a\nb\n\n\n'; printf x)"
exact="${exact%x}"                  # now $exact has every newline preserved
```

### `inherit_errexit` interaction

Without `shopt -s inherit_errexit`, the subshell spawned by `$( ... )`
*does not inherit* `set -e`. Failures inside the substitution are
silently swallowed unless their exit status is also the substitution's
exit status:

```bash
# scenario: errexit drops at the subshell boundary
set -euo pipefail
declare -- result
result="$(false; echo done)"        # without inherit_errexit:
                                    #   result='done', no exit
echo "still alive: $result"

# With inherit_errexit (BCS0101 mandates this):
shopt -s inherit_errexit
result="$(false; echo done)"        # subshell aborts at false;
                                    # outer shell sees rc=1, exits
```

Always pair `set -e` with `shopt -s inherit_errexit` — see §13.6 for
the full discussion. BCS0101's strict-mode preamble enables it
unconditionally.

### Quoting and word splitting

The result of an unquoted command substitution undergoes word
splitting (§5.8) and pathname expansion (§5.9):

```bash
# scenario: quote unless splitting is the intent
declare -- list_with_spaces
list_with_spaces="$(printf 'foo bar\nbaz\n')"
printf '[%s]\n' "$list_with_spaces"
# ⇒ [foo bar
# ⇒ baz]
# shellcheck disable=SC2086  # word-splitting is the demo
printf '[%s]\n' $list_with_spaces
# ⇒ [foo]
# ⇒ [bar]
# ⇒ [baz]

# Idiomatic capture into an array (one element per line)
: > demo-input.txt && printf 'pattern A\npattern B\nother\n' > demo-input.txt
declare -a lines
readarray -t lines < <(grep '^pattern' demo-input.txt)
printf 'lines captured: %d\n' "${#lines[@]}"   # ⇒ lines captured: 2
```

For any capture you intend to manipulate as a single string, quote.
For line-by-line capture into an array, prefer `readarray -t` with
process substitution (§5.7) over `arr=( $(...) )`, which mishandles
embedded whitespace.

### Bash 5.3 `${ command; }` no-fork form

Bash 5.3 introduces a no-fork command substitution: `${ command; }`
runs `command` in the *current* shell, with no subshell, capturing its
output. Variable changes propagate. This is documented in §25.1 and
is not yet generally portable across Bash 5.2 deployments.

**See also**: §5.7 (process substitution for streaming captures),
§5.8 (word splitting of unquoted results), §13.6 (inherit_errexit
discipline), §25.1 (Bash 5.3 no-fork command substitution),
BCS0302 (command substitution patterns), BCS0101 (strict-mode
preamble).

#fin
