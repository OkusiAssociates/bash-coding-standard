# Short-Option Disaggregation

**Split bundled options (`-abc` â†' `-a -b -c`) for Unix-compliant CLI parsing.**

## Methods (Performance)

| Method | Speed | Dependencies |
|--------|-------|--------------|
| grep | ~190/s | External, SC2046 |
| fold | ~195/s | External, SC2046 |
| **Pure Bash** | **~318/s** | **None** |

## Pure Bash (Recommended)

```bash
-[ovnVh]*)  # Split bundled options
  local -- opt=${1:1}
  local -a new_args=()
  while ((${#opt})); do
    new_args+=("-${opt:0:1}")
    opt=${opt:1}
  done
  set -- '' "${new_args[@]}" "${@:2}" ;;
```

## grep/fold Alternative

```bash
-[ovnVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```

## Critical Rules

1. List valid options in pattern: `-[ovnVh]*`
2. Options with arguments â†' end of bundle or separate
3. Place before `-*)` invalid option case

## Anti-Patterns

```bash
# âœ— Option with arg in middle of bundle
./script -von out.txt  # -o captures 'n' as argument!

# âœ“ Correct placement
./script -vno out.txt  # -n -o out.txt
```

**Ref:** BCS0805
