# Test Fixtures

Test fixtures used by the BCS test suite.

## Directory Structure

```
fixtures/
├── sample-complete.sh        # Full BCS-compliant script example
├── sample-minimal.sh         # Minimal BCS-compliant script
├── sample-non-compliant.sh   # Non-compliant script for testing
├── valid-scripts/
│   └── minimal-compliant.sh  # Minimal compliant script fixture
├── invalid-scripts/
│   ├── no-shebang.sh         # Missing shebang line
│   ├── no-set-options.sh     # Missing set -euo pipefail
│   └── no-fin-marker.sh      # Missing #fin end marker
├── test-rules/
│   ├── 99-test-rule.complete.md
│   ├── 99-test-rule.summary.md
│   └── 99-test-rule.abstract.md
└── templates/                # Reserved for expected template outputs
```

## Sample Scripts (Root)

Scripts in the fixtures root for direct testing:

| File | Purpose |
|------|---------|
| `sample-complete.sh` | Full-featured BCS-compliant script |
| `sample-minimal.sh` | Minimal BCS-compliant script |
| `sample-non-compliant.sh` | Script with deliberate violations |

## valid-scripts/

BCS-compliant scripts that should pass validation:
- `minimal-compliant.sh` - Minimal BCS-compliant script

## invalid-scripts/

Non-compliant scripts for negative testing:
- `no-shebang.sh` - Missing shebang line
- `no-set-options.sh` - Missing `set -euo pipefail`
- `no-fin-marker.sh` - Missing `#fin` end marker

## test-rules/

Sample BCS rule files for testing data structure parsing:
- `99-test-rule.complete.md` - Complete tier test rule
- `99-test-rule.summary.md` - Summary tier test rule
- `99-test-rule.abstract.md` - Abstract tier test rule

## templates/

Reserved directory for expected template outputs (currently empty).

## Usage in Tests

```bash
# Test compliance checking
./bcs check tests/fixtures/valid-scripts/minimal-compliant.sh

# Test against non-compliant script
./bcs check tests/fixtures/sample-non-compliant.sh

# Compare template output
diff <(./bcs template -t minimal) tests/fixtures/sample-minimal.sh
```

## Maintenance

- Keep fixtures synchronized with BCS standard updates
- Add new fixtures when new test cases are needed
- Document fixture characteristics in script comments
