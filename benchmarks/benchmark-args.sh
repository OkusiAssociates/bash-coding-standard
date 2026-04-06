#!/usr/bin/bash
# shellcheck disable=SC2209,SC2034
# benchmark-args.sh - Performance comparison of argument processing methods
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
declare -r RESULTS_FILE=benchmark-results-args-"$(printf '%(%F_%T)T')".txt

# Test argument arrays
declare -ra ARGS_SHORT=(-v -q -n -f -D -x -c -o /tmp/out -p 8080 -l info)
declare -ra ARGS_LONG=(--verbose --quiet --dry-run --force --debug --xtrace --color --output /tmp/out --port 8080 --level info)
declare -ra ARGS_BUNDLED=(-vqnfDxc -o /tmp/out -p 8080 -l info)

# Test results storage
declare -a times_0 times_1 times_2 times_3

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

run_benchmark_bcs() {
  # Benchmark: BCS while/case (BCS0801 + BCS0805 bundling)
  local -ri iterations=$1
  shift
  local -a args=("$@")
  local -i i start end
  local -i _v _q _n _f _D _x _c
  local -- _o _p _l

  start=${EPOCHREALTIME/./}
  i=-$iterations
  while ((1)); do
    ((i++)) || break
    _v=0 _q=0 _n=0 _f=0 _D=0 _x=0 _c=0
    _o='' _p='' _l=''
    set -- "${args[@]}"
    while (($#)); do case $1 in
      -v|--verbose) _v=1 ;;
      -q|--quiet)   _q=1 ;;
      -n|--dry-run) _n=1 ;;
      -f|--force)   _f=1 ;;
      -D|--debug)   _D=1 ;;
      -x|--xtrace)  _x=1 ;;
      -c|--color)   _c=1 ;;
      -o|--output)  shift; _o=$1 ;;
      -p|--port)    shift; _p=$1 ;;
      -l|--level)   shift; _l=$1 ;;
      -[vqnfDxcopl]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --) shift; break ;;
      -*) break ;;
      *)  break ;;
    esac; shift; done
  done
  end=${EPOCHREALTIME/./}
  echo $((end - start))
}

run_benchmark_getopts() {
  # Benchmark: getopts builtin (short options only)
  local -ri iterations=$1
  shift
  local -a args=("$@")
  local -i i start end
  local -i _v _q _n _f _D _x _c
  local -- _o _p _l _opt

  start=${EPOCHREALTIME/./}
  i=-$iterations
  while ((1)); do
    ((i++)) || break
    _v=0 _q=0 _n=0 _f=0 _D=0 _x=0 _c=0
    _o='' _p='' _l=''
    set -- "${args[@]}"
    OPTIND=1
    while getopts 'vqnfDxco:p:l:' _opt; do
      case $_opt in
        v) _v=1 ;;
        q) _q=1 ;;
        n) _n=1 ;;
        f) _f=1 ;;
        D) _D=1 ;;
        x) _x=1 ;;
        c) _c=1 ;;
        o) _o=$OPTARG ;;
        p) _p=$OPTARG ;;
        l) _l=$OPTARG ;;
        *) break ;;
      esac
    done
  done
  end=${EPOCHREALTIME/./}
  echo $((end - start))
}

run_benchmark_getopt() {
  # Benchmark: GNU getopt (external command, forks per call)
  local -ri iterations=$1
  shift
  local -a args=("$@")
  local -i i start end
  local -i _v _q _n _f _D _x _c
  local -- _o _p _l _parsed

  start=${EPOCHREALTIME/./}
  i=-$iterations
  while ((1)); do
    ((i++)) || break
    _v=0 _q=0 _n=0 _f=0 _D=0 _x=0 _c=0
    _o='' _p='' _l=''
    _parsed=$(getopt -o 'vqnfDxco:p:l:' \
      -l 'verbose,quiet,dry-run,force,debug,xtrace,color,output:,port:,level:' \
      -- "${args[@]}") || break
    eval set -- "$_parsed"
    while (($#)); do case $1 in
      -v|--verbose) _v=1 ;;
      -q|--quiet)   _q=1 ;;
      -n|--dry-run) _n=1 ;;
      -f|--force)   _f=1 ;;
      -D|--debug)   _D=1 ;;
      -x|--xtrace)  _x=1 ;;
      -c|--color)   _c=1 ;;
      -o|--output)  _o=$2; shift ;;
      -p|--port)    _p=$2; shift ;;
      -l|--level)   _l=$2; shift ;;
      --) shift; break ;;
    esac; shift; done
  done
  end=${EPOCHREALTIME/./}
  echo $((end - start))
}

