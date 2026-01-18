## Readonly After Group

**Declare variables first, then make entire group readonly in single statement.**

**Rationale:** Prevents assignment-to-readonly errors; makes immutability contract explicit; script fails if variable uninitialized before readonly.

**Three-step pattern** (for args/runtime config):
```bash
declare -i VERBOSE=0 DRY_RUN=0          # 1. Declare defaults
# 2. Parse/modify in main()
readonly -- VERBOSE DRY_RUN             # 3. Lock after parsing
```

**Standard groups:**
- **Metadata**: Use `declare -r` (BCS0103 exception)
- **Colors/paths/config**: readonly-after-group pattern

```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
readonly -- PREFIX BIN_DIR SHARE_DIR    # All together
```

**Anti-patterns:**
```bash
# ✗ Premature readonly
PREFIX=/usr/local
readonly -- PREFIX    # Too early!
BIN_DIR="$PREFIX"/bin # Not protected if this fails

# ✗ Missing -- separator
readonly PREFIX       # Risky if name starts with -
```

**Key rules:**
- Initialize in dependency order → readonly together
- Always use `--` separator
- Delayed readonly after arg parsing: `readonly -- VERBOSE DRY_RUN`
- Conditional values: `[[ -z "$VAR" ]] || readonly -- VAR`

**Ref:** BCS0205
