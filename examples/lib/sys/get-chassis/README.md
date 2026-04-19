# get-chassis

Return the chassis type of the current machine (e.g., `laptop`, `desktop`, `tablet`).

Can be sourced as a library function or run as a standalone script. When given
type arguments, exits 0 on match (case-insensitive) — useful for conditional
logic in other scripts.

## Features

- Detects chassis via `hostnamectl` (systemd), with automatic fallback to
  SMBIOS `/sys/class/dmi/id/chassis_type`
- Maps all 36 SMBIOS chassis type codes to human-readable strings
- Case-insensitive type matching with multiple arguments
- Works as both a sourceable library (`declare -fx get_chassis`) and a CLI tool

## Requirements

- **Bash** 4.4+
- **Linux** with systemd or DMI/SMBIOS support
- **jq** (optional — falls back to SMBIOS if unavailable)

## Quick Install

```bash
sudo make install
```

## Installation

```bash
git clone https://github.com/OkusiAssociates/get-chassis.git
cd get-chassis
sudo make install
```

To install to a custom prefix:

```bash
sudo make PREFIX=/opt/local install
```

### Makefile Targets

| Target | Description |
|--------|-------------|
| `install` | Install script and manpage to `$(PREFIX)` |
| `uninstall` | Remove installed files |
| `check` | Verify installation |
| `test` | Run test suite |
| `help` | Show available targets (default) |

## Usage

```bash
# Print chassis type
get-chassis

# Test against one or more types (exit 0 on match)
get-chassis laptop notebook

# Use in conditionals
get-chassis desktop && echo "This is a desktop"

# Source as a library
source get-chassis
get_chassis laptop && echo "Running on a laptop"
```

### Options

| Option | Description |
|--------|-------------|
| `-V, --version` | Show version |
| `-h, --help` | Show help |

### Valid Chassis Types

`other`, `unknown`, `desktop`, `low-profile-desktop`, `pizza-box`,
`mini-tower`, `tower`, `portable`, `laptop`, `notebook`, `hand-held`,
`docking-station`, `all-in-one`, `sub-notebook`, `space-saving`,
`lunch-box`, `main-server-chassis`, `expansion-chassis`, `sub-chassis`,
`bus-expansion-chassis`, `peripheral-chassis`, `raid-chassis`,
`rack-mount-chassis`, `sealed-case-pc`, `multi-system-chassis`,
`compact-pci`, `advanced-tca`, `blade`, `blade-enclosure`, `tablet`,
`convertible`, `detachable`, `iot-gateway`, `embedded-pc`, `mini-pc`,
`stick-pc`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[GNU General Public License v3.0](LICENSE)

## Authors

Gary Dean, Biksu Okusi

## Links

- GitHub: https://github.com/OkusiAssociates/get-chassis
