<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.7 `xargs -P`

External tool for parallel one-shot work — when each unit of input
maps to one independent invocation of a command (BCS1102). Simpler
than a hand-rolled fan-out (§16.5) for the common case.

### Form register

- `xargs -P N -I {} cmd {}` — run up to N invocations in parallel,
  one input per invocation.
- `-n N` — pack N inputs per invocation (default 1 with `-I`).
- `-0` — NUL-separated input; pairs with `find -print0`.
- `-r` — do not run if input is empty (GNU extension; BSD lacks).
- Exit status: 123 if any invocation exited 1–125; 124 if any was
  killed by signal; 125 if `xargs` itself failed.

### `find -print0` piped example

The canonical NUL-safe variant:

```bash
# scenario: convert every PNG under . to JPEG, 4-way parallel
find . -type f -name '*.png' -print0 \
  | xargs -0 -P 4 -I {} sh -c 'magick convert "$1" "${1%.png}.jpg"' _ {}
```

- `-print0` emits NUL-terminated paths (newlines and spaces in
  filenames preserved).
- `-0` tells xargs to expect NUL framing.
- `-P 4` runs four converters concurrently.
- `-I {}` substitutes the input where the placeholder appears.
- `sh -c '...' _ {}` is the BCS-recommended way to run a small shell
  expression — `_` becomes `$0`, `{}` becomes `$1`. Avoids quoting
  surprises if the path contains `$`, backticks, or quotes.

### Line-buffering pitfall

When parallel invocations write to the same stdout, output interleaves
at write boundaries. Lines longer than `PIPE_BUF` (typically 4096
bytes; §14.12) split across writes and tear:

```bash
# scenario: parallel commands writing to one stdout — interleaved output
seq 1 100 | xargs -P 8 -I {} sh -c 'echo "long line {} ============================="'
# output frequently shows two lines mashed together
```

Workarounds:

- `xargs -P 4 -L 1 ... | grep -F .` — the `-L 1` mode does not help
  this; the issue is downstream, not in xargs.
- `stdbuf -oL cmd` — line-buffer the *child's* stdout. With glibc-
  linked binaries this prevents partial writes within a line.
- Per-PID redirection: `cmd > "/tmp/out.$$"` from inside the command;
  concatenate after the parallel block.
- `parallel --line-buffer` (§16.8) — GNU parallel handles this case
  natively.

### Exit-status aggregation

`xargs -P` sets a non-zero exit if *any* child failed, but does not
report which one. For per-task reporting, log inside the command:

```bash
# scenario: capture per-task failures into a log
find . -type f -name '*.png' -print0 \
  | xargs -0 -P 4 -I {} sh -c 'process "$1" || echo "FAIL $1" >> /tmp/fail.log' _ {}
```

### See also

- §16.5 — hand-rolled bounded fan-out for richer error handling
- §16.8 — GNU parallel for line-buffer and joblog support
- §14.12 — `PIPE_BUF` and atomic-append details
- BCS1102 (parallel execution)

#fin
