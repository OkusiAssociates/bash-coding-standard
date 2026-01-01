## Version Output Format

**Output `<script_name> <version_number>` with space separator — no "version" word.**

```bash
# ✓ Correct
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

# ✗ Wrong
-V|--version)   echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
```

**Why:** GNU standards; consistent with Unix utilities.

**Ref:** BCS0802
