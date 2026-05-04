<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 14.1 Standard streams discipline

The convention that distinguishes a composable script from a broken one:
**stdout carries data, stderr carries diagnostics.** A script that follows
this rule slots cleanly into a pipeline; one that does not corrupts every
downstream consumer.

### The two channels

- **stdout (fd 1)** — the script's *data output*, the payload a downstream
  pipe consumes. If the script has no data to emit, stdout stays empty
  and exit status communicates success or failure.
- **stderr (fd 2)** — *diagnostics*: info, warn, error, debug, progress
  bars, prompts. Anything a human reads but a pipe should not.

A script may legitimately produce no stdout at all. A script must
**never** emit diagnostics to stdout when stdout is being captured or
piped — the consumer cannot distinguish data from chatter.

### The anti-pattern

```bash
# wrong — script counts matching files but chats on stdout
#!/bin/bash
set -euo pipefail
count_matches() {
  echo "Scanning..."                # ← diagnostic on stdout (wrong)
  local -i n=0
  for f in *.txt; do ((n+=1)); done
  echo "$n"
}
count_matches
```

Piped into `wc -l`, the caller sees `2` lines (`Scanning...` plus the
count) instead of the single number it expected. The first downstream
arithmetic operation produces nonsense:

```text
$ count_matches | wc -l
2                   # ⇒ should be 1; the diagnostic line was counted
$ total=$(count_matches); echo "$((total + 1))"
bash: Scanning...
12 + 1: syntax error in expression
```

### The correct pattern

Send every diagnostic to fd 2 explicitly. The BCS messaging helpers
(`info`, `warn`, `error`, `die`) do this for you (BCS0703); for ad-hoc
diagnostics, redirect with `>&2`.

```bash
# right — same script, diagnostics on stderr
count_matches() {
  printf 'Scanning...\n' >&2       # diagnostic on stderr (correct)
  local -i n=0
  for f in *.txt; do ((n+=1)); done
  printf '%d\n' "$n"               # data on stdout
}
```

```text
$ count_matches | wc -l
Scanning...
1                   # ⇒ correct: stderr passed through to terminal,
                    #   stdout had exactly one line for wc
```

### Rules of thumb

- Never write diagnostics with bare `echo` or `printf` — always `>&2`,
  or use a messaging helper that does it for you.
- Prompts (`read -p`) write to stderr automatically — safe inside
  pipelines.
- Progress bars and spinners go to stderr; they are diagnostics, not
  data.
- A script that *only* produces side-effects (deploys, syncs, installs)
  may emit progress to stdout under `--verbose`, but its default mode
  should be silent on stdout so it composes with `&&`/`||` chains.
- When in doubt, ask: *would I want this line captured by a downstream
  `read -r line`?* If no, it belongs on stderr.

### Exit status is part of the contract

stdout and stderr describe *what* the script did; exit status describes
*whether it succeeded*. A pipeline-friendly script returns:

- `0` — success, any stdout is valid data
- non-zero — failure; stdout content (if any) is undefined and should
  not be consumed

Combined with `set -o pipefail` (assumed under strict mode), this lets
callers detect failure even when the failing stage is upstream of the
last command in a pipeline.

### See also

- §14.7 — logging discipline (always to stderr)
- §14.10 — progress indicators (stderr destination)
- §14.12 — concurrent writes and `PIPE_BUF`
- BCS0703 (messaging system), BCS0701 (script structure)

#fin
