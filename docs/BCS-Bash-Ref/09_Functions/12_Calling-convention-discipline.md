<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.12 Calling-convention discipline

Stylistic and architectural rules for clean function design. The
core rule: a function is *contractual* — it should declare its
inputs, its outputs, and its side effects, and the body should not
quietly violate the contract.

- **Pure functions**: no globals, all input via parameters, output
  via stdout or namerefs.
- **One return path** or consistent return paths; no surprise
  `exit` from inside a function.
- Document expected `$1`, `$2`, … in a comment or via `${1:?}` for
  enforced presence.
- Validate at the boundary: top of function checks its arguments;
  internals trust them.
- Avoid command substitution in tight loops (forks a subshell; can
  dominate run time).
- Prefer namerefs when output is large; avoid for tiny scalars
  (overhead exceeds the value transfer).
- Functions over inline complex logic; reuse over duplication.

### Pure vs side-effecting — paired example

The contrast below shows the same job done two ways. The pure form
is testable, composable, and side-effect-free; the side-effecting
form mutates a global, depends on caller setup, and silently
couples the function to the rest of the script.

```bash
# scenario: compute the upper-cased basename of a path.
#!/usr/bin/env bash
set -euo pipefail

# ─── PURE form (BCS-recommended) ───
# Inputs:  $1 — a path
# Outputs: stdout — basename, upper-cased
# Side effects: none
upper_basename_pure() {
  local -- path="${1:?usage: upper_basename_pure PATH}"
  local -- base="${path##*/}"
  printf '%s' "${base^^}"                      # output via stdout (BCS0411)
}

# ─── SIDE-EFFECTING form (avoid) ───
# Inputs:  reads $INPUT_PATH global
# Outputs: writes $RESULT global
# Side effects: depends on, and mutates, two unrelated globals
declare -- INPUT_PATH=''
declare -- RESULT=''
upper_basename_dirty() {
  local -- base="${INPUT_PATH##*/}"            # global dependency, hidden coupling
  RESULT="${base^^}"                           # global mutation, hidden coupling
}

# Composition: pure version is trivially testable and pipeline-friendly.
upper_basename_pure '/etc/hosts.allow'         # ⇒ HOSTS.ALLOW
result=$(upper_basename_pure '/etc/hosts.allow')
printf '[%s]\n' "$result"                       # ⇒ [HOSTS.ALLOW]

# Composition: dirty version requires caller to manage globals.
INPUT_PATH='/etc/hosts.allow'
upper_basename_dirty
printf '[%s]\n' "$RESULT"                       # ⇒ [HOSTS.ALLOW]
# but: any other code touching INPUT_PATH/RESULT silently breaks this.

#fin
```

Three observations on the pure form: every input is a parameter
declared `local --`; output is via stdout (small string) which the
caller captures with `$()` only if needed; failure is signalled by
`return` or a non-zero exit status, not by `exit`. The dirty form
violates each of these and is therefore both harder to reason about
and harder to test (BCS0410, BCS0411).

The exception that justifies side-effecting design: when the output
is large (multi-line text, multi-element array), pass an output
nameref (BCS0202, BCS0411) — that gives nameref-mediated mutation
without resorting to globals.

**See also**: §9.1 definition syntax, §9.3 `local` and scope, §9.4
return value via `return N`, §9.5 communicating results, §4.11
namerefs (`-n`), BCS0410 (recursive function state discipline),
BCS0411 (subshell return-value patterns), BCS0401 (function
definition).

#fin
