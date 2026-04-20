# Directory Path Resolution: `cd && pwd` vs `realpath` Reference

Resolving a directory path to a normalised absolute form is one of the
most frequently written Bash idioms. There are two implementation
families: a Bash builtin pair (`cd && pwd` in a subshell) and the GNU
coreutils `realpath` external. Each has a *logical* and a *canonical*
variant, giving four idioms total. This doc compares them on speed,
semantics, error behaviour, and when each is appropriate.

This doc is **distinct from `script-path_reference.md`**, which covers
resolving `$0` (script self-location) at startup. Path resolution is
the more general case: an arbitrary directory path, possibly from user
input or a configuration file, possibly resolved in a loop.

## Quick Comparison

| Idiom                         | Symlinks | Fork | Execve | Errors on bad input | Speed |
|-------------------------------|:--------:|:----:|:------:|:-------------------:|------:|
| `cd "$dir" && pwd`            | preserved | ✓ | ✗ | partial¹ | **fastest** |
| `realpath -s -- "$dir"`       | preserved | ✓ | ✓ | yes | ~2.1× slower |
| `cd -P "$dir" && pwd -P`      | resolved  | ✓ | ✗ | partial¹ | **fastest** |
| `realpath -- "$dir"`          | resolved  | ✓ | ✓ | yes | ~2.0× slower |

¹ `cd` errors when the directory doesn't exist or isn't accessible,
but it does not validate path syntax or normalise non-existent
intermediate components the way `realpath` does. See "Error Behaviour"
below.

## Benchmark Results

Measured on Intel i9-13900HX, Bash 5.2.21, GNU coreutils 9.4, 10 runs
per series, mean times in seconds. Test target was a temporary tree
with a symlinked intermediate directory. See
`path-resolve_results_*.txt` for raw data.

### Pair A — Logical resolve (symlinks preserved)

| Iterations | `cd && pwd`  | `realpath -s` | Speedup |
|-----------:|-------------:|--------------:|--------:|
| 100        | **0.048**    | 0.099         | 2.1×    |
| 1K         | **0.473**    | 1.001         | 2.1×    |
| 5K         | **2.347**    | 5.015         | 2.1×    |

### Pair B — Canonical resolve (symlinks resolved)

| Iterations | `cd -P && pwd -P` | `realpath` | Speedup |
|-----------:|------------------:|-----------:|--------:|
| 100        | **0.051**         | 0.100      | 1.9×    |
| 1K         | **0.512**         | 1.011      | 2.0×    |
| 5K         | **2.514**         | 5.016      | 2.0×    |

**Reading the numbers:** the speedup is constant (~2×) because the
delta is a fixed per-call cost: `realpath` pays an `execve()` on top of
the same `fork()` that `cd && pwd` already pays for the subshell.
Per-call: `realpath` ≈ 1.00 ms, `cd && pwd` ≈ 0.50 ms. Delta ≈ 0.50 ms.

## The Two Semantic Pairs

The single most common mistake is comparing across pairs — measuring
`cd && pwd` against `realpath` and concluding "the builtin is twice as
fast." It is, but they're computing different things. A fair
comparison must match semantics.

### Logical (symlinks preserved)

The path the user typed, with `.` and `..` collapsed but symlinks left
intact.

```bash
# both produce: /tmp/work/link/b/c   (where link -> a)
result=$(cd -- "$dir" && pwd)
result=$(realpath -s -- "$dir")
```

`cd` (no `-P`) updates `$PWD` logically. `pwd` (no `-P`) prints
`$PWD`. `realpath -s` (the `-s` flag is "skip symlink expansion")
matches that semantic.

**Use when:** the user typed the path, you want to echo it back to
them, or you need the path as-named in error messages or logs.
Resolving symlinks would confuse the user ("I didn't type that path").

### Canonical (symlinks resolved)

The fully resolved physical path, with `.`, `..`, and every symlink
component expanded.

```bash
# both produce: /tmp/work/a/b/c   (link -> a)
result=$(cd -P -- "$dir" && pwd -P)
result=$(realpath -- "$dir")
```

`cd -P` resolves symlinks during the `cd`. `pwd -P` prints the
physical path. `realpath` (no flags) does the full canonicalisation in
one shot.

**Use when:** comparing two paths for equality, building a stable
dictionary key, deduplicating results, or verifying whether two paths
refer to the same on-disk object. Two logically distinct paths can
canonicalise to the same physical path; logical comparison would miss
that.

## Error Behaviour

The two families differ on what counts as an error.

### `cd && pwd` — succeeds only on accessible existing directories

```bash
$ result=$(cd -- /nonexistent && pwd) || echo "failed: $?"
bash: cd: /nonexistent: No such file or directory
failed: 1

$ result=$(cd -- /etc/shadow && pwd) || echo "failed: $?"   # not a directory
bash: cd: /etc/shadow: Not a directory
failed: 1

$ result=$(cd -- "$file_no_x_perm" && pwd) || echo "failed: $?"   # no execute bit
bash: cd: ...: Permission denied
failed: 1
```

`cd` fails noisily on stderr and returns non-zero. Under `set -e` the
whole script aborts unless you handle the failure. The error message
goes through Bash's own builtin error path.

### `realpath` — strict path validation, configurable

