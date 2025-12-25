# BCS Code Migration: Old to New Mapping

This document provides a complete mapping of BCS codes from the original 14-section structure (v1.0.0) to the new 12-section structure (v2.0.0).

**Migration Date:** 2025-12-24
**Reason:** Section consolidation and rebalancing

---

## Summary of Changes

| Change Type | Count | Description |
|-------------|-------|-------------|
| Unchanged | ~40 | Same code, same content |
| Renumbered | ~35 | Different code, same content |
| Merged | ~15 | Multiple old codes → one new code |
| New | ~12 | New content added |
| Deleted | ~12 | Removed (minor/redundant) |

---

## Section Mapping

| Old Section | New Section | Change |
|-------------|-------------|--------|
| 01 Script Structure | 01 Script Structure | Unchanged |
| 02 Variables | 02 Variables & Data | Content added |
| 03 Expansion | (merged into 02) | Deleted |
| 04 Quoting | 03 Strings & Quoting | Renumbered + condensed |
| 05 Arrays | (merged into 02) | Deleted |
| 06 Functions | 04 Functions & Libraries | Renumbered + expanded |
| 07 Control Flow | 05 Control Flow | Renumbered + expanded |
| 08 Error Handling | 06 Error Handling | Renumbered |
| 09 I/O Messaging | 07 I/O & Messaging | Renumbered + expanded |
| 10 Command-Line | 08 Command-Line | Renumbered |
| 11 File Operations | 09 File Operations | Renumbered |
| 12 Security | 10 Security | Renumbered |
| 13 Code Style | (merged into 12) | Merged |
| 14 Advanced | 11 Concurrency + 12 Style | Split |

---

## Complete Code Mapping

### Section 01: Script Structure & Layout

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS0101 | BCS0101 | Unchanged | Script Layout |
| BCS010101 | BCS010101 | Unchanged | Complete Example |
| BCS010102 | BCS010102 | Unchanged | Anti-Patterns |
| BCS010103 | BCS010103 | Unchanged | Edge Cases |
| BCS0102 | BCS0102 | Unchanged | Shebang |
| BCS010201 | BCS0406 | **Elevated** | Dual-Purpose Scripts |
| BCS0103 | BCS0103 | Unchanged | Metadata |
| BCS0104 | BCS0104 | Unchanged | FHS Compliance |
| BCS0105 | BCS0105 | Unchanged | shopt Settings |
| BCS0106 | BCS0106 | Unchanged | File Extensions |
| BCS0107 | BCS0107 | Unchanged | Function Organization |

### Section 02: Variables & Data Types

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS0201 | BCS0201 | Unchanged | Type-Specific Declarations |
| BCS0202 | BCS0202 | Unchanged | Variable Scoping |
| BCS0203 | BCS0203 | Unchanged | Naming Conventions |
| BCS0204 | BCS0204 | Unchanged | Constants & Environment |
| BCS0205 | BCS0205 | **Merged** | Readonly Patterns (+ old 0206) |
| BCS0206 | (merged) | Merged into 0205 | Readonly Declaration |
| BCS0207 | BCS0206 | Renumbered | Boolean Flags |
| BCS0208 | BCS0208 | Reserved | Reserved for Future |
| BCS0209 | BCS0209 | Unchanged | Derived Variables |
| BCS0301 | BCS0210 | **Merged** | Parameter Expansion (+ 0302) |
| BCS0302 | (merged) | Merged into 0210 | Braces Usage |
| BCS0501 | BCS0207 | **Merged** | Arrays (+ 0502) |
| BCS0502 | (merged) | Merged into 0207 | Safe List Handling |

