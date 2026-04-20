#!/usr/bin/bash
# shellcheck disable=SC2209,SC2034
# benchmark-path-resolve.sh - Performance comparison of directory-resolve idioms
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

##
## INITIALIZATION
##

# Script metadata
declare -r VERSION=1.0.0 # 2026-04-11 - Initial version
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
declare -a times_cd_pwd
declare -a times_realpath
declare -a times_cd_pwd_p
declare -a times_realpath_s

# Test target directory (a real, stable path with a few components)
declare -- TARGET_DIR=''

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
$SCRIPT_NAME $VERSION - Performance comparison of directory-resolve idioms

Measures the cost of resolving a directory path using four equivalent
idioms, split into two semantically-matched pairs.

Pair A -- Logical resolve (symlinks preserved):
  cd && pwd       \$(cd "\${dir:-.}" && pwd)
  realpath -s     \$(realpath -s -- "\${dir:-.}")

Pair B -- Canonical resolve (symlinks resolved):
  cd -P && pwd -P \$(cd -P -- "\${dir:-.}" && pwd -P)
  realpath        \$(realpath -- "\${dir:-.}")

Each comparison is fair: both members of a pair produce the same output
for the test target. Mixing pairs (e.g. 'cd && pwd' vs 'realpath') would
compare different semantics, not different implementations.

Target directory: a fresh mktemp -d tree with a symlink component
(\$TMPDIR/XXX/link/b/c where link -> a), removed on EXIT.

Default run: 6 test series (each pair at 100, 1K, 5K iterations).
With -i NUM: 2 test series (Pair A + Pair B) at NUM iterations.
Each test series repeats RUNS_PER_TEST times and reports mean/median/stddev.

Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -h, --help       Show this help and exit
  -V, --version    Show version and exit
  -i NUM           Replace default 100/1K/5K matrix with a single pass at NUM
  -r NUM           Runs per test series (default: 10)

Output:
  stdout           Live progress, per-series results, fastest method,
                   slowdown ratio (e.g. '8.2x slower')
  file             benchmark-results-path-resolve-YYYY-MM-DD_HH:MM:SS.txt
                   (system info, raw numbers, semantic notes)

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
realpath: $(realpath --version | head -n1)
Target dir: $TARGET_DIR
Runs per test: $RUNS_PER_TEST

SYSINFO
}

setup_target() {
  # Build a fresh mktemp -d tree with a symlink component so resolution
  # actually exercises logical vs canonical semantics (link -> a, then b/c).
  # cleanup_target() only removes the tree if it lives under /tmp.
  local -- candidate
  candidate=$(mktemp -d)
  mkdir -p "$candidate"/a/b/c
  ln -s a "$candidate"/link
  TARGET_DIR=$candidate/link/b/c
}

