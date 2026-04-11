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

# Configuration
declare -i RUNS_PER_TEST=10

# Output files
#shellcheck disable=SC2155
declare -r RESULTS_FILE=benchmark-results-path-resolve-"$(printf '%(%F_%T)T')".txt

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

print_system_info() {
  cat <<EOF
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

EOF
}

setup_target() {
  # Use a real directory with a symlink in its path to exercise resolution.
  # Fallback to /tmp if the BCS source tree is unavailable.
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
  local -i sum=0 count=${#values[@]}
  local -a sorted
  local -- mean median stddev variance sum_sq_diff

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

show_help() {
  cat <<'HELP'
benchmark-path-resolve.sh - Performance comparison of directory-resolve idioms

Compares the performance of:
  - target_dir=$(cd "${target_dir:-.}" && pwd)          (subshell + builtins)
  - target_dir=$(realpath -- "${target_dir:-.}")        (fork+exec coreutils)

Also compares the symlink-canonical variants for a fair semantic match:
  - target_dir=$(cd -P -- "${target_dir:-.}" && pwd -P)
  - target_dir=$(realpath -s -- "${target_dir:-.}")     (logical, no -s symlink expansion)

Usage: benchmark-path-resolve.sh [OPTIONS]

Options:
  -h, --help       Show this help message
  -V, --version    Show version information
  -i NUM           Override iteration count (default: 100/1K/5K matrix)
  -r NUM           Number of runs per test (default: 10)

Output:
  benchmark-results-path-resolve-TIMESTAMP.txt

HELP
  exit "${1:-0}"
}

##
## EXECUTION
##

main() {
  local -i custom_iterations=0

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

  setup_target
  trap cleanup_target EXIT

  { print_system_info
    echo 'Starting benchmarks...'
    echo
    true
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
