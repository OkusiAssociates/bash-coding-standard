#!/usr/bin/env bash
# generate.bash — re-assemble docs/BCS-Bash-Ref/ tree into ../BCS-ADVANCED-BASH-REFERENCE.md.
# Tree is the canonical source; the single-file artefact is regenerated from it.
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -rx PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

# --- Script metadata ---
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH="$(realpath -- "$0")"
declare -r SCRIPT_DIR="${SCRIPT_PATH%/*}"
declare -r SCRIPT_NAME="${SCRIPT_PATH##*/}"

declare -r TREE_DIR="$SCRIPT_DIR"
declare -r OUTPUT_FILE="${SCRIPT_DIR%/BCS-Bash-Ref}/BCS-ADVANCED-BASH-REFERENCE.md"

# --- Messaging ---
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
$SCRIPT_NAME $VERSION -- Regenerate BCS-ADVANCED-BASH-REFERENCE.md from BCS-Bash-Ref/ tree.

Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -q, --quiet     Suppress informational output
  -V, --version   Show version
  -h, --help      Show this help
HELP
}

emit_stripped() {
  local -- file="$1" line
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == '<!-- SPDX-License-Identifier:'* ]]; then
      continue
    fi
    if [[ "$line" == '#fin' ]]; then
      continue
    fi
    printf '%s\n' "$line"
  done < "$file"
}

emit_until() {
  local -- file="$1" marker="$2" line
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == '<!-- SPDX-License-Identifier:'* ]]; then
      continue
    fi
    if [[ "$line" == "$marker" ]]; then
      return 0
    fi
    printf '%s\n' "$line"
  done < "$file"
}

emit_from() {
  local -- file="$1" marker="$2" line
  local -i found=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    if (( ! found )); then
      if [[ "$line" == "$marker" ]]; then
        found=1
      else
        continue
      fi
    fi
    if [[ "$line" == '#fin' ]]; then
      continue
    fi
    printf '%s\n' "$line"
  done < "$file"
}

trim_trailing_blanks() {
  local -a buf=()
  local -- line
  while IFS= read -r line || [[ -n "$line" ]]; do
    buf+=("$line")
  done
  local -i last=${#buf[@]}
  while (( last > 0 )); do
    if [[ -z "${buf[last-1]}" ]]; then
      last=$((last-1))
    else
      break
    fi
  done
  local -i j
  for ((j=0; j<last; j++)); do
    printf '%s\n' "${buf[j]}"
  done
}

# Reverse the path rewrites that the extractor applied to top-level index.md
# so that the regenerated single file at docs/ uses original-style paths.
rewrite_preface_paths() {
  sed -E '
    s#\]\(\.\./\.\./data/BASH-CODING-STANDARD\.md\)#](../data/BASH-CODING-STANDARD.md)#g
    s#\]\(\.\./BCS-bash/index\.md\)#](BCS-bash/index.md)#g
    s#\]\(\.\./BCS-bash/\)#](BCS-bash/)#g
    s#\]\(\.\./\.\./examples/templates/\)#](../examples/templates/)#g
    s#\]\(\.\./\.\./examples/\)#](../examples/)#g
  '
}

# Same idea for Appendix Q ("Further Reading") — restore docs/-relative paths.
rewrite_q_paths() {
  sed -E '
    s#\]\(\.\./\.\./promo/getting-serious-about-bash\.md\)#](promo/getting-serious-about-bash.md)#g
    s#\]\(\.\./\.\./\.\./data/BASH-CODING-STANDARD\.md\)#](../data/BASH-CODING-STANDARD.md)#g
    s#\]\(\.\./\.\./BCS-bash/\)#](BCS-bash/)#g
  '
}

heading_of() {
  local -- file="$1" line
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" == '<!-- SPDX-License-Identifier:'* ]] && continue
    [[ -z "$line" ]] && continue
    printf '%s' "$line"
    return 0
  done < "$file"
  return 1
}

part_heading_of() {
  local -- dir="$1" line
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" == '<!-- SPDX-License-Identifier:'* ]] && continue
    if [[ "$line" == '# Part '* ]]; then
      printf '%s' "$line"
      return 0
    fi
  done < "$dir/index.md"
  return 1
}

emit_flat_toc() {
  local -- part_dir chap_file app_file
  local -- part_heading chap_heading app_heading
  for part_dir in "$TREE_DIR"/[012][0-9]_*/; do
    [[ -d "$part_dir" ]] || continue
    part_heading="$(part_heading_of "$part_dir")"
    printf '### %s\n' "${part_heading#'# '}"
    for chap_file in "$part_dir"[0-9][0-9]_*.md; do
      [[ -f "$chap_file" ]] || continue
      chap_heading="$(heading_of "$chap_file")"
      printf '%s\n' "${chap_heading#'## '}"
    done
    printf '\n'
  done
  printf '### Appendices\n'
  for app_file in "$TREE_DIR"/99_Appendices/[A-Z]_*.md; do
    [[ -f "$app_file" ]] || continue
    app_heading="$(heading_of "$app_file")"
    printf '%s\n' "${app_heading#'## '}"
  done
}

generate() {
  [[ -d "$TREE_DIR" ]] || die 3 "Tree directory not found: $TREE_DIR"
  [[ -f "$TREE_DIR/index.md" ]] || die 3 "Top-level index.md not found"
  [[ -d "$TREE_DIR/99_Appendices" ]] || die 3 "99_Appendices/ not found"

  info "regenerating $OUTPUT_FILE from $TREE_DIR"

  local -- part_dir chap_file app_file
  local -i part_count=0 chap_count=0 app_count=0

  {
    emit_until "$TREE_DIR/index.md" '## Table of Contents' \
      | rewrite_preface_paths \
      | trim_trailing_blanks
    printf '\n---\n\n'

    printf '## Table of Contents\n\n'
    emit_flat_toc

    printf '\n---\n\n<!-- BODY-START -->\n\n'

    for part_dir in "$TREE_DIR"/[012][0-9]_*/; do
      [[ -d "$part_dir" ]] || continue
      part_count+=1

      emit_until "$part_dir/index.md" '## Chapters' | trim_trailing_blanks
      printf '\n---\n\n'

      for chap_file in "$part_dir"[0-9][0-9]_*.md; do
        [[ -f "$chap_file" ]] || continue
        chap_count+=1
        emit_stripped "$chap_file" | trim_trailing_blanks
        printf '\n'
      done
    done

    printf '%s\n\n# Appendices\n\n' '---'
    for app_file in "$TREE_DIR"/99_Appendices/[A-Z]_*.md; do
      [[ -f "$app_file" ]] || continue
      app_count+=1
      if [[ "$app_file" == */Q_*.md ]]; then
        emit_stripped "$app_file" | rewrite_q_paths | trim_trailing_blanks
      else
        emit_stripped "$app_file" | trim_trailing_blanks
      fi
      printf '\n'
    done

    printf '%s\n\n' '---'
    emit_from "$TREE_DIR/index.md" '*End of reference.*' | trim_trailing_blanks
    printf '\n#fin\n'
  } > "$OUTPUT_FILE"

  success "wrote $OUTPUT_FILE"
  info "parts: $part_count, chapters: $chap_count, appendices: $app_count"
}

main() {
  while (($#)); do
    case "$1" in
      -q|--quiet)   VERBOSE=0; shift ;;
      -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
      -h|--help)    show_help; exit 0 ;;
      -[qVh]?*)     set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)           shift; break ;;
      -*)           die 22 "Unknown option: $1" ;;
      *)            die 22 "Unexpected argument: $1" ;;
    esac
  done

  generate
}

main "$@"
#fin
