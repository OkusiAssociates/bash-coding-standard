<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.8 `export` and the environment

`export` marks a shell variable so that its name and value are passed
into the environment of every subsequently-spawned child process. The
exported state is a per-variable attribute (the `-x` flag in `declare`
terms), not a separate namespace: an exported variable is still a
shell variable, simply one that crosses the `fork+exec` boundary.

### Forms

- `export name=value` — assignment plus export in one statement.
- `declare -x name=value` — equivalent; useful when combining with
  other attributes (`declare -rx FROZEN=…`).
- `export name` — mark an existing variable as exported without
  changing its value.
- `export -p` — print all exported variables in re-loadable form.
- `export -n name` — remove the export attribute. The variable
  remains as a shell variable; only the inheritance flag is cleared.
- `export -f funcname` — export a function (see *Function export and
  Shellshock* below).

### Inheritance is one-way

A child process receives a **copy** of the environment at exec time.
Modifications inside the child do not propagate back. Subshells
(parenthesised groups, `$( )`, pipelines) inherit by reference *for
read* but copy-on-write for any modification — once the subshell
mutates a variable, the parent's binding is unchanged.

```bash
# scenario: child sees the parent's export, mutations stay in the child
export GREETING='hello'

bash -c 'printf "child sees: %s\n" "$GREETING"; GREETING=mutated'
# ⇒ child sees: hello

printf 'parent still: %s\n' "$GREETING"
# ⇒ parent still: hello
```

### Assignment-prefixed commands

A command preceded by one or more `name=value` assignments inherits
those bindings as exports **for the duration of that command only**.
The shell variable in the parent is *not* modified.

```bash
# scenario: temporary export for one command
unset LANG          # remove from current shell

LANG=C sort < input.txt > sorted.txt
# ⇒ sort sees LANG=C; the parent's LANG remains unset afterwards

printf 'parent LANG: <%s>\n' "${LANG-unset}"
# ⇒ parent LANG: <unset>
```

The exception: when the command is a *special builtin* (`:`, `.`,
`break`, `continue`, `eval`, `exec`, `exit`, `export`, `readonly`,
`return`, `set`, `shift`, `times`, `trap`, `unset`), the assignment
persists in the *current* shell. Avoid this corner — under strict-mode
scripting, prefer an explicit `export`/`declare` statement to anything
that could reach a special builtin.

### What is and is not exported by default

Bash inherits whatever the parent shell exports. On a typical login
shell that includes:

- `PATH`, `HOME`, `USER`, `SHELL`, `TERM` — set by the login process
- `LANG`, `LC_*` — locale settings
- `PWD`, `OLDPWD` — Bash maintains these and exports them
- `EDITOR`, `PAGER`, `LESS`, etc. — user-set in `~/.bashrc` or
  `~/.profile`

A new variable created in a script is **not** exported unless you say
so. This is the right default — exported state pollutes every child
and can break tools that expect a clean environment.

### Function export and Shellshock

`export -f funcname` puts a function definition into the environment,
encoded as a string. Bash 4.2 and earlier encoded this as a literal
function body assigned to a specially-named variable; the child shell
parsed and re-executed that body during startup. The infamous
**CVE-2014-6271 ("Shellshock")** exploited a flaw whereby Bash kept
parsing trailing commands after the function body, allowing remote
code execution through any path that fed user input into the
environment of a Bash subshell — notably CGI scripts.

Bash 4.3+ encodes exported functions with a separate prefix
(`BASH_FUNC_name%%`) and the parser stops at the function body.
Modern Bash is safe, but the larger lesson stands:

- **Exported functions are not portable** across shells. A child `sh`
  process will not pick them up.
- **They are a debugging trap** — the function appears in `env` output
  and can shadow the same name in the child.
- **Avoid `export -f` in production scripts.** Prefer dotting-in a
  library file in the child, or passing logic via `bash -c "$(declare
  -f fn); fn args"` — explicit and visible.

```bash
# scenario: function export — works, but rarely the right tool
greet() { printf 'hello, %s\n' "${1-world}"; }
export -f greet

bash -c 'greet alice'
# ⇒ hello, alice

env | grep -F BASH_FUNC_greet
# ⇒ BASH_FUNC_greet%%=() {  printf 'hello, %s\n' "${1-world}";\n}
```

### Pitfalls

- `export name` *without* a value exports whatever value `name`
  currently has — including empty. Mark and assign in one step where
  possible.
- `unset name` removes the variable entirely, including its export
  attribute. `export -n name` removes only the attribute.
- A variable assigned **without** `export` inside a function does not
  reach a child even if a parent-scope global of the same name was
  exported — the local shadows the global.
- Tools that read the environment via `/proc/self/environ` or
  `getenv()` see the byte-level encoding, including any nul-terminated
  embedded values. Never put untrusted data into an exported variable.

### See also

- §4.5 — `declare -x` and attribute combinations
- §4.6 — `local` and dynamic scope (locals are not exported by default)
- §4.13 — variable assignment semantics, especially assignment-prefix
- BCS0204 (constants and environment variables)

#fin
