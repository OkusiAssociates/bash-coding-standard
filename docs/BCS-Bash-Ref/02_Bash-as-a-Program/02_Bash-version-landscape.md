<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 2.2 Bash version landscape

Bash's feature set has grown substantially since 4.0 (2009). Targeting a specific minimum is a load-bearing decision: scripts that rely on `mapfile -d` (4.3) or `${var@Q}` (4.4) silently fall back to broken behaviour on older Bashes. Use `BASH_VERSINFO` for a runtime gate (BCS0409) rather than a comment that says "needs Bash 4.4+".

Release-by-release additions:

- **3.2 (2006)** — the macOS perpetual baseline. No associative arrays, no `mapfile`, no `coproc`.
- **4.0 (2009)** — associative arrays (`declare -A`), `coproc`, `mapfile`/`readarray`, `&>>`, `**` globstar, `;&`/`;;&` case fall-through, `read -i`, autocd.
- **4.1 (2009)** — `printf -v` writes into named variable, `BASH_XTRACEFD` for redirected `set -x`, `&>` standardised.
- **4.2 (2011)** — `declare -g` (assign global from function), `printf '%(fmt)T'` (strftime built-in), `lastpipe` shopt.
- **4.3 (2014)** — namerefs (`declare -n`), `mapfile -d` for custom record separators, `wait -n`, negative subscripts on indexed arrays.
- **4.4 (2016)** — parameter transforms `${var@Q/E/P/A/a/K/k/U/u/L}` (BCS0306), `local -` (save/restore options), `mapfile` callback improvements, `BASH_REMATCH` made readonly.
- **5.0 (2019)** — `EPOCHSECONDS`, `EPOCHREALTIME`, `BASH_ARGV0` (writable `$0`), `history -d` ranges, `assoc_expand_once`.
- **5.1 (2020)** — `SRANDOM` (cryptographically-seeded), `BASH_REMATCH` reset on regex failure, `wait -p` to capture PID.
- **5.2 (2022)** — recursive bison grammar for `$(…)`, `varredir_close` shopt, `${var@k}` (assoc-array key-value pairs), `globskipdots`, `noexpand_translation`, `patsub_replacement`.
- **5.3 (2025)** — no-fork command substitution `${ cmd; }`, expanded `compgen`, further globbing options (§25).

```bash
# scenario: gate a script on a minimum Bash and bail loudly on macOS 3.2
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4) )); then
  printf 'requires Bash >= 4.4 (have %s)\n' "$BASH_VERSION" >&2
  exit 1
fi
# inspect the full tuple
printf '%s\n' "${BASH_VERSINFO[@]}"
# ⇒ 5
# ⇒ 2
# ⇒ 21
# ⇒ 1
# ⇒ release
# ⇒ x86_64-pc-linux-gnu
```

The full version-feature matrix is in Appendix M; treat it as the authoritative cross-reference when porting.

**See also**: §2.3 (build-time feature detection), §2.7 (`--version`), §23.6 (macOS 3.2 workarounds), §25 (5.3 preview), Appendix M (full feature matrix).

#fin
