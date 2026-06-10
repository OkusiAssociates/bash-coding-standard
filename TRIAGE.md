# BCS Critical-Analysis Triage

**Date:** 2026-06-10
**Method:** 9-dimension parallel audit (83 agents) → adversarial per-finding verification (default-refute) → completeness critic.
**Tree audited:** working tree of `/ai/scripts/Okusi/BCS` at `b02c710` + 1 uncommitted edit to `bcs` (opus alias bump).
**Raw result:** 73 findings → 70 confirmed / 3 refuted → 1 critical / 18 major / 51 minor. Collapsed here to **36 distinct issues** (several auditors caught the same root cause; e.g. the `bcs:730` glob was reported by 6 dimensions).
**Machine-readable source:** `/tmp/bcs-analysis.json`.

## Progress

**2026-06-10 — batch 1 FIXED & verified** (17/17 suites green, `shellcheck -x --severity=warning` clean, working tree not dirtied):
`T-01` (default checker text extraction + empty guard), `T-02` (opus → `claude-opus-4-8` synced across code/docs/tests; `sonnet-4-7` thinking gate restored; CI re-greened), `T-03` (API keys out of `curl` argv on all three API backends), `T-04` (`$PWD` trap-injection closed), `T-09` (test counter now partitions: run = passed + failed), `T-11` (generate suite no longer overwrites the tracked standard; drift test made real again). Added 4 `_extract_anthropic_text` unit tests. **Uncommitted** — awaiting commit instruction.

**2026-06-10 — batch 2 FIXED & verified** (17/17 suites green, shellcheck clean):
`T-31` (empty LLM result on any backend → exit 5 + valid JSON envelope, never a false "clean" pass), `T-24` (process-wide EXIT/INT/TERM temp-cleanup net — temps reclaimed even on die/errexit/SIGINT, not just RETURN; verified register→cleanup removes both file and dir), `T-12` (test-helpers forces a hermetic `BCS_CONF_DIR` so a real `/etc/bcs.conf` or `~/.config/bcs/bcs.conf` can no longer leak into any suite), `T-10` (README + CLAUDE.md corrected: the self-compliance test is *structural*, not an LLM `bcs check bcs` run). **Uncommitted.**

**2026-06-10 — batch 1+2 COMMITTED** as `a6bde07` (engine/security: T-01,02,03,04,24,31) and `81943c0` (test harness: T-09,11,12) — plus T-10 docs. Not pushed.

