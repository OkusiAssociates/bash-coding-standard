<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## Appendix I — Parameter Expansion Cheat Sheet

| Form | Effect |
|------|--------|
| `$var`, `${var}` | Value |
| `${var:-default}` | Default if unset/empty |
| `${var-default}` | Default if unset only |
| `${var:=default}` | Assign default; same usage |
| `${var=default}` | Assign default if unset only |
| `${var:?msg}` | Error if unset/empty |
| `${var?msg}` | Error if unset only |
| `${var:+alt}` | alt if set/non-empty |
| `${var+alt}` | alt if set only |
| `${var:offset}` | Substring from offset |
| `${var:offset:length}` | Substring of length |
| `${#var}` | Length |
| `${var#prefix}` | Remove shortest prefix |
| `${var##prefix}` | Remove longest prefix |
| `${var%suffix}` | Remove shortest suffix |
| `${var%%suffix}` | Remove longest suffix |
| `${var/old/new}` | Replace first |
| `${var//old/new}` | Replace all |
| `${var/#old/new}` | Replace if at start |
| `${var/%old/new}` | Replace if at end |
| `${var^}` | Uppercase first |
| `${var^^}` | Uppercase all |
| `${var,}` | Lowercase first |
| `${var,,}` | Lowercase all |
| `${!var}` | Indirect |
| `${!prefix*}`, `${!prefix@}` | Names matching prefix |
| `${!arr[@]}` | Array indices |
| `${var@Q}` | Quoted form |
| `${var@E}` | Escape-interpreted |
| `${var@P}` | Prompt-expanded |
| `${var@A}` | Assignment form |
| `${var@a}` | Attributes |
| `${var@K}`, `${var@k}` | Assoc-array form (5.2+) |
| `${var@U}`, `${var@u}`, `${var@L}` | Case forms |

#fin
