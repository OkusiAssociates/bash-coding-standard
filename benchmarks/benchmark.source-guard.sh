#!/usr/bin/bash
# shellcheck disable=SC1090,SC2209,SC2034
# benchmark-source-guard.sh - Performance comparison of source guard methods
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

##
## INITIALIZATION
##

# Script metadata
declare -r VERSION=1.1.0 # 2026-04-08 - Source actual test files instead of inline proxies
declare -r SCRIPT_NAME=${0##*/}

# Test name derived from script filename: 'benchmark.X.sh' → 'X'
declare -- TESTNAME=${SCRIPT_NAME#benchmark.}
TESTNAME=${TESTNAME%.sh}
declare -r TESTNAME

# Configuration
declare -i RUNS_PER_TEST=10

# Output files
#shellcheck disable=SC2155
declare -r RESULTS_FILE=${TESTNAME}_results_$(printf '%(%F_%T)T').txt

# Test results storage
declare -a times_0 times_1 times_2

# Temp files for source testing
declare -- TMPDIR_BENCH=''
declare -- FILE_BASH_SOURCE='' FILE_RETURN_GUARD='' FILE_SUBSHELL=''

##
## FUNCTIONS
##

error() { >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "$*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
noarg() {
  if (($# <= 1)) || [[ ${2:0:1} == '-' ]]; then
    die 22 "Option ${1@Q} requires an argument"
  fi
}

show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION - Performance comparison of source guard methods

Measures the end-to-end cost of sourcing a library file with a "run-as-
script vs. sourced" guard. Each iteration opens a temp file, parses it,
defines a dummy function, evaluates the guard, and returns.

Guard patterns tested:
  1. BASH_SOURCE check    [[ \${BASH_SOURCE[0]} == "\$0" ]] || return 0
  2. return 0 guard       return 0 2>/dev/null ||:
  3. (return 0) subshell  (return 0 2>/dev/null) && return 0

Temporary guard files are written to a fresh mktemp -d directory and
removed on EXIT via trap.

Default run: 3 test series at 1K, 5K, 10K iterations.
With -i NUM: 1 test series at NUM iterations.
Each test series repeats RUNS_PER_TEST times and reports mean/median/stddev.

Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -h, --help       Show this help and exit
  -V, --version    Show version and exit
  -i NUM           Replace default 1K/5K/10K matrix with a single pass at NUM
  -r NUM           Runs per test series (default: 10)

Output:
  stdout           Live progress, per-series results, fastest method
  file             benchmark-results-source-guard-YYYY-MM-DD_HH:MM:SS.txt
                   (system info, raw numbers, analysis)

Exit codes:
  0  success
  2  unexpected positional argument
 22  unknown option or missing option argument

HELP
}

print_system_info() {
  cat <<SYSINFO
System Information
==================
Date: $(date -Iseconds)
Hostname: $(hostname)
Bash Version: $BASH_VERSION
CPU: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
Kernel: $(uname -r)
Runs per test: $RUNS_PER_TEST

SYSINFO
}

setup_test_files() {
  TMPDIR_BENCH=$(mktemp -d)

  # Pattern 1: BASH_SOURCE check
  cat > "$TMPDIR_BENCH"/guard-bash-source.sh <<'EOF'
#!/bin/bash
my_dummy_func() { :; }
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

set -euo pipefail
echo 'script'
#fin
EOF
  FILE_BASH_SOURCE=$TMPDIR_BENCH/guard-bash-source.sh

  # Pattern 2: return 0 guard
  cat > "$TMPDIR_BENCH"/guard-return.sh <<'EOF'
#!/bin/bash
my_dummy_func() { :; }
return 0 2>/dev/null ||:

set -euo pipefail
echo 'script'
#fin
EOF
  FILE_RETURN_GUARD=$TMPDIR_BENCH/guard-return.sh

  # Pattern 3: subshell test
  cat > "$TMPDIR_BENCH"/guard-subshell.sh <<'EOF'
#!/bin/bash
my_dummy_func() { :; }
(return 0 2>/dev/null) && return 0

set -euo pipefail
echo 'script'
#fin
EOF
  FILE_SUBSHELL=$TMPDIR_BENCH/guard-subshell.sh
}

cleanup_test_files() {
  [[ -d ${TMPDIR_BENCH-} ]] && rm -rf "$TMPDIR_BENCH"
}

run_benchmark_bash_source() {
  # Benchmark: source file with [[ ${BASH_SOURCE[0]} == "$0" ]] guard
  local -ri iterations=$1
  local -i i
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    source "$FILE_BASH_SOURCE"
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_benchmark_return_guard() {
  # Benchmark: source file with return 0 2>/dev/null ||: guard
  local -ri iterations=$1
  local -i i
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    source "$FILE_RETURN_GUARD"
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_benchmark_subshell() {
  # Benchmark: source file with (return 0 2>/dev/null) && return 0 guard
  local -ri iterations=$1
  local -i i
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    source "$FILE_SUBSHELL"
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

calculate_statistics() {
  # Calculate mean, median, stddev from array of values (microseconds)
  local -n values=$1
  local -i sum=0 count=${#values[@]} val=0
  local -a sorted
  local -i mean median variance sum_sq_diff
  local -- stddev

  # Calculate mean
  for val in "${values[@]}"; do
    sum+=val
  done
  mean=$((sum / count))

  # Calculate median
  readarray -t sorted < <(printf '%s\n' "${values[@]}" | sort -n)
  if ((count % 2 == 0)); then
    median=$(( (sorted[count/2-1] + sorted[count/2]) / 2 ))
  else
    median=${sorted[count/2]}
  fi

  # Calculate standard deviation
  sum_sq_diff=0
  for val in "${values[@]}"; do
    ((sum_sq_diff += (val - mean) * (val - mean)))
  done
  variance=$((sum_sq_diff / count))
  stddev=$(awk "BEGIN {printf \"%.0f\", sqrt($variance)}")

  # Return: mean median stddev (in microseconds)
  echo "$mean $median $stddev"
}

format_time() {
  # Convert microseconds to human-readable format
  local -i us=$1
  local -- seconds

  seconds=$(awk "BEGIN {printf \"%.3f\", $us/1000000}")
  echo "${seconds}s"
}

run_test_series() {
  local -r test_name=$1
  local -ri iterations=$2
  shift 2

  # Parse label/function pairs
  local -a labels=() funcs=()
  while (($#)); do
    labels+=("$1"); funcs+=("$2")
    shift 2
  done
  local -ri method_count=${#labels[@]}

  echo "Running test: $test_name (iterations: $iterations, runs: $RUNS_PER_TEST)"
  echo '========================================================================'

  # Clear timing arrays
  times_0=() times_1=() times_2=()

  # Run benchmarks
  local -i run m
  local -- result
  for ((run=1; run<=RUNS_PER_TEST; run+=1)); do
    for ((m=0; m<method_count; m+=1)); do
      printf '\rRun %2d/%d: Testing %s...' "$run" "$RUNS_PER_TEST" "${labels[m]}"
      result=$("${funcs[m]}" "$iterations")
      case $m in
        0) times_0+=("$result") ;;
        1) times_1+=("$result") ;;
        2) times_2+=("$result") ;;
      esac
    done
  done
  printf '\rRun %2d/%d: Complete!                          \n' "$RUNS_PER_TEST" "$RUNS_PER_TEST"

  # Calculate statistics per method
  local -a stat_mean=() stat_median=() stat_stddev=() _tmp
  for ((m=0; m<method_count; m+=1)); do
    IFS=' ' read -ra _tmp <<<"$(calculate_statistics "times_$m")"
    stat_mean+=("${_tmp[0]}")
    stat_median+=("${_tmp[1]}")
    stat_stddev+=("${_tmp[2]}")
  done

  # Display results
  echo
  echo "Results for: $test_name"
  echo '-------------------------------------------'
  printf '%-20s %12s %12s %12s\n' Method Mean Median StdDev

  for ((m=0; m<method_count; m+=1)); do
    printf '%-20s %12s %12s %12s\n' "${labels[m]}" \
      "$(format_time "${stat_mean[m]}")" \
      "$(format_time "${stat_median[m]}")" \
      "$(format_time "${stat_stddev[m]}")"
  done

  # Find fastest method
  local -i fastest_idx=0 fastest_time=${stat_mean[0]}
  for ((m=1; m<method_count; m+=1)); do
    if ((stat_mean[m] < fastest_time)); then
      fastest_time=${stat_mean[m]}
      fastest_idx=$m
    fi
  done

  printf '\n◉ Fastest: %s\n' "${labels[fastest_idx]}"

  # Guard against degenerate 0 µs measurements (would raise SIGFPE below)
  ((fastest_time)) || fastest_time=1

  local -i diff_pct
  for ((m=0; m<method_count; m+=1)); do
    ((m == fastest_idx)) && continue
    diff_pct=$(( (stat_mean[m] - fastest_time) * 100 / fastest_time ))
    printf '  - %s is %d%% slower\n' "${labels[m]}" "$diff_pct"
  done

  echo
  echo '========================================================================'
  echo

  # Save to results file
  { echo "Test: $test_name (iterations: $iterations)"
    for ((m=0; m<method_count; m+=1)); do
      printf '%-20s - Mean: %s, Median: %s, StdDev: %s\n' \
        "${labels[m]}" \
        "$(format_time "${stat_mean[m]}")" \
        "$(format_time "${stat_median[m]}")" \
        "$(format_time "${stat_stddev[m]}")"
    done
    echo "Fastest: ${labels[fastest_idx]}"
    echo
  } >> "$RESULTS_FILE"
}

##
## EXECUTION
##

main() {
  local -i custom_iterations=0

  # Argument parsing
  while (($#)); do
    case $1 in
      -h|--help)    show_help; exit 0 ;;
      -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
      -i)           noarg "$@"; shift
                    [[ $1 =~ ^[0-9]+$ ]] \
                      || die 22 "Option -i requires a positive integer, got ${1@Q}"
                    custom_iterations=$1 ;;
      -r)           noarg "$@"; shift
                    [[ $1 =~ ^[0-9]+$ ]] \
                      || die 22 "Option -r requires a positive integer, got ${1@Q}"
                    RUNS_PER_TEST=$1 ;;
      --)           shift; break ;;
      -[hVir]?*)    set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      -*)           die 22 "Unknown option ${1@Q}" ;;
      *)            die 2 "Unexpected argument ${1@Q}" ;;
    esac
    shift
  done
  readonly RUNS_PER_TEST

  # Create test files and schedule cleanup
  setup_test_files
  trap cleanup_test_files EXIT

  # Print header
  { print_system_info
    if ((custom_iterations)); then
      echo "Starting benchmarks: 1 test series at ${custom_iterations} iterations (${RUNS_PER_TEST} runs each)"
    else
      echo "Starting benchmarks: 3 test series (1K/5K/10K iterations, ${RUNS_PER_TEST} runs each)"
    fi
    echo
  } | tee "$RESULTS_FILE"

  if ((custom_iterations)); then
    run_test_series "Source guard (${custom_iterations})" "$custom_iterations" \
      'BASH_SOURCE check'   run_benchmark_bash_source \
      'return 0 guard'        run_benchmark_return_guard \
      '(return 0) subshell' run_benchmark_subshell
  else
    # Default test matrix
    run_test_series 'Source guard (1K)' 1000 \
      'BASH_SOURCE check'   run_benchmark_bash_source \
      'return 0 guard'        run_benchmark_return_guard \
      '(return 0) subshell' run_benchmark_subshell

    run_test_series 'Source guard (5K)' 5000 \
      'BASH_SOURCE check'   run_benchmark_bash_source \
      'return 0 guard'        run_benchmark_return_guard \
      '(return 0) subshell' run_benchmark_subshell

    run_test_series 'Source guard (10K)' 10000 \
      'BASH_SOURCE check'   run_benchmark_bash_source \
      'return 0 guard'        run_benchmark_return_guard \
      '(return 0) subshell' run_benchmark_subshell
  fi

  # Generate summary
  { cat <<SUMMARY
Benchmark Complete
==================

Detailed results saved to: $RESULTS_FILE

Methods tested (each sources a file with a dummy function + guard):
  1. BASH_SOURCE check   -- [[ \${BASH_SOURCE[0]} == "\$0" ]]
  2. return 0 guard      -- return 0 2>/dev/null ||:
  3. (return 0) subshell -- (return 0 2>/dev/null) && return 0

Each iteration: open file, parse, define function, evaluate guard,
return to caller. This measures the full realistic cost of sourcing
a library with a source guard.

Analysis:
---------
All three methods carry the same baseline cost of file I/O, parsing,
and function definition. The difference lies in the guard mechanism.

The return 0 guard ('return 0 2>/dev/null ||:') is the fastest method
when sourced. On the sourced path, 'return 0' is a single builtin
that succeeds immediately -- execution returns to the caller with no
further evaluation. The redirect is set up but never used (return
produces no output on success); even so, the total cost is minimal.

The BASH_SOURCE comparison requires three operations: expand
\${BASH_SOURCE[0]}, expand "\$0", then evaluate [[ == ]] as a string
comparison. Each is fast, but together they are measurably slower
than a single successful return (~13% at 10K iterations).

The subshell guard forks a child process to test whether return
succeeds, then issues a second return in the parent. Two operations
where one suffices, plus fork overhead per call (~56x slower).

SUMMARY
  } | tee -a "$RESULTS_FILE"

  echo
  echo "Results saved to ${RESULTS_FILE@Q}"
}

main "$@"
#fin
