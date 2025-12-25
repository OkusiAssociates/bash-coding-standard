## Version Output Format

**Format `--version` output as: `<script_name> <version_number>` without the word "version".**

```bash
#  Correct
-V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

#  Wrong
-V|--version) echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
```

**Rationale:** GNU/Unix standard format (e.g., `bash --version` ’ "GNU bash, version 5.2.15").

**Ref:** BCS1002
