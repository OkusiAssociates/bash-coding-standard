<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.1 Exit status fundamentals

Every command produces an 8-bit exit status. Bash exposes it as `$?`
and uses it for control-flow decisions (`if`, `while`, `&&`, `||`,
`set -e`). The status is a single unsigned byte — a hard, kernel-level
constraint — so any code outside the range 0–255 is silently truncated.

| Range | Meaning |
|-------|---------|
| `0` | success |
| `1`–`125` | application-defined failure |
| `126` | found but not executable |
| `127` | command not found |
| `128 + N` | killed by signal `N` (e.g. 130 = SIGINT, 143 = SIGTERM) |
| `255` | fatal error from `exit -1` (truncated) |

Bash's own conventions:

- `$?` reflects the last *foreground* command. Backgrounded jobs do
  not update `$?`; their status is collected via `wait $!`.
- A pipeline's status is the **rightmost** component's status by
  default; with `set -o pipefail` it is the rightmost *non-zero*
  status (§13.5).
- A function's status is the status of its last command, or the
  argument to `return N`.
- A sourced file's status is the status of its last command, or the
  argument to `return N` (not `exit N` — `exit` ends the *whole*
  shell, not just the source).

### 8-bit truncation: `exit 257` becomes `exit 1`

The status byte is taken `mod 256`. Negative values wrap into the
high half of the byte; values above 255 wrap into the low half.

```bash
# scenario: exit status truncation
# A subshell `(exit N)` sets $? to N's truncated value without running
# the inner output; same semantics as `$(exit N)` but no SC2091 noise.
# Out-of-range exit codes are the whole point of the demo — suppress
# SC2242 across the group via a brace-block scope.
# shellcheck disable=SC2242
{
  (exit 257); echo "$?"     # ⇒ 1     (257 % 256 = 1)
  (exit 256); echo "$?"     # ⇒ 0     (256 % 256 = 0 — silent failure!)
  (exit 511); echo "$?"     # ⇒ 255   (511 % 256 = 255)
  (exit -1);  echo "$?"     # ⇒ 255   (-1 wraps to 255)
  (exit -2);  echo "$?"     # ⇒ 254
}
```

The `exit 256` case is the dangerous one: a script meant to flag
failure with code 256 reports success. Always keep exit codes inside
the 1–125 application range; reserve 126/127 for the shell, 128+ for
signals, and never go above 255.

### Pipelines and `pipefail`

```bash
# scenario: pipefail changes the status of a pipeline
false | true | true; echo "$?"          # ⇒ 0  (rightmost succeeded)

set -o pipefail
false | true | true; echo "$?"          # ⇒ 1  (leftmost non-zero wins)
```

The default behaviour exists for historical sh-compatibility; under
strict mode (BCS0101) `pipefail` is mandatory and the rightmost-only
rule never applies to BCS-compliant scripts. See §13.5 for the full
discussion.

### Signal-killed children: 128 + N

Conventionally, when a process is terminated by signal `N`, its waited
status is `128 + N`. SIGINT (2) → 130, SIGTERM (15) → 143, SIGKILL (9)
→ 137. This is a shell convention (the kernel exposes the signal
number directly through `wait(2)`'s status word, and the shell encodes
it as `128 + N` for compatibility with the 8-bit exit-status return
type). See Appendix L for the complete table.

**See also**: §13.2 (`set -e` semantics), §13.5 (pipefail), §13.10
(exit code conventions), §13.11 (propagating exit codes), Appendix K
(signal numbers), Appendix L (exit code conventions), BCS-bash
`23_EXIT-STATUS.md`, BCS0602 (exit codes).

#fin
