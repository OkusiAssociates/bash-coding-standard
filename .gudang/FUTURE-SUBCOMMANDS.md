# Future BCS Subcommands Design

This document outlines the design for additional subcommands to be added to the `bcs` toolkit. These commands extend the toolkit's capabilities for practical development workflows.

## Design Principles

All subcommands must:
1. Follow BASH-CODING-STANDARD.md patterns
2. Pass `shellcheck -x` validation
3. Provide comprehensive `--help` output
4. Support both short (`-x`) and long (`--xxx`) options
5. Return proper exit codes (0=success, 1=error, 2=usage error)
6. Include comprehensive test coverage

## Priority Classification

- **HIGH** - Critical for daily development workflow
- **MEDIUM** - Useful but not essential
- **LOW** - Nice-to-have features

---

## 1. template - Generate Script Templates

**Priority:** HIGH

**Aliases:** `tpl`, `new`

### Purpose
Generate new Bash scripts from compliant templates following BASH-CODING-STANDARD.md structure.

### Usage
```bash
bcs template [OPTIONS] [NAME]
bcs template SCRIPTNAME           # Create script from default template
bcs template -t minimal SCRIPT    # Minimal template (no colors, basic functions)
bcs template -t full SCRIPT       # Full template (all utility functions)
bcs template -t library SCRIPT    # Library template (sourceable only)
```

### Options
- `-t, --type TYPE` - Template type: minimal, basic (default), full, library
- `-o, --output FILE` - Output file path (default: ./NAME)
- `-f, --force` - Overwrite existing file
- `-x, --executable` - Make executable (chmod +x) after creation
- `-e, --edit` - Open in $EDITOR after creation
- `--no-shopt` - Exclude shopt settings
- `--no-colors` - Exclude color definitions
- `--no-metadata` - Exclude script metadata

### Template Types

#### minimal
```bash
#!/usr/bin/env bash
# [DESCRIPTION]
set -euo pipefail

error() { >&2 echo "$0: $*"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

main() {
  # TODO: Add implementation
  echo 'Hello from minimal template'
}

main "$@"
#fin
```

#### basic (default)
- Includes: shopt settings, script metadata, basic messaging functions
- Functions: `_msg()`, `error()`, `die()`
- ~40 lines

#### full
- Includes: All utility functions from Section 9
- Functions: `_msg()`, `vecho()`, `success()`, `warn()`, `info()`, `debug()`, `error()`, `die()`, `yn()`
- Color support
- Verbose flag
- ~80 lines

