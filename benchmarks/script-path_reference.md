# Script Path Resolution: `realpath` vs `cd -P && pwd -P` Reference

Mechanisms for resolving `SCRIPT_PATH` and `SCRIPT_DIR` from `$0` (or `${BASH_SOURCE[0]}`) at the start of a Bash script. Relevant to the BCS0106 script-metadata block:

```bash
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}
```

## Quick Comparison

| Method                     | Fork | Execve | Final-symlink follow | Direct | Symlinked | Speed vs `realpath` |
|----------------------------|:-:|:-:|:-:|:-:|:-:|:-:|
| `realpath -- "$0"`         | ✓ | ✓ | ✓ | ✓ | ✓ | 1.00x |
| `readlink -f -- "$0"`      | ✓ | ✓ | ✓ | ✓ | ✓ | ~1.00x |
| `cd -P && pwd -P` + base   | ✓ | ✗ | ✗ | ✓ | ✗ (link path) | ~2.00x |
| `cd -P && pwd -P` (dir)    | ✓ | ✗ | ✗ | ✓ | ✗ (link dir)  | ~2.10x |
| readlink loop              | ✓ | ✓ per hop | ✓ | ✓ | ✓ | 2.04x direct / **0.62x symlinked** |

Percentages from `benchmark.script-path.sh` at 5000 iterations
(i9-13900HX, Bash 5.2.21, GNU coreutils 9.4). The `cd -P && pwd -P`
variants win by ~2× because they fork a subshell but skip the execve
of an external binary. The readlink loop is competitive on direct
files (~2× faster than `realpath`) but **inverts to ~0.62× — actively
slower — once a symlink is present**, because it pays an execve per
hop *plus* the `cd+pwd` subshell afterwards.

## The Five Methods

### 1. `realpath -- "$0"` (canonical, external)

```bash
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
```

Resolves the directory *and* final-component symlinks in one call. Handles every install pattern — direct, FHS copy, dev-repo symlink, wrapper chains. One fork, one execve of `/usr/bin/realpath` (GNU coreutils). `--` terminates options so a leading-dash `$0` cannot be misparsed.

**Use when:** the script may be invoked via a symlink and you need the real file location.

### 2. `readlink -f -- "$0"` (canonical, external)

```bash
SCRIPT_PATH=$(readlink -f -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
```

Functionally identical to `realpath --` for this purpose. Both are GNU coreutils, both do the whole canonicalisation in C, performance is indistinguishable. Pick on readability — `realpath` arguably reads better.

### 3. `cd -P "${0%/*}" && pwd -P` with basename append (fast, direct only)

```bash
_dir=${0%/*}; [[ $_dir == "$0" ]] && _dir=.    # no-slash guard
SCRIPT_DIR=$(cd -P -- "$_dir" && pwd -P)
SCRIPT_PATH=$SCRIPT_DIR/${0##*/}
SCRIPT_NAME=${0##*/}
unset _dir
```

One fork for the subshell, zero execve — all work done in Bash builtins (`cd`, `pwd`). `-P` flags force physical (symlink-resolved) resolution. Roughly 2x faster than `realpath` per call.

**Semantic hole:** if `$0` itself is a symlink, the basename is appended to the *link's* directory. `SCRIPT_PATH` ends up as the link path, not the target. For pure `SCRIPT_DIR` use, the link's directory may or may not be what you want — see "Install Patterns" below.

**Edge case:** the no-slash guard handles the case where `$0` has no `/` (invoked via `PATH`, shell assigns just the basename). Without the guard, `cd -P -- "${0%/*}"` would try to `cd` into the script name.

### 4. `cd -P "${0%/*}" && pwd -P` — directory only (fastest, most common case)

```bash
_dir=${0%/*}; [[ $_dir == "$0" ]] && _dir=.
SCRIPT_DIR=$(cd -P -- "$_dir" && pwd -P)
SCRIPT_NAME=${0##*/}
unset _dir
```

Same as method 3 but skips the basename append. Marginally faster (~2.0x vs ~1.9x over `realpath`) because there is no param expansion or string concat in the hot path. Most scripts only need `SCRIPT_DIR` at runtime — `SCRIPT_NAME` is used only in help text, error messages, and `$0`-style self-reference, none of which care about the target file's canonical name.

**Use when:** you don't need `SCRIPT_PATH` (rare), and the script is not installed behind a symlink — or it is installed via an FHS copy (not a dev-repo link) where the link's directory is still the correct discovery root.

