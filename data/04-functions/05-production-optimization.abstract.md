## Production Script Optimization

**Remove all unused functions/variables before deployment.**

### Rationale
- Reduces script size and attack surface
- Eliminates maintenance burden for dead code

### Pattern
```bash
# Keep only what's called:
# ✓ error(), die() if used
# ✗ yn(), decp(), trim() if NOT used
# ✗ SCRIPT_DIR, DEBUG if NOT referenced
```

### Anti-patterns
- `source utils.sh` → using 2 of 20 functions
- Keeping "might need later" code in production

**Ref:** BCS0405
