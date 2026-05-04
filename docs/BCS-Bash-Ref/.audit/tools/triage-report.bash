#!/usr/bin/env bash
# triage-report.bash — group REVIEW-classified rows from
# dispositions-augmented.tsv by leading Part directory and emit one
# markdown report per Part under .audit/triage/Part-NN-triage.md.
#
# Each report lists every REVIEW item with: source (lint|runtime), code
# or bucket, label, current rationale, captured stdout excerpt (first 5
# lines), stderr excerpt (first 3 lines), and a recommended-action stub
# for the human reviewer to fill in (FIX_BLOCK, FIX_ANNOTATION,
# ACCEPT_SANDBOX, ACCEPT_PROSE).
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -rx PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH="$(realpath -- "$0")"
declare -r SCRIPT_DIR="${SCRIPT_PATH%/*}"
declare -r SCRIPT_NAME="${SCRIPT_PATH##*/}"

declare -r REF_DIR="${SCRIPT_DIR%/.audit/tools}"
declare -r DEFAULT_DISP="$REF_DIR/.audit/findings/dispositions-augmented.tsv"
declare -r DEFAULT_LOG_DIR="$REF_DIR/.audit/findings/runtime-log"
declare -r DEFAULT_BLOCKS_DIR="$REF_DIR/.audit/blocks"
declare -r DEFAULT_OUT_DIR="$REF_DIR/.audit/triage"

declare -i VERBOSE=1
declare -- TMP_DIR=''
trap 'rm -rf -- "${TMP_DIR:-}"' EXIT

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
$SCRIPT_NAME $VERSION -- Per-Part triage report generator.

Usage: $SCRIPT_NAME [OPTIONS]

Reads the dispositions-augmented.tsv produced by triage.bash, filters
rows where action=REVIEW, groups them by the leading Part directory of
the leaf path, and writes one markdown file per Part to
.audit/triage/Part-NN-triage.md.

Each entry includes lint/runtime context, captured stdout/stderr
excerpts, and a checkbox stub for the human reviewer to record one of:
  - FIX_BLOCK         — block has a real bug; edit the leaf
  - FIX_ANNOTATION    — block correct but # ⇒ wrong; edit the leaf
  - ACCEPT_SANDBOX    — confirmed sandbox artefact; record decision
  - ACCEPT_PROSE      — annotation is descriptive prose, not literal

Options:
  -d, --dispositions FILE  Source TSV (default: $DEFAULT_DISP)
  -L, --log-dir DIR        Runtime logs (default: $DEFAULT_LOG_DIR)
  -b, --blocks DIR         Materialised blocks (default: $DEFAULT_BLOCKS_DIR)
  -o, --out-dir DIR        Output dir (default: $DEFAULT_OUT_DIR)
  -q, --quiet              Suppress informational output
  -V, --version            Show version
  -h, --help               Show this help
HELP
}

flatten_path() {
  local -- p="$1"
  printf '%s' "${p//\//__}"
}

# Resolve a leaf path to its Part-NN tag. The leading directory has the
# form NN_Title; we want "Part-NN".
part_of() {
  local -- leaf="$1"
  local -- top="${leaf%%/*}"
  local -- num="${top%%_*}"
  if [[ "$num" =~ ^[0-9]+$ ]]; then
    printf 'Part-%02d' "$((10#$num))"
  else
    printf 'Part-XX'
  fi
}

# Slug used for in-page anchors / headings.
leaf_slug() {
  local -- leaf="$1"
  printf '%s' "${leaf##*/}"
}

# Cat first N non-empty lines from a file, indented with two spaces for
# inclusion under a markdown bullet.
excerpt_file() {
  local -- file="$1" n="$2"
  [[ -f "$file" ]] || { printf '    _(no file)_\n'; return; }
  if [[ ! -s "$file" ]]; then
    printf '    _(empty)_\n'
    return
  fi
  awk -v n="$n" '
    NF > 0 {
      kept++
      printf "    %s\n", $0
      if (kept >= n) exit
    }
  ' "$file"
}

