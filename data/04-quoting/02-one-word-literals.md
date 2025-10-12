### Exception: One-Word Literals

Literal one-word values (containing only alphanumeric characters, underscores, hyphens, dots, or slashes—no spaces or special shell characters) may be left unquoted in variable assignments and simple conditionals. Note: This subsection provides guidance for a common practice, but using quotes is more defensive and consistent.

```bash
# Variable assignments - one-word literals can be unquoted
ORGANIZATION=Okusi
LOG_LEVEL=INFO
DEFAULT_PATH=/usr/local/bin
FILE_EXT=.tmp

# Also correct with quotes (more defensive)
ORGANIZATION='Okusi'
LOG_LEVEL='INFO'

# Conditionals - one-word literals can be unquoted
[[ $ORGANIZATION == Okusi ]]
[[ $status == success ]]
[[ $ext == .txt ]]

# Also correct with quotes (recommended for consistency)
[[ $ORGANIZATION == 'Okusi' ]]
[[ $status == 'success' ]]

# Path construction with unquoted literals
tempfile="$PWD"/.foobar.tmp
config_dir="$HOME"/.config/myapp
backup="$filename".bak

# Multi-word or values with spaces MUST be quoted
MESSAGE='Hello world'              # ✓ Correct - contains space
[[ "$var" == 'hello world' ]]      # ✓ Correct - contains space
ERROR_MSG='File not found'         # ✓ Correct - contains spaces
```

**Recommendation:** While unquoted one-word literals are permitted and common, using quotes is more defensive and consistent. Choose based on your team's preference, but be consistent within a script.
