# Section 03: Strings & Quoting

## BCS0300 Section Overview

Single quotes signal "literal text"; double quotes signal "shell processing needed." This semantic distinction clarifies intent for both developers and AI assistants.

## BCS0301 Quoting Fundamentals

Use single quotes for static strings. Use double quotes only when variable expansion is needed.

```bash
# correct
info 'Checking prerequisites...'
info "Processing $count files"
die 1 "Unknown option ${1@Q}"
EMAIL='user@domain.com'
VAR=''

# wrong — double quotes for static string
info "Checking prerequisites..."
EMAIL="user@domain.com"
VAR=""
```

One-word alphanumeric literals (`a-zA-Z0-9_-./`) may be unquoted: `STATUS=success`, `[[ "$level" == INFO ]]`. When in doubt, quote everything.

In general, quote variable portions separately from literal path components for clarity:

```bash
# recommended — clear boundaries
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"

# acceptable but less clear
"$PREFIX/bin"
"$SCRIPT_DIR/data/$filename"
```

## BCS0302 Command Substitution

Use double quotes when strings include command substitution.

```bash
# correct
echo "Current time: $(date +%T)"
result=$(git describe --tags)        # simple assignment, quotes optional
VERSION="$(git describe)".beta       # concatenation needs quotes
echo "$result"                       # always quote when using

# wrong
echo $result                         # unquoted usage
```

## BCS0303 Quoting in Conditionals

Inside `[[ ]]`, **no word splitting or pathname expansion occurs** — variables are safe unquoted in any position. Quoting only matters for the right-hand side of `==`/`!=` (where it controls pattern vs literal matching) and `=~` (where it disables regex).

```bash
# correct — all unquoted forms are safe inside [[ ]]
[[ -f $file ]]
[[ -d $dir && -r $dir ]]
[[ $name == "$expected" ]]           # quoted RHS: literal comparison
[[ $mode == production ]]            # static value, quotes optional

# correct — glob matching (right side unquoted)
[[ $filename == *.txt ]]

# correct — regex (right side unquoted)
[[ $email =~ ^[a-z]+@[a-z]+$ ]]

# wrong
[ -f $file ]                         # **never** use [ ]; it requires quoting
[[ $input =~ "$pattern" ]]           # quoted regex disables matching
```

## BCS0304 Here Documents

Use quoted delimiter `<<'EOF'` for literal content. Use unquoted delimiter `<<EOF` for variable expansion. Use descriptive names for the delimiter.

```bash
# correct — no expansion needed
cat <<'VARS'
Variables like $HOME are literal text.
VARS

# correct — expansion needed
cat <<EOT
Hello $USER, your home is $HOME
EOT

# correct — indented (strips leading tabs, not spaces)
if true; then
	cat <<-CONTENT
	indented content
	CONTENT
fi
```

Quote here-doc delimiters for JSON, SQL, or any content with `$` characters.

## BCS0305 Printf Patterns

Use single quotes for format strings, double quotes for variable arguments.

```bash
# correct
printf '%s: %d files\n' "$name" "$count"
printf 'Line1\nLine2\n'

# wrong
echo -e "Line1\nLine2"              # inconsistent escape handling
```

Use `$'...'` syntax as an alternative for escape sequences: `echo $'Line1\nLine2'`.

## BCS0306 Parameter Quoting with @Q

Use `${parameter@Q}` to safely display user input in error messages.

```bash
# correct
die 22 "Invalid option ${1@Q}"
error "File not found ${file@Q}"
info "[DRY-RUN] Would execute ${cmd@Q}"

# wrong — no safe quoting for display
die 22 "Invalid option $1"          # special chars break output
die 2 "Invalid argument '$1'"       # special chars break output
```

Never use `@Q` for normal variable expansion or comparisons.

## BCS0307 Anti-Patterns

```bash
# wrong — double quotes for static strings
info "Starting backup..."           # use single quotes
echo "${HOME}/bin"                  # unnecessary braces

# wrong — unquoted variables
echo $result
rm $temp_file
for item in ${items[@]}

# correct
info 'Starting backup...'
echo "$HOME"/bin
echo "$result"
rm "$temp_file"
for item in "${items[@]}"
```

Use braces only when required: `${var:-default}`, `${file##*/}`, `${array[@]}`, `${var1}${var2}`.
