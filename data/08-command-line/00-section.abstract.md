# Command-Line Arguments

**Standard argument parsing with short (`-h`) and long (`--help`) options for consistent CLI interfaces.**

Core requirements:
- Version format: `scriptname X.Y.Z`
- Validate required args; detect option conflicts
- Simple scripts: top-level parsing; complex: in `main()`

```bash
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help) usage; exit 0 ;;
    -v|--version) echo "${0##*/} 1.0.0"; exit 0 ;;
    --) shift; break ;;
    -*) die "Unknown option: $1" ;;
    *) args+=("$1") ;;
  esac; shift
done
```

Anti-patterns: No `getopt`/`getopts` for long options â†' use `case`; no silent failures on missing required args.

**Ref:** BCS0800
