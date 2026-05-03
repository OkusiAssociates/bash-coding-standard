<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 14.8 Log levels

Standard severity hierarchy. Bash scripts that ship to production should
honour at least three levels (info / warn / error) plus a debug channel
gated by a verbosity flag (BCS0701, BCS0703).

### Severity ladder

- **DEBUG** — detailed trace, off by default.
- **INFO** — normal operational message.
- **WARN** — concerning but not failing.
- **ERROR** — failed operation; script may continue.
- **FATAL** — failed and exiting (BCS `die` at exit code 1+).

### BCS messaging aliases

The BCS `_msg()` helper dispatches by `FUNCNAME`, exposing one alias
per level:

| Alias | Severity | Stream | Default visibility |
|-------|----------|--------|-------------------|
| `info`    | INFO  | stderr | shown when `VERBOSE >= 1` |
| `success` | INFO  | stderr | shown when `VERBOSE >= 1` |
| `warn`    | WARN  | stderr | always |
| `error`   | ERROR | stderr | always |
| `die`     | FATAL | stderr | always (then `exit`) |

Verbosity flags map to integers: `-q` → `VERBOSE=0`, default → 1,
`-v` → 2, `-vv` → 3 (DEBUG). Each helper checks `VERBOSE` before
emitting (see §14.7 for the implementation).

### Structured logging (JSON)

When the consumer is a log aggregator (journald, Loki, ELK), structured
output beats colourised text:

```bash
# scenario: emit one JSON object per event for downstream parsing
declare -r LOG_HOST=$(hostname -s)
declare -r LOG_SCRIPT=${0##*/}

log_json() {
  local -- level=$1 message=$2
  printf '{"ts":"%(%FT%T%z)T","host":"%s","script":"%s","level":"%s","msg":%s}\n' \
    -1 "$LOG_HOST" "$LOG_SCRIPT" "$level" "${message@Q}" >&2
}

log_json info  'starting backup'
log_json warn  'disk above 80%'
log_json error 'rsync exited 23'
# ⇒ {"ts":"2026-05-03T14:32:07+0700","host":"okusi","script":"backup","level":"info","msg":'starting backup'}
```

The `${message@Q}` parameter transformation produces a shell-safe
quoted string (BCS0306) which is also valid JSON for ASCII messages;
for arbitrary Unicode, pipe through `jq -Rsa .` or use a real logger.

### Filter and aggregate

- `2> >(jq -c '. | select(.level=="error")')` — pre-filter at the
  source by piping stderr through a process substitution.
- `logger -t "$LOG_SCRIPT"` — forward to syslog/journald instead of
  inventing a transport.
- `systemd-cat -t "$LOG_SCRIPT"` — same idea, journald-native.

### See also

- §14.7 — full `_msg()` implementation and dispatch table
- §14.1 — why diagnostics belong on stderr
- BCS0701 (message control flags), BCS0703 (core messaging system)

#fin
