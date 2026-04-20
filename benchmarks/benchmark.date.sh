#!/usr/bin/bash
# shellcheck disable=SC2209,SC2034
# benchmark-date.sh - Performance comparison of date formatting methods
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

##
## INITIALIZATION
##

# Script metadata
declare -r VERSION=1.0.0 # 2026-04-06 - Initial version
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
declare -a times_printf_builtin
declare -a times_date_external

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
$SCRIPT_NAME $VERSION - Performance comparison of date formatting methods

Measures the cost of formatting the current date using Bash's printf
builtin versus the external date(1) command, in two usage patterns.

Method pairs:
  Pair A -- discard output (written to /dev/null)
    printf '%(%F)T' "\$EPOCHSECONDS"
    date -d "@\$EPOCHSECONDS" +'%F'

  Pair B -- capture into a variable
    printf -v var '%(%F)T'
    var=\$(date +'%F')

Pair A isolates the formatting cost. Pair B adds the subshell overhead
that date(1) requires to get its output into a variable.

Default run: 6 test series
  Pair A at 100, 1000, 5000 iterations
  Pair B at 100, 1000, 5000 iterations

With -i NUM: 2 test series (Pair A + Pair B) at NUM iterations each.

Iteration counts are deliberately small -- date(1) forks a process
per call, so even 5K iterations costs several seconds on commodity
hardware. Each test series repeats RUNS_PER_TEST times.

Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -h, --help       Show this help and exit
  -V, --version    Show version and exit
  -i NUM           Replace default 100/1K/5K matrix with a single pass at NUM
  -r NUM           Runs per test series (default: 10)

Output:
  stdout           Live progress, per-series results, fastest method,
                   slowdown ratio (e.g. '12.4x slower')
  file             benchmark-results-date-YYYY-MM-DD_HH:MM:SS.txt
                   (system info, raw numbers, analysis notes)

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

