<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 1.3 Files, directories, and special files

The Linux VFS exposes seven file types through one uniform API. Bash exploits this freely; knowing which type to reach for is half the skill of writing concise shell. The conditional primaries `[[ -f ]]`, `[[ -d ]]`, `[[ -L ]]`, `[[ -p ]]`, `[[ -S ]]`, `[[ -c ]]`, `[[ -b ]]` map one-to-one to the seven types and are the canonical Bash interface; quoting these tests is mandatory under strict mode (BCS0303).

The seven canonical types and their `ls -l` glyphs:

| Glyph | Type             | Bash test    | Typical creator         |
|-------|------------------|--------------|-------------------------|
| `-`   | regular          | `[[ -f f ]]` | `>`, `cp`, editors      |
| `d`   | directory        | `[[ -d f ]]` | `mkdir`                 |
| `l`   | symbolic link    | `[[ -L f ]]` | `ln -s`                 |
| `p`   | FIFO / named pipe| `[[ -p f ]]` | `mkfifo`                |
| `s`   | Unix socket      | `[[ -S f ]]` | `socket(2)`, daemons    |
| `c`   | character device | `[[ -c f ]]` | `mknod c`               |
| `b`   | block device     | `[[ -b f ]]` | `mknod b`               |

Synthetic and special filesystems worth knowing:

- `/proc` — process introspection (`/proc/$$/fd`, `/proc/self/status`) and kernel parameters (`/proc/sys/...`).
- `/sys` — device and subsystem control (`/sys/class/net/`, `/sys/block/`).
- `/dev/null` (sink), `/dev/zero` (NUL stream), `/dev/full` (always-`ENOSPC` for write-error tests).
- `/dev/random`, `/dev/urandom` — entropy sources; on modern kernels (≥ 5.6) the two are functionally equivalent post-seed.
- `/dev/tcp/host/port` and `/dev/udp/host/port` — Bash-synthesised network endpoints, not real device nodes (see §17.6).
- `/dev/stdin`, `/dev/stdout`, `/dev/stderr`, `/dev/fd/N` — descriptor-as-path (see §1.4, §6.4).
- `tmpfs` filesystems: `/tmp`, `/run`, `/dev/shm` — RAM-backed; survives nothing across reboot.

```bash
# scenario: classify a path without forking stat(1)
classify_path() {
  local -- p="$1"
  [[ -L $p ]] && { printf 'symlink -> %s\n' "$(realpath -- "$p")"; return; }
  [[ -d $p ]] && { printf 'directory\n'; return; }
  [[ -f $p ]] && { printf 'regular (%d bytes)\n' "$(stat -c%s -- "$p")"; return; }
  [[ -p $p ]] && { printf 'fifo\n'; return; }
  [[ -S $p ]] && { printf 'socket\n'; return; }
  [[ -c $p ]] && { printf 'char-device\n'; return; }
  [[ -b $p ]] && { printf 'block-device\n'; return; }
  printf 'missing or inaccessible\n'
}
classify_path /dev/null   # ⇒ char-device
classify_path /tmp        # ⇒ directory
```

Order matters: test `-L` before `-f`/`-d` because the latter follow symlinks by default.

**See also**: §1.4 (streams), §1.6 (permission bits live on inodes), §6 (redirections that conjure FIFOs and `/dev/fd/N`), §17.6 (`/dev/tcp`).

#fin
