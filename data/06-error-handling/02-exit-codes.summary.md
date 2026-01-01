## Exit Codes

**Standard implementation:**
```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
die 0                    # Success (or use `exit 0`)
die 1                    # Exit 1 with no error message
die 1 'General error'    # General error
die 2 'Missing argument' # Missing argument
die 22 'Invalid option'  # Invalid argument
```

**Standard exit codes:**

| Code | Meaning | When to Use |
|------|---------|-------------|
| 0 | Success | Command completed successfully |
| 1 | General error | Catchall for general errors |
| 2 | Misuse of shell builtin | Missing keyword/command, permission denied |
| 22 | Invalid argument | Invalid option provided (EINVAL) |
| 126 | Command cannot execute | Permission problem or not executable |
| 127 | Command not found | Possible typo or PATH issue |
| 128+n | Fatal error signal n | e.g., 130 = Ctrl+C (128+SIGINT) |
| 255 | Exit status out of range | Use 0-255 only |

**Custom codes with constants:**
```bash
readonly -i SUCCESS=0
readonly -i ERR_GENERAL=1
readonly -i ERR_USAGE=2
readonly -i ERR_CONFIG=3
readonly -i ERR_NETWORK=4

die "$ERR_CONFIG" 'Failed to load configuration file'
die 22 "Invalid option ${1@Q}"  # Bad argument (EINVAL)
```

**Rationale:** 0=success (universal Unix convention), 1=general error (safe catchall), 2=usage error (matches bash built-in behavior), 22=EINVAL (standard errno). Use 1-125 for custom codes to avoid signal conflicts (128+n).

**Checking exit codes:**
```bash
if command; then
  echo 'Success'
else
  exit_code=$?
  case $exit_code in
    1) echo 'General failure' ;;
    2) echo 'Usage error' ;;
    *) echo "Unknown error: $exit_code" ;;
  esac
fi
```
