## Comments

**Comment WHY (rationale, decisions), not WHAT (code shows that).**

### Good vs Bad

```bash
# ✓ WHY: hardcoded for system-wide profile integration
declare -- PROFILE_DIR=/etc/profile.d

((max_depth > 0)) || max_depth=255  # -1 means unlimited

# ✗ BAD: "Set PROFILE_DIR to /etc/profile.d" → restates code
```

### Patterns

**Comment:** business rules, intentional deviations, complex logic, approach rationale, gotchas
**Skip:** obvious assignments, self-explanatory code, standard patterns

### Icons

`◉` info | `⦿` debug | `▲` warn | `✓` success | `✗` error

**Ref:** BCS1202
