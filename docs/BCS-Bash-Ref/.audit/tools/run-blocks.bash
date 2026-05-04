#!/usr/bin/env bash
# run-blocks.bash — execute every RUNNABLE bash block from inventory.tsv
# in a sandboxed working directory with a hard 10-second timeout.
# Captures stdout / stderr / exit-status, parses `# ⇒` annotations, and
# emits one TSV row per block to .audit/findings/runtime.tsv.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -rx PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH="$(realpath -- "$0")"
declare -r SCRIPT_DIR="${SCRIPT_PATH%/*}"
declare -r SCRIPT_NAME="${SCRIPT_PATH##*/}"

declare -r REF_DIR="${SCRIPT_DIR%/.audit/tools}"
declare -r DEFAULT_BLOCKS_DIR="$REF_DIR/.audit/blocks"
declare -r DEFAULT_INV="$REF_DIR/.audit/findings/inventory.tsv"
declare -r DEFAULT_OUT="$REF_DIR/.audit/findings/runtime.tsv"
declare -r DEFAULT_LOG_DIR="$REF_DIR/.audit/findings/runtime-log"

declare -i TIMEOUT_SECS=10
declare -i VERBOSE=1

declare -r SHIM_PREAMBLE=$'#!/usr/bin/env bash\nset -euo pipefail\nshopt -s inherit_errexit shift_verbose extglob nullglob\n'

if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

