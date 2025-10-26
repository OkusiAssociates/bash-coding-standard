# Quoting & String Literals

This section establishes critical quoting rules that prevent word-splitting errors and clarify code intent. The fundamental principle: single quotes (`'...'`) for static string literals, double quotes (`"..."`) when variable expansion, command substitution, or escape sequences are needed. Single quotes signal "literal text" while double quotes signal "shell processing needed"this semantic distinction helps both developers and AI assistants understand code intent immediately.

## Core Principles

**Default behaviors:**
- Static strings: single quotes (`'Processing data'`)
- Variable content: double quotes (`"Found $count items"`)
- One-word literals: may be unquoted, but quoting is defensive
- Conditionals: always quote variables (`[[ -f "$file" ]]`)
- Arrays: always quote expansions (`"${array[@]}"`)

**Semantic clarity:** Quote choice documents intent. Single quotes mean "no shell processing", double quotes mean "shell processing required".

## Rule Coverage

1. Static strings and constants
2. One-word literals (unquoted vs quoted trade-offs)
3. Strings containing variables
4. Mixed quoting techniques
5. Command substitution in strings
6. Variables in conditionals (always quote)
7. Array expansions (always quote)
8. Here documents (quoted vs unquoted delimiters)
9. Echo and printf statements
10. Common anti-patterns to avoid
11. String trimming operations
12. Displaying declared variables
13. Pluralization helpers
14. Escape sequences and special characters

Single-quoted strings are literalno variable expansion, no command substitution, no escape sequences (except `'\''` for embedded single quote). Double-quoted strings enable shell processing: variables expand, commands substitute, escape sequences work (`\n`, `\t`, `\\`, `\"`). The choice between them communicates whether shell interpretation is intended, making maintenance clearer and preventing word-splitting bugs.
