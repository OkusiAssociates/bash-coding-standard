## Argument Parsing Location

**Place argument parsing inside `main()` for testability and scoping.**

### Rationale
- Testability: call `main` with synthetic args
- Scoping: parsing vars stay local to `main()`

### Pattern

```bash
main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX=$1 ;;
      -h|--help) show_help; exit 0 ;;
      -*) die 22 "Invalid option ${1@Q}" ;;
    esac
    shift
  done
  # main logic
}
main "$@"
```

### Anti-Pattern

Top-level parsing in scripts >200 lines â†' harder to test, pollutes global scope.

**Ref:** BCS0804
