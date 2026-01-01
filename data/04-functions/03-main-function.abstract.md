## Main Function

**Include `main()` for scripts >200 lines; place `main "$@"` before `#fin`. Single entry point for testability, organization, and scope control.**

**Rationale:** Testability (source without executing), scope control (locals prevent global pollution), centralized exit code handling.

**Structure:**
```bash
main() {
  local -i verbose=0
  local -- output=''
  local -a files=()

  while (($#)); do case $1 in
    -v) verbose=1 ;;
    -o) shift; output=$1 ;;
    --) shift; break ;;
    -*) die 22 "Invalid: ${1@Q}" ;;
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

**Sourceable pattern:**
```bash
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
main "$@"
```

**Anti-patterns:**
- `main` without `"$@"` â†' arguments lost
- Functions defined after `main "$@"` â†' not available
- Argument parsing outside main â†' globals, consumed before main

**Ref:** BCS0403
