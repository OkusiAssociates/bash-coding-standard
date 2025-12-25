## Argument Parsing Location

**Place argument parsing inside `main()` function, not at top level.**

**Rationale:** Enables testability (can invoke `main()` with test arguments), cleaner scoping (parsing variables local to `main()`), better encapsulation.

**Pattern:**

```bash
main() {
  while (($#)); do
    case $1 in
      --opt)    FLAG=1 ;;
      --prefix) shift; PREFIX="$1" ;;
      -h|--help) show_help; exit 0 ;;
      -*)       die 22 "Invalid option '$1'" ;;
      *)        die 2 "Unknown option '$1'" ;;
    esac
    shift
  done

  check_prerequisites
  process_data
}

main "$@"
```

**Exception:** Simple scripts <200 lines without `main()` may parse at top level ’ `while (($#)); do case $1 in -v) VERBOSE=1 ;; esac; shift; done`

**Ref:** BCS1004
