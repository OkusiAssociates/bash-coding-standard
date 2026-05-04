#!/usr/bin/env bash
# extract-blocks.bash — emit a TSV inventory of every fenced code block in
# the BCS-Bash-Ref leaf tree. One row per block. Phase 0 of the
# code-block audit; downstream tools (lint, run, triage) consume the TSV.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -rx PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH="$(realpath -- "$0")"
declare -r SCRIPT_DIR="${SCRIPT_PATH%/*}"
declare -r SCRIPT_NAME="${SCRIPT_PATH##*/}"

# Leaf tree root: .audit/tools/ → .audit/ → BCS-Bash-Ref/
declare -r REF_DIR="${SCRIPT_DIR%/.audit/tools}"

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
$SCRIPT_NAME $VERSION -- Inventory fenced code blocks in BCS-Bash-Ref/.

Usage: $SCRIPT_NAME [OPTIONS] [FILE...]

With no FILE arguments, walks the whole leaf tree. With FILE arguments,
processes only the listed leaves (relative or absolute paths).

Output is one TSV row per block on stdout, columns:
  leaf_path  block_idx  fence_lang  line_start  line_end  n_lines
  label_class  runnability  has_output_annot  sha1

Options:
  -H, --header   Emit the column-name header row first
  -q, --quiet    Suppress informational output
  -V, --version  Show version
  -h, --help     Show this help
HELP
}

# Classify the block's intent based on inline ``# wrong'' / ``# right''
# comments inside the block body. Comment-style WRONG markers are the
# dominant convention in BCS-Bash-Ref; heading-style markers are rare
# but also detected.
classify_label() {
  local -- body="$1" line lowered
  local -i wrong=0 right=0
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*\# ]] || continue
    lowered="${line,,}"
    if [[ "$lowered" =~ (^|[^[:alnum:]_])(wrong|broken|do[[:space:]]*not|never|anti-?pattern|footgun|pitfall|buggy|bug:) ]]; then
      wrong+=1
    elif [[ "$lowered" =~ (^|[^[:alnum:]_])(right|fixed|correct|prefer|idiom)([^[:alnum:]_]|$) ]]; then
      right+=1
    fi
  done <<< "$body"
  if (( wrong && right )); then printf 'MIXED'
  elif (( wrong )); then        printf 'WRONG'
  elif (( right )); then        printf 'RIGHT'
  else                          printf 'NEUTRAL'
  fi
}

# Word-boundary helper. Bash's POSIX ERE has no \b, so we approximate
# with an explicit non-word-character prefix.
declare -r WB_L='(^|[^[:alnum:]_-])'

# Classify the block's runtime behaviour. Order matters: more-specific
# disqualifiers first. Conservative by design — anything ambiguous falls
# back to FRAGMENT (lint-only, no runtime execution).
classify_runnability() {
  local -- body="$1" label="$2" lang="$3"
  # Only language-tagged `bash` fences enter the lint/run pipeline.
  # Untagged (NONE) and other-language fences are diagrams, output
  # samples, or non-shell snippets.
  if [[ "$lang" != 'bash' ]]; then
    printf 'FRAGMENT'; return
  fi
  if [[ "$label" == 'WRONG' ]]; then
    printf 'ANTIPATTERN'; return
  fi
  # Destructive: filesystem-mutating verbs targeting non-/tmp paths, or
  # any privilege-escalation / process-killing / device-writing call.
  if [[ "$body" =~ ${WB_L}rm[[:space:]]+-[rRf]+[[:space:]] ]] && [[ ! "$body" =~ /tmp/ ]]; then
    printf 'DESTRUCTIVE'; return
  fi
  if [[ "$body" =~ ${WB_L}sudo[[:space:]] ]]; then
    printf 'DESTRUCTIVE'; return
  fi
  if [[ "$body" =~ ${WB_L}(kill|pkill|killall)[[:space:]] ]]; then
    printf 'DESTRUCTIVE'; return
  fi
  if [[ "$body" =~ ${WB_L}(chmod|chown|chgrp)[[:space:]] ]] && [[ ! "$body" =~ /tmp/ ]]; then
    printf 'DESTRUCTIVE'; return
  fi
  if [[ "$body" =~ ${WB_L}dd[[:space:]]+if= ]]; then
    printf 'DESTRUCTIVE'; return
  fi
  # Network: any external network tool.
  if [[ "$body" =~ ${WB_L}(curl|wget|ssh|scp|sftp|rsync|nc|ncat|dig|nslookup)[[:space:]] ]]; then
    printf 'NETWORK'; return
  fi
  if [[ "$body" =~ ${WB_L}git[[:space:]]+clone[[:space:]] ]]; then
    printf 'NETWORK'; return
  fi
  # Interactive: anything that needs a TTY, readline, or job-control input.
  if [[ "$body" =~ ${WB_L}read[[:space:]]+-p[[:space:]] ]]; then
    printf 'INTERACTIVE'; return
  fi
  if [[ "$body" =~ ${WB_L}(select|tput|bind|complete|stty)[[:space:]] ]]; then
    printf 'INTERACTIVE'; return
  fi
  # Plain `read` without a here-string / here-doc / redirected stdin = needs input.
  if [[ "$body" =~ ${WB_L}read[[:space:]] ]] && [[ ! "$body" =~ \<\<\<|\<\< ]]; then
    printf 'NEEDS_INPUT'; return
  fi
  printf 'RUNNABLE'
}

