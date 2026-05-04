<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.1 Definition syntax

Bash accepts two syntactic forms for defining a function. They produce
the same callable object once defined, but the surface differences
matter when reading other people's scripts and when the body needs
behaviour beyond a plain brace group.

### The two forms

The POSIX form is `name() { body; }` — parentheses, then a *compound
command* as the body. The bash keyword form is `function name { body; }`
or `function name() { body; }`. With the `function` keyword the
parentheses are optional; with the POSIX form they are mandatory.

```bash
# scenario: side-by-side definition forms — all three define the same callable
greet() { printf 'hello %s\n' "$1"; }                  # POSIX form
function greet { printf 'hello %s\n' "$1"; }           # keyword, no parens
function greet() { printf 'hello %s\n' "$1"; }         # keyword + parens (legal, redundant)
```

Style preference under BCS is the POSIX form (BCS0401): it is portable
to other Bourne-family shells *if* the body uses no bash-only features,
and it reads with less ceremony. Reserve the `function` keyword only
where it is technically required — most often when a function name
contains characters the parser would otherwise reject (hyphens are the
canonical example, though hyphenated names are themselves discouraged
by BCS0402).

### Body kind: brace group versus subshell

The body's outer compound command is normally a brace group `{ …; }`,
which executes in the *current* shell environment. Variable and trap
modifications survive the call. Bash also allows the body to be a
subshell `( …; )`, which forks a child process for every call. Inside
that subshell, `set -e`, traps, and variable mutations are isolated —
the parent never sees them.

```bash
# scenario: subshell-bodied function — every call forks; mutations are local
in_subshell() (
  cd /tmp || exit 1                  # cd persists only inside the subshell
  trap 'echo cleanup' EXIT           # fires when the subshell exits, not later
  ls -1 | head -3
)

in_subshell                          # output + cleanup, $PWD unchanged in parent
# → "$PWD" remains the parent's working directory
echo "PWD-was-not-/tmp: $([[ "$PWD" != /tmp ]] && echo yes || echo no)"
# ⇒ PWD-was-not-/tmp: yes
```

The subshell-bodied form is rare and deliberate: use it when the
function must contain side effects (cd, trap, IFS munging) that you
*want* to throw away on return. The cost is one fork per call; for
hot-path code the brace-group form is the only sensible choice.

### Trailing redirections on the definition

A function definition may be followed by a redirection, which is
applied to *every* invocation of that function — not to the act of
defining it. This is occasionally useful for log-only helpers, but
mostly a curio.

```bash
# scenario: trailing redirection captures stderr from every call
warn_log() { printf '[WARN] %s\n' "$@"; } 2>>/var/log/myapp.warn

warn_log "disk near full"            # ⇒ appended to /var/log/myapp.warn, no stderr to terminal
warn_log "another"                   # ⇒ same redirection re-applied
```

The redirection is evaluated at *call* time, not at definition time,
so the path may reference variables set later. BCS scripts rarely
exploit this; explicit redirection at the call site is clearer.

### Naming and the `function` keyword exception

A function name with the POSIX form must be a valid bash identifier
(alphanumeric plus underscore, not starting with a digit). The
`function` keyword loosens this rule and accepts hyphens — this is
the only routine reason to choose the keyword form. BCS0402 forbids
hyphens regardless: tooling such as `declare -f` and `export -f` then
work without quoting, and the name remains usable in any shell.

```bash
# legal under bash but rejected by BCS0402 — needs the keyword form
function send-email { :; }           # avoid

# canonical form
send_email() { :; }                  # accept
```

**See also**: §9.2 (argument passing), §9.3 (`local` and scope),
§9.10 (naming conventions), §10.1 (`source` semantics — sourced
files install function definitions in the caller's shell), BCS0401
(function definition style), BCS0402 (function names), BCS-bash
`09_06_Shell-Function-Definitions.md`.

#fin
