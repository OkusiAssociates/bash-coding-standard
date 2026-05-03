<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 15.7 `--` end-of-options

Standard convention for ending option processing (BCS0806). After the
literal `--`, every remaining argument is positional, even if it
starts with `-`. Without this discipline a filename like `-rf` is
silently parsed as the option `-r` followed by `-f`.

### The case arm

```bash
--)            shift; POSITIONAL+=("$@"); break ;;
```

`shift` skips the `--` itself; `POSITIONAL+=("$@")` slurps every
remaining argv slot into the array; `break` exits the loop.

### Filename-with-leading-dash

```bash
# scenario: a file named -input.log must be passable to the script
mytool --verbose -- -input.log

# inside parse_args, the loop reaches:
#   $1=-input.log  (after -- has been consumed)
# the * arm fires: POSITIONAL+=("$1") — captures the literal name
```

Without the `--`, the arm `-*) die 22 "unknown option: $1"` rejects
`-input.log` as an unknown flag. The `--` sentinel is the canonical
escape hatch.

### Pass-through to children

Long-running wrappers should propagate `--` to inner commands so the
escape hatch chains through the whole pipeline:

```bash
# scenario: outer wrapper that passes positionals through to rsync
parse_args "$@"
rsync -av --delete -- "${POSITIONAL[@]}"
```

This way `mytool -- -src dest` reaches `rsync -- -src dest`, which in
turn treats `-src` as a literal source path.

### When to omit

Scripts that take *no* positional arguments do not need `--` handling.
A `*) die 22 "unexpected argument: $1"` arm protects against typos
without needing the sentinel.

### Cross-tool register

Most GNU tools honour `--`: `rm -- -file`, `grep -- -pattern file`,
`git checkout -- file`. Documenting it in `--help` (§15.9) under the
"Use `--` to end option processing" hint is good practice.

### See also

- §15.1 — CLI conventions
- §15.4 — full hand-rolled parser
- BCS0801 (standard parsing pattern), BCS0806 (standard options)

#fin
