<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 25.5 Forward-compatibility considerations

Writing bash that will benefit from future versions without breaking.

- Avoid relying on undocumented behaviour.
- Watch deprecation notices in NEWS.
- Use modern idioms (no backticks, no `[ ]`, no `expr`).
- Pin bash version requirements in script headers.
- Test against new bash versions when they ship.

#fin