### 5. Manual readlink loop (correct but slow)

```bash
_resolve() {
  local -- path=$1 target
  while [[ -L $path ]]; do
    target=$(readlink -- "$path")
    if [[ $target == /* ]]; then
      path=$target
    else
      path=${path%/*}/$target
    fi
  done
  local -- dir=${path%/*}
  [[ $dir == "$path" ]] && dir=.
  dir=$(cd -P -- "$dir" && pwd -P)
  printf '%s\n' "$dir/${path##*/}"
}
SCRIPT_PATH=$(_resolve "$0")
```

Follows the symlink chain hop-by-hop using `readlink(1)`, then canonicalises the final directory via `cd -P && pwd -P`. Semantically equivalent to `realpath --`.

**Do not use.** It pays an execve per hop *plus* the cd+pwd fork — benchmarks show 0.63–0.65x the speed of `realpath` on a one-hop symlink, with the gap widening on longer chains. Included in the benchmark for completeness; included here so nobody proposes it as a "pure Bash" win.

## Install Patterns and Which Method Works

Different install layouts want different answers for `SCRIPT_DIR`:

### Pattern A — Direct invocation from source tree

```
/opt/myproject/bin/myscript.bash       # invoked as ./bin/myscript.bash
/opt/myproject/data/                    # data lives here
```

- `$0` = `./bin/myscript.bash` or absolute equivalent
- All five methods return the same directory: `/opt/myproject/bin`
- Discovery: `DATA_DIR=${SCRIPT_DIR%/bin}/data`
- **Fastest correct method:** 4 (dir-only cd+pwd)

### Pattern B — FHS install (files copied, no symlinks)

```
/usr/local/bin/myscript                 # actual file
/usr/local/share/myproject/data/        # data lives here
```

- `$0` = `/usr/local/bin/myscript`
- All five methods return `/usr/local/bin`
- Discovery: `DATA_DIR=${SCRIPT_DIR%/bin}/share/myproject/data`
- **Fastest correct method:** 4

This is the BCS install pattern — `make install` copies the `bcs` script to `$PREFIX/bin` and data files to `$PREFIX/share/yatti/BCS/data`. No symlinks involved.

### Pattern C — Dev-repo wrapper symlink

```
/usr/local/bin/myscript -> /opt/myproject/bin/myscript.bash    (symlink)
/opt/myproject/data/                    # data lives here
```

