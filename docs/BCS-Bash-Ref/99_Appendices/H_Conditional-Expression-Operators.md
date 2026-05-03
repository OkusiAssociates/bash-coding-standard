<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## Appendix H — Conditional Expression Operators

For use inside `[[ ]]`.

**File tests (single operand):**

| Operator | True if |
|----------|---------|
| `-e file` | exists |
| `-f file` | regular file |
| `-d file` | directory |
| `-L file`, `-h file` | symlink |
| `-b file` | block device |
| `-c file` | character device |
| `-p file` | FIFO |
| `-S file` | socket |
| `-r file` | readable |
| `-w file` | writable |
| `-x file` | executable |
| `-s file` | non-zero size |
| `-N file` | modified since last read |
| `-O file` | owned by EUID |
| `-G file` | group owned by EGID |
| `-k file` | sticky bit |
| `-u file` | SUID bit |
| `-g file` | SGID bit |
| `-t fd` | fd is a terminal |

**File comparisons:**

| Operator | True if |
|----------|---------|
| `f1 -nt f2` | f1 newer than f2 |
| `f1 -ot f2` | f1 older than f2 |
| `f1 -ef f2` | same inode |

**String tests:**

| Operator | True if |
|----------|---------|
| `-z str` | empty |
| `-n str` | non-empty |
| `-v var` | variable set |
| `-R name` | name is a nameref |
| `s1 = s2`, `s1 == s2` | strings equal |
| `s1 != s2` | strings not equal |
| `s1 < s2` | s1 lexically less |
| `s1 > s2` | s1 lexically greater |
| `s == pattern` | glob match |
| `s =~ regex` | ERE match |

#fin
