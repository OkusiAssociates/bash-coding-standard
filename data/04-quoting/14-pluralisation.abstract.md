## Pluralisation Helper

**Use `s()` helper for conditional plurals in messages.**

**Rationale:** Prevents grammatically incorrect messages like "1 files processed" or verbose conditionals throughout code.

**Implementation:**
```bash
s() { (( ${1:-1} == 1 )) || echo -n 's'; }
```

**Usage:**
```bash
echo "$count file$(s "$count") processed"
# Outputs: "1 file processed" or "5 files processed"
```

**Anti-patterns:** `’` Writing conditional logic inline: `[[ $n -eq 1 ]] && echo "file" || echo "files"`

**Ref:** BCS0414
