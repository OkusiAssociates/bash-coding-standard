#!/usr/bin/env bash
#shellcheck disable=SC2034
# Sync vendored library dependencies from upstream sources
# Reads lib/.sync-manifest and syncs libraries from /ai/scripts locations

set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
declare -- SCRIPT_PATH
SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}
declare -r MANIFEST_FILE="$SCRIPT_DIR/.sync-manifest"
declare -r README_FILE="$SCRIPT_DIR/README.md"

# Global flags
declare -i DRY_RUN=0
declare -i AUTO_COMMIT=0
declare -i VERSION_CHECK=0
declare -i VERBOSE=0

# Counters
declare -i SYNCED_COUNT=0
declare -i FAILED_COUNT=0
declare -i UNCHANGED_COUNT=0

# Color definitions (only if terminal)
if [[ -t 1 ]]; then
  declare -r -- RED='\033[0;31m'
  declare -r -- GREEN='\033[0;32m'
  declare -r -- YELLOW='\033[1;33m'
  declare -r -- BLUE='\033[0;34m'
  declare -r -- CYAN='\033[0;36m'
  declare -r -- NC='\033[0m' # No Color
else
  declare -r -- RED='' GREEN='' YELLOW='' BLUE='' CYAN='' NC=''
fi
readonly -- RED GREEN YELLOW BLUE CYAN NC

# Messaging functions
_msg() {
  local -- level=${1:-info}
  shift
  local -- func="${FUNCNAME[2]}"
  [[ "$func" == 'main' ]] && func=$SCRIPT_NAME
  case "$level" in
    success) echo -e "${GREEN}✓${NC} [$func] $*" ;;
    info)    echo -e "${BLUE}◉${NC} [$func] $*" ;;
    warn)    >&2 echo -e "${YELLOW}▲${NC} [$func] $*" ;;
    error)   >&2 echo -e "${RED}✗${NC} [$func] $*" ;;
  esac
}

success() { _msg success "$@"; }
info() { _msg info "$@"; }
warn() { _msg warn "$@"; }
error() { _msg error "$@"; }
die() { error "$@"; exit 1; }

vecho() {
  ((VERBOSE)) || return 0
  echo "$@"
}

# Help/usage functions
usage() {
  cat <<'EOF'
Usage: sync-lib.sh [OPTIONS]

Sync vendored library dependencies from upstream sources.
Reads lib/.sync-manifest and syncs libraries from /ai/scripts locations.

OPTIONS:
  -n, --dry-run       Show what would be synced without making changes
  -c, --commit        Auto-commit changes after successful sync
  -V, --version       Check versions only (compare git hashes)
  -v, --verbose       Verbose output
  -h, --help          Show this help message

EXAMPLES:
  sync-lib.sh                    # Sync all libraries
  sync-lib.sh --dry-run          # Preview changes
  sync-lib.sh --version          # Check if updates available
  sync-lib.sh --commit           # Sync and auto-commit
EOF
}

# Parse command-line arguments
parse_args() {
  while (($#)); do
    case "$1" in
      -n|--dry-run)
        DRY_RUN=1
        shift
        ;;
      -c|--commit)
        AUTO_COMMIT=1
        shift
        ;;
      -V|--version)
        VERSION_CHECK=1
        shift
        ;;
      -v|--verbose)
        VERBOSE=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1 (use --help for usage)"
        ;;
    esac
  done
}

# Get git commit hash for a directory
get_git_hash() {
  local -- dir=$1

  [[ -d "$dir/.git" ]] || return 1

  pushd "$dir" >/dev/null 2>&1 || return 1
  local -- hash
  hash=$(git log -1 --format='%H' 2>/dev/null) || { popd >/dev/null 2>&1; return 1; }
  popd >/dev/null 2>&1

  echo "$hash"
}

# Get git commit timestamp for a directory
get_git_timestamp() {
  local -- dir=$1

  [[ -d "$dir/.git" ]] || return 1

  pushd "$dir" >/dev/null 2>&1 || return 1
  local -- timestamp
  timestamp=$(git log -1 --format='%ci' 2>/dev/null) || { popd >/dev/null 2>&1; return 1; }
  popd >/dev/null 2>&1

  echo "$timestamp"
}

