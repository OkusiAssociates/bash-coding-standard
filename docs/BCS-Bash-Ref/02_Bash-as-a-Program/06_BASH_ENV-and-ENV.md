<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 2.6 `BASH_ENV` and `ENV`

Two specific environment variables that control startup-file sourcing for non-interactive shells. Often overlooked, occasionally weaponised in exploits, always worth understanding under any security model.

The two variables:

- **`BASH_ENV`** — when Bash is invoked non-interactively (e.g. running a script), it expands `$BASH_ENV`, performs PATH lookup if the result is unqualified, and sources the resulting file before running the script. Set it and any non-interactive Bash inherits the contents.
- **`ENV`** — analogous but only honoured when Bash runs in POSIX mode (`--posix` or invoked as `sh`). In standard Bash mode it is silently ignored.

Both are subject to expansion and (for `BASH_ENV`) PATH resolution. SUID Bash scripts are forbidden by BCS1001 (and disabled by the kernel under Linux), but a non-SUID Bash invoked from a SUID C wrapper would still read these variables — historically the route to several CVEs, and the reason `bash` ignores them when its `ruid != euid`.

```bash
# scenario: a per-tenant init that runs before any non-interactive script
cat >/etc/bash-tenant-init.sh <<'EOF'
export TENANT_ID=acme
umask 0027                    # BCS1006 — restrictive defaults
EOF
BASH_ENV=/etc/bash-tenant-init.sh bash -c 'printf tenant=%s umask=%s\\n "$TENANT_ID" "$(umask)"'
# ⇒ tenant=acme umask=0027
```

The same mechanism in adversarial hands:

```bash
# wrong — BASH_ENV honoured from the caller's environment
BASH_ENV=/tmp/evil.sh bash innocent-script.sh
# (innocent-script never opted in; /tmp/evil.sh runs anyway)
```

Mitigations under any hardened invocation: `unset BASH_ENV ENV` at the head of long-lived service scripts (BCS1007 environment-scrubbing pattern) and refuse to source files outside a known directory.

`BASH_ENV` is sourced **before** the script's own code; it cannot inspect `$0`, `$@`, or any of the script's logic before running.

**See also**: §2.4 (interactive vs non-interactive invocation), §2.5 (full startup-file chain — `BASH_ENV` is the non-interactive equivalent of `~/.bashrc`), §10 (security — `unset` hostile environment, sanitise `IFS` and `PATH`), §20.8 (why SUID scripts are doubly forbidden).

#fin
