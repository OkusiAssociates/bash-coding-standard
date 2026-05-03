<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.3 `time` builtin vs `time` external

Bash has a `time` reserved word and a `/usr/bin/time` external.

- Bash `time`: built into the shell, times pipelines and compound commands.
- External `time`: separate process; can't time builtins or shell constructs.
- `time -p` (POSIX format) and `TIMEFORMAT` variable for bash's `time`.
- `TIMEFORMAT='%R'` for just real seconds.
- `/usr/bin/time -v` for richer info (max RSS, page faults, context switches).

```bash
# scenario: bash builtin with custom format
TIMEFORMAT='real %3R | user %3U | sys %3S | cpu %P%%'
time { sleep 0.5; ls -R /usr >/dev/null; }
# ⇒ real 0.612 | user 0.080 | sys 0.140 | cpu 35.94%
```

```text
$ /usr/bin/time -v ls -R /usr >/dev/null
        Command being timed: "ls -R /usr"
        User time (seconds): 0.06
        System time (seconds): 0.13
        Percent of CPU this job got: 99%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.20
        Maximum resident set size (kbytes): 4992
        Voluntary context switches: 1
        Involuntary context switches: 4
```

Use the builtin for shell-level work (loops, function bodies); reach for
`/usr/bin/time -v` only when you need RSS or syscall accounting on a
single external command.

**See also**: §19.2 (profiling tools), §19.4 (`BASH_XTRACEFD`), §19.6 (`EPOCHREALTIME`).

#fin
