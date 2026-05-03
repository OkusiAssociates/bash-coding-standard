<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 1.7 Exit status and process termination

Every process exits with an 8-bit status code. Bash exposes it as `$?`, propagates it through pipelines, and uses it to drive `set -e`, `||`, `&&`, and `if`. The encoding distinguishes ordinary exits from termination by signal.

### Encoding

- **Normal exit:** `exit N` returns `N & 0xFF` to the parent. `exit 256` reports as 0; `exit 257` as 1.
- **Signal termination:** Bash reports the status as `128 + signum`. `kill -TERM` (signal 15) yields 143; `kill -KILL` (9) yields 137.
- `0` is success; non-zero is failure. This convention is universal — POSIX and the Linux kernel both observe it.

### BCS exit-code table

The Bash Coding Standard prescribes a fixed vocabulary so that callers can branch on `$?` without parsing messages (BCS0602):

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Usage / argument error |
| 3 | File or directory not found |
| 5 | I/O error |
| 13 | Permission denied |
| 18 | Missing dependency |
| 22 | Invalid argument |
| 24 | Timeout |

Reserved ranges (do not use): 64-78 (`sysexits.h`), 126 (cannot execute), 127 (not found), 128+n (signalled).

### Reading `$?`

`$?` is overwritten by every command and is "sticky" only until the next one. Capture it immediately into a typed integer if you need the value later.

```bash
# scenario: $? is replaced by every command, even by [[ ]]
( exit 42 )
declare -i rc=$?              # ⇒ rc=42
[[ -d /nonexistent ]]         # this overwrites $?
echo "rc=$rc, \$?=$?"          # ⇒ rc=42, $?=1
```

### Termination by signal — the `128 + signum` rule

When a child is killed by a signal, Bash synthesises the status from the kernel-reported signal number. Use `kill -l` to map back.

```bash
# scenario: prove 128+signum encoding
( kill -TERM "$BASHPID" ) || true
echo "$?"                    # ⇒ 143  (128 + 15)

( kill -INT "$BASHPID" ) || true
echo "$?"                    # ⇒ 130  (128 + 2)

kill -l 143                  # ⇒ TERM
```

### Pipelines and `set -o pipefail`

By default, a pipeline's exit status is that of its **last** command. `set -o pipefail` (mandatory under strict mode, BCS0101) returns the rightmost non-zero status, exposing failures in upstream stages.

```bash
# scenario: pipefail surfaces the upstream failure
set -o pipefail
false | true
echo "$?"      # ⇒ 1   (without pipefail, would be 0)
```

### `exit N` arithmetic and `WIFSIGNALED`

```bash
# wrong — relying on >255 status
exit 1000        # delivered as 232 (1000 % 256)

# right — keep within the 0-127 application range
exit 22          # invalid argument, BCS table
```

`WIFSIGNALED`, `WTERMSIG`, and `WCOREDUMP` are kernel-level macros wrapping the same status word; Bash reports the synthesised `128 + signum` form for shell scripts and reserves the kernel-level bits for `wait`'s C callers.

### `sysexits.h` legacy

The 64-78 range from BSD's `sysexits.h` (`EX_USAGE=64`, `EX_DATAERR=65`, …) is still seen in older Unix tooling but is not used in modern Bash. Treat it as reserved (do not collide), not as a target.

**See also**: §1.1 (`wait` reaps the status), §1.8 (signal taxonomy), §12 (signal handling), BCS0602 (exit codes), BCS0601 (exit on error), BCS0101 (strict mode).

#fin
