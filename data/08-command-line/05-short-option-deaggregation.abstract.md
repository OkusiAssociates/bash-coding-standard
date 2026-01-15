# Short-Option Disaggregation

**Split bundled options (`-abc` â†' `-a -b -c`) to follow Unix conventions.**

## Methods

| Method | Speed | Deps | Notes |
|--------|-------|------|-------|
| grep | ~190/s | grep | Current standard |
| fold | ~195/s | fold | Marginal gain |
| **Pure Bash** | **~318/s** | None | **68% faster**, no shellcheck |

## Pattern

```bash
# grep method (current standard)
-[ovnVh]*) #shellcheck disable=SC2046
    set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;

# Pure bash (recommended for performance)
-[ovnVh]*)
    local -- opt=${1:1}; local -a new_args=()
    while ((${#opt})); do new_args+=("-${opt:0:1}"); opt=${opt:1}; done
    set -- '' "${new_args[@]}" "${@:2}" ;;
```

## Critical Rules

- List valid options in pattern: `-[ovnVh]*`
- Options with arguments must be at end of bundle or separate
- Place before `-*)` invalid option case

## Anti-patterns

`-von output.txt` â†' `-o` captures `n` as argument (wrong order)

**Ref:** BCS0805
