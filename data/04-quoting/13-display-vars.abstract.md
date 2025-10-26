## Display Declared Variables

**Use `decp()` helper to inspect variable declarations without type flags.**

```bash
decp() { declare -p "$@" | sed 's/^declare -[a-zA-Z-]* //'; }
```

Shows variable values cleanly: `decp VERSION` ’ `VERSION='1.0.0'` (strips `declare -r`).

**Ref:** BCS0413
