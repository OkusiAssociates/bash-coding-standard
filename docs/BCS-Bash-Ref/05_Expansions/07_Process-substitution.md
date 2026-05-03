<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.7 Process substitution

Process substitution gives a command a filename argument that is
really a pipe to or from another command. The substituted process runs
concurrently with the consumer; bash hands over a `/dev/fd/N` path (or
a named pipe on systems without `/dev/fd`) and the consumer reads or
writes that path as if it were a file. This bridges the gap between
tools that accept *filenames* and tools that produce *streams* — the
canonical example being `diff`, which insists on filenames yet is
almost always wanted on the output of *commands*.

### Read substitution `<( … )`

`<(cmd)` opens `cmd`'s standard output as a readable file. The
filename appears on the command line; the consumer opens it and reads
the stream.

```bash
# scenario: diff two sorted streams without temp files
diff <(sort -u list1.txt) <(sort -u list2.txt)

# Equivalent older approach (with cleanup burden):
# t1=$(mktemp); t2=$(mktemp)
# sort -u list1.txt > "$t1"
# sort -u list2.txt > "$t2"
# diff "$t1" "$t2"
# rm -f "$t1" "$t2"
```

The substituted processes run in parallel; `diff` reads both pipes
concurrently. No temp files are created, no cleanup is required, and
no error is possible from a filesystem-full condition.

### Write substitution `>( … )` — fan-out

`>(cmd)` opens a writable file connected to `cmd`'s standard input.
Combined with `tee`, this fans one stream out to multiple consumers
in a single pass:

```bash
# scenario: archive, hash, and inspect a large stream in one pass
generate_data \
  | tee >(gzip > out.gz) \
        >(sha256sum > out.sha256) \
        >(wc -l > out.lines) \
  > /dev/null

# At completion: out.gz, out.sha256, out.lines all written; data read once.
```

Compare the alternative — running `generate_data` three times, or
storing the output in a temp file and reading it three times. The
process-substitution form is both faster and more memory-efficient
when the stream is large.

### Strict-mode and exit-status caveat

The exit status of a substituted process is *not* directly available
in `$?` — only the consumer's status is. This breaks under
`set -e` if the substituted process fails: the outer pipeline appears
to succeed.

```bash
# scenario: substituted process failure is invisible
set -euo pipefail
shopt -s inherit_errexit

# false here is silently ignored — diff sees an empty file and reports no diff
diff <(false) <(echo bar)
echo "rc=$?"     # ⇒ rc=1   — but from diff seeing a difference, not from false

# To capture the substituted process's exit, name it and wait:
exec {fd}< <(some_command); pid=$!
# ... read from /dev/fd/$fd ...
wait "$pid" || die 5 'some_command failed'
```

When the substituted process's exit status matters, capture the PID
via `$!` immediately after the substitution and `wait` on it. For
bidirectional coordination, prefer a coproc (Part XVII).

### Avoiding the `while-read | …` subshell trap

The classic *anti-pattern* is `cmd | while read -r line; …; done`,
which runs the loop body in a subshell — every variable assignment is
lost on exit. Process substitution fixes it without forking a
subshell for the loop:

```bash
# scenario: read into the current shell, no subshell
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(grep '^pattern' file.txt)
echo "matched $count lines"     # ⇒ matched 17 lines (or whatever)
```

The `< <(cmd)` form is the BCS-preferred way to feed a `while` loop
from a command's output (BCS0903). The space between the redirection
operator `<` and the substitution `<(...)` is required.

### Lifetime and FD inheritance

The substituted process is reaped by bash on the consumer's behalf.
The `/dev/fd/N` path lives only for the duration of the parent
command — referencing it after the command returns is undefined.
Substituted processes inherit the parent's open file descriptors,
which can occasionally bite (a logging FD held open keeps the parent
alive longer than expected); see §17 for management techniques.

Process substitution is not POSIX. It works in bash, ksh, and zsh.
Scripts that must run under `dash` or strict POSIX `sh` cannot use it.

**See also**: §5.6 (command substitution captures stdout into a
variable rather than a filename), §5.8 (word splitting does not affect
process-substitution paths), §17 (coproc for bidirectional pipes),
§13.5 (pipefail for pipeline-component error visibility), BCS0504
(process substitution idioms), BCS0903 (avoiding subshell-loop
pitfalls with `< <(...)`).

#fin
