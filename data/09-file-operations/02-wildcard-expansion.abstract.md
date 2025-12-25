## Wildcard Expansion

**Always prefix wildcards with explicit path to prevent filenames starting with `-` from being interpreted as flags.**

**Rationale:** Files like `-rf` or `--force` become command flags without path prefix, causing catastrophic execution errors or unintended destructive operations.

**Example:**
```bash
# ✓ Correct
rm -v ./*
for file in ./*.txt; do process "$file"; done

# ✗ Wrong - `-rf.txt` becomes `rm -v -rf.txt`
rm -v *
```

**Anti-patterns:** `rm *`, `cp * dest/`, `for f in *.sh` → Use `./*`, `./*.sh`

**Ref:** BCS1102
