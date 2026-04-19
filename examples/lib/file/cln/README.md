# cln

Recursively clean temporary and junk files from directories.

## Default Patterns

```
*~  ~*  .~*  .*~  DEADJOE  dead.letter  wget-log*
```

## Installation

```bash
make install          # installs cln, man page, and bash completion
make uninstall        # removes installed files
```

## Usage

```bash
# Clean current directory (interactive)
cln

# Clean without prompting
cln -P /path/to/clean

# Quiet mode, no prompts
cln -Pq /tmp

# Add custom patterns
cln -a '*.bak,*.tmp' .

# Replace default patterns entirely
cln -S '*.tmp,*.old' /tmp

# Deep clean (depth 7)
cln -Pqm 7 /home/user

# Multiple directories
cln -P dir1 dir2 dir3
```

## Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help |
| `-V`, `--version` | Show version |
| `-p`, `-n`, `--prompt` | Prompt before deleting (default) |
| `-P`, `-N`, `--no-prompt` | Delete without prompting |
| `-v`, `--verbose` | Increase verbosity (up to 3 levels) |
| `-q`, `--quiet` | Suppress output |
| `-m N`, `--depth N` | Max depth (-1 = unlimited, default: 3) |
| `-a SPEC`, `--add SPEC` | Add file patterns (comma-separated) |
| `-S SPEC`, `--set SPEC` | Set/replace all patterns (overrides config) |
| `-L` | Follow symbolic links |

## Configuration

Patterns can be customized via config files (one pattern per line, `#` for comments).

Search order (first found wins):

| File | Purpose |
|------|---------|
| `$XDG_CONFIG_HOME/cln/cln.conf` | User override (default `~/.config`) |
| `/etc/cln/cln.conf` | System config |
| `/etc/cln.conf` | System config (flat) |
| `/etc/default/cln` | System default |
| `/usr/local/etc/cln/cln.conf` | Local install |

Command-line `-S` overrides config.

## Testing

```bash
bash tests/run-all-tests.sh
```

## Requirements

- Bash 5.2+
- GNU findutils (`find`), GNU coreutils (`rm`)

#fin
