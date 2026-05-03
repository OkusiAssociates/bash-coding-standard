<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 15.9 Help text conventions

Conventions for `--help` output (BCS0704). The text is a contract
between the script and its callers; departures from convention break
muscle memory.

### Required sections

- **Usage line** — `Usage: NAME [OPTIONS] [ARGS]`.
- **Brief description** — one short paragraph immediately below.
- **Options block** — `-x, --long DESC` indented two spaces, aligned.
- **Examples** — at least one realistic invocation.
- **Exit codes** — when more than `0`/`1` are used (BCS0602).
- **See also** — pointer to man page, related commands, project URL.

### Width and stream

- 80 columns or current terminal width — never wider.
- Always to **stdout** (so users can `mytool --help | less`).
- Exit `0` (help is success).

### Fully-formed sample

```bash
# scenario: a real --help, line by line
usage() {
  cat <<HELP
$SCRIPT_NAME $VERSION -- Synchronise local files to a remote server.

Usage: $SCRIPT_NAME [OPTIONS] SOURCE [SOURCE...] DEST

Description:
  Wraps rsync with project conventions: dry-run by default, exclude
  patterns from .syncignore, and refuse to run on the production hosts
  unless --not-dry-run is given.

Options:
  -n, --dry-run            preview changes (default)
  -N, --not-dry-run        execute the sync
  -d, --delete             delete extraneous files at DEST
  -x, --exclude PATTERN    additional exclude (repeatable)
  -V, --venv               include .venv directories
  -v, --verbose            increase verbosity
  -q, --quiet              suppress informational output
  -h, --help               show this help and exit
      --version            show version and exit

Examples:
  # preview a sync to ok1
  $SCRIPT_NAME 1

  # actually push to ok1, ok2, ok3
  $SCRIPT_NAME -N 1 2 3

  # sync with .venv included and a custom exclude
  $SCRIPT_NAME -NV -x '*.tmp' 1

Exit codes:
  0   success
  1   general error
  2   usage error
  18  missing dependency (rsync)
  22  invalid argument

See also:
  rsync(1), push-to-okusi(8), https://example.com/docs/sync
HELP
}
```

### Heredoc discipline

- Use a quoted-or-unquoted heredoc consistently — the example above
  expands `$SCRIPT_NAME` and `$VERSION` because the delimiter `HELP`
  is unquoted (BCS0904). For static help text, quote the delimiter
  (`<<'HELP'`) to skip expansion.
- Two-space indent on the options column; align the description column
  to a fixed offset (24 columns is the common BCS choice).

### Per-subcommand help

Subcommand CLIs (§15.8) need both a top-level usage and a
`show_NAME_help` for each subcommand. The top-level usage lists
subcommands rather than options:

```text
Subcommands:
  init       initialise a new project
  build      build the artefact
  deploy     deploy to a target
  help       show subcommand help

Run '$SCRIPT_NAME help SUBCOMMAND' for per-subcommand help.
```

### See also

- §15.10 — synopsis grammar (the `[OPTIONS] SOURCE...` syntax)
- §15.11 — auto-generating usage from option specs
- BCS0704 (usage documentation), BCS0602 (exit codes)

#fin
