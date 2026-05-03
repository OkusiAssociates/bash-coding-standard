<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.13 Environment inheritance

Children inherit the environment that bash assembles at the moment of
`fork(2)+execve(2)`. The rules differ subtly between subshells (no
`exec`) and exec'd children (a fresh program image).

| Scenario | What the child sees |
|----------|---------------------|
| Subshell `( … )` | full set of shell variables, including non-exported ones, plus any changes made in the parent before the fork |
| `$(…)` substitution | same as a subshell — full shell variable visibility |
| External command (`cmd`) | only **exported** variables (`export VAR` or `declare -x VAR`) |
| Per-command export (`VAR=val cmd`) | exported variables plus the inline assignments, **for that one invocation only** |
| `env -i cmd` | empty environment — even `PATH` and `HOME` are gone |
| `env VAR=val cmd` | normal env plus the inline pairs |

The subshell case fools many scripts: variables set with `declare`
(no `-x`) are *not* visible to subprocesses but *are* visible to
subshells. Forgetting to export breaks a script the moment a function
is rewritten to invoke an external helper.

```bash
# scenario: shell-local variable vs exported variable
local_var='shell-only'
declare -x exported_var='visible'

# Subshell sees both:
( echo "in (..): $local_var | $exported_var" )
# ⇒ in (..): shell-only | visible

# External program sees only the exported one:
bash -c 'echo "in bash -c: ${local_var:-<unset>} | $exported_var"'
# ⇒ in bash -c: <unset> | visible
```

### One-shot export with `VAR=val cmd`

The leading-assignment form attaches variables to a single command's
environment without polluting the parent shell. It is the canonical way
to override `LC_ALL`, `LANG`, `TZ`, `PATH`, etc. for one call:

```bash
# scenario: deterministic sort regardless of caller's locale
LC_ALL=C sort -- "$file"
echo "$LC_ALL"           # ⇒ <unset or unchanged> — the parent shell is untouched
```

This is **not** the same as `export VAR=val; cmd`, which leaks the
assignment into every later command in the script. Prefer the inline
form unless the override is genuinely script-wide.

### Scrubbed environment with `env -i`

`env -i cmd` runs `cmd` with an empty environment. No `PATH`, no
`HOME`, no `LANG` — the child must supply everything it needs or rely
on hard-coded defaults inside libc. Useful for reproducible builds and
security-sensitive contexts (BCS1007). To rebuild a minimum environment:

```bash
# scenario: tightly controlled environment for a privileged tool
env -i PATH=/usr/bin:/bin LANG=C HOME="$HOME" /usr/bin/run-trusted-tool
```

`env VAR=val cmd` (without `-i`) augments rather than scrubs — the
behaviour is identical to the leading-assignment form above but works
when `cmd` is itself an env-style program (e.g. inside a shebang).

### Size limits

The combined size of arguments and environment passed to `execve(2)` is
capped by `ARG_MAX` (typically 2 MiB on Linux 6.x — query with
`getconf ARG_MAX`). A single huge environment variable (e.g. an inlined
JSON document) can push a script over the limit and produce an `E2BIG`
("Argument list too long") failure on a subsequent `exec`. Pass big
payloads via files or stdin, not via the environment.

**See also**: §02 (Bash as a Program — limits), §11.3 (subshell origins),
§11.11 (`nohup`/`setsid`), §10.6 (sourcing libraries — variable
visibility), Appendix C (`PATH`, `HOME`, `LC_*`), BCS0204 (constants and
environment variables), BCS1007 (environment scrubbing before exec).

#fin
