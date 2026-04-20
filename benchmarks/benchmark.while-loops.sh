#!/usr/bin/bash
# shellcheck disable=SC2209
# benchmark-while-loops.sh - Performance comparison of while loop constructs
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

##
## INITIALIZATION
##

# Script metadata
declare -r VERSION=1.1.0 # 2025-10-20 - Added while true comparison
declare -r SCRIPT_NAME=${0##*/}

# Test name derived from script filename: 'benchmark.X.sh' → 'X'
declare -- TESTNAME=${SCRIPT_NAME#benchmark.}
TESTNAME=${TESTNAME%.sh}
declare -r TESTNAME

# Configuration
declare -i RUNS_PER_TEST=30

# Output files
#shellcheck disable=SC2155
declare -r RESULTS_FILE=${TESTNAME}_results_$(printf '%(%F_%T)T').txt

# Test results storage
declare -a times_while_double_paren
declare -a times_while_colon
declare -a times_while_true

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
$SCRIPT_NAME $VERSION - Performance comparison of while loop constructs

Measures pure loop overhead (and loop + arithmetic work) for three
equivalent infinite-loop constructs.

Constructs tested:
  while ((1)); do ... done   arithmetic-eval infinite loop
  while :;    do ... done    null-builtin infinite loop
  while true; do ... done    external/builtin-alias infinite loop

Each construct is exercised in two loop bodies:
  empty      ((i++)) || break          (pure loop overhead)
  with-work  ((i++)) || break; sum+=i  (loop + arithmetic assignment)

Default run: 4 test series
  Empty loop at 100K, 1M, 2M iterations
  Loop with arithmetic work at 1M iterations

With -i NUM: 2 test series (empty + with-work) at NUM iterations each.

Each test series repeats RUNS_PER_TEST times and reports mean/median/stddev.

Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -h, --help       Show this help and exit
  -V, --version    Show version and exit
  -i NUM           Replace default matrix with empty + with-work at NUM
  -r NUM           Runs per test series (default: 30)

Output:
  stdout           Live progress, per-series results, fastest construct
  file             benchmark-results-while-YYYY-MM-DD_HH:MM:SS.txt
                   (system info, raw numbers, summary)

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

run_benchmark_double_paren() {
  # Benchmark: while ((1)); do ... done
  local -ri iterations=$1
  local -i i
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_benchmark_colon() {
  # Benchmark: while :; do ... done
  local -ri iterations=$1
  local -i i
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while :; do
    ((i++)) || break
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_benchmark_true() {
  # Benchmark: while true; do ... done
  local -ri iterations=$1
  local -i i
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while true; do
    ((i++)) || break
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_benchmark_double_paren_with_work() {
  # Benchmark: while ((1)) with work inside loop
  local -ri iterations=$1
  local -i i sum
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  sum=0
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    sum+=i
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_benchmark_colon_with_work() {
  # Benchmark: while : with work inside loop
  local -ri iterations=$1
  local -i i sum
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  sum=0
  #bcscheck disable=BCS0505
  while :; do
    ((i++)) || break
    sum+=i
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_benchmark_true_with_work() {
  # Benchmark: while true with work inside loop
  local -ri iterations=$1
  local -i i sum
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  sum=0
  #bcscheck disable=BCS0505
  while true; do
    ((i++)) || break
    sum+=i
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
  local -r func_double_paren=$3
  local -r func_colon=$4
  local -r func_true=$5
  local -i run
  local -- result

  echo "Running test: $test_name (iterations: $iterations, runs: $RUNS_PER_TEST)"
  echo '========================================================================'

  # Clear result arrays
  times_while_double_paren=()
  times_while_colon=()
  times_while_true=()

  # Run benchmarks
  #bcscheck disable=BCS0503,BCS0505
  for ((run=1; run<=RUNS_PER_TEST; run++)); do
    printf '\rRun %2d/%d: Testing while ((1))...' "$run" "$RUNS_PER_TEST"
    result=$($func_double_paren "$iterations")
    times_while_double_paren+=("$result")

    printf '\rRun %2d/%d: Testing while :...   ' "$run" "$RUNS_PER_TEST"
    result=$($func_colon "$iterations")
    times_while_colon+=("$result")

    printf '\rRun %2d/%d: Testing while true...' "$run" "$RUNS_PER_TEST"
    result=$($func_true "$iterations")
    times_while_true+=("$result")
  done
  printf '\rRun %2d/%d: Complete!                \n' "$RUNS_PER_TEST" "$RUNS_PER_TEST"

  # Calculate statistics
  local -a stats_dp stats_colon stats_true
  IFS=' ' read -ra stats_dp <<<"$(calculate_statistics times_while_double_paren)"
  IFS=' ' read -ra stats_colon <<<"$(calculate_statistics times_while_colon)"
  IFS=' ' read -ra stats_true <<<"$(calculate_statistics times_while_true)"

  # Display results
  echo
  echo "Results for: $test_name"
  echo '-------------------------------------------'
  printf '%-20s %15s %15s %15s\n' Construct Mean Median StdDev
  printf '%-20s %15s %15s %15s\n' "while ((1))" \
    "$(format_time "${stats_dp[0]}")" \
    "$(format_time "${stats_dp[1]}")" \
    "$(format_time "${stats_dp[2]}")"
  printf '%-20s %15s %15s %15s\n' 'while :' \
    "$(format_time "${stats_colon[0]}")" \
    "$(format_time "${stats_colon[1]}")" \
    "$(format_time "${stats_colon[2]}")"
  printf '%-20s %15s %15s %15s\n' 'while true' \
    "$(format_time "${stats_true[0]}")" \
    "$(format_time "${stats_true[1]}")" \
    "$(format_time "${stats_true[2]}")"

  # Find fastest construct
  local -i fastest_time=${stats_dp[0]}
  local -- fastest_name='while ((1))'

  if ((stats_colon[0] < fastest_time)); then
    fastest_time=${stats_colon[0]}
    fastest_name='while :'
  fi

  if ((stats_true[0] < fastest_time)); then
    fastest_time=${stats_true[0]}
    fastest_name='while true'
  fi

  # Guard against degenerate 0 µs measurements (would raise SIGFPE below)
  ((fastest_time)) || fastest_time=1

  # Calculate percentage differences from fastest
  local -i diff_dp diff_colon diff_true
  diff_dp=$(( (stats_dp[0] - fastest_time) * 100 / fastest_time ))
  diff_colon=$(( (stats_colon[0] - fastest_time) * 100 / fastest_time ))
  diff_true=$(( (stats_true[0] - fastest_time) * 100 / fastest_time ))

  printf "\n◉ Fastest: %s\n" "$fastest_name"
  if [[ $fastest_name != 'while ((1))' ]]; then
    printf '  - while ((1)) is %d%% slower\n' "$diff_dp"
  fi
  if [[ $fastest_name != 'while :' ]]; then
    printf '  - while : is %d%% slower\n' "$diff_colon"
  fi
  if [[ $fastest_name != 'while true' ]]; then
    printf '  - while true is %d%% slower\n' "$diff_true"
  fi

  echo
  echo "========================================================================"
  echo

  # Save to results file
  { echo "Test: $test_name (iterations: $iterations)"
    echo "while ((1)) - Mean: $(format_time "${stats_dp[0]}"), Median: $(format_time "${stats_dp[1]}"), StdDev: $(format_time "${stats_dp[2]}")"
    echo "while :     - Mean: $(format_time "${stats_colon[0]}"), Median: $(format_time "${stats_colon[1]}"), StdDev: $(format_time "${stats_colon[2]}")"
    echo "while true  - Mean: $(format_time "${stats_true[0]}"), Median: $(format_time "${stats_true[1]}"), StdDev: $(format_time "${stats_true[2]}")"
    echo "Fastest: $fastest_name"
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
      echo "Starting benchmarks: 4 test series (empty @ 100K/1M/2M + with-work @ 1M, ${RUNS_PER_TEST} runs each)"
    fi
    echo
  } | tee "$RESULTS_FILE"

  if ((custom_iterations)); then
    # Single iteration count: one empty-loop test + one with-work test
    run_test_series \
      "Empty loop with counter break (${custom_iterations})" \
      "$custom_iterations" \
      run_benchmark_double_paren \
      run_benchmark_colon \
      run_benchmark_true

    run_test_series \
      "Loop with arithmetic work (${custom_iterations})" \
      "$custom_iterations" \
      run_benchmark_double_paren_with_work \
      run_benchmark_colon_with_work \
      run_benchmark_true_with_work
  else
    # Default test matrix
    run_test_series \
      'Empty loop with counter break (100K)' \
      100000 \
      run_benchmark_double_paren \
      run_benchmark_colon \
      run_benchmark_true

    run_test_series \
      'Empty loop with counter break (1M)' \
      1000000 \
      run_benchmark_double_paren \
      run_benchmark_colon \
      run_benchmark_true

    run_test_series \
      'Empty loop with counter break (2M)' \
      2000000 \
      run_benchmark_double_paren \
      run_benchmark_colon \
      run_benchmark_true

    run_test_series \
      'Loop with arithmetic work (1M)' \
      1000000 \
      run_benchmark_double_paren_with_work \
      run_benchmark_colon_with_work \
      run_benchmark_true_with_work
  fi

  # Generate summary
  { cat <<SUMMARY
Benchmark Complete
==================

Detailed results saved to: $RESULTS_FILE

Construct notes:
  while ((1))  Pure Bash arithmetic; no command lookup.
  while :      Null builtin; POSIX-portable, traditional idiom.
  while true   'true' is a Bash builtin but goes through command lookup.

Analysis:
---------
All three are pure-Bash constructs. On modern Bash the difference per
iteration is in nanoseconds -- visible only at million-iteration scale.
See the per-series results above for the actual numbers on this host.

BCS guidance:
  - Any of the three is acceptable for clarity.
  - Prefer while ((1)) when the loop contains arithmetic already.
  - Prefer while : for the shortest, most traditional idiom.
  - while true is acceptable but offers no advantage over while :.

SUMMARY
  } | tee -a "$RESULTS_FILE"

  echo
  echo "Results saved to ${RESULTS_FILE@Q}"
}

main "$@"

#fin