run_benchmark_simple() {
  # Benchmark: Simple while/case (no bundling)
  local -ri iterations=$1
  shift
  local -a args=("$@")
  local -i i start end
  local -i _v _q _n _f _D _x _c
  local -- _o _p _l

  start=${EPOCHREALTIME/./}
  i=-$iterations
  while ((1)); do
    ((i++)) || break
    _v=0 _q=0 _n=0 _f=0 _D=0 _x=0 _c=0
    _o='' _p='' _l=''
    set -- "${args[@]}"
    while [[ $# -gt 0 ]]; do
      case $1 in
        -v|--verbose) _v=1; shift ;;
        -q|--quiet)   _q=1; shift ;;
        -n|--dry-run) _n=1; shift ;;
        -f|--force)   _f=1; shift ;;
        -D|--debug)   _D=1; shift ;;
        -x|--xtrace)  _x=1; shift ;;
        -c|--color)   _c=1; shift ;;
        -o|--output)  shift; _o=$1; shift ;;
        -p|--port)    shift; _p=$1; shift ;;
        -l|--level)   shift; _l=$1; shift ;;
        --) shift; break ;;
        *)  break ;;
      esac
    done
  done
  end=${EPOCHREALTIME/./}
  echo $((end - start))
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
  local -r args_var=$3
  shift 3

  # Parse label/function pairs
  local -a labels=() funcs=()
  while (($#)); do
    labels+=("$1"); funcs+=("$2")
    shift 2
  done
  local -ri method_count=${#labels[@]}

  local -n test_args=$args_var

  echo "Running test: $test_name (iterations: $iterations, runs: $RUNS_PER_TEST)"
  echo '========================================================================'

  # Clear timing arrays
  times_0=() times_1=() times_2=() times_3=()

  # Run benchmarks
  local -i run m
  local -- result
  for ((run=1; run<=RUNS_PER_TEST; run+=1)); do
    for ((m=0; m<method_count; m+=1)); do
      printf '\rRun %2d/%d: Testing %s...' "$run" "$RUNS_PER_TEST" "${labels[m]}"
      result=$("${funcs[m]}" "$iterations" "${test_args[@]}")
      case $m in
        0) times_0+=("$result") ;;
        1) times_1+=("$result") ;;
        2) times_2+=("$result") ;;
        3) times_3+=("$result") ;;
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
  printf '%-20s %12s %12s %12s\n' Construct Mean Median StdDev

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

