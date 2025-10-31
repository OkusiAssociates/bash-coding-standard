## Function Names

**Use lowercase_with_underscores; prefix private functions with underscore.**

**Rationale:** Matches Unix/shell conventions, avoids conflicts with built-ins, clear visibility distinction.

**Example:**
```bash
#  Public function
process_log_file() {
  &
}

#  Private function
_validate_input() {
  &
}

#  Avoid
MyFunction() { & }      # CamelCase confusing
cd() { & }              # Overrides built-in
my-function() { & }     # Dashes problematic
```

**Anti-patterns:** Overriding built-ins without prefix/suffix (`cd()` ’ use `change_dir()`), CamelCase, special characters.

**Ref:** BCS0602
