## Comments

**Explain WHY (rationale, decisions) not WHAT (code already shows).**

```bash
# ✓ WHY - explains rationale
# PROFILE_DIR hardcoded for system-wide bash profile integration
declare -- PROFILE_DIR=/etc/profile.d
((max_depth > 0)) || max_depth=255  # -1 means unlimited

# ✗ WHAT - restates code
# Set PROFILE_DIR to /etc/profile.d
declare -- PROFILE_DIR=/etc/profile.d
```

**Good:** Business rules, intentional deviations, complex logic rationale, gotchas �' **Avoid:** Obvious code, self-explanatory names

**Icons:** `◉` info | `⦿` debug | `▲` warn | `✓` success | `✗` error

**Ref:** BCS1202
