#!/usr/bin/env bash
# lint-blocks.bash — run shellcheck against each bash code block from
# inventory.tsv. Wraps blocks lacking a strict-mode preamble in a shim
# before linting so SC2034 / SC1090 noise does not drown real findings.
# Emits one TSV row per shellcheck finding to .audit/findings/shellcheck.tsv.
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
declare -r DEFAULT_OUT="$REF_DIR/.audit/findings/shellcheck.tsv"

declare -i VERBOSE=1

# Strict-mode preamble injected ahead of bodies that lack one. The
# function wrapper makes `local --` legal even when the original
# fragment is a function-body excerpt.
declare -r SHIM_PREAMBLE=$'#!/usr/bin/env bash\nset -euo pipefail\nshopt -s inherit_errexit shift_verbose extglob nullglob\n_audit_main() {\n'
declare -r SHIM_TRAILER=$'\n}\n_audit_main\n'

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
$SCRIPT_NAME $VERSION -- Lint every fenced bash block via shellcheck.

Usage: $SCRIPT_NAME [OPTIONS]

Reads inventory.tsv and the materialised block files, lints each one,
and emits one TSV row per shellcheck finding. Non-bash blocks (json,
yaml, etc.) are skipped.

Output columns:
  leaf_path  block_idx  runnability  label  sc_code  level
  block_line  leaf_line  expected_violation  message

expected_violation = 1 when the block label is WRONG (the block exists
to demonstrate a footgun).

Options:
  -i, --inventory FILE  Source TSV (default: $DEFAULT_INV)
  -b, --blocks-dir DIR  Materialised blocks (default: $DEFAULT_BLOCKS_DIR)
  -o, --output FILE     Output TSV (default: $DEFAULT_OUT)
  -L, --leaf REGEX      Only lint leaves matching REGEX
  -q, --quiet           Suppress informational output
  -V, --version         Show version
  -h, --help            Show this help
HELP
}

flatten_path() {
  local -- p="$1"
  printf '%s' "${p//\//__}"
}

# Strip our sidecar comments from a materialised block file.
strip_sidecar() {
  awk '!/^# bcs-audit:/' "$1"
}

# Decide whether this block already carries its own strict-mode contract.
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

# Lint the block body; emit one TSV row per shellcheck comment.
lint_one_block() {
  local -- leaf="$1" idx="$2" runn="$3" label="$4" file="$5" line_start="$6"
  local -- body wrapped expected
  body="$(strip_sidecar "$file")"

  if has_preamble "$body"; then
    wrapped="$body"
  else
    wrapped="${SHIM_PREAMBLE}${body}${SHIM_TRAILER}"
  fi

  if [[ "$label" == 'WRONG' ]]; then
    expected=1
  else
    expected=0
  fi

  local -- json
  set +e
  json="$(printf '%s' "$wrapped" | shellcheck --shell=bash --format=json --severity=warning -)"
  set -e
  [[ -n "$json" ]] || return 0

  # Compute line offsets so block-relative line numbers map back to
  # the leaf's own line numbers. Two cases:
  #   - shimmed: 4 preamble lines (shebang, set -euo, shopt, _audit_main { )
  #   - native:  no offset
  local -i shim_offset=0 fence_offset=1
  if [[ "$wrapped" != "$body" ]]; then
    shim_offset=4
  fi

  printf '%s' "$json" | jq -r --arg leaf "$leaf" --arg idx "$idx" \
    --arg runn "$runn" --arg label "$label" --argjson exp "$expected" \
    --argjson shim "$shim_offset" --argjson lstart "$line_start" \
    --argjson fence "$fence_offset" '
    .[]
    | [
        $leaf, $idx, $runn, $label,
        ("SC" + (.code|tostring)),
        .level,
        ((.line - $shim) | tostring),
        ((.line - $shim + $lstart + $fence - 1) | tostring),
        ($exp | tostring),
        (.message | gsub("\t"; " "))
      ]
    | @tsv'
}

run() {
  local -- inv="$1" blocks_dir="$2" out="$3" leaf_re="$4"

  [[ -f "$inv" ]] || die 3 "inventory not found: $inv"
  [[ -d "$blocks_dir" ]] || die 3 "blocks dir not found: $blocks_dir"

  command -v shellcheck > /dev/null || die 18 "shellcheck not on PATH"
  command -v jq > /dev/null || die 18 "jq not on PATH"

  mkdir -p -- "${out%/*}"
  : > "$out"
  printf 'leaf_path\tblock_idx\trunnability\tlabel\tsc_code\tlevel\tblock_line\tleaf_line\texpected_violation\tmessage\n' > "$out"

  local -- leaf idx lang ls label runn flat src
  #shellcheck disable=SC2034
  local -- _le _n_lines _has_annot _sha
  local -i lint_count=0 finding_count=0 skip_count=0
  while IFS=$'\t' read -r leaf idx lang ls _le _n_lines label runn _has_annot _sha; do
    [[ "$leaf" == 'leaf_path' ]] && continue
    if [[ "$lang" != 'bash' ]]; then
      skip_count+=1
      continue
    fi
    if [[ -n "$leaf_re" ]] && ! [[ "$leaf" =~ $leaf_re ]]; then
      skip_count+=1
      continue
    fi
    flat="$(flatten_path "$leaf")"
    printf -v src '%s/%s__%03d.bash' "$blocks_dir" "$flat" "$idx"
    [[ -f "$src" ]] || { warn "missing block file: $src"; continue; }
    lint_count+=1
    local before
    before="$(wc -l < "$out")"
    lint_one_block "$leaf" "$idx" "$runn" "$label" "$src" "$ls" >> "$out"
    local after
    after="$(wc -l < "$out")"
    finding_count=$(( finding_count + (after - before) ))
  done < "$inv"

  success "linted $lint_count bash blocks (skipped $skip_count); $finding_count findings → $out"
}

main() {
  local -- inv="$DEFAULT_INV" blocks_dir="$DEFAULT_BLOCKS_DIR" out="$DEFAULT_OUT" leaf_re=''
  while (($#)); do
    case "$1" in
      -i|--inventory)  noarg "$@"; inv="$2"; shift 2 ;;
      -b|--blocks-dir) noarg "$@"; blocks_dir="$2"; shift 2 ;;
      -o|--output)     noarg "$@"; out="$2"; shift 2 ;;
      -L|--leaf)       noarg "$@"; leaf_re="$2"; shift 2 ;;
      -q|--quiet)      VERBOSE=0; shift ;;
      -V|--version)    printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
      -h|--help)       show_help; exit 0 ;;
      -[iboLqVh]?*)    set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)              shift; break ;;
      -*)              die 22 "Unknown option: $1" ;;
      *)               die 22 "Unexpected argument: $1" ;;
    esac
  done
  run "$inv" "$blocks_dir" "$out" "$leaf_re"
}

main "$@"
#fin
