### Command Substitution

Command substitution replaces a command with its standard output:

 $(command)

Bash executes command in a subshell and substitutes the output, with trailing newlines deleted. Embedded newlines are preserved but may be removed during word splitting.

The form $(< file) is equivalent to $(cat file) but faster, as it reads the file directly without spawning a subprocess.

All characters between the parentheses form the command; none are treated specially. Command substitutions nest naturally:

 result=$(echo $(date +%Y))

Within double quotes, the result is not subject to word splitting or pathname expansion.
