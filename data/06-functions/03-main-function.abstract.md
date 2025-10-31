## Main Function

**Include `main()` for scripts >200 lines as single entry point; place `main "$@"` before `#fin`.**

**Rationale:** Enables testability (source without executing), organization, and scope control.

**Structure:**
```bash
main() {
  local -i verbose=0
  local -- output_dir=''
  local -a files=()

  # Parse args
  while (($#)); do case $1 in
    -v|--verbose) verbose=1 ;;
    -o|--output) shift; output_dir="$1" ;;
    -h|--help) usage; return 0 ;;
    -*) die 22 "Invalid: $1" ;;
    *) files+=("$1") ;;
  esac; shift; done

  readonly -- verbose output_dir
  readonly -a files

  # Validation & logic
  [[ ${#files[@]} -eq 0 ]] && die 22 'No files'

  return 0
}

main "$@"
#fin
```

**Testable pattern:**
```bash
main() { : ; }

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
#fin
```

**Anti-pattern:**
```bash
# ✗ Args parsed outside main
while (($#)); do : ; done
main "$@"  # Args already consumed!

# ✓ Parse in main
main() {
  while (($#)); do : ; done
}
main "$@"
```

**Ref:** BCS0603