_msg()    { >&2 printf '%s: %s %s\n' "$SCRIPT_NAME" "$1" "${*:2}"; }
error()   { _msg "$RED✗$NC" "$@"; }
warn()    { _msg "$YELLOW▲$NC" "$@"; }
info()    { ((VERBOSE)) || return 0; _msg "$CYAN◉$NC" "$@"; }
success() { ((VERBOSE)) || return 0; _msg "$GREEN✓$NC" "$@"; }
die()     { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
noarg()   { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION -- Sandbox-execute every RUNNABLE bash block.

Usage: $SCRIPT_NAME [OPTIONS]

For each RUNNABLE block in inventory.tsv:
  1. Slice the body and prepend a strict-mode preamble if missing.
  2. Set up a fresh per-block PWD under /tmp.
  3. Run under \`timeout $TIMEOUT_SECS\` with a pinned PATH and HOME.
  4. Capture stdout, stderr, exit status. Persist all three under
     .audit/findings/runtime-log/<flat>__<idx>.{stdout,stderr,exit}.
  5. Compare \`# ⇒ <text>\` annotations against captured stdout
     (substring match, all annotations must be present).

TSV columns:
  leaf_path  block_idx  runnability  label  exit_code
  bucket  expected_count  actual_lines  expected_match
  expected_crash

bucket ∈ {OK, MISMATCH, CRASH, TIMEOUT, NO_EXPECTED, MISSING_ANNOT}

Options:
  -i, --inventory FILE    Source TSV (default: $DEFAULT_INV)
  -b, --blocks-dir DIR    Materialised blocks (default: $DEFAULT_BLOCKS_DIR)
  -o, --output FILE       Output TSV (default: $DEFAULT_OUT)
  -l, --log-dir DIR       Per-block stdout/stderr (default: $DEFAULT_LOG_DIR)
  -t, --timeout SECS      Per-block timeout (default: $TIMEOUT_SECS)
  -L, --leaf REGEX        Only run blocks whose leaf matches REGEX
  -q, --quiet             Suppress informational output
  -V, --version           Show version
  -h, --help              Show this help
HELP
}

flatten_path() {
  local -- p="$1"
  printf '%s' "${p//\//__}"
}

strip_sidecar() {
  awk '!/^# bcs-audit:/' "$1"
}

has_preamble() {
  local -- body="$1"
  if [[ "$body" =~ \#![[:space:]]*/ ]]; then
    return 0
  fi
  if [[ "$body" =~ set[[:space:]]+-(eu|euo|euo[[:space:]]+pipefail) ]]; then
    return 0
  fi
  return 1
}

# Extract every `# ⇒ ...` annotation as one line, with the leading
# annotation marker stripped. Annotations may sit at end-of-command or
# on their own line. The corpus uses both `# ⇒ value` and aligned
# `#         ⇒ value` continuation forms.
#
# Trailing parenthetical clarifications like `value   (depends on host)`
# are stripped — the matcher tests for the literal-output portion only.
# Likewise, prose-only annotations like `# ⇒ N is host-dependent` (no
# leading literal text) are dropped from the expected list, since they
# describe output rather than enumerate it.
extract_expected() {
  local -- body="$1"
  awk '
    /[[:space:]]*#[[:space:]]*⇒/ {
      idx = match($0, /#[[:space:]]*⇒/)
      if (idx == 0) next
      # Skip past the `#  ⇒` marker.
      rest = substr($0, idx + RLENGTH)
      sub(/^[[:space:]]+/, "", rest)
      sub(/[[:space:]]+$/, "", rest)
      # Strip a trailing parenthetical clarifier (one level only).
      sub(/[[:space:]]+\([^)]*\)[[:space:]]*$/, "", rest)
      sub(/[[:space:]]+$/, "", rest)
      if (length(rest) == 0) next
      # Drop prose-only annotations that start with a parenthesis or a
      # leading `(` — those describe runtime behaviour rather than
      # enumerate stdout.
      if (substr(rest, 1, 1) == "(") next
      print rest
    }
  ' <<< "$body"
}

# Match: every expected line must appear as a substring in actual stdout.
# Returns the count of unmatched expected lines.
diff_expected() {
  local -- expected="$1" actual="$2"
  local -i unmatched=0
  local -- exp
  while IFS= read -r exp; do
    [[ -z "$exp" ]] && continue
    if [[ "$actual" != *"$exp"* ]]; then
      unmatched+=1
    fi
  done <<< "$expected"
  printf '%d' "$unmatched"
}

run_one_block() {
  local -- leaf="$1" idx="$2" runn="$3" label="$4" file="$5" log_dir="$6"
  local -- body wrapped expected
  body="$(strip_sidecar "$file")"

  if has_preamble "$body"; then
    wrapped="$body"
  else
    wrapped="${SHIM_PREAMBLE}${body}"
  fi

  expected="$(extract_expected "$body")"

  local -- flat sandbox stdout_log stderr_log exit_log
  flat="$(flatten_path "$leaf")"
  printf -v stdout_log '%s/%s__%03d.stdout' "$log_dir" "$flat" "$idx"
  printf -v stderr_log '%s/%s__%03d.stderr' "$log_dir" "$flat" "$idx"
  printf -v exit_log   '%s/%s__%03d.exit'   "$log_dir" "$flat" "$idx"

  sandbox="$(mktemp -d -t "bcs-audit-run-XXXXXXXX")"
  local -i exit_code=0
  set +e
  # Critical: redirect stdin from /dev/null. A block that calls
  # `exec bash` (no -c) inherits stdin from the parent loop, which is
  # reading inventory.tsv — those lines get consumed as commands and
  # the surrounding loop runs out of input.
  (
    cd "$sandbox"
    env -i HOME="$sandbox" PATH="$PATH" \
      LC_ALL=C.UTF-8 LANG=C.UTF-8 \
      timeout "${TIMEOUT_SECS}s" bash --noprofile --norc -c "$wrapped" < /dev/null
  ) > "$stdout_log" 2> "$stderr_log"
  exit_code=$?
  set -e
  printf '%d\n' "$exit_code" > "$exit_log"
  rm -rf -- "$sandbox"

  local -- actual bucket expected_match
  actual="$(< "$stdout_log")"
  local -i exp_count=0 unmatched=0 actual_lines=0
  if [[ -n "$expected" ]]; then
    exp_count="$(grep -c '' <<< "$expected" || true)"
    unmatched="$(diff_expected "$expected" "$actual")"
  fi
  if [[ -n "$actual" ]]; then
    actual_lines="$(grep -c '' <<< "$actual" || true)"
  fi

  local -i expected_crash=0
  if [[ "$label" == 'WRONG' ]]; then expected_crash=1; fi

  if (( exit_code == 124 )); then
    bucket='TIMEOUT'
    expected_match='-'
  elif (( exit_code != 0 )); then
    bucket='CRASH'
    expected_match='-'
  elif (( exp_count == 0 )); then
    if (( actual_lines > 0 )); then
      bucket='MISSING_ANNOT'
    else
      bucket='NO_EXPECTED'
    fi
    expected_match='-'
  elif (( unmatched == 0 )); then
    bucket='OK'
    expected_match='OK'
  else
    bucket='MISMATCH'
    expected_match="MISSING:$unmatched/$exp_count"
  fi

  printf '%s\t%s\t%s\t%s\t%d\t%s\t%d\t%d\t%s\t%d\n' \
    "$leaf" "$idx" "$runn" "$label" "$exit_code" "$bucket" \
    "$exp_count" "$actual_lines" "$expected_match" "$expected_crash"
}

run() {
  local -- inv="$1" blocks_dir="$2" out="$3" log_dir="$4" leaf_re="$5"

  [[ -f "$inv" ]] || die 3 "inventory not found: $inv"
  [[ -d "$blocks_dir" ]] || die 3 "blocks dir not found: $blocks_dir"

  command -v timeout > /dev/null || die 18 "timeout(1) not on PATH"

  mkdir -p -- "${out%/*}" "$log_dir"
  printf 'leaf_path\tblock_idx\trunnability\tlabel\texit_code\tbucket\texpected_count\tactual_lines\texpected_match\texpected_crash\n' > "$out"

  local -- leaf idx lang label runn flat src
  #shellcheck disable=SC2034
  local -- _ls _le _n_lines _has_annot _sha
  local -i count=0 ok=0 crash=0 to=0 mis=0 noex=0 missann=0
  while IFS=$'\t' read -r leaf idx lang _ls _le _n_lines label runn _has_annot _sha; do
    [[ "$leaf" == 'leaf_path' ]] && continue
    [[ "$lang" == 'bash' ]] || continue
    [[ "$runn" == 'RUNNABLE' ]] || continue
    if [[ -n "$leaf_re" ]] && ! [[ "$leaf" =~ $leaf_re ]]; then
      continue
    fi
    flat="$(flatten_path "$leaf")"
    printf -v src '%s/%s__%03d.bash' "$blocks_dir" "$flat" "$idx"
    [[ -f "$src" ]] || { warn "missing block file: $src"; continue; }
    count+=1
    local row
    row="$(run_one_block "$leaf" "$idx" "$runn" "$label" "$src" "$log_dir")"
    printf '%s\n' "$row" >> "$out"
    case "$row" in
      *$'\t'OK$'\t'*)            ok+=1 ;;
      *$'\t'CRASH$'\t'*)         crash+=1 ;;
      *$'\t'TIMEOUT$'\t'*)       to+=1 ;;
      *$'\t'MISMATCH$'\t'*)      mis+=1 ;;
      *$'\t'NO_EXPECTED$'\t'*)   noex+=1 ;;
      *$'\t'MISSING_ANNOT$'\t'*) missann+=1 ;;
    esac
    if (( count % 50 == 0 )); then
      info "ran $count blocks (ok=$ok crash=$crash timeout=$to mismatch=$mis no_exp=$noex missing_ann=$missann)"
    fi
    # Avoid local-leak in long loops.
    unset row
  done < "$inv"

  success "ran $count blocks: ok=$ok crash=$crash timeout=$to mismatch=$mis no_exp=$noex missing_ann=$missann"
  info "TSV: $out"
  info "logs: $log_dir/"
}

