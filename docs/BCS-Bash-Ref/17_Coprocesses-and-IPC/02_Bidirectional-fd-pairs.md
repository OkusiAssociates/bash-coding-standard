<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 17.2 Bidirectional fd pairs

The pattern of using a coproc as a persistent worker. The parent
sends queries on the write fd and reads answers on the read fd; the
child stays alive, amortising start-up cost across many calls.

### Canonical form

```bash
# scenario: keep bc resident, feed it expressions
coproc BC { bc -l; }

eval_expr() {
  local -- expr=$1 result
  printf '%s\n' "$expr" >&"${BC[1]}"
  IFS= read -r -t 1 result <&"${BC[0]}"
  printf '%s\n' "$result"
}

eval_expr '3.14 * 2'      # ⇒ 6.28
eval_expr '2 ^ 32'        # ⇒ 4294967296
eval_expr 'sqrt(2)'       # ⇒ 1.41421356237309504880

exec {BC[1]}>&-           # close write fd → child sees EOF
wait "$BC_PID"
```

- `>&"${BC[1]}"` writes to the child's stdin.
- `<&"${BC[0]}"` reads from the child's stdout.
- `read -r -t 1` adds a one-second guard against a child that hangs
  (see deadlock discussion below).
- The persistent process saves ~1 ms per call versus `result=$(echo "$expr" | bc)`.
- `bc -l` autoflushes after each line; `awk` would not. See alternative
  callout below.

### Deadlock-on-buffering — the canonical pitfall

Most line-buffered tools (`bc`, `dc`, `python -i`) flush on each
newline. *Block-buffered* tools — most C programs when stdout is a
pipe — buffer up to 4 KB before writing. The parent then `read`s
forever waiting for output that the child has produced but not
flushed:

```bash
# wrong — awk block-buffers when its stdout is a pipe
coproc AWK { awk '{ print toupper($0) }'; }
printf 'hello\n' >&"${AWK[1]}"
read -r reply <&"${AWK[0]}"        # hangs — awk's output sits in the buffer
```

The fix is `stdbuf -oL` (or `stdbuf -o0` for unbuffered), which
overrides the buffering mode at exec time:

```bash
# right — force line buffering on awk's stdout
coproc AWK { stdbuf -oL awk '{ print toupper($0) }'; }
printf 'hello\n' >&"${AWK[1]}"
read -r reply <&"${AWK[0]}"
printf '%s\n' "$reply"             # ⇒ HELLO
```

`stdbuf` works for any C program that uses stdio and respects
`LD_PRELOAD`. It does *not* work for programs that bypass stdio (Go,
some Rust binaries) or programs that explicitly set their buffer mode
(`setvbuf`). In those cases the child must be patched to flush
explicitly, or replaced.

### Choosing the worker

- `bc -l` — arbitrary-precision arithmetic, autoflushes, ubiquitous.
  Used in this chapter for illustration.
- `awk -v ...` — text transformation; needs `stdbuf -oL`.
- `python3 -u` — `-u` is Python's "unbuffered" flag.
- `jq --unbuffered` — explicit JSON-line streaming mode.

If `bc` is unavailable, the `awk` form above is the portable
fallback, with `stdbuf -oL` mandatory.

### Read-fd hygiene

- Always pair the read with `-t TIMEOUT` so a stuck child surfaces as
  an error rather than a hang (§14.2).
- Always close the write fd with `exec {fd}>&-` before `wait` —
  otherwise the child waits for EOF that never comes.

### See also

- §17.1 — `coproc` invocation reference
- §17.3 — multiple coprocesses (Bash 5.x)
- §14.2 — `read -t` timeout patterns
- BCS1101 (background job management), BCS1104 (timeout handling)

#fin