# Walk one .md leaf, emit one TSV row per fenced block.
extract_one_file() {
  local -- file="$1"
  local -i lineno=0 in_block=0 block_start=0 block_idx=0
  local -- block_lang='' line body sha label runn has_annot
  local -- relpath="${file#"$REF_DIR/"}"
  body=''
  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno+=1
    if (( in_block )); then
      if [[ "$line" == '```' ]]; then
        block_idx+=1
        sha="$(printf '%s' "$body" | sha1sum | cut -d' ' -f1)"
        label="$(classify_label "$body")"
        runn="$(classify_runnability "$body" "$label" "$block_lang")"
        if [[ "$body" == *'# ⇒'* || "$body" == *'#  ⇒'* ]]; then
          has_annot=1
        else
          has_annot=0
        fi
        local -i n_lines
        n_lines=$(( lineno - block_start - 1 ))
        printf '%s\t%d\t%s\t%d\t%d\t%d\t%s\t%s\t%d\t%s\n' \
          "$relpath" "$block_idx" "$block_lang" "$block_start" "$lineno" "$n_lines" \
          "$label" "$runn" "$has_annot" "$sha"
        in_block=0; block_lang=''; body=''
      else
        body+="$line"$'\n'
      fi
    else
      if [[ "$line" =~ ^\`\`\`(.*)$ ]]; then
        block_lang="${BASH_REMATCH[1]:-NONE}"
        # Strip trailing whitespace from lang tag.
        block_lang="${block_lang%%[[:space:]]*}"
        [[ -n "$block_lang" ]] || block_lang='NONE'
        block_start=$lineno
        in_block=1
        body=''
      fi
    fi
  done < "$file"
  if (( in_block )); then
    warn "unterminated fence at $relpath:$block_start"
  fi
}

# Discover leaves under REF_DIR, skipping the .audit/ subtree.
discover_leaves() {
  find "$REF_DIR" -name '*.md' -not -path "$REF_DIR/.audit/*" -print0 | sort -z
}

run() {
  local -i header=$1 argc=$2
  shift 2
  if (( header )); then
    printf 'leaf_path\tblock_idx\tfence_lang\tline_start\tline_end\tn_lines\tlabel_class\trunnability\thas_output_annot\tsha1\n'
  fi
  if (( argc == 0 )); then
    info "scanning leaf tree at $REF_DIR"
    while IFS= read -r -d '' file; do
      extract_one_file "$file"
    done < <(discover_leaves)
  else
    local -- arg
    for arg in "$@"; do
      if [[ "$arg" != /* ]]; then
        arg="$PWD/$arg"
      fi
      [[ -f "$arg" ]] || die 3 "leaf not found: $arg"
      extract_one_file "$arg"
    done
  fi
}

main() {
  local -i emit_header=0
  while (($#)); do
    case "$1" in
      -H|--header)  emit_header=1; shift ;;
      -q|--quiet)   VERBOSE=0; shift ;;
      -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
      -h|--help)    show_help; exit 0 ;;
      -[HqVh]?*)    set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)           shift; break ;;
      -*)           die 22 "Unknown option: $1" ;;
      *)            break ;;
    esac
  done
  run "$emit_header" "$#" "$@"
}

main "$@"
#fin
