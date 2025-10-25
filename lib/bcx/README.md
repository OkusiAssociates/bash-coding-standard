# bcx

**Terminal calculator for floating-point expressions with interactive REPL**

A Bash wrapper around `bc` that fixes its poor terminal UX by providing readline history, proper Ctrl-C handling, and a clean REPL interface.

**GitHub**: [Open-Technology-Foundation/bcx](https://github.com/Open-Technology-Foundation/bcx)

## Features

- **Interactive REPL** with readline history (arrow keys, Ctrl-R search)
- **Single-expression mode** for quick calculations
- **Persistent command history** (`~/.bcx_history`)
- **x → * conversion** in terminal mode (e.g., `3x4` becomes `3*4`)
- **Clean error handling** with clear feedback
- **Math library** support (sqrt, sin, cos, etc.)

## Installation

```bash
# Copy to system path
sudo cp bcx /usr/local/bin/
sudo chmod +x /usr/local/bin/bcx

# Optional: Install bash completion
sudo cp .bash_completion /etc/bash_completion.d/bcx

# Optional: Create alias for quick access
echo "alias ?='bcx'" >> ~/.bashrc
```

## Usage

**Single-expression evaluation:**
```bash
bcx "3.14 * 2"              # 6.28
bcx "sqrt(144)"             # 12
bcx 42x72/3.14              # x converts to * in terminal mode
```

**Interactive REPL:**
```bash
$ bcx
> 2 + 2
4
> sqrt(16)
4
> ^D
```

**As command alias:**
```bash
? 23x42                     # Quick calculation
? "scale=4; 22/7"           # Pi approximation
```

**In scripts (non-terminal mode):**
```bash
result=$(bcx "42 * 72 / 3.14")
echo "Result: $result"
```

## Requirements

- Bash 4.0+
- `bc` command-line calculator
- Linux/Unix terminal with readline support

## BCS Compliance

This script follows the [Bash Coding Standard](https://github.com/Open-Technology-Foundation/bash-coding-standard) with proper error handling, readonly constants, and structured organization.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

GNU General Public License v3.0 - see [LICENSE](LICENSE).

## Author

Gary Dean | [garydean.id](https://garydean.id)
