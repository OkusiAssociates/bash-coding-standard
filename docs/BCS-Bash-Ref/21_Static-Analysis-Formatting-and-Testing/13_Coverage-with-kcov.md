<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.13 Coverage with kcov

Code coverage measurement for bash.

- `kcov OUTPUT_DIR ./script.bash args` — instruments and runs.
- Outputs HTML coverage report.
- Slow on large scripts.
- Misses some bash constructs (subshells, certain expansions).
- Use case: ensuring tests touch all branches of long functions.
- Combine with bats: `kcov OUTPUT_DIR bats tests/`.

```bash
# scenario: bats + kcov + threshold gate
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r COVERAGE_DIR='build/coverage'
declare -ri THRESHOLD=80      # percent

rm -rf -- "$COVERAGE_DIR"
mkdir -p -- "$COVERAGE_DIR"

# instrument bats run; kcov writes per-suite reports
kcov \
  --include-pattern=.bash,.sh \
  --exclude-pattern=tests/ \
  "$COVERAGE_DIR" \
  bats tests/

# extract the merged percentage
percent=$(jq -r '.percent_covered' "$COVERAGE_DIR"/*/coverage.json | head -1)
percent_int=${percent%.*}

if (( percent_int < THRESHOLD )); then
  printf >&2 'coverage %s%% below threshold %d%%\n' "$percent" "$THRESHOLD"
  exit 1
fi

printf 'coverage %s%% (threshold %d%%)\n' "$percent" "$THRESHOLD"

#fin
```

`--include-pattern` restricts instrumentation to bash sources; the
`--exclude-pattern` keeps the test files themselves out of the
denominator. The `coverage.json` schema is stable; pipe through `jq` for
gate logic. CI-side: archive `$COVERAGE_DIR/index.html` as an artefact
for human inspection.

**See also**: §21.8 (bats-core), §21.9 (setup/teardown), §21.7 (CI integration).

#fin
