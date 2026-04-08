# Source Guards: Detecting Sourced vs Executed

Mechanisms for a Bash script to detect whether it is being sourced or
executed directly. BCS mandates the `BASH_SOURCE` check. See BCS0106, BCS0406.

## Quick Comparison

| Feature                 | BASH_SOURCE check | return trick | (return 0) subshell |
|-------------------------|:-:|:-:|:-:|
| Readable intent         | ✓ | ✗ | ✗ |
| Pure Bash (no fork)     | ✓ | ✓ | ✗ |
| Works in functions      | ✓ | ✗ | ✗ |
| POSIX sh compatible     | ✗ | ✓ | ✓ |
| Performance (relative)  | Fastest | ~2-3x slower | ~50-100x slower |
| BCS recommended         | ✓ | ✗ | ✗ |

## BCS Pattern: BASH_SOURCE Check (BCS0106)

### Dual-purpose script (functions + script mode)

```bash
# Functions defined here (available when sourced)
my_func() { ...; }

# Source guard -- everything below runs only when executed directly
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# Script mode begins
main() { ...; }
main "$@"
```

The guard returns 0 to the sourcing script if sourced, allowing functions
above the guard to be imported. Code below the guard runs only when the
file is executed directly.

### Dual-purpose with exported functions (BCS0406)

```bash
my_func() { ...; }

[[ ${BASH_SOURCE[0]} == "$0" ]] || { declare -fx my_func; return 0; }
```

The `declare -fx` exports functions to child processes when sourced.

### Pure library guard (BCS0407)

```bash
[[ ${BASH_SOURCE[0]} != "$0" ]] || { >&2 echo 'Error: must be sourced'; exit 1; }
```

Inverts the test -- prevents direct execution of library files.

## Alternative: return Trick

```bash
return 0 2>/dev/null ||:
# If we reach here, the script is being executed (not sourced)
```

**How it works:** `return` at script top-level (not inside a function) is
only valid when the script is being sourced. If executed directly, `return`
fails with "can only return from a function or sourced script". The
`2>/dev/null` suppresses that error message, and `||:` prevents `set -e`
from killing the script after the failed return.

If sourced, `return 0` succeeds and the script returns to the caller --
code below the line never runs.

**Limitations:**
- Obscure intent -- readers must understand the `return`-at-top-level trick
- Cannot be used inside a function (where `return` always succeeds)
- Three operations per call: command dispatch, redirect, error recovery
- No way to export functions before returning (the return happens immediately)
- Error message generation adds hidden overhead even when suppressed

**Why BCS avoids it:** clever but opaque. The `BASH_SOURCE` check states
its intent directly and supports the dual-purpose pattern where functions
are defined above the guard.

## Alternative: Subshell Test

```bash
if (return 0 2>/dev/null); then
  echo 'sourced'
else
  echo 'executed'
fi
```

**How it works:** `(return 0 2>/dev/null)` runs `return` inside a subshell.
In a sourced context, `return` succeeds (exit status 0). When executed
directly, `return` fails (exit status 1). The subshell isolates the side
effect -- a successful return exits only the subshell, not the caller.

**Why it is worst of all:**
- Forks a child process on every call (~50-100x slower in benchmarks)
- Doesn't actually return -- only detects, requires a separate `return` or `exit`
- Two-step: detect then act, versus the single-step BASH_SOURCE guard
- The fork cost is per-call, unlike a one-time guard at script startup

## How BASH_SOURCE Works

`BASH_SOURCE` is an array maintained by Bash:

| Index | Contains |
|-------|----------|
| `BASH_SOURCE[0]` | The file currently being executed or sourced |
| `BASH_SOURCE[1]` | The file that sourced `BASH_SOURCE[0]` |
| `BASH_SOURCE[N]` | The Nth frame in the source call stack |

`$0` is the name of the script as invoked from the command line. It does
not change when a file is sourced.

**Executed directly:** `BASH_SOURCE[0]` and `$0` are the same file.

```
$ ./myscript.sh
  BASH_SOURCE[0] = ./myscript.sh
  $0             = ./myscript.sh
  → match → script is being executed
```

**Sourced by another script:** `BASH_SOURCE[0]` is the sourced file,
while `$0` remains the original script.

```
$ ./caller.sh          # caller.sh contains: source ./myscript.sh
  BASH_SOURCE[0] = ./myscript.sh    (the sourced file)
  $0             = ./caller.sh      (the invoking script)
  → mismatch → script is being sourced
```

## Critical Ordering: Functions Before Guard

The source guard divides a dual-purpose file into two zones:

```bash
#!/usr/bin/bash
# Zone 1: Library (always available)
my_func() { ...; }
helper() { ...; }

# --- source guard ---
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# Zone 2: Script mode (only when executed directly)
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
main() { my_func; helper; ...; }
main "$@"
```

**`set -euo pipefail` goes AFTER the guard, never before.** If placed
before the guard, sourcing the file enables strict mode in the caller's
shell -- a dangerous side effect that can break the sourcing script in
unexpected ways.

**Functions go BEFORE the guard.** This is the entire point of the
dual-purpose pattern: other scripts source the file to access its
functions, and the guard prevents the script's mainline from running.

## Common Mistakes

```bash
# wrong -- set -e before guard alters the sourcing shell
set -euo pipefail
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# wrong -- unreliable, depends on invocation method
if [[ $0 == bash ]]; then
  echo 'sourced'        # fails with: bash ./script.sh, /bin/bash, etc.
fi

# wrong -- FUNCNAME-based detection, fragile
if [[ ${FUNCNAME[0]} == source ]]; then
  echo 'sourced'        # only works at specific call depths
fi

# wrong -- no guard at all
#!/usr/bin/bash
my_func() { ...; }
main() { ...; }
main "$@"               # sourcing this file runs main() immediately
```

## Notes

- The guard runs once at startup -- performance is irrelevant in practice.
  The benchmark exists to demonstrate the architectural costs of each
  mechanism, not to influence real-world script choice.
- `BASH_SOURCE` is a Bash extension (also available in zsh as a
  compatibility feature). It is not available in POSIX sh, dash, or ash.
- The return trick works in POSIX sh where `BASH_SOURCE` does not exist.
  For scripts that must run under `/bin/sh`, it is the only option.
- BCS targets Bash 5.2+ exclusively and does not require POSIX
  compatibility, so `BASH_SOURCE` is always available.
- `${BASH_SOURCE[0]}` and `$BASH_SOURCE` are equivalent when only index 0
  is needed, but the explicit index is clearer and recommended.
