# English Locale for Indonesia (en_ID)

A locale definition for English language users in Indonesia, combining international English standards with Indonesian regional conventions.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Design Decisions](#design-decisions)
- [Contributing](#contributing)
- [License](#license)

## Overview

The `en_ID` locale provides English language support tailored for Indonesia. It combines:
- **British English** spelling conventions (inherited from `en_GB`)
- **Indonesian** currency format (IDR/Rp)
- **International** business standards (ISO 8601 dates, Anglo number formatting, 24-hour time)

### Who needs this?

- International businesses operating in Indonesia
- Indonesian professionals working in English
- Software systems requiring English UI with Indonesian regional settings
- Educational institutions using English as medium of instruction

## Features

| Category | Setting | Example |
|----------|---------|---------|
| **Language** | English (British spelling) | colour, centre |
| **Currency** | Indonesian Rupiah | Rp1,234,567.89 |
| **Numbers** | Decimal point, comma separator | 1,234,567.89 |
| **Date** | ISO 8601 format | 2024-01-15 |
| **DateTime** | ISO with weekday | Mon 2024-01-15 14:30:45 |
| **Time** | 24-hour default, 12-hour available | 14:30:45 / 2:30:45 PM |
| **Week** | ISO 8601 numbering, Monday start | Week 1 contains first Thursday |
| **Paper** | A4 (297×210mm) | - |
| **Measurement** | Metric | - |
| **Country Code** | +62, RI | - |

## Quick Start

Install en_ID as your system default locale with one command:

### Ubuntu/Debian
```bash
wget -O- https://raw.githubusercontent.com/Open-Technology-Foundation/en_ID/main/install-ubuntu.sh | sudo bash
```

### Fedora/RHEL/CentOS/Rocky/AlmaLinux
```bash
wget -O- https://raw.githubusercontent.com/Open-Technology-Foundation/en_ID/main/install-fedora.sh | sudo bash
```

### Arch Linux
```bash
wget -O- https://raw.githubusercontent.com/Open-Technology-Foundation/en_ID/main/install-arch.sh | sudo bash
```

### Ensure Persistence (All Distributions)

If you've already installed en_ID and want to ensure it persists through system updates:

```bash
# Download and run the persistence script
wget https://raw.githubusercontent.com/Open-Technology-Foundation/en_ID/main/ensure-persistence.sh
sudo bash ensure-persistence.sh
```

## Installation

### Automated Installation

The installation scripts provide a fully automated setup that:
- Installs the en_ID locale files
- Generates the compiled locale
- Automatically sets en_ID as the system default locale
- Backs up existing locale settings before making changes
- Updates SSH configuration for locale support
- Configures environment files for application compatibility
- Runs verification tests to ensure proper installation
- Sets up persistence mechanisms to prevent removal during system updates
- Includes error handling for network and installation issues

The scripts automatically configure all locale categories (LC_ALL, LC_CTYPE, LC_NUMERIC, etc.) for comprehensive system-wide support. The repository URL can be customized by setting the `EN_ID_REPO_URL` environment variable.

### Manual Installation

<details>
<summary>Ubuntu/Debian</summary>

```bash
# Clone repository
git clone https://github.com/Open-Technology-Foundation/en_ID.git
cd en_ID

# Install
sudo make install

# Verify
locale -a | grep en_ID
```
</details>

<details>
<summary>Fedora/RHEL/CentOS</summary>

```bash
# Clone repository
git clone https://github.com/Open-Technology-Foundation/en_ID.git
cd en_ID

# Install locale file
sudo cp localedata/en_ID /usr/share/i18n/locales/

# Generate locale
sudo localedef -i en_ID -f UTF-8 en_ID.UTF-8

# Set as default (optional)
sudo localectl set-locale LANG=en_ID.UTF-8
```
</details>

<details>
<summary>Arch Linux</summary>

```bash
# Clone repository
git clone https://github.com/Open-Technology-Foundation/en_ID.git
cd en_ID

# Install locale file
sudo cp localedata/en_ID /usr/share/i18n/locales/

# Add to locale.gen
echo "en_ID.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen

# Generate locale
sudo locale-gen

# Set as default (optional)
echo "LANG=en_ID.UTF-8" | sudo tee /etc/locale.conf
```
</details>

**Note**: Systems may display the locale as `en_ID.utf8` or `en_ID.UTF-8`. Both refer to the same locale.

## Usage

### Set as System Default
```bash
# Ubuntu/Debian
sudo update-locale LANG=en_ID.UTF-8 LC_ALL=en_ID.UTF-8

# Fedora/RHEL
sudo localectl set-locale LANG=en_ID.UTF-8

# Arch Linux
echo "LANG=en_ID.UTF-8" | sudo tee /etc/locale.conf
```

### Use in Current Session
```bash
export LANG=en_ID.UTF-8
export LC_ALL=en_ID.UTF-8
```

### Use for Single Application
```bash
LC_ALL=en_ID.UTF-8 your-application
```

**Important**: Use `LC_ALL` to ensure all locale categories use en_ID. Using only `LANG` may result in some categories falling back to system defaults.

## Testing

### Run Full Test Suite

```bash
# Run all tests (47 tests across 10 categories)
make test

# Test specific categories
./tests/test_en_ID.sh LC_TIME
./tests/test_en_ID.sh LC_TIME_EXT    # Extended: week, am_pm, datetime
./tests/test_en_ID.sh LC_MONETARY
./tests/test_en_ID.sh LC_NUMERIC
./tests/test_en_ID.sh LC_ADDRESS
./tests/test_en_ID.sh LC_TELEPHONE
./tests/test_en_ID.sh LC_NAME
```

### Manual Verification

```bash
# Check if installed
locale -a | grep en_ID

# Test date format (should show: 2024-01-15)
LC_ALL=en_ID.UTF-8 date +%x

# Test datetime format (should show: Fri 2024-01-15 14:30:45)
LC_ALL=en_ID.UTF-8 date -d "2024-01-15 14:30:45" +%c

# Test time format (should show: 14:30:45)
LC_ALL=en_ID.UTF-8 date +%X

# Test 12-hour format (should show: 02:30:45 PM)
LC_ALL=en_ID.UTF-8 date -d "14:30:45" +%r

# Test currency (number formatting)
LC_MONETARY=en_ID.UTF-8 printf "%'.2f\n" 1234567.89
# Output: 1,234,567.89

# Test full date with day name
LC_ALL=en_ID.UTF-8 date +"%x = %A, %d %B %Y"
# Output: 2024-01-15 = Monday, 15 January 2024

# Show all locale settings
LC_ALL=en_ID.UTF-8 locale
```

## Design Decisions

### LC_NAME: Minimal Definition

The LC_NAME category uses a minimal definition because Indonesian naming conventions don't map well to Western name formatting:

- **Single names** are common (Sukarno, Suharto, Junarti)
- **Name origins** vary widely (Javanese, Balinese, Chinese, Arabic)
- **Titles** like Pak/Bu are Indonesian, not English
- **English contexts** typically use Mr./Ms. anyway

The provided `name_fmt` supports basic English formal contexts while avoiding misrepresentation of Indonesian naming patterns.

### Indonesian Standards Adopted

The en_ID locale adopts these standards from Indonesia:

- **Currency**: Indonesian Rupiah (IDR/Rp) with standard positioning
- **Country Codes**: ID (alpha-2), IDN (alpha-3), 360 (numeric), RI (vehicle registration)
- **Telephone**: +62 country code, 00 international access, domestic format with area codes
- **Address**: Indonesian postal format with full country and language metadata
- **Paper Size**: A4 (297×210mm)
- **Measurement**: Metric system
- **Week Start**: Monday (ISO 8601 week numbering)

### International Standards Used

Rather than traditional Indonesian formats, en_ID uses:
- **Dates**: ISO 8601 (YYYY-MM-DD) instead of Indonesian DD/MM/YYYY
- **DateTime**: ISO 8601 date with weekday prefix (Mon 2024-01-15 14:30:45)
- **Time**: 24-hour format by default; 12-hour format available via `%r` for compatibility
- **Week Numbering**: ISO 8601 (week 1 contains the first Thursday)
- **Numbers**: Anglo format (1,234.56) instead of Indonesian (1.234,56)
- **Language**: English (inherited from en_GB and en_SG)

This design prioritizes international compatibility for English-language business and technical contexts.

### British vs American English

British English was chosen because:
- It's the standard in Indonesian education
- Used by neighboring Singapore and Malaysia
- Common in Commonwealth countries

### Modern UTF-8 Format

The locale definition uses direct UTF-8 text format instead of legacy Unicode code points:
- **Direct text**: `currency_symbol "Rp"` instead of `<U0052><U0070>`
- **Improved readability**: Day names like `"Monday"` are immediately recognizable
- **Easier maintenance**: No need to look up Unicode tables
- **Consistent with modern locales**: Follows the same format as en_GB, en_US, etc.

### Locale Categories Reference

| Category | Description |
|----------|-------------|
| LC_CTYPE | Character classification (inherited from en_GB) |
| LC_COLLATE | String collation order (ISO 14651) |
| LC_MONETARY | Currency: IDR/Rp, decimal point, comma grouping |
| LC_NUMERIC | Numbers: decimal point, comma separator |
| LC_TIME | Date/time: ISO 8601, 24h default, 12h available, ISO week numbering |
| LC_MESSAGES | Yes/no expressions (inherited from en_SG) |
| LC_PAPER | A4 paper size (297x210mm) |
| LC_NAME | Minimal name formatting for English contexts |
| LC_ADDRESS | Indonesian country codes (ID, IDN, RI), English language codes |
| LC_TELEPHONE | +62 prefix, 00 international access, domestic format |
| LC_MEASUREMENT | Metric system |

## Building from Source

```bash
# Clone the repository
git clone https://github.com/Open-Technology-Foundation/en_ID.git
cd en_ID

# Check syntax and compile
make

# Run tests
make test

# Install system-wide (requires sudo)
sudo make install

# Install with persistence (prevents removal on system updates)
sudo make install-persistent

# Uninstall the locale
sudo make uninstall

# Clean build artifacts
make clean

# Show available make targets
make help

# Display locale information
make info
```

## Troubleshooting

### Locale disappears after system updates

If the en_ID locale disappears after system updates (showing errors like `cannot change locale (en_ID.UTF-8): No such file or directory`), this is likely because the locale was removed when glibc or locale packages were updated.

#### Quick Fix

Run the persistence script to set up automatic regeneration:

```bash
sudo ./ensure-persistence.sh
```

This script will:
- Add en_ID to `/etc/locale.gen` (Debian/Ubuntu/Arch)
- Create package manager hooks to automatically regenerate the locale after updates
- Regenerate the locale immediately

#### Manual Fix

If you prefer to fix it manually:

```bash
# Regenerate the locale
sudo localedef -i en_ID -f UTF-8 en_ID.UTF-8

# Ensure persistence for Debian/Ubuntu
echo "en_ID.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
sudo locale-gen

# Create APT hook for automatic regeneration (Debian/Ubuntu)
echo 'DPkg::Post-Invoke { "if [ -f /etc/locale.gen ] && grep -q \"^en_ID.UTF-8\" /etc/locale.gen; then locale-gen en_ID.UTF-8 2>/dev/null || true; fi"; };' | sudo tee /etc/apt/apt.conf.d/99en-id-locale-gen
```

#### Prevention

The updated installation scripts now include persistence mechanisms by default. If you installed en_ID before this update, run:

```bash
# Using make
sudo make install-persistent

# Or using the persistence script
sudo ./ensure-persistence.sh
```

### Locale not taking effect

If you've installed the locale but it's not taking effect:

1. **Log out and log back in** - Session variables need to be reloaded
2. **For SSH sessions** - Disconnect and reconnect
3. **Check your shell configuration** - Ensure no conflicting LANG/LC_* variables in `~/.bashrc` or `~/.profile`
4. **Verify with**: `locale` command should show en_ID.UTF-8

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes to `localedata/en_ID`
4. Run `make test` to verify your changes
5. Submit a pull request

### Reporting Issues

Please report bugs or suggestions via [GitHub Issues](https://github.com/Open-Technology-Foundation/en_ID/issues).

## License

This locale definition is released under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.

## Author

Created and maintained by [Yayasan Teknologi Terbuka Indonesia](https://yatti.id) (Indonesian Open Technology Foundation).

Contact: admin@yatti.id

## See Also

- [GNU C Library Locales](https://www.gnu.org/software/libc/manual/html_node/Locales.html)
- [ISO 639 Language Codes](https://www.loc.gov/standards/iso639-2/)
- [ISO 3166 Country Codes](https://www.iso.org/iso-3166-country-codes.html)
- [Unicode CLDR](http://cldr.unicode.org/)
