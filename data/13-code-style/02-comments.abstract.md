## Comments

**Explain WHY, not WHAT. Code shows what happens; comments explain rationale, business logic, and non-obvious decisions.**

**Rationale:**
- Self-documenting code reduces maintenance burden; comments decay when code changes
- WHY explanations capture decision context that code structure cannot express

```bash
#  Explains rationale and special cases
# PROFILE_DIR hardcoded to /etc/profile.d for system-wide integration,
# regardless of PREFIX, ensuring builtins available in all sessions
declare -- PROFILE_DIR=/etc/profile.d

((max_depth > 0)) || max_depth=255  # -1 means unlimited

#  Restates what code shows
# Set PROFILE_DIR to /etc/profile.d
declare -- PROFILE_DIR=/etc/profile.d
```

**Comment when:**
- Non-obvious business rules/edge cases exist
- Intentional deviations from patterns occur
- Specific approach chosen over alternatives requires explanation

**Don't comment:**
- Simple assignments ’ `PREFIX=/usr/local`
- Self-explanatory code with clear naming
- Standard BCS patterns

**Section separators:** 80 dashes
```bash
# --------------------------------------------------------------------------------
```

**Documentation icons:** É (info), ¿ (debug), ² (warn),  (success),  (error)

**Ref:** BCS1302
