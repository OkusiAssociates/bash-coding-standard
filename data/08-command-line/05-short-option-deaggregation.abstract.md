# Short-Option Disaggregation

**Split bundled options (`-abc` → `-a -b -c`) for Unix-compliant argument parsing.**

## Iterative Method (Recommended)

```bash
-[ovnVh]?*)  # Bundled short options
  set -- "${1:0:2}" "-${1:2}" "${@:2}"
  continue
  ;;
```

**How:** `${1:0:2}` extracts first option; `"-${1:2}"` creates remainder with dash; `continue` reprocesses.

## Performance

| Method | Iter/Sec | Dependencies | Shellcheck |
|--------|----------|--------------|------------|
| **Iterative** | **24K-53K** | None | Clean |
| grep | ~445 | grep | SC2046 |
| fold | ~460 | fold | SC2046 |

**Iterative is 53-119× faster** with no external dependencies.

## Alternative: grep/fold

```bash
-[ovnVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```

## Critical Rules

- **Pattern must list valid options:** `-[ovnVh]?*` prevents disaggregating unknown options
- **Options with arguments:** Must be at end of bundle or separate (`-vno out.txt` ✓, `-von out.txt` ✗)
- Place disaggregation case **before** `-*)` invalid option handler

## Anti-Patterns

```bash
# ✗ Missing continue (infinite loop)
-[ovnVh]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}" ;;

# ✗ Option with arg in middle of bundle
./script -von out.txt  # -o captures "n" as argument!
```

**Ref:** BCS0805
