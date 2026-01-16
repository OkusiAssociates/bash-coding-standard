# Short-Option Disaggregation

**Split bundled options (`-abc` �' `-a -b -c`) for Unix-compliant CLI parsing.**

## Iterative Method (Recommended)

```bash
-[ovnVh]?*)  set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
```

**Pattern:** `${1:0:2}` extracts first option; `"-${1:2}"` creates remainder; `continue` reprocesses.

## Rationale

- **53-119× faster** than grep/fold (~24,000-53,000 vs ~450 iter/sec)
- Pure bash, no external deps, no shellcheck warnings

## Alternatives

| Method | Speed | Notes |
|--------|-------|-------|
| grep | ~445/s | `set -- '' $(printf '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"` SC2046 |
| fold | ~460/s | Same pattern with `fold -w1` |
| bash loop | ~318/s | More verbose, no `continue` needed |

## Anti-patterns

```bash
# ✗ Options with args mid-bundle
-von file    # -o captures "n" as argument

# ✓ Args at end or separate
-vno file    # -v -n -o file
```

## Edge Cases

- List valid options explicitly: `-[ovnVh]?*` prevents unknown option disaggregation
- Options requiring arguments must be at bundle end or separate

**Ref:** BCS0805
