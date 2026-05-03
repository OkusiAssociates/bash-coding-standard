<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.3 File comparison operators

Two-operand file tests, available only inside `[[ ]]` (or the
deprecated `[`/`test`).

- `file1 -nt file2` — file1 newer than file2 (modification time).
- `file1 -ot file2` — file1 older than file2.
- `file1 -ef file2` — same inode (hard links, or two paths to the
  same file).

### Pitfall — missing operands

The newness/oldness operators have an asymmetric "missing file"
rule that catches almost everyone the first time:

- `f1 -nt f2` returns **true** when `f1` exists and `f2` does *not*.
- `f1 -ot f2` returns **true** when `f2` exists and `f1` does *not*.
- `f1 -ef f2` returns **false** if either file is missing.

This means a naive freshness test can pass simply because the
comparison file does not yet exist. Always pair the freshness test
with an existence check on both operands.

```bash
# scenario: rebuild target only if source is genuinely newer.
#!/usr/bin/env bash
set -euo pipefail

src='build.in'
target='build.out'

# wrong: this is true the first time when target/ does not exist —
# which happens to be what you want here, but is a coincidence.
if [[ $src -nt $target ]]; then
  echo 'rebuild needed'
fi

# right: explicit existence check makes intent clear (BCS0901).
if [[ ! -e $target ]] || [[ $src -nt $target ]]; then
  echo 'rebuild needed (target missing or stale)'
fi

# demonstration of the trap:
rm -f phantom.txt
[[ real.txt -nt phantom.txt ]] && echo 'newer'   # ⇒ newer (phantom does not exist!)
[[ phantom.txt -nt real.txt ]] && echo 'oh?'     # not printed (phantom missing → false)

#fin
```

The `-ef` operator is reliably symmetric: it tests inode equality
and so requires both files to exist (returning false otherwise),
making it safer for "are these the same file?" checks.

**See also**: §8.2 file test operators (`-e`, `-f`, etc.), §8.7
logical operators and grouping (combine `-e` with `-nt`), BCS0901
(safe file testing), BCS0303 (quoting in conditionals).

#fin
