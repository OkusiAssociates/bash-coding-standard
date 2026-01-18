## Argument Parsing Location

**Parse arguments inside `main()` rather than at top level.**

**Why:** Testability (test `main()` with different args), local variable scoping, encapsulation. Exception: simple scripts (<200 lines) may use top-level parsing.

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
  # main logic here
}
main "$@"
```

**Anti-pattern:** Top-level parsing in complex scripts → poor testability, polluted global scope.

**Ref:** BCS0804
