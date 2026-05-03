<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.16 Self-test mode (dual-purpose script)

A script that runs as a script when invoked directly and as a library when sourced.

```bash
if (( ${#BASH_SOURCE[@]} == 1 )); then
  main "$@"
fi
```

- Detects whether sourced (length > 1) or executed (length == 1).
- Run `main` only when executed directly.
- Allows the same file to be sourced for testing of its functions.
- Alternative: `[[ ${BASH_SOURCE[0]} == "$0" ]]` (less reliable in subtle cases).
- BCS template includes this pattern.

#fin
