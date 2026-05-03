<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 14.11 Reading binary data

Bash is byte-oriented but treats NUL specially. Reading binary requires
care, and the safe outcome is usually "shell out to a tool that handles
binary natively."

### The NUL constraint

- Bash strings cannot contain NUL bytes — the C-string termination
  rule applies to every variable.
- `read -d ''` reads up to the next NUL (the NUL itself becomes the
  delimiter and is discarded).
- `mapfile -d ''` reads NUL-separated chunks into array elements.
- `IFS= read -r -n N var` reads N bytes but silently drops any NULs in
  the run.

### NUL-separated mapfile from `find -print0`

The canonical "list of files that may contain newlines" idiom:

```bash
# scenario: collect every regular file under . into a NUL-safe array
declare -a files
mapfile -d '' -t files < <(find . -type f -print0)
printf 'collected %d paths\n' "${#files[@]}"

# scenario: per-file processing without splitting on whitespace
for path in "${files[@]}"; do
  printf 'processing %q\n' "$path"
done
```

`find -print0` emits each filename followed by a NUL; `mapfile -d ''`
treats NUL as the record separator; `-t` strips it from each stored
element. The result is an array where every element is a literal
file path — newlines, spaces, and shell metacharacters preserved.

### Hex / octal escape hatches

For genuine binary processing, hand off to a tool that does not
care about NUL:

- `xxd -p file | tr -d '\n'` — hex string, easily processed in bash.
- `od -An -vtx1 file` — alternative hex dump, more portable.
- `hexdump -ve '1/1 "%02x"'` — hex output with full control over format.
- `dd bs=1 skip=N count=M` — extract a byte range.

```bash
# scenario: read a single byte at offset 0x42 as a hex string
declare -- byte
byte=$(dd if=image.bin bs=1 skip=66 count=1 2>/dev/null | xxd -p)
# ⇒ byte='ff'
```

### Safety boundary

If a script's logic requires inspecting raw bytes, the bash layer
should be a thin wrapper around a real binary-aware program (Python,
awk, perl, dedicated tool). See §20 for the security implications of
mishandling binary input from untrusted sources.

### See also

- §14.2 — `read -d ''` for NUL-framed line input
- §14.3 — `mapfile -d ''` for whole-input-into-array
- §20.5 — binary input from untrusted sources
- BCS1005 (input sanitization)

#fin
