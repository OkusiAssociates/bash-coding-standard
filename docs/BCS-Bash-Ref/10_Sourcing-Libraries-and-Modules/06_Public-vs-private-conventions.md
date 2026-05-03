<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 10.6 Public vs private conventions

A library that distinguishes its API from its internals can evolve
its internals without breaking callers. Bash provides no actual
visibility control; the convention substitutes for the missing
language feature.

- **Public functions**: bare names (after the namespace prefix —
  `mylib::greet`), documented in the library header.
- **Private functions**: leading underscore — `_mylib_helper` (or
  `mylib::_helper`).
- Documented only the public API; private functions may change
  without notice in any patch release.
- Variables follow the same convention.
- BCS recommends explicit documentation of the public name list in
  the library header (BCS0407) — both as discoverability and as a
  contract.

### Library-header documentation

The header below shows the expected shape: a one-line synopsis, a
list of public names, a `# Internal:` block listing private helpers
(so reviewers can see they exist without granting them API status),
and license/version metadata.

```bash
# scenario: library-header documentation block, BCS-style.
# ── /usr/local/lib/myapp/strings.sh ───────────────────────────
#!/usr/bin/env bash
# strings.sh — string utilities for myapp.
#
# Public API:
#   mylib::upper STRING        Upper-case STRING.
#   mylib::lower STRING        Lower-case STRING.
#   mylib::trim  STRING        Strip leading/trailing whitespace.
#   mylib::join  SEP ELT…      Join elements with SEP.
#   MYLIB_VERSION              Version string (declare -gr).
#
# Internal (do NOT call from outside):
#   _mylib_assert_nonempty STRING
#   _mylib_normalise_locale
#
# License: CC-BY-SA-4.0
# Version: 1.0.0
# Source : git@example.com:myapp/strings.git

[[ -n ${MYLIB_LOADED:-} ]] && return            # §10.4 (BCS0407)
declare -gri MYLIB_LOADED=1
declare -gr  MYLIB_VERSION='1.0.0'

# … public functions follow …
# … private helpers follow …

#fin
```

The header pays for discoverability (a reader sees the API without
`grep`), reviewability (private helpers are called out, not
mistaken for public during code review), and stability (the header
*is* the contract — backward compatibility on listed public names,
but not on `_mylib_*`). For larger libraries, extract the header
into a sibling `README.md` and shrink the in-file header to a
pointer.

**See also**: §10.5 namespace prefixes, §10.4 idempotent sourcing
guards, §10.7 version negotiation (the public version constant is
part of the public API), §10.10 API design, §9.10 naming
conventions, BCS0203 (naming conventions), BCS0407 (library
patterns).

#fin
