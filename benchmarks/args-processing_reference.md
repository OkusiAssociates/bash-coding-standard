# Argument Processing Methods Reference

Four approaches to parsing command-line arguments in Bash 5.2+.
Benchmarks show `getopts` is the fastest on short and bundled options
(C-level bundling); the BCS while/case pattern is competitive on
non-bundled forms and the only pure-Bash option for long flags. GNU
`getopt` forks an external process and is **~35× (≈3400%) slower** at
~1.05 ms per invocation. See BCS0801, BCS0805.

## Quick Comparison

| Feature              | BCS while/case | getopts | GNU getopt | Simple while/case |
|----------------------|:-:|:-:|:-:|:-:|
| Long options         | ✓ | ✗ | ✓ | ✓ |
| Option bundling      | ✓ | ✓ | ✓ | ✗ |
| `-oFILE` attached arg| ✗ | ✓ | ✓ | ✗ |
| Pure Bash (no fork)  | ✓ | ✓ | ✗ | ✓ |
| Argument validation  | Manual | Automatic | Automatic | Manual |
| Error messages       | Custom | Generic | Generic | Custom |
| BCS recommended      | ✓ | Acceptable | ✗ | ✗ |

## Benchmark Results

Measured on Intel i9-13900HX, Bash 5.2.21, 10 runs per series, mean
times in seconds. See `args-processing_results_*.txt` for raw data.

| Test                        | BCS while/case | getopts | GNU getopt | Simple case |
|-----------------------------|---------------:|--------:|-----------:|------------:|
| Short options (1K iter)     | 0.038          | **0.031** | 1.056    | 0.038       |
| Short options (5K iter)     | 0.175          | **0.151** | 5.299    | 0.182       |
| Long options (1K iter)      | **0.041**      | n/a     | 1.081      | 0.041       |
| Long options (5K iter)      | **0.193**      | n/a     | 5.477      | 0.201       |
| Bundled short (1K iter)     | 0.087          | **0.032** | 1.109    | n/a         |
| Bundled short (5K iter)     | 0.442          | **0.162** | 5.564    | n/a         |

**Reading the numbers:**
- `getopts` wins short and bundled by ~16-23% (non-bundled) or ~2.7×
  (bundled) — its option splitting is implemented in C, the BCS pattern
  re-enters the loop in shell.
- For long options, `getopts` does not compete (POSIX limitation). BCS
  while/case ties Simple case.
- GNU `getopt` is 26-35× slower across every test — the cost of
  `fork()+execve()` per invocation. Per-call overhead is consistently
  ~1.05-1.11 ms.

## Method 1: BCS while/case (BCS0801 + BCS0805)

The standard BCS pattern. Handles long options, bundling, and custom errors.

```bash
while (($#)); do case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -q|--quiet)   VERBOSE=0 ;;
  -o|--output)  noarg "$@"; shift; OUTPUT=$1 ;;
  -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  --)           shift; FILES+=("$@"); break ;;
  -[vqoVh]?*)   set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)           die 22 "Invalid option ${1@Q}" ;;
  *)            FILES+=("$1") ;;
esac; shift; done
```

**Bundling line explained:**
`-[vqoVh]?*)` matches any `-X...` where `X` is a listed short option followed
by more characters. It peels the first option off: `-vqn` becomes `-v` `-qn`,
then `-q` `-n` on the next pass. The `continue` re-enters the loop without
the trailing `shift`, since no option was consumed yet.

**Character class rule:** list every valid short option. Arg-taking options
(like `-o`) work correctly when last in the bundle: `-vo file` disaggregates
to `-v -o`, then `-o` consumes `file` via shift. Placing them mid-bundle
(`-ov file`) disaggregates to `-o -v`, and `-o` consumes `-v` as its argument
-- user error, not a parser bug.

## Method 2: getopts (Bash builtin)

Short options only. Handles bundling and `-oFILE` natively.

```bash
while getopts 'vqo:Vh' opt; do
  case $opt in
    v) VERBOSE=1 ;;
    q) VERBOSE=0 ;;
    o) OUTPUT=$OPTARG ;;
    V) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    h) show_help; exit 0 ;;
    *) show_help 2 ;;
  esac
done
shift $((OPTIND - 1))
```

