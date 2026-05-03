<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 14.9 Coloured output and TERM detection

Coloured diagnostics improve readability on a terminal but corrupt log
files, CI captures, and pipelines. The fix is to gate every colour
constant on a TTY check and define empty fallbacks otherwise. The BCS
pattern (BCS0706) does this once at script top, producing a set of
constants every messaging helper can use unconditionally.

### Canonical initialisation block

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' \
             CYAN=$'\033[0;36m' BOLD=$'\033[1m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi
```

The branches declare *the same set of variables* (BCS0706) — every name
exists in both modes. Messaging helpers can write `"$RED✗$NC"`
without conditional logic; when output is redirected, the colour
expansions are empty and the icons render as plain text.

### Why both `-t 1` *and* `-t 2`

`[[ -t 1 ]]` checks stdout; `[[ -t 2 ]]` checks stderr. The BCS pattern
requires both because messaging functions write to stderr (§14.1) but
data may be piped from stdout — colouring stderr while stdout is
captured is harmless, but a script that only checks `-t 1` will turn
colour off whenever its data is piped, even though the human is still
watching stderr. The pragmatic compromise BCS adopts is to colour only
when *both* descriptors are TTYs — i.e. the script is running fully
interactively.

### `tput` versus raw ANSI escapes

There are two ways to get colour codes:

```bash
# scenario: raw ANSI (BCS canonical)
declare -r RED=$'\033[0;31m' RESET=$'\033[0m'

# scenario: tput from terminfo
declare -r RED=$(tput setaf 1) RESET=$(tput sgr0)
```

| Aspect          | Raw ANSI ($'\033[…m')          | `tput setaf N`                 |
|-----------------|--------------------------------|--------------------------------|
| Portability     | Any ANSI/VT100 terminal        | Anything terminfo supports     |
| Failure mode    | Garbage on non-ANSI terminals  | Empty string if `TERM=dumb`    |
| Dependencies    | None (built into bash)         | Requires `ncurses`/terminfo    |
| Run-time cost   | Zero (string literal)          | One fork+exec per invocation   |
| Truecolor       | Direct: `\033[38;2;R;G;Bm`     | Limited to terminfo capability |

BCS prefers raw ANSI for two reasons: it is a string constant assigned
once, and modern terminals (`xterm-256color`, `screen`, `tmux`,
`alacritty`, `kitty`) all honour the standard ANSI sequences. `tput` is
preferred only when broad portability to obscure terminals matters more
than fork cost.

### Adding a `TERM=dumb` guard

If the script may run under `make`, `emacs shell`, or a CI logger that
sets `TERM=dumb`, extend the test:

```bash
# scenario: paranoid TTY+TERM gate
if [[ -t 1 && -t 2 && ${TERM:-} != dumb ]]; then
  declare -r RED=$'\033[0;31m' RESET=$'\033[0m'
else
  declare -r RED='' RESET=''
fi
```

Note `${TERM:-}` — the default expansion is required because `TERM`
may be unset under `set -u`.

### Honouring `NO_COLOR`

The `NO_COLOR` convention (no-color.org) lets users opt out by
exporting any non-empty value. Adding the check costs one term:

```bash
if [[ -t 1 && -t 2 && ${TERM:-} != dumb && -z ${NO_COLOR:-} ]]; then
  declare -r RED=$'\033[0;31m' RESET=$'\033[0m'
else
  declare -r RED='' RESET=''
fi
```

A `--no-colour` CLI flag can also clobber the constants after parsing,
but that requires `declare` without `-r` so the values stay mutable.

### Common pitfalls

- **Embedded newlines** — `printf` format strings containing colour
  codes must end with `\n`, never embed `\n` between colour and text;
  many terminals reset colour state at end-of-line.
- **Tab-completion menus** — completion scripts inherit the shell's
  TTY status; colour escapes in completion lists confuse `compgen`.
  Disable colour explicitly inside completion functions.
- **Forked subshells** — child processes do not re-evaluate `[[ -t N ]]`;
  if a script forks and the child's fd is redirected, the inherited
  constants remain ANSI-coded. Either re-run the gate in the child
  context or pass the colour state through environment.

### See also

- §14.7 — logging discipline (consumer of these constants)
- §14.1 — stdout/stderr discipline
- §14.10 — progress indicators (also colour-gated)
- BCS0706 (colour definitions), BCS0703 (messaging system),
  BCS0405 (declare only colours actually used)

#fin
