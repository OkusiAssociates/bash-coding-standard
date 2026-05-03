<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 2.8 Exit and shell session lifecycle

How and when Bash terminates, what runs at exit, and the boundary between the script's exit and the parent shell's lifecycle. The `EXIT` pseudo-trap is the bedrock of cleanup discipline (BCS0110, BCS0603); understanding when it fires — and when it does **not** — is non-negotiable.

Causes of exit:

- `exit N` — terminate the current shell with status `N` (truncated to 8 bits, see §1.7).
- End of script — implicit `exit` with the status of the last command.
- Fatal signal — exit status `128 + signo` (e.g. `SIGINT` ⇒ 130).
- `set -e` — uncaught failure terminates the shell.
- `return` outside a function or sourced file — error.

The `EXIT` trap fires once, exactly once, at any normal cause of exit (including signal-induced exit when the signal is also trapped). It does **not** fire when the shell is replaced by `exec`, nor when the kernel kills the shell with `SIGKILL` (uncatchable).

Subshell semantics, precisely stated:

- A subshell (child Bash from `(...)`, `$(...)`, `cmd &`, `|`) inherits the parent's traps initially, but its own exit fires its own `EXIT` trap, not the parent's.
- `set -E` (`errtrace`) propagates the **`ERR`** trap into functions, command substitutions, and subshells. It has no effect on `EXIT`.
- `set -T` (`functrace`) propagates `DEBUG` and `RETURN` similarly. Again, no effect on `EXIT`.
- The `EXIT` trap is a per-shell construct; you cannot make a subshell "skip" or "share" the parent's `EXIT` trap.

Other lifecycle hooks:

- `~/.bash_logout` — sourced on login-shell exit only.
- `shopt -s huponexit` — interactive shell sends `SIGHUP` to background jobs on exit.
- `exec CMD` — replaces the Bash image; no exit, no `EXIT` trap, no `~/.bash_logout`.
- `kill -KILL $$` — uncatchable; no trap fires; no cleanup.

```bash
# scenario: a cleanup trap that runs only in the parent shell
declare -- tmp
tmp=$(mktemp) || exit 5
trap 'rm -f -- "$tmp"' EXIT       # BCS0603 — single-quoted so $tmp resolves at trap time
( printf 'subshell uses %s\n' "$tmp"; exit 0 )
# the subshell's own EXIT trap is empty by default — parent's trap is NOT inherited at fire-time
echo "back in parent: $tmp still exists -> $([[ -f $tmp ]] && echo yes)"
# ⇒ subshell uses /tmp/tmp.XXXXXX
# ⇒ back in parent: /tmp/tmp.XXXXXX still exists -> yes
# (the trap fires once when the script ends)
```

The only reliable cleanup for uncatchable death is filesystem layout: prefer `mktemp -d` under a directory you `rm -rf` later, and never leave secret material in long-lived predictable paths (BCS1006).

**See also**: §1.7 (exit status encoding, signal-induced exits), §1.8 (signals overview), §12.5 (`trap` builtin in depth), §12.6 (pseudo-signals `EXIT`/`ERR`/`DEBUG`/`RETURN`), §20 (cleanup discipline under uncatchable signals).

#fin
