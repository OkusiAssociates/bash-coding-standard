## Color Support

**Test `[[ -t 1 && -t 2 ]]` before setting colors; empty strings when non-TTY.**

### Rationale
- Prevents escape codes corrupting pipes/files
- Enables automatic CI/log-safe output

### Pattern
```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi
```

### Anti-patterns
- `RED='\033[0;31m'` unconditionally → corrupts redirected output
- Missing `-t 2` check → stderr escapes leak to logs

**Ref:** BCS0701
