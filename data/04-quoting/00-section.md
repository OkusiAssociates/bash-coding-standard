## Quoting & String Literals

**General Principle:** Use single quotes (`'...'`) for static string literals. Use double quotes (`"..."`) only when variable expansion, command substitution, or escape sequences are needed.

**Rationale:** Single quotes prevent any interpretation by the shell, making them safer and clearer for literal strings. Double quotes should signal "this string needs shell processing" to both programmers and AI assistants.
