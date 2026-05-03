<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.12 Rich error output

Diagnostic output that carries enough context for an operator to
identify the failing command, the call stack, and any relevant process
state — without forcing them to re-run with `bash -x`.

### Stack-walking handler

The canonical pattern walks `FUNCNAME[]`, `BASH_SOURCE[]`, and
`BASH_LINENO[]` to print one frame per line, indented for readability:

```bash
bash_stack() {
  local i frame
  for ((i = 1; i < ${#FUNCNAME[@]}; i++)); do
    frame="${FUNCNAME[i]} (${BASH_SOURCE[i]}:${BASH_LINENO[i-1]})"
    printf '  at %s\n' "$frame" >&2
  done
}

on_err() {
  local rc=$? line=$1
  error "command failed (rc=$rc) at line $line: $BASH_COMMAND"
  bash_stack
}
trap 'on_err $LINENO' ERR
```

- `FUNCNAME[]`, `BASH_SOURCE[]`, `BASH_LINENO[]` are parallel arrays
  that together describe the call stack.
- Index 0 is the trap itself; useful frames start at 1.
- `BASH_LINENO[i-1]` is the line where frame `i` *called* frame `i-1`
  — the off-by-one is correct.
- All output goes to **stderr** (`>&2`) so callers can capture stdout
  cleanly (BCS0702).

### Formatted (icon-decorated) output

Combine BCS messaging icons (BCS0710 — `◉` info, `⦿` debug, `▲` warn,
`✓` success, `✗` error) with colour codes (BCS0706) for human-scannable
output. Wrap colour escapes in a `[[ -t 2 ]]` TTY check so non-tty
readers see plain text:

```bash
# scenario: formatted error output with icons + colour
if [[ -t 2 ]]; then RED=$'\033[31m' YEL=$'\033[33m' RST=$'\033[0m'
else                RED=''           YEL=''           RST=''
fi
error_pretty() {
  local rc=$? line=$1
  printf '%b ✗ command failed (rc=%d) at line %d\n' "$RED" "$rc" "$line" >&2
  printf '   %b%s%b\n'                         "$YEL" "$BASH_COMMAND" "$RST" >&2
  bash_stack
}
trap 'error_pretty $LINENO' ERR
```

### JSON-mode variant for machine consumption

Long-running daemons, CI pipelines, and supervisors increasingly want
structured error output. The same handler can emit a JSON object on a
single line — easily ingested by `jq`, log aggregators, or test
runners:

```bash
# scenario: structured JSON error output
on_err_json() {
  local rc=$? line=$1
  local -a frames=()
  local i
  for ((i = 1; i < ${#FUNCNAME[@]}; i++)); do
    frames+=( "$(printf '{"func":%q,"source":%q,"line":%d}' \
                  "${FUNCNAME[i]}" "${BASH_SOURCE[i]}" "${BASH_LINENO[i-1]}")" )
  done
  local frames_json
  printf -v frames_json '%s,' "${frames[@]}"
  frames_json="[${frames_json%,}]"

  printf '{"level":"error","rc":%d,"line":%d,"command":%q,"stack":%s}\n' \
    "$rc" "$line" "$BASH_COMMAND" "$frames_json" >&2
}
trap 'on_err_json $LINENO' ERR
```

The output is one JSON object per line — `ndjson` — so a downstream
consumer can `jq -c .` over the stderr stream without buffering. Switch
between text and JSON modes via a flag (`--json` or `BCS_JSON_MODE=1`),
mirroring the BCS-CLI convention used by `bcs check -j`.

```bash
if [[ ${OUTPUT_FORMAT:-text} == json ]]; then
  trap 'on_err_json $LINENO' ERR
else
  trap 'error_pretty  $LINENO' ERR
fi
```

### What to include

A useful error report covers: exit status (`$?`); failing command
text (`$BASH_COMMAND`); source location (`$LINENO`, `BASH_SOURCE`);
call stack (`FUNCNAME[]`/`BASH_LINENO[]`); and — when the script forks
or the diagnostic crosses a pipeline — process identity (`$$`,
`$BASHPID`, `$PPID`). A consistent text format is greppable; the
JSON form is parseable. Pick one shape per script and stick to it.

**See also**: §13.1 (exit status fundamentals), §13.2 (`set -e`
semantics), §13.8 (ERR trap), §13.9 (errtrace and trap inheritance),
§13.10 (exit code conventions), §14.7 (logging discipline), BCS0602
(exit codes), BCS0701 (message control flags), BCS0702 (stdout vs
stderr separation), BCS0703 (core messaging system), BCS0706 (color
definitions), BCS0710 (standard icons), BCS0603 (trap handling).

#fin
