#!/bin/bash
# Regenerate BASH-CODING-STANDARD.md from data/ tree
set -euo pipefail

VERSION='1.0.0'
SCRIPT_PATH=$(readlink -en -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Output file
declare -- OUTPUT_FILE="$SCRIPT_DIR/BASH-CODING-STANDARD.md"
declare -- DATA_DIR="$SCRIPT_DIR/data"

# Validate data directory exists
[[ -d "$DATA_DIR" ]] || {
  >&2 echo "$SCRIPT_NAME: error: Data directory not found: $DATA_DIR"
  exit 1
}

# Find all .md files in data/ (excluding README.md) and sort them
echo "$SCRIPT_NAME: Collecting markdown files from $DATA_DIR..."
readarray -t md_files < <(find "$DATA_DIR" -name '*.md' -type f ! -name 'README.md' | sort)

# Check if we found any files
if (( ${#md_files[@]} == 0 )); then
  >&2 echo "$SCRIPT_NAME: error: No .md files found in $DATA_DIR"
  exit 1
fi

echo "$SCRIPT_NAME: Found ${#md_files[@]} markdown files"

# Concatenate all files
echo "$SCRIPT_NAME: Regenerating $OUTPUT_FILE..."
{
  for file in "${md_files[@]}"; do
    cat "$file"
    echo  # Add blank line between files
  done
} > "$OUTPUT_FILE"

# Add final marker
echo '#fin' >> "$OUTPUT_FILE"

echo "$SCRIPT_NAME: Successfully regenerated $OUTPUT_FILE"
echo "$SCRIPT_NAME: Total lines: $(wc -l < "$OUTPUT_FILE")"

#fin
