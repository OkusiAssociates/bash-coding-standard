bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/File/cln/cln' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'medium' --strict 'off' '/ai/scripts/File/cln/cln'
## Analysis

### BCS0111 — WARNING — Lines 111–127 (read_conf search order)

The `read_conf` implementation uses **first-match-wins** semantics (returns on the first found file) rather than the BCS-standard cascade (source all found files, later entries override earlier). Additionally, the search path order differs from BCS0111: XDG user config is listed first (highest priority) rather than last, and the function reads patterns with `readarray`/`grep` rather than sourcing the file. This is an intentional design choice (first-match-wins for pattern files rather than variable-overlay config), and the help text documents the actual search paths. Per the compliance checking note, intentional deviations documented in help text are warnings, not violations.

**Fix:** Either document explicitly in a comment that first-match-wins is intentional, or convert to cascade sourcing per BCS0111. Since the config contains pattern data (not variable assignments), the `readarray`/`grep` approach is defensible — add a comment explaining the deliberate deviation.

---

### BCS0806 — WARNING — Line 176

`--version` and `--help` use `return 0` rather than `exit 0`. For a non-sourced script this is functionally equivalent, but the BCS canonical pattern uses `exit 0` for these terminal options. This is a minor style deviation.

**Fix:**
```bash
-V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
-h|--help)    show_help; exit 0 ;;
```

---

### BCS0806 — WARNING — Line 181 (option bundling character class)

The bundling character class `-[LaSmpPNnvqVh]?*` includes `-S` (which takes an argument) and `-m`/`-a` (which take arguments). Per BCS0805, arg-taking options must be placed last in a bundle by the user. The character class correctly includes them — this is acceptable per BCS0805. However, `-p` and `-n` in the class conflict with BCS0806 standard option letters (`-n` is standard for `--dry-run`). This is suppressed by `#bcscheck disable=BCS0806` at line 169, which covers the `-p|-n|--prompt` case. The suppression is correctly scoped to that case; the bundling class itself is not covered by the suppression directive.

**Fix:** No change required — the BCS0806 suppression documents the intentional reassignment of `-n`. The bundling class correctly reflects the options in use.

---

### BCS0207 — WARNING — Line 151, 160 (inline trim vs `trim()`)

The inline trim expression `spec="${spec#"${spec%%[![:blank:]]*}"}"; spec="${spec%"${spec##*[![:blank:]]}"}"` is used twice. BCS1211 defines a `trim()` utility function for exactly this purpose. The function is not defined in the script, so the inline form is used — which is correct per BCS0405 (don't add unused functions). However, since this logic appears in two separate places, extracting it to a local `trim()` would reduce duplication. This is a style observation only.

**Fix (optional):** Define `trim()` from BCS1211 and call `spec=$(trim "$spec")` at lines 151 and 160.

---

### BCS0503 — VIOLATION — Line 167

```bash
((max_depth != -1)) || max_depth=255
```

This is correct BCS0606 inverted-condition form. ✓ Not a violation.

*(Retracted — included only for clarity that this passes.)*

---

### BCS0226 (implicit) — WARNING — Line 226

```bash
((fnd == 1)) && [[ -z ${found_files[0]} ]] && fnd=0 ||:
```

This is a `&&...&&...||:` chain. The `||:` correctly guards the entire chain. Per BCS0606, this is acceptable. The comment on the preceding line explains the `readarray` quirk, satisfying BCS1202. No violation.

---

### BCS0702 — WARNING — Line 48

```bash
echo >&2
```

Per BCS0702, `>&2` should be placed at the **beginning** of the line, not at the end.

**Fix:**
```bash
>&2 echo
```

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0111 | WARNING | 111–127 | `read_conf` uses first-match-wins with `readarray`/`grep` instead of BCS cascade-source pattern; search order differs (XDG first, not last). Intentional but should be commented. |
| BCS0806 | WARNING | 176–177 | `--version`/`--help` use `return 0` instead of `exit 0` in a non-sourced script. |
| BCS0702 | WARNING | 48 | `echo >&2` — redirection operator `>&2` should be at the start of the line, not the end. |
bcs: ◉ Tokens: in=26314 out=1237
bcs: ◉ Elapsed: 28s
