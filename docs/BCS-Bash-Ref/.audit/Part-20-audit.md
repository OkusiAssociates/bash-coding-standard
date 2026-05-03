<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XX — Security — Audit

Date: 2026-05-03
Priority: **P1 (foundational, must-have)**
Files audited: 15 (14 chapters + index)

## Summary

Part XX is the most consequential chapter in this shard. Bash scripts run
with the privileges of their invoker — frequently root — and the security
chapters are exactly where readers will arrive after a CVE, an audit
finding, or a near-miss. The skeleton form is *unacceptable* here: bullets
that say "validate input" without showing a validator, "use `flock`" without
showing the subshell pattern, "drop privileges" without naming `setpriv`'s
correct invocation, are worse than no chapter — they imply the reader
already knows the answer.

The audit briefing instructs: "Lean toward PROMOTE for every leaf with
actionable security guidance." This audit applies that discipline rigorously.

Disposition tally: KEEP 2 / ENRICH 4 / PROMOTE 9. Aggressive PROMOTE rate
reflects the P1 priority and the cost of a misled reader.

## Top-5 findings (Part XX is weighted: top-7 listed)

1. **[critical] §20.5 Command-injection-vectors lists vectors but provides
   zero vulnerable/fixed pairs.** This is *the* central chapter of Part XX.
   It must show: `eval` injection example, unquoted-expansion injection,
   `find -exec sh -c` injection, and the canonical "validate then pass as
   positional" fix. PROMOTE; target ~200 lines, 3+ examples.
2. **[critical] §20.4 `eval`-avoidance acknowledges nameref/assoc-array
   alternatives but does not show them.** The canonical refactor of
   `eval "var_$key=$value"` into `declare -n ref="var_$key"; ref=$value`
   (or `declare -A registry; registry[$key]=$value`) must appear. PROMOTE.
3. **[critical] §20.13 Symlink-races claims `mktemp -d` is the safe path
   without showing the canonical wrapper (mktemp + trap cleanup + path
   validation).** Readers will use predictable `/tmp/foo.$$` patterns
   forever if this chapter doesn't make the safe pattern copy-pasteable.
   PROMOTE.
4. **[major] §20.9 Secrets-handling mentions `set +x` discipline around
   secret use but does not show the scoped-disable pattern**
   (`{ set +x; cmd "$SECRET"; } 2>/dev/null` or `set +x; cmd; set -x`
   guarded by saved options). Process-arg-leak (`ps eww`) demonstration
   also missing. PROMOTE.
5. **[major] §20.6 Input-validation chapter promises an allow-list but
   provides no validator-function template.** Should include a parameterised
   `validate_kind() { case $1 in id) [[ $2 =~ ^[0-9]+$ ]] ;; ... esac; }`
   or equivalent, plus rejection examples for `..`, leading `-`, and NUL.
   PROMOTE.
6. **[major] §20.11 Privilege-drop names `setpriv` without showing the
   capability-drop incantation** (`setpriv --reuid=1000 --regid=1000
   --clear-groups --no-new-privs cmd`) — the single most useful three-line
   pattern in this chapter. PROMOTE.
7. **[major] §20.8 SUID-restrictions correctly notes Linux ignores SUID on
   scripts but does not show the C-wrapper template** that is the
   *recommended alternative*. Without the template the chapter is a
   prohibition without a path. PROMOTE.

## Per-leaf table

| File | Disposition | Notes |
|------|-------------|-------|
| index.md | KEEP | Complete chapter index with orientation |
| 01_Threat-model.md | PROMOTE | Each class needs one concrete vector |
| 02_PATH-hardening.md | ENRICH | Example present; add sudo-i / IFS interaction note |
| 03_IFS-reset.md | ENRICH | Add IFS-injection demo and save/restore template |
| 04_eval-avoidance.md | PROMOTE | Vulnerable/fixed pair with nameref replacement required |
| 05_Command-injection-vectors.md | PROMOTE | Central P1 chapter; needs vulnerable/fixed pairs |
| 06_Input-validation.md | PROMOTE | Validator-function template required |
| 07_Quoting-under-set-u.md | ENRICH | Add set-u trap demo for arr[@]:- and ${1:-} |
| 08_SUID-restrictions.md | PROMOTE | Sudoers NOPASSWD + C-wrapper template required |
| 09_Secrets-handling.md | PROMOTE | Scoped set +x and process-arg-leak examples |
| 10_noclobber.md | ENRICH | Add canonical PID-bearing exclusive-create lockfile |
| 11_Privilege-drop.md | PROMOTE | setpriv capability-drop and EUID re-acquire example |
| 12_Sanitising-filenames.md | PROMOTE | Full sanitiser function and realpath -- example |
| 13_Symlink-races.md | PROMOTE | mktemp -d + trap cleanup canonical wrapper |
| 14_Restricted-shell-mode.md | ENRICH | Worked rbash escape demo to reinforce non-boundary status |

