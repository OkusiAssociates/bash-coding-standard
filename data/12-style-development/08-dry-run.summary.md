## Dry-Run Pattern

Implement preview mode for state-modifying operations.

```bash
declare -i DRY_RUN=0

# Parse from command-line
-n|--dry-run) DRY_RUN=1 ;;
-N|--not-dry-run) DRY_RUN=0 ;;

# Pattern: Check flag, show preview, return early
build_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would build standalone binaries'
    return 0
  fi
  make standalone || die 1 'Build failed'
}

install_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would install:' \
         "  $BIN_DIR/mailheader" \
         "  $BIN_DIR/mailmessage"
    return 0
  fi
  install -m 755 build/bin/mailheader "$BIN_DIR"/
  install -m 755 build/bin/mailmessage "$BIN_DIR"/
}
```

**Pattern:** Check `((DRY_RUN))` at function start â†' display `[DRY-RUN]` prefixed preview via `info` â†' return 0 early â†' real operations only when disabled.

**Benefits:** Safe preview of destructive operations; verify paths/files/commands before execution; identical control flow in both modes separates decision logic from action.
