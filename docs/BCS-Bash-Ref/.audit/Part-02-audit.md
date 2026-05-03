<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part 02 — Bash as a Program — Audit

## Summary
- Leaves audited: 9 (8 chapters + index)
- KEEP / ENRICH / PROMOTE: 1 / 6 / 2
- Code-block coverage: 0 of 9 leaves contain at least one fenced code block
- Strict-mode framing: low (Part covers invocation/genealogy; strict mode rarely interacts beyond startup files)
- Cross-reference density: medium (xrefs to §23.6 macOS, §25 5.3, Appendix M version matrix, §20.14 restricted shell — the Appendix M xref is critical and currently unresolvable)

## Highest-leverage findings (top 5)
1. §2.4 (Invocation modes) and §2.5 (Startup files) are the *most-cited* Bash debugging chapters in practice ("works in terminal, breaks in cron"). Both PROMOTE: §2.4 needs the four-quadrant matrix as a literal table; §2.5 needs a flowchart of which files are sourced when.
2. §2.2 (Version landscape) defers to Appendix M for the full feature matrix. This xref must resolve — the appendix-shard auditor must confirm `M_*` exists. Otherwise inline the matrix here.
3. §2.6 (`BASH_ENV` and `ENV`) is correctly short — but it currently makes a security claim ("Subject to PATH lookup … with security implications under SUID — but SUID scripts are forbidden anyway") that needs either a code demo or a sharper xref to §20.
4. §2.8 (Exit lifecycle) makes a precise claim about subshell EXIT-trap inheritance ("does not run parent's EXIT trap unless `set -E` and parent's trap is inheritable (it isn't, by design)") — this is **technically wrong**. `set -E` controls ERR-trap inheritance; EXIT trap is never inherited by subshells regardless. **[major] technical error to fix during ENRICH.**
5. §2.7 (Bash CLI options) duplicates content with `bash --help`. KEEP-as-table would be acceptable; current form is a flat bullet list — promote to a literal table for cheatsheet usefulness.

## Per-leaf table
| File | Disposition | Coverage | Human | AI/RAG | Xref | Strict | Example | Notes |
|------|-------------|----------|-------|--------|------|--------|---------|-------|
| 01_Genealogy-and-the-shell-family.md | ENRICH | high | high | med | med | n-a | no | Bullet list adequate as orientation; tighten dates |
| 02_Bash-version-landscape.md | ENRICH | high | high | med | med | n-a | no | Defers to Appendix M; add BASH_VERSINFO snippet |
| 03_Build-configuration-and-feature-detection.md | ENRICH | med | high | low | low | low | no | Feature-detection is concrete topic that demands code |
| 04_Invocation-modes.md | PROMOTE | high | high | low | med | low | no | Four-quadrant matrix essential as table; the cron pitfall must be demoed |
| 05_Startup-file-chains.md | PROMOTE | high | high | low | high | low | no | Canonical map; needs visual ordering |
| 06_BASH_ENV-and-ENV.md | ENRICH | med | high | low | low | low | no | Correctly short; needs one demo plus security xref |
| 07_Command-line-options-to-bash-itself.md | ENRICH | high | high | med | low | n-a | no | Convert bullet list to table |
| 08_Exit-and-shell-session-lifecycle.md | ENRICH | med | high | low | low | med | no | **[major] technical error re: set -E and EXIT trap; correct during enrich pass** |
| index.md | KEEP | high | high | high | high | n-a | n-a | Standard index page, complete |

## Cross-reference issues
- §2.2 → Appendix M ("full version-feature matrix"). Verify `99_Appendices/M_*.md` exists and is named correctly. **Flag for appendix-shard auditor.**
- §2.4 → §23 and §20.14 (restricted shell). Both targets exist by Part numbering; verify chapter §20.14 exists when Part 20 is audited.
- §2.8 → no broken xrefs but contains a **technical error** about `set -E` semantics (see findings).

## Self-containment risks
- §2.2 — version-feature claims (e.g. "Bash 4.4: BASH_REMATCH immutability") cannot be verified from this leaf. Either inline a citation or accept that this is preview-of-appendix content.
- §2.5 — the prose claims `/etc/bash.bashrc` is "Debian/Ubuntu" — distro-specific behaviour that varies; RHEL/Fedora differ. Self-containment requires noting the variance, not just listing one distro path.
- §2.6 — Shellshock CVE referenced obliquely in §4.8 not here; for AI retrieval of this leaf alone the SUID-history claim is unmoored.

## Code-gap recommendations
1. §2.3 — `printf '%s\n' "${BASH_VERSINFO[@]}"`, `shopt extglob`, `enable -p | head` for runtime feature detection.
2. §2.4 — `[[ $- == *i* ]] && echo interactive`, `shopt -q login_shell && echo login`.
3. §2.5 — Conceptual diagram is more valuable than code, but a `bash -lic 'echo done'` vs `bash -c 'echo done'` contrast would help.
4. §2.6 — `BASH_ENV=/path/to/env bash script.sh` worked example.
5. §2.8 — `trap 'echo exiting' EXIT; ( echo subshell; exit 1 ); echo $?` to demonstrate the actual EXIT-trap-and-subshell behaviour after the technical fix.

#fin