#### library
- Dual-purpose sourceable library template
- No `set -e` (respects caller's shell)
- All functions ready for export
- Version and metadata
- ~50 lines

### Implementation Notes
- Store templates in `data/templates/` directory
- Templates use placeholder variables: `{{NAME}}`, `{{DESCRIPTION}}`, `{{DATE}}`, `{{VERSION}}`
- Validate template completeness before generation
- Default description: "TODO: Add script description"

### Exit Codes
- `0` - Template created successfully
- `1` - File exists (without --force), template error
- `2` - Invalid template type, missing arguments

---

## 2. check - Validate Script Compliance

**Priority:** HIGH

**Aliases:** `lint`, `verify`

### Purpose
Validate Bash scripts against BASH-CODING-STANDARD.md rules with detailed compliance reporting.

### Usage
```bash
bcs check SCRIPT               # Check single script
bcs check SCRIPT1 SCRIPT2      # Check multiple scripts
bcs check *.sh                 # Check all .sh files
bcs check -r DIR               # Recursive check
```

### Options
- `-r, --recursive` - Check directory recursively
- `-q, --quiet` - Show only failures
- `-v, --verbose` - Show detailed rule checking
- `-f, --fix` - Auto-fix simple issues (spacing, trailing whitespace)
- `--ignore RULE` - Ignore specific BCS rule (can be used multiple times)
- `--report FILE` - Generate compliance report (markdown format)
- `--strict` - Enable strict mode (fail on warnings)
- `--no-shellcheck` - Skip ShellCheck validation

### Validation Checks

**Structure (BCS01):**
- ✓ Shebang present and correct
- ✓ `set -euo pipefail` present
- ✓ Script metadata declared
- ✓ `#fin` marker at end
- ✓ `main()` function for scripts >40 lines

**Variables (BCS02):**
- ✓ Type-specific declarations (`declare -i`, `declare --`, etc.)
- ✓ Constants are readonly
- ✓ Boolean flags use integer type

**Quoting (BCS04):**
- ✓ Static strings use single quotes
- ✓ Variables in conditionals are quoted
- ✓ Array expansions use `"${array[@]}"`

**Functions (BCS06):**
- ✓ Bottom-up organization
- ✓ Lowercase with underscores naming

**Error Handling (BCS08):**
- ✓ Proper exit codes
- ✓ Error output to STDERR
- ✓ Return value checking

**Security (BCS12):**
- ✓ No SUID/SGID
- ✓ Explicit wildcard paths
- ✓ No raw `eval` usage

**ShellCheck:**
- ✓ Passes `shellcheck -x` (compulsory)
- ✓ Documents any disabled checks

### Output Format
```
Checking: my-script.sh
  [✓] BCS0102: Shebang present and correct
  [✓] BCS0104: set -euo pipefail present
  [✗] BCS0402: Static string uses double quotes (line 42)
  [⚠] BCS0611: main() function recommended for 67-line script
  [✓] ShellCheck: No issues found

Summary: 12/14 checks passed (2 issues, 1 warning)
Exit code: 1 (compliance issues found)
```

### Implementation Notes
- Parse script with bash AST or regex patterns
- Use `shellcheck` for syntax validation
- Provide line numbers for all issues
- Support multiple scripts in single run
- Generate machine-readable JSON report with `--report=json`

### Exit Codes
- `0` - All scripts compliant
- `1` - Compliance issues found
- `2` - Invalid arguments, file not found

---

## 3. init - Initialize New Project

**Priority:** MEDIUM

**Aliases:** `create`, `scaffold`

### Purpose
Initialize a new Bash project with standard structure, templates, and configuration files.

### Usage
```bash
bcs init PROJECT_NAME          # Create new project
bcs init -t library LIBNAME    # Create library project
bcs init -t tool TOOLNAME      # Create CLI tool project
```

### Options
- `-t, --type TYPE` - Project type: tool (default), library, automation, testing
- `-d, --directory DIR` - Create in specific directory (default: ./PROJECT_NAME)
- `--git` - Initialize git repository
- `--license TYPE` - Add license (mit, gpl3, apache2, cc-by-sa)
- `--readme` - Generate comprehensive README.md
- `--makefile` - Generate Makefile for installation
- `--tests` - Generate test structure with helpers

### Project Types

#### tool (default)
CLI tool with subcommand dispatcher:
```
project-name/
├── README.md
├── LICENSE
├── Makefile
├── project-name              # Main script
├── lib/                      # Library modules
│   └── common.sh
├── tests/
│   ├── test-helpers.sh
│   └── test-main.sh
└── docs/
    └── USAGE.md
```

#### library
Sourceable library package:
```
libname/
├── README.md
├── LICENSE
├── libname.sh                # Main library
├── lib/
│   ├── core.sh
│   └── utils.sh
├── examples/
│   └── example-usage.sh
└── tests/
    └── test-library.sh
```

#### automation
Automation script collection:
```
automation/
├── README.md
├── scripts/
│   ├── deploy.sh
│   ├── backup.sh
│   └── monitor.sh
├── config/
│   └── settings.conf
└── tests/
    └── test-scripts.sh
```

#### testing
Test framework setup:
```
testing/
├── README.md
├── tests/
│   ├── test-helpers.sh
│   ├── run-all-tests.sh
│   └── test-example.sh
└── lib/
    └── test-fixtures.sh
```

### Generated Files

**README.md:** Project description, usage, installation instructions

**Makefile:** Standard targets:
- `install` - Install to PREFIX (default /usr/local)
- `uninstall` - Remove installation
- `test` - Run test suite
- `check` - Run shellcheck on all scripts
- `clean` - Remove generated files

**Main script:** Generated from appropriate template

**tests/test-helpers.sh:** Standard test functions:
- `test_section()`, `pass()`, `fail()`, `assert_equals()`, etc.

### Implementation Notes
- Validate project name (alphanumeric + hyphens)
- Check directory doesn't exist (or use --force)
- Create directory structure
- Generate all files from templates
- Make scripts executable
- Initialize git if requested
- Display completion message with next steps

### Exit Codes
- `0` - Project created successfully
- `1` - Directory exists, invalid name, template error
- `2` - Invalid arguments

---

## 4. validate - Comprehensive Script Validation

**Priority:** MEDIUM

**Aliases:** `test`, `ci`

### Purpose
Comprehensive validation suite combining multiple checks for CI/CD integration. More thorough than `bcs check`.

### Usage
```bash
bcs validate SCRIPT            # Full validation suite
bcs validate --ci SCRIPT       # CI-friendly output
bcs validate --report SCRIPT   # Generate detailed report
```

### Options
- `--ci` - CI-friendly output (exit codes, no colors, JSON results)
- `--report FILE` - Generate comprehensive report (markdown or JSON)
- `--fix` - Attempt auto-fixes where possible
- `--strict` - Treat warnings as errors
- `--no-shellcheck` - Skip ShellCheck
- `--no-syntax` - Skip syntax validation
- `--no-compliance` - Skip BCS compliance checks

### Validation Suite

1. **Syntax validation** (`bash -n`)
   - Parse errors
   - Syntax issues

2. **ShellCheck** (`shellcheck -x`)
   - All ShellCheck warnings/errors
   - Documented exceptions

3. **BCS compliance** (from `bcs check`)
   - All BASH-CODING-STANDARD.md rules
   - Structure, quoting, functions, error handling

4. **Security checks**
   - SUID/SGID detection
   - Dangerous patterns (`eval`, `rm *`, etc.)
   - Input sanitization
   - PATH security

5. **Best practices**
   - Function complexity (lines per function)
   - Script length (recommend splitting at 500 lines)
   - TODO/FIXME/HACK comments
   - Unused functions (if detectable)

6. **Style consistency**
   - Consistent indentation
   - Line length (max 100 chars)
   - Trailing whitespace
   - Consistent function naming

### Output Format
```
=== Validating: my-script.sh ===

[1/6] Syntax validation... ✓ PASS
[2/6] ShellCheck validation... ✓ PASS
[3/6] BCS compliance... ✗ FAIL (2 issues)
      - Line 42: BCS0402 Static string uses double quotes
      - Line 67: BCS0611 main() recommended for this script
[4/6] Security checks... ✓ PASS
[5/6] Best practices... ⚠ WARN (1 issue)
      - Line 123: TODO comment found
[6/6] Style consistency... ✓ PASS

=== Summary ===
Passed: 4/6 checks
Failed: 1 check (BCS compliance)
Warnings: 1 check (best practices)

Overall: FAIL (1 critical issue, 1 warning)
Exit code: 1
```

### CI Integration
```bash
# .github/workflows/validate.yml
- name: Validate scripts
  run: |
    ./bcs validate --ci --report=validation-report.json scripts/*.sh

# Exit codes for CI
- 0: All checks passed
- 1: Validation failed (fail the build)
- 2: Invalid usage
```

### Implementation Notes
- Combine results from multiple validators
- Cache validation results where possible
- Support parallel validation of multiple files
- Generate detailed reports for review
- Provide fix suggestions where possible

### Exit Codes
- `0` - All validations passed
- `1` - Validation failures found
- `2` - Invalid arguments, file not found

---

## 5. format - Format Existing Scripts

**Priority:** LOW

**Aliases:** `fmt`, `beautify`

### Purpose
Automatically format Bash scripts to comply with BASH-CODING-STANDARD.md style guidelines. Non-destructive with backup support.

### Usage
```bash
bcs format SCRIPT              # Format script (creates .bak)
bcs format --in-place SCRIPT   # Format without backup
bcs format --diff SCRIPT       # Show diff without applying
```

### Options
- `-i, --in-place` - Format without creating backup
- `-d, --diff` - Show changes without applying
- `-b, --backup EXT` - Backup extension (default: .bak)
- `--no-backup` - Don't create backup (dangerous)
- `--indent SIZE` - Indentation spaces (default: 2)
- `--line-length NUM` - Max line length (default: 100)
- `--check` - Check if formatting needed (exit code only)

### Formatting Rules

**Indentation:**
- 2 spaces per level (configurable)
- Align continuation lines

**Spacing:**
- Space after `#` in comments
- Space around `=` in assignments (when allowed)
- Space before `{` in function definitions
- Remove trailing whitespace

**Line breaks:**
- Keep functions separated by one blank line
- Two blank lines between sections
- Split long lines at pipes and logical operators

**Quoting:**
- Convert static double quotes to single quotes
- Ensure variable quoting in conditionals

**Comments:**
- Normalize comment spacing
- Align inline comments (when possible)

### What Won't Be Changed
- Variable names (compliance, not cosmetic)
- Function names (would break functionality)
- Logic or control flow
- Quoted content (respects literal strings)

### Output
```
Formatting: my-script.sh
  ✓ Fixed indentation (12 lines)
  ✓ Normalized spacing (5 lines)
  ✓ Converted quotes (3 lines)
  ✓ Removed trailing whitespace (2 lines)

Backup created: my-script.sh.bak
Changes applied: 22 lines modified

You can review changes with:
  diff my-script.sh.bak my-script.sh
```

### Implementation Notes
- Use bash parser or careful regex patterns
- Preserve original file permissions
- Create backup before any changes
- Support dry-run mode (`--diff`)
- Detect if script is already formatted (`--check`)
- Log all changes for review

### Exit Codes
- `0` - Formatting successful (or no changes needed)
- `1` - Formatting errors, file permissions
- `2` - Invalid arguments

### Safety Features
- Always create backup by default
- Validate syntax before and after formatting
- Abort if post-format validation fails
- Provide detailed diff for review

---

## 6. about - Display Project Information

**Priority:** HIGH

**Aliases:** `info`, `version`

### Purpose
Display comprehensive information about the Bash Coding Standard project, including philosophy, statistics, and references. Serves as an introduction for new users and quick reference for project details.

### Usage
```bash
bcs about                      # Show general information
bcs about -s                   # Show statistics only
bcs about -v                   # Show verbose information
bcs about --quote              # Show only the philosophy quote
```

### Options
- `-s, --stats` - Show statistics only (sections, rules, files, lines)
- `-l, --links` - Show links and references only
- `-v, --verbose` - Show all information (default + stats + links)
- `-q, --quote` - Show only the philosophy quote
- `--json` - Output as JSON for scripting

### Default Output

Display concise, informative overview:

```
Bash Coding Standard (BCS) v1.0.0

A comprehensive coding standard for modern Bash 5.2+ scripts, designed for
consistency, robustness, and maintainability.

"This isn't just a coding standard - it's a systems engineering philosophy
applied to Bash." -- Biksu Okusi

Coding Principles:
  • K.I.S.S. (Keep It Simple, Stupid)
  • "The best process is no process"
  • "Everything should be made as simple as possible, but not any simpler."

Quick Stats:
  14 major sections  |  ~99 BCS rules  |  2,145 lines  |  13 test files

Developed by:  Okusi Associates (https://okusiassociates.com)
Adopted by:    Indonesian Open Technology Foundation (YaTTI)
License:       CC BY-SA 4.0
Repository:    https://github.com/OkusiAssociates/bash-coding-standard

Learn more:  bcs help
View standard: bcs display
```

### Statistics Output (`--stats`)

```bash
$ bcs about --stats

=== Bash Coding Standard Statistics ===

Structure:
  Sections:           14
  Rules:              99 BCS codes
  Subrules:          ~30 nested rules

Documentation:
  Standard size:      2,145 lines (full)
                      ~800 lines (concise)
                      ~1,400 lines (balanced)
  Source files:       283 .md files in data/
  Data directory:     14 section directories

Code Quality:
  Test files:         13 comprehensive test scripts
  Test coverage:      Core functionality + all 6 subcommands
  ShellCheck:         All scripts pass validation

Repository:
  Main script:        bash-coding-standard (v1.0.0)
  Subcommands:        6 (display, codes, generate, search, explain, sections)
  License:            CC BY-SA 4.0
```

### Links Output (`--links`)

```bash
$ bcs about --links

=== Bash Coding Standard Links ===

Documentation:
  • Main standard:    BASH-CODING-STANDARD.md
  • Repository:       https://github.com/OkusiAssociates/bash-coding-standard
  • FAQ/Rebuttals:    REBUTTALS-FAQ.md
  • Future plans:     FUTURE-SUBCOMMANDS.md

Organizations:
  • Okusi Associates: https://okusiassociates.com
  • YaTTI:            https://yatti.id

References:
  • Google Shell Style Guide:    https://google.github.io/styleguide/shellguide.html
  • ShellCheck:                  https://www.shellcheck.net/
  • Bash Reference Manual:       https://www.gnu.org/software/bash/manual/bash.html
  • Advanced Bash-Scripting:     https://tldp.org/LDP/abs/html/

License:
  • CC BY-SA 4.0:                https://creativecommons.org/licenses/by-sa/4.0/
```

### Verbose Output (`--verbose`)

Combines all sections:
- Default output (philosophy, principles, quick stats)
- Complete statistics (--stats output)
- All links and references (--links output)
- Table of contents (14 sections listed)

### Quote Output (`--quote`)

```bash
$ bcs about --quote

"This isn't just a coding standard - it's a systems engineering philosophy
applied to Bash."
                                                        -- Biksu Okusi

Coding Principles:
  • K.I.S.S. (Keep It Simple, Stupid)
  • "The best process is no process"
  • "Everything should be made as simple as possible, but not any simpler."

NOTE: Do not over-engineer scripts; functions and variables not required
for the operation of the script should not be included and/or removed.
```

### JSON Output (`--json`)

```bash
$ bcs about --json

{
  "name": "Bash Coding Standard",
  "abbreviation": "BCS",
  "version": "1.0.0",
  "bash_version": "5.2+",
  "description": "A comprehensive coding standard for modern Bash scripts",
  "philosophy": "This isn't just a coding standard - it's a systems engineering philosophy applied to Bash.",
  "author": "Biksu Okusi",
  "statistics": {
    "sections": 14,
    "rules": 99,
    "lines": {
      "full": 2145,
      "balanced": 1400,
      "concise": 800
    },
    "source_files": 283,
    "test_files": 13
  },
  "organizations": {
    "developer": "Okusi Associates",
    "adopter": "Indonesian Open Technology Foundation (YaTTI)"
  },
  "license": "CC BY-SA 4.0",
  "repository": "https://github.com/OkusiAssociates/bash-coding-standard",
  "references": {
    "google_style": "https://google.github.io/styleguide/shellguide.html",
    "shellcheck": "https://www.shellcheck.net/",
    "bash_manual": "https://www.gnu.org/software/bash/manual/bash.html"
  }
}
```

### Implementation Notes

**Data Sources:**
1. **Header content:** Read from `data/00-header.md` for philosophy and principles
2. **Version:** Extract from `bash-coding-standard` script (`VERSION` variable)
3. **Statistics:**
   - Count sections: `ls -d data/[0-9][0-9]-* | wc -l`
   - Count rules: `./bcs codes | wc -l`
   - Count lines: `wc -l < BASH-CODING-STANDARD.md`
   - Count source files: `find data/ -name '*.md' | wc -l`
   - Count test files: `find tests/ -name 'test-*.sh' | wc -l`
4. **Links:** Hardcoded references (from README.md)

**Formatting:**
- Use colors for section headers (when terminal)
- Align statistics in columns
- Box drawing for visual appeal (optional)
- Respect terminal width for word wrapping

**Caching:**
- Cache statistics for performance (recalculate on --force)
- Stats rarely change, avoid recomputing every time

**Dependencies:**
- Must work without external dependencies
- Falls back gracefully if files missing
- JSON output requires valid JSON (no comments)

### Use Cases

1. **New users:** First command to understand BCS
   ```bash
   bcs about
   ```

2. **CI/CD:** Get version programmatically
   ```bash
   bcs about --json | jq -r '.version'
   ```

3. **Documentation:** Quick statistics reference
   ```bash
   bcs about --stats
   ```

4. **Teaching:** Show philosophy and principles
   ```bash
   bcs about --quote
   ```

5. **Integration:** Link to external resources
   ```bash
   bcs about --links | grep "ShellCheck"
   ```

### Exit Codes
- `0` - Information displayed successfully
- `1` - Error reading files, invalid option
- `2` - Invalid arguments

### Testing Requirements

**test-subcommand-about.sh:**
- Default output contains key elements (version, philosophy, stats)
- Statistics are accurate (count matches reality)
- Links are valid URLs
- JSON output is valid and parseable
- Quote output contains philosophy
- Verbose combines all sections
- Exit codes correct
- Works without color support
- Handles missing files gracefully

---

## Implementation Priority Order

Based on development workflow impact:

1. **HIGH Priority (Implement First):**
   - `bcs about` - Essential onboarding, helps new users understand BCS
   - `bcs template` - Daily use for new scripts
   - `bcs check` - Continuous validation during development

2. **MEDIUM Priority (Implement Second):**
   - `bcs init` - Useful for new projects
   - `bcs validate` - CI/CD integration

3. **LOW Priority (Implement Later):**
   - `bcs format` - Nice-to-have, risky to automate

## Testing Requirements

Each subcommand must have comprehensive test coverage:

**test-subcommand-about.sh:**
- Default output contains all key elements
- Statistics accuracy
- JSON output validation
- Links and quote output
- Exit codes

**test-subcommand-template.sh:**
- Template generation for all types
- File overwrite protection
- Option handling
- Placeholder substitution

**test-subcommand-check.sh:**
- Individual rule validation
- Multiple file checking
- Report generation
- Exit codes

**test-subcommand-init.sh:**
- Project structure creation
- Git initialization
- All project types
- File generation

**test-subcommand-validate.sh:**
- All validation checks
- CI mode output
- Report generation
- Exit codes

**test-subcommand-format.sh:**
- Formatting rules application
- Backup creation
- Diff generation
- Syntax preservation

## Documentation Requirements

Each subcommand requires:

1. **README.md section** - Usage examples, quick reference
2. **Comprehensive `--help`** - All options, examples
3. **Test coverage** - Dedicated test file
4. **Code examples** - Real-world usage patterns

## Future Enhancements

Possible additions after core 6 subcommands:

- `bcs refactor` - Automated refactoring patterns
- `bcs analyze` - Complexity analysis, metrics
- `bcs migrate` - Migrate non-compliant scripts
- `bcs docs` - Generate documentation from scripts
- `bcs profile` - Performance profiling
- `bcs package` - Package scripts for distribution

---

**Status:** Design phase complete, ready for implementation prioritization

**Summary:** 6 future subcommands designed and specified:
1. `bcs about` - Display project information (HIGH)
2. `bcs template` - Generate script templates (HIGH)
3. `bcs check` - Validate script compliance (HIGH)
4. `bcs init` - Initialize new project (MEDIUM)
5. `bcs validate` - Comprehensive validation suite (MEDIUM)
6. `bcs format` - Format existing scripts (LOW)

**Next Steps:**
1. Review design with maintainers
2. Implement HIGH priority commands first (`about`, `template`, `check`)
3. Create templates and validation rules
4. Add comprehensive test coverage
5. Update README.md with new subcommands

*Last updated: 2025-10-13*
