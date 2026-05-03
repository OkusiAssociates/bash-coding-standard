<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.14 Mock-friendly subprocess wrapper

Wrap external commands behind a function for testability.

```bash
git_cmd() { command git "$@"; }
```

- Tests can override `git_cmd` to a mock.
- Use `command` prefix to bypass any function shadowing.
- Use case: any external dep that touches network, filesystem, or system state.

#fin
