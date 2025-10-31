# Input/Output & Messaging

Establishes standardized messaging patterns with color support and proper stream handling. Defines complete messaging suite: `_msg()` (core function using FUNCNAME), `vecho()` (verbose output), `success()`, `warn()`, `info()`, `debug()`, `error()` (unconditional to stderr), `die()` (exit with error), `yn()` (yes/no prompts). Covers STDOUT vs STDERR separation (data vs diagnostics), usage documentation patterns, and when to use messaging functions versus bare echo. Error output must use `>&2` at command beginning.
