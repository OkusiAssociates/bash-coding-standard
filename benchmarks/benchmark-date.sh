#!/usr/bin/bash
# shellcheck disable=SC2209
# benchmark-date.sh - Performance comparison of date formatting methods
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

##
## INITIALIZATION
##

# Script metadata
declare -r VERSION=1.0.0 # 2026-04-06 - Initial version
declare -r SCRIPT_NAME=${0##*/}

# Configuration
declare -i RUNS_PER_TEST=10

# Output files
#shellcheck disable=SC2155
declare -r RESULTS_FILE=benchmark-results-date-"$(printf '%(%Y-%m-%d_%H-%M-%S)T')".txt

# Test results storage
declare -a times_printf_builtin
declare -a times_date_external

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

run_benchmark_printf() {
  # Benchmark: printf '%(%Y-%m-%d)T\n' "$EPOCHSECONDS" (builtin)
  local -ri iterations=$1
  local -i i
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  while ((1)); do
    ((i++)) || break
    printf '%(%Y-%m-%d)T\n' "$EPOCHSECONDS" >/dev/null
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_benchmark_date() {
  # Benchmark: date -d "@$EPOCHSECONDS" +'%Y-%m-%d' (external)
  local -ri iterations=$1
  local -i i
  local -- start end elapsed

  start=${EPOCHREALTIME/./}

  i=-$iterations
  while ((1)); do
    ((i++)) || break
    date -d "@$EPOCHSECONDS" +'%Y-%m-%d' >/dev/null
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
  for ((run=1; run<=RUNS_PER_TEST; run++)); do
    printf "\rRun %2d/%d: Testing printf builtin..." "$run" "$RUNS_PER_TEST"
    result=$($func_printf "$iterations")
    times_printf_builtin+=("$result")

    printf "\rRun %2d/%d: Testing date command...  " "$run" "$RUNS_PER_TEST"
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

show_help() {
  cat <<'HELP'
benchmark-date.sh - Performance comparison of date formatting methods

Compares the performance of:
  - printf '%(%Y-%m-%d)T' "$EPOCHSECONDS"   (Bash builtin)
  - date -d "@$EPOCHSECONDS" +'%Y-%m-%d'    (external command)

Usage: benchmark-date.sh [OPTIONS]

Options:
  -h, --help       Show this help message
  -V, --version    Show version information
  -i NUM           Override iteration count (default: 100/1K/5K matrix)
  -r NUM           Number of runs per test (default: 10)

Output:
  benchmark-results-date-TIMESTAMP.txt (detailed results with summary)

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
      -i) custom_iterations=${2:?'-i requires a number'}; shift ;;
      -r) RUNS_PER_TEST=${2:?'-r requires a number'}; shift ;;
      -[hV]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --) shift; break ;;
      -*) echo "$SCRIPT_NAME: unknown option: $1" >&2; show_help 2 ;;
      *)  echo "$SCRIPT_NAME: unexpected argument: $1" >&2; show_help 2 ;;
    esac
    shift
  done

  # Print header
  {
    print_system_info
    echo 'Starting benchmarks...'
    echo
    true
  } | tee "$RESULTS_FILE"

  if ((custom_iterations)); then
    run_test_series \
      "Date formatting (${custom_iterations})" \
      "$custom_iterations" \
      run_benchmark_printf \
      run_benchmark_date
  else
    # Default test matrix (small counts — date forks per call)
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
  fi

  # Generate summary
  { cat <<SUMMARY
Benchmark Complete
==================

Detailed results saved to: $RESULTS_FILE

Analysis:
---------
printf '%(%Y-%m-%d)T' uses Bash's built-in strftime — no fork, no exec.
date(1) forks a subprocess for every invocation.

For BCS guideline consideration:
- printf %()T is the preferred method for date formatting in Bash 5.2+
- date(1) is necessary only when printf %()T lacks a needed format

SUMMARY
  } | tee -a "$RESULTS_FILE"

  echo
  echo "Results saved to ${RESULTS_FILE@Q}"
}

main "$@"

#fin
