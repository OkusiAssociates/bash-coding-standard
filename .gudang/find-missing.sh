#!/bin/bash
find data -type f -name "*.complete.md" -not -name "README.md" | while IFS= read -r f; do
  abstract="${f%.complete.md}.abstract.md"
  summary="${f%.complete.md}.summary.md"
  if [[ ! -f "$abstract" ]]; then
    echo "Missing abstract: $f"
  fi
  if [[ ! -f "$summary" ]]; then
    echo "Missing summary: $f"
  fi
done
