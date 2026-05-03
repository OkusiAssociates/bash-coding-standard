<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 24.3 Variable storage

Bash maintains variables in a hash table, scoped by call stack.

- One global variable table.
- Per-function local-variable tables.
- Lookup: walk from innermost scope outward.
- Hash table: open addressing, linear probing.
- Variable record: name, value, attributes (`-i`, `-a`, etc.), reference count.
- Performance: `O(1)` average; `O(N)` worst case under collision.

#fin
