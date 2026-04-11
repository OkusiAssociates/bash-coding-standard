#!/usr/bin/bash
# shellcheck disable=SC2209,SC2034
# benchmark-script-path.sh - Performance comparison of SCRIPT_PATH resolution idioms
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

##
## INITIALIZATION
##

# Script metadata
declare -r VERSION=1.1.0 # 2026-04-11 - Add dir-only cd+pwd variant (no basename append)
declare -r SCRIPT_NAME=${0##*/}

# Configuration
declare -i RUNS_PER_TEST=10

# Output files
#shellcheck disable=SC2155
declare -r RESULTS_FILE=benchmark-results-script-path-"$(printf '%(%F_%T)T')".txt

# Test results storage (one array per method)
declare -a times_realpath
declare -a times_readlink_f
declare -a times_cd_pwd
declare -a times_cd_pwd_dir
declare -a times_readlink_loop

# Test targets
declare -- REAL_SCRIPT=''      # /tmp/.../bin/fake.bash   (no symlink)
declare -- LINK_SCRIPT=''      # /tmp/.../link/fake.bash  (symlink to REAL_SCRIPT)
declare -- TMPROOT=''

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
readlink: $(readlink --version | head -n1)
Real target: $REAL_SCRIPT
Link target: $LINK_SCRIPT
Runs per test: $RUNS_PER_TEST

EOF
}

setup_targets() {
  TMPROOT=$(mktemp -d)
  mkdir -p "$TMPROOT"/bin
  : >"$TMPROOT"/bin/fake.bash
  chmod +x "$TMPROOT"/bin/fake.bash
  REAL_SCRIPT=$TMPROOT/bin/fake.bash

  # Install-style wrapper symlink (one hop, relative target)
  mkdir -p "$TMPROOT"/usr/local/bin
  ln -s ../../../bin/fake.bash "$TMPROOT"/usr/local/bin/fake.bash
  LINK_SCRIPT=$TMPROOT/usr/local/bin/fake.bash
}

cleanup_targets() {
  [[ -n $TMPROOT && -d $TMPROOT && $TMPROOT == /tmp/* ]] && rm -rf -- "$TMPROOT"
  return 0
}

##
## Resolution methods
##

run_realpath() {
  # Method 1: SCRIPT_PATH=$(realpath -- "$0")
  local -ri iterations=$1
  local -- arg0=$2
  local -i i start end elapsed
  local -- result

  start=${EPOCHREALTIME/./}

  i=-$iterations
  while ((1)); do
    ((i++)) || break
    result=$(realpath -- "$arg0")
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))
  echo "$elapsed"
}

run_readlink_f() {
  # Method 2: SCRIPT_PATH=$(readlink -f -- "$0")
  local -ri iterations=$1
  local -- arg0=$2
  local -i i start end elapsed
  local -- result

  start=${EPOCHREALTIME/./}

  i=-$iterations
  while ((1)); do
    ((i++)) || break
    result=$(readlink -f -- "$arg0")
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))
  echo "$elapsed"
}

run_cd_pwd() {
  # Method 3: dir=$(cd -P "${0%/*}" && pwd -P); SCRIPT_PATH=$dir/${0##*/}
  #          (does NOT follow final-component symlink)
  local -ri iterations=$1
  local -- arg0=$2
  local -i i start end elapsed
  local -- dir result base

  start=${EPOCHREALTIME/./}

  i=-$iterations
  while ((1)); do
    ((i++)) || break
    dir=${arg0%/*}
    [[ $dir == "$arg0" ]] && dir=.
    base=${arg0##*/}
    dir=$(cd -P -- "$dir" && pwd -P)
    result=$dir/$base
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))
  echo "$elapsed"
}

