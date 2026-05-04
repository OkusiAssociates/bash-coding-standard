<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 23.5 Bash vs zsh

`zsh` is interactive-rich and scripting-divergent. Apple ships it as
the default login shell on macOS, and it has a substantial fan base on
Linux for daily use. As a *scripting* target, however, it is a separate
language wearing similar clothing: the same `if`/`for`/`case`, the same
`$(…)`, the same `[[ … ]]` — but with enough differences in defaults
that running a bash script under `zsh -c …` is a guaranteed surprise.

The two divergences that bite scripters most often are word-splitting
defaults and array indexing.

### Word-splitting contrast

Bash splits unquoted parameter expansions on `IFS`. zsh, by default,
does not — it expands them as a single word. This is one of zsh's most
deliberately user-friendly choices, and the most reliably confusing one
when porting:

```bash
# scenario: bash splits unquoted; zsh would not (this block runs under bash)
list='red green blue'

# shellcheck disable=SC2086  # word-splitting is the demo
for x in $list; do printf '[%s]\n' "$x"; done
# ⇒ [red]
# ⇒ [green]
# ⇒ [blue]
# (the equivalent loop in zsh 5.9 with default options would print
#  the single line `[red green blue]` — zsh does not split unquoted
#  parameter expansions)
```

A bash script that loops over `$list` and silently produces one
iteration under zsh is the canonical port-failure. Re-enable bash-style
splitting with `setopt SH_WORD_SPLIT`, or always quote and split
explicitly with arrays:

```bash
# bash-and-zsh portable: use an array, no implicit splitting
declare -a list=(red green blue)
for x in "${list[@]}"; do printf '[%s]\n' "$x"; done
# ⇒ [red]
# ⇒ [green]
# ⇒ [blue]
# (same output under bash and zsh — quoted "${arr[@]}" is the portable form)
```

### Array indexing — KSH_ARRAYS

zsh arrays are **1-indexed by default**. `arr[1]` is the first element;
`arr[0]` is empty. Bash arrays are 0-indexed (inherited from ksh88's
later behaviour). The `KSH_ARRAYS` option forces zsh into 0-indexed,
bash-compatible mode:

```text
# zsh, default options (illustrative — `print` and `setopt` are zsh builtins)
arr=(red green blue)
print -- "$arr[1]"           # → red       (1-indexed)
print -- "$arr[0]"           # →           (empty)
print -- "${#arr[@]}"        # → 3

# zsh with KSH_ARRAYS enabled
setopt KSH_ARRAYS
print -- "${arr[0]}"         # → red       (0-indexed, like bash)
print -- "${arr[1]}"         # → green
```

`KSH_ARRAYS` also forces braces around any subscripted reference (zsh
otherwise allows the bareword `$arr[1]`), bringing the surface syntax
closer to bash. It is the single most useful zsh setopt for "make this
script bash-shaped."

### Other differences worth noting

- **Globbing.** zsh has glob qualifiers (`*(.)` for plain files,
  `*(/)` for directories) and recursive globs (`**/*.c`) without
  needing `globstar`. bash's `**` matches directories only with
  `shopt -s globstar`.
- **`function` keyword.** zsh accepts both `function name { … }` and
  `name() { … }`; bash too, but with subtle differences in alias
  handling.
- **Redirection.** zsh's MULTIOS option lets `>file1 >file2` write to
  both; bash uses only the last redirection.
- **`read`.** bash's `read -a arr` reads a whole line into an array;
  zsh uses `read -A arr`.

### Practical advice

Many bash idioms break under zsh; many zsh idioms break under bash. For
shared `~/.profile` or `~/.bashrc.local` files sourced from both, code
defensively against both unset/unset-or-empty differences in parameter
expansion, and never rely on word-splitting of unquoted variables. For
scripts, pick a shell in the shebang (`#!/bin/bash` or `#!/bin/zsh`)
and write to that target — there is no point pretending the same script
runs cleanly under both.

**See also**: §23.1 (Bash vs POSIX sh) for the underlying spec; §23.2
(bashisms list); BCS0102 (shebang) for the BCS shebang convention;
BCS0206 (arrays) for the bash-side array discipline.

#fin