- `$0` = `/usr/local/bin/myscript` when invoked via `PATH`
- Methods 1, 2, 5 return `/opt/myproject/bin` (correct — follows the link)
- Methods 3, 4 return `/usr/local/bin` (wrong — link's directory, no `data/` sibling)
- **Fastest correct method:** 1 (`realpath --`)

This is the typical `symlink` command pattern for keeping dev-repo scripts on `PATH` without copying. If a project might be installed this way, `realpath` is mandatory.

### Pattern D — Hybrid (support both)

```bash
if [[ -L $0 ]]; then
  SCRIPT_PATH=$(realpath -- "$0")
  SCRIPT_DIR=${SCRIPT_PATH%/*}
else
  SCRIPT_DIR=$(cd -P -- "${0%/*}" && pwd -P)
  SCRIPT_PATH=$SCRIPT_DIR/${0##*/}
fi
SCRIPT_NAME=${0##*/}
```

Branch on whether `$0` is a symlink. Pays `realpath` only when there is a link to follow; takes the fast path for direct invocation and FHS installs. Correct in all four patterns. The `-L` test is a Bash builtin — zero cost.

**Use when:** a project ships with a dev-repo symlink wrapper *and* you care about the ~0.5 ms `realpath` startup cost. For most scripts that resolve `SCRIPT_PATH` exactly once, the saving is irrelevant.

## FHS-Aware Data Discovery Pattern

BCS scripts use a cascading search for data directories:

```bash
_find_data_dir() {
  local -a candidates=(
    "$SCRIPT_DIR/data"                              # development mode
    "${SCRIPT_DIR%/bin}/share/yatti/BCS/data"       # FHS relative to install
    '/usr/local/share/yatti/BCS/data'               # local install
    '/usr/share/yatti/BCS/data'                     # system install
  )
  local -- dir
  for dir in "${candidates[@]}"; do
    [[ -d $dir ]] && { printf '%s\n' "$dir"; return 0; }
  done
  return 1
}
```

Order matters. `$SCRIPT_DIR/data` first lets a script work from an unpacked tarball or git checkout without installation. `${SCRIPT_DIR%/bin}/share/...` handles FHS installs with non-standard prefixes (e.g. `$HOME/.local`). The absolute paths at the end are the fallback for rigid system installs.

For this pattern to work, `SCRIPT_DIR` must reflect *where the data is*, not where the user invoked the script from. That is why patterns A and B work with method 4 (the link's directory is still the install root), and why pattern C needs method 1 (the link's directory has nothing to do with where the repo data lives).

## Performance (5000 iterations, warm cache)

Measured on Intel i9-13900HX, Bash 5.2.21, GNU coreutils 9.4, 10 runs
per series, mean times in seconds. See `script-path_results_*.txt` for
raw data including 100/1K/5K iteration sweeps.

| Method                    | Direct | Symlinked |
|---------------------------|-------:|----------:|
| `realpath --`             | 5.008s | 5.073s    |
| `readlink -f --`          | 5.020s | 5.044s    |
| `cd -P && pwd -P` + base  | 2.382s | 2.563s    |
| `cd -P && pwd -P` (dir)   | 2.374s | 2.454s    |
| readlink loop             | 2.460s | **7.978s** |

Per-call cost: `realpath` ≈ 1.00 ms, `cd -P && pwd -P` (dir) ≈ 0.48 ms.
Delta ≈ 0.52 ms per invocation, invariant across iteration counts — a
fixed per-call cost dominated by fork+execve overhead for the
external-binary methods. The `readlink loop` symlinked figure
(7.978 s = ~1.6 ms per call) reflects two execves per hop plus the
final `cd+pwd` subshell.

**Cold cache:** the gap widens. First invocation of `realpath` in a fresh shell incurs PATH lookup, page faults loading the binary, `ld.so` startup, and libc initialisation. Bash builtins pay none of this.

## Common Mistakes

```bash
# wrong -- no -- option terminator, $0 starting with - gets misparsed
SCRIPT_PATH=$(realpath "$0")

# wrong -- no -P on cd, symlinks in directory components are not resolved
SCRIPT_DIR=$(cd "${0%/*}" && pwd)

# wrong -- no -P on pwd; cd -P resolves, pwd without -P may still print $OLDPWD
SCRIPT_DIR=$(cd -P "${0%/*}" && pwd)

# wrong -- no no-slash guard; fails when $0 has no / (PATH invocation)
SCRIPT_DIR=$(cd -P -- "${0%/*}" && pwd -P)

# wrong -- uses readlink without -f, only follows one hop
SCRIPT_PATH=$(readlink -- "$0")

# wrong -- $BASH_SOURCE instead of $0 is fine for direct execution, but
#         if the file is sourced, ${BASH_SOURCE[0]} refers to the sourced
#         file, not the invoking script. For a top-level script both are
#         equivalent; for dual-purpose scripts prefer ${BASH_SOURCE[0]}.
SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")   # OK, preferred for BCS
```

## Notes

- `SCRIPT_PATH` / `SCRIPT_DIR` are resolved exactly once at script startup. The absolute time saved by the fast idiom is sub-millisecond per invocation. Benchmarks exist to *understand* the trade, not to justify micro-optimising a one-shot assignment.
- `cd -P` forces physical directory resolution: symlinks in the path are canonicalised during the `cd`, and `$PWD` is updated to the real path.
- `pwd -P` prints the physical path regardless of how `cd` was invoked. Without `-P`, `pwd` prints `$PWD` which may still contain symlinks from a logical `cd`. Use both for consistency.
- The subshell in `$(cd -P -- "$dir" && pwd -P)` is isolated — the parent shell's `$PWD` is unaffected. Safe to use at any point in a script.
- `realpath --` and `readlink -f --` both resolve `/` components, `.`, `..`, and all symlinks. They also fail loudly on nonexistent paths (unless `-e`/`-m` is passed to modify behaviour).
- GNU `realpath` accepts `-s` to skip symlink expansion (logical path). Useful for comparing with `cd && pwd` (without `-P`) on a fair footing — both then produce the logical path.
- BCS uses `realpath --` in its own script metadata because correctness matters more than 0.5 ms at startup. Other projects that ship with dev-repo symlinks should do the same.
- `${BASH_SOURCE[0]}` is preferred over `$0` in scripts that might be sourced or included as libraries — `$0` refers to the invoking shell/script, which changes meaning under `source`.

