### Standard Script General Layout
1. Shebang
2. Global shellcheck directives (where required)
3. Script description comment
4. `set -euo pipefail`
5. Script metadata (VERSION, SCRIPT_NAME, etc.)
6. Global variable declarations
7. Color definitions (if terminal output)
8. Utility functions
9. Business logic functions
10. `main()` function
11. Script invocation: `main "$@"`
12. End marker: `#fin` or `#end`