run_benchmark_printf() {
  # Benchmark: printf '%(%F)T' "$EPOCHSECONDS" (builtin)
  local -ri iterations=$1
  local -i i start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    printf '%(%F)T' "$EPOCHSECONDS" >/dev/null
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_benchmark_date() {
  # Benchmark: date -d "@$EPOCHSECONDS" +'%F' (external)
  local -ri iterations=$1
  local -i i
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    date -d "@$EPOCHSECONDS" +'%F' >/dev/null
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_benchmark_printf_var() {
  # Benchmark: printf -v var '%(%F)T' (builtin, no subshell)
  local -ri iterations=$1
  local -i i start end elapsed
  local -- var

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    printf -v var '%(%F)T'
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_benchmark_date_var() {
  # Benchmark: var=$(date +'%F') (external + subshell)
  local -ri iterations=$1
  local -i i
  local -- var start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    var=$(date +'%F')
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
  mapfile -t sorted < <(printf '%s\n' "${values[@]}" | sort -n)
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
  local -r func_printf=$3
  local -r func_date=$4
  local -i run
  local -- result

  echo "Running test: $test_name (iterations: $iterations, runs: $RUNS_PER_TEST)"
  echo '========================================================================'

  # Clear result arrays
  times_printf_builtin=()
  times_date_external=()

  # Run benchmarks
  for ((run=1; run<=RUNS_PER_TEST; run+=1)); do
    printf '\rRun %2d/%d: Testing printf builtin...' "$run" "$RUNS_PER_TEST"
    result=$($func_printf "$iterations")
    times_printf_builtin+=("$result")

    printf '\rRun %2d/%d: Testing date command...  ' "$run" "$RUNS_PER_TEST"
    result=$($func_date "$iterations")
    times_date_external+=("$result")
  done
  printf '\rRun %2d/%d: Complete!                  \n' "$RUNS_PER_TEST" "$RUNS_PER_TEST"

  # Calculate statistics
  local -a stats_printf stats_date
  IFS=' ' read -ra stats_printf <<<"$(calculate_statistics times_printf_builtin)"
  IFS=' ' read -ra stats_date <<<"$(calculate_statistics times_date_external)"

  # Display results
  echo
  echo "Results for: $test_name"
  echo '-------------------------------------------'
  printf '%-20s %15s %15s %15s\n' Construct Mean Median StdDev
  printf '%-20s %15s %15s %15s\n' 'printf %()T' \
    "$(format_time "${stats_printf[0]}")" \
    "$(format_time "${stats_printf[1]}")" \
    "$(format_time "${stats_printf[2]}")"
  printf '%-20s %15s %15s %15s\n' 'date command' \
    "$(format_time "${stats_date[0]}")" \
    "$(format_time "${stats_date[1]}")" \
    "$(format_time "${stats_date[2]}")"

  # Calculate speedup
  local -i faster_time slower_time diff_pct
  local -- faster_name slower_name ratio

  if ((stats_printf[0] <= stats_date[0])); then
    faster_time=${stats_printf[0]}
    faster_name='printf %()T'
    slower_time=${stats_date[0]}
    slower_name='date command'
  else
    faster_time=${stats_date[0]}
    faster_name='date command'
    slower_time=${stats_printf[0]}
    slower_name='printf %()T'
  fi

  # Guard against degenerate 0 µs measurements (would raise SIGFPE below)
  ((faster_time)) || faster_time=1
  diff_pct=$(( (slower_time - faster_time) * 100 / faster_time ))
  ratio=$(awk "BEGIN {printf \"%.1f\", $slower_time/$faster_time}")

  printf '\n◉ Fastest: %s\n' "$faster_name"
  printf '  - %s is %sx slower (%d%%)\n' "$slower_name" "$ratio" "$diff_pct"

  echo
  echo '========================================================================'
  echo

  # Save to results file
  { echo "Test: $test_name (iterations: $iterations)"
    echo "printf %()T  - Mean: $(format_time "${stats_printf[0]}"), Median: $(format_time "${stats_printf[1]}"), StdDev: $(format_time "${stats_printf[2]}")"
    echo "date command - Mean: $(format_time "${stats_date[0]}"), Median: $(format_time "${stats_date[1]}"), StdDev: $(format_time "${stats_date[2]}")"
    echo "Fastest: $faster_name (${ratio}x)"
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

  # Print header
  { print_system_info
    if ((custom_iterations)); then
      echo "Starting benchmarks: 2 test series at ${custom_iterations} iterations (${RUNS_PER_TEST} runs each)"
    else
      echo "Starting benchmarks: 6 test series (format + var-assign × 100/1K/5K, ${RUNS_PER_TEST} runs each)"
    fi
    echo
  } | tee "$RESULTS_FILE"

  if ((custom_iterations)); then
    run_test_series \
      "Date formatting (${custom_iterations})" \
      "$custom_iterations" \
      run_benchmark_printf \
      run_benchmark_date

    run_test_series \
      "Variable assignment (${custom_iterations})" \
      "$custom_iterations" \
      run_benchmark_printf_var \
      run_benchmark_date_var
  else
    # Default test matrix (small counts -- date forks per call)
    run_test_series \
      'Date formatting (100)' \
      100 \
      run_benchmark_printf \
      run_benchmark_date

    run_test_series \
      'Date formatting (1K)' \
      1000 \
      run_benchmark_printf \
      run_benchmark_date

    run_test_series \
      'Date formatting (5K)' \
      5000 \
      run_benchmark_printf \
      run_benchmark_date

    run_test_series \
      'Variable assignment (100)' \
      100 \
      run_benchmark_printf_var \
      run_benchmark_date_var

    run_test_series \
      'Variable assignment (1K)' \
      1000 \
      run_benchmark_printf_var \
      run_benchmark_date_var

    run_test_series \
      'Variable assignment (5K)' \
      5000 \
      run_benchmark_printf_var \
      run_benchmark_date_var
  fi

  # Generate summary
  { cat <<SUMMARY
Benchmark Complete
==================

Detailed results saved to: $RESULTS_FILE

Analysis:
---------
printf '%(%F)T' uses Bash's built-in strftime -- no fork, no exec.
date(1) forks a subprocess for every invocation.

For BCS guideline consideration:
- printf %()T is the preferred method for date formatting in Bash 5.2+
- date(1) is necessary only when printf %()T lacks a needed format

Note on caching:
After the first date(1) invocation, the kernel page cache, dentry/inode
cache, and Bash path hash table keep the binary warm -- subsequent calls
avoid page faults and PATH lookups. These results therefore reflect
warm-cache conditions, favourable to date(1). Cold invocations (e.g.,
first call in a new shell) would show an even larger gap.

SUMMARY
  } | tee -a "$RESULTS_FILE"

  echo
  echo "Results saved to ${RESULTS_FILE@Q}"
}

main "$@"

#fin
