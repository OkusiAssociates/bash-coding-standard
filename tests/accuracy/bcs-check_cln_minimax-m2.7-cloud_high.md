bcs: ◉ Backend 'ollama' inferred from model 'minimax-m2.7:cloud'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/cln' against BCS (backend=ollama)...
bcs: ◉ bcs check --model 'minimax-m2.7:cloud' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/cln'


Looking at this script against the Bash Coding Standard systematically.

**Key observations:**
- Strict mode, shebang, metadata declarations, global variables, messaging system, function organization, argument parsing, and end marker all conform to BCS requirements.
- Messaging functions match BCS0703 (subset used: `_msg`, `info`, `warn`, `error`, `die`, `yn`) — compliant per BCS0405 (no dead code).
- Colors conditional on terminal detection — compliant per BCS0706.
- Several variables are used as arrays (`+=`, `"${var[@]}"`) but lack array type declarations.
- The bundled options pattern and case statement have minor inconsistencies.
- `find` command has an operator precedence bug.

---

**ERRORS:**

[ERROR] BCS0503 line 200-204: `find` command has operator precedence bug. The expression `-name "*.bak" -o -name "*.tmp" -print` groups as `(-name "*.bak") -o (-name "*.tmp" -print)`, so `-print` executes only when the **last** pattern matches. Files matching the first pattern are silently skipped. With `all_specs=(*.bak *.tmp)`, only `.tmp` files are reported; `.bak` files matching the first spec are never printed.

Fix recommendation: Wrap the `-o` chain in parentheses and append `-print` after the loop:

```bash
  # Build find criteria
  local -a find_expr=()
  local -i idx=0
  for spec in "${all_specs[@]}"; do
    if ((${#all_specs[@]} > 1)); then
      find_expr+=( '(' -name "$spec" -o)
    else
      find_expr+=(-name "$spec")
    fi
    idx+=1
  done
  if ((${#all_specs[@]} > 1)); then
    unset 'find_expr[-1]'
    find_expr+=(')' '-print')
  else
    find_expr+=('-print')
  fi
```

---

**WARNINGS:**

[WARN] BCS0201 line 134: `add_specs` used as array (`+=`, `"${add_specs[@]}"`) but declared as `local --` (scalar).

[WARN] BCS0201 line 137: `paths` used as array (`+=`, `"${paths[@]}"`) but declared as `local --` (scalar).

[WARN] BCS0201 line 140: `all_specs`, `add_specs_raw`, `set_specs_raw` used as arrays (`+=`) but declared as `local --` (scalar).

[WARN] BCS0201 line 141: `found_files` used as array (`+=`, `"${found_files[@]}"`, `readarray`) but declared as `local --` (scalar).

[WARN] BCS0201 line 143: `find_expr` used as array (passed to `find`) but declared as `local --` (scalar).

Fix recommendation for all: change `local --` to `local -a` for these variables.

[WARN] BCS0806 line 170: `-n` reassigned from standard `--dry-run` (BCS0806, BCS1207) to `--prompt`. BCS0806 says "Avoid reassigning a standard letter to a different purpose."

[WARN] BCS0806 lines 171, 181: Inconsistency between case statement (`-P|-N|--no-prompt`) and bundle pattern (missing `-P`). The pattern `-[LaSmpPNnvqVh]?*` does not include `-P`; only `-N` is present.

---

**Summary table:**

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0201 | style | WARN | 134 | `add_specs` array declared as scalar |
| BCS0201 | style | WARN | 137 | `paths` array declared as scalar |
| BCS0201 | style | WARN | 140 | `all_specs`, `add_specs_raw`, `set_specs_raw` arrays declared as scalar |
| BCS0201 | style | WARN | 141 | `found_files` array declared as scalar |
| BCS0201 | style | WARN | 143 | `find_expr` array declared as scalar |
| BCS0503 | core | ERROR | 200-204 | `find` precedence: `-print` only applies to last `-name` pattern |
| BCS0806 | recommended | WARN | 170 | `-n` reassigned from `--dry-run` to `--prompt` |
| BCS0806 | recommended | WARN | 171, 181 | Case/bundle inconsistency: `-P` in case, missing from bundle; `-N` in bundle, unclear in case |
bcs: ◉ Tokens: in=30922 out=12618
bcs: ◉ Elapsed: 182s
bcs: ◉ Exit: 1
bcs: ◉ Raw response: /home/sysadmin/.local/state/bcs/last-response.txt