**2026-06-10 — batch 3 FIXED & verified** (17/17 suites green, shellcheck clean; uncommitted):
`T-25` (operands after `--` now honour the one-file rule instead of silently taking the first/overwriting), `T-26` (single effort-validation point covers `BCS_EFFORT` from env/conf + the `min` alias, not just the `-e` flag), `T-27` (policy/tier loaders: trailing-newline-less final directive honoured; policy codes must be exactly 4 digits so typo'd codes warn instead of silent no-op; section-source tiers validated against the legal set), `T-23` (failure/`-D` diagnostics now print even under `-q`). Added 6 regression tests (3 in check, 3 in load-policy).

**2026-06-10 — batch 4 (standard content) FIXED & verified** (17/17 green; standard regenerated; counts unchanged 112/34/43/23):
`T-13` (`read -ar fields` populated `r` not `fields` — fixed all 3 IFS examples to `read -ra`; was silently broken), `T-14` (unterminated quote `/$server".out` → `/"$server".out`), `T-15` (invalid block-suppression example → valid `case` block), `T-16` (version-guard example reordered so the guard precedes `shopt -s inherit_errexit`, matching the rule's own Important note), `T-20` ("Five" → "Seven essential security areas" + the two missing), `T-21` (`case $?` after a bare command is unreachable under `set -e` → capture with `\|\| rc=$?`), `T-22` (all 4 dead benchmark links fixed: hyphen→underscore, `date-printf-reference`→`date_reference`).
**`T-18` SKIPPED — false positive**: `((fnd==1)) && [[…]] && fnd=0` was empirically verified to SURVIVE `set -e` (the `((…))` is exempt as a non-final command in a `&&` list), so the "missing `||:`/BCS0606" claim is wrong; will not alter working code.
**`T-17` DEFERRED** — section 13 documents a large removed surface (tier keywords `fast/balanced/thorough`, `_detect_backend()`, `*_MODELS` arrays, `BCS_MODEL` default `balanced`). Doc-only (no codes) but a substantial accurate rewrite — better as its own focused commit.
**`T-19` DEFERRED** — `#fin` vs `#end`: BCS0109 permits both, BCS0403/BCS1206 imply `#fin` only. Resolving it is a normative decision (does `#end` stay?) for the standard's maintainer.

**2026-06-10 — T-06 FIXED & verified** (committed `c53fa1c`): `cmd_generate` no longer rewrites relative `](../…)` links to the producer's absolute checkout path — that baked a dev path into the shipped, version-controlled standard (dead links elsewhere, non-reproducible, path leak in a public repo). Links stay relative to `data/` and resolve in place; regenerated, all 8 verified.

**Commits this session (not pushed):** `a6bde07` engine/security · `81943c0` test harness · `dcd6732` CLI · `536f559` standard content · `c53fa1c` generate links. **22 issues fixed; T-18 skipped (verified false positive); T-17, T-19 deferred.**

**2026-06-10 — template/CLI cluster FIXED & verified** (committed `bacaa78`; 17/17 green; +5 regression tests):
`T-07` (template substitution + library identifier: `my.tool`→`my_tool`; basic/complete templates now genuinely shellcheck-clean via inline disables, test no longer masks SC2034/SC2155), `T-28` (patsub_replacement disabled so `&`/backslash in values insert literally), `T-29` (`codes`/`_load_tiers` no longer `cat` an empty array → no stdin hang; codes dies 3 on no section files), `T-30` (`display -S` refuses to clobber a regular file; pager early-quit no longer exits 141; replay hint emits `--strict`/`--no-strict` not invalid `--strict off`).

**Commits this session (not pushed):** `a6bde07` · `81943c0` · `dcd6732` · `536f559` · `c53fa1c` · `bacaa78`. **26 issues fixed; T-18 skipped; T-05/T-17/T-19 deferred.**

**2026-06-10 — packaging/docs sweep FIXED & verified** (committed `3fac90f` docs, `444129e` scorer/tests; 17/17 green):
`T-08` (pre-commit `args` can't carry bcs flags through the per-file wrapper → document `BCS_MODEL` in bcs.conf), `T-32` (manpage now documents `codes -J/--json`, `check --shellcheck/--no-shellcheck`, `BCS_SHELLCHECK`), `T-33` (Makefile no longer ships a dev's gitignored `98-user.md`; clone-URL repo name aligned; `make check` doc corrected; T-33a/b judged non-defects — dead-but-harmless `examples` install / graceful md2ansi fallback), `T-34` (scorer: mislabeled-fixture exclusion, `stability=n/a` not 1.000 on empty, loud warning + non-zero exit on no conclusive runs under REQUIRE_BACKEND), `T-35` (stale line counts/URLs/"Twenty"→24/auto-detect claim), `T-36` (bcscheck shim now tested; `codes -T` 34/43/23 asserted). Scorer verified by shellcheck + review, not a live scoring run (no backend here).

**Open URL question for the user:** docs say org `Open-Technology-Foundation/bash-coding-standard`, but the actual git remote is `OkusiAssociates/bash-coding-standard` — confirm which org hosts the public clone URL.

**Commits this session (8, not pushed):** `a6bde07` `81943c0` `dcd6732` `536f559` `c53fa1c` `bacaa78` `3fac90f` `444129e`. **32 issues fixed; T-18 skipped; T-05 (live API), T-17, T-19 deferred.**

**2026-06-10 — T-17 + T-19 + org-URL RESOLVED** (committed `c563ed3`; 17/17 green; counts unchanged 112/34/43/23):
**Org-URL:** `Open-Technology-Foundation/bash-coding-standard` and the working remote `OkusiAssociates/bash-coding-standard` are a mirror pair (identical `main` SHA); the dead URL was `Open-Technology-Foundation/BCS.git` (Makefile, fixed in the sweep). Docs now uniformly use the OTF URL, which resolves publicly; also fixed a stray `Okusi/BCS.git` in `docs/BCS-ADVANCED-BASH-REFERENCE.md`.
**T-17:** section 13 rewritten to the real config surface — `BCS_MODEL` default `sonnet`, name-based backend routing (legacy tier keywords exit 22), `MODEL_ALIASES` replaces the four `BCS_*_MODEL` overrides and `*_MODELS` arrays, keys documented as header-via-`--config` (never argv/query), `BCS_CONF_DIR` documented.
**T-19:** BCS0109 now mandates `#fin` (the form BCS0403/BCS1206/templates/tests already required); `#end` noted as deprecated. Nothing in the tree used `#end`.

**Commits this session (9, not pushed):** `a6bde07` `81943c0` `dcd6732` `536f559` `c53fa1c` `bacaa78` `3fac90f` `444129e` `c563ed3`. **All triage items now closed except:** T-18 (skipped — verified false positive) and T-05 (needs one live opus-4-8 API call).

**2026-06-10 — `bcs check bcs` deep check RUN & resolved** (committed `6002bfa`; 637s, sonnet/high via Claude CLI; 17/17 green after fixes):
Raw result: exit 1 — 3 core ERRORs, 2 WARNs. Adjudicated: **BCS0603** (cleanup trap re-entry guard) FIXED; **BCS0202/BCS0204** (function exports → `local -x`; bonus: external `BCS_RESPONSE_DUMP` now honoured, making §13's redirect claim true) FIXED; **BCS0406** (strict mode before source fence) SUPPRESSED with inline directives + comment — the suggested restructure is invalid (`shopt -s extglob` must precede parse of `@(...)` function bodies; moving it breaks `source ./bcs`), and the only sourcing consumers are test suites running identical strict mode; **BCS0108** (readonly VERBOSE) REJECTED as wrong — every subcommand parser reassigns VERBOSE for `-v/-q`; applying it would break the CLI. Verification-debt item closed; T-05 (live opus-4-8 probe) remains the sole open item.

Remaining items below are unchanged.

## Verification legend

| Tag | Meaning |
|-----|---------|
| `SELF` | Re-confirmed by hand in this session (ran command / read the exact line). |
| `WF` | Confirmed by the workflow's adversarial verifier; not independently re-run here. |
| `LIVE?` | Depends on an external LLM-API contract; **not** exercised offline — needs one live round-trip to settle. |

---

## P0 — Blocks the core value proposition

### T-01 · Default `bcs check` returns empty and exits 0 `SELF`
- **Where:** `bcs:766` — `jq -r '.content[0].text // empty'`
- **Root cause:** The default invocation (`sonnet`, effort `medium`) enables extended thinking (budget 2000, matches the `*sonnet-4-6*` gate at `bcs:730`). With thinking enabled the Anthropic API returns a **thinking block at `content[0]`**; the text block is later. `.content[0].text` is therefore null → the backend prints empty → `cmd_check` sees zero findings → reports the script **CLEAN** and exits **0**.
- **Impact:** The flagship checker silently passes everything on its own default path. Catastrophic for a compliance tool.
- **Fix:** `jq -r '[.content[] | select(.type=="text") | .text] | join("")'`. Add a guard: empty model text on a 2xx response must be an error (exit 5), never "clean".
- **Note:** Logic confirmed by reading; the content-block ordering is standard Anthropic behavior. Recommend one live `bcs check` to nail `LIVE?` shut after the fix.
- **Effort:** S (1 line + 1 guard). **Add a test:** assert non-empty extraction from a recorded thinking-on fixture response.

---

## P1 — Major: ship-blocking, security, or actively red

### T-02 · Uncommitted opus edit: 3 contradictory IDs, duplicated glob, red CI `SELF`
- **Where:** `bcs:42` (`[opus]=claude-opus-4-8`), comments `bcs:658` & `bcs:1249` (`claude-opus-4-6` — an ID that never existed), `bcs:730` glob, plus stale `README.md:186`, `bcs.1:123`, `bcs.bash_completion:13` (all `claude-opus-4-7`).
- **Symptoms:**
  1. **Duplicated glob branch** `@(*opus*|*sonnet-4-6*|*sonnet-4-6*)` — the `*sonnet-4-7*` alternative was overwritten with a duplicate. Anyone selecting `claude-sonnet-4-7` (recommended by `bcs.conf.sample:54`) **silently loses the thinking budget**, no warning.
  2. **Two red suites** (confirmed live): `test-resolver` asserts `opus → claude-opus-4-7`; `check` asserts the `BCS_MODEL` fallback. CI gate is currently failing.
  3. Three different canonical opus IDs coexist in one tree.
- **Fix:** Decide the canonical opus ID once. Restore *or* deliberately remove the `*sonnet-4-7*` branch (don't leave a duplicate). Sync `README.md`, `bcs.1`, `bcs.bash_completion`, the two comments, and `test-resolver`/`check` expectations in **one** commit. Re-green the suite.
- **Effort:** S–M. **Highest-ROI fix after T-01** — it's uncommitted and it's why CI is red.

### T-03 · API key passed in `curl` argv `SELF` `security`
- **Where:** `bcs:753` — `-H 'x-api-key: '"$ANTHROPIC_API_KEY"` (Anthropic; check OpenAI/Google backends for the same shape).
- **Impact:** Key is visible to any local user via `ps` / `/proc/PID/cmdline`. Directly violates the project's documented API-key discipline ("never passed on the CLI where it appears in `ps`").
- **Fix:** Feed headers via `--config <fd>` or `-H @file` from a `0600` temp / process-substitution FD so the secret never enters argv.
- **Effort:** S per backend.

### T-04 · Command injection via `$PWD` in RETURN trap `SELF` `security`
- **Where:** `bcs:1055` — `trap "cd '$PWD' 2>/dev/null; rm -rf '$check_dir'" RETURN` (claude-code backend).
- **Impact:** `$PWD` is interpolated into a single-quoted trap string at definition time. Running `bcs check` from a directory whose path contains a single quote + shell metacharacters breaks out and executes arbitrary code. Vector: clone/cd into an attacker-named path.
- **Fix:** Don't interpolate `$PWD` into trap text. Capture into a local and reference by name: `local -- _ret_dir=$PWD; trap 'cd "$_ret_dir" 2>/dev/null; rm -rf "$check_dir"' RETURN` — but note T-24 (RETURN traps don't fire on errexit/die/SIGINT), so prefer an EXIT trap with a tracked global.
- **Effort:** S.

### T-05 · `bcs check -m opus` may HTTP-400 above `-e low` `WF` `LIVE?`
- **Where:** `bcs:730` gate sends `thinking.budget_tokens` to whatever `*opus*` resolves to (now `claude-opus-4-8`).
- **Claim:** If `claude-opus-4-8` dropped the legacy `budget_tokens` field, every effort above `low` 400s.
- **Action:** Verify against the live opus-4-8 API. If true, tighten the gate to versions that accept the field, or migrate to the current thinking-parameter shape.
- **Effort:** S once the contract is confirmed.

### T-06 · `bcs generate` bakes the absolute checkout path into the output `WF`
- **Where:** `bcs:1757` → `data/BASH-CODING-STANDARD.md`.
- **Impact:** Non-reproducible committed artifact, dead links, and dev-machine path leakage on every install.
- **Fix:** Emit repo-relative paths (or omit the path entirely) in the generated header/footer.
- **Effort:** S.

### T-07 · `template` emits non-compliant / unsourceable output `SELF`
- **Where:** `bcs:1171`; `examples/templates/basic.sh.template:10`, `complete.sh.template`.
- **Symptoms:** (a) `-t library` with a name that isn't a valid bash identifier (`my.tool`, `my-tool`) produces a broken function name → unsourceable. (b) Generated `basic`/`complete` templates fail `shellcheck -x` at warning severity out of the box (SC2034) — contradicts "BCS-compliant templates" and violates core rule BCS1206.
- **Fix:** Sanitize/validate the name into a legal identifier (reject or transform). Fix the SC2034 in the template sources (reference the unused var, or add a scoped directive).
- **Effort:** S–M.

### T-08 · `.pre-commit-hooks.yaml` `args` override is dead `WF`
- **Where:** `.pre-commit-hooks.yaml:19`.
- **Impact:** The documented `args:` override never reaches `bcs` — the `bash -c '... for f; do ...'` file-loop consumes them. Users can't change model/tier/strictness via pre-commit config.
- **Fix:** Thread `"$@"`-passed args ahead of the file list, or document the real override mechanism.
- **Effort:** S.

### T-09 · Test counters report `passed > run` `SELF`
- **Where:** `tests/test-helpers.sh:29`.
- **Impact:** Live output shows "24 run, 25 passed", "16 run, 23 passed", "10 run, 21 passed". Pass totals are not trustworthy → a real regression can hide behind an inflated count.
- **Fix:** Audit the increment sites; ensure every asserted check bumps `TESTS_RUN` exactly once. Add a self-test asserting `passed + failed == run`.
- **Effort:** S.

### T-10 · Self-compliance test is grep-theatre `WF`
- **Where:** `tests/test-self-compliance.sh:113`.
- **Impact:** It greps for structural markers and a line-count envelope; it **never runs `bcs check bcs`**, despite README and CLAUDE.md claiming the self-compliance invariant is enforced. Expectation mismatch.
- **Fix:** Either run a cheap-backend `bcs check bcs` behind a backend-available guard, or correct the docs to say "structural self-check only."
- **Effort:** S (doc) / M (real check).

### T-11 · Generate suite rewrites the tracked standard `WF`
- **Where:** `tests/test-subcommand-generate.sh:57`.
- **Impact:** The suite regenerates and overwrites the committed `data/BASH-CODING-STANDARD.md`, neutralizing the very drift-detection it claims to perform and dirtying the tree.
- **Fix:** Generate into a temp dir and diff against the tracked file; never write the tracked path.
- **Effort:** S.

### T-12 · Suites are non-hermetic / mask failures `SELF`
- **Where:** `tests/test-subcommand-codes.sh:13` (and most suites); `tests/test-check-fixtures.sh:100`; `tests/test-resolver.sh:39`.
- **Symptoms:** (a) A real `/etc/bcs.conf` or `~/.config/bcs/bcs.conf` is sourced by every subprocess `bcs` call — 4 false failures demonstrated. (b) The fixture gate counts **inconclusive** runs as passed, and `BCS_FIXTURES_REQUIRE_BACKEND` only guards the probe — a present-but-broken backend yields a green gate with zero conclusive checks. (c) Several suites run under `set -e` with no `|| true`, aborting on the first failing assertion and losing the summary.
- **Fix:** Force `BCS_CONF_DIR` to a throwaway dir in every suite (the hermetic switch already exists). Treat inconclusive as a distinct non-pass state. Wrap assertion runs so the suite collects all failures.
- **Effort:** M.

---

## P2 — The standard contradicts itself (self-violations)

Each is a "correct" example in the standard that violates the standard or is invalid bash. These erode trust in the document the tool exists to enforce.

| ID | Where | Defect |
|----|-------|--------|
| T-13 | `data/10-security.md:53` (BCS1003) | `read -ar fields` populates array `r`, never `fields`. `WF` |
| T-14 | `data/11-concurrency.md:67` (BCS1102) | "Correct" parallel example has an **unterminated quote** — syntax error. `WF` |
| T-15 | `data/12-style-development.md:130` (BCS1206) | Block-suppression "correct" example is **invalid bash syntax**. `WF` |
| T-16 | `data/04-functions.md:271` (BCS0409) | Self-contradiction (and vs BCS0101) on version-guard ordering. `WF` |
| T-17 | `data/13-environment.md:30` | Section 13 documents a **removed** config surface (tier keywords, `_detect_backend()`, `BCS_*_MODEL`, `*_MODELS` arrays). `WF` |
| T-18 | `data/12-style-development.md:37` (BCS1202) | "Correct" comment example violates core BCS0606 (missing `||:`) and BCS0501's `((var == 1))` anti-pattern. `WF` |
| T-19 | `data/12-style-development.md:145` | End-marker contradiction: BCS0109 permits `#fin` **or** `#end`; BCS1206/BCS0403 mandate `#fin` only. `WF` |
| T-20 | `data/10-security.md:6` (BCS1000) | Overview says "Five essential security areas"; Section 10 defines **seven** rules. `WF` |
| T-21 | `data/11-concurrency.md:118` (BCS1104/BCS0604) | "Correct" `$?`-inspection patterns are unreachable under the standard's mandatory `set -e`. `WF` |
| T-22 | `data/05-control-flow.md:143` | All four benchmark "See also" links point at nonexistent filenames. `WF` |

**Fix approach:** batch-edit the section sources, then `./bcs generate` once, then re-sync counts (T-20 changes the Section-10 overview claim). Add a CI lint that shellchecks every fenced bash example marked "correct."

---

## P2 — Engine / CLI real-but-bounded bugs

| ID | Where | Defect | Fix |
|----|-------|--------|-----|
| T-23 | `bcs:1541` | Quiet mode (`-q`) suppresses the failure-path diagnostics **including** the promised `Raw response:` dump announcement — `info()` is VERBOSE-gated; line 1541 is dead in every path. `SELF` | Use `warn`/non-gated `>&2 _msg` for failure diagnostics. |
| T-24 | `bcs:1737`, `bcs:1055` | RETURN traps never fire on `die`/errexit/SIGINT → temp file + temp dir leak, despite a comment claiming interrupt cleanup. `WF` | Move cleanup to an EXIT trap keyed on a tracked global. |
| T-25 | `bcs:1221` | After `--`, `cmd_check` overwrites an already-set script file and silently drops extra operands, bypassing the one-file guard. `WF` | Apply the same multi-operand rejection after `--`. |
| T-26 | `bcs:1191` | `BCS_EFFORT` from env/conf bypasses validation and the documented `min` alias. `WF` | Route env effort through the same validator as `-e`. |
| T-27 | `bcs:523`, `:529`, `:495` | Policy/tier parser: drops the final directive when the file lacks a trailing newline; accepts wrong-digit codes (`BCS302`, `BCS01010`) silently; `_load_tiers` accepts arbitrary tier words (`banana`) that then can never be filtered. `WF` | `while read … || [[ -n $line ]]`; tighten the code regex to exactly 4 digits; validate tier against the known set and warn. |
| T-28 | `bcs:1171` | Template placeholder substitution corrupts output when name/description/version contains `&` or backslash (bash 5.2 `patsub_replacement`). `WF` | Escape replacement metacharacters, or use a literal-replacement method. |
| T-29 | `bcs:1636` | `bcs codes` hangs reading stdin (and `_load_tiers` consumes stdin) when the resolved data dir has no section files. `WF` | `</dev/null` on the read, or fail fast with exit 3 when no sections found. |
| T-30 | `bcs:1082`, `:1107`, `:1306` | `display -S` silently destroys an existing regular `BASH-CODING-STANDARD.md` in cwd; default display exits 141 (SIGPIPE) when the pager is quit early; the replay-command hint prints invalid syntax `--strict 'off'`. `WF` | Refuse to overwrite without `-f`; swallow 141 on pager quit; emit `--no-strict` (or omit) in the hint. |
| T-31 | `bcs:1494` | JSON mode + claude-code backend + empty LLM output → no JSON envelope emitted, exits 0. `WF` | Same empty-output guard as T-01; always emit a valid envelope or error. |

---

## P3 — Docs / packaging drift

| ID | Where | Defect |
|----|-------|--------|
| T-32 | `bcs.1:222`, `:236` | Manpage omits `bcs codes -J/--json` and `bcs check --shellcheck/--no-shellcheck` (and their env vars), all shipped. `WF` |
| T-33 | `Makefile:48`, `:35`, `README.md:315` | `examples` rule installs nothing; installed `bcs display` can never find the shipped `md2ansi`; `make check` ≠ `shellcheck` despite README; `98-user.d` drop-ins never installed. `WF` |
| T-34 | `.github/workflows/accuracy.yml:34`, `tests/accuracy/bcs-accuracy-score.sh:271`, `:203` | accuracy.yml "fail loudly" bypassed when a model is pinned; scorer exits 0 with all-zero metrics + `stability=1.000` when every run is inconclusive; scorer reclassifies any pragma-less fixture as "clean" (flips real detections TP→FP). `WF` |
| T-35 | `README.md:186/273`, `bcs.1:123`, `bcs.bash_completion:13`, `tests/fixtures/README.md:119`, `Makefile:123`, `bcs.conf.sample:89` | Stale: opus ID, example line counts, "Twenty fixtures" (corpus is 24), clone-URL mismatch (README vs Makefile), "auto-detect tries each key in order" (no such probe exists). `WF` |
| T-36 | `tests/test-shims.sh:11` | Zero coverage: `bcscheck` shim, `codes -T` tier filter + the 34/43/23 counts, `--strict`, inline `#bcscheck disable=`. `WF` |

---

## Refuted (did not survive verification)

1. **BCS1002 "puts `~/.local/bin` in PATH while forbidding home dirs"** — the rule's wording doesn't actually forbid it.
2. **BCS0411 temp-file trap double-quoting "violates BCS0603"** — context makes it compliant.
3. **"Data egress to LLM APIs never disclosed"** — disclosure exists; *but* the completeness critic rates it thin (users may not see it where it matters). Soft follow-up, not a confirmed defect.

## Coverage gaps (unexamined risk — from the completeness critic)

1. **Default text-mode exit contract** of `bcs check` — what CI/pre-commit actually consume — is untested.
2. **No backend checks `stop_reason`/`finish_reason`** → silent output-token truncation passes as a clean result.
3. **Published accuracy numbers were never re-validated** against current code.
4. **Installed-system round trip / FHS resolution** never actually executed (does an installed copy find its `data/`?).
5. **Concurrent `bcs check` runs share one fixed dump file** → diagnostics clobber each other.

---

## Suggested execution order

1. **T-01** — restores the product. (S)
2. **T-02** — uncommitted, re-greens CI, one commit. (S–M)
3. **T-03, T-04** — security; small, high-value. (S)
4. **T-09 → T-12** — fix the test harness first, so every subsequent fix is actually verifiable. (M)
5. **T-31, T-24 → T-30, T-05** — engine correctness. (M)
6. **T-13 → T-22** — batch standard-content fixes + `./bcs generate` + count re-sync. (M)
7. **T-06, T-07, T-08, T-32 → T-36** — packaging/docs sweep. (M)

Severity here reflects the adversarial verifier's recalibration, not the auditors' first pass (`SELF` items I re-confirmed by hand this session; `WF` items rest on the verifier's evidence; `LIVE?` needs one paid round-trip). Full per-finding reasoning is in `/tmp/bcs-analysis.json`.

#fin
