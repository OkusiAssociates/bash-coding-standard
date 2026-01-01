## Version Output Format

**Standard format:** `<script_name> <version_number>`

Output script name, space, version number. Do **not** include "version", "vs", or "v".

```bash
# ✓ Correct
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

# ✗ Wrong - do not include the word "version"
-V|--version)   echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
# Output: myscript version 1.2.3  (incorrect)
```

**Rationale:** Follows GNU standards and Unix/Linux utility conventions.
