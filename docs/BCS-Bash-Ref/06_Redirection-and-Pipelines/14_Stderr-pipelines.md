<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.14 Stderr pipelines (`|&`)

`a |& b` is the parser shorthand for `a 2>&1 | b` — both stdout and
stderr of `a` flow into `b`'s stdin. Bash 4.0+. Useful when a noisy
producer mixes diagnostics with data and the consumer needs to see
both streams.

### Equivalence with `2>&1 |`

```bash
# scenario: |& and 2>&1 | produce identical pipelines
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

producer() {
  echo 'data line'
  echo 'diagnostic line' >&2
}

# Form A — combined operator
producer |& cat -n
# ⇒ data line
# ⇒ diagnostic line

# Form B — manual stderr merge, identical result
producer 2>&1 | cat -n
# ⇒ data line
# ⇒ diagnostic line
# (cat -n prefixes each line with `<spaces>N<TAB>`; both forms feed it
#  the same merged stream, so the numbered output is identical)
```

The two forms compile to the same fd-table operations: open the pipe,
dup the write end onto fd 1, then dup fd 1 onto fd 2 — in that order.
The ordering bug that plagues hand-written `2>&1 >file` (§6.4) cannot
occur with `|&` because the operator name picks a single fixed
ordering.

### Exit status and `pipefail`

`|&` is a pipeline operator like `|`; the exit-status rules of §6.13
and §6.15 apply unchanged. With `set -o pipefail` (mandatory under
BCS strict mode, BCS0101), the pipeline exits non-zero if **any**
component does.

### When to use it

- Capturing the merged output of a noisy command into a single
  pager / logger / filter: `make build |& tee build.log`.
- Filtering both data and diagnostics through the same `grep`/`sed`:
  `wget -q --content-on-error … |& grep -v '^Saving to'`.
- Anywhere `2>&1 |` was the intent — `|&` is shorter and harder to
  reorder by accident.

### When **not** to use it

- When stdout is data and stderr is diagnostics, and the consumer is
  a *data* sink (counter, parser, DB loader). Mixing the streams
  corrupts the data path. Use `2> err.log | parser` instead, sending
  stderr to a file the parser ignores.
- When you need pipeline-component status detection by stream: with
  `|&` both streams collapse into one, so the consumer cannot tell
  data from diagnostics.

### BCS posture

- `|&` is fine in BCS scripts when "I want both streams" is the
  literal intent (BCS0711 family — combined redirection).
- For "send everything to a file (not a pipe)", prefer `&> file`
  (§6.3, §6.4); `|&` is for pipelines, `&>` is for files.
- Always `set -o pipefail` so a producer failure surfaces (BCS0101).

**See also**: §6.4 (stderr merging — the order-of-operators rule),
§6.13 (pipeline mechanics and `PIPESTATUS`), §6.15 (`pipefail`),
§6.16 (`lastpipe`).

#fin
