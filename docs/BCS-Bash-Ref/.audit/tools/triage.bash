#!/usr/bin/env bash
# triage.bash — fold lint + runtime findings into a per-finding
# disposition table. First-pass classification is rule-based; rows that
# need human attention are tagged TRIAGE_NEEDED with a hint.
#
# Output: .audit/findings/dispositions-augmented.tsv
#   leaf  block_idx  source(lint|runtime)  code_or_bucket  action  confidence  rationale
# action ∈ {FIX_BLOCK, FIX_ANNOTATION, ADD_SUPPRESSION, EXPECTED_VIOLATION,
#           EXPECTED_CRASH, SANDBOX_ARTEFACT, FALSE_POSITIVE, REVIEW}
# confidence ∈ {HIGH, MEDIUM, LOW}
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -rx PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH="$(realpath -- "$0")"
declare -r SCRIPT_DIR="${SCRIPT_PATH%/*}"
declare -r SCRIPT_NAME="${SCRIPT_PATH##*/}"

declare -r REF_DIR="${SCRIPT_DIR%/.audit/tools}"
declare -r DEFAULT_INV="$REF_DIR/.audit/findings/inventory.tsv"
declare -r DEFAULT_LINT="$REF_DIR/.audit/findings/shellcheck.tsv"
declare -r DEFAULT_RUN="$REF_DIR/.audit/findings/runtime.tsv"
declare -r DEFAULT_BLOCKS="$REF_DIR/.audit/blocks"
declare -r DEFAULT_OUT="$REF_DIR/.audit/findings/dispositions-augmented.tsv"

declare -i VERBOSE=1

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
$SCRIPT_NAME $VERSION -- First-pass triage of lint+runtime findings.

Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -i, --inventory FILE  Inventory TSV (default: $DEFAULT_INV)
  -l, --lint FILE       Shellcheck TSV (default: $DEFAULT_LINT)
  -r, --runtime FILE    Runtime TSV (default: $DEFAULT_RUN)
  -b, --blocks DIR      Materialised blocks (default: $DEFAULT_BLOCKS)
  -o, --output FILE     Output TSV (default: $DEFAULT_OUT)
  -q, --quiet           Suppress informational output
  -V, --version         Show version
  -h, --help            Show this help
HELP
}

flatten_path() {
  local -- p="$1"
  printf '%s' "${p//\//__}"
}

# Read body of a materialised block (sidecar stripped) for pattern matching.
read_block_body() {
  local -- leaf="$1" idx="$2" blocks_dir="$3"
  local -- flat src
  flat="$(flatten_path "$leaf")"
  printf -v src '%s/%s__%03d.bash' "$blocks_dir" "$flat" "$idx"
  [[ -f "$src" ]] && awk '!/^# bcs-audit:/' "$src" || true
}

