<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 23.11 Forward-compatibility hygiene

Writing bash that won't break in future versions.

- Test with `BASH_COMPAT=` unset (modern semantics).
- Avoid relying on undocumented behaviour.
- Watch the bash release notes (NEWS file).
- Keep up with deprecations: backticks, `$[…]`, `expr`.
- Don't depend on `lastpipe` being on/off — set it explicitly.

#fin
