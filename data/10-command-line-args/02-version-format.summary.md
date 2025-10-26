## Version Output Format

**Standard format:** `<script_name> <version_number>`

The `--version` option outputs script name, space, and version number. Do **not** include the word "version" between them.

```bash
#  Correct
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

#  Wrong - do not include the word "version"
-V|--version)   echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
# Output: myscript version 1.2.3  (incorrect)
```

**Rationale:** Follows GNU standards and Unix/Linux utility conventions (e.g., `bash --version` outputs "GNU bash, version 5.2.15").