show_help() {
  cat <<'HELP'
benchmark-args.sh - Performance comparison of argument processing methods

Compares the performance of:
  1. BCS while/case   -- BCS0801 pattern with BCS0805 bundling
  2. getopts           -- POSIX builtin (short options only)
  3. GNU getopt        -- external command (fork + exec per call)
  4. Simple while/case -- common tutorial pattern, no bundling

Usage: benchmark-args.sh [OPTIONS]

Options:
  -h, --help       Show this help message
  -V, --version    Show version information
  -i NUM           Override iteration count (default: 1K/5K matrix)
  -r NUM           Number of runs per test (default: 10)

Output:
  benchmark-results-args-TIMESTAMP.txt (detailed results with summary)

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
      -*)           >&2 echo "$SCRIPT_NAME: unknown option ${1@Q}"; show_help 2 ;;
      *)            >&2 echo "$SCRIPT_NAME: unexpected argument ${1@Q}"; show_help 2 ;;
    esac
    shift
  done
  readonly RUNS_PER_TEST

  # Print header
  { print_system_info
    echo 'Starting benchmarks...'
    echo
    true
  } | tee "$RESULTS_FILE"

  if ((custom_iterations)); then
    # All 3 scenarios at custom iteration count
    run_test_series "Short options (${custom_iterations})" "$custom_iterations" ARGS_SHORT \
      'BCS while/case' run_benchmark_bcs \
      'getopts'        run_benchmark_getopts \
      'GNU getopt'     run_benchmark_getopt \
      'Simple case'    run_benchmark_simple

    run_test_series "Long options (${custom_iterations})" "$custom_iterations" ARGS_LONG \
      'BCS while/case' run_benchmark_bcs \
      'GNU getopt'     run_benchmark_getopt \
      'Simple case'    run_benchmark_simple

    run_test_series "Bundled short (${custom_iterations})" "$custom_iterations" ARGS_BUNDLED \
      'BCS while/case' run_benchmark_bcs \
      'getopts'        run_benchmark_getopts \
      'GNU getopt'     run_benchmark_getopt
  else
    # Scenario 1: Short options -- all 4 methods
    run_test_series 'Short options (1K)' 1000 ARGS_SHORT \
      'BCS while/case' run_benchmark_bcs \
      'getopts'        run_benchmark_getopts \
      'GNU getopt'     run_benchmark_getopt \
      'Simple case'    run_benchmark_simple

    run_test_series 'Short options (5K)' 5000 ARGS_SHORT \
      'BCS while/case' run_benchmark_bcs \
      'getopts'        run_benchmark_getopts \
      'GNU getopt'     run_benchmark_getopt \
      'Simple case'    run_benchmark_simple

    # Scenario 2: Long options -- 3 methods (no getopts)
    run_test_series 'Long options (1K)' 1000 ARGS_LONG \
      'BCS while/case' run_benchmark_bcs \
      'GNU getopt'     run_benchmark_getopt \
      'Simple case'    run_benchmark_simple

    run_test_series 'Long options (5K)' 5000 ARGS_LONG \
      'BCS while/case' run_benchmark_bcs \
      'GNU getopt'     run_benchmark_getopt \
      'Simple case'    run_benchmark_simple

    # Scenario 3: Bundled short options -- 3 methods (no simple)
    run_test_series 'Bundled short (1K)' 1000 ARGS_BUNDLED \
      'BCS while/case' run_benchmark_bcs \
      'getopts'        run_benchmark_getopts \
      'GNU getopt'     run_benchmark_getopt

    run_test_series 'Bundled short (5K)' 5000 ARGS_BUNDLED \
      'BCS while/case' run_benchmark_bcs \
      'getopts'        run_benchmark_getopts \
      'GNU getopt'     run_benchmark_getopt
  fi

  # Generate summary
  { cat <<SUMMARY
Benchmark Complete
==================

Detailed results saved to: $RESULTS_FILE

Methods tested:
  1. BCS while/case    -- standard BCS0801 pattern with BCS0805 bundling
  2. getopts           -- POSIX builtin (short options only)
  3. GNU getopt        -- external command (fork + exec per call)
  4. Simple while/case -- common tutorial pattern, no bundling

Capability matrix:
  Feature              BCS    getopts  getopt  Simple
  Long options          ✓       ✗        ✓       ✓
  Option bundling       ✓       ✓        ✓       ✗
  -oFILE attached arg   ✗       ✓        ✓       ✗
  Pure Bash (no fork)   ✓       ✓        ✗       ✓

Analysis:
---------
The three pure-Bash methods (BCS, getopts, simple) all operate in
microsecond range -- the difference between them is negligible in
real-world scripts that parse arguments once at startup.

GNU getopt forks an external process per invocation, adding ~1-3ms
overhead. For a single parse at script startup this is invisible,
but it shows in tight loops and highlights the architectural cost.

BCS while/case offers the best balance of capability and performance:
long options, bundling, pure Bash, and explicit control flow.

Note on simple while/case:
The simple pattern lacks option bundling (-vqn). In practice,
programmers either omit bundling entirely (frustrating users who
expect it) or bolt on ad-hoc solutions -- typically fragile regex
splits or nested loops that introduce subtle bugs with argument-
taking options. The BCS bundling line (BCS0805) solves this with a
single, well-tested and fast pattern.

Note on BCS argument style:
BCS does not support -oFILE (attached argument) forms. Arguments
must always be space-separated: -o FILE. This is a deliberate
simplicity trade-off -- the bundling disaggregation pattern treats
-oFILE as -o -F -I -L -E, which would be incorrect.

For BCS guideline consideration:
- The while/case pattern is the recommended approach (BCS0801)
- getopts is acceptable for very simple scripts needing only short options
- GNU getopt should be avoided

SUMMARY
  } | tee -a "$RESULTS_FILE"

  echo
  echo "Results saved to ${RESULTS_FILE@Q}"
}

main "$@"
#fin
