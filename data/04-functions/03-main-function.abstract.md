## Main Function

**Use `main()` for scripts >200 lines as single entry point; place `main "$@"` before `#fin`.**

**Rationale:** Testability (source without executing), scope control (locals in main), centralized exit code handling.

**Core pattern:**
```bash
main() {
  local -i verbose=0
  local -- output=''
  local -a files=()

  while (($#)); do case $1 in
    -v) verbose=1 ;;
    -o) shift; output=$1 ;;
    --) shift; break ;;
    -*) die 22 "Invalid: $1" ;;
    *) files+=("$1") ;;
  esac; shift; done
  files+=("$@")
  readonly -- verbose output; readonly -a files

  # Business logic...
  return 0
}
main "$@"
#fin
```

**Sourceable pattern:** `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` before `main "$@"`.

**Anti-patterns:**
- `main` without `"$@"` â†' arguments lost
- Defining functions after `main "$@"` â†' undefined at runtime
- Parsing arguments outside main â†' consumed before main runs

**Ref:** BCS0403