# Render one REVIEW entry as a markdown stanza.
render_entry() {
  local -- leaf="$1" idx="$2" source="$3" code="$4" label="$5"
  local -- rationale="$6" log_dir="$7" blocks_dir="$8"
  local -- flat stdout_log stderr_log block_file
  flat="$(flatten_path "$leaf")"
  printf -v stdout_log '%s/%s__%03d.stdout' "$log_dir" "$flat" "$idx"
  printf -v stderr_log '%s/%s__%03d.stderr' "$log_dir" "$flat" "$idx"
  printf -v block_file '%s/%s__%03d.bash'  "$blocks_dir" "$flat" "$idx"

  cat <<MD
### Block #$idx — \`$source\` $code

- **Label:** $label
- **Rationale:** $rationale
- **Block file:** \`.audit/blocks/$(basename -- "$block_file")\`

**stdout (first 5 non-empty lines):**

$(excerpt_file "$stdout_log" 5)

**stderr (first 3 non-empty lines):**

$(excerpt_file "$stderr_log" 3)

**Decision** (tick one):

- [ ] FIX_BLOCK
- [ ] FIX_ANNOTATION
- [ ] ACCEPT_SANDBOX
- [ ] ACCEPT_PROSE

**Notes:**

---

MD
}

run() {
  local -- disp="$1" log_dir="$2" blocks_dir="$3" out_dir="$4"
  [[ -f "$disp" ]] || die 3 "missing dispositions: $disp"
  [[ -d "$log_dir" ]] || warn "log dir missing: $log_dir (excerpts will be sparse)"
  [[ -d "$blocks_dir" ]] || die 3 "missing blocks dir: $blocks_dir"

  mkdir -p -- "$out_dir"

  # Bucket REVIEW rows by Part. Use a temp dir of per-Part TSV slices so
  # we can stream large dispositions without slurping into associative
  # arrays. The tmp dir is registered globally because EXIT traps fire
  # after function locals fall out of scope.
  local -- tmp
  tmp="$(mktemp -d -t bcs-triage-report-XXXXXXXX)"
  TMP_DIR="$tmp"

  local -- leaf idx source code level label action _conf rat part slice
  while IFS=$'\t' read -r leaf idx source code level label action _conf rat; do
    [[ "$leaf" == 'leaf_path' ]] && continue
    [[ "$action" == 'REVIEW' ]] || continue
    part="$(part_of "$leaf")"
    slice="$tmp/$part.tsv"
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$leaf" "$idx" "$source" "$code" "$level" "$label" "$rat" >> "$slice"
  done < "$disp"

  local -i parts=0 entries=0
  local -- f part_label out_md
  for f in "$tmp"/Part-*.tsv; do
    [[ -f "$f" ]] || continue
    part_label="$(basename -- "${f%.tsv}")"
    out_md="$out_dir/${part_label}-triage.md"
    render_part "$part_label" "$f" "$log_dir" "$blocks_dir" > "$out_md"
    entries+="$(wc -l < "$f")"
    parts+=1
  done

  if (( parts == 0 )); then
    success "no REVIEW rows; no triage files emitted"
    return
  fi
  success "wrote $parts triage files ($entries entries) → $out_dir/"
}

# Render the report body for one Part: header, summary, then entries
# grouped by leaf.
render_part() {
  local -- part_label="$1" slice="$2" log_dir="$3" blocks_dir="$4"
  local -i total=0
  local -- by_source
  total="$(wc -l < "$slice")"
  by_source="$(awk -F'\t' '{c[$3]++} END {for (k in c) printf "  - %s: %d\n", k, c[k]}' "$slice" | sort)"

  cat <<MD
<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# $part_label — Residual triage

Auto-generated by \`triage-report.bash\`. One entry per REVIEW-classified
row from \`dispositions-augmented.tsv\` whose leaf path falls under this
Part. Tick a decision per entry, then run the per-Part fix pass.

**Total entries:** $total

**By source:**
$by_source

---

MD

  local -- prev_leaf='' leaf idx source code level label rat
  # Sort entries: leaf, then numeric idx.
  while IFS=$'\t' read -r leaf idx source code level label rat; do
    if [[ "$leaf" != "$prev_leaf" ]]; then
      #shellcheck disable=SC2016
      printf '## `%s`\n\n' "$leaf"
      prev_leaf="$leaf"
    fi
    render_entry "$leaf" "$idx" "$source" "$code" "$label" "$rat" "$log_dir" "$blocks_dir"
  done < <(sort -t $'\t' -k1,1 -k2,2n -- "$slice")
}

main() {
  local -- disp="$DEFAULT_DISP" log_dir="$DEFAULT_LOG_DIR"
  local -- blocks="$DEFAULT_BLOCKS_DIR" out="$DEFAULT_OUT_DIR"
  while (($#)); do
    case "$1" in
      -d|--dispositions) noarg "$@"; disp="$2"; shift 2 ;;
      -L|--log-dir)      noarg "$@"; log_dir="$2"; shift 2 ;;
      -b|--blocks)       noarg "$@"; blocks="$2"; shift 2 ;;
      -o|--out-dir)      noarg "$@"; out="$2"; shift 2 ;;
      -q|--quiet)        VERBOSE=0; shift ;;
      -V|--version)      printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
      -h|--help)         show_help; exit 0 ;;
      -[dLboqVh]?*)      set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)                shift; break ;;
      -*)                die 22 "Unknown option: $1" ;;
      *)                 die 22 "Unexpected argument: $1" ;;
    esac
  done
  run "$disp" "$log_dir" "$blocks" "$out"
}

main "$@"
#fin
