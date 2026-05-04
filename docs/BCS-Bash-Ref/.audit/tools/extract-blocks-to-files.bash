#!/usr/bin/env bash
# extract-blocks-to-files.bash — materialise each block from
# inventory.tsv into a standalone file under .audit/blocks/. Output
# names: <flattened-leaf-path>__<block_idx>.bash.
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
declare -r DEFAULT_OUT="$REF_DIR/.audit/blocks"

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
$SCRIPT_NAME $VERSION -- Materialise each fenced block to a separate file.

Usage: $SCRIPT_NAME [OPTIONS]

Reads inventory.tsv (default: $DEFAULT_INV) and writes one file per
block to OUTDIR (default: $DEFAULT_OUT).

Each file contains the block body verbatim, with a leading sidecar
metadata header (a few '# bcs-audit:' comment lines). The sidecar lets
downstream tools recover leaf path, block index, lang, line range,
runnability, and label without reparsing the TSV.

Options:
  -i, --inventory FILE  Source TSV (default: $DEFAULT_INV)
  -o, --outdir DIR      Output directory (default: $DEFAULT_OUT)
  -c, --clean           Remove OUTDIR before writing
  -q, --quiet           Suppress informational output
  -V, --version         Show version
  -h, --help            Show this help
HELP
}

flatten_path() {
  local -- p="$1"
  printf '%s' "${p//\//__}"
}

slice_block_body() {
  local -- file="$1" line_start="$2" line_end="$3"
  # The body is between the opening fence (line_start) and closing fence
  # (line_end), exclusive of both.
  local -i body_start=$((line_start + 1)) body_end=$((line_end - 1))
  if (( body_end < body_start )); then
    return 0
  fi
  awk -v s="$body_start" -v e="$body_end" 'NR>=s && NR<=e' "$file"
}

run() {
  local -- inv="$1" outdir="$2"
  local -i clean="$3"

  [[ -f "$inv" ]] || die 3 "inventory not found: $inv"

  if (( clean )) && [[ -d "$outdir" ]]; then
    info "cleaning $outdir"
    rm -rf -- "$outdir"
  fi
  mkdir -p -- "$outdir"

  local -- leaf idx lang ls le n_lines label runn has_annot sha
  local -i count=0
  while IFS=$'\t' read -r leaf idx lang ls le n_lines label runn has_annot sha; do
    [[ "$leaf" == 'leaf_path' ]] && continue
    local -- src="$REF_DIR/$leaf"
    [[ -f "$src" ]] || { warn "missing source: $src"; continue; }
    local -- flat
    flat="$(flatten_path "$leaf")"
    local -- out
    printf -v out '%s/%s__%03d.bash' "$outdir" "$flat" "$idx"
    {
      printf '# bcs-audit: leaf=%s\n' "$leaf"
      printf '# bcs-audit: block_idx=%s lang=%s lines=%s-%s n_lines=%s\n' \
        "$idx" "$lang" "$ls" "$le" "$n_lines"
      printf '# bcs-audit: label=%s runnability=%s has_output_annot=%s\n' \
        "$label" "$runn" "$has_annot"
      printf '# bcs-audit: sha1=%s\n' "$sha"
      slice_block_body "$src" "$ls" "$le"
    } > "$out"
    count+=1
  done < "$inv"
  success "wrote $count block files to $outdir"
}

main() {
  local -- inv="$DEFAULT_INV" outdir="$DEFAULT_OUT"
  local -i clean=0
  while (($#)); do
    case "$1" in
      -i|--inventory) noarg "$@"; inv="$2"; shift 2 ;;
      -o|--outdir)    noarg "$@"; outdir="$2"; shift 2 ;;
      -c|--clean)     clean=1; shift ;;
      -q|--quiet)     VERBOSE=0; shift ;;
      -V|--version)   printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
      -h|--help)      show_help; exit 0 ;;
      -[icqVh]?*)     set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)             shift; break ;;
      -*)             die 22 "Unknown option: $1" ;;
      *)              die 22 "Unexpected argument: $1" ;;
    esac
  done
  run "$inv" "$outdir" "$clean"
}

main "$@"
#fin
