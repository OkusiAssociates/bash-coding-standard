<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 3.8 Locale-translation `$"..."`

Quoting form that triggers a gettext lookup against the program's message catalogue. Used for internationalised scripts.

- `$"text"` — looks up `text` in the active locale's catalogue.
- `gettext.sh` from GNU gettext for setup.
- `TEXTDOMAIN` and `TEXTDOMAINDIR` variables.
- Extracting messages with `xgettext` from shell sources.
- The `noexpand_translation` shopt (Bash 5.2) — suppresses expansion of `$"..."` for security in some contexts.
- Rare in practice; mentioned for completeness.

#fin
