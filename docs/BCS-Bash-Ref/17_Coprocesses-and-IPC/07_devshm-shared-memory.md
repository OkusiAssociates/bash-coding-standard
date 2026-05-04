<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 17.7 `/dev/shm` shared memory

`/dev/shm` is a `tmpfs` — a RAM-backed filesystem mounted by default
on most Linux distributions. Files there live entirely in RAM, are
cleared on reboot, and are visible to every process with the right
permission.

### Properties

- Files in `/dev/shm` live in RAM (or swap when memory pressure hits).
- Cleared on reboot.
- Cross-process visible (any user with permission).
- Shares quota with system RAM — large writes can OOM the host.
- Default mode 1777 (sticky, world-writable, like `/tmp`).

### Use cases

- High-throughput temporary files where disk IO would dominate.
- Coordination files (lock files, status files) that must vanish on
  reboot.
- Backing store for in-memory queues (§16.12) when the queue need not
  survive crashes.

```bash
# scenario: share a state file across cooperating processes for the boot
declare -r STATE_FILE=/dev/shm/myapp.state
printf 'pid=%d ts=%(%FT%T%z)T\n' "$$" -1 > "$STATE_FILE"
```

### Detect availability

`/dev/shm` is *not* universal: minimal containers, BSD systems, and
some hardened distributions omit it. Probe before relying on it:

```bash
# scenario: pick /dev/shm if available, /tmp otherwise
declare -- TMPBASE
if [[ -d /dev/shm && -w /dev/shm ]] && mountpoint -q /dev/shm; then
  TMPBASE=/dev/shm
else
  TMPBASE=${TMPDIR:-/tmp}
fi

WORKDIR=$(mktemp -d --tmpdir="$TMPBASE" "${SCRIPT_NAME}.XXXXXX")
trap 'rm -rf -- "$WORKDIR"' EXIT
```

`mountpoint -q DIR` returns 0 if `DIR` is the mount point of a
filesystem (i.e., not just an empty directory). It is the canonical
"is this real shared memory or just an empty path?" test.

### Detect tmpfs size

The mount option `size=` caps total RAM the tmpfs may use. To inspect:

```bash
# scenario: discover the size cap before writing GB of data
declare -- size_opt
size_opt=$(awk '$2=="/dev/shm" {print $4}' /proc/mounts)
printf 'tmpfs options on /dev/shm: %s\n' "$size_opt"
# ⇒ tmpfs options on /dev/shm:
# (the comma-separated list typically contains rw,nosuid,nodev,inode64
#  and may end in size=NNNNk on systems that pin the cap)

# numerical: bytes free right now
df -B1 --output=avail /dev/shm | tail -n1
# → an integer byte count (varies per system load)
```

`df` reports the *current* free space; the mount option reports the
configured cap. A producer should check `df` before writing because
other tenants may have consumed the share.

### `noexec` interaction

Many distributions mount `/dev/shm` with `noexec` (cannot execute
files placed there) and `nosuid` (no SUID effect). Do not write a
helper script to `/dev/shm` and try to run it — it will fail with
`Permission denied` even though the file is readable and the bits
are right (BCS1001):

```bash
# wrong on hardened systems — /dev/shm has noexec
cat > /dev/shm/helper <<'EOF'
#!/bin/bash
echo hi
EOF
chmod +x /dev/shm/helper
/dev/shm/helper          # ⇒ bash: ./helper: Permission denied (noexec)

# right — sourcing works because no exec(2) is involved
source /dev/shm/helper
```

### Cleanup discipline

Files in `/dev/shm` persist until explicitly removed (or the host
reboots). A script that creates state there should clean up via
trap (BCS0110):

```bash
declare -- shmfile=/dev/shm/myapp.$$
trap 'rm -f -- "$shmfile"' EXIT
```

### See also

- §16.10 — locking primitives that frequently land in `/dev/shm`
- §17.4 — named pipes (often created in `/dev/shm` for performance)
- BCS1006 (temporary file handling), BCS1001 (SUID/SGID prohibition)

#fin
