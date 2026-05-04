<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.8 Building structured output

When a bash script has to emit data for another program — a CSV ingested by a
spreadsheet, a TSV piped to `awk`, a JSON payload curled into an API — the
scripts that fail in production almost always fail at the *quoting boundary*.
A field with an embedded comma, a stray backslash, a Unicode quotation mark
in someone's name: each is a defect just waiting for the right input.

The general rule is: **emit through a tool whose authors have already solved
the quoting problem.** For TSV that's `printf`; for CSV it's a discipline of
explicit quoting; for JSON it is unconditionally `jq`.

### TSV — the easy case

Tab-separated values with no embedded tabs or newlines is the cheapest
structured format bash supports. `printf` does the right thing for free:

```bash
# scenario: emit a TSV header and rows from arrays
printf '%s\t%s\t%s\n' name email role
for ((i=0; i<${#names[@]}; i+=1)); do
  printf '%s\t%s\t%s\n' "${names[i]}" "${emails[i]}" "${roles[i]}"
done
# ⇒ name<TAB>email<TAB>role
#   alice<TAB>alice@example.com<TAB>admin
```

The only failure mode is a field containing an actual tab or newline. Strip or
escape those at the source — `${value//$'\t'/ }` for tabs.

### CSV — explicit quoting required

CSV (RFC 4180) requires fields containing commas, double-quotes, or newlines
to be wrapped in double-quotes, with internal quotes doubled. Skipping this
step is the canonical bash CSV bug.

```bash
# scenario: write a CSV row from a bash array, RFC-4180 correct
csv_field() {
  local -- value=$1
  if [[ $value == *[\",$'\n']* ]]; then
    value=${value//\"/\"\"}              # double internal quotes
    printf '"%s"' "$value"
  else
    printf '%s' "$value"
  fi
}

csv_row() {
  local -i i
  for ((i=1; i<=$#; i+=1)); do
    (( i > 1 )) && printf ','
    csv_field "${!i}"
  done
  printf '\n'
}

# Usage:
csv_row 'Alice' 'alice@example.com' 'sales, EU'
csv_row 'Bob, Jr.'  $'multi\nline'   'admin'
# ⇒ Alice,alice@example.com,"sales, EU"
#   "Bob, Jr.","multi
#   line",admin
```

### JSON — never hand-roll, use jq

Hand-rolling JSON in bash is the wrong answer to every question. Backslashes,
control characters, Unicode, and the contrast between "null" and `"null"` will
defeat any printf-based scheme eventually. Use `jq -n` and pass values through
`--arg` (string) or `--argjson` (already-JSON):

```bash
# scenario: build a JSON object from bash variables
declare -- name='O'\''Brien' email='o@example.com'
declare -i age=42

jq -nc \
  --arg name  "$name" \
  --arg email "$email" \
  --argjson age "$age" \
  '{name: $name, email: $email, age: $age}'
# ⇒ {"name":"O'Brien","email":"o@example.com","age":42}
```

For JSON arrays built from a bash array, push the whole list through `jq -R`
(raw input) and `-s` (slurp into an array):

```bash
# scenario: emit a JSON array from a bash array of strings
declare -a tags=(red 'amber/orange' 'with "quotes"')

printf '%s\n' "${tags[@]}" | jq -R . | jq -cs .
# ⇒ ["red","amber/orange","with \"quotes\""]

# scenario: nest the array inside an object
items_json=$(printf '%s\n' "${tags[@]}" | jq -R . | jq -s .)
jq -nc --argjson items "$items_json" '{count: ($items | length), items: $items}'
# ⇒ {"count":3,"items":["red","amber/orange","with \"quotes\""]}
```

The reason `--argjson` matters: `--arg age 42` would pass the *string* "42",
yielding `{"age":"42"}`. Numeric and boolean fields must use `--argjson`.

```bash
# wrong — every field becomes a string, breaking downstream consumers
jq -nc --arg active true --arg count 0 '{active: $active, count: $count}'
# ⇒ {"active":"true","count":"0"}

# right — booleans and numbers go through --argjson
jq -nc --argjson active true --argjson count 0 '{active: $active, count: $count}'
# ⇒ {"active":true,"count":0}
```

**See also**: §6.10 (`printf` formatting); §11.4 (`mapfile -t` for the inverse —
JSON-to-bash); BCS0305 (printf patterns) for the general printf-over-echo
preference; BCS0306 (`@Q` quoting) for safe shell-quoted output when the
consumer is bash itself.

#fin
