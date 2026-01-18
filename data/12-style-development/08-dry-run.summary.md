## Dry-Run Pattern

Implement preview mode for state-modifying operations.

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

update_man_database() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would update man database'
    return 0
  fi

  # Actual man database update
  mandb -q 2>/dev/null || true
}
```

**Pattern structure:**
1. Check `((DRY_RUN))` at function start
2. Display `[DRY-RUN]` prefix message via `info`
3. Return 0 without actual operations
4. Proceed with real operations only when disabled

**Benefits:** Safe preview of destructive operations; verify paths/files/commands before execution; maintains identical control flow for logic verification.