### Section 03: Strings & Quoting (formerly Section 04)

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS0401 | BCS0301 | **Merged** | Quoting Fundamentals |
| BCS0402 | (merged) | Merged into 0301 | One-Word Literals |
| BCS0403 | (merged) | Merged into 0301 | Strings with Variables |
| BCS0404 | (merged) | Merged into 0301 | Mixed Quoting |
| BCS0405 | BCS0302 | Renumbered | Command Substitution |
| BCS0406 | BCS0303 | Renumbered | Quoting in Conditionals |
| BCS0407 | (merged) | Moved to BCS0207 | Array Expansions |
| BCS0408 | BCS0304 | **Merged** | Here Documents (+ 1104) |
| BCS0409 | BCS0305 | Renumbered | printf Patterns |
| BCS0410 | (deleted) | **Deleted** | Summary Decision Tree |
| BCS0411 | BCS0307 | Renumbered | Anti-Patterns |
| BCS0412 | (deleted) | **Deleted** | String Trimming |
| BCS0413 | (deleted) | **Deleted** | Displaying Variables |
| BCS0414 | (deleted) | **Deleted** | Pluralization |
| BCS0415 | BCS0306 | Renumbered | Parameter Quoting |

### Section 04: Functions & Libraries (formerly Section 06)

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS0601 | BCS0401 | Renumbered | Definition Pattern |
| BCS0602 | BCS0402 | Renumbered | Function Naming |
| BCS0603 | BCS0403 | Renumbered | main() Function |
| BCS0604 | BCS0404 | Renumbered | Function Export |
| BCS0605 | BCS0405 | Renumbered | Production Optimization |
| BCS010201 | BCS0406 | **Elevated** | Dual-Purpose Scripts |
| - | BCS0407 | **New** | Library Patterns |
| - | BCS0408 | **New** | Dependency Management |

### Section 05: Control Flow (formerly Section 07)

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS0701 | BCS0501 | Renumbered | Conditionals |
| BCS0702 | BCS0502 | Renumbered | Case Statements |
| BCS0703 | BCS0503 | Renumbered | Loops |
| BCS0704 | BCS0504 | Renumbered | Process Substitution |
| BCS0705 | BCS0505 | Renumbered | Arithmetic |
| - | BCS0506 | **New** | Floating-Point Operations |

### Section 06: Error Handling (formerly Section 08)

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS0801 | BCS0601 | Renumbered | set -e |
| BCS0802 | BCS0602 | Renumbered | Exit Codes |
| BCS0803 | BCS0603 | Renumbered | Trap Handling |
| BCS0804 | BCS0604 | Renumbered | Return Value Checking |
| BCS0805 | BCS0605 | Renumbered | Error Suppression |
| BCS0806 | BCS0606 | Renumbered | Conditional Declarations |

### Section 07: I/O & Messaging (formerly Section 09)

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS0901 | BCS0701 | Renumbered | Color Support |
| BCS0902 | BCS0702 | Renumbered | STDOUT/STDERR |
| BCS0903 | BCS0703 | Renumbered | Core Messaging Functions |
| BCS0904 | BCS0704 | Renumbered | Usage/Documentation |
| BCS0905 | BCS0705 | Renumbered | echo vs Messaging |
| BCS0906 | BCS0706 | Renumbered | Color Management |
| - | BCS0707 | **New** | TUI Basics |
| - | BCS0708 | **New** | Terminal Capabilities |

### Section 08: Command-Line Arguments (formerly Section 10)

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS1001 | BCS0801 | Renumbered | Parsing Pattern |
| BCS1002 | BCS0802 | Renumbered | Version Format |
| BCS1003 | BCS0803 | Renumbered | Validation/noarg |
| BCS1004 | BCS0804 | Renumbered | Parsing Location |
| BCS1005 | BCS0805 | Renumbered | Short Option Deaggregation |

### Section 09: File Operations (formerly Section 11)

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS1101 | BCS0901 | Renumbered | File Testing |
| BCS1102 | BCS0902 | Renumbered | Wildcard Expansion |
| BCS1103 | BCS0903 | Renumbered | Process Substitution |
| BCS1104 | (merged) | Merged into BCS0304 | Here Documents |
| BCS1105 | BCS0904 | Renumbered | Redirect Input |

