<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.11 Glob options

Pathname expansion (§5.9) is governed by a small set of `shopt`
toggles. Each one changes a specific aspect of pattern matching;
together they let scripts opt in to safer, fuller, or stricter glob
behaviour. This chapter documents the toggles, the recommended
defaults, and the save-restore idiom for changing them inside a
function.

### Toggle inventory

| Option | Default | Effect |
|--------|--------:|--------|
| `nullglob` | off | unmatched glob expands to *nothing* (zero words) |
| `failglob` | off | unmatched glob is a syntax error; the command does not run |
| `dotglob` | off | `*` and `?` match leading `.` (still excludes `.` and `..` under `globskipdots`) |
| `globskipdots` | on (Bash 5.2+) | `*` and `?` never match `.` or `..` |
| `nocaseglob` | off | filename matching is case-insensitive |
| `nocasematch` | off | `[[ ]]` and `case` glob comparisons are case-insensitive |
| `globstar` | off | `**` matches any number of directories (recursive) |
| `extglob` | off | enables extended-glob operators (§5.12) |
| `globasciiranges` | off | `[a-z]` is interpreted by ASCII order rather than locale collation |
| `dirspell` | off | typo-correction for directory names during completion |
| `cdspell` | off | typo-correction for `cd` arguments |

`nullglob`, `extglob`, and the Bash 5.2 `globskipdots` are enabled by
the BCS strict-mode preamble (BCS0101). `failglob` is offered as an
alternative for scripts that treat any unmatched glob as a bug.

### `nullglob` versus `failglob`

The default no-match behaviour — passing the literal pattern through —
is almost never what scripts want. `nullglob` and `failglob` represent
the two principled responses:

```bash
# scenario: nullglob — empty match yields empty array, loop runs zero times
shopt -s nullglob
declare -a stale=( /tmp/staging-*.lock )
for f in "${stale[@]}"; do          # zero iterations if no matches
  rm -f -- "$f"
done

# scenario: failglob — empty match aborts the command
shopt -s failglob
declare -a inputs=( /no/such/path/*.txt )
# ⇒ bash: no match: /no/such/path/*.txt
# the assignment never happens; the script aborts under set -e
```

Use `nullglob` when "no matches" is a normal outcome (clean-up loops,
optional fixtures). Use `failglob` when an empty match is a bug (a
config-file pattern that *must* find at least one file). The two are
mutually exclusive; setting one does not unset the other automatically,
so do not enable both.

### Save-restore idiom

`shopt` settings are global to the shell — there is no `local`
mechanism for them, and a function that toggles a shopt leaves the
toggle changed when it returns. The defensive idiom is to capture the
current state with `shopt -p` (which prints a re-runnable `shopt`
command), change what is needed, then `eval` the saved state on exit:

```bash
# scenario: temporarily enable nocaseglob without leaking the change
case_insensitive_match() {
  local -- _saved
  _saved=$(shopt -p nocaseglob)       # capture current state
  shopt -s nocaseglob

  # ... pattern-matching code that needs case insensitivity ...
  declare -a matches=( *.PNG *.JPG *.JPEG )
  printf '%s\n' "${matches[@]}"

  eval "$_saved"                      # restore prior state, set or unset
}
```

The `shopt -p name` form emits exactly `shopt -s name` or `shopt -u name`
depending on the prior value, so `eval "$_saved"` always restores the
original. Pair it with a trap on `RETURN` if the function has multiple
exit paths.

### `globstar` and `**`

With `globstar` enabled, `**` matches any number of directories
(including zero), recursively. Without it, `**` is the same as `*`.

```bash
# scenario: globstar for recursive file collection
shopt -s globstar nullglob
declare -a sources=( src/**/*.bash )
echo "${#sources[@]} files"

# Without globstar, src/**/*.bash matches only src/*/*.bash (one level deep).
```

`globstar` makes simple shell-only recursion possible without forking
`find`. The only caveat: `**` follows symlinks by default, which can
recurse forever on a circular link. For untrusted trees, prefer
`find -type f`.

### `nocasematch` for `[[` and `case`

`nocaseglob` only affects filename expansion. The companion
`nocasematch` affects pattern-matching in `[[ ]]` and `case`:

```bash
# scenario: nocasematch — case-insensitive [[ and case
shopt -s nocasematch
[[ Hello == hello ]] && echo 'match'        # ⇒ match

case 'README.MD' in
  *.md) echo 'markdown' ;;                  # ⇒ markdown
esac
shopt -u nocasematch
```

These two toggles are independent — set whichever the context needs.

**See also**: §5.9 (pathname expansion fundamentals), §5.12 (extended
globs require `extglob`), §5.13 (locale and `globasciiranges`), §9
(functions and the case for save-restore around shopt changes), §13
(error-handling effect of `failglob` under `set -e`), BCS0101 (strict-
mode `shopt` set), BCS0902 (wildcard expansion safety), BCS0501
(conditional expressions and `nocasematch`).

#fin
