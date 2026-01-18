## Version Output Format

**Format: `<script_name> <version_number>` — no "version"/"v" prefix.**

```bash
# ✓ Correct
-V|--version)  echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

# ✗ Wrong
echo "$SCRIPT_NAME version $VERSION"  # → "myscript version 1.2.3"
```

**Rationale:** GNU standard; avoids redundancy (bash outputs "GNU bash, version 5.2.15" not "version version").

**Ref:** BCS0802
