<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 15.1 CLI conventions

Conventions for command-line interfaces that bash scripts should follow
(BCS0801, BCS0806). Following them keeps a script's surface predictable
to humans, shells, and other tools.

### Form register

- **Short options** — `-x`, single character, may take a value
  (`-fname` or `-f name`).
- **Long options** — `--long`, may take a value (`--file=name` or
  `--file name`).
- **Bundled short** — `-abc` is `-a -b -c` (each must be flag-only;
  see §15.6).
- **End-of-options** — `--` terminates options; everything after is
  positional (§15.7).
- **Stdin/stdout sentinel** — `-` alone is conventionally "stdin" or
  "stdout".

### Standard option register

| Short | Long | Purpose |
|-------|------|---------|
| `-h` | `--help` | print usage and exit 0 |
| `-V` | `--version` | print version and exit 0 |
| `-v` | `--verbose` | increase verbosity |
| `-q` | `--quiet` | suppress informational output |
| `-n` | `--dry-run` | simulate without changing state |
| `-y` | `--yes` | assume yes to prompts |
| `-f` | `--force` | override safety checks |

### Concrete invocation examples

The same script should accept all conventional forms — calls below all
parse to the same effective configuration:

```bash
# scenario: every form a well-behaved CLI must accept
mytool -v -n -f config.yaml input.txt
mytool --verbose --dry-run --file config.yaml input.txt
mytool --verbose --dry-run --file=config.yaml input.txt
mytool -vnf config.yaml input.txt           # bundled, last takes value
mytool -vn --file config.yaml -- -input.txt # -- protects positional
```

The `--` form is what distinguishes a careful caller: a filename of
`-input.txt` would otherwise be parsed as the unknown option `-i`.

### Discoverability rules

- Help: `-h` *and* `--help` both work, both exit 0 to stdout
  (machine-readable consumers redirect `--help` into a pager).
- Version: `-V` *and* `--version`, output is one line, machine-parsable
  (`name version`).
- Unknown option: exit 22 with a one-line diagnostic on stderr
  (BCS0602).

### Composability

Standard exit codes (§13.10, BCS0602) let pipelines compose:

```bash
# scenario: pipe-friendly CLIs allow this idiom
mytool --quiet input | downstream || die 1 'pipeline failed'
```

`-q` suppresses informational chatter; `||` catches the non-zero exit;
`die` (BCS0703) reports and exits.

### See also

- §15.4 — the canonical hand-rolled parser
- §15.9 — `--help` text conventions
- BCS0801 (standard parsing pattern), BCS0806 (standard options)

#fin
