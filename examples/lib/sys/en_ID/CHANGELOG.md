# Changelog

All notable changes to the en_ID locale will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2026-03-09

### Added
- 8 new tests for LC_MONETARY fields, `postal_fmt`, and `lang_lib` (47 total)

### Changed
- Installer scripts refactored for BCS compliance (PATH hardening, messaging functions, error handling)
- CI workflow now tests across Ubuntu 22.04, 24.04, 26.04 (was 3 identical ubuntu-latest jobs)

### Fixed
- Makefile `check` target now properly validates locale syntax
- Makefile `.PHONY` missing `info` and `help` targets
- README `int_select` documentation (001 → 00)

### Removed
- Vestigial `[1.1.0] - Unreleased` CHANGELOG section

## [2.0.0] - 2024-12-13

### Added
- LC_TIME: Added `date_fmt` for ISO 8601 consistency in `date(1)` output
- LC_TIME: Added `week` definition (7;19971130;4) for ISO 8601 week numbering
- LC_TIME: Added proper 12-hour time support (`am_pm`, `t_fmt_ampm`)
- LC_ADDRESS: Added `country_name`, `lang_name`, `country_car`, `lang_ab`, `lang_term`, `lang_lib`
- LC_TELEPHONE: Added `tel_dom_fmt`, `int_select`, `int_prefix`
- Test suite expanded to 39 tests across 10 categories
- Locale Categories Reference table in README

### Changed
- Locale revision bumped to 2.0
- LC_TIME: `d_t_fmt` now uses ISO 8601 hybrid format (`%a %Y-%m-%d %T`)
- LC_TELEPHONE: `tel_dom_fmt` includes trunk prefix 0 for correct domestic dialing
- LC_TELEPHONE: `int_select` changed from "001" to "00" (generic international prefix)
- LC_MONETARY: `n_sign_posn` changed from 0 to 1 (minus prefix instead of parentheses)
- LC_NAME: Updated comments to accurately describe minimal definition
- README: Expanded Features table, added datetime/week/12-hour info
- README: Fixed currency format documentation (no space: Rp1,234.56)

### Fixed
- LC_TIME: Removed FIXME comment, replaced with proper week definition
- LC_TELEPHONE: `tel_int_fmt` formatting (removed extra semicolons)
- Documentation/code mismatch in LC_NAME comments

## [1.0.0] - 2024-06-26

### Added
- Initial release of en_ID locale
- Support for English language with Indonesian regional settings
- Complete locale definition covering all standard categories:
  - LC_MONETARY: Indonesian Rupiah (IDR) formatting
  - LC_NUMERIC: Decimal point and comma thousands separator
  - LC_TIME: 24-hour format with ISO 8601 dates
  - LC_MESSAGES: English yes/no strings (inherited from en_SG)
  - LC_PAPER: A4 paper size
  - LC_ADDRESS: Indonesian country codes
  - LC_TELEPHONE: International dialing format
  - LC_MEASUREMENT: Metric system
- Comprehensive test suite
- Build system using Makefile
- GitHub Actions CI/CD workflow
- Documentation and contribution guidelines

### Technical Details
- Based on en_GB for British English spelling
- Incorporates Indonesian formatting conventions
- Compatible with GNU libc locale system
- UTF-8 character encoding

[2.1.0]: https://github.com/Open-Technology-Foundation/en_ID/releases/tag/v2.1.0
[2.0.0]: https://github.com/Open-Technology-Foundation/en_ID/releases/tag/v2.0.0
[1.0.0]: https://github.com/Open-Technology-Foundation/en_ID/releases/tag/v1.0.0