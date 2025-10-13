#!/bin/bash
# Systematic compression helper - shows file sizes for manual review
set -euo pipefail

find data -type f -name "*.abstract.md" -exec du -b {} + | \
  awk '$1 > 1500 {printf "%5d bytes  %s\n", $1, $2}' | \
  sort -rn

echo ""
echo "Target: Reduce all files to ~600-1200 bytes for total ~75KB"
echo "Strategy: Keep 1 example, 1 anti-pattern, brief principle, ref line"
