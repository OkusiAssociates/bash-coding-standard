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

# Configuration
declare -i RUNS_PER_TEST=30

# Output files
#shellcheck disable=SC2155
declare -r RESULTS_FILE=benchmark-results-while-"$(printf '%(%F_%T)T')".txt

# Test results storage
declare -a times_while_double_paren
declare -a times_while_colon
declare -a times_while_true

##
## FUNCTIONS
##

print_system_info() {
  cat <<EOF
System Information
==================
Date: $(date -Iseconds)
Hostname: $(hostname)
Bash Version: $BASH_VERSION
CPU: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
Kernel: $(uname -r)
Runs per test: $RUNS_PER_TEST

EOF
}

run_benchmark_double_paren() {
  # Benchmark: while ((1)); do ... done
  local -ri iterations=$1
  local -i i
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
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
  local -i sum=0 count=${#values[@]}
  local -a sorted
  local -- mean median stddev variance sum_sq_diff

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
  for ((run=1; run<=RUNS_PER_TEST; run++)); do
    printf "\rRun %2d/%d: Testing while ((1))..." "$run" "$RUNS_PER_TEST"
    result=$($func_double_paren "$iterations")
    times_while_double_paren+=("$result")

    printf "\rRun %2d/%d: Testing while :...   " "$run" "$RUNS_PER_TEST"
    result=$($func_colon "$iterations")
    times_while_colon+=("$result")

    printf "\rRun %2d/%d: Testing while true..." "$run" "$RUNS_PER_TEST"
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
  printf "%-20s %15s %15s %15s\n" "while :" \
    "$(format_time "${stats_colon[0]}")" \
    "$(format_time "${stats_colon[1]}")" \
    "$(format_time "${stats_colon[2]}")"
  printf "%-20s %15s %15s %15s\n" "while true" \
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

show_help() {
  cat <<'HELP'
benchmark-while-loops.sh - Performance comparison of while loop constructs

Compares the performance of:
  - while ((1)); do ... done
  - while :; do ... done
  - while true; do ... done

Usage: benchmark-while-loops.sh [OPTIONS]

Options:
  -h, --help       Show this help message
  -V, --version    Show version information
  -i NUM           Override iteration count (default: 100K/1M/5M matrix)
  -r NUM           Number of runs per test (default: 30)

Output:
  benchmark-results-while-TIMESTAMP.txt (detailed results with summary)

HELP
  exit "${1:-0}"
}

##
## EXECUTION
##

main() {
  local -i custom_iterations=0

  # Argument parsing
  while (($#)); do
    case $1 in
      -h|--help)    show_help 0 ;;
      -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
      -i)           custom_iterations=${2:?'-i requires a number'}; shift ;;
      -r)           RUNS_PER_TEST=${2:?'-r requires a number'}; shift ;;
      -[irhV]?*)    set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)           shift; break ;;
      -*)           echo "$SCRIPT_NAME: unknown option: $1" >&2; show_help 2 ;;
      *)            echo "$SCRIPT_NAME: unexpected argument: $1" >&2; show_help 2 ;;
    esac
    shift
  done

  # Print header
  { print_system_info
    echo 'Starting benchmarks...'
    echo
    true
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

Analysis and Recommendation:
----------------------------
See results above for performance comparison.

For BCS guideline consideration:
- If while ((1)) is consistently faster: Recommend for performance-critical code
- If while : is faster or equivalent: Recommend for better POSIX compatibility
- If difference is < 5%: Recommend while : for readability and tradition

SUMMARY
  } | tee -a "$RESULTS_FILE"

  echo
  echo "Results saved to ${RESULTS_FILE@Q}"
}

main "$@"

#fin
