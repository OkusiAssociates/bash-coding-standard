## Exit Codes

Exit codes provide consistent error reporting across scripts. This is a **reference guide** - use integers directly or define constants as needed.

### Standard `die()` Function

```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

**Usage patterns:**
```bash
# Direct integer (simplest)
die 3 'File not found'
die 22 'Invalid argument'

# With constants (clearer intent)
declare -i ERR_NOENT=3
die "$ERR_NOENT" "Config file not found ${file@Q}"
```

---

### BCS Canonical Exit Codes

#### Success

| Code | Name | Description |
|------|------|-------------|
| 0 | SUCCESS | Successful termination |

#### Core Errors (Bash convention)

| Code | Name | Description |
|------|------|-------------|
| 1 | ERR_GENERAL | General/unspecified error (catchall) |
| 2 | ERR_USAGE | Command line usage error |

#### File Operations

| Code | Name | Description | errno |
|------|------|-------------|-------|
| 3 | ERR_NOENT | No such file or directory | ENOENT=2 |
| 4 | ERR_ISDIR | Is a directory (expected file) | EISDIR=21 |
| 5 | ERR_IO | I/O error | EIO=5 |
| 6 | ERR_NOTDIR | Not a directory (expected dir) | ENOTDIR=20 |
| 7 | ERR_EMPTY | File/input is empty | - |

#### Arguments & Validation

| Code | Name | Description | errno |
|------|------|-------------|-------|
| 8 | ERR_REQUIRED | Required argument missing | - |
| 9 | ERR_RANGE | Value out of range | ERANGE=34 |
| 10 | ERR_TYPE | Wrong type/format | - |
| 22 | ERR_INVAL | Invalid argument | EINVAL=22 |

#### Permissions

| Code | Name | Description | errno |
|------|------|-------------|-------|
| 11 | ERR_PERM | Operation not permitted | EPERM=1 |
| 12 | ERR_READONLY | Read-only filesystem | EROFS=30 |
| 13 | ERR_ACCESS | Permission denied | EACCES=13 |

#### Resources

| Code | Name | Description | errno |
|------|------|-------------|-------|
| 14 | ERR_NOMEM | Out of memory | ENOMEM=12 |
| 15 | ERR_NOSPC | No space left on device | ENOSPC=28 |
| 16 | ERR_BUSY | Resource busy/locked | EBUSY=16 |
| 17 | ERR_EXIST | Already exists | EEXIST=17 |

#### Environment & Dependencies

| Code | Name | Description |
|------|------|-------------|
| 18 | ERR_NODEP | Missing dependency (command/library) |
| 19 | ERR_CONFIG | Configuration error |
| 20 | ERR_ENV | Environment error |
| 21 | ERR_STATE | Invalid state/precondition |

#### Network

| Code | Name | Description | errno |
|------|------|-------------|-------|
| 23 | ERR_NETWORK | General network error | - |
| 24 | ERR_TIMEOUT | Operation timed out | ETIMEDOUT=110 |
| 25 | ERR_HOST | Host unreachable/unknown | EHOSTUNREACH=113 |

---

### Reserved Ranges

| Range | Purpose |
|-------|---------|
| 64-78 | BSD sysexits.h (EX_USAGE=64, EX_CONFIG=78) |
| 126 | Command cannot execute (Bash) |
| 127 | Command not found (Bash) |
| 128+n | Fatal signal n (130=SIGINT, 137=SIGKILL, 143=SIGTERM) |

---

### Common Usage Examples

```bash
# File operations
[[ -f "$config" ]] || die 3 "Config not found ${config@Q}"
[[ -d "$dir" ]] || die 6 "Not a directory ${dir@Q}"
[[ -s "$input" ]] || die 7 "Input file is empty ${input@Q}"

# Argument validation
[[ -n "$required" ]] || die 8 'Required argument missing: --name'
((port >= 1 && port <= 65535)) || die 9 "Port out of range: $port"
[[ "$mode" =~ ^(read|write)$ ]] || die 22 "Invalid mode ${mode@Q}"

# Permissions
[[ -r "$file" ]] || die 13 "Cannot read ${file@Q}"
[[ -w "$dir" ]] || die 12 "Directory is read-only ${dir@Q}"

# Dependencies
command -v jq &>/dev/null || die 18 'Missing dependency: jq'
[[ -f "$config" ]] || die 19 'Configuration file missing'

# Network
curl -sf "$url" || die 24 "Request timed out: $url"
ping -c1 "$host" &>/dev/null || die 25 "Host unreachable: $host"
```

---

### Checking Exit Codes

```bash
if validate_input "$data"; then
  process "$data"
else
  case $? in
    8)  die 8 'Validation failed: missing required field' ;;
    9)  die 9 'Validation failed: value out of range' ;;
    22) die 22 'Validation failed: invalid format' ;;
    *)  die 1 'Validation failed: unknown error' ;;
  esac
fi
```

---

### Design Rationale

- **0-2 (Bash convention)**: Match standard shell behavior
- **3-25 (BCS custom)**: Logical groupings by error category
- **22 (EINVAL)**: Preserved at errno value - widely recognized
- **errno alignment**: Where practical (5, 13, 16, 17, 22) for familiarity
- **Avoid 64+**: Reserved for sysexits.h and signal codes

**Goal**: Consistency across scripts when the same error type occurs. Not a mandate - use what makes sense for your script.