## Cross-reference issues

- §20.2 PATH-hardening should xref BCS standard's PATH discipline rule —
  not present. RAG users will not surface the rule.
- §20.7 `set -u` quoting should xref §13/14 (Error handling, I/O) and §15
  (Command-line) where the same patterns recur — none present.
- §20.10 noclobber chapter and §16.10 locking primitives are both about
  exclusive-create lockfiles; **add reciprocal xrefs**.
- §20.13 symlink-races and §16.9 race-conditions overlap — **add reciprocal
  xrefs**; otherwise readers may miss either.
- §20.9 secrets-handling references HashiCorp Vault and AWS Secrets Manager
  but provides no minimal usage guidance. If kept, mark as external; if
  PROMOTE, drop to "see vendor docs" rather than implying tutorial.

## Self-containment risks

- "BCS pattern" referenced in §20.7 ("declare every variable") without
  citing the rule code. RAG retrieval will surface no related guidance.
- §20.3 "Inherited IFS could split words unexpectedly" — the canonical
  demonstration (`IFS=:; for x in $(echo a:b); do echo "$x"; done`) is
  not shown; reader has no way to internalise the threat from bullets.
- §20.11 names `setpriv` and `runuser` without indicating availability
  (`setpriv` requires util-linux 2.32+; `runuser` is systemd-shipped on
  most distros but not all). PROMOTE expansion must qualify availability.
- §20.13 mentions `O_NOFOLLOW` as "not directly accessible from bash" —
  true, but should mention `python3 -c 'import os; os.open(...)'` helper
  pattern, or reference §17.8 external-IPC tools' philosophy of escape-
  hatching to a real language.
- Cross-cutting: virtually every chapter implies a relationship with
  §15/§13 error-handling without making it explicit. The PROMOTE
  expansions should either inline the relevant rule code or add
  back-links.

## Code-gap recommendations

PROMOTE chapters require these concrete, copy-pasteable blocks. **Cannot
ship as skeleton.**

| Chapter | Required example(s) |
|---------|---------------------|
| §20.1 | One-line concrete vector per threat class (7 classes, 7 inline lines) |
| §20.4 | Vulnerable: `eval "var_$key=$value"`. Fixed: `declare -n ref="var_$key"; ref=$value` (and assoc-array variant) |
| §20.5 | Three vulnerable/fixed pairs: unquoted expansion; `find -exec sh -c "$IN"`; `eval "$IN"`. Plus the allow-list-then-positional pattern |
| §20.6 | `validate_kind()` template covering `id`, `filename`, `length`, with explicit failure handling |
| §20.8 | Sudoers `Cmnd_Alias` + `NOPASSWD` snippet **and** the C-wrapper exec template (with `clearenv`) |
| §20.9 | `{ set +x; secret_op; } 2>/dev/null`; `printf '%s' "$SECRET" \| cmd --stdin-secret` (vs `cmd --secret="$SECRET"`); `ps eww` leak demo |
| §20.11 | `setpriv --reuid=$(id -u nobody) --regid=$(id -g nobody) --clear-groups --no-new-privs cmd`; `sudo -u nobody --` for the simpler case |
| §20.12 | `sanitise_name()` function: strip control chars, reject `..` and leading `-`, length cap, returns 22 on reject |
| §20.13 | `td=$(mktemp -d); trap 'rm -rf -- "$td"' EXIT; cd -- "$td"` canonical wrapper |

ENRICH chapters need one inline block each:

| Chapter | Required example |
|---------|------------------|
| §20.2 | Demo of inherited PATH from `sudo -i` vs `sudo -E` and the override pattern |
| §20.3 | `saved_IFS=$IFS; IFS=$'\n'; …; IFS=$saved_IFS` template + IFS-injection demo |
| §20.7 | One full `"${var:-}"`/`"${arr[@]:-}"` argv-parser snippet |
| §20.10 | `set -C; (echo "$$" > "$LOCK") || die "locked by $(<"$LOCK")"; trap 'rm -f -- "$LOCK"' EXIT` |
| §20.14 | rbash invocation + simple escape via `bash -c` to show the boundary leak |

Total estimated code-block delta for Part XX: ~25 blocks across 13 files.
**Highest expansion priority of any Part in this shard.**

#fin