```bash
$ realpath -- /nonexistent                    # default: fails
realpath: /nonexistent: No such file or directory

$ realpath -m -- /nonexistent/deeper/path     # -m: missing OK
/nonexistent/deeper/path

$ realpath -e -- /etc                         # -e: must exist (default for full paths)
/etc

$ realpath -- "$file"                         # fine on a regular file
/etc/passwd
```

`realpath` is more flexible: `-e` requires existence, `-m` allows
missing components, default mode requires the *final* component to
exist but not intermediate ones. None of these modes have a
`cd && pwd` equivalent.

**The trade-off:** `cd && pwd` is faster but only works for existing,
accessible directories. `realpath` works for arbitrary path strings
(files, missing paths, partial paths) but pays the fork+execve cost.

## Common Patterns

### Resolve user-supplied directory with default

```bash
# fast path for an existing accessible directory
target_dir=$(cd -P -- "${1:-.}" && pwd -P)

# strict, with explicit error on bad input
target_dir=$(realpath -e -- "${1:-.}") \
  || die 3 "Cannot resolve directory ${1@Q}"
```

### Resolve a path that may not exist yet

```bash
# planned output path, may not exist
output_path=$(realpath -m -- "$user_path")

# cd && pwd would fail here — wrong tool
```

### Compare two paths for equality

```bash
# correct — canonicalise both, then compare
a=$(realpath -- "$path_a") || die 1 "Bad path $path_a"
b=$(realpath -- "$path_b") || die 1 "Bad path $path_b"
[[ $a == "$b" ]] && echo 'same physical location'

# wrong — string comparison
[[ $path_a == "$path_b" ]]   # /etc and /etc/. differ as strings
```

### Hot loop over many directories

```bash
# correct — pure-Bash form when correctness allows it
for dir in "${dirs[@]}"; do
  resolved=$(cd -P -- "$dir" && pwd -P) || continue
  process "$resolved"
done

# acceptable — realpath when paths might be missing
for dir in "${dirs[@]}"; do
  resolved=$(realpath -m -- "$dir")
  process "$resolved"
done
```

In a thousand-iteration loop the cd+pwd form saves ~0.5 s. In a
ten-iteration loop the saving (~5 ms) is invisible.

## Common Mistakes

```bash
# wrong — no -P on cd, symlinks in path components are NOT resolved
result=$(cd -- "$dir" && pwd -P)         # mismatched: cd logical, pwd physical
                                         # cd -P missing means $PWD is logical;
                                         # pwd -P prints OLDPWD-canonical, may differ

# wrong — no -P on pwd, may print OLDPWD which still has symlinks
result=$(cd -P -- "$dir" && pwd)         # cd resolves, but pwd reads $PWD
                                         # which may not match the canonical form

# wrong — cross-pair semantic comparison
fast=$(cd -- "$dir" && pwd)              # logical
slow=$(realpath -- "$dir")               # canonical
[[ $fast == "$slow" ]]                   # may differ when $dir contains a symlink

# wrong — no -- option terminator, leading-dash $dir misparsed
result=$(cd "$dir" && pwd)               # cd treats -foo as an option
result=$(realpath "$dir")                # same hazard

# wrong — assumes cd succeeded, no error handling
result=$(cd -- "$dir" && pwd) ||:        # ||: silently swallows failure,
                                         # leaving $result empty
                                         # script proceeds with bad state
```

## Relationship to BCS

BCS recommends `realpath -- "$0"` for **script self-location** (BCS0103
script metadata block) on correctness grounds — the cost is paid once
at startup, and a script invoked through a symlinked wrapper needs the
canonical path to find its sibling data directory.

For **arbitrary directory resolution** in business logic, BCS makes no
prescription. Pick on use case:

- Hot loop over known-existing directories → `cd -P && pwd -P` (or
  `cd && pwd` if logical is enough).
- One-shot resolution of a path that might be missing or wrong →
  `realpath` (use `-e`/`-m` to control existence semantics).
- Comparing paths for physical equality → `realpath` on both sides.

The script-path benchmark (`benchmark.script-path.sh`) covers a
related-but-distinct comparison: five idioms for resolving `$0`
specifically (with the symlinked-wrapper case as the load-bearing
scenario). See `script-path_reference.md` for that analysis.

## Notes

- `cd -P` resolves symlinks during the `cd` operation; `$PWD` is
  updated to the canonical form. `cd` (no `-P`) updates `$PWD`
  logically — symlink components are left as the user named them.
- `pwd -P` prints the canonical form regardless of how `cd` was
  invoked, by reading `getcwd(2)` from the kernel rather than
  echoing `$PWD`. `pwd` (no `-P`) prints `$PWD` directly.
- The subshell `$(cd ... && pwd)` isolates the `cd` — the parent
  shell's `$PWD` is unaffected. This is what makes the pattern safe
  to use anywhere in a script.
- `realpath` is GNU coreutils. BSD `realpath` exists but has different
  semantics (no `-s`/`-m`/`-e`). For portable scripts targeting
  non-Linux, prefer the `cd && pwd` form or guard the `realpath` call.
- `readlink -f` is functionally equivalent to `realpath` (both follow
  the symlink chain to the canonical path), but `realpath` is
  preferred in BCS for readability.
- All benchmark results above are warm-cache. First invocation in a
  fresh shell pays additional cost: PATH lookup, page faults loading
  the `realpath` binary, `ld.so` startup, libc initialisation. Bash
  builtins pay none of this — the cold-cache gap widens further.