# Classify one shellcheck finding into action + confidence.
# Inputs: code, level, label, body (block body), block_line.
# Outputs: "ACTION\tCONFIDENCE\tRATIONALE"
# Single-quoted printf strings deliberately preserve literal $() / [] / # ⇒
# in rationales — this is data, not code.
#shellcheck disable=SC2016
classify_lint() {
  local -- code="$1" level="$2" label="$3" body="$4"
  case "$label" in
    WRONG)
      printf 'EXPECTED_VIOLATION\tHIGH\tblock labelled WRONG (anti-pattern demo)' ; return ;;
  esac
  case "$code" in
    SC1128)
      # Shebang must be on first line. Convention here puts a
      # `# scenario:` comment above the shebang to label the demo.
      if [[ "$body" =~ ^[[:space:]]*\#[[:space:]]*scenario: ]]; then
        printf 'ADD_SUPPRESSION\tHIGH\tcorpus convention places `# scenario:` above shebang'
      else
        printf 'FIX_BLOCK\tMEDIUM\tshebang not on first non-blank line'
      fi
      return ;;
    SC2034)
      # Variable unused — most are pedagogy.
      if [[ "$label" == 'MIXED' || "$label" == 'RIGHT' ]]; then
        printf 'ADD_SUPPRESSION\tMEDIUM\tdeclared to demonstrate, not consumed'
      else
        printf 'ADD_SUPPRESSION\tMEDIUM\tlikely declared for demonstration'
      fi
      return ;;
    SC2154)
      # Variable referenced but not assigned — common in fragments
      # that reference vars defined earlier in the leaf prose.
      printf 'ADD_SUPPRESSION\tMEDIUM\tfragment references context var defined in prose'
      return ;;
    SC1090|SC1091)
      printf 'ADD_SUPPRESSION\tHIGH\tnon-constant source — standard suppression idiom'
      return ;;
    SC2155)
      printf 'FIX_BLOCK\tHIGH\tdeclare and assign separately (BCS-flagged)'
      return ;;
    SC2046)
      printf 'FIX_BLOCK\tHIGH\tunquoted $(...) — likely real bug'
      return ;;
    SC2086)
      printf 'FIX_BLOCK\tHIGH\tunquoted variable — likely real bug'
      return ;;
    SC2120)
      # BCS canonical idiom: helpers like noarg() { (($# > 1)) || die ...; }
      # use $#/$@ without declaring parameters; SC2120 is a false positive
      # for these. Real cases are rare; default to suppression.
      printf 'ADD_SUPPRESSION\tMEDIUM\tBCS noarg-style helper uses $#/$@ without declared params'
      return ;;
    SC2288)
      printf 'FIX_BLOCK\tHIGH\t$(...) inside [...] — likely real bug'
      return ;;
    SC1072|SC1073)
      # Parser errors — usually intentional grammar samples.
      printf 'REVIEW\tLOW\tparser error — possibly an intentional grammar sample'
      return ;;
    SC1083)
      printf 'REVIEW\tLOW\tliteral { ... } in word context — diagram or footgun?'
      return ;;
    SC1056|SC1036)
      printf 'REVIEW\tLOW\tcode-fence parser confusion — investigate per-leaf'
      return ;;
    SC2242)
      # Invalid exit code (e.g., negative). Often pedagogical.
      printf 'REVIEW\tLOW\tinvalid exit code — verify pedagogical intent'
      return ;;
    SC2068)
      printf 'FIX_BLOCK\tHIGH\t$@ unquoted — likely real bug'
      return ;;
    SC2091)
      printf 'REVIEW\tMEDIUM\t$(...) used as a command — verify'
      return ;;
    *)
      printf 'REVIEW\tLOW\tcode %s — first-pass triage rule not yet defined' "$code"
      return ;;
  esac
}

# Classify one runtime row. Inputs: bucket, label, exit_code, body.
#shellcheck disable=SC2016
classify_runtime() {
  local -- bucket="$1" label="$2" exit_code="$3" body="$4"
  case "$bucket" in
    OK)
      printf 'NO_ACTION\tHIGH\tran cleanly; expected output matched'
      return ;;
    NO_EXPECTED)
      printf 'NO_ACTION\tHIGH\tran cleanly; no annotations to compare'
      return ;;
    MISSING_ANNOT)
      printf 'FIX_ANNOTATION\tMEDIUM\tblock produced output but has no `# ⇒` annotation — opportunity to add'
      return ;;
    MISMATCH)
      # If the documented output uses /home/u/ placeholders we cannot
      # reproduce in the sandbox, this is a documentation pattern, not
      # a bug.
      if [[ "$body" =~ /home/u(/|[[:space:]]|$) ]]; then
        printf 'FALSE_POSITIVE\tMEDIUM\tdoc uses /home/u placeholder; runtime sees sandbox HOME'
      else
        printf 'REVIEW\tMEDIUM\tactual stdout did not contain documented `# ⇒` text — fix doc or block'
      fi
      return ;;
    CRASH)
      if [[ "$label" == 'WRONG' ]]; then
        printf 'EXPECTED_CRASH\tHIGH\tblock is anti-pattern demo; non-zero exit is the point'
        return
      fi
      # Sandbox-isolation artefacts: blocks call project helpers
      # (`die`, `info`, `success`, `error`, `warn`, `noarg`) or external
      # tools (`bcscheck`, `phcs`, `ok1`/`ok2`/`ok3`) that aren't on PATH
      # under env -i.
      if [[ "$body" =~ (^|[^[:alnum:]_])(die|info|success|warn|error|noarg|vecho|yn)[[:space:]] ]]; then
        printf 'SANDBOX_ARTEFACT\tMEDIUM\tblock calls BCS messaging helper not in sandbox PATH'
        return
      fi
      if [[ "$body" =~ (^|[^[:alnum:]_])(bcscheck|phcs|ok[123]|push-to-okusi)[[:space:]] ]]; then
        printf 'SANDBOX_ARTEFACT\tHIGH\tblock calls Okusi-fleet binary unavailable in sandbox'
        return
      fi
      # Use of /etc/passwd, /var/, /proc/, /sys/ — system-state-dependent.
      if [[ "$body" =~ /(etc|var|proc|sys)/ ]]; then
        printf 'SANDBOX_ARTEFACT\tMEDIUM\tblock reads /etc/var/proc/sys path — sandbox may differ'
        return
      fi
      # Real candidate
      printf 'REVIEW\tLOW\tcrash with no obvious sandbox cause; exit=%s' "$exit_code"
      return ;;
    TIMEOUT)
      printf 'REVIEW\tMEDIUM\thit 10s wall — long sleep loop or accidental hang'
      return ;;
    *)
      printf 'REVIEW\tLOW\tunknown bucket %s' "$bucket"
      return ;;
  esac
}

