## Comments

Focus on **WHY** (rationale, business logic, non-obvious decisions) not **WHAT** (code already shows):

```bash
# Section separator (80 dashes)
# --------------------------------------------------------------------------------

# ✓ Good - explains WHY (rationale and special cases)
# PROFILE_DIR intentionally hardcoded to /etc/profile.d for system-wide bash profile
# integration, regardless of PREFIX. This ensures builtins are available in all
# user sessions. To override, modify this line or use a custom install method.
declare -- PROFILE_DIR=/etc/profile.d

((max_depth > 0)) || max_depth=255  # -1 means unlimited (WHY -1 is special)

# ✗ Bad - restates WHAT the code already shows
# Set PROFILE_DIR to /etc/profile.d
declare -- PROFILE_DIR=/etc/profile.d
```

**Good comments:** Non-obvious business rules, intentional pattern deviations, complex logic rationale, chosen approach justification, subtle gotchas/side effects.

**Avoid commenting:** Simple assignments, obvious conditionals, standard patterns, self-explanatory code.

**Documentation icons:** ◉ info | ⦿ debug | ▲ warn | ✓ success | ✗ error
