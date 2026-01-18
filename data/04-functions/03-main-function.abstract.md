## Main Function

**Include `main()` for scripts >200 lines as single entry point; place `main "$@"` at script end before `#fin`.**

**Rationale:** Testability (source without executing), scope control (locals prevent global pollution), centralized exit code handling.

**When required:** >200 lines, multiple functions, argument parsing, complex flow. **Skip for:** trivial wrappers, linear scripts <200 lines.

**Core pattern:**
```bash
helper_func() { : ...; }

main() {
  local -i verbose=0; local -a files=()
  while (($#)); do case $1 in
    -v) verbose=1 ;; -h) show_help; return 0 ;;
    --) shift; break ;; -*) die 22 "Invalid: $1" ;;
    *) files+=("$1") ;;
  esac; shift; done
  files+=("$@"); readonly -a files
  # ... logic ...
  return 0
}
main "$@"
#fin
```

**Testable sourcing:** `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` before main.

**Anti-patterns:** No main in complex scripts → untestable | main() not at end → undefined functions | `main` without `"$@"` → arguments lost | parsing args outside main → consumed before main called | mixing global/local state.

**Ref:** BCS0403
