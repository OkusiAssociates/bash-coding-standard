# Error Handling

This section establishes comprehensive error handling for robust scripts. It mandates `set -euo pipefail` (with strongly recommended `shopt -s inherit_errexit`) for automatic error detection, defines standard exit code conventions (0=success, 1=general error, 2=misuse, 5=IO error, 22=invalid argument), explains trap handling for cleanup operations, details return value checking patterns, and clarifies safe error suppression methods (`|| true`, `|| :`, conditional checks). Error handling must be configured before any other commands run.
