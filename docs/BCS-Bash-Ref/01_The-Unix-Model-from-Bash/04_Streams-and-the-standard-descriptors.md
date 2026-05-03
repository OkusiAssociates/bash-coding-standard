<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 1.4 Streams and the standard descriptors

Every program inherits stdin (fd 0), stdout (fd 1), and stderr (fd 2) from its parent. The discipline of "stdout is data, stderr is diagnostics" is not enforced by the kernel — it is a convention Bash scripts must uphold to remain composable in pipelines (BCS0702). A script that mixes diagnostic chatter into stdout is a script that cannot be piped without grief.

Key facts:

- Inheritance: descriptors survive `fork`/`exec` unless marked close-on-exec (`O_CLOEXEC`). Children see the same open file descriptions until they redirect.
- Buffering (set by libc, not the kernel): line-buffered when fd 1 is a terminal, fully-buffered (≈ 4-8 KiB) when fd 1 is a pipe or file, unbuffered for fd 2 by C convention.
- `stdbuf(1)` and `unbuffer(1)` (`expect`) override a child's libc buffering; Bash's own `printf` is line-buffered and rarely needs them.
- `isatty(3)` is the C interface; in Bash use `[[ -t N ]]`.
- Prefer `printf` over `echo` for any non-trivial output (see §14.5) — `echo`'s flag handling diverges across shells.

```bash
# scenario: emit colour only on a terminal, plain text in pipes
if [[ -t 1 ]]; then
  printf '\033[32m%s\033[0m\n' OK
else
  printf '%s\n' OK
fi
```

Buffering becomes visible the moment a pipeline appears. The classic trap:

```bash
# wrong — `grep` buffers because its stdout is now a pipe
tail -f log | grep ERROR | tee errors.log
# right — force grep to line-buffer so tee sees lines as they arrive
tail -f log | grep --line-buffered ERROR | tee errors.log
# alternative — wrap the buffering child via stdbuf
tail -f log | stdbuf -oL grep ERROR | tee errors.log
```

The descriptor-vs-filename duality is exposed via `/dev/fd/N` and `/proc/self/fd/N`:

```bash
exec 3< /etc/hostname            # fd 3 opened on a real file
ls -l /proc/self/fd/3            # ⇒ symlink pointing to /etc/hostname
read -r -u3 hostname; exec 3<&-  # consume and close
```

**See also**: §1.2 (fd table), §1.3 (`/dev/null` and friends), §6.1–§6.3 (redirection operators), §14.5 (`printf` vs `echo`), §20 (avoid leaking secrets to stdout/stderr).

#fin