run() {
  local -- inv="$1" lint="$2" runtm="$3" blocks="$4" out="$5"
  for f in "$inv" "$lint" "$runtm"; do
    [[ -f "$f" ]] || die 3 "missing input: $f"
  done
  [[ -d "$blocks" ]] || die 3 "missing blocks dir: $blocks"

  mkdir -p -- "${out%/*}"
  printf 'leaf_path\tblock_idx\tsource\tcode\tlevel_or_bucket\tlabel\taction\tconfidence\trationale\n' > "$out"

  # Build label map from inventory: leaf TAB idx -> label
  declare -A LABEL_MAP=()
  local -- l_leaf l_idx l_label
  while IFS=$'\t' read -r l_leaf l_idx _ _ _ _ l_label _ _ _; do
    [[ "$l_leaf" == 'leaf_path' ]] && continue
    LABEL_MAP["$l_leaf	$l_idx"]="$l_label"
  done < "$inv"

  local -i lint_count=0 runtime_count=0
  local -- leaf idx label code level body action conf rat runrow
  local -- bucket exit_code

  # Pass 1: lint rows
  #shellcheck disable=SC2034
  local -- _runn _label _exp _block_line _leaf_line _msg
  while IFS=$'\t' read -r leaf idx _runn _label code level _block_line _leaf_line _exp _msg; do
    [[ "$leaf" == 'leaf_path' ]] && continue
    label="${LABEL_MAP["$leaf	$idx"]:-NEUTRAL}"
    body="$(read_block_body "$leaf" "$idx" "$blocks")"
    runrow="$(classify_lint "$code" "$level" "$label" "$body")"
    IFS=$'\t' read -r action conf rat <<< "$runrow"
    printf '%s\t%s\tlint\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$leaf" "$idx" "$code" "$level" "$label" "$action" "$conf" "$rat" >> "$out"
    lint_count+=1
  done < "$lint"

  # Pass 2: runtime rows
  while IFS=$'\t' read -r leaf idx _runn label exit_code bucket _ _ _ _; do
    [[ "$leaf" == 'leaf_path' ]] && continue
    body="$(read_block_body "$leaf" "$idx" "$blocks")"
    runrow="$(classify_runtime "$bucket" "$label" "$exit_code" "$body")"
    IFS=$'\t' read -r action conf rat <<< "$runrow"
    printf '%s\t%s\truntime\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$leaf" "$idx" "$bucket" "exit=$exit_code" "$label" "$action" "$conf" "$rat" >> "$out"
    runtime_count+=1
  done < "$runtm"

  success "triaged $lint_count lint findings + $runtime_count runtime rows → $out"
}

main() {
  local -- inv="$DEFAULT_INV" lint="$DEFAULT_LINT" runtm="$DEFAULT_RUN"
  local -- blocks="$DEFAULT_BLOCKS" out="$DEFAULT_OUT"
  while (($#)); do
    case "$1" in
      -i|--inventory) noarg "$@"; inv="$2"; shift 2 ;;
      -l|--lint)      noarg "$@"; lint="$2"; shift 2 ;;
      -r|--runtime)   noarg "$@"; runtm="$2"; shift 2 ;;
      -b|--blocks)    noarg "$@"; blocks="$2"; shift 2 ;;
      -o|--output)    noarg "$@"; out="$2"; shift 2 ;;
      -q|--quiet)     VERBOSE=0; shift ;;
      -V|--version)   printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
      -h|--help)      show_help; exit 0 ;;
      -[ilrboqVh]?*)  set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)             shift; break ;;
      -*)             die 22 "Unknown option: $1" ;;
      *)              die 22 "Unexpected argument: $1" ;;
    esac
  done
  run "$inv" "$lint" "$runtm" "$blocks" "$out"
}

main "$@"
#fin
