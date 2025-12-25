# Short-Option Disaggregation in Command-Line Processing Loops

**Split bundled short options (`-abc` → `-a -b -c`) for Unix-standard processing. Allows `script -vvn` instead of `script -v -v -n`.**

## Three Methods

### Method 1: grep (Current)
```bash
-[amLpvqVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```
~190 iter/sec | Requires `grep` + SC2046 disable

### Method 2: fold
```bash
-[amLpvqVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- "-%c " $(fold -w1 <<<"${1:1}")) "${@:2}" ;;
```
~195 iter/sec (+2.3%) | Requires `fold` + SC2046 disable

### Method 3: Pure Bash (Recommended)
```bash
-[amLpvqVh]*) # Pure bash method
  local -- opt=${1:1}; local -a new_args=()
  while ((${#opt})); do new_args+=("-${opt:0:1}"); opt=${opt:1}; done
  set -- '' "${new_args[@]}" "${@:2}" ;;
```
~318 iter/sec (**+68%**) | No external deps | No shellcheck warnings

## Rationale

1. **68% faster** - Eliminates subprocess overhead
2. **No external dependencies** - Works in minimal environments
3. **Cleaner code** - No shellcheck disables

## Key Points

- List valid options in pattern (`-[ovnVh]*`) prevents invalid disaggregation
- Place before `-*)` case
- Options with arguments at end: `-vno file.txt` ✓, `-von` ✗ (`-o` captures `n`)

## Anti-Patterns

`((i++))` → Use `i+=1` (fails with `set -e` when i=0)
`[[ -f $file ]]` → Use `[[ -f "$file" ]]` (quote variables)

**Ref:** BCS1005