# Read and parse manifest file
read_manifest() {
  [[ -f "$MANIFEST_FILE" ]] || die "Manifest file not found: $MANIFEST_FILE"

  local -- line lib_subdir upstream_path file_pattern copy_docs

  while IFS='|' read -r lib_subdir upstream_path file_pattern copy_docs; do
    # Skip comments and blank lines
    [[ "$lib_subdir" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$lib_subdir" ]] && continue

    # Validate upstream path exists
    [[ -d "$upstream_path" ]] || {
      warn "Upstream path not found: $upstream_path (skipping $lib_subdir)"
      ((FAILED_COUNT+=1))
      continue
    }

    sync_library "$lib_subdir" "$upstream_path" "$file_pattern" "$copy_docs"
  done < "$MANIFEST_FILE"
}

# Sync a single library
sync_library() {
  local -- lib_subdir=$1
  local -- upstream_path=$2
  local -- file_pattern=$3
  local -- copy_docs=$4

  local -- target_dir="$SCRIPT_DIR/$lib_subdir"

  info "Processing: $lib_subdir"

  # Get current and upstream git hashes
  local -- current_hash='' upstream_hash=''
  upstream_hash=$(get_git_hash "$upstream_path") || upstream_hash='not-a-git-repo'

  if [[ -d "$target_dir" ]]; then
    # For version check mode, get current hash from README.md
    if ((VERSION_CHECK)); then
      current_hash=$(grep -A 5 "^### ${lib_subdir##*/}/" "$README_FILE" 2>/dev/null | grep -oP 'Git commit.*`\K[0-9a-f]{40}' | head -1) || current_hash='unknown'
    fi
  fi

  # Version check mode - just compare
  if ((VERSION_CHECK)); then
    if [[ "$upstream_hash" == 'not-a-git-repo' ]]; then
      info "  Not a git repo - cannot check version"
      return 0
    fi

    if [[ "$current_hash" == "$upstream_hash" ]]; then
      success "  Up to date: $upstream_hash"
      ((UNCHANGED_COUNT+=1))
    elif [[ "$current_hash" == 'unknown' ]]; then
      warn "  Current version unknown, upstream: ${upstream_hash:0:8}"
    else
      warn "  Update available: ${current_hash:0:8} → ${upstream_hash:0:8}"
      ((FAILED_COUNT+=1))
    fi
    return 0
  fi

  # Create target directory
  if ((DRY_RUN)); then
    vecho "  [DRY-RUN] Would ensure directory exists: $target_dir"
  else
    mkdir -p "$target_dir" 2>/dev/null || {
      error "  Failed to create directory: $target_dir"
      ((FAILED_COUNT+=1))
      return 1
    }
  fi

  # Copy files using the pattern
  vecho "  Copying files matching: $file_pattern"
  local -a files
  local -- pattern

  # Handle multiple patterns separated by spaces
  for pattern in $file_pattern; do
    # shellcheck disable=SC2206
    files=("$upstream_path"/$pattern)

    for file in "${files[@]}"; do
      [[ -e "$file" ]] || continue

      local -- basename=${file##*/}
      local -- target="$target_dir/$basename"

      if ((DRY_RUN)); then
        vecho "    [DRY-RUN] Would copy: $file → $target"
      else
        cp -a "$file" "$target" || {
          error "    Failed to copy: $file"
          ((FAILED_COUNT+=1))
          return 1
        }
        vecho "    Copied: $basename"
      fi
    done
  done

  # Copy documentation if requested
  if [[ "$copy_docs" == 'yes' ]]; then
    for doc in LICENSE README.md; do
      if [[ -f "$upstream_path/$doc" ]]; then
        if ((DRY_RUN)); then
          vecho "    [DRY-RUN] Would copy: $doc"
        else
          cp -a "$upstream_path/$doc" "$target_dir/" || {
            warn "    Failed to copy $doc (non-fatal)"
          }
          vecho "    Copied: $doc"
        fi
      fi
    done
  fi

  # Update README.md with git hash if applicable
  if [[ "$upstream_hash" != 'not-a-git-repo' ]]; then
    local -- timestamp
    timestamp=$(get_git_timestamp "$upstream_path") || timestamp='unknown'

    if ((DRY_RUN)); then
      vecho "  [DRY-RUN] Would update README.md:"
      vecho "    Git commit: $upstream_hash"
      vecho "    Last synced: $timestamp"
    else
      update_readme_hash "$lib_subdir" "$upstream_hash" "$timestamp" || {
        warn "  Failed to update README.md (non-fatal)"
      }
    fi
  fi

  success "  Synced: $lib_subdir"
  ((SYNCED_COUNT+=1))
}

# Update lib/README.md with new git hash
update_readme_hash() {
  local -- lib_name=$1
  local -- new_hash=$2
  local -- new_timestamp=$3

  # Find the section for this library
  local -- section_name=${lib_name##*/}

  # Update git commit line
  if grep -q "^### $section_name/" "$README_FILE" 2>/dev/null; then
    # Update existing Git commit line
    sed -i "/^### $section_name\//,/^---\$/ s|^\*\*Git commit:\*\* \`[0-9a-f]\{40\}\`|\*\*Git commit:\*\* \`$new_hash\`|" "$README_FILE"
    sed -i "/^### $section_name\//,/^---\$/ s|^\*\*Last synced:\*\* .*|\*\*Last synced:\*\* $new_timestamp|" "$README_FILE"
    vecho "    Updated README.md git hash"
  else
    vecho "    Section not found in README.md (skipping hash update)"
  fi
}

# Auto-commit changes
auto_commit() {
  ((AUTO_COMMIT)) || return 0

  info 'Auto-committing changes...'

  # Check if there are changes to commit
  if ! git diff --quiet lib/ || ! git diff --cached --quiet lib/; then
    git add lib/
    git commit -m "$(cat <<EOF
Sync vendored libraries from upstream

Updated $SYNCED_COUNT libraries:
$(git diff --cached --name-only lib/ | head -10)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
    success 'Changes committed'
  else
    info 'No changes to commit'
  fi
}

# Main function
main() {
  parse_args "$@"

  # Header
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Library Sync - Bash Coding Standard v$VERSION"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  ((DRY_RUN)) && info 'DRY-RUN MODE - No changes will be made'
  ((VERSION_CHECK)) && info 'VERSION CHECK MODE - Comparing git hashes only'
  echo

  # Read and process manifest
  read_manifest

  # Summary
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if ((VERSION_CHECK)); then
    echo "  Summary: $UNCHANGED_COUNT up-to-date, $FAILED_COUNT updates available"
  else
    echo "  Summary: $SYNCED_COUNT synced, $FAILED_COUNT failed, $UNCHANGED_COUNT unchanged"
  fi
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Auto-commit if requested
  if ! ((DRY_RUN)) && ! ((VERSION_CHECK)); then
    auto_commit
  fi

  # Exit with appropriate code
  if ((FAILED_COUNT > 0)); then
    exit 1
  fi
}

main "$@"

#fin
