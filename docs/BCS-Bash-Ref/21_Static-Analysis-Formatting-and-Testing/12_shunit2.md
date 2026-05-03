<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.12 shunit2

Older bash test framework, less popular than bats but still used.

- xUnit-style: `testFunctionName` named functions.
- `assertEquals`, `assertTrue`, `assertFalse`, `assertNotNull`.
- `setUp`, `tearDown`, `oneTimeSetUp`, `oneTimeTearDown`.
- Single file: `source shunit2`.
- Use case: shell-script-only environments where installing bats is heavy.

#fin
