<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 10.9 Cross-shell sourcing pitfalls

When a library may be sourced by both bash and another shell (sh,
dash, ksh, zsh) — or when bash itself is invoked under the name
`sh` and silently downgrades — the assumptions that hold in
strict-mode bash no longer apply.

- Detect bash at all: `[[ -n ${BASH_VERSION:-} ]]`.
- Avoid bashisms in sh-compatible code paths (`[[ ]]`, arrays,
  `${var,,}`, `<<<`, namerefs, regex, `local -n`).
- Use POSIX-only constructs in sh-compatible paths: `[ ]`, no
  arrays, no namerefs, no `<<<`, no `[[ ]]`.
- Or **refuse to load**: bash-only libraries should detect and
  bail when sourced by anything else (shown below).
- The sh-mode-of-bash trap: bash invoked as `sh` (often via
  `/bin/sh -> bash` on legacy distros) silently disables many
  features.

### Refuse-to-load guard

The cleanest cross-shell story is: declare the library bash-only,
detect the host shell, and refuse to load anywhere else. The
library author then never has to think about portability again.

```bash
# scenario: bash-only library refuses to be sourced by sh/dash/zsh.
# ── /usr/local/lib/myapp/strings.sh ───────────────────────────
# Detect bash and refuse otherwise.
if [ -z "${BASH_VERSION:-}" ]; then
  echo 'mylib: requires bash, not POSIX sh' >&2
  return 1 2>/dev/null || exit 1               # return if sourced, exit if exec'd
fi

# Detect bash invoked as sh — bash silently turns off many features.
if [[ ${0##*/} == sh || -n ${POSIXLY_CORRECT:-} ]]; then
  echo 'mylib: refusing to load under sh-emulation mode' >&2
  return 1                                     # (BCS0407)
fi

# Detect bash version — features used here need 4.4+.
if (( BASH_VERSINFO[0] < 4 )) || \
   (( BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4 )); then
  printf 'mylib: bash 4.4+ required, found %s\n' "$BASH_VERSION" >&2
  return 1
fi

# … library body follows, free to use bashisms …
#fin
```

### sh-mode-of-bash trap — what is silently disabled

When bash is invoked as `sh` (its argv[0] is `sh`, or `--posix`
is set, or `POSIXLY_CORRECT` is in the environment), it disables a
long list of features that look like they should still work:

| Feature              | Disabled in sh mode? | Workaround                        |
|----------------------|----------------------|-----------------------------------|
| `[[ ]]`              | No (still works)     | —                                 |
| `(( ))`              | No (still works)     | —                                 |
| `<<<` here-string    | No (still works)     | —                                 |
| `function name { }`  | Disallowed           | use `name() { }` form             |
| Brace expansion      | Disabled             | enumerate or use globs            |
| `+B`/`-B` toggle     | Default off          | not portable                      |
| `source` keyword     | Use `.` instead      | `. lib.sh`                        |
| `${var,,}` etc.      | Still work           | —                                 |
| `BASH_ENV`           | Read at start-up     | unaffected                        |
| Process substitution | May be disabled      | use temp files                    |

The list is enough surface that most cross-shell libraries either
restrict themselves to a tiny POSIX-compatible subset or use the
refuse-to-load guard above. Mixed-mode (try-bash-first, fall-back-to-
POSIX) is rarely worth the complexity.

**See also**: §10.1 `source` semantics (`return` versus `exit`
asymmetry — the guard above relies on it), §10.10 API design,
§10.11 distribution and installation (which `bash` to require in
the shebang), §1.x bash invocation modes, BCS0102 (shebang),
BCS0407 (library patterns), BCS0409 (bash version detection).

#fin