run_cd_pwd_dir() {
  # Method 5: SCRIPT_DIR ONLY: dir=$(cd -P -- "${0%/*}" && pwd -P)
  #          No basename append. Relevant when only SCRIPT_DIR is needed
  #          (the common case -- SCRIPT_NAME is used only in help/messages).
  #          Returns the LINK'S directory when $0 is a symlink.
  local -ri iterations=$1
  local -- arg0=$2
  local -i i start end elapsed
  local -- dir result

  start=${EPOCHREALTIME/./}

  i=-$iterations
  while ((1)); do
    ((i++)) || break
    dir=${arg0%/*}
    [[ $dir == "$arg0" ]] && dir=.
    result=$(cd -P -- "$dir" && pwd -P)
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))
  echo "$elapsed"
}

run_readlink_loop() {
  # Method 4: manual symlink-follow loop using readlink(1) + cd -P/pwd -P
  #          (follows final-component symlink chain)
  local -ri iterations=$1
  local -- arg0=$2
  local -i i start end elapsed
  local -- path dir base target result

  start=${EPOCHREALTIME/./}

  i=-$iterations
  while ((1)); do
    ((i++)) || break
    path=$arg0
    while [[ -L $path ]]; do
      target=$(readlink -- "$path")
      if [[ $target == /* ]]; then
        path=$target
      else
        path=${path%/*}/$target
      fi
    done
    dir=${path%/*}
    [[ $dir == "$path" ]] && dir=.
    base=${path##*/}
    dir=$(cd -P -- "$dir" && pwd -P)
    result=$dir/$base
  done

  end=${EPOCHREALTIME/./}
  elapsed=$((end - start))
  echo "$elapsed"
}

##
## Stats / reporting
##

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