main() {
  local -- inv="$DEFAULT_INV" blocks_dir="$DEFAULT_BLOCKS_DIR"
  local -- out="$DEFAULT_OUT" log_dir="$DEFAULT_LOG_DIR" leaf_re=''
  while (($#)); do
    case "$1" in
      -i|--inventory)  noarg "$@"; inv="$2"; shift 2 ;;
      -b|--blocks-dir) noarg "$@"; blocks_dir="$2"; shift 2 ;;
      -o|--output)     noarg "$@"; out="$2"; shift 2 ;;
      -l|--log-dir)    noarg "$@"; log_dir="$2"; shift 2 ;;
      -t|--timeout)    noarg "$@"; TIMEOUT_SECS="$2"; shift 2 ;;
      -L|--leaf)       noarg "$@"; leaf_re="$2"; shift 2 ;;
      -q|--quiet)      VERBOSE=0; shift ;;
      -V|--version)    printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
      -h|--help)       show_help; exit 0 ;;
      -[ibolLtqVh]?*)  set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)              shift; break ;;
      -*)              die 22 "Unknown option: $1" ;;
      *)               die 22 "Unexpected argument: $1" ;;
    esac
  done
  run "$inv" "$blocks_dir" "$out" "$log_dir" "$leaf_re"
}

main "$@"
#fin
