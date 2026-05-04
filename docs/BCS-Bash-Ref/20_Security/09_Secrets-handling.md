<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.9 Secrets handling

Secrets — API tokens, private keys, passwords — must never appear in
process tables, trace output, log files, or version control. The threat
model is local-user adjacent (a low-privilege user on the same host) plus
the operator looking over their own shoulder at a `set -x` log.

### Storage and transport — visibility matrix

| Channel              | Visible to                                      | Verdict                          |
|----------------------|-------------------------------------------------|----------------------------------|
| Command-line args    | Any user via `ps eww`                           | Forbidden                        |
| Environment variables| Same-user processes via `/proc/PID/environ`     | Acceptable for own process       |
| Mode 0600 file       | Owner only                                      | Acceptable                       |
| `/dev/shm` file      | Same as 0600 file but cleared on reboot         | Acceptable for short-lived       |
| stdin pipe           | Same as args' parent process                    | Preferred for child processes    |

Ranked preference: stdin pipe ≻ env var (own-process) ≻ mode-0600 file ≻
`/dev/shm` ≻ argv. Vendor secret managers (HashiCorp Vault, AWS Secrets
Manager, GCP Secret Manager) are the source of truth; their CLI clients
emit secrets on stdout for piping into downstream consumers — see vendor
docs for invocation.

### Process-arg leak — the `ps eww` demonstration

The argv channel is the easiest to misuse and the easiest to demonstrate:

```bash
# scenario: secret passed as a CLI flag — visible to every user on the host
curl --user "alice:$PASSWORD" https://api.example.com/  &
sleep 0.5
ps eww -p $!                       # ⇒ shows: curl --user alice:s3cret https://...
wait
```

Any unprivileged process can read `/proc/<pid>/cmdline`; `ps eww` even
spills the environment. The fix is the tool's stdin-secret variant:

```bash
# scenario: same call, secret arrives on stdin via --config
printf -- 'user = "alice:%s"\n' "$PASSWORD" \
  | curl --config - https://api.example.com/
                                    # ⇒ argv contains no secret; stdin is process-private
```

When a tool offers no stdin variant (rare, but check first), pass via env
var and document the choice; never construct the secret into argv.

### `set -x` discipline — scoped disable

`set -x` traces every expansion, including secret-bearing arguments. The
canonical scoped-disable pattern saves the option state, disables tracing
for the duration of the secret-using command, and restores afterwards —
all redirected so the disable itself does not leak via the trace stream:

```bash
# scenario: scoped trace disable around a secret-using call
{ set +x; } 2>/dev/null               # disable, swallow the trace of the disable
api_call --secret-from-env            # SECRET in env, not argv
saved_xtrace=$-                        # capture current option state
{ [[ $saved_xtrace == *x* ]] && set -x; } 2>/dev/null
```

In practice the simpler one-liner suffices for a single secret-using call:

```bash
# scenario: one-shot disable, immediate restore
api_call() { :; }     # placeholder for the real client; the trace is the demo
{ set +x; api_call --secret-from-env; set -x; } 2>/dev/null
```

The outer `{ … } 2>/dev/null` blocks the `+ set -x` line that bash would
otherwise emit on stderr. If your script does not rely on `set -x` being
on after the call, drop the restore.

### Logging discipline

Every `info`/`warn`/`error` invocation that touches a secret-bearing
variable is a leak. Audit with `grep -nE '\$(PASS|TOKEN|SECRET|KEY)' script`
and require redaction in messaging functions:

```bash
# scenario: redacted error message
error "auth failed for user ${user@Q} (secret length: ${#PASSWORD})"
# ⇒ logs the length, never the value
```

### Reading secrets — `read -s` and file mode

Interactive prompts must use `read -s` (silent) so the value never reaches
the terminal:

```bash
# scenario: prompt for a passphrase without echo
read -rs -p 'Passphrase: ' PASSPHRASE
printf '\n'                          # newline manually since -s suppressed it
```

For credentials read from a file, validate the file mode before reading.
If the file is group- or world-readable, refuse to load:

```bash
# scenario: refuse to load a credential file with loose permissions
declare -r CRED=/etc/myservice/api.token
mode=$(stat -c '%a' -- "$CRED")
[[ $mode == 600 || $mode == 400 ]] \
  || die 13 "permissions on $CRED must be 600 or 400 (got $mode)"
TOKEN=$(<"$CRED")
```

The mode check fails closed: missing file, unreadable file, or wrong mode
all exit non-zero.

### Lifetime — `unset` after use

Secrets in shell variables persist until the variable is unset or the
process exits. For scripts that fork children after the secret is no
longer needed, `unset` reduces the leak surface — children no longer
inherit the value:

```bash
# scenario: clear secret immediately after use
api_call --secret-from-env || die 1 'auth failed'
unset -v PASSPHRASE TOKEN PASSWORD   # ⇒ removed from env for any later forks
```

`unset -v` is preferred over plain `unset` to avoid the rare collision
with a function of the same name.

**See also**: §20.5 command-injection vectors, §20.7 quoting under set -u,
BCS1005 input sanitization, BCS0703 core messaging system.

#fin
