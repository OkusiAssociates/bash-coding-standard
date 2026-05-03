<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.4 String operators

String comparison and inspection inside `[[ ]]`.

- `-z str` — empty (zero length).
- `-n str` — non-empty.
- `str1 = str2` — equal (POSIX form, accepted but not idiomatic).
- `str1 == str2` — equal (bash form; RHS is a glob unless quoted, §8.5).
- `str1 != str2` — not equal (RHS also a glob unless quoted).
- `str1 < str2` — lexicographically less (locale-dependent).
- `str1 > str2` — lexicographically greater.
- The `<` and `>` operators must be inside `[[ ]]`, where they are
  comparators; in ordinary commands they are redirections.
- `[[ -v var ]]` — true if `var` is set (declared and assigned).
- `[[ -v arr[i] ]]` — true if element `i` of `arr` is set.
- `[[ -R name ]]` — true if `name` is a nameref (§4.11).

### `-v` on an array element

`[[ -v arr[i] ]]` is the only reliable way to distinguish an
*unset* element from one that exists with an empty value. This
matters under `set -u`, where reading an unset element traps but a
set-but-empty element is fine. Note that `i` is taken as an
arithmetic context for indexed arrays (so a bare name is treated as
a variable) and as a literal key for associative arrays.

```bash
# scenario: indexed-array element existence vs emptiness under set -u
#!/usr/bin/env bash
set -euo pipefail

declare -a fruits=()
fruits[0]='apple'
fruits[2]=''                                   # set, but empty
# fruits[1] is unset — there is a *gap*

[[ -v fruits[0] ]] && echo "0 set: '${fruits[0]}'"   # ⇒ 0 set: 'apple'
[[ -v fruits[1] ]] && echo '1 set' || echo '1 unset' # ⇒ 1 unset
[[ -v fruits[2] ]] && echo "2 set: '${fruits[2]}'"   # ⇒ 2 set: '' (BCS0206)

# associative arrays: the index is a key string, NOT arithmetic
declare -A meta=([author]='gd' [date]='')
[[ -v meta[author] ]] && echo 'author key set'       # ⇒ author key set
[[ -v meta[missing] ]] || echo 'missing key absent'  # ⇒ missing key absent

#fin
```

The contrast with `${arr[i]:-}` is important: `${arr[1]:-default}`
under `set -u` would still trap before the `:-` could rescue it for
indexed-array gaps in some bash versions; `[[ -v arr[1] ]]` is the
robust idiom (BCS0206).

**See also**: §8.5 pattern matching (`==` glob behaviour), §8.6
regex matching with `=~`, §4.9 indexed arrays, §4.10 associative
arrays, §4.11 namerefs (interaction with `-R`), BCS0206 (arrays),
BCS0207 (parameter expansion).

#fin