verify_methods() {
  # Print what each method actually produces for both targets, so we can
  # eyeball semantic equivalence before trusting the numbers.
  local -- arg0 path dir base target result

  echo 'Semantic verification'
  echo '---------------------'
  for arg0 in "$REAL_SCRIPT" "$LINK_SCRIPT"; do
    echo "Input: $arg0"
    printf '  %-22s -> %s\n' 'realpath --'       "$(realpath -- "$arg0")"
    printf '  %-22s -> %s\n' 'readlink -f --'    "$(readlink -f -- "$arg0")"

    dir=${arg0%/*}; [[ $dir == "$arg0" ]] && dir=.
    base=${arg0##*/}
    dir=$(cd -P -- "$dir" && pwd -P)
    printf '  %-22s -> %s\n' 'cd -P && pwd -P'       "$dir/$base"
    printf '  %-22s -> %s  (SCRIPT_DIR only)\n' 'cd -P && pwd -P (dir)' "$dir"

    path=$arg0
    while [[ -L $path ]]; do
      target=$(readlink -- "$path")
      if [[ $target == /* ]]; then
        path=$target
      else
        path=${path%/*}/$target
      fi
    done
    dir=${path%/*}; [[ $dir == "$path" ]] && dir=.
    base=${path##*/}
    dir=$(cd -P -- "$dir" && pwd -P)
    printf '  %-22s -> %s\n' 'readlink loop'     "$dir/$base"
    echo
  done
}

run_scenario() {
  local -r scenario=$1
  local -r arg0=$2
  local -ri iterations=$3
  local -i run
  local -- result

  echo "Running scenario: $scenario (iterations: $iterations, runs: $RUNS_PER_TEST)"
  echo 'Input: '"$arg0"
  echo '========================================================================'

  times_realpath=()
  times_readlink_f=()
  times_cd_pwd=()
  times_cd_pwd_dir=()
  times_readlink_loop=()

  for ((run=1; run<=RUNS_PER_TEST; run+=1)); do
    printf '\rRun %2d/%d: realpath...              ' "$run" "$RUNS_PER_TEST"
    result=$(run_realpath "$iterations" "$arg0")
    times_realpath+=("$result")

    printf '\rRun %2d/%d: readlink -f...           ' "$run" "$RUNS_PER_TEST"
    result=$(run_readlink_f "$iterations" "$arg0")
    times_readlink_f+=("$result")

    printf '\rRun %2d/%d: cd -P && pwd -P...       ' "$run" "$RUNS_PER_TEST"
    result=$(run_cd_pwd "$iterations" "$arg0")
    times_cd_pwd+=("$result")

    printf '\rRun %2d/%d: cd -P && pwd -P (dir)... ' "$run" "$RUNS_PER_TEST"
    result=$(run_cd_pwd_dir "$iterations" "$arg0")
    times_cd_pwd_dir+=("$result")

    printf '\rRun %2d/%d: readlink loop...         ' "$run" "$RUNS_PER_TEST"
    result=$(run_readlink_loop "$iterations" "$arg0")
    times_readlink_loop+=("$result")
  done
  printf '\rRun %2d/%d: Complete!                            \n' "$RUNS_PER_TEST" "$RUNS_PER_TEST"

  local -a s_rp s_rl s_cd s_cdd s_loop
  IFS=' ' read -ra s_rp   <<<"$(calculate_statistics times_realpath)"
  IFS=' ' read -ra s_rl   <<<"$(calculate_statistics times_readlink_f)"
  IFS=' ' read -ra s_cd   <<<"$(calculate_statistics times_cd_pwd)"
  IFS=' ' read -ra s_cdd  <<<"$(calculate_statistics times_cd_pwd_dir)"
  IFS=' ' read -ra s_loop <<<"$(calculate_statistics times_readlink_loop)"

  echo
  echo "Results for: $scenario"
  echo '----------------------------------------------------'
  printf '%-22s %15s %15s %15s\n' Method Mean Median StdDev
  printf '%-22s %15s %15s %15s\n' 'realpath --' \
    "$(format_time "${s_rp[0]}")" \
    "$(format_time "${s_rp[1]}")" \
    "$(format_time "${s_rp[2]}")"
  printf '%-22s %15s %15s %15s\n' 'readlink -f --' \
    "$(format_time "${s_rl[0]}")" \
    "$(format_time "${s_rl[1]}")" \
    "$(format_time "${s_rl[2]}")"
  printf '%-22s %15s %15s %15s\n' 'cd -P && pwd -P' \
    "$(format_time "${s_cd[0]}")" \
    "$(format_time "${s_cd[1]}")" \
    "$(format_time "${s_cd[2]}")"
  printf '%-22s %15s %15s %15s\n' 'cd -P && pwd -P (dir)' \
    "$(format_time "${s_cdd[0]}")" \
    "$(format_time "${s_cdd[1]}")" \
    "$(format_time "${s_cdd[2]}")"
  printf '%-22s %15s %15s %15s\n' 'readlink loop' \
    "$(format_time "${s_loop[0]}")" \
    "$(format_time "${s_loop[1]}")" \
    "$(format_time "${s_loop[2]}")"

  # Speedup summary vs realpath baseline
  local -- ratio_rl ratio_cd ratio_cdd ratio_loop
  ratio_rl=$(awk "BEGIN {printf \"%.2f\", ${s_rp[0]}/${s_rl[0]}}")
  ratio_cd=$(awk "BEGIN {printf \"%.2f\", ${s_rp[0]}/${s_cd[0]}}")
  ratio_cdd=$(awk "BEGIN {printf \"%.2f\", ${s_rp[0]}/${s_cdd[0]}}")
  ratio_loop=$(awk "BEGIN {printf \"%.2f\", ${s_rp[0]}/${s_loop[0]}}")

  echo
  echo '◉ Speedup vs realpath baseline (higher = faster):'
  printf '  %-22s %sx\n' 'readlink -f'           "$ratio_rl"
  printf '  %-22s %sx\n' 'cd -P && pwd -P'       "$ratio_cd"
  printf '  %-22s %sx\n' 'cd -P && pwd -P (dir)' "$ratio_cdd"
  printf '  %-22s %sx\n' 'readlink loop'         "$ratio_loop"

  echo
  echo '========================================================================'
  echo

  { echo "Scenario: $scenario (iterations: $iterations)"
    echo "Input: $arg0"
    echo "realpath --            Mean: $(format_time "${s_rp[0]}"), Median: $(format_time "${s_rp[1]}"), StdDev: $(format_time "${s_rp[2]}")"
    echo "readlink -f --         Mean: $(format_time "${s_rl[0]}"), Median: $(format_time "${s_rl[1]}"), StdDev: $(format_time "${s_rl[2]}")"
    echo "cd -P && pwd -P        Mean: $(format_time "${s_cd[0]}"), Median: $(format_time "${s_cd[1]}"), StdDev: $(format_time "${s_cd[2]}")"
    echo "cd -P && pwd -P (dir)  Mean: $(format_time "${s_cdd[0]}"), Median: $(format_time "${s_cdd[1]}"), StdDev: $(format_time "${s_cdd[2]}")"
    echo "readlink loop          Mean: $(format_time "${s_loop[0]}"), Median: $(format_time "${s_loop[1]}"), StdDev: $(format_time "${s_loop[2]}")"
    echo "Speedup vs realpath: readlink -f ${ratio_rl}x, cd+pwd ${ratio_cd}x, cd+pwd dir ${ratio_cdd}x, readlink loop ${ratio_loop}x"
    echo
  } >> "$RESULTS_FILE"
}

show_help() {
  cat <<'HELP'
benchmark-script-path.sh - Performance comparison of SCRIPT_PATH resolution idioms

Compares five ways to resolve a script path (e.g. SCRIPT_PATH=...):
  1. realpath -- "$0"                                       (external, canonical)
  2. readlink -f -- "$0"                                    (external, canonical)
  3. cd -P "${0%/*}" && pwd -P  + basename append           (no final symlink follow)
  4. cd -P "${0%/*}" && pwd -P                              (SCRIPT_DIR only, no basename)
  5. pure loop: readlink(1) per hop + cd -P/pwd -P          (follows final symlink)

Two scenarios are tested:
  - Direct:     $0 is the real file (no install-style symlink)
  - Symlinked:  $0 is a symlink to the real file (one hop)

Usage: benchmark-script-path.sh [OPTIONS]

Options:
  -h, --help       Show this help message
  -V, --version    Show version information
  -i NUM           Override iteration count (default: 100/1K/5K matrix)
  -r NUM           Number of runs per test (default: 10)

Output:
  benchmark-results-script-path-TIMESTAMP.txt

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

  setup_targets
  trap cleanup_targets EXIT

  { print_system_info
    verify_methods
    echo 'Starting benchmarks...'
    echo
    true
  } | tee "$RESULTS_FILE"

  if ((custom_iterations)); then
    run_scenario "Direct (${custom_iterations})"    "$REAL_SCRIPT" "$custom_iterations"
    run_scenario "Symlinked (${custom_iterations})" "$LINK_SCRIPT" "$custom_iterations"
  else
    run_scenario 'Direct (100)'    "$REAL_SCRIPT" 100
    run_scenario 'Direct (1K)'     "$REAL_SCRIPT" 1000
    run_scenario 'Direct (5K)'     "$REAL_SCRIPT" 5000
    run_scenario 'Symlinked (100)' "$LINK_SCRIPT" 100
    run_scenario 'Symlinked (1K)'  "$LINK_SCRIPT" 1000
    run_scenario 'Symlinked (5K)'  "$LINK_SCRIPT" 5000
  fi

  { cat <<SUMMARY
Benchmark Complete
==================

Detailed results saved to: $RESULTS_FILE

Analysis:
---------
Semantic recap:
  realpath / readlink -f  -> fully canonical (directory AND final-component
                             symlinks resolved). One fork + one execve.
  cd -P && pwd -P + base  -> directory canonical only; final component
                             stays as-typed. One fork, zero execve.
  readlink loop           -> manual chain-follow using readlink(1) per hop,
                             plus final cd -P && pwd -P. One execve per
                             symlink hop + one fork for cd+pwd.

When to pick which:
- Script is never installed behind a symlink: use 'cd -P && pwd -P'. It is
  equivalent to realpath for that case and roughly 2x faster per call.
- Script MAY be installed behind a wrapper symlink (e.g. /usr/local/bin/foo
  -> /opt/foo/foo.bash): 'cd -P && pwd -P' will return the *link* path, not
  the real file. SCRIPT_DIR-based data discovery will then look in the
  wrong place. Use realpath / readlink -f, OR the readlink loop.
- SCRIPT_PATH is resolved exactly ONCE at startup. The absolute time saved
  by the faster idiom is sub-millisecond per script invocation. This
  benchmark is about understanding the trade, not about micro-optimising
  a one-shot assignment.

Caching:
Warm-cache conditions throughout (page cache, dentry cache, Bash path
hash). Cold first-invocation gaps would be larger.

SUMMARY
  } | tee -a "$RESULTS_FILE"

  echo
  echo "Results saved to ${RESULTS_FILE@Q}"
}

main "$@"

#fin
