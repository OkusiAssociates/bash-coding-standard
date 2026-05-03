<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.9 Pipes vs redirection

`cmd > out 2>&1` instead of `cmd 2>&1 | tee out` when no filtering needed.

- Pipes always involve a subshell.
- Redirection is fd manipulation in the same process.
- For "log everything to a file", redirection is direct.
- For "log AND show", `tee` (with the pipe) is the right tool.

```bash
# wrong — extra subshell, no terminal output anyway
cmd 2>&1 | tee log.txt >/dev/null

# right — pure redirection, same effect, no fork
cmd >log.txt 2>&1
```

```bash
# scenario: log-and-show — tee is the right tool, but mind pipefail
set -o pipefail
cmd 2>&1 | tee -a log.txt
# ⇒ tee's exit status (almost always 0) does NOT mask cmd's failure under pipefail
```

Without `pipefail` (BCS0101 strict mode), `cmd | tee` returns `tee`'s
status — masking `cmd` failures. With `pipefail` set, the rightmost
non-zero status wins, so `cmd`'s exit propagates. Always pair `tee` with
`set -o pipefail`, or capture status from `${PIPESTATUS[0]}` immediately
after the pipeline.

**See also**: §19.10 (builtins vs externals), BCS0101 (strict mode), BCS0711 (combined redirection).

#fin
