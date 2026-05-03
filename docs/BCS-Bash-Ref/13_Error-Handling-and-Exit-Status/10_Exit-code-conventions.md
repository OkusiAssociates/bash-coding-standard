<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.10 Exit code conventions

Standardised exit codes let callers (other scripts, supervisors, CI
systems) interpret a failure programmatically. Bash scripts mix several
conventions; choose one and document it. Consistency is more important
than which scheme is "right".

### Reserved by the shell and the kernel

| Code | Meaning |
|------|---------|
| `0`     | success |
| `1`     | generic error (catch-all) |
| `2`     | misuse of shell builtins / usage error (BSD convention) |
| `126`   | command found but not executable |
| `127`   | command not found |
| `128 + N` | killed by signal `N` (e.g. 130 = SIGINT, 143 = SIGTERM) |
| `255`   | wrap-around from `exit -1` (don't do this) |

Application codes should stay in `1`–`125` to avoid colliding with the
shell-reserved high range.

### `sysexits.h` (BSD)

The 64–113 range carries semantic meanings from `<sysexits.h>`:

| Code | Symbol | Meaning |
|------|--------|---------|
| 64 | `EX_USAGE`       | usage error |
| 65 | `EX_DATAERR`     | input data error |
| 66 | `EX_NOINPUT`     | missing input |
| 67 | `EX_NOUSER`      | unknown user |
| 68 | `EX_NOHOST`      | unknown host |
| 69 | `EX_UNAVAILABLE` | service unavailable |
| 70 | `EX_SOFTWARE`    | internal software error |
| 71 | `EX_OSERR`       | system error |
| 72 | `EX_OSFILE`      | system file error |
| 73 | `EX_CANTCREAT`   | cannot create output |
| 74 | `EX_IOERR`       | I/O error |
| 75 | `EX_TEMPFAIL`    | temporary failure (retryable) |
| 76 | `EX_PROTOCOL`    | protocol error |
| 77 | `EX_NOPERM`      | permission denied |
| 78 | `EX_CONFIG`      | configuration error |

This range is widely used by BSD-derived tools and `mailx`; less common
in shell scripts.

### BCS exit-code conventions

The Bash Coding Standard defines a compact subset focused on
shell-script needs (BCS0602). These overlap deliberately with the
shell-reserved codes (1, 2) and pick non-conflicting numbers
elsewhere:

| Code | Meaning |
|------|---------|
| 1  | generic error |
| 2  | usage error |
| 3  | file not found |
| 5  | I/O error |
| 13 | permission denied (`EACCES`) |
| 18 | missing dependency |
| 22 | invalid argument (`EINVAL`) |
| 24 | timeout (`ETIME`) |

```bash
# scenario: BCS-style die helpers with explicit codes
[[ -r $config ]] || die 3 "config not readable: $config"
command -v jq    >/dev/null || die 18 "missing dependency: jq"
[[ $verbose =~ ^[01]$ ]] || die 22 "verbose must be 0 or 1: '$verbose'"
```

For the canonical numeric→meaning table, including the `sysexits.h`
range, the shell-reserved codes, and the BCS subset side-by-side, see
**Appendix L (Exit Code Conventions)**. Cross-script callers should
read the appendix when defining a contract; script authors should pin
to one column and document it.

For a new BCS project, use the subset above and document the
project-specific extensions at the top of the script as a `# Exit
codes:` comment block. A downstream caller can then `case $rc` without
grepping source.

Three reminders: `kill -9` reports waited-status `137` (= 128 + 9)
and the EXIT trap does not run; `set -e` exits with the *failing
command's* status, not 1; `exit -1` becomes 255 and `exit 256`
becomes 0 (§13.1) — stay inside 1–125.

**See also**: §13.1 (exit status fundamentals), §13.2 (`set -e`
semantics), §13.11 (propagating exit codes), Appendix L (Exit Code
Conventions), Appendix K (Signal Numbers — Linux), BCS Section 6
(Error Handling), BCS0602 (exit codes), BCS-bash `23_EXIT-STATUS.md`.

#fin
