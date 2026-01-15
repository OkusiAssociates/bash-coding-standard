# Functions

**Functions use `lowercase_with_underscores`, require `main()` for scripts >200 lines, organized bottom-up.**

**Organization:** messaging â†' helpers â†' business logic â†' `main()` (each function calls only previously defined functions).

**Export:** Use `declare -fx func_name` for sourceable libraries.

**Production:** Remove unused utility functions from mature scripts.

**Ref:** BCS0400
