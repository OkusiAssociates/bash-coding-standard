<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.2 Brace expansion

Generates arbitrary token sequences from a textual pattern. Phase 1
of the expansion order (§5.1) — runs **before** parameter expansion,
so a variable referenced inside the braces is not visible at brace
time. Brace expansion is purely lexical: it does not consult the
filesystem and does not see variables.

### Forms

- **Comma form**: `{a,b,c}` → three tokens `a`, `b`, `c`.
- **Range form**: `{1..5}`, `{a..z}`, `{05..10}` (zero-padded),
  `{1..10..2}` (step). Reverse ranges work: `{5..1}` → `5 4 3 2 1`.
- **Nested**: `{a,b}{1,2}` → `a1 a2 b1 b2` (Cartesian product).
- **Preamble/postscript**: `pre{a,b}post` → `preapost prebpost`.
- **Single element**: `{a}` is left literal — at least two
  comma-separated items, or a `..` range, is required.
- **Unmatched / malformed**: `{a,b` or `}b,c}` left literal.

### Outputs

```bash
# scenario: see exactly what each form produces
echo {a,b,c}            # ⇒ a b c
echo {1..5}             # ⇒ 1 2 3 4 5
echo {05..10}           # ⇒ 05 06 07 08 09 10
echo {1..10..2}         # ⇒ 1 3 5 7 9
echo {5..1}             # ⇒ 5 4 3 2 1
echo {a..e}             # ⇒ a b c d e
echo pre{a,b}post       # ⇒ preapost prebpost
echo {a,b}{1,2}         # ⇒ a1 a2 b1 b2
echo {a}                # ⇒ {a}    (single element — left literal)
echo \{a,b\}            # ⇒ {a,b}  (escaped braces — disabled)

# Variables inside braces do NOT expand:
declare -- list='1,2,3'
echo {$list}            # ⇒ {1,2,3}    (literal — phase 1 < phase 3)
```

### Why `{$list}` does not work

Brace expansion is phase 1; parameter expansion is phase 3. By the
time `$list` becomes `1,2,3`, the brace operator has already failed
to match (single element after expansion). The work-around is `eval`
(BCS1004 — almost always wrong) or arrays (`for x in "${list[@]}"; do`),
which is the canonical replacement (§4.9, BCS0206).

### Common idioms

```bash
# scenario: bulk file rename without forking sed
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# 1. atomic rename: file.txt → file.txt.bak
mv -- "$f"{,.bak}                  # expands to: mv -- "$f" "$f".bak

# 2. directory tree creation in one call
mkdir -p -- {2024,2025,2026}/{01..12}/{logs,reports}

# 3. backup + restore symmetric pair
cp -- "$conf"{,.orig}              # cp -- conf conf.orig
mv -- "$conf"{.orig,}              # mv -- conf.orig conf

# 4. compose a numeric sequence (no seq fork required)
for i in {01..10}; do printf 'job-%s\n' "$i"; done
```

### BCS posture

- Use brace expansion freely for *literal* sequences known at parse
  time. It saves forks (`seq`, `printf` loops).
- For *runtime* sequences, use arrays (BCS0206), not `eval`.
- Quote the `{,.bak}` idiom only on the static side: `mv -- "$f"{,.bak}`.
  The braces themselves must remain unquoted to expand.
- Range form preserves zero-padding only when both ends are padded:
  `{05..10}` works; `{5..010}` does not.

**See also**: §5.1 (expansion order, why brace runs first), §5.4
(parameter expansion), §5.9 (pathname expansion — distinct from brace),
§5.11 (`globstar`).

#fin