**Limitations:**
- No `--long-option` support (POSIX constraint)
- Error messages are generic (`illegal option`)
- `OPTIND` must be reset if parsing multiple times
- Stops at first non-option argument (no mixed args/options)

**When acceptable:** simple scripts with few options, all short, no
long forms needed. Note: `getopts` is the **fastest** parser in the
benchmarks for short and bundled options (~16-23% faster than BCS
while/case unbundled, ~2.7× faster bundled). The BCS preference for
while/case is driven by long-option support and explicit dispatch, not
performance.

## Method 3: GNU getopt (external command)

Supports everything but forks a process. Requires `util-linux` getopt (not BSD).

```bash
parsed=$(getopt -o 'vqo:Vh' \
  -l 'verbose,quiet,output:,version,help' \
  -- "$@") || exit 2
eval set -- "$parsed"

while (($#)); do case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -q|--quiet)   VERBOSE=0 ;;
  -o|--output)  OUTPUT=$2; shift ;;
  -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  --) shift; break ;;
esac; shift; done
```

**Why BCS avoids this:**
- Forks an external process (~1.05-1.11 ms per call; **~26-35× slower**
  than the pure-Bash methods across every measured workload)
- Requires `eval set --` which is fragile and hard to audit
- Not portable: BSD getopt is incompatible with GNU getopt
- Reorders arguments silently (options before non-options)

## Method 4: Simple while/case (common tutorial pattern)

Long options, no bundling. What most programmers write without guidance.

```bash
while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose) VERBOSE=1; shift ;;
    -q|--quiet)   VERBOSE=0; shift ;;
    -o|--output)  shift; OUTPUT=$1; shift ;;
    --) shift; break ;;
    *)  break ;;
  esac
done
```

**Problems:**
- No bundling: `-vq` is unrecognised, users must type `-v -q`
- Uses `[[ $# -gt 0 ]]` instead of the more efficient `(($#))`
- Each case arm must remember its own `shift` (inconsistent, error-prone)
- Adding bundling after the fact is difficult and usually done incorrectly

**Common broken bundling attempts:**

```bash
# broken -- regex split, mishandles arg-taking options
-[a-zA-Z][a-zA-Z]*) for ((i=1; i<${#1}; i++)); do
    parse_opt "-${1:i:1}"    # -ofile calls parse_opt -o, then -f, -i, -l, -e
  done ;;

# broken -- expands unknown characters
-??*) while [[ ${#1} -gt 2 ]]; do
    set -- "${1:0:2}" "-${1:2}" "${@:2}"
  done ;;                    # no char class filter, expands -Zfoo to -Z -f -o -o
```

These fail because they lack a character class filter and cannot distinguish
boolean options from arg-taking options. The BCS pattern avoids both traps
with its explicit character class and `continue`-based re-entry.

## BCS Argument Style

BCS does not support `-oFILE` (attached argument) forms. Arguments must
always be space-separated: `-o FILE`.

This is a deliberate simplicity trade-off. The bundling disaggregation
pattern treats `-oFILE` as `-o -F -I -L -E`, which is incorrect.
getopts and GNU getopt support attached arguments natively because they
use a fundamentally different parsing strategy (optstring-driven scanning
vs pattern matching).

## Argument Validation (BCS0803)

Always validate that arg-taking options have an argument:

```bash
noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

# usage -- noarg before shift
-o|--output) noarg "$@"; shift; OUTPUT=$1 ;;
```

Without `noarg`, `--output --verbose` silently captures `--verbose` as
the output filename.

## Notes

- All three pure-Bash methods parse in microseconds per call. For
  scripts that parse arguments once at startup the differences (~30-450
  µs total) are irrelevant; the choice is driven by capability
  (long options, bundling) and clarity, not speed.
- The exception is `getopts` vs BCS while/case on **bundled** input:
  ~2.7× wider gap. Still microseconds per call in absolute terms, but
  worth noting if bundling is the dominant call pattern.
- BCS mandates `(($#))` over `[[ $# -gt 0 ]]` (BCS0801) -- arithmetic
  evaluation is faster and more idiomatic.
- Place argument parsing inside `main()` for scripts >200 lines (BCS0804).
- Make parsed variables `readonly` after parsing completes.
- The `--` sentinel ends option parsing; everything after is positional.
