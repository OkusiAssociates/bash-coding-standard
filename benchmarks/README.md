# BCS Benchmarks

Companion benchmark suite for the Bash Coding Standard (BCS). Each
script measures the **runtime cost** of a Bash idiom that BCS
recommends, against equivalent constructions that BCS discourages or
treats as alternatives. Numbers from these scripts back the rule
guidance in the standard's section files.

The suite is documented in the project root `CLAUDE.md` under
*"Companion benchmarks/references"*.

---

## Quick Start

```bash
# Run any benchmark with defaults
./benchmark.while-loops.sh

# Single-pass run at a custom iteration count
./benchmark.args-processing.sh -i 2000

# Override runs-per-test (default varies per script)
./benchmark.date.sh -r 30

# Help and version
./benchmark.source-guard.sh -h
./benchmark.script-path.sh -V
```

All scripts write progress to stdout and a timestamped results file in
the current directory.

---

## Benchmark Scripts

| Script | Compares | Reference doc |
|--------|----------|---------------|
| [`benchmark.args-processing.sh`](benchmark.args-processing.sh) | BCS while/case vs. `getopts` vs. GNU `getopt` vs. simple while/case (3 argument styles: short / long / bundled) | [`args-processing_reference.md`](args-processing_reference.md) |
| [`benchmark.date.sh`](benchmark.date.sh) | `printf '%(...)T'` builtin vs. external `date(1)` (discard-output and capture-to-variable variants) | [`date_reference.md`](date_reference.md) |
| [`benchmark.path-resolve.sh`](benchmark.path-resolve.sh) | `cd && pwd` vs. `realpath` for directory resolution (logical and canonical pairs) | [`path-resolve_reference.md`](path-resolve_reference.md) |
| [`benchmark.script-path.sh`](benchmark.script-path.sh) | Five idioms for resolving a script's own path: `realpath`, `readlink -f`, `cd -P && pwd -P`, `cd -P && pwd -P` (dir only), pure-Bash `readlink` loop — under direct and symlinked `$0` | [`script-path_reference.md`](script-path_reference.md) |
| [`benchmark.source-guard.sh`](benchmark.source-guard.sh) | Three "sourced vs. executed" guard patterns: `BASH_SOURCE` check, `return 0` guard, `(return 0)` subshell | [`source-guard_reference.md`](source-guard_reference.md) |
| [`benchmark.while-loops.sh`](benchmark.while-loops.sh) | `while ((1))` vs. `while :` vs. `while true` (empty body and arithmetic-work body) | [`while-loops_reference.md`](while-loops_reference.md) |

---

## Common Options

Every script accepts the same option set:

| Option | Description |
|--------|-------------|
| `-h, --help` | Show full per-script help and exit |
| `-V, --version` | Show version and exit |
| `-i NUM` | Replace the default iteration matrix with a single pass at `NUM` iterations |
| `-r NUM` | Runs per test series (default: 10, except `benchmark.while-loops.sh` which uses 30) |

Both `-i` and `-r` validate their arguments as positive integers and
exit with status `22` on invalid input.

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 2 | Unexpected positional argument |
| 18 | Missing dependency (e.g. GNU `getopt` for `benchmark.args-processing.sh`) |
| 22 | Unknown option or invalid option argument |

---

## How Each Benchmark Works

All six scripts follow an identical harness:

1. **Setup.** Print system info (kernel, CPU, Bash version, runs-per-test).
2. **Test series.** For each (method × iteration count) combination,
   run the inner loop `RUNS_PER_TEST` times. Each run is timed end-to-end
   using `EPOCHREALTIME` (microsecond resolution), with the inner-loop
   counter implemented as `((i++)) || break` so termination crosses zero
   without an explicit comparison.
3. **Statistics.** Compute mean, median, and standard deviation across
   the `RUNS_PER_TEST` samples per method. Report in tabular form.
4. **Comparison.** Identify the fastest method and report each other
   method's percent slowdown (or absolute slowdown ratio for the
   two-method scripts).
5. **Persist.** Append everything to a timestamped results file in the
   current directory.

Results files are named `<testname>_results_YYYY-MM-DD_HH:MM:SS.txt`,
where `<testname>` is derived from the script filename
(`benchmark.args-processing.sh` → `args-processing`).

---

## Reference Documents

Each benchmark has a paired reference doc named
`<testname>_reference.md`. They contain:

- The full set of idioms tested, in BCS-compliant Bash.
- Semantic notes explaining what each idiom does and where the variants
  differ in behaviour (not just performance).
- Recommendations on when to prefer which idiom, with the benchmark
  numbers as supporting evidence.

These are the canonical artefacts — the benchmark scripts merely
generate the numbers that the reference docs cite.

---

## BCS Compliance

Every benchmark script in this directory:

- Passes `shellcheck -x` cleanly.
- Follows the BCS 13-step mandatory script structure (shebang,
  `set -euo pipefail`, `shopt` flags, metadata, utility functions,
  `main()`, `#fin`).
- Uses the BCS0801 argument-parsing pattern with BCS0805 short-option
  bundling (`-[hVir]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}"`).
- Validates numeric option arguments at the parsing boundary.
- Uses `local -n` namerefs (BCS1004) for array indirection — never
  `eval`.

▲ **Note on suppressions.** The inner measurement loops use
`((i++)) || break` and are explicitly exempted with `#bcscheck
disable=BCS0505` directives. The construct is intentional — rewriting
to `i+=1` would change what is being measured. Similarly,
`benchmark.args-processing.sh` includes a `while [[ $# -gt 0 ]]`
pattern under `#bcscheck disable=BCS0503` because that construct is
itself one of the parsers being benchmarked.

---

## Adding a New Benchmark

1. Copy the closest existing script (`benchmark.while-loops.sh` is the
   simplest template; `benchmark.script-path.sh` is the richest).
2. Replace the `times_*` arrays, the inner-loop bodies in
   `run_benchmark_*()`, and the dispatch `case` in `run_test_series()`.
3. Bump `VERSION` and rewrite the `show_help` heredoc. `TESTNAME` and
   `RESULTS_FILE` auto-derive from the script filename — no edits
   needed there.
4. Add a corresponding `<testname>_reference.md` documenting idioms tested
   and conclusions drawn.
5. Verify with `shellcheck -x` and a short smoke run (`-i 100 -r 3`).

---

*Part of the [Bash Coding Standard](../README.md) — Okusi Associates,
for the Indonesian Open Technology Foundation (YaTTI).*
