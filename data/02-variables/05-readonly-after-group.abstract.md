## Readonly After Group

**Declare variables with values first, then make entire group readonly in single statement.**

**Rationale:** Prevents assignment-to-readonly errors; makes immutability contract explicit; fails if uninitialized.

**Three-step pattern** (for args/config that need parsing):
```bash
# 1. Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0
declare -- OUTPUT_FILE=''

# 2. Parse/modify in main()
main() {
  while (($#)); do case $1 in
    -v) VERBOSE+=1 ;; -n) DRY_RUN=1 ;;
  esac; shift; done
  # 3. Readonly AFTER parsing
  readonly -- VERBOSE DRY_RUN OUTPUT_FILE
}
```

**Group patterns:**
- **Metadata**: Use `declare -r` (BCS0103 exception)
- **Colors**: Conditional `declare -r` in if/else
- **Paths/Config**: Initialize â†' `readonly --` group

**Anti-patterns:**
- `readonly -- VAR` before derived vars set â†' inconsistent protection
- Missing `--` separator â†' option injection risk
- `readonly` inside conditional â†' may not execute

**Ref:** BCS0205
