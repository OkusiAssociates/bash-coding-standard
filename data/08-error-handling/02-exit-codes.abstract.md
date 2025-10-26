## Exit Codes

**Use standardized exit codes: 0=success, 1=general error, 2=usage error, 22=invalid argument (EINVAL).**

**Rationale:**
- 0 is universal Unix convention for success
- 1 is safe catchall for general errors
- 2 matches bash builtin behavior for argument errors
- 22 (EINVAL) is standard errno for invalid arguments
- Consistency enables reliable error handling in scripts and CI/CD

**Core implementation:**
```bash
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
die 0                    # Success
die 1 'General error'    # General error
die 2 'Missing argument' # Usage error
die 22 'Invalid option'  # Invalid argument
```

**Standard codes:**
- `0` = Success
- `1` = General error (catchall)
- `2` = Misuse of shell builtin/missing argument
- `22` = Invalid argument (EINVAL)
- `126` = Command cannot execute (permission issue)
- `127` = Command not found
- `128+n` = Fatal signal (e.g., 130 = Ctrl+C)

**Best practice - named constants:**
```bash
readonly -i SUCCESS=0 ERR_GENERAL=1 ERR_USAGE=2 ERR_CONFIG=3
die "$ERR_CONFIG" 'Failed to load configuration'
```

**Anti-patterns:**
- Inconsistent exit codes across similar errors ’ `die 1` for all failures
- Using high numbers (>125) for custom codes (conflicts with signals)
- Exiting with 0 on errors or non-zero on success

**Ref:** BCS0802
