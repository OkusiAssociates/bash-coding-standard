## Dry-Run Pattern

Implement preview mode for operations that modify system state, allowing users to see what would happen without making actual changes.

```bash
# Declare dry-run flag
declare -i DRY_RUN=0

# Parse from command-line
-n|--dry-run) DRY_RUN=1 ;;
-N|--not-dry-run) DRY_RUN=0 ;;

# Pattern: Check flag, show preview message, return early
build_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would build standalone binaries'
    return 0
  fi

  # Actual build operations
  make standalone || die 1 'Build failed'
}

install_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would install:' \
         "  $BIN_DIR/mailheader" \
         "  $BIN_DIR/mailmessage" \
         "  $BIN_DIR/mailheaderclean"
    return 0
  fi

  # Actual installation operations
  install -m 755 build/bin/mailheader "$BIN_DIR"/
  install -m 755 build/bin/mailmessage "$BIN_DIR"/
  install -m 755 build/bin/mailheaderclean "$BIN_DIR"/
}
```

**Pattern structure:**
1. Check `((DRY_RUN))` at start of functions that modify state
2. Display preview message with `[DRY-RUN]` prefix using `info`
3. Return early (exit code 0) without performing operations
4. Proceed with real operations only when dry-run disabled

**Rationale:** Separates decision logic from action. Script flows through same functions whether in dry-run mode or not, enabling logic verification without side effects. Safe preview of destructive operations with identical control flow.
