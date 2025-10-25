# printline

Bash utility to draw a line from the cursor to the end of terminal.

## Usage

```bash
printline [char [text]]
```

- `char` - any single printable character (default: `-`)
- `text` - text to print before the line chars

## Examples

```bash
printline
printline '='
echo -n "123 abc "; printline '#'
printline '*' '# topic header '
printline '=' '    ## section 1 '
printline '-' '        ### subsection 1 '
```

## Source as Function

```bash
source /path/to/printline
printline '-' 'Section: '
```

## Installation

```bash
cp printline /usr/local/bin/
chmod +x /usr/local/bin/printline
```

## License

GPL-3.0 - see [LICENSE](LICENSE)