cleanup_target() {
  [[ -n $TARGET_DIR ]] || return 0
  local -- root=${TARGET_DIR%/link/*}
  [[ -d $root && $root == /tmp/* ]] && rm -rf -- "$root"
  return 0
}

run_cd_pwd() {
  # Logical resolve: target_dir=$(cd "${target_dir:-.}" && pwd)
  local -ri iterations=$1
  local -i i start end elapsed
  local -- target_dir=$TARGET_DIR result

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    result=$(cd "${target_dir:-.}" && pwd)
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_realpath() {
  # Canonical resolve: target_dir=$(realpath -- "${target_dir:-.}")
  local -ri iterations=$1
  local -i i start end elapsed
  local -- target_dir=$TARGET_DIR result

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    result=$(realpath -- "${target_dir:-.}")
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_cd_pwd_p() {
  # Physical resolve (symlink-canonical): cd -P "$dir" && pwd -P
  local -ri iterations=$1
  local -i i start end elapsed
  local -- target_dir=$TARGET_DIR result

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    result=$(cd -P -- "${target_dir:-.}" && pwd -P)
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

run_realpath_s() {
  # Logical-equivalent: realpath -s (no symlink expansion)
  local -ri iterations=$1
  local -i i start end elapsed
  local -- target_dir=$TARGET_DIR result

  start=${EPOCHREALTIME/./}

  i=-$iterations
  #bcscheck disable=BCS0505
  while ((1)); do
    ((i++)) || break
    result=$(realpath -s -- "${target_dir:-.}")
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))

  echo "$elapsed"
}

calculate_statistics() {
  local -n values=$1
  local -i sum=0 count=${#values[@]} val=0
  local -a sorted
  local -i mean median variance sum_sq_diff
  local -- stddev

  for val in "${values[@]}"; do
    sum+=val
  done
  mean=$((sum / count))

  mapfile -t sorted < <(printf '%s\n' "${values[@]}" | sort -n)
  if ((count % 2 == 0)); then
    median=$(( (sorted[count/2-1] + sorted[count/2]) / 2 ))
  else
    median=${sorted[count/2]}
  fi

  sum_sq_diff=0
  for val in "${values[@]}"; do
    ((sum_sq_diff += (val - mean) * (val - mean)))
  done
  variance=$((sum_sq_diff / count))
  stddev=$(awk "BEGIN {printf \"%.0f\", sqrt($variance)}")

  echo "$mean $median $stddev"
}

format_time() {
  local -i us=$1
  local -- seconds
  seconds=$(awk "BEGIN {printf \"%.3f\", $us/1000000}")
  echo "${seconds}s"
}

run_pair() {
  local -r test_name=$1
  local -ri iterations=$2
  local -r func_a=$3 label_a=$4
  local -r func_b=$5 label_b=$6
  local -n arr_a=$7
  local -n arr_b=$8
  local -i run
  local -- result

  echo "Running test: $test_name (iterations: $iterations, runs: $RUNS_PER_TEST)"
  echo '========================================================================'

  arr_a=()
  arr_b=()

  for ((run=1; run<=RUNS_PER_TEST; run+=1)); do
    printf '\rRun %2d/%d: Testing %s...           ' "$run" "$RUNS_PER_TEST" "$label_a"
    result=$($func_a "$iterations")
    arr_a+=("$result")

    printf '\rRun %2d/%d: Testing %s...           ' "$run" "$RUNS_PER_TEST" "$label_b"
    result=$($func_b "$iterations")
    arr_b+=("$result")
  done
  printf '\rRun %2d/%d: Complete!                                 \n' "$RUNS_PER_TEST" "$RUNS_PER_TEST"

  local -a stats_a stats_b
  IFS=' ' read -ra stats_a <<<"$(calculate_statistics arr_a)"
  IFS=' ' read -ra stats_b <<<"$(calculate_statistics arr_b)"

  echo
  echo "Results for: $test_name"
  echo '-------------------------------------------'
  printf '%-24s %15s %15s %15s\n' Construct Mean Median StdDev
  printf '%-24s %15s %15s %15s\n' "$label_a" \
    "$(format_time "${stats_a[0]}")" \
    "$(format_time "${stats_a[1]}")" \
    "$(format_time "${stats_a[2]}")"
  printf '%-24s %15s %15s %15s\n' "$label_b" \
    "$(format_time "${stats_b[0]}")" \
    "$(format_time "${stats_b[1]}")" \
    "$(format_time "${stats_b[2]}")"

  local -i faster_time slower_time diff_pct
  local -- faster_name slower_name ratio

  if ((stats_a[0] <= stats_b[0])); then
    faster_time=${stats_a[0]}
    faster_name=$label_a
    slower_time=${stats_b[0]}
    slower_name=$label_b
  else
    faster_time=${stats_b[0]}
    faster_name=$label_b
    slower_time=${stats_a[0]}
    slower_name=$label_a
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

  { echo "Test: $test_name (iterations: $iterations)"
    echo "$label_a - Mean: $(format_time "${stats_a[0]}"), Median: $(format_time "${stats_a[1]}"), StdDev: $(format_time "${stats_a[2]}")"
    echo "$label_b - Mean: $(format_time "${stats_b[0]}"), Median: $(format_time "${stats_b[1]}"), StdDev: $(format_time "${stats_b[2]}")"
    echo "Fastest: $faster_name (${ratio}x)"
    echo
  } >> "$RESULTS_FILE"
}

##
## EXECUTION
##

main() {
  local -i custom_iterations=0

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

  setup_target
  trap cleanup_target EXIT

  { print_system_info
    if ((custom_iterations)); then
      echo "Starting benchmarks: 2 test series at ${custom_iterations} iterations (${RUNS_PER_TEST} runs each)"
    else
      echo "Starting benchmarks: 6 test series (logical + canonical × 100/1K/5K, ${RUNS_PER_TEST} runs each)"
    fi
    echo
  } | tee "$RESULTS_FILE"

  if ((custom_iterations)); then
    run_pair \
      "Logical resolve (${custom_iterations})" \
      "$custom_iterations" \
      run_cd_pwd      'cd && pwd' \
      run_realpath_s  'realpath -s' \
      times_cd_pwd times_realpath_s

    run_pair \
      "Canonical resolve (${custom_iterations})" \
      "$custom_iterations" \
      run_cd_pwd_p  'cd -P && pwd -P' \
      run_realpath  'realpath' \
      times_cd_pwd_p times_realpath
  else
    # Logical (symlinks preserved)
    run_pair 'Logical resolve (100)'   100  run_cd_pwd 'cd && pwd' run_realpath_s 'realpath -s' times_cd_pwd times_realpath_s
    run_pair 'Logical resolve (1K)'    1000 run_cd_pwd 'cd && pwd' run_realpath_s 'realpath -s' times_cd_pwd times_realpath_s
    run_pair 'Logical resolve (5K)'    5000 run_cd_pwd 'cd && pwd' run_realpath_s 'realpath -s' times_cd_pwd times_realpath_s

    # Canonical (symlinks resolved)
    run_pair 'Canonical resolve (100)' 100  run_cd_pwd_p 'cd -P && pwd -P' run_realpath 'realpath' times_cd_pwd_p times_realpath
    run_pair 'Canonical resolve (1K)'  1000 run_cd_pwd_p 'cd -P && pwd -P' run_realpath 'realpath' times_cd_pwd_p times_realpath
    run_pair 'Canonical resolve (5K)'  5000 run_cd_pwd_p 'cd -P && pwd -P' run_realpath 'realpath' times_cd_pwd_p times_realpath
  fi

  { cat <<SUMMARY
Benchmark Complete
==================

Detailed results saved to: $RESULTS_FILE

Analysis:
---------
\$(cd "\$dir" && pwd) runs inside a subshell but uses only Bash builtins
(cd, pwd) -- no fork+exec of an external binary. The subshell itself is
a fork() but no execve() of a new program image.

\$(realpath -- "\$dir") also spawns a subshell for command substitution,
then fork+execs the GNU coreutils realpath binary -- paying the full
dynamic-loader + libc startup cost on every invocation.

Semantic note:
- 'cd && pwd' prints the LOGICAL path (\$PWD as entered, symlinks kept)
- 'realpath' (no flags) prints the CANONICAL path (all symlinks resolved)
- For a fair semantic comparison, use 'cd -P && pwd -P' vs 'realpath'
  (both canonical), or 'cd && pwd' vs 'realpath -s' (both logical).

Caching:
After the first realpath invocation, the kernel page cache, dentry/inode
cache, and Bash path hash keep the binary warm. These results therefore
reflect warm-cache conditions, favourable to realpath. Cold invocations
would show an even larger gap.

SUMMARY
  } | tee -a "$RESULTS_FILE"

  echo
  echo "Results saved to ${RESULTS_FILE@Q}"
}

main "$@"

#fin