### Section 10: Security (formerly Section 12)

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS1201 | BCS1001 | Renumbered | SUID/SGID |
| BCS1202 | BCS1002 | Renumbered | PATH Security |
| BCS1203 | BCS1003 | Renumbered | IFS Safety |
| BCS1204 | BCS1004 | Renumbered | Eval Avoidance |
| BCS1205 | BCS1005 | Renumbered | Input Sanitization |
| BCS1403 | BCS1006 | **Moved** | Temp File Security |

### Section 11: Concurrency & Jobs (NEW)

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS1406 | BCS1101 | **Moved** | Background Jobs |
| - | BCS1102 | **New** | Parallel Execution |
| - | BCS1103 | **New** | Wait Patterns |
| - | BCS1104 | **New** | Timeout Handling |
| - | BCS1105 | **New** | Exponential Backoff |

### Section 12: Style & Development (formerly 13+14)

| Old Code | New Code | Status | Topic |
|----------|----------|--------|-------|
| BCS1301 | BCS1201 | Renumbered | Code Formatting |
| BCS1302 | BCS1202 | Renumbered | Comments |
| BCS1303 | BCS1203 | Renumbered | Blank Lines |
| BCS1304 | BCS1204 | Renumbered | Section Markers |
| BCS1305 | BCS1205 | Renumbered | Language Practices |
| BCS1306 | BCS1206 | Renumbered | Development Practices |
| BCS1307 | (deleted) | **Deleted** | Emoticons |
| BCS1401 | BCS1207 | **Moved** | Debugging |
| BCS1402 | BCS1208 | **Moved** | Dry-Run Mode |
| BCS1403 | BCS1006 | **Moved** | Temp Files (→ Security) |
| BCS1404 | (merged) | Merged into BCS0204 | Environment Variables |
| BCS1405 | (merged) | Merged into BCS0301 | Regular Expressions |
| BCS1406 | BCS1101 | **Moved** | Background Jobs (→ Concurrency) |
| BCS1407 | (merged) | Merged into BCS0703 | Logging |
| BCS1408 | (deleted) | **Deleted** | Performance Profiling |
| BCS1409 | BCS1209 | **Moved** | Testing |
| BCS1410 | BCS1210 | **Moved** | Progressive State |

---

## Deleted Rules

These rules were removed as too minor or redundant:

| Old Code | Topic | Reason |
|----------|-------|--------|
| BCS0410 | Summary Decision Tree | Redundant with quoting rules |
| BCS0412 | String Trimming | Minor utility pattern |
| BCS0413 | Displaying Variables | Minor debugging pattern |
| BCS0414 | Pluralization | Minor helper pattern |
| BCS1307 | Emoticons | Too minor for standard |
| BCS1408 | Performance Profiling | Too specialized |

---

## New Rules Added

| New Code | Topic | Description |
|----------|-------|-------------|
| BCS0407 | Library Patterns | Sourcing, namespacing, exports |
| BCS0408 | Dependency Management | Checking deps, lazy loading |
| BCS0506 | Floating-Point | bc/awk integration |
| BCS0707 | TUI Basics | Cursor control, progress bars |
| BCS0708 | Terminal Capabilities | Feature detection |
| BCS1102 | Parallel Execution | Background job patterns |
| BCS1103 | Wait Patterns | Job synchronization |
| BCS1104 | Timeout Handling | timeout command patterns |
| BCS1105 | Exponential Backoff | Retry strategies |

---

## Migration Notes

### For Existing Scripts

If you have scripts referencing old BCS codes in comments:

```bash
# Old comment style:
# Compliant with BCS0701, BCS0705

# New comment style:
# Compliant with BCS0501, BCS0505
```

### For Documentation

Update any external documentation that references BCS codes using this mapping.

### For Automated Tools

Update any linting or compliance checking tools to use new code numbers.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-XX-XX | Original 14-section structure |
| 2.0.0 | 2025-12-24 | Restructured to 12 sections |

#fin
