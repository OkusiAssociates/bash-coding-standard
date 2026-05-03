<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part X — Sourcing, Libraries, and Modules: Audit

Date: 2026-05-03
Priority: P2 (language proper)
Files audited: 11 chapters + 1 index = 12

## Summary

Part X is **the most code-block-dense Part of the shard** — three chapters (10.3 self-locating, 10.4 idempotent guard, 10.7 version negotiation) already include working code blocks. The chapters that need PROMOTE are 10.1 (`source` semantics — `set -e` propagation and return/exit asymmetry are landmines that need a trace) and 10.8 (lazy/conditional loading — the `declare -g` pitfall is a strict-mode interaction that *must* be demonstrated).

Strict-mode framing is solid in this Part — most chapters acknowledge that sourced files inherit `set -e`, and 10.4's idempotent-guard pattern is correctly explained as `&&`-context-exempt. 2 PROMOTE / 8 ENRICH / 2 KEEP.

## Top-5 findings

1. **[major]** `01_source-semantics.md`: `set -e` propagation and the `return`/`exit` asymmetry inside a sourced file are foundational facts but unanchored to demonstrations. A reference reader needs the trace.
2. **[major]** `08_Lazy-and-conditional-loading.md`: the `declare -g`-required-inside-functions pitfall is a strict-mode landmine that the leaf names but does not exhibit. PROMOTE-priority for this Part.
3. **[minor]** `03_Self-locating-library-pattern.md` shares the canonical idiom with §9.11. Cross-reference is missing; both leaves should explicitly point to each other.
4. **[minor]** `09_Cross-shell-sourcing-pitfalls.md`: the "bash invoked as `sh`" trap is real and unique-to-bash; a one-line `[[ -z ${BASH_VERSION:-} ]]` example is shown but the *trap of bash silently disabling features* needs a concrete listing.
5. **[minor]** `02_The-BASH_SOURCE-array.md` overlaps heavily with §9.11. Decide which chapter owns the array's full anatomy and have the other forward-link.

## Per-leaf table

| File | Coverage | Clarity-H | Clarity-AI | XRefs | Strict | Example | Self-cont | Disp |
|------|----------|-----------|------------|-------|--------|---------|-----------|------|
| index.md | high | high | high | high | n-a | n-a | yes | KEEP |
| 01_source-semantics.md | high | high | low | high | high | no | no | PROMOTE |
| 02_The-BASH_SOURCE-array.md | high | high | med | high | low | no | yes | ENRICH |
| 03_Self-locating-library-pattern.md | high | high | med | med | high | yes | yes | ENRICH |
| 04_Idempotent-sourcing-guards.md | high | high | high | med | high | yes | yes | ENRICH |
| 05_Namespace-prefixes.md | high | high | med | low | n-a | no | yes | ENRICH |
| 06_Public-vs-private-conventions.md | high | high | high | low | n-a | no | yes | ENRICH |
| 07_Version-negotiation.md | high | high | high | low | low | yes | yes | ENRICH |
| 08_Lazy-and-conditional-loading.md | high | high | low | low | high | no | no | PROMOTE |
| 09_Cross-shell-sourcing-pitfalls.md | high | high | med | low | high | no | yes | ENRICH |
| 10_API-design.md | high | high | med | low | low | no | yes | ENRICH |
| 11_Distribution-and-installation.md | high | high | med | med | n-a | no | yes | ENRICH |

## Cross-reference issues

- 02 ↔ 9.11: same `BASH_SOURCE` material owned twice; pick canonical owner and forward-link.
- 03 ↔ 9.11: same self-locating idiom; the library version should be canonical and 9.11 forward-link.
- 11 mentions FHS pattern and "BCS pattern" without anchoring to a BCS rule code (BCS01xx); pin to specific code if it exists, or remove the implicit claim.
- 09 mentions detection idiom; pairs with §11 distribution but no explicit link.

## Self-containment risks

- 01, 08: assertions about `set -e` propagation and `declare -g`-required-inside-functions cannot be verified without code. Both PROMOTE.
- 09: the "sh-mode-of-bash trap" wording is suggestive but unanchored — a list of features bash silently disables when invoked as `sh` would close the gap.
- 11: distribution claims (deb/rpm/symlink-S) are correct but not demonstrated; for a *reference* this is acceptable as long as one canonical install-time anchor exists.

## Code-gap recommendations

Mandatory examples (per disposition column):
- 01: 2 examples — `set -e` propagation trace; `return`/`exit` asymmetry.
- 08: 2 examples — function-scoped global pitfall with and without `declare -g`.
- 02–07, 09–11: 1 example each (most leaves already have at least a fragment).

Total target: ~13 new code blocks across the Part. 3 chapters already include working examples that should be retained and possibly extended.

#fin
