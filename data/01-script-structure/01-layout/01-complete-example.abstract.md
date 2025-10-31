### Complete Working Example

**Production-quality installation script demonstrating all 13 mandatory BCS0101 steps in ~450 lines.**

**Key elements:**
- Shebang + shellcheck + description ’ `set -euo pipefail` + shopt
- Metadata: `VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME` (readonly after group)
- Globals: config vars (`PREFIX='/usr/local'`), runtime flags (`DRY_RUN=0`), arrays (`WARNINGS=()`)
- Terminal-aware colors: `if [[ -t 1 && -t 2 ]]` conditional assignment
- Standard messaging: `_msg()` + helpers (vecho, info, warn, error, die, yn)
- Business logic: validation ’ creation ’ installation ’ summary (bottom-up)
- Argument parsing: Short/long options (`-p|--prefix`), `noarg()` validation
- Progressive readonly: Variables locked after parsing
- `main()` orchestrates workflow
- Invocation: `main "$@"`
- End: `#fin`

**Patterns demonstrated:**
- **Dry-run:** `((DRY_RUN)) && { info '[DRY-RUN] Would...'; return 0; }`
- **Derived paths:** `update_derived_paths()` recomputes when `PREFIX` changes
- **Force mode:** Overwrite control with `((FORCE))` checks
- **Error accumulation:** `WARNINGS+=()` array for summary
- **Validation first:** `check_prerequisites` ’ `validate_config` before action
- **Conditional features:** `((INSTALL_SYSTEMD))` guards systemd operations

**Production features:** help text, version info, verbose/quiet modes, config generation, permission management, comprehensive summary report.

**Ref:** BCS01010101
